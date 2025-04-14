#include <time.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <assert.h>
#include <mpi.h>

#define max_nodes 264
#define str_length 50
#define ngen 1000      // Number of generations
#define npop 50        // Population size
#define n 10           // Grid size (n x n)

// Function prototypes
void iteration(char *plate[2], int start, int end);
int fitness(char *plate, char *target, int size);
void print_plate(char *plate, int size);
void cross(char *a, char *b, int size);
void mutate(char *a, char *b, int size, int rate);
void makerandom(char *a, int size);
void initialize_target(char *target, int size);

// Global variables
char *population[npop]; // Population array
char *target_plate;     // Target pattern
char *buffer_plate;     // Buffer for calculations
int pop_fitness[npop];  // Fitness scores
int best = 0;           // Index of best individual
int sbest = 1;          // Index of second best individual
int M = 0;              // Some counter (appears in your code)

// Stub implementations for compilation
void iteration(char *plate[2], int start, int end) {
    // TODO: Implement actual Game of Life iteration
}

int fitness(char *plate, char *target, int size) {
    // TODO: Implement actual fitness calculation
    return 0;
}

void print_plate(char *plate, int size) {
    // TODO: Implement actual plate printing
    for (int i = 0; i < size; i++) {
        for (int j = 0; j < size; j++) {
            printf("%c", plate[i*(size+2)+j] ? 'X' : '.');
        }
        printf("\n");
    }
}

void cross(char *a, char *b, int size) {
    // TODO: Implement actual crossover
    for (int i = 0; i < (size+2)*(size+2); i++) {
        a[i] = (rand() % 2) ? a[i] : b[i];
    }
}

void mutate(char *a, char *b, int size, int rate) {
    // TODO: Implement actual mutation
    for (int i = 0; i < (size+2)*(size+2); i++) {
        if (rand() % 100 < rate) {
            a[i] = !a[i];
        }
    }
}

void makerandom(char *a, int size) {
    // Initialize random plate
    for (int i = 0; i < (size+2)*(size+2); i++) {
        a[i] = rand() % 2;
    }
}

void initialize_target(char *target, int size) {
    // TODO: Implement actual target initialization
    // Simple glider pattern for testing
    for (int i = 0; i < (size+2)*(size+2); i++) target[i] = 0;
    int center = size/2;
    target[(center)*(size+2)+center] = 1;
    target[(center)*(size+2)+center+1] = 1;
    target[(center)*(size+2)+center+2] = 1;
    target[(center+1)*(size+2)+center] = 1;
    target[(center+2)*(size+2)+center+1] = 1;
}

int main(int argc, char *argv[]) {
    // Initialize MPI
    int rank, size;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    // Initialize random seed
    srand(time(NULL) + rank);

    // Initialize plates
    target_plate = (char *)malloc((n+2)*(n+2)*sizeof(char));
    buffer_plate = (char *)malloc((n+2)*(n+2)*sizeof(char));
    for(int i=0; i<npop; i++) {
        population[i] = (char *)malloc((n+2)*(n+2)*sizeof(char));
        makerandom(population[i], n);
    }
    initialize_target(target_plate, n);

    // Main evolution loop
    for(int g=0; g < ngen; g++) {
        // Evaluate population
        for(int i=0; i<npop; i++) {
            char *plate[2];
            plate[0] = population[i];
            plate[1] = buffer_plate;
            iteration(plate, 0, n);
            pop_fitness[i] = fitness(buffer_plate, target_plate, n);
            
            if (pop_fitness[i] < pop_fitness[best]) { 
                sbest = best;
                best = i;
                if (pop_fitness[best] == 0) {
                    printf("Worker %d: Perfect plate found\n", rank);
                    char *temp = target_plate;
                    target_plate = population[best];
                    population[best] = temp;
                    printf("%d %d\n", n, M);
                    print_plate(target_plate, n);
                    pop_fitness[best] = n*n;
                    M++;
                }
            } else if (pop_fitness[i] < pop_fitness[sbest] && i != best) {
                sbest = i;
            }
        }

        // Neighbor communication with ring topology
        int plate_size = (n+2)*(n+2);
        int best_fitness = pop_fitness[best];
        
        // Use non-blocking communication
        MPI_Request requests[4];
        MPI_Status statuses[4];
        int next_rank = (rank + 1) % size;
        int prev_rank = (rank - 1 + size) % size;
        
        // Allocate buffers for communication
        int received_fitness;
        char *received_plate = (char *)malloc(plate_size * sizeof(char));
        
        // Post receives first to avoid deadlock
        MPI_Irecv(&received_fitness, 1, MPI_INT, prev_rank, 0, MPI_COMM_WORLD, &requests[0]);
        MPI_Irecv(received_plate, plate_size, MPI_CHAR, prev_rank, 1, MPI_COMM_WORLD, &requests[1]);
        
        // Then post sends
        MPI_Isend(&best_fitness, 1, MPI_INT, next_rank, 0, MPI_COMM_WORLD, &requests[2]);
        MPI_Isend(population[best], plate_size, MPI_CHAR, next_rank, 1, MPI_COMM_WORLD, &requests[3]);
        
        // Wait for all communication to complete
        MPI_Waitall(4, requests, statuses);
        
        // Process received data
        int worst = 0;
        for (int i = 1; i < npop; i++) {
            if (pop_fitness[i] > pop_fitness[worst]) {
                worst = i;
            }
        }
        
        // Replace worst individual if neighbor is better
        if (received_fitness < pop_fitness[worst]) {
            memcpy(population[worst], received_plate, plate_size);
            pop_fitness[worst] = received_fitness;
            
            // Update best/sbest if needed
            if (received_fitness < pop_fitness[best]) {
                sbest = best;
                best = worst;
            } else if (received_fitness < pop_fitness[sbest] && worst != best) {
                sbest = worst;
            }
        }
        
        free(received_plate);

        printf("Worker %d: Generation %d with best=%d fitness=%d\n", 
               rank, g, best, pop_fitness[best]);
        
        // Mutation and crossover
        int rate = (int)((double)pop_fitness[best]/(n*n) * 100);
        for(int i=0; i <npop; i++) {
            if (i == sbest) {
                cross(population[i], population[best], n);
            } else if (i != best) {
                if (i < npop/3) {
                    mutate(population[i], population[best], n, rate);
                } else if (i < (npop*2)/3) {
                    cross(population[i], population[best], n);
                } else {
                    makerandom(population[i], n);
                }
            }
        }
    }
    
    // Cleanup
    free(target_plate);
    free(buffer_plate);
    for(int i=0; i<npop; i++) {
        free(population[i]);
    }
    
    MPI_Finalize();
    return 0;
}
