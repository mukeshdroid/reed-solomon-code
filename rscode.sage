#extended euclids algorithm
def extended_euclides(a,b,quo=lambda a,b:a//b):
    r0 = a; r1 = b
    s0 = 1; s1 = 0
    t0 = 0; t1 = 1

    while r1 != 0:
        q = quo(r0, r1)
        r0, r1 = r1, r0 - q * r1
        s0, s1 = s1, s0 - q * s1
        t0, t1 = t1, t0 - q * t1

    return r0, s0, t0

def toBinary(a):
    '''Converts a string to a string of binary values'''
    tmp = [str(int(bin(ord(i))[2:])) for i in a]
    b = ""
    for i in tmp:
        b = b + i
    return b

def tobincoeffs(a,n):
    '''break the binary string passed into blocks of n length padding with zero'''
    #compute the number of blocks
    nb = int(len(a) / n) + 1
    
    #padding length needed
    np= nb * n - len(a) 
    
    a = a + np * '0'
    
    li = [a[i:i+n] for i in range(0,len(a),n)]
    
    return li


def msgtorscoeff(msg):
    '''change a messge to order of coefficients that will form the RS polynomials'''
    binary = toBinary(msg)
    coeffs = tobincoeffs(binary,4)
    orders = [int(bString, 2) for bString in coeffs]
    return orders

def rscoefftomsg(coeff):
    '''Converts a list of coefficents to ascii. reverse of msgtorscoeff'''
    coeff = reversed(coeff)
    F.<b> = GF(2)[]
    S.<a> = GF( 2**4, modulus = b^4 + b^3 + 1)
    li = list(S)
    binstr = ''
    for i in coeff:
        indexi = li.index(i)
#         print(indexi)
        stri = '{0:04b}'.format(indexi)
#         print(stri)
        binstr = binstr + stri
#         print(binstr)
#     print(binstr)
    #remove padding
    nblocks = len(binstr) // 7
    binstr = binstr[:7 * nblocks]
    chrli = [binstr[i:i+7] for i in range(0,len(binstr),7)]
#     print(chrli)
    chrs = [chr(int(i,2)) for i in chrli]
    return chrs
    

class rs:
    
    def __init__(self):
        '''initialize a rs code with msg length 4'''
#         self.F.<b> = GF(2)[]
#         self.S.<a> = GF( 2**4, modulus = b^4 + b^3 + 1)
#         self.R.<x> = PolynomialRing(S,'x')
#         self.Syn.<z> = PolynomialRing(S,'z')
    
    def rs_encode(self,msg):
        F.<b> = GF(2)[]
        S.<a> = GF( 2**4, modulus = b^4 + b^3 + 1)
        R.<x> = PolynomialRing(S,'x')
        Syn.<z> = PolynomialRing(S,'z')
        g = R([-a,1]) * R([-a^2,1]) * R([-a^3,1]) * R([-a^4,1]) * R([-a^5,1]) * R([-a^6,1])
        # convert the message to polynomial
        coeff = msgtorscoeff(msg)
        b = R(list(reversed([a^i for i in coeff])))
        print("message : {}".format(b))
        # generate the codeword
        c = g * b
        print("codeword: {}".format(c))
        return c

    def rs_decode(self,codeword):
        F.<b> = GF(2)[]
        S.<a> = GF( 2**4, modulus = b^4 + b^3 + 1)
        R.<x> = PolynomialRing(S,'x')
        Syn.<z> = PolynomialRing(S,'z')
        g = R([-a,1]) * R([-a^2,1]) * R([-a^3,1]) * R([-a^4,1]) * R([-a^5,1]) * R([-a^6,1])
        r = R(codeword)
        print("r : {}".format(r))

        s1 = r(a)
        s2 = r(a^2)
        s3 = r(a^3)
        s4 = r(a^4)
        s5 = r(a^5)
        s6 = r(a^6)
        
        #if all syndromes are zero there are no errors
        if (s1 == 0) and (s2 == 0) and (s3 == 0) and (s4 == 0) and (s5 == 0) and (s6 == 0):
            return ''.join(rscoefftomsg((r // g).coefficients(sparse=False)))
        print("{}|{}|{}|{}|{}|{}".format(s1,s2,s3,s4,s5,s6))
        Synpoly = s1 + s2 * z + s3 * z^2 + s4 * z^3 + s5 * z^4 + s6 * z^5
        az = Syn([0,0,0,0,0,0,1])
        gcdz , uz, vz = extended_euclides(az,Synpoly)
        gcdz = gcdz
        uz = uz 
        vz = vz
        invroot_indices = []
        for i in range(1,16):
            if vz(a^i) == 0:
                invroot_indices.append(i)
        # these are the error positions
        root_indices = {}
        for i in invroot_indices:
            root_indices[i] = len(list(S)) -1 -i
        #get coefficients of the error position
        vzdif = vz.diff()
        error_coeff = {}
        for i in invroot_indices:
               error_coeff[root_indices[i]] = (gcdz(a^i) / vzdif(a^i))
        li = [0 for i in range(0,16)]
        for i in error_coeff:
            li[i] = error_coeff[i]
        error_poly = R(list(li))
        print("error_poly : {}".format(error_poly))
        print("decoded_codeword : {}".format(r - error_poly))
        return ''.join(rscoefftomsg(((r - error_poly) // g).coefficients(sparse=False)))