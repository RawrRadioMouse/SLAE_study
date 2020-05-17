# GENERAL CPU AND SYSTEM NOTES
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
        - use a legment selector and an offset in that segment to figure out how to access specific locations (MORE READING: https://superuser.com/questions/318804/understanding-flat-memory-model-and-segmented-memory-model)
    - real-address mode model
        -

The kernel is a computer program at the core of a computer's operating system with 
complete control over everything in the system. 
It is the "portion of the operating system code that is always resident in memory". 
It facilitates interactions between hardware and software components.

### HOW DOES A SYSTEM CALL WORK:
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
    

# DEALING WITH DATA

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

#### defining initialised data
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

#### Little endian
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
Examine top of stack
this can also be used to address inline string data. if the string is placed directly after a call inst, the address of 
the string will be pushed to the stack as the return address. instead of calling a function, we can jump straight past 
the string to a pop inst that will take the address off the stack and into a register.
```
define hook-stop

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

##### For 32 bit multiplication:

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

### division

For division:
```
    AX
    /
    r/m8
Quotant in AL
Remainder in AH
```