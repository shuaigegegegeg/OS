#include <list.h>
#include <sync.h>
#include <proc.h>
#include <sched.h>
#include <assert.h>

// wakeup_proc函数用于将一个处于特定状态的进程设置为可运行（PROC_RUNNABLE）状态。
// 其参数是一个指向struct proc_struct类型的指针proc，表示要操作的目标进程。
void
wakeup_proc(struct proc_struct *proc) {
    // 使用断言来确保传入的进程当前状态既不是僵尸状态（PROC_ZOMBIE）也不是已经可运行状态（PROC_RUNNABLE）。
    // 因为如果是僵尸状态，说明进程已经结束等待回收资源，不应该再被唤醒；如果已经是可运行状态，也没必要再次设置为可运行状态，这里通过断言防止不合理的操作。
    assert(proc->state!= PROC_ZOMBIE && proc->state!= PROC_RUNNABLE);
    // 将目标进程的状态设置为可运行状态（PROC_RUNNABLE），意味着该进程现在可以被调度器选择并分配CPU时间来执行了。
    proc->state = PROC_RUNNABLE;
}

// schedule函数实现了进程调度的核心逻辑，用于选择下一个要运行的进程，并进行相应的切换操作。
void
schedule(void) {
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    // local_intr_save是一个用于保存当前中断状态并禁止中断的函数（具体实现应该在sync.h等相关头文件对应的源文件中）。
    // 这样做是为了保证进程调度过程的原子性，避免在调度过程中被外部中断打断，导致出现不一致的情况，将当前中断状态保存到intr_flag变量中。
    local_intr_save(intr_flag);
    {
        // 将当前运行进程（current指向的进程）的need_resched标志位设置为0，表示当前进程暂时不需要重新调度了（因为马上要进行调度操作了）。
        current->need_resched = 0;

        // 根据当前运行进程是否是空闲进程（idleproc）来确定从哪里开始查找下一个可运行进程。
        // 如果当前运行进程是空闲进程，那么就从全局的进程链表proc_list开始查找；否则从当前运行进程在进程链表中的节点（current->list_link）的下一个节点开始查找。
        // 这里通过这样的判断来实现一种循环查找的逻辑，确保所有进程都能被遍历到。
        last = (current == idleproc)? &proc_list : &(current->list_link);
        le = last;

        // 开始一个循环，遍历进程链表来查找下一个处于可运行状态（PROC_RUNNABLE）的进程。
        do {
            // 获取当前节点的下一个节点，如果下一个节点不是链表头（proc_list表示链表头），说明还没遍历完链表。
            if ((le = list_next(le))!= &proc_list) {
                // 将下一个节点对应的进程结构体指针获取出来，通过le2proc宏（其定义应该能将链表节点转换为对应的进程结构体指针，基于链表节点在进程结构体中的成员偏移等信息实现）。
                next = le2proc(le, list_link);
                // 判断获取到的这个进程是否处于可运行状态，如果是，则找到了合适的下一个要运行的进程，跳出循环。
                if (next->state == PROC_RUNNABLE) {
                    break;
                }
            }
        } while (le!= last);

        // 如果经过上述循环查找后，没有找到可运行的进程（next为NULL）或者找到的进程不是可运行状态（可能由于某些异常情况等），那么就将下一个要运行的进程设置为空闲进程（idleproc）。
        // 这意味着在没有其他合适进程可运行时，让空闲进程占用CPU，等待其他进程变为可运行状态。
        if (next == NULL || next->state!= PROC_RUNNABLE) {
            next = idleproc;
        }

        // 将找到的下一个要运行的进程（next指向的进程）的运行次数（runs）加1，可用于统计进程被调度运行的次数等相关用途，比如可能在一些调度算法中根据运行次数来决定后续的调度策略等。
        next->runs++;

        // 如果找到的下一个要运行的进程不是当前正在运行的进程（current指向的进程），就调用proc_run函数进行进程切换，将CPU控制权交给下一个进程。
        // proc_run函数内部会涉及到如保存当前进程上下文、恢复下一个进程上下文以及修改相关寄存器（比如CR3寄存器等）等操作来实现进程切换。
        if (next!= current) {
            proc_run(next);
        }
    }
    // local_intr_restore函数用于恢复之前保存的中断状态（由local_intr_save保存的状态），重新允许中断，使得系统可以正常响应外部中断了。
    local_intr_restore(intr_flag);
}