# Jan Kwinta
#
# 21.12.2025
#
# Problem PYTHON01

import sys
import time
import random
import string
import multiprocessing
import threading

##########################################################
# wartosci stale - konfiguracja
NUM_RECORDS = 150000
NUM_WORKERS = 6

##########################################################
# tworzenie slownika
def generate_data(n):
    data = []
    for i in range(n):
        # generacja losowego tekstu
        random_text = ' '.join(''.join(random.choices(string.ascii_lowercase, k=random.randint(3, 7))) for _ in range(random.randint(2, 100)))
        data.append({"id": i, "text": random_text})
    return data

##########################################################
# liczenie score
def process_record(record):
    text = record["text"].lower()
    words = text.split()
    unique_letters = len(set(c for c in text if c.isalpha()))
    score = text.count('a') + text.count('e') + text.count('i') + text.count('o') + text.count('u') + text.count('y')
    return record["id"], { "word_count": len(words), "unique": unique_letters, "score": score }

##########################################################
# weryfikacja rezultatow
def verify_results(base_results, test_results):
    if len(base_results) != len(test_results):
        return -1

    for i in range(NUM_RECORDS):
        if i not in test_results:
            return -2
        
        if base_results[i]["word_count"] != test_results[i]["word_count"]:
            return -3

        if base_results[i]["unique"] != test_results[i]["unique"]:
            return -4

        if base_results[i]["score"] != test_results[i]["score"]:
            return -5

    return 1

##########################################################
###### SEKWENCYJNIE ######
def run_sequential(data):
    results = {}
    start = time.time()
    for record in data:
        rid, res = process_record(record)
        results[rid] = res
    end = time.time()
    return results, end - start

##########################################################
###### MULTIPROCESSING ######
def chunk_worker(chunk):
    # kazdy proces ma swoj wlasny lokalny slownik local_results
    local_results = {}
    for record in chunk:
        rid, res = process_record(record)
        local_results[rid] = res
    return local_results

def run_multiprocessing(data):
    results = {}
    start = time.time()
    chunk_size = len(data) // NUM_WORKERS
    chunks = [data[i:i + chunk_size] for i in range(0, len(data), chunk_size)]
    
    with multiprocessing.Pool(processes=NUM_WORKERS) as pool:
        partial_results = pool.map(chunk_worker, chunks)
        
    # laczenie slownikow
    for partial in partial_results:
        results.update(partial)
        
    end = time.time()
    return results, end - start

##########################################################
###### MULTITHREADING ######
# Unsafe
def run_threading_unsafe(data):
    shared_data_list = list(data) 
    results = {}
    threads = []
    num_threads = NUM_WORKERS

    def worker():
        while True:
            try:
                record = shared_data_list.pop()
            except IndexError:
                # lista jest pusta - koniec
                break
            
            rid, res = process_record(record)
            results[rid] = res

    start = time.time()
    for _ in range(num_threads):
        t = threading.Thread(target=worker)
        threads.append(t)
        t.start()

    for t in threads:
        t.join()
        
    end = time.time()
    return results, end - start

# Thread-lock
def run_threading_safe(data):
    shared_data_list = list(data) 
    results = {}
    threads = []
    lock = threading.Lock()
    num_threads = NUM_WORKERS

    def worker():
        while True:
            with lock:
                try:
                    record = shared_data_list.pop()
                except IndexError:
                    # lista jest pusta - koniec
                    break
            rid, res = process_record(record)
            with lock:
                results[rid] = res

    start = time.time()
    for _ in range(num_threads):
        t = threading.Thread(target=worker)
        threads.append(t)
        t.start()

    for t in threads:
        t.join()
        
    end = time.time()
    return results, end - start


##########################################################
##########################################################
###### MAIN ######
if __name__ == "__main__":

    print(f"GIL = {sys._is_gil_enabled()}")

    data = generate_data(NUM_RECORDS)

    ### Sekwencyjnie
    results_0, time_0 = run_sequential(data)
    print(f"Sekwencyjnie: {time_0:.4f}s")
    
    ### Multiprocessing
    results_1, time_1 = run_multiprocessing(data)
    is_correct_1 = verify_results(results_0, results_1) == 1
    print(f"Multiprocessing: {time_1:.4f}s | Czy poprawny: {is_correct_1}")
        
    ### Threading
    results_2, time_2 = run_threading_unsafe(data)
    is_correct_2 = verify_results(results_0, results_2) == 1
    print(f"Threading (bez zabezpieczen): {time_2:.4f}s | Czy poprawny: {is_correct_2}")
        
    ### Threading z synchronizacja
    results_3, time_3 = run_threading_safe(data)
    is_correct_3 = verify_results(results_0, results_3) == 1
    print(f"Threading (z synchronizacja): {time_3:.4f}s | Czy poprawny: {is_correct_3}")
