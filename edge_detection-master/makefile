# Compiler and flags

CC = gcc

CFLAGS = -fopenmp -lstdc++ -lpng -lm

OPT_FLAGS = -O3 -march=native

PROFILE_FLAGS = -O3 -fprofile-generate



# Source files

SRC = png_util.c main_process.c

OBJ = $(SRC:.c=.o)



# Executables

EXECUTABLES = png_util png_util_instrumented png_util_optimized



# Default target

all: $(EXECUTABLES)



# Rule to build the default executable

png_util: $(OBJ)

	$(CC) $(CFLAGS) -o $@ $^



# Rule to build the instrumented executable

png_util_instrumented: $(SRC)

	$(CC) $(CFLAGS) $(PROFILE_FLAGS) -o $@ $^



# Rule to build the optimized executable

png_util_optimized: $(SRC)

	$(CC) $(CFLAGS) $(OPT_FLAGS) -o $@ $^



# Rule to compile source files into object files

%.o: %.c

	$(CC) $(CFLAGS) -c $< -o $@



# Clean up build files

clean:

	rm -f $(OBJ) $(EXECUTABLES)



# Test the executables

test: all

	@echo "Testing png_util..."

	./png_util test.png output_default.png

	@echo "Testing png_util_instrumented..."

	./png_util_instrumented test.png output_instrumented.png

	@echo "Testing png_util_optimized..."

	./png_util_optimized test.png output_optimized.png

	@echo "Tests completed."



# Phony targets

.PHONY: all clean testall: process 

main_process.o: main_process.c
	gcc -c main_process.c 

png_util.o: png_util.c
	gcc -l lpng16 -c png_util.c

process: main_process.o png_util.o
	gcc -o process -lm -l png16 main_process.o png_util.o

test: process 
	./process ./images/cube.png test.png

clean:
	rm *.o
	rm process 
