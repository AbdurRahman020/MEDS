#!/bin/bash

# exit immediately if:
# - any command fails (-e)
# - an undefined variable is used (-u)
# - a command inside a pipeline fails (-o pipefail)
set -euo pipefail

# file where the final combined report will be stored
OUTPUT_DIR="output/summary_reports.txt"

# create the output directory if it does not already exist
mkdir -p output

echo "Generating summary report..."
echo ""

# create/overwrite the report file with a fresh header
{
    echo "RISC-V Log Analysis - Summary Report"
    echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
} > "$OUTPUT_DIR"

# loop through every .log file inside test_data/
for logfile in test_data/*.log; do
    echo "Processing: $logfile"
    
    # add the current file name to the summary report
    {
        echo "File: $logfile"
    } >> "$OUTPUT_DIR"

    # run the analysis script on the log file, which appends both normal output and errors to the report, and '|| true' prevents the script from stopping if one file fails
    bash scripts/analyze.sh "$logfile" >> "$OUTPUT_DIR" 2>&1 || true
    
    # add a blank line between reports for readability
    echo "" >> "$OUTPUT_DIR"

done

echo ""
echo "Summary report generated at: $OUTPUT_DIR"
