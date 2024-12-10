// 这是一个条件编译指令，用于防止头文件被重复包含。如果 __KERN_PROCESS_PROC_H__ 这个宏没有被定义过，
// 则下面的代码会被编译，直到遇到 #endif。如果已经定义过了，那么从 #ifndef 到 #endif 之间的内容会被跳过。
#ifndef __KERN_PROCESS_PROC_H__
#define __KERN_PROCESS_PROC_H__

// 包含一些自定义的头文件，可能包含了一些基本的数据类型定义、通用的结构体定义、与中断陷阱相关的内容以及内存布局相关的定义等
#include <defs.h>
#include <list.h>
#include <trap.h>
#include <memlayout.h>

// process's state in his life cycle
// 定义进程在其生命周期中的状态枚举类型
enum proc_state {
    PROC_UNINIT = 0,  // 进程未初始化状态
    PROC_SLEEPING,    // 进程处于睡眠状态，可能正在等待某些资源等情况
    PROC_RUNNABLE,    // 进程处于可运行状态（有可能正在运行）
    PROC_ZOMBIE,      // 进程几乎死亡，等待父进程回收其资源的状态
};

// 定义进程上下文结构体，用于保存进程切换时相关寄存器等上下文信息
struct context {
    uintptr_t ra;    // 返回地址寄存器相关内容
    uintptr_t sp;    // 栈指针寄存器相关内容
    uintptr_t s0;
    uintptr_t s1;
    uintptr_t s2;
    uintptr_t s3;
    uintptr_t s4;
    uintptr_t s5;
    uintptr_t s6;
    uintptr_t s7;
    uintptr_t s8;
    uintptr_t s9;
    uintptr_t s10;
    uintptr_t s11;
};

// 定义进程名字的最大长度
#define PROC_NAME_LEN               15
// 定义系统中最大允许的进程数量
#define MAX_PROCESS                 4096
// 定义最大的进程ID值，是最大进程数量的两倍（具体用途可能与进程ID分配等机制有关）
#define MAX_PID                     (MAX_PROCESS * 2)

// 声明一个全局的链表头，用于管理进程链表，具体的链表节点类型应该是 struct proc_struct，
// 外部文件可以通过这个全局变量来操作进程链表（例如遍历、插入、删除进程节点等操作）
extern list_entry_t proc_list;

// 定义进程结构体，用于描述进程的各种属性和相关信息
struct proc_struct {
    enum proc_state state;                      // 进程的当前状态，使用前面定义的 proc_state 枚举类型表示
    int pid;                                    // 进程的唯一标识符，即进程ID
    int runs;                                   // 进程已经运行的次数，可用于统计等相关用途
    uintptr_t kstack;                           // 进程内核栈的地址，用于内核态下进程相关操作的栈空间
    volatile bool need_resched;                 // 一个布尔值，表示是否需要重新调度，即是否需要释放CPU给其他进程
    struct proc_struct *parent;                 // 指向父进程的指针，用于建立进程间的父子关系
    struct mm_struct *mm;                       // 指向进程内存管理相关结构体的指针，用于管理进程的内存相关操作
    struct context context;                     // 进程上下文信息，用于进程切换时保存和恢复相关寄存器等内容
    struct trapframe *tf;                       // 用于处理当前中断相关的上下文信息,保存了进程的中断帧。当进程从用户空间跳进内核空间的时候，进程的执行状态被保存在了中断帧中（注意这里需要保存的执行状态数量不同于上下文切换）。系统调用可能会改变用户寄存器的值，我们可以通过调整中断帧来使得系统调用返回特定的值。
    uintptr_t cr3;                              // CR3寄存器的值，它是页表的基地址，与内存分页管理相关
    uint32_t flags;                             // 进程的一些标志位，可用于表示进程的特定属性等
    char name[PROC_NAME_LEN + 1];               // 进程的名字，以字符数组形式存储，长度由 PROC_NAME_LEN 定义
    list_entry_t list_link;                     // 用于将进程结构体链接到进程链表中的链表节点
    list_entry_t hash_link;                     // 可能用于将进程结构体链接到某个哈希表中的链表节点（具体看后续实现）
};

// 一个宏定义，用于将一个链表节点指针（le）转换为对应的进程结构体指针（struct proc_struct *）。
// 它通过给定的链表节点成员名（member）来进行转换，具体的实现依赖于 to_struct 这个可能在其他地方定义的宏或函数（应该是根据结构体成员的偏移量等信息来进行转换）
#define le2proc(le, member)         \
    to_struct((le), struct proc_struct, member)

// 声明三个全局的进程结构体指针，分别指向空闲进程、初始进程以及当前正在运行的进程。
// 外部文件可以访问和操作这些指针，以实现与这些特定进程相关的功能，比如获取当前进程的信息、启动初始进程等
extern struct proc_struct *idleproc, *initproc, *current;

// 函数原型声明，用于初始化进程相关的模块或数据结构，具体实现应该在对应的源文件中定义
void proc_init(void);
// 函数原型声明，用于启动（运行）指定的进程，将CPU控制权交给该进程等相关操作
void proc_run(struct proc_struct *proc);
// 函数原型声明，用于在内核中创建一个新的线程，接收线程执行的函数指针、函数参数以及一些克隆标志等参数
int kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags);

// 函数原型声明，用于设置指定进程的名字，返回值是进程名字的指针（可能用于后续的检查或其他操作）
char *set_proc_name(struct proc_struct *proc, const char *name);
// 函数原型声明，用于获取指定进程的名字，返回值是进程名字的指针
char *get_proc_name(struct proc_struct *proc);
// 函数原型声明，声明一个永不返回的函数（noreturn 属性），用于在CPU空闲时执行一些空闲相关的操作（比如等待中断等）
void cpu_idle(void) __attribute__((noreturn));

// 函数原型声明，根据给定的进程ID查找对应的进程结构体指针，如果找到则返回该指针，否则返回 NULL 等相应表示没找到的情况
struct proc_struct *find_proc(int pid);
// 函数原型声明，用于执行进程的 fork 操作，创建一个新的进程，接收克隆标志、栈地址以及陷阱帧指针等参数，返回新进程创建的结果（比如成功或失败等状态码）
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf);
// 函数原型声明，用于执行进程的退出操作，接收退出的错误码参数，进行进程资源回收等相关退出处理工作
int do_exit(int error_code);

// 结束条件编译指令的定义部分，如果前面的 #ifndef 条件成立，那么到这里整个头文件的定义结束
#endif /*!__KERN_PROCESS_PROC_H__ */