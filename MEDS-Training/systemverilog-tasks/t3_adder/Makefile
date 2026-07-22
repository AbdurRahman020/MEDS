# these are command names, not actual files
# without .PHONY, make would look for files named 'all', 'run', etc.
.PHONY: all run run-full run-half wave diagram clean setup help

SRC_DIR  := src
SIM_DIR  := sim
DOCS_DIR := docs
OUT_DIR  := output

# shared across both modules — one design file, one diagram
SRC      := $(SRC_DIR)/adder.sv
DIAGRAM  := $(DOCS_DIR)/adder.drawio

# only the top module / testbench differ per variant
FULL_TOP := tb_full_adder
FULL_TB  := $(SIM_DIR)/tb_full_adder.sv
FULL_VCD := $(OUT_DIR)/full_adder/dump.vcd

HALF_TOP := tb_half_adder
HALF_TB  := $(SIM_DIR)/tb_half_adder.sv
HALF_VCD := $(OUT_DIR)/half_adder/dump.vcd

# used by 'make wave'/'make diagram' to pick which module, e.g:
#   make wave MODULE=half
# defaults to full if not specified
MODULE ?= full

# build + run both simulations (default target)
all: run-full run-half

# run whichever module was requested: make run MODULE=half
run:
	@$(MAKE) run-$(MODULE)

run-full:
	@echo "=== Building and running full_adder simulation ==="
	@mkdir -p $(OUT_DIR)/full_adder
	@OUT_DIR=$(OUT_DIR)/full_adder bash scripts/simulate.sh $(FULL_TOP) $(SRC) $(FULL_TB)

run-half:
	@echo "=== Building and running half_adder simulation ==="
	@mkdir -p $(OUT_DIR)/half_adder
	@OUT_DIR=$(OUT_DIR)/half_adder bash scripts/simulate.sh $(HALF_TOP) $(SRC) $(HALF_TB)

# open the waveform in gtkwave for the selected module (requires 'make run' first)
# usage: make wave MODULE=full   or   make wave MODULE=half
wave:
ifeq ($(MODULE),full)
	@$(MAKE) _wave VCD=$(FULL_VCD) RUN_TARGET=run-full
else
	@$(MAKE) _wave VCD=$(HALF_VCD) RUN_TARGET=run-half
endif

_wave:
	@if [ ! -f "$(VCD)" ]; then \
		echo "No waveform found yet, running simulation first..."; \
		$(MAKE) $(RUN_TARGET); \
	fi
	@echo "=== Opening waveform in GTKWave ==="
	@gtkwave $(VCD) &

# open the shared diagram in VS Code (uses the draw.io extension)
diagram:
	@echo "=== Opening $(DIAGRAM) in VS Code ==="
	@code $(DIAGRAM)

# delete all generated build/output files
clean:
	@echo "Cleaning up generated files..."
	@# -rf removes directories and their contents without prompting
	@rm -rf $(OUT_DIR)
	@echo "Done!"

# check that verilator/gtkwave/code+drawio-extension are installed
setup:
	@bash scripts/setup_env.sh

# show all available make targets with descriptions
help:
	@echo "Available targets:"
	@echo ""
	@echo "  make all           — Build and run BOTH simulations"
	@echo "  make run-full      — Build and run the full_adder sim"
	@echo "  make run-half      — Build and run the half_adder sim"
	@echo "  make run MODULE=x  — Build and run x (full or half)"
	@echo "  make wave MODULE=x — Open x's waveform in GTKWave (default: full)"
	@echo "  make diagram       — Open the shared diagram in VS Code"
	@echo "  make clean         — Delete the output/ directory"
	@echo "  make setup         — Check that required tools are installed"
	@echo "  make help          — Show this help message"
