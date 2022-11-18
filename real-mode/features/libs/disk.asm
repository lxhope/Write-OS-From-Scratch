; ==================================================================
; 磁盘读写功能模块，ATA PIO模式
; ATA端口：
;    主：0x1f0 ～ 0x1f7
;    从：0x
; 子功能：
; 
;
; 参考：https://wiki.osdev.org/ATA_read/write_sectors
;    https://forum.osdev.org/viewtopic.php?t=12268
;    https://forum.osdev.org/viewtopic.php?f=1&t=33515
; ==================================================================

; ------------------------------------------------------------------
; read_sector_chs -- Read sectors in CHS mode
; IN:
;   AH = 驱动
;   AL = 柱头，只有低4位有效，高4位会清零
;   BX = 柱面，两个字节，BH：高字节，BL：低字节
;   CH = 扇区号
;   CL = 读取扇区数量
;   ES:DI = 存储缓冲区地址
; OUT:
;

read_sector_chs:

    call ata_disk_wait

    mov dx, 0x1f6       ; 驱动/磁头端口
    and al, 0x0F        ; 保留低4位
    or al, 0xA0         ; 位7、5固定为1
    out dx, al

    mov dx, 0x1f2       ; 扇区数量端口
    mov al, cl          ; CL中应包含读取扇区数量
    out dx, al

    mov dx, 0x1f3       ; 扇区编号端口
    mov al, ch          ; CH中应包含读取扇区起始编号
    out dx, al

    mov dx, 0x1f4       ; 柱面低字节端口
    mov al, bl          ; BL中应包含柱面低字节
    out dx, al

    mov dx, 0x1f5       ; 柱面高字节端口
    mov al, bh          ; BH中应包含柱面高字节
    out dx, al

    mov dx, 0x1f7       ; 命令端口
    mov al, 0x20        ; 带重试读
    out dx, al

.still_going:
    in al, dx
    test al, 8
    jz .still_going

    mov ax, 512/2
    xor ch, ch        ; 将CX高位清零，避免影响计算，只保留CL中的读取扇区数量
    mul cx            ; 无符号乘 (DX:AX := AX * CX).
    mov cx, ax        ; CX中包含读取的次数，由于忽略了DX中的值，此处还需补全
    mov dx, 0x1f0     ; 数据端口
    rep insw          ; 从DX指定的端口读取一个字到ES:DI指定的内存地址，rep代表重复CX指定的次数

    ret


; ------------------------------------------------------------------
; write_sector_chs -- Write sectors in CHS mode
; 与读磁盘唯一不同的是写入命令端口的值为0x30，使用outsw替换insw
; IN:
;   AH = 驱动
;   AL = 柱头，只有低4位有效，高4位会清零
;   BX = 柱面，两个字节，BH：高字节，BL：低字节
;   CH = 扇区号
;   CL = 读取扇区数量
;   ES:DI = 存储缓冲区地址
; OUT:
;

write_sector_chs:
    
    call ata_disk_wait

    mov dx, 0x1f6       ; 驱动/磁头端口
    and al, 0x0F        ; 保留低4位
    or al, 0xA0         ; 位7、5固定为1
    out dx, al

    mov dx, 0x1f2       ; 扇区数量端口
    mov al, cl          ; CL中应包含读取扇区数量
    out dx, al

    mov dx, 0x1f3       ; 扇区编号端口
    mov al, ch          ; CH中应包含读取扇区起始编号
    out dx, al

    mov dx, 0x1f4       ; 柱面低字节端口
    mov al, bl          ; BL中应包含柱面低字节
    out dx, al

    mov dx, 0x1f5       ; 柱面高字节端口
    mov al, bh          ; BH中应包含柱面高字节
    out dx, al

    mov dx, 0x1f7       ; 命令端口
    mov al, 0x30        ; 带重试写。此处与读方法不同
    out dx, al

.still_going:
    in al, dx
    test al, 8
    jz .still_going

    mov ax, 512/2
    xor ch, ch        ; 将CX高位清零，避免影响计算，只保留CL中的读取扇区数量
    mul cx            ; 无符号乘 (DX:AX := AX * CX).
    mov cx, ax        ; CX中包含读取的次数，由于忽略了DX中的值，此处还需补全
    mov dx, 0x1f0     ; 数据端口
    rep outsw         ; outsw指令将ES:DI指定的内存地址的一个字内容写入DX指定的端口，rep代表重复CX指定的次数。此处与读方法不同

    ret


; ------------------------------------------------------------------
; read_sector_lba -- Read sectors in LBA mode
; IN:
;   AH = 驱动
;   BX = LBA位0-15，从0开始，即0代表第一个扇区
;   CL = 读取扇区数量
;   ES:DI = 存储缓冲区地址
; OUT:
;

read_sector_lba:

    call ata_disk_wait

    mov dx, 0x1f6       ; 驱动和LBA位24-27端口
    ;rol ax, 8           ; 先将ah与al互换位置
    ;and al, 0x0F        ; 保留低4位
    ;or al, 0xE0         ; 位7、5固定为1，位6=1代表LBA模式
    mov al, 0xe0
    out dx, al

    mov dx, 0x1f2       ; 扇区数量端口
    mov al, cl          ; CL中应包含读取扇区数量
    out dx, al

    mov dx, 0x1f3       ; LBA位0-7端口
    mov al, bl          ; LBA位0-7
    out dx, al

    mov dx, 0x1f4       ; LBA位8-15端口
    mov al, bh          ; LBA位8-15
    out dx, al

    mov dx, 0x1f5       ; LBA位16-23端口
    mov al, ah          ; LBA位16-23
    out dx, al

    mov dx, 0x1f7       ; 命令端口
    mov al, 0x20        ; 带重试读
    out dx, al

.still_going:
    in al, dx
    test al, 8
    jz .still_going

    mov ax, 512/2
    xor ch, ch        ; 将CX高位清零，避免影响计算，只保留CL中的读取扇区数量
    mul cx            ; 无符号乘 (DX:AX := AX * CX).
    mov cx, ax        ; CX中包含读取的次数，由于忽略了DX中的值，此处还需补全
    mov dx, 0x1f0     ; 数据端口
    rep insw          ; 从DX指定的端口读取一个字到ES:DI指定的内存地址，rep代表重复CX指定的次数

    ret


; ------------------------------------------------------------------
; write_sector_lba -- Write sectors in LBA mode
; IN:
;   AH = 驱动
;   BX = LBA位0-15，从0开始，即0代表第一个扇区
;   CL = 写入扇区数量
;   DS:SI = 存储缓冲区地址
; OUT:
;

write_sector_lba:

    call ata_disk_wait

    mov dx, 0x1f6       ; 驱动和LBA位24-27端口
    ;rol ax, 8           ; 先将ah与al互换位置
    ;and al, 0x0F        ; 保留低4位
    ;or al, 0xE0         ; 位7、5固定为1，位6=1代表LBA模式
    mov al, 0xe0
    out dx, al

    mov dx, 0x1f2       ; 扇区数量端口
    mov al, cl          ; CL中应包含读取扇区数量
    out dx, al

    mov dx, 0x1f3       ; LBA位0-7端口
    mov al, bl          ; LBA位0-7
    out dx, al

    mov dx, 0x1f4       ; LBA位8-15端口
    mov al, bh          ; LBA位8-15
    out dx, al

    mov dx, 0x1f5       ; LBA位16-23端口
    mov al, ah          ; LBA位16-23
    out dx, al

    mov dx, 0x1f7       ; 命令端口
    mov al, 0x30        ; 带重试写
    out dx, al

.still_going:
    in al, dx
    test al, 8
    jz .still_going

    mov ax, 512/2
    xor ch, ch        ; 将CX高位清零，避免影响计算，只保留CL中的读取扇区数量
    mul cx            ; 无符号乘 (DX:AX := AX * CX).
    mov cx, ax        ; CX中包含读取的次数，由于忽略了DX中的值，此处还需补全
    mov dx, 0x1f0     ; 数据端口
    rep outsw         ; 从DX指定的端口读取一个字到ES:DI指定的内存地址，rep代表重复CX指定的次数

    ret


; 参考：https://forum.osdev.org/viewtopic.php?f=1&t=33515
ata_drq_wait:
    pusha
    xor al, al
    mov dx, 01F7h
.loop:   
    in  al, dx
    test al, 008h
    jz .loop
.end:
    popa
    ret

ata_disk_wait:
    pusha
    xor ax, ax
    mov dx, 01F7h
.loop:
    in  al, dx
    and al, 0C0h
    cmp al, 040h
    jne .loop
.end:
    popa
    ret