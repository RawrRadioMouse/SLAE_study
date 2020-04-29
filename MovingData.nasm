;MovingData.nasm
; Author: SLAE_Student

global _start			

section .text
_start:

	; mov immediate data to register 

	mov eax, 0xaaaaaaaa
	mov al, 0xbb
	mov ah, 0xcc
	mov ax, 0xdddd

	mov ebx, 0
	mov ecx, 0

	; mov register to register 

	mov ebx, eax
	mov cl, al
	mov ch, ah
	mov cx, ax

	mov eax, 0
	mov ebx, 0
	mov ecx, 0

	; mov from memory into register 

	mov al, [sample]
	mov ah, [sample +1]
	mov bx, [sample]
	mov ecx, [sample]
	
	; mov from register into memory 


	mov eax, 0x33445566
	mov byte [sample], al	
	mov word [sample], ax
	mov dword [sample], eax

	; mov immediate value into memory 

	mov dword [sample], 0x33445566

	; lea demo

	lea eax, [sample]
	lea ebx, [eax] 


	; xchg demo 
	mov eax, 0x11223344
	mov ebx, 0xaabbccdd

	xchg eax, ebx
 
	
	; exit the program gracefully  

	mov eax, 1
	mov ebx, 0		
	int 0x80


section .data

sample:	db 0xaa, 0xbb, 0xcc, 0xdd, 0xee, 0xff, 0x11, 0x22



;MOV can move data:
;	- Between Registers
;	- Memory to register and Register to Memory
;	- Immediate Data to register
;	- Immediate Data to Memory
;
;XCHG can exchange data:
;	- Register,Register
;	- Register,Memory
;	
;LEA can load effective address load pointer address
;	- EXAMPLE: LEA EAX, [label] - Will load the pointer inside EAX, (the exact mem location where label is defined)
;
;**BONUS NOTE**
;The primary difference between register and memory is that register holds the data that the CPU is currently processing whereas,
;the memory holds the data the that will be required for processing
;source: https://www.quora.com/What-is-the-difference-between-register-and-memory
;Immediate Data can be used literally in an instruction to change the contents of a register or memory location.
;
;					LABEL
;	Identifier for where instruction is located
;				INSTRUCTION
;			The instruction itself
;					OPERAND
;		Arguments to the instruction (registers, memory locations, immediate values (not a reference)
;
;in IA32
;Data types
;byte - 8 bits
;word - 16 bits
;double word - 32 bits
;quad word - 64 bits
;double quad word - 128 bits
;
;Signed vs unsigned
;
;unsigned double word
;the whole 32 bits are dedicated to storing the value
;
;signed double word
;first 31bits are dedicated, and the last (most significant bit) is used to store the sign which can be pos or neg
;
;defining initialised data
;db = definedbyte
;dw = definedword
;
;dw = 'a' ; 0x61 0x00
;
;declare UNinitialised (used for the bss segment)
;
;buffer: resb 64 ;reserve 64 bytes
;wordvar: resw 1 ;reserver 1 word
