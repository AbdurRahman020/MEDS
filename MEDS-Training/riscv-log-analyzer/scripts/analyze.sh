#!/bin/bash

# exit immediately if:
# - any command fails (-e)
# - an undefined variable is used (-u)
# - a command inside a pipeline fails (-o pipefail)
set -euo pipefail

# print help message
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

# read the log file and calculate results
analyze_log() {
    local logfile="$1"

    # count PASS, FAIL, and SKIP lines
    local pass_count
    pass_count=$(grep -c "TEST PASS:" "$logfile" || true)

    local fail_count
    fail_count=$(grep -c "TEST FAIL:" "$logfile" || true)

    local skip_count
    skip_count=$(grep -c "TEST SKIP:" "$logfile" || true)

    # total tests
    local total
    total=$(( pass_count + fail_count + skip_count ))

    # calculate pass percentage
    local pass_rate
    if [ "$total" -gt 0 ]; then
        pass_rate=$(awk "BEGIN { printf \"%.1f\", ($pass_count / $total) * 100 }")
    else
        pass_rate="0.0"
    fi

    # get names of failed tests
    local failed_tests
    failed_tests=$(grep "TEST FAIL:" "$logfile" | awk '{print $5}' || true)

    # extract timing values like 0.32 from (0.32s)
    local times
    times=$(grep -oP '\(\K[0-9]+\.[0-9]+(?=s\))' "$logfile" || true)

    # timing stats
    local min_time max_time avg_time min_test max_test
    min_time="N/A"
    max_time="N/A"
    avg_time="N/A"
    min_test=""
    max_test=""

    if [ -n "$times" ]; then
        # find min, max, and average times
        min_time=$(echo "$times" | awk 'BEGIN{min=9999} {if($1<min) min=$1} END{printf "%.2f", min}')
        max_time=$(echo "$times" | awk 'BEGIN{max=0} {if($1>max) max=$1} END{printf "%.2f", max}')
        avg_time=$(echo "$times" | awk '{sum+=$1; count++} END{printf "%.2f", sum/count}')

        # find which tests had min and max times
        min_test=$(grep "${min_time}s" "$logfile" | grep "TEST" | awk '{print $5}' | head -1 || true)
        max_test=$(grep "${max_time}s" "$logfile" | grep "TEST" | awk '{print $5}' | head -1 || true)
    fi

    # print output
    if [ "$FORMAT" = "csv" ]; then
        # csv format
        echo "logfile,total,passed,failed,skipped,pass_rate"
        echo "$logfile,$total,$pass_count,$fail_count,$skip_count,$pass_rate%"

        if [ -n "$failed_tests" ]; then
            echo ""
            echo "failed_tests"
            echo "$failed_tests"
        fi
    else
        # text format
        echo "=== RISC-V Simulation Log Analysis ==="
        echo "Log file: $logfile"
        echo "Analysis date: $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""

        echo "--- Results Summary ---"
        printf "Total tests:  %d\n" "$total"
        printf "Passed:       %d (%s%%)\n" "$pass_count" "$pass_rate"
        printf "Failed:       %d\n" "$fail_count"
        printf "Skipped:      %d\n" "$skip_count"
        echo ""

        # show failed tests if there are any
        if [ "$fail_count" -gt 0 ]; then
            echo "--- Failed Tests ---"

            local i=1
            while IFS= read -r test_name; do
                echo "  $i. $test_name"
                i=$(( i + 1 ))
            done <<< "$failed_tests"

            echo ""
        fi

        echo "--- Timing Statistics ---"
        printf "Min time: %ss (%s)\n" "$min_time" "$min_test"
        printf "Max time: %ss (%s)\n" "$max_time" "$max_test"
        printf "Avg time: %ss\n" "$avg_time"
        echo ""

        # final result
        if [ "$fail_count" -gt 0 ]; then
            echo "--- Verdict: FAIL ---"
        else
            echo "--- Verdict: PASS ---"
        fi
    fi

    # return error code if tests failed
    if [ "$fail_count" -gt 0 ]; then
        return 1
    else
        return 0
    fi
}

# main program starts here

# default settings
FORMAT="text"
OUTPUT=""
VERBOSE=false
LOG_FILE=""

# read command-line arguments
while [ $# -gt 0 ]; do
    case "$1" in
        --help)
            print_help
            exit 0
            ;;

        --format)
            shift
            FORMAT="$1"

            # allow only text or csv
            if [ "$FORMAT" != "text" ] && [ "$FORMAT" != "csv" ]; then
                echo "Error: --format must be 'text' or 'csv'" >&2
                exit 1
            fi
            ;;

        --output)
            shift
            OUTPUT="$1"
            ;;

        --verbose)
            VERBOSE=true
            ;;

        -*)
            # unknown option
            echo "Error: Unknown option: $1" >&2
            echo "Run '$0 --help' for usage." >&2
            exit 1
            ;;

        *)
            # treat as log file path
            LOG_FILE="$1"
            ;;
    esac

    shift
done

# check if log file was provided
if [ -z "$LOG_FILE" ]; then
    echo "Error: No log file specified." >&2
    echo "Run '$0 --help' for usage." >&2
    exit 1
fi

# check if file exists
if [ ! -f "$LOG_FILE" ]; then
    echo "Error: File not found: $LOG_FILE" >&2
    exit 1
fi

# extra messages in verbose mode
if [ "$VERBOSE" = true ]; then
    echo "[verbose] Reading log file: $LOG_FILE"
    echo "[verbose] Output format: $FORMAT"
    echo "[verbose] Output destination: ${OUTPUT:-stdout}"
    echo ""
fi

# save output to file or print to terminal
if [ -n "$OUTPUT" ]; then
    # create output folder if needed
    mkdir -p "$(dirname "$OUTPUT")"

    # save report to file
    analyze_log "$LOG_FILE" > "$OUTPUT"

    echo "Report saved to: $OUTPUT"
else
    # print directly
    analyze_log "$LOG_FILE"
fi
