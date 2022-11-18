; PIT中断处理程序
; 参考：
;    https://wiki.osdev.org/Pit

pit_interrupt_handler:
    pusha

    mov cx, count_decimal_str_len
    mov di, count_decimal_str
    mov al, 0        
    rep stosb                     ; 清除十进制字符串缓存 

    mov eax, [count]              ; 计数加1
    inc eax
    mov [count], eax

    call clear_screen
    ;PrintString msg, msg_len
    ;call newline
    mov di, count_decimal_str
    call binary_to_decimal_str
    PrintString count_decimal_str, count_decimal_str_len

.quit:
    mov al, 0x20                ; 发送EOI消息，告知中断控制器中断已结束。必须有，否则接收不到下一个中断 
    out 0x20, al                ; 发送到主控制器

    popa
    iret

msg db 'PIT Interrupt Handler'
msg_len equ $ - msg

count dw 0

count_decimal_str db 0, 0, 0, 0, 0
count_decimal_str_len equ $ - count_decimal_str