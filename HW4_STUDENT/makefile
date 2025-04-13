# Compiler settings
CC := gcc
MPICC := mpicc
EXT := c
CFLAGS := -Wall -Wextra -O2
LDFLAGS := -lm -lpng
MPI_FLAGS := $(CFLAGS)  # Add any MPI-specific flags here if needed

# Targets
all: revGOL revGOL-mpi gol

# Original serial version
reverseGOL.o: reverseGOL.$(EXT)
	$(CC) $(CFLAGS) -c $< -o $@

png_util.o: png_util.c png_util.h
	$(CC) $(CFLAGS) -c $< -o $@

revGOL: reverseGOL.o png_util.o
	$(CC) $(CFLAGS) $^ $(LDFLAGS) -o $@

# MPI version
reverseGOL-mpi.o: reverseGOL-mpi.$(EXT)
	$(MPICC) $(MPI_FLAGS) -c $< -o $@

revGOL-mpi: reverseGOL-mpi.o png_util.o
	$(MPICC) $(MPI_FLAGS) $^ $(LDFLAGS) -o $@

# Game of Life visualization
gameoflife.o: gameoflife.$(EXT)
	$(CC) $(CFLAGS) -c $< -o $@

gol: gameoflife.o png_util.o
	$(CC) $(CFLAGS) $^ $(LDFLAGS) -o $@

# Test targets
test: revGOL data.txt
	./revGOL data.txt

test-mpi: revGOL-mpi data.txt
	mpirun -np 4 ./revGOL-mpi data.txt

# Cleanup
clean:
	rm -f *.o
	rm -f gol revGOL revGOL-mpi
	rm -f *.png

.PHONY: all test test-mpi clean
