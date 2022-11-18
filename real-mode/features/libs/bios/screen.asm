; ==================================================================
; BIOS文本模式显示功能模块
; 功能编号：0x10
; 子功能：
;   0x06: 向上翻页，可以用来清空屏幕
;   0x0e: 打印一个字符
;   0x13: 打印一个字符串
;
; 参考：https://www.stanislavs.org/helppc/int_10.html
; ==================================================================

; ------------------------------------------------------------------
; bios_clear_screen -- Clear screen
; IN: Nothing; OUT: Nothing (registers preserved)
; 参考：https://www.stanislavs.org/helppc/int_10-6.html

bios_clear_screen:
    pusha

    mov dx, 0       ; Position cursor at top-left
    call bios_move_cursor

    mov ah, 06      ; clear screen instruction
    mov al, 0       ; number of lines to scroll, previous lines are
	                ;  blanked, if 0 or AL > screen size, window is blanked
    mov bh, 0x0f	; display attribute - colors, 前4位为背景颜色，后4位为字体颜色，0 = 白色，1 = 黑色
    mov ch, 0       ; row of upper left corner of scroll window
    mov cl, 0       ; column of upper left corner of scroll window
    mov dh, 24      ; row of lower right corner of scroll window
    mov dl, 79      ; column of lower right corner of scroll window
    int 0x10

    popa
    ret

; ------------------------------------------------------------------
; bios_print_char -- Print a charactor on screen
; IN: AL = character; OUT: Nothing (registers preserved)
; 参考：https://www.stanislavs.org/helppc/int_10-6.html

bios_print_char:
    push ax

    mov ah, 0x0e
    int 0x10

    pop ax
    ret

; ------------------------------------------------------------------
; bios_print_string -- Print a string on screen
; IN: ES:BP = pointer to string, CX = length of string (ignoring attributes); 
; OUT: Nothing (registers preserved)
; 参考：https://www.stanislavs.org/helppc/int_10-13.html

bios_print_string:
    push ax

    call bios_get_cursor_pos ; get cursor position, store in dx

    mov ah, 0x13
    mov al, 1     ; string is chars only, attribute in BL, cursor moved
    mov bh, 0     ; current page
    mov bl, 0x0f  ; attribute, upper 4 bits = foreground color, lower 4 bits = background color
    int 0x10

    pop ax
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