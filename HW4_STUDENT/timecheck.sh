#!/bin/bash

fastest_time=999999
best_seed=0

for seed in {1..10}; do
    echo "Running seed $seed..."
    
    start=$(date +%s.%N)
    ./revGOL cmse2.txt $seed > /dev/null
    end=$(date +%s.%N)
    
    runtime=$(echo "$end - $start" | bc)
    echo "Seed $seed completed in $runtime seconds"
    
    if (( $(echo "$runtime < $fastest_time" | bc -l) )); then
        fastest_time=$runtime
        best_seed=$seed
        cp serial.txt serial_best.txt
        echo "New fastest time: $runtime (seed $seed)"
    fi
done

echo ""
echo "Fastest run was seed $best_seed with time $fastest_time seconds"
echo "Best solution saved to serial_best.txt"
