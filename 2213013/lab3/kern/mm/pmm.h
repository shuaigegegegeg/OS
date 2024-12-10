// 条件编译指令，用于防止头文件重复包含。如果没有定义过__KERN_MM_PMM_H__这个宏，就执行下面的代码块，直到遇到#endif为止
#ifndef __KERN_MM_PMM_H__
#define __KERN_MM_PMM_H__

// 包含断言相关头文件，用于在代码中进行条件断言检查，确保程序运行时某些关键条件满足
#include <assert.h>
// 包含原子操作相关头文件，可能用于实现对共享变量等的原子性操作，在多线程或多核环境下保证数据操作的一致性
#include <atomic.h>
// 包含项目中自定义的一些基本定义、类型别名、常量等通用内容的头文件，具体定义依赖项目实际情况
#include <defs.h>
// 包含内存布局相关头文件，可能定义了内存中不同区域（如内核空间、用户空间等）的划分、页面相关结构体等信息，用于描述内存的整体结构安排
#include <memlayout.h>
// 包含内存管理单元（MMU）相关头文件，用于处理虚拟地址与物理地址转换、页表操作等内存管理相关功能，之前可能已经定义了地址结构、页表项等相关内容
#include <mmu.h>

// pmm_manager结构体定义，它代表物理内存管理类，是一个抽象的概念，用于管理物理内存空间。
// 不同的具体物理内存管理实现（比如基于不同算法或策略的管理方式）可以通过实现这个结构体中定义的方法来完成对物理内存的管理工作
struct pmm_manager {
    const char *name;  // XXX_pmm_manager的名称，用于标识具体是哪种物理内存管理方式，比如可能是"buddy_pmm_manager"之类的名字

    // 函数指针，指向用于初始化内部描述和管理数据结构（例如空闲块列表、空闲块数量等）的函数，不同的物理内存管理实现会有各自的初始化逻辑
    void (*init)(
        void);  

    // 函数指针，指向根据初始的空闲物理内存空间来设置描述和管理数据结构的函数，比如根据系统启动时检测到的可用物理内存情况进行相应设置
    void (*init_memmap)(
        struct Page *base,
        size_t n);  

    // 函数指针，指向分配大于等于n页内存的函数，具体分配多少页以及如何分配依赖于具体采用的分配算法，返回指向分配得到的页面结构体的指针
    struct Page *(*alloc_pages)(
        size_t n);  

    // 函数指针，指向释放大于等于n页内存的函数，参数中的"base"是指向Page结构体的起始地址（Page结构体可能描述了内存页面相关属性，在memlayout.h中定义），用于释放相应的内存页面
    void (*free_pages)(struct Page *base, size_t n);  

    // 函数指针，指向返回空闲页面数量的函数，用于查询当前系统中还有多少可用的空闲内存页面
    size_t (*nr_free_pages)(void);  

    // 函数指针，指向检查该物理内存管理实现正确性的函数，例如检查内存分配和释放操作后内存状态是否正确等
    void (*check)(void);  
};

// 声明一个外部的指向pmm_manager结构体的指针，意味着这个指针在其他源文件中定义，在这里只是声明，通过它可以访问具体的物理内存管理实现对象
extern const struct pmm_manager *pmm_manager;
// 声明一个外部的页目录项指针（pde_t类型，在mmu.h等相关头文件中应该有定义），可能与系统启动时的初始页目录相关，用于地址映射等操作
extern pde_t *boot_pgdir;
// 声明一个外部的size_t类型的常量nbase，其具体含义可能与内存页面相关的一些基准值或者偏移量等有关，依赖于项目整体内存布局定义
extern const size_t nbase;
// 声明一个外部的无符号整数指针类型（uintptr_t）的变量boot_cr3，可能与处理器的控制寄存器相关（在x86等架构中CR3寄存器用于存放页目录基址等信息，这里类似，用于启动相关的地址管理等情况）
extern uintptr_t boot_cr3;

// 函数声明，用于初始化物理内存管理模块，在系统启动等阶段会调用这个函数来完成物理内存管理相关的初始化工作
void pmm_init(void);

// 函数声明，用于分配n页内存，返回指向分配得到的页面结构体的指针，是对外提供的内存分配接口之一
struct Page *alloc_pages(size_t n);
// 函数声明，用于释放以base为起始地址的n页内存，实现内存的回收操作
void free_pages(struct Page *base, size_t n);
// 函数声明，用于获取当前系统中空闲页面的数量，返回空闲页面的数量值
size_t nr_free_pages(void);

// 宏定义，方便分配一页内存，实际调用alloc_pages函数并传入参数1来实现
#define alloc_page() alloc_pages(1)
// 宏定义，方便释放一页内存，实际调用free_pages函数并传入参数（page，1）来实现，其中page是要释放的页面结构体指针
#define free_page(page) free_pages(page, 1)

// 函数声明，用于获取指定线性地址（la）对应的页表项（PTE）指针，如果create参数为true，可能会在页表不存在相应项时创建该项，返回指向页表项的指针
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create);
// 函数声明，用于获取指定线性地址（la）对应的页面结构体指针，同时可以将对应的页表项指针存储到ptep_store指向的位置（如果不为空），返回指向页面结构体的指针
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store);
// 函数声明，用于移除指定线性地址（la）在页目录（pgdir）中的映射，比如在释放内存页面或者调整内存映射关系时会用到
void page_remove(pde_t *pgdir, uintptr_t la);
// 函数声明，用于在页目录（pgdir）中插入页面（page）到指定线性地址（la）的映射，并设置相应的权限（perm），返回操作是否成功的状态（可能是整型表示，比如0表示成功，其他值表示失败等情况）
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm);

// 函数声明，用于使指定页目录（pgdir）中对应线性地址（la）的转换旁视缓冲器（TLB，用于加速地址转换的硬件缓存）项失效，比如在更新了页表内容后需要调用这个函数来确保缓存数据的一致性
void tlb_invalidate(pde_t *pgdir, uintptr_t la);
// 函数声明，用于在页目录（pgdir）中为指定线性地址（la）分配一个页面，并设置相应的权限（perm），返回指向分配得到的页面结构体的指针
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm);

/* *
 * PADDR - 这个宏用于将内核虚拟地址（指向KERNBASE之上的地址，在机器最大256MB的物理内存被映射的区域内）转换为对应的物理地址。
 * 如果传入的不是内核虚拟地址，会触发panic（系统错误处理，通常是终止程序并输出错误信息）。
 * */
#define PADDR(kva)                                                 \
    ({                                                             \
        uintptr_t __m_kva = (uintptr_t)(kva);                      \
        if (__m_kva < KERNBASE) {                                  \
            panic("PADDR called with invalid kva %08lx", __m_kva); \
        }                                                          \
        __m_kva - va_pa_offset;                                    \
    })

/* *
 * KADDR - 这个宏用于将物理地址转换为对应的内核虚拟地址。如果传入的是无效的物理地址，会触发panic。
 * */
#define KADDR(pa)                                                \
    ({                                                           \
        uintptr_t __m_pa = (pa);                                 \
        size_t __m_ppn = PPN(__m_pa);                            \
        if (__m_ppn >= npage) {                                  \
            panic("KADDR called with invalid pa %08lx", __m_pa); \
        }                                                        \
        (void *)(__m_pa + va_pa_offset);                         \
    })

// 声明一个外部的指向Page结构体的指针pages，可能指向系统中所有内存页面结构体组成的数组，用于管理各个页面
extern struct Page *pages;
// 声明一个外部的size_t类型变量npage，可能表示系统中总的页面数量，用于内存管理中对页面计数等操作
extern size_t npage;
// 再次声明之前提到的外部常量nbase，确保在这个头文件中能使用其定义
extern const size_t nbase;
// 声明一个外部的无符号整数类型（uint_t）变量va_pa_offset，可能表示虚拟地址与物理地址之间的偏移量，用于地址转换等相关计算
extern uint_t va_pa_offset;

// 内联函数，用于将Page结构体指针转换为对应的页号（PPN，物理页号相关概念，在mmu.h等相关头文件中有定义），通过计算页面在pages数组中的相对位置加上nbase得到
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }

// 内联函数，用于将Page结构体指针转换为对应的物理地址，先通过page2ppn获取页号，然后将页号左移PGSHIFT位（PGSHIFT表示页面大小以2为底的对数，也就是页面偏移量的位数，用于计算物理地址）得到物理地址
static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
}

// 内联函数，用于将物理地址转换为对应的Page结构体指针，先通过PPN宏获取物理地址对应的页号，然后判断页号是否超出系统总页面数量（npage），如果超出则触发panic，否则返回指向对应页面的Page结构体指针（从pages数组中获取）
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
}

// 内联函数，用于将Page结构体指针转换为对应的内核虚拟地址，先通过page2pa将页面转换为物理地址，然后再通过KADDR宏将物理地址转换为内核虚拟地址
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }

// 内联函数，用于将内核虚拟地址转换为对应的Page结构体指针，先通过PADDR将内核虚拟地址转换为物理地址，然后再通过pa2page将物理地址转换为Page结构体指针
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }

// 内联函数，用于将页表项（pte_t类型）转换为对应的Page结构体指针，首先检查页表项的有效位（PTE_V）是否设置，如果未设置则触发panic，然后通过PTE_ADDR宏获取页表项中的地址部分，再通过pa2page将其转换为Page结构体指针
static inline struct Page *pte2page(pte_t pte) {
    if (!(pte & PTE_V)) {
        panic("pte2page called with invalid pte");
    }
    return pa2page(PTE_ADDR(pte));
}

// 内联函数，用于将页目录项（pde_t类型）转换为对应的Page结构体指针，通过PDE_ADDR宏获取页目录项中的地址部分，再通过pa2page将其转换为Page结构体指针
static inline struct Page *pde2page(pde_t pde) {
    return pa2page(PDE_ADDR(pde));
}

// 内联函数，用于获取页面结构体（Page结构体）的引用计数，返回Page结构体中ref成员的值（ref成员可能用于记录页面被引用的次数，在内存管理中用于判断页面是否可以释放等情况）
static inline int page_ref(struct Page *page) { return page->ref; }

// 内联函数，用于设置页面结构体（Page结构体）的引用计数为指定的值（val），直接对Page结构体中的ref成员进行赋值操作
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }

// 内联函数，用于增加页面结构体（Page结构体）的引用计数，先将引用计数加1，然后返回增加后的引用计数值
static inline int page_ref_inc(struct Page *page) {
    page->ref += 1;
    return page->ref;
}

// 内联函数，用于减少页面结构体（Page结构体）的引用计数，先将引用计数减1，然后返回减少后的引用计数值
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}

// 内联函数，通过内联汇编指令（"sfence.vma"，在某些架构中用于刷新内存管理相关的硬件缓存，确保内存一致性等情况）来刷新转换旁视缓冲器（TLB），可能在更新页表等操作后调用
static inline void flush_tlb() { asm volatile("sfence.vma"); }

// 内联函数，用于根据给定的页号（ppn）和权限类型（type）构造一个页表项（PTE），通过将页号左移PTE_PPN_SHIFT位，然后与有效位（PTE_V）以及给定的权限类型按位或操作得到页表项的值
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
}

// 内联函数，用于根据给定的页号（ppn）构造一个页表项（PTE），只是简单调用pte_create并传入PTE_V作为权限类型，表示只设置有效位，用于创建页表目录等相关情况的页表项构造
static inline pte_t ptd_create(uintptr_t ppn) { return pte_create(ppn, PTE_V); }

// 声明两个外部的字符数组，bootstack可能表示系统启动时的栈空间起始位置，bootstacktop表示栈空间的结束位置（栈是从高地址向低地址增长的，所以这里这样命名来界定栈的范围）
extern char bootstack[], bootstacktop[];

// 函数声明，用于动态分配n字节大小的内存空间，返回指向分配得到的内存空间的指针，是内存分配的一种接口函数
extern void *kmalloc(size_t n);
// 函数声明，用于释放ptr指向的大小为n字节的内存空间，实现内存的回收操作，与kmalloc相对应
extern void kfree(void *ptr, size_t n);

#endif /*!__KERN_MM_PMM_H__ */