// Arrays (multidimensional), loops and nested loops

int array_size = 4;

void print_matrix (int matrix[array_size][array_size], int n) {
    int i = 0, j = 0;
 
    for (i= 0; i< n; i++) {                       // nested for loop
        for (j = 0; j < n; j++) {
            if (j == n) {
                printf("\n");
            }
            else{
                printf("%d", matrix[i][j]);
            }
        }
    }
    return;
}

