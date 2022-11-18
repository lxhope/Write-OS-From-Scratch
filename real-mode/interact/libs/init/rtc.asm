; 初始化RTC相关功能模块
; 参考：
;    https://wiki.osdev.org/RTC
;    https://programmer.group/x86-assembly-language-interrupt-handling.html

; ------------------------------------------------------------------
; enable_rtc_interrupt -- Enable RTC interrupt
; IN: Nothing
; OUT: Nothing
;

enable_rtc_interrupt:  ; 启用RTC中断
    cli
    push ax
    push bx

    mov al, 0x8B       ; 选择寄存器B，并禁用NMI
    out 0x70, al       ; 向CMOS控制端口发送数据
    in al, 0x71        ; 读取寄存器B的值
    mov bl, al         ; 放在bl中做备份

    or bl, 0x40        ; 设置位6，该位控制IRQ 8开启
    mov al, 0x8B
    out 0x70, al
    mov al, bl
    out 0x71, al       ; 向CMOS数据接口发送数据，开启IRQ

    pop bx
    pop ax
    sti
    ret

; ------------------------------------------------------------------
; set_rtc_interrupt_rate -- Set RTC interrupt frequency
; IN: 
;    CL = rate, range: 3~15，frequency =  32768 >> (rate-1);
; OUT: Nothing
;

set_rtc_interrupt_rate:          ; 设置RTC中断频率
    cli
    push ax
    push bx

    mov al, 0x8A       ; 选择寄存器B，并禁用NMI
    out 0x70, al       ; 向CMOS控制端口发送数据
    in al, 0x71        ; 读取寄存器A的值
    mov bl, al         ; 放在bl中做备份

    and bl, 0xF0
    and cl, 0x0F       ; 确保CL只有低4位有值
    or bl, cl          ; 设置rate

    mov al, 0x8A
    out 0x70, al
    mov al, bl
    out 0x71, al       ; 向CMOS数据接口发送数据，设置rate

    pop bx
    pop ax
    sti
    ret