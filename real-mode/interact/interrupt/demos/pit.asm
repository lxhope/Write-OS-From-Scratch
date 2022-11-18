; pit-interrupt-demo.asm
; PIT中断演示样例
; PIT设置后直接使用STI就可以开启，无需进一步的启用动作
; 参考：
;   https://wiki.osdev.org/Pit

%include "../features/macros/screen.asm"
%include "./macros/interrupt.asm"


[BITS 16]
[ORG 0x7c00]

    xor ax, ax
    mov ds, ax
    mov es, ax
    mov sp, 0x9000

    mov bx, 0x0FFF      ; 设置计数值，值越大，PIT中断频率越低，值0例外，代表65536（最高），也是默认值
    call set_pit_count

    SetupIntHandler 0x08, pit_interrupt_handler ; IRQ 0（PIT）中断，对应中断向量0x8

    jmp $

%include "./libs/handlers/pit.asm"
%include "./libs/init/pit.asm"

%include "../features/libs/screen.asm"
%include "../features/libs/misc.asm"

decimal_str:
    db 0, 0, 0, 0, 0, 0
decimal_str_len equ $ - decimal_str

    times 510-($-$$) db 0
    db 0x55
    db 0xAA