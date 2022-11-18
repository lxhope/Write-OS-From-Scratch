; rtc-interrupt-demo.asm
; RTC中断演示样例
; 参考：
;    https://wiki.osdev.org/RTC

%include "../features/macros/screen.asm"
%include "./macros/interrupt.asm"


[BITS 16]
[ORG 0x7c00]

    xor ax, ax
    mov ds, ax
    mov es, ax
    mov sp, 0x9000

    SetupIntHandler 0x70, rtc_interrupt_handler ; IRQ 8（RTC）中断，对应中断向量0x70

    call enable_rtc_interrupt

    jmp $

%include "./libs/handlers/rtc.asm"
%include "./libs/init/rtc.asm"

%include "../features/libs/screen.asm"

    times 510-($-$$) db 0
    db 0x55
    db 0xAA

SECTION .bss  ; 此段在编译的时候会放在下面部分之后
; RTC原始数据暂存区（BCD编码）
rtc_mem:
    .year    resb 1
    .month   resb 1
    .day     resb 1
    .hour    resb 1
    .minute  resb 1
    .second  resb 1
end_rtc_mem:
    rtc_mem_len equ end_rtc_mem - rtc_mem

; RTC数据转换为ASCII后的暂存区
rtc_ascii_mem:
    .year    resw 1
    .month   resw 1
    .day     resw 1
    .hour    resw 1
    .minute  resw 1
    .second  resw 1
end_rtc_ascii_mem:
    rtc_ascii_mem_len equ end_rtc_ascii_mem - rtc_ascii_mem