  BITS 32

                org     0x08048000
  origin        equ     0x08048000

  ehdr:                                                 ; Elf32_Ehdr
                db      0x7F, "ELF", 1, 1, 1, 0         ;   e_ident
                db      0, 0, 0, 0, 0, 0, 0, 0
                dw      2                               ;   e_type
                dw      3                               ;   e_machine
                dd      1                               ;   e_version
                dd      _start                          ;   e_entry
                dd      phdr - $$                       ;   e_phoff
                dd      0                               ;   e_shoff
                dd      0                               ;   e_flags
                dw      ehdrsize                        ;   e_ehsize
                dw      phdrsize                        ;   e_phentsize
                dw      1                               ;   e_phnum
                dw      0                               ;   e_shentsize
                dw      0                               ;   e_shnum
                dw      0                               ;   e_shstrndx

  ehdrsize      equ     $ - ehdr

  phdr:                                                 ; Elf32_Phdr
                dd      1                               ;   p_type
                dd      0                               ;   p_offset
                dd      origin                          ;   p_vaddr
                dd      origin                          ;   p_paddr
                dd      filesize                        ;   p_filesz
                dd      filesize                        ;   p_memsz
                dd      5                               ;   p_flags
                dd      0x1000                          ;   p_align

  phdrsize      equ     $ - phdr


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

filesize      equ     $ - $$
