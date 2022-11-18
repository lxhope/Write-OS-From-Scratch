; disk-demo.asm
; 读取磁盘示例

%macro  PrintString 2  ; 2个参数，第一个是字符串的首个字母位置，第二个为字符串长度

        push si
        push cx

        mov ax, %1   ; %1代表第一个参数
        mov si, ax
        mov cx, %2   ; %2代表第二个参数
        call print_string

        pop cx
        pop si

%endmacro

[BITS 16]
[ORG 0x7c00]

    xor ax, ax
    mov ds, ax
    mov es, ax
    mov sp, 0x9000

    call clear_screen
    
    mov di, rtc_mem
    call read_date_time

    mov si, rtc_mem
    mov di, rtc_ascii_mem
    mov cx, rtc_mem_len
    call bcd_to_ascii_str

    PrintString rtc_ascii_mem, rtc_ascii_mem_len

hang:
    jmp hang

%include "../libs/screen.asm"
%include "../libs/rtc.asm"
%include "../libs/misc.asm"

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

SECTION .text
    times 510-($-$$) db 0
    db 0x55
    db 0xAA