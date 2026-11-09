/* Definiciones para ensamblador. La extensión .h permite que Arduino IDE
   copie este archivo a su carpeta temporal antes de compilar los .S. */
#ifndef ATRAPA_FRUTAS_RP2040_DEFS_H
#define ATRAPA_FRUTAS_RP2040_DEFS_H

/* Direcciones de registros del RP2040. */
.equ SIO_BASE,          0xD0000000
.equ SIO_GPIO_IN,       0x04
.equ SIO_GPIO_OUT_SET,  0x14
.equ SIO_GPIO_OUT_CLR,  0x18
.equ SIO_GPIO_OE_SET,   0x24

.equ IO_BANK0_BASE,     0x40014000
.equ PADS_BANK0_BASE,   0x4001C000
.equ RESETS_BASE,       0x4000C000
.equ RESETS_RESET,      0x00
.equ RESETS_DONE,       0x08
.equ SPI0_BASE,         0x4003C000
.equ SPI_CR0,           0x00
.equ SPI_CR1,           0x04
.equ SPI_DR,            0x08
.equ SPI_SR,            0x0C
.equ SPI_CPSR,          0x10
.equ ADC_BASE,          0x4004C000
.equ ADC_CS,            0x00
.equ ADC_RESULT,        0x04

/* TFT: CS17, SCK18, MOSI19, DC20 y RST21. */
.equ TFT_CS_MASK,       (1 << 17)
.equ TFT_DC_MASK,       (1 << 20)
.equ TFT_RST_MASK,      (1 << 21)
.equ TFT_OUT_MASK,      ((1 << 17) | (1 << 20) | (1 << 21))
.equ BTN_Z_MASK,        (1 << 14)
.equ BTN_SHIELD_MASK,   (1 << 15)

/* Colores RGB565. */
.equ C_BLACK,  0x0000
.equ C_WHITE,  0xFFFF
.equ C_RED,    0xF800
.equ C_GREEN,  0x07E0
.equ C_BLUE,   0x001F
.equ C_YELLOW, 0xFFE0
.equ C_CYAN,   0x07FF
.equ C_NAVY,   0x000C
.equ C_ORANGE, 0xFD20
.equ C_SKY,    0x3DDF
.equ C_GRASS,  0x04A0
.equ C_BROWN,  0xA285

#endif
