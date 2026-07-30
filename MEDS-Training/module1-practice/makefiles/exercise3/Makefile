CC = gcc
CFLAGS = -Wall -Wextra -g

SRC = main.c utils.c
OBJ = $(SRC:.c=.o)
TARGET = myapp

all: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^

%.o: %.c utils.h
	$(CC) $(CFLAGS) -c $< -o $@

test: $(TARGET)
	./$(TARGET)

clean:
	rm -f $(OBJ) $(TARGET)

# display available make commands and variables
help:
	@echo "Usage:"
	@echo "  make   - Build the application"
	@echo "  test   - Run the application"
	@echo "  clean  - Remove object files and executable"
	@echo "  help   - Show this help message"
	@echo ""
	@echo "Variables you can override:"
	@echo "  CC     - C compiler (default: gcc)"
	@echo "  CFLAGS - Compiler flags (default: -Wall -Wextra -g)"
	@echo ""
	@echo "Example: make CC=clang CFLAGS='-Wall -Wextra -O2'"
