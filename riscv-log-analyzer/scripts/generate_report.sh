#!/bin/bash

# exit immediately if:
# - any command fails (-e)
# - an undefined variable is used (-u)
# - a command inside a pipeline fails (-o pipefail)
set -euo pipefail

# path where the final combined summary report will be saved
OUTPUT_DIR="output/summary_reports.txt"

# path where the HTML version of the report will be saved
HTML_REPORT="output/summary_reports.html"

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

# ------------------------
# HTML report generation
# ------------------------

echo ""
echo "Generating HTML report..."

# write the HTML opening tags and table header into a fresh file
# > creates or overwrites the file, giving us a clean starting point
echo "<html>" > "$HTML_REPORT"
echo "<body>" >> "$HTML_REPORT"
echo "<h1>RISC-V Log Analysis Report</h1>" >> "$HTML_REPORT"
echo "<p>Generated: $(date '+%Y-%m-%d %H:%M:%S')</p>" >> "$HTML_REPORT"
echo "<table border='1'>" >> "$HTML_REPORT"
# write the table header row with column names
echo "  <tr><th>Log File</th><th>Total</th><th>Passed</th><th>Failed</th><th>Skipped</th><th>Pass Rate</th><th>Verdict</th></tr>" >> "$HTML_REPORT"

# loop through every .log file to build one table row per file
for logfile in test_data/*.log; do

    # count results — same way analyze.sh does
    # || true prevents stopping if grep finds no matches
    PASS=$(grep -c "TEST PASS:" "$logfile" || true)
    FAIL=$(grep -c "TEST FAIL:" "$logfile" || true)
    SKIP=$(grep -c "TEST SKIP:" "$logfile" || true)
    # calculate total from the three counts
    TOTAL=$(( PASS + FAIL + SKIP ))

    # calculate pass rate using awk since bash cannot handle decimal math
    if [ "$TOTAL" -gt 0 ]; then
        PASS_RATE=$(awk "BEGIN { printf \"%.1f\", ($PASS / $TOTAL) * 100 }")
    else
        # avoid division by zero if no tests were found
        PASS_RATE="0.0"
    fi

    # set verdict to FAIL if any tests failed, otherwise PASS
    if [ "$FAIL" -gt 0 ]; then
        VERDICT="FAIL"
    else
        VERDICT="PASS"
    fi

    # write one table row for this log file
    echo "  <tr><td>$logfile</td><td>$TOTAL</td><td>$PASS</td><td>$FAIL</td><td>$SKIP</td><td>$PASS_RATE%</td><td>$VERDICT</td></tr>" >> "$HTML_REPORT"

done

# close all open HTML tags to produce a valid document
echo "</table>" >> "$HTML_REPORT"
echo "</body>" >> "$HTML_REPORT"
echo "</html>" >> "$HTML_REPORT"

echo "HTML report generated at: $HTML_REPORT"
