#!/bin/bash

# Stop the script if:
# -e:  any command fails
# -u: an undefined variable is used
# -o pipefail: a command inside a pipe fails
set -euo pipefail

# -----------------------------------------------
# RISC-V Simulation Log Analyzer
# Usage: ./analyze_log.sh <logfile> [options]
# -----------------------------------------------

# --- function 1: Show help/usage instructions ---
print_help() {
    echo "Usage: $0 <logfile> [options]"
    echo ""
    echo "Arguments:"
    echo "  <logfile>          Path to the simulation log file (required)"
    echo ""
    echo "Options:"
    echo "  --format text|csv  Output format (default: text)"
    echo "  --output <path>    Save output to a file instead of printing"
    echo "  --verbose          Show extra details while running"
    echo "  --help             Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 test_data/sample_fail.log"
    echo "  $0 test_data/sample_fail.log --format csv --output output/report.csv"
}

# --- function 2: Analyze the log file and generate a report ---
analyze_log() {
    # store the log file path passed to the function
    local LOGFILE="$1"

    # count how many PASS / FAIL / SKIP lines exist in the log
    # grep -c counts matching lines, and || true prevents the script from stopping if no match is found
    local PASS=$(grep -c "TEST PASS:" "$LOGFILE" || true)
    local FAIL=$(grep -c "TEST FAIL:" "$LOGFILE" || true)
    local SKIP=$(grep -c "TEST SKIP:" "$LOGFILE" || true)
    # calculate total number of tests
    local TOTAL=$(( PASS + FAIL + SKIP ))

    # calculate pass percentage
    # awk is used because bash cannot handle decimal math directly
    local PASS_RATE
    if [ "$TOTAL" -gt 0 ]; then
        PASS_RATE=$(awk "BEGIN { printf \"%.1f\", ($PASS / $TOTAL) * 100 }")
    else
        PASS_RATE="0.0"
    fi

    # get names of failed tests
    # awk '{print $5}' prints the 5th word from each matching line
    local FAILED_TESTS=$(grep "TEST FAIL:" "$LOGFILE" | awk '{print $5}' || true)
    # extract timing values like 0.32 from strings like (0.32s)
    # grep -o prints only the matching part, and sed removes brackets and the letter 's'
    local TIMES=$(grep -o '([0-9]*\.[0-9]*s)' "$LOGFILE" | sed 's/[()s]//g' || true)

    # default timing values if no timings exist
    local MIN_TIME="N/A"
    local MAX_TIME="N/A"
    local AVG_TIME="N/A"
    local MIN_TEST=""
    local MAX_TEST=""

    # only calculate timing statistics if timings were found
    if [ -n "$TIMES" ]; then
        # find minimum execution time
        MIN_TIME=$(echo "$TIMES" | awk 'BEGIN{m=9999} {if($1<m) m=$1} END{printf "%.2f", m}')
        # find maximum execution time
        MAX_TIME=$(echo "$TIMES" | awk 'BEGIN{m=0} {if($1>m) m=$1} END{printf "%.2f", m}')
        # calculate average execution time
        AVG_TIME=$(echo "$TIMES" | awk '{s+=$1; n++} END{printf "%.2f", s/n}')
        # find the test names corresponding to min/max times
        MIN_TEST=$(grep "${MIN_TIME}s" "$LOGFILE" | grep "TEST" | awk '{print $5}' | head -1 || true)
        MAX_TEST=$(grep "${MAX_TIME}s" "$LOGFILE" | grep "TEST" | awk '{print $5}' | head -1 || true)
    fi

    # -----------------------------------------------
    # Print the final report
    # -----------------------------------------------

    if [ "$FORMAT" = "csv" ]; then
        # CSV format output
        echo "logfile,total,passed,failed,skipped,pass_rate"
        echo "$LOGFILE,$TOTAL,$PASS,$FAIL,$SKIP,$PASS_RATE%"

        # print failed tests if any exist
        if [ -n "$FAILED_TESTS" ]; then
            echo ""
            echo "failed_tests"
            echo "$FAILED_TESTS"
        fi

    else

        # default text output
        echo "=== RISC-V Simulation Log Analysis ==="
        echo "Log file : $LOGFILE"
        echo "Date     : $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""

        echo "--- Results ---"
        echo "Total   : $TOTAL"
        echo "Passed  : $PASS ($PASS_RATE%)"
        echo "Failed  : $FAIL"
        echo "Skipped : $SKIP"
        echo ""

        # print failed test names
        if [ "$FAIL" -gt 0 ]; then
            echo "--- Failed Tests ---"

            # counter for numbering failed tests
            local i=1

            # read failed test names one by one
            while IFS= read -r name; do
                echo "  $i. $name"
                i=$(( i + 1 ))

            done <<< "$FAILED_TESTS"

            echo ""
        fi

        echo "--- Timing ---"
        echo "Min : ${MIN_TIME}s  ($MIN_TEST)"
        echo "Max : ${MAX_TIME}s  ($MAX_TEST)"
        echo "Avg : ${AVG_TIME}s"
        echo ""

        # final PASS/FAIL result
        if [ "$FAIL" -gt 0 ]; then
            echo "--- Verdict: FAIL ---"
        else
            echo "--- Verdict: PASS ---"
        fi
    fi

    # return exit code
    # return 1 if failures exist, otherwise return 0
    if [ "$FAIL" -gt 0 ]; then
        return 1
    else
        return 0
    fi
}

# -----------------------------------------------
# Main program starts here
# -----------------------------------------------

# default settings
FORMAT="text"
OUTPUT=""
VERBOSE=false
LOG_FILE=""

# read all command-line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        # show help message
        --help)
            print_help
            exit 0
            ;;
        # set output format
        --format)
            # move to next argument
            shift
            FORMAT="$1"
            # allow only text or csv
            if [ "$FORMAT" != "text" ] && [ "$FORMAT" != "csv" ]; then
                echo "Error: --format must be 'text' or 'csv'" >&2
                exit 1
            fi
            ;;
        # set output file path
        --output)
            # move to next argument
            shift
            OUTPUT="$1"
            ;;
        # enable verbose mode
        --verbose)
            VERBOSE=true
            ;;
        # handle unknown options
        -*)
            echo "Error: Unknown option: $1" >&2
            echo "Run '$0 --help' for usage." >&2
            exit 1
            ;;
        # treat non-option argument as log file path
        *)
            LOG_FILE="$1"
            ;;
    esac
    # move to next argument
    shift
done

# check if log file argument is missing
if [ -z "$LOG_FILE" ]; then
    echo "Error: No log file specified." >&2
    print_help
    exit 1
fi

# check if the file exists
if [ ! -f "$LOG_FILE" ]; then
    echo "Error: File not found: $LOG_FILE" >&2
    exit 1
fi

# print extra information in verbose mode
if [ "$VERBOSE" = true ]; then
    echo "[verbose] Reading log file: $LOG_FILE"
    echo "[verbose] Output format: $FORMAT"
    # if OUTPUT is empty, show stdout
    echo "[verbose] Output destination: ${OUTPUT:-stdout}"
    echo ""
fi

# run analysis
if [ -n "$OUTPUT" ]; then
    # create output directory if it doesn't exist
    mkdir -p "$(dirname "$OUTPUT")"
    # save report to file
    analyze_log "$LOG_FILE" > "$OUTPUT"
    echo "Report saved to: $OUTPUT"
else
    # print report directly to terminal
    analyze_log "$LOG_FILE"
fi
