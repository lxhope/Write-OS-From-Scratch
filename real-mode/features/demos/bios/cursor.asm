; cursor-demo.asm
; 设置光标位置示例

%macro  SetCursorPos 2  ; 2个参数，第一个是光标所在的行，第二个为光标所在的列

        push dx
        mov dh, %1   ; %1代表第一个参数
        mov dl, %2   ; %2代表第二个参数
        call bios_move_cursor
        pop dx

%endmacro

[BITS 16]
[ORG 0x7c00]

    SetCursorPos 2, 3

hang:
    jmp hang

%include "../libs/bios/cursor.asm"

    times 510-($-$$) db 0
    db 0x55
    db 0xAA