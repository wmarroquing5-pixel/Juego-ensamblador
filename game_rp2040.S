.syntax unified
.cpu cortex-m0plus
.thumb
#include "rp2040_defs.h"             /* Pines y colores compartidos. */

.equ ITEM_COUNT,3                    /* Tres objetos simultáneos. */
.equ BASKET_Y,282                    /* Altura de la canasta. */

.section .bss
.align 2
basket_x:       .space 4             /* X actual de la canasta. */
old_basket_x:   .space 4             /* X anterior. */
item_x:         .space 12            /* X de tres objetos. */
item_y:         .space 12            /* Y de tres objetos. */
old_item_y:     .space 12            /* Y anterior. */
item_type:      .space 12            /* 0 manzana,1 naranja,2 bomba. */
score:          .space 4             /* Puntuación. */
lives:          .space 4             /* Vidas. */
level_speed:    .space 4             /* Velocidad 2..4. */
shield_time:    .space 4             /* Duración del escudo. */
z_lock:         .space 4             /* Antirrebote de Z. */
shield_lock:    .space 4             /* Antirrebote GP15. */
rng_state:      .space 4             /* Estado pseudoaleatorio. */
digit_buf:      .space 2             /* Cadena de un dígito. */

.section .text.game_rp2040,"ax",%progbits
.thumb_func
.global asm_game_setup
asm_game_setup:                       /* Entrada única desde setup(). */
  push {lr}                           /* Conserva retorno. */
  bl rp2040_hw_init                   /* Configura registros RP2040. */
  bl tft_init_asm                     /* Inicializa TFT por SPI0. */
  bl start_screen                     /* Presenta portada. */
  bl new_game                         /* Crea primera partida. */
  pop {pc}                            /* Regresa. */

.ltorg
.thumb_func
.global asm_game_loop
asm_game_loop:                        /* Entrada repetida desde loop(). */
  push {lr}                           /* Conserva retorno. */
  bl update_controls                 /* Lee joystick y botones. */
  bl update_items                    /* Mueve frutas y bombas. */
  bl draw_frame                      /* Actualiza pantalla. */
  ldr r0,=lives                      /* Consulta vidas. */
  ldr r0,[r0]                         /* Lee valor. */
  cmp r0,#0                           /* Comprueba Game Over. */
  bne 1f                              /* Continúa si quedan vidas. */
  bl game_over                        /* Detiene y reinicia. */
1:movs r0,#35                         /* Pausa entre cuadros. */
  bl delay_ms_asm                     /* Regula velocidad. */
  pop {pc}                            /* Regresa. */

.ltorg
.thumb_func
start_screen:                         /* Dibuja portada académica. */
  push {r4,lr}                        /* Conserva registros. */
  ldr r0,=C_SKY                       /* Cielo. */
  bl tft_clear                        /* Limpia pantalla. */
  movs r0,#0                          /* X cabecera. */
  movs r1,#0                          /* Y cabecera. */
  movs r2,#240                        /* Ancho. */
  movs r3,#58                         /* Alto. */
  ldr r4,=C_NAVY                      /* Azul oscuro. */
  push {r4}                           /* Color. */
  bl tft_fill_rect                    /* Dibuja cabecera. */
  add sp,#4                           /* Limpia. */
  movs r0,#72                         /* X UMG. */
  movs r1,#12                         /* Y. */
  ldr r2,=txt_umg                     /* Texto. */
  ldr r3,=C_YELLOW                    /* Color. */
  bl draw_text                        /* Dibuja. */
  movs r0,#36                         /* X curso. */
  movs r1,#36                         /* Y. */
  ldr r2,=txt_course                  /* Texto. */
  ldr r3,=C_WHITE                     /* Color. */
  bl draw_text                        /* Dibuja. */
  movs r0,#60                         /* X VIDEOJUEGO. */
  movs r1,#78                         /* Y. */
  ldr r2,=txt_videogame               /* Texto. */
  ldr r3,=C_ORANGE                    /* Color. */
  bl draw_text                        /* Dibuja. */
  movs r0,#42                         /* X título. */
  movs r1,#104                        /* Y. */
  ldr r2,=txt_title                   /* ATRAPA FRUTAS. */
  ldr r3,=C_RED                       /* Color. */
  bl draw_text                        /* Dibuja. */
  movs r0,#24                         /* X nombre. */
  movs r1,#154                        /* Y. */
  ldr r2,=txt_name                    /* Wilmer. */
  ldr r3,=C_WHITE                     /* Color. */
  bl draw_text                        /* Dibuja. */
  movs r0,#48                         /* X carnet. */
  movs r1,#180                        /* Y. */
  ldr r2,=txt_id                      /* Carnet. */
  ldr r3,=C_YELLOW                    /* Color. */
  bl draw_text                        /* Dibuja. */
  movs r0,#50                         /* X marco. */
  movs r1,#226                        /* Y. */
  movs r2,#140                        /* Ancho. */
  movs r3,#48                         /* Alto. */
  ldr r4,=C_YELLOW                    /* Color. */
  push {r4}                           /* Pasa color. */
  bl tft_fill_rect                    /* Marco. */
  add sp,#4                           /* Limpia. */
  movs r0,#55                         /* X interior. */
  movs r1,#231                        /* Y. */
  movs r2,#130                        /* Ancho. */
  movs r3,#38                         /* Alto. */
  ldr r4,=C_NAVY                      /* Fondo. */
  push {r4}                           /* Color. */
  bl tft_fill_rect                    /* Interior. */
  add sp,#4                           /* Limpia. */
  movs r0,#78                         /* X iniciar. */
  movs r1,#242                        /* Y. */
  ldr r2,=txt_start                   /* Texto. */
  ldr r3,=C_WHITE                     /* Color. */
  bl draw_text                        /* Dibuja. */
1:bl buttons_any                      /* Espera botones libres. */
  cmp r0,#0                           /* Comprueba. */
  bne 1b                              /* Repite. */
2:bl buttons_any                      /* Espera pulsación. */
  cmp r0,#0                           /* Comprueba. */
  beq 2b                              /* Repite. */
3:bl buttons_any                      /* Espera liberación. */
  cmp r0,#0                           /* Comprueba. */
  bne 3b                              /* Repite. */
  pop {r4,pc}                         /* Regresa. */

.ltorg
.thumb_func
new_game:                             /* Inicializa variables. */
  push {r4-r7,lr}                     /* Conserva registros. */
  ldr r0,=basket_x                    /* Posición canasta. */
  movs r1,#104                        /* Centro. */
  str r1,[r0]                         /* Guarda. */
  ldr r0,=old_basket_x                /* Posición anterior. */
  str r1,[r0]                         /* Guarda. */
  movs r1,#0                          /* Cero. */
  ldr r0,=score                       /* Puntos. */
  str r1,[r0]                         /* Reinicia. */
  ldr r0,=shield_time                 /* Escudo. */
  str r1,[r0]                         /* Apaga. */
  ldr r0,=z_lock                      /* Seguro Z. */
  str r1,[r0]                         /* Libera. */
  ldr r0,=shield_lock                 /* Seguro GP15. */
  str r1,[r0]                         /* Libera. */
  ldr r0,=lives                       /* Vidas. */
  movs r1,#3                          /* Tres vidas. */
  str r1,[r0]                         /* Guarda. */
  ldr r0,=level_speed                 /* Velocidad. */
  movs r1,#2                          /* Nivel uno. */
  str r1,[r0]                         /* Guarda. */
  ldr r0,=rng_state                   /* Aleatorio. */
  ldr r1,=0x6C8E9CF1                  /* Semilla. */
  str r1,[r0]                         /* Guarda. */
  ldr r4,=item_y                      /* Alturas. */
  movs r5,#64                         /* Primera. */
  str r5,[r4,#0]                      /* Guarda. */
  movs r5,#126                        /* Segunda. */
  str r5,[r4,#4]                      /* Guarda. */
  movs r5,#190                        /* Tercera. */
  str r5,[r4,#8]                      /* Guarda. */
  ldr r6,=old_item_y                  /* Anteriores. */
  ldr r5,[r4,#0]                      /* Lee primera. */
  str r5,[r6,#0]                      /* Copia. */
  ldr r5,[r4,#4]                      /* Lee segunda. */
  str r5,[r6,#4]                      /* Copia. */
  ldr r5,[r4,#8]                      /* Lee tercera. */
  str r5,[r6,#8]                      /* Copia. */
  ldr r4,=item_type                   /* Tipos. */
  movs r5,#0                          /* Manzana. */
  str r5,[r4,#0]                      /* Guarda. */
  movs r5,#1                          /* Naranja. */
  str r5,[r4,#4]                      /* Guarda. */
  movs r5,#2                          /* Bomba. */
  str r5,[r4,#8]                      /* Guarda. */
  movs r7,#0                          /* Índice. */
4:mov r0,r7                           /* Pasa índice. */
  bl randomize_x                      /* Elige X. */
  adds r7,#1                          /* Avanza. */
  cmp r7,#ITEM_COUNT                  /* Comprueba. */
  blo 4b                              /* Repite. */
  bl draw_background                  /* Construye fondo. */
  bl draw_all_sprites                 /* Dibuja objetos. */
  pop {r4-r7,pc}                      /* Regresa. */

.ltorg
.thumb_func
update_controls:                      /* Lee joystick, pausa y escudo. */
  push {r4-r7,lr}                     /* Conserva registros. */
  bl adc_read_x                       /* Lee GP26/ADC0. */
  mov r7,r0                           /* Guarda ADC. */
  ldr r4,=basket_x                    /* X canasta. */
  ldr r5,[r4]                         /* Lee X. */
  ldr r6,=old_basket_x                /* X anterior. */
  str r5,[r6]                         /* Conserva. */
  ldr r0,=1500                        /* Límite izquierdo. */
  cmp r7,r0                           /* Compara. */
  bhs 1f                              /* Prueba derecha. */
  cmp r5,#5                           /* Borde. */
  bls 2f                              /* No sale. */
  subs r5,#5                          /* Mueve izquierda. */
  b 2f                                /* Guarda. */
1:ldr r0,=2600                        /* Límite derecho. */
  cmp r7,r0                           /* Compara. */
  blo 2f                              /* Centro. */
  cmp r5,#203                         /* Borde. */
  bhi 2f                              /* No sale. */
  adds r5,#5                          /* Mueve derecha. */
2:str r5,[r4]                         /* Guarda X. */

  bl button_shield                   /* Lee GP15. */
  mov r4,r0                           /* Estado. */
  ldr r5,=shield_lock                 /* Seguro. */
  ldr r6,[r5]                         /* Lee. */
  cmp r4,#0                           /* Libre. */
  bne 3f                              /* Pulsado. */
  movs r6,#0                          /* Libera seguro. */
  str r6,[r5]                         /* Guarda. */
  b 4f                                /* Continúa Z. */
3:cmp r6,#0                           /* Nueva pulsación. */
  bne 4f                              /* Ignora sostenida. */
  movs r6,#1                          /* Bloquea. */
  str r6,[r5]                         /* Guarda. */
  ldr r0,=shield_time                 /* Escudo. */
  ldr r1,=150                         /* Duración. */
  str r1,[r0]                         /* Activa. */

4:bl button_z                         /* Lee Z. */
  mov r4,r0                           /* Estado. */
  ldr r5,=z_lock                      /* Seguro. */
  ldr r6,[r5]                         /* Lee. */
  cmp r4,#0                           /* Libre. */
  bne 5f                              /* Pulsado. */
  movs r6,#0                          /* Libera. */
  str r6,[r5]                         /* Guarda. */
  b 9f                                /* Termina. */
5:cmp r6,#0                           /* Nueva pulsación. */
  bne 9f                              /* Ignora sostenida. */
  movs r6,#1                          /* Bloquea. */
  str r6,[r5]                         /* Guarda. */
  bl pause_screen                     /* Pausa hasta otro Z. */
9:pop {r4-r7,pc}                      /* Regresa. */

.ltorg
.thumb_func
update_items:                         /* Caída y colisiones. */
  push {r4-r7,lr}                     /* Conserva registros. */
  ldr r4,=item_y                      /* Alturas. */
  ldr r5,=old_item_y                  /* Alturas anteriores. */
  ldr r6,=level_speed                 /* Velocidad. */
  ldr r6,[r6]                         /* Lee. */
  movs r7,#0                          /* Índice. */
1:lsls r1,r7,#2                       /* Desplazamiento índice*4. */
  ldr r0,[r4,r1]                      /* Lee Y. */
  str r0,[r5,r1]                      /* Conserva Y. */
  adds r0,r0,r6                       /* Cae. */
  str r0,[r4,r1]                      /* Guarda. */
  ldr r2,=310                         /* Límite inferior (no cabe en CMP inmediato). */
  cmp r0,r2                           /* Salida inferior. */
  bhs 4f                              /* Reaparece. */
  ldr r2,=268                         /* Inicio de la zona de canasta. */
  cmp r0,r2                           /* Zona de canasta. */
  blo 5f                              /* Aún arriba. */
  ldr r2,=item_x                      /* X objetos. */
  ldr r2,[r2,r1]                      /* X actual. */
  ldr r3,=basket_x                    /* X canasta. */
  ldr r3,[r3]                         /* Lee. */
  adds r2,#15                         /* Borde derecho objeto. */
  cmp r2,r3                           /* Compara izquierda canasta. */
  blo 5f                              /* No coincide. */
  subs r2,#15                         /* Recupera X objeto. */
  adds r3,#32                         /* Borde derecho canasta. */
  cmp r2,r3                           /* Compara. */
  bhi 5f                              /* No coincide. */
  ldr r2,=item_type                   /* Tipos. */
  ldr r2,[r2,r1]                      /* Lee tipo. */
  cmp r2,#2                           /* Bomba. */
  beq 2f                              /* Procesa. */
  mov r0,r2                           /* Conserva el tipo de fruta. */
  ldr r3,=score                       /* Puntos. */
  ldr r2,[r3]                         /* Lee. */
  cmp r0,#1                           /* La naranja vale 15 puntos. */
  beq 6f                              /* Suma 15. */
  adds r2,#10                         /* Suma 10. */
  b 7f                                /* Guarda. */
6:adds r2,#15                         /* Suma 15. */
7:str r2,[r3]                         /* Guarda puntos. */
  b 4f                                /* Reaparece. */
2:ldr r2,=shield_time                 /* Consulta escudo. */
  ldr r2,[r2]                         /* Lee. */
  cmp r2,#0                           /* Activo. */
  beq 3f                              /* Sin escudo pierde vida. */
  ldr r3,=score                       /* Puntos. */
  ldr r2,[r3]                         /* Lee. */
  adds r2,#5                          /* Suma cinco. */
  str r2,[r3]                         /* Guarda. */
  b 4f                                /* Reaparece. */
3:ldr r3,=lives                       /* Vidas. */
  ldr r2,[r3]                         /* Lee. */
  cmp r2,#0                           /* Evita negativo. */
  beq 4f                              /* Continúa. */
  subs r2,#1                          /* Resta vida. */
  str r2,[r3]                         /* Guarda. */
4:mov r0,r7                           /* Índice. */
  bl respawn_item                     /* Reaparece. */
5:adds r7,#1                          /* Avanza. */
  cmp r7,#ITEM_COUNT                  /* Comprueba tres. */
  blo 1b                              /* Repite. */
  ldr r0,=shield_time                 /* Escudo. */
  ldr r1,[r0]                         /* Lee. */
  cmp r1,#0                           /* Activo. */
  beq 8f                              /* No reduce cero. */
  subs r1,#1                          /* Reduce. */
  str r1,[r0]                         /* Guarda. */
8:ldr r0,=score                       /* Puntos para nivel. */
  ldr r0,[r0]                         /* Lee. */
  movs r1,#2                          /* Velocidad nivel 1. */
  cmp r0,#30                          /* Primer umbral. */
  blo 9f                              /* Mantiene. */
  movs r1,#3                          /* Nivel 2. */
  cmp r0,#70                          /* Segundo umbral. */
  blo 9f                              /* Mantiene. */
  movs r1,#4                          /* Nivel 3. */
9:ldr r0,=level_speed                /* Dirección velocidad. */
  str r1,[r0]                         /* Guarda. */
  pop {r4-r7,pc}                      /* Regresa. */

.ltorg
.thumb_func
respawn_item:                         /* r0=índice. */
  push {r4-r7,lr}                     /* Conserva registros. */
  mov r4,r0                           /* Índice. */
  lsls r7,r4,#2                       /* Desplazamiento. */
  ldr r5,=item_y                      /* Alturas. */
  movs r6,#56                         /* Arriba. */
  str r6,[r5,r7]                      /* Guarda. */
  ldr r5,=old_item_y                  /* Anterior. */
  str r6,[r5,r7]                      /* Guarda. */
  mov r0,r4                           /* Índice. */
  bl randomize_x                      /* Nueva X. */
  bl random_next                      /* Aleatorio tipo. */
  movs r1,#3                          /* Reduce módulo 3 por restas. */
1:cmp r0,#3                           /* Menor que 3. */
  blo 2f                              /* Termina. */
  subs r0,#3                          /* Resta. */
  b 1b                                /* Repite. */
2:ldr r5,=item_type                  /* Tipos. */
  str r0,[r5,r7]                      /* Guarda. */
  pop {r4-r7,pc}                      /* Regresa. */

.ltorg
.thumb_func
randomize_x:                          /* r0=índice; X 8..217. */
  push {r4-r6,lr}                     /* Conserva. */
  mov r4,r0                           /* Índice. */
  bl random_next                      /* Aleatorio reducido. */
1:cmp r0,#210                         /* Rango. */
  blo 2f                              /* Termina. */
  subs r0,#210                        /* Reduce. */
  b 1b                                /* Repite. */
2:adds r0,#8                          /* Margen. */
  lsls r4,r4,#2                       /* Desplazamiento. */
  ldr r5,=item_x                      /* Arreglo. */
  str r0,[r5,r4]                      /* Guarda. */
  pop {r4-r6,pc}                      /* Regresa. */

.ltorg
.thumb_func
random_next:                          /* Xorshift y devuelve 0..255. */
  ldr r1,=rng_state                   /* Estado. */
  ldr r0,[r1]                         /* Lee. */
  mov r2,r0                           /* Copia. */
  lsls r2,#13                         /* Mezcla. */
  eors r0,r2                          /* XOR. */
  mov r2,r0                           /* Copia. */
  lsrs r2,#17                         /* Mezcla. */
  eors r0,r2                          /* XOR. */
  mov r2,r0                           /* Copia. */
  lsls r2,#5                          /* Mezcla. */
  eors r0,r2                          /* XOR. */
  str r0,[r1]                         /* Guarda. */
  movs r2,#0xFF                       /* Máscara. */
  ands r0,r2                          /* Reduce a byte. */
  bx lr                               /* Regresa. */

.ltorg
.thumb_func
draw_background:                      /* Cielo, suelo y HUD. */
  push {r4,lr}                        /* Conserva. */
  ldr r0,=C_SKY                       /* Cielo. */
  bl tft_clear                        /* Limpia. */
  movs r0,#0                          /* X suelo. */
  ldr r1,=278                         /* Y suelo. */
  movs r2,#240                        /* Ancho. */
  movs r3,#42                         /* Alto. */
  ldr r4,=C_GRASS                     /* Verde. */
  push {r4}                           /* Color. */
  bl tft_fill_rect                    /* Dibuja suelo. */
  add sp,#4                           /* Limpia. */
  bl draw_hud                         /* Dibuja HUD. */
  pop {r4,pc}                         /* Regresa. */

.ltorg
.thumb_func
draw_all_sprites:                     /* Dibuja objetos y canasta. */
  push {r4-r7,lr}                     /* Conserva. */
  ldr r4,=item_x                      /* X objetos. */
  ldr r5,=item_y                      /* Y objetos. */
  ldr r6,=item_type                   /* Tipos. */
  movs r7,#0                          /* Índice. */
1:lsls r3,r7,#2                       /* Desplazamiento. */
  ldr r0,[r4,r3]                      /* X. */
  ldr r1,[r5,r3]                      /* Y. */
  ldr r2,[r6,r3]                      /* Tipo. */
  bl draw_item                        /* Dibuja. */
  adds r7,#1                          /* Avanza. */
  cmp r7,#ITEM_COUNT                  /* Comprueba. */
  blo 1b                              /* Repite. */
  ldr r0,=basket_x                    /* X canasta. */
  ldr r0,[r0]                         /* Lee. */
  ldr r1,=BASKET_Y                    /* Y. */
  bl draw_basket                      /* Dibuja. */
  bl draw_shield                      /* Dibuja escudo. */
  pop {r4-r7,pc}                      /* Regresa. */

.ltorg
.thumb_func
draw_frame:                           /* Borra anteriores y dibuja actuales. */
  push {r4-r7,lr}                     /* Conserva. */
  ldr r4,=item_x                      /* X. */
  ldr r5,=old_item_y                  /* Y anterior. */
  movs r7,#0                          /* Índice. */
1:lsls r6,r7,#2                       /* Desplazamiento. */
  ldr r0,[r4,r6]                      /* X. */
  subs r0,#1                          /* Margen. */
  ldr r1,[r5,r6]                      /* Y. */
  subs r1,#7                          /* Incluye tallo. */
  movs r2,#18                         /* Ancho. */
  movs r3,#23                         /* Alto. */
  ldr r6,=C_SKY                       /* Cielo. */
  push {r6}                           /* Color. */
  bl tft_fill_rect                    /* Borra. */
  add sp,#4                           /* Limpia. */
  adds r7,#1                          /* Avanza. */
  cmp r7,#ITEM_COUNT                  /* Comprueba. */
  blo 1b                              /* Repite. */
  ldr r0,=old_basket_x                /* X anterior. */
  ldr r0,[r0]                         /* Lee. */
  subs r0,#4                          /* Margen. */
  ldr r1,=278                         /* Desde suelo. */
  movs r2,#42                         /* Ancho. */
  movs r3,#34                         /* Alto. */
  ldr r6,=C_GRASS                     /* Verde. */
  push {r6}                           /* Color. */
  bl tft_fill_rect                    /* Borra canasta. */
  add sp,#4                           /* Limpia. */
  movs r0,#0                          /* Restaura suelo completo. */
  ldr r1,=278                         /* Y. */
  movs r2,#240                        /* Ancho. */
  movs r3,#42                         /* Alto. */
  push {r6}                           /* Verde. */
  bl tft_fill_rect                    /* Dibuja suelo. */
  add sp,#4                           /* Limpia. */
  bl draw_all_sprites                 /* Dibuja estado nuevo. */
  bl draw_hud                         /* Actualiza datos. */
  pop {r4-r7,pc}                      /* Regresa. */

.ltorg
.thumb_func
draw_shield:                          /* Marco cian alrededor de canasta. */
  push {r4,lr}                        /* Conserva. */
  ldr r0,=shield_time                 /* Tiempo. */
  ldr r0,[r0]                         /* Lee. */
  cmp r0,#0                           /* Activo. */
  beq 9f                              /* No dibuja. */
  ldr r0,=basket_x                    /* X canasta. */
  ldr r0,[r0]                         /* Lee. */
  subs r0,#3                          /* Margen. */
  ldr r1,=279                         /* Y. */
  movs r2,#38                         /* Ancho. */
  movs r3,#2                          /* Alto. */
  ldr r4,=C_CYAN                      /* Cian. */
  push {r4}                           /* Color. */
  bl tft_fill_rect                    /* Borde superior. */
  add sp,#4                           /* Limpia. */
9:pop {r4,pc}                         /* Regresa. */

.ltorg
.thumb_func
draw_hud:                             /* Puntos, vidas, nivel y escudo. */
  push {r4-r7,lr}                     /* Conserva. */
  movs r0,#0                          /* X. */
  movs r1,#0                          /* Y. */
  movs r2,#240                        /* Ancho. */
  movs r3,#48                         /* Alto. */
  ldr r4,=C_NAVY                      /* Fondo. */
  push {r4}                           /* Color. */
  bl tft_fill_rect                    /* Limpia HUD. */
  add sp,#4                           /* Limpia. */
  movs r0,#4                          /* X P. */
  movs r1,#8                          /* Y. */
  ldr r2,=txt_p                       /* Etiqueta. */
  ldr r3,=C_YELLOW                    /* Color. */
  bl draw_text                        /* Dibuja. */
  ldr r0,=score                       /* Puntos. */
  ldr r0,[r0]                         /* Lee. */
  movs r1,#20                         /* X número. */
  bl draw_number2                     /* Dibuja. */
  movs r0,#76                         /* X V. */
  movs r1,#8                          /* Y. */
  ldr r2,=txt_v                       /* Etiqueta. */
  ldr r3,=C_WHITE                     /* Color. */
  bl draw_text                        /* Dibuja. */
  ldr r0,=lives                       /* Vidas. */
  ldr r0,[r0]                         /* Lee. */
  movs r1,#94                         /* X. */
  bl draw_digit                       /* Dibuja. */
  movs r0,#126                        /* X N. */
  movs r1,#8                          /* Y. */
  ldr r2,=txt_n                       /* Etiqueta. */
  ldr r3,=C_WHITE                     /* Color. */
  bl draw_text                        /* Dibuja. */
  ldr r0,=level_speed                 /* Velocidad. */
  ldr r0,[r0]                         /* Lee. */
  subs r0,#1                          /* Nivel 1..3. */
  movs r1,#144                        /* X. */
  bl draw_digit                       /* Dibuja. */
  movs r0,#176                        /* X E. */
  movs r1,#8                          /* Y. */
  ldr r2,=txt_e                       /* Etiqueta. */
  ldr r3,=C_CYAN                      /* Color. */
  bl draw_text                        /* Dibuja. */
  ldr r0,=shield_time                 /* Escudo. */
  ldr r0,[r0]                         /* Lee. */
  cmp r0,#0                           /* Convierte a 0/1. */
  beq 1f                              /* Cero. */
  movs r0,#1                          /* Uno. */
1:movs r1,#194                        /* X. */
  bl draw_digit                       /* Dibuja. */
  pop {r4-r7,pc}                      /* Regresa. */

.ltorg
.thumb_func
draw_number2:                         /* r0=número,r1=X; últimos dos dígitos. */
  push {r4-r7,lr}                     /* Conserva. */
  mov r4,r0                           /* Número. */
  mov r5,r1                           /* X. */
1:cmp r4,#100                         /* Reduce centenas. */
  blo 2f                              /* Continúa. */
  subs r4,#100                        /* Resta. */
  b 1b                                /* Repite. */
2:movs r6,#0                          /* Decenas. */
3:cmp r4,#10                          /* Divide por restas. */
  blo 4f                              /* Termina. */
  subs r4,#10                         /* Resta diez. */
  adds r6,#1                          /* Cuenta. */
  b 3b                                /* Repite. */
4:mov r0,r6                           /* Decena. */
  mov r1,r5                           /* X. */
  bl draw_digit                       /* Dibuja. */
  mov r0,r4                           /* Unidad. */
  mov r1,r5                           /* Recupera X inicial. */
  adds r1,#14                         /* X siguiente. */
  bl draw_digit                       /* Dibuja. */
  pop {r4-r7,pc}                      /* Regresa. */

.ltorg
.thumb_func
draw_digit:                           /* r0=0..9,r1=X,Y=8. */
  push {r4,lr}                        /* Conserva. */
  mov r4,r1                           /* X. */
  adds r0,#48                         /* ASCII. */
  ldr r2,=digit_buf                   /* Buffer. */
  strb r0,[r2]                        /* Guarda carácter. */
  movs r0,#0                          /* Terminador. */
  strb r0,[r2,#1]                     /* Guarda cero. */
  mov r0,r4                           /* X. */
  movs r1,#8                          /* Y. */
  ldr r3,=C_CYAN                      /* Color. */
  bl draw_text                        /* Dibuja. */
  pop {r4,pc}                         /* Regresa. */

.ltorg
.thumb_func
pause_screen:                         /* Pausa bloqueante hasta otro Z. */
  push {r4,lr}                        /* Conserva. */
  movs r0,#54                         /* X panel. */
  movs r1,#132                        /* Y. */
  movs r2,#132                        /* Ancho. */
  movs r3,#48                         /* Alto. */
  ldr r4,=C_NAVY                      /* Fondo. */
  push {r4}                           /* Color. */
  bl tft_fill_rect                    /* Dibuja panel. */
  add sp,#4                           /* Limpia. */
  movs r0,#90                         /* X texto. */
  movs r1,#148                        /* Y. */
  ldr r2,=txt_pause                   /* PAUSA. */
  ldr r3,=C_YELLOW                    /* Color. */
  bl draw_text                        /* Dibuja. */
1:bl button_z                         /* Espera liberar Z. */
  cmp r0,#0                           /* Comprueba. */
  bne 1b                              /* Repite. */
2:bl button_z                         /* Espera nueva pulsación. */
  cmp r0,#0                           /* Comprueba. */
  beq 2b                              /* Repite. */
3:bl button_z                         /* Espera liberar. */
  cmp r0,#0                           /* Comprueba. */
  bne 3b                              /* Repite. */
  bl draw_background                  /* Restaura escena. */
  bl draw_all_sprites                 /* Restaura objetos. */
  pop {r4,pc}                         /* Regresa. */

.ltorg
.thumb_func
game_over:                            /* Detiene física hasta botón. */
  push {lr}                           /* Conserva. */
  ldr r0,=C_BLACK                     /* Negro. */
  bl tft_clear                        /* Limpia. */
  movs r0,#66                         /* X. */
  movs r1,#118                        /* Y. */
  ldr r2,=txt_game_over               /* Texto. */
  ldr r3,=C_RED                       /* Rojo. */
  bl draw_text                        /* Dibuja. */
  movs r0,#42                         /* X. */
  movs r1,#164                        /* Y. */
  ldr r2,=txt_restart                 /* Reinicio. */
  ldr r3,=C_WHITE                     /* Blanco. */
  bl draw_text                        /* Dibuja. */
1:bl buttons_any                      /* Espera libre. */
  cmp r0,#0                           /* Comprueba. */
  bne 1b                              /* Repite. */
2:bl buttons_any                      /* Espera pulsar. */
  cmp r0,#0                           /* Comprueba. */
  beq 2b                              /* Repite. */
3:bl buttons_any                      /* Espera soltar. */
  cmp r0,#0                           /* Comprueba. */
  bne 3b                              /* Repite. */
  bl new_game                         /* Reinicia. */
  pop {pc}                            /* Regresa. */

.ltorg
.thumb_func
buttons_any:                          /* Devuelve uno si GP14 o GP15 están pulsados. */
  push {lr}                           /* Conserva. */
  bl button_z                         /* Lee Z. */
  cmp r0,#0                           /* Comprueba. */
  bne 1f                              /* Termina. */
  bl button_shield                    /* Lee GP15. */
1:pop {pc}                            /* Regresa. */

.section .rodata.game_text,"a",%progbits
.align 2
txt_umg:       .asciz "UMG 2026"           /* Universidad. */
txt_course:    .asciz "ARQUITECTURA 2"     /* Curso. */
txt_videogame: .asciz "VIDEOJUEGO"         /* Tipo. */
txt_title:     .asciz "ATRAPA FRUTAS"      /* Título. */
txt_name:      .asciz "WILMER MARROQUIN"   /* Nombre. */
txt_id:        .asciz "7691-19-2535"       /* Carnet. */
txt_start:     .asciz "INICIAR"            /* Inicio. */
txt_pause:     .asciz "PAUSA"              /* Pausa. */
txt_game_over: .asciz "GAME OVER"          /* Derrota. */
txt_restart:   .asciz "PULSA REINICIAR"    /* Reinicio. */
txt_p:         .asciz "P"                  /* Puntos. */
txt_v:         .asciz "V"                  /* Vidas. */
txt_n:         .asciz "N"                  /* Nivel. */
txt_e:         .asciz "E"                  /* Escudo. */
