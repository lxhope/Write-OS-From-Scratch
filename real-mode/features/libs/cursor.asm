; ==================================================================
; 光标功能模块，非BIOS实现
; 功能端口：
;    命令端口：0x3D4
;    数据端口：0x3D5
;
; 参考：https://zhuanlan.zhihu.com/p/145572718
; ==================================================================


; ------------------------------------------------------------------
; enable_cursor -- Enable the cursor in text mode
; IN: Nothing; OUT: Nothing (registers preserved)

enable_cursor:
    pushf
    push eax
    push edx

    mov dx, 0x3D4
    mov al, 0xA    ; low cursor shape register
    out dx, al

    inc dx
    in al, dx
    and al, 0xC0
    out dx, al

    mov dx, 0x3D4
    mov al, 0x0B
    out dx, al

    inc dx
    in al, dx
    and al, 0xE0
    out dx, al

    pop edx
    pop eax
    popf
    ret

; ------------------------------------------------------------------
; disable_cursor -- Disable the cursor in text mode
; IN: Nothing; OUT: Nothing (registers preserved)

disable_cursor:
    pushf
    push eax
    push edx

    mov dx, 0x3D4
    mov al, 0xA    ; low cursor shape register
    out dx, al

    inc dx         ; port 0x3D5
    mov al, 0x20   ; bits 6-7 unused, bit 5 disables the cursor, bits 0-4 control the cursor shape
    out dx, al

    pop edx
    pop eax
    popf
    ret

; ------------------------------------------------------------------
; move_cursor -- Move the cursor in text mode
; IN: ax, bx = row, column; OUT: Nothing (registers preserved)

VGA.Width equ 80
move_cursor:
    pusha

    mov dl, VGA.Width
    mul dl
    add bx, ax

    mov dx, 0x03D4
    mov al, 0x0F    ; lower byte
    out dx, al

    inc dl
    mov al, bl
    out dx, al

    dec dl
    mov al, 0x0E    ; upper byte
    out dx, al

    inc dl
    mov al, bh
    out dx, al

    popa
    ret

; ------------------------------------------------------------------
; get_cursor_pos -- Get cursor position in text mode
; IN: Nothing; 
; OUT: ax = pos = y * VGA_WIDTH + x

get_cursor_pos:
    pusha

    mov dx, 0x03D4
    mov al, 0x0E    ; upper byte
    out dx, al

    inc dl
    in al, dx
    shl ax, 8

    dec dl
    mov al, 0x0F    ; lower byte
    out dx, al

    inc dl
    in al, dx

    mov [.tmp], ax
	popa
	mov ax, [.tmp]
    ret

    .tmp dw 0