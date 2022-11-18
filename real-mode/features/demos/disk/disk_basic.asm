; disk-basic-demo.asm
; 最基础的读取磁盘示例
; 作用：将启动磁盘的第2个扇区数据加载到0x7e00处，并打印0x7e00处的字符串

%macro PrintString 2 ; 2个参数，第一个是字符串的位置，第二个为显示的长度

        pusha

        mov bp, %1
        mov cx, %2
        call bios_print_string

        popa

%endmacro

%macro LoadSector 0         ; 为方便起见，所需的参数都直接写在代码中

        mov dx, 0x1f6       ; 驱动/柱头端口
        mov al, 10100000b   ; 位7 = 1，位6 = 0，位5 = 1，位4 = 0选择驱动器0、1选择驱动器1，位3-0为柱头编号
        out dx, al

        mov dx, 0x1f2       ; 扇区数量端口
        mov al, 1           ; 读取一个扇区
        out dx, al

        mov dx, 0x1f3       ; 扇区编号端口
        mov al, 2           ; 读取第2个扇区，此编号从1开始，不是0
        out dx, al

        mov dx, 0x1f4       ; 柱面低字节端口
        mov al, 0           ; 柱面0
        out dx, al

        mov dx, 0x1f5       ; 柱面高字节端口
        mov al, 0
        out dx, al

        mov dx, 0x1f7       ; 命令端口
        mov al, 0x20        ; 带重试读
        out dx, al

%%still_going:
        in al, dx
        test al, 8
        jz %%still_going

        mov cx, 512/2
        mov di, 0x7e00
        mov dx, 0x1f0     ; 数据端口
        rep insw          ; 每次读取一个字（两字节）

%endmacro

[BITS 16]
[ORG 0x7c00]

    mov ax, 0
    mov es, ax
    mov ds, ax
    mov sp, 0x9000
    
    call bios_clear_screen

    LoadSector          ; 将启动磁盘的第2个扇区数据加载到0x7e00处

    PrintString second_sector_msg, second_sector_msg_len

hang:
    jmp hang

%include "../libs/bios/screen.asm"

success_msg db 'Read sector success!', 0x0a, 0x0d  ; 0x0a, 0x0d代表一次换行
success_msg_len equ $ - success_msg
fail_msg db 'Read sector failed!', 0x0a, 0x0d
fail_msg_len equ $ - fail_msg

drive_num:
    db 0

    times 510-($-$$) db 0
    db 0x55
    db 0xAA

;==========================
; 第2个扇区

second_sector_msg db 'This is a message which in second sector'
second_sector_msg_len equ $ - second_sector_msg

    times 1024-($-$$) db 0