# these are command names, not actual files
.PHONY: all test report clean help setup

# run analyzer on all sample logs
all:
	@echo "=== Running analyzer on all test log files ==="

	# run analyzer on sample log
	@bash scripts/analyze.sh test_data/sample_sim.log || true

	@echo ""

	# run analyzer on passing log
	@bash scripts/analyze.sh test_data/sample_pass.log || true

	@echo ""

	# run analyzer on failing log
	@bash scripts/analyze.sh test_data/sample_fail.log || true


# run simple checks to verify script behavior
test:
	@echo "=== Running tests ==="
	@echo ""

	# expect PASS verdict
	@echo "Test 1: sample_pass.log - expecting PASS verdict"

	# grep checks if the output contains "Verdict: PASS"
	@bash scripts/analyze.sh test_data/sample_pass.log | grep "Verdict: PASS" > /dev/null \
		&& echo "RESULT: OK" \
		|| echo "RESULT: UNEXPECTED - sample_pass.log should have all passing tests"

	@echo ""

	# expect FAIL verdict
	@echo "Test 2: sample_fail.log - expecting FAIL verdict"

	@bash scripts/analyze.sh test_data/sample_fail.log | grep "Verdict: FAIL" > /dev/null \
		&& echo "RESULT: OK" \
		|| echo "RESULT: UNEXPECTED - sample_fail.log should have some failing tests"

	@echo ""

	# expect file-not-found error
	@echo "Test 3: Missing file - expecting an error message"

	# 2>&1 sends error messages into grep
	@bash scripts/analyze.sh nonexistent.log 2>&1 | grep "Error: File not found" > /dev/null \
		&& echo "RESULT: OK" \
		|| echo "RESULT: UNEXPECTED - should have printed an error"

	@echo ""
	@echo "=== All tests completed ==="


# generate combined report
report:
	@bash scripts/generate_report.sh


# delete generated files
clean:
	@echo "Cleaning up generated files..."

	# Remove everything inside output/
	@rm -rf output/*

	@echo "Done!"


# run setup script
setup:
	@bash scripts/setup_env.sh


# show available make commands
help:
	@echo "Available targets:"
	@echo ""
	@echo "  make all     — Run analyzer on all test log files"
	@echo "  make test    — Run basic checks on each test log"
	@echo "  make report  — Generate a combined summary report in output/"
	@echo "  make clean   — Delete all files in output/"
	@echo "  make setup   — Check that required tools are installed"
	@echo "  make help    — Show this help message"
