#!/usr/bin/env bash
# Builds and runs the SystemVerilog design and testbench using Verilator.
# Usage: bash scripts/simulate.sh [top_module] [source files...]

set -euo pipefail

# Use the provided top module, or default to "tb".
TOP_MODULE="${1:-tb}"
shift || true

# Use any provided source files, otherwise fall back to the defaults.
SOURCES=("$@")
if [ "${#SOURCES[@]}" -eq 0 ]; then
    SOURCES=(fifo.sv tb_fifo.sv)
fi

OUT_DIR="output"
OBJ_DIR="${OUT_DIR}/obj_dir"

# Create the output directory if it does not already exist.
mkdir -p "${OUT_DIR}"

# Ensure Verilator is installed before attempting to build.
if ! command -v verilator >/dev/null 2>&1; then
    echo "Error: verilator not found. Run 'make setup' first." >&2
    exit 1
fi

echo "=== Building (top=${TOP_MODULE}, sources=${SOURCES[*]}) ==="
verilator --binary -j 0 -Wall --Wno-fatal --trace \
    --top-module "${TOP_MODULE}" \
    --Mdir "${OBJ_DIR}" \
    -o Vtb \
    "${SOURCES[@]}"

echo ""
echo "=== Running simulation ==="

# Run the generated simulation executable.
"${OBJ_DIR}/Vtb"

# Move the generated waveform to the output directory if it exists.
if [ -f dump.vcd ]; then
    mv dump.vcd "${OUT_DIR}/dump.vcd"
    echo ""
    echo "Waveform written to ${OUT_DIR}/dump.vcd"
fi
