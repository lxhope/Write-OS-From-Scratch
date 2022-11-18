## 注意
所有demo都必须在当前目录下编译，因为要引用libs文件夹中的文件，nasm编译时需要在包含引用库的目录下使用
如：nasm -f bin demos/bios/disk/disk_read.asm -o demo.bin

## 启动
qemu-system-x86_64 demo.bin
如果没有窗口系统（比如在服务器上）：
qemu-system-x86_64 -display curses demo.bin