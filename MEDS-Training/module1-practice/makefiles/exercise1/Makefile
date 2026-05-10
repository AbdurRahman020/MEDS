# compiler to use
CC = gcc

# compiler flags:
# 	-Wall and -Wextra enable warnings
# 	-g adds debugging information
CFLAGS = -Wall -Wextra -g

# source files
SRC = main.c utils.c

# convert .c files into .o object files
OBJ = $(SRC:.c=.o)

# name of the final executable
TARGET = myapp

# default target
all: $(TARGET)

# build the executable from object files
$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $^

# compile .c files into .o files
# $< = current source file
# $@ = output object file
%.o: %.c utils.h
	$(CC) $(CFLAGS) -c $< -o $@

# run the program
test: $(TARGET)
	./$(TARGET)

# remove generated files
clean:
	rm -f $(OBJ) $(TARGET)
