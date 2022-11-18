; memory-demo.asm
; 内存检测示例

%include "../macros/screen.asm"

%macro DetectMemory 1 ; 检测内存，参数为条目存放地址

        ;pusha

        mov di, %1  ; 加载到内存的位置

        call detect_memory_e820

        ;popa

%endmacro


%macro PrintMemoryMap 1 ; 显示内存映射，1:内存映射存储基址

    pushf
    std         ; 从高字节到低字节
    
    mov bx, %1

%%loop:
    mov si, bx
    add si, 7              ; 显示基址
    mov cx, 8
    call print_memory
    PrintChar ' '
    add si, 8              ; 显示长度
    mov cx, 8
    call print_memory
    PrintChar ' '
    add si, 4              ; 显示类型
    mov cx, 4
    call print_memory
    add bx, 24             ; 移动到下一个条目
    call newline
    dec bp                 ; 计数减1
    test bp, bp
    jnz %%loop

    popf

%endmacro


%define MEMORY_MAP_BASE 0x8000

[BITS 16]
[ORG 0x7c00]

    xor ax, ax
    mov ds, ax
    mov es, ax
    mov sp, 0x9000

    call clear_screen
    
    DetectMemory MEMORY_MAP_BASE

    PrintMemoryMap MEMORY_MAP_BASE

hang:
    jmp hang

%include "../libs/screen.asm"
%include "../libs/memory.asm"
%include "../libs/misc.asm"
%include "../libs/debug.asm"

    times 510-($-$$) db 0
    db 0x55
    db 0xAA