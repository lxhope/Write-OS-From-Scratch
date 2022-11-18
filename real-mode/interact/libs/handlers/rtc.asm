; RTC中断处理程序
; 参考：
;    https://wiki.osdev.org/RTC
;    https://programmer.group/x86-assembly-language-interrupt-handling.html

rtc_interrupt_handler:
    pusha

    call read_rtc_second
    cmp al, [rtc_mem.second]    ; 与上次读取的秒数进行对比，如果不一样，再重新读取日期和时间
    je .quit

    mov di, rtc_mem
    call read_date_time

    mov si, rtc_mem
    mov di, rtc_ascii_mem
    mov cx, rtc_mem_len
    call bcd_to_ascii_str

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

%include "../features/libs/rtc.asm"
%include "../features/libs/misc.asm"