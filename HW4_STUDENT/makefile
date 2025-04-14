# Compiler settings
CC := gcc
MPICC := mpicc
EXT := c
CFLAGS := -Wall -Wextra -O2
LDFLAGS := -lm -lpng
MPI_FLAGS := $(CFLAGS)

# Targets
all: revGOL revGOL-mpi gol timecheck.sh mpi_job.sb

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

# Time check script
timecheck.sh:
	echo '#!/bin/bash' > $@
	echo 'echo "Start time: $$(date)"' >> $@
	echo 'START=$$(date +%s)' >> $@
	echo './$$1 $$2' >> $@
	echo 'END=$$(date +%s)' >> $@
	echo 'echo "End time: $$(date)"' >> $@
	echo 'DIFF=$$((END-START))' >> $@
	echo 'echo "Execution time: $$DIFF seconds"' >> $@
	chmod +x $@

# MPI job submission script
mpi_job.sb:
	echo '#!/bin/bash' > $@
	echo '#SBATCH --job-name=reverseGOL' >> $@
	echo '#SBATCH --output=mpi_output_%j.txt' >> $@
	echo '#SBATCH --nodes=4' >> $@
	echo '#SBATCH --ntasks-per-node=8' >> $@
	echo '#SBATCH --time=01:00:00' >> $@
	echo '' >> $@
	echo 'module load openmpi' >> $@
	echo '' >> $@
	echo 'mpirun -np $$SLURM_NTASKS ./revGOL-mpi data.txt' >> $@
	chmod +x $@

# Test targets
test: revGOL data.txt
	./timecheck.sh revGOL data.txt

test-mpi: revGOL-mpi data.txt
	./timecheck.sh revGOL-mpi data.txt

submit-mpi: revGOL-mpi mpi_job.sb
	sbatch mpi_job.sb

# Cleanup
clean:
	rm -f *.o
	rm -f gol revGOL revGOL-mpi
	rm -f *.png
	rm -f mpi_output_*.txt mpi_best.txt mpi_report.txt
	rm -f timecheck.sh mpi_job.sb

.PHONY: all test test-mpi submit-mpi clean
