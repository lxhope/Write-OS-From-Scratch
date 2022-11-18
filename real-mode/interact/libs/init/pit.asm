; PIC初始化功能模块
; PIT(Programmable Interval Timer)，可编程间隔计时器
; 通常在启动过程中，BIOS设置通道0的计数为65535或0（转换为65536），
;  这是输出频率为18.2065Hz（或每54.9254ms一个IRQ）
; 参考：
;    https://wiki.osdev.org/Pit


; ------------------------------------------------------------------
; set_pit_count -- Set PIT channel 0 reload count
; IN: BX = count
; OUT: Nothing
;
set_pit_count:    ; 设置PIT channel 0 重载值
    cli
    push ax

    mov al, 00110100b    ; 设置通道0的访问模式为低字节/高字节，操作模式为 模式2（速率产生器）
    out 0x43, al         ; PIT命令寄存器

    mov al, bl           ; 设置低字节
    out 0x40, al         ; PIT channel 0端口
    mov al, bh           ; 设置高字节
    out 0x40, al

    pop ax
    sti
    ret
