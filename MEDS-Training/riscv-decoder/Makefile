# compiler and flags
CC       = gcc
CFLAGS   = -Wall -Wextra -Iinclude      # enable warnings + include header path
DBGFLAGS = $(CFLAGS) -g -O0             # debug flags: no optimization, include debug symbols

# source files list
SRC      = src/main.c src/decoder.c src/memory.c

# output binary location
BIN      = bin/riscv-decoder

# default target: build release version
all: $(BIN)

# build rule for final executable
$(BIN): $(SRC)
	@mkdir -p bin                      		  # ensure output directory exists
	@echo "Building riscv-decoder..."  		  # build start message
	@$(CC) $(CFLAGS) -o $@ $^          		  # compile all sources into binary
	@echo "Done → $(BIN) [build complete]"    # success message

# debug build (for gdb/valgrind)
debug: $(SRC)
	@mkdir -p bin
	@echo "Building debug build..."
	@$(CC) $(DBGFLAGS) -o $(BIN) $^    # compile with debug symbols
	@echo "Done → $(BIN) (debug)"

# run predefined test programs
test: all
	@echo "\n--- Running: mixed.hex ---"
	@./$(BIN) test/programs/mixed.hex
	@echo "\n--- Running: r_type.hex ---"
	@./$(BIN) test/programs/r_type.hex
	@echo "\n--- Running: i_type.hex ---"
	@./$(BIN) test/programs/i_type.hex
	@echo "\n--- Running: branch.hex ---"
	@./$(BIN) test/programs/branch.hex

# run with custom input file
run: all
	@if [ -z "$(FILE)" ]; then \
		echo "Error: specify a file → make run FILE=test/programs/r_type.hex"; \
	else \
		./$(BIN) $(FILE); \
	fi

# memory leak check using Valgrind (debug build recommended)
valgrind: debug
	@echo "Running Valgrind memory check..."
	@valgrind --leak-check=full --error-exitcode=1 ./$(BIN) test/programs/mixed.hex

# clean build artifacts
clean:
	@echo "Cleaning build output..."
	@rm -rf bin/
	@echo "Done."

# phony targets (not real files)
.PHONY: all debug test run valgrind clean
