#!/usr/bin/env bash
# Builds and runs the SystemVerilog design+testbench through Verilator.
# Usage: bash scripts/simulate.sh [top_module] [source files...]

set -euo pipefail

# defaults, can be overridden by args
TOP_MODULE="${1:-tb}"
shift || true
SOURCES=("$@")
if [ "${#SOURCES[@]}" -eq 0 ]; then
    SOURCES=(up_down_counter.sv tb_up_down_counter.sv)
fi

OUT_DIR="output"
OBJ_DIR="${OUT_DIR}/obj_dir"

mkdir -p "${OUT_DIR}"

# check verilator is installed before doing anything else
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
# verilator drops dump.vcd in the cwd it's run from, so cd into obj_dir's parent
# and point it at the same place the sim expects (cwd), then move it after
"${OBJ_DIR}/Vtb"

if [ -f dump.vcd ]; then
    mv dump.vcd "${OUT_DIR}/dump.vcd"
    echo ""
    echo "Waveform written to ${OUT_DIR}/dump.vcd"
fi
