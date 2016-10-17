class SampleLCG:
    state = 0
    p = 2 ** 31
    addend = 2531011
    mult = 214013

    def __init__(self, seed):
        self.state = seed

    def next_rand(self):
        self.state = ((self.mult * self.state) + self.addend) % self.p
        return self.state

def recover_sample_lcg_modulus(samples):
    import random
    seed = random.randint(2, 2**31)
    print("using random seed %d" % seed)
    lcg = SampleLCG(seed)
    nums = []
    for x in range(samples):
        nums.append(lcg.next_rand())
    print(recover_modulus(nums))

def recover_sample_state():
    import random
    seed = random.randint(2, 2**31)
    print("using random seed %d" % seed)
    lcg = SampleLCG(seed)
    x = lcg.next_rand()
    y = lcg.next_rand()
    z = lcg.next_rand()
    print(recover_lcg_state(x, y, z, 2**31))


def recover_lcg_state(r1, r2, r3, modulus):
    """ Given 3 sequential outputs and a modulus from a LCG: recover the other
    uknowns. Specifically, this will recover the "seed", the multiplier, and
    the increment value. The "seed" is not necessarily, the number used to
    initialize the RNG, but the unknown state value used to create the first
    random number.

    Args:
      r1, r2, r3  (int): Three sequential pseudo-random integers output from an
      LCG PRNG.  
      m (int): The modulus used in the LCG PRNG.

    Returns:
      dict(str,int):  A dictionary containing the increment, multiple, and seed
      value with respective keys ("inc", "mult", "seed").
    """
    var('inc,mult,seed')
    eqns = [r1 == seed*mult + inc, r2 == r1*mult + inc, r3 == r2*mult + inc]
    return solve_mod(eqns=eqns, modulus=modulus, solution_dict=True)


def u(n, n1, n2, n3):
    """ A helper function that takes 4 sequential numbers 
    output from an LCG and returns a number that is a multiple
    of the (possibly unknown) modulus used in the LCG

    Args:
       n, n1, n2, n3 (int): Four sequential psuedo-random integers output from an LCG PRNG.

    Returns:
       int: A value that is a random multiple of the modulus.
    """
    tn,tn1,tn2 = (n1-n, n2-n1, n3-n2)
    tul = tn2 * tn
    tur = tn1 ** 2
    return abs(tul - tur)


def recover_modulus(nums):
    """ A probabilistic function used to recover an unknown modulus of a LCG PRNG.
    The chance of success is dependent on the number of input integers provided.
    This function only works when at least 8 integers are provided. This algorithm 
    is described in this StackOverflow post: 
    http://security.stackexchange.com/questions/4268/cracking-a-linear-congruential-generator

    Args:
       nums (int[]): A list of sequentials integers output from a LCG PRNG.

    Returns:
       int: A value that is likely the PRNG's modulus.
    """

    lnums = len(nums)
    if (lnums < 8):
        return 1

    if (lnums % 4 != 0):
	rem = lnums % 4
	lnums = lnums - rem

    us = [ u(nums[i+0], nums[i+1], nums[i+2], nums[i+3]) for i in range(0, lnums, 4) ]

    return gcd(us)
