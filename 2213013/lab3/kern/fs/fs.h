// 防止头文件重复包含的宏定义，如果没有定义过__KERN_FS_FS_H__，则执行下面的代码块，直到遇到#endif
#ifndef __KERN_FS_FS_H__
#define __KERN_FS_FS_H__

// 包含内存管理单元（MMU）相关的头文件，可能会用到与内存映射等相关的定义或函数
#include <mmu.h>

// 定义磁盘扇区大小为512字节，这是常见的磁盘扇区标准大小，在后续模拟磁盘IO操作时会依据这个大小进行数据处理
#define SECTSIZE            512
// 计算一页内存需要几个磁盘扇区来存储，通过将页面大小（PGSIZE，应该在其他地方定义了具体值）除以磁盘扇区大小（SECTSIZE）得到
#define PAGE_NSECT          (PGSIZE / SECTSIZE) //8

// 定义交换设备编号为1，用于在后续操作中指定使用哪个设备作为交换区（这里的交换区其实就是模拟的“硬盘”）
#define SWAP_DEV_NO         1

// 结束条件编译指令，与#ifndef对应，表示__KERN_FS_FS_H__这个宏已经定义过了，后续再次包含这个头文件时，里面的代码就不会重复执行了
#endif /*!__KERN_FS_FS_H__ */