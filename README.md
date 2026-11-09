# Atrapa Frutas — Raspberry Pi Pico + ILI9341

Videojuego para abrir y cargar desde Arduino IDE. El control del hardware, los gráficos y la lógica del juego están escritos en ensamblador ARM Thumb para el RP2040 (Cortex-M0+). El archivo `.ino` solamente contiene las dos entradas obligatorias de Arduino IDE y llama al ensamblador.

## Conexiones

La pantalla de 8 pines de la fotografía se conecta así:

| Pantalla ILI9341 | Raspberry Pi Pico |
|---|---|
| VCC | 3V3 OUT, pin físico 36 |
| GND | GND, pin físico 38 |
| SCL | GP18, pin físico 24 |
| SDA | GP19, pin físico 25 |
| RST | GP21, pin físico 27 |
| DC | GP20, pin físico 26 |
| CS | GP17, pin físico 22 |
| BL | 3V3 OUT, pin físico 36 |

Joystick:

| Joystick | Raspberry Pi Pico |
|---|---|
| VCC | 3V3 OUT |
| GND | GND |
| VRx | GP26/ADC0, pin físico 31 |
| VRy | GP27/ADC1, pin físico 32 (reservado) |
| SW/Z | GP14, pin físico 19 |

Pulsador externo: una pata a GP15 (pin físico 20) y la otra a GND. El programa habilita resistencias pull-up internas; no se conecta ningún botón a 3.3 V.

## Controles

- Joystick izquierda/derecha: mueve la canasta.
- Botón externo GP15: activa temporalmente el escudo contra bombas.
- Botón Z/SW GP14: inicia y pausa/reanuda.
- En Game Over: cualquiera de los dos botones reinicia.

## Cómo cargarlo

1. Mantener todos los archivos juntos dentro de esta carpeta.
2. Abrir `AtrapaFrutas_RP2040_Ensamblador_ArduinoIDE.ino`.
3. En Arduino IDE seleccionar **Raspberry Pi Pico** (no Pico W, salvo que realmente sea ese modelo).
4. Conectar la Pico por USB y seleccionar su puerto. Si se usa BOOTSEL, mantenerlo pulsado al conectar y cargar el archivo UF2.
5. Pulsar **Verificar** y después **Cargar**.

No instalar Adafruit_GFX ni otra biblioteca gráfica: este proyecto contro

## Archivos

- `.ino`: puente mínimo requerido por Arduino IDE.
- `rp2040_defs.h`: direcciones, pines y colores; Arduino IDE lo copia durante la compilación.
- `rp2040_hw.S`: GPIO, SPI, ADC, botones y retardos.
- `tft_rp2040.S`: inicialización y rectángulos ILI9341.
- `font_rp2040.S`: fuente 5x7 y textos.
- `sprites_rp2040.S`: canasta, frutas y bomba en pixel-art.
- `game_rp2040.S`: portada, controles, colisiones, puntos, vidas, niveles, pausa y reinicio.
- `docs/EXPLICACION.md`: explicación para presentar el proyecto.
- `docs/PRUEBAS.md`: verificaciones realizadas y pruebas físicas pendientes.

# Juego-ensamblador
