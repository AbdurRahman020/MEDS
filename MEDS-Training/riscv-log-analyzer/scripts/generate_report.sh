#!/bin/bash

# exit immediately if:
# - any command fails (-e)
# - an undefined variable is used (-u)
# - a command inside a pipeline fails (-o pipefail)
set -euo pipefail

# path where the final combined summary report will be saved
OUTPUT_DIR="output/summary_reports.txt"

# create the output directory if it does not already exist
# -p prevents errors if the directory is already there
mkdir -p output

echo "Generating summary report..."
echo ""

# write the report header into the file
# using a block {} lets multiple echo commands share a single redirect
# > overwrites any existing file, giving us a clean starting point
{
    echo "RISC-V Log Analysis - Summary Report"
    echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
} > "$OUTPUT_DIR"

# loop through every .log file found inside test_data/
for logfile in test_data/*.log; do
    echo "Processing: $logfile"

    # append the current log file's name as a label in the report
    {
        echo "File: $logfile"
    } >> "$OUTPUT_DIR"

    # run the analyzer on this log file and append its output to the report
    # 2>&1 redirects stderr into stdout so errors are captured in the report too
    # || true prevents the loop from stopping if the analyzer returns a non-zero exit code
    bash scripts/analyze.sh "$logfile" >> "$OUTPUT_DIR" 2>&1 || true

    # add a blank line after each file's section to keep the report readable
    echo "" >> "$OUTPUT_DIR"

done

echo ""
# print the final location of the generated report
echo "Summary report generated at: $OUTPUT_DIR"
