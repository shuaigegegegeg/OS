# `lab3`实验报告

***

## 练习一

`do_pgfault`:在发生`PageFault`的时候调用该函数完成页面的换入换出，通过`swap_in`函数完成页面的换入，并使用`page_insert`函数完成映射后的页表项的插入，并通过`swap_map_swappable`函数将换进的页面设置为可换出的。

`get_pte`：返回指定地址的页表项。

`find_vma`；找到指定地址所在的`vma`。

`page_insert`:完成虚拟地址到物理地址的映射并将映射的页表项插入到页表中。

`swap_map_swappable`：设置页面为可换出的。

`swap_in`：用于换入页面，首先使用`alloc_page`函数来申请一个页面，接着通过`get_pte`来找到或者构建对应的页表项，最后将数据从硬盘读到内存（也就是刚刚申请的页面）。

`swapfs_read`：将数据从硬盘读到内存。

`alloc_page`：用于申请页面，如果在申请的过程中申请失败，那么需要调用`swap_out`函数换出页面，换出成功之后再进行申请页面。

`swap_out`：用于换出页面，通过调用`swap_out_victim`函数来找到要替换出去的页面，通过`get_pte`函数找到相应的页表项，最后通过`swapfs_write`函数将要换出的页面写入到交换空间。

`swapfs_write`：要换出的页面写入到交换空间。

`tlb_invalidate`：刷新`TLB`。

`_fifo_init_mm`：初始化`FIFO`的链表，并使得链表的头指向`mm->sm_priv`。

`_fifo_map_swappable`：将最近使用的页面添加到链表的头，最先进入的页面位于链表的尾部。

`_fifo_swap_out_victim`：用于获取要释放的页面，释放链表对于尾部元素的链接并将其作为要释放的页面。

`free_page`：用于释放相应的页面。

***

## 练习二

***

1，相似的原因：

两者都是在获取指定虚拟地址的页表项，并在需要的时候创建相应的页和页表项，第一段代码在三级页表中查找PDX1的地址。第二段代码在三级页表中查找PDX0的地址，两次查找的逻辑是相同的，只有三级页表中只用页表的级别和页表内的偏移量是不同的，所以大体上的形式是相同的，只有部分的索引寻找是不同的。

***

2，我认为这种写法好，因为在大部分的时候页表项的查找和页表项的分配应该是一起，我们通常会直接查找页表项，这种情况下如果该页表项存在那么可以直接返回，如果页表项不存在那么可以直接完成页表项的分配再进行返回，将它们合在一起还可以减少代码的重复以及函数调用的开销，使得代码更加简洁。

***

## 练习三

***

实现过程：

```c++
swap_in(mm,addr,&page);
page_insert(mm->pgdir,page,addr,perm);
swap_map_swappable(mm,addr,page,1);
```

首先的`swap_in`函数会将要换进的页面换入内存，如果没有页面可以使用则会在`alloc_page`中调用`swap_out`函数来换出部分的页面来使得需要换入的页面得以换入，接下来使用`page_insert`函数来完成虚拟地址到物理地址的映射并将页表项加入到页表中，最后使用`swap_map_swappable`函数来将换入的页面设置为可换出的。

问题回答：

潜在用处：首先要将换入的页面的虚拟地址到物理地址的映射构成相应的页表项，并将其加入到页表中，同时页目录项和页表项中的一些页面会存在一些权限位和合法位，在进行页面的换入和换出的时候需要检查相应的权限位和合法位。

发生页访问异常时硬件的工作：

1，保存当前的异常原因，根据`stvec`的地址跳转到中断处理程序，就是`trap`函数

2，在`trap`函数中在`exception_handler`中根据异常的原因到`CAUSE_LOAD_ACCESS`中处理缺页异常。

3，接着会跳转到`pgfault_handler`，在其中的`do_pgfault`函数中实际来处理缺页的异常。

4，如果缺页异常处理完成，那么返回到异常处继续执行，如果缺页异常不能处理则输出`unhandled page fault`。

对应关系：

有对应的关系，`Page`用来记录所有分配的物理页面，页表项用来存储相应的虚拟地址到物理地址的映射，而页表项中映射的物理地址就对应`Page`中的一项，通过页表项存储的物理地址可以来索引`Page`得到其中的一页。

***

## 练习四

***

设计实现过程：

1，初始化链表，设置当前指针以及`mm`成员的`sm_priv`指针:

```c++
 list_init(&pra_list_head);
 curr_ptr = &pra_list_head;
 mm->sm_priv = &pra_list_head;
```

2，将可交换的页面page插入到页面链表pra_list_head的末尾并将页面的visited标志置为1，表示该页面已被访问：

```c++
list_add_before((list_entry_t*) mm->sm_priv,entry);
page->visited = 1;
```

3，遍历页面链表pra_list_head，查找最早未被访问的页面，如果当前页面未被访问，则将该页面从页面链表中删除，并将该页面指针赋值给ptr_page作为换出页面，如果当前页面已被访问，则将visited标志置为0，表示该页面已被重新访问：

```c++
 		curr_ptr = list_next(curr_ptr);
        if(curr_ptr == head) {
            curr_ptr = list_next(curr_ptr);
            if(curr_ptr == head) {
                *ptr_page = NULL;
                break;
            }
        }
        struct Page* page = le2page(curr_ptr, pra_page_link);
        if(!page->visited) {
            *ptr_page = page;
            list_del(curr_ptr);
            cprintf("curr_ptr %p\n",curr_ptr);
            break;
        } else {
            page->visited = 0;
        }
```

不同：

`FIFO`算法：设计一个链表，每次向访问页面的时候向链表的头部添加，每次要换出页面的时候选用链表的尾部页面替换出去。

`Clock`页替换算法：而Clock算法会在每次页面访问的时候向链表的尾部添加页面，同时将页面的visited属性置位1，在每次替换出页面的时候如果当前指针指向的页面visited属性为1，那么将该属性置位0，指针向后移动，直到寻找到一个页面的visited属性为0，那么将该页面替换出去。

***

## 练习五

***

优势：

内存的访问次数将会减少，一次访问就可以得到最终的物理地址；可以有效提高TLB的命中率，提高内存的利用率和访问速度。

劣势：

占用的内存过大，出错的可能行增加，页表的维护工作变得更加困难；因为大页涉及更大的内存块操作，所以在动态内存管理方面可能会带来一些开销和挑战。

## 扩展练习 Challenge

***

设计以及代码的实现：

`lru`算法就是管理按照最近一次访问的先后顺序排列的链表，最近访问时间近的页面使其排列在链表的头部，最近访问时间长的页面使其排列在链表的尾部，更新链表的时候主要有两个部分，若是访问的页面时硬盘上替换进来的页面，那么直接将其排在链表的首部，并断开与链表的尾部页面的连接，实现的代码如下：

```c++
static int
_lru_map_swappable(struct mm_struct *mm, uintptr_t addr, struct Page *page, int swap_in)
{
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
    list_entry_t *entry=&(page->pra_page_link);
 
    assert(entry != NULL && head != NULL);
    list_add((list_entry_t*) mm->sm_priv,entry);
    return 0;
}
static int
_lru_swap_out_victim(struct mm_struct *mm, struct Page ** ptr_page, int in_tick)
{
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
        assert(head != NULL);
    assert(in_tick==0);
    list_entry_t* entry = list_prev(head);
    if (entry != head) {
        list_del(entry);
        *ptr_page = le2page(entry, pra_page_link);
    } else {
        *ptr_page = NULL;
    }
    return 0;
}
```

第二种情况就是访问的页面是内存里的页面，那么要将链表中的这个页面删除并将其重新链接在链表的首部，为了实现每次访问内存里的页面都会触发重新排列，这里实现的时候将内存里的所有的页面都设为不可读的，那么访问内存里的任意一个页面都会出现`pg_fault`，转到实现的`lru_pgfault`中，在实现的`lru_pgfault`中会将该访问页面重新排列在链表的首部，实现的代码如下：

```c++
int lru_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
    cprintf("lru page fault at 0x%x\n", addr);
    // 设置所有页面不可读
    if(swap_init_ok) 
    {
    	 list_entry_t *head=(list_entry_t*) mm->sm_priv, *le = head;
	while ((le = list_prev(le)) != head)
	{
	struct Page* page = le2page(le, pra_page_link);
	pte_t* ptep = NULL;
	ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);
	*ptep &= ~PTE_R;
	}
    }
    // 将需要获得的页面设置为可读
    pte_t* ptep = NULL;
    ptep = get_pte(mm->pgdir, addr, 0);
    *ptep |= PTE_R;
    if(!swap_init_ok) 
    {
    	return 0;
    }  
    struct Page* page = pte2page(*ptep);
    // 将该页放在链表头部
    list_entry_t *head=(list_entry_t*) mm->sm_priv, *le = head;
    while ((le = list_prev(le)) != head)
    {
        struct Page* curr = le2page(le, pra_page_link);
        if(page == curr) {
            
            list_del(le);
            list_add(head, le);
            break;
        }
    }
    return 0;
}
```

测试用例以及相应的测试结果：

实验中使用的测试的样例如下：

```c++
static int
_lru_check_swap(void) {
    *(unsigned char *)0x3000 = 0x0c;
    assert(pgfault_num==4);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==4);
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==4);
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==5);
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==5);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==5);
    *(unsigned char *)0x2000 = 0x0b;
    assert(pgfault_num==5);
    *(unsigned char *)0x4000 = 0x0d;
    assert(pgfault_num==6);
    *(unsigned char *)0x5000 = 0x0e;
    assert(pgfault_num==6);
    *(unsigned char *)0x1000 = 0x0a;
    assert(pgfault_num==6);
    *(unsigned char *)0x4000 = 0x0d;
     assert(pgfault_num==6);
    *(unsigned char *)0x3000 = 0x0c;
     assert(pgfault_num==7);
    return 0;
}
```

运行得到的结果如下：

```
Store/AMO page fault
page fault at 0x00002000: K/W
lru page fault at 0x2000
Store/AMO page fault
page fault at 0x00005000: K/W
swap_out: i 0, store page in vaddr 0x4000 to disk swap entry 5
Store/AMO page fault
page fault at 0x00005000: K/W
lru page fault at 0x5000
Store/AMO page fault
page fault at 0x00004000: K/W
swap_out: i 0, store page in vaddr 0x3000 to disk swap entry 4
swap_in: load disk swap entry 5 with swap_page in vadr 0x4000
Store/AMO page fault
page fault at 0x00004000: K/W
lru page fault at 0x4000
Store/AMO page fault
page fault at 0x00003000: K/W
swap_out: i 0, store page in vaddr 0x1000 to disk swap entry 2
swap_in: load disk swap entry 4 with swap_page in vadr 0x3000
Store/AMO page fault
page fault at 0x00003000: K/W
lru page fault at 0x3000
count is 1, total is 8
check_swap() succeeded!
++ setup timer interrupts
100 ticks
100 ticks
100 ticks
100 ticks
```

从结果中可以看出运行的结果都通过了断言，是符合预期运行的结果的。







