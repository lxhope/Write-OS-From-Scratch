; keyboard-interrupt-demo.asm
; 键盘输入中断演示样例
; 键盘中断对应IRQ 1，即INT 0x9
; 参考：
;   https://wiki.osdev.org/Keyboard

%include "../features/macros/screen.asm"
%include "./macros/interrupt.asm"


[BITS 16]
[ORG 0x7c00]

    xor ax, ax
    mov ds, ax
    mov es, ax
    mov sp, 0x9000

    call disable_keyboard_translation  ; 默认使用scan code 1，禁用转换后使用scan code 2

    SetupIntHandler 0x09, keyboard_interrupt_handler ; IRQ 1（Keyboard）中断，对应中断向量0x9

    call clear_screen

    jmp $

%include "./libs/init/keyboard.asm"
%include "./libs/handlers/keyboard.asm"

%include "../features/libs/screen.asm"
%include "../features/libs/misc.asm"

scan_code db 0, 0

    times 510-($-$$) db 0
    db 0x55
    db 0xAA