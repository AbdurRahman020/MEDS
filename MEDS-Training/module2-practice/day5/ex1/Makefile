CC     = gcc
CFLAGS = -Wall -Wextra -std=c11 -g

SRC    = main.c decoder.c

all: decoder

decoder: SRC
	$(CC) $(CFLAGS) -o decoder $(SRC)

clean:
	rm -f decoder
