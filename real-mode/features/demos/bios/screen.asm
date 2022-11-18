; screen-demo.asm
; 屏幕显示示例

%macro  ClearScreen 0  ; 没有参数

        call bios_clear_screen

%endmacro

%macro  SetCursorPos 2  ; 2个参数，第一个是光标所在的行，第二个为光标所在的列

        push dx
        mov dh, %1   ; %1代表第一个参数
        mov dl, %2   ; %2代表第二个参数
        call bios_move_cursor
        pop dx

%endmacro

%macro PrintChar 1   ; 要显示的字符

        push ax

        mov al, %1
        call bios_print_char

        pop ax

%endmacro

%macro PrintString 2 ; 2个参数，第一个是字符串的位置，第二个为显示的长度

        pusha

        mov bp, %1
        mov cx, %2
        call bios_print_string

        popa

%endmacro

%macro NewLine 0   ; 换行

        push ax

        mov al, 0x0a    ; 将显示位置移到下一行，0x0a = Line Feed character in ASCII
        call bios_print_char
        mov al, 0x0d    ; 将显示位置移动行首，0x0d = Carriage Return character in ASCII
        call bios_print_char

        pop ax

%endmacro

[BITS 16]
[ORG 0x7c00]

    ClearScreen
    
    PrintChar 'a'
    PrintChar 'b'

    NewLine

    PrintChar 'c'
    PrintChar 'd'

    NewLine

    PrintString msg, msg_len

hang:
    jmp hang

%include "../libs/bios/screen.asm"

msg db 'Hello World!'
msg_len equ $ - msg

    times 510-($-$$) db 0
    db 0x55
    db 0xAA