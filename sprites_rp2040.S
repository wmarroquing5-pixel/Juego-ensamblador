.syntax unified                       /* Sintaxis ARM. */
.cpu cortex-m0plus                    /* RP2040. */
.thumb                                /* Thumb. */
#include "rp2040_defs.h"             /* Colores. */

.section .text.sprites,"ax",%progbits /* Sprites originales en ensamblador. */
.thumb_func
.global draw_basket
draw_basket:                          /* r0=X,r1=Y; canasta detallada 32x25. */
  push {r4-r7,lr}                     /* Conserva estado. */
  mov r4,r0                           /* Guarda X. */
  mov r5,r1                           /* Guarda Y. */
  adds r0,r4,#4                       /* Asa izquierda. */
  mov r1,r5                           /* Y asa. */
  movs r2,#3                          /* Ancho. */
  movs r3,#10                         /* Alto. */
  ldr r6,=0x8200                      /* Marrón oscuro. */
  push {r6}                           /* Pasa color. */
  bl tft_fill_rect                    /* Dibuja. */
  add sp,#4                           /* Limpia. */
  mov r0,r4                           /* Copia X. */
  adds r0,#25                         /* Asa derecha. */
  mov r1,r5                           /* Y. */
  movs r2,#3                          /* Ancho. */
  movs r3,#10                         /* Alto. */
  push {r6}                           /* Color. */
  bl tft_fill_rect                    /* Dibuja. */
  add sp,#4                           /* Limpia. */
  adds r0,r4,#6                       /* Asa superior. */
  mov r1,r5                           /* Y. */
  movs r2,#20                         /* Ancho. */
  movs r3,#3                          /* Alto. */
  push {r6}                           /* Color. */
  bl tft_fill_rect                    /* Dibuja. */
  add sp,#4                           /* Limpia. */
  mov r0,r4                           /* Borde X. */
  mov r1,r5                           /* Copia Y. */
  adds r1,#9                          /* Borde Y. */
  movs r2,#32                         /* Ancho. */
  movs r3,#4                          /* Alto. */
  push {r6}                           /* Color. */
  bl tft_fill_rect                    /* Dibuja borde. */
  add sp,#4                           /* Limpia. */
  adds r0,r4,#2                       /* Cuerpo. */
  mov r1,r5                           /* Copia Y. */
  adds r1,#13                         /* Y cuerpo. */
  movs r2,#28                         /* Ancho. */
  movs r3,#8                          /* Alto. */
  ldr r7,=C_BROWN                     /* Marrón claro. */
  push {r7}                           /* Color. */
  bl tft_fill_rect                    /* Dibuja cuerpo. */
  add sp,#4                           /* Limpia. */
  adds r0,r4,#5                       /* Base. */
  mov r1,r5                           /* Copia Y. */
  adds r1,#21                         /* Y base. */
  movs r2,#22                         /* Ancho. */
  movs r3,#4                          /* Alto. */
  push {r6}                           /* Oscuro. */
  bl tft_fill_rect                    /* Dibuja base. */
  add sp,#4                           /* Limpia. */
  adds r0,r4,#4                       /* Tejido uno. */
  mov r1,r5                           /* Copia Y. */
  adds r1,#15                         /* Y. */
  movs r2,#24                         /* Ancho. */
  movs r3,#2                          /* Alto. */
  ldr r6,=C_YELLOW                    /* Dorado. */
  push {r6}                           /* Color. */
  bl tft_fill_rect                    /* Dibuja fibra. */
  add sp,#4                           /* Limpia. */
  adds r0,r4,#6                       /* Tejido dos. */
  mov r1,r5                           /* Copia Y. */
  adds r1,#19                         /* Y. */
  movs r2,#20                         /* Ancho. */
  movs r3,#2                          /* Alto. */
  push {r6}                           /* Color. */
  bl tft_fill_rect                    /* Dibuja fibra. */
  add sp,#4                           /* Limpia. */
  pop {r4-r7,pc}                      /* Regresa. */

.ltorg
.thumb_func
.global draw_item
draw_item:                            /* r0=X,r1=Y,r2=tipo 0 manzana,1 naranja,2 bomba. */
  push {r4-r7,lr}                     /* Conserva estado. */
  mov r4,r0                           /* X. */
  mov r5,r1                           /* Y. */
  mov r7,r2                           /* Tipo. */
  cmp r7,#2                           /* Bomba. */
  beq 3f                              /* Salta. */
  cmp r7,#1                           /* Naranja. */
  beq 2f                              /* Salta. */
1:ldr r6,=C_RED                      /* Manzana roja. */
  b 4f                                /* Dibuja cuerpo. */
2:ldr r6,=C_ORANGE                   /* Naranja. */
  b 4f                                /* Dibuja cuerpo. */
3:ldr r6,=C_BLACK                    /* Bomba. */
4:adds r0,r4,#3                       /* Corona redondeada. */
  mov r1,r5                           /* Y. */
  movs r2,#10                         /* Ancho. */
  movs r3,#2                          /* Alto. */
  push {r6}                           /* Color. */
  bl tft_fill_rect                    /* Dibuja corona. */
  add sp,#4                           /* Limpia. */
  adds r0,r4,#1                       /* Cuerpo ancho. */
  adds r1,r5,#2                       /* Y. */
  movs r2,#14                         /* Ancho. */
  movs r3,#9                          /* Alto. */
  push {r6}                           /* Color. */
  bl tft_fill_rect                    /* Dibuja cuerpo. */
  add sp,#4                           /* Limpia. */
  adds r0,r4,#3                       /* Base redondeada. */
  mov r1,r5                           /* Copia Y. */
  adds r1,#11                         /* Y. */
  movs r2,#10                         /* Ancho. */
  movs r3,#3                          /* Alto. */
  push {r6}                           /* Color. */
  bl tft_fill_rect                    /* Dibuja base. */
  add sp,#4                           /* Limpia. */
  cmp r7,#2                           /* Decide tallo o mecha. */
  beq 5f                              /* Mecha. */
  adds r0,r4,#6                       /* Tallo X. */
  subs r1,r5,#5                       /* Tallo Y. */
  movs r2,#3                          /* Ancho. */
  movs r3,#6                          /* Alto. */
  ldr r6,=C_GREEN                     /* Verde. */
  push {r6}                           /* Color. */
  bl tft_fill_rect                    /* Dibuja tallo. */
  add sp,#4                           /* Limpia. */
  mov r0,r4                           /* Copia X. */
  adds r0,#9                          /* Hoja. */
  subs r1,r5,#4                       /* Y hoja. */
  movs r2,#5                          /* Ancho. */
  movs r3,#3                          /* Alto. */
  push {r6}                           /* Verde. */
  bl tft_fill_rect                    /* Dibuja hoja. */
  add sp,#4                           /* Limpia. */
  b 6f                                /* Continúa brillo. */
5:adds r0,r4,#7                       /* Cuello de bomba. */
  subs r1,r5,#5                       /* Y. */
  movs r2,#3                          /* Ancho. */
  movs r3,#5                          /* Alto. */
  ldr r6,=0x8410                      /* Gris. */
  push {r6}                           /* Color. */
  bl tft_fill_rect                    /* Dibuja cuello. */
  add sp,#4                           /* Limpia. */
  mov r0,r4                           /* Copia X. */
  adds r0,#9                          /* Mecha encendida. */
  subs r1,r5,#7                       /* Y. */
  movs r2,#5                          /* Ancho. */
  movs r3,#3                          /* Alto. */
  ldr r6,=C_YELLOW                    /* Amarillo. */
  push {r6}                           /* Color. */
  bl tft_fill_rect                    /* Dibuja mecha. */
  add sp,#4                           /* Limpia. */
6:adds r0,r4,#3                       /* Brillo X. */
  adds r1,r5,#3                       /* Brillo Y. */
  movs r2,#3                          /* Ancho. */
  movs r3,#3                          /* Alto. */
  ldr r6,=C_WHITE                     /* Blanco. */
  push {r6}                           /* Color. */
  bl tft_fill_rect                    /* Dibuja reflejo. */
  add sp,#4                           /* Limpia. */
  pop {r4-r7,pc}                      /* Regresa. */
