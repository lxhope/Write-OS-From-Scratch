; PIT中断处理程序
; 打印原始的scan code，不做任何转换
; 参考：
;    https://wiki.osdev.org/Keyboard

keyboard_interrupt_handler:
    pusha

    in al, 0x60
    call binary_to_hex

    mov [scan_code_tmp], ah
    mov [scan_code_tmp+1], al
    PrintString scan_code_tmp, 2

    PrintChar ' '

.quit:
    mov al, 0x20                ; 发送EOI消息，告知中断控制器中断已结束。必须有，否则接收不到下一个中断 
    out 0x20, al                ; 发送到主控制器

    popa
    iret

scan_code_tmp dw 0