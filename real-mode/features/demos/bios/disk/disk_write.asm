; disk-write-demo.asm
; 磁盘写示例

%macro ReadSector 6  ; 6个参数，1:驱动器编号，2:Cylinder，3:Head，4:Sector，5:读取扇区数量，6:读取到的位置

        pusha

        mov dl, %1   ; 驱动器编号，(0=A:, 1=2nd floppy, 80h=drive 0, 81h=drive 1)
        mov ch, %2   ; 柱面（Cylinder）
        mov dh, %3   ; 磁头（Head）
        mov cl, %4   ; 扇区（Sector）
        mov al, %5   ; 读取扇区数量
        mov bx, %6   ; 存储位置
        call bios_read_sector

        jc %%fail    ; 如果出现错误，会设置进位标志

%%success:           ; %%代表局部符号，为防止多次使用宏时出现名称冲突，在预处理的时候会修改为全局唯一符号，如"..@2345.success"
        PrintString success_msg, success_msg_len
        jmp %%exit

%%fail:
        PrintString fail_msg, fail_msg_len

%%exit:
        popa

%endmacro

%macro WriteSector 6  ; 6个参数，1:驱动器编号，2:Cylinder，3:Head，4:Sector，5:读取扇区数量，6:要写入的位置

        pusha

        mov dl, %1   ; 驱动器编号，(0=A:, 1=2nd floppy, 80h=drive 0, 81h=drive 1)
        mov ch, %2   ; 柱面（Cylinder）
        mov dh, %3   ; 磁头（Head）
        mov cl, %4   ; 扇区（Sector）
        mov al, %5   ; 写入扇区数量
        mov bx, %6   ; 存储位置
        call bios_write_sector

        jc %%fail    ; 如果出现错误，会设置进位标志

%%success:
        PrintString write_success_msg, write_success_msg_len
        jmp %%exit

%%fail:
        PrintString write_fail_msg, write_fail_msg_len

%%exit:
        popa

%endmacro

%macro PrintString 2 ; 2个参数，第一个是字符串的位置，第二个为显示的长度

        pusha

        mov bp, %1
        mov cx, %2
        call bios_print_string

        popa

%endmacro

[BITS 16]
[ORG 0x7c00]

    mov ax, 0
    mov es, ax
    mov ds, ax
    mov sp, 0x9000

    mov [drive_num], dl  ; 保存驱动器编号。启动时会将启动磁盘驱动器编号放在dl中
    
    call bios_clear_screen

    ReadSector [drive_num], 0, 0, 2, 1, 0x7e00  ; 将启动磁盘的第二个扇区加载到内存0x7e00处

    mov al, 'B'                                 ; 将第二个扇区的第一个字符改为‘B’，并写入磁盘
    mov [second_sector_msg], al
    WriteSector [drive_num], 0, 0, 2, 1, 0x7e00  ; 将内存0x7e00处的512个字节写入启动磁盘的第二个扇区

    ReadSector [drive_num], 0, 0, 2, 1, 0x7e00   ; 再次读取第二个扇区

    PrintString second_sector_msg, second_sector_msg_len

hang:
    jmp hang

%include "../libs/bios/screen.asm"
%include "../libs/bios/disk.asm"

success_msg db 'Read sector success!', 0x0a, 0x0d  ; 0x0a, 0x0d代表一次换行
success_msg_len equ $ - success_msg
fail_msg db 'Read sector failed!', 0x0a, 0x0d
fail_msg_len equ $ - fail_msg

write_success_msg db 'Write sector success!', 0x0a, 0x0d
write_success_msg_len equ $ - write_success_msg
write_fail_msg db 'Write sector failed!', 0x0a, 0x0d
write_fail_msg_len equ $ - write_fail_msg

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