; 与中断有关的宏

%ifndef INTERACT_INTERRUPT_MACROS   ; 使该文件可以被重复引入
    %define INTERACT_INTERRUPT_MACROS

%macro SetupIntHandler 2  ; 设置中断处理程序，2个参数，1:中断向量号，2:中断处理程序入口

    cli                   ; 关闭中断
    pusha                 ; 压入所有通用寄存器
    push gs

    mov bx, %1            ; 中断号
    shl bx, 2             ; 乘以4，每个中断配置条目占4个字节
    xor ax, ax
    mov gs, ax            ; 实地址模式下中断描述符表位于内存0x0～0x3ff的地址空间
    mov [gs:bx], word %2  ; 设置上处理程序
    mov [gs:bx+2], ds     ; 段

    pop gs
    popa
    sti

%endmacro

%endif