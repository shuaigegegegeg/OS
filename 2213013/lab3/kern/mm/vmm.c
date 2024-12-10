#include <vmm.h>
#include <sync.h>
#include <string.h>
#include <assert.h>
#include <stdio.h>
#include <error.h>
#include <pmm.h>
#include <riscv.h>
#include <swap.h>

/* 
  vmm设计包含两部分：mm_struct（mm）和vma_struct（vma）。
  mm是针对具有相同页目录表（PDT）的一组连续虚拟内存区域的内存管理器。vma则是一个连续的虚拟内存区域。
  在mm中存在一个用于vma的线性链表以及一个红黑树链表（这里代码中未完整展示红黑树相关操作，可能后续有拓展或者只是一种设计说明）。
  以下是相关函数的分类说明：
  ---------------
  mm相关函数：
    全局函数
      struct mm_struct * mm_create(void)：用于分配并初始化一个mm_struct结构体。
      void mm_destroy(struct mm_struct *mm)：用于释放mm结构体以及其内部相关字段占用的内存资源。
      int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr)：处理页面错误（Page Fault），当访问的虚拟地址不存在对应的物理页面时被调用，尝试解决页面缺失等问题。
  --------------
  vma相关函数：
    全局函数
      struct vma_struct * vma_create (uintptr_t vm_start, uintptr_t vm_end,...)：分配并初始化一个vma_struct结构体，指定其虚拟内存区域的起始、结束地址以及相关标志位等信息。
      void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)：将一个vma结构体插入到指定mm结构体管理的链表中，插入时会按照起始地址顺序进行排列，并检查是否有地址重叠等情况。
      struct vma_struct * find_vma(struct mm_struct *mm, uintptr_t addr)：在给定的mm结构体所管理的虚拟内存区域中查找包含指定虚拟地址（addr）的vma结构体，如果找到则返回其指针，否则返回NULL。
    局部函数
      inline void check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)：用于检查两个vma结构体所表示的虚拟内存区域是否有重叠情况，通过断言进行相关范围的检查。
  ---------------
  检查正确性相关函数：
    void check_vmm(void)：检查整个虚拟内存管理（VMM）机制的正确性，会调用其他检查函数分别对不同部分进行检查，并验证空闲页面数量等情况。
    void check_vma_struct(void)：检查与vma结构体相关操作的正确性，例如创建、插入、查找等操作是否按预期工作，通过一系列测试用例来验证。
    void check_pgfault(void)：检查页面错误处理函数（pgfault handler）的正确性，模拟页面错误场景并执行相关操作，最后验证空闲页面数量等是否符合预期。
*/

// szx func : print_vma和print_mm这两个函数用于打印vma_struct和mm_struct结构体的相关信息，方便调试和查看内存管理结构的状态。

// print_vma函数用于打印给定vma_struct结构体的详细信息，传入一个用于标识的名称（name）和要打印的vma_struct指针（vma）。
void print_vma(char *name, struct vma_struct *vma) {
    // 打印函数的标识信息，表明接下来打印的是哪个vma的相关信息。
    cprintf("-- %s print_vma --\n", name);
    // 打印vma所属的mm_struct结构体的指针地址，用于查看内存管理结构之间的关联关系。
    cprintf("   mm_struct: %p\n", vma->vm_mm);
    // 打印vma的起始虚拟地址和结束虚拟地址，展示其涵盖的虚拟内存范围。
    cprintf("   vm_start,vm_end: %x,%x\n", vma->vm_start, vma->vm_end);
    // 打印vma的标志位信息，用于查看其具有的访问权限等属性。
    cprintf("   vm_flags: %x\n", vma->vm_flags);
    // 打印vma结构体中用于链表链接的节点元素的地址，方便查看链表相关结构信息。
    cprintf("   list_entry_t: %p\n", &vma->list_link);
}

// print_mm函数用于打印给定mm_struct结构体的详细信息，传入一个用于标识的名称（name）和要打印的mm_struct指针（mm）。
void print_mm(char *name, struct mm_struct *mm) {
    // 打印函数的标识信息，表明接下来打印的是哪个mm的相关信息。
    cprintf("-- %s print_mm --\n", name);
    // 打印mm结构体中用于管理vma链表的链表头节点的地址，通过这个链表头可以遍历所有属于该mm管理的vma结构体。
    cprintf("   mmap_list: %p\n", &mm->mmap_list);
    // 打印mm结构体中管理的vma结构体的数量，方便了解内存管理结构中包含的虚拟内存区域个数情况。
    cprintf("   map_count: %d\n", mm->map_count);
    // 获取mm结构体中管理vma链表的链表头节点指针，用于后续遍历链表操作。
    list_entry_t *list = &mm->mmap_list;
    // 循环遍历mm管理的所有vma结构体，根据vma的数量（map_count）进行循环，每次通过list_next函数获取下一个链表节点，并将其转换为对应的vma_struct结构体指针，然后调用print_vma函数打印该vma的详细信息。
    for (int i = 0; i < mm->map_count; i++) {
        list = list_next(list);
        print_vma(name, le2vma(list, list_link));
    }
}

// 以下三个函数先进行声明，具体定义在后续代码中，它们用于检查虚拟内存管理不同方面的正确性，属于静态函数，只能在当前文件内被调用。
static void check_vmm(void);
static void check_vma_struct(void);
static void check_pgfault(void);

// mm_create -  alloc a mm_struct & initialize it.
// mm_create函数用于分配一个mm_struct结构体的内存空间，并对其进行初始化操作，返回初始化好的mm_struct结构体指针。
struct mm_struct *
mm_create(void) {
    // 使用kmalloc函数（应该是一个内核空间的内存分配函数，在其他地方定义）分配一个大小为struct mm_struct结构体大小的内存空间，用于存放mm_struct结构体实例，并将返回的指针存储在mm变量中，如果分配失败（返回NULL）则mm为NULL。
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
    if (mm!= NULL) {
        // 初始化mm结构体中的mmap_list链表，通过调用list_init函数（可能是自定义的链表初始化函数）将链表设置为初始的空链表状态，方便后续插入vma结构体节点。
        list_init(&(mm->mmap_list));
        // 将mm结构体中的mmap_cache指针初始化为NULL，这个指针用于缓存最近访问的vma结构体，提高查找效率，初始时还没有访问过任何vma，所以设置为NULL。
        mm->mmap_cache = NULL;
        // 将mm结构体中的pgdir指针初始化为NULL，pgdir用于指向该mm管理的虚拟内存区域所使用的页目录表（Page Directory Table，PDT），在创建初期还没有设置具体的页目录表，所以为NULL。
        mm->pgdir = NULL;
        // 将mm结构体中记录管理的vma结构体数量的变量map_count初始化为0，因为刚创建还没有添加任何vma结构体。
        mm->map_count = 0;

        // 如果交换功能初始化成功（swap_init_ok为真，这个变量应该在其他地方定义并根据交换功能初始化情况被设置），则调用swap_init_mm函数（具体功能与交换管理相关，可能是初始化mm结构体中与交换相关的私有数据等操作）对mm结构体进行交换功能相关的初始化；否则将mm结构体中的sm_priv指针设置为NULL，表示没有交换相关的私有数据。
        if (swap_init_ok)
            swap_init_mm(mm);
        else
            mm->sm_priv = NULL;
    }
    return mm;
}

// vma_create - alloc a vma_struct & initialize it. (addr range: vm_start~vm_end)
// vma_create函数用于分配一个vma_struct结构体的内存空间，并根据传入的起始虚拟地址（vm_start）、结束虚拟地址（vm_end）以及虚拟内存区域标志位（vm_flags）对其进行初始化，返回初始化好的vma_struct结构体指针。
struct vma_struct *
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
    // 使用kmalloc函数分配一个大小为struct vma_struct结构体大小的内存空间，用于存放vma_struct结构体实例，并将返回的指针存储在vma变量中，如果分配失败（返回NULL）则vma为NULL。
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
    if (vma!= NULL) {
        // 将传入的起始虚拟地址赋值给vma结构体的vm_start成员变量，确定该虚拟内存区域的起始位置。
        vma->vm_start = vm_start;
        // 将传入的结束虚拟地址赋值给vma结构体的vm_end成员变量，确定该虚拟内存区域的结束位置（注意不包含该地址本身）。
        vma->vm_end = vm_end;
        // 将传入的虚拟内存区域标志位赋值给vma结构体的vm_flags成员变量，设置该区域的访问权限等属性。
        vma->vm_flags = vm_flags;
    }
    return vma;
}

// find_vma - find a vma  (vma->vm_start <= addr <= vma_vm_end)
// find_vma函数用于在给定的mm_struct结构体所管理的虚拟内存区域中查找包含指定虚拟地址（addr）的vma_struct结构体，如果找到则返回其指针，否则返回NULL。
struct vma_struct *
find_vma(struct mm_struct *mm, uintptr_t addr) {
    struct vma_struct *vma = NULL;
    if (mm!= NULL) {
        // 首先尝试从mm结构体的mmap_cache中获取vma，mmap_cache用于缓存最近访问过的vma结构体，如果缓存命中且该vma包含指定地址（满足地址范围条件），则可以直接返回该vma，提高查找效率。
        vma = mm->mmap_cache;
        if (!(vma!= NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
            bool found = 0;
            // 获取mm结构体中管理vma链表的链表头节点指针，并将其赋值给list和le变量，后续通过le变量进行链表遍历操作。
            list_entry_t *list = &(mm->mmap_list), *le = list;
            // 循环遍历链表，通过list_next函数获取下一个链表节点，直到遍历完整个链表（回到链表头表示遍历结束）。
            while ((le = list_next(le))!= list) {
                // 将当前链表节点转换为对应的vma_struct结构体指针，通过le2vma宏（在其他地方定义，用于从链表节点获取对应的结构体指针）实现。
                vma = le2vma(le, list_link);
                // 检查当前vma的起始地址小于等于指定地址（addr）且指定地址小于vma的结束地址，即判断指定地址是否在当前vma表示的虚拟内存区域范围内，如果在则表示找到，将found标志设置为1，并跳出循环。
                if (vma->vm_start <= addr && addr < vma->vm_end) {
                    found = 1;
                    break;
                }
            }
            // 如果遍历完链表都没有找到符合条件的vma，则将vma设置为NULL，表示查找失败。
            if (!found) {
                vma = NULL;
            }
        }
        // 如果最终找到了符合条件的vma（vma不为NULL），则将其更新到mm结构体的mmap_cache中，方便下次查找相同或相近地址所属的vma时能更快命中缓存。
        if (vma!= NULL) {
            mm->mmap_cache = vma;
        }
    }
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2?
// check_vma_overlap函数是一个内联静态函数，用于检查两个vma_struct结构体所表示的虚拟内存区域是否有重叠情况，通过断言来确保相关的地址范围条件满足不重叠的要求。
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
    // 断言检查前一个vma的起始地址小于其结束地址，确保前一个vma的地址范围表示合理。
    assert(prev->vm_start < prev->vm_end);
    // 断言检查前一个vma的结束地址小于等于后一个vma的起始地址，确保两个vma的地址范围没有重叠，按照内存管理要求有序排列。
    assert(prev->vm_end <= next->vm_start);
    // 断言检查后一个vma的起始地址小于其结束地址，确保后一个vma的地址范围表示合理。
    assert(next->vm_start < next->vm_end);
}

// insert_vma_struct -insert vma in mm's list link
// insert_vma_struct函数用于将一个vma_struct结构体插入到指定mm_struct结构体管理的链表中，插入时会按照虚拟内存区域的起始地址顺序进行插入，并检查是否有地址重叠等情况。
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    // 首先通过断言检查传入的vma结构体的起始地址小于其结束地址，确保vma的地址范围表示合理，符合虚拟内存区域的定义。
    assert(vma->vm_start < vma->vm_end);
    // 获取mm结构体中管理vma链表的链表头节点指针，用于后续在链表中查找插入位置等操作。
    list_entry_t *list = &(mm->mmap_list);
    list_entry_t *le_prev = list, *le_next;

    list_entry_t *le = list;
    // 遍历mm管理的vma链表，通过比较每个vma的起始地址与要插入的vma的起始地址大小，找到合适的插入位置，即找到第一个起始地址大于要插入vma起始地址的现有vma所在的链表节点位置（le），那么要插入的vma就应该插入到该节点的前面。
    while ((le = list_next(le))!= list) {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start) {
            break;
        }
        le_prev = le;
    }

    // 获取找到的插入位置的下一个链表节点指针，用于后续检查地址重叠等情况以及进行链表插入操作。
    le_next = list_next(le_prev);

    /* check overlap */
    // 如果找到的插入位置的前一个节点不是链表头（即存在前一个vma），则调用check_vma_overlap函数检查要插入的vma与前一个vma是否有地址重叠情况，确保插入操作不会破坏已有的虚拟内存区域顺序和不重叠要求。
    if (le_prev!= list) {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
    }
    // 如果找到的插入位置的下一个节点不是链表头（即存在后一个vma），则调用check_vma_overlap函数检查要插入的vma与后一个vma是否有地址重叠情况，同样确保插入操作不会破坏已有的虚拟内存区域顺序和不重叠要求。
    if (le_next!= list) {
        check_vma_overlap(vma, le2vma(le_next, list_link));
    }

    // 将vma结构体的vm_mm成员指针指向传入的mm结构体，表示该vma属于这个mm管理，建立两者之间的关联关系。
    vma->vm_mm = mm;
    // 将vma结构体的链表节点插入到找到的插入位置（le_prev节点后面），通过调用list_add_after函数（自定义的链表插入函数）实现链表插入操作，将vma添加到mm管理的vma链表中。
    list_add_after(le_prev, &(vma->list_link));

    // 将mm结构体中管理的vma结构体数量（map_count）加1，表示增加了一个虚拟内存区域。
    mm->map_count++;
}

// mm_destroy - free mm and mm internal fields
// 该函数用于释放给定的mm_struct结构体以及其内部管理的所有虚拟内存区域相关资源，完成内存回收操作。
void
mm_destroy(struct mm_struct *mm) {
    // 获取mm结构体中管理vma链表的链表头节点指针，同时初始化一个临时指针le用于后续遍历链表操作。
    list_entry_t *list = &(mm->mmap_list), *le;
    // 开始循环遍历mm管理的vma链表，只要le通过list_next获取到的下一个节点不是链表头（意味着还没遍历完整个链表），就执行循环体内容。
    while ((le = list_next(list))!= list) {
        // 先将当前节点从链表中删除，调用list_del函数（应该是自定义的链表节点删除操作函数）来实现。
        list_del(le);
        // 调用kfree函数（通常是内核空间的内存释放函数，用于回收之前通过kmalloc等分配的内存）释放当前节点对应的vma_struct结构体所占用的内存空间，
        // 传入通过le2vma宏（用于从链表节点获取对应的vma_struct结构体指针）转换得到的vma结构体指针以及vma_struct结构体的大小作为参数，确保正确释放内存。
        kfree(le2vma(le, list_link), sizeof(struct vma_struct));  
    }
    // 释放mm_struct结构体自身所占用的内存空间，同样使用kfree函数进行释放，传入mm指针以及mm_struct结构体的大小作为参数。
    kfree(mm, sizeof(struct mm_struct)); 
    // 将mm指针赋值为NULL，虽然这一步在函数外部可能意义不大（因为mm是函数参数，外部的指针变量本身不会因为这里的赋值而改变），
    // 但在函数内部逻辑上表示该结构体已经被释放，避免后续误操作这个已经释放的指针。
    mm = NULL;
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
// 该函数作为虚拟内存管理（VMM）的初始化入口函数，目前其功能主要是调用check_vmm函数来检查虚拟内存管理机制的正确性。
void
vmm_init(void) {
    check_vmm();
}

// check_vmm - check correctness of vmm
// 此函数用于检查整个虚拟内存管理（VMM）机制的正确性，通过调用其他相关的检查函数并结合空闲页面数量的验证来完成检查工作。
static void
check_vmm(void) {
    // 首先获取并记录当前系统中空闲页面的数量，通过调用nr_free_pages函数来获取空闲页面数，并将其存储在nr_free_pages_store变量中，
    // 后续在执行一系列检查操作后，可以通过对比这个值来检查操作过程中是否存在空闲页面数量统计错误等问题，以此验证内存管理操作对空闲页面数量的影响是否符合预期。
    size_t nr_free_pages_store = nr_free_pages();
    // 调用check_vma_struct函数来检查与虚拟内存区域（vma_struct）相关操作的正确性，比如vma的创建、插入、查找等功能是否按预期工作，包含了一系列针对这些操作的测试用例。
    check_vma_struct();
    // 调用check_pgfault函数来检查页面错误处理函数（pgfault handler）的正确性，模拟页面错误场景并执行相关操作，最后验证空闲页面数量等是否符合预期，确保页面错误处理机制能正常运行。
    check_pgfault();

    // 根据注释说明（Sv39三级页表多占一个内存页的情况相关），将记录的空闲页面数量减1，这里可能是基于特定的内存管理架构和设计，在进行相关检查操作后需要对空闲页面数量的预期值进行相应调整，以符合实际的内存占用情况。
    nr_free_pages_store--;  
    // 通过断言检查当前系统实际的空闲页面数量（再次调用nr_free_pages函数获取）与调整后的预期空闲页面数量（nr_free_pages_store）是否相等，
    // 如果相等则说明经过一系列涉及VMM相关操作的检查后，空闲页面数量的变化符合预期，间接验证了整个虚拟内存管理机制在内存使用和回收等方面的正确性。
    assert(nr_free_pages_store == nr_free_pages());

    // 输出提示信息，表示对虚拟内存管理机制（VMM）的检查成功完成，意味着上述各项检查都通过了，没有发现明显的错误，整个VMM相关功能按预期工作。
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    // 首先获取并记录当前系统中空闲页面的数量，与前面的类似，通过调用nr_free_pages函数来获取空闲页面数，并将其存储在nr_free_pages_store变量中，
    // 后续在执行一系列与vma相关操作的测试后，通过对比这个值来验证操作过程中是否存在空闲页面数量统计错误等问题，以此检查vma相关操作对内存管理的影响是否正确。
    size_t nr_free_pages_store = nr_free_pages();

    // 调用mm_create函数创建一个新的mm_struct结构体实例，用于后续模拟管理虚拟内存区域（vma）的相关操作，同时通过断言检查创建操作是否成功（即返回的mm指针不为NULL），确保能获取到有效的mm结构体进行后续测试。
    struct mm_struct *mm = mm_create();
    assert(mm!= NULL);

    // 定义两个整型变量step1和step2，用于控制后续创建虚拟内存区域（vma）的循环次数以及地址范围等，这里step2的值是step1的10倍，具体用途在后续循环创建vma的过程中体现。
    int step1 = 10, step2 = step1 * 10;

    int i;
    // 第一个循环，从step1开始递减到1，每次循环创建一个新的vma_struct结构体实例，通过调用vma_create函数传入相应的起始地址（i * 5）、结束地址（i * 5 + 2）以及默认标志位（0）来初始化vma，
    // 然后通过断言检查vma创建是否成功（返回的vma指针不为NULL），并调用insert_vma_struct函数将创建好的vma插入到刚才创建的mm结构体管理的链表中，模拟添加多个不同范围的虚拟内存区域的情况。
    for (i = step1; i >= 1; i--) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma!= NULL);
        insert_vma_struct(mm, vma);
    }

    // 第二个循环，从step1 + 1开始递增到step2，同样每次循环创建一个新的vma_struct结构体实例，并进行插入操作，进一步丰富mm结构体管理的虚拟内存区域情况，模拟更多不同范围的vma插入到同一个mm管理的链表中。
    for (i = step1 + 1; i <= step2; i++) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma!= NULL);
        insert_vma_struct(mm, vma);
    }

    // 获取mm结构体中管理vma链表的链表头节点的下一个节点指针（即第一个vma对应的链表节点），用于后续遍历链表验证每个vma的属性是否正确。
    list_entry_t *le = list_next(&(mm->mmap_list));

    // 循环遍历mm管理的vma链表，从第一个vma开始（通过前面获取的le指针），按照顺序依次验证每个vma的起始地址和结束地址是否符合预期（通过断言检查是否等于当前循环次数i对应的计算值），
    // 每次循环获取下一个链表节点（通过list_next函数），确保整个链表中所有vma的属性都符合创建时设置的预期值，以此检查vma插入和链表维护的正确性。
    for (i = 1; i <= step2; i++) {
        assert(le!= &(mm->mmap_list));
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
        le = list_next(le);
    }

    // 另一个循环，从5开始，每次增加5（步长为5），直到达到5 * step2，用于测试查找vma的功能，通过调用find_vma函数查找每个地址对应的vma，
    // 然后通过一系列断言检查查找结果是否符合预期，比如地址i、i + 1应该能找到对应的vma，而地址i + 2、i + 3、i + 4等应该查找不到（返回NULL），同时验证找到的vma的起始地址和结束地址是否正确，以此检查vma查找功能的准确性。
    for (i = 5; i <= 5 * step2; i += 5) {
        struct vma_struct *vma1 = find_vma(mm, i);
        assert(vma1!= NULL);
        struct vma_struct *vma2 = find_vma(mm, i + 1);
        assert(vma2!= NULL);
        struct vma_struct *vma3 = find_vma(mm, i + 2);
        assert(vma3 == NULL);
        struct vma_struct *vma4 = find_vma(mm, i + 3);
        assert(vma4 == NULL);
        struct vma_struct *vma5 = find_vma(mm, i + 4);
        assert(vma5 == NULL);

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
    }

    // 再一个循环，从4开始递减到0，用于检查查找小于特定范围（这里可能以5为界限相关情况）的地址对应的vma是否返回NULL（即不存在对应的vma），
    // 如果查找到的vma不为NULL，则输出该vma的相关信息（通过cprintf函数），同时通过断言检查查找结果应该为NULL，以此验证查找边界情况和不存在对应vma时的返回值正确性。
    for (i = 4; i >= 0; i--) {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
        if (vma_below_5!= NULL) {
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
        }
        assert(vma_below_5 == NULL);
    }

    // 调用mm_destroy函数释放之前创建并用于测试的mm结构体及其管理的所有vma相关资源，完成内存回收操作，还原内存状态，同时也检查资源释放功能是否正确执行。
    mm_destroy(mm);

    // 通过断言检查当前系统实际的空闲页面数量（再次调用nr_free_pages函数获取）与最初记录的空闲页面数量（nr_free_pages_store）是否相等，
    // 如果相等则说明经过一系列与vma相关的创建、插入、查找以及释放等操作后，空闲页面数量的变化符合预期，间接验证了vma相关操作在内存管理方面的正确性。
    assert(nr_free_pages_store == nr_free_pages());

    // 输出提示信息，表示对虚拟内存区域（vma_struct）相关操作的检查成功完成，意味着上述针对vma的各项检查都通过了，没有发现明显的错误，vma相关功能按预期工作。
    cprintf("check_vma_struct() succeeded!\n");
}

struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
// check_pgfault - check correctness of pgfault handler
// 此函数用于检查页面错误（page fault）处理程序的正确性，通过模拟一系列与页面错误相关的操作，并验证相关状态和资源情况来达到检查目的。
static void
check_pgfault(void) {
    // 以下这行代码原本可能是用于定义一个函数内局部的标识字符串变量，但被注释掉了。
    // char *name = "check_pgfault";

    // 获取当前系统中空闲页面的数量，并存储在nr_free_pages_store变量中，后续将通过对比这个值来检查页面错误处理相关操作前后空闲页面数量是否符合预期，以此验证内存管理的正确性。
    size_t nr_free_pages_store = nr_free_pages();

    // 调用mm_create函数创建一个新的mm_struct结构体实例，用于模拟页面错误发生时的内存管理上下文环境。mm_create函数应该是负责分配内存并初始化这个结构体，使其可以管理一组虚拟内存区域（VMA）。
    check_mm_struct = mm_create();

    // 通过断言检查创建的mm_struct结构体是否成功（即指针不为NULL），若为NULL则说明内存分配或初始化出现问题，不符合预期。
    assert(check_mm_struct!= NULL);
    // 将创建好的mm_struct结构体指针赋值给局部变量mm，方便后续操作，mm结构体在后续模拟页面错误处理过程中扮演着关键角色，它管理着相关的虚拟内存区域等信息。
    struct mm_struct *mm = check_mm_struct;
    // 获取mm结构体中的页目录表（Page Directory Table，PDT）指针，并将其赋值为系统启动时的页目录表指针（boot_pgdir，这应该是一个全局定义的表示初始页目录表的变量），这样就建立了当前模拟环境与系统初始页目录的关联。
    pde_t *pgdir = mm->pgdir = boot_pgdir;
    // 通过断言检查页目录表的第一个条目（pgdir[0]）的值是否为0，这可能是基于特定的初始化要求或者当前测试场景下页目录表的预期初始状态进行的验证，确保初始状态符合预期设定。
    assert(pgdir[0] == 0);

    // 调用vma_create函数创建一个新的虚拟内存区域（vma_struct）实例，指定起始地址为0，结束地址为PTSIZE（PTSIZE应该是一个预定义的表示页面大小或者某个特定内存区域大小的常量），权限设置为可写（VM_WRITE），以此模拟出一个可供后续操作的虚拟内存区域。
    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    // 通过断言检查vma创建是否成功（返回的vma指针不为NULL），若创建失败则不符合预期，后续基于这个虚拟内存区域的模拟操作将无法正常进行。
    assert(vma!= NULL);

    // 调用insert_vma_struct函数将刚创建的vma结构体插入到mm结构体管理的虚拟内存区域链表中，这样mm结构体就正式管理了这个虚拟内存区域，建立起了完整的内存管理结构关联关系，模拟出正常的内存管理配置情况。
    insert_vma_struct(mm, vma);

    // 定义一个虚拟地址变量addr并赋值为0x100，用于模拟后续触发页面错误的访问地址，这个地址需要落在前面创建并插入的虚拟内存区域范围内才有意义，以便后续验证相关的查找等操作是否正确。
    uintptr_t addr = 0x100;
    // 通过断言检查调用find_vma函数查找该地址对应的vma是否就是之前创建并插入的那个vma，以此验证find_vma函数在这种场景下能否正确找到对应的虚拟内存区域，确保内存区域查找功能的准确性。
    assert(find_vma(mm, addr) == vma);

    int i, sum = 0;
    // 以下循环从0到99，模拟对虚拟地址addr开始的一段内存区域进行写入操作，每次将当前地址（addr + i）处的字节赋值为当前循环次数i，并将这个值累加到sum变量中，这一步是为了后续验证内存读写操作的正确性做准备，先模拟正常的内存写入情况。
    for (i = 0; i < 100; i++) {
        *(char *)(addr + i) = i;
        sum += i;
    }
    // 下面这个循环同样从0到99，模拟对之前写入的内存区域进行读取操作，每次从当前地址（addr + i）处读取一个字节的值，并从sum变量中减去这个值，理论上经过写入和读取相同数据后，sum最终应该为0，通过这个操作以及后续的断言检查来验证内存读写功能在没有页面错误等异常情况下的数据一致性。
    for (i = 0; i < 100; i++) {
        sum -= *(char *)(addr + i);
    }
    // 通过断言检查sum的值是否为0，若为0则说明前面的内存读写操作按预期执行，没有出现数据不一致等问题，为后续制造页面错误情况做对比基础，只有在正常读写没问题的情况下，才能更好地验证页面错误处理机制的正确性。
    assert(sum == 0);

    // 调用page_remove函数移除页目录表（pgdir）中对应于给定虚拟地址（通过ROUNDDOWN宏将addr按页面大小向下取整后的地址）的页面映射关系，模拟制造页面错误情况，即对应的页面被移除后，再访问该地址就会触发页面错误，这是模拟页面错误发生的关键操作步骤。
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));

    // 调用free_page函数释放通过页目录表项（pgdir[0]）获取到的页面（通过pde2page函数将页目录表项转换为对应的页面结构体指针），进行内存回收操作，进一步改变内存状态，模拟页面错误发生后的内存资源调整情况，符合真实场景下页面错误处理时可能涉及的资源释放操作。
    free_page(pde2page(pgdir[0]));

    // 将页目录表的第一个条目（pgdir[0]）赋值为0，重置页目录表的相关状态，可能是模拟更彻底的页面错误处理后的页目录表清理操作，确保处于一个符合预期的初始状态（或者测试后续相关功能能正确处理这种情况），为后续的资源释放及整个mm结构体的销毁做准备。
    pgdir[0] = 0;

    // 将mm结构体中的页目录表指针设置为NULL，表示解除与当前页目录表的关联，模拟内存管理结构在页面错误处理后的相关状态变化情况，进一步完善整个页面错误处理流程的模拟操作。
    mm->pgdir = NULL;
    // 调用mm_destroy函数释放之前创建并用于测试的mm结构体及其管理的所有虚拟内存区域相关资源，完成内存回收操作，还原内存状态，同时也检查资源释放功能是否正确执行，确保整个模拟过程中资源管理的完整性。
    mm_destroy(mm);

    // 将全局的check_mm_struct指针设置为NULL，因为之前创建用于测试的mm结构体已经被销毁，这里将其对应的全局指针置空，避免后续误操作这个已经释放的结构指针。
    check_mm_struct = NULL;
    // 根据注释说明（Sv39第二级页表多占了一个内存页的情况相关），将记录的空闲页面数量减1，这里可能是基于特定的内存管理架构和设计，在进行相关检查操作后需要对空闲页面数量的预期值进行相应调整，以符合实际的内存占用情况。
    nr_free_pages_store--;

    // 通过断言检查当前系统实际的空闲页面数量（再次调用nr_free_pages函数获取）与调整后的预期空闲页面数量（nr_free_pages_store）是否相等，若相等则说明经过一系列涉及页面错误处理模拟操作后，空闲页面数量的变化符合预期，间接验证了页面错误处理机制在内存管理方面的正确性，包括资源释放、内存状态重置等操作都没有对空闲页面数量统计造成错误影响。
    assert(nr_free_pages_store == nr_free_pages());

    // 输出提示信息，表示对页面错误处理程序（pgfault handler）的检查成功完成，意味着上述各项针对页面错误处理相关的模拟操作及验证都通过了，没有发现明显的错误，页面错误处理相关功能按预期工作。
    cprintf("check_pgfault() succeeded!\n");
}
//page fault number
// 定义一个名为pgfault_num的无符号整数变量，使用volatile关键字修饰。
// volatile表示该变量的值可能会在程序执行过程中被异步地修改（例如被中断处理程序等修改），
// 所以编译器在优化代码时不会对它进行一些可能导致错误的优化操作，能确保每次读取到的都是其最新的值。
// 这个变量用于记录页面错误（Page Fault）发生的次数，方便后续对页面错误情况进行统计、分析等操作。
volatile unsigned int pgfault_num = 0;

/* do_pgfault - interrupt handler to process the page fault execption
 * @mm         : the control struct for a set of vma using the same PDT
 * @error_code : the error code recorded in trapframe->tf_err which is setted by x86 hardware
 * @addr       : the addr which causes a memory access exception, (the contents of the CR2 register)
 *
 * CALL GRAPH: trap--> trap_dispatch-->pgfault_handler-->do_pgfault
 * 函数功能描述：
 * do_pgfault是一个中断处理函数，用于处理页面错误异常情况。在整个系统的调用流程中，当发生页面错误时，
 * 先是由硬件触发陷阱（trap），然后经过陷阱分发（trap_dispatch），再到页面错误处理程序（pgfault_handler），
 * 最终调用到这个do_pgfault函数来具体处理页面错误。
 * 处理器会为该函数提供两方面重要的信息，以辅助诊断页面错误异常并进行相应的恢复操作：
 *   (1) The contents of the CR2 register. The processor loads the CR2 register with the
 *       32-bit linear address that generated the exception. The do_pgfault fun can
 *       use this address to locate the corresponding page directory and page-table
 *       entries.
 * 即处理器会将触发页面错误的32位线性地址加载到CR2寄存器中，而do_pgfault函数可以利用这个地址来定位对应的页目录（Page Directory）和页表（Page Table）项，
 * 通过这些信息来判断和处理页面错误相关的映射等问题。
 *
 *   (2) An error code on the kernel stack. The error code for a page fault has a format different from
 *       that for other exceptions. The error code tells the exception handler three things:
 *         -- The P flag   (bit 0) indicates whether the exception was due to a not-present page (0)
 *            or to either an access rights violation or the use of a reserved bit (1).
 *         -- The W/R flag (bit 1) indicates whether the memory access that caused the exception
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 * 内核栈上的错误代码对于页面错误来说格式与其他异常的错误代码不同，它能告诉异常处理函数三方面信息：
 *    - P标志（第0位）：表示异常是由于页面不存在（值为0），还是由于访问权限违规或者使用了保留位（值为1）所导致的。
 *    - W/R标志（第1位）：表示引发异常的内存访问操作是读操作（值为0）还是写操作（值为1）。
 *    - U/S标志（第1位）：表示处理器在发生异常时是处于用户模式（值为1）还是超级用户（也叫内核、监督者等，值为0）模式。
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
    pte_t* temp = NULL;
temp = get_pte(mm->pgdir, addr, 0);
if(temp != NULL && (*temp & (PTE_V | PTE_R))) {
    return lru_pgfault(mm, error_code, addr);
}
    // 初始化返回值为 -E_INVAL，通常 -E_INVAL 表示无效的操作或参数等错误情况，在这里先将返回值设为这个错误码，
    // 后续会根据实际的页面错误处理情况来更新这个返回值，如果处理成功则会将其修改为0等表示成功的值，否则保持错误码以返回相应的错误信息。
    int ret = -E_INVAL;

    // 尝试在给定的mm_struct结构体所管理的虚拟内存区域中查找包含指定地址（addr）的虚拟内存区域（vma_struct），
    // 通过调用find_vma函数来实现查找功能，返回查找到的vma_struct结构体指针并存储在vma变量中，
    // 后续会基于这个vma来进一步判断地址的合法性以及进行相应的页面错误处理操作，例如判断地址是否在合法的虚拟内存区域范围内等。
    struct vma_struct *vma = find_vma(mm, addr);

    // 将全局的页面错误发生次数（pgfault_num）加1，每次进入这个页面错误处理函数就表示发生了一次新的页面错误，
    // 通过这个变量可以统计页面错误出现的频率等信息，对于调试、分析系统的内存访问情况以及评估页面错误处理机制的性能等方面都有帮助。
    pgfault_num++;

    // 判断触发页面错误的地址（addr）是否在mm结构体管理的某个虚拟内存区域（vma）范围内，
    // 如果vma为NULL（意味着没有找到对应的虚拟内存区域）或者vma的起始地址大于addr（说明给定地址不在找到的vma范围内），
    // 那么这个地址就是不合法的，无法进行有效的页面错误处理，此时会输出相应的提示信息（通过cprintf函数），
    // 并跳转到failed标签处，最终返回错误码（当前的ret值，即 -E_INVAL）表示处理失败。
    if (vma == NULL || vma->vm_start > addr) {
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
        goto failed;
    }

    /* IF (write an existed addr ) OR
     *    (write an non_existed addr && addr is writable) OR
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     * 这段注释描述的逻辑是：
     * 如果满足以下几种情况之一，就继续进行页面错误的处理流程：
     * 一是对已经存在的页面地址进行写入操作；
     * 二是对不存在的页面地址，但该地址具有可写权限的情况下进行写入操作；
     * 三是对不存在的页面地址，但该地址具有可读权限的情况下进行读取操作。
     * 这种判断是基于内存访问权限和页面存在与否的逻辑来决定是否可以进一步处理页面错误，以恢复正常的内存访问。
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
        perm |= (PTE_R | PTE_W);
    }
    perm &= ~PTE_R;
    // 将触发页面错误的地址（addr）按照页面大小向下取整，通过调用ROUNDDOWN宏（这个宏应该在其他地方定义，用于按页面大小对齐地址）来实现。
    // 这样做的目的是在处理页面相关操作时，确保处理的是页面粒度的地址，符合内存管理中以页面为单位进行映射、分配等操作的要求，
    // 后续关于页面表项查找、页面分配以及页面与地址映射等操作都是基于这个取整后的地址来进行的。
    addr = ROUNDDOWN(addr, PGSIZE);

    // 重新初始化返回值为 -E_NO_MEM，通常 -E_NO_MEM表示内存不足的错误情况，在这里先将返回值设为这个值，
    // 后续在进行一些需要分配内存的操作（比如分配页面等）时，如果失败了就会保持这个返回值以表示因内存不足导致页面错误处理失败，
    // 如果操作成功则会更新这个返回值为表示成功的值（比如0）。
    ret = -E_NO_MEM;

    pte_t *ptep = NULL;
    /*
    * Maybe you want help comment, BELOW comments can help you finish the code
    * 以下是一段帮助性注释，提示接下来的代码编写可以参考一些已定义的宏、函数以及相关的变量、定义等信息，
    * 用于实现具体的页面错误处理逻辑，尤其是在处理页面表项（PTE）相关情况时会用到这些内容。
    *
    * Some Useful MACROs and DEFINEs, you can use them in below implementation.
    * MACROs or Functions:
    *   get_pte : get an pte and return the kernel virtual address of this pte for la
    *             if the PT contians this pte didn't exist, alloc a page for PT (notice the 3th parameter '1')
    * 含义：调用get_pte函数可以获取对应于给定地址（la）的页面表项（PTE），并且如果对应的页表（Page Table，PT）中不存在这个表项，
    * 则会分配一个页面用于创建该页表，最后返回这个页面表项对应的内核虚拟地址，方便后续对该表项进行操作。
    *
    *   pgdir_alloc_page : call alloc_page & page_insert functions to allocate a page size memory & setup
    *             an addr map pa<--->la with linear address la and the PDT pgdir
    * 含义：pgdir_alloc_page函数会调用alloc_page（用于分配一个页面大小的内存）和page_insert（用于建立地址映射）等函数，
    * 来分配一个页面大小的内存，并设置给定线性地址（la）与物理地址（pa）之间的映射关系，这个映射关系会关联到给定的页目录表（pgdir），
    * 以此完成页面在内存中的分配和地址映射操作，确保可以通过虚拟地址正确访问到物理内存页面。
    *
    * DEFINES:
    *   VM_WRITE  : If vma->vm_flags & VM_WRITE == 1/0, then the vma is writable/non writable
    * 含义：通过对vma结构体中的vm_flags标志位与VM_WRITE进行按位与操作，如果结果为1则表示对应的虚拟内存区域（vma）是可写的，为0则表示不可写，
    * 这用于判断虚拟内存区域的写权限情况，以便后续确定页面的访问权限等设置。
    *
    *   PTE_W           0x002                   // page table/directory entry flags bit : Writeable
    * 含义：这是一个定义的宏，表示页面表项/目录项中的可写标志位，对应的值为0x002，在设置页面表项的标志位时可以使用这个值来表示页面是否可写，
    * 与其他标志位一起组合来确定页面的完整访问权限等属性。
    *
    *   PTE_U           0x004                   // page table/directory entry flags bit : User can access
    * 含义：这是一个定义的宏，表示页面表项/目录项中的用户可访问标志位，对应的值为0x004，用于设置页面是否允许用户模式下的程序访问，
    * 同样会和其他标志位配合来确定页面的详细访问权限配置。
    *
    * VARIABLES:
    *   mm->pgdir : the PDT of these vma
    * 含义：mm->pgdir是指向页目录表（Page Directory Table，PDT）的指针，这个页目录表管理着当前mm_struct结构体所对应的一组虚拟内存区域（vma）的地址映射，
    * 通过这个指针可以访问和操作整个页表体系，用于查找、创建以及维护页面的虚拟地址到物理地址的映射关系，是内存管理中非常关键的一个数据结构指针。
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    // 调用get_pte函数尝试获取对应于给定地址（addr）的页面表项（PTE），传入mm结构体中的页目录表指针（mm->pgdir）以及地址（addr），
    // 第三个参数1表示如果对应的页表（Page Table，PT）不存在，则分配一个页面用于创建该页表，
    // 返回获取到的页面表项的内核虚拟地址存储在ptep指针中，后续将基于这个表项进行相关判断和操作，例如判断页面是否存在、进行页面交换等处理。

    if (*ptep == 0) {
        // 如果获取到的页面表项（*ptep）的值为0，说明对应的页面在内存中不存在（可能是触发页面错误的原因就是页面缺失），
        // 则尝试调用pgdir_alloc_page函数来分配一个页面大小的内存，并建立该页面的物理地址（PA）与线性地址（LA，即传入的addr）之间的映射关系，
        // 同时关联到给定的页目录表（pgdir），如果分配页面及建立映射操作失败（返回NULL），则输出相应的提示信息（通过cprintf函数），
        // 并跳转到failed标签处，最终返回错误码（当前的ret值，即 -E_NO_MEM）表示处理失败。
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
            goto failed;
        }
    } else {
        /*LAB3 EXERCISE 3: 
        * 请你根据以下信息提示，补充函数
        * 现在我们认为pte是一个交换条目，那我们应该从磁盘加载数据并放到带有phy addr的页面，
        * 并将phy addr与逻辑addr映射，触发交换管理器记录该页面的访问情况
        *
        *  一些有用的宏和定义，可能会对你接下来代码的编写产生帮助(显然是有帮助的)
        *  宏或函数:
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    含义：这个函数用于从磁盘中读取数据到内存中，首先会分配一个内存页（通过某种内存分配机制），
        *    然后依据页面表项（PTE）里交换条目（swap entry）记录的磁盘地址信息，找到对应的磁盘页，
        *    最后将磁盘页中的内容读取到刚才分配的内存页里，实现从磁盘到内存的数据加载，为恢复页面内容做准备。
        *
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    含义：用于建立一个页面的物理地址（phy addr）与线性地址（也就是逻辑地址，linear addr la）之间的映射关系，
        *    通过这个映射，系统就能根据虚拟地址（逻辑地址）正确地找到对应的物理内存页面，从而实现内存访问，
        *    是内存管理中恢复页面映射关系的关键操作之一。
        *
        *    swap_map_swappable ： 设置页面可交换
        *    含义：该函数用于设置页面是否可交换的属性，在内存管理中，有些页面可能需要在内存和磁盘之间进行交换（比如内存不足时将部分页面换出到磁盘），
        *    通过这个函数可以标记页面是否可以参与这样的交换操作，以便交换管理器等相关模块进行管理和调度。
        */
        if (swap_init_ok) {
            struct Page *page = NULL;
            // (1）According to the mm AND addr, try
            // to load the content of right disk page
            // into the memory which page managed.
            // 调用swap_in函数，根据传入的mm结构体和地址（addr），分配一个内存页，并根据页面表项（PTE）中的交换条目地址信息，
            // 找到磁盘页的地址，然后将磁盘页的内容读入这个新分配的内存页中，完成从磁盘加载数据到内存的操作，为后续恢复页面映射做准备。
            swap_in(mm, addr, &page);
            // (2) According to the mm,
            // addr AND page, setup the
            // map of phy addr <--->
            // logical addr
            // 调用page_insert函数，根据传入的mm结构体、页面指针（page）、地址（addr）以及权限（perm），
            // 建立页面的物理地址与线性地址（即逻辑地址）之间的映射关系，使得内存中的页面能够正确地对应到虚拟地址空间中，
            // 恢复因页面交换等原因导致的映射缺失情况，确保可以通过虚拟地址访问到正确的物理页面。
            page_insert(mm->pgdir, page, addr, perm);
            // (3) make the page swappable.
            // 调用swap_map_swappable函数，设置刚才加载数据并建立映射的页面为可交换状态，这样该页面后续在内存紧张等情况下可以被交换管理器合理地换出到磁盘或者从磁盘换入内存，
            // 实现内存资源的动态管理，同时传入参数1表示设置为可交换（具体参数含义可能根据函数定义来确定，这里推测1表示可交换的设置值）。
            swap_map_swappable(mm, addr, page, 1);
            // 将页面结构体（page）中的pra_vaddr成员变量设置为当前处理的地址（addr），这个操作可能是用于记录页面对应的虚拟地址相关信息，
            // 方便后续在内存管理的其他操作（比如页面查找、验证等）中使用，建立页面与虚拟地址之间更明确的关联关系。
            page->pra_vaddr = addr;
        } else {
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
    }

   // 如果前面的页面错误处理操作都顺利完成，没有出现错误（比如页面分配成功、从磁盘加载数据及建立映射等操作都成功执行），
   // 则将返回值ret设置为0，表示页面错误处理成功，后续调用该函数的地方可以根据这个返回值判断处理结果并进行相应的后续操作。
    ret = 0;
failed:
    // 当出现错误情况（如地址不合法、页面分配失败、交换相关操作失败等）时，代码会通过goto语句跳转到这里，
    // 然后直接返回当前的ret值，这个值可能是之前设置的表示错误的代码（如 -E_INVAL 或 -E_NO_MEM），
    // 从而将页面错误处理的结果返回给调用者，调用者可以根据返回的错误码采取进一步的措施，比如向用户报告错误、进行错误记录或者尝试其他的恢复策略等。
    return ret;
}