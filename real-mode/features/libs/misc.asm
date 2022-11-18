; ==================================================================
; 一些常用的功能模块，比如整数转ASCII、BCD转ASCII等
; 
; 参考：
; ==================================================================

%ifndef FEATURE_LIBS_MISC_FUNCS   ; 使该文件可以被重复引入
    %define FEATURE_LIBS_MISC_FUNCS 


; ------------------------------------------------------------------
; bcd_to_ascii -- Convert BCD numbers to ASCII characters.
; IN: AL = BCD number; OUT: AX = ASCII character
; 参考：

bcd_to_ascii:

    mov ah, al   ; 复制AL，保存高4位BCD值
    and al, 0xF  ; 保留AL中的低4位，即低位的BCD值
    add al, '0'  ; 将4位的BCD值加上ASCII中数字区的偏移，即转换为了ASCII字符

    shr ah, 4    ; 将高位BCD值移到AH低位
    add ah, '0'  ; 同上面AL操作

    ret

; ------------------------------------------------------------------
; bcd_to_ascii_str -- Batch convert BCD numbers to ASCII characters.
; IN: DS:SI = BCD data entry, CX = count;
; OUT: ES:DI = ASCII characters data entry
; 参考：

bcd_to_ascii_str:

.loop:
    lodsb
    call bcd_to_ascii
    rol ax, 8    ; 由于x86是小端序，存储时需要将字符位置调换
    stosw
    loop .loop

    ret

; ------------------------------------------------------------------
; binary_to_hex -- Convert binary byte to hexdecimal in ASCII code.
; IN: AL = Binary data
; OUT: AX = Hexdecimal ASCII characters
; 参考：

binary_to_hex:
    push bx

    mov bl, al
    and al, 0x0F      ; 取低4位
    add al, '0'      ; 转换为相应ASCII编码
    cmp al, '9'      ; 大于9还要加一个到字符‘A‘的偏移
    jle .high
    add al, 'A' - '9' - 1

.high:
    shr bl, 4        ; 取高4位
    add bl, '0'
    mov ah, bl
    cmp ah, '9'      ; 大于9还要加一个到字符‘A‘的偏移
    jle .quit
    add ah, 'A' - '9' - 1

.quit:
    pop bx
    ret


; ------------------------------------------------------------------
; binary_to_decimal_str -- Convert binary numbers to decimal string in ASCII code.
; IN: AX = Binary data
; OUT: ES:DI = Decimal string entry 
; 参考：

binary_to_decimal_str:
    pusha

    mov bx, 10       ; 被除数
    xor cx, cx       ; 将CX清零，用于记录十进制数字的长度

.div_loop:
    xor dx, dx       ; 将DX清零，必须在div之前设置，即必须放在循环中，放在循环外（上面）会使循环无法停止，因为div的余数会放在该寄存器中
    div bx           ; Unsigned divide DX:AX by r/m16, with result stored in AX := Quotient, DX := Remainder.
    add dl, '0'      ; 将二进制值加上ASCII中数字区的偏移，即转换为了ASCII字符
    push dx          ; 压入堆栈
    inc cx           ; 将十进制数字长度加1
    test ax, ax      ; 检测ax是否为0
    jnz .div_loop    ; 循环直到AX为0

.store_loop:
    pop ax
    stosb            ; 将AL中的值存储在ES:DI内存位置，并将DI递增1
    loop .store_loop ; 循环直到CX为0

    popa
    ret

%endif