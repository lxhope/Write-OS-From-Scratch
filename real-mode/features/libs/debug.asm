; ==================================================================
; 调试相关功能模块
; 子功能：
; ==================================================================


; ------------------------------------------------------------------
; print_register_16 -- Print content in 16 bit register
; IN:
;    AX = Two hex characters to print
; OUT:
;    Nothing
;------------------------------------------------------------------

print_register_16:


; ------------------------------------------------------------------
; print_memory -- Print content in memory
; IN:
;    DS:SI = Base address of memory
;    DF = Direction, 0 = From lower to upper, 1 = From upper to lower
;    CX = Byte length to print
; OUT:
;    Nothing
;------------------------------------------------------------------

print_memory:
    pusha

.loop:
    lodsb
    call binary_to_hex
    mov bx, ax
    mov ah, 0x0F
    mov al, bh
    call print_char
    mov al, bl
    call print_char
    loop .loop

    popa
    ret
