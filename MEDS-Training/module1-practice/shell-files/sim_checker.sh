#!/bin/bash

# ensure a log file argument is provided
if [ -z "$1" ]; then
    echo "Error: Please provide a log file."
    echo "Usage: bash sim_checker.sh simulation.log"
    exit 1
fi

LOG_FILE="$1"

# verify the log file exists
if [ ! -f "$LOG_FILE" ]; then
    echo "Error: File '$LOG_FILE' not found"
    exit 1
fi

# counters for log analysis
ERROR_COUNT=0
WARNING_COUNT=0
PASS_COUNT=0

# read the log file line by line
while read LINE; do

    # count matching log messages
    if [[ "$LINE" == *"ERROR"* ]]; then
        ((ERROR_COUNT++))
    elif [[ "$LINE" == *"WARNING"* ]]; then
        ((WARNING_COUNT++))
    elif [[ "$LINE" == *"PASS"* ]]; then
        ((PASS_COUNT++))
    fi

done < "$LOG_FILE"

# print summary
echo "Simulation Log Analysis:"
echo "Errors: $ERROR_COUNT"
echo "Warnings: $WARNING_COUNT"
echo "Passes: $PASS_COUNT"

# set exit status based on results
if [ $ERROR_COUNT -gt 0 ]; then
    echo "Simulation failed with $ERROR_COUNT errors."
    exit 1
elif [ $WARNING_COUNT -gt 0 ]; then
    echo "Simulation completed with $WARNING_COUNT warnings."
    exit 0
else
    echo "Simulation completed successfully with no errors or warnings."
    exit 0
fi