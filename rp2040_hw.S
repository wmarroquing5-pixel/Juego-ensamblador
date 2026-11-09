.syntax unified                       /* Sintaxis ARM unificada. */
.cpu cortex-m0plus                    /* Núcleo real del RP2040. */
.thumb                                /* Instrucciones Thumb compatibles con M0+. */
#include "rp2040_defs.h"             /* Arduino IDE sí copia encabezados .h. */

.section .text.rp2040_hw,"ax",%progbits /* Código de acceso directo al hardware. */
.thumb_func
.global rp2040_hw_init
rp2040_hw_init:                       /* Configura GPIO */
  push {r4-r7,lr}                     /* Conserva registros. */
  ldr r4,=IO_BANK0_BASE               /* Base de funciones GPIO. */
  movs r0,#5                          /* Función SIO. */
  ldr r1,=(4 + 8*17)                  /* Desplazamiento CTRL de GP17. */
  str r0,[r4,r1]                      /* CS como SIO. */
  ldr r1,=(4 + 8*20)                  /* CTRL de GP20. */
  str r0,[r4,r1]                      /* DC como SIO. */
  ldr r1,=(4 + 8*21)                  /* CTRL de GP21. */
  str r0,[r4,r1]                      /* RST como SIO. */
  ldr r1,=(4 + 8*14)                  /* CTRL de GP14. */
  str r0,[r4,r1]                      /* Z como SIO entrada. */
  ldr r1,=(4 + 8*15)                  /* CTRL de GP15. */
  str r0,[r4,r1]                      /* Pulsador como SIO entrada. */
  movs r0,#1                          /* Función SPI0. */
  ldr r1,=(4 + 8*18)                  /* CTRL de GP18. */
  str r0,[r4,r1]                      /* GP18 como SCK. */
  ldr r1,=(4 + 8*19)                  /* CTRL de GP19. */
  str r0,[r4,r1]                      /* GP19 como TX/MOSI. */
  movs r0,#31                         /* Función NULL para analógico. */
  ldr r1,=(4 + 8*26)                  /* CTRL de GP26. */
  str r0,[r4,r1]                      /* GP26 como ADC0. */
  ldr r1,=(4 + 8*27)                  /* CTRL de GP27. */
  str r0,[r4,r1]                      /* GP27 como ADC1. */

  ldr r4,=PADS_BANK0_BASE             /* Base de configuración eléctrica. */
  movs r0,#0x4A                       /* Entrada digital, pull-up y Schmitt. */
  ldr r1,=(4 + 4*14)                  /* PAD GP14. */
  str r0,[r4,r1]                      /* Activa pull-up Z. */
  ldr r1,=(4 + 4*15)                  /* PAD GP15. */
  str r0,[r4,r1]                      /* Activa pull-up pulsador. */
  movs r0,#0x02                       /* Sin entrada digital ni pull para ADC. */
  ldr r1,=(4 + 4*26)                  /* PAD GP26. */
  str r0,[r4,r1]                      /* Protege ADC0. */
  ldr r1,=(4 + 4*27)                  /* PAD GP27. */
  str r0,[r4,r1]                      /* Protege ADC1. */

  ldr r4,=SIO_BASE                    /* Base SIO. */
  ldr r0,=TFT_OUT_MASK                /* Máscara CS, DC y RST. */
  str r0,[r4,#SIO_GPIO_OE_SET]        /* Habilita salidas. */
  ldr r0,=(TFT_CS_MASK | TFT_RST_MASK) /* CS y RST inicialmente altos. */
  str r0,[r4,#SIO_GPIO_OUT_SET]       /* Coloca niveles seguros. */

  ldr r4,=RESETS_BASE                 /* Base de resets. */
  ldr r0,[r4,#RESETS_RESET]           /* Lee registro. */
  ldr r1,=((1 << 16) | 1)             /* SPI0 y ADC. */
  bics r0,r1                          /* Libera ambos resets. */
  str r0,[r4,#RESETS_RESET]           /* Guarda. */
1:ldr r0,[r4,#RESETS_DONE]            /* Consulta periféricos listos. */
  ands r0,r1                          /* Conserva SPI0 y ADC. */
  cmp r0,r1                           /* Comprueba ambos. */
  bne 1b                              /* Espera finalización. */

  ldr r4,=SPI0_BASE                   /* Base SPI0. */
  movs r0,#0                          /* Deshabilita durante configuración. */
  str r0,[r4,#SPI_CR1]                /* Apaga SPI. */
  ldr r0,=0x00000407                  /* 8 bits, modo 0, SCR=4. */
  str r0,[r4,#SPI_CR0]                /* Configura formato. */
  movs r0,#2                          /* CPSR=2: aproximadamente 12.5 MHz. */
  str r0,[r4,#SPI_CPSR]               /* Configura divisor. */
  movs r0,#2                          /* SSE=1, maestro. */
  str r0,[r4,#SPI_CR1]                /* Habilita SPI0. */

  ldr r4,=ADC_BASE                    /* Base ADC. */
  ldr r0,=(1 << 0)                    /* EN=1. */
  str r0,[r4,#ADC_CS]                 /* Habilita ADC. */
2:ldr r0,[r4,#ADC_CS]                 /* Lee estado. */
  movs r1,#1                          /* Máscara READY será cargada aparte. */
  lsls r1,r1,#8                       /* Bit READY=8. */
  tst r0,r1                           /* Prueba listo. */
  beq 2b                              /* Espera. */
  pop {r4-r7,pc}                      /* Regresa. */

.ltorg
.thumb_func
.global spi_write8
spi_write8:                           /* r0=byte; transmite por SPI0. */
  ldr r1,=SPI0_BASE                   /* Base SPI. */
1:ldr r2,[r1,#SPI_SR]                 /* Lee estado. */
  movs r3,#2                          /* TNF: FIFO TX no lleno. */
  tst r2,r3                           /* Comprueba. */
  beq 1b                              /* Espera espacio. */
  str r0,[r1,#SPI_DR]                 /* Envía byte. */
2:ldr r2,[r1,#SPI_SR]                 /* Lee estado. */
  movs r3,#4                          /* RNE: dato recibido. */
  tst r2,r3                           /* Comprueba. */
  beq 2b                              /* Espera fin. */
  ldr r0,[r1,#SPI_DR]                 /* Vacía RX. */
  bx lr                               /* Regresa. */

.ltorg
.thumb_func
.global adc_read_x
adc_read_x:                           /* Devuelve ADC0/GP26 en r0. */
  ldr r1,=ADC_BASE                    /* Base ADC. */
  movs r0,#1                          /* EN=1, AINSEL=0. */
  movs r2,#4                          /* START_ONCE. */
  orrs r0,r2                          /* Inicia conversión. */
  str r0,[r1,#ADC_CS]                 /* Guarda control. */
1:ldr r0,[r1,#ADC_CS]                 /* Lee estado. */
  movs r2,#1                          /* Prepara READY. */
  lsls r2,r2,#8                       /* Bit 8. */
  tst r0,r2                           /* Comprueba listo. */
  beq 1b                              /* Espera. */
  ldr r0,[r1,#ADC_RESULT]             /* Lee resultado 0..4095. */
  bx lr                               /* Regresa. */

.ltorg
.thumb_func
.global button_z
button_z:                             /* Devuelve uno si GP14 está en bajo. */
  ldr r1,=SIO_BASE                    /* Base SIO. */
  ldr r0,[r1,#SIO_GPIO_IN]            /* Lee GPIO. */
  ldr r1,=BTN_Z_MASK                  /* Máscara Z. */
  tst r0,r1                           /* Prueba nivel. */
  beq 1f                              /* Bajo significa pulsado. */
  movs r0,#0                          /* Libre. */
  bx lr                               /* Regresa. */
1:movs r0,#1                          /* Pulsado. */
  bx lr                               /* Regresa. */

.ltorg
.thumb_func
.global button_shield
button_shield:                        /* Devuelve uno si GP15 está en bajo. */
  ldr r1,=SIO_BASE                    /* Base SIO. */
  ldr r0,[r1,#SIO_GPIO_IN]            /* Lee GPIO. */
  ldr r1,=BTN_SHIELD_MASK             /* Máscara pulsador. */
  tst r0,r1                           /* Prueba nivel. */
  beq 1f                              /* Bajo significa pulsado. */
  movs r0,#0                          /* Libre. */
  bx lr                               /* Regresa. */
1:movs r0,#1                          /* Pulsado. */
  bx lr                               /* Regresa. */

.ltorg
.thumb_func
.global delay_ms_asm
delay_ms_asm:                         /* r0=milisegundos aproximados a 125 MHz. */
  cmp r0,#0                           /* Comprueba cero. */
  beq 3f                              /* Termina. */
1:ldr r1,=18000                       /* Iteraciones calibradas aproximadamente. */
2:subs r1,#1                          /* Reduce bucle interno. */
  bne 2b                              /* Repite. */
  subs r0,#1                          /* Reduce milisegundo. */
  bne 1b                              /* Repite. */
3:bx lr                               /* Regresa. */
