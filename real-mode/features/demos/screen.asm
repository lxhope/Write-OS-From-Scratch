; screen-demo.asm
; 文本模式显示示例

%include "../macros/screen.asm"

[BITS 16]
[ORG 0x7c00]

    mov ax, 0
    mov ds, ax

    call clear_screen
    PrintString msg, msg_len
    call newline
    PrintString msg_2, msg_2_len
    call newline
    PrintChar 'Y'

hang:
    jmp hang

%include "../libs/screen.asm"

msg db 'Hello World!'
msg_len equ $ - msg

msg_2 db 'Good'
msg_2_len equ $ - msg_2

    times 510-($-$$) db 0
    db 0x55
    db 0xAA