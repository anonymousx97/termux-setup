CC ?= clang
CFLAGS = -std=c23 -Wall -Wextra -O2 -Iinclude
LDFLAGS = -lcurl

SRC = $(wildcard src/*.c)
OBJ = $(patsubst src/%.c,build/%.o,$(SRC))
TARGET ?= setup

# Gets set in github actions env.
ifdef TARGET_ARCH
OUT = $(TARGET)-$(TARGET_ARCH)
else
OUT = $(TARGET)
endif

all: $(OUT)

$(OUT): $(OBJ)
	$(CC) $(CFLAGS) -o $@ $(OBJ) $(LDFLAGS)

build/%.o: src/%.c
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -rf build