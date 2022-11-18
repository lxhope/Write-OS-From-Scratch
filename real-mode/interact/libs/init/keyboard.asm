; PS/2键盘设置功能模块
; PS/2控制器端口
;    0x60: 数据端口
;    0x64: 状态/命令端口
; 参考：
;    https://wiki.osdev.org/%228042%22_PS/2_Controller
;    https://wiki.osdev.org/Keyboard
;    https://www.scs.stanford.edu/10wi-cs140/pintos/specs/kbd/scancodes-10.html
;    https://www.scs.stanford.edu/10wi-cs140/pintos/specs/kbd/scancodes-9.html

; ------------------------------------------------------------------
; disable_keyboard_translation -- Disable keyboard scan code translation
; IN: Nothing
; OUT: Nothing
;
disable_keyboard_translation:
    cli
    pusha

.check_write_status:   ; 检查写（输入）状态（位1，值为0代表已准备好）
    in al, 0x64
    test al, 0x02
    jnz .check_write_status

    mov al, 0x20       ; 读取键盘控制器命令
    out 0x64, al

    in al, 0x60        ; 进行读取
    mov bl, al         ; 备份

    mov al, 0x60       ; 写入键盘控制器命令
    out 0x64, al

    mov al, bl
    and al, 10111111b  ; 将转换位（位6）清除
    out 0x60, al       ; 进行写入

    popa
    sti
    ret

; ------------------------------------------------------------------
; get_keyboard_scan_code -- Get PS/2 keyboard scan code
; IN: BX = count
; OUT: Nothing
;

get_keyboard_scan_code:
    cli

.check_write_status:   ; 检查写（输入）状态（位1，值为0代表已准备好）
    in al, 0x64
    test al, 0x02
    jnz .check_write_status

    mov al, 0x20       ; 读取键盘控制器命令
    out 0x64, al

    in al, 0x60        ; 进行读取
    mov bl, al         ; 备份

    mov al, 0x60       ; 写入键盘控制器命令
    out 0x64, al

    mov al, bl
    and al, 10111111b  ; 将转换位（位6）清除
    out 0x60, al       ; 进行写入

    mov al, 0x20       ; 读取键盘控制器命令
    out 0x64, al

.check_read_status:    ; 检查读（输出）状态（位0，值为1代表已准备好）
    in al, 0x64
    test al, 0x01
    jz .check_read_status

    in al, 0x60
    call binary_to_hex

    ; 显示AX中的内容
    mov bx, ax
    shr ax, 8
    mov ah, 0x0F
    call print_char
    mov al, bl
    call print_char

    sti
    ret

; ------------------------------------------------------------------
; set_keyboard_scan_code -- Set PIT channel 0 reload count
; IN: BX = count
; OUT: Nothing
;