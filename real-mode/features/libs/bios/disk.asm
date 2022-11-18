; ==================================================================
; BIOS磁盘读写功能模块
; 功能编号：0x13
; 子功能：
;   0x02: 读取磁盘扇区（CHS方式）
;   0x03: 写入磁盘扇区（CHS方式）
;   0x42: 以LBA方式读取扇区
;   0x43: 以LBA方式写入扇区
;
; 参考：https://www.stanislavs.org/helppc/int_13.html
; ==================================================================


; ------------------------------------------------------------------
; bios_read_sector -- Read sectors using CHS way
; AH = 0x02
; IN: 
;   AL = number of sectors to read	(1-128 dec.)
;   CH = track/cylinder number  (0-1023 dec., see below)
;   CL = sector number  (1-17 dec.)
;   DH = head number  (0-15 dec.)
;   DL = drive number (0=A:, 1=2nd floppy, 80h=drive 0, 81h=drive 1)
;   ES:BX = pointer to buffer
; OUT: 
;   AH = status  (see INT 13,STATUS)
;   AL = number of sectors read
;   CF = 0 if successful
;      = 1 if error
; 参考：https://www.stanislavs.org/helppc/int_13-2.html

bios_read_sector:
    
    mov ah, 0x02
    int 0x13

    ret

; ------------------------------------------------------------------
; bios_write_sector -- Write sectors using CHS way
; AH = 0x03
; IN:
;   AL = number of sectors to write  (1-128 dec.)
;   CH = track/cylinder number  (0-1023 dec.)
;   CL = sector number  (1-17 dec., see below)
;   DH = head number  (0-15 dec.)
;   DL = drive number (0=A:, 1=2nd floppy, 80h=drive 0, 81h=drive 1)
;   ES:BX = pointer to buffer
; OUT:
;   AH = 0 if CF=0; otherwise disk status  (see INT 13,STATUS)
;   AL = number of sectors written
;   CF = 0 if successful
;      = 1 if error
; 参考：https://www.stanislavs.org/helppc/int_13-3.html

bios_write_sector:

    mov ah, 0x03
    int 0x13

    ret

; ------------------------------------------------------------------
; bios_lba_read_sector -- Read sectors using LBA way
; AH = 0x42
; IN: 
;   DL = drive number (0=A:, 1=2nd floppy, 80h=drive 0, 81h=drive 1)
;   SI = Disk Address Packet in memory
; OUT: 
;   AH = status  (see INT 13,STATUS)
;   AL = number of sectors read
;   CF = 0 if successful
;      = 1 if error
; 参考：https://wiki.osdev.org/ATA_in_x86_RealMode_(BIOS)#LBA_in_Extended_Mode

bios_lba_read_sector:
    
    mov ah, 0x42
    int 0x13

    ret

; ------------------------------------------------------------------
; bios_lba_write_sector -- Read sectors using LBA way
; AH = 0x42
; IN: 
;   DL = drive number (0=A:, 1=2nd floppy, 80h=drive 0, 81h=drive 1)
;   SI = Disk Address Packet in memory
; OUT: 
;   AH = status  (see INT 13,STATUS)
;   AL = number of sectors read
;   CF = 0 if successful
;      = 1 if error
; 参考：https://wiki.osdev.org/ATA_in_x86_RealMode_(BIOS)#LBA_in_Extended_Mode

bios_lba_write_sector:
    
    mov ah, 0x43
    int 0x13

    ret