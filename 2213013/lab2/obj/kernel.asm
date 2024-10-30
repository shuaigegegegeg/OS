
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02052b7          	lui	t0,0xc0205
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000a:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc020000e:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200012:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200016:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200018:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc020001c:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200020:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200024:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	00006517          	auipc	a0,0x6
ffffffffc0200036:	fde50513          	addi	a0,a0,-34 # ffffffffc0206010 <slub_cache>
ffffffffc020003a:	00006617          	auipc	a2,0x6
ffffffffc020003e:	46e60613          	addi	a2,a2,1134 # ffffffffc02064a8 <end>
int kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
int kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	264010ef          	jal	ra,ffffffffc02012ae <memset>
    cons_init();  // init the console
ffffffffc020004e:	3fc000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200052:	00001517          	auipc	a0,0x1
ffffffffc0200056:	26e50513          	addi	a0,a0,622 # ffffffffc02012c0 <etext>
ffffffffc020005a:	090000ef          	jal	ra,ffffffffc02000ea <cputs>

    print_kerninfo();
ffffffffc020005e:	0dc000ef          	jal	ra,ffffffffc020013a <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200062:	402000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc0200066:	373000ef          	jal	ra,ffffffffc0200bd8 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006a:	3fa000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc020006e:	39a000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200072:	3e6000ef          	jal	ra,ffffffffc0200458 <intr_enable>



    /* do nothing */
    while (1)
ffffffffc0200076:	a001                	j	ffffffffc0200076 <kern_init+0x44>

ffffffffc0200078 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200078:	1141                	addi	sp,sp,-16
ffffffffc020007a:	e022                	sd	s0,0(sp)
ffffffffc020007c:	e406                	sd	ra,8(sp)
ffffffffc020007e:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200080:	3cc000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200084:	401c                	lw	a5,0(s0)
}
ffffffffc0200086:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200088:	2785                	addiw	a5,a5,1
ffffffffc020008a:	c01c                	sw	a5,0(s0)
}
ffffffffc020008c:	6402                	ld	s0,0(sp)
ffffffffc020008e:	0141                	addi	sp,sp,16
ffffffffc0200090:	8082                	ret

ffffffffc0200092 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200092:	1101                	addi	sp,sp,-32
ffffffffc0200094:	862a                	mv	a2,a0
ffffffffc0200096:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	00000517          	auipc	a0,0x0
ffffffffc020009c:	fe050513          	addi	a0,a0,-32 # ffffffffc0200078 <cputch>
ffffffffc02000a0:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a2:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a4:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a6:	533000ef          	jal	ra,ffffffffc0200dd8 <vprintfmt>
    return cnt;
}
ffffffffc02000aa:	60e2                	ld	ra,24(sp)
ffffffffc02000ac:	4532                	lw	a0,12(sp)
ffffffffc02000ae:	6105                	addi	sp,sp,32
ffffffffc02000b0:	8082                	ret

ffffffffc02000b2 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b2:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b4:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000b8:	8e2a                	mv	t3,a0
ffffffffc02000ba:	f42e                	sd	a1,40(sp)
ffffffffc02000bc:	f832                	sd	a2,48(sp)
ffffffffc02000be:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c0:	00000517          	auipc	a0,0x0
ffffffffc02000c4:	fb850513          	addi	a0,a0,-72 # ffffffffc0200078 <cputch>
ffffffffc02000c8:	004c                	addi	a1,sp,4
ffffffffc02000ca:	869a                	mv	a3,t1
ffffffffc02000cc:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000ce:	ec06                	sd	ra,24(sp)
ffffffffc02000d0:	e0ba                	sd	a4,64(sp)
ffffffffc02000d2:	e4be                	sd	a5,72(sp)
ffffffffc02000d4:	e8c2                	sd	a6,80(sp)
ffffffffc02000d6:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000d8:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000da:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000dc:	4fd000ef          	jal	ra,ffffffffc0200dd8 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e0:	60e2                	ld	ra,24(sp)
ffffffffc02000e2:	4512                	lw	a0,4(sp)
ffffffffc02000e4:	6125                	addi	sp,sp,96
ffffffffc02000e6:	8082                	ret

ffffffffc02000e8 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000e8:	a695                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ea <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ea:	1101                	addi	sp,sp,-32
ffffffffc02000ec:	e822                	sd	s0,16(sp)
ffffffffc02000ee:	ec06                	sd	ra,24(sp)
ffffffffc02000f0:	e426                	sd	s1,8(sp)
ffffffffc02000f2:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f4:	00054503          	lbu	a0,0(a0)
ffffffffc02000f8:	c51d                	beqz	a0,ffffffffc0200126 <cputs+0x3c>
ffffffffc02000fa:	0405                	addi	s0,s0,1
ffffffffc02000fc:	4485                	li	s1,1
ffffffffc02000fe:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200100:	34c000ef          	jal	ra,ffffffffc020044c <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200104:	00044503          	lbu	a0,0(s0)
ffffffffc0200108:	008487bb          	addw	a5,s1,s0
ffffffffc020010c:	0405                	addi	s0,s0,1
ffffffffc020010e:	f96d                	bnez	a0,ffffffffc0200100 <cputs+0x16>
    (*cnt) ++;
ffffffffc0200110:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200114:	4529                	li	a0,10
ffffffffc0200116:	336000ef          	jal	ra,ffffffffc020044c <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011a:	60e2                	ld	ra,24(sp)
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	6442                	ld	s0,16(sp)
ffffffffc0200120:	64a2                	ld	s1,8(sp)
ffffffffc0200122:	6105                	addi	sp,sp,32
ffffffffc0200124:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200126:	4405                	li	s0,1
ffffffffc0200128:	b7f5                	j	ffffffffc0200114 <cputs+0x2a>

ffffffffc020012a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012a:	1141                	addi	sp,sp,-16
ffffffffc020012c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020012e:	326000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200132:	dd75                	beqz	a0,ffffffffc020012e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200134:	60a2                	ld	ra,8(sp)
ffffffffc0200136:	0141                	addi	sp,sp,16
ffffffffc0200138:	8082                	ret

ffffffffc020013a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020013c:	00001517          	auipc	a0,0x1
ffffffffc0200140:	1a450513          	addi	a0,a0,420 # ffffffffc02012e0 <etext+0x20>
void print_kerninfo(void) {
ffffffffc0200144:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200146:	f6dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014a:	00000597          	auipc	a1,0x0
ffffffffc020014e:	ee858593          	addi	a1,a1,-280 # ffffffffc0200032 <kern_init>
ffffffffc0200152:	00001517          	auipc	a0,0x1
ffffffffc0200156:	1ae50513          	addi	a0,a0,430 # ffffffffc0201300 <etext+0x40>
ffffffffc020015a:	f59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020015e:	00001597          	auipc	a1,0x1
ffffffffc0200162:	16258593          	addi	a1,a1,354 # ffffffffc02012c0 <etext>
ffffffffc0200166:	00001517          	auipc	a0,0x1
ffffffffc020016a:	1ba50513          	addi	a0,a0,442 # ffffffffc0201320 <etext+0x60>
ffffffffc020016e:	f45ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200172:	00006597          	auipc	a1,0x6
ffffffffc0200176:	e9e58593          	addi	a1,a1,-354 # ffffffffc0206010 <slub_cache>
ffffffffc020017a:	00001517          	auipc	a0,0x1
ffffffffc020017e:	1c650513          	addi	a0,a0,454 # ffffffffc0201340 <etext+0x80>
ffffffffc0200182:	f31ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200186:	00006597          	auipc	a1,0x6
ffffffffc020018a:	32258593          	addi	a1,a1,802 # ffffffffc02064a8 <end>
ffffffffc020018e:	00001517          	auipc	a0,0x1
ffffffffc0200192:	1d250513          	addi	a0,a0,466 # ffffffffc0201360 <etext+0xa0>
ffffffffc0200196:	f1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019a:	00006597          	auipc	a1,0x6
ffffffffc020019e:	70d58593          	addi	a1,a1,1805 # ffffffffc02068a7 <end+0x3ff>
ffffffffc02001a2:	00000797          	auipc	a5,0x0
ffffffffc02001a6:	e9078793          	addi	a5,a5,-368 # ffffffffc0200032 <kern_init>
ffffffffc02001aa:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001ae:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b2:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b4:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001b8:	95be                	add	a1,a1,a5
ffffffffc02001ba:	85a9                	srai	a1,a1,0xa
ffffffffc02001bc:	00001517          	auipc	a0,0x1
ffffffffc02001c0:	1c450513          	addi	a0,a0,452 # ffffffffc0201380 <etext+0xc0>
}
ffffffffc02001c4:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001c6:	b5f5                	j	ffffffffc02000b2 <cprintf>

ffffffffc02001c8 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001c8:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001ca:	00001617          	auipc	a2,0x1
ffffffffc02001ce:	1e660613          	addi	a2,a2,486 # ffffffffc02013b0 <etext+0xf0>
ffffffffc02001d2:	04e00593          	li	a1,78
ffffffffc02001d6:	00001517          	auipc	a0,0x1
ffffffffc02001da:	1f250513          	addi	a0,a0,498 # ffffffffc02013c8 <etext+0x108>
void print_stackframe(void) {
ffffffffc02001de:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e0:	1cc000ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc02001e4 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001e4:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001e6:	00001617          	auipc	a2,0x1
ffffffffc02001ea:	1fa60613          	addi	a2,a2,506 # ffffffffc02013e0 <etext+0x120>
ffffffffc02001ee:	00001597          	auipc	a1,0x1
ffffffffc02001f2:	21258593          	addi	a1,a1,530 # ffffffffc0201400 <etext+0x140>
ffffffffc02001f6:	00001517          	auipc	a0,0x1
ffffffffc02001fa:	21250513          	addi	a0,a0,530 # ffffffffc0201408 <etext+0x148>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001fe:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200200:	eb3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200204:	00001617          	auipc	a2,0x1
ffffffffc0200208:	21460613          	addi	a2,a2,532 # ffffffffc0201418 <etext+0x158>
ffffffffc020020c:	00001597          	auipc	a1,0x1
ffffffffc0200210:	23458593          	addi	a1,a1,564 # ffffffffc0201440 <etext+0x180>
ffffffffc0200214:	00001517          	auipc	a0,0x1
ffffffffc0200218:	1f450513          	addi	a0,a0,500 # ffffffffc0201408 <etext+0x148>
ffffffffc020021c:	e97ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200220:	00001617          	auipc	a2,0x1
ffffffffc0200224:	23060613          	addi	a2,a2,560 # ffffffffc0201450 <etext+0x190>
ffffffffc0200228:	00001597          	auipc	a1,0x1
ffffffffc020022c:	24858593          	addi	a1,a1,584 # ffffffffc0201470 <etext+0x1b0>
ffffffffc0200230:	00001517          	auipc	a0,0x1
ffffffffc0200234:	1d850513          	addi	a0,a0,472 # ffffffffc0201408 <etext+0x148>
ffffffffc0200238:	e7bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }
    return 0;
}
ffffffffc020023c:	60a2                	ld	ra,8(sp)
ffffffffc020023e:	4501                	li	a0,0
ffffffffc0200240:	0141                	addi	sp,sp,16
ffffffffc0200242:	8082                	ret

ffffffffc0200244 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200244:	1141                	addi	sp,sp,-16
ffffffffc0200246:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200248:	ef3ff0ef          	jal	ra,ffffffffc020013a <print_kerninfo>
    return 0;
}
ffffffffc020024c:	60a2                	ld	ra,8(sp)
ffffffffc020024e:	4501                	li	a0,0
ffffffffc0200250:	0141                	addi	sp,sp,16
ffffffffc0200252:	8082                	ret

ffffffffc0200254 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200254:	1141                	addi	sp,sp,-16
ffffffffc0200256:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200258:	f71ff0ef          	jal	ra,ffffffffc02001c8 <print_stackframe>
    return 0;
}
ffffffffc020025c:	60a2                	ld	ra,8(sp)
ffffffffc020025e:	4501                	li	a0,0
ffffffffc0200260:	0141                	addi	sp,sp,16
ffffffffc0200262:	8082                	ret

ffffffffc0200264 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200264:	7115                	addi	sp,sp,-224
ffffffffc0200266:	ed5e                	sd	s7,152(sp)
ffffffffc0200268:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020026a:	00001517          	auipc	a0,0x1
ffffffffc020026e:	21650513          	addi	a0,a0,534 # ffffffffc0201480 <etext+0x1c0>
kmonitor(struct trapframe *tf) {
ffffffffc0200272:	ed86                	sd	ra,216(sp)
ffffffffc0200274:	e9a2                	sd	s0,208(sp)
ffffffffc0200276:	e5a6                	sd	s1,200(sp)
ffffffffc0200278:	e1ca                	sd	s2,192(sp)
ffffffffc020027a:	fd4e                	sd	s3,184(sp)
ffffffffc020027c:	f952                	sd	s4,176(sp)
ffffffffc020027e:	f556                	sd	s5,168(sp)
ffffffffc0200280:	f15a                	sd	s6,160(sp)
ffffffffc0200282:	e962                	sd	s8,144(sp)
ffffffffc0200284:	e566                	sd	s9,136(sp)
ffffffffc0200286:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200288:	e2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020028c:	00001517          	auipc	a0,0x1
ffffffffc0200290:	21c50513          	addi	a0,a0,540 # ffffffffc02014a8 <etext+0x1e8>
ffffffffc0200294:	e1fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (tf != NULL) {
ffffffffc0200298:	000b8563          	beqz	s7,ffffffffc02002a2 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029c:	855e                	mv	a0,s7
ffffffffc020029e:	3a4000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a2:	00001c17          	auipc	s8,0x1
ffffffffc02002a6:	276c0c13          	addi	s8,s8,630 # ffffffffc0201518 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002aa:	00001917          	auipc	s2,0x1
ffffffffc02002ae:	22690913          	addi	s2,s2,550 # ffffffffc02014d0 <etext+0x210>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b2:	00001497          	auipc	s1,0x1
ffffffffc02002b6:	22648493          	addi	s1,s1,550 # ffffffffc02014d8 <etext+0x218>
        if (argc == MAXARGS - 1) {
ffffffffc02002ba:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002bc:	00001b17          	auipc	s6,0x1
ffffffffc02002c0:	224b0b13          	addi	s6,s6,548 # ffffffffc02014e0 <etext+0x220>
        argv[argc ++] = buf;
ffffffffc02002c4:	00001a17          	auipc	s4,0x1
ffffffffc02002c8:	13ca0a13          	addi	s4,s4,316 # ffffffffc0201400 <etext+0x140>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4a8d                	li	s5,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ce:	854a                	mv	a0,s2
ffffffffc02002d0:	68b000ef          	jal	ra,ffffffffc020115a <readline>
ffffffffc02002d4:	842a                	mv	s0,a0
ffffffffc02002d6:	dd65                	beqz	a0,ffffffffc02002ce <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002d8:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002dc:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002de:	e1bd                	bnez	a1,ffffffffc0200344 <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002e0:	fe0c87e3          	beqz	s9,ffffffffc02002ce <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e4:	6582                	ld	a1,0(sp)
ffffffffc02002e6:	00001d17          	auipc	s10,0x1
ffffffffc02002ea:	232d0d13          	addi	s10,s10,562 # ffffffffc0201518 <commands>
        argv[argc ++] = buf;
ffffffffc02002ee:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f0:	4401                	li	s0,0
ffffffffc02002f2:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f4:	787000ef          	jal	ra,ffffffffc020127a <strcmp>
ffffffffc02002f8:	c919                	beqz	a0,ffffffffc020030e <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fa:	2405                	addiw	s0,s0,1
ffffffffc02002fc:	0b540063          	beq	s0,s5,ffffffffc020039c <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200300:	000d3503          	ld	a0,0(s10)
ffffffffc0200304:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200308:	773000ef          	jal	ra,ffffffffc020127a <strcmp>
ffffffffc020030c:	f57d                	bnez	a0,ffffffffc02002fa <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020030e:	00141793          	slli	a5,s0,0x1
ffffffffc0200312:	97a2                	add	a5,a5,s0
ffffffffc0200314:	078e                	slli	a5,a5,0x3
ffffffffc0200316:	97e2                	add	a5,a5,s8
ffffffffc0200318:	6b9c                	ld	a5,16(a5)
ffffffffc020031a:	865e                	mv	a2,s7
ffffffffc020031c:	002c                	addi	a1,sp,8
ffffffffc020031e:	fffc851b          	addiw	a0,s9,-1
ffffffffc0200322:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200324:	fa0555e3          	bgez	a0,ffffffffc02002ce <kmonitor+0x6a>
}
ffffffffc0200328:	60ee                	ld	ra,216(sp)
ffffffffc020032a:	644e                	ld	s0,208(sp)
ffffffffc020032c:	64ae                	ld	s1,200(sp)
ffffffffc020032e:	690e                	ld	s2,192(sp)
ffffffffc0200330:	79ea                	ld	s3,184(sp)
ffffffffc0200332:	7a4a                	ld	s4,176(sp)
ffffffffc0200334:	7aaa                	ld	s5,168(sp)
ffffffffc0200336:	7b0a                	ld	s6,160(sp)
ffffffffc0200338:	6bea                	ld	s7,152(sp)
ffffffffc020033a:	6c4a                	ld	s8,144(sp)
ffffffffc020033c:	6caa                	ld	s9,136(sp)
ffffffffc020033e:	6d0a                	ld	s10,128(sp)
ffffffffc0200340:	612d                	addi	sp,sp,224
ffffffffc0200342:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200344:	8526                	mv	a0,s1
ffffffffc0200346:	753000ef          	jal	ra,ffffffffc0201298 <strchr>
ffffffffc020034a:	c901                	beqz	a0,ffffffffc020035a <kmonitor+0xf6>
ffffffffc020034c:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200350:	00040023          	sb	zero,0(s0)
ffffffffc0200354:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200356:	d5c9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200358:	b7f5                	j	ffffffffc0200344 <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc020035a:	00044783          	lbu	a5,0(s0)
ffffffffc020035e:	d3c9                	beqz	a5,ffffffffc02002e0 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200360:	033c8963          	beq	s9,s3,ffffffffc0200392 <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc0200364:	003c9793          	slli	a5,s9,0x3
ffffffffc0200368:	0118                	addi	a4,sp,128
ffffffffc020036a:	97ba                	add	a5,a5,a4
ffffffffc020036c:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200370:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200374:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200376:	e591                	bnez	a1,ffffffffc0200382 <kmonitor+0x11e>
ffffffffc0200378:	b7b5                	j	ffffffffc02002e4 <kmonitor+0x80>
ffffffffc020037a:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc020037e:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200380:	d1a5                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200382:	8526                	mv	a0,s1
ffffffffc0200384:	715000ef          	jal	ra,ffffffffc0201298 <strchr>
ffffffffc0200388:	d96d                	beqz	a0,ffffffffc020037a <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038a:	00044583          	lbu	a1,0(s0)
ffffffffc020038e:	d9a9                	beqz	a1,ffffffffc02002e0 <kmonitor+0x7c>
ffffffffc0200390:	bf55                	j	ffffffffc0200344 <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200392:	45c1                	li	a1,16
ffffffffc0200394:	855a                	mv	a0,s6
ffffffffc0200396:	d1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc020039a:	b7e9                	j	ffffffffc0200364 <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020039c:	6582                	ld	a1,0(sp)
ffffffffc020039e:	00001517          	auipc	a0,0x1
ffffffffc02003a2:	16250513          	addi	a0,a0,354 # ffffffffc0201500 <etext+0x240>
ffffffffc02003a6:	d0dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return 0;
ffffffffc02003aa:	b715                	j	ffffffffc02002ce <kmonitor+0x6a>

ffffffffc02003ac <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003ac:	00006317          	auipc	t1,0x6
ffffffffc02003b0:	0b430313          	addi	t1,t1,180 # ffffffffc0206460 <is_panic>
ffffffffc02003b4:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b8:	715d                	addi	sp,sp,-80
ffffffffc02003ba:	ec06                	sd	ra,24(sp)
ffffffffc02003bc:	e822                	sd	s0,16(sp)
ffffffffc02003be:	f436                	sd	a3,40(sp)
ffffffffc02003c0:	f83a                	sd	a4,48(sp)
ffffffffc02003c2:	fc3e                	sd	a5,56(sp)
ffffffffc02003c4:	e0c2                	sd	a6,64(sp)
ffffffffc02003c6:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c8:	020e1a63          	bnez	t3,ffffffffc02003fc <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003cc:	4785                	li	a5,1
ffffffffc02003ce:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003d2:	8432                	mv	s0,a2
ffffffffc02003d4:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d6:	862e                	mv	a2,a1
ffffffffc02003d8:	85aa                	mv	a1,a0
ffffffffc02003da:	00001517          	auipc	a0,0x1
ffffffffc02003de:	18650513          	addi	a0,a0,390 # ffffffffc0201560 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	ccfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	ca7ff0ef          	jal	ra,ffffffffc0200092 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00001517          	auipc	a0,0x1
ffffffffc02003f4:	fb850513          	addi	a0,a0,-72 # ffffffffc02013a8 <etext+0xe8>
ffffffffc02003f8:	cbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003fc:	062000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	e63ff0ef          	jal	ra,ffffffffc0200264 <kmonitor>
    while (1) {
ffffffffc0200406:	bfed                	j	ffffffffc0200400 <__panic+0x54>

ffffffffc0200408 <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc0200408:	1141                	addi	sp,sp,-16
ffffffffc020040a:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc020040c:	02000793          	li	a5,32
ffffffffc0200410:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200414:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200418:	67e1                	lui	a5,0x18
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	609000ef          	jal	ra,ffffffffc0201228 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0407b123          	sd	zero,66(a5) # ffffffffc0206468 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	15250513          	addi	a0,a0,338 # ffffffffc0201580 <commands+0x68>
}
ffffffffc0200436:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b9ad                	j	ffffffffc02000b2 <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	5e30006f          	j	ffffffffc0201228 <sbi_set_timer>

ffffffffc020044a <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020044a:	8082                	ret

ffffffffc020044c <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc020044c:	0ff57513          	andi	a0,a0,255
ffffffffc0200450:	5bf0006f          	j	ffffffffc020120e <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	5ef0006f          	j	ffffffffc0201242 <sbi_console_getchar>

ffffffffc0200458 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200458:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc020045c:	8082                	ret

ffffffffc020045e <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc020045e:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200462:	8082                	ret

ffffffffc0200464 <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200464:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200468:	00000797          	auipc	a5,0x0
ffffffffc020046c:	2e478793          	addi	a5,a5,740 # ffffffffc020074c <__alltraps>
ffffffffc0200470:	10579073          	csrw	stvec,a5
}
ffffffffc0200474:	8082                	ret

ffffffffc0200476 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200476:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200478:	1141                	addi	sp,sp,-16
ffffffffc020047a:	e022                	sd	s0,0(sp)
ffffffffc020047c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020047e:	00001517          	auipc	a0,0x1
ffffffffc0200482:	12250513          	addi	a0,a0,290 # ffffffffc02015a0 <commands+0x88>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	12a50513          	addi	a0,a0,298 # ffffffffc02015b8 <commands+0xa0>
ffffffffc0200496:	c1dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	13450513          	addi	a0,a0,308 # ffffffffc02015d0 <commands+0xb8>
ffffffffc02004a4:	c0fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	13e50513          	addi	a0,a0,318 # ffffffffc02015e8 <commands+0xd0>
ffffffffc02004b2:	c01ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	14850513          	addi	a0,a0,328 # ffffffffc0201600 <commands+0xe8>
ffffffffc02004c0:	bf3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	15250513          	addi	a0,a0,338 # ffffffffc0201618 <commands+0x100>
ffffffffc02004ce:	be5ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	15c50513          	addi	a0,a0,348 # ffffffffc0201630 <commands+0x118>
ffffffffc02004dc:	bd7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	16650513          	addi	a0,a0,358 # ffffffffc0201648 <commands+0x130>
ffffffffc02004ea:	bc9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	17050513          	addi	a0,a0,368 # ffffffffc0201660 <commands+0x148>
ffffffffc02004f8:	bbbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	17a50513          	addi	a0,a0,378 # ffffffffc0201678 <commands+0x160>
ffffffffc0200506:	badff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	18450513          	addi	a0,a0,388 # ffffffffc0201690 <commands+0x178>
ffffffffc0200514:	b9fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	18e50513          	addi	a0,a0,398 # ffffffffc02016a8 <commands+0x190>
ffffffffc0200522:	b91ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	19850513          	addi	a0,a0,408 # ffffffffc02016c0 <commands+0x1a8>
ffffffffc0200530:	b83ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	1a250513          	addi	a0,a0,418 # ffffffffc02016d8 <commands+0x1c0>
ffffffffc020053e:	b75ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	1ac50513          	addi	a0,a0,428 # ffffffffc02016f0 <commands+0x1d8>
ffffffffc020054c:	b67ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	1b650513          	addi	a0,a0,438 # ffffffffc0201708 <commands+0x1f0>
ffffffffc020055a:	b59ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	1c050513          	addi	a0,a0,448 # ffffffffc0201720 <commands+0x208>
ffffffffc0200568:	b4bff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	1ca50513          	addi	a0,a0,458 # ffffffffc0201738 <commands+0x220>
ffffffffc0200576:	b3dff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	1d450513          	addi	a0,a0,468 # ffffffffc0201750 <commands+0x238>
ffffffffc0200584:	b2fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	1de50513          	addi	a0,a0,478 # ffffffffc0201768 <commands+0x250>
ffffffffc0200592:	b21ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	1e850513          	addi	a0,a0,488 # ffffffffc0201780 <commands+0x268>
ffffffffc02005a0:	b13ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	1f250513          	addi	a0,a0,498 # ffffffffc0201798 <commands+0x280>
ffffffffc02005ae:	b05ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	1fc50513          	addi	a0,a0,508 # ffffffffc02017b0 <commands+0x298>
ffffffffc02005bc:	af7ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	20650513          	addi	a0,a0,518 # ffffffffc02017c8 <commands+0x2b0>
ffffffffc02005ca:	ae9ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	21050513          	addi	a0,a0,528 # ffffffffc02017e0 <commands+0x2c8>
ffffffffc02005d8:	adbff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	21a50513          	addi	a0,a0,538 # ffffffffc02017f8 <commands+0x2e0>
ffffffffc02005e6:	acdff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	22450513          	addi	a0,a0,548 # ffffffffc0201810 <commands+0x2f8>
ffffffffc02005f4:	abfff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	22e50513          	addi	a0,a0,558 # ffffffffc0201828 <commands+0x310>
ffffffffc0200602:	ab1ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	23850513          	addi	a0,a0,568 # ffffffffc0201840 <commands+0x328>
ffffffffc0200610:	aa3ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	24250513          	addi	a0,a0,578 # ffffffffc0201858 <commands+0x340>
ffffffffc020061e:	a95ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	24c50513          	addi	a0,a0,588 # ffffffffc0201870 <commands+0x358>
ffffffffc020062c:	a87ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	25250513          	addi	a0,a0,594 # ffffffffc0201888 <commands+0x370>
}
ffffffffc020063e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200640:	bc8d                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200642 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200648:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020064a:	00001517          	auipc	a0,0x1
ffffffffc020064e:	25650513          	addi	a0,a0,598 # ffffffffc02018a0 <commands+0x388>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a5fff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00001517          	auipc	a0,0x1
ffffffffc0200666:	25650513          	addi	a0,a0,598 # ffffffffc02018b8 <commands+0x3a0>
ffffffffc020066a:	a49ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	25e50513          	addi	a0,a0,606 # ffffffffc02018d0 <commands+0x3b8>
ffffffffc020067a:	a39ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	26650513          	addi	a0,a0,614 # ffffffffc02018e8 <commands+0x3d0>
ffffffffc020068a:	a29ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	26a50513          	addi	a0,a0,618 # ffffffffc0201900 <commands+0x3e8>
}
ffffffffc020069e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a0:	bc09                	j	ffffffffc02000b2 <cprintf>

ffffffffc02006a2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
ffffffffc02006a6:	472d                	li	a4,11
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
ffffffffc02006ac:	06f76c63          	bltu	a4,a5,ffffffffc0200724 <interrupt_handler+0x82>
ffffffffc02006b0:	00001717          	auipc	a4,0x1
ffffffffc02006b4:	33070713          	addi	a4,a4,816 # ffffffffc02019e0 <commands+0x4c8>
ffffffffc02006b8:	078a                	slli	a5,a5,0x2
ffffffffc02006ba:	97ba                	add	a5,a5,a4
ffffffffc02006bc:	439c                	lw	a5,0(a5)
ffffffffc02006be:	97ba                	add	a5,a5,a4
ffffffffc02006c0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02006c2:	00001517          	auipc	a0,0x1
ffffffffc02006c6:	2b650513          	addi	a0,a0,694 # ffffffffc0201978 <commands+0x460>
ffffffffc02006ca:	b2e5                	j	ffffffffc02000b2 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	28c50513          	addi	a0,a0,652 # ffffffffc0201958 <commands+0x440>
ffffffffc02006d4:	baf9                	j	ffffffffc02000b2 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	24250513          	addi	a0,a0,578 # ffffffffc0201918 <commands+0x400>
ffffffffc02006de:	bad1                	j	ffffffffc02000b2 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	2b850513          	addi	a0,a0,696 # ffffffffc0201998 <commands+0x480>
ffffffffc02006e8:	b2e9                	j	ffffffffc02000b2 <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc02006ea:	1141                	addi	sp,sp,-16
ffffffffc02006ec:	e406                	sd	ra,8(sp)
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // cprintf("Supervisor timer interrupt\n");
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc02006ee:	d4dff0ef          	jal	ra,ffffffffc020043a <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc02006f2:	00006697          	auipc	a3,0x6
ffffffffc02006f6:	d7668693          	addi	a3,a3,-650 # ffffffffc0206468 <ticks>
ffffffffc02006fa:	629c                	ld	a5,0(a3)
ffffffffc02006fc:	06400713          	li	a4,100
ffffffffc0200700:	0785                	addi	a5,a5,1
ffffffffc0200702:	02e7f733          	remu	a4,a5,a4
ffffffffc0200706:	e29c                	sd	a5,0(a3)
ffffffffc0200708:	cf19                	beqz	a4,ffffffffc0200726 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc020070a:	60a2                	ld	ra,8(sp)
ffffffffc020070c:	0141                	addi	sp,sp,16
ffffffffc020070e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200710:	00001517          	auipc	a0,0x1
ffffffffc0200714:	2b050513          	addi	a0,a0,688 # ffffffffc02019c0 <commands+0x4a8>
ffffffffc0200718:	ba69                	j	ffffffffc02000b2 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc020071a:	00001517          	auipc	a0,0x1
ffffffffc020071e:	21e50513          	addi	a0,a0,542 # ffffffffc0201938 <commands+0x420>
ffffffffc0200722:	ba41                	j	ffffffffc02000b2 <cprintf>
            print_trapframe(tf);
ffffffffc0200724:	bf39                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc0200726:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200728:	06400593          	li	a1,100
ffffffffc020072c:	00001517          	auipc	a0,0x1
ffffffffc0200730:	28450513          	addi	a0,a0,644 # ffffffffc02019b0 <commands+0x498>
}
ffffffffc0200734:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200736:	bab5                	j	ffffffffc02000b2 <cprintf>

ffffffffc0200738 <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200738:	11853783          	ld	a5,280(a0)
ffffffffc020073c:	0007c763          	bltz	a5,ffffffffc020074a <trap+0x12>
    switch (tf->cause) {
ffffffffc0200740:	472d                	li	a4,11
ffffffffc0200742:	00f76363          	bltu	a4,a5,ffffffffc0200748 <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
ffffffffc0200746:	8082                	ret
            print_trapframe(tf);
ffffffffc0200748:	bded                	j	ffffffffc0200642 <print_trapframe>
        interrupt_handler(tf);
ffffffffc020074a:	bfa1                	j	ffffffffc02006a2 <interrupt_handler>

ffffffffc020074c <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc020074c:	14011073          	csrw	sscratch,sp
ffffffffc0200750:	712d                	addi	sp,sp,-288
ffffffffc0200752:	e002                	sd	zero,0(sp)
ffffffffc0200754:	e406                	sd	ra,8(sp)
ffffffffc0200756:	ec0e                	sd	gp,24(sp)
ffffffffc0200758:	f012                	sd	tp,32(sp)
ffffffffc020075a:	f416                	sd	t0,40(sp)
ffffffffc020075c:	f81a                	sd	t1,48(sp)
ffffffffc020075e:	fc1e                	sd	t2,56(sp)
ffffffffc0200760:	e0a2                	sd	s0,64(sp)
ffffffffc0200762:	e4a6                	sd	s1,72(sp)
ffffffffc0200764:	e8aa                	sd	a0,80(sp)
ffffffffc0200766:	ecae                	sd	a1,88(sp)
ffffffffc0200768:	f0b2                	sd	a2,96(sp)
ffffffffc020076a:	f4b6                	sd	a3,104(sp)
ffffffffc020076c:	f8ba                	sd	a4,112(sp)
ffffffffc020076e:	fcbe                	sd	a5,120(sp)
ffffffffc0200770:	e142                	sd	a6,128(sp)
ffffffffc0200772:	e546                	sd	a7,136(sp)
ffffffffc0200774:	e94a                	sd	s2,144(sp)
ffffffffc0200776:	ed4e                	sd	s3,152(sp)
ffffffffc0200778:	f152                	sd	s4,160(sp)
ffffffffc020077a:	f556                	sd	s5,168(sp)
ffffffffc020077c:	f95a                	sd	s6,176(sp)
ffffffffc020077e:	fd5e                	sd	s7,184(sp)
ffffffffc0200780:	e1e2                	sd	s8,192(sp)
ffffffffc0200782:	e5e6                	sd	s9,200(sp)
ffffffffc0200784:	e9ea                	sd	s10,208(sp)
ffffffffc0200786:	edee                	sd	s11,216(sp)
ffffffffc0200788:	f1f2                	sd	t3,224(sp)
ffffffffc020078a:	f5f6                	sd	t4,232(sp)
ffffffffc020078c:	f9fa                	sd	t5,240(sp)
ffffffffc020078e:	fdfe                	sd	t6,248(sp)
ffffffffc0200790:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200794:	100024f3          	csrr	s1,sstatus
ffffffffc0200798:	14102973          	csrr	s2,sepc
ffffffffc020079c:	143029f3          	csrr	s3,stval
ffffffffc02007a0:	14202a73          	csrr	s4,scause
ffffffffc02007a4:	e822                	sd	s0,16(sp)
ffffffffc02007a6:	e226                	sd	s1,256(sp)
ffffffffc02007a8:	e64a                	sd	s2,264(sp)
ffffffffc02007aa:	ea4e                	sd	s3,272(sp)
ffffffffc02007ac:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007ae:	850a                	mv	a0,sp
    jal trap
ffffffffc02007b0:	f89ff0ef          	jal	ra,ffffffffc0200738 <trap>

ffffffffc02007b4 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007b4:	6492                	ld	s1,256(sp)
ffffffffc02007b6:	6932                	ld	s2,264(sp)
ffffffffc02007b8:	10049073          	csrw	sstatus,s1
ffffffffc02007bc:	14191073          	csrw	sepc,s2
ffffffffc02007c0:	60a2                	ld	ra,8(sp)
ffffffffc02007c2:	61e2                	ld	gp,24(sp)
ffffffffc02007c4:	7202                	ld	tp,32(sp)
ffffffffc02007c6:	72a2                	ld	t0,40(sp)
ffffffffc02007c8:	7342                	ld	t1,48(sp)
ffffffffc02007ca:	73e2                	ld	t2,56(sp)
ffffffffc02007cc:	6406                	ld	s0,64(sp)
ffffffffc02007ce:	64a6                	ld	s1,72(sp)
ffffffffc02007d0:	6546                	ld	a0,80(sp)
ffffffffc02007d2:	65e6                	ld	a1,88(sp)
ffffffffc02007d4:	7606                	ld	a2,96(sp)
ffffffffc02007d6:	76a6                	ld	a3,104(sp)
ffffffffc02007d8:	7746                	ld	a4,112(sp)
ffffffffc02007da:	77e6                	ld	a5,120(sp)
ffffffffc02007dc:	680a                	ld	a6,128(sp)
ffffffffc02007de:	68aa                	ld	a7,136(sp)
ffffffffc02007e0:	694a                	ld	s2,144(sp)
ffffffffc02007e2:	69ea                	ld	s3,152(sp)
ffffffffc02007e4:	7a0a                	ld	s4,160(sp)
ffffffffc02007e6:	7aaa                	ld	s5,168(sp)
ffffffffc02007e8:	7b4a                	ld	s6,176(sp)
ffffffffc02007ea:	7bea                	ld	s7,184(sp)
ffffffffc02007ec:	6c0e                	ld	s8,192(sp)
ffffffffc02007ee:	6cae                	ld	s9,200(sp)
ffffffffc02007f0:	6d4e                	ld	s10,208(sp)
ffffffffc02007f2:	6dee                	ld	s11,216(sp)
ffffffffc02007f4:	7e0e                	ld	t3,224(sp)
ffffffffc02007f6:	7eae                	ld	t4,232(sp)
ffffffffc02007f8:	7f4e                	ld	t5,240(sp)
ffffffffc02007fa:	7fee                	ld	t6,248(sp)
ffffffffc02007fc:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc02007fe:	10200073          	sret

ffffffffc0200802 <slub_init>:
// 全局SLUB缓存实例
slub_cache_t slub_cache;

// 初始化SLUB缓存
void slub_init() {
    slub_cache.size = 0;
ffffffffc0200802:	00006797          	auipc	a5,0x6
ffffffffc0200806:	80e78793          	addi	a5,a5,-2034 # ffffffffc0206010 <slub_cache>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020080a:	00006617          	auipc	a2,0x6
ffffffffc020080e:	81660613          	addi	a2,a2,-2026 # ffffffffc0206020 <slub_cache+0x10>
ffffffffc0200812:	00006697          	auipc	a3,0x6
ffffffffc0200816:	81e68693          	addi	a3,a3,-2018 # ffffffffc0206030 <slub_cache+0x20>
ffffffffc020081a:	00006717          	auipc	a4,0x6
ffffffffc020081e:	82670713          	addi	a4,a4,-2010 # ffffffffc0206040 <slub_cache+0x30>
ffffffffc0200822:	0007b023          	sd	zero,0(a5)
    slub_cache.offset = 0;
ffffffffc0200826:	0007b423          	sd	zero,8(a5)
    slub_cache.page = NULL;
ffffffffc020082a:	0407b023          	sd	zero,64(a5)
    slub_cache.free_objects = 0;
    slub_cache.objects = 0;
ffffffffc020082e:	0407b423          	sd	zero,72(a5)
ffffffffc0200832:	ef90                	sd	a2,24(a5)
ffffffffc0200834:	eb90                	sd	a2,16(a5)
ffffffffc0200836:	f794                	sd	a3,40(a5)
ffffffffc0200838:	f394                	sd	a3,32(a5)
ffffffffc020083a:	ff98                	sd	a4,56(a5)
ffffffffc020083c:	fb98                	sd	a4,48(a5)
    list_init(&slub_cache.full);
    list_init(&slub_cache.partial);
    list_init(&slub_cache.free);
}
ffffffffc020083e:	8082                	ret

ffffffffc0200840 <slub_init_memmap>:

// 初始化内存映射
void slub_init_memmap(struct Page *base, size_t n) {
    slub_cache.objects = calculate_objects_per_page(slub_cache.size);
ffffffffc0200840:	00005717          	auipc	a4,0x5
ffffffffc0200844:	7d070713          	addi	a4,a4,2000 # ffffffffc0206010 <slub_cache>
    slub_cache.free_objects = slub_cache.objects * n;
}

// 计算每个页面可容纳的对象数量
static unsigned int calculate_objects_per_page(size_t obj_size) {
    return (PGSIZE - sizeof(struct Page)) / obj_size;
ffffffffc0200848:	631c                	ld	a5,0(a4)
ffffffffc020084a:	6605                	lui	a2,0x1
ffffffffc020084c:	fd860613          	addi	a2,a2,-40 # fd8 <kern_entry-0xffffffffc01ff028>
ffffffffc0200850:	02f65633          	divu	a2,a2,a5
ffffffffc0200854:	2601                	sext.w	a2,a2
    slub_cache.objects = calculate_objects_per_page(slub_cache.size);
ffffffffc0200856:	c730                	sw	a2,72(a4)
    for (size_t i = 0; i < n; i++) {
ffffffffc0200858:	c98d                	beqz	a1,ffffffffc020088a <slub_init_memmap+0x4a>
ffffffffc020085a:	00259693          	slli	a3,a1,0x2
ffffffffc020085e:	96ae                	add	a3,a3,a1
ffffffffc0200860:	0561                	addi	a0,a0,24
ffffffffc0200862:	068e                	slli	a3,a3,0x3
ffffffffc0200864:	96aa                	add	a3,a3,a0
ffffffffc0200866:	00005817          	auipc	a6,0x5
ffffffffc020086a:	7da80813          	addi	a6,a6,2010 # ffffffffc0206040 <slub_cache+0x30>
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
ffffffffc020086e:	7f1c                	ld	a5,56(a4)
        base[i].flags = 0;
ffffffffc0200870:	fe053823          	sd	zero,-16(a0)
        base[i].property = 0;
ffffffffc0200874:	fe052c23          	sw	zero,-8(a0)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0200878:	e388                	sd	a0,0(a5)
ffffffffc020087a:	ff08                	sd	a0,56(a4)
    elm->next = next;
ffffffffc020087c:	e51c                	sd	a5,8(a0)
    elm->prev = prev;
ffffffffc020087e:	01053023          	sd	a6,0(a0)
    for (size_t i = 0; i < n; i++) {
ffffffffc0200882:	02850513          	addi	a0,a0,40
ffffffffc0200886:	fed514e3          	bne	a0,a3,ffffffffc020086e <slub_init_memmap+0x2e>
    slub_cache.free_objects = slub_cache.objects * n;
ffffffffc020088a:	02c585bb          	mulw	a1,a1,a2
ffffffffc020088e:	c76c                	sw	a1,76(a4)
}
ffffffffc0200890:	8082                	ret

ffffffffc0200892 <slub_nr_free_pages>:
    }
}

// 获取空闲页面数量（这里简单返回空闲对象可占用的页面数，可优化）
size_t slub_nr_free_pages() {
    return (slub_cache.free_objects + slub_cache.objects - 1) / slub_cache.objects;
ffffffffc0200892:	00005717          	auipc	a4,0x5
ffffffffc0200896:	77e70713          	addi	a4,a4,1918 # ffffffffc0206010 <slub_cache>
ffffffffc020089a:	473c                	lw	a5,72(a4)
ffffffffc020089c:	4768                	lw	a0,76(a4)
ffffffffc020089e:	9d3d                	addw	a0,a0,a5
ffffffffc02008a0:	357d                	addiw	a0,a0,-1
ffffffffc02008a2:	02f5553b          	divuw	a0,a0,a5
}
ffffffffc02008a6:	1502                	slli	a0,a0,0x20
ffffffffc02008a8:	9101                	srli	a0,a0,0x20
ffffffffc02008aa:	8082                	ret

ffffffffc02008ac <slub_free_pages>:
    if (page == NULL) {
ffffffffc02008ac:	c529                	beqz	a0,ffffffffc02008f6 <slub_free_pages+0x4a>
    if (page->property > 0) {
ffffffffc02008ae:	491c                	lw	a5,16(a0)
ffffffffc02008b0:	c7a1                	beqz	a5,ffffffffc02008f8 <slub_free_pages+0x4c>
        if (--page->property == 0) {
ffffffffc02008b2:	fff7861b          	addiw	a2,a5,-1
            slub_cache.free_objects += slub_cache.objects;
ffffffffc02008b6:	00005717          	auipc	a4,0x5
ffffffffc02008ba:	75a70713          	addi	a4,a4,1882 # ffffffffc0206010 <slub_cache>
        if (--page->property == 0) {
ffffffffc02008be:	c910                	sw	a2,16(a0)
            slub_cache.free_objects += slub_cache.objects;
ffffffffc02008c0:	4734                	lw	a3,72(a4)
        if (--page->property == 0) {
ffffffffc02008c2:	ea05                	bnez	a2,ffffffffc02008f2 <slub_free_pages+0x46>
    __list_del(listelm->prev, listelm->next);
ffffffffc02008c4:	01853883          	ld	a7,24(a0)
ffffffffc02008c8:	02053803          	ld	a6,32(a0)
            slub_cache.free_objects += slub_cache.objects;
ffffffffc02008cc:	477c                	lw	a5,76(a4)
            list_add(&slub_cache.free, &page->page_link);
ffffffffc02008ce:	01850593          	addi	a1,a0,24
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02008d2:	0108b423          	sd	a6,8(a7)
    __list_add(elm, listelm, listelm->next);
ffffffffc02008d6:	7f10                	ld	a2,56(a4)
    next->prev = prev;
ffffffffc02008d8:	01183023          	sd	a7,0(a6)
            slub_cache.free_objects += slub_cache.objects;
ffffffffc02008dc:	9ebd                	addw	a3,a3,a5
    prev->next = next->prev = elm;
ffffffffc02008de:	e20c                	sd	a1,0(a2)
ffffffffc02008e0:	ff0c                	sd	a1,56(a4)
    elm->next = next;
ffffffffc02008e2:	f110                	sd	a2,32(a0)
    elm->prev = prev;
ffffffffc02008e4:	00005617          	auipc	a2,0x5
ffffffffc02008e8:	75c60613          	addi	a2,a2,1884 # ffffffffc0206040 <slub_cache+0x30>
ffffffffc02008ec:	ed10                	sd	a2,24(a0)
ffffffffc02008ee:	c774                	sw	a3,76(a4)
ffffffffc02008f0:	8082                	ret
        } else if (page->property == slub_cache.objects - 1) {
ffffffffc02008f2:	00d78963          	beq	a5,a3,ffffffffc0200904 <slub_free_pages+0x58>
}
ffffffffc02008f6:	8082                	ret
        cprintf("Error: page->property is negative during free\n");
ffffffffc02008f8:	00001517          	auipc	a0,0x1
ffffffffc02008fc:	11850513          	addi	a0,a0,280 # ffffffffc0201a10 <commands+0x4f8>
ffffffffc0200900:	fb2ff06f          	j	ffffffffc02000b2 <cprintf>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200904:	6d0c                	ld	a1,24(a0)
ffffffffc0200906:	7110                	ld	a2,32(a0)
            list_add(&slub_cache.partial, &page->page_link);
ffffffffc0200908:	01850693          	addi	a3,a0,24
    prev->next = next;
ffffffffc020090c:	e590                	sd	a2,8(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc020090e:	771c                	ld	a5,40(a4)
    next->prev = prev;
ffffffffc0200910:	e20c                	sd	a1,0(a2)
    prev->next = next->prev = elm;
ffffffffc0200912:	e394                	sd	a3,0(a5)
ffffffffc0200914:	f714                	sd	a3,40(a4)
    elm->next = next;
ffffffffc0200916:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0200918:	00005797          	auipc	a5,0x5
ffffffffc020091c:	71878793          	addi	a5,a5,1816 # ffffffffc0206030 <slub_cache+0x20>
ffffffffc0200920:	ed1c                	sd	a5,24(a0)
}
ffffffffc0200922:	8082                	ret

ffffffffc0200924 <slub_alloc_pages>:
    return list->next == list;
ffffffffc0200924:	00005797          	auipc	a5,0x5
ffffffffc0200928:	6ec78793          	addi	a5,a5,1772 # ffffffffc0206010 <slub_cache>
ffffffffc020092c:	7798                	ld	a4,40(a5)
struct Page *slub_alloc_pages(size_t n) {
ffffffffc020092e:	1141                	addi	sp,sp,-16
ffffffffc0200930:	e406                	sd	ra,8(sp)
    if (list_empty(&slub_cache.partial)) {
ffffffffc0200932:	00005697          	auipc	a3,0x5
ffffffffc0200936:	6fe68693          	addi	a3,a3,1790 # ffffffffc0206030 <slub_cache+0x20>
ffffffffc020093a:	06d70963          	beq	a4,a3,ffffffffc02009ac <slub_alloc_pages+0x88>
    struct Page *page = le2page(list_next(&slub_cache.partial), page_link);
ffffffffc020093e:	fe870513          	addi	a0,a4,-24
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200942:	00006697          	auipc	a3,0x6
ffffffffc0200946:	b366b683          	ld	a3,-1226(a3) # ffffffffc0206478 <pages>
ffffffffc020094a:	40d506b3          	sub	a3,a0,a3
ffffffffc020094e:	00001617          	auipc	a2,0x1
ffffffffc0200952:	77263603          	ld	a2,1906(a2) # ffffffffc02020c0 <error_string+0x38>
ffffffffc0200956:	868d                	srai	a3,a3,0x3
ffffffffc0200958:	02c686b3          	mul	a3,a3,a2
ffffffffc020095c:	00001597          	auipc	a1,0x1
ffffffffc0200960:	76c5b583          	ld	a1,1900(a1) # ffffffffc02020c8 <nbase>
    void *obj = (void *)(PADDR(page2pa(page)) + slub_cache.offset);
ffffffffc0200964:	c0200637          	lui	a2,0xc0200
ffffffffc0200968:	96ae                	add	a3,a3,a1

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc020096a:	06b2                	slli	a3,a3,0xc
ffffffffc020096c:	0ac6e163          	bltu	a3,a2,ffffffffc0200a0e <slub_alloc_pages+0xea>
    if (slub_cache.free_objects > 0) {
ffffffffc0200970:	47f4                	lw	a3,76(a5)
ffffffffc0200972:	cea5                	beqz	a3,ffffffffc02009ea <slub_alloc_pages+0xc6>
    if (++page->property == slub_cache.objects) {
ffffffffc0200974:	ff872603          	lw	a2,-8(a4)
        slub_cache.free_objects--;
ffffffffc0200978:	36fd                	addiw	a3,a3,-1
    if (++page->property == slub_cache.objects) {
ffffffffc020097a:	47ac                	lw	a1,72(a5)
ffffffffc020097c:	2605                	addiw	a2,a2,1
        slub_cache.free_objects--;
ffffffffc020097e:	c7f4                	sw	a3,76(a5)
    if (++page->property == slub_cache.objects) {
ffffffffc0200980:	fec72c23          	sw	a2,-8(a4)
ffffffffc0200984:	0006069b          	sext.w	a3,a2
ffffffffc0200988:	00d59f63          	bne	a1,a3,ffffffffc02009a6 <slub_alloc_pages+0x82>
    __list_del(listelm->prev, listelm->next);
ffffffffc020098c:	630c                	ld	a1,0(a4)
ffffffffc020098e:	6710                	ld	a2,8(a4)
    prev->next = next;
ffffffffc0200990:	e590                	sd	a2,8(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200992:	6f94                	ld	a3,24(a5)
    next->prev = prev;
ffffffffc0200994:	e20c                	sd	a1,0(a2)
    prev->next = next->prev = elm;
ffffffffc0200996:	e298                	sd	a4,0(a3)
ffffffffc0200998:	ef98                	sd	a4,24(a5)
    elm->prev = prev;
ffffffffc020099a:	00005797          	auipc	a5,0x5
ffffffffc020099e:	68678793          	addi	a5,a5,1670 # ffffffffc0206020 <slub_cache+0x10>
    elm->next = next;
ffffffffc02009a2:	e714                	sd	a3,8(a4)
    elm->prev = prev;
ffffffffc02009a4:	e31c                	sd	a5,0(a4)
}
ffffffffc02009a6:	60a2                	ld	ra,8(sp)
ffffffffc02009a8:	0141                	addi	sp,sp,16
ffffffffc02009aa:	8082                	ret
    return list->next == list;
ffffffffc02009ac:	7f94                	ld	a3,56(a5)
        if (list_empty(&slub_cache.free)) {
ffffffffc02009ae:	00005617          	auipc	a2,0x5
ffffffffc02009b2:	69260613          	addi	a2,a2,1682 # ffffffffc0206040 <slub_cache+0x30>
ffffffffc02009b6:	04c68a63          	beq	a3,a2,ffffffffc0200a0a <slub_alloc_pages+0xe6>
        struct list_entry *next_free_next = next_free->next; 
ffffffffc02009ba:	668c                	ld	a1,8(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02009bc:	6288                	ld	a0,0(a3)
        if (slub_cache.free_objects >= slub_cache.objects) {
ffffffffc02009be:	47f0                	lw	a2,76(a5)
ffffffffc02009c0:	0487a803          	lw	a6,72(a5)
    prev->next = next;
ffffffffc02009c4:	e50c                	sd	a1,8(a0)
    next->prev = prev;
ffffffffc02009c6:	e188                	sd	a0,0(a1)
        struct Page *new_page = le2page(next_free, page_link);
ffffffffc02009c8:	fe868593          	addi	a1,a3,-24
        slub_cache.page = new_page;
ffffffffc02009cc:	e3ac                	sd	a1,64(a5)
        if (slub_cache.free_objects >= slub_cache.objects) {
ffffffffc02009ce:	03066663          	bltu	a2,a6,ffffffffc02009fa <slub_alloc_pages+0xd6>
    __list_add(elm, listelm, listelm->next);
ffffffffc02009d2:	778c                	ld	a1,40(a5)
            slub_cache.free_objects -= slub_cache.objects;
ffffffffc02009d4:	4106063b          	subw	a2,a2,a6
ffffffffc02009d8:	c7f0                	sw	a2,76(a5)
        new_page->property = 0;
ffffffffc02009da:	fe06ac23          	sw	zero,-8(a3)
    prev->next = next->prev = elm;
ffffffffc02009de:	e194                	sd	a3,0(a1)
ffffffffc02009e0:	f794                	sd	a3,40(a5)
    elm->next = next;
ffffffffc02009e2:	e68c                	sd	a1,8(a3)
    elm->prev = prev;
ffffffffc02009e4:	e298                	sd	a4,0(a3)
    return listelm->next;
ffffffffc02009e6:	7798                	ld	a4,40(a5)
}
ffffffffc02009e8:	bf99                	j	ffffffffc020093e <slub_alloc_pages+0x1a>
        cprintf("Error: free_objects became negative during allocation\n");
ffffffffc02009ea:	00001517          	auipc	a0,0x1
ffffffffc02009ee:	0c650513          	addi	a0,a0,198 # ffffffffc0201ab0 <commands+0x598>
ffffffffc02009f2:	ec0ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
        return NULL;
ffffffffc02009f6:	4501                	li	a0,0
ffffffffc02009f8:	b77d                	j	ffffffffc02009a6 <slub_alloc_pages+0x82>
            cprintf("Error in free_objects calculation during allocation\n");
ffffffffc02009fa:	00001517          	auipc	a0,0x1
ffffffffc02009fe:	04650513          	addi	a0,a0,70 # ffffffffc0201a40 <commands+0x528>
ffffffffc0200a02:	eb0ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
            return NULL;
ffffffffc0200a06:	4501                	li	a0,0
ffffffffc0200a08:	bf79                	j	ffffffffc02009a6 <slub_alloc_pages+0x82>
            return NULL; 
ffffffffc0200a0a:	4501                	li	a0,0
ffffffffc0200a0c:	bf69                	j	ffffffffc02009a6 <slub_alloc_pages+0x82>
    void *obj = (void *)(PADDR(page2pa(page)) + slub_cache.offset);
ffffffffc0200a0e:	00001617          	auipc	a2,0x1
ffffffffc0200a12:	06a60613          	addi	a2,a2,106 # ffffffffc0201a78 <commands+0x560>
ffffffffc0200a16:	04a00593          	li	a1,74
ffffffffc0200a1a:	00001517          	auipc	a0,0x1
ffffffffc0200a1e:	08650513          	addi	a0,a0,134 # ffffffffc0201aa0 <commands+0x588>
ffffffffc0200a22:	98bff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200a26 <slub_check>:

// 检查SLUB缓存（这里添加一些简单检查，可更完善）
void slub_check() {
ffffffffc0200a26:	1101                	addi	sp,sp,-32
    cprintf("SLUB check started...\n");
ffffffffc0200a28:	00001517          	auipc	a0,0x1
ffffffffc0200a2c:	0c050513          	addi	a0,a0,192 # ffffffffc0201ae8 <commands+0x5d0>
void slub_check() {
ffffffffc0200a30:	e426                	sd	s1,8(sp)
ffffffffc0200a32:	ec06                	sd	ra,24(sp)
ffffffffc0200a34:	e822                	sd	s0,16(sp)
ffffffffc0200a36:	e04a                	sd	s2,0(sp)

    // 检查初始化
    if (slub_cache.size == 0 && slub_cache.offset == 0 && slub_cache.page == NULL &&
ffffffffc0200a38:	00005497          	auipc	s1,0x5
ffffffffc0200a3c:	5d848493          	addi	s1,s1,1496 # ffffffffc0206010 <slub_cache>
    cprintf("SLUB check started...\n");
ffffffffc0200a40:	e72ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    if (slub_cache.size == 0 && slub_cache.offset == 0 && slub_cache.page == NULL &&
ffffffffc0200a44:	60bc                	ld	a5,64(s1)
ffffffffc0200a46:	14078663          	beqz	a5,ffffffffc0200b92 <slub_check+0x16c>
        slub_cache.free_objects == 0 && slub_cache.objects == 0 &&
        list_empty(&slub_cache.full) && list_empty(&slub_cache.partial) && list_empty(&slub_cache.free)) {
        cprintf("SLUB initialization check passed.\n");
    } else {
        cprintf("SLUB initialization check failed.\n");
ffffffffc0200a4a:	00001517          	auipc	a0,0x1
ffffffffc0200a4e:	0de50513          	addi	a0,a0,222 # ffffffffc0201b28 <commands+0x610>
ffffffffc0200a52:	e60ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    }

    // 尝试分配一些页面并检查
    struct Page *page1 = slub_alloc_pages(1);
ffffffffc0200a56:	4505                	li	a0,1
ffffffffc0200a58:	ecdff0ef          	jal	ra,ffffffffc0200924 <slub_alloc_pages>
ffffffffc0200a5c:	842a                	mv	s0,a0
    if (page1!= NULL) {
ffffffffc0200a5e:	10050c63          	beqz	a0,ffffffffc0200b76 <slub_check+0x150>
        cprintf("Page allocation check 1 passed.\n");
ffffffffc0200a62:	00001517          	auipc	a0,0x1
ffffffffc0200a66:	0ee50513          	addi	a0,a0,238 # ffffffffc0201b50 <commands+0x638>
ffffffffc0200a6a:	e48ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
        slub_free_pages(page1, 1);
ffffffffc0200a6e:	8522                	mv	a0,s0
ffffffffc0200a70:	4585                	li	a1,1
ffffffffc0200a72:	e3bff0ef          	jal	ra,ffffffffc02008ac <slub_free_pages>
        cprintf("Page release check 1 passed.\n");
ffffffffc0200a76:	00001517          	auipc	a0,0x1
ffffffffc0200a7a:	10250513          	addi	a0,a0,258 # ffffffffc0201b78 <commands+0x660>
ffffffffc0200a7e:	e34ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    } else {
        cprintf("Page allocation check 1 failed.\n");
    }

    // 再次分配和释放，检查不同情况
    struct Page *page2 = slub_alloc_pages(1);
ffffffffc0200a82:	4505                	li	a0,1
ffffffffc0200a84:	ea1ff0ef          	jal	ra,ffffffffc0200924 <slub_alloc_pages>
ffffffffc0200a88:	842a                	mv	s0,a0
    struct Page *page3 = slub_alloc_pages(1);
ffffffffc0200a8a:	4505                	li	a0,1
ffffffffc0200a8c:	e99ff0ef          	jal	ra,ffffffffc0200924 <slub_alloc_pages>
ffffffffc0200a90:	892a                	mv	s2,a0
    if (page2!= NULL && page3!= NULL) {
ffffffffc0200a92:	cc0d                	beqz	s0,ffffffffc0200acc <slub_check+0xa6>
ffffffffc0200a94:	cd05                	beqz	a0,ffffffffc0200acc <slub_check+0xa6>
        cprintf("Page allocation check 2 passed.\n");
ffffffffc0200a96:	00001517          	auipc	a0,0x1
ffffffffc0200a9a:	12a50513          	addi	a0,a0,298 # ffffffffc0201bc0 <commands+0x6a8>
ffffffffc0200a9e:	e14ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
        slub_free_pages(page2, 1);
ffffffffc0200aa2:	4585                	li	a1,1
ffffffffc0200aa4:	8522                	mv	a0,s0
ffffffffc0200aa6:	e07ff0ef          	jal	ra,ffffffffc02008ac <slub_free_pages>
        cprintf("Page release check 2 passed.\n");
ffffffffc0200aaa:	00001517          	auipc	a0,0x1
ffffffffc0200aae:	13e50513          	addi	a0,a0,318 # ffffffffc0201be8 <commands+0x6d0>
ffffffffc0200ab2:	e00ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
        slub_free_pages(page3, 1);
ffffffffc0200ab6:	854a                	mv	a0,s2
ffffffffc0200ab8:	4585                	li	a1,1
ffffffffc0200aba:	df3ff0ef          	jal	ra,ffffffffc02008ac <slub_free_pages>
        cprintf("Page release check 3 passed.\n");
ffffffffc0200abe:	00001517          	auipc	a0,0x1
ffffffffc0200ac2:	14a50513          	addi	a0,a0,330 # ffffffffc0201c08 <commands+0x6f0>
ffffffffc0200ac6:	decff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200aca:	a039                	j	ffffffffc0200ad8 <slub_check+0xb2>
    } else {
        cprintf("Page allocation check 2 failed.\n");
ffffffffc0200acc:	00001517          	auipc	a0,0x1
ffffffffc0200ad0:	15c50513          	addi	a0,a0,348 # ffffffffc0201c28 <commands+0x710>
ffffffffc0200ad4:	ddeff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    return (slub_cache.free_objects + slub_cache.objects - 1) / slub_cache.objects;
ffffffffc0200ad8:	44bc                	lw	a5,72(s1)
ffffffffc0200ada:	44e0                	lw	s0,76(s1)
    }

    // 检查空闲页面数量计算是否合理
    size_t free_pages_before_alloc = slub_nr_free_pages();
    struct Page *page4 = slub_alloc_pages(1);
ffffffffc0200adc:	4505                	li	a0,1
    return (slub_cache.free_objects + slub_cache.objects - 1) / slub_cache.objects;
ffffffffc0200ade:	9c3d                	addw	s0,s0,a5
ffffffffc0200ae0:	347d                	addiw	s0,s0,-1
ffffffffc0200ae2:	02f4543b          	divuw	s0,s0,a5
    struct Page *page4 = slub_alloc_pages(1);
ffffffffc0200ae6:	e3fff0ef          	jal	ra,ffffffffc0200924 <slub_alloc_pages>
    return (slub_cache.free_objects + slub_cache.objects - 1) / slub_cache.objects;
ffffffffc0200aea:	44b8                	lw	a4,72(s1)
ffffffffc0200aec:	44fc                	lw	a5,76(s1)
    struct Page *page4 = slub_alloc_pages(1);
ffffffffc0200aee:	892a                	mv	s2,a0
    return (slub_cache.free_objects + slub_cache.objects - 1) / slub_cache.objects;
ffffffffc0200af0:	9fb9                	addw	a5,a5,a4
ffffffffc0200af2:	37fd                	addiw	a5,a5,-1
ffffffffc0200af4:	02e7d7bb          	divuw	a5,a5,a4
ffffffffc0200af8:	1402                	slli	s0,s0,0x20
ffffffffc0200afa:	9001                	srli	s0,s0,0x20
    size_t free_pages_after_alloc = slub_nr_free_pages();
    if (free_pages_after_alloc == free_pages_before_alloc - 1 && page4!= NULL) {
ffffffffc0200afc:	fff40693          	addi	a3,s0,-1
    return (slub_cache.free_objects + slub_cache.objects - 1) / slub_cache.objects;
ffffffffc0200b00:	1782                	slli	a5,a5,0x20
ffffffffc0200b02:	9381                	srli	a5,a5,0x20
    if (free_pages_after_alloc == free_pages_before_alloc - 1 && page4!= NULL) {
ffffffffc0200b04:	04f69863          	bne	a3,a5,ffffffffc0200b54 <slub_check+0x12e>
ffffffffc0200b08:	c531                	beqz	a0,ffffffffc0200b54 <slub_check+0x12e>
        cprintf("Free page count after allocation check passed.\n");
ffffffffc0200b0a:	00001517          	auipc	a0,0x1
ffffffffc0200b0e:	14650513          	addi	a0,a0,326 # ffffffffc0201c50 <commands+0x738>
ffffffffc0200b12:	da0ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
        slub_free_pages(page4, 1);
ffffffffc0200b16:	4585                	li	a1,1
ffffffffc0200b18:	854a                	mv	a0,s2
ffffffffc0200b1a:	d93ff0ef          	jal	ra,ffffffffc02008ac <slub_free_pages>
    return (slub_cache.free_objects + slub_cache.objects - 1) / slub_cache.objects;
ffffffffc0200b1e:	44b8                	lw	a4,72(s1)
ffffffffc0200b20:	44fc                	lw	a5,76(s1)
ffffffffc0200b22:	9fb9                	addw	a5,a5,a4
ffffffffc0200b24:	37fd                	addiw	a5,a5,-1
ffffffffc0200b26:	02e7d7bb          	divuw	a5,a5,a4
ffffffffc0200b2a:	1782                	slli	a5,a5,0x20
ffffffffc0200b2c:	9381                	srli	a5,a5,0x20
        size_t free_pages_after_free = slub_nr_free_pages();
        if (free_pages_after_free == free_pages_before_alloc) {
ffffffffc0200b2e:	04f40b63          	beq	s0,a5,ffffffffc0200b84 <slub_check+0x15e>
            cprintf("Free page count after release check passed.\n");
        } else {
            cprintf("Free page count after release check failed.\n");
ffffffffc0200b32:	00001517          	auipc	a0,0x1
ffffffffc0200b36:	17e50513          	addi	a0,a0,382 # ffffffffc0201cb0 <commands+0x798>
ffffffffc0200b3a:	d78ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    } else {
        cprintf("Free page count after allocation check failed.\n");
    }

    cprintf("SLUB check completed.\n");
}
ffffffffc0200b3e:	6442                	ld	s0,16(sp)
ffffffffc0200b40:	60e2                	ld	ra,24(sp)
ffffffffc0200b42:	64a2                	ld	s1,8(sp)
ffffffffc0200b44:	6902                	ld	s2,0(sp)
    cprintf("SLUB check completed.\n");
ffffffffc0200b46:	00001517          	auipc	a0,0x1
ffffffffc0200b4a:	1ca50513          	addi	a0,a0,458 # ffffffffc0201d10 <commands+0x7f8>
}
ffffffffc0200b4e:	6105                	addi	sp,sp,32
    cprintf("SLUB check completed.\n");
ffffffffc0200b50:	d62ff06f          	j	ffffffffc02000b2 <cprintf>
        cprintf("Free page count after allocation check failed.\n");
ffffffffc0200b54:	00001517          	auipc	a0,0x1
ffffffffc0200b58:	18c50513          	addi	a0,a0,396 # ffffffffc0201ce0 <commands+0x7c8>
ffffffffc0200b5c:	d56ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
}
ffffffffc0200b60:	6442                	ld	s0,16(sp)
ffffffffc0200b62:	60e2                	ld	ra,24(sp)
ffffffffc0200b64:	64a2                	ld	s1,8(sp)
ffffffffc0200b66:	6902                	ld	s2,0(sp)
    cprintf("SLUB check completed.\n");
ffffffffc0200b68:	00001517          	auipc	a0,0x1
ffffffffc0200b6c:	1a850513          	addi	a0,a0,424 # ffffffffc0201d10 <commands+0x7f8>
}
ffffffffc0200b70:	6105                	addi	sp,sp,32
    cprintf("SLUB check completed.\n");
ffffffffc0200b72:	d40ff06f          	j	ffffffffc02000b2 <cprintf>
        cprintf("Page allocation check 1 failed.\n");
ffffffffc0200b76:	00001517          	auipc	a0,0x1
ffffffffc0200b7a:	02250513          	addi	a0,a0,34 # ffffffffc0201b98 <commands+0x680>
ffffffffc0200b7e:	d34ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200b82:	b701                	j	ffffffffc0200a82 <slub_check+0x5c>
            cprintf("Free page count after release check passed.\n");
ffffffffc0200b84:	00001517          	auipc	a0,0x1
ffffffffc0200b88:	0fc50513          	addi	a0,a0,252 # ffffffffc0201c80 <commands+0x768>
ffffffffc0200b8c:	d26ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200b90:	bfc1                	j	ffffffffc0200b60 <slub_check+0x13a>
        slub_cache.free_objects == 0 && slub_cache.objects == 0 &&
ffffffffc0200b92:	609c                	ld	a5,0(s1)
ffffffffc0200b94:	6494                	ld	a3,8(s1)
ffffffffc0200b96:	64b8                	ld	a4,72(s1)
ffffffffc0200b98:	8fd5                	or	a5,a5,a3
ffffffffc0200b9a:	8fd9                	or	a5,a5,a4
ffffffffc0200b9c:	ea0797e3          	bnez	a5,ffffffffc0200a4a <slub_check+0x24>
ffffffffc0200ba0:	6c98                	ld	a4,24(s1)
ffffffffc0200ba2:	00005797          	auipc	a5,0x5
ffffffffc0200ba6:	47e78793          	addi	a5,a5,1150 # ffffffffc0206020 <slub_cache+0x10>
ffffffffc0200baa:	eaf710e3          	bne	a4,a5,ffffffffc0200a4a <slub_check+0x24>
        list_empty(&slub_cache.full) && list_empty(&slub_cache.partial) && list_empty(&slub_cache.free)) {
ffffffffc0200bae:	7498                	ld	a4,40(s1)
ffffffffc0200bb0:	00005797          	auipc	a5,0x5
ffffffffc0200bb4:	48078793          	addi	a5,a5,1152 # ffffffffc0206030 <slub_cache+0x20>
ffffffffc0200bb8:	e8f719e3          	bne	a4,a5,ffffffffc0200a4a <slub_check+0x24>
ffffffffc0200bbc:	7c98                	ld	a4,56(s1)
ffffffffc0200bbe:	00005797          	auipc	a5,0x5
ffffffffc0200bc2:	48278793          	addi	a5,a5,1154 # ffffffffc0206040 <slub_cache+0x30>
ffffffffc0200bc6:	e8f712e3          	bne	a4,a5,ffffffffc0200a4a <slub_check+0x24>
        cprintf("SLUB initialization check passed.\n");
ffffffffc0200bca:	00001517          	auipc	a0,0x1
ffffffffc0200bce:	f3650513          	addi	a0,a0,-202 # ffffffffc0201b00 <commands+0x5e8>
ffffffffc0200bd2:	ce0ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
ffffffffc0200bd6:	b541                	j	ffffffffc0200a56 <slub_check+0x30>

ffffffffc0200bd8 <pmm_init>:

static void check_alloc_page(void);

// init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void) {
    pmm_manager = &slub_pmm_manager;
ffffffffc0200bd8:	00001797          	auipc	a5,0x1
ffffffffc0200bdc:	16878793          	addi	a5,a5,360 # ffffffffc0201d40 <slub_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200be0:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200be2:	1101                	addi	sp,sp,-32
ffffffffc0200be4:	e426                	sd	s1,8(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200be6:	00001517          	auipc	a0,0x1
ffffffffc0200bea:	19250513          	addi	a0,a0,402 # ffffffffc0201d78 <slub_pmm_manager+0x38>
    pmm_manager = &slub_pmm_manager;
ffffffffc0200bee:	00006497          	auipc	s1,0x6
ffffffffc0200bf2:	89248493          	addi	s1,s1,-1902 # ffffffffc0206480 <pmm_manager>
void pmm_init(void) {
ffffffffc0200bf6:	ec06                	sd	ra,24(sp)
ffffffffc0200bf8:	e822                	sd	s0,16(sp)
    pmm_manager = &slub_pmm_manager;
ffffffffc0200bfa:	e09c                	sd	a5,0(s1)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200bfc:	cb6ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pmm_manager->init();
ffffffffc0200c00:	609c                	ld	a5,0(s1)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200c02:	00006417          	auipc	s0,0x6
ffffffffc0200c06:	89640413          	addi	s0,s0,-1898 # ffffffffc0206498 <va_pa_offset>
    pmm_manager->init();
ffffffffc0200c0a:	679c                	ld	a5,8(a5)
ffffffffc0200c0c:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200c0e:	57f5                	li	a5,-3
ffffffffc0200c10:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200c12:	00001517          	auipc	a0,0x1
ffffffffc0200c16:	17e50513          	addi	a0,a0,382 # ffffffffc0201d90 <slub_pmm_manager+0x50>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200c1a:	e01c                	sd	a5,0(s0)
    cprintf("physcial memory map:\n");
ffffffffc0200c1c:	c96ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200c20:	46c5                	li	a3,17
ffffffffc0200c22:	06ee                	slli	a3,a3,0x1b
ffffffffc0200c24:	40100613          	li	a2,1025
ffffffffc0200c28:	16fd                	addi	a3,a3,-1
ffffffffc0200c2a:	07e005b7          	lui	a1,0x7e00
ffffffffc0200c2e:	0656                	slli	a2,a2,0x15
ffffffffc0200c30:	00001517          	auipc	a0,0x1
ffffffffc0200c34:	17850513          	addi	a0,a0,376 # ffffffffc0201da8 <slub_pmm_manager+0x68>
ffffffffc0200c38:	c7aff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200c3c:	777d                	lui	a4,0xfffff
ffffffffc0200c3e:	00007797          	auipc	a5,0x7
ffffffffc0200c42:	86978793          	addi	a5,a5,-1943 # ffffffffc02074a7 <end+0xfff>
ffffffffc0200c46:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200c48:	00006517          	auipc	a0,0x6
ffffffffc0200c4c:	82850513          	addi	a0,a0,-2008 # ffffffffc0206470 <npage>
ffffffffc0200c50:	00088737          	lui	a4,0x88
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200c54:	00006597          	auipc	a1,0x6
ffffffffc0200c58:	82458593          	addi	a1,a1,-2012 # ffffffffc0206478 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0200c5c:	e118                	sd	a4,0(a0)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200c5e:	e19c                	sd	a5,0(a1)
ffffffffc0200c60:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200c62:	4701                	li	a4,0
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200c64:	4885                	li	a7,1
ffffffffc0200c66:	fff80837          	lui	a6,0xfff80
ffffffffc0200c6a:	a011                	j	ffffffffc0200c6e <pmm_init+0x96>
        SetPageReserved(pages + i);
ffffffffc0200c6c:	619c                	ld	a5,0(a1)
ffffffffc0200c6e:	97b6                	add	a5,a5,a3
ffffffffc0200c70:	07a1                	addi	a5,a5,8
ffffffffc0200c72:	4117b02f          	amoor.d	zero,a7,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200c76:	611c                	ld	a5,0(a0)
ffffffffc0200c78:	0705                	addi	a4,a4,1
ffffffffc0200c7a:	02868693          	addi	a3,a3,40
ffffffffc0200c7e:	01078633          	add	a2,a5,a6
ffffffffc0200c82:	fec765e3          	bltu	a4,a2,ffffffffc0200c6c <pmm_init+0x94>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200c86:	6190                	ld	a2,0(a1)
ffffffffc0200c88:	00279713          	slli	a4,a5,0x2
ffffffffc0200c8c:	973e                	add	a4,a4,a5
ffffffffc0200c8e:	fec006b7          	lui	a3,0xfec00
ffffffffc0200c92:	070e                	slli	a4,a4,0x3
ffffffffc0200c94:	96b2                	add	a3,a3,a2
ffffffffc0200c96:	96ba                	add	a3,a3,a4
ffffffffc0200c98:	c0200737          	lui	a4,0xc0200
ffffffffc0200c9c:	08e6ef63          	bltu	a3,a4,ffffffffc0200d3a <pmm_init+0x162>
ffffffffc0200ca0:	6018                	ld	a4,0(s0)
    if (freemem < mem_end) {
ffffffffc0200ca2:	45c5                	li	a1,17
ffffffffc0200ca4:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200ca6:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0200ca8:	04b6e863          	bltu	a3,a1,ffffffffc0200cf8 <pmm_init+0x120>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200cac:	609c                	ld	a5,0(s1)
ffffffffc0200cae:	7b9c                	ld	a5,48(a5)
ffffffffc0200cb0:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200cb2:	00001517          	auipc	a0,0x1
ffffffffc0200cb6:	16650513          	addi	a0,a0,358 # ffffffffc0201e18 <slub_pmm_manager+0xd8>
ffffffffc0200cba:	bf8ff0ef          	jal	ra,ffffffffc02000b2 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200cbe:	00004597          	auipc	a1,0x4
ffffffffc0200cc2:	34258593          	addi	a1,a1,834 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200cc6:	00005797          	auipc	a5,0x5
ffffffffc0200cca:	7cb7b523          	sd	a1,1994(a5) # ffffffffc0206490 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200cce:	c02007b7          	lui	a5,0xc0200
ffffffffc0200cd2:	08f5e063          	bltu	a1,a5,ffffffffc0200d52 <pmm_init+0x17a>
ffffffffc0200cd6:	6010                	ld	a2,0(s0)
}
ffffffffc0200cd8:	6442                	ld	s0,16(sp)
ffffffffc0200cda:	60e2                	ld	ra,24(sp)
ffffffffc0200cdc:	64a2                	ld	s1,8(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0200cde:	40c58633          	sub	a2,a1,a2
ffffffffc0200ce2:	00005797          	auipc	a5,0x5
ffffffffc0200ce6:	7ac7b323          	sd	a2,1958(a5) # ffffffffc0206488 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200cea:	00001517          	auipc	a0,0x1
ffffffffc0200cee:	14e50513          	addi	a0,a0,334 # ffffffffc0201e38 <slub_pmm_manager+0xf8>
}
ffffffffc0200cf2:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200cf4:	bbeff06f          	j	ffffffffc02000b2 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200cf8:	6705                	lui	a4,0x1
ffffffffc0200cfa:	177d                	addi	a4,a4,-1
ffffffffc0200cfc:	96ba                	add	a3,a3,a4
ffffffffc0200cfe:	777d                	lui	a4,0xfffff
ffffffffc0200d00:	8ef9                	and	a3,a3,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200d02:	00c6d513          	srli	a0,a3,0xc
ffffffffc0200d06:	00f57e63          	bgeu	a0,a5,ffffffffc0200d22 <pmm_init+0x14a>
    pmm_manager->init_memmap(base, n);
ffffffffc0200d0a:	609c                	ld	a5,0(s1)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200d0c:	982a                	add	a6,a6,a0
ffffffffc0200d0e:	00281513          	slli	a0,a6,0x2
ffffffffc0200d12:	9542                	add	a0,a0,a6
ffffffffc0200d14:	6b9c                	ld	a5,16(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200d16:	8d95                	sub	a1,a1,a3
ffffffffc0200d18:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200d1a:	81b1                	srli	a1,a1,0xc
ffffffffc0200d1c:	9532                	add	a0,a0,a2
ffffffffc0200d1e:	9782                	jalr	a5
}
ffffffffc0200d20:	b771                	j	ffffffffc0200cac <pmm_init+0xd4>
        panic("pa2page called with invalid pa");
ffffffffc0200d22:	00001617          	auipc	a2,0x1
ffffffffc0200d26:	0c660613          	addi	a2,a2,198 # ffffffffc0201de8 <slub_pmm_manager+0xa8>
ffffffffc0200d2a:	06b00593          	li	a1,107
ffffffffc0200d2e:	00001517          	auipc	a0,0x1
ffffffffc0200d32:	0da50513          	addi	a0,a0,218 # ffffffffc0201e08 <slub_pmm_manager+0xc8>
ffffffffc0200d36:	e76ff0ef          	jal	ra,ffffffffc02003ac <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200d3a:	00001617          	auipc	a2,0x1
ffffffffc0200d3e:	d3e60613          	addi	a2,a2,-706 # ffffffffc0201a78 <commands+0x560>
ffffffffc0200d42:	07000593          	li	a1,112
ffffffffc0200d46:	00001517          	auipc	a0,0x1
ffffffffc0200d4a:	09250513          	addi	a0,a0,146 # ffffffffc0201dd8 <slub_pmm_manager+0x98>
ffffffffc0200d4e:	e5eff0ef          	jal	ra,ffffffffc02003ac <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200d52:	86ae                	mv	a3,a1
ffffffffc0200d54:	00001617          	auipc	a2,0x1
ffffffffc0200d58:	d2460613          	addi	a2,a2,-732 # ffffffffc0201a78 <commands+0x560>
ffffffffc0200d5c:	08b00593          	li	a1,139
ffffffffc0200d60:	00001517          	auipc	a0,0x1
ffffffffc0200d64:	07850513          	addi	a0,a0,120 # ffffffffc0201dd8 <slub_pmm_manager+0x98>
ffffffffc0200d68:	e44ff0ef          	jal	ra,ffffffffc02003ac <__panic>

ffffffffc0200d6c <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0200d6c:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200d70:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0200d72:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200d76:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0200d78:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200d7c:	f022                	sd	s0,32(sp)
ffffffffc0200d7e:	ec26                	sd	s1,24(sp)
ffffffffc0200d80:	e84a                	sd	s2,16(sp)
ffffffffc0200d82:	f406                	sd	ra,40(sp)
ffffffffc0200d84:	e44e                	sd	s3,8(sp)
ffffffffc0200d86:	84aa                	mv	s1,a0
ffffffffc0200d88:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0200d8a:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0200d8e:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0200d90:	03067e63          	bgeu	a2,a6,ffffffffc0200dcc <printnum+0x60>
ffffffffc0200d94:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0200d96:	00805763          	blez	s0,ffffffffc0200da4 <printnum+0x38>
ffffffffc0200d9a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0200d9c:	85ca                	mv	a1,s2
ffffffffc0200d9e:	854e                	mv	a0,s3
ffffffffc0200da0:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0200da2:	fc65                	bnez	s0,ffffffffc0200d9a <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200da4:	1a02                	slli	s4,s4,0x20
ffffffffc0200da6:	00001797          	auipc	a5,0x1
ffffffffc0200daa:	0d278793          	addi	a5,a5,210 # ffffffffc0201e78 <slub_pmm_manager+0x138>
ffffffffc0200dae:	020a5a13          	srli	s4,s4,0x20
ffffffffc0200db2:	9a3e                	add	s4,s4,a5
}
ffffffffc0200db4:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200db6:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0200dba:	70a2                	ld	ra,40(sp)
ffffffffc0200dbc:	69a2                	ld	s3,8(sp)
ffffffffc0200dbe:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200dc0:	85ca                	mv	a1,s2
ffffffffc0200dc2:	87a6                	mv	a5,s1
}
ffffffffc0200dc4:	6942                	ld	s2,16(sp)
ffffffffc0200dc6:	64e2                	ld	s1,24(sp)
ffffffffc0200dc8:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200dca:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0200dcc:	03065633          	divu	a2,a2,a6
ffffffffc0200dd0:	8722                	mv	a4,s0
ffffffffc0200dd2:	f9bff0ef          	jal	ra,ffffffffc0200d6c <printnum>
ffffffffc0200dd6:	b7f9                	j	ffffffffc0200da4 <printnum+0x38>

ffffffffc0200dd8 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0200dd8:	7119                	addi	sp,sp,-128
ffffffffc0200dda:	f4a6                	sd	s1,104(sp)
ffffffffc0200ddc:	f0ca                	sd	s2,96(sp)
ffffffffc0200dde:	ecce                	sd	s3,88(sp)
ffffffffc0200de0:	e8d2                	sd	s4,80(sp)
ffffffffc0200de2:	e4d6                	sd	s5,72(sp)
ffffffffc0200de4:	e0da                	sd	s6,64(sp)
ffffffffc0200de6:	fc5e                	sd	s7,56(sp)
ffffffffc0200de8:	f06a                	sd	s10,32(sp)
ffffffffc0200dea:	fc86                	sd	ra,120(sp)
ffffffffc0200dec:	f8a2                	sd	s0,112(sp)
ffffffffc0200dee:	f862                	sd	s8,48(sp)
ffffffffc0200df0:	f466                	sd	s9,40(sp)
ffffffffc0200df2:	ec6e                	sd	s11,24(sp)
ffffffffc0200df4:	892a                	mv	s2,a0
ffffffffc0200df6:	84ae                	mv	s1,a1
ffffffffc0200df8:	8d32                	mv	s10,a2
ffffffffc0200dfa:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200dfc:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0200e00:	5b7d                	li	s6,-1
ffffffffc0200e02:	00001a97          	auipc	s5,0x1
ffffffffc0200e06:	0aaa8a93          	addi	s5,s5,170 # ffffffffc0201eac <slub_pmm_manager+0x16c>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0200e0a:	00001b97          	auipc	s7,0x1
ffffffffc0200e0e:	27eb8b93          	addi	s7,s7,638 # ffffffffc0202088 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200e12:	000d4503          	lbu	a0,0(s10)
ffffffffc0200e16:	001d0413          	addi	s0,s10,1
ffffffffc0200e1a:	01350a63          	beq	a0,s3,ffffffffc0200e2e <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc0200e1e:	c121                	beqz	a0,ffffffffc0200e5e <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc0200e20:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200e22:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0200e24:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200e26:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200e2a:	ff351ae3          	bne	a0,s3,ffffffffc0200e1e <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200e2e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0200e32:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0200e36:	4c81                	li	s9,0
ffffffffc0200e38:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0200e3a:	5c7d                	li	s8,-1
ffffffffc0200e3c:	5dfd                	li	s11,-1
ffffffffc0200e3e:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc0200e42:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200e44:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0200e48:	0ff5f593          	andi	a1,a1,255
ffffffffc0200e4c:	00140d13          	addi	s10,s0,1
ffffffffc0200e50:	04b56263          	bltu	a0,a1,ffffffffc0200e94 <vprintfmt+0xbc>
ffffffffc0200e54:	058a                	slli	a1,a1,0x2
ffffffffc0200e56:	95d6                	add	a1,a1,s5
ffffffffc0200e58:	4194                	lw	a3,0(a1)
ffffffffc0200e5a:	96d6                	add	a3,a3,s5
ffffffffc0200e5c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0200e5e:	70e6                	ld	ra,120(sp)
ffffffffc0200e60:	7446                	ld	s0,112(sp)
ffffffffc0200e62:	74a6                	ld	s1,104(sp)
ffffffffc0200e64:	7906                	ld	s2,96(sp)
ffffffffc0200e66:	69e6                	ld	s3,88(sp)
ffffffffc0200e68:	6a46                	ld	s4,80(sp)
ffffffffc0200e6a:	6aa6                	ld	s5,72(sp)
ffffffffc0200e6c:	6b06                	ld	s6,64(sp)
ffffffffc0200e6e:	7be2                	ld	s7,56(sp)
ffffffffc0200e70:	7c42                	ld	s8,48(sp)
ffffffffc0200e72:	7ca2                	ld	s9,40(sp)
ffffffffc0200e74:	7d02                	ld	s10,32(sp)
ffffffffc0200e76:	6de2                	ld	s11,24(sp)
ffffffffc0200e78:	6109                	addi	sp,sp,128
ffffffffc0200e7a:	8082                	ret
            padc = '0';
ffffffffc0200e7c:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc0200e7e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200e82:	846a                	mv	s0,s10
ffffffffc0200e84:	00140d13          	addi	s10,s0,1
ffffffffc0200e88:	fdd6059b          	addiw	a1,a2,-35
ffffffffc0200e8c:	0ff5f593          	andi	a1,a1,255
ffffffffc0200e90:	fcb572e3          	bgeu	a0,a1,ffffffffc0200e54 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc0200e94:	85a6                	mv	a1,s1
ffffffffc0200e96:	02500513          	li	a0,37
ffffffffc0200e9a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0200e9c:	fff44783          	lbu	a5,-1(s0)
ffffffffc0200ea0:	8d22                	mv	s10,s0
ffffffffc0200ea2:	f73788e3          	beq	a5,s3,ffffffffc0200e12 <vprintfmt+0x3a>
ffffffffc0200ea6:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0200eaa:	1d7d                	addi	s10,s10,-1
ffffffffc0200eac:	ff379de3          	bne	a5,s3,ffffffffc0200ea6 <vprintfmt+0xce>
ffffffffc0200eb0:	b78d                	j	ffffffffc0200e12 <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc0200eb2:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0200eb6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200eba:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0200ebc:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0200ec0:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0200ec4:	02d86463          	bltu	a6,a3,ffffffffc0200eec <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0200ec8:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0200ecc:	002c169b          	slliw	a3,s8,0x2
ffffffffc0200ed0:	0186873b          	addw	a4,a3,s8
ffffffffc0200ed4:	0017171b          	slliw	a4,a4,0x1
ffffffffc0200ed8:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0200eda:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0200ede:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0200ee0:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0200ee4:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0200ee8:	fed870e3          	bgeu	a6,a3,ffffffffc0200ec8 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0200eec:	f40ddce3          	bgez	s11,ffffffffc0200e44 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc0200ef0:	8de2                	mv	s11,s8
ffffffffc0200ef2:	5c7d                	li	s8,-1
ffffffffc0200ef4:	bf81                	j	ffffffffc0200e44 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0200ef6:	fffdc693          	not	a3,s11
ffffffffc0200efa:	96fd                	srai	a3,a3,0x3f
ffffffffc0200efc:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200f00:	00144603          	lbu	a2,1(s0)
ffffffffc0200f04:	2d81                	sext.w	s11,s11
ffffffffc0200f06:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0200f08:	bf35                	j	ffffffffc0200e44 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0200f0a:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200f0e:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0200f12:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200f14:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0200f16:	bfd9                	j	ffffffffc0200eec <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0200f18:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0200f1a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0200f1e:	01174463          	blt	a4,a7,ffffffffc0200f26 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc0200f22:	1a088e63          	beqz	a7,ffffffffc02010de <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0200f26:	000a3603          	ld	a2,0(s4)
ffffffffc0200f2a:	46c1                	li	a3,16
ffffffffc0200f2c:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0200f2e:	2781                	sext.w	a5,a5
ffffffffc0200f30:	876e                	mv	a4,s11
ffffffffc0200f32:	85a6                	mv	a1,s1
ffffffffc0200f34:	854a                	mv	a0,s2
ffffffffc0200f36:	e37ff0ef          	jal	ra,ffffffffc0200d6c <printnum>
            break;
ffffffffc0200f3a:	bde1                	j	ffffffffc0200e12 <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0200f3c:	000a2503          	lw	a0,0(s4)
ffffffffc0200f40:	85a6                	mv	a1,s1
ffffffffc0200f42:	0a21                	addi	s4,s4,8
ffffffffc0200f44:	9902                	jalr	s2
            break;
ffffffffc0200f46:	b5f1                	j	ffffffffc0200e12 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0200f48:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0200f4a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0200f4e:	01174463          	blt	a4,a7,ffffffffc0200f56 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc0200f52:	18088163          	beqz	a7,ffffffffc02010d4 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc0200f56:	000a3603          	ld	a2,0(s4)
ffffffffc0200f5a:	46a9                	li	a3,10
ffffffffc0200f5c:	8a2e                	mv	s4,a1
ffffffffc0200f5e:	bfc1                	j	ffffffffc0200f2e <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200f60:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc0200f64:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200f66:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0200f68:	bdf1                	j	ffffffffc0200e44 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc0200f6a:	85a6                	mv	a1,s1
ffffffffc0200f6c:	02500513          	li	a0,37
ffffffffc0200f70:	9902                	jalr	s2
            break;
ffffffffc0200f72:	b545                	j	ffffffffc0200e12 <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200f74:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc0200f78:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200f7a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0200f7c:	b5e1                	j	ffffffffc0200e44 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc0200f7e:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0200f80:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0200f84:	01174463          	blt	a4,a7,ffffffffc0200f8c <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc0200f88:	14088163          	beqz	a7,ffffffffc02010ca <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc0200f8c:	000a3603          	ld	a2,0(s4)
ffffffffc0200f90:	46a1                	li	a3,8
ffffffffc0200f92:	8a2e                	mv	s4,a1
ffffffffc0200f94:	bf69                	j	ffffffffc0200f2e <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc0200f96:	03000513          	li	a0,48
ffffffffc0200f9a:	85a6                	mv	a1,s1
ffffffffc0200f9c:	e03e                	sd	a5,0(sp)
ffffffffc0200f9e:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0200fa0:	85a6                	mv	a1,s1
ffffffffc0200fa2:	07800513          	li	a0,120
ffffffffc0200fa6:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0200fa8:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0200faa:	6782                	ld	a5,0(sp)
ffffffffc0200fac:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0200fae:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc0200fb2:	bfb5                	j	ffffffffc0200f2e <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0200fb4:	000a3403          	ld	s0,0(s4)
ffffffffc0200fb8:	008a0713          	addi	a4,s4,8
ffffffffc0200fbc:	e03a                	sd	a4,0(sp)
ffffffffc0200fbe:	14040263          	beqz	s0,ffffffffc0201102 <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc0200fc2:	0fb05763          	blez	s11,ffffffffc02010b0 <vprintfmt+0x2d8>
ffffffffc0200fc6:	02d00693          	li	a3,45
ffffffffc0200fca:	0cd79163          	bne	a5,a3,ffffffffc020108c <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0200fce:	00044783          	lbu	a5,0(s0)
ffffffffc0200fd2:	0007851b          	sext.w	a0,a5
ffffffffc0200fd6:	cf85                	beqz	a5,ffffffffc020100e <vprintfmt+0x236>
ffffffffc0200fd8:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0200fdc:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0200fe0:	000c4563          	bltz	s8,ffffffffc0200fea <vprintfmt+0x212>
ffffffffc0200fe4:	3c7d                	addiw	s8,s8,-1
ffffffffc0200fe6:	036c0263          	beq	s8,s6,ffffffffc020100a <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0200fea:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0200fec:	0e0c8e63          	beqz	s9,ffffffffc02010e8 <vprintfmt+0x310>
ffffffffc0200ff0:	3781                	addiw	a5,a5,-32
ffffffffc0200ff2:	0ef47b63          	bgeu	s0,a5,ffffffffc02010e8 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0200ff6:	03f00513          	li	a0,63
ffffffffc0200ffa:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0200ffc:	000a4783          	lbu	a5,0(s4)
ffffffffc0201000:	3dfd                	addiw	s11,s11,-1
ffffffffc0201002:	0a05                	addi	s4,s4,1
ffffffffc0201004:	0007851b          	sext.w	a0,a5
ffffffffc0201008:	ffe1                	bnez	a5,ffffffffc0200fe0 <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc020100a:	01b05963          	blez	s11,ffffffffc020101c <vprintfmt+0x244>
ffffffffc020100e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201010:	85a6                	mv	a1,s1
ffffffffc0201012:	02000513          	li	a0,32
ffffffffc0201016:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201018:	fe0d9be3          	bnez	s11,ffffffffc020100e <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020101c:	6a02                	ld	s4,0(sp)
ffffffffc020101e:	bbd5                	j	ffffffffc0200e12 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201020:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201022:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0201026:	01174463          	blt	a4,a7,ffffffffc020102e <vprintfmt+0x256>
    else if (lflag) {
ffffffffc020102a:	08088d63          	beqz	a7,ffffffffc02010c4 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc020102e:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201032:	0a044d63          	bltz	s0,ffffffffc02010ec <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0201036:	8622                	mv	a2,s0
ffffffffc0201038:	8a66                	mv	s4,s9
ffffffffc020103a:	46a9                	li	a3,10
ffffffffc020103c:	bdcd                	j	ffffffffc0200f2e <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc020103e:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201042:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0201044:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201046:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc020104a:	8fb5                	xor	a5,a5,a3
ffffffffc020104c:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201050:	02d74163          	blt	a4,a3,ffffffffc0201072 <vprintfmt+0x29a>
ffffffffc0201054:	00369793          	slli	a5,a3,0x3
ffffffffc0201058:	97de                	add	a5,a5,s7
ffffffffc020105a:	639c                	ld	a5,0(a5)
ffffffffc020105c:	cb99                	beqz	a5,ffffffffc0201072 <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc020105e:	86be                	mv	a3,a5
ffffffffc0201060:	00001617          	auipc	a2,0x1
ffffffffc0201064:	e4860613          	addi	a2,a2,-440 # ffffffffc0201ea8 <slub_pmm_manager+0x168>
ffffffffc0201068:	85a6                	mv	a1,s1
ffffffffc020106a:	854a                	mv	a0,s2
ffffffffc020106c:	0ce000ef          	jal	ra,ffffffffc020113a <printfmt>
ffffffffc0201070:	b34d                	j	ffffffffc0200e12 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201072:	00001617          	auipc	a2,0x1
ffffffffc0201076:	e2660613          	addi	a2,a2,-474 # ffffffffc0201e98 <slub_pmm_manager+0x158>
ffffffffc020107a:	85a6                	mv	a1,s1
ffffffffc020107c:	854a                	mv	a0,s2
ffffffffc020107e:	0bc000ef          	jal	ra,ffffffffc020113a <printfmt>
ffffffffc0201082:	bb41                	j	ffffffffc0200e12 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201084:	00001417          	auipc	s0,0x1
ffffffffc0201088:	e0c40413          	addi	s0,s0,-500 # ffffffffc0201e90 <slub_pmm_manager+0x150>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020108c:	85e2                	mv	a1,s8
ffffffffc020108e:	8522                	mv	a0,s0
ffffffffc0201090:	e43e                	sd	a5,8(sp)
ffffffffc0201092:	1cc000ef          	jal	ra,ffffffffc020125e <strnlen>
ffffffffc0201096:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020109a:	01b05b63          	blez	s11,ffffffffc02010b0 <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc020109e:	67a2                	ld	a5,8(sp)
ffffffffc02010a0:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02010a4:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc02010a6:	85a6                	mv	a1,s1
ffffffffc02010a8:	8552                	mv	a0,s4
ffffffffc02010aa:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02010ac:	fe0d9ce3          	bnez	s11,ffffffffc02010a4 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02010b0:	00044783          	lbu	a5,0(s0)
ffffffffc02010b4:	00140a13          	addi	s4,s0,1
ffffffffc02010b8:	0007851b          	sext.w	a0,a5
ffffffffc02010bc:	d3a5                	beqz	a5,ffffffffc020101c <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02010be:	05e00413          	li	s0,94
ffffffffc02010c2:	bf39                	j	ffffffffc0200fe0 <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc02010c4:	000a2403          	lw	s0,0(s4)
ffffffffc02010c8:	b7ad                	j	ffffffffc0201032 <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc02010ca:	000a6603          	lwu	a2,0(s4)
ffffffffc02010ce:	46a1                	li	a3,8
ffffffffc02010d0:	8a2e                	mv	s4,a1
ffffffffc02010d2:	bdb1                	j	ffffffffc0200f2e <vprintfmt+0x156>
ffffffffc02010d4:	000a6603          	lwu	a2,0(s4)
ffffffffc02010d8:	46a9                	li	a3,10
ffffffffc02010da:	8a2e                	mv	s4,a1
ffffffffc02010dc:	bd89                	j	ffffffffc0200f2e <vprintfmt+0x156>
ffffffffc02010de:	000a6603          	lwu	a2,0(s4)
ffffffffc02010e2:	46c1                	li	a3,16
ffffffffc02010e4:	8a2e                	mv	s4,a1
ffffffffc02010e6:	b5a1                	j	ffffffffc0200f2e <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc02010e8:	9902                	jalr	s2
ffffffffc02010ea:	bf09                	j	ffffffffc0200ffc <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc02010ec:	85a6                	mv	a1,s1
ffffffffc02010ee:	02d00513          	li	a0,45
ffffffffc02010f2:	e03e                	sd	a5,0(sp)
ffffffffc02010f4:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02010f6:	6782                	ld	a5,0(sp)
ffffffffc02010f8:	8a66                	mv	s4,s9
ffffffffc02010fa:	40800633          	neg	a2,s0
ffffffffc02010fe:	46a9                	li	a3,10
ffffffffc0201100:	b53d                	j	ffffffffc0200f2e <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc0201102:	03b05163          	blez	s11,ffffffffc0201124 <vprintfmt+0x34c>
ffffffffc0201106:	02d00693          	li	a3,45
ffffffffc020110a:	f6d79de3          	bne	a5,a3,ffffffffc0201084 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc020110e:	00001417          	auipc	s0,0x1
ffffffffc0201112:	d8240413          	addi	s0,s0,-638 # ffffffffc0201e90 <slub_pmm_manager+0x150>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201116:	02800793          	li	a5,40
ffffffffc020111a:	02800513          	li	a0,40
ffffffffc020111e:	00140a13          	addi	s4,s0,1
ffffffffc0201122:	bd6d                	j	ffffffffc0200fdc <vprintfmt+0x204>
ffffffffc0201124:	00001a17          	auipc	s4,0x1
ffffffffc0201128:	d6da0a13          	addi	s4,s4,-659 # ffffffffc0201e91 <slub_pmm_manager+0x151>
ffffffffc020112c:	02800513          	li	a0,40
ffffffffc0201130:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201134:	05e00413          	li	s0,94
ffffffffc0201138:	b565                	j	ffffffffc0200fe0 <vprintfmt+0x208>

ffffffffc020113a <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020113a:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020113c:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201140:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201142:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201144:	ec06                	sd	ra,24(sp)
ffffffffc0201146:	f83a                	sd	a4,48(sp)
ffffffffc0201148:	fc3e                	sd	a5,56(sp)
ffffffffc020114a:	e0c2                	sd	a6,64(sp)
ffffffffc020114c:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020114e:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201150:	c89ff0ef          	jal	ra,ffffffffc0200dd8 <vprintfmt>
}
ffffffffc0201154:	60e2                	ld	ra,24(sp)
ffffffffc0201156:	6161                	addi	sp,sp,80
ffffffffc0201158:	8082                	ret

ffffffffc020115a <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc020115a:	715d                	addi	sp,sp,-80
ffffffffc020115c:	e486                	sd	ra,72(sp)
ffffffffc020115e:	e0a6                	sd	s1,64(sp)
ffffffffc0201160:	fc4a                	sd	s2,56(sp)
ffffffffc0201162:	f84e                	sd	s3,48(sp)
ffffffffc0201164:	f452                	sd	s4,40(sp)
ffffffffc0201166:	f056                	sd	s5,32(sp)
ffffffffc0201168:	ec5a                	sd	s6,24(sp)
ffffffffc020116a:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc020116c:	c901                	beqz	a0,ffffffffc020117c <readline+0x22>
ffffffffc020116e:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc0201170:	00001517          	auipc	a0,0x1
ffffffffc0201174:	d3850513          	addi	a0,a0,-712 # ffffffffc0201ea8 <slub_pmm_manager+0x168>
ffffffffc0201178:	f3bfe0ef          	jal	ra,ffffffffc02000b2 <cprintf>
readline(const char *prompt) {
ffffffffc020117c:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020117e:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201180:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201182:	4aa9                	li	s5,10
ffffffffc0201184:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201186:	00005b97          	auipc	s7,0x5
ffffffffc020118a:	edab8b93          	addi	s7,s7,-294 # ffffffffc0206060 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020118e:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201192:	f99fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc0201196:	00054a63          	bltz	a0,ffffffffc02011aa <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020119a:	00a95a63          	bge	s2,a0,ffffffffc02011ae <readline+0x54>
ffffffffc020119e:	029a5263          	bge	s4,s1,ffffffffc02011c2 <readline+0x68>
        c = getchar();
ffffffffc02011a2:	f89fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02011a6:	fe055ae3          	bgez	a0,ffffffffc020119a <readline+0x40>
            return NULL;
ffffffffc02011aa:	4501                	li	a0,0
ffffffffc02011ac:	a091                	j	ffffffffc02011f0 <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc02011ae:	03351463          	bne	a0,s3,ffffffffc02011d6 <readline+0x7c>
ffffffffc02011b2:	e8a9                	bnez	s1,ffffffffc0201204 <readline+0xaa>
        c = getchar();
ffffffffc02011b4:	f77fe0ef          	jal	ra,ffffffffc020012a <getchar>
        if (c < 0) {
ffffffffc02011b8:	fe0549e3          	bltz	a0,ffffffffc02011aa <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02011bc:	fea959e3          	bge	s2,a0,ffffffffc02011ae <readline+0x54>
ffffffffc02011c0:	4481                	li	s1,0
            cputchar(c);
ffffffffc02011c2:	e42a                	sd	a0,8(sp)
ffffffffc02011c4:	f25fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i ++] = c;
ffffffffc02011c8:	6522                	ld	a0,8(sp)
ffffffffc02011ca:	009b87b3          	add	a5,s7,s1
ffffffffc02011ce:	2485                	addiw	s1,s1,1
ffffffffc02011d0:	00a78023          	sb	a0,0(a5)
ffffffffc02011d4:	bf7d                	j	ffffffffc0201192 <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc02011d6:	01550463          	beq	a0,s5,ffffffffc02011de <readline+0x84>
ffffffffc02011da:	fb651ce3          	bne	a0,s6,ffffffffc0201192 <readline+0x38>
            cputchar(c);
ffffffffc02011de:	f0bfe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            buf[i] = '\0';
ffffffffc02011e2:	00005517          	auipc	a0,0x5
ffffffffc02011e6:	e7e50513          	addi	a0,a0,-386 # ffffffffc0206060 <buf>
ffffffffc02011ea:	94aa                	add	s1,s1,a0
ffffffffc02011ec:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02011f0:	60a6                	ld	ra,72(sp)
ffffffffc02011f2:	6486                	ld	s1,64(sp)
ffffffffc02011f4:	7962                	ld	s2,56(sp)
ffffffffc02011f6:	79c2                	ld	s3,48(sp)
ffffffffc02011f8:	7a22                	ld	s4,40(sp)
ffffffffc02011fa:	7a82                	ld	s5,32(sp)
ffffffffc02011fc:	6b62                	ld	s6,24(sp)
ffffffffc02011fe:	6bc2                	ld	s7,16(sp)
ffffffffc0201200:	6161                	addi	sp,sp,80
ffffffffc0201202:	8082                	ret
            cputchar(c);
ffffffffc0201204:	4521                	li	a0,8
ffffffffc0201206:	ee3fe0ef          	jal	ra,ffffffffc02000e8 <cputchar>
            i --;
ffffffffc020120a:	34fd                	addiw	s1,s1,-1
ffffffffc020120c:	b759                	j	ffffffffc0201192 <readline+0x38>

ffffffffc020120e <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc020120e:	4781                	li	a5,0
ffffffffc0201210:	00005717          	auipc	a4,0x5
ffffffffc0201214:	df873703          	ld	a4,-520(a4) # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201218:	88ba                	mv	a7,a4
ffffffffc020121a:	852a                	mv	a0,a0
ffffffffc020121c:	85be                	mv	a1,a5
ffffffffc020121e:	863e                	mv	a2,a5
ffffffffc0201220:	00000073          	ecall
ffffffffc0201224:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201226:	8082                	ret

ffffffffc0201228 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201228:	4781                	li	a5,0
ffffffffc020122a:	00005717          	auipc	a4,0x5
ffffffffc020122e:	27673703          	ld	a4,630(a4) # ffffffffc02064a0 <SBI_SET_TIMER>
ffffffffc0201232:	88ba                	mv	a7,a4
ffffffffc0201234:	852a                	mv	a0,a0
ffffffffc0201236:	85be                	mv	a1,a5
ffffffffc0201238:	863e                	mv	a2,a5
ffffffffc020123a:	00000073          	ecall
ffffffffc020123e:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201240:	8082                	ret

ffffffffc0201242 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201242:	4501                	li	a0,0
ffffffffc0201244:	00005797          	auipc	a5,0x5
ffffffffc0201248:	dbc7b783          	ld	a5,-580(a5) # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
ffffffffc020124c:	88be                	mv	a7,a5
ffffffffc020124e:	852a                	mv	a0,a0
ffffffffc0201250:	85aa                	mv	a1,a0
ffffffffc0201252:	862a                	mv	a2,a0
ffffffffc0201254:	00000073          	ecall
ffffffffc0201258:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc020125a:	2501                	sext.w	a0,a0
ffffffffc020125c:	8082                	ret

ffffffffc020125e <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020125e:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201260:	e589                	bnez	a1,ffffffffc020126a <strnlen+0xc>
ffffffffc0201262:	a811                	j	ffffffffc0201276 <strnlen+0x18>
        cnt ++;
ffffffffc0201264:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201266:	00f58863          	beq	a1,a5,ffffffffc0201276 <strnlen+0x18>
ffffffffc020126a:	00f50733          	add	a4,a0,a5
ffffffffc020126e:	00074703          	lbu	a4,0(a4)
ffffffffc0201272:	fb6d                	bnez	a4,ffffffffc0201264 <strnlen+0x6>
ffffffffc0201274:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201276:	852e                	mv	a0,a1
ffffffffc0201278:	8082                	ret

ffffffffc020127a <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020127a:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020127e:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201282:	cb89                	beqz	a5,ffffffffc0201294 <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc0201284:	0505                	addi	a0,a0,1
ffffffffc0201286:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201288:	fee789e3          	beq	a5,a4,ffffffffc020127a <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020128c:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201290:	9d19                	subw	a0,a0,a4
ffffffffc0201292:	8082                	ret
ffffffffc0201294:	4501                	li	a0,0
ffffffffc0201296:	bfed                	j	ffffffffc0201290 <strcmp+0x16>

ffffffffc0201298 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201298:	00054783          	lbu	a5,0(a0)
ffffffffc020129c:	c799                	beqz	a5,ffffffffc02012aa <strchr+0x12>
        if (*s == c) {
ffffffffc020129e:	00f58763          	beq	a1,a5,ffffffffc02012ac <strchr+0x14>
    while (*s != '\0') {
ffffffffc02012a2:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02012a6:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02012a8:	fbfd                	bnez	a5,ffffffffc020129e <strchr+0x6>
    }
    return NULL;
ffffffffc02012aa:	4501                	li	a0,0
}
ffffffffc02012ac:	8082                	ret

ffffffffc02012ae <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02012ae:	ca01                	beqz	a2,ffffffffc02012be <memset+0x10>
ffffffffc02012b0:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02012b2:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02012b4:	0785                	addi	a5,a5,1
ffffffffc02012b6:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02012ba:	fec79de3          	bne	a5,a2,ffffffffc02012b4 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02012be:	8082                	ret
