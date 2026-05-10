#!/bin/bash

# exit immediately if:
# - a command fails (-e)
# - an undefined variable is used (-u)
# - a command inside a pipeline fails (-o pipefail)
set -euo pipefail

echo "Checking required tools..."
echo ""

# list of commands/tools needed for the project
REQUIRED_TOOLS=(
    "bash"
    "mkdir"
    "date"
    "grep"
    "awk"
)

# assume everything is fine unless a tool is missing
ALL_OK=true

# loop through each required tool
for tool in "${REQUIRED_TOOLS[@]}"; do
    # check if the command exists in the system PATH
    if command -v "$tool" >/dev/null 2>&1; then
        echo "[OK] $tool found at: $(command -v "$tool")"
    else
        echo "[MISSING] $tool - please install it to proceed."
        ALL_OK=false
    fi
done

echo ""

# final result after checking all tools
if [ "$ALL_OK" = true ]; then
    echo "All required tools are available. You can proceed with the setup."
    echo ""
    echo "Try Running: make all"
else
    echo "One or more required tools are missing."
    echo "Please install them and run this script again."
    exit 1
fi
