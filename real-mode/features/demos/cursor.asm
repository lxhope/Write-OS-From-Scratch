; cursor-demo.asm
; 设置光标位置示例
; qemu调试命令手册：https://qemu.readthedocs.io/en/latest/system/monitor.html#

%macro  SetCursorPos 2  ; 2个参数，第一个是光标所在的行，第二个为光标所在的列

        push ax
        push bx

        mov ax, %1   ; %1代表第一个参数，代表光标位置的行或y
        mov bx, %2   ; %2代表第二个参数，代表光标位置的列或x
        call move_cursor

        pop bx
        pop ax

%endmacro

[BITS 16]
[ORG 0x7c00]

    ;call disable_cursor
    ;call enable_cursor

    SetCursorPos 3, 4
    call get_cursor_pos

hang:
    jmp hang

%include "../libs/cursor.asm"

    times 510-($-$$) db 0
    db 0x55
    db 0xAA