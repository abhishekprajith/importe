import math
from numba import njit
import timeit


@njit
def ClearBit(rawbits, index):

    if (index % 2 == 0):
        assert("If you're setting even bits, you're sub-optimal for some reason!")
        return False
    else:
        rawbits[int(index/2)] = False

@njit
def GetBit(rawbits, index):

    if (index % 2 == 0): # even numbers are automaticallty returned as non-prime
        return False
    else:
        return rawbits[int(index/2)]

@njit
def runSieve(sieveSize):
    rawbits = [True] * (int((sieveSize+1)/2))
    factor = 3
    q = math.sqrt(sieveSize)

    while (factor < q):
        for num in range (factor, sieveSize):
            if (GetBit(rawbits, num) == True):
                factor = num
                break

        # If marking factor 3, you wouldn't mark 6 (it's a mult of 2) so start with the 3rd instance of this factor's multiple.
        # We can then step by factor * 2 because every second one is going to be even by definition

        for num in range (factor * 3, sieveSize, factor * 2): 
            ClearBit(rawbits, num)

        factor += 2 # No need to check evens, so skip to next odd (factor = 3, 5, 7, 9...)
    
    output = [2]
    for x, y in enumerate(rawbits[1:]):
        if y:
            output.append(2*x + 3)

    return output


known_values = {
    10: 4, 
    100: 25, 
    1000: 168, 
    10000: 1229, 
    100000: 9592, 
    1000000: 78498, 
    10000000: 664579,
    100000000: 5761455,
    1000000000: 50847534,
}

def validate():
    for num, primes in known_values.items():
        start = timeit.default_timer()
        result = runSieve(num)
        end = timeit.default_timer()
        print(f"{num} took {end-start} seconds and returned {len(result)} primes, the true value is {primes} which is {len(result) == primes}")
        

def timethem():
    print("Start timing process")
    num_itters = 1_000_000
    primes = []
    tStart = timeit.default_timer()                         # Record our starting time
    passes = 0                                              # We're going to count how many passes we make in fixed window of time
    while (timeit.default_timer() - tStart < 10):           # Run until more than 10 seconds have elapsed
        primes = runSieve(num_itters)                       #  Find the results
        passes = passes + 1                                 #  Count this pass

    tend = timeit.default_timer()
    duration = tend-tStart

    print(f"Passes: {passes}, Time: {duration}, Avg: {duration/passes}, Limit: {num_itters}, Count: {passes}, Valid: {len(primes) == known_values.get(num_itters)}")
    # Passes: 1550, Time: 10.003551700000001, Avg: 0.006453904322580646, Limit: 1000000, Count: 1550, Valid: True


timethem()