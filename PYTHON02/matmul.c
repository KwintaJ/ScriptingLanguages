// Jan Kwinta
//
// 28.12.2025
//
// Problem PYTHON02
// matmul.c

#include <stdio.h>

void mult(const int *A, const int *B, int *C, int n, int m, int p) {
    for (int i = 0; i < n; i++) {
        for (int j = 0; j < p; j++) {
            int sum = 0;
            for (int k = 0; k < m; k++) {
                sum += A[i * m + k] * B[k * p + j];
            }
            C[i * p + j] = sum;
        }
    }
}