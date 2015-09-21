	Bootstrapping a simple compiler from nothing
	============================================

This document describes how I implemented a tiny compiler for a toy
programming language somewhat reminiscent of C and Forth. The funny
bit is that I implemented the compiler in the language itself without
directly using any previously existing software. So I started by
writing raw machine code in hexadecimal and then, through a series of
bootstrapping steps, gradually made programming easier for myself
while implementing better and better "languages".

The complete source code for all the stages is in a tar archive:
<http://www.rano.org/bcompiler.tar.gz>. This text is the README file
from that archive. So, if you are reading this on-line, you can fetch
the tar archive and continue off-line, if you prefer.

The code only runs on i386-linux, though it would be easy to port it
to another operating system on i386, and probably not at all hard to
port it to a different architecture.


HEX1: the boot loader
---------------------

You could input a short program into the memory of an early computer
by using switches on its front panel. This short program might then
read in a longer program from punched cards. To write a program on
punched cards you did not need an editor program, as you could write
new cards using an electro-mechanical card punch and manually insert
and remove cards from the deck. So, if we were using an early
computer, we could really implement a compiler without using any
existing software. Unfortunately, a modern PC has neither front panel
switches nor a punched card reader, so you need some software running
on the machine just to read in a new program. In fact, you probably
need some rather complex software running on the machine: just take a
look at /usr/src/linux/drivers/block/floppy.c, for example.

Since we are doing this on a PC running Linux, we have to define some
other starting point. Rather than use the raw hardware, we start with
these facilities:

 - an operating system;

 - a simple text editor (or we could use Emacs and pretend it's a
   simple text editor);

 - a shell that lets us run a program with file descriptors connected
   to particular files (this way the programs we write only need to
   read from and write to file descriptors and do not have to know
   about opening files);

 - an initial program to convert hexadecimal to binary so that we can
   compose our first programs in hexadecimal, using the text editor,
   and then "compile" them to binary in order to run them (this
   corresponds roughly to the program that you might enter into an
   early computer using front panel switches).

Our initial program is hex1.he (the source in hexadecimal) or hex1
(the binary). If you want to check that hex1 really is the binary
corresponding to hex1.he, you can do a hex dump of it:

	od -Ax -tx1 hex1

If you use hex1 to process hex1.he the result it hex1 again:

	./hex1 < hex1.he | diff - hex1

So we can think of hex1 as a trivial bootstrapping compiler for a
language called HEX1.

Apart from comments and white space, the syntax of HEX1 is
/([0-9a-f]{2})*/. Comments start with '#' and continue to the end of
the line. The semantics of HEX1 is the semantics of machine code,
which is rather complex. Fortunately we can restrict ourselves to a
tiny subset of the full instruction set.

In hex1.he I have put the corresponding assembler code in comments
next to the machine code. The file starts with two ELF headers: a
52-byte file header and a 32-byte program header. It is not necessary
to understand all the fields in the ELF header. The most interesting
fields are:

* e_entry, which specifies where execution should begin. Here it is
0x08048054, which is directly after the ELF headers (labelled _start).

* p_vaddr and p_paddr, which specify the target address in memory.
Here it is 0x08048000, which is standard for Linux binaries.

* p_filesz and p_memsz, which should be set to the length of the file.
It seems not to matter if you put a larger number here, and I will
make use of that later, though here I have put the correct value.

(For more information about ELF do a web search. SCO and Intel have
some useful on-line documents.)

The code at _start is a loop that reads pairs of hex digits by calling
gethex and outputs bytes by calling putchar. Next comes putchar, which
uses the "write" system call. Then gethex, which calls getchar and
contains a loop for skipping over comments. The ASCII characters
[0-9a-f] are converted correctly to the values 0 to 15; everything
below '0' (48) is treated as a space and ignored; other characters are
misconverted, as there is no error detection. The function getchar
uses the "read" system call, and calls "exit" at the end of the file.


HEX2: one-character labels
--------------------------

Writing machine code in hex is not much fun. The worst part is
calculating the addresses for branch, jump and call instructions. Here
I am using relative addresses, so I have to recalculate the address
every time I change the length of the code between an instruction and
its target. It would be no better if I were using absolute addresses:
then I would have to change all references to locations after the
change.

So the first feature I add for my convenience is a function for
computing relative addresses. Instead of writing

	# function:
		...
		e8 cc ff ff ff		# call function

I will be able to write:

	.F			# function:
		...
		e8 F			# call function

HEX2 automatically fills in the correct 4-byte relative address.

Unfortunately, I still have to use HEX1 to implement the first version
of HEX2, so, to keep the implementation simple, I only allow
one-character labels and backwards references to them. And there is no
error detection for an undefined label.

The syntax of HEX2 is ([0-9a-f]{2}|\.L|L)*, where L is any character
above 32 apart from [0-9a-f].

The first implementation of HEX2 is hex2a.he. If you compare the ELF
headers in hex1.he and hex2a.he you will notice that I have changed
p_flags. This is to make the program writable as well as executable.
Normal programs consist of several sections, in particular a text
section, which contains the program itself, and a data section. The
text section is executable, but not writable, and the data section is
writable, but not executable. In hex1.he I did not need to write any
data to memory, so I only had a text section. In hex2a.he I need to
write data to memory, but I can not be bothered with separate
sections, so I use a single section which is both executable and
writable.

There are only two pieces of data: "pos" is a 32-bit counter to keep
track of our location as we output the binary, and "label" is a
259-byte table to record the values of the labels. Why 259 bytes? This
is because I forgot to multiply by 4. I should have used a table of
256 4-byte values, one for each possible one-character label, and
calculated the address as (table + char * 4). Since I forgot to
multiply by 4, I only need 259 bytes for my table, and I have to avoid
using labels that are close to one another: if I use 'm', then I
cannot use 'j', 'k', 'l', 'n', 'o' or 'p'. It would be easy to fix
this bug immediately, but it is even easier to work around it for now
and fix it a bit later.

We can "compile" hex2a.he using hex1:

	./hex1 < hex2a.he > hex2a && chmod +x hex2a

Since HEX2 is a superset of HEX1, hex2a.he can also compile itself:

	./hex2a < hex2a.he | diff - hex2a

To test the new facility, I made hex2b.he from hex2a.he by replacing
numerical addresses by symbolic ones wherever possible. Compiling
hex2b.he gives the same binary as hex2a.he:

	./hex2a < hex2b.he | diff - hex2a

In hex2c.he I fix the "multiply by 4" bug. It is easier to fix the bug
now that I can use labels and do not have to manually modify relative
addresses. In hex2c.he I also replace some 1-byte relative addresses
by 4-byte relative addresses, so that I can use labels, and I have
inserted blocks of NOPs at the end of file to make the precise value
of e_entry less critical.

We can compile hex2c.he using hex2a/hex2b or using itself:

	./hex2a < hex2c.he > hex2c && chmod +x hex2c
	./hex2c < hex2c.he | diff - hex2c


HEX3: four-character labels and a lot of calls
----------------------------------------------

One-character labels are a bit restrictive, so let us implement
four-character labels. If labels have exactly four characters we can
store them neatly in 32-bit words!

The syntax of HEX3 is /([0-9a-f]{2}|:....|\.....)*/, and now we will
introduce some very basic error detection. The compiler can report
three different kins of error, which is will do using its exit code:

 exit code 1: syntax error
 exit code 2: redefined label
 exit code 3: undefined label

Since it is a single-pass compiler, only backwards references to
labels are permitted.

The first implementation of HEX3 was hex3a.he, written in HEX2:

	./hex2c < hex3a.he > hex3a && chmod +x hex3a

It is not possible to compile hex3a.he with hex3a itself, as HEX3 is
not compatible with HEX2.

I created hex3a.he by making successive small changes to hex2c.he. The
system call brk() is used to get memory for an arbitrarily large
symbol table. Absolute references to data are avoided by putting a
function (.z / get_p) in front of the static data area that returns
the address of the following data.

Having created hex3a.he, I started work on hex3b.he, an implementation
of HEX3 written in HEX3. Initially hex3b.he was just hex3a.he
translated to the new syntax, but I then gradually rewrote it to make
much greater use of labels and functions. In the final version, after
a certain point in the file, everything is done using only these
instruction groups:

 - push a constant onto the stack:  68 XX XX XX XX
 - call a named function:           e8 .LABEL
 - unconditional jump:              e9 .LABEL
 - conditional branch:              58 85 c0 0f 85 .LABEL
 - push an address onto the stack:  68 .LABEL e8 .reab

The last instruction group consists of a push instruction followed by
a call instruction, but the two may not be separated: the function
"reab" converts the relative address on the stack to an absolute
address by adding its return address and subtracting 5.

We can compile hex3b.he using hex3a or itself:

	./hex3a < hex3b.he > hex3b && chmod +x hex3b
	./hex3b < hex3b.he | diff - hex3b


HEX4: any-length labels and implicit calls
------------------------------------------

When implementing hex3b.he we found that it is possible to define all
complex functions in terms of simpler functions by using a tiny subset
of all the possible machine instructions: branch, call, jump and a few
others.

In HEX4 we use an even smaller set of instructions and generate those
instructions implicitly.

In HEX4 there are four types of token:

 - in-line code or data ('58, '59)
 - define label (:data, :loop, :func)
 - instruction: push constant (10, 42)
 - instruction: push label address (&func, &loop)
 - instruction: call label address (+, -, jump, branch, func)

Tokens must be separated by white space and the type of token is
recognised from the first character. Labels can have any length - but
we implement them with a simple hash function, so there is a risk of
spurious redefined label errors.

The jump and branch instruction groups from HEX3 are implemented by
functions. A "push label address" instruction must always be followed
immediately by a call to one of the functions that can understand a
relative address: address, branch, jump. The "address" function
(formally "reab") converts the relative address to an absolute
address, which can be stored and used later.

The predefined functions are:

Stack manipulation: drop dup rot pick swap
Arithmetic: + - * / % << >> log
Comparisons: < <= == != >= >
Bitwise logic: & | ^ ~
Memory access: @ = c@ c=
Flow of control, using immediate relative address: branch call
Flow of control, using stored absolute address: call
Address conversion: address
Array support: [] []& []= c[] c[]& c[]=
Access of arguments and variables: arg arg& arg= var var& var=
Function support: enter vars xreturnx xreturn0 xreturn1
Dynamic memory: wsize sbrk / malloc free realloc
System calls: exit in out

- All operations take arguments and return results to the stack.

- Comparisons return 0 or 1.

- All data are words, except for c@, c=, c[], c[]&, c[]=, which
operate on bytes.

- Any user-defined function must start with "enter"; "vars" can be
used straight after "enter" to reserve space for N local variables.

- To return from a function, use one of the "return" functions. "X Y
xreturnx" means return Y values from a function that took X arguments.
The most common cases are Y=0 and Y=1, so "X xreturn0" and "X
xreturn1" are provided.

- Like in C, addresses are byte addresses, so we have to multiply by
wsize when allocating memory with sbrk or malloc.

- "x y []" is equivalent to "x y wsize * + @"

- As always, no forward references to labels are allowed.

As with HEX3 there are two implementations of HEX4. The first one,
hex4a.he, is written in HEX3. The second one, hex4b.he, is written in
HEX4.

	./hex3b < hex4a.he > hex4a && chmod +x hex4a
	./hex4a < hex4b.he > hex4b && chmod +x hex4b
	./hex4b < hex4b.he | diff - hex4b


HEX5: structured programming, at last
-------------------------------------

HEX5 is more like a real structured programming language. There are no
longer any labels; instead there are loops and if...(else)...fi
structures. The syntax of HEX5 can no longer be described with a
regular expression; instead we need a context-free grammar:

	program = (hexitem | global | procedure)*
	hexitem = hexbyte |  "_def" symbol
	hexbyte = /'[0-9a-f][0-9a-f]/
	global = "var" symbol | "string" symbol string_literal
	string_literal = /"([^"]|\\.)*"/
	procedure = "def" args name "{" vars body "}"
	args = symbol*
	name = symbol
	vars = "var" symbol
	body = (number | word | loop | jump | if)*
	number = /[0-9]+/
	word = symbol
	loop = "{" body "}"
	jump = "break" | "continue" | "until" | "while"
	if = "if" body "fi" | "if" body "else" body "fi"
	symbol = /.+/ except ...

Lexical rules:

	comment = /#[^\n]*\n?/
	space = /\s/
	string_literal = /"([^"]|\\.)*"/
	token = /\S+/

The first implementation of HEX5, written in HEX4, is hex5a.he. This
is only a very partial implementation, as it would be quite tedious to
implement all of HEX5 in HEX4. In particular, there are not yet any
named variables or arguments; access to a function's arguments and
local variables is done using the functions from HEX4. Global
variables are implemented with a cunning hack:

	./hex4b < hex5a.he > hex5a && chmod +x hex5a

Next came hex5b.he, which can compile itself, as it is written in a
subset of HEX5. In hex5b.he I implemented named arguments and
variables:

	./hex5a < hex5b.he > hex5b && chmod +x hex5b
	./hex5b < hex5b.he | diff - hex5b

Then I wanted to start using those features for implementing further
features, so I switched to developing hex5c.he, in which I implemented
string constants, "while", "until", "return0" and "return1":

	./hex5b < hex5c.he > hex5c && chmod +x hex5c


BCC: a real language
--------------------

All that is needed to turn HEX5 into a tiny structured programming
language is to separate off the first part of the source, where there
is in-line machine code and the "predefined" and library functions are
implemented, into a separate header file. At this point I removed
references to "hex" and called the two files "header.bc" and "bcc.bc".
These two files are concatenated for compilation:

	cat header.bc bcc.bc | ./hex5c > bcc && chmod +x bcc

Now bcc can compile itself, of course:

	cat header.bc bcc.bc | ./bcc > bcc2 && chmod +x bcc2
	mv bcc2 bcc
	cat header.bc bcc.bc | ./bcc | diff - bcc

Note that the bcc produced by hex5 might not be identical to the bcc
produced by bcc itself, as I might make some minor improvements to the
code generated by bcc. But the main improvements to be introduced in
bcc are:

 - proper error messages to stderr instead of just exit codes
 - report undefined symbols
 - a dynamic buffer for tokens so there is no limit to their length


What next?
----------

Here are some things that one might want to do with BCC for one's
education and entertainment:

 - port it to a different operating system or architecture
   (you could compile to Java byte code, for example)

 - think of a neater way of handling return values from functions

 - implement a compile-time check for stack underflow

 - include a non-bogus implementation of malloc, realloc, free

 - use an RB-tree for the symbol table so that the compiler does not
   take time quadratic in the number of symbols

 - think up a way of using BCC to bootstrap GCC ...


Edmund GRIMLEY EVANS <edmundo@rano.org>, March 2001
Revised: March 2002
