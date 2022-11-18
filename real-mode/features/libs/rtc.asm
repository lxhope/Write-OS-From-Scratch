; ==================================================================
; 实时时钟（Real-Time Clock）读写功能模块
; RTC地址：
;    命令端口：0x70
;    数据端口：0x71
; 子功能：
;
; 参考：https://wiki.osdev.org/CMOS#Getting_Current_Date_and_Time_from_RTC
; ==================================================================

%ifndef FEATURE_LIBS_RTC_FUNCS   ; 使该文件可以被重复引入
    %define FEATURE_LIBS_RTC_FUNCS 


RTC_CMD_PORT  equ 0x70     ; RTC命令端口
RTC_DATA_PORT equ 0x71     ; RTC数据端口

RTC_SECOND_REGISTER  equ 0x0  ; 秒数寄存器
RTC_MINUTE_REGISTER  equ 0x02 ; 分钟寄存器
RTC_HOUR_REGISTER    equ 0x04 ; 小时寄存器
RTC_DAY_OF_WEEK_REGISTER equ 0x06 ; RTC day of week
RTC_DAY_OF_MONTH_REGISTER equ 0x07 ; RTC day of month
RTC_MONTH_REGISTER   equ 0x08 ; 月份寄存器
RTC_YEAR_REGISTER    equ 0x09 ; 年份寄存器

%macro  ReadRTC 2  ; 读取RTC寄存器，参数1：读取的寄存器，参数2：读取到的位置（内存地址）
    mov al, %1
    out RTC_CMD_PORT, al
    in al, RTC_DATA_PORT
    mov [%2], al
%endmacro

; ------------------------------------------------------------------
; read_date_time -- Read date and time in CMOS
; IN:
;   ES:DI = 时间数据结构存放的入口，数据默认为BCD格式
; OUT:
;
read_date_time:
    pusha

    ReadRTC RTC_YEAR_REGISTER, es:di     ; 读取年
    ReadRTC RTC_MONTH_REGISTER, es:di+1  ; 读取月
    ReadRTC RTC_DAY_OF_MONTH_REGISTER, es:di+2  ; 读取天
    ReadRTC RTC_HOUR_REGISTER, es:di+3   ; 读取小时
    ReadRTC RTC_MINUTE_REGISTER, es:di+4 ; 读取分钟
    ReadRTC RTC_SECOND_REGISTER, es:di+5 ; 读取秒

   popa
   ret

; ------------------------------------------------------------------
; read_rtc_second -- Read second data in RTC
; IN:
;   Nothing
; OUT:
;   AL = second in BCD code
read_rtc_second:

    mov al, RTC_SECOND_REGISTER
    out RTC_CMD_PORT, al
    in al, RTC_DATA_PORT

    ret


%endif