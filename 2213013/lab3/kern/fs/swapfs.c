// 包含交换相关的头文件，可能包含交换操作的一些结构体定义、函数原型等内容
#include <swap.h>
// 包含交换文件系统相关的头文件，也许定义了交换文件系统特有的一些数据结构、操作函数等
#include <swapfs.h>
// 包含内存管理单元（MMU）相关的头文件，用于处理内存相关操作，比如内存映射等
#include <mmu.h>
// 包含文件系统（fs）相关头文件，可能包含文件系统通用的操作函数原型等，用于和“硬盘”（模拟的）进行交互
#include <fs.h>
// 包含IDE相关头文件，用于调用之前在ide.c中定义的IDE设备操作函数，如读写扇区等函数
#include <ide.h>
// 包含物理内存管理（pmm）相关头文件，可能涉及物理内存分配等相关操作，虽然在这段代码中暂时没体现其具体用途，但可能在更完整的系统中有关联
#include <pmm.h>
// 包含断言相关头文件，用于在代码中进行条件断言检查，确保程序运行时某些关键条件满足
#include <assert.h>

// 函数用于初始化交换文件系统相关的资源和进行一些必要的检查
void swapfs_init(void) {
    // 使用静态断言检查页面大小（PGSIZE）是否是磁盘扇区大小（SECTSIZE）的整数倍，这是为了保证后续以扇区为单位进行数据交换等操作时能正确对齐
    static_assert((PGSIZE % SECTSIZE) == 0);
    // 调用ide_device_valid函数验证交换设备编号（SWAP_DEV_NO，定义为1）对应的设备是否有效
    // 如果设备无效（返回false），则调用panic函数（应该是系统的错误处理函数，用于终止程序并输出错误信息）提示交换文件系统不可用
    if (!ide_device_valid(SWAP_DEV_NO)) {
        panic("swap fs isn't available.\n");
    }
    // 计算并赋值最大交换偏移量（max_swap_offset），通过获取交换设备（SWAP_DEV_NO对应的设备）的大小（以扇区数量表示，调用ide_device_size函数获取）除以一页需要的扇区数量（PAGE_NSECT）得到
    // 这个偏移量可能用于后续在交换空间中定位数据等操作
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PAGE_NSECT);//最大扇区数量56/单页所占扇区数量8=7
}

// 函数用于模拟从交换文件系统（也就是模拟的“硬盘”交换区）读取数据到指定的页面中
// 参数说明：
// - entry: 交换项相关的结构体（swap_entry_t类型，具体定义应该在swap.h等相关头文件中），可能包含了交换数据在交换区中的位置等信息
// - page: 指向Page结构体的指针（Page结构体应该与页面管理相关，定义在其他地方），表示要将读取的数据存入的目标页面
int swapfs_read(swap_entry_t entry, struct Page *page) {
    // 函数从调用ide_read_secs交换设备（SWAP_DEV_NO对应的设备，即模拟的“硬盘”）读取数据
    // 读取的起始扇区号通过swap_offset函数（应该是根据entry计算得到起始扇区号相关的函数，定义在其他地方）乘以一页需要的扇区数量（PAGE_NSECT）得到
    // 读取的数据要存入的目标内存地址通过page2kva函数（应该是将页面结构体转换为对应的内存地址的函数，定义在其他地方）得到，读取的数据长度为一页需要的扇区数量（PAGE_NSECT）
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}

// 函数用于模拟将指定页面的数据写入到交换文件系统（模拟的“硬盘”交换区）中
// 参数说明：
// - entry: 交换项相关的结构体（swap_entry_t类型），包含了写入数据在交换区中的目标位置等信息
// - page: 指向Page结构体的指针，表示要写入的源页面数据
int swapfs_write(swap_entry_t entry, struct Page *page) {
    // 调用ide_write_secs函数向交换设备（SWAP_DEV_NO对应的设备）写入数据
    // 写入的起始扇区号通过swap_offset函数乘以一页需要的扇区数量（PAGE_NSECT）得到
    // 写入的源数据地址通过page2kva函数得到，写入的数据长度为一页需要的扇区数量（PAGE_NSECT）
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
}