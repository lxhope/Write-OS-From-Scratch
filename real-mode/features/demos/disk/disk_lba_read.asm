; disk-lba-read-demo.asm
; 以CHS模式读取磁盘示例

%macro  PrintString 2  ; 2个参数，第一个是字符串的首个字母位置，第二个为字符串长度

        push ax
        push si
        push cx

        mov ax, %1   ; %1代表第一个参数
        mov si, ax
        mov cx, %2   ; %2代表第二个参数
        call print_string

        pop cx
        pop si
        pop ax

%endmacro

%macro LoadSector 4  ; 6个参数，1:驱动，2:LBA值，3:读取扇区数量，4:读取到的内存位置

        pusha

        mov ah, %1   ; 驱动（Drive），暂时没有使用
        mov bx, %2   ; LBA值，从0开始
        mov cl, %3   ; 读取扇区数量
        mov di, %4   ; 读取到的位置
        call read_sector_lba

        popa

%endmacro

[BITS 16]
[ORG 0x7c00]

    xor ax, ax
    mov ds, ax
    mov es, ax
    mov sp, 0x9000

    call clear_screen
    PrintString msg, msg_len
    call newline

    LoadSector 0, 1, 1, 0x7e00    ; 将启动磁盘的第二个扇区加载到内存位置0x7e00

    PrintString second_sector_msg, second_sector_msg_len

hang:
    jmp hang

%include "../libs/screen.asm"
%include "../libs/disk.asm"

msg db 'Read disk sector in LBA mode.'
msg_len equ $ - msg

    times 510-($-$$) db 0
    db 0x55
    db 0xAA

;=============================
; 第二个扇区

second_sector_msg:
    db 'This message is from second sector, Load Success!'
second_sector_msg_len equ $ - second_sector_msg

    times 1024-($-$$) db 0