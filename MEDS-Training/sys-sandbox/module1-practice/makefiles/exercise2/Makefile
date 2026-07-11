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
	@echo "Available targets:"
	@echo "  all    - Build the application"
	@echo "  test   - Run the application"
	@echo "  clean  - Remove object files and executable"
	@echo "  help   - Show this help message"
