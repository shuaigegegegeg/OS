#include <default_pmm.h>
// 包含项目自定义的一些基本定义、类型别名、常量等通用内容的头文件，具体定义依赖项目实际情况
#include <defs.h>
// 包含错误处理相关头文件，可能定义了各种错误码以及错误处理函数等，用于在程序出现错误时进行相应处理
#include <error.h>
// 包含内存布局相关头文件，可能定义了内存中不同区域（如内核空间、用户空间等）的划分、页面相关结构体等信息，用于描述内存的整体结构安排
#include <memlayout.h>
// 包含内存管理单元（MMU）相关头文件，用于处理虚拟地址与物理地址转换、页表操作等内存管理相关功能
#include <mmu.h>
// 包含物理内存管理（pmm）相关头文件，之前可能定义了物理内存管理相关的结构体、函数声明等内容，用于管理物理内存
#include <pmm.h>
// 包含与SBI（Supervisor Binary Interface，用于在RISC-V中实现内核与底层硬件平台交互等功能）相关的头文件，可能涉及硬件相关的查询、操作等接口
#include <sbi.h>
// 包含标准输入输出相关头文件，用于在控制台进行数据的显示等操作，例如使用cprintf函数输出信息
#include <stdio.h>
// 包含字符串处理相关头文件，提供了像strcpy、strcmp等字符串操作函数，代码中用于字符串的复制、比较等操作
#include <string.h>
// 包含交换相关的头文件，可能涉及页面交换等内存管理策略中与交换空间相关的操作和结构体定义等
#include <swap.h>
// 包含同步相关头文件，也许用于处理多线程或多核环境下的资源同步、互斥等问题（虽然在当前代码中暂未明显体现其具体应用场景）
#include <sync.h>
// 包含虚拟内存管理（vmm）相关头文件，可能涉及虚拟内存相关的映射、管理等操作和函数声明
#include <vmm.h>
// 包含与RISC-V架构相关的头文件，可能包含针对RISC-V指令集架构特有的一些寄存器定义、指令宏定义、与硬件底层交互相关的函数原型等，用于基于RISC-V架构的软件开发

// 虚拟地址的物理页面数组，用于管理物理页面相关信息，每个元素可能对应一个物理页面的描述结构体（Page结构体，在其他地方定义）
struct Page *pages;
// 物理内存的总量（以页面数量为单位），用于记录系统中总的物理内存页面数，方便在内存管理中进行资源统计和分配操作
size_t npage = 0;
// 内核虚拟地址与物理地址之间的偏移量，用于在虚拟地址和物理地址相互转换时进行计算，例如通过虚拟地址找到对应的物理地址等情况
uint_t va_pa_offset;
// 在RISC-V架构中，内存起始地址为0x80000000，这里通过将DRAM_BASE（应该是表示内存起始物理地址的常量，在其他地方定义）除以页面大小（PGSIZE，通常表示一个内存页面的字节数，在相关头文件中定义）得到起始页面的索引，作为nbase的值
const size_t nbase = DRAM_BASE / PGSIZE;

// 启动时的页目录的虚拟地址，页目录用于管理虚拟地址到物理地址的映射关系，初始时指向启动阶段相关的页目录结构（可能后续会进行调整和完善）
pde_t *boot_pgdir = NULL;
// 启动时的页目录的物理地址，与boot_pgdir相对应，记录其在物理内存中的实际位置，用于在一些硬件相关操作（如设置控制寄存器等）中使用
uintptr_t boot_cr3;

// 指向物理内存管理对象的指针，通过这个指针可以调用具体的物理内存管理实现（不同的实现方式可能遵循pmm_manager结构体定义的接口）来管理物理内存
const struct pmm_manager *pmm_manager;

// 以下是几个静态函数的声明，这些函数用于进行一些内部的检查操作，具体功能在各自函数定义处体现
static void check_alloc_page(void);
static void check_pgdir(void);
static void check_boot_pgdir(void);

// init_pmm_manager - 初始化一个pmm_manager实例，将pmm_manager指针指向默认的物理内存管理实现（default_pmm_manager，应该是在<default_pmm.h>中定义的具体管理对象）
// 然后输出内存管理的名称（通过访问pmm_manager结构体中的name成员获取），最后调用默认物理内存管理实现的init函数进行内部初始化操作
static void init_pmm_manager(void) {
    pmm_manager = &default_pmm_manager;
    cprintf("memory management: %s\n", pmm_manager->name);
    pmm_manager->init();
}

// init_memmap - 调用具体物理内存管理实现（通过pmm_manager指针调用）的init_memmap函数，根据传入的起始页面指针（base）和页面数量（n）来构建用于描述空闲内存的Page结构体等相关管理数据结构，用于初始化内存管理中对空闲内存的记录和管理
static void init_memmap(struct Page *base, size_t n) {
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - 用于分配连续的n个页面大小（PAGESIZE，通常等同于PGSIZE，即一个页面的字节数）的内存
// 它在一个循环中尝试进行内存分配，通过先保存中断状态（使用local_intr_save函数，可能是用于在多核等环境下避免分配过程被中断干扰），然后调用具体物理内存管理实现的alloc_pages函数进行内存分配
// 如果分配成功（page指针不为NULL）或者要分配的页面数量大于1（可能对于多页分配有不同处理逻辑）或者交换初始化未完成（swap_init_ok == 0，swap_init_ok应该是在其他地方定义的表示交换功能初始化状态的变量），则跳出循环
// 如果分配失败且不满足上述跳出条件，则调用swap_out函数（可能涉及将内存页面交换到磁盘等交换空间的操作，具体依赖于swap相关的实现逻辑）尝试释放一些内存以便再次进行分配，最后返回分配得到的页面指针（如果分配成功）或者NULL（分配失败）
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;

    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page!= NULL || n > 1 || swap_init_ok == 0) break;

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}

// free_pages - 用于释放连续的n个页面大小的内存，通过先保存中断状态（防止在释放过程中被中断干扰内存管理数据结构的一致性），然后调用具体物理内存管理实现的free_pages函数来释放由base指针指向起始位置的n个页面内存
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
    local_intr_restore(intr_flag);
}

// nr_free_pages - 用于获取当前空闲内存的大小（以页面数量表示），同样先保存中断状态，然后调用具体物理内存管理实现的nr_free_pages函数获取空闲页面数量，最后恢复中断状态并返回获取到的空闲页面数量值
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
    local_intr_restore(intr_flag);
    return ret;
}

/* page_init - 初始化物理内存管理相关操作，主要包括以下几个方面：
1. 计算虚拟地址与物理地址的偏移量（va_pa_offset），通过内核虚拟地址基址（KERNBASE）减去一个固定的物理地址（0x80200000，可能是特定的内存起始映射相关地址，依赖于系统设定）得到。
2. 确定物理内存的起始地址（mem_begin）、大小（mem_size）和结束地址（mem_end），这里使用了硬编码取代了可能原本通过sbi_query_memory()接口获取内存信息的方式（也许是出于简化或者特定需求考虑），然后输出这些内存相关的信息（通过cprintf函数）。
3. 根据计算得到的最大物理地址（maxpa，取mem_end和KERNTOP（可能是内核内存顶部地址相关常量）中的较小值）来确定系统总的页面数量（npage），通过将maxpa除以页面大小（PGSIZE）得到。
4. 找到用于管理物理页面的数组（pages）的起始虚拟地址，通过将内核结束地址（end，可能是内核代码段等结束的标记地址，在其他地方定义）向上对齐到页面大小的整数倍来确定，然后将一定范围内的页面（从nbase到npage - nbase）标记为保留页面（通过SetPageReserved函数，可能用于防止这些页面被误分配等情况，具体功能依赖其定义）。
5. 确定空闲内存的起始和结束地址（分别为freemem和mem_end，经过对齐处理），如果空闲内存范围有效（freemem小于mem_end），则调用init_memmap函数根据空闲内存范围构建用于管理空闲内存的Page结构体等相关数据结构。
*/
static void page_init(void) {
    extern char kern_entry[];

    va_pa_offset = KERNBASE - 0x80200000;
    uint64_t mem_begin = KERNEL_BEGIN_PADDR;
    uint64_t mem_size = PHYSICAL_MEMORY_END - KERNEL_BEGIN_PADDR;
    uint64_t mem_end = PHYSICAL_MEMORY_END; //硬编码取代 sbi_query_memory()接口
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
    cprintf("physcial memory map:\n");
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
            mem_end - 1);
    uint64_t maxpa = mem_end;

    if (maxpa > KERNTOP) {
        maxpa = KERNTOP;
    }

    extern char end[];

    npage = maxpa / PGSIZE;
    // BBL has put the initial page table at the first available page after the
    // kernel
    // so stay away from it by adding extra offset to end
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
    for (size_t i = 0; i < npage - nbase; i++) {
        SetPageReserved(pages + i);
    }

    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
    mem_begin = ROUNDUP(freemem, PGSIZE);
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
    if (freemem < mem_end) {
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

// enable_paging - 通过向特定的控制寄存器（satp，在RISC-V架构中用于配置地址转换相关信息的寄存器）写入值来启用分页机制，写入的值由两部分组成：高16位（0x8000000000000000，表示一些模式等相关设置，具体依RISC-V架构定义）和经过移位处理后的boot_cr3（可能是将页目录物理地址按照分页机制要求进行调整后的表示形式，移位位数由RISCV_PGSHIFT定义，在相关架构头文件中应该有规定）
static void enable_paging(void) {
    write_csr(satp, (0x8000000000000000) | (boot_cr3 >> RISCV_PGSHIFT));
}

/**
 * @brief      setup and enable the paging mechanism
 *
 * @param      pgdir  The page dir（页目录的虚拟地址，用于管理地址映射关系）
 * @param[in]  la     Linear address of this memory need to map（需要映射的线性地址，线性地址是在虚拟地址经过一定转换等处理后的中间表示形式，用于页表映射等操作）
 * @param[in]  size   Memory size（要映射的内存大小，用于确定需要映射多少个连续的页面等情况）
 * @param[in]  pa     Physical address of this memory（对应内存的物理地址，与要映射的线性地址相关联，表示实际在物理内存中的位置）
 * @param[in]  perm   The permission of this memory（内存的访问权限，例如可读、可写、可执行等权限组合，通过一些位标志来表示，在相关头文件中有定义）
 */
static void boot_map_segment(pde_t *pgdir, uintptr_t la, size_t size,
                             uintptr_t pa, uint32_t perm) {
    // 断言确保线性地址和物理地址在页面内的偏移量是相等的，这是正确进行地址映射的基本要求
    assert(PGOFF(la) == PGOFF(pa));
    // 计算需要映射的页面数量，通过将给定的内存大小加上线性地址在页面内的偏移量后向上对齐到页面大小（PGSIZE），再除以页面大小得到页面数量n
    size_t n = ROUNDUP(size + PGOFF(la), PGSIZE) / PGSIZE;
    // 将线性地址向下对齐到页面大小的整数倍，方便后续按页面为单位进行映射操作
    la = ROUNDDOWN(la, PGSIZE);
    // 将物理地址也向下对齐到页面大小的整数倍，保证地址映射的一致性
    pa = ROUNDDOWN(pa, PGSIZE);
    // 循环遍历每个要映射的页面，对于每个页面执行以下操作：
    for (; n > 0; n--, la += PGSIZE, pa += PGSIZE) {
        // 获取对应线性地址的页表项（PTE）指针，如果create参数为1，表示如果页表不存在相应项时创建该项，通过调用get_pte函数实现
        pte_t *ptep = get_pte(pgdir, la, 1);
        // 断言确保获取到的页表项指针不为NULL，否则表示获取页表项出现问题，可能是内存不足等原因无法创建页表项等情况
        assert(ptep!= NULL);
        // 根据物理地址（pa）和权限（perm）构造页表项的值，通过调用pte_create函数将物理地址的页号（通过右移PGSHIFT位获取，PGSHIFT表示页面大小以2为底的对数，用于提取页号）以及有效位（PTE_V）和给定的权限按位或操作来设置页表项内容，最后将构造好的页表项值赋给对应的页表项指针指向的位置，完成地址映射设置
        *ptep = pte_create(pa >> PGSHIFT, PTE_V | perm);
    }
}

// boot_alloc_page - 分配一个页面，通过调用alloc_page函数（实际是调用alloc_pages函数分配一页内存）来获取页面，如果分配失败则触发panic（输出错误信息并终止程序），如果分配成功则将分配到的页面通过page2kva函数转换为对应的内核虚拟地址并返回，此函数常用于获取用于页目录表（PDT）和页表（PT）等相关结构的内存
static void *boot_alloc_page(void) {
    struct Page *p = alloc_page();
    if (p == NULL) {
        panic("boot_alloc_page failed.\n");
    }
    return page2kva(p);
}

// pmm_init - setup a pmm to manage physical memory, build PDT&PT to setup
// paging mechanism
//         - check the correctness of pmm & paging mechanism, print PDT&PT
void pmm_init(void) {
    // 初始化物理内存管理实例，选择具体的物理内存管理策略实现（如first_fit、best_fit等，这里选择默认实现）
    // 通过调用init_pmm_manager函数，将pmm_manager指针指向相应的实现，并执行其初始化操作
    init_pmm_manager();

    // 进行物理内存空间的检测，保留已经被使用的内存部分，然后利用物理内存管理实例的init_memmap函数
    // 创建空闲页面列表，以便后续进行内存分配等操作时能知晓哪些内存页面是可分配的
    page_init();

    // 调用物理内存管理实例的check函数（通过check_alloc_page函数间接调用），验证内存分配和释放函数的正确性
    // 确保物理内存管理模块中这两个核心功能按预期工作，例如检查分配后内存状态是否正确、释放是否彻底等
    check_alloc_page();

    // 创建启动时的页目录（Page Directory Table，简称PDT），从外部获取预先定义好的页表数据（boot_page_table_sv39）
    // 并将其赋值给boot_pgdir，使其指向启动时的页目录虚拟地址，然后获取该页目录对应的物理地址赋值给boot_cr3
    extern char boot_page_table_sv39[];
    boot_pgdir = (pte_t*)boot_page_table_sv39;
    boot_cr3 = PADDR(boot_pgdir);

    // 调用check_pgdir函数检查页目录相关的一些属性和操作的正确性，例如页目录的地址对齐情况、能否正确获取页面等
    check_pgdir();

    // 进行静态断言检查，确保内核虚拟地址基址（KERNBASE）和内核内存顶部地址（KERNTOP）是页面大小（PTSIZE）的整数倍
    // 这有助于保证后续内存映射等操作基于合理的地址边界进行，避免出现地址对齐方面的错误
    static_assert(KERNBASE % PTSIZE == 0 && KERNTOP % PTSIZE == 0);

    // 以下这行代码被注释掉了，原本它的作用是将所有物理内存映射到以KERNBASE为起始的线性内存地址空间
    // 但这里提示需要在enable_paging()和gdt_init()完成后才能使用这个映射，所以暂时不执行此操作
    //boot_map_segment(boot_pgdir, KERNBASE, KMEMSIZE, PADDR(KERNBASE),
    //                READ_WRITE_EXEC);

    // 这部分也是一段临时映射相关的代码，被注释掉了，可能是用于在特定阶段设置某种虚拟地址到物理地址的临时映射关系
    // virtual_addr 3G~3G+4M = linear_addr 0~4M = linear_addr 3G~3G+4M =
    // phy_addr 0~4M
    // boot_pgdir[0] = boot_pgdir[PDX(KERNBASE)];

    // 同样，enable_paging函数用于启用分页机制，但在这里也被注释掉了，可能需要在其他相关初始化完成后再调用
    //    enable_paging();

    // 检查基本虚拟内存映射（可能是之前一系列初始化和设置操作后形成的内存映射情况）的正确性，通过调用check_boot_pgdir函数实现
    check_boot_pgdir();
}

// get_pte - get pte and return the kernel virtual address of this pte for la
//        - if the PT contians this pte didn't exist, alloc a page for PT
// 参数说明：
//  pgdir: 页目录（Page Directory Table，PDT）的内核虚拟基地址，用于定位整个页目录结构，基于此找到对应线性地址的映射信息
//  la:     需要映射的线性地址（Linear Address），在虚拟地址转换为物理地址的过程中，线性地址是中间表示形式，通过页表结构来将其映射到具体的物理地址
//  create: 一个逻辑值（布尔值），用于决定当对应的页表项（Page Table Entry，PTE）不存在时，是否为页表分配一个新页面来创建该项
// 返回值：返回对应页表项（PTE）的内核虚拟地址，如果获取或创建失败则返回NULL
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
    /*
     * 如果需要访问物理地址，请使用KADDR()函数进行转换，建议阅读pmm.h文件获取更多有用的宏定义和函数等信息
     * 以下注释提供了一些可能在代码实现中有用的宏和函数说明，帮助完成代码逻辑
     */
    // 根据线性地址la获取其在第一级页目录中的索引（PDX1(la)），然后获取对应的页目录项指针pdep1
    pde_t *pdep1 = &pgdir[PDX1(la)];
    // 检查该页目录项的有效位（PTE_V）是否未设置，即对应的页表是否不存在（在这个两级页表结构中，第一级页目录项指向第二级页表）
    if (!(*pdep1 & PTE_V)) {
        struct Page *page;
        // 如果create为false（即不允许创建新页面来构建页表）或者分配页面失败（alloc_page返回NULL），则直接返回NULL，表示无法获取到对应的页表项
        if (!create || (page = alloc_page()) == NULL) {
            return NULL;
        }
        // 设置刚分配页面的引用计数为1，表示有一个地方引用了该页面（这里是用于构建页表）
        set_page_ref(page, 1);
        // 获取刚分配页面的物理地址，通过page2pa函数将页面结构体指针转换为对应的物理地址
        uintptr_t pa = page2pa(page);
        // 使用KADDR函数将物理地址转换为内核虚拟地址，然后将对应的内存区域（大小为一个页面，PGSIZE字节）清零
        // 这一步可能是为了初始化新分配的页表页面内容，确保其处于一个初始的、可使用的状态
        memset(KADDR(pa), 0, PGSIZE);
        // 根据刚分配页面的页号（通过page2ppn获取）以及设置有效位（PTE_V）和用户可访问位（PTE_U，这里假设一般创建的页表项用户可访问，具体根据实际需求可能不同）构造页目录项的值，并赋值给对应的页目录项指针指向的位置
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
    // 根据第一级页目录项指向的页表（先通过KADDR和PDE_ADDR宏获取其物理地址对应的内核虚拟地址，再进行类型转换），获取对应线性地址在第二级页表中的索引（PDX0(la)），从而得到对应的第二级页表项指针pdep0
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    // 同样检查该第二级页表项的有效位（PTE_V）是否未设置，即对应的映射关系是否还未建立
    if (!(*pdep0 & PTE_V)) {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        // 与上面类似，将新分配用于页表项的页面内存区域清零，这里使用KADDR将物理地址转换为内核虚拟地址后进行操作，确保在虚拟地址空间对应的内存区域被初始化
        memset(KADDR(pa), 0, PGSIZE);
 //   	memset(pa, 0, PGSIZE);  // 原代码此处有误，不能直接用物理地址操作内存（除非在特定的直接访问物理内存的环境下），应通过内核虚拟地址访问内存
        // 根据新分配页面的页号构造页表项的值，同样设置有效位以及用户可访问位，然后赋值给对应的第二级页表项指针指向的位置，完成页表项的创建和映射关系的初步建立
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
    }
    // 最后，根据第二级页表项所在的页表（通过KADDR和PDE_ADDR获取内核虚拟地址）以及线性地址在页表中的索引（PTX(la)），返回对应的页表项指针，即获取到了最终用于映射该线性地址的页表项
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
}

// get_page - get related Page struct for linear address la using PDT pgdir
// 根据给定的页目录（pgdir）和线性地址（la），获取对应的页面结构体指针，如果ptep_store指针不为NULL，还会将对应的页表项指针存储到ptep_store指向的位置
// 返回值：如果能找到有效的页表项且对应的页面存在，则返回对应的页面结构体指针；否则返回NULL
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
    // 首先调用get_pte函数获取对应线性地址la的页表项指针
    pte_t *ptep = get_pte(pgdir, la, 0);
    // 如果ptep_store指针不为NULL，将获取到的页表项指针存储到ptep_store指向的位置
    if (ptep_store!= NULL) {
        *ptep_store = ptep;
    }
    // 如果获取到的页表项指针不为NULL且该页表项的有效位（PTE_V）被设置，表示对应的页面存在且映射关系有效，通过pte2page函数将页表项转换为对应的页面结构体指针并返回
    if (ptep!= NULL && *ptep & PTE_V) {
        return pte2page(*ptep);
    }
    // 如果上述条件不满足，即无法获取到有效的页面映射，返回NULL
    return NULL;
}

// page_remove_pte - free an Page sturct which is related linear address la
//                - and clean(invalidate) pte which is related linear address la
// 说明：当需要释放与线性地址la相关的页面结构体，并清理（使无效）对应的页表项时调用此函数，注意由于页表（PT）发生了改变，所以需要使相应的转换旁视缓冲器（TLB）项无效，以保证地址转换的缓存数据一致性
// 这里定义为内联函数，可能是期望在调用处直接展开代码，减少函数调用开销，常用于内存释放相关操作中涉及的页表项和页面清理工作
static inline void page_remove_pte(pde_t *pgdir, uintptr_t la, pte_t *ptep) {
    /*
     * 需要检查ptep是否有效，并且如果映射关系被更新了，必须手动更新TLB（转换旁视缓冲器），以确保处理器使用的地址映射缓存数据是最新的
     * 以下注释提供了一些可能在代码实现中有用的宏和函数说明，帮助完成代码逻辑
     */
    // 首先检查页表项的有效位（PTE_V）是否被设置，只有有效页表项对应的页面才需要进行后续释放等操作
    if (*ptep & PTE_V) {  
        // 通过pte2page函数根据页表项获取对应的页面结构体指针，找到与该页表项相关联的页面
        struct Page *page = pte2page(*ptep);  
        // 减少该页面的引用计数，因为要释放该页面或者减少对它的引用，通过page_ref_dec函数实现引用计数减1操作
        page_ref_dec(page);  
        // 如果页面的引用计数减到0，表示没有其他地方再引用这个页面了，此时可以安全地释放该页面，通过调用free_page函数释放页面内存
        if (page_ref(page) == 0) {  
            free_page(page);
        }
        // 将对应的页表项清零，清除该页表项中的映射关系，相当于解除了线性地址与物理地址通过该页表项建立的映射
        *ptep = 0;  
        // 调用tlb_invalidate函数使与该线性地址相关的TLB项无效，确保处理器后续进行地址转换时不会使用到旧的、已经失效的映射缓存数据
        tlb_invalidate(pgdir, la);  
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
// 释放与线性地址la相关且具有有效页表项的页面，此函数通过先获取对应线性地址的页表项，然后调用page_remove_pte函数来完成实际的页面释放和页表项清理工作
void page_remove(pde_t *pgdir, uintptr_t la) {
    pte_t *ptep = get_pte(pgdir, la, 0);
    if (ptep!= NULL) {
        page_remove_pte(pgdir, la, ptep);
    }
}

// page_insert - build the map of phy addr of an Page with the linear addr la
// 参数说明：
//  pgdir: 页目录（Page Directory Table，PDT）的内核虚拟基地址，用于定位整个页目录结构，基于此来插入新的页面映射关系
//  page:  需要映射的页面结构体指针，代表要将哪个物理页面映射到指定的线性地址上
//  la:    需要映射的线性地址（Linear Address），指定了要建立映射关系的目标线性地址
//  perm:  页面的权限设置，用于设置对应页表项中关于页面访问权限的相关位（如可读、可写、可执行等权限组合），通过一些预定义的位标志来表示（在相关头文件中有定义）
// 返回值：始终返回0，表示操作成功（如果操作失败，例如内存不足无法创建页表项等情况，会通过其他方式返回错误信息或者进行错误处理，比如在get_pte函数中返回NULL等）
// 注意：由于插入页面映射会改变页表（PT）内容，所以需要使相应的转换旁视缓冲器（TLB）项无效，以保证地址转换的缓存数据一致性
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
    // 首先调用get_pte函数获取对应线性地址la的页表项指针，如果create参数为1（这里调用时传入的是1），表示如果页表项不存在则会尝试创建
    pte_t *ptep = get_pte(pgdir, la, 1);
    // 如果获取页表项指针失败（返回NULL），可能是内存不足等原因无法创建页表项，此时返回-E_NO_MEM错误码，表示没有足够内存来完成操作
    if (ptep == NULL) {
        return -E_NO_MEM;
    }
    // 增加要插入映射的页面的引用计数，因为又有一处（这里是通过页表项建立的映射关系）引用了该页面，通过page_ref_inc函数实现引用计数加1操作
    page_ref_inc(page);
    // 检查获取到的页表项的有效位（PTE_V）是否已被设置，即是否已经存在映射关系
    if (*ptep & PTE_V) {
        struct Page *p = pte2page(*ptep);
        // 如果已经存在的映射关系对应的页面就是要插入映射的页面（即重复映射同一个页面到相同线性地址，可能是更新权限等情况），则减少该页面的引用计数，因为之前可能已经增加过引用计数了，这里平衡一下
        if (p == page) {
            page_ref_dec(page);
        } else {
            // 如果存在的映射关系对应的页面与要插入映射的页面不同，说明需要替换原来的映射关系，先调用page_remove_pte函数释放原来的页面并清理对应的页表项
            page_remove_pte(pgdir, la, ptep);
        }
    }
    // 根据要插入映射的页面的页号（通过page2ppn获取）以及设置有效位（PTE_V）和传入的权限参数（perm）构造新的页表项值，并赋值给对应的页表项指针指向的位置，完成页面到线性地址的映射关系建立，并设置相应的权限
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
    // 调用tlb_invalidate函数使与该线性地址相关的TLB项无效，确保处理器后续进行地址转换时使用最新的映射关系缓存数据
    tlb_invalidate(pgdir, la);
    return 0;
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
// tlb_invalidate函数用于使指定页目录（pgdir）中对应线性地址（la）的转换旁视缓冲器（TLB）项无效。
// TLB用于缓存虚拟地址到物理地址的转换结果以提高地址转换速度，当页表内容被修改（比如页面映射关系改变）后，
// 需要使对应的TLB项失效，确保处理器后续使用的是最新的地址映射信息。这里通过调用flush_tlb函数来实现TLB的刷新操作。
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }

// pgdir_alloc_page - call alloc_page & page_insert functions to
//                  - allocate a page size memory & setup an addr map
//                  - pa<->la with linear address la and the PDT pgdir
// pgdir_alloc_page函数用于在给定的页目录（pgdir）下，为指定的线性地址（la）分配一个页面大小的内存，
// 并建立物理地址（pa）与线性地址（la）之间的映射关系，同时涉及到一些与页面交换（swap）相关的操作（如果条件满足）。
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
    // 首先调用alloc_page函数分配一个页面，尝试获取一个空闲的物理页面，返回对应的页面结构体指针。
    struct Page *page = alloc_page();
    if (page!= NULL) {
        // 如果成功分配到页面，接着调用page_insert函数尝试在给定的页目录（pgdir）中将该页面插入到指定线性地址（la）的映射关系中，
        // 并设置相应的权限（perm）。如果page_insert函数返回非0值，表示插入映射操作失败（例如可能内存不足等原因无法完成映射设置）。
        if (page_insert(pgdir, page, la, perm)!= 0) {
            // 若映射插入失败，则释放刚才分配的页面，通过调用free_page函数实现，然后返回NULL，表示此次分配页面及建立映射操作失败。
            free_page(page);
            return NULL;
        }
        // 如果交换功能初始化成功（swap_init_ok为真，swap_init_ok应该是在其他地方定义的用于标识交换功能初始化状态的变量），
        // 则执行与页面交换相关的操作，将该页面标记为可交换的，并记录其对应的线性地址等信息。
        if (swap_init_ok) {
            // 调用swap_map_swappable函数（具体功能依赖其实现，大概是将页面标记为可交换状态并关联相关信息），
            // 将当前页面、对应的线性地址以及其他相关参数（这里最后一个参数0具体含义需看函数定义）传入。
            swap_map_swappable(check_mm_struct, la, page, 0);
            // 将页面结构体中的pra_vaddr成员设置为当前线性地址la，用于记录该页面对应的线性地址信息，方便后续交换等操作使用。
            page->pra_vaddr = la;
            // 通过断言检查页面的引用计数是否为1，因为刚分配并建立映射后，理论上该页面应该只有一处引用（通过这个映射关系），确保引用计数的正确性。
            assert(page_ref(page) == 1);
            // cprintf("get No. %d  page: pra_vaddr %x, pra_link.prev %x,
            // pra_link_next %x in pgdir_alloc_page\n", (page-pages),
            // page->pra_vaddr,page->pra_page_link.prev,
            // page->pra_page_link.next);
        }
    }

    // 如果分配页面成功且映射插入也成功（或者不需要考虑交换相关操作时），则返回分配并建立好映射的页面结构体指针。
    return page;
}

// check_alloc_page函数用于检查物理内存分配功能的正确性。
// 它通过调用物理内存管理实例（pmm_manager）的check函数来进行具体的检查操作，
// 然后输出提示信息表示检查成功，意味着内存分配相关的函数和机制按预期工作，没有出现明显错误。
static void check_alloc_page(void) {
    pmm_manager->check();
    cprintf("check_alloc_page() succeeded!\n");
}

// check_pgdir函数用于对页目录（pgdir）相关的一系列操作和属性进行检查，确保页目录及其涉及的页面映射等功能的正确性。
static void check_pgdir(void) {
    // assert(npage <= KMEMSIZE / PGSIZE);
    // 以下注释提到在RISC-V架构中内存起始地址相关情况导致npage通常大于KMEMSIZE / PGSIZE，所以这里先注释掉了这个断言检查。
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE

    // 首先获取并记录当前空闲页面的数量，通过调用nr_free_pages函数实现，将结果存储在nr_free_store变量中，
    // 以便后续在一系列操作后对比空闲页面数量是否发生预期之外的变化，用于检查内存管理操作对空闲页面统计的准确性。
    size_t nr_free_store;
    nr_free_store = nr_free_pages();

    // 断言检查系统总的页面数量（npage）不超过内核内存顶部地址（KERNTOP）对应的页面数量（通过除以页面大小PGSIZE得到页面数量），
    // 确保内存管理中涉及的页面范围没有超出合理界限，避免出现越界等错误情况。
    assert(npage <= KERNTOP / PGSIZE);
    // 断言检查启动时的页目录（boot_pgdir）不为NULL，并且其在页面内的偏移量（通过PGOFF宏获取）为0，
    // 即确保页目录的地址是按页面大小对齐的，符合内存管理中对地址对齐的要求。
    assert(boot_pgdir!= NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
    // 断言检查通过页目录（boot_pgdir）获取线性地址为0x0对应的页面结构体指针应该为NULL，
    // 因为初始情况下可能该地址并没有映射有效的页面，用于检查获取页面操作的初始正确性。
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);

    // 分配一个页面，通过调用alloc_page函数获取页面结构体指针，并将其存储在p1变量中，用于后续一系列关于页面插入、引用计数等操作的测试。
    struct Page *p1, *p2;
    p1 = alloc_page();
    // 调用page_insert函数尝试将刚才分配的p1页面插入到页目录（boot_pgdir）中，对应线性地址为0x0，权限设置为0（具体权限含义需看相关定义，可能表示无特定权限），
    // 断言检查插入操作返回值为0，表示插入成功。
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
    // 调用get_pte函数获取对应线性地址0x0的页表项（PTE）指针，存储在ptep变量中，
    // 断言检查获取到的页表项指针不为NULL，确保能正确获取到页表项。
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0))!= NULL);
    // 调用pte2page函数根据获取到的页表项指针获取对应的页面结构体指针，断言检查得到的页面结构体指针与之前分配的p1页面指针相同，
    // 验证通过页表项获取页面的操作正确性以及页面插入后映射关系的准确性。
    assert(pte2page(*ptep) == p1);
    // 断言检查p1页面的引用计数为1，因为刚插入到页目录的映射关系中，理论上只有这一处引用，确保引用计数符合预期。
    assert(page_ref(p1) == 1);

    // 通过一系列地址转换和页表项获取操作，找到对应页面大小（PGSIZE）偏移后的线性地址（即地址为PGSIZE处）对应的页表项指针，
    // 具体操作涉及先通过KADDR、PDE_ADDR等宏进行地址转换和页表项索引计算，这里得到的ptep指针应该指向预期的页表项位置，用于后续验证。
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);

    // 再分配一个页面，将其指针存储在p2变量中，同样用于后续测试页面插入、权限验证等操作。
    p2 = alloc_page();
    // 调用page_insert函数将p2页面插入到页目录（boot_pgdir）中，对应线性地址为PGSIZE，权限设置为用户可访问（PTE_U）和可写（PTE_W），
    // 断言检查插入操作返回值为0，表示插入成功。
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
    // 再次获取对应线性地址PGSIZE的页表项指针，断言检查获取到的页表项指针不为NULL，确保能正确获取到页表项。
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0))!= NULL);
    // 断言检查获取到的页表项设置了用户可访问位（PTE_U），验证权限设置是否正确。
    assert(*ptep & PTE_U);
    // 断言检查获取到的页表项设置了可写位（PTE_W），进一步验证权限设置的正确性。
    assert(*ptep & PTE_W);
    // 断言检查页目录（boot_pgdir）的第一个页目录项（boot_pgdir[0]）设置了用户可访问位（PTE_U），确保页目录相关权限设置符合预期。
    assert(boot_pgdir[0] & PTE_U);
    // 断言检查p2页面的引用计数为1，因为刚插入到页目录的映射关系中，理论上只有这一处引用，确保引用计数符合预期。
    assert(page_ref(p2) == 1);

    // 再次调用page_insert函数尝试将p1页面插入到页目录（boot_pgdir）中，对应线性地址为PGSIZE，权限设置为0，
    // 断言检查插入操作返回值为0，表示插入成功，这里可能模拟了页面重新映射等情况的测试。
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
    // 断言检查p1页面的引用计数变为2，因为现在有两处映射关系引用了该页面（之前在地址0x0和现在又在地址PGSIZE处插入了映射），确保引用计数更新正确。
    assert(page_ref(p1) == 2);
    // 断言检查p2页面的引用计数变为0，因为刚才将相同线性地址（PGSIZE）的映射替换为了p1页面，p2页面不再被该映射引用，确保引用计数更新正确。
    assert(page_ref(p2) == 0);
    // 再次获取对应线性地址PGSIZE的页表项指针，断言检查获取到的页表项指针不为NULL，确保能正确获取到页表项。
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0))!= NULL);
    // 调用pte2page函数根据获取到的页表项指针获取对应的页面结构体指针，断言检查得到的页面结构体指针与p1页面指针相同，
    // 验证重新映射后通过页表项获取页面的操作正确性以及页面替换后的映射关系准确性。
    assert(pte2page(*ptep) == p1);
    // 断言检查获取到的页表项没有设置用户可访问位（PTE_U），验证权限设置是否按照预期在重新映射时被正确更新。
    assert((*ptep & PTE_U) == 0);

    // 调用page_remove函数移除页目录（boot_pgdir）中对应线性地址0x0的页面映射关系，用于测试页面释放和引用计数更新等操作。
    page_remove(boot_pgdir, 0x0);
    // 断言检查p1页面的引用计数变为1，因为刚才移除了一处对该页面的映射引用，确保引用计数更新正确。
    assert(page_ref(p1) == 1);
    // 断言检查p2页面的引用计数依然为0，确保其引用计数没有受到影响，符合预期情况。
    assert(page_ref(p2) == 0);

    // 调用page_remove函数移除页目录（boot_pgdir）中对应线性地址PGSIZE的页面映射关系，进一步测试页面释放和引用计数更新等操作。
    page_remove(boot_pgdir, PGSIZE);
    // 断言检查p1页面的引用计数变为0，因为现在所有对该页面的映射引用都被移除了，确保引用计数更新正确，并且此时该页面应该可以被释放了。
    assert(page_ref(p1) == 0);
    // 断言检查p2页面的引用计数依然为0，确保其引用计数没有受到影响，符合预期情况。
    assert(page_ref(p2) == 0);

    // 断言检查通过页目录（boot_pgdir）的第一个页目录项（boot_pgdir[0]）获取到的页面（通过pde2page函数）的引用计数为1，
    // 这里应该是检查页目录项对应的页面引用情况是否符合预期，确保没有出现意外的引用计数错误。
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);

    // 获取页目录（boot_pgdir）的指针以及通过页目录项（boot_pgdir[0]）获取对应的页表所在页面的内核虚拟地址对应的指针，分别存储在pd1和pd0变量中，
    // 用于后续释放相关页面的操作，这里涉及到多层地址转换和页表、页目录结构的操作。
    pde_t *pd1 = boot_pgdir, *pd0 = page2kva(pde2page(boot_pgdir[0]));
    // 调用free_page函数释放通过pd0指向的页表所在页面，进行内存回收操作。
    free_page(pde2page(pd0[0]));
    // 调用free_page函数释放通过pd1指向的页目录所在页面，进行内存回收操作，这里假设页目录所在页面也是可以动态分配和释放的情况（具体依实现而定）。
    free_page(pde2page(pd1[0]));
    // 将页目录（boot_pgdir）的第一个页目录项清零，解除其对应的映射关系（如果有的话），重置页目录的初始状态。
    boot_pgdir[0] = 0;

    // 断言检查当前空闲页面数量（通过再次调用nr_free_pages函数获取）与之前记录的空闲页面数量（nr_free_store）相等，
    // 验证经过一系列页面分配、插入、移除和释放操作后，空闲页面数量统计是否正确，确保内存管理对空闲页面数量的维护准确无误。
    assert(nr_free_store == nr_free_pages());

    // 输出提示信息，表示对页目录相关检查成功，意味着页目录及其涉及的页面映射等操作在上述各种测试情况下都按预期工作，没有出现明显错误。
    cprintf("check_pgdir() succeeded!\n");
}

// check_boot_pgdir函数用于对启动时的页目录（boot_pgdir）相关的一些关键属性、页面映射关系以及基于此的内存操作进行检查，以确保整个内存管理机制在启动相关阶段的正确性。
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    // 首先获取并记录当前系统中空闲页面的数量，通过调用nr_free_pages函数来获取空闲页面数，并将其存储在nr_free_store变量中。
    // 后续在执行一系列与页面操作相关的测试后，可以通过对比这个值来检查操作过程中是否存在空闲页面数量统计错误等问题。
    nr_free_store = nr_free_pages();

    // 以下循环遍历从内核虚拟地址基址（KERNBASE）开始，按照页面大小（PGSIZE）为步长，一直到系统总的页面数量（npage）所对应的内存范围。
    // 目的是检查在这个范围内的每个页面大小的线性地址对应的页表项是否能正确获取，以及页表项中的地址信息是否与当前线性地址匹配，以此验证页目录中映射关系的准确性以及整个虚拟内存映射的正确性。
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
        // 对于每个线性地址，调用get_pte函数尝试获取对应的页表项（PTE）指针，传入启动时的页目录（boot_pgdir）、将线性地址转换为内核虚拟地址（通过KADDR函数）以及设置create参数为0（表示仅获取，不创建新的页表项）。
        // 然后使用断言检查获取到的页表项指针不为NULL，确保能够正确获取到对应的页表项，这意味着页目录到页表的映射关系在理论上是正确建立的。
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0))!= NULL);
        // 进一步断言检查获取到的页表项中存储的地址信息（通过PTE_ADDR宏获取，具体实现可能是提取页表项中表示地址的相关位）与当前线性地址（i）相等，
        // 这验证了页表项所记录的地址映射关系是准确的，即从线性地址能正确映射到对应的物理地址（通过页表项间接体现）。
        assert(PTE_ADDR(*ptep) == i);
    }

    // 断言检查启动时的页目录（boot_pgdir）的第一个页目录项（boot_pgdir[0]）的值为0。
    // 这可能是基于特定的初始化要求或者当前检查阶段的预期状态进行的验证，也许表示该页目录项在当前情况下没有有效的映射或者处于默认的未设置状态等，具体含义要结合整个内存管理的初始化逻辑来理解。
    assert(boot_pgdir[0] == 0);

    // 分配一个页面，通过调用alloc_page函数获取页面结构体指针，并将其存储在p变量中。
    // 这个页面将用于后续测试页面插入到页目录的不同线性地址、页面引用计数以及基于映射后的内存访问等相关操作。
    struct Page *p;
    p = alloc_page();

    // 调用page_insert函数将刚才分配的页面（p）插入到启动时的页目录（boot_pgdir）中，对应线性地址设置为0x100，权限设置为可写（PTE_W）和可读（PTE_R）。
    // 然后使用断言检查插入操作返回值为0，表示页面插入及映射关系建立成功。
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
    // 断言检查页面（p）的引用计数为1，因为刚插入到页目录的一个映射关系中，理论上此时该页面只有这一处引用，以此验证页面引用计数机制在插入操作后的正确性。
    assert(page_ref(p) == 1);

    // 再次调用page_insert函数，将同一个页面（p）插入到启动时的页目录（boot_pgdir）中，但这次对应线性地址设置为0x100 + PGSIZE（即在上一个映射地址基础上偏移一个页面大小），权限同样设置为可写（PTE_W）和可读（PTE_R）。
    // 再次使用断言检查插入操作返回值为0，表示第二次页面插入及映射关系建立成功，模拟了同一个页面在不同线性地址建立映射的情况。
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
    // 断言检查页面（p）的引用计数变为2，因为现在该页面通过两个不同的线性地址映射关系被引用，确保页面引用计数能正确随着映射关系的增加而更新，验证引用计数机制的准确性。
    assert(page_ref(p) == 2);

    // 定义一个字符串常量，内容为 "ucore: Hello world!!"，用于后续测试基于映射后的内存写入和读取操作是否正确。
    const char *str = "ucore: Hello world!!";
    // 使用strcpy函数将字符串复制到线性地址为0x100的内存位置（通过之前建立的页面映射关系，实际会写入到对应的物理页面内存中），
    // 这测试了基于映射后的内存写入操作是否能正常进行，以及写入的数据是否能正确存储在对应的内存位置。
    strcpy((void *)0x100, str);
    // 使用strcmp函数比较线性地址为0x100和0x100 + PGSIZE处的字符串内容是否相等，由于前面将相同的字符串复制到了这两个通过同一个页面映射的不同线性地址位置，所以理论上它们应该相等。
    // 通过这个断言检查验证基于页面映射的内存读取操作以及内存中数据一致性是否正确，即从不同映射地址读取到的数据应该是一样的（因为都映射到同一个物理页面）。
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);

    // 通过page2kva函数将页面结构体指针（p）转换为对应的内核虚拟地址，然后找到该虚拟地址偏移0x100位置的字符，并将其赋值为'\0'，
    // 这相当于修改了之前存储在对应内存位置的字符串内容，将其变为空字符串，用于测试内存数据的可修改性以及后续对字符串长度检查的操作。
    *(char *)(page2kva(p) + 0x100) = '\0';
    // 使用strlen函数检查线性地址为0x100处的字符串长度是否变为0，验证前面修改字符串内容的操作是否生效，进一步测试基于页面映射的内存修改和读取操作的正确性。
    assert(strlen((const char *)0x100) == 0);

    // 获取启动时的页目录（boot_pgdir）的指针并存储在pd1变量中，同时通过一系列地址转换和页表、页目录相关操作获取对应页目录项（boot_pgdir[0]）指向的页表所在页面的内核虚拟地址对应的指针，并存储在pd0变量中。
    // 这些指针将用于后续释放相关页面的操作，涉及到多层内存结构的操作和管理，释放这些页面是为了还原内存状态并检查内存回收等相关功能是否正确。
    pde_t *pd1 = boot_pgdir, *pd0 = page2kva(pde2page(boot_pgdir[0]));
    // 调用free_page函数释放之前分配并进行各种操作的页面（p），进行内存回收操作，将该页面占用的物理内存释放回空闲内存池，以便后续可以重新分配使用。
    free_page(p);
    // 调用free_page函数释放通过pd0指针指向的页表所在页面，将对应的页表占用的物理内存也进行回收，确保内存管理中涉及的页表页面能正确释放。
    free_page(pde2page(pd0[0]));
    // 调用free_page函数释放通过pd1指针指向的页目录所在页面，将页目录占用的物理内存也进行回收，同样是为了完整地还原内存状态并检查内存释放相关功能的正确性（假设页目录所在页面也是可以动态分配和释放的情况，具体依实现而定）。
    free_page(pde2page(pd1[0]));
    // 将启动时的页目录（boot_pgdir）的第一个页目录项清零，解除其对应的映射关系（如果有的话），将页目录的相关状态重置为初始的、未设置映射的状态，为后续可能的重新初始化或其他操作做准备。
    boot_pgdir[0] = 0;

    // 断言检查当前系统的空闲页面数量（通过再次调用nr_free_pages函数获取）与之前记录的空闲页面数量（nr_free_store）相等，
    // 这验证了经过一系列页面分配、插入、内存操作以及页面释放等操作后，内存管理模块对空闲页面数量的统计是准确的，没有出现空闲页面数量计算错误等问题，确保整个内存管理机制在这些操作过程中的稳定性和正确性。
    assert(nr_free_store == nr_free_pages());

    // 输出提示信息，表示对启动时的页目录相关的检查操作成功完成，意味着上述各种针对页目录、页面映射、内存操作以及空闲页面数量等方面的检查都通过了，没有发现明显的错误，整个启动阶段的内存管理相关功能按预期工作。
    cprintf("check_boot_pgdir() succeeded!\n");
}

// kmalloc函数用于在内核空间中分配指定大小（n字节）的内存块。
// 它通过计算需要分配的页面数量，调用alloc_pages函数获取相应的物理页面，然后将页面转换为对应的内核虚拟地址并返回，以供内核其他部分使用。
void *kmalloc(size_t n) {
    void *ptr = NULL;
    struct Page *base = NULL;
    // 首先进行断言检查，确保要分配的内存大小（n）大于0且小于一个特定的限制值（1024 * 0124，这里可能是基于系统内存资源限制或者设计考虑设定的一个合理上限，防止不合理的大内存分配请求）。
    assert(n > 0 && n < 1024 * 0124);
    // 计算需要分配的页面数量，通过将请求分配的内存大小（n）加上页面大小（PGSIZE）减1后再除以页面大小（PGSIZE）来向上取整得到页面数量。
    // 例如，如果n小于PGSIZE，也会分配一个页面；如果n刚好是PGSIZE的整数倍，则分配对应整数倍数量的页面，确保分配的内存能完整覆盖请求的大小。
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
    // 调用alloc_pages函数分配指定数量（num_pages）的物理页面，返回对应的页面结构体指针，并将其存储在base变量中。
    // 如果分配成功，base将指向分配到的连续物理页面的起始页面结构体；如果分配失败（例如内存不足等原因），base将为NULL。
    base = alloc_pages(num_pages);
    // 使用断言检查分配操作是否成功，即base指针不为NULL，确保能获取到有效的物理页面来满足内存分配请求。
    assert(base!= NULL);
    // 通过page2kva函数将分配到的物理页面（base）转换为对应的内核虚拟地址，这个虚拟地址就是分配给调用者使用的内存块的起始地址，将其存储在ptr变量中。
    ptr = page2kva(base);
    // 最后返回分配到的内存块的内核虚拟地址指针，供调用者使用，调用者可以通过这个指针在分配的内存区域进行读写等操作，就好像操作普通的内存空间一样，实际上背后是通过页表等机制映射到对应的物理页面上的。
    return ptr;
}

// kfree函数用于释放之前通过kmalloc函数在内核空间中分配的内存块。
// 它根据传入的内存块指针（ptr）和内存块大小（n），计算出对应的页面数量，然后调用free_pages函数将这些页面释放回空闲内存池，完成内存回收操作。
void kfree(void *ptr, size_t n) {
    // 首先进行断言检查，确保要释放的内存大小（n）大于0且小于一个特定的限制值（1024 * 0124，与kmalloc函数中的限制对应，确保释放操作的参数合理性）。
    assert(n > 0 && n < 1024 * 0124);
    // 再次进行断言检查，确保传入的内存块指针（ptr）不为NULL，因为不能释放一个空指针指向的内存，防止出现错误操作。
    assert(ptr!= NULL);
    struct Page *base = NULL;
    // 计算需要释放的页面数量，计算方式与kmalloc函数中类似，通过将内存块大小（n）加上页面大小（PGSIZE）减1后再除以页面大小（PGSIZE）来向上取整得到页面数量，确保能准确释放对应内存块所占用的所有页面。
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
    // 通过kva2page函数将传入的内存块指针（ptr）转换为对应的页面结构体指针，找到该内存块所对应的起始物理页面结构体，将其存储在base变量中，以便后续调用free_pages函数进行页面释放操作。
    base = kva2page(ptr);
    // 调用free_pages函数释放由base指针指向的起始位置的指定数量（num_pages）的页面，将这些页面占用的物理内存释放回空闲内存池，完成内存回收操作，使这些内存可以被后续的内存分配请求再次使用。
    free_pages(base, num_pages);
}
