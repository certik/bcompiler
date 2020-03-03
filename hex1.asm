SECTION .TEXT
    GLOBAL _start

_start:
    call gethex
    shl eax,byte 0x4
    push eax
    call gethex
    add [esp],eax
    call putchar
    pop eax
    jmp _start

putchar:
    xor ebx,ebx
    inc ebx
    lea ecx,[esp+0x4]
    mov edx,ebx
    mov eax,0x4
    int 0x80
    ret

gethex:
    call getchar
    cmp eax,byte +0x23
    jnz .convhex
.loop:
    call getchar
    cmp eax,byte +0xa
    jnz .loop
    jmp gethex
.convhex:
    sub eax,byte +0x30
    jl gethex
    cmp eax,byte +0x30
    jl .ret
    sub eax,byte +0x27
.ret:
    ret

getchar:
    push byte +0x0
    xor ebx,ebx
    mov ecx,esp
    mov edx,ebx
    inc edx
    mov eax,0x3
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
