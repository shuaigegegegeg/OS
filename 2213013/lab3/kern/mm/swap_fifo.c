#include <defs.h>
#include <riscv.h>
#include <stdio.h>
#include <string.h>
#include <swap.h>
#include <swap_fifo.h>
#include <list.h>

/* [wikipedia]The simplest Page Replacement Algorithm(PRA) is a FIFO algorithm. The first-in, first-out
 * page replacement algorithm is a low-overhead algorithm that requires little book-keeping on
 * the part of the operating system. The idea is obvious from the name - the operating system
 * keeps track of all the pages in memory in a queue, with the most recent arrival at the back,
 * and the earliest arrival in front. When a page needs to be replaced, the page at the front
 * of the queue (the oldest page) is selected. While FIFO is cheap and intuitive, it performs
 * poorly in practical application. Thus, it is rarely used in its unmodified form. This
 * algorithm experiences Belady's anomaly.
 *
 * Details of FIFO PRA
 * (1) Prepare: In order to implement FIFO PRA, we should manage all swappable pages, so we can
 *              link these pages into pra_list_head1 according the time order. At first you should
 *              be familiar to the struct list in list.h. struct list is a simple doubly linked list
 *              implementation. You should know howto USE: list_init, list_add(list_add_after),
 *              list_add_before, list_del, list_next, list_prev. Another tricky method is to transform
 *              a general list struct to a special struct (such as struct page). You can find some MACRO:
 *              le2page (in memlayout.h), (in future labs: le2vma (in vmm.h), le2proc (in proc.h),etc.
 * 这段注释介绍了先进先出（FIFO）页面置换算法（Page Replacement Algorithm，PRA）的基本概念以及在代码中实现它的一些准备要点。
 * FIFO算法是一种简单的页面置换算法，操作系统开销较低，基本思路是将内存中的页面按照进入内存的时间顺序排成队列，
 * 新进入的页面放在队尾，最早进入的页面在队头，当需要置换页面时，选择队头（最旧的页面）进行置换。
 * 同时提到要实现该算法需要管理可交换页面，利用 `list.h` 中的双向链表结构 `struct list` 来按时间顺序将页面链接到 `pra_list_head1` 链表中，
 * 并且需要熟悉相关链表操作函数（如初始化、添加节点、删除节点、获取前后节点等），还提及了可以通过特定宏（如 `le2page`）将链表节点转换为具体的结构体（如 `struct page`）类型。
 */

// 定义一个链表头节点 `pra_list_head1`，用于构建管理可交换页面的链表，后续通过这个链表实现FIFO页面置换算法，按照页面进入的先后顺序来组织页面。
list_entry_t pra_list_head1;

/*
 * (2) _fifo_init_mm: init pra_list_head1 and let  mm->sm_priv point to the addr of pra_list_head1.
 *              Now, From the memory control struct mm_struct, we can access FIFO PRA
 * 函数功能：`_fifo_init_mm` 函数用于初始化 `pra_list_head1` 链表，并使 `mm_struct` 结构体中的 `sm_priv` 成员指向 `pra_list_head1` 的地址。
 * 这样，通过内存管理结构体 `mm_struct` 就能方便地访问到与FIFO页面置换算法相关的数据结构（即这个链表），为后续基于FIFO算法的页面管理操作做准备。
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{
    // 调用 `list_init` 函数（应该是 `list.h` 中定义的用于初始化链表的函数）对 `pra_list_head1` 链表进行初始化，使其成为一个可用的双向链表，准备接收页面节点。
    list_init(&pra_list_head1);
    // 将 `mm` 结构体中的 `sm_priv` 成员指针指向 `pra_list_head1` 的地址，建立起内存管理结构体与页面置换算法链表之间的关联，方便后续操作。
    mm->sm_priv = &pra_list_head1;
    // 以下这行代码被注释掉了，原本可能用于输出调试信息，显示 `mm->sm_priv` 的地址值，方便查看是否正确赋值。
    // cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
    // 函数执行成功，返回0表示初始化操作顺利完成。
    return 0;
}

/*
 * (3)_fifo_map_swappable: According FIFO PRA, we should link the most recent arrival page at the back of pra_list_head1 qeueue
 * 函数功能：`_fifo_map_swappable` 函数按照FIFO页面置换算法的规则，将新到达（即最近访问的可交换）页面链接到 `pra_list_head1` 链表的尾部，
 * 以此维护页面进入内存的时间顺序，便于后续在需要置换页面时能按照先进先出的原则找到最早进入的页面。
 */
static int
_fifo_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    // 获取 `mm` 结构体中 `sm_priv` 成员指向的链表头指针，这个指针应该就是指向 `pra_list_head1` 链表头，用于后续操作链表。
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
    // 获取要添加页面（`page`）对应的链表节点指针，这个节点用于将页面插入到链表中，通过 `page` 结构体中的 `pra_page_link` 成员来获取（`pra_page_link` 应该是用于构建链表关系的成员）。
    list_entry_t *entry = &(page->pra_page_link);

    // 通过断言检查获取到的链表节点指针和链表头指针都不为 `NULL`，确保后续链表操作的安全性，避免空指针异常。
    assert(entry!= NULL && head!= NULL);
    // record the page access situlation
    // 以下这行代码被注释掉了，可能原本计划用于记录页面访问情况相关的操作，但目前没有具体实现内容，也许后续可以添加相应代码来记录页面的访问信息等。

    // (1)link the most recent arrival page at the back of the pra_list_head1 qeueue.
    // 调用 `list_add` 函数（应该是 `list.h` 中定义的在链表尾部添加节点的函数）将新页面对应的链表节点 `entry` 添加到链表头 `head` 所指向的链表（即 `pra_list_head1`）的尾部，实现按照FIFO顺序添加页面到链表的操作。
    list_add(head, entry);
    // 函数执行成功，返回0表示页面链接操作顺利完成。
    return 0;
}

/*
 *  (4)_fifo_swap_out_victim: According FIFO PRA, we should unlink the  earliest arrival page in front of pra_list_head1 qeueue,
 *                            then set the addr of addr of this page to ptr_page.
 * 函数功能：`_fifo_swap_out_victim` 函数依据FIFO页面置换算法的原则，从 `pra_list_head1` 链表的头部（即最早进入的页面所在位置）移除一个页面节点，
 * 并将该页面的地址通过指针 `ptr_page` 返回给调用者，以便进行后续的页面置换操作（比如将该页面换出到磁盘等）。
 */
static int
_fifo_swap_out_victim(struct mm_struct *mm, struct Page **ptr_page, int in_tick)
{
    // 获取 `mm` 结构体中 `sm_priv` 成员指向的链表头指针，同样这个指针指向的是 `pra_list_head1` 链表头，用于后续操作链表。
    list_entry_t *head = (list_entry_t *)mm->sm_priv;
    // 通过断言检查链表头指针不为 `NULL`，确保链表操作的合法性，避免空指针问题。
    assert(head!= NULL);
    // 通过断言检查 `in_tick` 的值为0，目前不清楚 `in_tick` 具体含义，但从这里的断言来看，在这个函数调用时它应该满足值为0的条件，可能与某种时间相关的条件或者触发机制有关（也许后续代码会完善其具体用途）。
    assert(in_tick == 0);

    /* Select the victim */
    // (1)  unlink the  earliest arrival page in front of pra_list_head1 qeueue
    // 调用 `list_prev` 函数（应该是获取链表中当前节点的前一个节点的函数，用于找到链表头部的节点，也就是最早进入的页面对应的节点）获取链表头部的节点指针，准备将其从链表中移除。
    list_entry_t *entry = list_prev(head);
    // 判断获取到的节点指针是否不等于链表头指针（即确保找到了有效的节点，不是空链表情况），如果找到了有效节点，则执行以下操作。
    if (entry!= head) {
        // 调用 `list_del` 函数（应该是 `list.h` 中定义的用于从链表中删除指定节点的函数）将找到的最早进入的页面对应的节点从链表中删除，完成页面从链表中的移除操作。
        list_del(entry);
        // 通过 `le2page` 宏（前面提到的用于将链表节点转换为 `struct page` 结构体类型的宏）将链表节点转换为页面结构体指针，并将其赋值给 `*ptr_page`，以便将这个要置换出的页面地址传递给调用者。
        *ptr_page = le2page(entry, pra_page_link);
    } else {
        // 如果链表为空（即 `entry` 等于 `head`），则将 `*ptr_page` 设置为 `NULL`，表示没有找到可置换的页面。
        *ptr_page = NULL;
    }
    // 函数执行成功，返回0表示页面置换选择（移除链表头部页面）操作顺利完成。
    return 0;
}

// 以下函数 `_fifo_check_swap` 看起来像是用于检查页面交换相关情况的测试函数，内部进行了一系列对虚拟页面的写入操作，并通过断言检查页面错误次数（`pgfault_num`）等情况来验证页面交换相关功能是否符合预期，但具体功能和验证逻辑可能需要结合更多代码上下文来完整理解。
static int
_fifo_check_swap(void)
{
    cprintf("write Virt Page c in fifo_check_swap\n");
    // 向虚拟地址 `0x3000` 处写入数据 `0x0c`，模拟对虚拟页面的写入操作，这里可能会触发页面相关的机制（比如页面错误处理、页面置换等，取决于整体内存管理逻辑），具体影响需要结合更多代码来看。
    *(unsigned char *)0x3000 = 0x0c;
    // 通过断言检查页面错误次数（`pgfault_num`）是否等于4，可能基于某种预期的页面错误发生次数来验证当前操作是否符合预期，具体这个4的预期值是如何确定的需要看整体页面管理逻辑的设定。
    assert(pgfault_num == 4);
    cprintf("write Virt Page a in fifo_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num == 4);
    cprintf("write Virt Page d in fifo_check_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num == 4);
    cprintf("write Virt Page b in fifo_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num == 4);
    cprintf("write Virt Page e in fifo_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num == 5);
    cprintf("write Virt Page b in fifo_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num == 5);
    cprintf("write Virt Page a in fifo_check_swap\n");
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num == 6);
    cprintf("write Virt Page b in fifo_check_swap\n");
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num == 7);
    cprintf("write Virt Page c in fifo_check_swap\n");
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num == 8);
    cprintf("write Virt Page d in fifo_check_swap\n");
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num == 9);
    cprintf("write Virt Page e in fifo_check_swap\n");
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num == 10);
    cprintf("write Virt Page a in fifo_check_swap\n");
    assert(*(unsigned char *)0x1000 == 0x0a);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num == 11);
    return 0;
}

// 以下函数 `_fifo_init` 目前看起来只是一个简单的占位函数，直接返回0，可能后续需要在这里添加真正的初始化相关代码逻辑来完善FIFO页面置换算法相关的初始化操作。
static int
_fifo_init(void)
{
    return 0;
}

// 以下函数 `_fifo_set_unswappable` 同样可能是一个待完善的函数，目前直接返回0，从函数名推测可能用于设置某些页面为不可交换状态，但具体实现还没有添加，也许后续会根据具体需求补充相应的页面状态设置代码。
static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}

// 以下函数 `_fifo_tick_event` 目前也是直接返回0，可能用于处理某种与时间相关的页面置换事件（从函数名中的 `tick` 推测可能和时钟节拍等时间触发机制有关），但目前没有具体的功能实现代码，有待后续进一步完善。
static int
_fifo_tick_event(struct mm_struct *mm)
{
    return 0;
}

// 定义一个名为 `swap_manager_fifo` 的 `swap_manager` 结构体实例，用于表示FIFO页面置换算法相关的管理结构体，
// 结构体中的各个成员函数指针分别指向前面定义的与FIFO算法实现相关的各个函数，通过这种方式将FIFO页面置换算法的各个功能函数组织在一起，方便在其他地方统一调用和管理。
struct swap_manager swap_manager_fifo =
{
   .name = "fifo swap manager",
   .init = &_fifo_init,
   .init_mm = &_fifo_init_mm,
   .tick_event = &_fifo_tick_event,
   .map_swappable = &_fifo_map_swappable,
   .set_unswappable = &_fifo_set_unswappable,
   .swap_out_victim = &_fifo_swap_out_victim,
   .check_swap = &_fifo_check_swap,
};