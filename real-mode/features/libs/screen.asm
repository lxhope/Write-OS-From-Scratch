; ==================================================================
; 文本模式显示功能模块
; 显存地址：0xb8000
; 子功能：
; 
;
; 参考：
; ==================================================================


%define VIDEO_MEMORY_SEG 0xb800   ; 显存段地址
%define VIDEO_MEMORY_BASE 0xb8000 ; 显存基地址
%define EMPTY_CHAR 0x0f00            ; 空字符
%define VIDEO_ROW_COUNT 25        ; 视频内存行数
%define VIDEO_COLUMN_COUNT 80     ; 视频内存列数

Screen:
    .Offsets dw 0

; ------------------------------------------------------------------
; clear_screen -- Clear screen
; IN: Nothing; OUT: Nothing (registers preserved)
; 参考：https://www.stanislavs.org/helppc/int_10-6.html

clear_screen:
    pusha              ; Push AX, CX, DX, BX, original SP, BP, SI, and DI.
    push es            ; 由于本函数会修改es段寄存器，也需要保存

    mov ax, VIDEO_MEMORY_SEG
    mov es, ax
    xor di, di         ; 将di设置为0，等同“mov di, 0”
    mov ax, EMPTY_CHAR
    mov cx, VIDEO_ROW_COUNT * VIDEO_COLUMN_COUNT
    rep stosw          ; 使用 AX 填写位于 [ES:(E)DI] 的 (E)CX 个字

    mov ax, 0          ; 将光标及显示位置重置到左上角
    call move_cursor_by_offset
    mov [Screen.Offsets], ax

    pop es
    popa
    ret

; ------------------------------------------------------------------
; print_char -- Print a character on screen
; IN: AL = character, AH = attribute
; OUT: Nothing (registers preserved)

print_char:
    pusha
    pushf
    push es
    
    ; 设置显存位置
    mov bx, VIDEO_MEMORY_SEG 
    mov es, bx
    mov bx, [Screen.Offsets]
    shl bx, 1           ; 将BX中的值乘以2，因为每个显示位置是两个字节
    mov di, bx          ; 真正的显示位置

    cld                 ; Clear Direction flag
    stosw               ; 将AX中内容存储到ES:DI内存位置处

    ; 将光标与显示位置进行相应的移动
    mov ax, [Screen.Offsets]
    add ax, 1
    call move_cursor_by_offset
    mov [Screen.Offsets], ax

    pop es
    popf
    popa
    ret


; ------------------------------------------------------------------
; print_string -- Print a string on screen
; IN: DS:SI = pointer to string, CX = length of string (ignoring attributes); 
; OUT: Nothing (registers preserved)

print_string:
    pusha
    push es            ; 由于本函数会修改es段寄存器，也需要保存

    mov bx, cx   ; 备份长度，用于移动显示位置

    mov ax, VIDEO_MEMORY_SEG
    mov es, ax
    mov ax, [Screen.Offsets]
    shl ax, 1           ; 将BX中的值乘以2，因为每个显示位置是两个字节
    mov di, ax          ; 真正的显示位置
_print_character:
    movsb               ; 从源地址DS:SI复制一个字节到目的地址ES:DI，由于源字符串是以字节为单位，目标字符串以字为单位，无法使用rep前缀
    inc di
    loop _print_character ; 以cx为计数寄存器循环，直到cx为0

    ; 将光标与显示位置进行相应的移动
    mov ax, [Screen.Offsets]
    add ax, bx
    call move_cursor_by_offset
    mov [Screen.Offsets], ax

    pop es
    popa
    ret

; ------------------------------------------------------------------
; newline --New line on screen
; IN: DS:SI = pointer to string, CX = length of string (ignoring attributes); 
; OUT: Nothing (registers preserved)

newline:
    pusha

    mov ax, [Screen.Offsets]
    mov dx, 0
    mov bx, VIDEO_COLUMN_COUNT
    div bx     ; Unsigned divide DX:AX by r/m16, with result stored in AX := Quotient, DX := Remainder.
    inc ax     ; 此时在ax中存的是行数，加1代表增加一行
    mul bx     ; Unsigned multiply (DX:AX := AX ∗ r/m16).
    mov [Screen.Offsets], ax
    call move_cursor_by_offset

    popa
    ret

; ------------------------------------------------------------------
; move_cursor -- Move the cursor in text mode
; IN: ax = offset; OUT: Nothing (registers preserved)

move_cursor_by_offset:
    pusha

    mov bx, ax

    mov dx, 0x03D4  ; 选择命令端口
    mov al, 0x0F    ; lower byte，寄存器编号
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