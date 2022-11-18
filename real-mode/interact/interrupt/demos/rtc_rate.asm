; rtc-interrupt-demo.asm
; RTC中断演示样例

%include "../features/macros/screen.asm"
%include "./macros/interrupt.asm"

[BITS 16]
[ORG 0x7c00]

    xor ax, ax
    mov ds, ax
    mov es, ax
    mov sp, 0x9000

    SetupIntHandler 0x70, rtc_interrupt_handler ; IRQ 8（RTC）中断，对应中断向量0x70

    mov cl, 0x0f           ; 设置RTC中断分频值，该值越大，频率越小
    call set_rtc_interrupt_rate

    call enable_rtc_interrupt

    jmp $


rtc_interrupt_handler:
    pusha

    call read_rtc_second
    cmp al, [rtc_mem.second]    ; 与上次读取的秒数进行对比，如果不一样，再重新读取日期和时间
    je .quit

    mov di, rtc_mem
    call read_date_time

    call clear_screen
    PrintString rtc_ascii_mem, rtc_ascii_mem_len

.quit:
    mov al, 0x0C                ; 读取寄存器C以清除掩码位。必须有，否则接收不到下一个中断
    out 0x70, al
    in al, 0x71

    mov al, 0x20                ; 发送EOI消息，告知中断控制器中断已结束。必须有，否则接收不到下一个中断 
    out 0xa0, al                ; 发送到从控制器
    out 0x20, al                ; 发送到主控制器

    popa
    iret

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