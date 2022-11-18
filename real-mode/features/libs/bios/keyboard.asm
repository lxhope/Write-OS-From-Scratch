; ==================================================================
; BIOS键盘功能模块
; 功能编号：0x16
; 子功能：
;   0x00: 等待键盘输入
;
; 参考：https://www.stanislavs.org/helppc/int_16.html
; ==================================================================

; ------------------------------------------------------------------
; bios_blocked_keyboard_input -- Wait for keystroke and read
; IN: Nothing; 
; OUT:
;   AH = keyboard scan code
;   AL = ASCII character or zero if special function key

bios_blocked_keyboard_input:

    mov ah, 0x0
    int 0x16

    ret