.syntax unified                       /* Sintaxis ARM. */
.cpu cortex-m0plus                    /* RP2040 Cortex-M0+. */
.thumb                                /* Thumb-1. */
#include "rp2040_defs.h"             /* Registros y colores. */

.section .text.tft_rp2040,"ax",%progbits /* Controlador TFT en ensamblador. */
.thumb_func
.global tft_cmd
tft_cmd:                              /* r0=comando de ocho bits. */
  push {r4,lr}                        /* Conserva comando y retorno. */
  mov r4,r0                           /* Guarda comando. */
  ldr r1,=SIO_BASE                    /* Base SIO. */
  ldr r2,=(TFT_DC_MASK | TFT_CS_MASK) /* Baja DC y CS. */
  str r2,[r1,#SIO_GPIO_OUT_CLR]       /* Selecciona comando. */
  mov r0,r4                           /* Recupera comando. */
  bl spi_write8                       /* Transmite. */
  ldr r1,=SIO_BASE                    /* Base SIO. */
  ldr r2,=TFT_CS_MASK                 /* Máscara CS. */
  str r2,[r1,#SIO_GPIO_OUT_SET]       /* Libera TFT. */
  pop {r4,pc}                         /* Regresa. */

.ltorg
.thumb_func
.global tft_data8
tft_data8:                            /* r0=dato de ocho bits. */
  push {r4,lr}                        /* Conserva dato. */
  mov r4,r0                           /* Guarda dato. */
  ldr r1,=SIO_BASE                    /* Base SIO. */
  ldr r2,=TFT_DC_MASK                 /* Máscara DC. */
  str r2,[r1,#SIO_GPIO_OUT_SET]       /* Selecciona datos. */
  ldr r2,=TFT_CS_MASK                 /* Máscara CS. */
  str r2,[r1,#SIO_GPIO_OUT_CLR]       /* Selecciona TFT. */
  mov r0,r4                           /* Recupera dato. */
  bl spi_write8                       /* Transmite. */
  ldr r1,=SIO_BASE                    /* Base SIO. */
  ldr r2,=TFT_CS_MASK                 /* Máscara CS. */
  str r2,[r1,#SIO_GPIO_OUT_SET]       /* Libera TFT. */
  pop {r4,pc}                         /* Regresa. */

.ltorg
.thumb_func
.global tft_init_asm
tft_init_asm:                         /* Reinicia e inicializa ILI9341. */
  push {r4,lr}                        /* Conserva registros. */
  ldr r1,=SIO_BASE                    /* Base SIO. */
  ldr r2,=TFT_RST_MASK                /* Máscara reset. */
  str r2,[r1,#SIO_GPIO_OUT_CLR]       /* Reset bajo. */
  movs r0,#50                         /* Espera 50 ms. */
  bl delay_ms_asm                     /* Mantiene reset. */
  ldr r1,=SIO_BASE                    /* Recupera base. */
  ldr r2,=TFT_RST_MASK                /* Máscara. */
  str r2,[r1,#SIO_GPIO_OUT_SET]       /* Libera reset. */
  movs r0,#150                        /* Espera encendido. */
  bl delay_ms_asm                     /* Retardo. */
  movs r0,#0x01                       /* Software reset. */
  bl tft_cmd                          /* Envía. */
  movs r0,#150                        /* Espera. */
  bl delay_ms_asm                     /* Retardo. */
  movs r0,#0x11                       /* Sleep out. */
  bl tft_cmd                          /* Envía. */
  movs r0,#150                        /* Espera. */
  bl delay_ms_asm                     /* Retardo. */
  movs r0,#0x3A                       /* Pixel format. */
  bl tft_cmd                          /* Envía comando. */
  movs r0,#0x55                       /* RGB565. */
  bl tft_data8                        /* Envía dato. */
  movs r0,#0x36                       /* MADCTL. */
  bl tft_cmd                          /* Envía. */
  movs r0,#0x08                       /* Retrato, BGR, sin espejo. */
  bl tft_data8                        /* Envía. */
  movs r0,#0x13                       /* Normal display. */
  bl tft_cmd                          /* Envía. */
  movs r0,#0x20                       /* Inversión desactivada. */
  bl tft_cmd                          /* Envía. */
  movs r0,#0x29                       /* Display on. */
  bl tft_cmd                          /* Enciende imagen. */
  movs r0,#80                         /* Espera final. */
  bl delay_ms_asm                     /* Retardo. */
  pop {r4,pc}                         /* Regresa. */

.ltorg
.thumb_func
tft_send16:                           /* r0=valor; envía byte alto y bajo como datos. */
  push {r4,lr}                        /* Conserva valor. */
  mov r4,r0                           /* Guarda valor. */
  lsrs r0,r0,#8                       /* Obtiene byte alto. */
  bl spi_write8                       /* Envía alto con TFT ya seleccionada. */
  mov r0,r4                           /* Recupera valor. */
  movs r1,#0xFF                       /* Máscara byte bajo. */
  ands r0,r1                          /* Obtiene bajo. */
  bl spi_write8                       /* Envía bajo. */
  pop {r4,pc}                         /* Regresa. */

.ltorg
.thumb_func
tft_window:                           /* r0=x0,r1=y0,r2=x1,r3=y1. */
  push {r4-r7,lr}                     /* Conserva coordenadas. */
  mov r4,r0                           /* Guarda x0. */
  mov r5,r1                           /* Guarda y0. */
  mov r6,r2                           /* Guarda x1. */
  mov r7,r3                           /* Guarda y1. */
  movs r0,#0x2A                       /* CASET. */
  bl tft_cmd                          /* Selecciona columnas. */
  ldr r1,=SIO_BASE                    /* Base SIO. */
  ldr r2,=TFT_DC_MASK                 /* DC alto. */
  str r2,[r1,#SIO_GPIO_OUT_SET]       /* Datos. */
  ldr r2,=TFT_CS_MASK                 /* CS bajo. */
  str r2,[r1,#SIO_GPIO_OUT_CLR]       /* Selecciona. */
  mov r0,r4                           /* x0. */
  bl tft_send16                       /* Envía. */
  mov r0,r6                           /* x1. */
  bl tft_send16                       /* Envía. */
  ldr r1,=SIO_BASE                    /* Base. */
  ldr r2,=TFT_CS_MASK                 /* CS. */
  str r2,[r1,#SIO_GPIO_OUT_SET]       /* Libera. */
  movs r0,#0x2B                       /* PASET. */
  bl tft_cmd                          /* Selecciona filas. */
  ldr r1,=SIO_BASE                    /* Base. */
  ldr r2,=TFT_DC_MASK                 /* DC alto. */
  str r2,[r1,#SIO_GPIO_OUT_SET]       /* Datos. */
  ldr r2,=TFT_CS_MASK                 /* CS bajo. */
  str r2,[r1,#SIO_GPIO_OUT_CLR]       /* Selecciona. */
  mov r0,r5                           /* y0. */
  bl tft_send16                       /* Envía. */
  mov r0,r7                           /* y1. */
  bl tft_send16                       /* Envía. */
  ldr r1,=SIO_BASE                    /* Base. */
  ldr r2,=TFT_CS_MASK                 /* CS. */
  str r2,[r1,#SIO_GPIO_OUT_SET]       /* Libera. */
  movs r0,#0x2C                       /* RAMWR. */
  bl tft_cmd                          /* Inicia memoria. */
  pop {r4-r7,pc}                      /* Regresa. */

.ltorg
.thumb_func
.global tft_fill_rect
tft_fill_rect:                        /* r0=x,r1=y,r2=w,r3=h,color en pila. */
  push {r4-r7,lr}                     /* Conserva registros; color queda en sp+20. */
  mov r4,r2                           /* Guarda ancho. */
  mov r5,r3                           /* Guarda alto. */
  ldr r6,[sp,#20]                     /* Lee color RGB565. */
  cmp r4,#0                           /* Comprueba ancho. */
  beq 9f                              /* Termina vacío. */
  cmp r5,#0                           /* Comprueba alto. */
  beq 9f                              /* Termina vacío. */
  adds r2,r0,r4                       /* x+w. */
  subs r2,#1                          /* x1. */
  adds r3,r1,r5                       /* y+h. */
  subs r3,#1                          /* y1. */
  bl tft_window                       /* Configura ventana. */
  ldr r1,=SIO_BASE                    /* Base SIO. */
  ldr r2,=TFT_DC_MASK                 /* DC alto. */
  str r2,[r1,#SIO_GPIO_OUT_SET]       /* Datos. */
  ldr r2,=TFT_CS_MASK                 /* CS bajo. */
  str r2,[r1,#SIO_GPIO_OUT_CLR]       /* Selecciona TFT. */
  mov r7,r4                           /* Copia ancho. */
  muls r7,r5                          /* Cantidad de píxeles. */
1:mov r0,r6                           /* Pasa color. */
  bl tft_send16                       /* Envía píxel. */
  subs r7,#1                          /* Reduce contador. */
  bne 1b                              /* Repite. */
  ldr r1,=SIO_BASE                    /* Base. */
  ldr r2,=TFT_CS_MASK                 /* CS. */
  str r2,[r1,#SIO_GPIO_OUT_SET]       /* Libera TFT. */
9:pop {r4-r7,pc}                      /* Regresa. */

.ltorg
.thumb_func
.global tft_clear
tft_clear:                            /* r0=color de pantalla completa. */
  push {r4,lr}                        /* Conserva color. */
  mov r4,r0                           /* Guarda color. */
  movs r0,#0                          /* X. */
  movs r1,#0                          /* Y. */
  movs r2,#240                        /* Ancho. */
  ldr r3,=320                         /* Alto. */
  push {r4}                           /* Pasa color. */
  bl tft_fill_rect                    /* Limpia pantalla. */
  add sp,#4                           /* Retira argumento. */
  pop {r4,pc}                         /* Regresa. */
