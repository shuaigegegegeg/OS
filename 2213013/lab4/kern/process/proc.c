#include <proc.h>
#include <kmalloc.h>
#include <string.h>
#include <sync.h>
#include <pmm.h>
#include <error.h>
#include <sched.h>
#include <elf.h>
#include <vmm.h>
#include <trap.h>
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

/* ------------- process/thread mechanism design&implementation -------------
(an simplified Linux process/thread mechanism )
introduction:
  ucore implements a simple process/thread mechanism. process contains the independent memory sapce, at least one threads
for execution, the kernel data(for management), processor state (for context switch), files(in lab6), etc. ucore needs to
manage all these details efficiently. In ucore, a thread is just a special kind of process(share process's memory).
这段注释主要介绍了 ucore 中实现的一个简易的进程/线程机制，说明了进程包含独立内存空间、至少一个用于执行的线程、内核管理数据、处理器状态（用于上下文切换）以及文件（在实验 6 中涉及）等内容，并且指出在 ucore 里线程是一种特殊的进程（共享进程内存）。
------------------------------
process state       :     meaning               -- reason
    PROC_UNINIT     :   uninitialized           -- alloc_proc
    PROC_SLEEPING   :   sleeping                -- try_free_pages, do_wait, do_sleep
    PROC_RUNNABLE   :   runnable(maybe running) -- proc_init, wakeup_proc, 
    PROC_ZOMBIE     :   almost dead             -- do_exit
这段注释解释了进程的几种状态及其含义和状态改变对应的相关函数，例如 PROC_UNINIT 表示未初始化，通常在 alloc_proc 函数中处于此状态；PROC_SLEEPING 表示睡眠状态，在 try_free_pages、do_wait、do_sleep 等操作时进入该状态等。
-----------------------------
process state changing:
                                            
  alloc_proc                                 RUNNING
      +                                   +--<----<--+
      +                                   + proc_run +
      V                                   +-->---->--+ 
PROC_UNINIT -- proc_init/wakeup_proc --> PROC_RUNNABLE -- try_free_pages/do_wait/do_sleep --> PROC_SLEEPING --
                                           A      +                                                           +
                                           |      +--- do_exit --> PROC_ZOMBIE                                +
                                           +                                                                  + 
                                           -----------------------wakeup_proc----------------------------------
以图形化（类似流程图）的方式展示了进程状态的变化流程，比如从 PROC_UNINIT 状态通过 proc_init 或 wakeup_proc 函数可转变为 PROC_RUNNABLE 状态，然后再通过不同操作转变到其他相应状态等。
-----------------------------
process relations
parent:           proc->parent  (proc is children)
children:         proc->cptr    (proc is parent)
older sibling:    proc->optr    (proc is younger sibling)
younger sibling:  proc->yptr    (proc is older sibling)
介绍了进程之间关系相关的成员变量，比如通过 proc->parent 可以获取进程的父进程，不过代码中目前只看到了对父进程指针的使用，其他如 cptr、optr、yptr 相关代码未完整呈现，可能在更完整的实现中有对应作用。
-----------------------------
related syscall for process:
SYS_exit        : process exit,                           -->do_exit
SYS_fork        : create child process, dup mm            -->do_fork-->wakeup_proc
SYS_wait        : wait process                            -->do_wait
SYS_exec        : after fork, process execute a program   -->load a program and refresh the mm
SYS_clone       : create child thread                     -->do_fork-->wakeup_proc
SYS_yield       : process flag itself need resecheduling, -- proc->need_sched=1, then scheduler will rescheule this process
SYS_sleep       : process sleep                           -->do_sleep 
SYS_kill        : kill process                            -->do_kill-->proc->flags |= PF_EXITING
                                                                 -->wakeup_proc-->do_wait-->do_exit   
SYS_getpid      : get the process's pid
列举了与进程相关的系统调用以及它们对应的实现函数，比如 SYS_exit 系统调用对应 do_exit 函数来实现进程退出功能等，说明了系统调用和具体函数实现之间的关联。
*/

// the process set's list，定义一个全局的双向链表头，用于管理所有的进程结构体，通过 list_link 成员将各个进程控制块链接到这个链表中
list_entry_t proc_list; 

#define HASH_SHIFT          10
#define HASH_LIST_SIZE      (1 << HASH_SHIFT)
#define pid_hashfn(x)       (hash32(x, HASH_SHIFT))
// 定义哈希表相关的参数，HASH_SHIFT 用于确定哈希表的大小，HASH_LIST_SIZE 就是哈希表的实际大小（这里是 2 的 10 次方），pid_hashfn 是一个根据进程 ID 计算哈希值的函数（依赖 hash32 函数，可能在其他地方定义）

// has list for process set based on pid，定义一个静态的数组，用于作为基于进程 ID 的哈希表，每个元素是一个链表头，用于存放具有相同哈希值的进程控制块（通过 hash_link 成员链接）
static list_entry_t hash_list[HASH_LIST_SIZE]; 

// idle proc，定义一个指向空闲进程结构体的指针，初始化为 NULL，空闲进程通常在系统没有其他可运行进程时占用 CPU
struct proc_struct *idleproc = NULL; 
// init proc，定义一个指向初始进程结构体的指针，初始化为 NULL，初始进程往往是系统启动后创建的第一个有实际意义的进程（后续可能用于创建用户态进程等）
struct proc_struct *initproc = NULL; 
// current proc，定义一个指向当前正在运行的进程结构体的指针，初始化为 NULL，随着进程切换，该指针会指向不同的正在运行的进程
struct proc_struct *current = NULL; 

static int nr_process = 0; // 用于记录当前系统中进程的数量

// 函数声明，这是内核线程的入口函数，具体实现应该在其他地方定义，内核线程启动后会从这里开始执行
void kernel_thread_entry(void); 
// 函数声明，具体功能未知，但应该和新线程/进程启动后的一些处理相关（可能和 fork 操作后的返回处理有关），参数是一个陷阱帧结构体指针
void forkrets(struct trapframe *tf); 
// 函数声明，用于在两个进程上下文之间进行切换，参数是两个上下文结构体指针，分别表示源进程上下文和目标进程上下文
void switch_to(struct context *from, struct context *to); 

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
// 该函数用于分配一个进程结构体并初始化其所有字段
static struct proc_struct *
alloc_proc(void) {
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct)); // 从内核内存中分配一个进程结构体大小的内存空间
    if (proc!= NULL) {
        //LAB4:EXERCISE1 YOUR CODE
        /*
         * below fields in proc_struct need to be initialized
         *       enum proc_state state;                      // Process state
         *       int pid;                                    // Process ID
         *       int runs;                                   // the running times of Proces
         *       uintptr_t kstack;                           // Process kernel stack
         *       volatile bool need_resched;                 // bool value: need to be rescheduled to release CPU?
         *       struct proc_struct *parent;                 // the parent process
         *       struct mm_struct *mm;                       // Process's memory management field
         *       struct context context;                     // Switch here to run process
         *       struct trapframe *tf;                       // Trap frame for current interrupt
         *       uintptr_t cr3;                              // CR3 register: the base addr of Page Directroy Table(PDT)
         *       uint32_t flags;                             // Process flag
         *       char name[PROC_NAME_LEN + 1];               // Process name
         */
        proc->state = PROC_UNINIT; // 将进程状态初始化为未初始化状态
        proc->pid = -1; // 初始时进程 ID 设为 -1，表示还未分配有效的 ID
        proc->runs = 0; // 运行次数初始化为 0
        proc->kstack = 0; // 内核栈地址初始化为 0，后续会进行实际分配
        proc->need_resched = 0; // 是否需要重新调度标志初始化为 false，即当前不需要重新调度
        proc->parent = NULL; // 父进程指针初始化为 NULL，后续在创建进程时会设置
        proc->mm = NULL; // 内存管理相关的结构体指针初始化为 NULL，可能在内存相关操作时进行赋值
        memset(&(proc->context), 0, sizeof(struct context)); // 将进程上下文结构体的内容清零，确保初始状态干净
        proc->tf = NULL; // 陷阱帧指针初始化为 NULL，在相关中断等场景下会进行设置
        proc->cr3 = boot_cr3; // 将 CR3 寄存器的值设置为启动时的 CR3 值（boot_cr3 应该是在其他地方定义的全局变量，表示初始的页目录表基址）
        proc->flags = 0; // 进程标志初始化为 0，可用于后续设置各种进程相关的标志位
        memset(proc->name, 0, PROC_NAME_LEN + 1); // 将进程名字字符数组清零，方便后续设置名字

    }
    return proc;
}

// set_proc_name - set the name of proc
// 该函数用于设置进程的名字，将传入的名字复制到进程结构体的 name 成员数组中
char *
set_proc_name(struct proc_struct *proc, const char *name) {
    memset(proc->name, 0, sizeof(proc->name)); // 先将原名字清零
    return memcpy(proc->name, name, PROC_NAME_LEN); // 复制新名字到进程名字数组中，最多复制 PROC_NAME_LEN 个字符，并返回进程名字数组指针
}

// get_proc_name - get the name of proc
// 该函数用于获取进程的名字，将进程结构体中的名字复制到一个静态的字符数组中并返回该数组指针
char *
get_proc_name(struct proc_struct *proc) {
    static char name[PROC_NAME_LEN + 1];
    memset(name, 0, sizeof(name));
    return memcpy(name, proc->name, PROC_NAME_LEN);
}

// get_pid - alloc a unique pid for process
// 该函数用于为进程分配一个唯一的进程 ID
static int
get_pid(void) {
    static_assert(MAX_PID > MAX_PROCESS); // 静态断言，确保最大进程 ID 大于最大进程数量，用于合法性检查
    struct proc_struct *proc;
    list_entry_t *list = &proc_list, *le;
    static int next_safe = MAX_PID, last_pid = MAX_PID;
    if (++ last_pid >= MAX_PID) { // 如果上次分配的进程 ID 达到了最大进程 ID，就重置为 1
        last_pid = 1;
        goto inside;
    }
    if (last_pid >= next_safe) {
    inside:
        next_safe = MAX_PID;
    repeat:
        le = list;
        while ((le = list_next(le))!= list) {
            proc = le2proc(le, list_link);
            if (proc->pid == last_pid) { // 如果找到已有进程使用了当前尝试分配的 ID
                if (++ last_pid >= next_safe) {
                    if (last_pid >= MAX_PID) {
                        last_pid = 1;
                    }
                    next_safe = MAX_PID;
                    goto repeat; // 继续尝试下一个 ID
                }
            }
            else if (proc->pid > last_pid && next_safe > proc->pid) {
                next_safe = proc->pid; // 更新下一个安全的可分配 ID 范围
            }
        }
    }
    return last_pid;
}

// proc_run - make process "proc" running on cpu
// 该函数用于使指定的进程在 CPU 上运行，涉及到进程上下文切换等操作
// NOTE: before call switch_to, should load  base addr of "proc"'s new PDT
void
proc_run(struct proc_struct *proc) {
    if (proc!= current) {
        // LAB4:EXERCISE3 YOUR CODE
        /*
        * Some Useful MACROs, Functions and DEFINEs, you can use them in below implementation.
        * MACROs or Functions:
        *   local_intr_save():        Disable interrupts
        *   local_intr_restore():     Enable Interrupts
        *   lcr3():                   Modify the value of CR3 register
        *   switch_to():              Context switching between two processes
        */
        bool intr_flag;
        struct proc_struct *prev = current, *next = proc;
        local_intr_save(intr_flag); // 先禁止中断，保证进程切换操作的原子性，避免被中断干扰，保存当前中断状态到 intr_flag
        {
            current = proc; // 更新当前运行进程指针为要切换到的进程
            lcr3(next->cr3); // 修改 CR3 寄存器的值为目标进程的页目录表基址，以便切换到正确的内存空间
            switch_to(&(prev->context), &(next->context)); // 进行进程上下文切换，从当前进程上下文切换到目标进程上下文
        }
        local_intr_restore(intr_flag); // 恢复之前保存的中断状态，重新允许中断
    }
}

// forkret -- the first kernel entry point of a new thread/process
// 该函数是新线程/进程在内核中的第一个入口点，在 switch_to 切换后，当前进程会执行到这里
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf); // 调用 forkrets 函数，传入当前进程的陷阱帧指针，进行后续相关处理（具体功能由 forkrets 函数定义）
}

// hash_proc - add proc into proc hash_list
// 该函数用于将进程添加到基于进程 ID 的哈希表中，通过 pid_hashfn 计算哈希值找到对应的链表并插入
static void
hash_proc(struct proc_struct *proc) {
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
}

// find_proc - find proc frome proc hash_list according to pid
// 该函数根据给定的进程 ID 从哈希表中查找对应的进程结构体指针，如果找到则返回该指针，否则返回 NULL
struct proc_struct *
find_proc(int pid) {
    if (0 < pid && pid < MAX_PID) {
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
        while ((le = list_next(le))!= list) {
            struct proc_struct *proc = le2proc(le, hash_link);
            if (proc->pid == pid) {
                return proc;
            }
        }
    }
    return NULL;
}

// kernel_thread - create a kernel thread using "fn" function
// 该函数用于创建一个内核线程，通过传入的函数指针、参数以及克隆标志等信息来创建，最终调用 do_fork 函数实现创建过程
// NOTE: the contents of temp trapframe tf will be copied to 
//       proc->tf in do_fork-->copy_thread function
int
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
    struct trapframe tf;
    memset(&tf, 0, sizeof(struct trapframe));
    tf.gpr.s0 = (uintptr_t)fn; // 将传入的函数指针赋值给陷阱帧的 s0 寄存器相关字段，用于后续执行线程时调用函数
    tf.gpr.s1 = (uintptr_t)arg; // 将传入的参数指针赋值给陷阱帧的 s1 寄存器相关字段，传递给线程函数的参数
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE; // 设置陷阱帧的状态字段，涉及一些处理器状态相关的设置（依赖 read_csr 等函数，可能在其他地方定义）
    tf.epc = (uintptr_t)kernel_thread_entry; // 设置陷阱帧的程序计数器字段，指向内核线程的入口函数地址
    return do_fork(clone_flags | CLONE_VM, 0, &tf); // 调用 do_fork 函数创建线程，传入克隆标志（添加了 CLONE_VM 标志）、栈指针（这里为 0 表示创建内核线程）以及陷阱帧指针
}

// setup_kstack - alloc pages with size KSTACKPAGE as process kernel stack
// 该函数用于为进程分配指定大小（KSTACKPAGE）的内核栈内存空间，返回成功或失败的状态码
static int
setup_kstack(struct proc_struct *proc) {
    struct Page *page = alloc_pages(KSTACKPAGE); // 调用 alloc_pages 函数分配内存页（具体实现可能在内存管理相关代码中）
    if (page!= NULL) {
        proc->kstack = (uintptr_t)page2kva(page); // 将分配到的内存页转换为内核虚拟地址，并赋值给进程的内核栈地址成员
        return 0; // 返回成功状态码 0
    }
    return -E_NO_MEM; // 如果分配失败，返回表示无内存的错误码
}

// put_kstack - free the memory space of process kernel stack
// 该函数的作用是释放进程的内核栈内存空间，它接收一个指向 `struct proc_struct` 类型的指针 `proc`，通过这个指针获取进程内核栈相关信息来执行释放操作。
static void
put_kstack(struct proc_struct *proc) {
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
    // 解释如下：
    // 1. kva2page 函数：
    //    它的作用应该是将内核虚拟地址（Kernel Virtual Address，KVA）转换为对应的物理内存页相关的表示形式（可能是 `struct Page` 结构体类型，具体取决于相关定义）。
    //    在这里，它以进程的内核栈地址 `proc->kstack`（这个地址是之前分配内核栈内存时得到的内核虚拟地址）作为参数，目的是获取该内核栈对应的物理内存页相关描述结构，以便后续释放操作能够基于物理内存层面进行处理。
    // 2. free_pages 函数：
    //    它用于释放指定的物理内存页，接收两个参数，第一个参数是通过 `kva2page` 转换得到的表示内存页的相关结构（比如指向内存页结构体的指针等），第二个参数 `KSTACKPAGE` 表示要释放的内存页数量。
    //    整体来说，这行代码就是先根据进程内核栈的虚拟地址找到对应的物理内存页描述结构，然后调用 `free_pages` 函数来释放相应数量（`KSTACKPAGE` 定义的数量）的物理内存页，从而完成对进程内核栈内存空间的释放操作，回收内存以供其他进程等使用。
}
// copy_mm - process "proc" duplicate OR share process "current"'s mm according clone_flags
//         - if clone_flags & CLONE_VM, then "share" ; else "duplicate"
// 这个函数用于根据传入的克隆标志 `clone_flags` 来决定进程 `proc` 是复制还是共享当前进程（`current`）的内存管理相关内容（通过 `mm` 结构体表示）。
// 如果 `clone_flags` 与 `CLONE_VM` 进行按位与运算结果为真，意味着要共享内存；否则就需要进行复制操作（不过当前代码注释表示在这个项目里暂时没做实际的复制操作，只是返回 0）。
static int
copy_mm(uint32_t clone_flags, struct proc_struct *proc) {
    assert(current->mm == NULL);
    /* do nothing in this project */
    return 0;
}

// copy_thread - setup the trapframe on the  process's kernel stack top and
//             - setup the kernel entry point and stack of process
// 此函数用于在新进程（由 `proc` 参数表示）的内核栈顶部设置陷阱帧（`trapframe`）相关内容，并且设置该进程的内核入口点以及栈相关信息，为新进程后续在内核中的执行做准备。
static void
copy_thread(struct proc_struct *proc, uintptr_t esp, struct trapframe *tf) {
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE - sizeof(struct trapframe));
    // 首先，计算出陷阱帧在进程内核栈中的位置，将进程内核栈地址 `proc->kstack` 加上内核栈总大小 `KSTACKSIZE`，再减去 `trapframe` 结构体的大小，得到的地址赋值给进程的 `tf` 成员，即让进程的陷阱帧指针指向内核栈中合适的位置，用于存放陷阱帧相关信息。

    *(proc->tf) = *tf;
    // 把传入的陷阱帧结构体 `tf` 的内容复制到新进程对应的陷阱帧位置（即 `proc->tf` 指向的位置），这样新进程就有了初始的陷阱帧信息，比如寄存器状态等，可能是从父进程或者创建时的临时陷阱帧复制而来，具体取决于调用场景。

    // Set a0 to 0 so a child process knows it's just forked
    proc->tf->gpr.a0 = 0;
    // 将新进程陷阱帧中对应通用寄存器 `a0` 的值设置为 0，用于标识该进程是刚通过 `fork` 操作创建出来的子进程，可能在后续代码中通过检查这个寄存器的值来区分进程是新创建的还是其他情况，以此执行不同的逻辑。

    proc->tf->gpr.sp = (esp == 0)? (uintptr_t)proc->tf : esp;
    // 根据传入的栈指针参数 `esp` 的值来设置新进程陷阱帧中的栈指针 `gpr.sp`。如果 `esp` 为 0，则将栈指针设置为进程陷阱帧的地址（也就是使用刚刚设置好的陷阱帧所在位置作为栈顶）；否则就使用传入的 `esp` 值作为栈指针，这样就确定了新进程在内核态运行时的初始栈指针位置。

    proc->context.ra = (uintptr_t)forkret;
    // 设置新进程上下文结构体中的返回地址寄存器（`ra`）的值为 `forkret` 函数的地址，这样当该进程开始运行时，执行完其他准备工作后会跳转到 `forkret` 函数继续执行，`forkret` 函数通常是新进程在内核中的入口逻辑后续部分。

    proc->context.sp = (uintptr_t)(proc->tf);
    // 将新进程上下文结构体中的栈指针寄存器（`sp`）的值设置为进程陷阱帧的地址，使得进程上下文的栈指针指向陷阱帧所在位置，与前面设置的陷阱帧相关内容相匹配，确保进程在切换到运行状态时栈相关操作的正确性。
}

/* do_fork -     parent process for a new child process
 * @clone_flags: used to guide how to clone the child process
 * @stack:       the parent's user stack pointer. if stack==0, It means to fork a kernel thread.
 * @tf:          the trapframe info, which will be copied to child process's proc->tf
 */
// `do_fork` 函数用于实现创建一个新的子进程的功能，由父进程调用，通过传入不同的参数来控制子进程的创建方式、共享或复制相关资源等情况，并且进行一系列初始化和状态设置操作，最后返回子进程的进程 ID 或者错误码。
int
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS) {
        goto fork_out;
    }
    ret = -E_NO_MEM;
    //LAB4:EXERCISE2 YOUR CODE
    /*
     * Some Useful MACROs, Functions and DEFINEs, you can use them in below implementation.
     * MACROs or Functions:
     *   alloc_proc:   create a proc struct and init fields (lab4:exercise1)
     *   setup_kstack: alloc pages with size KSTACKPAGE as process kernel stack
     *   copy_mm:      process "proc" duplicate OR share process "current"'s mm according clone_flags
     *                 if clone_flags & CLONE_VM, then "share" ; else "duplicate"
     *   copy_thread:  setup the trapframe on the  process's kernel stack top and
     *                 setup the kernel entry point and stack of process
     *   hash_proc:    add proc into proc hash_list
     *   get_pid:      alloc a unique pid for process
     *   wakeup_proc:  set proc->state = PROC_RUNNABLE
     * VARIABLES:
     *   proc_list:    the process set's list
     *   nr_process:   the number of process set
     */

    //    1. call alloc_proc to allocate a proc_struct
    // 首先调用 `alloc_proc` 函数分配一个新的进程结构体，并进行基本的字段初始化，得到一个新的 `proc` 结构体指针，代表新创建的子进程。
    proc = alloc_proc();
    proc->parent = current;
    // 将新进程的父进程指针设置为当前正在运行的进程（也就是调用 `do_fork` 的父进程），建立父子进程关系。

    //    2. call setup_kstack to allocate a kernel stack for child process
    // 调用 `setup_kstack` 函数为新创建的子进程分配内核栈内存空间，如果分配失败会根据后续代码逻辑进行相应的错误处理和资源清理。
    setup_kstack(proc);

    //    3. call copy_mm to dup OR share mm according clone_flag
    // 根据传入的克隆标志 `clone_flags` 调用 `copy_mm` 函数决定新进程是复制还是共享当前进程的内存管理相关内容（这里目前只是简单返回 0，没实际做复杂操作）。
    copy_mm(clone_flags, proc);

    //    4. call copy_thread to setup tf & context in proc_struct
    // 调用 `copy_thread` 函数在新进程的内核栈上设置陷阱帧以及进程上下文相关信息，为新进程的执行做好准备，比如设置入口点、栈指针等关键内容。
    copy_thread(proc, stack, tf);

    //    5. insert proc_struct into hash_list && proc_list
    // 调用 `hash_proc` 函数将新创建的进程结构体添加到基于进程 ID 的哈希表中，方便后续根据 ID 快速查找进程。
    int pid = get_pid();
    proc->pid = pid;
    hash_proc(proc);
    list_add(&proc_list, &(proc->list_link));
    // 同时将新进程结构体添加到全局的进程链表 `proc_list` 中，用于遍历所有进程等操作。

    //    6. call wakeup_proc to make the new child process RUNNABLE
    // 调用 `wakeup_proc` 函数将新进程的状态设置为 `PROC_RUNNABLE`，表示新进程已经准备好可以被调度运行了。
    nr_process++;
    proc->state = PROC_RUNNABLE;

    //    7. set ret vaule using child proc's pid
    ret = proc->pid;
    // 将返回值 `ret` 设置为新创建的子进程的进程 ID，表示 `do_fork` 操作成功，返回新子进程的 ID，外部调用者可以根据这个 ID 来对新进程进行进一步操作等。

    

fork_out:
    return ret;

bad_fork_cleanup_kstack:
    put_kstack(proc);
    // 如果在创建子进程过程中出现问题（比如内存分配失败等），需要调用 `put_kstack` 函数释放已经分配给子进程的内核栈内存空间，避免内存泄漏。

bad_fork_cleanup_proc:
    kfree(proc);
    // 调用 `kfree` 函数释放已经分配给子进程的进程结构体内存空间，进一步清理资源，然后跳转到 `fork_out` 处返回错误码。
    goto fork_out;
}

// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
// 该函数用于处理进程退出相关操作，通常由 `sys_exit` 系统调用触发，主要执行以下几个关键步骤：
// 首先调用一些内存相关的释放函数（这里代码中 `exit_mmap`、`put_pgdir`、`mm_destroy` 等函数未给出具体实现，但推测是用于释放进程所占用的各种内存资源）来回收进程几乎所有的内存空间。
// 然后将进程的状态设置为 `PROC_ZOMBIE`（僵尸状态），表示进程已经结束但还未被父进程回收资源，接着调用 `wakeup_proc` 函数唤醒父进程（通过传入父进程指针等方式，这里未明确体现参数传递情况），告知父进程可以来回收自己了。
// 最后调用调度器相关函数（这里 `scheduler` 函数未给出具体实现），让系统切换到其他可运行的进程继续执行，释放当前进程占用的 CPU 资源。
int
do_exit(int error_code) {
    panic("process exit!!.\n");
    // 当前代码只是简单地触发一个 `panic`，可能表示这里还需要进一步完善具体的退出逻辑实现，真正执行上述提到的那些内存释放、状态设置和调度切换等操作，目前这样直接 `panic` 只是一种临时的占位或者调试相关的提示表示进程退出操作被调用了但还没正确实现。
}

// init_main - the second kernel thread used to create user_main kernel threads
// 这是一个作为第二个内核线程的函数，用于创建用户态的 `user_main` 内核线程（不过这里 `user_main` 未明确具体实现和细节），可能在系统启动初始化等阶段发挥作用，用于进一步构建系统的运行环境，启动相关的用户态任务等。
static int
init_main(void *arg) {
    cprintf("this initproc, pid = %d, name = \"%s\"\n", current->pid, get_proc_name(current));
    cprintf("To U: \"%s\".\n", (const char *)arg);
    cprintf("To U: \"en.., Bye, Bye. :)\"\n");
    return 0;
}

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
// 这个函数用于进行系统的进程相关初始化操作，主要完成以下两个关键事项：
// 一是设置并初始化第一个内核线程 `idleproc`（空闲进程），对其各种字段进行赋值和检查，确保空闲进程结构体的初始化状态正确，比如设置进程 ID 为 0，状态为 `PROC_RUNNABLE`，内核栈地址等相关字段也进行合适的设置，并将其名字设置为 "idle"，同时增加进程数量统计值 `nr_process`。
// 二是通过调用 `kernel_thread` 函数创建第二个内核线程 `init_main`，用于后续进一步的系统初始化或者启动用户态相关操作等，如果创建失败会触发 `panic`，创建成功后找到对应的进程结构体并将其赋值给 `initproc`，同时设置其名字为 "init"，最后进行一些断言检查确保 `idleproc` 和 `initproc` 的进程 ID 等关键信息符合预期。
void
proc_init(void) {
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
        list_init(hash_list + i);
    }
    // 首先初始化全局的进程链表 `proc_list` 以及哈希表中每个链表（通过循环对 `hash_list` 数组中的每个元素对应的链表进行初始化操作），为后续添加和管理进程做准备。

    if ((idleproc = alloc_proc()) == NULL) {
        panic("cannot alloc idleproc.\n");
    }
    // 尝试分配空闲进程结构体，如果分配失败则触发 `panic`，表示无法分配空闲进程，这是比较严重的初始化错误，因为空闲进程对于系统正常运行很重要，在没有其他可运行进程时需要它占用 CPU。

    // check the proc structure
    int *context_mem = (int*) kmalloc(sizeof(struct context));
    memset(context_mem, 0, sizeof(struct context));
    int context_init_flag = memcmp(&(idleproc->context), context_mem, sizeof(struct context));

    int *proc_name_mem = (int*) kmalloc(PROC_NAME_LEN);
    memset(proc_name_mem, 0, PROC_NAME_LEN);
    int proc_name_flag = memcmp(&(idleproc->name), proc_name_mem, PROC_NAME_LEN);

    if(idleproc->cr3 == boot_cr3 && idleproc->tf == NULL &&!context_init_flag
        && idleproc->state == PROC_UNINIT && idleproc->pid == -1 && idleproc->runs == 0
        && idleproc->kstack == 0 && idleproc->need_resched == 0 && idleproc->parent == NULL
        && idleproc->mm == NULL && idleproc->flags == 0 &&!proc_name_flag
    ){
        cprintf("alloc_proc() correct!\n");

    }
    // 这段代码通过分配临时内存空间并清零，然后使用 `memcmp` 函数比较空闲进程结构体中的 `context` 和 `name` 等字段与清零后的临时内存空间，以此来检查 `alloc_proc` 函数对空闲进程结构体初始化是否符合预期，如果所有比较条件都满足（即初始化后的字段值与期望的初始值一致），则打印提示信息表示 `alloc_proc` 函数初始化正确。

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
    set_proc_name(idleproc, "idle");
    nr_process ++;
    // 对空闲进程结构体的关键字段进行赋值，设置进程 ID 为 0，状态为 `PROC_RUNNABLE`，内核栈地址为 `bootstack`（这里 `bootstack` 应该是一个全局定义的表示启动时栈相关内容的变量），设置需要重新调度标志为 1（表示空闲进程可以根据调度情况让出 CPU），设置进程名字为 "idle"，同时增加进程数量统计值。

    current = idleproc;
    // 将当前运行进程指针 `current` 设置为空闲进程，因为在系统初始化阶段，最初就是空闲进程在运行（或者等待运行，取决于调度情况

    int pid = kernel_thread(init_main, "Hello world!!", 0);
    // 调用 `kernel_thread` 函数创建第二个内核线程，传入 `init_main` 函数指针作为新线程要执行的函数，传入字符串 "Hello world!!" 作为参数（具体该参数在 `init_main` 函数中的使用情况前面已介绍），克隆标志设置为 0（这里根据 `kernel_thread` 函数的逻辑和具体需求传入合适的标志值，0 可能表示默认的创建方式等）。
    if (pid <= 0) {
        panic("create init_main failed.\n");
    }
    // 如果创建 `init_main` 内核线程返回的进程 ID 小于等于 0，表示创建失败，触发 `panic`，因为这个内核线程对于系统后续的初始化以及正常启动等操作很关键，创建失败意味着系统无法按预期继续构建运行环境。

    initproc = find_proc(pid);
    // 通过调用 `find_proc` 函数，根据刚创建的内核线程的进程 ID 查找对应的进程结构体指针，并赋值给 `initproc`，以便后续对这个 `init` 进程（也就是 `init_main` 对应的进程）进行操作，比如设置名字等。

    set_proc_name(initproc, "init");
    // 调用 `set_proc_name` 函数为 `initproc` 进程设置名字为 "init"，方便后续识别和管理该进程。

    assert(idleproc!= NULL && idleproc->pid == 0);
    assert(initproc!= NULL && initproc->pid == 1);
    // 进行两个断言检查，第一个断言确保空闲进程 `idleproc` 不为 `NULL` 且其进程 ID 为 0，符合空闲进程的预期设置；第二个断言确保 `initproc` 不为 `NULL` 且其进程 ID 为 1，因为它是系统创建的第二个有实际意义的进程（第一个是空闲进程，ID 为 0），这样通过断言来保证关键进程的初始化和属性设置符合预期，有助于发现可能的错误和问题，增强系统的稳定性和可靠性。
}

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
// 这个函数定义了空闲进程 `idleproc` 在系统内核初始化结束后（比如在 `kern_init` 函数执行完相关初始化操作后）所执行的工作，通常用于在系统没有其他可运行进程或者当前运行进程主动让出 CPU 等情况下，让空闲进程占用 CPU 并等待进一步的任务到来或者系统事件触发等情况。
void
cpu_idle(void) {
    while (1) {
        if (current->need_resched) {
            schedule();
        }
    }
    // 这里是一个无限循环，空闲进程会一直循环检查当前进程（也就是它自己，因为通常是空闲进程在执行这个函数）的 `need_resched` 标志位（表示是否需要重新调度）。
    // 当 `need_resched` 标志位为真时，调用 `schedule` 函数（这里 `schedule` 函数未给出具体实现，但推测是用于进行进程调度的核心函数，会根据一定的调度算法选择下一个要运行的进程，并进行进程上下文切换等操作），这样空闲进程就会让出 CPU，让调度器选择其他可运行的进程来运行；如果 `need_resched` 标志位为假，就继续循环检查该标志位，保持空闲状态等待调度。
}