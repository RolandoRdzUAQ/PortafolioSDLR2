# ==========================================
# Makefile Quartus en Linux
# ==========================================

# Nombre de tu proyecto (Debe coincidir con tu archivo .qpf y tu Top Level entity)
PROJECT = digitalFIR

#Ruta de Herramienta de ModelSim
MODELSIM_BIN = /opt/intelFPGA/20.1/modelsim_ase/bin/vsim

# ⏳ Tiempo máximo de simulación (Puedes usar ns, us, ms, s)
SIM_TIME = 3ms

# Binarios de Quartus (Asume que están agregados a tu variable $PATH)
MAP = quartus_map
FIT = quartus_fit
ASM = quartus_asm
STA = quartus_sta
PGM = quartus_pgm

# ==========================================
# REGLAS Y COMANDOS
# ==========================================

# Regla por defecto: Si solo escribes 'make', hará la compilación completa
all: compile

# Regla de auto-descubrimiento de archivos
update_sources:
	@echo "=> Escaneando carpeta src/ para actualizar el .qsf..."
	@sed -i '/-name VHDL_FILE/d' $(PROJECT).qsf
	@for file in src/*.vhd; do \
		if [ -f "$$file" ]; then \
			echo "set_global_assignment -name VHDL_FILE $$file" >> $(PROJECT).qsf; \
		fi \
	done

# 1. Compilación Completa (Síntesis, Enrutamiento y Generación del .sof)
compile: update_sources
	@echo "=> Iniciando Síntesis (Analysis & Synthesis)..."
	$(MAP) --read_settings_files=on --write_settings_files=off $(PROJECT) -c $(PROJECT)
	@echo "=> Iniciando Enrutamiento (Fitter)..."
	$(FIT) --read_settings_files=off --write_settings_files=off $(PROJECT) -c $(PROJECT)
	@echo "=> Generando archivo de programación (Assembler)..."
	$(ASM) --read_settings_files=off --write_settings_files=off $(PROJECT) -c $(PROJECT)
	@echo "=> Análisis de tiempos (Timing Analyzer)..."
	$(STA) $(PROJECT) -c $(PROJECT)
	@echo "¡Compilación Total Exitosa! El archivo .sof está listo."

# 2. Compilación Rápida (Solo Análisis y Síntesis para verificar conexiones)
syn: update_sources
	@echo "=> Ejecutando solo Análisis y Síntesis..."
	$(MAP) --read_settings_files=on --write_settings_files=off $(PROJECT) -c $(PROJECT)
	@echo "¡Análisis estructural completado sin errores lógicos!"

# 3. Compilación Individual (Analiza sintaxis estricta de un solo archivo)
# Uso: make check FILE=AsynchronousReceiver.vhd
check:
	@echo "=> Analizando archivo específico: $(FILE)"
	$(MAP) --analyze_file=$(FILE) $(PROJECT) -c $(PROJECT)

# 4. Programación / Flasheo (Requiere la tarjeta DE10-Lite conectada por USB)
flash:
	@echo "=> Programando la FPGA por JTAG..."
	$(PGM) -m jtag -c 1 -o "p;output_files/$(PROJECT).sof"
	@echo "¡FPGA programada exitosamente!"

# 5. Limpieza de proyecto (Borra todos los archivos temporales y reportes pesados)
clean:
	@echo "=> Limpiando el directorio del proyecto..."
	rm -rf db incremental_db output_files *.qws *.summary *.rpt *.smsg *.done *.jdi *.pin *.chm
	@echo "¡Directorio limpio!"


# ==========================================
# SIMULACIÓN CON GHDL Y GTKWAVE
# ==========================================
# Asume automáticamente que tu testbench se llama "tb_NOMBREDELPROYECTO"
TB_ENTITY = tb_$(PROJECT)

sim:
	@echo "=> Compilando códigos fuente y testbench..."
	@mkdir -p sim_build
	ghdl -a --workdir=sim_build src/*.vhd tb/*.vhd
	@echo "=> Elaborando diseño..."
	ghdl -e --workdir=sim_build $(TB_ENTITY)
	@echo "=> Ejecutando simulación por $(SIM_TIME) y exportando ondas..."
	ghdl -r --workdir=sim_build $(TB_ENTITY) --stop-time=$(SIM_TIME) --vcd=sim_build/$(PROJECT)_waves.vcd
	@echo "=> Simulación lista. Usa 'make view' para abrir GTKWave, o recarga la ventana activa."

view:
	@echo "=> Abriendo GTKWave..."
	gtkwave sim_build/$(PROJECT)_waves.vcd &

clean_sim:
	rm -rf sim_build

# ==========================================
# FLUJO MODELSIM (INDUSTRIAL / MATLAB)
# ==========================================
modelsim:
	@echo "=> Iniciando ModelSim en modo Batch..."
	@mkdir -p ms_build
	# Creamos el script TCL al vuelo para no depender de archivos extra
	@echo "vlib work; \
	      vmap work work; \
	      vcom -93 src/*.vhd tb/*.vhd; \
	      vsim -gui -voptargs=+acc work.$(TB_ENTITY); \
	      add wave -position insertpoint sim:/$(TB_ENTITY)/*; \
	      run $(SIM_TIME);" > ms_build/sim.tcl
	$(MODELSIM_BIN) -do ms_build/sim.tcl -l ms_build/transcript &
