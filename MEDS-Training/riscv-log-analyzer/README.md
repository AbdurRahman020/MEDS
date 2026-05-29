# riscv-log-analyzer - MEDS Module 1 Grand Assignment

A shell-based tool that reads RISC-V simulation log files, counts test results, and prints a summary report.

Built as the Module 1 capstone project for MEDS Lab.

---

## What it does

- Counts how many tests **passed**, **failed**, and were **skipped**
- Shows the **pass rate** as a percentage
- Lists the **names of failing tests**
- Shows **min / max / avg execution time** across all tests
- Can output results as plain text or CSV
- Generates a **combined text + HTML summary report** across all log files

---

## Installation

No installation needed. Just clone the repo and make the scripts executable:

```bash
git clone https://github.com/AbdurRahman020/MEDS
cd MEDS/MED-Training/riscv-log-analyzer
chmod +x scripts/*.sh
```

Check that all required tools are available:

```bash
make setup
```

This runs `scripts/setup_env.sh`, which checks for: `bash`, `mkdir`, `date`, `grep`, `awk`.

Sample output:
```
Checking required tools...

[OK] bash found at: /usr/bin/bash
[OK] mkdir found at: /usr/bin/mkdir
[OK] date found at: /usr/bin/date
[OK] grep found at: /usr/bin/grep
[OK] awk found at: /usr/bin/awk

All required tools are available. You can proceed with the setup.

Try Running: make all
```

---

## Usage

### Analyze a single log file

```bash
bash scripts/analyze.sh <logfile> [options]
```

> **Note:** Flags must come **before** the log file argument.

| Option | Description |
|---|---|
| `-f text\|csv` | Output format (default: `text`) |
| `-o <path>` | Save output to a file instead of printing |
| `-v` | Print extra info while running |
| `-h` | Show usage information |

### Generate a report for all log files

```bash
make report
```

This runs `scripts/generate_report.sh`, which processes every `.log` file in `test_data/` and produces:
- `output/summary_reports.txt` — plain text summary of all files
- `output/summary_reports.html` — HTML table with one row per log file

---

## Examples

**Basic analysis:**
```bash
bash scripts/analyze.sh test_data/sample_fail.log
```

**Verbose mode** (flags must come before the log file):
```bash
bash scripts/analyze.sh -v test_data/sample_fail.log
```

**Save as CSV:**
```bash
bash scripts/analyze.sh -f csv -o output/results.csv test_data/sample_fail.log
```

**Show help:**
```bash
bash scripts/analyze.sh -h
```

**Run analyzer on all test files:**
```bash
make all
```

**Generate combined text + HTML summary report:**
```bash
make report
```

---

## Sample Output

**Text format (`-f text`, default):**
```
=== RISC-V Simulation Log Analysis ===
Log file : test_data/sample_fail.log
Date     : 2026-05-25 08:55:40

--- Results ---
Total   : 3
Passed  : 1 (33.3%)
Failed  : 1
Skipped : 1

--- Failed Tests ---
  1. rv32i-sll

--- Timing ---
Min : 0.82s  (rv32i-add)
Max : 1.02s  (rv32i-sll)
Avg : 0.92s

--- Verdict: FAIL ---
```

**CSV format (`-f csv`):**
```
logfile,total,passed,failed,skipped,pass_rate
test_data/sample_fail.log,3,1,1,1,33.3%

failed_tests
rv32i-sll
```

**HTML report (`make report`):**

Saved to `output/summary_reports.html` — contains a table with columns:
`Log File | Total | Passed | Failed | Skipped | Pass Rate | Verdict`

---

## Project Structure

```
riscv-log-analyzer/
├── README.md
├── Makefile
├── .gitignore
├── scripts/
│   ├── analyze.sh          # Main analyzer — single log file
│   ├── setup_env.sh        # Checks required tools are installed
│   └── generate_report.sh  # Batch processor — all logs → text + HTML report
├── test_data/
│   ├── sample_sim.log
│   ├── sample_pass.log
│   └── sample_fail.log
├── output/                 # Generated reports (git-ignored)
│   ├── summary_reports.txt
│   └── summary_reports.html
└── docs/
    └── USAGE.md
```
