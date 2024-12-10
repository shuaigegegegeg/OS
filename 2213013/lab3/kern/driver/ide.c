#include <assert.h>
#include <defs.h>
#include <fs.h>
#include <ide.h>
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

// 函数定义，目前函数体为空，推测是用于初始化IDE相关的设备或资源等，后续可能会添加具体的初始化代码，比如配置寄存器等操作
void ide_init(void) {}

// 定义最大支持的IDE设备数量为2，可能用于限制对IDE设备操作时的索引范围，避免访问不存在的设备
#define MAX_IDE 2
// 定义磁盘的最大扇区数量为56，用于表示磁盘在这个模拟环境下的容量规模（以扇区数量衡量）
#define MAX_DISK_NSECS 56
// 声明一个静态的字符数组ide，用于模拟磁盘的数据存储区域，其大小根据扇区大小（SECTSIZE，后续在其他头文件中定义为512字节）和最大扇区数量来确定
// 相当于在内核的静态存储区划分出一块内存来模拟“硬盘”
static char ide[MAX_DISK_NSECS * SECTSIZE];

// 函数用于验证给定的IDE设备编号是否有效，通过比较设备编号是否小于最大支持的IDE设备数量（MAX_IDE）来判断
// 返回值为布尔类型，小于则返回true，表示设备编号有效，否则返回false
bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }

// 函数用于获取指定IDE设备的大小（以扇区数量表示），目前只是简单返回预定义的最大扇区数量（MAX_DISK_NSECS）
// 实际可能需要根据不同设备的实际情况进行更灵活的调整，比如不同设备有不同容量时查询对应实际容量
size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }

// 函数用于模拟从IDE设备读取扇区数据
// 参数说明：
// - ideno: 表示IDE设备编号，用于指定从哪个IDE设备读取数据，这里虽然理论上可以支持多设备，但实际目前只有一块“磁盘”，这个参数暂时没用到
// - secno: 表示要读取的起始扇区号，确定从磁盘的哪个位置开始读取
// - dst: 是一个指向目标内存地址的指针，用于存放从磁盘读取到的数据，调用者需要确保这个指针指向的内存空间足够存放要读取的数据量
// - nsecs: 表示要读取的扇区数量，即读取操作的数据长度（以扇区为单位）
int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    // 计算读取数据在模拟磁盘数据缓存数组（ide）中的起始偏移量，通过扇区号乘以扇区大小得到
    int iobase = secno * SECTSIZE;
    // 使用memcpy函数将从ide数组中以iobase为起始位置、长度为nsecs * SECTSIZE的数据复制到dst所指向的目标内存地址中
    // 从而实现模拟的磁盘扇区数据读取操作，这里其实就是在内存里进行数据复制来模拟磁盘读取
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
    // 返回0表示读取操作正常完成，实际更完善的代码可能会根据不同错误情况返回不同错误码来反馈读取中的问题
    return 0;
}

// 函数用于模拟向IDE设备写入扇区数据
// 参数说明：
// - ideno: 表示要写入的IDE设备编号
// - secno: 表示写入数据的起始扇区号，确定往磁盘的哪个位置开始写入
// - src: 是一个指向源内存地址的指针，这个内存地址存放着要写入磁盘的数据，调用者需要保证这个内存区域的数据在写入过程中保持有效
// - nsecs: 表示要写入的扇区数量，即写入操作的数据长度（以扇区为单位）
int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    // 计算在模拟磁盘数据缓存数组（ide）中写入数据的起始偏移量，计算方式与读取函数中一样，通过扇区号乘以扇区大小得到
    int iobase = secno * SECTSIZE;
    // 使用memcpy函数将src所指向的内存区域中长度为nsecs * SECTSIZE的数据复制到ide数组以iobase为起始的位置中，完成模拟的磁盘扇区数据写入操作
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
    // 返回0表示写入操作顺利结束，更完善的代码可能会根据实际错误情况返回不同错误码来反馈写入中的问题
    return 0;
}