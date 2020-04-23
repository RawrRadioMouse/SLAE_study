;HelloWorld.asm
;Author: SLAE_Student

global _start

section .text

_start:
	; all we are doing here is moving the hex values into registers
	; each proceeding register is an arg to EAX - write systemcall
	mov eax, 0x4     ;move 4 (write) into eax
	mov ebx, 0x1     ;define FD as STDOUT
	mov ecx, message ;move our string into ECX
	mov edx, mlen	 ;move string length into edx register
	int 0x80

	; exit gracefully

	mov eax, 0x1 ;value for "exit" systemcall
	mov ebx, 0x5
	int 0x80


section .data

	message: db "Hello World!"
	mlen	equ   $-message
  
  ; compile with nasm -f elf32 -o HelloWorld.o HelloWorld.asm
  ; create linker ld -o HelloWorld HelloWorld.o
