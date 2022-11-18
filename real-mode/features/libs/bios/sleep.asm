; ==================================================================
; BIOS等待功能模块
; 功能编号：0x15
; 子功能：
;   0x86: 等待一段时间
;
; 参考：https://www.stanislavs.org/helppc/int_15-86.html
; ==================================================================

; ------------------------------------------------------------------
; bios_wait -- Elapsed Time Wait (AT and PS/2)
; IN: CX,DX = number of microseconds to wait (976 æs resolution);
; OUT: 
;   CF = set if error (PC,PCjr,XT)
;	   = set if wait in progress
;	   = clear if successful wait
;	AH = 80h for PC and PCjr
;	   = 86h for XT

bios_wait:
    push ax

    mov ah, 0x86
    int 0x15

    pop ax
    ret