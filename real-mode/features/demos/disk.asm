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

%macro LoadSector 4 ; 加载扇区

        pusha

        ;mov bl, %2  ; 扇区索引

        ;mov cl, %3  ; 加载扇区数量

        mov ax, %4
        mov di, ax  ; 加载到内存的位置

        call ata_chs_read

        popa

%endmacro

[BITS 16]
[ORG 0x7c00]

    mov ax, 0
    mov ds, ax

    call clear_screen
    PrintString msg, msg_len
    call newline

    mov ebx, 2
    mov ch, 1
    mov edi, 0x7e00
    call ata_chs_read
    PrintString second_sector_msg, second_sector_msg_len

hang:
    jmp hang

%include "../libs/screen.asm"
%include "../libs/disk.asm"

msg db 'Hello World!'
msg_len equ $ - msg

    times 510-($-$$) db 0
    db 0x55
    db 0xAA

;=============================
; 第二个扇区

second_sector_msg:
    db 'The second sector, Load Success!'
second_sector_msg_len equ $ - second_sector_msg

    times 1024-($-$$) db 0