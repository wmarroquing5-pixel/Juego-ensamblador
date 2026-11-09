# Explicación para la presentación

## Funcionamiento general

El RP2040 configura directamente los pines, el convertidor analógico y el periférico SPI. Por SPI envía comandos y colores RGB565 al controlador ILI9341, sin usar una biblioteca gráfica.

Al encender aparece la portada con UMG 2026, Arquitectura 2, el nombre **Wilmer Marroquín** y el carnet **7691-19-2535**. Al pulsar Z comienza el juego: las frutas y bombas caen, la canasta se mueve con el joystick y las colisiones actualizan puntos y vidas.

## Cada código en dos líneas

`AtrapaFrutas_RP2040_Ensamblador_ArduinoIDE.ino`: Arduino IDE exige `setup()` y `loop()`. Estas funciones no contienen el juego; solamente transfieren la ejecución a `asm_game_setup` y `asm_game_loop`.

`rp2040_defs.h`: define direcciones de registros, números de GPIO, máscaras y colores. Su extensión permite que Arduino IDE lo incluya al compilar los archivos ensambladores.

`rp2040_hw.S`: configura GPIO, SPI0 y ADC mediante registros del RP2040. También lee el joystick y los dos pulsadores con pull-up.

`tft_rp2040.S`: reinicia e inicializa el ILI9341 en RGB565 y orientación correcta. Define ventanas de dibujo y rellena rectángulos enviando píxeles por SPI.

`font_rp2040.S`: contiene una fuente propia de letras y números de 5x7 puntos. Convierte cada bit activo en un pequeño rectángulo de color.

`sprites_rp2040.S`: dibuja la canasta, manzana, naranja y bomba usando figuras simples. Los gráficos son originales y no dependen de imágenes externas.

`game_rp2040.S`: maneja portada, estados, movimiento, caída, colisiones, escudo, puntos, vidas y niveles. En Game Over detiene las actualizaciones hasta que el usuario reinicia.

## Puntos para demostrar

1. Mover el joystick y mostrar que la canasta responde horizontalmente.
2. Atrapar una fruta para aumentar el puntaje.
3. Atrapar una bomba sin escudo para perder una vida.
4. Pulsar GP15 y mostrar la letra `E` del escudo activa.
5. Pulsar Z para pausar y volver a pulsarlo para continuar.
6. Perder todas las vidas y reiniciar desde Game Over.

