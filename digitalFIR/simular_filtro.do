# =========================================
# Script de Automatización para Simulink
# Archivo: simular_filtro.do
# =========================================

# 1. Crear la librería de trabajo
vlib work

# 2. Compilar tu programa (asegúrate de que la ruta sea correcta)
vcom -work work src/digitalFIR.vhd

# 3. Cargar la simulación 
# (Nota: usamos -novopt o -voptargs=+acc para evitar que 
# Questa borre puertos que Simulink necesita leer)
vsim -voptargs=+acc work.digitalFIR

# 4. Estímulos Fijos (Forces)
# -> CLK: Suponiendo un reloj de 50 MHz (20 ns de periodo)
force -freeze sim:/digitalFIR/CLK 1 0, 0 {10 ns} -r 20 ns

# -> RST: Lo encendemos en 1 al inicio y lo bajamos a 0 después de 100 ns
force -freeze sim:/digitalFIR/RST 1 0, 0 {100 ns}

# -> SYN: Un pulso que dura un ciclo de reloj (20 ns) y se repite cada 2 ms
force -freeze sim:/digitalFIR/SYN 1 0, 0 {20 ns} -r 2 ms

# 5. Enlazar con Simulink usando Memoria Compartida (SharedMem)
# Este es el comando mágico que enlaza el bloque de tu diagrama
matlabtb digitalFIR

# 6. Darle play a la simulación desde el lado de Questa
# (Se quedará esperando a que le des "Run" en Simulink)
