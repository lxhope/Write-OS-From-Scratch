; disk-read-by-lba-demo.asm
; 以LBA模式读磁盘示例

%macro ReadSector 2  ; 2个参数，1: 驱动器编号，2: Disk Access Packet

        pusha

        mov dl, %1
        mov si, %2
        call bios_lba_read_sector

        jc .error    ; 如果出现错误，会设置进位标志

.success:
        PrintString success_msg, success_msg_len
        jmp .exit

.error:
        PrintString fail_msg, fail_msg_len

.exit:
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

    ReadSector [drive_num], DiskAdressPacket  ; 将启动磁盘的第二个扇区加载到内存0x7e00处

    PrintString second_sector_msg, second_sector_msg_len

hang:
    jmp hang

%include "../libs/bios/screen.asm"
%include "../libs/bios/disk.asm"

DiskAdressPacket:
    db 0x10        ; 包大小（16字节）
    db 0           ; 始终为0
    dw 1           ; 传输的扇区数
    dw 0x7e00      ; 传输缓冲区
    dw 0           ; LBA起始位置的高32位
    dd 1           ; LBA起始位置的第16位，从0开始，1代表第2个扇区
    dd 0

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