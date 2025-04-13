#!/bin/bash

#SBATCH -N 4

#SBATCH --job-name=print_env_vars  # Name of the job

#SBATCH --output=output.log        # Output file for stdout

#SBATCH --error=error.log          # Error file for stderr

#SBATCH --ntasks=1                 # Number of tasks (processes)

#SBATCH --cpus-per-task=1          # Number of CPU cores per task

#SBATCH --time=00:01:00            # Maximum runtime (1 minute)

#SBATCH --partition=standard       # Partition (queue) to use

#SBATCH --mem=100M                 # Memory required per node



# Print all environment variables

env



# Exit the script

exit 0

