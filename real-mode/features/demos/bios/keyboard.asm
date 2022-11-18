; keyboard-input-demo.asm
; 键盘输入示例

%macro  ClearScreen 0  ; 没有参数

        call bios_clear_screen

%endmacro

%macro  BlockedKeyboardInput 0

        call bios_blocked_keyboard_input

%endmacro


[BITS 16]
[ORG 0x7c00]

    ClearScreen

loop:
    call bios_blocked_keyboard_input 
    call bios_print_char
    jmp loop

hang:
    jmp hang

%include "../libs/bios/screen.asm"
%include "../libs/bios/keyboard.asm"

msg db 'Hello World!'
msg_len equ $ - msg

    times 510-($-$$) db 0
    db 0x55
    db 0xAA