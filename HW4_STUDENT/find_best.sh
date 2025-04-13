#!/bin/bash

# Find the best solution from all revGOL output files
# and save it to pp_best.txt

echo "Finding best solution from all output files..."

# Initialize variables
BEST_FITNESS=999999
BEST_SEED=""
BEST_FILE=""
BEST_SERIAL=""

# Process all output files
for out_file in revGOL_*.out; do
    # Extract seed from filename (handles both revGOL_JOBID_SEED.out and revGOL_SEED.out patterns)
    seed=$(echo "$out_file" | grep -oE '[0-9]+\.out' | cut -d'.' -f1)
    
    # Get the final fitness value (last generation)
    fitness=$(grep "Done with Generation" "$out_file" | tail -1 | awk '{print $NF}')
    
    # Compare fitness values (lower is better)
    if (( $(echo "$fitness < $BEST_FITNESS" | bc -l) )); then
        BEST_FITNESS=$fitness
        BEST_SEED=$seed
        BEST_FILE=$out_file
        BEST_SERIAL="serial_${seed}.txt"
    fi
done

echo "Best solution found in $BEST_FILE"
echo "Seed: $BEST_SEED with fitness: $BEST_FITNESS"

# Try to find and copy the best solution
if [ -f "$BEST_SERIAL" ]; then
    cp "$BEST_SERIAL" pp_best.txt
    echo "Successfully copied $BEST_SERIAL to pp_best.txt"
else
    echo "Warning: Could not find $BEST_SERIAL"
    echo "Searching for alternative serial files..."
    
    # Try alternative patterns if default doesn't exist
    ALT_SERIAL=$(ls serial*${BEST_SEED}*.txt 2>/dev/null | head -1)
    
    if [ -f "$ALT_SERIAL" ]; then
        cp "$ALT_SERIAL" pp_best.txt
        echo "Successfully copied $ALT_SERIAL to pp_best.txt"
    else
        echo "Error: Could not find solution file for seed $BEST_SEED"
        echo "Possible solutions:"
        echo "1. Check if serial files were generated"
        echo "2. Verify the naming pattern of serial files"
        echo "3. Manually inspect output files"
        exit 1
    fi
fi

# Generate summary report
echo "Generating results summary..."
{
    echo "Optimization Results Summary"
    echo "==========================="
    echo "Total output files processed: $(ls revGOL_*.out 2>/dev/null | wc -l)"
    echo "Best seed: $BEST_SEED"
    echo "Best fitness: $BEST_FITNESS"
    echo "Best solution file: pp_best.txt"
    echo ""
    echo "Top 5 solutions:"
    grep "Done with Generation" revGOL_*.out | awk '{
        split(FILENAME, parts, /[_\.]/); 
        seed = parts[3]; 
        fitness = $NF; 
        if (!(seed in best) || fitness < best[seed]) {
            best[seed] = fitness;
        }
    } END {
        for (seed in best) {
            print best[seed], seed;
        }
    }' | sort -n | head -5
} > results_summary.txt

echo "Summary saved to results_summary.txt"
echo "Done!"
