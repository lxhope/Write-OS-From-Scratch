; 与显示有关的宏

%ifndef FEATURE_SCREEN_MACROS   ; 使该文件可以被重复引入
    %define FEATURE_SCREEN_MACROS

; 语法参考：https://www.nasm.us/xdoc/2.15.05/html/nasmdoc4.html#section-4.3
%macro  PrintString 2  ; 2个参数，第一个是字符串的首个字母位置，第二个为字符串长度

        push si
        push cx

        mov ax, %1   ; %1代表第一个参数
        mov si, ax
        mov cx, %2   ; %2代表第二个参数
        call print_string

        pop cx
        pop si

%endmacro


; 语法参考：https://www.nasm.us/xdoc/2.15.05/html/nasmdoc4.html#section-4.3.5
%macro  PrintChar 1-2 0x0F ; 1或2个参数，1:字符ASCII，必需；2:属性, 可选，默认黑色背景白色字体，即0x0F

        push ax

        mov al, %1   ; %1代表第一个参数
        mov ah, %2   ; %2代表第二个参数
        call print_char

        pop ax

%endmacro

%endif 