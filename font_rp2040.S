.syntax unified                       /* Sintaxis ARM. */
.cpu cortex-m0plus                    /* RP2040. */
.thumb                                /* Thumb compatible. */
#include "rp2040_defs.h"             /* Archivo reconocido por Arduino IDE. */

.section .text.font_rp2040,"ax",%progbits /* Rutinas de texto en ensamblador. */
.thumb_func
.global draw_text
draw_text:                            /* r0=X,r1=Y,r2=cadena,r3=color; escala 2. */
  push {r4-r7,lr}                     /* Conserva estado. */
  mov r4,r0                           /* Guarda X actual. */
  mov r5,r1                           /* Guarda Y. */
  mov r6,r2                           /* Guarda puntero. */
  mov r7,r3                           /* Guarda color. */
1:ldrb r2,[r6]                        /* Lee carácter. */
  cmp r2,#0                           /* Comprueba fin. */
  beq 2f                              /* Termina. */
  adds r6,#1                          /* Avanza cadena. */
  mov r0,r4                           /* Pasa X. */
  mov r1,r5                           /* Pasa Y. */
  mov r3,r7                           /* Pasa color. */
  bl draw_char                        /* Dibuja carácter. */
  adds r4,#12                         /* Avanza seis columnas a escala 2. */
  b 1b                                /* Repite. */
2:pop {r4-r7,pc}                      /* Regresa. */

.ltorg                                /* Acerca la tabla literal al código Thumb-1. */
.thumb_func
draw_char:                            /* r0=X,r1=Y,r2=ASCII,r3=color. */
  push {r4-r7,lr}                     /* Conserva estado. */
  mov r4,r0                           /* Guarda X. */
  mov r5,r1                           /* Guarda Y. */
  mov r7,r3                           /* Guarda color. */
  cmp r2,#32                          /* Espacio. */
  beq 9f                              /* No dibuja. */
  cmp r2,#45                          /* Guion. */
  bne 1f                              /* Continúa a fuente. */
  mov r0,r4                           /* X. */
  adds r1,r5,#6                       /* Y central. */
  movs r2,#10                         /* Ancho. */
  movs r3,#2                          /* Alto. */
  push {r7}                           /* Pasa color. */
  bl tft_fill_rect                    /* Dibuja guion. */
  add sp,#4                           /* Limpia argumento. */
  b 9f                                /* Termina. */
1:cmp r2,#48                          /* Primer dígito. */
  blo 9f                              /* Ignora anterior. */
  cmp r2,#57                          /* Último dígito. */
  bhi 2f                              /* Prueba letra. */
  subs r2,#48                         /* Índice 0..9. */
  b 3f                                /* Busca glyph. */
2:cmp r2,#65                          /* Primera letra. */
  blo 9f                              /* Ignora. */
  cmp r2,#90                          /* Última letra. */
  bhi 9f                              /* Ignora. */
  subs r2,#65                         /* Índice A..Z. */
  adds r2,#10                         /* Después de dígitos. */
3:movs r0,#5                          /* Cinco bytes por glyph. */
  muls r2,r0                          /* Calcula desplazamiento. */
  ldr r6,=font5x7                     /* Base de fuente. */
  adds r6,r6,r2                       /* Apunta al glyph. */
  movs r0,#0                          /* Columna cero. */
4:ldrb r2,[r6,r0]                     /* Lee bits verticales. */
  movs r1,#0                          /* Fila cero. */
5:movs r3,#1                          /* Máscara inicial. */
  lsls r3,r1                          /* Desplaza hasta fila. */
  tst r2,r3                           /* Comprueba píxel. */
  beq 6f                              /* Salta píxel apagado. */
  push {r0-r3}                        /* Conserva bucles. */
  lsls r0,r0,#1                       /* Columna por dos. */
  adds r0,r4,r0                       /* X final. */
  lsls r1,r1,#1                       /* Fila por dos. */
  adds r1,r5,r1                       /* Y final. */
  movs r2,#2                          /* Ancho del punto. */
  movs r3,#2                          /* Alto del punto. */
  push {r7}                           /* Pasa color. */
  bl tft_fill_rect                    /* Dibuja punto. */
  add sp,#4                           /* Limpia color. */
  pop {r0-r3}                         /* Recupera bucles. */
6:adds r1,#1                          /* Siguiente fila. */
  cmp r1,#7                           /* Siete filas. */
  blo 5b                              /* Repite. */
  adds r0,#1                          /* Siguiente columna. */
  cmp r0,#5                           /* Cinco columnas. */
  blo 4b                              /* Repite. */
9:pop {r4-r7,pc}                      /* Regresa. */

.section .rodata.font5x7,"a",%progbits /* Fuente constante. */
.align 2
font5x7:
 .byte 0x3E,0x51,0x49,0x45,0x3E, 0x00,0x42,0x7F,0x40,0x00 /* 0,1 */
 .byte 0x42,0x61,0x51,0x49,0x46, 0x21,0x41,0x45,0x4B,0x31 /* 2,3 */
 .byte 0x18,0x14,0x12,0x7F,0x10, 0x27,0x45,0x45,0x45,0x39 /* 4,5 */
 .byte 0x3C,0x4A,0x49,0x49,0x30, 0x01,0x71,0x09,0x05,0x03 /* 6,7 */
 .byte 0x36,0x49,0x49,0x49,0x36, 0x06,0x49,0x49,0x29,0x1E /* 8,9 */
 .byte 0x7E,0x11,0x11,0x11,0x7E, 0x7F,0x49,0x49,0x49,0x36 /* A,B */
 .byte 0x3E,0x41,0x41,0x41,0x22, 0x7F,0x41,0x41,0x22,0x1C /* C,D */
 .byte 0x7F,0x49,0x49,0x49,0x41, 0x7F,0x09,0x09,0x09,0x01 /* E,F */
 .byte 0x3E,0x41,0x49,0x49,0x7A, 0x7F,0x08,0x08,0x08,0x7F /* G,H */
 .byte 0x00,0x41,0x7F,0x41,0x00, 0x20,0x40,0x41,0x3F,0x01 /* I,J */
 .byte 0x7F,0x08,0x14,0x22,0x41, 0x7F,0x40,0x40,0x40,0x40 /* K,L */
 .byte 0x7F,0x02,0x0C,0x02,0x7F, 0x7F,0x04,0x08,0x10,0x7F /* M,N */
 .byte 0x3E,0x41,0x41,0x41,0x3E, 0x7F,0x09,0x09,0x09,0x06 /* O,P */
 .byte 0x3E,0x41,0x51,0x21,0x5E, 0x7F,0x09,0x19,0x29,0x46 /* Q,R */
 .byte 0x46,0x49,0x49,0x49,0x31, 0x01,0x01,0x7F,0x01,0x01 /* S,T */
 .byte 0x3F,0x40,0x40,0x40,0x3F, 0x1F,0x20,0x40,0x20,0x1F /* U,V */
 .byte 0x7F,0x20,0x18,0x20,0x7F, 0x63,0x14,0x08,0x14,0x63 /* W,X */
 .byte 0x03,0x04,0x78,0x04,0x03, 0x61,0x51,0x49,0x45,0x43 /* Y,Z */
