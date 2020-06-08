#!/usr/bin/python

# ctypes is a library for wrapping native programs in python code
# in this case lets import enough of libc to load our shellcode as an argument

from ctypes import CDLL, c_char_p, c_void_p, memmove, cast, CFUNCTYPE
from sys import argv


libc = CDLL('libc.so.6') # load glibc 

# strip out the x's from the shellcode, if any, decode as hex
shellcode = argv[1].replace('\\x', '').decode('hex')

# create a char pointer to our shellcode
sc = c_char_p(shellcode)

# need to know the length
size = len(shellcode)

# allocate memory as a void pointer and store the address
addr = c_void_p(libc.valloc(size))

# copy our shellcode into memory 
memmove(addr, sc, size)

# allow this memory address executable
libc.mprotect(addr, size, 0x7)

# cast the address of main to a function we can execute
run = cast(addr, CFUNCTYPE(c_void_p))

# run forest...
run()
