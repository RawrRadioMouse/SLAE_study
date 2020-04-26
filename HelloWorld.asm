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
;this will execute the current instruction and step to the next one, check  info regsisters/i r and you will see that the original pending
;operation has completed in hello world as the value "4" has been moved into eax 
;(the register for holding operands from calls, thus telling it we use syscall "4" (write))
;
;So, We can check what is next with disassemble, then stepi, and info regsisters/i r again to see it has completed
;the instruction EG if the instruction was
;"mov    ecx,0x80490a4" (in our program this was defined as mov ecx, message, when it runs in assembly it looks
;at the memory address where our "message" variable is stored,when disassembling, we can confirm conents of message with x/s <memaddress>),
;then we should see that memory address in ecx (a pointer for data)
;
;after continuing this we eventually reach our interrupt instruction, the next time we stepi we will get our ptinter output
;bonus knowledge - an interrupt instruction is called as such as it "interrupts" the program flow and goes and does something real quick 
;"You can think of it as like signaling Batman. You need something done, you send the signal, and then he comes to the rescue"
;(gdb) i r
;eax            0x4	4
;ecx            0x80490a4	134516900
;edx            0xc	12
;ebx            0x1	1
;esp            0xbffff3d0	0xbffff3d0
;ebp            0x0	0x0
;esi            0x0	0
;edi            0x0	0
;eip            0x8048094	0x8048094 <_start+20>
;eflags         0x202	[ IF ]
;cs             0x73	115
;ss             0x7b	123
;ds             0x7b	123
;es             0x7b	123
;fs             0x0	0
;gs             0x0	0
;(gdb) disassemble 
;Dump of assembler code for function _start:
;   0x08048080 <+0>:	mov    eax,0x4
;   0x08048085 <+5>:	mov    ebx,0x1
;   0x0804808a <+10>:	mov    ecx,0x80490a4
;   0x0804808f <+15>:	mov    edx,0xc
;=> 0x08048094 <+20>:	int    0x80
;   0x08048096 <+22>:	mov    eax,0x1
v   0x0804809b <+27>:	mov    ebx,0x5
v   0x080480a0 <+32>:	int    0x80
;End of assembler dump.
;(gdb) 
;(gdb) stepi
;Hello World!0x08048096 in _start ()
;(gdb) 








