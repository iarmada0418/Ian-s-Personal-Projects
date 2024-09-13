CC = gcc
CFLAGS = -std=gnu99 -Wall
LDFLAGS = -lssl -lcrypto
SRC_DIR = ./src
BIN_DIR = ./bin

# Target for myserver only
all: $(BIN_DIR)/myproxy

$(BIN_DIR)/myproxy: $(SRC_DIR)/myproxy.c
	$(CC) $(CFLAGS) $(SRC_DIR)/myproxy.c -o $(BIN_DIR)/myproxy $(LDFLAGS)

clean:
	rm -rf $(BIN_DIR)/*
