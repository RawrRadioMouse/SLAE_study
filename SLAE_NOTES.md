## GENERAL CPU AND SYSTEM NOTES
lscpu cpu architecture
cat /proc/cpuinfo - what we are looking for is the flags, this lets us know the capability of the cpu (the instructions it supports)

CPU Notes

CPU IA-32 has 3 modes of operation

#### real modes

    - When powered up or reset
    - only has access to 1mb memory
    - no memory protection
    - no privilege levels (kernal vs user space)
    
#### protected modes - THE MAIN MODE WE WILL BE FOCUSING ON:

    - up to 4gb memory
    - access to memory protection, privilege level and multitasking
    - supports Virtual-8086 mode (to execute outdated software from previous generation)
    
#### system management mode
    - used for pwr mgmnt
    
#### memory model
    - Flat model
        - memory address is linear accross the address space, can access any memory directly
    - Segmented model
        - use a segment selector and an offset in that segment to figure out how to access specific locations (MORE READING: https://superuser.com/questions/318804/understanding-flat-memory-model-and-segmented-memory-model)
    - real-address mode model
        -

The kernel is a computer program at the core of a computer's operating system with 
complete control over everything in the system. 
It is the "portion of the operating system code that is always resident in memory". 
It facilitates interactions between hardware and software components.

## HOW DOES A SYSTEM CALL WORK:
Example:
User space program generates an interrupt at 0x80, once the interupt is generated the CPU
will check the interrupt handlers table, and then invoke the system call handler.
Now the system call handler is a kernel mode program, it will go and fogure out the system call routine
for the specific system call EG if the program now needs to print output or read from input these are seperate system calls.

Can also invoke system calls with SYSENTER instruction NOTE modern implementations use Virtual Dynamic Shared Object (REQUIRES HIGHER LEVEL KERNEL AND LOADER KNOWLEDGE)
For exploitation we almost exclusively use x80 (#define __NR_getgroups           80)

Where are systemcalls defined???
in /usr/include/i386-linux-gnu/asm/unistd_32.h

In our hello world program, to findout what to do in order to print Hello World we invoke man 2 write, which tells us which header to include and usage:

#### SYNOPSIS
```
       #include <unistd.h>
                 
       ssize_t write(int fd, const void *buf, size_t count);

{EAX=syscall nmb}^        ^{EBX=STDOUT}   ^{ECX=string} ^{EDX=length of string}
ssize_t write(int fd, const void *buf, size_t count);
```

EAX        System Call Number (for write, 4) Return Value always goes in

EBX        2nd Argument

ECX        3rd Argument

EDX        4th Argument

ESI        5th Argument

EDI        6th Argument


#### system bus 

    - links together memory, cpu and I/O devices

#### cpu 

    - broken up into control unit (responsible for retrieving and decoding instructions, storing data in memory)
    - execution unt, where actual execution of instructions occurs
        - stores temp data in registers in CPU
        - uses flags to notify programmer of events
        
## REGISTERS
    - [*]general purpose registers (32 bits wide)
        - EAX (access lower 16 bits using AX register, and then break down further into AH AL) |==EAX=={|=AH=|=AL=|}<-AX
            - Accumlator Register - used for storing operands and data from calls
        - EBX <AS ABOVE> |==EBX=={|=BH=|=BL=|}<-BX
            - base register - pointer to data
            - EXAMPLE OF BIT BREAKDOWN:
                gdb-peda$ i r ebx
                ebx            0xb7fa1ff4    0xb7fa1ff4 (32BITS)
                gdb-peda$ i r bx
                bx             0x1ff4    0x1ff4 (16BITS)
                gdb-peda$ i r bh
                bh             0x1f    0x1f (8BITS)
                gdb-peda$ i r bl
                bl             0xf4    0xf4 (8BITS)
        - ECX <AS ABOVE> |==ECX=={|=CH=|=CL=|}<-CX
        - EDX <AS ABOVE> ETC
            - data register - I/O pointer
        - ESP (can only access lower 16 bits using SP register) |==ESP==|==SP===|
            - stack pointer register <<SPECIFIC TO STACK MANIPULATION>>
        - EBP <AS ABOVE> ETC
            - stack data pointer register
        - ESI <AS ABOVE> ETC
            - data pointer registers for memory operations <<WILL BE USED FOR STRING MANIPULATION>>
        - EDI <AS ABOVE> ETC
            - data pointer registers for memory operations (same as ESI) <<WILL BE USED FOR STRING MANIPULATION>>
    - [*]segment registers  (when looking at the stack remember these via the S on the end)
            |------------------|
          CS|       Code       |               
            |------------------|   
          DS|       Data       |               
            |------------------|    
          SS|       Stack      |               
            |------------------|   
          ES|       Data       |               
            |------------------|    
          FS|       Data       |               
            |------------------|  
          GS|       Data       |               
            |------------------|     
    - [*]flags, EIP
        - If an instruction, gets set to a ZERO value, then the ZERO flag gets set
        - EIP; THE HOLY GRAIL for code execution, points to the next instruction to be executed
    - [*]floating point registers (AKA x87)
        - ST(0) to ST(7), teh registers are 80bits, and behave like a stack (REST TO BE COVERED LATER DURING ASSEMBLY PROGRAMMING)
    - [*]MMX registers
        - Is an "Instruction Extension"
                    - MMX
                    - SSE
                    - SSE2
                    - SSE3
        - Is carved out of the FPU register    (FPU is 80bits wide, and the FIRST lower 64bits is assigned to MMX)
              |------------------|
         ST(0)|       MM0        |               
              |------------------|   
         ST(1)|       MM1        |               
              |------------------|    
         ST(2)|       MM2        |               
              |------------------|   
         ST(3)|       MM3        |               
              |------------------|    
         ST(4)|       MM4        |               
              |------------------|  
         ST(5)|       MM5        |               
              |------------------|
         ST(6)|       MM6        |               
              |------------------|
         ST(7)|       MM7        |               
              |------------------|            
    - [*]XMM registers
        - Even bigger register (128bits) (REST TO BE COVERED LATER DURING ASSEMBLY PROGRAMMING)
    

## DEALING WITH DATA

_SQUARE BRACKETS MEANS A REFERENCE!!!_

in IA32
Data types
```
byte - 8 bits
word - 16 bits
double word - 32 bits (2 bytes)
quad word - 64 bits
double quad word - 128 bits
```
Signed vs unsigned

#### unsigned double word
the whole 32 bits are dedicated to storing the value

#### signed double word
first 31bits are dedicated, and the last (most significant bit) is used to store the sign which can be pos or neg

## defining initialised data
```
db = definedbyte
dw = definedword
```
dw = 'a' ; 0x61 0x00

declare UNinitialised (used for the bss segment)

buffer: resb 64 ;reserve 64 bytes
wordvar: resw 1 ;reserver 1 word

Special tokens {below are used to figure out the offset of the current instruction from somewhere else}
$ - evaluates to the current line
$$ - evaluates to the neginning of current section

## Little endian
Lower byte gets stored in lower memory

higher in high memory register

```
0A0B0C0D   mem
            0D  <=lower
            0C
            0B
            0A    <=higher
```            
    EXAMPLE (we examine the next bit in this address in ascending order):
            (gdb) x/xb 0x080490aa
            0x80490aa <var4>:    0xdd
            (gdb) x/xb 0x080490ab
            0x80490ab <var4+1>:    0xcc
            (gdb) x/xb 0x080490ac
            0x80490ac <var4+2>:    0xbb
            (gdb) x/xb 0x080490ad
            0x80490ad <var4+3>:    0xaa
            (gdb) 


Instruction

                    LABEL
    Identifier for where instruction is located
                INSTRUCTION
            The instruction itself
                    OPERAND
        Arguments to the instruction (registers, memory locations, immediate values (not a reference)
```        
gdb -nx <binary>
set-disassembly-flavor intel
break <break> OR if where you want to break is further down: break <*&break +X> (* is for break & is address)
        OR simply *0x<address>
run
disassemble $eip (this will disassemble eip in any case without that arg)
print/x $<register> OR display $eax   ;to look at register
```
* To step through registers after hitting break: stepi
* this will execute th current instruction and step to the next one, you will see that the original pending
operation has completed in hello world as the value "4" has been moved into eax (the register for holding operands from calls, thus telling it we use syscall "4" (write))

So, We can check what is next with disassemble, then stepi, and info regsisters/i r again to see it has completed the instruction EG if the instruction was
"mov    ecx,0x80490a4" (in our program this was defined as mov ecx, message, when it runs in assembly it looks at the memory address where our "message" variable is stored, 
when disassembling, we can confirm conents of message with x/s <memaddress>),
 then we should see that memory address

**BONUS NOTE**
The primary difference between register and memory is that register holds the data that the CPU is currently processing whereas,
the memory holds the data the that will be required for processing (IE when you are debugging after breaking and stepping through, you will obviously be seeing the registers)
source: https://www.quora.com/What-is-the-difference-between-register-and-memory
Immediate Data can be used literally in an instruction to change the contents of a register or memory location.

MOV can move data:
    - Between Registers
    - Memory to register and Register to Memory
    - Immediate Data to register
    - Immediate Data to Memory

XCHG can exchange data:
    - Register,Register
    - Register,Memory
    
LEA can load effective address load pointer address
    - EXAMPLE: LEA EAX, [label] - Will load the pointer inside EAX, (the exact mem location where label is defined)
    
to examine a register, use examine command x
    - eg info variables
    - /x <variable> OR /x &<variable> to also return the exact address
    
*When stepping through data, there are many additional pieces of output we would like to see, we do this with:
    - define hook-stop
    - > print/x $eax
    - > print/x $ebx
    - > print/x $ecx
    - > x/8xb &sample
    - > disassemble $eip,+10
    - > end
    
    Alternatively at the beginning of the program you can:
        - display/x $eax
        - display/x $ebx
        - display/x $ecx
    And then hook-stop contains only
        - disassemble $eip,+10
        
When interacting with variables (MOV, ADD etc), they will appear in the disassemble as the memory location, EG:
        0x804910c <var1>:    0x22
        Dump of assembler code from 0x80480a5 to 0x80480af:
        => 0x080480a5 <_start+37>:    add    BYTE PTR ds:0x804910c,0x11
        ***NOTE: When doing it this way, we are manipulating memory DIRECTLY, WITHOUT any medium such as registry***



## Stack


stack based exploits work via call and ret insts. when a function is called, the return address 
of the next inst is pushed to the stack, begining the stack frame. when the function has completed, 
the ret inst pops the return address from the stack and jumps EIP back there.

by overwriting the stored return address on the stack before the ret instruction, we can take control of a programs execution.

Can push 16 or 32bit values on the stack 
They can be in register or reference memory
```
b - byte
h - halfword (16-bit value)
w - word (32-bit value)
g - giant word (64-bit value)
```
#### why the heck do we run code waith a variable defined as a word, but we examine in GDB as a HALF????

SO gdb knows halfword as 16 bits
C language knows word as 16 bits
so you have to manually convert.
```
Windows/C:
BYTE - 8 bits, unsigned
WORD - 16 bits, unsigned
DWORD - 32 bits, unsigned
QWORD - 64 bits, unsigned
GDB:
Byte
Halfword (two bytes).
Word (four bytes).
Giant words (eight bytes).
```
Examine top of stack
this can also be used to address inline string data. if the string is placed directly after a call inst, the address of 
the string will be pushed to the stack as the return address. instead of calling a function, we can jump straight past 
the string to a pop inst that will take the address off the stack and into a register.
```
define hook-stop
>x/20x $sp
>x/8xb $esp (sample displayed as 8 consecutive bytes)
>x/4xh $esp (sample split into 4 halfword chunks)
>x/2xw $esp (sample split into 2 word chunks)
>disassemble $eip,+10
>end
```

after setting hook and stepping through first instruction (mov 66778899 into the eax register) we get below:
```
(gdb) stepi
0xbffff3b0:	0x01	0x00	0x00	0x00	0x28	0xf5	0xff	0xbf 
(((memory location pointed to by the top of the stack)))
0xbffff3b0:	0x0001	0x0000	0xf528	0xbfff
0xbffff3b0:	0x00000001	0xbffff528
Dump of assembler code from 0x8048085 to 0x804808f:
=> 0x08048085 <_start+5>:	mov    ebx,0x0
   0x0804808a <_start+10>:	mov    ecx,0x0
End of assembler dump.
0x08048085 in _start ()
3: /x $ecx = 0x0
2: /x $ebx = 0x0
1: /x $eax = 0x66778899
(gdb) 
```
When we reach push ax, we can see that the top of the stack now contains the contents of pseudoregister ax
```
Dump of assembler code from 0x804808f to 0x8048099:
=> 0x0804808f <_start+15>:	push   ax
   0x08048091 <_start+17>:	pop    bx
   0x08048093 <_start+19>:	push   eax
   0x08048094 <_start+20>:	pop    ecx
   0x08048095 <_start+21>:	push   WORD PTR ds:0x80490b0
End of assembler dump.
0x0804808f in _start ()
3: /x $ecx = 0x0
2: /x $ebx = 0x0
1: /x $eax = 0x66778899
(gdb) stepi
0xbffff3ae:	0x99	0x88	0x01	0x00	0x00	0x00	0x28	0xf5
0xbffff3ae:	0x8899	0x0001	0x0000	0xf528
0xbffff3ae:	0x00018899	0xf5280000
```

when displaying with bytes, value will be reversed, if display via word, it will display true to source

## Arithmetic

Arithmatic operations typically affect the status flags

There are 4 main arithmetic instructions we need to be aware of:
```
	ADD destination, source
	ADC destination, source (same as above but set carry flag)
	SUB and SBB (subtract and subtract borrow - which means subtract and then borrow one, dependant on carry flag being set)
	INC and DEC (Increment and decrement by 1)
```	
Do make this simple; mov REPLACES the value, and ADD "adds" to the value, eg:
```
		$eax = 0x00
		next inst = add al,0x22
		$eax = 0x22
		next inst = add al,0x11
		$eax = 0x33		
		next inst = mov ax,0x1122
		$eax = 0x1122
		next inst = add ax,0x3344
		$eax = 0x4466
		
		**same is true with starting eax value of 0x10000000
		next inst = add al,0x22
		$eax = 0x10000022
		next inst = add al,0x11
		$eax = 0x10000033		
		**ETC
```		
#### When multiplying
the first number is held in the relevent register, second number can be referenced in a memory location OR register.
relevent register you say? yes.
multiplying 8bit numbers, will use AL, 16 will use AX, and 32 will use EAX
AX and EAX results will be stored as such: Upper half in (E)DX, lower half in (E)AX
If the result is larger than the register, the OF (overflow) and CF (carry) flags will be set.
	
Implied registers
```
    mov al, 0x10
	mov bl, 0x2
	mul bl

$AL = 0xff (255)
$BL = 0x2
$AX = 0xff
```

mul bl (when you multiply it implies that the first value sits one register up, so it will look at AL in this case)

As AL already contains the highest possible value, we get an overflow and carry

```
$AL = 0xfe
$BL = 0x2
$AX = 0x1fe (510)

(gdb) print $eflags
$20 = [ CF SF IF OF ]
```

#### 32 bit multiplication Example:
```
Dump of assembler code from 0x80480c5 to 0x80480d4:
=> 0x080480c5 <_start+69>:	mul    ebx
   0x080480c7 <_start+71>:	mul    BYTE PTR ds:0x8049100
   0x080480cd <_start+77>:	mul    WORD PTR ds:0x8049101
End of assembler dump.
0x080480c5 in _start ()
4: $eflags = [ PF IF ]
3: /x $ebx = 0x55667788
2: /x $eax = 0x11223344
1: /x $edx = 0x0
(gdb) nexti
Dump of assembler code from 0x80480c7 to 0x80480d6:
=> 0x080480c7 <_start+71>:	mul    BYTE PTR ds:0x8049100
   0x080480cd <_start+77>:	mul    WORD PTR ds:0x8049101
   0x080480d4 <_start+84>:	mul    DWORD PTR ds:0x8049103
End of assembler dump.
0x080480c7 in _start ()
4: $eflags = [ CF IF OF ]
3: /x $ebx = 0x55667788
2: /x $eax = 0x117d820
1: /x $edx = 0x5b736a6
(gdb)
``` 
55667788 x 11223344 = 624,778,734,443,072 or 5b736a6117d820 in hex
first half of answer contained in edx and second half (overflow) in EAX.

#### division

For division:

    AX
    /
    r/m8
Quotant in AL
Remainder in AH

## Logical Operations

All BITWISE operations (they do not look at the values, they look at the BITS)
With BOOLEAN when matching up the two sets of bits, as soon as one pair hit AND or OR or XOR etc it will be flagged as true

AND
    Destination can be in R or M
    Source can be in R or M or an Immediate Value
    Cannot do AND between 2 memory locations
    (The AND operator is a Boolean operator used to perform a logical conjunction on two expressions -- Expression 1 And Experession 2. AND operator returns a value of TRUE if both its operands are TRUE, and FALSE otherwise.)
    EG
    so when you and bits like this
    0x0010
    0x0001
    --------
    0x0000

OR
    (The OR operator is a Boolean operator which would return the value TRUE or Boolean value of 1 if either or both of the operands are TRUE or have Boolean value of 1.)
    0x0001
    0x0100
    ---------
    0x0101

XOR

    (The XOR or the exclusive OR operator returns the Boolean value of 1 or TRUE if the number of the inputs having a value of 1 or TRUE is odd.)
    0x0101
    0x0110
    ---------
    0x0011

NOT

    (checks if a value is false EG a=0; if (!a) printf("this will print"))

var2	dw	0xbbcc
and word [var2], 0x1122

comes out as <var2>:	0x1100
bitmasking 
xoring == encoding
modify the logical program

```
Righto so... bitwise and between two hexadecimal values

step 1

convert each value to its binary representation... so

0xBBCC  = 1011 1011 1100 1100
0x1122   = 0001 0001 0010  0010
==========================
0x1100   = 0001 0001 0000  0000

step 2 do that :point_up:
step 3 convert back to hex
```

## control instructions

control instructions rely on flags

branching
    conditional
      Uses flags to determine if it will JMP
      EG JZ == jump if ZERO flag set
      can't be used with far Jump
    unconditional
      JMP
        near (current segment)
        far  (in another segment)


        small things in the stack, big in the heap

## procedures and preservation

WE PRESERVE states becuase in a complicated program we need to retain the state while different tasks are running
https://en.wikipedia.org/wiki/Function_prologue
https://stackoverflow.com/questions/1395591/what-is-exactly-the-base-pointer-and-stack-pointer-to-what-do-they-point 

set of operations grouped together
called from  different places of code
In NASM defined by labels
EGs
    CALL <procedure_name>

    <code>
    <code>
    <code>
    
    RET ; tells CPU to go back to the next instruction line
    
To preserve the registers and flags we push them all on and then pop them all off

    pushad
    pushfd
    Call program
    popfd
    popad

Preserve frame pointer

    push ebp ; marks start of functions stack frame
    mov ebp, esp ; we preserve where we were to enable us to return

restore

    move esp, ebp
    pop ebp

## String instructions

For MOVS and CMPS It is assumed that the source string is referenced by ESI and the destination is sourced by EDI ; they rely on direction flag DF (this being set means copying occurs high to low memory)

moving a string from on place to another
we move a byte, and then we use REP, which will repeat the byte move until there are none left at source address

To examine a string in ascii, 
    x/w $sp
    x/s <address>

#### Common string instructions

| Instruction | Description |
| :--- | :--- |
| MOVS\* | Move string data from `esi` to `edi` |
| CMPS\* | Compare string data from `esi` to `edi` |
| SCAS\* | Search for data defined in `al, ax or eax` in a string addressed in `edi` |
| STOS\* | Store string data from the accumulator into a string addressed by `edi` |
| LODS\* | Load memory addressed by `esi` into the accumulator |

#### Repeat prefixes

You can repeat string operations using a _repeat prefix_ - like the `loop*` instructions they use the `ecx` register as a counter. E.g.

```text
mov    esi, my_str
mov    edi, my_other_str
mov    ecx, 10
rep    movsb
```

## Libc in nasm

Remember that arguments get pushed on in reverse order

    CALL function(a,b,c,d)
    PUSH d, PUSH c, PUSH b, PUSH a,

To maintain a proper state for ESP: after libc call returns, adjust the stack accordingly

#### Very important to note:
> Use the extern instruction to define which functions you want to use from other libraries, at the top of your program
> In this instance, the calling convention is to place arguments on the stack in reverse order
> Don't mess up the stack pointer! After your function call returns, you will need to recall the location of the stack pointer; "you use some memory on the stack - you take it away, want some back? add"
> Rather than using the low level linker ld, use gcc to perform the linking stage, as this has better support for linking libc. This means that by default, we would need to use an entry point of main instead of _start

#### Stack adjustment (add 0x4)

in simple terms, we are essentially pushing the SP back up to where it was prior to calling.
We pretty much only need to adjust stack for instructions involving args, as the args go ontop of the intsruction, the SP needs to get back to the top
EG

1 arg passed = add 4 bytes
2 arg passed = add 8 bytes

```
main:

	push message ; 
	call printf  ; SP is underneath message as per RET, meaning the exit call will have a bonkers argument fed to it
	;add esp, 0x4  ; adjust the stack 

	push 0x5
	call exit
```

## Shellcoding: basics

Essentially machine code with a specific purpose EG
    spawn a shell
    bind to a port
    create new account
    any other sneaky and devious task

**It requires NO further assembling, linking or compiling. It can be executed by teh CPU directly**

When shellcode is part of an exploit AKA a payload, pay mind to size of shellcode (smalller is better) and obviously eliminate bad chars (OSCP PTSD)

Your shellcode can be added into an executable which means that:
    it could run in a seperate thread
    size no longer a concern
    bad chars not a concern
    replace executable functionality

## Shellcoding: JMP-CALL-POP

To avoid crashes and such, we exploit jmp-call-pop.
We do NOT at any point want to be referencing an address in our shellcode EG moving "Hello World!" into ecx, we circumvent by by performing a short jump to a call function and within that we POP into ECX, with the next instruction on the stack being the definition of the variable "message: db "Hello World!", 0xA - we are able to not care what the address is.

Before firing of your shellcode, **always** verify in gdb by comparing:
    print /x &code
    shell cat shellcode.c
    x/<number of bytes>xb <address>


## Shellcoding: getting a program to execute from within the program EG spawn root shell

We want "execve"!

```execve()  executes the program pointed to by filename.  filename must be either
       a binary executable, or a script starting with a line of the form:

 #include <unistd.h>
                         
       int execve(const char *filename, char *const argv[],
                  char *const envp[]);
```
We need to terminate our arg string containing the target binary with a null.
So: 
*filename would be /bin/bash, 0x0 inside EBX
*const argv[] would be Address of /bin/bash, 0x00000000 inside ECX
*const envp[] would be 0x00000000 inside EDX

^^^Unfortunately of course our shellcode cannot contain nulls :O

Confusing?
Consider the below as we break it down:

```
_start:

	jmp short call_shellcode


shellcode:

	pop esi ; next instruction after jmping to call shellcode is the value of message, which now gets popped into ESI, thus finding us the location/address of the string

	xor ebx, ebx ; create a zero value
	mov byte [esi +7], bl ; overwrite the A value in message with null, to terminate after /bin/sh WE USE BL BECAUSE WE ONLY WANT TO OVERWRITE ONE BYTE AND NO MORE!!!
	mov dword [esi +8], esi ; now that we have the address, we overwrite the BBBB in message with that address, satisfying the second requirement for execve args
	mov dword [esi +12], ebx ; we overwrite CCCC with ebx, thus zeroing it out and completing the last requirement for execve

	; we then load the bytes into the registers

	lea ebx, [esi] ; will now contain /bin/sh0x0

	lea ecx, [esi +8] ; will now contain address of /bin/sh, 0x00000000

	lea edx, [esi +12] ; will now contain 0x00000000

	xor eax, eax
	mov al, 0xb
	int 0x80



call_shellcode:

	call shellcode ; as we hit call, the ret address gets pushed onto the stack, which we then pop inside shellcode so the address gets thrown into ESI, thus enabling the rest of the trickery
	message db "/bin/shABBBBCCCC"

```
