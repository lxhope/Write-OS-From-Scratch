[ORG 0x7c00]

    xor ax, ax ; make it zero
    mov ds, ax

    mov si, msg
    cld
ch_loop:
    lodsb
    or al, al ; zero=end of string
    jz hang   ; get out
    mov ah, 0x0E
    mov bh, 0
    int 0x10
    jmp ch_loop

hang:
    jmp hang

msg db 'Hello World', 13, 10, 0

    times 510-($-$$) db 0
    db 0x55
    db 0xAA