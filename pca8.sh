

#!/bin/bash


#SBATCH --output=output.log # Output file for stdout


# Prompt the user to enter a number





echo -n “Enter a number: “

read num





if [ $num -gt 0 ]; then

    echo “$num is a positive number.”

elif [ $num -lt 0 ]; then

    echo “$num is a negative number.”

else

    echo “$num is zero.”

fi
