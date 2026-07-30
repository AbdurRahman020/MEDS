#!/bin/bash

# exit immediately if:
# - a command fails (-e)
# - an undefined variable is used (-u)
# - a command inside a pipeline fails (-o pipefail)
set -euo pipefail

echo "Checking required tools..."
echo ""

# list of commands/tools that must be present for the project to run
REQUIRED_TOOLS=(
    "bash"
    "mkdir"
    "date"
    "grep"
    "awk"
)

# tracks whether all tools were found
# set to false as soon as any tool is missing
ALL_OK=true

# loop through each tool in the required list
for tool in "${REQUIRED_TOOLS[@]}"; do
    # command -v checks if the tool exists in the system PATH
    # >/dev/null 2>&1 suppresses any output from the check itself
    if command -v "$tool" >/dev/null 2>&1; then
        echo "[OK] $tool found at: $(command -v "$tool")"
    else
        # print which tool is missing and flip the flag
        echo "[MISSING] $tool - please install it to proceed."
        ALL_OK=false
    fi
done

echo ""

# print final verdict after all tools have been checked
if [ "$ALL_OK" = true ]; then
    echo "All required tools are available. You can proceed with the setup."
    echo ""
    echo "Try Running: make all"
else
    # exit with code 1 to signal failure to any calling script or Makefile
    echo "One or more required tools are missing."
    echo "Please install them and run this script again."
    exit 1
fi
