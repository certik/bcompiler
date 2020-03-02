SECTION .DATA
    hello:     db 'Hello world!',10
    helloLen:  equ $-hello

SECTION .TEXT
    GLOBAL _start

_start:
    mov eax,4            ; 'write' system call = 4
    mov ebx,1            ; file descriptor 1 = STDOUT
    mov ecx,hello        ; string to write
    mov edx,helloLen     ; length of string to write
    int 80h              ; call the kernel

    ; Terminate program
    mov eax,1            ; 'exit' system call
    mov ebx,0            ; exit with error code 0
    int 80h              ; call the kernel

putchar:
    xor ebx, ebx
    inc ebx
    lea ecx, [esp+4]
    mov edx, ebx
    mov eax, 4
    int 80h
    ret

gethex:
    call getchar
    cmp eax, 35
    jne .convhex
.loop:
    call getchar
    cmp eax, 10
    jne .loop
    jmp gethex
.convhex:
    sub eax, 48
    jl gethex
    cmp eax, 48
    jl .ret
    sub eax, 39
.ret:
    ret

getchar:
    push 0
    xor ebx, ebx
    mov ecx, esp
    mov edx, ebx
    inc edx
    mov eax, 3
    int 80h
    test eax, eax
    je exit
    pop eax
    ret

exit:
    xor eax, eax
    mov ebx, eax
    inc eax
    int 80h
