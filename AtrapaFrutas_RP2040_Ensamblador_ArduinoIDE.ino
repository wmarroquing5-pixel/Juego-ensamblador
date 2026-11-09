/* Entrada mínima requerida por Arduino IDE; juego y hardware están en ensamblador. */
extern "C" void asm_game_setup(void); // Entrada ensamblador ejecutada una sola vez.
extern "C" void asm_game_loop(void);  // Entrada ensamblador ejecutada continuamente.

void setup() {                        // Inicio estándar de Arduino IDE.
  asm_game_setup();                   // Transfiere el control al código Thumb.
}

void loop() {                         // Ciclo estándar de Arduino IDE.
  asm_game_loop();                    // Ejecuta un cuadro completamente en ensamblador.
}
