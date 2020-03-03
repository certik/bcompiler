SECTION .TEXT
    GLOBAL _start

_start:
    call gethex
    shl eax,4
    push eax
    call gethex
    add [esp],eax
    call putchar
    pop eax
    jmp _start

putchar:
    xor ebx,ebx
    inc ebx
    lea ecx,[esp+4]
    mov edx,ebx
    mov eax,4
    int 0x80
    ret

gethex:
    call getchar
    cmp eax,35
    jnz .convhex
.loop:
    call getchar
    cmp eax,10
    jnz .loop
    jmp gethex
.convhex:
    sub eax,48
    jl gethex
    cmp eax,48
    jl .ret
    sub eax,39
.ret:
    ret

getchar:
    push 0
    xor ebx,ebx
    mov ecx,esp
    mov edx,ebx
    inc edx
    mov eax,3
    int 0x80
    test eax,eax
    jz exit
    pop eax
    ret

exit:
    xor eax,eax
    mov ebx,eax
    inc eax
    int 0x80
