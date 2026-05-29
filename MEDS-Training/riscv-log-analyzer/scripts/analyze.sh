#!/bin/bash

# stop the script if:
#   -e:  any command fails
#   -u: an undefined variable is used
#   -o pipefail: a command inside a pipe fails
set -euo pipefail

# ANSI color codes for terminal output
# these are escape sequences that terminals interpret as colors
GREEN='\033[0;32m'
RED='\033[0;31m'
# NC = No Color, resets color back to normal after use
NC='\033[0m'


# -------------------------------------------------------------------
# RISC-V Simulation Log Analyzer
#
# usage: ./analyze.sh [-f text|csv] [-o <path>] [-v] [-h] <logfile>
# -------------------------------------------------------------------

# --- function 1: show help/usage instructions ---
print_help() {
    echo "Usage: $0 [-f text|csv] [-o <path>] [-v] [-h] <logfile>"
    echo ""
    echo "Arguments:"
    echo "  <logfile>          Path to the simulation log file (required)"
    echo ""
    echo "Options:"
    echo "  -f text|csv        Output format (default: text)"
    echo "  -o <path>          Save output to a file instead of printing"
    echo "  -v                 Show extra details while running"
    echo "  -h                 Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 test_data/sample_fail.log"
    echo "  $0 -f csv -o output/report.csv test_data/sample_fail.log"
}

# --- function 2: analyze the log file and generate a report ---
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

    # ------------------------
    # print the final report
    # ------------------------

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
        # -e enables interpretation of \e[ color codes
        # $NC resets the color after the verdict so nothing else gets colored
        if [ "$FAIL" -gt 0 ]; then
            echo -e "${RED}--- Verdict: FAIL ---${NC}"
        else
            echo -e "${GREEN}--- Verdict: PASS ---${NC}"
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

# --------------
# main program
# --------------

# default settings
FORMAT="text"
OUTPUT=""
VERBOSE=false
LOG_FILE=""

# getopts is a built-in bash tool for parsing short flags like -f or -o
# the colon after a letter means that flag expects a value after it
while getopts ":f:o:vh" opt; do
    case "$opt" in
        # -f sets the output format
        f)
            FORMAT="$OPTARG"
            # allow only text or csv
            if [ "$FORMAT" != "text" ] && [ "$FORMAT" != "csv" ]; then
                echo "Error: -f must be 'text' or 'csv'" >&2
                exit 1
            fi
            ;;
        # -o sets the output file path
        o)
            OUTPUT="$OPTARG"
            ;;
        # -v enables verbose mode
        v)
            VERBOSE=true
            ;;
        # -h shows help
        h)
            print_help
            exit 0
            ;;
        # handle unknown flags
        \?)
            echo "Error: Unknown option: -$OPTARG" >&2
            echo "Run '$0 -h' for usage." >&2
            exit 1
            ;;
    esac
done

# shift past all the parsed flags so $1 becomes the log file argument
# OPTIND is the index of the next argument after the flags
shift $(( OPTIND - 1 ))
LOG_FILE="${1:-}"

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
