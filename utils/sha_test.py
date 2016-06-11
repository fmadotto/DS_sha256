#!/usr/bin/python

# Copyright (c) 2016 Federico Madotto and Coline Doebelin
# federico.madotto (at) gmail.com
# coline.doebelin (at) gmail.com
# https://github.com/fmadotto/DS_sha256

# sha_test.py is part of DS_sha256.

# DS_sha256 is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# DS_sha256 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.


import sys

# Initialise hash values
h0 = 0x6a09e667L
h1 = 0xbb67ae85L
h2 = 0x3c6ef372L
h3 = 0xa54ff53aL
h4 = 0x510e527fL
h5 = 0x9b05688cL
h6 = 0x1f83d9abL
h7 = 0x5be0cd19L


# Initialise array of round constants:

k = (
      0x428a2f98L, 0x71374491L, 0xb5c0fbcfL, 0xe9b5dba5L, 0x3956c25bL, 0x59f111f1L, 0x923f82a4L, 0xab1c5ed5L,
      0xd807aa98L, 0x12835b01L, 0x243185beL, 0x550c7dc3L, 0x72be5d74L, 0x80deb1feL, 0x9bdc06a7L, 0xc19bf174L,
      0xe49b69c1L, 0xefbe4786L, 0x0fc19dc6L, 0x240ca1ccL, 0x2de92c6fL, 0x4a7484aaL, 0x5cb0a9dcL, 0x76f988daL,
      0x983e5152L, 0xa831c66dL, 0xb00327c8L, 0xbf597fc7L, 0xc6e00bf3L, 0xd5a79147L, 0x06ca6351L, 0x14292967L,
      0x27b70a85L, 0x2e1b2138L, 0x4d2c6dfcL, 0x53380d13L, 0x650a7354L, 0x766a0abbL, 0x81c2c92eL, 0x92722c85L,
      0xa2bfe8a1L, 0xa81a664bL, 0xc24b8b70L, 0xc76c51a3L, 0xd192e819L, 0xd6990624L, 0xf40e3585L, 0x106aa070L,
      0x19a4c116L, 0x1e376c08L, 0x2748774cL, 0x34b0bcb5L, 0x391c0cb3L, 0x4ed8aa4aL, 0x5b9cca4fL, 0x682e6ff3L,
      0x748f82eeL, 0x78a5636fL, 0x84c87814L, 0x8cc70208L, 0x90befffaL, 0xa4506cebL, 0xbef9a3f7L, 0xc67178f2L
    )


# padded message foobaraaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
M0=0x666f6f62L
M1=0x61726161L
M2=0x61616161L
M3=0x61616161L
M4=0x61616161L
M5=0x61616161L
M6=0x61616161L
M7=0x61616161L
M8=0x61616161L
M9=0x61616180L
M10=0x00000000L
M11=0x00000000L
M12=0x00000000L
M13=0x00000000L
M14=0x00000000L
M15=0x00000138L



# M0=0x666f6f62L
# M1=0x61726161L
# M2=M3=M4=M5=M6=M7=M8=M9=M10=M11=M12=M13=M14=M15=0x61616161L


def prnt(x):
  print '0x%08x' % (x & 0xffffffff)


ror = lambda val, r_bits, max_bits: ((val & (2**max_bits-1)) >> r_bits%max_bits) | (val << (max_bits-(r_bits%max_bits)) & (2**max_bits-1))

def sigma0(x):
  return ror(x, 7, 32) ^ ror(x, 18, 32) ^ (x >> 3)

def sigma1(x):
  return ror(x, 17, 32) ^ ror(x, 19, 32) ^ (x >> 10)

def csigma0(x):
  return ror(x, 2, 32) ^ ror(x, 13, 32) ^ ror(x, 22, 32)

def csigma1(x):
  return ror(x, 6, 32) ^ ror(x, 11, 32) ^ ror(x, 25, 32)

def Ch(x, y, z):
  return (x & y) ^ (~x & z)

def Maj(x, y, z):
  return (x & y) ^ (x & z) ^ (y & z)

def csa(x, y, z):
  return (x ^ y ^ z, (x & y) | (x & z) | (y & z))

def cla(x, y):
  return (x + y) % (1 << 32)

# Initialise working variables to current hash value:
a = h0
b = h1
c = h2
d = h3
e = h4
f = h5
g = h6
h = h7

# Expander
w = [M0, M1, M2, M3, M4, M5, M6, M7, M8, M9, M10, M11, M12, M13, M14, M15]

for j in range(16, 64):
  w.append(cla(cla(cla(sigma1(w[j-2]), w[j-7]), sigma0(w[j-15])), w[j-16]))

# Compression function main loop:

for j in range(0, 64):
  print "--------------------------------"
  print "Beginning of round " + str(j)
  print "--------------------------------"
  
  sys.stdout.write('a = ')
  prnt(a)
  print ""

  sys.stdout.write('b = ')
  prnt(b)
  print ""

  sys.stdout.write('c = ')
  prnt(c)
  print ""

  sys.stdout.write('d = ')
  prnt(d)
  print ""

  sys.stdout.write('e = ')
  prnt(e)
  print ""

  sys.stdout.write('f = ')
  prnt(f)
  print ""

  sys.stdout.write('g = ')
  prnt(g)
  print ""

  sys.stdout.write('h = ')
  prnt(h)
  print ""


  sys.stdout.write('Wj = ')
  prnt(w[j])
  print ""

  sys.stdout.write('Kj = ')
  prnt(k[j])
  print ""

  T1 = cla(cla(cla(cla(h, csigma1(e)), Ch(e, f, g)), k[j]), w[j])
  T2 = cla(csigma0(a), Maj(a,b,c))
  h = g
  g = f
  f = e
  e = cla(d, T1)
  d = c
  c = b
  b = a
  a = cla(T1, T2)

# Add the compressed chunk to the current hash value:
new_h0 = cla(h0, a)
new_h1 = cla(h1, b)
new_h2 = cla(h2, c)
new_h3 = cla(h3, d)
new_h4 = cla(h4, e)
new_h5 = cla(h5, f)
new_h6 = cla(h6, g)
new_h7 = cla(h7, h)


print ""
print "--------------------------------"
print "Final result"
print "--------------------------------"

sys.stdout.write('new_h0 = ')
prnt(new_h0)
print ""

sys.stdout.write('new_h1 = ')
prnt(new_h1)
print ""

sys.stdout.write('new_h2 = ')
prnt(new_h2)
print ""

sys.stdout.write('new_h3 = ')
prnt(new_h3)
print ""

sys.stdout.write('new_h4 = ')
prnt(new_h4)
print ""

sys.stdout.write('new_h5 = ')
prnt(new_h5)
print ""

sys.stdout.write('new_h6 = ')
prnt(new_h6)
print ""

sys.stdout.write('new_h7 = ')
prnt(new_h7)
print ""  
