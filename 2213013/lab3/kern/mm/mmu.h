// 条件编译指令，用于防止头文件重复包含。如果没有定义过__KERN_MM_MMU_H__这个宏，就执行下面的代码块，直到遇到#endif为止
#ifndef __KERN_MM_MMU_H__
#define __KERN_MM_MMU_H__

// 另一个条件编译指令，用于区分汇编代码和C代码环境。如果不是汇编代码环境（__ASSEMBLER__未定义），则包含<defs.h>头文件
// <defs.h>可能包含了一些项目中自定义的基本定义、类型别名、常量等通用的内容
#ifndef __ASSEMBLER__
#include <defs.h>
#endif /*!__ASSEMBLER__ */

// 以下是关于线性地址结构以及相关宏操作的注释说明，线性地址在RISC-V架构下有特定的结构划分

// 线性地址'la'具有如下四部分结构：
// +--------9-------+-------9--------+-------9--------+---------12----------+
// | Page Directory | Page Directory |   Page Table   | Offset within Page  |
// |     Index 1    |    Index 2     |                |                     |
// +----------------+----------------+----------------+---------------------+
//  \-- PDX1(la) --/ \-- PDX0(la) --/ \--- PTX(la) --/ \---- PGOFF(la) ----/
//  \-------------------PPN(la)----------------------/
//
// 这里的PDX1、PDX0、PTX、PGOFF、PPN这些宏用于按照上述结构分解线性地址，而PGADDR宏用于根据相应的索引和偏移量构建线性地址

// 注释说明RISC-V使用39位虚拟地址来访问56位物理地址，并展示了Sv39虚拟地址和物理地址的结构格式

// RISC-V使用39位虚拟地址来访问56位物理地址！
// Sv39虚拟地址:
// +----9----+----9---+----9---+---12--+
// |  VPN[2] | VPN[1] | VPN[0] | PGOFF |
// +---------+----+---+--------+-------+
//
// Sv39物理地址:
// +----26---+----9---+----9---+---12--+
// |  PPN[2] | PPN[1] | PPN[0] | PGOFF |
// +---------+----+---+--------+-------+
//
// Sv39页表项:
// +----26---+----9---+----9---+---2----+-------8-------+
// |  PPN[2] | PPN[1] | PPN[0] |Reserved|D|A|G|U|X|W|R|V|
// +---------+----+---+--------+--------+---------------+

// 以下是具体的宏定义及解析

// 提取线性地址'la'中的页目录索引1（Page Directory Index 1），通过将线性地址右移PDX1SHIFT位，然后与0x1FF（9位掩码，因为索引占9位）进行按位与操作来获取
#define PDX1(la) ((((uintptr_t)(la)) >> PDX1SHIFT) & 0x1FF)

// 提取线性地址'la'中的页目录索引0（Page Directory Index 0），原理同PDX1(la)，只是右移的位数是PDX0SHIFT，同样与0x1FF按位与获取9位的索引值
#define PDX0(la) ((((uintptr_t)(la)) >> PDX0SHIFT) & 0x1FF)

// 提取线性地址'la'中的页表索引（Page Table Index），将线性地址右移PTXSHIFT位后与0x1FF按位与，得到9位的页表索引值
#define PTX(la) ((((uintptr_t)(la)) >> PTXSHIFT) & 0x1FF)

// 提取线性地址'la'中的页号部分（Page Number field of address），直接将线性地址右移PTXSHIFT位获取，这里的实现方式可能基于整体的地址结构和计算逻辑简化而来
#define PPN(la) (((uintptr_t)(la)) >> PTXSHIFT)

// 提取线性地址'la'中在页面内的偏移量（Offset in page），通过将线性地址与0xFFF（12位掩码，因为页面内偏移量占12位）进行按位与操作获取
#define PGOFF(la) (((uintptr_t)(la)) & 0xFFF)

// 根据页目录索引1（d1）、页目录索引0（d0）、页表索引（t）以及页面内偏移量（o）构建线性地址，
// 通过将各部分按相应的位移量左移后进行位或操作来组合成完整的线性地址，其中位移量分别对应各自在地址结构中的位置
#define PGADDR(d1, d0, t, o) ((uintptr_t)((d1) << PDX1SHIFT | (d0) << PDX0SHIFT | (t) << PTXSHIFT | (o)))

// 获取页表项（PTE）中地址部分，先将页表项（pte）与~0x3FF（取反操作，用于清除低10位，因为这部分不属于地址部分）按位与，然后左移(PTXSHIFT - PTE_PPN_SHIFT)位来调整到正确的地址表示形式
// 页目录项（PDE）地址获取方式和页表项一样，所以直接复用这个宏
#define PTE_ADDR(pte)   (((uintptr_t)(pte) & ~0x3FF) << (PTXSHIFT - PTE_PPN_SHIFT))
#define PDE_ADDR(pde)   PTE_ADDR(pde)

/* 以下是关于页目录和页表相关的常量定义 */

// 定义每个页目录中包含的页目录项数量为512个，用于描述页目录的规模大小，影响地址映射等相关操作
#define NPDEENTRY       512                    // page directory entries per page directory

// 定义每个页表中包含的页表项数量为512个，同样是用于说明页表的规模，在进行内存映射时会涉及到对这些页表项的操作
#define NPTEENTRY       512                    // page table entries per page table

// 定义页面大小为4096字节，这是一个常见的页面大小设定，在内存管理中很多操作都是基于这个页面单位进行的，比如内存分配、映射等
#define PGSIZE          4096                    // bytes mapped by a page

// 计算页面大小以2为底的对数（用于一些位运算等相关的计算简化），在这里PGSIZE为4096，其以2为底的对数为12，也就是页面偏移量的位数
#define PGSHIFT         12                      // log2(PGSIZE)

// 计算一个页目录项所映射的字节数，通过页面大小乘以每个页表的页表项数量得到，反映了页目录项在地址映射方面覆盖的内存范围
#define PTSIZE          (PGSIZE * NPTEENTRY)    // bytes mapped by a page directory entry

// 计算PTSIZE以2为底的对数，用于相关的位运算和地址计算逻辑中，基于PTSIZE的值计算出对应的对数为21
#define PTSHIFT         21                      // log2(PTSIZE)

// 定义在线性地址中页表索引（PTX）的偏移量（也就是从线性地址的哪个位置开始是页表索引部分），这里设定为12位，对应前面提到的线性地址结构划分
#define PTXSHIFT        12                      // offset of PTX in a linear address

// 定义在线性地址中页目录索引0（PDX0）的偏移量，设定为21位，符合线性地址结构中相应部分的位置关系，用于提取该部分索引值
#define PDX0SHIFT       21                      // offset of PDX0 in a linear address

// 定义在线性地址中页目录索引1（PDX1）的偏移量，设定为30位，用于在按位运算中准确提取该索引部分
#define PDX1SHIFT       30                      // offset of PDX0 in a linear address

// 定义在物理地址中页号（PPN）的偏移量，为10位，用于在处理物理地址相关信息时提取或设置页号部分
#define PTE_PPN_SHIFT   10                      // offset of PPN in a physical address

// 以下是关于页表项（PTE）各个字段的定义及相关组合宏定义，用于表示页表项中不同的属性位含义

// 定义PTE_V表示页表项的有效位（Valid），值为0x001，当该位为1时表示对应的页面映射是有效的，可用于访问等操作
#define PTE_V     0x001 // Valid

// 定义PTE_R表示读权限位（Read），值为0x002，用于控制对对应页面是否有读权限
#define PTE_R     0x002 // Read

// 定义PTE_W表示写权限位（Write），值为0x004，用于控制对对应页面是否有写权限
#define PTE_W     0x004 // Write

// 定义PTE_X表示执行权限位（Execute），值为0x008，用于控制对对应页面是否有执行权限
#define PTE_X     0x008 // Execute

// 定义PTE_U表示用户权限位（User），值为0x010，用于区分是用户模式还是内核模式下可访问，为1时表示用户模式可访问
#define PTE_U     0x010 // User

// 定义PTE_G表示全局位（Global），值为0x020，可能用于一些特殊的全局属性设置，比如在某些情况下不受地址空间切换等影响等情况（具体依架构和系统设计而定）
#define PTE_G     0x020 // Global

// 定义PTE_A表示访问位（Accessed），值为0x040，用于记录页面是否被访问过，可用于一些页面置换等内存管理策略中
#define PTE_A     0x040 // Accessed

// 定义PTE_D表示脏位（Dirty），值为0x080，用于标记页面数据是否被修改过，在写回等内存管理操作中会用到这个信息
#define PTE_D     0x080 // Dirty

// 定义PTE_SOFT表示软件保留位（Reserved for Software），值为0x300，留给软件进行一些自定义的标记或扩展使用（具体使用方式由软件层面定义）
#define PTE_SOFT  0x300 // Reserved for Software

// 以下是一些常用的页表项权限组合宏定义，方便在设置页表项权限时使用

// 定义表示页表项为页表目录的权限组合，只设置了有效位（PTE_V），符合页表目录项在内存管理中只需要标记有效与否的常规设定
#define PAGE_TABLE_DIR (PTE_V)

// 定义表示只读权限的组合，包含读权限位（PTE_R）和有效位（PTE_V），用于设置页面为只读状态
#define READ_ONLY (PTE_R | PTE_V)

// 定义表示读写权限的组合，包含读权限位（PTE_R）、写权限位（PTE_W）和有效位（PTE_V），用于设置页面可读写
#define READ_WRITE (PTE_R | PTE_W | PTE_V)

// 定义表示只执行权限的组合，包含执行权限位（PTE_X）和有效位（PTE_V），用于设置页面只能执行代码等操作
#define EXEC_ONLY (PTE_X | PTE_V)

// 定义表示可读可执行权限的组合，包含读权限位（PTE_R）、执行权限位（PTE_X）和有效位（PTE_V），用于设置页面可读且可执行
#define READ_EXEC (PTE_R | PTE_X | PTE_V)

// 定义表示可读可写可执行权限的组合，包含读权限位（PTE_R）、写权限位（PTE_W）、执行权限位（PTE_X）和有效位（PTE_V），用于设置页面具有完整的读写执行权限
#define READ_WRITE_EXEC (PTE_R | PTE_W | PTE_X | PTE_V)

// 定义表示用户模式下可读写执行权限的组合，包含读权限位（PTE_R）、写权限位（PTE_W）、执行权限位（PTE_X）、用户权限位（PTE_U）和有效位（PTE_V），用于设置页面在用户模式下可进行完整操作
#define PTE_USER (PTE_R | PTE_W | PTE_X | PTE_U | PTE_V)

#endif /*!__KERN_MM_MMU_H__ */