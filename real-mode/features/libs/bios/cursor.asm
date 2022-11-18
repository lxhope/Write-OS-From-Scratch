; ==================================================================
; BIOS光标功能模块
; 功能编号：0x10
; 子功能：
;   0x01: 启用/禁用光标
;   0x02: 移动光标
;   0x03: 获取光标位置
;
; 参考：https://www.stanislavs.org/helppc/int_10.html
; ==================================================================


; ------------------------------------------------------------------
; bios_enable_cursor -- Enable the cursor in text mode
; IN: Nothing; OUT: Nothing (registers preserved)

bios_enable_cursor:
    pusha

    mov ah, 0x01
    mov ch, 6
    mov cl, 7
    int 0x10

    popa
    ret

; ------------------------------------------------------------------
; bios_diable_cursor -- Disable the cursor in text mode
; IN: Nothing; OUT: Nothing (registers preserved)

bios_disable_cursor:
    pusha

    mov ah, 0x01
    mov ch, 0x3F
    int 0x10

    popa
    ret

; ------------------------------------------------------------------
; bios_move_cursor -- Moves cursor in text mode
; IN: DH, DL = row, column; OUT: Nothing (registers preserved)

bios_move_cursor:
    pusha

    mov ah, 0x02
    mov bh, 0
    int 0x10

    popa
    ret

; ------------------------------------------------------------------
; bios_get_cursor_pos -- Get cursor position in text mode
; IN: Nothing; OUT: DH, DL = row, column;

bios_get_cursor_pos:
    pusha

    mov ah, 0x03
    mov bh, 0
    int 0x10

    mov [.tmp], dx
	popa
	mov dx, [.tmp]
	ret

	.tmp dw 0