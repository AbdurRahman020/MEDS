CC     = gcc
CFLAGS = -Wall -Wextra -std=c11 -g

SRC    = main.c decoder.c

all: decoder

decoder: SRC
	$(CC) $(CFLAGS) -o decoder $(SRC)

debug: SRC
	$(CC) $(CFLAGS) -DDEBUG -o decoder $(SRC)

release: SRC
	$(CC) $(CFLAGS) -DRV64 -O2 -o decoder $(SRC)

clean:
	rm -f decoder

.PHONY: all debug release clean
