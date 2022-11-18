; sleep-demo.asm
; 屏幕显示示例

%macro  ClearScreen 0  ; 没有参数

        call bios_clear_screen

%endmacro

%macro  Sleep 1  ; 1个参数，休眠多长时间，单位：微秒（1秒=1000000微秒）

        pusha

        mov ecx, %1
        mov dx, cx     ; 将低16位赋给dx
        shr ecx, 16    ; 将高16位移动到低16位
        call bios_wait

        popa

%endmacro


[BITS 16]
[ORG 0x7c00]

    ClearScreen

    mov al, '0'
loop:
    call bios_print_char 
    Sleep 1000000  ; 等待1秒
    inc al         ; 下一次打印新的字符
    jmp loop

hang:
    jmp hang

%include "../libs/bios/screen.asm"
%include "../libs/bios/sleep.asm"

msg db 'Hello World!'
msg_len equ $ - msg

    times 510-($-$$) db 0
    db 0x55
    db 0xAA