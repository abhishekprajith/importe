import timeit
import numpy as np
from numba import jit
from argparse import ArgumentParser

# Converted to global.
PRIME_COUNTS = { 10 : 1,                 # Historical data for validating our results - the number of primes
                100 : 25,                # to be found under some limit, such as 168 primes under 1000
                1000 : 168,
                10000 : 1229,
                100000 : 9592,
                1000000 : 78498,
                10000000 : 664579,
                100000000 : 5761455
                }

@jit("boolean[:](int32)", nopython=True)  # Numba decorator. If commented out, this function reverts to Python Numpy code with no jit compilation.
def runSieve(limit: int) -> np.ndarray:
    """Numba-optimized runSieve function.
    
    By passing the "@jit" decorator, the function is jit compiled. 
        Arguments to jit provide it with more information about our
        functions argument and return types.

    Arguments:
        limit (int): The limit up to where you want to search for primes.

    Returns:
        A boolean np.ndarray of length len(range(limit)) holding True for 
            indexes that have a prime, else False.
    """
    rawbits = np.repeat(True, (limit + 1) // 2)

    factor: int = 3
    q: float = np.sqrt(limit)

    while (factor < q):
        for num in range (factor, limit):
            # In-lining logic for getting a bit.
            if num % 2 == 0: # even numbers are automaticallty returned as non-prime
                bit = False
            else:
                bit = rawbits[num // 2]

            if bit:
                factor = num
                break

        # If marking factor 3, you wouldn't mark 6 (it's a mult of 2) so start with the 3rd instance of this factor's multiple.
        # We can then step by factor * 2 because every second one is going to be even by definition

        for num in range (factor * 3, limit, factor * 2):
            # In-lining logic for clearing a bit.
            rawbits[num // 2] = False # Assuming you're using optimized code. No need for "num % 2 == 0" check.

        factor += 2 # No need to check evens, so skip to next odd (factor = 3, 5, 7, 9...)
    return rawbits


def validateResults(sieveSize: int, myCount: int) -> bool:                      # Check to see if this is an upper_limit we can
    """Checks to see if our data matches known expected values (if they are registered in our cache).

    Arguments:
        sieveSize (int): This upper limit of values we were searching for primes in.
        myCount (int): This is our actual count of primes.

    Returns:
        A boolean - True if our results are valid, else False
    """
    if sieveSize in PRIME_COUNTS:      # the data, and (b) our count matches. Since it will return
        return PRIME_COUNTS[sieveSize] == myCount # false for an unknown upper_limit, can't assume false == bad
    return False


def printResults(rawbits: np.ndarray, showResults: bool, duration: float, passes: int):
    """Prints results from runSieve.

    Arguments:
        rawbits (np.ndarray): This is the array of rawbits generated by runSieve.
        showResults (bool): This is a flag to show the list of primes (gets VERY long).
        duration (int): This is how many seconds the program ran for.
        passes (int): This is the number of iterations the program was able to accomplish in <duration> seoncds.
    """
    primes = np.nonzero(rawbits)[0]

    if showResults:
        print("2, " + ", ".join(primes.astype(str).tolist()))

    isValid = validateResults(rawbits.shape[0], primes.shape[0])
    print(
        f"Passes {passes}, Time: {duration}, Avg: {duration/passes}, Limit: {rawbits.shape[0]}, "
        f"Count: {primes.shape[0]}, Valid: {isValid}"
    )

  
# MAIN Entry
if __name__ == "__main__":
    # Adding a CLI interface. Defaults should allow us to run this script with 0 arguments.
    # e.g. python PrimePY_Numba.py -n 100 --show-results

    ap = ArgumentParser()
    ap.add_argument("-n", type=int, default=1000000, help="The sieve size")
    ap.add_argument("--show-results", action="store_true", help="Flag to display all detected primes (WARNING: Can be a lot of text)")
    args = ap.parse_args()

    tStart = timeit.default_timer()                         # Record our starting time
    passes = 0                                              # We're going to count how many passes we make in fixed window of time

    rawbits = None
    while (timeit.default_timer() - tStart < 10):           # Run until more than 10 seconds have elapsed
        # FIXME: Unnecessary to return rawbits every time.
        rawbits = runSieve(args.n)                         #  Calc the primes up to a million
        passes = passes + 1                                 #  Count this pass
    
    tD = timeit.default_timer() - tStart                    # After the "at least 10 seconds", get the actual elapsed
    assert rawbits is not None

    printResults(rawbits, args.show_results, tD, passes)                # Display outcome
