;HelloWorld.asm
;Author: SLAE_Student

global _start

section .text

_start:
	; all we are doing here is moving the hex values into registers
	; each proceeding register is an arg to EAX - write systemcall
	mov eax, 0x4     ;move 4 (write) into eax
	mov ebx, 0x1     ;define FD as STDOUT
	mov ecx, message ;move our string into ECX (when disassembling, we can confirm conents of message with x/s <memaddress>
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
  
  
;when analysing in gdb, if we break at _start and then dissamble we can see all the register moves as below:
;(gdb) disassemble 
;Dump of assembler code for function _start:
;=> 0x08048080 <+0>:	mov    eax,0x4
;   0x08048085 <+5>:	mov    ebx,0x1
;   0x0804808a <+10>:	mov    ecx,0x80490a4
;   0x0804808f <+15>:	mov    edx,0xc
;   0x08048094 <+20>:	int    0x80
;   0x08048096 <+22>:	mov    eax,0x1
;   0x0804809b <+27>:	mov    ebx,0x5
;   0x080480a0 <+32>:	int    0x80
;
;we can step through each register with stepi
;
;this will execute the current instruction and step to the next one, you will see that the original pending
;operation has completed in hello world as the value "4" has been moved into eax 
;(the register for holding operands from calls, thus telling it we use syscall "4" (write))
;
;So, We can check what is next with disassemble, then stepi, and info regsisters/i r again to see it has completed
;the instruction EG if the instruction was
;"mov    ecx,0x80490a4" (in our program this was defined as mov ecx, message, when it runs in assembly it looks
;at the memory address where our "message" variable is stored,when disassembling, we can confirm conents of message with x/s <memaddress>),
; then we should see that memory address








