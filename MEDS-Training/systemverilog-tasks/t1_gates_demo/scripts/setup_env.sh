#!/usr/bin/env bash
# Checks that the tools required for the simulation environment are available.

set -uo pipefail

# Tracks whether any required tool is missing.
MISSING=0

# Check if a command exists and optionally display its version.
check_tool() {
    local tool="$1"
    local version_flag="${2-"--version"}"

    if command -v "${tool}" >/dev/null 2>&1; then
        if [ -z "${version_flag}" ]; then
            echo "  [OK]   ${tool} — $(command -v "${tool}")"
        else
            local version
            version=$("${tool}" "${version_flag}" 2>/dev/null | head -n1)
            echo "  [OK]   ${tool} (${version:-version unknown}) — $(command -v "${tool}")"
        fi
    else
        echo "  [MISSING] ${tool} not found on PATH"
        MISSING=1
    fi
}

# Check whether a VS Code extension is installed using its publisher.extension ID.
check_vscode_extension() {
    local ext_id="$1"
    local ext_label="$2"

    # Skip the extension check if the VS Code CLI is unavailable.
    if ! command -v code >/dev/null 2>&1; then
        echo "  [SKIP] ${ext_label} extension check skipped ('code' CLI not found)"
        return
    fi

    local match
    match=$(code --list-extensions --show-versions 2>/dev/null | grep -i "^${ext_id}@")

    if [ -n "${match}" ]; then
        echo "  [OK]   ${ext_label} extension installed (${match})"
    else
        echo "  [MISSING] ${ext_label} extension not installed in VS Code"
        MISSING=1
    fi
}

echo "=== Checking required tools ==="

# Check required simulation tools.
check_tool verilator
check_tool gtkwave ""
check_tool code
check_vscode_extension "hediet.vscode-drawio" "draw.io"

echo ""

# Print a summary and installation instructions if needed.
if [ "${MISSING}" -eq 0 ]; then
    echo "All required tools are installed."
else
    echo "Some tools are missing."
    echo "Install verilator: sudo apt update && sudo apt install verilator"
    echo "Install gtkwave:   sudo apt update && sudo apt install gtkwave"
    echo "Install draw.io ext: code --install-extension hediet.vscode-drawio"
fi

# Return success (0) if everything is installed, otherwise return failure (1).
exit "${MISSING}"
