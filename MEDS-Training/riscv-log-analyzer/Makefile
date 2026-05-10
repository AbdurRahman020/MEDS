.PHONY: all test report clean help setup

all:
	@echo "=== Running analyzer on all test log files ==="
	@bash scripts/analyze.sh test_data/sample_sim.log || true
	@echo ""
	@bash scripts/analyze.sh test_data/sample_pass.log || true
	@echo ""
	@bash scripts/analyze.sh test_data/sample_fail.log || true

test:
	@echo "=== Running tests ==="
	@echo ""

	@echo "Test 1: sample_pass.log - expecting PASS verdict"
	@bash scripts/analyze.sh test_data/sample_pass.log | grep "Verdict: PASS" > /dev/null \
		&& echo "RESULT: OK" \
		|| echo "RESULT: UNEXPECTED - sample_pass.log should have all passing tests"
	
	@echo ""
	@echo "Test 2: sample_fail.log - expecting FAIL verdict"
	@bash scripts/analyze.sh test_data/sample_fail.log | grep "Verdict: FAIL" > /dev/null \
		&& echo "RESULT: OK" \
		|| echo "RESULT: UNEXPECTED - sample_fail.log should have some failing tests"
	
	@echo ""
	@echo "Test 3: Missing file - expecting an error message"
	@bash scripts/analyze.sh nonexistent.log 2>&1 | grep "Error: File not found" > /dev/null \
		&& echo "RESULT: OK" \
		|| echo "RESULT: UNEXPECTED - should have printed an error"

	@echo ""
	@echo "=== All tests completed ==="


report:
	@bash scripts/generate_report.sh

clean:
	@echo "Cleaning up generated files..."
	@rm -rf output/*
	@echo "Done!"

setup:
	@bash scripts/setup_env.sh

help:
	@echo "Available targets:"
	@echo ""
	@echo "  make all     — Run analyzer on all test log files"
	@echo "  make test    — Run basic checks on each test log"
	@echo "  make report  — Generate a combined summary report in output/"
	@echo "  make clean   — Delete all files in output/"
	@echo "  make setup   — Check that required tools are installed"
	@echo "  make help    — Show this help message"
