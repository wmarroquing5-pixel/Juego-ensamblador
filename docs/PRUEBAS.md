# Estado de verificación

## Revisado

- La estructura del sketch cumple el nombre de carpeta requerido por Arduino IDE.
- Los módulos `.S` usan instrucciones Thumb compatibles con Cortex-M0+ y registros bajos.
- Se revisaron referencias entre funciones y variables de los módulos.
- La pantalla usa SPI0 y los pines acordados: CS17, SCK18, MOSI19, DC20 y RST21.
- El texto se configura sin espejo con MADCTL `0x08`.
- Los botones son activos en nivel bajo y tienen pull-up interno.

## Pendiente en hardware

- Compilar con la instalación RP2040 del Arduino IDE del usuario.
- Confirmar visualmente colores y orientación en la unidad ILI9341 concreta.
- Calibrar los umbrales del joystick si su centro no está cerca de 2048.
- Confirmar que GP14 y GP15 llegan a GND al pulsarlos.

Si la pantalla queda negra, revisar primero VCC/BL a 3.3 V, GND común y que SDA/SCL no estén intercambiados. Si el juego aparece pero no responde, medir el joystick y verificar que nunca reciba 5 V.

