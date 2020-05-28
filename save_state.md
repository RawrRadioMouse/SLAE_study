
global _start			

section .text

HelloWorldProc:

	push ebp
	mov ebp, esp

	; Print hello world using write syscall
	

	mov eax, 0x4
	mov ebx, 0x1
	mov ecx, message
	mov edx, mlen
	int 0x80

	; mov esp, ebp
	; pop ebp

	leave
	ret   ; signifies end of procedure 


_start:

	mov ecx, 0x10 ; #### start here, we specify how many loops

PrintHelloWorld:

; **preserve registers and flags (make way for process variables, but obviously we want to pic up where we left off once the proc is finished right?)**

; **we push all the current values for safe keeping**

	pushad
; **same with flag states**

	pushfd

; **our process runs and finishes, signified by RET which points to the next instruction, where we restore what we put away for safe keeping**

	call HelloWorldProc 

; **restore registers and stack**

; **put the flags back so we can continue**

	popfd 
	
; **put the values back so we can continue, this is proven by the fact that even after all the trickery in the process, the LOOP instruction below can still pick up the ECX value and decrement.**

	popad 

; **loop takes one out of ECX to keep track of loop, and we push, call, and pop over and over until ECX becomes ZERO**

	loop PrintHelloWorld 



	mov eax, 1
	mov ebx, 10		; sys_exit syscall
	int 0x80

section .data

	message: db "Hello World!"
	mlen     equ $-message

