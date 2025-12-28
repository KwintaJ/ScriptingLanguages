import numpy as np
import cython

@cython.boundscheck(False)
@cython.wraparound(False)
def mult(int[:, :] A, int[:, :] B):
    cdef int rows_A = A.shape[0]
    cdef int cols_A = A.shape[1]
    cdef int rows_B = B.shape[0]
    cdef int cols_B = B.shape[1]
    
    cdef int[:, :] C = np.zeros((rows_A, cols_B), dtype=np.int32)

    cdef int i, j, k
    cdef int temp_sum

    for i in range(rows_A):
        for j in range(cols_B):
            temp_sum = 0
            for k in range(cols_A):
                temp_sum += A[i, k] * B[k, j]
            C[i, j] = temp_sum

    return np.asarray(C)