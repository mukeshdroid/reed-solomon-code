import time
import random
import math


def euler_totitent(n):
    """ computes the euler totitent function for an integer n which is the number of numbers 
    less than n which are coprime to n.
    """

    if (not isinstance(n, int) and n > 0):
        raise TypeError(
            "Please ensure that the parameter is a positive integer")

    co_primes = [i for i in range(1, n) if math.gcd(n, i) == 1]
    return len(co_primes)


# returns order of a in prime group of order n
def order(n, a):
    if math.gcd(a, n) != 1:
        raise ValueError('The numbers must be coprime')
    for i in range(1, euler_totitent(n) + 1):
        if pow(a, i, n) == 1:
            return i


def primitive_root(n):
    """generate smallest primitive root of n

    Args:
        n (int): integer
    """
    phi_n = euler_totitent(n)
    for i in range(2, n):
        if math.gcd(i, n) == 1 and order(n, i) == phi_n:
            return i
    raise ValueError("The number {} has no primitive roots".format(n))


def modulo_inv(a, m, method='FLT'):
    '''input : two integer values a and m
    default method utilzed fermat little theorem. Other available methods are extended eucledian and naive.
    returns a integer x such that ax = 1 (mod m)

    If values are not int or gcd(a,m) is not 1 then raises error. The function is also undefined if 
    a = 0 or m = 1.
    '''

    if (not isinstance(a, int) or not isinstance(m, int)):
        raise TypeError("Please ensure that the parameters are integers")

    if (m == 0 or a == 0):
        raise ValueError("Please ensure that m and a are not 0")

    if (a == 1):
        return 1

    if (not math.gcd(a, m) == 1):
        # print('Value :: {} and modulo :: {}'.format(a,m))
        raise ValueError(
            "Inverse doesnot exist as the numbers provided are not co-prime.")

    if (method == 'naive'):
        for i in range(1, m):
            if ((a * i) % m == 1):
                return i

    elif (method == 'euclidean'):
        x, _ = math.gcd(a, m)
        return x % m

    elif (method == 'FLT'):
        return (a**(euler_totitent(m) - 1) % m)

    else:
        raise ValueError("The method used is not recognized.")


def isPrime(n):
    """checks if n is prime by naive division

    Args:
        n (int): integer to be checked

    Raises:
        TypeError: input is not an positive integer

    Returns:
        bool: returns True if n is prime
    """
    if (not isinstance(n, int) or not (n > 0)):
        raise TypeError("Please ensure that the parameters are integers")

    if (n == 1):
        return False

    for i in range(2, int(math.sqrt(n)) + 1):
        if n % i == 0:
            return False
    return True


def nDigitPrimeGen(n):
    """generates and returns a prime with n digits
    Args:
        n (int) : number of digits in generated prime
    Returns:
        int: prime number of n digits
    """
    while True:
        li = [str(random.randint(1, 9))]
        for i in range(n - 2):
            li.append(str(random.randint(0, 9)))
        li.append(str(random.choice([1, 3, 7, 9])))
        number_st = ''.join(li)
        if isPrime(int(number_st)):
            return int(number_st)


def charEncodingLen(n):
    """number of digits needed to encode the given number of char

    Args:
        n (int): number of char to be encoded

    Returns:
        _float_: length of string encoded by given number
    """
    return int(n * 8 * 0.30102999566)


def intEncodingLen(n):
    """length of string encoded by the number with n digits

    Args:
        n (_int_): number of digits in the number

    Returns:
        _int_ : length of string encoded by number with n digits
    """
    return n // (8 * 0.30102999566)


def string2Blocks(string, blocklen):
    """tokenize a string into blocks of equal size

    Args:
        string (_type_): string to be tokenize
        blocklen (_type_): length of block

    Returns:
        list: list of tokens of the string of equal length
    """
    return [string[i:i+blocklen] for i in range(0, len(string), blocklen)]


l2n = {}
for i, letter in enumerate(' ABCDEFGHIJKLMNOPQRSTUVWXYZ'):
    number = i
    l2n[letter] = number

n2l = {}
for i, letter in enumerate(' ABCDEFGHIJKLMNOPQRSTUVWXYZ'):
    number = i
    n2l[number] = letter



def string2num(string, encoding='base26'):
    """encodes a string into a number

    Args:
        string (str): string to be converted

    Returns:
        int: number representing the string
    """

    if encoding == 'base26':
        num = 0
        for char in string:
            num = (num + l2n[char]) * 27
        return num // 27

    else:
        mybytes = string.encode('ISO-8859-1')
        myint = int.from_bytes(mybytes, 'big')
        return myint


def num2string(num, encoding='base26'):
    """decodes the string from the number

    Args:
        num (int): number encoding the string

    Returns:
        str: string decoded from the integer.
    """
    if encoding == 'base26':
        li = []
        while num > 0:
            x = num % 27
            num = num // 27
            li.insert(0, n2l[x])
        return ''.join(li)

    else:
        recoveredbytes = num.to_bytes((num.bit_length() + 7) // 8, 'big')
        recoveredstring = recoveredbytes.decode('ISO-8859-1')
        return recoveredstring


# n = 14930
# print((n.bit_length() + 7) // 8)
# print(n.to_bytes(2,"bi"))
# print(num2string(570892))
# print(string2num('AB CD'))
