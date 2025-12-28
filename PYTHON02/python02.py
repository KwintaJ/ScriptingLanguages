# Jan Kwinta
#
# 28.12.2025
#
# Problem PYTHON02

import sys
import time
import random
import numpy as np
import matmul_cy

##########################################################
# zaladowanie biblioteki z C
import ctypes
matmul_c = ctypes.CDLL("./matmul.so")
matmul_c.mult.argtypes = [
    ctypes.POINTER(ctypes.c_int), # A
    ctypes.POINTER(ctypes.c_int), # B
    ctypes.POINTER(ctypes.c_int), # C
    ctypes.c_int,                 # rowsA
    ctypes.c_int,                 # colsA
    ctypes.c_int                  # colsB
]
matmul_c.mult.restype = None

##########################################################
# generowanie losowych macierzy
def generate_matrix(rows, cols):
    mx = []

    for i in range(rows):
        new_row = []
        for j in range(cols):
            new_element = random.randint(-200, 200)
            new_row.append(new_element)
        mx.append(new_row)

    return mx

##########################################################
###### PYTHON BRUTE FORCE ######
def mult_python(mxA, mxB):
    rows_A = len(mxA)
    cols_A = len(mxA[0])
    rows_B = len(mxB)
    cols_B = len(mxB[0])

    mxC = []

    start = time.time()

    for i in range(rows_A):
        new_row = []
        for j in range(cols_B):
            new_element = 0
            for k in range(cols_A):
                new_element += mxA[i][k] * mxB[k][j]
            new_row.append(new_element)
        mxC.append(new_row)

    end = time.time()
    return mxC, end - start

##########################################################
###### NUMPY ######
def mult_numpy(mxA, mxB):
    A_np = np.array(mxA)
    B_np = np.array(mxB)

    start = time.time()
    C_np = A_np @ B_np
    end = time.time()

    mxC = C_np.tolist()
    return mxC, end - start

##########################################################
###### CYTHON ######
def mult_cython(mxA, mxB):
    A_arr = np.array(mxA, dtype=np.int32)
    B_arr = np.array(mxB, dtype=np.int32)
    
    start = time.time()
    C_arr = matmul_cy.mult(A_arr, B_arr)
    end = time.time()

    mxC = C_arr.tolist()
    return mxC, end - start

##########################################################
###### EXTERNAL C ######
def mult_c(mxA, mxB):
    rowsA = len(mxA)
    colsA = len(mxA[0])
    rowsB = len(mxB)
    colsB = len(mxB[0])

    # splaszczenie tablic
    flatA = [item for row in mxA for item in row]
    flatB = [item for row in mxB for item in row]

    A_c = (ctypes.c_int * len(flatA))(*flatA)
    B_c = (ctypes.c_int * len(flatB))(*flatB)
    C_c = (ctypes.c_int * (rowsA * colsB))()

    start = time.time()
    matmul_c.mult(A_c, B_c, C_c, rowsA, colsA, colsB)
    end = time.time()

    res_flat = list(C_c)
    mxC = [res_flat[i * colsB : (i + 1) * colsB] for i in range(rowsA)]
    return mxC, end - start

##########################################################
##########################################################
###### MAIN ######

A = generate_matrix(200, 3000)
B = generate_matrix(3000, 500)

### Python
result_0, time_0 = mult_python(A, B)
print(f"Python: {time_0:.4f}s")

### Numpy
result_1, time_1 = mult_numpy(A, B)
is_correct_1 = result_0 == result_1
print(f"Numpy: {time_1:.4f}s | Correct: {is_correct_1}")

### Cython
result_2, time_2 = mult_cython(A, B)
is_correct_2 = result_0 == result_2
print(f"Cython: {time_2:.4f}s | Correct: {is_correct_2}")

### External C
result_3, time_3 = mult_c(A, B)
is_correct_3 = result_0 == result_3
print(f"External C: {time_3:.4f}s | Correct: {is_correct_3}")
