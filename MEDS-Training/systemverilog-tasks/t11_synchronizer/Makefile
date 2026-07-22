# these are command names, not actual files
# without .PHONY, make would look for files named 'all', 'run', etc.
.PHONY: all run wave diagram clean setup help

TOP_MODULE := tb_reset_synchronizer
SRC_DIR    := src
SIM_DIR    := sim
DOCS_DIR   := docs
OUT_DIR    := output

# design files (synthesizable RTL only)
SRC        := $(SRC_DIR)/reset_synchronizer.sv
# testbench file(s)
TB         := $(SIM_DIR)/tb_reset_synchronizer.sv
SOURCES    := $(SRC) $(TB)

VCD        := $(OUT_DIR)/dump.vcd
DIAGRAM    := $(DOCS_DIR)/reset_synchronizer.drawio

# build + run the simulation (default target)
all: run

# compile and simulate via verilator
run:
	@echo "=== Building and running simulation ==="
	@bash scripts/simulate.sh $(TOP_MODULE) $(SOURCES)

# open the waveform in gtkwave (requires 'make run' first)
wave: $(VCD)
	@echo "=== Opening waveform in GTKWave ==="
	@gtkwave $(VCD) &

# make sure the vcd exists before trying to open it
$(VCD):
	@echo "No waveform found yet, running simulation first..."
	@$(MAKE) run

# open the fsm diagram in VS Code (uses the draw.io extension)
diagram:
	@echo "=== Opening $(DIAGRAM) in VS Code ==="
	@code $(DIAGRAM)

# delete all generated build/output files
clean:
	@echo "Cleaning up generated files..."
	@# -rf removes directories and their contents without prompting
	@rm -rf $(OUT_DIR)
	@echo "Done!"

# check that verilator/gtkwave are installed
setup:
	@bash scripts/setup_env.sh

# show all available make targets with descriptions
help:
	@echo "Available targets:"
	@echo ""
	@echo "  make all     — Build and run the simulation (default)"
	@echo "  make run     — Compile with Verilator and run the sim"
	@echo "  make wave    — Open output/dump.vcd in GTKWave"
	@echo "  make diagram — Open $(DIAGRAM) in VS Code (draw.io extension)"
	@echo "  make clean   — Delete the output/ directory"
	@echo "  make setup   — Check that verilator/gtkwave are installed"
	@echo "  make help    — Show this help message"
