# ==========================================
# CONFIGURACIÓN DEL PROYECTO (¡Edita esto!)
# ==========================================
set VHDL_FILE "src/digitalFIR.vhd"
set VHDL_ENTITY    "digitalFIR"
set PORT      "4449"

# La librería de MathWorks (Esta nunca cambia en tu versión R2025b)
set MATLAB_LIB "/usr/local/MATLAB/R2025b/toolbox/edalink/extensions/modelsim/linux64/liblfmhdls_tmwgcc.so"

# ==========================================
# AUTOMATIZACIÓN (No toques de aquí para abajo)
# ==========================================

echo ">>> 1. Compilando $VHDL_FILE..."
vcom -work work $VHDL_FILE

echo ">>> 2. Cargando diseño $VHDL_ENTITY e inyectando servidor Simulink en puerto $PORT..."
vsim -voptargs=+acc work.$VHDL_ENTITY -foreign "simlinkserver {$MATLAB_LIB} ; -socket $PORT"

echo ">>> 3. Reseteando tiempos y memorias..."
restart -f

echo ">>> 4. Inyectando estímulos base..."
# Nota: La sintaxis sim:/$VHDL_ENTITY/ sustituye el nombre automáticamente
force -freeze sim:/$VHDL_ENTITY/CLK 1 0, 0 {10 ns} -r 20 ns
force -freeze sim:/$VHDL_ENTITY/RST 0 0, 1 {100 ns}
force -freeze sim:/$VHDL_ENTITY/SYN 1 0, 0 {20 ns} -r 2 ms

echo ">>> ¡LISTO! Servidor levantado. Presiona RUN en Simulink."
