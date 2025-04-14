#!/bin/bash
#SBATCH --job-name=reverseGOL
#SBATCH --output=mpi_output_%j.txt
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=4
#SBATCH --time=00:10:00

# Load required modules
module load openmpi/4.0.3

# Compile the program
echo "Compiling reverseGOL-mpi.c..."
mpicc -o reverseGOL-mpi reverseGOL-mpi.c -Wall -O3
if [ $? -ne 0 ]; then
    echo "Compilation failed!"
    exit 1
fi

# Run the MPI program
echo "Running MPI program with $SLURM_NTASKS tasks..."
mpirun -np $SLURM_NTASKS ./reverseGOL-mpi

# Process output to find best solution
echo "Analyzing results..."
OUTPUT_FILE="mpi_output_$SLURM_JOB_ID.txt"

# Find perfect solution if it exists
if grep -q "Perfect plate found" $OUTPUT_FILE; then
    echo "Perfect solution found!"
    grep -A $((n+2)) "Perfect plate found" $OUTPUT_FILE | tail -n $n > mpi_best.txt
    FITNESS=0
else
    # Find best fitness from output
    FITNESS=$(grep "fitness=" $OUTPUT_FILE | awk -F= '{print $NF}' | sort -n | head -1)
    echo "Best fitness found: $FITNESS"
    
    # Find and save the corresponding pattern
    grep -B1 "fitness=$FITNESS" $OUTPUT_FILE -m 1 | head -n 1 > mpi_best.txt
    grep -A $n "fitness=$FITNESS" $OUTPUT_FILE | tail -n +2 >> mpi_best.txt
fi

# Generate report
echo "Generating report..."
{
    echo "Reverse Game of Life MPI Results"
    echo "==============================="
    echo "Job ID: $SLURM_JOB_ID"
    echo "Date: $(date)"
    echo "Parameters:"
    echo "- Generations: $ngen"
    echo "- Population size: $npop"
    echo "- Grid size: ${n}x${n}"
    echo "- MPI Processes: $SLURM_NTASKS"
    echo ""
    echo "Results:"
    echo "- Best fitness: $FITNESS"
    echo ""
    echo "Best solution pattern:"
    cat mpi_best.txt
} > mpi_report.txt

echo "Results saved:"
echo "- Output: $OUTPUT_FILE"
echo "- Best solution: mpi_best.txt"
echo "- Report: mpi_report.txt"
