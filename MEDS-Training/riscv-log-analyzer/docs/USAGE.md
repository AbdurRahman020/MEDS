# USAGE.md — Detailed Command Reference

## analyze.sh

The main script. Give it a log file and it tells you what happened.

### Syntax

```bash
bash scripts/analyze.sh <logfile> [--format text|csv] [--output <path>] [--verbose] [--help]
```

### Arguments

**`<logfile>`** (required)
Path to the `.log` file you want to analyze. The file must exist and follow the expected format (see below).

**`--format text|csv`** (optional, default: `text`)
Choose how the output is formatted.
- `text` — human-readable report (good for reading in the terminal)
- `csv` — comma-separated values (good for opening in Excel or processing further)

**`--output <path>`** (optional)
Write the output to a file instead of printing it. The directory will be created automatically if it doesn't exist.

**`--verbose`** (optional)
Print extra information before the main output, like which file is being read and what format is being used. Useful for debugging.

**`--help`** (optional)
Print the usage message and exit.

---

### Exit Codes

| Code | Meaning |
|---|---|
| `0` | All tests in the log passed (or there were no failures) |
| `1` | One or more tests failed |

You can check the exit code in the terminal with `echo $?` right after running the script.

---

### Expected Log Format

The script expects log lines that look like this:

```
[2026-05-01 10:23:45] TEST START: rv32i-add
[2026-05-01 10:23:46] TEST PASS: rv32i-add (0.82s)
[2026-05-01 10:23:47] TEST FAIL: rv32i-sll (1.02s)
[2026-05-01 10:23:48] TEST SKIP: rv32i-srl (not supported)
```

Each `TEST PASS`, `TEST FAIL`, and `TEST SKIP` line contributes to the counts. The time in parentheses (like `0.82s`) is used for timing statistics.

---

## Makefile Targets

Run these from the project root directory.

| Command | What it does |
|---|---|
| `make all` | Run analyze.sh on all three test log files |
| `make test` | Run basic checks to verify the scripts work correctly |
| `make report` | Run generate_report.sh to create `output/summary_report.txt` |
| `make clean` | Delete everything inside `output/` |
| `make setup` | Check that all required tools (bash, grep, awk, etc.) are installed |
| `make help` | Show a list of all available make targets |

---

## generate_report.sh

Runs `analyze.sh` on every `.log` file in `test_data/` and combines the results into a single file at `output/summary_report.txt`.

```bash
bash scripts/generate_report.sh
# or
make report
```

---

## setup_env.sh

Checks that all the command-line tools used by this project are installed on your system.

```bash
bash scripts/setup_env.sh
# or
make setup
```
