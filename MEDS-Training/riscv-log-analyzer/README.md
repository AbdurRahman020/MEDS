# riscv-log-analyzer v1

A shell-based tool that reads RISC-V simulation log files, counts test results, and prints a summary report.

Built as the Module 1 capstone project for MEDS Lab.

---

## What it does

- Counts how many tests **passed**, **failed**, and were **skipped**
- Shows the **pass rate** as a percentage
- Lists the **names of failing tests**
- Shows **min / max / avg execution time** across all tests
- Can output results as plain text or CSV

---

## Installation

No installation needed. Just clone the repo and make the scripts executable:

```bash
git clone <your-repo-url>
cd riscv-log-analyzer
chmod +x scripts/*.sh
```

Check that all required tools are available:

```bash
make setup
```

---

## Usage

```bash
bash scripts/analyze.sh <logfile> [options]
```

| Option | Description |
|---|---|
| `--format text\|csv` | Output format (default: `text`) |
| `--output <path>` | Save output to a file instead of printing |
| `--verbose` | Print extra info while running |
| `--help` | Show usage information |

---

## Examples

**Basic analysis:**
```bash
bash scripts/analyze.sh test_data/sample_fail.log
```

**Save as CSV:**
```bash
bash scripts/analyze.sh test_data/sample_fail.log --format csv --output output/results.csv
```

**Run on all test files at once:**
```bash
make all
```

**Generate a combined summary report:**
```bash
make report
```

---

## Sample Output

```
=== RISC-V Simulation Log Analysis ===
Log file: test_data/sample_fail.log
Analysis date: 2026-05-05 14:30:00

--- Results Summary ---
Total tests:  10
Passed:       7 (70.0%)
Failed:       2
Skipped:      1

--- Failed Tests ---
  1. rv32i-sll
  2. rv32i-beq

--- Timing Statistics ---
Min time: 0.42s (rv32i-nop)
Max time: 2.31s (rv32i-mul)
Avg time: 0.87s

--- Verdict: FAIL ---
```

---

## Project Structure

```
riscv-log-analyzer/
├── README.md
├── Makefile
├── .gitignore
├── scripts/
│   ├── analyze.sh          # Main script
│   ├── setup_env.sh        # Tool checker
│   └── generate_report.sh  # Batch report generator
├── test_data/
│   ├── sample_sim.log
│   ├── sample_pass.log
│   └── sample_fail.log
├── output/                 # Generated reports (git-ignored)
└── docs/
    └── USAGE.md
```
