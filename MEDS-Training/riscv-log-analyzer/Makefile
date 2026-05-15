# these are command names, not actual files
# without .PHONY, make would look for files named 'all', 'test', etc.
.PHONY: all test report clean help setup

# run analyzer on all sample logs
all:
	@echo "=== Running analyzer on all test log files ==="
	@echo ""

	@# FAILED tracks if any analyzer call returned a non-zero exit code
	@# all commands are chained with \ and ; because each recipe line runs in a separate shell
	@# $$ is used instead of $ because make reserves $ for its own variable expansion
	@FAILED=0; \
	bash scripts/analyze.sh test_data/sample_sim.log || FAILED=1; \
	echo ""; \
	bash scripts/analyze.sh test_data/sample_pass.log || FAILED=1; \
	echo ""; \
	bash scripts/analyze.sh test_data/sample_fail.log || FAILED=1; \
	echo "Exit code: $$FAILED"


# run simple checks to verify script behavior
test:
	@echo "=== Running tests ==="
	@echo ""

	@echo "Test 1: sample_pass.log - expecting PASS verdict"
	@# pipe output into grep — exits 0 if found, then && / || decide what to print
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
	@# 2>&1 redirects stderr into stdout so grep can read the error message
	@bash scripts/analyze.sh nonexistent.log 2>&1 | grep "Error: File not found" > /dev/null \
		&& echo "RESULT: OK" \
		|| echo "RESULT: UNEXPECTED - should have printed an error"

	@echo ""
	@echo "=== All tests completed ==="


# generate combined report
report:
	@bash scripts/generate_report.sh


# delete all generated files inside output/
clean:
	@echo "Cleaning up generated files..."
	@# -rf removes directories and their contents without prompting
	@rm -rf output/*
	@echo "Done!"


# check that all required tools are installed
setup:
	@bash scripts/setup_env.sh


# show all available make targets with descriptions
help:
	@echo "Available targets:"
	@echo ""
	@echo "  make all     — Run analyzer on all test log files"
	@echo "  make test    — Run basic checks on each test log"
	@echo "  make report  — Generate a combined summary report in output/"
	@echo "  make clean   — Delete all files in output/"
	@echo "  make setup   — Check that required tools are installed"
	@echo "  make help    — Show this help message"
