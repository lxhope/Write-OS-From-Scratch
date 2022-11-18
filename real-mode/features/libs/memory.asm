; ==================================================================
; 内存探测功能模块，使用BIOS
; 功能号：INT 0x15, EAX=0xE820：
; 
; 参考：
;    https://wiki.osdev.org/Detecting_Memory_(x86)
;    http://www.ctyme.com/intr/rb-1741.htm
; ==================================================================

; ------------------------------------------------------------------
; detect_memory_e820 -- Detect memory map with BIOS INT 0x15, eax=E820
; 检测内存映射
; IN:
;   ES:DI = 存储缓冲区地址
; OUT:
;   BP = 条目数量

detect_memory_e820:
    pushf

    xor ebx, ebx      ; ebx must be 0 to start
    xor bp, bp        ; keep en entry count in bp
    mov edx, 0x0534D4150 ; Place "SMAP" into edx
    mov eax, 0xE820
    mov [es:di + 20], dword 1  ; force a valid ACPI 3.X entry
    mov ecx, 24
    int 0x15
    jc .failed       ; 如果失败会设置进位标志（carry flag）
    
.e820_loop:
    inc bp
    add di, 24
    mov eax, 0xE820
    mov [es:di + 20], dword 1
    int 0x15
    jc .failed
    test ebx, ebx
    jne .e820_loop

.failed:
    popf
    ret