
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c02092b7          	lui	t0,0xc0209
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc0200004:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200008:	01e31313          	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc020000c:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200010:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc0200014:	fff0031b          	addiw	t1,zero,-1
ffffffffc0200018:	03f31313          	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc020001c:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200020:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200024:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc0200028:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	0000a517          	auipc	a0,0xa
ffffffffc020003a:	00a50513          	addi	a0,a0,10 # ffffffffc020a040 <edata>
ffffffffc020003e:	00011617          	auipc	a2,0x11
ffffffffc0200042:	55260613          	addi	a2,a2,1362 # ffffffffc0211590 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	2d6040ef          	jal	ra,ffffffffc0204324 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200052:	00004597          	auipc	a1,0x4
ffffffffc0200056:	2fe58593          	addi	a1,a1,766 # ffffffffc0204350 <etext+0x2>
ffffffffc020005a:	00004517          	auipc	a0,0x4
ffffffffc020005e:	31650513          	addi	a0,a0,790 # ffffffffc0204370 <etext+0x22>
ffffffffc0200062:	05c000ef          	jal	ra,ffffffffc02000be <cprintf>

    print_kerninfo();
ffffffffc0200066:	09e000ef          	jal	ra,ffffffffc0200104 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006a:	283010ef          	jal	ra,ffffffffc0201aec <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006e:	4fc000ef          	jal	ra,ffffffffc020056a <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc0200072:	5a4030ef          	jal	ra,ffffffffc0203616 <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200076:	41e000ef          	jal	ra,ffffffffc0200494 <ide_init>
    swap_init();                // init swap
ffffffffc020007a:	764020ef          	jal	ra,ffffffffc02027de <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007e:	352000ef          	jal	ra,ffffffffc02003d0 <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
ffffffffc0200082:	a001                	j	ffffffffc0200082 <kern_init+0x4c>

ffffffffc0200084 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200084:	1141                	addi	sp,sp,-16
ffffffffc0200086:	e022                	sd	s0,0(sp)
ffffffffc0200088:	e406                	sd	ra,8(sp)
ffffffffc020008a:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020008c:	398000ef          	jal	ra,ffffffffc0200424 <cons_putc>
    (*cnt) ++;
ffffffffc0200090:	401c                	lw	a5,0(s0)
}
ffffffffc0200092:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200094:	2785                	addiw	a5,a5,1
ffffffffc0200096:	c01c                	sw	a5,0(s0)
}
ffffffffc0200098:	6402                	ld	s0,0(sp)
ffffffffc020009a:	0141                	addi	sp,sp,16
ffffffffc020009c:	8082                	ret

ffffffffc020009e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009e:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	86ae                	mv	a3,a1
ffffffffc02000a2:	862a                	mv	a2,a0
ffffffffc02000a4:	006c                	addi	a1,sp,12
ffffffffc02000a6:	00000517          	auipc	a0,0x0
ffffffffc02000aa:	fde50513          	addi	a0,a0,-34 # ffffffffc0200084 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ae:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000b0:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000b2:	597030ef          	jal	ra,ffffffffc0203e48 <vprintfmt>
    return cnt;
}
ffffffffc02000b6:	60e2                	ld	ra,24(sp)
ffffffffc02000b8:	4532                	lw	a0,12(sp)
ffffffffc02000ba:	6105                	addi	sp,sp,32
ffffffffc02000bc:	8082                	ret

ffffffffc02000be <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000be:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000c0:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c4:	f42e                	sd	a1,40(sp)
ffffffffc02000c6:	f832                	sd	a2,48(sp)
ffffffffc02000c8:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ca:	862a                	mv	a2,a0
ffffffffc02000cc:	004c                	addi	a1,sp,4
ffffffffc02000ce:	00000517          	auipc	a0,0x0
ffffffffc02000d2:	fb650513          	addi	a0,a0,-74 # ffffffffc0200084 <cputch>
ffffffffc02000d6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d8:	ec06                	sd	ra,24(sp)
ffffffffc02000da:	e0ba                	sd	a4,64(sp)
ffffffffc02000dc:	e4be                	sd	a5,72(sp)
ffffffffc02000de:	e8c2                	sd	a6,80(sp)
ffffffffc02000e0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e6:	563030ef          	jal	ra,ffffffffc0203e48 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000ea:	60e2                	ld	ra,24(sp)
ffffffffc02000ec:	4512                	lw	a0,4(sp)
ffffffffc02000ee:	6125                	addi	sp,sp,96
ffffffffc02000f0:	8082                	ret

ffffffffc02000f2 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f2:	ae0d                	j	ffffffffc0200424 <cons_putc>

ffffffffc02000f4 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f4:	1141                	addi	sp,sp,-16
ffffffffc02000f6:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000f8:	360000ef          	jal	ra,ffffffffc0200458 <cons_getc>
ffffffffc02000fc:	dd75                	beqz	a0,ffffffffc02000f8 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02000fe:	60a2                	ld	ra,8(sp)
ffffffffc0200100:	0141                	addi	sp,sp,16
ffffffffc0200102:	8082                	ret

ffffffffc0200104 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200104:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200106:	00004517          	auipc	a0,0x4
ffffffffc020010a:	2a250513          	addi	a0,a0,674 # ffffffffc02043a8 <etext+0x5a>
void print_kerninfo(void) {
ffffffffc020010e:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200110:	fafff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200114:	00000597          	auipc	a1,0x0
ffffffffc0200118:	f2258593          	addi	a1,a1,-222 # ffffffffc0200036 <kern_init>
ffffffffc020011c:	00004517          	auipc	a0,0x4
ffffffffc0200120:	2ac50513          	addi	a0,a0,684 # ffffffffc02043c8 <etext+0x7a>
ffffffffc0200124:	f9bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200128:	00004597          	auipc	a1,0x4
ffffffffc020012c:	22658593          	addi	a1,a1,550 # ffffffffc020434e <etext>
ffffffffc0200130:	00004517          	auipc	a0,0x4
ffffffffc0200134:	2b850513          	addi	a0,a0,696 # ffffffffc02043e8 <etext+0x9a>
ffffffffc0200138:	f87ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020013c:	0000a597          	auipc	a1,0xa
ffffffffc0200140:	f0458593          	addi	a1,a1,-252 # ffffffffc020a040 <edata>
ffffffffc0200144:	00004517          	auipc	a0,0x4
ffffffffc0200148:	2c450513          	addi	a0,a0,708 # ffffffffc0204408 <etext+0xba>
ffffffffc020014c:	f73ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200150:	00011597          	auipc	a1,0x11
ffffffffc0200154:	44058593          	addi	a1,a1,1088 # ffffffffc0211590 <end>
ffffffffc0200158:	00004517          	auipc	a0,0x4
ffffffffc020015c:	2d050513          	addi	a0,a0,720 # ffffffffc0204428 <etext+0xda>
ffffffffc0200160:	f5fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200164:	00012597          	auipc	a1,0x12
ffffffffc0200168:	82b58593          	addi	a1,a1,-2005 # ffffffffc021198f <end+0x3ff>
ffffffffc020016c:	00000797          	auipc	a5,0x0
ffffffffc0200170:	eca78793          	addi	a5,a5,-310 # ffffffffc0200036 <kern_init>
ffffffffc0200174:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200178:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020017c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020017e:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200182:	95be                	add	a1,a1,a5
ffffffffc0200184:	85a9                	srai	a1,a1,0xa
ffffffffc0200186:	00004517          	auipc	a0,0x4
ffffffffc020018a:	2c250513          	addi	a0,a0,706 # ffffffffc0204448 <etext+0xfa>
}
ffffffffc020018e:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200190:	b73d                	j	ffffffffc02000be <cprintf>

ffffffffc0200192 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200192:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200194:	00004617          	auipc	a2,0x4
ffffffffc0200198:	1e460613          	addi	a2,a2,484 # ffffffffc0204378 <etext+0x2a>
ffffffffc020019c:	04e00593          	li	a1,78
ffffffffc02001a0:	00004517          	auipc	a0,0x4
ffffffffc02001a4:	1f050513          	addi	a0,a0,496 # ffffffffc0204390 <etext+0x42>
void print_stackframe(void) {
ffffffffc02001a8:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001aa:	1c6000ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc02001ae <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001ae:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001b0:	00004617          	auipc	a2,0x4
ffffffffc02001b4:	3a060613          	addi	a2,a2,928 # ffffffffc0204550 <commands+0xd8>
ffffffffc02001b8:	00004597          	auipc	a1,0x4
ffffffffc02001bc:	3b858593          	addi	a1,a1,952 # ffffffffc0204570 <commands+0xf8>
ffffffffc02001c0:	00004517          	auipc	a0,0x4
ffffffffc02001c4:	3b850513          	addi	a0,a0,952 # ffffffffc0204578 <commands+0x100>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001c8:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ca:	ef5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02001ce:	00004617          	auipc	a2,0x4
ffffffffc02001d2:	3ba60613          	addi	a2,a2,954 # ffffffffc0204588 <commands+0x110>
ffffffffc02001d6:	00004597          	auipc	a1,0x4
ffffffffc02001da:	3da58593          	addi	a1,a1,986 # ffffffffc02045b0 <commands+0x138>
ffffffffc02001de:	00004517          	auipc	a0,0x4
ffffffffc02001e2:	39a50513          	addi	a0,a0,922 # ffffffffc0204578 <commands+0x100>
ffffffffc02001e6:	ed9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc02001ea:	00004617          	auipc	a2,0x4
ffffffffc02001ee:	3d660613          	addi	a2,a2,982 # ffffffffc02045c0 <commands+0x148>
ffffffffc02001f2:	00004597          	auipc	a1,0x4
ffffffffc02001f6:	3ee58593          	addi	a1,a1,1006 # ffffffffc02045e0 <commands+0x168>
ffffffffc02001fa:	00004517          	auipc	a0,0x4
ffffffffc02001fe:	37e50513          	addi	a0,a0,894 # ffffffffc0204578 <commands+0x100>
ffffffffc0200202:	ebdff0ef          	jal	ra,ffffffffc02000be <cprintf>
    }
    return 0;
}
ffffffffc0200206:	60a2                	ld	ra,8(sp)
ffffffffc0200208:	4501                	li	a0,0
ffffffffc020020a:	0141                	addi	sp,sp,16
ffffffffc020020c:	8082                	ret

ffffffffc020020e <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020020e:	1141                	addi	sp,sp,-16
ffffffffc0200210:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200212:	ef3ff0ef          	jal	ra,ffffffffc0200104 <print_kerninfo>
    return 0;
}
ffffffffc0200216:	60a2                	ld	ra,8(sp)
ffffffffc0200218:	4501                	li	a0,0
ffffffffc020021a:	0141                	addi	sp,sp,16
ffffffffc020021c:	8082                	ret

ffffffffc020021e <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020021e:	1141                	addi	sp,sp,-16
ffffffffc0200220:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200222:	f71ff0ef          	jal	ra,ffffffffc0200192 <print_stackframe>
    return 0;
}
ffffffffc0200226:	60a2                	ld	ra,8(sp)
ffffffffc0200228:	4501                	li	a0,0
ffffffffc020022a:	0141                	addi	sp,sp,16
ffffffffc020022c:	8082                	ret

ffffffffc020022e <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020022e:	7115                	addi	sp,sp,-224
ffffffffc0200230:	e962                	sd	s8,144(sp)
ffffffffc0200232:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200234:	00004517          	auipc	a0,0x4
ffffffffc0200238:	28c50513          	addi	a0,a0,652 # ffffffffc02044c0 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc020023c:	ed86                	sd	ra,216(sp)
ffffffffc020023e:	e9a2                	sd	s0,208(sp)
ffffffffc0200240:	e5a6                	sd	s1,200(sp)
ffffffffc0200242:	e1ca                	sd	s2,192(sp)
ffffffffc0200244:	fd4e                	sd	s3,184(sp)
ffffffffc0200246:	f952                	sd	s4,176(sp)
ffffffffc0200248:	f556                	sd	s5,168(sp)
ffffffffc020024a:	f15a                	sd	s6,160(sp)
ffffffffc020024c:	ed5e                	sd	s7,152(sp)
ffffffffc020024e:	e566                	sd	s9,136(sp)
ffffffffc0200250:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200252:	e6dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200256:	00004517          	auipc	a0,0x4
ffffffffc020025a:	29250513          	addi	a0,a0,658 # ffffffffc02044e8 <commands+0x70>
ffffffffc020025e:	e61ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    if (tf != NULL) {
ffffffffc0200262:	000c0563          	beqz	s8,ffffffffc020026c <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200266:	8562                	mv	a0,s8
ffffffffc0200268:	4ec000ef          	jal	ra,ffffffffc0200754 <print_trapframe>
ffffffffc020026c:	00004c97          	auipc	s9,0x4
ffffffffc0200270:	20cc8c93          	addi	s9,s9,524 # ffffffffc0204478 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc0200274:	00005997          	auipc	s3,0x5
ffffffffc0200278:	79c98993          	addi	s3,s3,1948 # ffffffffc0205a10 <default_pmm_manager+0x990>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020027c:	00004917          	auipc	s2,0x4
ffffffffc0200280:	29490913          	addi	s2,s2,660 # ffffffffc0204510 <commands+0x98>
        if (argc == MAXARGS - 1) {
ffffffffc0200284:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200286:	00004b17          	auipc	s6,0x4
ffffffffc020028a:	292b0b13          	addi	s6,s6,658 # ffffffffc0204518 <commands+0xa0>
    if (argc == 0) {
ffffffffc020028e:	00004a97          	auipc	s5,0x4
ffffffffc0200292:	2e2a8a93          	addi	s5,s5,738 # ffffffffc0204570 <commands+0xf8>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200296:	4b8d                	li	s7,3
        if ((buf = readline("")) != NULL) {
ffffffffc0200298:	854e                	mv	a0,s3
ffffffffc020029a:	72f030ef          	jal	ra,ffffffffc02041c8 <readline>
ffffffffc020029e:	842a                	mv	s0,a0
ffffffffc02002a0:	dd65                	beqz	a0,ffffffffc0200298 <kmonitor+0x6a>
ffffffffc02002a2:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002a6:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002a8:	c999                	beqz	a1,ffffffffc02002be <kmonitor+0x90>
ffffffffc02002aa:	854a                	mv	a0,s2
ffffffffc02002ac:	05a040ef          	jal	ra,ffffffffc0204306 <strchr>
ffffffffc02002b0:	c925                	beqz	a0,ffffffffc0200320 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02002b2:	00144583          	lbu	a1,1(s0)
ffffffffc02002b6:	00040023          	sb	zero,0(s0)
ffffffffc02002ba:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002bc:	f5fd                	bnez	a1,ffffffffc02002aa <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02002be:	dce9                	beqz	s1,ffffffffc0200298 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002c0:	6582                	ld	a1,0(sp)
ffffffffc02002c2:	00004d17          	auipc	s10,0x4
ffffffffc02002c6:	1b6d0d13          	addi	s10,s10,438 # ffffffffc0204478 <commands>
    if (argc == 0) {
ffffffffc02002ca:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002cc:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002ce:	0d61                	addi	s10,s10,24
ffffffffc02002d0:	00c040ef          	jal	ra,ffffffffc02042dc <strcmp>
ffffffffc02002d4:	c919                	beqz	a0,ffffffffc02002ea <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002d6:	2405                	addiw	s0,s0,1
ffffffffc02002d8:	09740463          	beq	s0,s7,ffffffffc0200360 <kmonitor+0x132>
ffffffffc02002dc:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002e0:	6582                	ld	a1,0(sp)
ffffffffc02002e2:	0d61                	addi	s10,s10,24
ffffffffc02002e4:	7f9030ef          	jal	ra,ffffffffc02042dc <strcmp>
ffffffffc02002e8:	f57d                	bnez	a0,ffffffffc02002d6 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02002ea:	00141793          	slli	a5,s0,0x1
ffffffffc02002ee:	97a2                	add	a5,a5,s0
ffffffffc02002f0:	078e                	slli	a5,a5,0x3
ffffffffc02002f2:	97e6                	add	a5,a5,s9
ffffffffc02002f4:	6b9c                	ld	a5,16(a5)
ffffffffc02002f6:	8662                	mv	a2,s8
ffffffffc02002f8:	002c                	addi	a1,sp,8
ffffffffc02002fa:	fff4851b          	addiw	a0,s1,-1
ffffffffc02002fe:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200300:	f8055ce3          	bgez	a0,ffffffffc0200298 <kmonitor+0x6a>
}
ffffffffc0200304:	60ee                	ld	ra,216(sp)
ffffffffc0200306:	644e                	ld	s0,208(sp)
ffffffffc0200308:	64ae                	ld	s1,200(sp)
ffffffffc020030a:	690e                	ld	s2,192(sp)
ffffffffc020030c:	79ea                	ld	s3,184(sp)
ffffffffc020030e:	7a4a                	ld	s4,176(sp)
ffffffffc0200310:	7aaa                	ld	s5,168(sp)
ffffffffc0200312:	7b0a                	ld	s6,160(sp)
ffffffffc0200314:	6bea                	ld	s7,152(sp)
ffffffffc0200316:	6c4a                	ld	s8,144(sp)
ffffffffc0200318:	6caa                	ld	s9,136(sp)
ffffffffc020031a:	6d0a                	ld	s10,128(sp)
ffffffffc020031c:	612d                	addi	sp,sp,224
ffffffffc020031e:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200320:	00044783          	lbu	a5,0(s0)
ffffffffc0200324:	dfc9                	beqz	a5,ffffffffc02002be <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc0200326:	03448863          	beq	s1,s4,ffffffffc0200356 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc020032a:	00349793          	slli	a5,s1,0x3
ffffffffc020032e:	0118                	addi	a4,sp,128
ffffffffc0200330:	97ba                	add	a5,a5,a4
ffffffffc0200332:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200336:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020033a:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020033c:	e591                	bnez	a1,ffffffffc0200348 <kmonitor+0x11a>
ffffffffc020033e:	b749                	j	ffffffffc02002c0 <kmonitor+0x92>
            buf ++;
ffffffffc0200340:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200342:	00044583          	lbu	a1,0(s0)
ffffffffc0200346:	ddad                	beqz	a1,ffffffffc02002c0 <kmonitor+0x92>
ffffffffc0200348:	854a                	mv	a0,s2
ffffffffc020034a:	7bd030ef          	jal	ra,ffffffffc0204306 <strchr>
ffffffffc020034e:	d96d                	beqz	a0,ffffffffc0200340 <kmonitor+0x112>
ffffffffc0200350:	00044583          	lbu	a1,0(s0)
ffffffffc0200354:	bf91                	j	ffffffffc02002a8 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200356:	45c1                	li	a1,16
ffffffffc0200358:	855a                	mv	a0,s6
ffffffffc020035a:	d65ff0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc020035e:	b7f1                	j	ffffffffc020032a <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200360:	6582                	ld	a1,0(sp)
ffffffffc0200362:	00004517          	auipc	a0,0x4
ffffffffc0200366:	1d650513          	addi	a0,a0,470 # ffffffffc0204538 <commands+0xc0>
ffffffffc020036a:	d55ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    return 0;
ffffffffc020036e:	b72d                	j	ffffffffc0200298 <kmonitor+0x6a>

ffffffffc0200370 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200370:	00011317          	auipc	t1,0x11
ffffffffc0200374:	0d030313          	addi	t1,t1,208 # ffffffffc0211440 <is_panic>
ffffffffc0200378:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020037c:	715d                	addi	sp,sp,-80
ffffffffc020037e:	ec06                	sd	ra,24(sp)
ffffffffc0200380:	e822                	sd	s0,16(sp)
ffffffffc0200382:	f436                	sd	a3,40(sp)
ffffffffc0200384:	f83a                	sd	a4,48(sp)
ffffffffc0200386:	fc3e                	sd	a5,56(sp)
ffffffffc0200388:	e0c2                	sd	a6,64(sp)
ffffffffc020038a:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020038c:	02031c63          	bnez	t1,ffffffffc02003c4 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200390:	4785                	li	a5,1
ffffffffc0200392:	8432                	mv	s0,a2
ffffffffc0200394:	00011717          	auipc	a4,0x11
ffffffffc0200398:	0af72623          	sw	a5,172(a4) # ffffffffc0211440 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020039c:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc020039e:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003a0:	85aa                	mv	a1,a0
ffffffffc02003a2:	00004517          	auipc	a0,0x4
ffffffffc02003a6:	24e50513          	addi	a0,a0,590 # ffffffffc02045f0 <commands+0x178>
    va_start(ap, fmt);
ffffffffc02003aa:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003ac:	d13ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003b0:	65a2                	ld	a1,8(sp)
ffffffffc02003b2:	8522                	mv	a0,s0
ffffffffc02003b4:	cebff0ef          	jal	ra,ffffffffc020009e <vcprintf>
    cprintf("\n");
ffffffffc02003b8:	00005517          	auipc	a0,0x5
ffffffffc02003bc:	1b050513          	addi	a0,a0,432 # ffffffffc0205568 <default_pmm_manager+0x4e8>
ffffffffc02003c0:	cffff0ef          	jal	ra,ffffffffc02000be <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003c4:	12e000ef          	jal	ra,ffffffffc02004f2 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02003c8:	4501                	li	a0,0
ffffffffc02003ca:	e65ff0ef          	jal	ra,ffffffffc020022e <kmonitor>
ffffffffc02003ce:	bfed                	j	ffffffffc02003c8 <__panic+0x58>

ffffffffc02003d0 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02003d0:	67e1                	lui	a5,0x18
ffffffffc02003d2:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc02003d6:	00011717          	auipc	a4,0x11
ffffffffc02003da:	06f73923          	sd	a5,114(a4) # ffffffffc0211448 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc02003de:	c0102573          	rdtime	a0
static inline void sbi_set_timer(uint64_t stime_value)
{
#if __riscv_xlen == 32
	SBI_CALL_2(SBI_SET_TIMER, stime_value, stime_value >> 32);
#else
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc02003e2:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc02003e4:	953e                	add	a0,a0,a5
ffffffffc02003e6:	4601                	li	a2,0
ffffffffc02003e8:	4881                	li	a7,0
ffffffffc02003ea:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc02003ee:	02000793          	li	a5,32
ffffffffc02003f2:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc02003f6:	00004517          	auipc	a0,0x4
ffffffffc02003fa:	21a50513          	addi	a0,a0,538 # ffffffffc0204610 <commands+0x198>
    ticks = 0;
ffffffffc02003fe:	00011797          	auipc	a5,0x11
ffffffffc0200402:	0607b923          	sd	zero,114(a5) # ffffffffc0211470 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200406:	b965                	j	ffffffffc02000be <cprintf>

ffffffffc0200408 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200408:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020040c:	00011797          	auipc	a5,0x11
ffffffffc0200410:	03c78793          	addi	a5,a5,60 # ffffffffc0211448 <timebase>
ffffffffc0200414:	639c                	ld	a5,0(a5)
ffffffffc0200416:	4581                	li	a1,0
ffffffffc0200418:	4601                	li	a2,0
ffffffffc020041a:	953e                	add	a0,a0,a5
ffffffffc020041c:	4881                	li	a7,0
ffffffffc020041e:	00000073          	ecall
ffffffffc0200422:	8082                	ret

ffffffffc0200424 <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200424:	100027f3          	csrr	a5,sstatus
ffffffffc0200428:	8b89                	andi	a5,a5,2
ffffffffc020042a:	0ff57513          	andi	a0,a0,255
ffffffffc020042e:	e799                	bnez	a5,ffffffffc020043c <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200430:	4581                	li	a1,0
ffffffffc0200432:	4601                	li	a2,0
ffffffffc0200434:	4885                	li	a7,1
ffffffffc0200436:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020043a:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020043c:	1101                	addi	sp,sp,-32
ffffffffc020043e:	ec06                	sd	ra,24(sp)
ffffffffc0200440:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200442:	0b0000ef          	jal	ra,ffffffffc02004f2 <intr_disable>
ffffffffc0200446:	6522                	ld	a0,8(sp)
ffffffffc0200448:	4581                	li	a1,0
ffffffffc020044a:	4601                	li	a2,0
ffffffffc020044c:	4885                	li	a7,1
ffffffffc020044e:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200452:	60e2                	ld	ra,24(sp)
ffffffffc0200454:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200456:	a859                	j	ffffffffc02004ec <intr_enable>

ffffffffc0200458 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200458:	100027f3          	csrr	a5,sstatus
ffffffffc020045c:	8b89                	andi	a5,a5,2
ffffffffc020045e:	eb89                	bnez	a5,ffffffffc0200470 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200460:	4501                	li	a0,0
ffffffffc0200462:	4581                	li	a1,0
ffffffffc0200464:	4601                	li	a2,0
ffffffffc0200466:	4889                	li	a7,2
ffffffffc0200468:	00000073          	ecall
ffffffffc020046c:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020046e:	8082                	ret
int cons_getc(void) {
ffffffffc0200470:	1101                	addi	sp,sp,-32
ffffffffc0200472:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200474:	07e000ef          	jal	ra,ffffffffc02004f2 <intr_disable>
ffffffffc0200478:	4501                	li	a0,0
ffffffffc020047a:	4581                	li	a1,0
ffffffffc020047c:	4601                	li	a2,0
ffffffffc020047e:	4889                	li	a7,2
ffffffffc0200480:	00000073          	ecall
ffffffffc0200484:	2501                	sext.w	a0,a0
ffffffffc0200486:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200488:	064000ef          	jal	ra,ffffffffc02004ec <intr_enable>
}
ffffffffc020048c:	60e2                	ld	ra,24(sp)
ffffffffc020048e:	6522                	ld	a0,8(sp)
ffffffffc0200490:	6105                	addi	sp,sp,32
ffffffffc0200492:	8082                	ret

ffffffffc0200494 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc0200494:	8082                	ret

ffffffffc0200496 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200496:	00253513          	sltiu	a0,a0,2
ffffffffc020049a:	8082                	ret

ffffffffc020049c <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020049c:	03800513          	li	a0,56
ffffffffc02004a0:	8082                	ret

ffffffffc02004a2 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004a2:	0000a797          	auipc	a5,0xa
ffffffffc02004a6:	b9e78793          	addi	a5,a5,-1122 # ffffffffc020a040 <edata>
ffffffffc02004aa:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02004ae:	1141                	addi	sp,sp,-16
ffffffffc02004b0:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004b2:	95be                	add	a1,a1,a5
ffffffffc02004b4:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02004b8:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004ba:	67d030ef          	jal	ra,ffffffffc0204336 <memcpy>
    return 0;
}
ffffffffc02004be:	60a2                	ld	ra,8(sp)
ffffffffc02004c0:	4501                	li	a0,0
ffffffffc02004c2:	0141                	addi	sp,sp,16
ffffffffc02004c4:	8082                	ret

ffffffffc02004c6 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc02004c6:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004c8:	0095979b          	slliw	a5,a1,0x9
ffffffffc02004cc:	0000a517          	auipc	a0,0xa
ffffffffc02004d0:	b7450513          	addi	a0,a0,-1164 # ffffffffc020a040 <edata>
                   size_t nsecs) {
ffffffffc02004d4:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004d6:	00969613          	slli	a2,a3,0x9
ffffffffc02004da:	85ba                	mv	a1,a4
ffffffffc02004dc:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc02004de:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004e0:	657030ef          	jal	ra,ffffffffc0204336 <memcpy>
    return 0;
}
ffffffffc02004e4:	60a2                	ld	ra,8(sp)
ffffffffc02004e6:	4501                	li	a0,0
ffffffffc02004e8:	0141                	addi	sp,sp,16
ffffffffc02004ea:	8082                	ret

ffffffffc02004ec <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004ec:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004f0:	8082                	ret

ffffffffc02004f2 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004f2:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004f6:	8082                	ret

ffffffffc02004f8 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004f8:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004fc:	1141                	addi	sp,sp,-16
ffffffffc02004fe:	e022                	sd	s0,0(sp)
ffffffffc0200500:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200502:	1007f793          	andi	a5,a5,256
static int pgfault_handler(struct trapframe *tf) {
ffffffffc0200506:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200508:	11053583          	ld	a1,272(a0)
ffffffffc020050c:	05500613          	li	a2,85
ffffffffc0200510:	c399                	beqz	a5,ffffffffc0200516 <pgfault_handler+0x1e>
ffffffffc0200512:	04b00613          	li	a2,75
ffffffffc0200516:	11843703          	ld	a4,280(s0)
ffffffffc020051a:	47bd                	li	a5,15
ffffffffc020051c:	05700693          	li	a3,87
ffffffffc0200520:	00f70463          	beq	a4,a5,ffffffffc0200528 <pgfault_handler+0x30>
ffffffffc0200524:	05200693          	li	a3,82
ffffffffc0200528:	00004517          	auipc	a0,0x4
ffffffffc020052c:	3e050513          	addi	a0,a0,992 # ffffffffc0204908 <commands+0x490>
ffffffffc0200530:	b8fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200534:	00011797          	auipc	a5,0x11
ffffffffc0200538:	05478793          	addi	a5,a5,84 # ffffffffc0211588 <check_mm_struct>
ffffffffc020053c:	6388                	ld	a0,0(a5)
ffffffffc020053e:	c911                	beqz	a0,ffffffffc0200552 <pgfault_handler+0x5a>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200540:	11043603          	ld	a2,272(s0)
ffffffffc0200544:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200548:	6402                	ld	s0,0(sp)
ffffffffc020054a:	60a2                	ld	ra,8(sp)
ffffffffc020054c:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020054e:	6060306f          	j	ffffffffc0203b54 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc0200552:	00004617          	auipc	a2,0x4
ffffffffc0200556:	3d660613          	addi	a2,a2,982 # ffffffffc0204928 <commands+0x4b0>
ffffffffc020055a:	07800593          	li	a1,120
ffffffffc020055e:	00004517          	auipc	a0,0x4
ffffffffc0200562:	3e250513          	addi	a0,a0,994 # ffffffffc0204940 <commands+0x4c8>
ffffffffc0200566:	e0bff0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc020056a <idt_init>:
    write_csr(sscratch, 0);
ffffffffc020056a:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc020056e:	00000797          	auipc	a5,0x0
ffffffffc0200572:	48278793          	addi	a5,a5,1154 # ffffffffc02009f0 <__alltraps>
ffffffffc0200576:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc020057a:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020057e:	000407b7          	lui	a5,0x40
ffffffffc0200582:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200586:	8082                	ret

ffffffffc0200588 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200588:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc020058a:	1141                	addi	sp,sp,-16
ffffffffc020058c:	e022                	sd	s0,0(sp)
ffffffffc020058e:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200590:	00004517          	auipc	a0,0x4
ffffffffc0200594:	3c850513          	addi	a0,a0,968 # ffffffffc0204958 <commands+0x4e0>
void print_regs(struct pushregs *gpr) {
ffffffffc0200598:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020059a:	b25ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020059e:	640c                	ld	a1,8(s0)
ffffffffc02005a0:	00004517          	auipc	a0,0x4
ffffffffc02005a4:	3d050513          	addi	a0,a0,976 # ffffffffc0204970 <commands+0x4f8>
ffffffffc02005a8:	b17ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005ac:	680c                	ld	a1,16(s0)
ffffffffc02005ae:	00004517          	auipc	a0,0x4
ffffffffc02005b2:	3da50513          	addi	a0,a0,986 # ffffffffc0204988 <commands+0x510>
ffffffffc02005b6:	b09ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005ba:	6c0c                	ld	a1,24(s0)
ffffffffc02005bc:	00004517          	auipc	a0,0x4
ffffffffc02005c0:	3e450513          	addi	a0,a0,996 # ffffffffc02049a0 <commands+0x528>
ffffffffc02005c4:	afbff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005c8:	700c                	ld	a1,32(s0)
ffffffffc02005ca:	00004517          	auipc	a0,0x4
ffffffffc02005ce:	3ee50513          	addi	a0,a0,1006 # ffffffffc02049b8 <commands+0x540>
ffffffffc02005d2:	aedff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005d6:	740c                	ld	a1,40(s0)
ffffffffc02005d8:	00004517          	auipc	a0,0x4
ffffffffc02005dc:	3f850513          	addi	a0,a0,1016 # ffffffffc02049d0 <commands+0x558>
ffffffffc02005e0:	adfff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005e4:	780c                	ld	a1,48(s0)
ffffffffc02005e6:	00004517          	auipc	a0,0x4
ffffffffc02005ea:	40250513          	addi	a0,a0,1026 # ffffffffc02049e8 <commands+0x570>
ffffffffc02005ee:	ad1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005f2:	7c0c                	ld	a1,56(s0)
ffffffffc02005f4:	00004517          	auipc	a0,0x4
ffffffffc02005f8:	40c50513          	addi	a0,a0,1036 # ffffffffc0204a00 <commands+0x588>
ffffffffc02005fc:	ac3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200600:	602c                	ld	a1,64(s0)
ffffffffc0200602:	00004517          	auipc	a0,0x4
ffffffffc0200606:	41650513          	addi	a0,a0,1046 # ffffffffc0204a18 <commands+0x5a0>
ffffffffc020060a:	ab5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc020060e:	642c                	ld	a1,72(s0)
ffffffffc0200610:	00004517          	auipc	a0,0x4
ffffffffc0200614:	42050513          	addi	a0,a0,1056 # ffffffffc0204a30 <commands+0x5b8>
ffffffffc0200618:	aa7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020061c:	682c                	ld	a1,80(s0)
ffffffffc020061e:	00004517          	auipc	a0,0x4
ffffffffc0200622:	42a50513          	addi	a0,a0,1066 # ffffffffc0204a48 <commands+0x5d0>
ffffffffc0200626:	a99ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc020062a:	6c2c                	ld	a1,88(s0)
ffffffffc020062c:	00004517          	auipc	a0,0x4
ffffffffc0200630:	43450513          	addi	a0,a0,1076 # ffffffffc0204a60 <commands+0x5e8>
ffffffffc0200634:	a8bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200638:	702c                	ld	a1,96(s0)
ffffffffc020063a:	00004517          	auipc	a0,0x4
ffffffffc020063e:	43e50513          	addi	a0,a0,1086 # ffffffffc0204a78 <commands+0x600>
ffffffffc0200642:	a7dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200646:	742c                	ld	a1,104(s0)
ffffffffc0200648:	00004517          	auipc	a0,0x4
ffffffffc020064c:	44850513          	addi	a0,a0,1096 # ffffffffc0204a90 <commands+0x618>
ffffffffc0200650:	a6fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200654:	782c                	ld	a1,112(s0)
ffffffffc0200656:	00004517          	auipc	a0,0x4
ffffffffc020065a:	45250513          	addi	a0,a0,1106 # ffffffffc0204aa8 <commands+0x630>
ffffffffc020065e:	a61ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200662:	7c2c                	ld	a1,120(s0)
ffffffffc0200664:	00004517          	auipc	a0,0x4
ffffffffc0200668:	45c50513          	addi	a0,a0,1116 # ffffffffc0204ac0 <commands+0x648>
ffffffffc020066c:	a53ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200670:	604c                	ld	a1,128(s0)
ffffffffc0200672:	00004517          	auipc	a0,0x4
ffffffffc0200676:	46650513          	addi	a0,a0,1126 # ffffffffc0204ad8 <commands+0x660>
ffffffffc020067a:	a45ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020067e:	644c                	ld	a1,136(s0)
ffffffffc0200680:	00004517          	auipc	a0,0x4
ffffffffc0200684:	47050513          	addi	a0,a0,1136 # ffffffffc0204af0 <commands+0x678>
ffffffffc0200688:	a37ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020068c:	684c                	ld	a1,144(s0)
ffffffffc020068e:	00004517          	auipc	a0,0x4
ffffffffc0200692:	47a50513          	addi	a0,a0,1146 # ffffffffc0204b08 <commands+0x690>
ffffffffc0200696:	a29ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc020069a:	6c4c                	ld	a1,152(s0)
ffffffffc020069c:	00004517          	auipc	a0,0x4
ffffffffc02006a0:	48450513          	addi	a0,a0,1156 # ffffffffc0204b20 <commands+0x6a8>
ffffffffc02006a4:	a1bff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006a8:	704c                	ld	a1,160(s0)
ffffffffc02006aa:	00004517          	auipc	a0,0x4
ffffffffc02006ae:	48e50513          	addi	a0,a0,1166 # ffffffffc0204b38 <commands+0x6c0>
ffffffffc02006b2:	a0dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006b6:	744c                	ld	a1,168(s0)
ffffffffc02006b8:	00004517          	auipc	a0,0x4
ffffffffc02006bc:	49850513          	addi	a0,a0,1176 # ffffffffc0204b50 <commands+0x6d8>
ffffffffc02006c0:	9ffff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006c4:	784c                	ld	a1,176(s0)
ffffffffc02006c6:	00004517          	auipc	a0,0x4
ffffffffc02006ca:	4a250513          	addi	a0,a0,1186 # ffffffffc0204b68 <commands+0x6f0>
ffffffffc02006ce:	9f1ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006d2:	7c4c                	ld	a1,184(s0)
ffffffffc02006d4:	00004517          	auipc	a0,0x4
ffffffffc02006d8:	4ac50513          	addi	a0,a0,1196 # ffffffffc0204b80 <commands+0x708>
ffffffffc02006dc:	9e3ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006e0:	606c                	ld	a1,192(s0)
ffffffffc02006e2:	00004517          	auipc	a0,0x4
ffffffffc02006e6:	4b650513          	addi	a0,a0,1206 # ffffffffc0204b98 <commands+0x720>
ffffffffc02006ea:	9d5ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006ee:	646c                	ld	a1,200(s0)
ffffffffc02006f0:	00004517          	auipc	a0,0x4
ffffffffc02006f4:	4c050513          	addi	a0,a0,1216 # ffffffffc0204bb0 <commands+0x738>
ffffffffc02006f8:	9c7ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006fc:	686c                	ld	a1,208(s0)
ffffffffc02006fe:	00004517          	auipc	a0,0x4
ffffffffc0200702:	4ca50513          	addi	a0,a0,1226 # ffffffffc0204bc8 <commands+0x750>
ffffffffc0200706:	9b9ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc020070a:	6c6c                	ld	a1,216(s0)
ffffffffc020070c:	00004517          	auipc	a0,0x4
ffffffffc0200710:	4d450513          	addi	a0,a0,1236 # ffffffffc0204be0 <commands+0x768>
ffffffffc0200714:	9abff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200718:	706c                	ld	a1,224(s0)
ffffffffc020071a:	00004517          	auipc	a0,0x4
ffffffffc020071e:	4de50513          	addi	a0,a0,1246 # ffffffffc0204bf8 <commands+0x780>
ffffffffc0200722:	99dff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200726:	746c                	ld	a1,232(s0)
ffffffffc0200728:	00004517          	auipc	a0,0x4
ffffffffc020072c:	4e850513          	addi	a0,a0,1256 # ffffffffc0204c10 <commands+0x798>
ffffffffc0200730:	98fff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200734:	786c                	ld	a1,240(s0)
ffffffffc0200736:	00004517          	auipc	a0,0x4
ffffffffc020073a:	4f250513          	addi	a0,a0,1266 # ffffffffc0204c28 <commands+0x7b0>
ffffffffc020073e:	981ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200742:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200744:	6402                	ld	s0,0(sp)
ffffffffc0200746:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200748:	00004517          	auipc	a0,0x4
ffffffffc020074c:	4f850513          	addi	a0,a0,1272 # ffffffffc0204c40 <commands+0x7c8>
}
ffffffffc0200750:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200752:	b2b5                	j	ffffffffc02000be <cprintf>

ffffffffc0200754 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200754:	1141                	addi	sp,sp,-16
ffffffffc0200756:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200758:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc020075a:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020075c:	00004517          	auipc	a0,0x4
ffffffffc0200760:	4fc50513          	addi	a0,a0,1276 # ffffffffc0204c58 <commands+0x7e0>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200764:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200766:	959ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    print_regs(&tf->gpr);
ffffffffc020076a:	8522                	mv	a0,s0
ffffffffc020076c:	e1dff0ef          	jal	ra,ffffffffc0200588 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200770:	10043583          	ld	a1,256(s0)
ffffffffc0200774:	00004517          	auipc	a0,0x4
ffffffffc0200778:	4fc50513          	addi	a0,a0,1276 # ffffffffc0204c70 <commands+0x7f8>
ffffffffc020077c:	943ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200780:	10843583          	ld	a1,264(s0)
ffffffffc0200784:	00004517          	auipc	a0,0x4
ffffffffc0200788:	50450513          	addi	a0,a0,1284 # ffffffffc0204c88 <commands+0x810>
ffffffffc020078c:	933ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc0200790:	11043583          	ld	a1,272(s0)
ffffffffc0200794:	00004517          	auipc	a0,0x4
ffffffffc0200798:	50c50513          	addi	a0,a0,1292 # ffffffffc0204ca0 <commands+0x828>
ffffffffc020079c:	923ff0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007a0:	11843583          	ld	a1,280(s0)
}
ffffffffc02007a4:	6402                	ld	s0,0(sp)
ffffffffc02007a6:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007a8:	00004517          	auipc	a0,0x4
ffffffffc02007ac:	51050513          	addi	a0,a0,1296 # ffffffffc0204cb8 <commands+0x840>
}
ffffffffc02007b0:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007b2:	90dff06f          	j	ffffffffc02000be <cprintf>

ffffffffc02007b6 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007b6:	11853783          	ld	a5,280(a0)
    switch (cause) {
ffffffffc02007ba:	472d                	li	a4,11
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007bc:	0786                	slli	a5,a5,0x1
ffffffffc02007be:	8385                	srli	a5,a5,0x1
    switch (cause) {
ffffffffc02007c0:	06f76f63          	bltu	a4,a5,ffffffffc020083e <interrupt_handler+0x88>
ffffffffc02007c4:	00004717          	auipc	a4,0x4
ffffffffc02007c8:	e6870713          	addi	a4,a4,-408 # ffffffffc020462c <commands+0x1b4>
ffffffffc02007cc:	078a                	slli	a5,a5,0x2
ffffffffc02007ce:	97ba                	add	a5,a5,a4
ffffffffc02007d0:	439c                	lw	a5,0(a5)
ffffffffc02007d2:	97ba                	add	a5,a5,a4
ffffffffc02007d4:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007d6:	00004517          	auipc	a0,0x4
ffffffffc02007da:	0e250513          	addi	a0,a0,226 # ffffffffc02048b8 <commands+0x440>
ffffffffc02007de:	8e1ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007e2:	00004517          	auipc	a0,0x4
ffffffffc02007e6:	0b650513          	addi	a0,a0,182 # ffffffffc0204898 <commands+0x420>
ffffffffc02007ea:	8d5ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007ee:	00004517          	auipc	a0,0x4
ffffffffc02007f2:	06a50513          	addi	a0,a0,106 # ffffffffc0204858 <commands+0x3e0>
ffffffffc02007f6:	8c9ff06f          	j	ffffffffc02000be <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007fa:	00004517          	auipc	a0,0x4
ffffffffc02007fe:	07e50513          	addi	a0,a0,126 # ffffffffc0204878 <commands+0x400>
ffffffffc0200802:	8bdff06f          	j	ffffffffc02000be <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200806:	00004517          	auipc	a0,0x4
ffffffffc020080a:	0e250513          	addi	a0,a0,226 # ffffffffc02048e8 <commands+0x470>
ffffffffc020080e:	8b1ff06f          	j	ffffffffc02000be <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200812:	1141                	addi	sp,sp,-16
ffffffffc0200814:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200816:	bf3ff0ef          	jal	ra,ffffffffc0200408 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc020081a:	00011797          	auipc	a5,0x11
ffffffffc020081e:	c5678793          	addi	a5,a5,-938 # ffffffffc0211470 <ticks>
ffffffffc0200822:	639c                	ld	a5,0(a5)
ffffffffc0200824:	06400713          	li	a4,100
ffffffffc0200828:	0785                	addi	a5,a5,1
ffffffffc020082a:	02e7f733          	remu	a4,a5,a4
ffffffffc020082e:	00011697          	auipc	a3,0x11
ffffffffc0200832:	c4f6b123          	sd	a5,-958(a3) # ffffffffc0211470 <ticks>
ffffffffc0200836:	c709                	beqz	a4,ffffffffc0200840 <interrupt_handler+0x8a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200838:	60a2                	ld	ra,8(sp)
ffffffffc020083a:	0141                	addi	sp,sp,16
ffffffffc020083c:	8082                	ret
            print_trapframe(tf);
ffffffffc020083e:	bf19                	j	ffffffffc0200754 <print_trapframe>
}
ffffffffc0200840:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200842:	06400593          	li	a1,100
ffffffffc0200846:	00004517          	auipc	a0,0x4
ffffffffc020084a:	09250513          	addi	a0,a0,146 # ffffffffc02048d8 <commands+0x460>
}
ffffffffc020084e:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200850:	86fff06f          	j	ffffffffc02000be <cprintf>

ffffffffc0200854 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200854:	11853783          	ld	a5,280(a0)
ffffffffc0200858:	473d                	li	a4,15
ffffffffc020085a:	16f76463          	bltu	a4,a5,ffffffffc02009c2 <exception_handler+0x16e>
ffffffffc020085e:	00004717          	auipc	a4,0x4
ffffffffc0200862:	dfe70713          	addi	a4,a4,-514 # ffffffffc020465c <commands+0x1e4>
ffffffffc0200866:	078a                	slli	a5,a5,0x2
ffffffffc0200868:	97ba                	add	a5,a5,a4
ffffffffc020086a:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc020086c:	1101                	addi	sp,sp,-32
ffffffffc020086e:	e822                	sd	s0,16(sp)
ffffffffc0200870:	ec06                	sd	ra,24(sp)
ffffffffc0200872:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200874:	97ba                	add	a5,a5,a4
ffffffffc0200876:	842a                	mv	s0,a0
ffffffffc0200878:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc020087a:	00004517          	auipc	a0,0x4
ffffffffc020087e:	fc650513          	addi	a0,a0,-58 # ffffffffc0204840 <commands+0x3c8>
ffffffffc0200882:	83dff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200886:	8522                	mv	a0,s0
ffffffffc0200888:	c71ff0ef          	jal	ra,ffffffffc02004f8 <pgfault_handler>
ffffffffc020088c:	84aa                	mv	s1,a0
ffffffffc020088e:	12051b63          	bnez	a0,ffffffffc02009c4 <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200892:	60e2                	ld	ra,24(sp)
ffffffffc0200894:	6442                	ld	s0,16(sp)
ffffffffc0200896:	64a2                	ld	s1,8(sp)
ffffffffc0200898:	6105                	addi	sp,sp,32
ffffffffc020089a:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc020089c:	00004517          	auipc	a0,0x4
ffffffffc02008a0:	e0450513          	addi	a0,a0,-508 # ffffffffc02046a0 <commands+0x228>
}
ffffffffc02008a4:	6442                	ld	s0,16(sp)
ffffffffc02008a6:	60e2                	ld	ra,24(sp)
ffffffffc02008a8:	64a2                	ld	s1,8(sp)
ffffffffc02008aa:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008ac:	813ff06f          	j	ffffffffc02000be <cprintf>
ffffffffc02008b0:	00004517          	auipc	a0,0x4
ffffffffc02008b4:	e1050513          	addi	a0,a0,-496 # ffffffffc02046c0 <commands+0x248>
ffffffffc02008b8:	b7f5                	j	ffffffffc02008a4 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008ba:	00004517          	auipc	a0,0x4
ffffffffc02008be:	e2650513          	addi	a0,a0,-474 # ffffffffc02046e0 <commands+0x268>
ffffffffc02008c2:	b7cd                	j	ffffffffc02008a4 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008c4:	00004517          	auipc	a0,0x4
ffffffffc02008c8:	e3450513          	addi	a0,a0,-460 # ffffffffc02046f8 <commands+0x280>
ffffffffc02008cc:	bfe1                	j	ffffffffc02008a4 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008ce:	00004517          	auipc	a0,0x4
ffffffffc02008d2:	e3a50513          	addi	a0,a0,-454 # ffffffffc0204708 <commands+0x290>
ffffffffc02008d6:	b7f9                	j	ffffffffc02008a4 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008d8:	00004517          	auipc	a0,0x4
ffffffffc02008dc:	e5050513          	addi	a0,a0,-432 # ffffffffc0204728 <commands+0x2b0>
ffffffffc02008e0:	fdeff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008e4:	8522                	mv	a0,s0
ffffffffc02008e6:	c13ff0ef          	jal	ra,ffffffffc02004f8 <pgfault_handler>
ffffffffc02008ea:	84aa                	mv	s1,a0
ffffffffc02008ec:	d15d                	beqz	a0,ffffffffc0200892 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02008ee:	8522                	mv	a0,s0
ffffffffc02008f0:	e65ff0ef          	jal	ra,ffffffffc0200754 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02008f4:	86a6                	mv	a3,s1
ffffffffc02008f6:	00004617          	auipc	a2,0x4
ffffffffc02008fa:	e4a60613          	addi	a2,a2,-438 # ffffffffc0204740 <commands+0x2c8>
ffffffffc02008fe:	0ca00593          	li	a1,202
ffffffffc0200902:	00004517          	auipc	a0,0x4
ffffffffc0200906:	03e50513          	addi	a0,a0,62 # ffffffffc0204940 <commands+0x4c8>
ffffffffc020090a:	a67ff0ef          	jal	ra,ffffffffc0200370 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc020090e:	00004517          	auipc	a0,0x4
ffffffffc0200912:	e5250513          	addi	a0,a0,-430 # ffffffffc0204760 <commands+0x2e8>
ffffffffc0200916:	b779                	j	ffffffffc02008a4 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc0200918:	00004517          	auipc	a0,0x4
ffffffffc020091c:	e6050513          	addi	a0,a0,-416 # ffffffffc0204778 <commands+0x300>
ffffffffc0200920:	f9eff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200924:	8522                	mv	a0,s0
ffffffffc0200926:	bd3ff0ef          	jal	ra,ffffffffc02004f8 <pgfault_handler>
ffffffffc020092a:	84aa                	mv	s1,a0
ffffffffc020092c:	d13d                	beqz	a0,ffffffffc0200892 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020092e:	8522                	mv	a0,s0
ffffffffc0200930:	e25ff0ef          	jal	ra,ffffffffc0200754 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200934:	86a6                	mv	a3,s1
ffffffffc0200936:	00004617          	auipc	a2,0x4
ffffffffc020093a:	e0a60613          	addi	a2,a2,-502 # ffffffffc0204740 <commands+0x2c8>
ffffffffc020093e:	0d400593          	li	a1,212
ffffffffc0200942:	00004517          	auipc	a0,0x4
ffffffffc0200946:	ffe50513          	addi	a0,a0,-2 # ffffffffc0204940 <commands+0x4c8>
ffffffffc020094a:	a27ff0ef          	jal	ra,ffffffffc0200370 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc020094e:	00004517          	auipc	a0,0x4
ffffffffc0200952:	e4250513          	addi	a0,a0,-446 # ffffffffc0204790 <commands+0x318>
ffffffffc0200956:	b7b9                	j	ffffffffc02008a4 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc0200958:	00004517          	auipc	a0,0x4
ffffffffc020095c:	e5850513          	addi	a0,a0,-424 # ffffffffc02047b0 <commands+0x338>
ffffffffc0200960:	b791                	j	ffffffffc02008a4 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200962:	00004517          	auipc	a0,0x4
ffffffffc0200966:	e6e50513          	addi	a0,a0,-402 # ffffffffc02047d0 <commands+0x358>
ffffffffc020096a:	bf2d                	j	ffffffffc02008a4 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc020096c:	00004517          	auipc	a0,0x4
ffffffffc0200970:	e8450513          	addi	a0,a0,-380 # ffffffffc02047f0 <commands+0x378>
ffffffffc0200974:	bf05                	j	ffffffffc02008a4 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200976:	00004517          	auipc	a0,0x4
ffffffffc020097a:	e9a50513          	addi	a0,a0,-358 # ffffffffc0204810 <commands+0x398>
ffffffffc020097e:	b71d                	j	ffffffffc02008a4 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200980:	00004517          	auipc	a0,0x4
ffffffffc0200984:	ea850513          	addi	a0,a0,-344 # ffffffffc0204828 <commands+0x3b0>
ffffffffc0200988:	f36ff0ef          	jal	ra,ffffffffc02000be <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020098c:	8522                	mv	a0,s0
ffffffffc020098e:	b6bff0ef          	jal	ra,ffffffffc02004f8 <pgfault_handler>
ffffffffc0200992:	84aa                	mv	s1,a0
ffffffffc0200994:	ee050fe3          	beqz	a0,ffffffffc0200892 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200998:	8522                	mv	a0,s0
ffffffffc020099a:	dbbff0ef          	jal	ra,ffffffffc0200754 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc020099e:	86a6                	mv	a3,s1
ffffffffc02009a0:	00004617          	auipc	a2,0x4
ffffffffc02009a4:	da060613          	addi	a2,a2,-608 # ffffffffc0204740 <commands+0x2c8>
ffffffffc02009a8:	0ea00593          	li	a1,234
ffffffffc02009ac:	00004517          	auipc	a0,0x4
ffffffffc02009b0:	f9450513          	addi	a0,a0,-108 # ffffffffc0204940 <commands+0x4c8>
ffffffffc02009b4:	9bdff0ef          	jal	ra,ffffffffc0200370 <__panic>
}
ffffffffc02009b8:	6442                	ld	s0,16(sp)
ffffffffc02009ba:	60e2                	ld	ra,24(sp)
ffffffffc02009bc:	64a2                	ld	s1,8(sp)
ffffffffc02009be:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc02009c0:	bb51                	j	ffffffffc0200754 <print_trapframe>
ffffffffc02009c2:	bb49                	j	ffffffffc0200754 <print_trapframe>
                print_trapframe(tf);
ffffffffc02009c4:	8522                	mv	a0,s0
ffffffffc02009c6:	d8fff0ef          	jal	ra,ffffffffc0200754 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009ca:	86a6                	mv	a3,s1
ffffffffc02009cc:	00004617          	auipc	a2,0x4
ffffffffc02009d0:	d7460613          	addi	a2,a2,-652 # ffffffffc0204740 <commands+0x2c8>
ffffffffc02009d4:	0f100593          	li	a1,241
ffffffffc02009d8:	00004517          	auipc	a0,0x4
ffffffffc02009dc:	f6850513          	addi	a0,a0,-152 # ffffffffc0204940 <commands+0x4c8>
ffffffffc02009e0:	991ff0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc02009e4 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc02009e4:	11853783          	ld	a5,280(a0)
ffffffffc02009e8:	0007c363          	bltz	a5,ffffffffc02009ee <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02009ec:	b5a5                	j	ffffffffc0200854 <exception_handler>
        interrupt_handler(tf);
ffffffffc02009ee:	b3e1                	j	ffffffffc02007b6 <interrupt_handler>

ffffffffc02009f0 <__alltraps>:
    .endm

    .align 4
    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc02009f0:	14011073          	csrw	sscratch,sp
ffffffffc02009f4:	712d                	addi	sp,sp,-288
ffffffffc02009f6:	e406                	sd	ra,8(sp)
ffffffffc02009f8:	ec0e                	sd	gp,24(sp)
ffffffffc02009fa:	f012                	sd	tp,32(sp)
ffffffffc02009fc:	f416                	sd	t0,40(sp)
ffffffffc02009fe:	f81a                	sd	t1,48(sp)
ffffffffc0200a00:	fc1e                	sd	t2,56(sp)
ffffffffc0200a02:	e0a2                	sd	s0,64(sp)
ffffffffc0200a04:	e4a6                	sd	s1,72(sp)
ffffffffc0200a06:	e8aa                	sd	a0,80(sp)
ffffffffc0200a08:	ecae                	sd	a1,88(sp)
ffffffffc0200a0a:	f0b2                	sd	a2,96(sp)
ffffffffc0200a0c:	f4b6                	sd	a3,104(sp)
ffffffffc0200a0e:	f8ba                	sd	a4,112(sp)
ffffffffc0200a10:	fcbe                	sd	a5,120(sp)
ffffffffc0200a12:	e142                	sd	a6,128(sp)
ffffffffc0200a14:	e546                	sd	a7,136(sp)
ffffffffc0200a16:	e94a                	sd	s2,144(sp)
ffffffffc0200a18:	ed4e                	sd	s3,152(sp)
ffffffffc0200a1a:	f152                	sd	s4,160(sp)
ffffffffc0200a1c:	f556                	sd	s5,168(sp)
ffffffffc0200a1e:	f95a                	sd	s6,176(sp)
ffffffffc0200a20:	fd5e                	sd	s7,184(sp)
ffffffffc0200a22:	e1e2                	sd	s8,192(sp)
ffffffffc0200a24:	e5e6                	sd	s9,200(sp)
ffffffffc0200a26:	e9ea                	sd	s10,208(sp)
ffffffffc0200a28:	edee                	sd	s11,216(sp)
ffffffffc0200a2a:	f1f2                	sd	t3,224(sp)
ffffffffc0200a2c:	f5f6                	sd	t4,232(sp)
ffffffffc0200a2e:	f9fa                	sd	t5,240(sp)
ffffffffc0200a30:	fdfe                	sd	t6,248(sp)
ffffffffc0200a32:	14002473          	csrr	s0,sscratch
ffffffffc0200a36:	100024f3          	csrr	s1,sstatus
ffffffffc0200a3a:	14102973          	csrr	s2,sepc
ffffffffc0200a3e:	143029f3          	csrr	s3,stval
ffffffffc0200a42:	14202a73          	csrr	s4,scause
ffffffffc0200a46:	e822                	sd	s0,16(sp)
ffffffffc0200a48:	e226                	sd	s1,256(sp)
ffffffffc0200a4a:	e64a                	sd	s2,264(sp)
ffffffffc0200a4c:	ea4e                	sd	s3,272(sp)
ffffffffc0200a4e:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200a50:	850a                	mv	a0,sp
    jal trap
ffffffffc0200a52:	f93ff0ef          	jal	ra,ffffffffc02009e4 <trap>

ffffffffc0200a56 <__trapret>:
    // sp should be the same as before "jal trap"
    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200a56:	6492                	ld	s1,256(sp)
ffffffffc0200a58:	6932                	ld	s2,264(sp)
ffffffffc0200a5a:	10049073          	csrw	sstatus,s1
ffffffffc0200a5e:	14191073          	csrw	sepc,s2
ffffffffc0200a62:	60a2                	ld	ra,8(sp)
ffffffffc0200a64:	61e2                	ld	gp,24(sp)
ffffffffc0200a66:	7202                	ld	tp,32(sp)
ffffffffc0200a68:	72a2                	ld	t0,40(sp)
ffffffffc0200a6a:	7342                	ld	t1,48(sp)
ffffffffc0200a6c:	73e2                	ld	t2,56(sp)
ffffffffc0200a6e:	6406                	ld	s0,64(sp)
ffffffffc0200a70:	64a6                	ld	s1,72(sp)
ffffffffc0200a72:	6546                	ld	a0,80(sp)
ffffffffc0200a74:	65e6                	ld	a1,88(sp)
ffffffffc0200a76:	7606                	ld	a2,96(sp)
ffffffffc0200a78:	76a6                	ld	a3,104(sp)
ffffffffc0200a7a:	7746                	ld	a4,112(sp)
ffffffffc0200a7c:	77e6                	ld	a5,120(sp)
ffffffffc0200a7e:	680a                	ld	a6,128(sp)
ffffffffc0200a80:	68aa                	ld	a7,136(sp)
ffffffffc0200a82:	694a                	ld	s2,144(sp)
ffffffffc0200a84:	69ea                	ld	s3,152(sp)
ffffffffc0200a86:	7a0a                	ld	s4,160(sp)
ffffffffc0200a88:	7aaa                	ld	s5,168(sp)
ffffffffc0200a8a:	7b4a                	ld	s6,176(sp)
ffffffffc0200a8c:	7bea                	ld	s7,184(sp)
ffffffffc0200a8e:	6c0e                	ld	s8,192(sp)
ffffffffc0200a90:	6cae                	ld	s9,200(sp)
ffffffffc0200a92:	6d4e                	ld	s10,208(sp)
ffffffffc0200a94:	6dee                	ld	s11,216(sp)
ffffffffc0200a96:	7e0e                	ld	t3,224(sp)
ffffffffc0200a98:	7eae                	ld	t4,232(sp)
ffffffffc0200a9a:	7f4e                	ld	t5,240(sp)
ffffffffc0200a9c:	7fee                	ld	t6,248(sp)
ffffffffc0200a9e:	6142                	ld	sp,16(sp)
    // go back from supervisor call
    sret
ffffffffc0200aa0:	10200073          	sret
	...

ffffffffc0200ab0 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200ab0:	00011797          	auipc	a5,0x11
ffffffffc0200ab4:	9c878793          	addi	a5,a5,-1592 # ffffffffc0211478 <free_area>
ffffffffc0200ab8:	e79c                	sd	a5,8(a5)
ffffffffc0200aba:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200abc:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200ac0:	8082                	ret

ffffffffc0200ac2 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200ac2:	00011517          	auipc	a0,0x11
ffffffffc0200ac6:	9c656503          	lwu	a0,-1594(a0) # ffffffffc0211488 <free_area+0x10>
ffffffffc0200aca:	8082                	ret

ffffffffc0200acc <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200acc:	715d                	addi	sp,sp,-80
ffffffffc0200ace:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200ad0:	00011917          	auipc	s2,0x11
ffffffffc0200ad4:	9a890913          	addi	s2,s2,-1624 # ffffffffc0211478 <free_area>
ffffffffc0200ad8:	00893783          	ld	a5,8(s2)
ffffffffc0200adc:	e486                	sd	ra,72(sp)
ffffffffc0200ade:	e0a2                	sd	s0,64(sp)
ffffffffc0200ae0:	fc26                	sd	s1,56(sp)
ffffffffc0200ae2:	f44e                	sd	s3,40(sp)
ffffffffc0200ae4:	f052                	sd	s4,32(sp)
ffffffffc0200ae6:	ec56                	sd	s5,24(sp)
ffffffffc0200ae8:	e85a                	sd	s6,16(sp)
ffffffffc0200aea:	e45e                	sd	s7,8(sp)
ffffffffc0200aec:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200aee:	31278f63          	beq	a5,s2,ffffffffc0200e0c <default_check+0x340>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200af2:	fe87b703          	ld	a4,-24(a5)
ffffffffc0200af6:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200af8:	8b05                	andi	a4,a4,1
ffffffffc0200afa:	30070d63          	beqz	a4,ffffffffc0200e14 <default_check+0x348>
    int count = 0, total = 0;
ffffffffc0200afe:	4401                	li	s0,0
ffffffffc0200b00:	4481                	li	s1,0
ffffffffc0200b02:	a031                	j	ffffffffc0200b0e <default_check+0x42>
ffffffffc0200b04:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0200b08:	8b09                	andi	a4,a4,2
ffffffffc0200b0a:	30070563          	beqz	a4,ffffffffc0200e14 <default_check+0x348>
        count ++, total += p->property;
ffffffffc0200b0e:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b12:	679c                	ld	a5,8(a5)
ffffffffc0200b14:	2485                	addiw	s1,s1,1
ffffffffc0200b16:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b18:	ff2796e3          	bne	a5,s2,ffffffffc0200b04 <default_check+0x38>
ffffffffc0200b1c:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200b1e:	3ef000ef          	jal	ra,ffffffffc020170c <nr_free_pages>
ffffffffc0200b22:	75351963          	bne	a0,s3,ffffffffc0201274 <default_check+0x7a8>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b26:	4505                	li	a0,1
ffffffffc0200b28:	317000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200b2c:	8a2a                	mv	s4,a0
ffffffffc0200b2e:	48050363          	beqz	a0,ffffffffc0200fb4 <default_check+0x4e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b32:	4505                	li	a0,1
ffffffffc0200b34:	30b000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200b38:	89aa                	mv	s3,a0
ffffffffc0200b3a:	74050d63          	beqz	a0,ffffffffc0201294 <default_check+0x7c8>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b3e:	4505                	li	a0,1
ffffffffc0200b40:	2ff000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200b44:	8aaa                	mv	s5,a0
ffffffffc0200b46:	4e050763          	beqz	a0,ffffffffc0201034 <default_check+0x568>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b4a:	2f3a0563          	beq	s4,s3,ffffffffc0200e34 <default_check+0x368>
ffffffffc0200b4e:	2eaa0363          	beq	s4,a0,ffffffffc0200e34 <default_check+0x368>
ffffffffc0200b52:	2ea98163          	beq	s3,a0,ffffffffc0200e34 <default_check+0x368>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200b56:	000a2783          	lw	a5,0(s4)
ffffffffc0200b5a:	2e079d63          	bnez	a5,ffffffffc0200e54 <default_check+0x388>
ffffffffc0200b5e:	0009a783          	lw	a5,0(s3)
ffffffffc0200b62:	2e079963          	bnez	a5,ffffffffc0200e54 <default_check+0x388>
ffffffffc0200b66:	411c                	lw	a5,0(a0)
ffffffffc0200b68:	2e079663          	bnez	a5,ffffffffc0200e54 <default_check+0x388>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b6c:	00011797          	auipc	a5,0x11
ffffffffc0200b70:	93c78793          	addi	a5,a5,-1732 # ffffffffc02114a8 <pages>
ffffffffc0200b74:	639c                	ld	a5,0(a5)
ffffffffc0200b76:	00004717          	auipc	a4,0x4
ffffffffc0200b7a:	15a70713          	addi	a4,a4,346 # ffffffffc0204cd0 <commands+0x858>
ffffffffc0200b7e:	630c                	ld	a1,0(a4)
ffffffffc0200b80:	40fa0733          	sub	a4,s4,a5
ffffffffc0200b84:	870d                	srai	a4,a4,0x3
ffffffffc0200b86:	02b70733          	mul	a4,a4,a1
ffffffffc0200b8a:	00005697          	auipc	a3,0x5
ffffffffc0200b8e:	59e68693          	addi	a3,a3,1438 # ffffffffc0206128 <nbase>
ffffffffc0200b92:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200b94:	00011697          	auipc	a3,0x11
ffffffffc0200b98:	8c468693          	addi	a3,a3,-1852 # ffffffffc0211458 <npage>
ffffffffc0200b9c:	6294                	ld	a3,0(a3)
ffffffffc0200b9e:	06b2                	slli	a3,a3,0xc
ffffffffc0200ba0:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200ba2:	0732                	slli	a4,a4,0xc
ffffffffc0200ba4:	2cd77863          	bgeu	a4,a3,ffffffffc0200e74 <default_check+0x3a8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200ba8:	40f98733          	sub	a4,s3,a5
ffffffffc0200bac:	870d                	srai	a4,a4,0x3
ffffffffc0200bae:	02b70733          	mul	a4,a4,a1
ffffffffc0200bb2:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bb4:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200bb6:	4ed77f63          	bgeu	a4,a3,ffffffffc02010b4 <default_check+0x5e8>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200bba:	40f507b3          	sub	a5,a0,a5
ffffffffc0200bbe:	878d                	srai	a5,a5,0x3
ffffffffc0200bc0:	02b787b3          	mul	a5,a5,a1
ffffffffc0200bc4:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bc6:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200bc8:	34d7f663          	bgeu	a5,a3,ffffffffc0200f14 <default_check+0x448>
    assert(alloc_page() == NULL);
ffffffffc0200bcc:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200bce:	00093c03          	ld	s8,0(s2)
ffffffffc0200bd2:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200bd6:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200bda:	00011797          	auipc	a5,0x11
ffffffffc0200bde:	8b27b323          	sd	s2,-1882(a5) # ffffffffc0211480 <free_area+0x8>
ffffffffc0200be2:	00011797          	auipc	a5,0x11
ffffffffc0200be6:	8927bb23          	sd	s2,-1898(a5) # ffffffffc0211478 <free_area>
    nr_free = 0;
ffffffffc0200bea:	00011797          	auipc	a5,0x11
ffffffffc0200bee:	8807af23          	sw	zero,-1890(a5) # ffffffffc0211488 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200bf2:	24d000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200bf6:	2e051f63          	bnez	a0,ffffffffc0200ef4 <default_check+0x428>
    free_page(p0);
ffffffffc0200bfa:	4585                	li	a1,1
ffffffffc0200bfc:	8552                	mv	a0,s4
ffffffffc0200bfe:	2c9000ef          	jal	ra,ffffffffc02016c6 <free_pages>
    free_page(p1);
ffffffffc0200c02:	4585                	li	a1,1
ffffffffc0200c04:	854e                	mv	a0,s3
ffffffffc0200c06:	2c1000ef          	jal	ra,ffffffffc02016c6 <free_pages>
    free_page(p2);
ffffffffc0200c0a:	4585                	li	a1,1
ffffffffc0200c0c:	8556                	mv	a0,s5
ffffffffc0200c0e:	2b9000ef          	jal	ra,ffffffffc02016c6 <free_pages>
    assert(nr_free == 3);
ffffffffc0200c12:	01092703          	lw	a4,16(s2)
ffffffffc0200c16:	478d                	li	a5,3
ffffffffc0200c18:	2af71e63          	bne	a4,a5,ffffffffc0200ed4 <default_check+0x408>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200c1c:	4505                	li	a0,1
ffffffffc0200c1e:	221000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200c22:	89aa                	mv	s3,a0
ffffffffc0200c24:	28050863          	beqz	a0,ffffffffc0200eb4 <default_check+0x3e8>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c28:	4505                	li	a0,1
ffffffffc0200c2a:	215000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200c2e:	8aaa                	mv	s5,a0
ffffffffc0200c30:	3e050263          	beqz	a0,ffffffffc0201014 <default_check+0x548>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c34:	4505                	li	a0,1
ffffffffc0200c36:	209000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200c3a:	8a2a                	mv	s4,a0
ffffffffc0200c3c:	3a050c63          	beqz	a0,ffffffffc0200ff4 <default_check+0x528>
    assert(alloc_page() == NULL);
ffffffffc0200c40:	4505                	li	a0,1
ffffffffc0200c42:	1fd000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200c46:	38051763          	bnez	a0,ffffffffc0200fd4 <default_check+0x508>
    free_page(p0);
ffffffffc0200c4a:	4585                	li	a1,1
ffffffffc0200c4c:	854e                	mv	a0,s3
ffffffffc0200c4e:	279000ef          	jal	ra,ffffffffc02016c6 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200c52:	00893783          	ld	a5,8(s2)
ffffffffc0200c56:	23278f63          	beq	a5,s2,ffffffffc0200e94 <default_check+0x3c8>
    assert((p = alloc_page()) == p0);
ffffffffc0200c5a:	4505                	li	a0,1
ffffffffc0200c5c:	1e3000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200c60:	32a99a63          	bne	s3,a0,ffffffffc0200f94 <default_check+0x4c8>
    assert(alloc_page() == NULL);
ffffffffc0200c64:	4505                	li	a0,1
ffffffffc0200c66:	1d9000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200c6a:	30051563          	bnez	a0,ffffffffc0200f74 <default_check+0x4a8>
    assert(nr_free == 0);
ffffffffc0200c6e:	01092783          	lw	a5,16(s2)
ffffffffc0200c72:	2e079163          	bnez	a5,ffffffffc0200f54 <default_check+0x488>
    free_page(p);
ffffffffc0200c76:	854e                	mv	a0,s3
ffffffffc0200c78:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200c7a:	00010797          	auipc	a5,0x10
ffffffffc0200c7e:	7f87bf23          	sd	s8,2046(a5) # ffffffffc0211478 <free_area>
ffffffffc0200c82:	00010797          	auipc	a5,0x10
ffffffffc0200c86:	7f77bf23          	sd	s7,2046(a5) # ffffffffc0211480 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200c8a:	00010797          	auipc	a5,0x10
ffffffffc0200c8e:	7f67af23          	sw	s6,2046(a5) # ffffffffc0211488 <free_area+0x10>
    free_page(p);
ffffffffc0200c92:	235000ef          	jal	ra,ffffffffc02016c6 <free_pages>
    free_page(p1);
ffffffffc0200c96:	4585                	li	a1,1
ffffffffc0200c98:	8556                	mv	a0,s5
ffffffffc0200c9a:	22d000ef          	jal	ra,ffffffffc02016c6 <free_pages>
    free_page(p2);
ffffffffc0200c9e:	4585                	li	a1,1
ffffffffc0200ca0:	8552                	mv	a0,s4
ffffffffc0200ca2:	225000ef          	jal	ra,ffffffffc02016c6 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200ca6:	4515                	li	a0,5
ffffffffc0200ca8:	197000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200cac:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200cae:	28050363          	beqz	a0,ffffffffc0200f34 <default_check+0x468>
ffffffffc0200cb2:	651c                	ld	a5,8(a0)
ffffffffc0200cb4:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200cb6:	8b85                	andi	a5,a5,1
ffffffffc0200cb8:	54079e63          	bnez	a5,ffffffffc0201214 <default_check+0x748>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200cbc:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200cbe:	00093b03          	ld	s6,0(s2)
ffffffffc0200cc2:	00893a83          	ld	s5,8(s2)
ffffffffc0200cc6:	00010797          	auipc	a5,0x10
ffffffffc0200cca:	7b27b923          	sd	s2,1970(a5) # ffffffffc0211478 <free_area>
ffffffffc0200cce:	00010797          	auipc	a5,0x10
ffffffffc0200cd2:	7b27b923          	sd	s2,1970(a5) # ffffffffc0211480 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200cd6:	169000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200cda:	50051d63          	bnez	a0,ffffffffc02011f4 <default_check+0x728>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200cde:	09098a13          	addi	s4,s3,144
ffffffffc0200ce2:	8552                	mv	a0,s4
ffffffffc0200ce4:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200ce6:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0200cea:	00010797          	auipc	a5,0x10
ffffffffc0200cee:	7807af23          	sw	zero,1950(a5) # ffffffffc0211488 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200cf2:	1d5000ef          	jal	ra,ffffffffc02016c6 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200cf6:	4511                	li	a0,4
ffffffffc0200cf8:	147000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200cfc:	4c051c63          	bnez	a0,ffffffffc02011d4 <default_check+0x708>
ffffffffc0200d00:	0989b783          	ld	a5,152(s3)
ffffffffc0200d04:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200d06:	8b85                	andi	a5,a5,1
ffffffffc0200d08:	4a078663          	beqz	a5,ffffffffc02011b4 <default_check+0x6e8>
ffffffffc0200d0c:	0a89a703          	lw	a4,168(s3)
ffffffffc0200d10:	478d                	li	a5,3
ffffffffc0200d12:	4af71163          	bne	a4,a5,ffffffffc02011b4 <default_check+0x6e8>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200d16:	450d                	li	a0,3
ffffffffc0200d18:	127000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200d1c:	8c2a                	mv	s8,a0
ffffffffc0200d1e:	46050b63          	beqz	a0,ffffffffc0201194 <default_check+0x6c8>
    assert(alloc_page() == NULL);
ffffffffc0200d22:	4505                	li	a0,1
ffffffffc0200d24:	11b000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200d28:	44051663          	bnez	a0,ffffffffc0201174 <default_check+0x6a8>
    assert(p0 + 2 == p1);
ffffffffc0200d2c:	438a1463          	bne	s4,s8,ffffffffc0201154 <default_check+0x688>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200d30:	4585                	li	a1,1
ffffffffc0200d32:	854e                	mv	a0,s3
ffffffffc0200d34:	193000ef          	jal	ra,ffffffffc02016c6 <free_pages>
    free_pages(p1, 3);
ffffffffc0200d38:	458d                	li	a1,3
ffffffffc0200d3a:	8552                	mv	a0,s4
ffffffffc0200d3c:	18b000ef          	jal	ra,ffffffffc02016c6 <free_pages>
ffffffffc0200d40:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200d44:	04898c13          	addi	s8,s3,72
ffffffffc0200d48:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200d4a:	8b85                	andi	a5,a5,1
ffffffffc0200d4c:	3e078463          	beqz	a5,ffffffffc0201134 <default_check+0x668>
ffffffffc0200d50:	0189a703          	lw	a4,24(s3)
ffffffffc0200d54:	4785                	li	a5,1
ffffffffc0200d56:	3cf71f63          	bne	a4,a5,ffffffffc0201134 <default_check+0x668>
ffffffffc0200d5a:	008a3783          	ld	a5,8(s4)
ffffffffc0200d5e:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200d60:	8b85                	andi	a5,a5,1
ffffffffc0200d62:	3a078963          	beqz	a5,ffffffffc0201114 <default_check+0x648>
ffffffffc0200d66:	018a2703          	lw	a4,24(s4)
ffffffffc0200d6a:	478d                	li	a5,3
ffffffffc0200d6c:	3af71463          	bne	a4,a5,ffffffffc0201114 <default_check+0x648>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200d70:	4505                	li	a0,1
ffffffffc0200d72:	0cd000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200d76:	36a99f63          	bne	s3,a0,ffffffffc02010f4 <default_check+0x628>
    free_page(p0);
ffffffffc0200d7a:	4585                	li	a1,1
ffffffffc0200d7c:	14b000ef          	jal	ra,ffffffffc02016c6 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200d80:	4509                	li	a0,2
ffffffffc0200d82:	0bd000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200d86:	34aa1763          	bne	s4,a0,ffffffffc02010d4 <default_check+0x608>

    free_pages(p0, 2);
ffffffffc0200d8a:	4589                	li	a1,2
ffffffffc0200d8c:	13b000ef          	jal	ra,ffffffffc02016c6 <free_pages>
    free_page(p2);
ffffffffc0200d90:	4585                	li	a1,1
ffffffffc0200d92:	8562                	mv	a0,s8
ffffffffc0200d94:	133000ef          	jal	ra,ffffffffc02016c6 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200d98:	4515                	li	a0,5
ffffffffc0200d9a:	0a5000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200d9e:	89aa                	mv	s3,a0
ffffffffc0200da0:	48050a63          	beqz	a0,ffffffffc0201234 <default_check+0x768>
    assert(alloc_page() == NULL);
ffffffffc0200da4:	4505                	li	a0,1
ffffffffc0200da6:	099000ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0200daa:	2e051563          	bnez	a0,ffffffffc0201094 <default_check+0x5c8>

    assert(nr_free == 0);
ffffffffc0200dae:	01092783          	lw	a5,16(s2)
ffffffffc0200db2:	2c079163          	bnez	a5,ffffffffc0201074 <default_check+0x5a8>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200db6:	4595                	li	a1,5
ffffffffc0200db8:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200dba:	00010797          	auipc	a5,0x10
ffffffffc0200dbe:	6d77a723          	sw	s7,1742(a5) # ffffffffc0211488 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200dc2:	00010797          	auipc	a5,0x10
ffffffffc0200dc6:	6b67bb23          	sd	s6,1718(a5) # ffffffffc0211478 <free_area>
ffffffffc0200dca:	00010797          	auipc	a5,0x10
ffffffffc0200dce:	6b57bb23          	sd	s5,1718(a5) # ffffffffc0211480 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200dd2:	0f5000ef          	jal	ra,ffffffffc02016c6 <free_pages>
    return listelm->next;
ffffffffc0200dd6:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200dda:	01278963          	beq	a5,s2,ffffffffc0200dec <default_check+0x320>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200dde:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200de2:	679c                	ld	a5,8(a5)
ffffffffc0200de4:	34fd                	addiw	s1,s1,-1
ffffffffc0200de6:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200de8:	ff279be3          	bne	a5,s2,ffffffffc0200dde <default_check+0x312>
    }
    assert(count == 0);
ffffffffc0200dec:	26049463          	bnez	s1,ffffffffc0201054 <default_check+0x588>
    assert(total == 0);
ffffffffc0200df0:	46041263          	bnez	s0,ffffffffc0201254 <default_check+0x788>
}
ffffffffc0200df4:	60a6                	ld	ra,72(sp)
ffffffffc0200df6:	6406                	ld	s0,64(sp)
ffffffffc0200df8:	74e2                	ld	s1,56(sp)
ffffffffc0200dfa:	7942                	ld	s2,48(sp)
ffffffffc0200dfc:	79a2                	ld	s3,40(sp)
ffffffffc0200dfe:	7a02                	ld	s4,32(sp)
ffffffffc0200e00:	6ae2                	ld	s5,24(sp)
ffffffffc0200e02:	6b42                	ld	s6,16(sp)
ffffffffc0200e04:	6ba2                	ld	s7,8(sp)
ffffffffc0200e06:	6c02                	ld	s8,0(sp)
ffffffffc0200e08:	6161                	addi	sp,sp,80
ffffffffc0200e0a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e0c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200e0e:	4401                	li	s0,0
ffffffffc0200e10:	4481                	li	s1,0
ffffffffc0200e12:	b331                	j	ffffffffc0200b1e <default_check+0x52>
        assert(PageProperty(p));
ffffffffc0200e14:	00004697          	auipc	a3,0x4
ffffffffc0200e18:	ec468693          	addi	a3,a3,-316 # ffffffffc0204cd8 <commands+0x860>
ffffffffc0200e1c:	00004617          	auipc	a2,0x4
ffffffffc0200e20:	ecc60613          	addi	a2,a2,-308 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0200e24:	0f000593          	li	a1,240
ffffffffc0200e28:	00004517          	auipc	a0,0x4
ffffffffc0200e2c:	ed850513          	addi	a0,a0,-296 # ffffffffc0204d00 <commands+0x888>
ffffffffc0200e30:	d40ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200e34:	00004697          	auipc	a3,0x4
ffffffffc0200e38:	f6468693          	addi	a3,a3,-156 # ffffffffc0204d98 <commands+0x920>
ffffffffc0200e3c:	00004617          	auipc	a2,0x4
ffffffffc0200e40:	eac60613          	addi	a2,a2,-340 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0200e44:	0bd00593          	li	a1,189
ffffffffc0200e48:	00004517          	auipc	a0,0x4
ffffffffc0200e4c:	eb850513          	addi	a0,a0,-328 # ffffffffc0204d00 <commands+0x888>
ffffffffc0200e50:	d20ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e54:	00004697          	auipc	a3,0x4
ffffffffc0200e58:	f6c68693          	addi	a3,a3,-148 # ffffffffc0204dc0 <commands+0x948>
ffffffffc0200e5c:	00004617          	auipc	a2,0x4
ffffffffc0200e60:	e8c60613          	addi	a2,a2,-372 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0200e64:	0be00593          	li	a1,190
ffffffffc0200e68:	00004517          	auipc	a0,0x4
ffffffffc0200e6c:	e9850513          	addi	a0,a0,-360 # ffffffffc0204d00 <commands+0x888>
ffffffffc0200e70:	d00ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200e74:	00004697          	auipc	a3,0x4
ffffffffc0200e78:	f8c68693          	addi	a3,a3,-116 # ffffffffc0204e00 <commands+0x988>
ffffffffc0200e7c:	00004617          	auipc	a2,0x4
ffffffffc0200e80:	e6c60613          	addi	a2,a2,-404 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0200e84:	0c000593          	li	a1,192
ffffffffc0200e88:	00004517          	auipc	a0,0x4
ffffffffc0200e8c:	e7850513          	addi	a0,a0,-392 # ffffffffc0204d00 <commands+0x888>
ffffffffc0200e90:	ce0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200e94:	00004697          	auipc	a3,0x4
ffffffffc0200e98:	ff468693          	addi	a3,a3,-12 # ffffffffc0204e88 <commands+0xa10>
ffffffffc0200e9c:	00004617          	auipc	a2,0x4
ffffffffc0200ea0:	e4c60613          	addi	a2,a2,-436 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0200ea4:	0d900593          	li	a1,217
ffffffffc0200ea8:	00004517          	auipc	a0,0x4
ffffffffc0200eac:	e5850513          	addi	a0,a0,-424 # ffffffffc0204d00 <commands+0x888>
ffffffffc0200eb0:	cc0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200eb4:	00004697          	auipc	a3,0x4
ffffffffc0200eb8:	e8468693          	addi	a3,a3,-380 # ffffffffc0204d38 <commands+0x8c0>
ffffffffc0200ebc:	00004617          	auipc	a2,0x4
ffffffffc0200ec0:	e2c60613          	addi	a2,a2,-468 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0200ec4:	0d200593          	li	a1,210
ffffffffc0200ec8:	00004517          	auipc	a0,0x4
ffffffffc0200ecc:	e3850513          	addi	a0,a0,-456 # ffffffffc0204d00 <commands+0x888>
ffffffffc0200ed0:	ca0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(nr_free == 3);
ffffffffc0200ed4:	00004697          	auipc	a3,0x4
ffffffffc0200ed8:	fa468693          	addi	a3,a3,-92 # ffffffffc0204e78 <commands+0xa00>
ffffffffc0200edc:	00004617          	auipc	a2,0x4
ffffffffc0200ee0:	e0c60613          	addi	a2,a2,-500 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0200ee4:	0d000593          	li	a1,208
ffffffffc0200ee8:	00004517          	auipc	a0,0x4
ffffffffc0200eec:	e1850513          	addi	a0,a0,-488 # ffffffffc0204d00 <commands+0x888>
ffffffffc0200ef0:	c80ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ef4:	00004697          	auipc	a3,0x4
ffffffffc0200ef8:	f6c68693          	addi	a3,a3,-148 # ffffffffc0204e60 <commands+0x9e8>
ffffffffc0200efc:	00004617          	auipc	a2,0x4
ffffffffc0200f00:	dec60613          	addi	a2,a2,-532 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0200f04:	0cb00593          	li	a1,203
ffffffffc0200f08:	00004517          	auipc	a0,0x4
ffffffffc0200f0c:	df850513          	addi	a0,a0,-520 # ffffffffc0204d00 <commands+0x888>
ffffffffc0200f10:	c60ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f14:	00004697          	auipc	a3,0x4
ffffffffc0200f18:	f2c68693          	addi	a3,a3,-212 # ffffffffc0204e40 <commands+0x9c8>
ffffffffc0200f1c:	00004617          	auipc	a2,0x4
ffffffffc0200f20:	dcc60613          	addi	a2,a2,-564 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0200f24:	0c200593          	li	a1,194
ffffffffc0200f28:	00004517          	auipc	a0,0x4
ffffffffc0200f2c:	dd850513          	addi	a0,a0,-552 # ffffffffc0204d00 <commands+0x888>
ffffffffc0200f30:	c40ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(p0 != NULL);
ffffffffc0200f34:	00004697          	auipc	a3,0x4
ffffffffc0200f38:	f9c68693          	addi	a3,a3,-100 # ffffffffc0204ed0 <commands+0xa58>
ffffffffc0200f3c:	00004617          	auipc	a2,0x4
ffffffffc0200f40:	dac60613          	addi	a2,a2,-596 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0200f44:	0f800593          	li	a1,248
ffffffffc0200f48:	00004517          	auipc	a0,0x4
ffffffffc0200f4c:	db850513          	addi	a0,a0,-584 # ffffffffc0204d00 <commands+0x888>
ffffffffc0200f50:	c20ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(nr_free == 0);
ffffffffc0200f54:	00004697          	auipc	a3,0x4
ffffffffc0200f58:	f6c68693          	addi	a3,a3,-148 # ffffffffc0204ec0 <commands+0xa48>
ffffffffc0200f5c:	00004617          	auipc	a2,0x4
ffffffffc0200f60:	d8c60613          	addi	a2,a2,-628 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0200f64:	0df00593          	li	a1,223
ffffffffc0200f68:	00004517          	auipc	a0,0x4
ffffffffc0200f6c:	d9850513          	addi	a0,a0,-616 # ffffffffc0204d00 <commands+0x888>
ffffffffc0200f70:	c00ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f74:	00004697          	auipc	a3,0x4
ffffffffc0200f78:	eec68693          	addi	a3,a3,-276 # ffffffffc0204e60 <commands+0x9e8>
ffffffffc0200f7c:	00004617          	auipc	a2,0x4
ffffffffc0200f80:	d6c60613          	addi	a2,a2,-660 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0200f84:	0dd00593          	li	a1,221
ffffffffc0200f88:	00004517          	auipc	a0,0x4
ffffffffc0200f8c:	d7850513          	addi	a0,a0,-648 # ffffffffc0204d00 <commands+0x888>
ffffffffc0200f90:	be0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200f94:	00004697          	auipc	a3,0x4
ffffffffc0200f98:	f0c68693          	addi	a3,a3,-244 # ffffffffc0204ea0 <commands+0xa28>
ffffffffc0200f9c:	00004617          	auipc	a2,0x4
ffffffffc0200fa0:	d4c60613          	addi	a2,a2,-692 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0200fa4:	0dc00593          	li	a1,220
ffffffffc0200fa8:	00004517          	auipc	a0,0x4
ffffffffc0200fac:	d5850513          	addi	a0,a0,-680 # ffffffffc0204d00 <commands+0x888>
ffffffffc0200fb0:	bc0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200fb4:	00004697          	auipc	a3,0x4
ffffffffc0200fb8:	d8468693          	addi	a3,a3,-636 # ffffffffc0204d38 <commands+0x8c0>
ffffffffc0200fbc:	00004617          	auipc	a2,0x4
ffffffffc0200fc0:	d2c60613          	addi	a2,a2,-724 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0200fc4:	0b900593          	li	a1,185
ffffffffc0200fc8:	00004517          	auipc	a0,0x4
ffffffffc0200fcc:	d3850513          	addi	a0,a0,-712 # ffffffffc0204d00 <commands+0x888>
ffffffffc0200fd0:	ba0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fd4:	00004697          	auipc	a3,0x4
ffffffffc0200fd8:	e8c68693          	addi	a3,a3,-372 # ffffffffc0204e60 <commands+0x9e8>
ffffffffc0200fdc:	00004617          	auipc	a2,0x4
ffffffffc0200fe0:	d0c60613          	addi	a2,a2,-756 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0200fe4:	0d600593          	li	a1,214
ffffffffc0200fe8:	00004517          	auipc	a0,0x4
ffffffffc0200fec:	d1850513          	addi	a0,a0,-744 # ffffffffc0204d00 <commands+0x888>
ffffffffc0200ff0:	b80ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ff4:	00004697          	auipc	a3,0x4
ffffffffc0200ff8:	d8468693          	addi	a3,a3,-636 # ffffffffc0204d78 <commands+0x900>
ffffffffc0200ffc:	00004617          	auipc	a2,0x4
ffffffffc0201000:	cec60613          	addi	a2,a2,-788 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0201004:	0d400593          	li	a1,212
ffffffffc0201008:	00004517          	auipc	a0,0x4
ffffffffc020100c:	cf850513          	addi	a0,a0,-776 # ffffffffc0204d00 <commands+0x888>
ffffffffc0201010:	b60ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201014:	00004697          	auipc	a3,0x4
ffffffffc0201018:	d4468693          	addi	a3,a3,-700 # ffffffffc0204d58 <commands+0x8e0>
ffffffffc020101c:	00004617          	auipc	a2,0x4
ffffffffc0201020:	ccc60613          	addi	a2,a2,-820 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0201024:	0d300593          	li	a1,211
ffffffffc0201028:	00004517          	auipc	a0,0x4
ffffffffc020102c:	cd850513          	addi	a0,a0,-808 # ffffffffc0204d00 <commands+0x888>
ffffffffc0201030:	b40ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201034:	00004697          	auipc	a3,0x4
ffffffffc0201038:	d4468693          	addi	a3,a3,-700 # ffffffffc0204d78 <commands+0x900>
ffffffffc020103c:	00004617          	auipc	a2,0x4
ffffffffc0201040:	cac60613          	addi	a2,a2,-852 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0201044:	0bb00593          	li	a1,187
ffffffffc0201048:	00004517          	auipc	a0,0x4
ffffffffc020104c:	cb850513          	addi	a0,a0,-840 # ffffffffc0204d00 <commands+0x888>
ffffffffc0201050:	b20ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(count == 0);
ffffffffc0201054:	00004697          	auipc	a3,0x4
ffffffffc0201058:	fcc68693          	addi	a3,a3,-52 # ffffffffc0205020 <commands+0xba8>
ffffffffc020105c:	00004617          	auipc	a2,0x4
ffffffffc0201060:	c8c60613          	addi	a2,a2,-884 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0201064:	12500593          	li	a1,293
ffffffffc0201068:	00004517          	auipc	a0,0x4
ffffffffc020106c:	c9850513          	addi	a0,a0,-872 # ffffffffc0204d00 <commands+0x888>
ffffffffc0201070:	b00ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(nr_free == 0);
ffffffffc0201074:	00004697          	auipc	a3,0x4
ffffffffc0201078:	e4c68693          	addi	a3,a3,-436 # ffffffffc0204ec0 <commands+0xa48>
ffffffffc020107c:	00004617          	auipc	a2,0x4
ffffffffc0201080:	c6c60613          	addi	a2,a2,-916 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0201084:	11a00593          	li	a1,282
ffffffffc0201088:	00004517          	auipc	a0,0x4
ffffffffc020108c:	c7850513          	addi	a0,a0,-904 # ffffffffc0204d00 <commands+0x888>
ffffffffc0201090:	ae0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201094:	00004697          	auipc	a3,0x4
ffffffffc0201098:	dcc68693          	addi	a3,a3,-564 # ffffffffc0204e60 <commands+0x9e8>
ffffffffc020109c:	00004617          	auipc	a2,0x4
ffffffffc02010a0:	c4c60613          	addi	a2,a2,-948 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02010a4:	11800593          	li	a1,280
ffffffffc02010a8:	00004517          	auipc	a0,0x4
ffffffffc02010ac:	c5850513          	addi	a0,a0,-936 # ffffffffc0204d00 <commands+0x888>
ffffffffc02010b0:	ac0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02010b4:	00004697          	auipc	a3,0x4
ffffffffc02010b8:	d6c68693          	addi	a3,a3,-660 # ffffffffc0204e20 <commands+0x9a8>
ffffffffc02010bc:	00004617          	auipc	a2,0x4
ffffffffc02010c0:	c2c60613          	addi	a2,a2,-980 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02010c4:	0c100593          	li	a1,193
ffffffffc02010c8:	00004517          	auipc	a0,0x4
ffffffffc02010cc:	c3850513          	addi	a0,a0,-968 # ffffffffc0204d00 <commands+0x888>
ffffffffc02010d0:	aa0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02010d4:	00004697          	auipc	a3,0x4
ffffffffc02010d8:	f0c68693          	addi	a3,a3,-244 # ffffffffc0204fe0 <commands+0xb68>
ffffffffc02010dc:	00004617          	auipc	a2,0x4
ffffffffc02010e0:	c0c60613          	addi	a2,a2,-1012 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02010e4:	11200593          	li	a1,274
ffffffffc02010e8:	00004517          	auipc	a0,0x4
ffffffffc02010ec:	c1850513          	addi	a0,a0,-1000 # ffffffffc0204d00 <commands+0x888>
ffffffffc02010f0:	a80ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02010f4:	00004697          	auipc	a3,0x4
ffffffffc02010f8:	ecc68693          	addi	a3,a3,-308 # ffffffffc0204fc0 <commands+0xb48>
ffffffffc02010fc:	00004617          	auipc	a2,0x4
ffffffffc0201100:	bec60613          	addi	a2,a2,-1044 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0201104:	11000593          	li	a1,272
ffffffffc0201108:	00004517          	auipc	a0,0x4
ffffffffc020110c:	bf850513          	addi	a0,a0,-1032 # ffffffffc0204d00 <commands+0x888>
ffffffffc0201110:	a60ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201114:	00004697          	auipc	a3,0x4
ffffffffc0201118:	e8468693          	addi	a3,a3,-380 # ffffffffc0204f98 <commands+0xb20>
ffffffffc020111c:	00004617          	auipc	a2,0x4
ffffffffc0201120:	bcc60613          	addi	a2,a2,-1076 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0201124:	10e00593          	li	a1,270
ffffffffc0201128:	00004517          	auipc	a0,0x4
ffffffffc020112c:	bd850513          	addi	a0,a0,-1064 # ffffffffc0204d00 <commands+0x888>
ffffffffc0201130:	a40ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201134:	00004697          	auipc	a3,0x4
ffffffffc0201138:	e3c68693          	addi	a3,a3,-452 # ffffffffc0204f70 <commands+0xaf8>
ffffffffc020113c:	00004617          	auipc	a2,0x4
ffffffffc0201140:	bac60613          	addi	a2,a2,-1108 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0201144:	10d00593          	li	a1,269
ffffffffc0201148:	00004517          	auipc	a0,0x4
ffffffffc020114c:	bb850513          	addi	a0,a0,-1096 # ffffffffc0204d00 <commands+0x888>
ffffffffc0201150:	a20ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201154:	00004697          	auipc	a3,0x4
ffffffffc0201158:	e0c68693          	addi	a3,a3,-500 # ffffffffc0204f60 <commands+0xae8>
ffffffffc020115c:	00004617          	auipc	a2,0x4
ffffffffc0201160:	b8c60613          	addi	a2,a2,-1140 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0201164:	10800593          	li	a1,264
ffffffffc0201168:	00004517          	auipc	a0,0x4
ffffffffc020116c:	b9850513          	addi	a0,a0,-1128 # ffffffffc0204d00 <commands+0x888>
ffffffffc0201170:	a00ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201174:	00004697          	auipc	a3,0x4
ffffffffc0201178:	cec68693          	addi	a3,a3,-788 # ffffffffc0204e60 <commands+0x9e8>
ffffffffc020117c:	00004617          	auipc	a2,0x4
ffffffffc0201180:	b6c60613          	addi	a2,a2,-1172 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0201184:	10700593          	li	a1,263
ffffffffc0201188:	00004517          	auipc	a0,0x4
ffffffffc020118c:	b7850513          	addi	a0,a0,-1160 # ffffffffc0204d00 <commands+0x888>
ffffffffc0201190:	9e0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201194:	00004697          	auipc	a3,0x4
ffffffffc0201198:	dac68693          	addi	a3,a3,-596 # ffffffffc0204f40 <commands+0xac8>
ffffffffc020119c:	00004617          	auipc	a2,0x4
ffffffffc02011a0:	b4c60613          	addi	a2,a2,-1204 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02011a4:	10600593          	li	a1,262
ffffffffc02011a8:	00004517          	auipc	a0,0x4
ffffffffc02011ac:	b5850513          	addi	a0,a0,-1192 # ffffffffc0204d00 <commands+0x888>
ffffffffc02011b0:	9c0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02011b4:	00004697          	auipc	a3,0x4
ffffffffc02011b8:	d5c68693          	addi	a3,a3,-676 # ffffffffc0204f10 <commands+0xa98>
ffffffffc02011bc:	00004617          	auipc	a2,0x4
ffffffffc02011c0:	b2c60613          	addi	a2,a2,-1236 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02011c4:	10500593          	li	a1,261
ffffffffc02011c8:	00004517          	auipc	a0,0x4
ffffffffc02011cc:	b3850513          	addi	a0,a0,-1224 # ffffffffc0204d00 <commands+0x888>
ffffffffc02011d0:	9a0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02011d4:	00004697          	auipc	a3,0x4
ffffffffc02011d8:	d2468693          	addi	a3,a3,-732 # ffffffffc0204ef8 <commands+0xa80>
ffffffffc02011dc:	00004617          	auipc	a2,0x4
ffffffffc02011e0:	b0c60613          	addi	a2,a2,-1268 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02011e4:	10400593          	li	a1,260
ffffffffc02011e8:	00004517          	auipc	a0,0x4
ffffffffc02011ec:	b1850513          	addi	a0,a0,-1256 # ffffffffc0204d00 <commands+0x888>
ffffffffc02011f0:	980ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011f4:	00004697          	auipc	a3,0x4
ffffffffc02011f8:	c6c68693          	addi	a3,a3,-916 # ffffffffc0204e60 <commands+0x9e8>
ffffffffc02011fc:	00004617          	auipc	a2,0x4
ffffffffc0201200:	aec60613          	addi	a2,a2,-1300 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0201204:	0fe00593          	li	a1,254
ffffffffc0201208:	00004517          	auipc	a0,0x4
ffffffffc020120c:	af850513          	addi	a0,a0,-1288 # ffffffffc0204d00 <commands+0x888>
ffffffffc0201210:	960ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201214:	00004697          	auipc	a3,0x4
ffffffffc0201218:	ccc68693          	addi	a3,a3,-820 # ffffffffc0204ee0 <commands+0xa68>
ffffffffc020121c:	00004617          	auipc	a2,0x4
ffffffffc0201220:	acc60613          	addi	a2,a2,-1332 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0201224:	0f900593          	li	a1,249
ffffffffc0201228:	00004517          	auipc	a0,0x4
ffffffffc020122c:	ad850513          	addi	a0,a0,-1320 # ffffffffc0204d00 <commands+0x888>
ffffffffc0201230:	940ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201234:	00004697          	auipc	a3,0x4
ffffffffc0201238:	dcc68693          	addi	a3,a3,-564 # ffffffffc0205000 <commands+0xb88>
ffffffffc020123c:	00004617          	auipc	a2,0x4
ffffffffc0201240:	aac60613          	addi	a2,a2,-1364 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0201244:	11700593          	li	a1,279
ffffffffc0201248:	00004517          	auipc	a0,0x4
ffffffffc020124c:	ab850513          	addi	a0,a0,-1352 # ffffffffc0204d00 <commands+0x888>
ffffffffc0201250:	920ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(total == 0);
ffffffffc0201254:	00004697          	auipc	a3,0x4
ffffffffc0201258:	ddc68693          	addi	a3,a3,-548 # ffffffffc0205030 <commands+0xbb8>
ffffffffc020125c:	00004617          	auipc	a2,0x4
ffffffffc0201260:	a8c60613          	addi	a2,a2,-1396 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0201264:	12600593          	li	a1,294
ffffffffc0201268:	00004517          	auipc	a0,0x4
ffffffffc020126c:	a9850513          	addi	a0,a0,-1384 # ffffffffc0204d00 <commands+0x888>
ffffffffc0201270:	900ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201274:	00004697          	auipc	a3,0x4
ffffffffc0201278:	aa468693          	addi	a3,a3,-1372 # ffffffffc0204d18 <commands+0x8a0>
ffffffffc020127c:	00004617          	auipc	a2,0x4
ffffffffc0201280:	a6c60613          	addi	a2,a2,-1428 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0201284:	0f300593          	li	a1,243
ffffffffc0201288:	00004517          	auipc	a0,0x4
ffffffffc020128c:	a7850513          	addi	a0,a0,-1416 # ffffffffc0204d00 <commands+0x888>
ffffffffc0201290:	8e0ff0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201294:	00004697          	auipc	a3,0x4
ffffffffc0201298:	ac468693          	addi	a3,a3,-1340 # ffffffffc0204d58 <commands+0x8e0>
ffffffffc020129c:	00004617          	auipc	a2,0x4
ffffffffc02012a0:	a4c60613          	addi	a2,a2,-1460 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02012a4:	0ba00593          	li	a1,186
ffffffffc02012a8:	00004517          	auipc	a0,0x4
ffffffffc02012ac:	a5850513          	addi	a0,a0,-1448 # ffffffffc0204d00 <commands+0x888>
ffffffffc02012b0:	8c0ff0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc02012b4 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02012b4:	1141                	addi	sp,sp,-16
ffffffffc02012b6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02012b8:	18058063          	beqz	a1,ffffffffc0201438 <default_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc02012bc:	00359693          	slli	a3,a1,0x3
ffffffffc02012c0:	96ae                	add	a3,a3,a1
ffffffffc02012c2:	068e                	slli	a3,a3,0x3
ffffffffc02012c4:	96aa                	add	a3,a3,a0
ffffffffc02012c6:	02d50d63          	beq	a0,a3,ffffffffc0201300 <default_free_pages+0x4c>
ffffffffc02012ca:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02012cc:	8b85                	andi	a5,a5,1
ffffffffc02012ce:	14079563          	bnez	a5,ffffffffc0201418 <default_free_pages+0x164>
ffffffffc02012d2:	651c                	ld	a5,8(a0)
ffffffffc02012d4:	8385                	srli	a5,a5,0x1
ffffffffc02012d6:	8b85                	andi	a5,a5,1
ffffffffc02012d8:	14079063          	bnez	a5,ffffffffc0201418 <default_free_pages+0x164>
ffffffffc02012dc:	87aa                	mv	a5,a0
ffffffffc02012de:	a809                	j	ffffffffc02012f0 <default_free_pages+0x3c>
ffffffffc02012e0:	6798                	ld	a4,8(a5)
ffffffffc02012e2:	8b05                	andi	a4,a4,1
ffffffffc02012e4:	12071a63          	bnez	a4,ffffffffc0201418 <default_free_pages+0x164>
ffffffffc02012e8:	6798                	ld	a4,8(a5)
ffffffffc02012ea:	8b09                	andi	a4,a4,2
ffffffffc02012ec:	12071663          	bnez	a4,ffffffffc0201418 <default_free_pages+0x164>
        p->flags = 0;
ffffffffc02012f0:	0007b423          	sd	zero,8(a5)
    return pa2page(PDE_ADDR(pde));
}

static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02012f4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02012f8:	04878793          	addi	a5,a5,72
ffffffffc02012fc:	fed792e3          	bne	a5,a3,ffffffffc02012e0 <default_free_pages+0x2c>
    base->property = n;
ffffffffc0201300:	2581                	sext.w	a1,a1
ffffffffc0201302:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc0201304:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201308:	4789                	li	a5,2
ffffffffc020130a:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc020130e:	00010697          	auipc	a3,0x10
ffffffffc0201312:	16a68693          	addi	a3,a3,362 # ffffffffc0211478 <free_area>
ffffffffc0201316:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201318:	669c                	ld	a5,8(a3)
ffffffffc020131a:	9db9                	addw	a1,a1,a4
ffffffffc020131c:	00010717          	auipc	a4,0x10
ffffffffc0201320:	16b72623          	sw	a1,364(a4) # ffffffffc0211488 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201324:	08d78f63          	beq	a5,a3,ffffffffc02013c2 <default_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc0201328:	fe078713          	addi	a4,a5,-32
ffffffffc020132c:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020132e:	4801                	li	a6,0
ffffffffc0201330:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc0201334:	00e56a63          	bltu	a0,a4,ffffffffc0201348 <default_free_pages+0x94>
    return listelm->next;
ffffffffc0201338:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020133a:	02d70563          	beq	a4,a3,ffffffffc0201364 <default_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020133e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201340:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0201344:	fee57ae3          	bgeu	a0,a4,ffffffffc0201338 <default_free_pages+0x84>
ffffffffc0201348:	00080663          	beqz	a6,ffffffffc0201354 <default_free_pages+0xa0>
ffffffffc020134c:	00010817          	auipc	a6,0x10
ffffffffc0201350:	12b83623          	sd	a1,300(a6) # ffffffffc0211478 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201354:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201356:	e390                	sd	a2,0(a5)
ffffffffc0201358:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc020135a:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc020135c:	f10c                	sd	a1,32(a0)
    if (le != &free_list) {
ffffffffc020135e:	02d59163          	bne	a1,a3,ffffffffc0201380 <default_free_pages+0xcc>
ffffffffc0201362:	a091                	j	ffffffffc02013a6 <default_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc0201364:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201366:	f514                	sd	a3,40(a0)
ffffffffc0201368:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020136a:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc020136c:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020136e:	00d70563          	beq	a4,a3,ffffffffc0201378 <default_free_pages+0xc4>
ffffffffc0201372:	4805                	li	a6,1
ffffffffc0201374:	87ba                	mv	a5,a4
ffffffffc0201376:	b7e9                	j	ffffffffc0201340 <default_free_pages+0x8c>
ffffffffc0201378:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc020137a:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc020137c:	02d78163          	beq	a5,a3,ffffffffc020139e <default_free_pages+0xea>
        if (p + p->property == base) {
ffffffffc0201380:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc0201384:	fe058613          	addi	a2,a1,-32
        if (p + p->property == base) {
ffffffffc0201388:	02081713          	slli	a4,a6,0x20
ffffffffc020138c:	9301                	srli	a4,a4,0x20
ffffffffc020138e:	00371793          	slli	a5,a4,0x3
ffffffffc0201392:	97ba                	add	a5,a5,a4
ffffffffc0201394:	078e                	slli	a5,a5,0x3
ffffffffc0201396:	97b2                	add	a5,a5,a2
ffffffffc0201398:	02f50e63          	beq	a0,a5,ffffffffc02013d4 <default_free_pages+0x120>
ffffffffc020139c:	751c                	ld	a5,40(a0)
    if (le != &free_list) {
ffffffffc020139e:	fe078713          	addi	a4,a5,-32
ffffffffc02013a2:	00d78d63          	beq	a5,a3,ffffffffc02013bc <default_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc02013a6:	4d0c                	lw	a1,24(a0)
ffffffffc02013a8:	02059613          	slli	a2,a1,0x20
ffffffffc02013ac:	9201                	srli	a2,a2,0x20
ffffffffc02013ae:	00361693          	slli	a3,a2,0x3
ffffffffc02013b2:	96b2                	add	a3,a3,a2
ffffffffc02013b4:	068e                	slli	a3,a3,0x3
ffffffffc02013b6:	96aa                	add	a3,a3,a0
ffffffffc02013b8:	04d70063          	beq	a4,a3,ffffffffc02013f8 <default_free_pages+0x144>
}
ffffffffc02013bc:	60a2                	ld	ra,8(sp)
ffffffffc02013be:	0141                	addi	sp,sp,16
ffffffffc02013c0:	8082                	ret
ffffffffc02013c2:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02013c4:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc02013c8:	e398                	sd	a4,0(a5)
ffffffffc02013ca:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02013cc:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02013ce:	f11c                	sd	a5,32(a0)
}
ffffffffc02013d0:	0141                	addi	sp,sp,16
ffffffffc02013d2:	8082                	ret
            p->property += base->property;
ffffffffc02013d4:	4d1c                	lw	a5,24(a0)
ffffffffc02013d6:	0107883b          	addw	a6,a5,a6
ffffffffc02013da:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02013de:	57f5                	li	a5,-3
ffffffffc02013e0:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02013e4:	02053803          	ld	a6,32(a0)
ffffffffc02013e8:	7518                	ld	a4,40(a0)
            base = p;
ffffffffc02013ea:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02013ec:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc02013f0:	659c                	ld	a5,8(a1)
ffffffffc02013f2:	01073023          	sd	a6,0(a4)
ffffffffc02013f6:	b765                	j	ffffffffc020139e <default_free_pages+0xea>
            base->property += p->property;
ffffffffc02013f8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02013fc:	fe878693          	addi	a3,a5,-24
ffffffffc0201400:	9db9                	addw	a1,a1,a4
ffffffffc0201402:	cd0c                	sw	a1,24(a0)
ffffffffc0201404:	5775                	li	a4,-3
ffffffffc0201406:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020140a:	6398                	ld	a4,0(a5)
ffffffffc020140c:	679c                	ld	a5,8(a5)
}
ffffffffc020140e:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201410:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201412:	e398                	sd	a4,0(a5)
ffffffffc0201414:	0141                	addi	sp,sp,16
ffffffffc0201416:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201418:	00004697          	auipc	a3,0x4
ffffffffc020141c:	c2868693          	addi	a3,a3,-984 # ffffffffc0205040 <commands+0xbc8>
ffffffffc0201420:	00004617          	auipc	a2,0x4
ffffffffc0201424:	8c860613          	addi	a2,a2,-1848 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0201428:	08300593          	li	a1,131
ffffffffc020142c:	00004517          	auipc	a0,0x4
ffffffffc0201430:	8d450513          	addi	a0,a0,-1836 # ffffffffc0204d00 <commands+0x888>
ffffffffc0201434:	f3dfe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(n > 0);
ffffffffc0201438:	00004697          	auipc	a3,0x4
ffffffffc020143c:	c3068693          	addi	a3,a3,-976 # ffffffffc0205068 <commands+0xbf0>
ffffffffc0201440:	00004617          	auipc	a2,0x4
ffffffffc0201444:	8a860613          	addi	a2,a2,-1880 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0201448:	08000593          	li	a1,128
ffffffffc020144c:	00004517          	auipc	a0,0x4
ffffffffc0201450:	8b450513          	addi	a0,a0,-1868 # ffffffffc0204d00 <commands+0x888>
ffffffffc0201454:	f1dfe0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0201458 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201458:	cd51                	beqz	a0,ffffffffc02014f4 <default_alloc_pages+0x9c>
    if (n > nr_free) {
ffffffffc020145a:	00010597          	auipc	a1,0x10
ffffffffc020145e:	01e58593          	addi	a1,a1,30 # ffffffffc0211478 <free_area>
ffffffffc0201462:	0105a803          	lw	a6,16(a1)
ffffffffc0201466:	862a                	mv	a2,a0
ffffffffc0201468:	02081793          	slli	a5,a6,0x20
ffffffffc020146c:	9381                	srli	a5,a5,0x20
ffffffffc020146e:	00a7ee63          	bltu	a5,a0,ffffffffc020148a <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc0201472:	87ae                	mv	a5,a1
ffffffffc0201474:	a801                	j	ffffffffc0201484 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc0201476:	ff87a703          	lw	a4,-8(a5)
ffffffffc020147a:	02071693          	slli	a3,a4,0x20
ffffffffc020147e:	9281                	srli	a3,a3,0x20
ffffffffc0201480:	00c6f763          	bgeu	a3,a2,ffffffffc020148e <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201484:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201486:	feb798e3          	bne	a5,a1,ffffffffc0201476 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020148a:	4501                	li	a0,0
}
ffffffffc020148c:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc020148e:	fe078513          	addi	a0,a5,-32
    if (page != NULL) {
ffffffffc0201492:	dd6d                	beqz	a0,ffffffffc020148c <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0201494:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201498:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc020149c:	00060e1b          	sext.w	t3,a2
ffffffffc02014a0:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc02014a4:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc02014a8:	02d67b63          	bgeu	a2,a3,ffffffffc02014de <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc02014ac:	00361693          	slli	a3,a2,0x3
ffffffffc02014b0:	96b2                	add	a3,a3,a2
ffffffffc02014b2:	068e                	slli	a3,a3,0x3
ffffffffc02014b4:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc02014b6:	41c7073b          	subw	a4,a4,t3
ffffffffc02014ba:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02014bc:	00868613          	addi	a2,a3,8
ffffffffc02014c0:	4709                	li	a4,2
ffffffffc02014c2:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc02014c6:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc02014ca:	02068613          	addi	a2,a3,32
    prev->next = next->prev = elm;
ffffffffc02014ce:	0105a803          	lw	a6,16(a1)
ffffffffc02014d2:	e310                	sd	a2,0(a4)
ffffffffc02014d4:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc02014d8:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc02014da:	0316b023          	sd	a7,32(a3)
        nr_free -= n;
ffffffffc02014de:	41c8083b          	subw	a6,a6,t3
ffffffffc02014e2:	00010717          	auipc	a4,0x10
ffffffffc02014e6:	fb072323          	sw	a6,-90(a4) # ffffffffc0211488 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02014ea:	5775                	li	a4,-3
ffffffffc02014ec:	17a1                	addi	a5,a5,-24
ffffffffc02014ee:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc02014f2:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02014f4:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02014f6:	00004697          	auipc	a3,0x4
ffffffffc02014fa:	b7268693          	addi	a3,a3,-1166 # ffffffffc0205068 <commands+0xbf0>
ffffffffc02014fe:	00003617          	auipc	a2,0x3
ffffffffc0201502:	7ea60613          	addi	a2,a2,2026 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0201506:	06200593          	li	a1,98
ffffffffc020150a:	00003517          	auipc	a0,0x3
ffffffffc020150e:	7f650513          	addi	a0,a0,2038 # ffffffffc0204d00 <commands+0x888>
default_alloc_pages(size_t n) {
ffffffffc0201512:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201514:	e5dfe0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0201518 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201518:	1141                	addi	sp,sp,-16
ffffffffc020151a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020151c:	c1fd                	beqz	a1,ffffffffc0201602 <default_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc020151e:	00359693          	slli	a3,a1,0x3
ffffffffc0201522:	96ae                	add	a3,a3,a1
ffffffffc0201524:	068e                	slli	a3,a3,0x3
ffffffffc0201526:	96aa                	add	a3,a3,a0
ffffffffc0201528:	02d50463          	beq	a0,a3,ffffffffc0201550 <default_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020152c:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc020152e:	87aa                	mv	a5,a0
ffffffffc0201530:	8b05                	andi	a4,a4,1
ffffffffc0201532:	e709                	bnez	a4,ffffffffc020153c <default_init_memmap+0x24>
ffffffffc0201534:	a07d                	j	ffffffffc02015e2 <default_init_memmap+0xca>
ffffffffc0201536:	6798                	ld	a4,8(a5)
ffffffffc0201538:	8b05                	andi	a4,a4,1
ffffffffc020153a:	c745                	beqz	a4,ffffffffc02015e2 <default_init_memmap+0xca>
        p->flags = p->property = 0;
ffffffffc020153c:	0007ac23          	sw	zero,24(a5)
ffffffffc0201540:	0007b423          	sd	zero,8(a5)
ffffffffc0201544:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201548:	04878793          	addi	a5,a5,72
ffffffffc020154c:	fed795e3          	bne	a5,a3,ffffffffc0201536 <default_init_memmap+0x1e>
    base->property = n;
ffffffffc0201550:	2581                	sext.w	a1,a1
ffffffffc0201552:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201554:	4789                	li	a5,2
ffffffffc0201556:	00850713          	addi	a4,a0,8
ffffffffc020155a:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020155e:	00010697          	auipc	a3,0x10
ffffffffc0201562:	f1a68693          	addi	a3,a3,-230 # ffffffffc0211478 <free_area>
ffffffffc0201566:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201568:	669c                	ld	a5,8(a3)
ffffffffc020156a:	9db9                	addw	a1,a1,a4
ffffffffc020156c:	00010717          	auipc	a4,0x10
ffffffffc0201570:	f0b72e23          	sw	a1,-228(a4) # ffffffffc0211488 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201574:	04d78a63          	beq	a5,a3,ffffffffc02015c8 <default_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc0201578:	fe078713          	addi	a4,a5,-32
ffffffffc020157c:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020157e:	4801                	li	a6,0
ffffffffc0201580:	02050613          	addi	a2,a0,32
            if (base < page) {
ffffffffc0201584:	00e56a63          	bltu	a0,a4,ffffffffc0201598 <default_init_memmap+0x80>
    return listelm->next;
ffffffffc0201588:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020158a:	02d70563          	beq	a4,a3,ffffffffc02015b4 <default_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020158e:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201590:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0201594:	fee57ae3          	bgeu	a0,a4,ffffffffc0201588 <default_init_memmap+0x70>
ffffffffc0201598:	00080663          	beqz	a6,ffffffffc02015a4 <default_init_memmap+0x8c>
ffffffffc020159c:	00010717          	auipc	a4,0x10
ffffffffc02015a0:	ecb73e23          	sd	a1,-292(a4) # ffffffffc0211478 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02015a4:	6398                	ld	a4,0(a5)
}
ffffffffc02015a6:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02015a8:	e390                	sd	a2,0(a5)
ffffffffc02015aa:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02015ac:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02015ae:	f118                	sd	a4,32(a0)
ffffffffc02015b0:	0141                	addi	sp,sp,16
ffffffffc02015b2:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02015b4:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02015b6:	f514                	sd	a3,40(a0)
ffffffffc02015b8:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02015ba:	f11c                	sd	a5,32(a0)
                list_add(le, &(base->page_link));
ffffffffc02015bc:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02015be:	00d70e63          	beq	a4,a3,ffffffffc02015da <default_init_memmap+0xc2>
ffffffffc02015c2:	4805                	li	a6,1
ffffffffc02015c4:	87ba                	mv	a5,a4
ffffffffc02015c6:	b7e9                	j	ffffffffc0201590 <default_init_memmap+0x78>
}
ffffffffc02015c8:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02015ca:	02050713          	addi	a4,a0,32
    prev->next = next->prev = elm;
ffffffffc02015ce:	e398                	sd	a4,0(a5)
ffffffffc02015d0:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc02015d2:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02015d4:	f11c                	sd	a5,32(a0)
}
ffffffffc02015d6:	0141                	addi	sp,sp,16
ffffffffc02015d8:	8082                	ret
ffffffffc02015da:	60a2                	ld	ra,8(sp)
ffffffffc02015dc:	e290                	sd	a2,0(a3)
ffffffffc02015de:	0141                	addi	sp,sp,16
ffffffffc02015e0:	8082                	ret
        assert(PageReserved(p));
ffffffffc02015e2:	00004697          	auipc	a3,0x4
ffffffffc02015e6:	a8e68693          	addi	a3,a3,-1394 # ffffffffc0205070 <commands+0xbf8>
ffffffffc02015ea:	00003617          	auipc	a2,0x3
ffffffffc02015ee:	6fe60613          	addi	a2,a2,1790 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02015f2:	04900593          	li	a1,73
ffffffffc02015f6:	00003517          	auipc	a0,0x3
ffffffffc02015fa:	70a50513          	addi	a0,a0,1802 # ffffffffc0204d00 <commands+0x888>
ffffffffc02015fe:	d73fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(n > 0);
ffffffffc0201602:	00004697          	auipc	a3,0x4
ffffffffc0201606:	a6668693          	addi	a3,a3,-1434 # ffffffffc0205068 <commands+0xbf0>
ffffffffc020160a:	00003617          	auipc	a2,0x3
ffffffffc020160e:	6de60613          	addi	a2,a2,1758 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0201612:	04600593          	li	a1,70
ffffffffc0201616:	00003517          	auipc	a0,0x3
ffffffffc020161a:	6ea50513          	addi	a0,a0,1770 # ffffffffc0204d00 <commands+0x888>
ffffffffc020161e:	d53fe0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0201622 <pa2page.part.4>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0201622:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201624:	00004617          	auipc	a2,0x4
ffffffffc0201628:	b2460613          	addi	a2,a2,-1244 # ffffffffc0205148 <default_pmm_manager+0xc8>
ffffffffc020162c:	06500593          	li	a1,101
ffffffffc0201630:	00004517          	auipc	a0,0x4
ffffffffc0201634:	b3850513          	addi	a0,a0,-1224 # ffffffffc0205168 <default_pmm_manager+0xe8>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0201638:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc020163a:	d37fe0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc020163e <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc020163e:	715d                	addi	sp,sp,-80
ffffffffc0201640:	e0a2                	sd	s0,64(sp)
ffffffffc0201642:	fc26                	sd	s1,56(sp)
ffffffffc0201644:	f84a                	sd	s2,48(sp)
ffffffffc0201646:	f44e                	sd	s3,40(sp)
ffffffffc0201648:	f052                	sd	s4,32(sp)
ffffffffc020164a:	ec56                	sd	s5,24(sp)
ffffffffc020164c:	e486                	sd	ra,72(sp)
ffffffffc020164e:	842a                	mv	s0,a0
ffffffffc0201650:	00010497          	auipc	s1,0x10
ffffffffc0201654:	e4048493          	addi	s1,s1,-448 # ffffffffc0211490 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201658:	4985                	li	s3,1
ffffffffc020165a:	00010a17          	auipc	s4,0x10
ffffffffc020165e:	e0ea0a13          	addi	s4,s4,-498 # ffffffffc0211468 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201662:	0005091b          	sext.w	s2,a0
ffffffffc0201666:	00010a97          	auipc	s5,0x10
ffffffffc020166a:	f22a8a93          	addi	s5,s5,-222 # ffffffffc0211588 <check_mm_struct>
ffffffffc020166e:	a00d                	j	ffffffffc0201690 <alloc_pages+0x52>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0201670:	609c                	ld	a5,0(s1)
ffffffffc0201672:	6f9c                	ld	a5,24(a5)
ffffffffc0201674:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0201676:	4601                	li	a2,0
ffffffffc0201678:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020167a:	ed0d                	bnez	a0,ffffffffc02016b4 <alloc_pages+0x76>
ffffffffc020167c:	0289ec63          	bltu	s3,s0,ffffffffc02016b4 <alloc_pages+0x76>
ffffffffc0201680:	000a2783          	lw	a5,0(s4)
ffffffffc0201684:	2781                	sext.w	a5,a5
ffffffffc0201686:	c79d                	beqz	a5,ffffffffc02016b4 <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201688:	000ab503          	ld	a0,0(s5)
ffffffffc020168c:	013010ef          	jal	ra,ffffffffc0202e9e <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201690:	100027f3          	csrr	a5,sstatus
ffffffffc0201694:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0201696:	8522                	mv	a0,s0
ffffffffc0201698:	dfe1                	beqz	a5,ffffffffc0201670 <alloc_pages+0x32>
        intr_disable();
ffffffffc020169a:	e59fe0ef          	jal	ra,ffffffffc02004f2 <intr_disable>
ffffffffc020169e:	609c                	ld	a5,0(s1)
ffffffffc02016a0:	8522                	mv	a0,s0
ffffffffc02016a2:	6f9c                	ld	a5,24(a5)
ffffffffc02016a4:	9782                	jalr	a5
ffffffffc02016a6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02016a8:	e45fe0ef          	jal	ra,ffffffffc02004ec <intr_enable>
ffffffffc02016ac:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc02016ae:	4601                	li	a2,0
ffffffffc02016b0:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02016b2:	d569                	beqz	a0,ffffffffc020167c <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc02016b4:	60a6                	ld	ra,72(sp)
ffffffffc02016b6:	6406                	ld	s0,64(sp)
ffffffffc02016b8:	74e2                	ld	s1,56(sp)
ffffffffc02016ba:	7942                	ld	s2,48(sp)
ffffffffc02016bc:	79a2                	ld	s3,40(sp)
ffffffffc02016be:	7a02                	ld	s4,32(sp)
ffffffffc02016c0:	6ae2                	ld	s5,24(sp)
ffffffffc02016c2:	6161                	addi	sp,sp,80
ffffffffc02016c4:	8082                	ret

ffffffffc02016c6 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02016c6:	100027f3          	csrr	a5,sstatus
ffffffffc02016ca:	8b89                	andi	a5,a5,2
ffffffffc02016cc:	eb89                	bnez	a5,ffffffffc02016de <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc02016ce:	00010797          	auipc	a5,0x10
ffffffffc02016d2:	dc278793          	addi	a5,a5,-574 # ffffffffc0211490 <pmm_manager>
ffffffffc02016d6:	639c                	ld	a5,0(a5)
ffffffffc02016d8:	0207b303          	ld	t1,32(a5)
ffffffffc02016dc:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc02016de:	1101                	addi	sp,sp,-32
ffffffffc02016e0:	ec06                	sd	ra,24(sp)
ffffffffc02016e2:	e822                	sd	s0,16(sp)
ffffffffc02016e4:	e426                	sd	s1,8(sp)
ffffffffc02016e6:	842a                	mv	s0,a0
ffffffffc02016e8:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc02016ea:	e09fe0ef          	jal	ra,ffffffffc02004f2 <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc02016ee:	00010797          	auipc	a5,0x10
ffffffffc02016f2:	da278793          	addi	a5,a5,-606 # ffffffffc0211490 <pmm_manager>
ffffffffc02016f6:	639c                	ld	a5,0(a5)
ffffffffc02016f8:	85a6                	mv	a1,s1
ffffffffc02016fa:	8522                	mv	a0,s0
ffffffffc02016fc:	739c                	ld	a5,32(a5)
ffffffffc02016fe:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0201700:	6442                	ld	s0,16(sp)
ffffffffc0201702:	60e2                	ld	ra,24(sp)
ffffffffc0201704:	64a2                	ld	s1,8(sp)
ffffffffc0201706:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201708:	de5fe06f          	j	ffffffffc02004ec <intr_enable>

ffffffffc020170c <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020170c:	100027f3          	csrr	a5,sstatus
ffffffffc0201710:	8b89                	andi	a5,a5,2
ffffffffc0201712:	eb89                	bnez	a5,ffffffffc0201724 <nr_free_pages+0x18>
// of current free memory
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201714:	00010797          	auipc	a5,0x10
ffffffffc0201718:	d7c78793          	addi	a5,a5,-644 # ffffffffc0211490 <pmm_manager>
ffffffffc020171c:	639c                	ld	a5,0(a5)
ffffffffc020171e:	0287b303          	ld	t1,40(a5)
ffffffffc0201722:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201724:	1141                	addi	sp,sp,-16
ffffffffc0201726:	e406                	sd	ra,8(sp)
ffffffffc0201728:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc020172a:	dc9fe0ef          	jal	ra,ffffffffc02004f2 <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020172e:	00010797          	auipc	a5,0x10
ffffffffc0201732:	d6278793          	addi	a5,a5,-670 # ffffffffc0211490 <pmm_manager>
ffffffffc0201736:	639c                	ld	a5,0(a5)
ffffffffc0201738:	779c                	ld	a5,40(a5)
ffffffffc020173a:	9782                	jalr	a5
ffffffffc020173c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020173e:	daffe0ef          	jal	ra,ffffffffc02004ec <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201742:	8522                	mv	a0,s0
ffffffffc0201744:	60a2                	ld	ra,8(sp)
ffffffffc0201746:	6402                	ld	s0,0(sp)
ffffffffc0201748:	0141                	addi	sp,sp,16
ffffffffc020174a:	8082                	ret

ffffffffc020174c <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020174c:	715d                	addi	sp,sp,-80
ffffffffc020174e:	fc26                	sd	s1,56(sp)
     *   PTE_W           0x002                   // page table/directory entry
     * flags bit : Writeable
     *   PTE_U           0x004                   // page table/directory entry
     * flags bit : User can access
     */
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201750:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201754:	1ff4f493          	andi	s1,s1,511
ffffffffc0201758:	048e                	slli	s1,s1,0x3
ffffffffc020175a:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc020175c:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc020175e:	f84a                	sd	s2,48(sp)
ffffffffc0201760:	f44e                	sd	s3,40(sp)
ffffffffc0201762:	f052                	sd	s4,32(sp)
ffffffffc0201764:	e486                	sd	ra,72(sp)
ffffffffc0201766:	e0a2                	sd	s0,64(sp)
ffffffffc0201768:	ec56                	sd	s5,24(sp)
ffffffffc020176a:	e85a                	sd	s6,16(sp)
ffffffffc020176c:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc020176e:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201772:	892e                	mv	s2,a1
ffffffffc0201774:	8a32                	mv	s4,a2
ffffffffc0201776:	00010997          	auipc	s3,0x10
ffffffffc020177a:	ce298993          	addi	s3,s3,-798 # ffffffffc0211458 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc020177e:	e3c9                	bnez	a5,ffffffffc0201800 <get_pte+0xb4>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201780:	16060163          	beqz	a2,ffffffffc02018e2 <get_pte+0x196>
ffffffffc0201784:	4505                	li	a0,1
ffffffffc0201786:	eb9ff0ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc020178a:	842a                	mv	s0,a0
ffffffffc020178c:	14050b63          	beqz	a0,ffffffffc02018e2 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201790:	00010b97          	auipc	s7,0x10
ffffffffc0201794:	d18b8b93          	addi	s7,s7,-744 # ffffffffc02114a8 <pages>
ffffffffc0201798:	000bb503          	ld	a0,0(s7)
ffffffffc020179c:	00003797          	auipc	a5,0x3
ffffffffc02017a0:	53478793          	addi	a5,a5,1332 # ffffffffc0204cd0 <commands+0x858>
ffffffffc02017a4:	0007bb03          	ld	s6,0(a5)
ffffffffc02017a8:	40a40533          	sub	a0,s0,a0
ffffffffc02017ac:	850d                	srai	a0,a0,0x3
ffffffffc02017ae:	03650533          	mul	a0,a0,s6
ffffffffc02017b2:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02017b6:	00010997          	auipc	s3,0x10
ffffffffc02017ba:	ca298993          	addi	s3,s3,-862 # ffffffffc0211458 <npage>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02017be:	4785                	li	a5,1
ffffffffc02017c0:	0009b703          	ld	a4,0(s3)
ffffffffc02017c4:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017c6:	9556                	add	a0,a0,s5
ffffffffc02017c8:	00c51793          	slli	a5,a0,0xc
ffffffffc02017cc:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02017ce:	0532                	slli	a0,a0,0xc
ffffffffc02017d0:	16e7f063          	bgeu	a5,a4,ffffffffc0201930 <get_pte+0x1e4>
ffffffffc02017d4:	00010797          	auipc	a5,0x10
ffffffffc02017d8:	cc478793          	addi	a5,a5,-828 # ffffffffc0211498 <va_pa_offset>
ffffffffc02017dc:	639c                	ld	a5,0(a5)
ffffffffc02017de:	6605                	lui	a2,0x1
ffffffffc02017e0:	4581                	li	a1,0
ffffffffc02017e2:	953e                	add	a0,a0,a5
ffffffffc02017e4:	341020ef          	jal	ra,ffffffffc0204324 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02017e8:	000bb683          	ld	a3,0(s7)
ffffffffc02017ec:	40d406b3          	sub	a3,s0,a3
ffffffffc02017f0:	868d                	srai	a3,a3,0x3
ffffffffc02017f2:	036686b3          	mul	a3,a3,s6
ffffffffc02017f6:	96d6                	add	a3,a3,s5

static inline void flush_tlb() { asm volatile("sfence.vma"); }

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02017f8:	06aa                	slli	a3,a3,0xa
ffffffffc02017fa:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02017fe:	e094                	sd	a3,0(s1)
    }
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201800:	77fd                	lui	a5,0xfffff
ffffffffc0201802:	068a                	slli	a3,a3,0x2
ffffffffc0201804:	0009b703          	ld	a4,0(s3)
ffffffffc0201808:	8efd                	and	a3,a3,a5
ffffffffc020180a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020180e:	0ce7fc63          	bgeu	a5,a4,ffffffffc02018e6 <get_pte+0x19a>
ffffffffc0201812:	00010a97          	auipc	s5,0x10
ffffffffc0201816:	c86a8a93          	addi	s5,s5,-890 # ffffffffc0211498 <va_pa_offset>
ffffffffc020181a:	000ab403          	ld	s0,0(s5)
ffffffffc020181e:	01595793          	srli	a5,s2,0x15
ffffffffc0201822:	1ff7f793          	andi	a5,a5,511
ffffffffc0201826:	96a2                	add	a3,a3,s0
ffffffffc0201828:	00379413          	slli	s0,a5,0x3
ffffffffc020182c:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    if (!(*pdep0 & PTE_V)) {
ffffffffc020182e:	6014                	ld	a3,0(s0)
ffffffffc0201830:	0016f793          	andi	a5,a3,1
ffffffffc0201834:	ebbd                	bnez	a5,ffffffffc02018aa <get_pte+0x15e>
    	struct Page *page;
    	if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201836:	0a0a0663          	beqz	s4,ffffffffc02018e2 <get_pte+0x196>
ffffffffc020183a:	4505                	li	a0,1
ffffffffc020183c:	e03ff0ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0201840:	84aa                	mv	s1,a0
ffffffffc0201842:	c145                	beqz	a0,ffffffffc02018e2 <get_pte+0x196>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201844:	00010b97          	auipc	s7,0x10
ffffffffc0201848:	c64b8b93          	addi	s7,s7,-924 # ffffffffc02114a8 <pages>
ffffffffc020184c:	000bb503          	ld	a0,0(s7)
ffffffffc0201850:	00003797          	auipc	a5,0x3
ffffffffc0201854:	48078793          	addi	a5,a5,1152 # ffffffffc0204cd0 <commands+0x858>
ffffffffc0201858:	0007bb03          	ld	s6,0(a5)
ffffffffc020185c:	40a48533          	sub	a0,s1,a0
ffffffffc0201860:	850d                	srai	a0,a0,0x3
ffffffffc0201862:	03650533          	mul	a0,a0,s6
ffffffffc0201866:	00080a37          	lui	s4,0x80
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020186a:	4785                	li	a5,1
    		return NULL;
    	}
    	set_page_ref(page, 1);
    	uintptr_t pa = page2pa(page);
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc020186c:	0009b703          	ld	a4,0(s3)
ffffffffc0201870:	c09c                	sw	a5,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201872:	9552                	add	a0,a0,s4
ffffffffc0201874:	00c51793          	slli	a5,a0,0xc
ffffffffc0201878:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020187a:	0532                	slli	a0,a0,0xc
ffffffffc020187c:	08e7fd63          	bgeu	a5,a4,ffffffffc0201916 <get_pte+0x1ca>
ffffffffc0201880:	000ab783          	ld	a5,0(s5)
ffffffffc0201884:	6605                	lui	a2,0x1
ffffffffc0201886:	4581                	li	a1,0
ffffffffc0201888:	953e                	add	a0,a0,a5
ffffffffc020188a:	29b020ef          	jal	ra,ffffffffc0204324 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020188e:	000bb683          	ld	a3,0(s7)
ffffffffc0201892:	40d486b3          	sub	a3,s1,a3
ffffffffc0201896:	868d                	srai	a3,a3,0x3
ffffffffc0201898:	036686b3          	mul	a3,a3,s6
ffffffffc020189c:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020189e:	06aa                	slli	a3,a3,0xa
ffffffffc02018a0:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);
    	*pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02018a4:	e014                	sd	a3,0(s0)
ffffffffc02018a6:	0009b703          	ld	a4,0(s3)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02018aa:	068a                	slli	a3,a3,0x2
ffffffffc02018ac:	757d                	lui	a0,0xfffff
ffffffffc02018ae:	8ee9                	and	a3,a3,a0
ffffffffc02018b0:	00c6d793          	srli	a5,a3,0xc
ffffffffc02018b4:	04e7f563          	bgeu	a5,a4,ffffffffc02018fe <get_pte+0x1b2>
ffffffffc02018b8:	000ab503          	ld	a0,0(s5)
ffffffffc02018bc:	00c95793          	srli	a5,s2,0xc
ffffffffc02018c0:	1ff7f793          	andi	a5,a5,511
ffffffffc02018c4:	96aa                	add	a3,a3,a0
ffffffffc02018c6:	00379513          	slli	a0,a5,0x3
ffffffffc02018ca:	9536                	add	a0,a0,a3
}
ffffffffc02018cc:	60a6                	ld	ra,72(sp)
ffffffffc02018ce:	6406                	ld	s0,64(sp)
ffffffffc02018d0:	74e2                	ld	s1,56(sp)
ffffffffc02018d2:	7942                	ld	s2,48(sp)
ffffffffc02018d4:	79a2                	ld	s3,40(sp)
ffffffffc02018d6:	7a02                	ld	s4,32(sp)
ffffffffc02018d8:	6ae2                	ld	s5,24(sp)
ffffffffc02018da:	6b42                	ld	s6,16(sp)
ffffffffc02018dc:	6ba2                	ld	s7,8(sp)
ffffffffc02018de:	6161                	addi	sp,sp,80
ffffffffc02018e0:	8082                	ret
            return NULL;
ffffffffc02018e2:	4501                	li	a0,0
ffffffffc02018e4:	b7e5                	j	ffffffffc02018cc <get_pte+0x180>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02018e6:	00003617          	auipc	a2,0x3
ffffffffc02018ea:	7ea60613          	addi	a2,a2,2026 # ffffffffc02050d0 <default_pmm_manager+0x50>
ffffffffc02018ee:	10200593          	li	a1,258
ffffffffc02018f2:	00004517          	auipc	a0,0x4
ffffffffc02018f6:	80650513          	addi	a0,a0,-2042 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc02018fa:	a77fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02018fe:	00003617          	auipc	a2,0x3
ffffffffc0201902:	7d260613          	addi	a2,a2,2002 # ffffffffc02050d0 <default_pmm_manager+0x50>
ffffffffc0201906:	10f00593          	li	a1,271
ffffffffc020190a:	00003517          	auipc	a0,0x3
ffffffffc020190e:	7ee50513          	addi	a0,a0,2030 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc0201912:	a5ffe0ef          	jal	ra,ffffffffc0200370 <__panic>
    	memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201916:	86aa                	mv	a3,a0
ffffffffc0201918:	00003617          	auipc	a2,0x3
ffffffffc020191c:	7b860613          	addi	a2,a2,1976 # ffffffffc02050d0 <default_pmm_manager+0x50>
ffffffffc0201920:	10b00593          	li	a1,267
ffffffffc0201924:	00003517          	auipc	a0,0x3
ffffffffc0201928:	7d450513          	addi	a0,a0,2004 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc020192c:	a45fe0ef          	jal	ra,ffffffffc0200370 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201930:	86aa                	mv	a3,a0
ffffffffc0201932:	00003617          	auipc	a2,0x3
ffffffffc0201936:	79e60613          	addi	a2,a2,1950 # ffffffffc02050d0 <default_pmm_manager+0x50>
ffffffffc020193a:	0ff00593          	li	a1,255
ffffffffc020193e:	00003517          	auipc	a0,0x3
ffffffffc0201942:	7ba50513          	addi	a0,a0,1978 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc0201946:	a2bfe0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc020194a <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020194a:	1141                	addi	sp,sp,-16
ffffffffc020194c:	e022                	sd	s0,0(sp)
ffffffffc020194e:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201950:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0201952:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201954:	df9ff0ef          	jal	ra,ffffffffc020174c <get_pte>
    if (ptep_store != NULL) {
ffffffffc0201958:	c011                	beqz	s0,ffffffffc020195c <get_page+0x12>
        *ptep_store = ptep;
ffffffffc020195a:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020195c:	c511                	beqz	a0,ffffffffc0201968 <get_page+0x1e>
ffffffffc020195e:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0201960:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0201962:	0017f713          	andi	a4,a5,1
ffffffffc0201966:	e709                	bnez	a4,ffffffffc0201970 <get_page+0x26>
}
ffffffffc0201968:	60a2                	ld	ra,8(sp)
ffffffffc020196a:	6402                	ld	s0,0(sp)
ffffffffc020196c:	0141                	addi	sp,sp,16
ffffffffc020196e:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201970:	00010717          	auipc	a4,0x10
ffffffffc0201974:	ae870713          	addi	a4,a4,-1304 # ffffffffc0211458 <npage>
ffffffffc0201978:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc020197a:	078a                	slli	a5,a5,0x2
ffffffffc020197c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020197e:	02e7f363          	bgeu	a5,a4,ffffffffc02019a4 <get_page+0x5a>
    return &pages[PPN(pa) - nbase];
ffffffffc0201982:	fff80537          	lui	a0,0xfff80
ffffffffc0201986:	97aa                	add	a5,a5,a0
ffffffffc0201988:	00010697          	auipc	a3,0x10
ffffffffc020198c:	b2068693          	addi	a3,a3,-1248 # ffffffffc02114a8 <pages>
ffffffffc0201990:	6288                	ld	a0,0(a3)
ffffffffc0201992:	60a2                	ld	ra,8(sp)
ffffffffc0201994:	6402                	ld	s0,0(sp)
ffffffffc0201996:	00379713          	slli	a4,a5,0x3
ffffffffc020199a:	97ba                	add	a5,a5,a4
ffffffffc020199c:	078e                	slli	a5,a5,0x3
ffffffffc020199e:	953e                	add	a0,a0,a5
ffffffffc02019a0:	0141                	addi	sp,sp,16
ffffffffc02019a2:	8082                	ret
ffffffffc02019a4:	c7fff0ef          	jal	ra,ffffffffc0201622 <pa2page.part.4>

ffffffffc02019a8 <page_remove>:
    }
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02019a8:	1141                	addi	sp,sp,-16
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02019aa:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02019ac:	e406                	sd	ra,8(sp)
ffffffffc02019ae:	e022                	sd	s0,0(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02019b0:	d9dff0ef          	jal	ra,ffffffffc020174c <get_pte>
    if (ptep != NULL) {
ffffffffc02019b4:	c511                	beqz	a0,ffffffffc02019c0 <page_remove+0x18>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02019b6:	611c                	ld	a5,0(a0)
ffffffffc02019b8:	842a                	mv	s0,a0
ffffffffc02019ba:	0017f713          	andi	a4,a5,1
ffffffffc02019be:	e709                	bnez	a4,ffffffffc02019c8 <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc02019c0:	60a2                	ld	ra,8(sp)
ffffffffc02019c2:	6402                	ld	s0,0(sp)
ffffffffc02019c4:	0141                	addi	sp,sp,16
ffffffffc02019c6:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02019c8:	00010717          	auipc	a4,0x10
ffffffffc02019cc:	a9070713          	addi	a4,a4,-1392 # ffffffffc0211458 <npage>
ffffffffc02019d0:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02019d2:	078a                	slli	a5,a5,0x2
ffffffffc02019d4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02019d6:	04e7f063          	bgeu	a5,a4,ffffffffc0201a16 <page_remove+0x6e>
    return &pages[PPN(pa) - nbase];
ffffffffc02019da:	fff80737          	lui	a4,0xfff80
ffffffffc02019de:	97ba                	add	a5,a5,a4
ffffffffc02019e0:	00010717          	auipc	a4,0x10
ffffffffc02019e4:	ac870713          	addi	a4,a4,-1336 # ffffffffc02114a8 <pages>
ffffffffc02019e8:	6308                	ld	a0,0(a4)
ffffffffc02019ea:	00379713          	slli	a4,a5,0x3
ffffffffc02019ee:	97ba                	add	a5,a5,a4
ffffffffc02019f0:	078e                	slli	a5,a5,0x3
ffffffffc02019f2:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc02019f4:	411c                	lw	a5,0(a0)
ffffffffc02019f6:	fff7871b          	addiw	a4,a5,-1
ffffffffc02019fa:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02019fc:	cb09                	beqz	a4,ffffffffc0201a0e <page_remove+0x66>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc02019fe:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a02:	12000073          	sfence.vma
}
ffffffffc0201a06:	60a2                	ld	ra,8(sp)
ffffffffc0201a08:	6402                	ld	s0,0(sp)
ffffffffc0201a0a:	0141                	addi	sp,sp,16
ffffffffc0201a0c:	8082                	ret
            free_page(page);
ffffffffc0201a0e:	4585                	li	a1,1
ffffffffc0201a10:	cb7ff0ef          	jal	ra,ffffffffc02016c6 <free_pages>
ffffffffc0201a14:	b7ed                	j	ffffffffc02019fe <page_remove+0x56>
ffffffffc0201a16:	c0dff0ef          	jal	ra,ffffffffc0201622 <pa2page.part.4>

ffffffffc0201a1a <page_insert>:
//  page:  the Page which need to map
//  la:    the linear address need to map
//  perm:  the permission of this Page which is setted in related pte
// return value: always 0
// note: PT is changed, so the TLB need to be invalidate
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a1a:	7179                	addi	sp,sp,-48
ffffffffc0201a1c:	87b2                	mv	a5,a2
ffffffffc0201a1e:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a20:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a22:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a24:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201a26:	ec26                	sd	s1,24(sp)
ffffffffc0201a28:	f406                	sd	ra,40(sp)
ffffffffc0201a2a:	e84a                	sd	s2,16(sp)
ffffffffc0201a2c:	e44e                	sd	s3,8(sp)
ffffffffc0201a2e:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201a30:	d1dff0ef          	jal	ra,ffffffffc020174c <get_pte>
    if (ptep == NULL) {
ffffffffc0201a34:	c945                	beqz	a0,ffffffffc0201ae4 <page_insert+0xca>
    page->ref += 1;
ffffffffc0201a36:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    page_ref_inc(page);
    if (*ptep & PTE_V) {
ffffffffc0201a38:	611c                	ld	a5,0(a0)
ffffffffc0201a3a:	892a                	mv	s2,a0
ffffffffc0201a3c:	0016871b          	addiw	a4,a3,1
ffffffffc0201a40:	c018                	sw	a4,0(s0)
ffffffffc0201a42:	0017f713          	andi	a4,a5,1
ffffffffc0201a46:	e339                	bnez	a4,ffffffffc0201a8c <page_insert+0x72>
ffffffffc0201a48:	00010797          	auipc	a5,0x10
ffffffffc0201a4c:	a6078793          	addi	a5,a5,-1440 # ffffffffc02114a8 <pages>
ffffffffc0201a50:	639c                	ld	a5,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201a52:	00003717          	auipc	a4,0x3
ffffffffc0201a56:	27e70713          	addi	a4,a4,638 # ffffffffc0204cd0 <commands+0x858>
ffffffffc0201a5a:	40f407b3          	sub	a5,s0,a5
ffffffffc0201a5e:	6300                	ld	s0,0(a4)
ffffffffc0201a60:	878d                	srai	a5,a5,0x3
ffffffffc0201a62:	000806b7          	lui	a3,0x80
ffffffffc0201a66:	028787b3          	mul	a5,a5,s0
ffffffffc0201a6a:	97b6                	add	a5,a5,a3
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201a6c:	07aa                	slli	a5,a5,0xa
ffffffffc0201a6e:	8fc5                	or	a5,a5,s1
ffffffffc0201a70:	0017e793          	ori	a5,a5,1
            page_ref_dec(page);
        } else {
            page_remove_pte(pgdir, la, ptep);
        }
    }
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201a74:	00f93023          	sd	a5,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a78:	12000073          	sfence.vma
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0201a7c:	4501                	li	a0,0
}
ffffffffc0201a7e:	70a2                	ld	ra,40(sp)
ffffffffc0201a80:	7402                	ld	s0,32(sp)
ffffffffc0201a82:	64e2                	ld	s1,24(sp)
ffffffffc0201a84:	6942                	ld	s2,16(sp)
ffffffffc0201a86:	69a2                	ld	s3,8(sp)
ffffffffc0201a88:	6145                	addi	sp,sp,48
ffffffffc0201a8a:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc0201a8c:	00010717          	auipc	a4,0x10
ffffffffc0201a90:	9cc70713          	addi	a4,a4,-1588 # ffffffffc0211458 <npage>
ffffffffc0201a94:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201a96:	00279513          	slli	a0,a5,0x2
ffffffffc0201a9a:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a9c:	04e57663          	bgeu	a0,a4,ffffffffc0201ae8 <page_insert+0xce>
    return &pages[PPN(pa) - nbase];
ffffffffc0201aa0:	fff807b7          	lui	a5,0xfff80
ffffffffc0201aa4:	953e                	add	a0,a0,a5
ffffffffc0201aa6:	00010997          	auipc	s3,0x10
ffffffffc0201aaa:	a0298993          	addi	s3,s3,-1534 # ffffffffc02114a8 <pages>
ffffffffc0201aae:	0009b783          	ld	a5,0(s3)
ffffffffc0201ab2:	00351713          	slli	a4,a0,0x3
ffffffffc0201ab6:	953a                	add	a0,a0,a4
ffffffffc0201ab8:	050e                	slli	a0,a0,0x3
ffffffffc0201aba:	953e                	add	a0,a0,a5
        if (p == page) {
ffffffffc0201abc:	00a40e63          	beq	s0,a0,ffffffffc0201ad8 <page_insert+0xbe>
    page->ref -= 1;
ffffffffc0201ac0:	411c                	lw	a5,0(a0)
ffffffffc0201ac2:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201ac6:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0201ac8:	cb11                	beqz	a4,ffffffffc0201adc <page_insert+0xc2>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0201aca:	00093023          	sd	zero,0(s2)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201ace:	12000073          	sfence.vma
ffffffffc0201ad2:	0009b783          	ld	a5,0(s3)
ffffffffc0201ad6:	bfb5                	j	ffffffffc0201a52 <page_insert+0x38>
    page->ref -= 1;
ffffffffc0201ad8:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201ada:	bfa5                	j	ffffffffc0201a52 <page_insert+0x38>
            free_page(page);
ffffffffc0201adc:	4585                	li	a1,1
ffffffffc0201ade:	be9ff0ef          	jal	ra,ffffffffc02016c6 <free_pages>
ffffffffc0201ae2:	b7e5                	j	ffffffffc0201aca <page_insert+0xb0>
        return -E_NO_MEM;
ffffffffc0201ae4:	5571                	li	a0,-4
ffffffffc0201ae6:	bf61                	j	ffffffffc0201a7e <page_insert+0x64>
ffffffffc0201ae8:	b3bff0ef          	jal	ra,ffffffffc0201622 <pa2page.part.4>

ffffffffc0201aec <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201aec:	00003797          	auipc	a5,0x3
ffffffffc0201af0:	59478793          	addi	a5,a5,1428 # ffffffffc0205080 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201af4:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201af6:	711d                	addi	sp,sp,-96
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201af8:	00003517          	auipc	a0,0x3
ffffffffc0201afc:	69850513          	addi	a0,a0,1688 # ffffffffc0205190 <default_pmm_manager+0x110>
void pmm_init(void) {
ffffffffc0201b00:	ec86                	sd	ra,88(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201b02:	00010717          	auipc	a4,0x10
ffffffffc0201b06:	98f73723          	sd	a5,-1650(a4) # ffffffffc0211490 <pmm_manager>
void pmm_init(void) {
ffffffffc0201b0a:	e8a2                	sd	s0,80(sp)
ffffffffc0201b0c:	e4a6                	sd	s1,72(sp)
ffffffffc0201b0e:	e0ca                	sd	s2,64(sp)
ffffffffc0201b10:	fc4e                	sd	s3,56(sp)
ffffffffc0201b12:	f852                	sd	s4,48(sp)
ffffffffc0201b14:	f456                	sd	s5,40(sp)
ffffffffc0201b16:	f05a                	sd	s6,32(sp)
ffffffffc0201b18:	ec5e                	sd	s7,24(sp)
ffffffffc0201b1a:	e862                	sd	s8,16(sp)
ffffffffc0201b1c:	e466                	sd	s9,8(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201b1e:	00010417          	auipc	s0,0x10
ffffffffc0201b22:	97240413          	addi	s0,s0,-1678 # ffffffffc0211490 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201b26:	d98fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    pmm_manager->init();
ffffffffc0201b2a:	601c                	ld	a5,0(s0)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b2c:	49c5                	li	s3,17
ffffffffc0201b2e:	40100a13          	li	s4,1025
    pmm_manager->init();
ffffffffc0201b32:	679c                	ld	a5,8(a5)
ffffffffc0201b34:	00010497          	auipc	s1,0x10
ffffffffc0201b38:	92448493          	addi	s1,s1,-1756 # ffffffffc0211458 <npage>
ffffffffc0201b3c:	00010917          	auipc	s2,0x10
ffffffffc0201b40:	96c90913          	addi	s2,s2,-1684 # ffffffffc02114a8 <pages>
ffffffffc0201b44:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b46:	57f5                	li	a5,-3
ffffffffc0201b48:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b4a:	07e006b7          	lui	a3,0x7e00
ffffffffc0201b4e:	01b99613          	slli	a2,s3,0x1b
ffffffffc0201b52:	015a1593          	slli	a1,s4,0x15
ffffffffc0201b56:	00003517          	auipc	a0,0x3
ffffffffc0201b5a:	65250513          	addi	a0,a0,1618 # ffffffffc02051a8 <default_pmm_manager+0x128>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201b5e:	00010717          	auipc	a4,0x10
ffffffffc0201b62:	92f73d23          	sd	a5,-1734(a4) # ffffffffc0211498 <va_pa_offset>
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201b66:	d58fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201b6a:	00003517          	auipc	a0,0x3
ffffffffc0201b6e:	66e50513          	addi	a0,a0,1646 # ffffffffc02051d8 <default_pmm_manager+0x158>
ffffffffc0201b72:	d4cfe0ef          	jal	ra,ffffffffc02000be <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201b76:	01b99693          	slli	a3,s3,0x1b
ffffffffc0201b7a:	16fd                	addi	a3,a3,-1
ffffffffc0201b7c:	015a1613          	slli	a2,s4,0x15
ffffffffc0201b80:	07e005b7          	lui	a1,0x7e00
ffffffffc0201b84:	00003517          	auipc	a0,0x3
ffffffffc0201b88:	66c50513          	addi	a0,a0,1644 # ffffffffc02051f0 <default_pmm_manager+0x170>
ffffffffc0201b8c:	d32fe0ef          	jal	ra,ffffffffc02000be <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201b90:	777d                	lui	a4,0xfffff
ffffffffc0201b92:	00011797          	auipc	a5,0x11
ffffffffc0201b96:	9fd78793          	addi	a5,a5,-1539 # ffffffffc021258f <end+0xfff>
ffffffffc0201b9a:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0201b9c:	00088737          	lui	a4,0x88
ffffffffc0201ba0:	00010697          	auipc	a3,0x10
ffffffffc0201ba4:	8ae6bc23          	sd	a4,-1864(a3) # ffffffffc0211458 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201ba8:	00010717          	auipc	a4,0x10
ffffffffc0201bac:	90f73023          	sd	a5,-1792(a4) # ffffffffc02114a8 <pages>
ffffffffc0201bb0:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201bb2:	4701                	li	a4,0
ffffffffc0201bb4:	4585                	li	a1,1
ffffffffc0201bb6:	fff80637          	lui	a2,0xfff80
ffffffffc0201bba:	a019                	j	ffffffffc0201bc0 <pmm_init+0xd4>
ffffffffc0201bbc:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc0201bc0:	97b6                	add	a5,a5,a3
ffffffffc0201bc2:	07a1                	addi	a5,a5,8
ffffffffc0201bc4:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201bc8:	609c                	ld	a5,0(s1)
ffffffffc0201bca:	0705                	addi	a4,a4,1
ffffffffc0201bcc:	04868693          	addi	a3,a3,72
ffffffffc0201bd0:	00c78533          	add	a0,a5,a2
ffffffffc0201bd4:	fea764e3          	bltu	a4,a0,ffffffffc0201bbc <pmm_init+0xd0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201bd8:	00093503          	ld	a0,0(s2)
ffffffffc0201bdc:	00379693          	slli	a3,a5,0x3
ffffffffc0201be0:	96be                	add	a3,a3,a5
ffffffffc0201be2:	fdc00737          	lui	a4,0xfdc00
ffffffffc0201be6:	972a                	add	a4,a4,a0
ffffffffc0201be8:	068e                	slli	a3,a3,0x3
ffffffffc0201bea:	96ba                	add	a3,a3,a4
ffffffffc0201bec:	c0200737          	lui	a4,0xc0200
ffffffffc0201bf0:	58e6e863          	bltu	a3,a4,ffffffffc0202180 <pmm_init+0x694>
ffffffffc0201bf4:	00010997          	auipc	s3,0x10
ffffffffc0201bf8:	8a498993          	addi	s3,s3,-1884 # ffffffffc0211498 <va_pa_offset>
ffffffffc0201bfc:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0201c00:	45c5                	li	a1,17
ffffffffc0201c02:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201c04:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201c06:	44b6ed63          	bltu	a3,a1,ffffffffc0202060 <pmm_init+0x574>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201c0a:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c0c:	00010417          	auipc	s0,0x10
ffffffffc0201c10:	84440413          	addi	s0,s0,-1980 # ffffffffc0211450 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201c14:	7b9c                	ld	a5,48(a5)
ffffffffc0201c16:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201c18:	00003517          	auipc	a0,0x3
ffffffffc0201c1c:	62850513          	addi	a0,a0,1576 # ffffffffc0205240 <default_pmm_manager+0x1c0>
ffffffffc0201c20:	c9efe0ef          	jal	ra,ffffffffc02000be <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201c24:	00007697          	auipc	a3,0x7
ffffffffc0201c28:	3dc68693          	addi	a3,a3,988 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201c2c:	00010797          	auipc	a5,0x10
ffffffffc0201c30:	82d7b223          	sd	a3,-2012(a5) # ffffffffc0211450 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201c34:	c02007b7          	lui	a5,0xc0200
ffffffffc0201c38:	0ef6eae3          	bltu	a3,a5,ffffffffc020252c <pmm_init+0xa40>
ffffffffc0201c3c:	0009b783          	ld	a5,0(s3)
ffffffffc0201c40:	8e9d                	sub	a3,a3,a5
ffffffffc0201c42:	00010797          	auipc	a5,0x10
ffffffffc0201c46:	84d7bf23          	sd	a3,-1954(a5) # ffffffffc02114a0 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc0201c4a:	ac3ff0ef          	jal	ra,ffffffffc020170c <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201c4e:	6098                	ld	a4,0(s1)
ffffffffc0201c50:	c80007b7          	lui	a5,0xc8000
ffffffffc0201c54:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0201c56:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201c58:	0ae7eae3          	bltu	a5,a4,ffffffffc020250c <pmm_init+0xa20>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201c5c:	6008                	ld	a0,0(s0)
ffffffffc0201c5e:	4c050163          	beqz	a0,ffffffffc0202120 <pmm_init+0x634>
ffffffffc0201c62:	03451793          	slli	a5,a0,0x34
ffffffffc0201c66:	4a079d63          	bnez	a5,ffffffffc0202120 <pmm_init+0x634>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201c6a:	4601                	li	a2,0
ffffffffc0201c6c:	4581                	li	a1,0
ffffffffc0201c6e:	cddff0ef          	jal	ra,ffffffffc020194a <get_page>
ffffffffc0201c72:	4c051763          	bnez	a0,ffffffffc0202140 <pmm_init+0x654>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201c76:	4505                	li	a0,1
ffffffffc0201c78:	9c7ff0ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0201c7c:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201c7e:	6008                	ld	a0,0(s0)
ffffffffc0201c80:	4681                	li	a3,0
ffffffffc0201c82:	4601                	li	a2,0
ffffffffc0201c84:	85d6                	mv	a1,s5
ffffffffc0201c86:	d95ff0ef          	jal	ra,ffffffffc0201a1a <page_insert>
ffffffffc0201c8a:	52051763          	bnez	a0,ffffffffc02021b8 <pmm_init+0x6cc>
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0201c8e:	6008                	ld	a0,0(s0)
ffffffffc0201c90:	4601                	li	a2,0
ffffffffc0201c92:	4581                	li	a1,0
ffffffffc0201c94:	ab9ff0ef          	jal	ra,ffffffffc020174c <get_pte>
ffffffffc0201c98:	50050063          	beqz	a0,ffffffffc0202198 <pmm_init+0x6ac>
    assert(pte2page(*ptep) == p1);
ffffffffc0201c9c:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201c9e:	0017f713          	andi	a4,a5,1
ffffffffc0201ca2:	46070363          	beqz	a4,ffffffffc0202108 <pmm_init+0x61c>
    if (PPN(pa) >= npage) {
ffffffffc0201ca6:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201ca8:	078a                	slli	a5,a5,0x2
ffffffffc0201caa:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201cac:	44c7f063          	bgeu	a5,a2,ffffffffc02020ec <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc0201cb0:	fff80737          	lui	a4,0xfff80
ffffffffc0201cb4:	97ba                	add	a5,a5,a4
ffffffffc0201cb6:	00379713          	slli	a4,a5,0x3
ffffffffc0201cba:	00093683          	ld	a3,0(s2)
ffffffffc0201cbe:	97ba                	add	a5,a5,a4
ffffffffc0201cc0:	078e                	slli	a5,a5,0x3
ffffffffc0201cc2:	97b6                	add	a5,a5,a3
ffffffffc0201cc4:	5efa9463          	bne	s5,a5,ffffffffc02022ac <pmm_init+0x7c0>
    assert(page_ref(p1) == 1);
ffffffffc0201cc8:	000aab83          	lw	s7,0(s5)
ffffffffc0201ccc:	4785                	li	a5,1
ffffffffc0201cce:	5afb9f63          	bne	s7,a5,ffffffffc020228c <pmm_init+0x7a0>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201cd2:	6008                	ld	a0,0(s0)
ffffffffc0201cd4:	76fd                	lui	a3,0xfffff
ffffffffc0201cd6:	611c                	ld	a5,0(a0)
ffffffffc0201cd8:	078a                	slli	a5,a5,0x2
ffffffffc0201cda:	8ff5                	and	a5,a5,a3
ffffffffc0201cdc:	00c7d713          	srli	a4,a5,0xc
ffffffffc0201ce0:	58c77963          	bgeu	a4,a2,ffffffffc0202272 <pmm_init+0x786>
ffffffffc0201ce4:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201ce8:	97e2                	add	a5,a5,s8
ffffffffc0201cea:	0007bb03          	ld	s6,0(a5) # ffffffffc8000000 <end+0x7deea70>
ffffffffc0201cee:	0b0a                	slli	s6,s6,0x2
ffffffffc0201cf0:	00db7b33          	and	s6,s6,a3
ffffffffc0201cf4:	00cb5793          	srli	a5,s6,0xc
ffffffffc0201cf8:	56c7f063          	bgeu	a5,a2,ffffffffc0202258 <pmm_init+0x76c>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201cfc:	4601                	li	a2,0
ffffffffc0201cfe:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d00:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d02:	a4bff0ef          	jal	ra,ffffffffc020174c <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201d06:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201d08:	53651863          	bne	a0,s6,ffffffffc0202238 <pmm_init+0x74c>

    p2 = alloc_page();
ffffffffc0201d0c:	4505                	li	a0,1
ffffffffc0201d0e:	931ff0ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0201d12:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201d14:	6008                	ld	a0,0(s0)
ffffffffc0201d16:	46d1                	li	a3,20
ffffffffc0201d18:	6605                	lui	a2,0x1
ffffffffc0201d1a:	85da                	mv	a1,s6
ffffffffc0201d1c:	cffff0ef          	jal	ra,ffffffffc0201a1a <page_insert>
ffffffffc0201d20:	4e051c63          	bnez	a0,ffffffffc0202218 <pmm_init+0x72c>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d24:	6008                	ld	a0,0(s0)
ffffffffc0201d26:	4601                	li	a2,0
ffffffffc0201d28:	6585                	lui	a1,0x1
ffffffffc0201d2a:	a23ff0ef          	jal	ra,ffffffffc020174c <get_pte>
ffffffffc0201d2e:	4c050563          	beqz	a0,ffffffffc02021f8 <pmm_init+0x70c>
    assert(*ptep & PTE_U);
ffffffffc0201d32:	611c                	ld	a5,0(a0)
ffffffffc0201d34:	0107f713          	andi	a4,a5,16
ffffffffc0201d38:	4a070063          	beqz	a4,ffffffffc02021d8 <pmm_init+0x6ec>
    assert(*ptep & PTE_W);
ffffffffc0201d3c:	8b91                	andi	a5,a5,4
ffffffffc0201d3e:	66078763          	beqz	a5,ffffffffc02023ac <pmm_init+0x8c0>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201d42:	6008                	ld	a0,0(s0)
ffffffffc0201d44:	611c                	ld	a5,0(a0)
ffffffffc0201d46:	8bc1                	andi	a5,a5,16
ffffffffc0201d48:	64078263          	beqz	a5,ffffffffc020238c <pmm_init+0x8a0>
    assert(page_ref(p2) == 1);
ffffffffc0201d4c:	000b2783          	lw	a5,0(s6)
ffffffffc0201d50:	61779e63          	bne	a5,s7,ffffffffc020236c <pmm_init+0x880>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201d54:	4681                	li	a3,0
ffffffffc0201d56:	6605                	lui	a2,0x1
ffffffffc0201d58:	85d6                	mv	a1,s5
ffffffffc0201d5a:	cc1ff0ef          	jal	ra,ffffffffc0201a1a <page_insert>
ffffffffc0201d5e:	5e051763          	bnez	a0,ffffffffc020234c <pmm_init+0x860>
    assert(page_ref(p1) == 2);
ffffffffc0201d62:	000aa703          	lw	a4,0(s5)
ffffffffc0201d66:	4789                	li	a5,2
ffffffffc0201d68:	5cf71263          	bne	a4,a5,ffffffffc020232c <pmm_init+0x840>
    assert(page_ref(p2) == 0);
ffffffffc0201d6c:	000b2783          	lw	a5,0(s6)
ffffffffc0201d70:	58079e63          	bnez	a5,ffffffffc020230c <pmm_init+0x820>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0201d74:	6008                	ld	a0,0(s0)
ffffffffc0201d76:	4601                	li	a2,0
ffffffffc0201d78:	6585                	lui	a1,0x1
ffffffffc0201d7a:	9d3ff0ef          	jal	ra,ffffffffc020174c <get_pte>
ffffffffc0201d7e:	56050763          	beqz	a0,ffffffffc02022ec <pmm_init+0x800>
    assert(pte2page(*ptep) == p1);
ffffffffc0201d82:	6114                	ld	a3,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201d84:	0016f793          	andi	a5,a3,1
ffffffffc0201d88:	38078063          	beqz	a5,ffffffffc0202108 <pmm_init+0x61c>
    if (PPN(pa) >= npage) {
ffffffffc0201d8c:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201d8e:	00269793          	slli	a5,a3,0x2
ffffffffc0201d92:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201d94:	34e7fc63          	bgeu	a5,a4,ffffffffc02020ec <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d98:	fff80737          	lui	a4,0xfff80
ffffffffc0201d9c:	97ba                	add	a5,a5,a4
ffffffffc0201d9e:	00379713          	slli	a4,a5,0x3
ffffffffc0201da2:	00093603          	ld	a2,0(s2)
ffffffffc0201da6:	97ba                	add	a5,a5,a4
ffffffffc0201da8:	078e                	slli	a5,a5,0x3
ffffffffc0201daa:	97b2                	add	a5,a5,a2
ffffffffc0201dac:	52fa9063          	bne	s5,a5,ffffffffc02022cc <pmm_init+0x7e0>
    assert((*ptep & PTE_U) == 0);
ffffffffc0201db0:	8ac1                	andi	a3,a3,16
ffffffffc0201db2:	6e069d63          	bnez	a3,ffffffffc02024ac <pmm_init+0x9c0>

    page_remove(boot_pgdir, 0x0);
ffffffffc0201db6:	6008                	ld	a0,0(s0)
ffffffffc0201db8:	4581                	li	a1,0
ffffffffc0201dba:	befff0ef          	jal	ra,ffffffffc02019a8 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0201dbe:	000aa703          	lw	a4,0(s5)
ffffffffc0201dc2:	4785                	li	a5,1
ffffffffc0201dc4:	6cf71463          	bne	a4,a5,ffffffffc020248c <pmm_init+0x9a0>
    assert(page_ref(p2) == 0);
ffffffffc0201dc8:	000b2783          	lw	a5,0(s6)
ffffffffc0201dcc:	6a079063          	bnez	a5,ffffffffc020246c <pmm_init+0x980>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201dd0:	6008                	ld	a0,0(s0)
ffffffffc0201dd2:	6585                	lui	a1,0x1
ffffffffc0201dd4:	bd5ff0ef          	jal	ra,ffffffffc02019a8 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0201dd8:	000aa783          	lw	a5,0(s5)
ffffffffc0201ddc:	66079863          	bnez	a5,ffffffffc020244c <pmm_init+0x960>
    assert(page_ref(p2) == 0);
ffffffffc0201de0:	000b2783          	lw	a5,0(s6)
ffffffffc0201de4:	70079463          	bnez	a5,ffffffffc02024ec <pmm_init+0xa00>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201de8:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201dec:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201dee:	000b3783          	ld	a5,0(s6)
ffffffffc0201df2:	078a                	slli	a5,a5,0x2
ffffffffc0201df4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201df6:	2ec7fb63          	bgeu	a5,a2,ffffffffc02020ec <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc0201dfa:	fff80737          	lui	a4,0xfff80
ffffffffc0201dfe:	973e                	add	a4,a4,a5
ffffffffc0201e00:	00371793          	slli	a5,a4,0x3
ffffffffc0201e04:	00093803          	ld	a6,0(s2)
ffffffffc0201e08:	97ba                	add	a5,a5,a4
ffffffffc0201e0a:	078e                	slli	a5,a5,0x3
ffffffffc0201e0c:	00f80733          	add	a4,a6,a5
ffffffffc0201e10:	4314                	lw	a3,0(a4)
ffffffffc0201e12:	4705                	li	a4,1
ffffffffc0201e14:	6ae69c63          	bne	a3,a4,ffffffffc02024cc <pmm_init+0x9e0>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201e18:	00003a97          	auipc	s5,0x3
ffffffffc0201e1c:	eb8a8a93          	addi	s5,s5,-328 # ffffffffc0204cd0 <commands+0x858>
ffffffffc0201e20:	000ab703          	ld	a4,0(s5)
ffffffffc0201e24:	4037d693          	srai	a3,a5,0x3
ffffffffc0201e28:	00080bb7          	lui	s7,0x80
ffffffffc0201e2c:	02e686b3          	mul	a3,a3,a4
ffffffffc0201e30:	96de                	add	a3,a3,s7
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e32:	00c69793          	slli	a5,a3,0xc
ffffffffc0201e36:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e38:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201e3a:	2ac7fb63          	bgeu	a5,a2,ffffffffc02020f0 <pmm_init+0x604>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0201e3e:	0009b703          	ld	a4,0(s3)
ffffffffc0201e42:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e44:	629c                	ld	a5,0(a3)
ffffffffc0201e46:	078a                	slli	a5,a5,0x2
ffffffffc0201e48:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e4a:	2ac7f163          	bgeu	a5,a2,ffffffffc02020ec <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e4e:	417787b3          	sub	a5,a5,s7
ffffffffc0201e52:	00379513          	slli	a0,a5,0x3
ffffffffc0201e56:	97aa                	add	a5,a5,a0
ffffffffc0201e58:	00379513          	slli	a0,a5,0x3
ffffffffc0201e5c:	9542                	add	a0,a0,a6
ffffffffc0201e5e:	4585                	li	a1,1
ffffffffc0201e60:	867ff0ef          	jal	ra,ffffffffc02016c6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e64:	000b3503          	ld	a0,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0201e68:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201e6a:	050a                	slli	a0,a0,0x2
ffffffffc0201e6c:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e6e:	26f57f63          	bgeu	a0,a5,ffffffffc02020ec <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e72:	417507b3          	sub	a5,a0,s7
ffffffffc0201e76:	00379513          	slli	a0,a5,0x3
ffffffffc0201e7a:	00093703          	ld	a4,0(s2)
ffffffffc0201e7e:	953e                	add	a0,a0,a5
ffffffffc0201e80:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0201e82:	4585                	li	a1,1
ffffffffc0201e84:	953a                	add	a0,a0,a4
ffffffffc0201e86:	841ff0ef          	jal	ra,ffffffffc02016c6 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0201e8a:	601c                	ld	a5,0(s0)
ffffffffc0201e8c:	0007b023          	sd	zero,0(a5)

    assert(nr_free_store==nr_free_pages());
ffffffffc0201e90:	87dff0ef          	jal	ra,ffffffffc020170c <nr_free_pages>
ffffffffc0201e94:	2caa1663          	bne	s4,a0,ffffffffc0202160 <pmm_init+0x674>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201e98:	00003517          	auipc	a0,0x3
ffffffffc0201e9c:	6b850513          	addi	a0,a0,1720 # ffffffffc0205550 <default_pmm_manager+0x4d0>
ffffffffc0201ea0:	a1efe0ef          	jal	ra,ffffffffc02000be <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0201ea4:	869ff0ef          	jal	ra,ffffffffc020170c <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201ea8:	6098                	ld	a4,0(s1)
ffffffffc0201eaa:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc0201eae:	8b2a                	mv	s6,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201eb0:	00c71693          	slli	a3,a4,0xc
ffffffffc0201eb4:	1cd7fd63          	bgeu	a5,a3,ffffffffc020208e <pmm_init+0x5a2>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201eb8:	83b1                	srli	a5,a5,0xc
ffffffffc0201eba:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201ebc:	c0200a37          	lui	s4,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201ec0:	1ce7f963          	bgeu	a5,a4,ffffffffc0202092 <pmm_init+0x5a6>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201ec4:	7c7d                	lui	s8,0xfffff
ffffffffc0201ec6:	6b85                	lui	s7,0x1
ffffffffc0201ec8:	a029                	j	ffffffffc0201ed2 <pmm_init+0x3e6>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0201eca:	00ca5713          	srli	a4,s4,0xc
ffffffffc0201ece:	1cf77263          	bgeu	a4,a5,ffffffffc0202092 <pmm_init+0x5a6>
ffffffffc0201ed2:	0009b583          	ld	a1,0(s3)
ffffffffc0201ed6:	4601                	li	a2,0
ffffffffc0201ed8:	95d2                	add	a1,a1,s4
ffffffffc0201eda:	873ff0ef          	jal	ra,ffffffffc020174c <get_pte>
ffffffffc0201ede:	1c050763          	beqz	a0,ffffffffc02020ac <pmm_init+0x5c0>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201ee2:	611c                	ld	a5,0(a0)
ffffffffc0201ee4:	078a                	slli	a5,a5,0x2
ffffffffc0201ee6:	0187f7b3          	and	a5,a5,s8
ffffffffc0201eea:	1f479163          	bne	a5,s4,ffffffffc02020cc <pmm_init+0x5e0>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201eee:	609c                	ld	a5,0(s1)
ffffffffc0201ef0:	9a5e                	add	s4,s4,s7
ffffffffc0201ef2:	6008                	ld	a0,0(s0)
ffffffffc0201ef4:	00c79713          	slli	a4,a5,0xc
ffffffffc0201ef8:	fcea69e3          	bltu	s4,a4,ffffffffc0201eca <pmm_init+0x3de>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc0201efc:	611c                	ld	a5,0(a0)
ffffffffc0201efe:	6a079363          	bnez	a5,ffffffffc02025a4 <pmm_init+0xab8>

    struct Page *p;
    p = alloc_page();
ffffffffc0201f02:	4505                	li	a0,1
ffffffffc0201f04:	f3aff0ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc0201f08:	8a2a                	mv	s4,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0201f0a:	6008                	ld	a0,0(s0)
ffffffffc0201f0c:	4699                	li	a3,6
ffffffffc0201f0e:	10000613          	li	a2,256
ffffffffc0201f12:	85d2                	mv	a1,s4
ffffffffc0201f14:	b07ff0ef          	jal	ra,ffffffffc0201a1a <page_insert>
ffffffffc0201f18:	66051663          	bnez	a0,ffffffffc0202584 <pmm_init+0xa98>
    assert(page_ref(p) == 1);
ffffffffc0201f1c:	000a2703          	lw	a4,0(s4) # ffffffffc0200000 <kern_entry>
ffffffffc0201f20:	4785                	li	a5,1
ffffffffc0201f22:	64f71163          	bne	a4,a5,ffffffffc0202564 <pmm_init+0xa78>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0201f26:	6008                	ld	a0,0(s0)
ffffffffc0201f28:	6b85                	lui	s7,0x1
ffffffffc0201f2a:	4699                	li	a3,6
ffffffffc0201f2c:	100b8613          	addi	a2,s7,256 # 1100 <BASE_ADDRESS-0xffffffffc01fef00>
ffffffffc0201f30:	85d2                	mv	a1,s4
ffffffffc0201f32:	ae9ff0ef          	jal	ra,ffffffffc0201a1a <page_insert>
ffffffffc0201f36:	60051763          	bnez	a0,ffffffffc0202544 <pmm_init+0xa58>
    assert(page_ref(p) == 2);
ffffffffc0201f3a:	000a2703          	lw	a4,0(s4)
ffffffffc0201f3e:	4789                	li	a5,2
ffffffffc0201f40:	4ef71663          	bne	a4,a5,ffffffffc020242c <pmm_init+0x940>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0201f44:	00003597          	auipc	a1,0x3
ffffffffc0201f48:	74458593          	addi	a1,a1,1860 # ffffffffc0205688 <default_pmm_manager+0x608>
ffffffffc0201f4c:	10000513          	li	a0,256
ffffffffc0201f50:	37a020ef          	jal	ra,ffffffffc02042ca <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0201f54:	100b8593          	addi	a1,s7,256
ffffffffc0201f58:	10000513          	li	a0,256
ffffffffc0201f5c:	380020ef          	jal	ra,ffffffffc02042dc <strcmp>
ffffffffc0201f60:	4a051663          	bnez	a0,ffffffffc020240c <pmm_init+0x920>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f64:	00093683          	ld	a3,0(s2)
ffffffffc0201f68:	000abc83          	ld	s9,0(s5)
ffffffffc0201f6c:	00080c37          	lui	s8,0x80
ffffffffc0201f70:	40da06b3          	sub	a3,s4,a3
ffffffffc0201f74:	868d                	srai	a3,a3,0x3
ffffffffc0201f76:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f7a:	5afd                	li	s5,-1
ffffffffc0201f7c:	609c                	ld	a5,0(s1)
ffffffffc0201f7e:	00cada93          	srli	s5,s5,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f82:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f84:	0156f733          	and	a4,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0201f88:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f8a:	16f77363          	bgeu	a4,a5,ffffffffc02020f0 <pmm_init+0x604>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201f8e:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201f92:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0201f96:	96be                	add	a3,a3,a5
ffffffffc0201f98:	10068023          	sb	zero,256(a3) # fffffffffffff100 <end+0x3fdedb70>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0201f9c:	2ea020ef          	jal	ra,ffffffffc0204286 <strlen>
ffffffffc0201fa0:	44051663          	bnez	a0,ffffffffc02023ec <pmm_init+0x900>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0201fa4:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0201fa8:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201faa:	000bb783          	ld	a5,0(s7)
ffffffffc0201fae:	078a                	slli	a5,a5,0x2
ffffffffc0201fb0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201fb2:	12e7fd63          	bgeu	a5,a4,ffffffffc02020ec <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc0201fb6:	418787b3          	sub	a5,a5,s8
ffffffffc0201fba:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201fbe:	96be                	add	a3,a3,a5
ffffffffc0201fc0:	039686b3          	mul	a3,a3,s9
ffffffffc0201fc4:	96e2                	add	a3,a3,s8
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fc6:	0156fab3          	and	s5,a3,s5
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fca:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201fcc:	12eaf263          	bgeu	s5,a4,ffffffffc02020f0 <pmm_init+0x604>
ffffffffc0201fd0:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0201fd4:	4585                	li	a1,1
ffffffffc0201fd6:	8552                	mv	a0,s4
ffffffffc0201fd8:	99b6                	add	s3,s3,a3
ffffffffc0201fda:	eecff0ef          	jal	ra,ffffffffc02016c6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fde:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0201fe2:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201fe4:	078a                	slli	a5,a5,0x2
ffffffffc0201fe6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201fe8:	10e7f263          	bgeu	a5,a4,ffffffffc02020ec <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc0201fec:	fff809b7          	lui	s3,0xfff80
ffffffffc0201ff0:	97ce                	add	a5,a5,s3
ffffffffc0201ff2:	00379513          	slli	a0,a5,0x3
ffffffffc0201ff6:	00093703          	ld	a4,0(s2)
ffffffffc0201ffa:	97aa                	add	a5,a5,a0
ffffffffc0201ffc:	00379513          	slli	a0,a5,0x3
    free_page(pde2page(pd0[0]));
ffffffffc0202000:	953a                	add	a0,a0,a4
ffffffffc0202002:	4585                	li	a1,1
ffffffffc0202004:	ec2ff0ef          	jal	ra,ffffffffc02016c6 <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202008:	000bb503          	ld	a0,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc020200c:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020200e:	050a                	slli	a0,a0,0x2
ffffffffc0202010:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202012:	0cf57d63          	bgeu	a0,a5,ffffffffc02020ec <pmm_init+0x600>
    return &pages[PPN(pa) - nbase];
ffffffffc0202016:	013507b3          	add	a5,a0,s3
ffffffffc020201a:	00379513          	slli	a0,a5,0x3
ffffffffc020201e:	00093703          	ld	a4,0(s2)
ffffffffc0202022:	953e                	add	a0,a0,a5
ffffffffc0202024:	050e                	slli	a0,a0,0x3
    free_page(pde2page(pd1[0]));
ffffffffc0202026:	4585                	li	a1,1
ffffffffc0202028:	953a                	add	a0,a0,a4
ffffffffc020202a:	e9cff0ef          	jal	ra,ffffffffc02016c6 <free_pages>
    boot_pgdir[0] = 0;
ffffffffc020202e:	601c                	ld	a5,0(s0)
ffffffffc0202030:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>

    assert(nr_free_store==nr_free_pages());
ffffffffc0202034:	ed8ff0ef          	jal	ra,ffffffffc020170c <nr_free_pages>
ffffffffc0202038:	38ab1a63          	bne	s6,a0,ffffffffc02023cc <pmm_init+0x8e0>
}
ffffffffc020203c:	6446                	ld	s0,80(sp)
ffffffffc020203e:	60e6                	ld	ra,88(sp)
ffffffffc0202040:	64a6                	ld	s1,72(sp)
ffffffffc0202042:	6906                	ld	s2,64(sp)
ffffffffc0202044:	79e2                	ld	s3,56(sp)
ffffffffc0202046:	7a42                	ld	s4,48(sp)
ffffffffc0202048:	7aa2                	ld	s5,40(sp)
ffffffffc020204a:	7b02                	ld	s6,32(sp)
ffffffffc020204c:	6be2                	ld	s7,24(sp)
ffffffffc020204e:	6c42                	ld	s8,16(sp)
ffffffffc0202050:	6ca2                	ld	s9,8(sp)

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202052:	00003517          	auipc	a0,0x3
ffffffffc0202056:	6ae50513          	addi	a0,a0,1710 # ffffffffc0205700 <default_pmm_manager+0x680>
}
ffffffffc020205a:	6125                	addi	sp,sp,96
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc020205c:	862fe06f          	j	ffffffffc02000be <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202060:	6705                	lui	a4,0x1
ffffffffc0202062:	177d                	addi	a4,a4,-1
ffffffffc0202064:	96ba                	add	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc0202066:	00c6d713          	srli	a4,a3,0xc
ffffffffc020206a:	08f77163          	bgeu	a4,a5,ffffffffc02020ec <pmm_init+0x600>
    pmm_manager->init_memmap(base, n);
ffffffffc020206e:	00043803          	ld	a6,0(s0)
    return &pages[PPN(pa) - nbase];
ffffffffc0202072:	9732                	add	a4,a4,a2
ffffffffc0202074:	00371793          	slli	a5,a4,0x3
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202078:	767d                	lui	a2,0xfffff
ffffffffc020207a:	8ef1                	and	a3,a3,a2
ffffffffc020207c:	97ba                	add	a5,a5,a4
    pmm_manager->init_memmap(base, n);
ffffffffc020207e:	01083703          	ld	a4,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202082:	8d95                	sub	a1,a1,a3
ffffffffc0202084:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0202086:	81b1                	srli	a1,a1,0xc
ffffffffc0202088:	953e                	add	a0,a0,a5
ffffffffc020208a:	9702                	jalr	a4
ffffffffc020208c:	bebd                	j	ffffffffc0201c0a <pmm_init+0x11e>
ffffffffc020208e:	6008                	ld	a0,0(s0)
ffffffffc0202090:	b5b5                	j	ffffffffc0201efc <pmm_init+0x410>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202092:	86d2                	mv	a3,s4
ffffffffc0202094:	00003617          	auipc	a2,0x3
ffffffffc0202098:	03c60613          	addi	a2,a2,60 # ffffffffc02050d0 <default_pmm_manager+0x50>
ffffffffc020209c:	1cd00593          	li	a1,461
ffffffffc02020a0:	00003517          	auipc	a0,0x3
ffffffffc02020a4:	05850513          	addi	a0,a0,88 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc02020a8:	ac8fe0ef          	jal	ra,ffffffffc0200370 <__panic>
ffffffffc02020ac:	00003697          	auipc	a3,0x3
ffffffffc02020b0:	4c468693          	addi	a3,a3,1220 # ffffffffc0205570 <default_pmm_manager+0x4f0>
ffffffffc02020b4:	00003617          	auipc	a2,0x3
ffffffffc02020b8:	c3460613          	addi	a2,a2,-972 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02020bc:	1cd00593          	li	a1,461
ffffffffc02020c0:	00003517          	auipc	a0,0x3
ffffffffc02020c4:	03850513          	addi	a0,a0,56 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc02020c8:	aa8fe0ef          	jal	ra,ffffffffc0200370 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02020cc:	00003697          	auipc	a3,0x3
ffffffffc02020d0:	4e468693          	addi	a3,a3,1252 # ffffffffc02055b0 <default_pmm_manager+0x530>
ffffffffc02020d4:	00003617          	auipc	a2,0x3
ffffffffc02020d8:	c1460613          	addi	a2,a2,-1004 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02020dc:	1ce00593          	li	a1,462
ffffffffc02020e0:	00003517          	auipc	a0,0x3
ffffffffc02020e4:	01850513          	addi	a0,a0,24 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc02020e8:	a88fe0ef          	jal	ra,ffffffffc0200370 <__panic>
ffffffffc02020ec:	d36ff0ef          	jal	ra,ffffffffc0201622 <pa2page.part.4>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02020f0:	00003617          	auipc	a2,0x3
ffffffffc02020f4:	fe060613          	addi	a2,a2,-32 # ffffffffc02050d0 <default_pmm_manager+0x50>
ffffffffc02020f8:	06a00593          	li	a1,106
ffffffffc02020fc:	00003517          	auipc	a0,0x3
ffffffffc0202100:	06c50513          	addi	a0,a0,108 # ffffffffc0205168 <default_pmm_manager+0xe8>
ffffffffc0202104:	a6cfe0ef          	jal	ra,ffffffffc0200370 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202108:	00003617          	auipc	a2,0x3
ffffffffc020210c:	23860613          	addi	a2,a2,568 # ffffffffc0205340 <default_pmm_manager+0x2c0>
ffffffffc0202110:	07000593          	li	a1,112
ffffffffc0202114:	00003517          	auipc	a0,0x3
ffffffffc0202118:	05450513          	addi	a0,a0,84 # ffffffffc0205168 <default_pmm_manager+0xe8>
ffffffffc020211c:	a54fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202120:	00003697          	auipc	a3,0x3
ffffffffc0202124:	16068693          	addi	a3,a3,352 # ffffffffc0205280 <default_pmm_manager+0x200>
ffffffffc0202128:	00003617          	auipc	a2,0x3
ffffffffc020212c:	bc060613          	addi	a2,a2,-1088 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202130:	19300593          	li	a1,403
ffffffffc0202134:	00003517          	auipc	a0,0x3
ffffffffc0202138:	fc450513          	addi	a0,a0,-60 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc020213c:	a34fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202140:	00003697          	auipc	a3,0x3
ffffffffc0202144:	17868693          	addi	a3,a3,376 # ffffffffc02052b8 <default_pmm_manager+0x238>
ffffffffc0202148:	00003617          	auipc	a2,0x3
ffffffffc020214c:	ba060613          	addi	a2,a2,-1120 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202150:	19400593          	li	a1,404
ffffffffc0202154:	00003517          	auipc	a0,0x3
ffffffffc0202158:	fa450513          	addi	a0,a0,-92 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc020215c:	a14fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202160:	00003697          	auipc	a3,0x3
ffffffffc0202164:	3d068693          	addi	a3,a3,976 # ffffffffc0205530 <default_pmm_manager+0x4b0>
ffffffffc0202168:	00003617          	auipc	a2,0x3
ffffffffc020216c:	b8060613          	addi	a2,a2,-1152 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202170:	1c000593          	li	a1,448
ffffffffc0202174:	00003517          	auipc	a0,0x3
ffffffffc0202178:	f8450513          	addi	a0,a0,-124 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc020217c:	9f4fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202180:	00003617          	auipc	a2,0x3
ffffffffc0202184:	09860613          	addi	a2,a2,152 # ffffffffc0205218 <default_pmm_manager+0x198>
ffffffffc0202188:	07700593          	li	a1,119
ffffffffc020218c:	00003517          	auipc	a0,0x3
ffffffffc0202190:	f6c50513          	addi	a0,a0,-148 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc0202194:	9dcfe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202198:	00003697          	auipc	a3,0x3
ffffffffc020219c:	17868693          	addi	a3,a3,376 # ffffffffc0205310 <default_pmm_manager+0x290>
ffffffffc02021a0:	00003617          	auipc	a2,0x3
ffffffffc02021a4:	b4860613          	addi	a2,a2,-1208 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02021a8:	19a00593          	li	a1,410
ffffffffc02021ac:	00003517          	auipc	a0,0x3
ffffffffc02021b0:	f4c50513          	addi	a0,a0,-180 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc02021b4:	9bcfe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02021b8:	00003697          	auipc	a3,0x3
ffffffffc02021bc:	12868693          	addi	a3,a3,296 # ffffffffc02052e0 <default_pmm_manager+0x260>
ffffffffc02021c0:	00003617          	auipc	a2,0x3
ffffffffc02021c4:	b2860613          	addi	a2,a2,-1240 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02021c8:	19800593          	li	a1,408
ffffffffc02021cc:	00003517          	auipc	a0,0x3
ffffffffc02021d0:	f2c50513          	addi	a0,a0,-212 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc02021d4:	99cfe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(*ptep & PTE_U);
ffffffffc02021d8:	00003697          	auipc	a3,0x3
ffffffffc02021dc:	25068693          	addi	a3,a3,592 # ffffffffc0205428 <default_pmm_manager+0x3a8>
ffffffffc02021e0:	00003617          	auipc	a2,0x3
ffffffffc02021e4:	b0860613          	addi	a2,a2,-1272 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02021e8:	1a500593          	li	a1,421
ffffffffc02021ec:	00003517          	auipc	a0,0x3
ffffffffc02021f0:	f0c50513          	addi	a0,a0,-244 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc02021f4:	97cfe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02021f8:	00003697          	auipc	a3,0x3
ffffffffc02021fc:	20068693          	addi	a3,a3,512 # ffffffffc02053f8 <default_pmm_manager+0x378>
ffffffffc0202200:	00003617          	auipc	a2,0x3
ffffffffc0202204:	ae860613          	addi	a2,a2,-1304 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202208:	1a400593          	li	a1,420
ffffffffc020220c:	00003517          	auipc	a0,0x3
ffffffffc0202210:	eec50513          	addi	a0,a0,-276 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc0202214:	95cfe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202218:	00003697          	auipc	a3,0x3
ffffffffc020221c:	1a868693          	addi	a3,a3,424 # ffffffffc02053c0 <default_pmm_manager+0x340>
ffffffffc0202220:	00003617          	auipc	a2,0x3
ffffffffc0202224:	ac860613          	addi	a2,a2,-1336 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202228:	1a300593          	li	a1,419
ffffffffc020222c:	00003517          	auipc	a0,0x3
ffffffffc0202230:	ecc50513          	addi	a0,a0,-308 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc0202234:	93cfe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202238:	00003697          	auipc	a3,0x3
ffffffffc020223c:	16068693          	addi	a3,a3,352 # ffffffffc0205398 <default_pmm_manager+0x318>
ffffffffc0202240:	00003617          	auipc	a2,0x3
ffffffffc0202244:	aa860613          	addi	a2,a2,-1368 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202248:	1a000593          	li	a1,416
ffffffffc020224c:	00003517          	auipc	a0,0x3
ffffffffc0202250:	eac50513          	addi	a0,a0,-340 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc0202254:	91cfe0ef          	jal	ra,ffffffffc0200370 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202258:	86da                	mv	a3,s6
ffffffffc020225a:	00003617          	auipc	a2,0x3
ffffffffc020225e:	e7660613          	addi	a2,a2,-394 # ffffffffc02050d0 <default_pmm_manager+0x50>
ffffffffc0202262:	19f00593          	li	a1,415
ffffffffc0202266:	00003517          	auipc	a0,0x3
ffffffffc020226a:	e9250513          	addi	a0,a0,-366 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc020226e:	902fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202272:	86be                	mv	a3,a5
ffffffffc0202274:	00003617          	auipc	a2,0x3
ffffffffc0202278:	e5c60613          	addi	a2,a2,-420 # ffffffffc02050d0 <default_pmm_manager+0x50>
ffffffffc020227c:	19e00593          	li	a1,414
ffffffffc0202280:	00003517          	auipc	a0,0x3
ffffffffc0202284:	e7850513          	addi	a0,a0,-392 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc0202288:	8e8fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020228c:	00003697          	auipc	a3,0x3
ffffffffc0202290:	0f468693          	addi	a3,a3,244 # ffffffffc0205380 <default_pmm_manager+0x300>
ffffffffc0202294:	00003617          	auipc	a2,0x3
ffffffffc0202298:	a5460613          	addi	a2,a2,-1452 # ffffffffc0204ce8 <commands+0x870>
ffffffffc020229c:	19c00593          	li	a1,412
ffffffffc02022a0:	00003517          	auipc	a0,0x3
ffffffffc02022a4:	e5850513          	addi	a0,a0,-424 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc02022a8:	8c8fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02022ac:	00003697          	auipc	a3,0x3
ffffffffc02022b0:	0bc68693          	addi	a3,a3,188 # ffffffffc0205368 <default_pmm_manager+0x2e8>
ffffffffc02022b4:	00003617          	auipc	a2,0x3
ffffffffc02022b8:	a3460613          	addi	a2,a2,-1484 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02022bc:	19b00593          	li	a1,411
ffffffffc02022c0:	00003517          	auipc	a0,0x3
ffffffffc02022c4:	e3850513          	addi	a0,a0,-456 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc02022c8:	8a8fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02022cc:	00003697          	auipc	a3,0x3
ffffffffc02022d0:	09c68693          	addi	a3,a3,156 # ffffffffc0205368 <default_pmm_manager+0x2e8>
ffffffffc02022d4:	00003617          	auipc	a2,0x3
ffffffffc02022d8:	a1460613          	addi	a2,a2,-1516 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02022dc:	1ae00593          	li	a1,430
ffffffffc02022e0:	00003517          	auipc	a0,0x3
ffffffffc02022e4:	e1850513          	addi	a0,a0,-488 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc02022e8:	888fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc02022ec:	00003697          	auipc	a3,0x3
ffffffffc02022f0:	10c68693          	addi	a3,a3,268 # ffffffffc02053f8 <default_pmm_manager+0x378>
ffffffffc02022f4:	00003617          	auipc	a2,0x3
ffffffffc02022f8:	9f460613          	addi	a2,a2,-1548 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02022fc:	1ad00593          	li	a1,429
ffffffffc0202300:	00003517          	auipc	a0,0x3
ffffffffc0202304:	df850513          	addi	a0,a0,-520 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc0202308:	868fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020230c:	00003697          	auipc	a3,0x3
ffffffffc0202310:	1b468693          	addi	a3,a3,436 # ffffffffc02054c0 <default_pmm_manager+0x440>
ffffffffc0202314:	00003617          	auipc	a2,0x3
ffffffffc0202318:	9d460613          	addi	a2,a2,-1580 # ffffffffc0204ce8 <commands+0x870>
ffffffffc020231c:	1ac00593          	li	a1,428
ffffffffc0202320:	00003517          	auipc	a0,0x3
ffffffffc0202324:	dd850513          	addi	a0,a0,-552 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc0202328:	848fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc020232c:	00003697          	auipc	a3,0x3
ffffffffc0202330:	17c68693          	addi	a3,a3,380 # ffffffffc02054a8 <default_pmm_manager+0x428>
ffffffffc0202334:	00003617          	auipc	a2,0x3
ffffffffc0202338:	9b460613          	addi	a2,a2,-1612 # ffffffffc0204ce8 <commands+0x870>
ffffffffc020233c:	1ab00593          	li	a1,427
ffffffffc0202340:	00003517          	auipc	a0,0x3
ffffffffc0202344:	db850513          	addi	a0,a0,-584 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc0202348:	828fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc020234c:	00003697          	auipc	a3,0x3
ffffffffc0202350:	12c68693          	addi	a3,a3,300 # ffffffffc0205478 <default_pmm_manager+0x3f8>
ffffffffc0202354:	00003617          	auipc	a2,0x3
ffffffffc0202358:	99460613          	addi	a2,a2,-1644 # ffffffffc0204ce8 <commands+0x870>
ffffffffc020235c:	1aa00593          	li	a1,426
ffffffffc0202360:	00003517          	auipc	a0,0x3
ffffffffc0202364:	d9850513          	addi	a0,a0,-616 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc0202368:	808fe0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc020236c:	00003697          	auipc	a3,0x3
ffffffffc0202370:	0f468693          	addi	a3,a3,244 # ffffffffc0205460 <default_pmm_manager+0x3e0>
ffffffffc0202374:	00003617          	auipc	a2,0x3
ffffffffc0202378:	97460613          	addi	a2,a2,-1676 # ffffffffc0204ce8 <commands+0x870>
ffffffffc020237c:	1a800593          	li	a1,424
ffffffffc0202380:	00003517          	auipc	a0,0x3
ffffffffc0202384:	d7850513          	addi	a0,a0,-648 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc0202388:	fe9fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020238c:	00003697          	auipc	a3,0x3
ffffffffc0202390:	0bc68693          	addi	a3,a3,188 # ffffffffc0205448 <default_pmm_manager+0x3c8>
ffffffffc0202394:	00003617          	auipc	a2,0x3
ffffffffc0202398:	95460613          	addi	a2,a2,-1708 # ffffffffc0204ce8 <commands+0x870>
ffffffffc020239c:	1a700593          	li	a1,423
ffffffffc02023a0:	00003517          	auipc	a0,0x3
ffffffffc02023a4:	d5850513          	addi	a0,a0,-680 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc02023a8:	fc9fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(*ptep & PTE_W);
ffffffffc02023ac:	00003697          	auipc	a3,0x3
ffffffffc02023b0:	08c68693          	addi	a3,a3,140 # ffffffffc0205438 <default_pmm_manager+0x3b8>
ffffffffc02023b4:	00003617          	auipc	a2,0x3
ffffffffc02023b8:	93460613          	addi	a2,a2,-1740 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02023bc:	1a600593          	li	a1,422
ffffffffc02023c0:	00003517          	auipc	a0,0x3
ffffffffc02023c4:	d3850513          	addi	a0,a0,-712 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc02023c8:	fa9fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc02023cc:	00003697          	auipc	a3,0x3
ffffffffc02023d0:	16468693          	addi	a3,a3,356 # ffffffffc0205530 <default_pmm_manager+0x4b0>
ffffffffc02023d4:	00003617          	auipc	a2,0x3
ffffffffc02023d8:	91460613          	addi	a2,a2,-1772 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02023dc:	1e800593          	li	a1,488
ffffffffc02023e0:	00003517          	auipc	a0,0x3
ffffffffc02023e4:	d1850513          	addi	a0,a0,-744 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc02023e8:	f89fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02023ec:	00003697          	auipc	a3,0x3
ffffffffc02023f0:	2ec68693          	addi	a3,a3,748 # ffffffffc02056d8 <default_pmm_manager+0x658>
ffffffffc02023f4:	00003617          	auipc	a2,0x3
ffffffffc02023f8:	8f460613          	addi	a2,a2,-1804 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02023fc:	1e000593          	li	a1,480
ffffffffc0202400:	00003517          	auipc	a0,0x3
ffffffffc0202404:	cf850513          	addi	a0,a0,-776 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc0202408:	f69fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc020240c:	00003697          	auipc	a3,0x3
ffffffffc0202410:	29468693          	addi	a3,a3,660 # ffffffffc02056a0 <default_pmm_manager+0x620>
ffffffffc0202414:	00003617          	auipc	a2,0x3
ffffffffc0202418:	8d460613          	addi	a2,a2,-1836 # ffffffffc0204ce8 <commands+0x870>
ffffffffc020241c:	1dd00593          	li	a1,477
ffffffffc0202420:	00003517          	auipc	a0,0x3
ffffffffc0202424:	cd850513          	addi	a0,a0,-808 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc0202428:	f49fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p) == 2);
ffffffffc020242c:	00003697          	auipc	a3,0x3
ffffffffc0202430:	24468693          	addi	a3,a3,580 # ffffffffc0205670 <default_pmm_manager+0x5f0>
ffffffffc0202434:	00003617          	auipc	a2,0x3
ffffffffc0202438:	8b460613          	addi	a2,a2,-1868 # ffffffffc0204ce8 <commands+0x870>
ffffffffc020243c:	1d900593          	li	a1,473
ffffffffc0202440:	00003517          	auipc	a0,0x3
ffffffffc0202444:	cb850513          	addi	a0,a0,-840 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc0202448:	f29fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc020244c:	00003697          	auipc	a3,0x3
ffffffffc0202450:	0a468693          	addi	a3,a3,164 # ffffffffc02054f0 <default_pmm_manager+0x470>
ffffffffc0202454:	00003617          	auipc	a2,0x3
ffffffffc0202458:	89460613          	addi	a2,a2,-1900 # ffffffffc0204ce8 <commands+0x870>
ffffffffc020245c:	1b600593          	li	a1,438
ffffffffc0202460:	00003517          	auipc	a0,0x3
ffffffffc0202464:	c9850513          	addi	a0,a0,-872 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc0202468:	f09fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020246c:	00003697          	auipc	a3,0x3
ffffffffc0202470:	05468693          	addi	a3,a3,84 # ffffffffc02054c0 <default_pmm_manager+0x440>
ffffffffc0202474:	00003617          	auipc	a2,0x3
ffffffffc0202478:	87460613          	addi	a2,a2,-1932 # ffffffffc0204ce8 <commands+0x870>
ffffffffc020247c:	1b300593          	li	a1,435
ffffffffc0202480:	00003517          	auipc	a0,0x3
ffffffffc0202484:	c7850513          	addi	a0,a0,-904 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc0202488:	ee9fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020248c:	00003697          	auipc	a3,0x3
ffffffffc0202490:	ef468693          	addi	a3,a3,-268 # ffffffffc0205380 <default_pmm_manager+0x300>
ffffffffc0202494:	00003617          	auipc	a2,0x3
ffffffffc0202498:	85460613          	addi	a2,a2,-1964 # ffffffffc0204ce8 <commands+0x870>
ffffffffc020249c:	1b200593          	li	a1,434
ffffffffc02024a0:	00003517          	auipc	a0,0x3
ffffffffc02024a4:	c5850513          	addi	a0,a0,-936 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc02024a8:	ec9fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02024ac:	00003697          	auipc	a3,0x3
ffffffffc02024b0:	02c68693          	addi	a3,a3,44 # ffffffffc02054d8 <default_pmm_manager+0x458>
ffffffffc02024b4:	00003617          	auipc	a2,0x3
ffffffffc02024b8:	83460613          	addi	a2,a2,-1996 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02024bc:	1af00593          	li	a1,431
ffffffffc02024c0:	00003517          	auipc	a0,0x3
ffffffffc02024c4:	c3850513          	addi	a0,a0,-968 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc02024c8:	ea9fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02024cc:	00003697          	auipc	a3,0x3
ffffffffc02024d0:	03c68693          	addi	a3,a3,60 # ffffffffc0205508 <default_pmm_manager+0x488>
ffffffffc02024d4:	00003617          	auipc	a2,0x3
ffffffffc02024d8:	81460613          	addi	a2,a2,-2028 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02024dc:	1b900593          	li	a1,441
ffffffffc02024e0:	00003517          	auipc	a0,0x3
ffffffffc02024e4:	c1850513          	addi	a0,a0,-1000 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc02024e8:	e89fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02024ec:	00003697          	auipc	a3,0x3
ffffffffc02024f0:	fd468693          	addi	a3,a3,-44 # ffffffffc02054c0 <default_pmm_manager+0x440>
ffffffffc02024f4:	00002617          	auipc	a2,0x2
ffffffffc02024f8:	7f460613          	addi	a2,a2,2036 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02024fc:	1b700593          	li	a1,439
ffffffffc0202500:	00003517          	auipc	a0,0x3
ffffffffc0202504:	bf850513          	addi	a0,a0,-1032 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc0202508:	e69fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020250c:	00003697          	auipc	a3,0x3
ffffffffc0202510:	d5468693          	addi	a3,a3,-684 # ffffffffc0205260 <default_pmm_manager+0x1e0>
ffffffffc0202514:	00002617          	auipc	a2,0x2
ffffffffc0202518:	7d460613          	addi	a2,a2,2004 # ffffffffc0204ce8 <commands+0x870>
ffffffffc020251c:	19200593          	li	a1,402
ffffffffc0202520:	00003517          	auipc	a0,0x3
ffffffffc0202524:	bd850513          	addi	a0,a0,-1064 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc0202528:	e49fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020252c:	00003617          	auipc	a2,0x3
ffffffffc0202530:	cec60613          	addi	a2,a2,-788 # ffffffffc0205218 <default_pmm_manager+0x198>
ffffffffc0202534:	0bd00593          	li	a1,189
ffffffffc0202538:	00003517          	auipc	a0,0x3
ffffffffc020253c:	bc050513          	addi	a0,a0,-1088 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc0202540:	e31fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202544:	00003697          	auipc	a3,0x3
ffffffffc0202548:	0ec68693          	addi	a3,a3,236 # ffffffffc0205630 <default_pmm_manager+0x5b0>
ffffffffc020254c:	00002617          	auipc	a2,0x2
ffffffffc0202550:	79c60613          	addi	a2,a2,1948 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202554:	1d800593          	li	a1,472
ffffffffc0202558:	00003517          	auipc	a0,0x3
ffffffffc020255c:	ba050513          	addi	a0,a0,-1120 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc0202560:	e11fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202564:	00003697          	auipc	a3,0x3
ffffffffc0202568:	0b468693          	addi	a3,a3,180 # ffffffffc0205618 <default_pmm_manager+0x598>
ffffffffc020256c:	00002617          	auipc	a2,0x2
ffffffffc0202570:	77c60613          	addi	a2,a2,1916 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202574:	1d700593          	li	a1,471
ffffffffc0202578:	00003517          	auipc	a0,0x3
ffffffffc020257c:	b8050513          	addi	a0,a0,-1152 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc0202580:	df1fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202584:	00003697          	auipc	a3,0x3
ffffffffc0202588:	05c68693          	addi	a3,a3,92 # ffffffffc02055e0 <default_pmm_manager+0x560>
ffffffffc020258c:	00002617          	auipc	a2,0x2
ffffffffc0202590:	75c60613          	addi	a2,a2,1884 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202594:	1d600593          	li	a1,470
ffffffffc0202598:	00003517          	auipc	a0,0x3
ffffffffc020259c:	b6050513          	addi	a0,a0,-1184 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc02025a0:	dd1fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc02025a4:	00003697          	auipc	a3,0x3
ffffffffc02025a8:	02468693          	addi	a3,a3,36 # ffffffffc02055c8 <default_pmm_manager+0x548>
ffffffffc02025ac:	00002617          	auipc	a2,0x2
ffffffffc02025b0:	73c60613          	addi	a2,a2,1852 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02025b4:	1d200593          	li	a1,466
ffffffffc02025b8:	00003517          	auipc	a0,0x3
ffffffffc02025bc:	b4050513          	addi	a0,a0,-1216 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc02025c0:	db1fd0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc02025c4 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc02025c4:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc02025c8:	8082                	ret

ffffffffc02025ca <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02025ca:	7179                	addi	sp,sp,-48
ffffffffc02025cc:	e84a                	sd	s2,16(sp)
ffffffffc02025ce:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02025d0:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02025d2:	f022                	sd	s0,32(sp)
ffffffffc02025d4:	ec26                	sd	s1,24(sp)
ffffffffc02025d6:	e44e                	sd	s3,8(sp)
ffffffffc02025d8:	f406                	sd	ra,40(sp)
ffffffffc02025da:	84ae                	mv	s1,a1
ffffffffc02025dc:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc02025de:	860ff0ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc02025e2:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc02025e4:	cd19                	beqz	a0,ffffffffc0202602 <pgdir_alloc_page+0x38>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc02025e6:	85aa                	mv	a1,a0
ffffffffc02025e8:	86ce                	mv	a3,s3
ffffffffc02025ea:	8626                	mv	a2,s1
ffffffffc02025ec:	854a                	mv	a0,s2
ffffffffc02025ee:	c2cff0ef          	jal	ra,ffffffffc0201a1a <page_insert>
ffffffffc02025f2:	ed39                	bnez	a0,ffffffffc0202650 <pgdir_alloc_page+0x86>
        if (swap_init_ok) {
ffffffffc02025f4:	0000f797          	auipc	a5,0xf
ffffffffc02025f8:	e7478793          	addi	a5,a5,-396 # ffffffffc0211468 <swap_init_ok>
ffffffffc02025fc:	439c                	lw	a5,0(a5)
ffffffffc02025fe:	2781                	sext.w	a5,a5
ffffffffc0202600:	eb89                	bnez	a5,ffffffffc0202612 <pgdir_alloc_page+0x48>
}
ffffffffc0202602:	8522                	mv	a0,s0
ffffffffc0202604:	70a2                	ld	ra,40(sp)
ffffffffc0202606:	7402                	ld	s0,32(sp)
ffffffffc0202608:	64e2                	ld	s1,24(sp)
ffffffffc020260a:	6942                	ld	s2,16(sp)
ffffffffc020260c:	69a2                	ld	s3,8(sp)
ffffffffc020260e:	6145                	addi	sp,sp,48
ffffffffc0202610:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202612:	0000f797          	auipc	a5,0xf
ffffffffc0202616:	f7678793          	addi	a5,a5,-138 # ffffffffc0211588 <check_mm_struct>
ffffffffc020261a:	6388                	ld	a0,0(a5)
ffffffffc020261c:	4681                	li	a3,0
ffffffffc020261e:	8622                	mv	a2,s0
ffffffffc0202620:	85a6                	mv	a1,s1
ffffffffc0202622:	06d000ef          	jal	ra,ffffffffc0202e8e <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202626:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202628:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc020262a:	4785                	li	a5,1
ffffffffc020262c:	fcf70be3          	beq	a4,a5,ffffffffc0202602 <pgdir_alloc_page+0x38>
ffffffffc0202630:	00003697          	auipc	a3,0x3
ffffffffc0202634:	b4868693          	addi	a3,a3,-1208 # ffffffffc0205178 <default_pmm_manager+0xf8>
ffffffffc0202638:	00002617          	auipc	a2,0x2
ffffffffc020263c:	6b060613          	addi	a2,a2,1712 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202640:	17a00593          	li	a1,378
ffffffffc0202644:	00003517          	auipc	a0,0x3
ffffffffc0202648:	ab450513          	addi	a0,a0,-1356 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc020264c:	d25fd0ef          	jal	ra,ffffffffc0200370 <__panic>
            free_page(page);
ffffffffc0202650:	8522                	mv	a0,s0
ffffffffc0202652:	4585                	li	a1,1
ffffffffc0202654:	872ff0ef          	jal	ra,ffffffffc02016c6 <free_pages>
            return NULL;
ffffffffc0202658:	4401                	li	s0,0
ffffffffc020265a:	b765                	j	ffffffffc0202602 <pgdir_alloc_page+0x38>

ffffffffc020265c <kmalloc>:
}

void *kmalloc(size_t n) {
ffffffffc020265c:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020265e:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc0202660:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202662:	fff50713          	addi	a4,a0,-1
ffffffffc0202666:	17f9                	addi	a5,a5,-2
ffffffffc0202668:	04e7ee63          	bltu	a5,a4,ffffffffc02026c4 <kmalloc+0x68>
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc020266c:	6785                	lui	a5,0x1
ffffffffc020266e:	17fd                	addi	a5,a5,-1
ffffffffc0202670:	953e                	add	a0,a0,a5
    base = alloc_pages(num_pages);
ffffffffc0202672:	8131                	srli	a0,a0,0xc
ffffffffc0202674:	fcbfe0ef          	jal	ra,ffffffffc020163e <alloc_pages>
    assert(base != NULL);
ffffffffc0202678:	c159                	beqz	a0,ffffffffc02026fe <kmalloc+0xa2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020267a:	0000f797          	auipc	a5,0xf
ffffffffc020267e:	e2e78793          	addi	a5,a5,-466 # ffffffffc02114a8 <pages>
ffffffffc0202682:	639c                	ld	a5,0(a5)
ffffffffc0202684:	8d1d                	sub	a0,a0,a5
ffffffffc0202686:	00002797          	auipc	a5,0x2
ffffffffc020268a:	64a78793          	addi	a5,a5,1610 # ffffffffc0204cd0 <commands+0x858>
ffffffffc020268e:	6394                	ld	a3,0(a5)
ffffffffc0202690:	850d                	srai	a0,a0,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202692:	0000f797          	auipc	a5,0xf
ffffffffc0202696:	dc678793          	addi	a5,a5,-570 # ffffffffc0211458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020269a:	02d50533          	mul	a0,a0,a3
ffffffffc020269e:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02026a2:	6398                	ld	a4,0(a5)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02026a4:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02026a6:	00c51793          	slli	a5,a0,0xc
ffffffffc02026aa:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02026ac:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02026ae:	02e7fb63          	bgeu	a5,a4,ffffffffc02026e4 <kmalloc+0x88>
ffffffffc02026b2:	0000f797          	auipc	a5,0xf
ffffffffc02026b6:	de678793          	addi	a5,a5,-538 # ffffffffc0211498 <va_pa_offset>
ffffffffc02026ba:	639c                	ld	a5,0(a5)
    ptr = page2kva(base);
    return ptr;
}
ffffffffc02026bc:	60a2                	ld	ra,8(sp)
ffffffffc02026be:	953e                	add	a0,a0,a5
ffffffffc02026c0:	0141                	addi	sp,sp,16
ffffffffc02026c2:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02026c4:	00003697          	auipc	a3,0x3
ffffffffc02026c8:	a5468693          	addi	a3,a3,-1452 # ffffffffc0205118 <default_pmm_manager+0x98>
ffffffffc02026cc:	00002617          	auipc	a2,0x2
ffffffffc02026d0:	61c60613          	addi	a2,a2,1564 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02026d4:	1f000593          	li	a1,496
ffffffffc02026d8:	00003517          	auipc	a0,0x3
ffffffffc02026dc:	a2050513          	addi	a0,a0,-1504 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc02026e0:	c91fd0ef          	jal	ra,ffffffffc0200370 <__panic>
ffffffffc02026e4:	86aa                	mv	a3,a0
ffffffffc02026e6:	00003617          	auipc	a2,0x3
ffffffffc02026ea:	9ea60613          	addi	a2,a2,-1558 # ffffffffc02050d0 <default_pmm_manager+0x50>
ffffffffc02026ee:	06a00593          	li	a1,106
ffffffffc02026f2:	00003517          	auipc	a0,0x3
ffffffffc02026f6:	a7650513          	addi	a0,a0,-1418 # ffffffffc0205168 <default_pmm_manager+0xe8>
ffffffffc02026fa:	c77fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(base != NULL);
ffffffffc02026fe:	00003697          	auipc	a3,0x3
ffffffffc0202702:	a3a68693          	addi	a3,a3,-1478 # ffffffffc0205138 <default_pmm_manager+0xb8>
ffffffffc0202706:	00002617          	auipc	a2,0x2
ffffffffc020270a:	5e260613          	addi	a2,a2,1506 # ffffffffc0204ce8 <commands+0x870>
ffffffffc020270e:	1f300593          	li	a1,499
ffffffffc0202712:	00003517          	auipc	a0,0x3
ffffffffc0202716:	9e650513          	addi	a0,a0,-1562 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc020271a:	c57fd0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc020271e <kfree>:

void kfree(void *ptr, size_t n) {
ffffffffc020271e:	1141                	addi	sp,sp,-16
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202720:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0202722:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202724:	fff58713          	addi	a4,a1,-1
ffffffffc0202728:	17f9                	addi	a5,a5,-2
ffffffffc020272a:	04e7eb63          	bltu	a5,a4,ffffffffc0202780 <kfree+0x62>
    assert(ptr != NULL);
ffffffffc020272e:	c941                	beqz	a0,ffffffffc02027be <kfree+0xa0>
    struct Page *base = NULL;
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0202730:	6785                	lui	a5,0x1
ffffffffc0202732:	17fd                	addi	a5,a5,-1
ffffffffc0202734:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202736:	c02007b7          	lui	a5,0xc0200
ffffffffc020273a:	81b1                	srli	a1,a1,0xc
ffffffffc020273c:	06f56463          	bltu	a0,a5,ffffffffc02027a4 <kfree+0x86>
ffffffffc0202740:	0000f797          	auipc	a5,0xf
ffffffffc0202744:	d5878793          	addi	a5,a5,-680 # ffffffffc0211498 <va_pa_offset>
ffffffffc0202748:	639c                	ld	a5,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc020274a:	0000f717          	auipc	a4,0xf
ffffffffc020274e:	d0e70713          	addi	a4,a4,-754 # ffffffffc0211458 <npage>
ffffffffc0202752:	6318                	ld	a4,0(a4)
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202754:	40f507b3          	sub	a5,a0,a5
    if (PPN(pa) >= npage) {
ffffffffc0202758:	83b1                	srli	a5,a5,0xc
ffffffffc020275a:	04e7f363          	bgeu	a5,a4,ffffffffc02027a0 <kfree+0x82>
    return &pages[PPN(pa) - nbase];
ffffffffc020275e:	fff80537          	lui	a0,0xfff80
ffffffffc0202762:	97aa                	add	a5,a5,a0
ffffffffc0202764:	0000f697          	auipc	a3,0xf
ffffffffc0202768:	d4468693          	addi	a3,a3,-700 # ffffffffc02114a8 <pages>
ffffffffc020276c:	6288                	ld	a0,0(a3)
ffffffffc020276e:	00379713          	slli	a4,a5,0x3
    base = kva2page(ptr);
    free_pages(base, num_pages);
}
ffffffffc0202772:	60a2                	ld	ra,8(sp)
ffffffffc0202774:	97ba                	add	a5,a5,a4
ffffffffc0202776:	078e                	slli	a5,a5,0x3
    free_pages(base, num_pages);
ffffffffc0202778:	953e                	add	a0,a0,a5
}
ffffffffc020277a:	0141                	addi	sp,sp,16
    free_pages(base, num_pages);
ffffffffc020277c:	f4bfe06f          	j	ffffffffc02016c6 <free_pages>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202780:	00003697          	auipc	a3,0x3
ffffffffc0202784:	99868693          	addi	a3,a3,-1640 # ffffffffc0205118 <default_pmm_manager+0x98>
ffffffffc0202788:	00002617          	auipc	a2,0x2
ffffffffc020278c:	56060613          	addi	a2,a2,1376 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202790:	1f900593          	li	a1,505
ffffffffc0202794:	00003517          	auipc	a0,0x3
ffffffffc0202798:	96450513          	addi	a0,a0,-1692 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc020279c:	bd5fd0ef          	jal	ra,ffffffffc0200370 <__panic>
ffffffffc02027a0:	e83fe0ef          	jal	ra,ffffffffc0201622 <pa2page.part.4>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02027a4:	86aa                	mv	a3,a0
ffffffffc02027a6:	00003617          	auipc	a2,0x3
ffffffffc02027aa:	a7260613          	addi	a2,a2,-1422 # ffffffffc0205218 <default_pmm_manager+0x198>
ffffffffc02027ae:	06c00593          	li	a1,108
ffffffffc02027b2:	00003517          	auipc	a0,0x3
ffffffffc02027b6:	9b650513          	addi	a0,a0,-1610 # ffffffffc0205168 <default_pmm_manager+0xe8>
ffffffffc02027ba:	bb7fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(ptr != NULL);
ffffffffc02027be:	00003697          	auipc	a3,0x3
ffffffffc02027c2:	94a68693          	addi	a3,a3,-1718 # ffffffffc0205108 <default_pmm_manager+0x88>
ffffffffc02027c6:	00002617          	auipc	a2,0x2
ffffffffc02027ca:	52260613          	addi	a2,a2,1314 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02027ce:	1fa00593          	li	a1,506
ffffffffc02027d2:	00003517          	auipc	a0,0x3
ffffffffc02027d6:	92650513          	addi	a0,a0,-1754 # ffffffffc02050f8 <default_pmm_manager+0x78>
ffffffffc02027da:	b97fd0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc02027de <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc02027de:	7135                	addi	sp,sp,-160
ffffffffc02027e0:	ed06                	sd	ra,152(sp)
ffffffffc02027e2:	e922                	sd	s0,144(sp)
ffffffffc02027e4:	e526                	sd	s1,136(sp)
ffffffffc02027e6:	e14a                	sd	s2,128(sp)
ffffffffc02027e8:	fcce                	sd	s3,120(sp)
ffffffffc02027ea:	f8d2                	sd	s4,112(sp)
ffffffffc02027ec:	f4d6                	sd	s5,104(sp)
ffffffffc02027ee:	f0da                	sd	s6,96(sp)
ffffffffc02027f0:	ecde                	sd	s7,88(sp)
ffffffffc02027f2:	e8e2                	sd	s8,80(sp)
ffffffffc02027f4:	e4e6                	sd	s9,72(sp)
ffffffffc02027f6:	e0ea                	sd	s10,64(sp)
ffffffffc02027f8:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc02027fa:	45e010ef          	jal	ra,ffffffffc0203c58 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc02027fe:	0000f797          	auipc	a5,0xf
ffffffffc0202802:	d3a78793          	addi	a5,a5,-710 # ffffffffc0211538 <max_swap_offset>
ffffffffc0202806:	6394                	ld	a3,0(a5)
ffffffffc0202808:	010007b7          	lui	a5,0x1000
ffffffffc020280c:	17e1                	addi	a5,a5,-8
ffffffffc020280e:	ff968713          	addi	a4,a3,-7
ffffffffc0202812:	42e7ea63          	bltu	a5,a4,ffffffffc0202c46 <swap_init+0x468>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
	
      sm = &swap_manager_lru;
ffffffffc0202816:	00007797          	auipc	a5,0x7
ffffffffc020281a:	7ea78793          	addi	a5,a5,2026 # ffffffffc020a000 <swap_manager_lru>
     //sm = &swap_manager_clock;
     //sm = &swap_manager_fifo;//use first in first out Page Replacement Algorithm
     int r = sm->init();
ffffffffc020281e:	6798                	ld	a4,8(a5)
      sm = &swap_manager_lru;
ffffffffc0202820:	0000f697          	auipc	a3,0xf
ffffffffc0202824:	c4f6b023          	sd	a5,-960(a3) # ffffffffc0211460 <sm>
     int r = sm->init();
ffffffffc0202828:	9702                	jalr	a4
ffffffffc020282a:	8b2a                	mv	s6,a0
     
     if (r == 0)
ffffffffc020282c:	c10d                	beqz	a0,ffffffffc020284e <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc020282e:	60ea                	ld	ra,152(sp)
ffffffffc0202830:	644a                	ld	s0,144(sp)
ffffffffc0202832:	855a                	mv	a0,s6
ffffffffc0202834:	64aa                	ld	s1,136(sp)
ffffffffc0202836:	690a                	ld	s2,128(sp)
ffffffffc0202838:	79e6                	ld	s3,120(sp)
ffffffffc020283a:	7a46                	ld	s4,112(sp)
ffffffffc020283c:	7aa6                	ld	s5,104(sp)
ffffffffc020283e:	7b06                	ld	s6,96(sp)
ffffffffc0202840:	6be6                	ld	s7,88(sp)
ffffffffc0202842:	6c46                	ld	s8,80(sp)
ffffffffc0202844:	6ca6                	ld	s9,72(sp)
ffffffffc0202846:	6d06                	ld	s10,64(sp)
ffffffffc0202848:	7de2                	ld	s11,56(sp)
ffffffffc020284a:	610d                	addi	sp,sp,160
ffffffffc020284c:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc020284e:	0000f797          	auipc	a5,0xf
ffffffffc0202852:	c1278793          	addi	a5,a5,-1006 # ffffffffc0211460 <sm>
ffffffffc0202856:	639c                	ld	a5,0(a5)
ffffffffc0202858:	00003517          	auipc	a0,0x3
ffffffffc020285c:	f4850513          	addi	a0,a0,-184 # ffffffffc02057a0 <default_pmm_manager+0x720>
    return listelm->next;
ffffffffc0202860:	0000f417          	auipc	s0,0xf
ffffffffc0202864:	c1840413          	addi	s0,s0,-1000 # ffffffffc0211478 <free_area>
ffffffffc0202868:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc020286a:	4785                	li	a5,1
ffffffffc020286c:	0000f717          	auipc	a4,0xf
ffffffffc0202870:	bef72e23          	sw	a5,-1028(a4) # ffffffffc0211468 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202874:	84bfd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0202878:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc020287a:	2e878a63          	beq	a5,s0,ffffffffc0202b6e <swap_init+0x390>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020287e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0202882:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202884:	8b05                	andi	a4,a4,1
ffffffffc0202886:	2e070863          	beqz	a4,ffffffffc0202b76 <swap_init+0x398>
     int ret, count = 0, total = 0, i;
ffffffffc020288a:	4481                	li	s1,0
ffffffffc020288c:	4901                	li	s2,0
ffffffffc020288e:	a031                	j	ffffffffc020289a <swap_init+0xbc>
ffffffffc0202890:	fe87b703          	ld	a4,-24(a5)
        assert(PageProperty(p));
ffffffffc0202894:	8b09                	andi	a4,a4,2
ffffffffc0202896:	2e070063          	beqz	a4,ffffffffc0202b76 <swap_init+0x398>
        count ++, total += p->property;
ffffffffc020289a:	ff87a703          	lw	a4,-8(a5)
ffffffffc020289e:	679c                	ld	a5,8(a5)
ffffffffc02028a0:	2905                	addiw	s2,s2,1
ffffffffc02028a2:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc02028a4:	fe8796e3          	bne	a5,s0,ffffffffc0202890 <swap_init+0xb2>
ffffffffc02028a8:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc02028aa:	e63fe0ef          	jal	ra,ffffffffc020170c <nr_free_pages>
ffffffffc02028ae:	5b351863          	bne	a0,s3,ffffffffc0202e5e <swap_init+0x680>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc02028b2:	8626                	mv	a2,s1
ffffffffc02028b4:	85ca                	mv	a1,s2
ffffffffc02028b6:	00003517          	auipc	a0,0x3
ffffffffc02028ba:	f0250513          	addi	a0,a0,-254 # ffffffffc02057b8 <default_pmm_manager+0x738>
ffffffffc02028be:	801fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc02028c2:	399000ef          	jal	ra,ffffffffc020345a <mm_create>
ffffffffc02028c6:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc02028c8:	50050b63          	beqz	a0,ffffffffc0202dde <swap_init+0x600>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc02028cc:	0000f797          	auipc	a5,0xf
ffffffffc02028d0:	cbc78793          	addi	a5,a5,-836 # ffffffffc0211588 <check_mm_struct>
ffffffffc02028d4:	639c                	ld	a5,0(a5)
ffffffffc02028d6:	52079463          	bnez	a5,ffffffffc0202dfe <swap_init+0x620>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02028da:	0000f797          	auipc	a5,0xf
ffffffffc02028de:	b7678793          	addi	a5,a5,-1162 # ffffffffc0211450 <boot_pgdir>
ffffffffc02028e2:	6398                	ld	a4,0(a5)
     check_mm_struct = mm;
ffffffffc02028e4:	0000f797          	auipc	a5,0xf
ffffffffc02028e8:	caa7b223          	sd	a0,-860(a5) # ffffffffc0211588 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc02028ec:	631c                	ld	a5,0(a4)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02028ee:	ec3a                	sd	a4,24(sp)
ffffffffc02028f0:	ed18                	sd	a4,24(a0)
     assert(pgdir[0] == 0);
ffffffffc02028f2:	52079663          	bnez	a5,ffffffffc0202e1e <swap_init+0x640>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc02028f6:	6599                	lui	a1,0x6
ffffffffc02028f8:	460d                	li	a2,3
ffffffffc02028fa:	6505                	lui	a0,0x1
ffffffffc02028fc:	3ab000ef          	jal	ra,ffffffffc02034a6 <vma_create>
ffffffffc0202900:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202902:	52050e63          	beqz	a0,ffffffffc0202e3e <swap_init+0x660>

     insert_vma_struct(mm, vma);
ffffffffc0202906:	855e                	mv	a0,s7
ffffffffc0202908:	40b000ef          	jal	ra,ffffffffc0203512 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc020290c:	00003517          	auipc	a0,0x3
ffffffffc0202910:	f1c50513          	addi	a0,a0,-228 # ffffffffc0205828 <default_pmm_manager+0x7a8>
ffffffffc0202914:	faafd0ef          	jal	ra,ffffffffc02000be <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202918:	018bb503          	ld	a0,24(s7)
ffffffffc020291c:	4605                	li	a2,1
ffffffffc020291e:	6585                	lui	a1,0x1
ffffffffc0202920:	e2dfe0ef          	jal	ra,ffffffffc020174c <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202924:	40050d63          	beqz	a0,ffffffffc0202d3e <swap_init+0x560>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202928:	00003517          	auipc	a0,0x3
ffffffffc020292c:	f5050513          	addi	a0,a0,-176 # ffffffffc0205878 <default_pmm_manager+0x7f8>
ffffffffc0202930:	0000fa17          	auipc	s4,0xf
ffffffffc0202934:	b80a0a13          	addi	s4,s4,-1152 # ffffffffc02114b0 <check_rp>
ffffffffc0202938:	f86fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020293c:	0000fa97          	auipc	s5,0xf
ffffffffc0202940:	b94a8a93          	addi	s5,s5,-1132 # ffffffffc02114d0 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202944:	89d2                	mv	s3,s4
          check_rp[i] = alloc_page();
ffffffffc0202946:	4505                	li	a0,1
ffffffffc0202948:	cf7fe0ef          	jal	ra,ffffffffc020163e <alloc_pages>
ffffffffc020294c:	00a9b023          	sd	a0,0(s3) # fffffffffff80000 <end+0x3fd6ea70>
          assert(check_rp[i] != NULL );
ffffffffc0202950:	2a050b63          	beqz	a0,ffffffffc0202c06 <swap_init+0x428>
ffffffffc0202954:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202956:	8b89                	andi	a5,a5,2
ffffffffc0202958:	28079763          	bnez	a5,ffffffffc0202be6 <swap_init+0x408>
ffffffffc020295c:	09a1                	addi	s3,s3,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020295e:	ff5994e3          	bne	s3,s5,ffffffffc0202946 <swap_init+0x168>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202962:	601c                	ld	a5,0(s0)
ffffffffc0202964:	00843983          	ld	s3,8(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc0202968:	0000fd17          	auipc	s10,0xf
ffffffffc020296c:	b48d0d13          	addi	s10,s10,-1208 # ffffffffc02114b0 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc0202970:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc0202972:	481c                	lw	a5,16(s0)
ffffffffc0202974:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc0202976:	0000f797          	auipc	a5,0xf
ffffffffc020297a:	b087b523          	sd	s0,-1270(a5) # ffffffffc0211480 <free_area+0x8>
ffffffffc020297e:	0000f797          	auipc	a5,0xf
ffffffffc0202982:	ae87bd23          	sd	s0,-1286(a5) # ffffffffc0211478 <free_area>
     nr_free = 0;
ffffffffc0202986:	0000f797          	auipc	a5,0xf
ffffffffc020298a:	b007a123          	sw	zero,-1278(a5) # ffffffffc0211488 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc020298e:	000d3503          	ld	a0,0(s10)
ffffffffc0202992:	4585                	li	a1,1
ffffffffc0202994:	0d21                	addi	s10,s10,8
ffffffffc0202996:	d31fe0ef          	jal	ra,ffffffffc02016c6 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc020299a:	ff5d1ae3          	bne	s10,s5,ffffffffc020298e <swap_init+0x1b0>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc020299e:	01042d03          	lw	s10,16(s0)
ffffffffc02029a2:	4791                	li	a5,4
ffffffffc02029a4:	36fd1d63          	bne	s10,a5,ffffffffc0202d1e <swap_init+0x540>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc02029a8:	00003517          	auipc	a0,0x3
ffffffffc02029ac:	f5850513          	addi	a0,a0,-168 # ffffffffc0205900 <default_pmm_manager+0x880>
ffffffffc02029b0:	f0efd0ef          	jal	ra,ffffffffc02000be <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02029b4:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc02029b6:	0000f797          	auipc	a5,0xf
ffffffffc02029ba:	aa07ab23          	sw	zero,-1354(a5) # ffffffffc021146c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02029be:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc02029c0:	0000f797          	auipc	a5,0xf
ffffffffc02029c4:	aac78793          	addi	a5,a5,-1364 # ffffffffc021146c <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc02029c8:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc02029cc:	4398                	lw	a4,0(a5)
ffffffffc02029ce:	4585                	li	a1,1
ffffffffc02029d0:	2701                	sext.w	a4,a4
ffffffffc02029d2:	30b71663          	bne	a4,a1,ffffffffc0202cde <swap_init+0x500>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc02029d6:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc02029da:	4394                	lw	a3,0(a5)
ffffffffc02029dc:	2681                	sext.w	a3,a3
ffffffffc02029de:	32e69063          	bne	a3,a4,ffffffffc0202cfe <swap_init+0x520>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc02029e2:	6689                	lui	a3,0x2
ffffffffc02029e4:	462d                	li	a2,11
ffffffffc02029e6:	00c68023          	sb	a2,0(a3) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc02029ea:	4398                	lw	a4,0(a5)
ffffffffc02029ec:	4589                	li	a1,2
ffffffffc02029ee:	2701                	sext.w	a4,a4
ffffffffc02029f0:	26b71763          	bne	a4,a1,ffffffffc0202c5e <swap_init+0x480>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc02029f4:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc02029f8:	4394                	lw	a3,0(a5)
ffffffffc02029fa:	2681                	sext.w	a3,a3
ffffffffc02029fc:	28e69163          	bne	a3,a4,ffffffffc0202c7e <swap_init+0x4a0>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202a00:	668d                	lui	a3,0x3
ffffffffc0202a02:	4631                	li	a2,12
ffffffffc0202a04:	00c68023          	sb	a2,0(a3) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202a08:	4398                	lw	a4,0(a5)
ffffffffc0202a0a:	458d                	li	a1,3
ffffffffc0202a0c:	2701                	sext.w	a4,a4
ffffffffc0202a0e:	28b71863          	bne	a4,a1,ffffffffc0202c9e <swap_init+0x4c0>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202a12:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc0202a16:	4394                	lw	a3,0(a5)
ffffffffc0202a18:	2681                	sext.w	a3,a3
ffffffffc0202a1a:	2ae69263          	bne	a3,a4,ffffffffc0202cbe <swap_init+0x4e0>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202a1e:	6691                	lui	a3,0x4
ffffffffc0202a20:	4635                	li	a2,13
ffffffffc0202a22:	00c68023          	sb	a2,0(a3) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202a26:	4398                	lw	a4,0(a5)
ffffffffc0202a28:	2701                	sext.w	a4,a4
ffffffffc0202a2a:	33a71a63          	bne	a4,s10,ffffffffc0202d5e <swap_init+0x580>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202a2e:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc0202a32:	439c                	lw	a5,0(a5)
ffffffffc0202a34:	2781                	sext.w	a5,a5
ffffffffc0202a36:	34e79463          	bne	a5,a4,ffffffffc0202d7e <swap_init+0x5a0>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202a3a:	481c                	lw	a5,16(s0)
ffffffffc0202a3c:	36079163          	bnez	a5,ffffffffc0202d9e <swap_init+0x5c0>
ffffffffc0202a40:	0000f797          	auipc	a5,0xf
ffffffffc0202a44:	a9078793          	addi	a5,a5,-1392 # ffffffffc02114d0 <swap_in_seq_no>
ffffffffc0202a48:	0000f717          	auipc	a4,0xf
ffffffffc0202a4c:	ab070713          	addi	a4,a4,-1360 # ffffffffc02114f8 <swap_out_seq_no>
ffffffffc0202a50:	0000f617          	auipc	a2,0xf
ffffffffc0202a54:	aa860613          	addi	a2,a2,-1368 # ffffffffc02114f8 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202a58:	56fd                	li	a3,-1
ffffffffc0202a5a:	c394                	sw	a3,0(a5)
ffffffffc0202a5c:	c314                	sw	a3,0(a4)
ffffffffc0202a5e:	0791                	addi	a5,a5,4
ffffffffc0202a60:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202a62:	fec79ce3          	bne	a5,a2,ffffffffc0202a5a <swap_init+0x27c>
ffffffffc0202a66:	0000f697          	auipc	a3,0xf
ffffffffc0202a6a:	af268693          	addi	a3,a3,-1294 # ffffffffc0211558 <check_ptep>
ffffffffc0202a6e:	0000f817          	auipc	a6,0xf
ffffffffc0202a72:	a4280813          	addi	a6,a6,-1470 # ffffffffc02114b0 <check_rp>
ffffffffc0202a76:	6c05                	lui	s8,0x1
    if (PPN(pa) >= npage) {
ffffffffc0202a78:	0000fc97          	auipc	s9,0xf
ffffffffc0202a7c:	9e0c8c93          	addi	s9,s9,-1568 # ffffffffc0211458 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a80:	0000fd97          	auipc	s11,0xf
ffffffffc0202a84:	a28d8d93          	addi	s11,s11,-1496 # ffffffffc02114a8 <pages>
ffffffffc0202a88:	00003d17          	auipc	s10,0x3
ffffffffc0202a8c:	6a0d0d13          	addi	s10,s10,1696 # ffffffffc0206128 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202a90:	6562                	ld	a0,24(sp)
         check_ptep[i]=0;
ffffffffc0202a92:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202a96:	4601                	li	a2,0
ffffffffc0202a98:	85e2                	mv	a1,s8
ffffffffc0202a9a:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0202a9c:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202a9e:	caffe0ef          	jal	ra,ffffffffc020174c <get_pte>
ffffffffc0202aa2:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202aa4:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202aa6:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc0202aa8:	16050f63          	beqz	a0,ffffffffc0202c26 <swap_init+0x448>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202aac:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202aae:	0017f613          	andi	a2,a5,1
ffffffffc0202ab2:	10060263          	beqz	a2,ffffffffc0202bb6 <swap_init+0x3d8>
    if (PPN(pa) >= npage) {
ffffffffc0202ab6:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202aba:	078a                	slli	a5,a5,0x2
ffffffffc0202abc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202abe:	10c7f863          	bgeu	a5,a2,ffffffffc0202bce <swap_init+0x3f0>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ac2:	000d3603          	ld	a2,0(s10)
ffffffffc0202ac6:	000db583          	ld	a1,0(s11)
ffffffffc0202aca:	00083503          	ld	a0,0(a6)
ffffffffc0202ace:	8f91                	sub	a5,a5,a2
ffffffffc0202ad0:	00379613          	slli	a2,a5,0x3
ffffffffc0202ad4:	97b2                	add	a5,a5,a2
ffffffffc0202ad6:	078e                	slli	a5,a5,0x3
ffffffffc0202ad8:	97ae                	add	a5,a5,a1
ffffffffc0202ada:	0af51e63          	bne	a0,a5,ffffffffc0202b96 <swap_init+0x3b8>
ffffffffc0202ade:	6785                	lui	a5,0x1
ffffffffc0202ae0:	9c3e                	add	s8,s8,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202ae2:	6795                	lui	a5,0x5
ffffffffc0202ae4:	06a1                	addi	a3,a3,8
ffffffffc0202ae6:	0821                	addi	a6,a6,8
ffffffffc0202ae8:	fafc14e3          	bne	s8,a5,ffffffffc0202a90 <swap_init+0x2b2>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202aec:	00003517          	auipc	a0,0x3
ffffffffc0202af0:	ebc50513          	addi	a0,a0,-324 # ffffffffc02059a8 <default_pmm_manager+0x928>
ffffffffc0202af4:	dcafd0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = sm->check_swap();
ffffffffc0202af8:	0000f797          	auipc	a5,0xf
ffffffffc0202afc:	96878793          	addi	a5,a5,-1688 # ffffffffc0211460 <sm>
ffffffffc0202b00:	639c                	ld	a5,0(a5)
ffffffffc0202b02:	7f9c                	ld	a5,56(a5)
ffffffffc0202b04:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202b06:	2a051c63          	bnez	a0,ffffffffc0202dbe <swap_init+0x5e0>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202b0a:	000a3503          	ld	a0,0(s4)
ffffffffc0202b0e:	4585                	li	a1,1
ffffffffc0202b10:	0a21                	addi	s4,s4,8
ffffffffc0202b12:	bb5fe0ef          	jal	ra,ffffffffc02016c6 <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b16:	ff5a1ae3          	bne	s4,s5,ffffffffc0202b0a <swap_init+0x32c>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202b1a:	855e                	mv	a0,s7
ffffffffc0202b1c:	2c5000ef          	jal	ra,ffffffffc02035e0 <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0202b20:	77a2                	ld	a5,40(sp)
ffffffffc0202b22:	0000f717          	auipc	a4,0xf
ffffffffc0202b26:	96f72323          	sw	a5,-1690(a4) # ffffffffc0211488 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0202b2a:	7782                	ld	a5,32(sp)
ffffffffc0202b2c:	0000f717          	auipc	a4,0xf
ffffffffc0202b30:	94f73623          	sd	a5,-1716(a4) # ffffffffc0211478 <free_area>
ffffffffc0202b34:	0000f797          	auipc	a5,0xf
ffffffffc0202b38:	9537b623          	sd	s3,-1716(a5) # ffffffffc0211480 <free_area+0x8>

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202b3c:	00898a63          	beq	s3,s0,ffffffffc0202b50 <swap_init+0x372>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202b40:	ff89a783          	lw	a5,-8(s3)
    return listelm->next;
ffffffffc0202b44:	0089b983          	ld	s3,8(s3)
ffffffffc0202b48:	397d                	addiw	s2,s2,-1
ffffffffc0202b4a:	9c9d                	subw	s1,s1,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202b4c:	fe899ae3          	bne	s3,s0,ffffffffc0202b40 <swap_init+0x362>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0202b50:	8626                	mv	a2,s1
ffffffffc0202b52:	85ca                	mv	a1,s2
ffffffffc0202b54:	00003517          	auipc	a0,0x3
ffffffffc0202b58:	e8450513          	addi	a0,a0,-380 # ffffffffc02059d8 <default_pmm_manager+0x958>
ffffffffc0202b5c:	d62fd0ef          	jal	ra,ffffffffc02000be <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0202b60:	00003517          	auipc	a0,0x3
ffffffffc0202b64:	e9850513          	addi	a0,a0,-360 # ffffffffc02059f8 <default_pmm_manager+0x978>
ffffffffc0202b68:	d56fd0ef          	jal	ra,ffffffffc02000be <cprintf>
ffffffffc0202b6c:	b1c9                	j	ffffffffc020282e <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0202b6e:	4481                	li	s1,0
ffffffffc0202b70:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202b72:	4981                	li	s3,0
ffffffffc0202b74:	bb1d                	j	ffffffffc02028aa <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0202b76:	00002697          	auipc	a3,0x2
ffffffffc0202b7a:	16268693          	addi	a3,a3,354 # ffffffffc0204cd8 <commands+0x860>
ffffffffc0202b7e:	00002617          	auipc	a2,0x2
ffffffffc0202b82:	16a60613          	addi	a2,a2,362 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202b86:	0bd00593          	li	a1,189
ffffffffc0202b8a:	00003517          	auipc	a0,0x3
ffffffffc0202b8e:	c0650513          	addi	a0,a0,-1018 # ffffffffc0205790 <default_pmm_manager+0x710>
ffffffffc0202b92:	fdefd0ef          	jal	ra,ffffffffc0200370 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202b96:	00003697          	auipc	a3,0x3
ffffffffc0202b9a:	dea68693          	addi	a3,a3,-534 # ffffffffc0205980 <default_pmm_manager+0x900>
ffffffffc0202b9e:	00002617          	auipc	a2,0x2
ffffffffc0202ba2:	14a60613          	addi	a2,a2,330 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202ba6:	0fd00593          	li	a1,253
ffffffffc0202baa:	00003517          	auipc	a0,0x3
ffffffffc0202bae:	be650513          	addi	a0,a0,-1050 # ffffffffc0205790 <default_pmm_manager+0x710>
ffffffffc0202bb2:	fbefd0ef          	jal	ra,ffffffffc0200370 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202bb6:	00002617          	auipc	a2,0x2
ffffffffc0202bba:	78a60613          	addi	a2,a2,1930 # ffffffffc0205340 <default_pmm_manager+0x2c0>
ffffffffc0202bbe:	07000593          	li	a1,112
ffffffffc0202bc2:	00002517          	auipc	a0,0x2
ffffffffc0202bc6:	5a650513          	addi	a0,a0,1446 # ffffffffc0205168 <default_pmm_manager+0xe8>
ffffffffc0202bca:	fa6fd0ef          	jal	ra,ffffffffc0200370 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202bce:	00002617          	auipc	a2,0x2
ffffffffc0202bd2:	57a60613          	addi	a2,a2,1402 # ffffffffc0205148 <default_pmm_manager+0xc8>
ffffffffc0202bd6:	06500593          	li	a1,101
ffffffffc0202bda:	00002517          	auipc	a0,0x2
ffffffffc0202bde:	58e50513          	addi	a0,a0,1422 # ffffffffc0205168 <default_pmm_manager+0xe8>
ffffffffc0202be2:	f8efd0ef          	jal	ra,ffffffffc0200370 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202be6:	00003697          	auipc	a3,0x3
ffffffffc0202bea:	cd268693          	addi	a3,a3,-814 # ffffffffc02058b8 <default_pmm_manager+0x838>
ffffffffc0202bee:	00002617          	auipc	a2,0x2
ffffffffc0202bf2:	0fa60613          	addi	a2,a2,250 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202bf6:	0de00593          	li	a1,222
ffffffffc0202bfa:	00003517          	auipc	a0,0x3
ffffffffc0202bfe:	b9650513          	addi	a0,a0,-1130 # ffffffffc0205790 <default_pmm_manager+0x710>
ffffffffc0202c02:	f6efd0ef          	jal	ra,ffffffffc0200370 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202c06:	00003697          	auipc	a3,0x3
ffffffffc0202c0a:	c9a68693          	addi	a3,a3,-870 # ffffffffc02058a0 <default_pmm_manager+0x820>
ffffffffc0202c0e:	00002617          	auipc	a2,0x2
ffffffffc0202c12:	0da60613          	addi	a2,a2,218 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202c16:	0dd00593          	li	a1,221
ffffffffc0202c1a:	00003517          	auipc	a0,0x3
ffffffffc0202c1e:	b7650513          	addi	a0,a0,-1162 # ffffffffc0205790 <default_pmm_manager+0x710>
ffffffffc0202c22:	f4efd0ef          	jal	ra,ffffffffc0200370 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202c26:	00003697          	auipc	a3,0x3
ffffffffc0202c2a:	d4268693          	addi	a3,a3,-702 # ffffffffc0205968 <default_pmm_manager+0x8e8>
ffffffffc0202c2e:	00002617          	auipc	a2,0x2
ffffffffc0202c32:	0ba60613          	addi	a2,a2,186 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202c36:	0fc00593          	li	a1,252
ffffffffc0202c3a:	00003517          	auipc	a0,0x3
ffffffffc0202c3e:	b5650513          	addi	a0,a0,-1194 # ffffffffc0205790 <default_pmm_manager+0x710>
ffffffffc0202c42:	f2efd0ef          	jal	ra,ffffffffc0200370 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202c46:	00003617          	auipc	a2,0x3
ffffffffc0202c4a:	b2a60613          	addi	a2,a2,-1238 # ffffffffc0205770 <default_pmm_manager+0x6f0>
ffffffffc0202c4e:	02800593          	li	a1,40
ffffffffc0202c52:	00003517          	auipc	a0,0x3
ffffffffc0202c56:	b3e50513          	addi	a0,a0,-1218 # ffffffffc0205790 <default_pmm_manager+0x710>
ffffffffc0202c5a:	f16fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(pgfault_num==2);
ffffffffc0202c5e:	00003697          	auipc	a3,0x3
ffffffffc0202c62:	cda68693          	addi	a3,a3,-806 # ffffffffc0205938 <default_pmm_manager+0x8b8>
ffffffffc0202c66:	00002617          	auipc	a2,0x2
ffffffffc0202c6a:	08260613          	addi	a2,a2,130 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202c6e:	09800593          	li	a1,152
ffffffffc0202c72:	00003517          	auipc	a0,0x3
ffffffffc0202c76:	b1e50513          	addi	a0,a0,-1250 # ffffffffc0205790 <default_pmm_manager+0x710>
ffffffffc0202c7a:	ef6fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(pgfault_num==2);
ffffffffc0202c7e:	00003697          	auipc	a3,0x3
ffffffffc0202c82:	cba68693          	addi	a3,a3,-838 # ffffffffc0205938 <default_pmm_manager+0x8b8>
ffffffffc0202c86:	00002617          	auipc	a2,0x2
ffffffffc0202c8a:	06260613          	addi	a2,a2,98 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202c8e:	09a00593          	li	a1,154
ffffffffc0202c92:	00003517          	auipc	a0,0x3
ffffffffc0202c96:	afe50513          	addi	a0,a0,-1282 # ffffffffc0205790 <default_pmm_manager+0x710>
ffffffffc0202c9a:	ed6fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(pgfault_num==3);
ffffffffc0202c9e:	00003697          	auipc	a3,0x3
ffffffffc0202ca2:	caa68693          	addi	a3,a3,-854 # ffffffffc0205948 <default_pmm_manager+0x8c8>
ffffffffc0202ca6:	00002617          	auipc	a2,0x2
ffffffffc0202caa:	04260613          	addi	a2,a2,66 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202cae:	09c00593          	li	a1,156
ffffffffc0202cb2:	00003517          	auipc	a0,0x3
ffffffffc0202cb6:	ade50513          	addi	a0,a0,-1314 # ffffffffc0205790 <default_pmm_manager+0x710>
ffffffffc0202cba:	eb6fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(pgfault_num==3);
ffffffffc0202cbe:	00003697          	auipc	a3,0x3
ffffffffc0202cc2:	c8a68693          	addi	a3,a3,-886 # ffffffffc0205948 <default_pmm_manager+0x8c8>
ffffffffc0202cc6:	00002617          	auipc	a2,0x2
ffffffffc0202cca:	02260613          	addi	a2,a2,34 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202cce:	09e00593          	li	a1,158
ffffffffc0202cd2:	00003517          	auipc	a0,0x3
ffffffffc0202cd6:	abe50513          	addi	a0,a0,-1346 # ffffffffc0205790 <default_pmm_manager+0x710>
ffffffffc0202cda:	e96fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(pgfault_num==1);
ffffffffc0202cde:	00003697          	auipc	a3,0x3
ffffffffc0202ce2:	c4a68693          	addi	a3,a3,-950 # ffffffffc0205928 <default_pmm_manager+0x8a8>
ffffffffc0202ce6:	00002617          	auipc	a2,0x2
ffffffffc0202cea:	00260613          	addi	a2,a2,2 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202cee:	09400593          	li	a1,148
ffffffffc0202cf2:	00003517          	auipc	a0,0x3
ffffffffc0202cf6:	a9e50513          	addi	a0,a0,-1378 # ffffffffc0205790 <default_pmm_manager+0x710>
ffffffffc0202cfa:	e76fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(pgfault_num==1);
ffffffffc0202cfe:	00003697          	auipc	a3,0x3
ffffffffc0202d02:	c2a68693          	addi	a3,a3,-982 # ffffffffc0205928 <default_pmm_manager+0x8a8>
ffffffffc0202d06:	00002617          	auipc	a2,0x2
ffffffffc0202d0a:	fe260613          	addi	a2,a2,-30 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202d0e:	09600593          	li	a1,150
ffffffffc0202d12:	00003517          	auipc	a0,0x3
ffffffffc0202d16:	a7e50513          	addi	a0,a0,-1410 # ffffffffc0205790 <default_pmm_manager+0x710>
ffffffffc0202d1a:	e56fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202d1e:	00003697          	auipc	a3,0x3
ffffffffc0202d22:	bba68693          	addi	a3,a3,-1094 # ffffffffc02058d8 <default_pmm_manager+0x858>
ffffffffc0202d26:	00002617          	auipc	a2,0x2
ffffffffc0202d2a:	fc260613          	addi	a2,a2,-62 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202d2e:	0eb00593          	li	a1,235
ffffffffc0202d32:	00003517          	auipc	a0,0x3
ffffffffc0202d36:	a5e50513          	addi	a0,a0,-1442 # ffffffffc0205790 <default_pmm_manager+0x710>
ffffffffc0202d3a:	e36fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202d3e:	00003697          	auipc	a3,0x3
ffffffffc0202d42:	b2268693          	addi	a3,a3,-1246 # ffffffffc0205860 <default_pmm_manager+0x7e0>
ffffffffc0202d46:	00002617          	auipc	a2,0x2
ffffffffc0202d4a:	fa260613          	addi	a2,a2,-94 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202d4e:	0d800593          	li	a1,216
ffffffffc0202d52:	00003517          	auipc	a0,0x3
ffffffffc0202d56:	a3e50513          	addi	a0,a0,-1474 # ffffffffc0205790 <default_pmm_manager+0x710>
ffffffffc0202d5a:	e16fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(pgfault_num==4);
ffffffffc0202d5e:	00003697          	auipc	a3,0x3
ffffffffc0202d62:	bfa68693          	addi	a3,a3,-1030 # ffffffffc0205958 <default_pmm_manager+0x8d8>
ffffffffc0202d66:	00002617          	auipc	a2,0x2
ffffffffc0202d6a:	f8260613          	addi	a2,a2,-126 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202d6e:	0a000593          	li	a1,160
ffffffffc0202d72:	00003517          	auipc	a0,0x3
ffffffffc0202d76:	a1e50513          	addi	a0,a0,-1506 # ffffffffc0205790 <default_pmm_manager+0x710>
ffffffffc0202d7a:	df6fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(pgfault_num==4);
ffffffffc0202d7e:	00003697          	auipc	a3,0x3
ffffffffc0202d82:	bda68693          	addi	a3,a3,-1062 # ffffffffc0205958 <default_pmm_manager+0x8d8>
ffffffffc0202d86:	00002617          	auipc	a2,0x2
ffffffffc0202d8a:	f6260613          	addi	a2,a2,-158 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202d8e:	0a200593          	li	a1,162
ffffffffc0202d92:	00003517          	auipc	a0,0x3
ffffffffc0202d96:	9fe50513          	addi	a0,a0,-1538 # ffffffffc0205790 <default_pmm_manager+0x710>
ffffffffc0202d9a:	dd6fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert( nr_free == 0);         
ffffffffc0202d9e:	00002697          	auipc	a3,0x2
ffffffffc0202da2:	12268693          	addi	a3,a3,290 # ffffffffc0204ec0 <commands+0xa48>
ffffffffc0202da6:	00002617          	auipc	a2,0x2
ffffffffc0202daa:	f4260613          	addi	a2,a2,-190 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202dae:	0f400593          	li	a1,244
ffffffffc0202db2:	00003517          	auipc	a0,0x3
ffffffffc0202db6:	9de50513          	addi	a0,a0,-1570 # ffffffffc0205790 <default_pmm_manager+0x710>
ffffffffc0202dba:	db6fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(ret==0);
ffffffffc0202dbe:	00003697          	auipc	a3,0x3
ffffffffc0202dc2:	c1268693          	addi	a3,a3,-1006 # ffffffffc02059d0 <default_pmm_manager+0x950>
ffffffffc0202dc6:	00002617          	auipc	a2,0x2
ffffffffc0202dca:	f2260613          	addi	a2,a2,-222 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202dce:	10300593          	li	a1,259
ffffffffc0202dd2:	00003517          	auipc	a0,0x3
ffffffffc0202dd6:	9be50513          	addi	a0,a0,-1602 # ffffffffc0205790 <default_pmm_manager+0x710>
ffffffffc0202dda:	d96fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(mm != NULL);
ffffffffc0202dde:	00003697          	auipc	a3,0x3
ffffffffc0202de2:	a0268693          	addi	a3,a3,-1534 # ffffffffc02057e0 <default_pmm_manager+0x760>
ffffffffc0202de6:	00002617          	auipc	a2,0x2
ffffffffc0202dea:	f0260613          	addi	a2,a2,-254 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202dee:	0c500593          	li	a1,197
ffffffffc0202df2:	00003517          	auipc	a0,0x3
ffffffffc0202df6:	99e50513          	addi	a0,a0,-1634 # ffffffffc0205790 <default_pmm_manager+0x710>
ffffffffc0202dfa:	d76fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0202dfe:	00003697          	auipc	a3,0x3
ffffffffc0202e02:	9f268693          	addi	a3,a3,-1550 # ffffffffc02057f0 <default_pmm_manager+0x770>
ffffffffc0202e06:	00002617          	auipc	a2,0x2
ffffffffc0202e0a:	ee260613          	addi	a2,a2,-286 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202e0e:	0c800593          	li	a1,200
ffffffffc0202e12:	00003517          	auipc	a0,0x3
ffffffffc0202e16:	97e50513          	addi	a0,a0,-1666 # ffffffffc0205790 <default_pmm_manager+0x710>
ffffffffc0202e1a:	d56fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202e1e:	00003697          	auipc	a3,0x3
ffffffffc0202e22:	9ea68693          	addi	a3,a3,-1558 # ffffffffc0205808 <default_pmm_manager+0x788>
ffffffffc0202e26:	00002617          	auipc	a2,0x2
ffffffffc0202e2a:	ec260613          	addi	a2,a2,-318 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202e2e:	0cd00593          	li	a1,205
ffffffffc0202e32:	00003517          	auipc	a0,0x3
ffffffffc0202e36:	95e50513          	addi	a0,a0,-1698 # ffffffffc0205790 <default_pmm_manager+0x710>
ffffffffc0202e3a:	d36fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(vma != NULL);
ffffffffc0202e3e:	00003697          	auipc	a3,0x3
ffffffffc0202e42:	9da68693          	addi	a3,a3,-1574 # ffffffffc0205818 <default_pmm_manager+0x798>
ffffffffc0202e46:	00002617          	auipc	a2,0x2
ffffffffc0202e4a:	ea260613          	addi	a2,a2,-350 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202e4e:	0d000593          	li	a1,208
ffffffffc0202e52:	00003517          	auipc	a0,0x3
ffffffffc0202e56:	93e50513          	addi	a0,a0,-1730 # ffffffffc0205790 <default_pmm_manager+0x710>
ffffffffc0202e5a:	d16fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202e5e:	00002697          	auipc	a3,0x2
ffffffffc0202e62:	eba68693          	addi	a3,a3,-326 # ffffffffc0204d18 <commands+0x8a0>
ffffffffc0202e66:	00002617          	auipc	a2,0x2
ffffffffc0202e6a:	e8260613          	addi	a2,a2,-382 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202e6e:	0c000593          	li	a1,192
ffffffffc0202e72:	00003517          	auipc	a0,0x3
ffffffffc0202e76:	91e50513          	addi	a0,a0,-1762 # ffffffffc0205790 <default_pmm_manager+0x710>
ffffffffc0202e7a:	cf6fd0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0202e7e <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0202e7e:	0000e797          	auipc	a5,0xe
ffffffffc0202e82:	5e278793          	addi	a5,a5,1506 # ffffffffc0211460 <sm>
ffffffffc0202e86:	639c                	ld	a5,0(a5)
ffffffffc0202e88:	0107b303          	ld	t1,16(a5)
ffffffffc0202e8c:	8302                	jr	t1

ffffffffc0202e8e <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0202e8e:	0000e797          	auipc	a5,0xe
ffffffffc0202e92:	5d278793          	addi	a5,a5,1490 # ffffffffc0211460 <sm>
ffffffffc0202e96:	639c                	ld	a5,0(a5)
ffffffffc0202e98:	0207b303          	ld	t1,32(a5)
ffffffffc0202e9c:	8302                	jr	t1

ffffffffc0202e9e <swap_out>:
{
ffffffffc0202e9e:	711d                	addi	sp,sp,-96
ffffffffc0202ea0:	ec86                	sd	ra,88(sp)
ffffffffc0202ea2:	e8a2                	sd	s0,80(sp)
ffffffffc0202ea4:	e4a6                	sd	s1,72(sp)
ffffffffc0202ea6:	e0ca                	sd	s2,64(sp)
ffffffffc0202ea8:	fc4e                	sd	s3,56(sp)
ffffffffc0202eaa:	f852                	sd	s4,48(sp)
ffffffffc0202eac:	f456                	sd	s5,40(sp)
ffffffffc0202eae:	f05a                	sd	s6,32(sp)
ffffffffc0202eb0:	ec5e                	sd	s7,24(sp)
ffffffffc0202eb2:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0202eb4:	cde9                	beqz	a1,ffffffffc0202f8e <swap_out+0xf0>
ffffffffc0202eb6:	8ab2                	mv	s5,a2
ffffffffc0202eb8:	892a                	mv	s2,a0
ffffffffc0202eba:	8a2e                	mv	s4,a1
ffffffffc0202ebc:	4401                	li	s0,0
ffffffffc0202ebe:	0000e997          	auipc	s3,0xe
ffffffffc0202ec2:	5a298993          	addi	s3,s3,1442 # ffffffffc0211460 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202ec6:	00003b17          	auipc	s6,0x3
ffffffffc0202eca:	bb2b0b13          	addi	s6,s6,-1102 # ffffffffc0205a78 <default_pmm_manager+0x9f8>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202ece:	00003b97          	auipc	s7,0x3
ffffffffc0202ed2:	b92b8b93          	addi	s7,s7,-1134 # ffffffffc0205a60 <default_pmm_manager+0x9e0>
ffffffffc0202ed6:	a825                	j	ffffffffc0202f0e <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202ed8:	67a2                	ld	a5,8(sp)
ffffffffc0202eda:	8626                	mv	a2,s1
ffffffffc0202edc:	85a2                	mv	a1,s0
ffffffffc0202ede:	63b4                	ld	a3,64(a5)
ffffffffc0202ee0:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0202ee2:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0202ee4:	82b1                	srli	a3,a3,0xc
ffffffffc0202ee6:	0685                	addi	a3,a3,1
ffffffffc0202ee8:	9d6fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202eec:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0202eee:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0202ef0:	613c                	ld	a5,64(a0)
ffffffffc0202ef2:	83b1                	srli	a5,a5,0xc
ffffffffc0202ef4:	0785                	addi	a5,a5,1
ffffffffc0202ef6:	07a2                	slli	a5,a5,0x8
ffffffffc0202ef8:	00fc3023          	sd	a5,0(s8) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
                    free_page(page);
ffffffffc0202efc:	fcafe0ef          	jal	ra,ffffffffc02016c6 <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0202f00:	01893503          	ld	a0,24(s2)
ffffffffc0202f04:	85a6                	mv	a1,s1
ffffffffc0202f06:	ebeff0ef          	jal	ra,ffffffffc02025c4 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0202f0a:	048a0d63          	beq	s4,s0,ffffffffc0202f64 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0202f0e:	0009b783          	ld	a5,0(s3)
ffffffffc0202f12:	8656                	mv	a2,s5
ffffffffc0202f14:	002c                	addi	a1,sp,8
ffffffffc0202f16:	7b9c                	ld	a5,48(a5)
ffffffffc0202f18:	854a                	mv	a0,s2
ffffffffc0202f1a:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0202f1c:	e12d                	bnez	a0,ffffffffc0202f7e <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0202f1e:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202f20:	01893503          	ld	a0,24(s2)
ffffffffc0202f24:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0202f26:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202f28:	85a6                	mv	a1,s1
ffffffffc0202f2a:	823fe0ef          	jal	ra,ffffffffc020174c <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202f2e:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0202f30:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0202f32:	8b85                	andi	a5,a5,1
ffffffffc0202f34:	cfb9                	beqz	a5,ffffffffc0202f92 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0202f36:	65a2                	ld	a1,8(sp)
ffffffffc0202f38:	61bc                	ld	a5,64(a1)
ffffffffc0202f3a:	83b1                	srli	a5,a5,0xc
ffffffffc0202f3c:	00178513          	addi	a0,a5,1
ffffffffc0202f40:	0522                	slli	a0,a0,0x8
ffffffffc0202f42:	5f5000ef          	jal	ra,ffffffffc0203d36 <swapfs_write>
ffffffffc0202f46:	d949                	beqz	a0,ffffffffc0202ed8 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0202f48:	855e                	mv	a0,s7
ffffffffc0202f4a:	974fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202f4e:	0009b783          	ld	a5,0(s3)
ffffffffc0202f52:	6622                	ld	a2,8(sp)
ffffffffc0202f54:	4681                	li	a3,0
ffffffffc0202f56:	739c                	ld	a5,32(a5)
ffffffffc0202f58:	85a6                	mv	a1,s1
ffffffffc0202f5a:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0202f5c:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0202f5e:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0202f60:	fa8a17e3          	bne	s4,s0,ffffffffc0202f0e <swap_out+0x70>
}
ffffffffc0202f64:	8522                	mv	a0,s0
ffffffffc0202f66:	60e6                	ld	ra,88(sp)
ffffffffc0202f68:	6446                	ld	s0,80(sp)
ffffffffc0202f6a:	64a6                	ld	s1,72(sp)
ffffffffc0202f6c:	6906                	ld	s2,64(sp)
ffffffffc0202f6e:	79e2                	ld	s3,56(sp)
ffffffffc0202f70:	7a42                	ld	s4,48(sp)
ffffffffc0202f72:	7aa2                	ld	s5,40(sp)
ffffffffc0202f74:	7b02                	ld	s6,32(sp)
ffffffffc0202f76:	6be2                	ld	s7,24(sp)
ffffffffc0202f78:	6c42                	ld	s8,16(sp)
ffffffffc0202f7a:	6125                	addi	sp,sp,96
ffffffffc0202f7c:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0202f7e:	85a2                	mv	a1,s0
ffffffffc0202f80:	00003517          	auipc	a0,0x3
ffffffffc0202f84:	a9850513          	addi	a0,a0,-1384 # ffffffffc0205a18 <default_pmm_manager+0x998>
ffffffffc0202f88:	936fd0ef          	jal	ra,ffffffffc02000be <cprintf>
                  break;
ffffffffc0202f8c:	bfe1                	j	ffffffffc0202f64 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0202f8e:	4401                	li	s0,0
ffffffffc0202f90:	bfd1                	j	ffffffffc0202f64 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0202f92:	00003697          	auipc	a3,0x3
ffffffffc0202f96:	ab668693          	addi	a3,a3,-1354 # ffffffffc0205a48 <default_pmm_manager+0x9c8>
ffffffffc0202f9a:	00002617          	auipc	a2,0x2
ffffffffc0202f9e:	d4e60613          	addi	a2,a2,-690 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0202fa2:	06900593          	li	a1,105
ffffffffc0202fa6:	00002517          	auipc	a0,0x2
ffffffffc0202faa:	7ea50513          	addi	a0,a0,2026 # ffffffffc0205790 <default_pmm_manager+0x710>
ffffffffc0202fae:	bc2fd0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0202fb2 <swap_in>:
{
ffffffffc0202fb2:	7179                	addi	sp,sp,-48
ffffffffc0202fb4:	e84a                	sd	s2,16(sp)
ffffffffc0202fb6:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0202fb8:	4505                	li	a0,1
{
ffffffffc0202fba:	ec26                	sd	s1,24(sp)
ffffffffc0202fbc:	e44e                	sd	s3,8(sp)
ffffffffc0202fbe:	f406                	sd	ra,40(sp)
ffffffffc0202fc0:	f022                	sd	s0,32(sp)
ffffffffc0202fc2:	84ae                	mv	s1,a1
ffffffffc0202fc4:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0202fc6:	e78fe0ef          	jal	ra,ffffffffc020163e <alloc_pages>
     assert(result!=NULL);
ffffffffc0202fca:	c129                	beqz	a0,ffffffffc020300c <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0202fcc:	842a                	mv	s0,a0
ffffffffc0202fce:	01893503          	ld	a0,24(s2)
ffffffffc0202fd2:	4601                	li	a2,0
ffffffffc0202fd4:	85a6                	mv	a1,s1
ffffffffc0202fd6:	f76fe0ef          	jal	ra,ffffffffc020174c <get_pte>
ffffffffc0202fda:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0202fdc:	6108                	ld	a0,0(a0)
ffffffffc0202fde:	85a2                	mv	a1,s0
ffffffffc0202fe0:	4b1000ef          	jal	ra,ffffffffc0203c90 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0202fe4:	00093583          	ld	a1,0(s2)
ffffffffc0202fe8:	8626                	mv	a2,s1
ffffffffc0202fea:	00002517          	auipc	a0,0x2
ffffffffc0202fee:	74650513          	addi	a0,a0,1862 # ffffffffc0205730 <default_pmm_manager+0x6b0>
ffffffffc0202ff2:	81a1                	srli	a1,a1,0x8
ffffffffc0202ff4:	8cafd0ef          	jal	ra,ffffffffc02000be <cprintf>
}
ffffffffc0202ff8:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0202ffa:	0089b023          	sd	s0,0(s3)
}
ffffffffc0202ffe:	7402                	ld	s0,32(sp)
ffffffffc0203000:	64e2                	ld	s1,24(sp)
ffffffffc0203002:	6942                	ld	s2,16(sp)
ffffffffc0203004:	69a2                	ld	s3,8(sp)
ffffffffc0203006:	4501                	li	a0,0
ffffffffc0203008:	6145                	addi	sp,sp,48
ffffffffc020300a:	8082                	ret
     assert(result!=NULL);
ffffffffc020300c:	00002697          	auipc	a3,0x2
ffffffffc0203010:	71468693          	addi	a3,a3,1812 # ffffffffc0205720 <default_pmm_manager+0x6a0>
ffffffffc0203014:	00002617          	auipc	a2,0x2
ffffffffc0203018:	cd460613          	addi	a2,a2,-812 # ffffffffc0204ce8 <commands+0x870>
ffffffffc020301c:	07f00593          	li	a1,127
ffffffffc0203020:	00002517          	auipc	a0,0x2
ffffffffc0203024:	77050513          	addi	a0,a0,1904 # ffffffffc0205790 <default_pmm_manager+0x710>
ffffffffc0203028:	b48fd0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc020302c <_lru_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc020302c:	0000e797          	auipc	a5,0xe
ffffffffc0203030:	54c78793          	addi	a5,a5,1356 # ffffffffc0211578 <pra_list_head2>
static int
_lru_init_mm(struct mm_struct *mm)
{     

    list_init(&pra_list_head2);
    mm->sm_priv = &pra_list_head2;
ffffffffc0203034:	f51c                	sd	a5,40(a0)
ffffffffc0203036:	e79c                	sd	a5,8(a5)
ffffffffc0203038:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc020303a:	4501                	li	a0,0
ffffffffc020303c:	8082                	ret

ffffffffc020303e <_lru_init>:

static int
_lru_init(void)
{
    return 0;
}
ffffffffc020303e:	4501                	li	a0,0
ffffffffc0203040:	8082                	ret

ffffffffc0203042 <_lru_set_unswappable>:

static int
_lru_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203042:	4501                	li	a0,0
ffffffffc0203044:	8082                	ret

ffffffffc0203046 <_lru_tick_event>:

static int
_lru_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203046:	4501                	li	a0,0
ffffffffc0203048:	8082                	ret

ffffffffc020304a <_lru_check_swap>:
_lru_check_swap(void) {
ffffffffc020304a:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020304c:	678d                	lui	a5,0x3
ffffffffc020304e:	4731                	li	a4,12
_lru_check_swap(void) {
ffffffffc0203050:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203052:	00e78023          	sb	a4,0(a5) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0203056:	0000e797          	auipc	a5,0xe
ffffffffc020305a:	41678793          	addi	a5,a5,1046 # ffffffffc021146c <pgfault_num>
ffffffffc020305e:	4398                	lw	a4,0(a5)
ffffffffc0203060:	4691                	li	a3,4
ffffffffc0203062:	2701                	sext.w	a4,a4
ffffffffc0203064:	08d71e63          	bne	a4,a3,ffffffffc0203100 <_lru_check_swap+0xb6>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203068:	6685                	lui	a3,0x1
ffffffffc020306a:	4629                	li	a2,10
ffffffffc020306c:	00c68023          	sb	a2,0(a3) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0203070:	4394                	lw	a3,0(a5)
ffffffffc0203072:	2681                	sext.w	a3,a3
ffffffffc0203074:	1ee69663          	bne	a3,a4,ffffffffc0203260 <_lru_check_swap+0x216>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203078:	6709                	lui	a4,0x2
ffffffffc020307a:	462d                	li	a2,11
ffffffffc020307c:	00c70023          	sb	a2,0(a4) # 2000 <BASE_ADDRESS-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc0203080:	4398                	lw	a4,0(a5)
ffffffffc0203082:	2701                	sext.w	a4,a4
ffffffffc0203084:	1ad71e63          	bne	a4,a3,ffffffffc0203240 <_lru_check_swap+0x1f6>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203088:	6715                	lui	a4,0x5
ffffffffc020308a:	46b9                	li	a3,14
ffffffffc020308c:	00d70023          	sb	a3,0(a4) # 5000 <BASE_ADDRESS-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc0203090:	4394                	lw	a3,0(a5)
ffffffffc0203092:	4715                	li	a4,5
ffffffffc0203094:	2681                	sext.w	a3,a3
ffffffffc0203096:	18e69563          	bne	a3,a4,ffffffffc0203220 <_lru_check_swap+0x1d6>
    assert(pgfault_num==5);
ffffffffc020309a:	4398                	lw	a4,0(a5)
ffffffffc020309c:	2701                	sext.w	a4,a4
ffffffffc020309e:	16d71163          	bne	a4,a3,ffffffffc0203200 <_lru_check_swap+0x1b6>
    assert(pgfault_num==5);
ffffffffc02030a2:	4394                	lw	a3,0(a5)
ffffffffc02030a4:	2681                	sext.w	a3,a3
ffffffffc02030a6:	12e69d63          	bne	a3,a4,ffffffffc02031e0 <_lru_check_swap+0x196>
    assert(pgfault_num==5);
ffffffffc02030aa:	4398                	lw	a4,0(a5)
ffffffffc02030ac:	2701                	sext.w	a4,a4
ffffffffc02030ae:	10d71963          	bne	a4,a3,ffffffffc02031c0 <_lru_check_swap+0x176>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02030b2:	6711                	lui	a4,0x4
ffffffffc02030b4:	46b5                	li	a3,13
ffffffffc02030b6:	00d70023          	sb	a3,0(a4) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
    assert(pgfault_num==6);
ffffffffc02030ba:	4398                	lw	a4,0(a5)
ffffffffc02030bc:	4699                	li	a3,6
ffffffffc02030be:	2701                	sext.w	a4,a4
ffffffffc02030c0:	0ed71063          	bne	a4,a3,ffffffffc02031a0 <_lru_check_swap+0x156>
    assert(pgfault_num==6);
ffffffffc02030c4:	4394                	lw	a3,0(a5)
ffffffffc02030c6:	2681                	sext.w	a3,a3
ffffffffc02030c8:	0ae69c63          	bne	a3,a4,ffffffffc0203180 <_lru_check_swap+0x136>
    assert(pgfault_num==6);
ffffffffc02030cc:	4398                	lw	a4,0(a5)
ffffffffc02030ce:	2701                	sext.w	a4,a4
ffffffffc02030d0:	08d71863          	bne	a4,a3,ffffffffc0203160 <_lru_check_swap+0x116>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc02030d4:	6711                	lui	a4,0x4
ffffffffc02030d6:	46b5                	li	a3,13
ffffffffc02030d8:	00d70023          	sb	a3,0(a4) # 4000 <BASE_ADDRESS-0xffffffffc01fc000>
     assert(pgfault_num==6);
ffffffffc02030dc:	4398                	lw	a4,0(a5)
ffffffffc02030de:	4699                	li	a3,6
ffffffffc02030e0:	2701                	sext.w	a4,a4
ffffffffc02030e2:	04d71f63          	bne	a4,a3,ffffffffc0203140 <_lru_check_swap+0xf6>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc02030e6:	670d                	lui	a4,0x3
ffffffffc02030e8:	46b1                	li	a3,12
ffffffffc02030ea:	00d70023          	sb	a3,0(a4) # 3000 <BASE_ADDRESS-0xffffffffc01fd000>
     assert(pgfault_num==7);
ffffffffc02030ee:	439c                	lw	a5,0(a5)
ffffffffc02030f0:	471d                	li	a4,7
ffffffffc02030f2:	2781                	sext.w	a5,a5
ffffffffc02030f4:	02e79663          	bne	a5,a4,ffffffffc0203120 <_lru_check_swap+0xd6>
}
ffffffffc02030f8:	60a2                	ld	ra,8(sp)
ffffffffc02030fa:	4501                	li	a0,0
ffffffffc02030fc:	0141                	addi	sp,sp,16
ffffffffc02030fe:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203100:	00003697          	auipc	a3,0x3
ffffffffc0203104:	85868693          	addi	a3,a3,-1960 # ffffffffc0205958 <default_pmm_manager+0x8d8>
ffffffffc0203108:	00002617          	auipc	a2,0x2
ffffffffc020310c:	be060613          	addi	a2,a2,-1056 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0203110:	03100593          	li	a1,49
ffffffffc0203114:	00003517          	auipc	a0,0x3
ffffffffc0203118:	9a450513          	addi	a0,a0,-1628 # ffffffffc0205ab8 <default_pmm_manager+0xa38>
ffffffffc020311c:	a54fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(pgfault_num==7);
ffffffffc0203120:	00003697          	auipc	a3,0x3
ffffffffc0203124:	9d068693          	addi	a3,a3,-1584 # ffffffffc0205af0 <default_pmm_manager+0xa70>
ffffffffc0203128:	00002617          	auipc	a2,0x2
ffffffffc020312c:	bc060613          	addi	a2,a2,-1088 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0203130:	04700593          	li	a1,71
ffffffffc0203134:	00003517          	auipc	a0,0x3
ffffffffc0203138:	98450513          	addi	a0,a0,-1660 # ffffffffc0205ab8 <default_pmm_manager+0xa38>
ffffffffc020313c:	a34fd0ef          	jal	ra,ffffffffc0200370 <__panic>
     assert(pgfault_num==6);
ffffffffc0203140:	00003697          	auipc	a3,0x3
ffffffffc0203144:	9a068693          	addi	a3,a3,-1632 # ffffffffc0205ae0 <default_pmm_manager+0xa60>
ffffffffc0203148:	00002617          	auipc	a2,0x2
ffffffffc020314c:	ba060613          	addi	a2,a2,-1120 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0203150:	04500593          	li	a1,69
ffffffffc0203154:	00003517          	auipc	a0,0x3
ffffffffc0203158:	96450513          	addi	a0,a0,-1692 # ffffffffc0205ab8 <default_pmm_manager+0xa38>
ffffffffc020315c:	a14fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==6);
ffffffffc0203160:	00003697          	auipc	a3,0x3
ffffffffc0203164:	98068693          	addi	a3,a3,-1664 # ffffffffc0205ae0 <default_pmm_manager+0xa60>
ffffffffc0203168:	00002617          	auipc	a2,0x2
ffffffffc020316c:	b8060613          	addi	a2,a2,-1152 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0203170:	04300593          	li	a1,67
ffffffffc0203174:	00003517          	auipc	a0,0x3
ffffffffc0203178:	94450513          	addi	a0,a0,-1724 # ffffffffc0205ab8 <default_pmm_manager+0xa38>
ffffffffc020317c:	9f4fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==6);
ffffffffc0203180:	00003697          	auipc	a3,0x3
ffffffffc0203184:	96068693          	addi	a3,a3,-1696 # ffffffffc0205ae0 <default_pmm_manager+0xa60>
ffffffffc0203188:	00002617          	auipc	a2,0x2
ffffffffc020318c:	b6060613          	addi	a2,a2,-1184 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0203190:	04100593          	li	a1,65
ffffffffc0203194:	00003517          	auipc	a0,0x3
ffffffffc0203198:	92450513          	addi	a0,a0,-1756 # ffffffffc0205ab8 <default_pmm_manager+0xa38>
ffffffffc020319c:	9d4fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==6);
ffffffffc02031a0:	00003697          	auipc	a3,0x3
ffffffffc02031a4:	94068693          	addi	a3,a3,-1728 # ffffffffc0205ae0 <default_pmm_manager+0xa60>
ffffffffc02031a8:	00002617          	auipc	a2,0x2
ffffffffc02031ac:	b4060613          	addi	a2,a2,-1216 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02031b0:	03f00593          	li	a1,63
ffffffffc02031b4:	00003517          	auipc	a0,0x3
ffffffffc02031b8:	90450513          	addi	a0,a0,-1788 # ffffffffc0205ab8 <default_pmm_manager+0xa38>
ffffffffc02031bc:	9b4fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==5);
ffffffffc02031c0:	00003697          	auipc	a3,0x3
ffffffffc02031c4:	91068693          	addi	a3,a3,-1776 # ffffffffc0205ad0 <default_pmm_manager+0xa50>
ffffffffc02031c8:	00002617          	auipc	a2,0x2
ffffffffc02031cc:	b2060613          	addi	a2,a2,-1248 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02031d0:	03d00593          	li	a1,61
ffffffffc02031d4:	00003517          	auipc	a0,0x3
ffffffffc02031d8:	8e450513          	addi	a0,a0,-1820 # ffffffffc0205ab8 <default_pmm_manager+0xa38>
ffffffffc02031dc:	994fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==5);
ffffffffc02031e0:	00003697          	auipc	a3,0x3
ffffffffc02031e4:	8f068693          	addi	a3,a3,-1808 # ffffffffc0205ad0 <default_pmm_manager+0xa50>
ffffffffc02031e8:	00002617          	auipc	a2,0x2
ffffffffc02031ec:	b0060613          	addi	a2,a2,-1280 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02031f0:	03b00593          	li	a1,59
ffffffffc02031f4:	00003517          	auipc	a0,0x3
ffffffffc02031f8:	8c450513          	addi	a0,a0,-1852 # ffffffffc0205ab8 <default_pmm_manager+0xa38>
ffffffffc02031fc:	974fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==5);
ffffffffc0203200:	00003697          	auipc	a3,0x3
ffffffffc0203204:	8d068693          	addi	a3,a3,-1840 # ffffffffc0205ad0 <default_pmm_manager+0xa50>
ffffffffc0203208:	00002617          	auipc	a2,0x2
ffffffffc020320c:	ae060613          	addi	a2,a2,-1312 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0203210:	03900593          	li	a1,57
ffffffffc0203214:	00003517          	auipc	a0,0x3
ffffffffc0203218:	8a450513          	addi	a0,a0,-1884 # ffffffffc0205ab8 <default_pmm_manager+0xa38>
ffffffffc020321c:	954fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==5);
ffffffffc0203220:	00003697          	auipc	a3,0x3
ffffffffc0203224:	8b068693          	addi	a3,a3,-1872 # ffffffffc0205ad0 <default_pmm_manager+0xa50>
ffffffffc0203228:	00002617          	auipc	a2,0x2
ffffffffc020322c:	ac060613          	addi	a2,a2,-1344 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0203230:	03700593          	li	a1,55
ffffffffc0203234:	00003517          	auipc	a0,0x3
ffffffffc0203238:	88450513          	addi	a0,a0,-1916 # ffffffffc0205ab8 <default_pmm_manager+0xa38>
ffffffffc020323c:	934fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==4);
ffffffffc0203240:	00002697          	auipc	a3,0x2
ffffffffc0203244:	71868693          	addi	a3,a3,1816 # ffffffffc0205958 <default_pmm_manager+0x8d8>
ffffffffc0203248:	00002617          	auipc	a2,0x2
ffffffffc020324c:	aa060613          	addi	a2,a2,-1376 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0203250:	03500593          	li	a1,53
ffffffffc0203254:	00003517          	auipc	a0,0x3
ffffffffc0203258:	86450513          	addi	a0,a0,-1948 # ffffffffc0205ab8 <default_pmm_manager+0xa38>
ffffffffc020325c:	914fd0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgfault_num==4);
ffffffffc0203260:	00002697          	auipc	a3,0x2
ffffffffc0203264:	6f868693          	addi	a3,a3,1784 # ffffffffc0205958 <default_pmm_manager+0x8d8>
ffffffffc0203268:	00002617          	auipc	a2,0x2
ffffffffc020326c:	a8060613          	addi	a2,a2,-1408 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0203270:	03300593          	li	a1,51
ffffffffc0203274:	00003517          	auipc	a0,0x3
ffffffffc0203278:	84450513          	addi	a0,a0,-1980 # ffffffffc0205ab8 <default_pmm_manager+0xa38>
ffffffffc020327c:	8f4fd0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0203280 <_lru_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203280:	7518                	ld	a4,40(a0)
{
ffffffffc0203282:	1141                	addi	sp,sp,-16
ffffffffc0203284:	e406                	sd	ra,8(sp)
        assert(head != NULL);
ffffffffc0203286:	c731                	beqz	a4,ffffffffc02032d2 <_lru_swap_out_victim+0x52>
    assert(in_tick==0);
ffffffffc0203288:	e60d                	bnez	a2,ffffffffc02032b2 <_lru_swap_out_victim+0x32>
    return listelm->prev;
ffffffffc020328a:	631c                	ld	a5,0(a4)
    if (entry != head) {
ffffffffc020328c:	00f70d63          	beq	a4,a5,ffffffffc02032a6 <_lru_swap_out_victim+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203290:	6394                	ld	a3,0(a5)
ffffffffc0203292:	6798                	ld	a4,8(a5)
}
ffffffffc0203294:	60a2                	ld	ra,8(sp)
        *ptr_page = le2page(entry, pra_page_link);
ffffffffc0203296:	fd078793          	addi	a5,a5,-48
    prev->next = next;
ffffffffc020329a:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc020329c:	e314                	sd	a3,0(a4)
ffffffffc020329e:	e19c                	sd	a5,0(a1)
}
ffffffffc02032a0:	4501                	li	a0,0
ffffffffc02032a2:	0141                	addi	sp,sp,16
ffffffffc02032a4:	8082                	ret
ffffffffc02032a6:	60a2                	ld	ra,8(sp)
        *ptr_page = NULL;
ffffffffc02032a8:	0005b023          	sd	zero,0(a1) # 1000 <BASE_ADDRESS-0xffffffffc01ff000>
}
ffffffffc02032ac:	4501                	li	a0,0
ffffffffc02032ae:	0141                	addi	sp,sp,16
ffffffffc02032b0:	8082                	ret
    assert(in_tick==0);
ffffffffc02032b2:	00003697          	auipc	a3,0x3
ffffffffc02032b6:	87e68693          	addi	a3,a3,-1922 # ffffffffc0205b30 <default_pmm_manager+0xab0>
ffffffffc02032ba:	00002617          	auipc	a2,0x2
ffffffffc02032be:	a2e60613          	addi	a2,a2,-1490 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02032c2:	02400593          	li	a1,36
ffffffffc02032c6:	00002517          	auipc	a0,0x2
ffffffffc02032ca:	7f250513          	addi	a0,a0,2034 # ffffffffc0205ab8 <default_pmm_manager+0xa38>
ffffffffc02032ce:	8a2fd0ef          	jal	ra,ffffffffc0200370 <__panic>
        assert(head != NULL);
ffffffffc02032d2:	00003697          	auipc	a3,0x3
ffffffffc02032d6:	84e68693          	addi	a3,a3,-1970 # ffffffffc0205b20 <default_pmm_manager+0xaa0>
ffffffffc02032da:	00002617          	auipc	a2,0x2
ffffffffc02032de:	a0e60613          	addi	a2,a2,-1522 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02032e2:	02300593          	li	a1,35
ffffffffc02032e6:	00002517          	auipc	a0,0x2
ffffffffc02032ea:	7d250513          	addi	a0,a0,2002 # ffffffffc0205ab8 <default_pmm_manager+0xa38>
ffffffffc02032ee:	882fd0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc02032f2 <_lru_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc02032f2:	03060713          	addi	a4,a2,48
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02032f6:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc02032f8:	cb09                	beqz	a4,ffffffffc020330a <_lru_map_swappable+0x18>
ffffffffc02032fa:	cb81                	beqz	a5,ffffffffc020330a <_lru_map_swappable+0x18>
    __list_add(elm, listelm, listelm->next);
ffffffffc02032fc:	6794                	ld	a3,8(a5)
}
ffffffffc02032fe:	4501                	li	a0,0
    prev->next = next->prev = elm;
ffffffffc0203300:	e298                	sd	a4,0(a3)
ffffffffc0203302:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0203304:	fe14                	sd	a3,56(a2)
    elm->prev = prev;
ffffffffc0203306:	fa1c                	sd	a5,48(a2)
ffffffffc0203308:	8082                	ret
{
ffffffffc020330a:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc020330c:	00002697          	auipc	a3,0x2
ffffffffc0203310:	7f468693          	addi	a3,a3,2036 # ffffffffc0205b00 <default_pmm_manager+0xa80>
ffffffffc0203314:	00002617          	auipc	a2,0x2
ffffffffc0203318:	9d460613          	addi	a2,a2,-1580 # ffffffffc0204ce8 <commands+0x870>
ffffffffc020331c:	45ed                	li	a1,27
ffffffffc020331e:	00002517          	auipc	a0,0x2
ffffffffc0203322:	79a50513          	addi	a0,a0,1946 # ffffffffc0205ab8 <default_pmm_manager+0xa38>
{
ffffffffc0203326:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0203328:	848fd0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc020332c <lru_pgfault>:

int lru_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020332c:	7179                	addi	sp,sp,-48
ffffffffc020332e:	ec26                	sd	s1,24(sp)
    cprintf("lru page fault at 0x%x\n", addr);
ffffffffc0203330:	85b2                	mv	a1,a2
int lru_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203332:	84aa                	mv	s1,a0
    cprintf("lru page fault at 0x%x\n", addr);
ffffffffc0203334:	00003517          	auipc	a0,0x3
ffffffffc0203338:	80c50513          	addi	a0,a0,-2036 # ffffffffc0205b40 <default_pmm_manager+0xac0>
int lru_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020333c:	e44e                	sd	s3,8(sp)
ffffffffc020333e:	e052                	sd	s4,0(sp)
ffffffffc0203340:	f406                	sd	ra,40(sp)
ffffffffc0203342:	f022                	sd	s0,32(sp)
ffffffffc0203344:	e84a                	sd	s2,16(sp)
ffffffffc0203346:	8a32                	mv	s4,a2
    // 设置所有页面不可读
    if(swap_init_ok) 
ffffffffc0203348:	0000e997          	auipc	s3,0xe
ffffffffc020334c:	12098993          	addi	s3,s3,288 # ffffffffc0211468 <swap_init_ok>
    cprintf("lru page fault at 0x%x\n", addr);
ffffffffc0203350:	d6ffc0ef          	jal	ra,ffffffffc02000be <cprintf>
    if(swap_init_ok) 
ffffffffc0203354:	0009a783          	lw	a5,0(s3)
ffffffffc0203358:	2781                	sext.w	a5,a5
ffffffffc020335a:	c395                	beqz	a5,ffffffffc020337e <lru_pgfault+0x52>
    {
    	 list_entry_t *head=(list_entry_t*) mm->sm_priv, *le = head;
ffffffffc020335c:	0284b903          	ld	s2,40(s1)
    return listelm->prev;
ffffffffc0203360:	00093403          	ld	s0,0(s2)
	while ((le = list_prev(le)) != head)
ffffffffc0203364:	00890d63          	beq	s2,s0,ffffffffc020337e <lru_pgfault+0x52>
	{
	struct Page* page = le2page(le, pra_page_link);
	pte_t* ptep = NULL;
	ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);
ffffffffc0203368:	680c                	ld	a1,16(s0)
ffffffffc020336a:	6c88                	ld	a0,24(s1)
ffffffffc020336c:	4601                	li	a2,0
ffffffffc020336e:	bdefe0ef          	jal	ra,ffffffffc020174c <get_pte>
	*ptep &= ~PTE_R;
ffffffffc0203372:	611c                	ld	a5,0(a0)
ffffffffc0203374:	6000                	ld	s0,0(s0)
ffffffffc0203376:	9bf5                	andi	a5,a5,-3
ffffffffc0203378:	e11c                	sd	a5,0(a0)
	while ((le = list_prev(le)) != head)
ffffffffc020337a:	fe8917e3          	bne	s2,s0,ffffffffc0203368 <lru_pgfault+0x3c>
	}
    }
    // 将需要获得的页面设置为可读
    pte_t* ptep = NULL;
    ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc020337e:	6c88                	ld	a0,24(s1)
ffffffffc0203380:	4601                	li	a2,0
ffffffffc0203382:	85d2                	mv	a1,s4
ffffffffc0203384:	bc8fe0ef          	jal	ra,ffffffffc020174c <get_pte>
    *ptep |= PTE_R;
ffffffffc0203388:	6114                	ld	a3,0(a0)
    if(!swap_init_ok) 
ffffffffc020338a:	0009a703          	lw	a4,0(s3)
    *ptep |= PTE_R;
ffffffffc020338e:	0026e793          	ori	a5,a3,2
ffffffffc0203392:	e11c                	sd	a5,0(a0)
    if(!swap_init_ok) 
ffffffffc0203394:	2701                	sext.w	a4,a4
ffffffffc0203396:	eb11                	bnez	a4,ffffffffc02033aa <lru_pgfault+0x7e>
            list_add(head, le);
            break;
        }
    }
    return 0;
}
ffffffffc0203398:	70a2                	ld	ra,40(sp)
ffffffffc020339a:	7402                	ld	s0,32(sp)
ffffffffc020339c:	64e2                	ld	s1,24(sp)
ffffffffc020339e:	6942                	ld	s2,16(sp)
ffffffffc02033a0:	69a2                	ld	s3,8(sp)
ffffffffc02033a2:	6a02                	ld	s4,0(sp)
ffffffffc02033a4:	4501                	li	a0,0
ffffffffc02033a6:	6145                	addi	sp,sp,48
ffffffffc02033a8:	8082                	ret
    if (!(pte & PTE_V)) {
ffffffffc02033aa:	8a85                	andi	a3,a3,1
ffffffffc02033ac:	cea9                	beqz	a3,ffffffffc0203406 <lru_pgfault+0xda>
    if (PPN(pa) >= npage) {
ffffffffc02033ae:	0000e717          	auipc	a4,0xe
ffffffffc02033b2:	0aa70713          	addi	a4,a4,170 # ffffffffc0211458 <npage>
ffffffffc02033b6:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02033b8:	078a                	slli	a5,a5,0x2
ffffffffc02033ba:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02033bc:	06e7f163          	bgeu	a5,a4,ffffffffc020341e <lru_pgfault+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc02033c0:	00003717          	auipc	a4,0x3
ffffffffc02033c4:	d6870713          	addi	a4,a4,-664 # ffffffffc0206128 <nbase>
ffffffffc02033c8:	6318                	ld	a4,0(a4)
ffffffffc02033ca:	0000e697          	auipc	a3,0xe
ffffffffc02033ce:	0de68693          	addi	a3,a3,222 # ffffffffc02114a8 <pages>
ffffffffc02033d2:	6290                	ld	a2,0(a3)
ffffffffc02033d4:	8f99                	sub	a5,a5,a4
ffffffffc02033d6:	00379713          	slli	a4,a5,0x3
    list_entry_t *head=(list_entry_t*) mm->sm_priv, *le = head;
ffffffffc02033da:	7494                	ld	a3,40(s1)
ffffffffc02033dc:	97ba                	add	a5,a5,a4
ffffffffc02033de:	078e                	slli	a5,a5,0x3
ffffffffc02033e0:	963e                	add	a2,a2,a5
ffffffffc02033e2:	87b6                	mv	a5,a3
ffffffffc02033e4:	639c                	ld	a5,0(a5)
    while ((le = list_prev(le)) != head)
ffffffffc02033e6:	faf689e3          	beq	a3,a5,ffffffffc0203398 <lru_pgfault+0x6c>
        struct Page* curr = le2page(le, pra_page_link);
ffffffffc02033ea:	fd078713          	addi	a4,a5,-48
        if(page == curr) {
ffffffffc02033ee:	fec71be3          	bne	a4,a2,ffffffffc02033e4 <lru_pgfault+0xb8>
    __list_del(listelm->prev, listelm->next);
ffffffffc02033f2:	638c                	ld	a1,0(a5)
ffffffffc02033f4:	6790                	ld	a2,8(a5)
    prev->next = next;
ffffffffc02033f6:	e590                	sd	a2,8(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02033f8:	6698                	ld	a4,8(a3)
    next->prev = prev;
ffffffffc02033fa:	e20c                	sd	a1,0(a2)
    prev->next = next->prev = elm;
ffffffffc02033fc:	e31c                	sd	a5,0(a4)
ffffffffc02033fe:	e69c                	sd	a5,8(a3)
    elm->next = next;
ffffffffc0203400:	e798                	sd	a4,8(a5)
    elm->prev = prev;
ffffffffc0203402:	e394                	sd	a3,0(a5)
ffffffffc0203404:	bf51                	j	ffffffffc0203398 <lru_pgfault+0x6c>
        panic("pte2page called with invalid pte");
ffffffffc0203406:	00002617          	auipc	a2,0x2
ffffffffc020340a:	f3a60613          	addi	a2,a2,-198 # ffffffffc0205340 <default_pmm_manager+0x2c0>
ffffffffc020340e:	07000593          	li	a1,112
ffffffffc0203412:	00002517          	auipc	a0,0x2
ffffffffc0203416:	d5650513          	addi	a0,a0,-682 # ffffffffc0205168 <default_pmm_manager+0xe8>
ffffffffc020341a:	f57fc0ef          	jal	ra,ffffffffc0200370 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020341e:	00002617          	auipc	a2,0x2
ffffffffc0203422:	d2a60613          	addi	a2,a2,-726 # ffffffffc0205148 <default_pmm_manager+0xc8>
ffffffffc0203426:	06500593          	li	a1,101
ffffffffc020342a:	00002517          	auipc	a0,0x2
ffffffffc020342e:	d3e50513          	addi	a0,a0,-706 # ffffffffc0205168 <default_pmm_manager+0xe8>
ffffffffc0203432:	f3ffc0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0203436 <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203436:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0203438:	00002697          	auipc	a3,0x2
ffffffffc020343c:	73868693          	addi	a3,a3,1848 # ffffffffc0205b70 <default_pmm_manager+0xaf0>
ffffffffc0203440:	00002617          	auipc	a2,0x2
ffffffffc0203444:	8a860613          	addi	a2,a2,-1880 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0203448:	07c00593          	li	a1,124
ffffffffc020344c:	00002517          	auipc	a0,0x2
ffffffffc0203450:	74450513          	addi	a0,a0,1860 # ffffffffc0205b90 <default_pmm_manager+0xb10>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0203454:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0203456:	f1bfc0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc020345a <mm_create>:
mm_create(void) {
ffffffffc020345a:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020345c:	03000513          	li	a0,48
mm_create(void) {
ffffffffc0203460:	e022                	sd	s0,0(sp)
ffffffffc0203462:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203464:	9f8ff0ef          	jal	ra,ffffffffc020265c <kmalloc>
ffffffffc0203468:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc020346a:	c115                	beqz	a0,ffffffffc020348e <mm_create+0x34>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020346c:	0000e797          	auipc	a5,0xe
ffffffffc0203470:	ffc78793          	addi	a5,a5,-4 # ffffffffc0211468 <swap_init_ok>
ffffffffc0203474:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc0203476:	e408                	sd	a0,8(s0)
ffffffffc0203478:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc020347a:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc020347e:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203482:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203486:	2781                	sext.w	a5,a5
ffffffffc0203488:	eb81                	bnez	a5,ffffffffc0203498 <mm_create+0x3e>
        else mm->sm_priv = NULL;
ffffffffc020348a:	02053423          	sd	zero,40(a0)
}
ffffffffc020348e:	8522                	mv	a0,s0
ffffffffc0203490:	60a2                	ld	ra,8(sp)
ffffffffc0203492:	6402                	ld	s0,0(sp)
ffffffffc0203494:	0141                	addi	sp,sp,16
ffffffffc0203496:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc0203498:	9e7ff0ef          	jal	ra,ffffffffc0202e7e <swap_init_mm>
}
ffffffffc020349c:	8522                	mv	a0,s0
ffffffffc020349e:	60a2                	ld	ra,8(sp)
ffffffffc02034a0:	6402                	ld	s0,0(sp)
ffffffffc02034a2:	0141                	addi	sp,sp,16
ffffffffc02034a4:	8082                	ret

ffffffffc02034a6 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc02034a6:	1101                	addi	sp,sp,-32
ffffffffc02034a8:	e04a                	sd	s2,0(sp)
ffffffffc02034aa:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02034ac:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc02034b0:	e822                	sd	s0,16(sp)
ffffffffc02034b2:	e426                	sd	s1,8(sp)
ffffffffc02034b4:	ec06                	sd	ra,24(sp)
ffffffffc02034b6:	84ae                	mv	s1,a1
ffffffffc02034b8:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02034ba:	9a2ff0ef          	jal	ra,ffffffffc020265c <kmalloc>
    if (vma != NULL) {
ffffffffc02034be:	c509                	beqz	a0,ffffffffc02034c8 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc02034c0:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc02034c4:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02034c6:	ed00                	sd	s0,24(a0)
}
ffffffffc02034c8:	60e2                	ld	ra,24(sp)
ffffffffc02034ca:	6442                	ld	s0,16(sp)
ffffffffc02034cc:	64a2                	ld	s1,8(sp)
ffffffffc02034ce:	6902                	ld	s2,0(sp)
ffffffffc02034d0:	6105                	addi	sp,sp,32
ffffffffc02034d2:	8082                	ret

ffffffffc02034d4 <find_vma>:
    if (mm != NULL) {
ffffffffc02034d4:	c51d                	beqz	a0,ffffffffc0203502 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc02034d6:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc02034d8:	c781                	beqz	a5,ffffffffc02034e0 <find_vma+0xc>
ffffffffc02034da:	6798                	ld	a4,8(a5)
ffffffffc02034dc:	02e5f663          	bgeu	a1,a4,ffffffffc0203508 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc02034e0:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc02034e2:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc02034e4:	00f50f63          	beq	a0,a5,ffffffffc0203502 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc02034e8:	fe87b703          	ld	a4,-24(a5)
ffffffffc02034ec:	fee5ebe3          	bltu	a1,a4,ffffffffc02034e2 <find_vma+0xe>
ffffffffc02034f0:	ff07b703          	ld	a4,-16(a5)
ffffffffc02034f4:	fee5f7e3          	bgeu	a1,a4,ffffffffc02034e2 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc02034f8:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc02034fa:	c781                	beqz	a5,ffffffffc0203502 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc02034fc:	e91c                	sd	a5,16(a0)
}
ffffffffc02034fe:	853e                	mv	a0,a5
ffffffffc0203500:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0203502:	4781                	li	a5,0
}
ffffffffc0203504:	853e                	mv	a0,a5
ffffffffc0203506:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203508:	6b98                	ld	a4,16(a5)
ffffffffc020350a:	fce5fbe3          	bgeu	a1,a4,ffffffffc02034e0 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc020350e:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0203510:	b7fd                	j	ffffffffc02034fe <find_vma+0x2a>

ffffffffc0203512 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203512:	6590                	ld	a2,8(a1)
ffffffffc0203514:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0203518:	1141                	addi	sp,sp,-16
ffffffffc020351a:	e406                	sd	ra,8(sp)
ffffffffc020351c:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc020351e:	01066863          	bltu	a2,a6,ffffffffc020352e <insert_vma_struct+0x1c>
ffffffffc0203522:	a8b9                	j	ffffffffc0203580 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0203524:	fe87b683          	ld	a3,-24(a5)
ffffffffc0203528:	04d66763          	bltu	a2,a3,ffffffffc0203576 <insert_vma_struct+0x64>
ffffffffc020352c:	873e                	mv	a4,a5
ffffffffc020352e:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0203530:	fef51ae3          	bne	a0,a5,ffffffffc0203524 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0203534:	02a70463          	beq	a4,a0,ffffffffc020355c <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0203538:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc020353c:	fe873883          	ld	a7,-24(a4)
ffffffffc0203540:	08d8f063          	bgeu	a7,a3,ffffffffc02035c0 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203544:	04d66e63          	bltu	a2,a3,ffffffffc02035a0 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0203548:	00f50a63          	beq	a0,a5,ffffffffc020355c <insert_vma_struct+0x4a>
ffffffffc020354c:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203550:	0506e863          	bltu	a3,a6,ffffffffc02035a0 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0203554:	ff07b603          	ld	a2,-16(a5)
ffffffffc0203558:	02c6f263          	bgeu	a3,a2,ffffffffc020357c <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc020355c:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc020355e:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0203560:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0203564:	e390                	sd	a2,0(a5)
ffffffffc0203566:	e710                	sd	a2,8(a4)
}
ffffffffc0203568:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc020356a:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc020356c:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc020356e:	2685                	addiw	a3,a3,1
ffffffffc0203570:	d114                	sw	a3,32(a0)
}
ffffffffc0203572:	0141                	addi	sp,sp,16
ffffffffc0203574:	8082                	ret
    if (le_prev != list) {
ffffffffc0203576:	fca711e3          	bne	a4,a0,ffffffffc0203538 <insert_vma_struct+0x26>
ffffffffc020357a:	bfd9                	j	ffffffffc0203550 <insert_vma_struct+0x3e>
ffffffffc020357c:	ebbff0ef          	jal	ra,ffffffffc0203436 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203580:	00002697          	auipc	a3,0x2
ffffffffc0203584:	6a068693          	addi	a3,a3,1696 # ffffffffc0205c20 <default_pmm_manager+0xba0>
ffffffffc0203588:	00001617          	auipc	a2,0x1
ffffffffc020358c:	76060613          	addi	a2,a2,1888 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0203590:	08300593          	li	a1,131
ffffffffc0203594:	00002517          	auipc	a0,0x2
ffffffffc0203598:	5fc50513          	addi	a0,a0,1532 # ffffffffc0205b90 <default_pmm_manager+0xb10>
ffffffffc020359c:	dd5fc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02035a0:	00002697          	auipc	a3,0x2
ffffffffc02035a4:	6c068693          	addi	a3,a3,1728 # ffffffffc0205c60 <default_pmm_manager+0xbe0>
ffffffffc02035a8:	00001617          	auipc	a2,0x1
ffffffffc02035ac:	74060613          	addi	a2,a2,1856 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02035b0:	07b00593          	li	a1,123
ffffffffc02035b4:	00002517          	auipc	a0,0x2
ffffffffc02035b8:	5dc50513          	addi	a0,a0,1500 # ffffffffc0205b90 <default_pmm_manager+0xb10>
ffffffffc02035bc:	db5fc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02035c0:	00002697          	auipc	a3,0x2
ffffffffc02035c4:	68068693          	addi	a3,a3,1664 # ffffffffc0205c40 <default_pmm_manager+0xbc0>
ffffffffc02035c8:	00001617          	auipc	a2,0x1
ffffffffc02035cc:	72060613          	addi	a2,a2,1824 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02035d0:	07a00593          	li	a1,122
ffffffffc02035d4:	00002517          	auipc	a0,0x2
ffffffffc02035d8:	5bc50513          	addi	a0,a0,1468 # ffffffffc0205b90 <default_pmm_manager+0xb10>
ffffffffc02035dc:	d95fc0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc02035e0 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
ffffffffc02035e0:	1141                	addi	sp,sp,-16
ffffffffc02035e2:	e022                	sd	s0,0(sp)
ffffffffc02035e4:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc02035e6:	6508                	ld	a0,8(a0)
ffffffffc02035e8:	e406                	sd	ra,8(sp)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc02035ea:	00a40e63          	beq	s0,a0,ffffffffc0203606 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02035ee:	6118                	ld	a4,0(a0)
ffffffffc02035f0:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link),sizeof(struct vma_struct));  //kfree vma        
ffffffffc02035f2:	03000593          	li	a1,48
ffffffffc02035f6:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02035f8:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02035fa:	e398                	sd	a4,0(a5)
ffffffffc02035fc:	922ff0ef          	jal	ra,ffffffffc020271e <kfree>
    return listelm->next;
ffffffffc0203600:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0203602:	fea416e3          	bne	s0,a0,ffffffffc02035ee <mm_destroy+0xe>
    }
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203606:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0203608:	6402                	ld	s0,0(sp)
ffffffffc020360a:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc020360c:	03000593          	li	a1,48
}
ffffffffc0203610:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); //kfree mm
ffffffffc0203612:	90cff06f          	j	ffffffffc020271e <kfree>

ffffffffc0203616 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0203616:	715d                	addi	sp,sp,-80
ffffffffc0203618:	e486                	sd	ra,72(sp)
ffffffffc020361a:	e0a2                	sd	s0,64(sp)
ffffffffc020361c:	fc26                	sd	s1,56(sp)
ffffffffc020361e:	f84a                	sd	s2,48(sp)
ffffffffc0203620:	f052                	sd	s4,32(sp)
ffffffffc0203622:	f44e                	sd	s3,40(sp)
ffffffffc0203624:	ec56                	sd	s5,24(sp)
ffffffffc0203626:	e85a                	sd	s6,16(sp)
ffffffffc0203628:	e45e                	sd	s7,8(sp)
}

// check_vmm - check correctness of vmm
static void
check_vmm(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020362a:	8e2fe0ef          	jal	ra,ffffffffc020170c <nr_free_pages>
ffffffffc020362e:	892a                	mv	s2,a0
    cprintf("check_vmm() succeeded.\n");
}

static void
check_vma_struct(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0203630:	8dcfe0ef          	jal	ra,ffffffffc020170c <nr_free_pages>
ffffffffc0203634:	8a2a                	mv	s4,a0

    struct mm_struct *mm = mm_create();
ffffffffc0203636:	e25ff0ef          	jal	ra,ffffffffc020345a <mm_create>
    assert(mm != NULL);
ffffffffc020363a:	842a                	mv	s0,a0
ffffffffc020363c:	03200493          	li	s1,50
ffffffffc0203640:	e919                	bnez	a0,ffffffffc0203656 <vmm_init+0x40>
ffffffffc0203642:	aeed                	j	ffffffffc0203a3c <vmm_init+0x426>
        vma->vm_start = vm_start;
ffffffffc0203644:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203646:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203648:	00053c23          	sd	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020364c:	14ed                	addi	s1,s1,-5
ffffffffc020364e:	8522                	mv	a0,s0
ffffffffc0203650:	ec3ff0ef          	jal	ra,ffffffffc0203512 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0203654:	c88d                	beqz	s1,ffffffffc0203686 <vmm_init+0x70>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203656:	03000513          	li	a0,48
ffffffffc020365a:	802ff0ef          	jal	ra,ffffffffc020265c <kmalloc>
ffffffffc020365e:	85aa                	mv	a1,a0
ffffffffc0203660:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0203664:	f165                	bnez	a0,ffffffffc0203644 <vmm_init+0x2e>
        assert(vma != NULL);
ffffffffc0203666:	00002697          	auipc	a3,0x2
ffffffffc020366a:	1b268693          	addi	a3,a3,434 # ffffffffc0205818 <default_pmm_manager+0x798>
ffffffffc020366e:	00001617          	auipc	a2,0x1
ffffffffc0203672:	67a60613          	addi	a2,a2,1658 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0203676:	0cd00593          	li	a1,205
ffffffffc020367a:	00002517          	auipc	a0,0x2
ffffffffc020367e:	51650513          	addi	a0,a0,1302 # ffffffffc0205b90 <default_pmm_manager+0xb10>
ffffffffc0203682:	ceffc0ef          	jal	ra,ffffffffc0200370 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0203686:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020368a:	1f900993          	li	s3,505
ffffffffc020368e:	a819                	j	ffffffffc02036a4 <vmm_init+0x8e>
        vma->vm_start = vm_start;
ffffffffc0203690:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203692:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203694:	00053c23          	sd	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203698:	0495                	addi	s1,s1,5
ffffffffc020369a:	8522                	mv	a0,s0
ffffffffc020369c:	e77ff0ef          	jal	ra,ffffffffc0203512 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02036a0:	03348a63          	beq	s1,s3,ffffffffc02036d4 <vmm_init+0xbe>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02036a4:	03000513          	li	a0,48
ffffffffc02036a8:	fb5fe0ef          	jal	ra,ffffffffc020265c <kmalloc>
ffffffffc02036ac:	85aa                	mv	a1,a0
ffffffffc02036ae:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02036b2:	fd79                	bnez	a0,ffffffffc0203690 <vmm_init+0x7a>
        assert(vma != NULL);
ffffffffc02036b4:	00002697          	auipc	a3,0x2
ffffffffc02036b8:	16468693          	addi	a3,a3,356 # ffffffffc0205818 <default_pmm_manager+0x798>
ffffffffc02036bc:	00001617          	auipc	a2,0x1
ffffffffc02036c0:	62c60613          	addi	a2,a2,1580 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02036c4:	0d300593          	li	a1,211
ffffffffc02036c8:	00002517          	auipc	a0,0x2
ffffffffc02036cc:	4c850513          	addi	a0,a0,1224 # ffffffffc0205b90 <default_pmm_manager+0xb10>
ffffffffc02036d0:	ca1fc0ef          	jal	ra,ffffffffc0200370 <__panic>
ffffffffc02036d4:	6418                	ld	a4,8(s0)
ffffffffc02036d6:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc02036d8:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc02036dc:	2ae40063          	beq	s0,a4,ffffffffc020397c <vmm_init+0x366>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02036e0:	fe873603          	ld	a2,-24(a4)
ffffffffc02036e4:	ffe78693          	addi	a3,a5,-2
ffffffffc02036e8:	20d61a63          	bne	a2,a3,ffffffffc02038fc <vmm_init+0x2e6>
ffffffffc02036ec:	ff073683          	ld	a3,-16(a4)
ffffffffc02036f0:	20d79663          	bne	a5,a3,ffffffffc02038fc <vmm_init+0x2e6>
ffffffffc02036f4:	0795                	addi	a5,a5,5
ffffffffc02036f6:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc02036f8:	feb792e3          	bne	a5,a1,ffffffffc02036dc <vmm_init+0xc6>
ffffffffc02036fc:	499d                	li	s3,7
ffffffffc02036fe:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0203700:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203704:	85a6                	mv	a1,s1
ffffffffc0203706:	8522                	mv	a0,s0
ffffffffc0203708:	dcdff0ef          	jal	ra,ffffffffc02034d4 <find_vma>
ffffffffc020370c:	8b2a                	mv	s6,a0
        assert(vma1 != NULL);
ffffffffc020370e:	2e050763          	beqz	a0,ffffffffc02039fc <vmm_init+0x3e6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0203712:	00148593          	addi	a1,s1,1
ffffffffc0203716:	8522                	mv	a0,s0
ffffffffc0203718:	dbdff0ef          	jal	ra,ffffffffc02034d4 <find_vma>
ffffffffc020371c:	8aaa                	mv	s5,a0
        assert(vma2 != NULL);
ffffffffc020371e:	2a050f63          	beqz	a0,ffffffffc02039dc <vmm_init+0x3c6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0203722:	85ce                	mv	a1,s3
ffffffffc0203724:	8522                	mv	a0,s0
ffffffffc0203726:	dafff0ef          	jal	ra,ffffffffc02034d4 <find_vma>
        assert(vma3 == NULL);
ffffffffc020372a:	28051963          	bnez	a0,ffffffffc02039bc <vmm_init+0x3a6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc020372e:	00348593          	addi	a1,s1,3
ffffffffc0203732:	8522                	mv	a0,s0
ffffffffc0203734:	da1ff0ef          	jal	ra,ffffffffc02034d4 <find_vma>
        assert(vma4 == NULL);
ffffffffc0203738:	26051263          	bnez	a0,ffffffffc020399c <vmm_init+0x386>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc020373c:	00448593          	addi	a1,s1,4
ffffffffc0203740:	8522                	mv	a0,s0
ffffffffc0203742:	d93ff0ef          	jal	ra,ffffffffc02034d4 <find_vma>
        assert(vma5 == NULL);
ffffffffc0203746:	2c051b63          	bnez	a0,ffffffffc0203a1c <vmm_init+0x406>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020374a:	008b3783          	ld	a5,8(s6)
ffffffffc020374e:	1c979763          	bne	a5,s1,ffffffffc020391c <vmm_init+0x306>
ffffffffc0203752:	010b3783          	ld	a5,16(s6)
ffffffffc0203756:	1d379363          	bne	a5,s3,ffffffffc020391c <vmm_init+0x306>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020375a:	008ab783          	ld	a5,8(s5)
ffffffffc020375e:	1c979f63          	bne	a5,s1,ffffffffc020393c <vmm_init+0x326>
ffffffffc0203762:	010ab783          	ld	a5,16(s5)
ffffffffc0203766:	1d379b63          	bne	a5,s3,ffffffffc020393c <vmm_init+0x326>
ffffffffc020376a:	0495                	addi	s1,s1,5
ffffffffc020376c:	0995                	addi	s3,s3,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020376e:	f9749be3          	bne	s1,s7,ffffffffc0203704 <vmm_init+0xee>
ffffffffc0203772:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0203774:	59fd                	li	s3,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0203776:	85a6                	mv	a1,s1
ffffffffc0203778:	8522                	mv	a0,s0
ffffffffc020377a:	d5bff0ef          	jal	ra,ffffffffc02034d4 <find_vma>
ffffffffc020377e:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0203782:	c90d                	beqz	a0,ffffffffc02037b4 <vmm_init+0x19e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0203784:	6914                	ld	a3,16(a0)
ffffffffc0203786:	6510                	ld	a2,8(a0)
ffffffffc0203788:	00002517          	auipc	a0,0x2
ffffffffc020378c:	5f850513          	addi	a0,a0,1528 # ffffffffc0205d80 <default_pmm_manager+0xd00>
ffffffffc0203790:	92ffc0ef          	jal	ra,ffffffffc02000be <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203794:	00002697          	auipc	a3,0x2
ffffffffc0203798:	61468693          	addi	a3,a3,1556 # ffffffffc0205da8 <default_pmm_manager+0xd28>
ffffffffc020379c:	00001617          	auipc	a2,0x1
ffffffffc02037a0:	54c60613          	addi	a2,a2,1356 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02037a4:	0f500593          	li	a1,245
ffffffffc02037a8:	00002517          	auipc	a0,0x2
ffffffffc02037ac:	3e850513          	addi	a0,a0,1000 # ffffffffc0205b90 <default_pmm_manager+0xb10>
ffffffffc02037b0:	bc1fc0ef          	jal	ra,ffffffffc0200370 <__panic>
ffffffffc02037b4:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc02037b6:	fd3490e3          	bne	s1,s3,ffffffffc0203776 <vmm_init+0x160>
    }

    mm_destroy(mm);
ffffffffc02037ba:	8522                	mv	a0,s0
ffffffffc02037bc:	e25ff0ef          	jal	ra,ffffffffc02035e0 <mm_destroy>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02037c0:	f4dfd0ef          	jal	ra,ffffffffc020170c <nr_free_pages>
ffffffffc02037c4:	28aa1c63          	bne	s4,a0,ffffffffc0203a5c <vmm_init+0x446>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02037c8:	00002517          	auipc	a0,0x2
ffffffffc02037cc:	62050513          	addi	a0,a0,1568 # ffffffffc0205de8 <default_pmm_manager+0xd68>
ffffffffc02037d0:	8effc0ef          	jal	ra,ffffffffc02000be <cprintf>

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
	// char *name = "check_pgfault";
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02037d4:	f39fd0ef          	jal	ra,ffffffffc020170c <nr_free_pages>
ffffffffc02037d8:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc02037da:	c81ff0ef          	jal	ra,ffffffffc020345a <mm_create>
ffffffffc02037de:	0000e797          	auipc	a5,0xe
ffffffffc02037e2:	daa7b523          	sd	a0,-598(a5) # ffffffffc0211588 <check_mm_struct>
ffffffffc02037e6:	842a                	mv	s0,a0

    assert(check_mm_struct != NULL);
ffffffffc02037e8:	2a050a63          	beqz	a0,ffffffffc0203a9c <vmm_init+0x486>
    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02037ec:	0000e797          	auipc	a5,0xe
ffffffffc02037f0:	c6478793          	addi	a5,a5,-924 # ffffffffc0211450 <boot_pgdir>
ffffffffc02037f4:	6384                	ld	s1,0(a5)
    assert(pgdir[0] == 0);
ffffffffc02037f6:	609c                	ld	a5,0(s1)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02037f8:	ed04                	sd	s1,24(a0)
    assert(pgdir[0] == 0);
ffffffffc02037fa:	32079d63          	bnez	a5,ffffffffc0203b34 <vmm_init+0x51e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02037fe:	03000513          	li	a0,48
ffffffffc0203802:	e5bfe0ef          	jal	ra,ffffffffc020265c <kmalloc>
ffffffffc0203806:	8a2a                	mv	s4,a0
    if (vma != NULL) {
ffffffffc0203808:	14050a63          	beqz	a0,ffffffffc020395c <vmm_init+0x346>
        vma->vm_end = vm_end;
ffffffffc020380c:	002007b7          	lui	a5,0x200
ffffffffc0203810:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc0203814:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);

    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0203816:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0203818:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc020381c:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc020381e:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc0203822:	cf1ff0ef          	jal	ra,ffffffffc0203512 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0203826:	10000593          	li	a1,256
ffffffffc020382a:	8522                	mv	a0,s0
ffffffffc020382c:	ca9ff0ef          	jal	ra,ffffffffc02034d4 <find_vma>
ffffffffc0203830:	10000793          	li	a5,256

    int i, sum = 0;
    for (i = 0; i < 100; i ++) {
ffffffffc0203834:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0203838:	2aaa1263          	bne	s4,a0,ffffffffc0203adc <vmm_init+0x4c6>
        *(char *)(addr + i) = i;
ffffffffc020383c:	00f78023          	sb	a5,0(a5) # 200000 <BASE_ADDRESS-0xffffffffc0000000>
        sum += i;
ffffffffc0203840:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc0203842:	fee79de3          	bne	a5,a4,ffffffffc020383c <vmm_init+0x226>
        sum += i;
ffffffffc0203846:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0203848:	10000793          	li	a5,256
        sum += i;
ffffffffc020384c:	35670713          	addi	a4,a4,854 # 1356 <BASE_ADDRESS-0xffffffffc01fecaa>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc0203850:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0203854:	0007c683          	lbu	a3,0(a5)
ffffffffc0203858:	0785                	addi	a5,a5,1
ffffffffc020385a:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc020385c:	fec79ce3          	bne	a5,a2,ffffffffc0203854 <vmm_init+0x23e>
    }
    assert(sum == 0);
ffffffffc0203860:	2a071a63          	bnez	a4,ffffffffc0203b14 <vmm_init+0x4fe>

    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0203864:	4581                	li	a1,0
ffffffffc0203866:	8526                	mv	a0,s1
ffffffffc0203868:	940fe0ef          	jal	ra,ffffffffc02019a8 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc020386c:	609c                	ld	a5,0(s1)
    if (PPN(pa) >= npage) {
ffffffffc020386e:	0000e717          	auipc	a4,0xe
ffffffffc0203872:	bea70713          	addi	a4,a4,-1046 # ffffffffc0211458 <npage>
ffffffffc0203876:	6318                	ld	a4,0(a4)
    return pa2page(PDE_ADDR(pde));
ffffffffc0203878:	078a                	slli	a5,a5,0x2
ffffffffc020387a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020387c:	28e7f063          	bgeu	a5,a4,ffffffffc0203afc <vmm_init+0x4e6>
    return &pages[PPN(pa) - nbase];
ffffffffc0203880:	00003717          	auipc	a4,0x3
ffffffffc0203884:	8a870713          	addi	a4,a4,-1880 # ffffffffc0206128 <nbase>
ffffffffc0203888:	6318                	ld	a4,0(a4)
ffffffffc020388a:	0000e697          	auipc	a3,0xe
ffffffffc020388e:	c1e68693          	addi	a3,a3,-994 # ffffffffc02114a8 <pages>
ffffffffc0203892:	6288                	ld	a0,0(a3)
ffffffffc0203894:	8f99                	sub	a5,a5,a4
ffffffffc0203896:	00379713          	slli	a4,a5,0x3
ffffffffc020389a:	97ba                	add	a5,a5,a4
ffffffffc020389c:	078e                	slli	a5,a5,0x3

    free_page(pde2page(pgdir[0]));
ffffffffc020389e:	953e                	add	a0,a0,a5
ffffffffc02038a0:	4585                	li	a1,1
ffffffffc02038a2:	e25fd0ef          	jal	ra,ffffffffc02016c6 <free_pages>

    pgdir[0] = 0;
ffffffffc02038a6:	0004b023          	sd	zero,0(s1)

    mm->pgdir = NULL;
    mm_destroy(mm);
ffffffffc02038aa:	8522                	mv	a0,s0
    mm->pgdir = NULL;
ffffffffc02038ac:	00043c23          	sd	zero,24(s0)
    mm_destroy(mm);
ffffffffc02038b0:	d31ff0ef          	jal	ra,ffffffffc02035e0 <mm_destroy>

    check_mm_struct = NULL;
    nr_free_pages_store--;	// szx : Sv39第二级页表多占了一个内存页，所以执行此操作
ffffffffc02038b4:	19fd                	addi	s3,s3,-1
    check_mm_struct = NULL;
ffffffffc02038b6:	0000e797          	auipc	a5,0xe
ffffffffc02038ba:	cc07b923          	sd	zero,-814(a5) # ffffffffc0211588 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02038be:	e4ffd0ef          	jal	ra,ffffffffc020170c <nr_free_pages>
ffffffffc02038c2:	1aa99d63          	bne	s3,a0,ffffffffc0203a7c <vmm_init+0x466>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc02038c6:	00002517          	auipc	a0,0x2
ffffffffc02038ca:	58a50513          	addi	a0,a0,1418 # ffffffffc0205e50 <default_pmm_manager+0xdd0>
ffffffffc02038ce:	ff0fc0ef          	jal	ra,ffffffffc02000be <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02038d2:	e3bfd0ef          	jal	ra,ffffffffc020170c <nr_free_pages>
    nr_free_pages_store--;	// szx : Sv39三级页表多占一个内存页，所以执行此操作
ffffffffc02038d6:	197d                	addi	s2,s2,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02038d8:	1ea91263          	bne	s2,a0,ffffffffc0203abc <vmm_init+0x4a6>
}
ffffffffc02038dc:	6406                	ld	s0,64(sp)
ffffffffc02038de:	60a6                	ld	ra,72(sp)
ffffffffc02038e0:	74e2                	ld	s1,56(sp)
ffffffffc02038e2:	7942                	ld	s2,48(sp)
ffffffffc02038e4:	79a2                	ld	s3,40(sp)
ffffffffc02038e6:	7a02                	ld	s4,32(sp)
ffffffffc02038e8:	6ae2                	ld	s5,24(sp)
ffffffffc02038ea:	6b42                	ld	s6,16(sp)
ffffffffc02038ec:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc02038ee:	00002517          	auipc	a0,0x2
ffffffffc02038f2:	58250513          	addi	a0,a0,1410 # ffffffffc0205e70 <default_pmm_manager+0xdf0>
}
ffffffffc02038f6:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc02038f8:	fc6fc06f          	j	ffffffffc02000be <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02038fc:	00002697          	auipc	a3,0x2
ffffffffc0203900:	39c68693          	addi	a3,a3,924 # ffffffffc0205c98 <default_pmm_manager+0xc18>
ffffffffc0203904:	00001617          	auipc	a2,0x1
ffffffffc0203908:	3e460613          	addi	a2,a2,996 # ffffffffc0204ce8 <commands+0x870>
ffffffffc020390c:	0dc00593          	li	a1,220
ffffffffc0203910:	00002517          	auipc	a0,0x2
ffffffffc0203914:	28050513          	addi	a0,a0,640 # ffffffffc0205b90 <default_pmm_manager+0xb10>
ffffffffc0203918:	a59fc0ef          	jal	ra,ffffffffc0200370 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020391c:	00002697          	auipc	a3,0x2
ffffffffc0203920:	40468693          	addi	a3,a3,1028 # ffffffffc0205d20 <default_pmm_manager+0xca0>
ffffffffc0203924:	00001617          	auipc	a2,0x1
ffffffffc0203928:	3c460613          	addi	a2,a2,964 # ffffffffc0204ce8 <commands+0x870>
ffffffffc020392c:	0ec00593          	li	a1,236
ffffffffc0203930:	00002517          	auipc	a0,0x2
ffffffffc0203934:	26050513          	addi	a0,a0,608 # ffffffffc0205b90 <default_pmm_manager+0xb10>
ffffffffc0203938:	a39fc0ef          	jal	ra,ffffffffc0200370 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020393c:	00002697          	auipc	a3,0x2
ffffffffc0203940:	41468693          	addi	a3,a3,1044 # ffffffffc0205d50 <default_pmm_manager+0xcd0>
ffffffffc0203944:	00001617          	auipc	a2,0x1
ffffffffc0203948:	3a460613          	addi	a2,a2,932 # ffffffffc0204ce8 <commands+0x870>
ffffffffc020394c:	0ed00593          	li	a1,237
ffffffffc0203950:	00002517          	auipc	a0,0x2
ffffffffc0203954:	24050513          	addi	a0,a0,576 # ffffffffc0205b90 <default_pmm_manager+0xb10>
ffffffffc0203958:	a19fc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(vma != NULL);
ffffffffc020395c:	00002697          	auipc	a3,0x2
ffffffffc0203960:	ebc68693          	addi	a3,a3,-324 # ffffffffc0205818 <default_pmm_manager+0x798>
ffffffffc0203964:	00001617          	auipc	a2,0x1
ffffffffc0203968:	38460613          	addi	a2,a2,900 # ffffffffc0204ce8 <commands+0x870>
ffffffffc020396c:	11000593          	li	a1,272
ffffffffc0203970:	00002517          	auipc	a0,0x2
ffffffffc0203974:	22050513          	addi	a0,a0,544 # ffffffffc0205b90 <default_pmm_manager+0xb10>
ffffffffc0203978:	9f9fc0ef          	jal	ra,ffffffffc0200370 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc020397c:	00002697          	auipc	a3,0x2
ffffffffc0203980:	30468693          	addi	a3,a3,772 # ffffffffc0205c80 <default_pmm_manager+0xc00>
ffffffffc0203984:	00001617          	auipc	a2,0x1
ffffffffc0203988:	36460613          	addi	a2,a2,868 # ffffffffc0204ce8 <commands+0x870>
ffffffffc020398c:	0da00593          	li	a1,218
ffffffffc0203990:	00002517          	auipc	a0,0x2
ffffffffc0203994:	20050513          	addi	a0,a0,512 # ffffffffc0205b90 <default_pmm_manager+0xb10>
ffffffffc0203998:	9d9fc0ef          	jal	ra,ffffffffc0200370 <__panic>
        assert(vma4 == NULL);
ffffffffc020399c:	00002697          	auipc	a3,0x2
ffffffffc02039a0:	36468693          	addi	a3,a3,868 # ffffffffc0205d00 <default_pmm_manager+0xc80>
ffffffffc02039a4:	00001617          	auipc	a2,0x1
ffffffffc02039a8:	34460613          	addi	a2,a2,836 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02039ac:	0e800593          	li	a1,232
ffffffffc02039b0:	00002517          	auipc	a0,0x2
ffffffffc02039b4:	1e050513          	addi	a0,a0,480 # ffffffffc0205b90 <default_pmm_manager+0xb10>
ffffffffc02039b8:	9b9fc0ef          	jal	ra,ffffffffc0200370 <__panic>
        assert(vma3 == NULL);
ffffffffc02039bc:	00002697          	auipc	a3,0x2
ffffffffc02039c0:	33468693          	addi	a3,a3,820 # ffffffffc0205cf0 <default_pmm_manager+0xc70>
ffffffffc02039c4:	00001617          	auipc	a2,0x1
ffffffffc02039c8:	32460613          	addi	a2,a2,804 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02039cc:	0e600593          	li	a1,230
ffffffffc02039d0:	00002517          	auipc	a0,0x2
ffffffffc02039d4:	1c050513          	addi	a0,a0,448 # ffffffffc0205b90 <default_pmm_manager+0xb10>
ffffffffc02039d8:	999fc0ef          	jal	ra,ffffffffc0200370 <__panic>
        assert(vma2 != NULL);
ffffffffc02039dc:	00002697          	auipc	a3,0x2
ffffffffc02039e0:	30468693          	addi	a3,a3,772 # ffffffffc0205ce0 <default_pmm_manager+0xc60>
ffffffffc02039e4:	00001617          	auipc	a2,0x1
ffffffffc02039e8:	30460613          	addi	a2,a2,772 # ffffffffc0204ce8 <commands+0x870>
ffffffffc02039ec:	0e400593          	li	a1,228
ffffffffc02039f0:	00002517          	auipc	a0,0x2
ffffffffc02039f4:	1a050513          	addi	a0,a0,416 # ffffffffc0205b90 <default_pmm_manager+0xb10>
ffffffffc02039f8:	979fc0ef          	jal	ra,ffffffffc0200370 <__panic>
        assert(vma1 != NULL);
ffffffffc02039fc:	00002697          	auipc	a3,0x2
ffffffffc0203a00:	2d468693          	addi	a3,a3,724 # ffffffffc0205cd0 <default_pmm_manager+0xc50>
ffffffffc0203a04:	00001617          	auipc	a2,0x1
ffffffffc0203a08:	2e460613          	addi	a2,a2,740 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0203a0c:	0e200593          	li	a1,226
ffffffffc0203a10:	00002517          	auipc	a0,0x2
ffffffffc0203a14:	18050513          	addi	a0,a0,384 # ffffffffc0205b90 <default_pmm_manager+0xb10>
ffffffffc0203a18:	959fc0ef          	jal	ra,ffffffffc0200370 <__panic>
        assert(vma5 == NULL);
ffffffffc0203a1c:	00002697          	auipc	a3,0x2
ffffffffc0203a20:	2f468693          	addi	a3,a3,756 # ffffffffc0205d10 <default_pmm_manager+0xc90>
ffffffffc0203a24:	00001617          	auipc	a2,0x1
ffffffffc0203a28:	2c460613          	addi	a2,a2,708 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0203a2c:	0ea00593          	li	a1,234
ffffffffc0203a30:	00002517          	auipc	a0,0x2
ffffffffc0203a34:	16050513          	addi	a0,a0,352 # ffffffffc0205b90 <default_pmm_manager+0xb10>
ffffffffc0203a38:	939fc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(mm != NULL);
ffffffffc0203a3c:	00002697          	auipc	a3,0x2
ffffffffc0203a40:	da468693          	addi	a3,a3,-604 # ffffffffc02057e0 <default_pmm_manager+0x760>
ffffffffc0203a44:	00001617          	auipc	a2,0x1
ffffffffc0203a48:	2a460613          	addi	a2,a2,676 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0203a4c:	0c600593          	li	a1,198
ffffffffc0203a50:	00002517          	auipc	a0,0x2
ffffffffc0203a54:	14050513          	addi	a0,a0,320 # ffffffffc0205b90 <default_pmm_manager+0xb10>
ffffffffc0203a58:	919fc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a5c:	00002697          	auipc	a3,0x2
ffffffffc0203a60:	36468693          	addi	a3,a3,868 # ffffffffc0205dc0 <default_pmm_manager+0xd40>
ffffffffc0203a64:	00001617          	auipc	a2,0x1
ffffffffc0203a68:	28460613          	addi	a2,a2,644 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0203a6c:	0fa00593          	li	a1,250
ffffffffc0203a70:	00002517          	auipc	a0,0x2
ffffffffc0203a74:	12050513          	addi	a0,a0,288 # ffffffffc0205b90 <default_pmm_manager+0xb10>
ffffffffc0203a78:	8f9fc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203a7c:	00002697          	auipc	a3,0x2
ffffffffc0203a80:	34468693          	addi	a3,a3,836 # ffffffffc0205dc0 <default_pmm_manager+0xd40>
ffffffffc0203a84:	00001617          	auipc	a2,0x1
ffffffffc0203a88:	26460613          	addi	a2,a2,612 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0203a8c:	12d00593          	li	a1,301
ffffffffc0203a90:	00002517          	auipc	a0,0x2
ffffffffc0203a94:	10050513          	addi	a0,a0,256 # ffffffffc0205b90 <default_pmm_manager+0xb10>
ffffffffc0203a98:	8d9fc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc0203a9c:	00002697          	auipc	a3,0x2
ffffffffc0203aa0:	36c68693          	addi	a3,a3,876 # ffffffffc0205e08 <default_pmm_manager+0xd88>
ffffffffc0203aa4:	00001617          	auipc	a2,0x1
ffffffffc0203aa8:	24460613          	addi	a2,a2,580 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0203aac:	10900593          	li	a1,265
ffffffffc0203ab0:	00002517          	auipc	a0,0x2
ffffffffc0203ab4:	0e050513          	addi	a0,a0,224 # ffffffffc0205b90 <default_pmm_manager+0xb10>
ffffffffc0203ab8:	8b9fc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203abc:	00002697          	auipc	a3,0x2
ffffffffc0203ac0:	30468693          	addi	a3,a3,772 # ffffffffc0205dc0 <default_pmm_manager+0xd40>
ffffffffc0203ac4:	00001617          	auipc	a2,0x1
ffffffffc0203ac8:	22460613          	addi	a2,a2,548 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0203acc:	0bc00593          	li	a1,188
ffffffffc0203ad0:	00002517          	auipc	a0,0x2
ffffffffc0203ad4:	0c050513          	addi	a0,a0,192 # ffffffffc0205b90 <default_pmm_manager+0xb10>
ffffffffc0203ad8:	899fc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203adc:	00002697          	auipc	a3,0x2
ffffffffc0203ae0:	34468693          	addi	a3,a3,836 # ffffffffc0205e20 <default_pmm_manager+0xda0>
ffffffffc0203ae4:	00001617          	auipc	a2,0x1
ffffffffc0203ae8:	20460613          	addi	a2,a2,516 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0203aec:	11500593          	li	a1,277
ffffffffc0203af0:	00002517          	auipc	a0,0x2
ffffffffc0203af4:	0a050513          	addi	a0,a0,160 # ffffffffc0205b90 <default_pmm_manager+0xb10>
ffffffffc0203af8:	879fc0ef          	jal	ra,ffffffffc0200370 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203afc:	00001617          	auipc	a2,0x1
ffffffffc0203b00:	64c60613          	addi	a2,a2,1612 # ffffffffc0205148 <default_pmm_manager+0xc8>
ffffffffc0203b04:	06500593          	li	a1,101
ffffffffc0203b08:	00001517          	auipc	a0,0x1
ffffffffc0203b0c:	66050513          	addi	a0,a0,1632 # ffffffffc0205168 <default_pmm_manager+0xe8>
ffffffffc0203b10:	861fc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(sum == 0);
ffffffffc0203b14:	00002697          	auipc	a3,0x2
ffffffffc0203b18:	32c68693          	addi	a3,a3,812 # ffffffffc0205e40 <default_pmm_manager+0xdc0>
ffffffffc0203b1c:	00001617          	auipc	a2,0x1
ffffffffc0203b20:	1cc60613          	addi	a2,a2,460 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0203b24:	11f00593          	li	a1,287
ffffffffc0203b28:	00002517          	auipc	a0,0x2
ffffffffc0203b2c:	06850513          	addi	a0,a0,104 # ffffffffc0205b90 <default_pmm_manager+0xb10>
ffffffffc0203b30:	841fc0ef          	jal	ra,ffffffffc0200370 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203b34:	00002697          	auipc	a3,0x2
ffffffffc0203b38:	cd468693          	addi	a3,a3,-812 # ffffffffc0205808 <default_pmm_manager+0x788>
ffffffffc0203b3c:	00001617          	auipc	a2,0x1
ffffffffc0203b40:	1ac60613          	addi	a2,a2,428 # ffffffffc0204ce8 <commands+0x870>
ffffffffc0203b44:	10c00593          	li	a1,268
ffffffffc0203b48:	00002517          	auipc	a0,0x2
ffffffffc0203b4c:	04850513          	addi	a0,a0,72 # ffffffffc0205b90 <default_pmm_manager+0xb10>
ffffffffc0203b50:	821fc0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0203b54 <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {	
ffffffffc0203b54:	7179                	addi	sp,sp,-48
ffffffffc0203b56:	ec26                	sd	s1,24(sp)
ffffffffc0203b58:	84aa                	mv	s1,a0
    pte_t* temp = NULL;
    temp = get_pte(mm->pgdir, addr, 0);
ffffffffc0203b5a:	6d08                	ld	a0,24(a0)
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {	
ffffffffc0203b5c:	f022                	sd	s0,32(sp)
ffffffffc0203b5e:	8432                	mv	s0,a2
ffffffffc0203b60:	e84a                	sd	s2,16(sp)
    temp = get_pte(mm->pgdir, addr, 0);
ffffffffc0203b62:	4601                	li	a2,0
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {	
ffffffffc0203b64:	892e                	mv	s2,a1
    temp = get_pte(mm->pgdir, addr, 0);
ffffffffc0203b66:	85a2                	mv	a1,s0
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {	
ffffffffc0203b68:	f406                	sd	ra,40(sp)
    temp = get_pte(mm->pgdir, addr, 0);
ffffffffc0203b6a:	be3fd0ef          	jal	ra,ffffffffc020174c <get_pte>
    if(temp != NULL && (*temp & (PTE_V | PTE_R))) {
ffffffffc0203b6e:	c501                	beqz	a0,ffffffffc0203b76 <do_pgfault+0x22>
ffffffffc0203b70:	611c                	ld	a5,0(a0)
ffffffffc0203b72:	8b8d                	andi	a5,a5,3
ffffffffc0203b74:	e7c5                	bnez	a5,ffffffffc0203c1c <do_pgfault+0xc8>
        return lru_pgfault(mm, error_code, addr);
    }
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203b76:	85a2                	mv	a1,s0
ffffffffc0203b78:	8526                	mv	a0,s1
ffffffffc0203b7a:	95bff0ef          	jal	ra,ffffffffc02034d4 <find_vma>

    pgfault_num++;
ffffffffc0203b7e:	0000e797          	auipc	a5,0xe
ffffffffc0203b82:	8ee78793          	addi	a5,a5,-1810 # ffffffffc021146c <pgfault_num>
ffffffffc0203b86:	439c                	lw	a5,0(a5)
ffffffffc0203b88:	2785                	addiw	a5,a5,1
ffffffffc0203b8a:	0000e717          	auipc	a4,0xe
ffffffffc0203b8e:	8ef72123          	sw	a5,-1822(a4) # ffffffffc021146c <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203b92:	c155                	beqz	a0,ffffffffc0203c36 <do_pgfault+0xe2>
ffffffffc0203b94:	651c                	ld	a5,8(a0)
ffffffffc0203b96:	0af46063          	bltu	s0,a5,ffffffffc0203c36 <do_pgfault+0xe2>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203b9a:	6d1c                	ld	a5,24(a0)
ffffffffc0203b9c:	4941                	li	s2,16
ffffffffc0203b9e:	8b89                	andi	a5,a5,2
ffffffffc0203ba0:	efa9                	bnez	a5,ffffffffc0203bfa <do_pgfault+0xa6>
        perm |= (PTE_R | PTE_W);
    }
    perm &= ~PTE_R;
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203ba2:	77fd                	lui	a5,0xfffff
    *   mm->pgdir : the PDT of these vma
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203ba4:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203ba6:	8c7d                	and	s0,s0,a5
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203ba8:	85a2                	mv	a1,s0
ffffffffc0203baa:	4605                	li	a2,1
ffffffffc0203bac:	ba1fd0ef          	jal	ra,ffffffffc020174c <get_pte>
                                         //PT(Page Table) isn't existed, then
                                         //create a PT.
    if (*ptep == 0) {
ffffffffc0203bb0:	610c                	ld	a1,0(a0)
ffffffffc0203bb2:	c5b1                	beqz	a1,ffffffffc0203bfe <do_pgfault+0xaa>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc0203bb4:	0000e797          	auipc	a5,0xe
ffffffffc0203bb8:	8b478793          	addi	a5,a5,-1868 # ffffffffc0211468 <swap_init_ok>
ffffffffc0203bbc:	439c                	lw	a5,0(a5)
ffffffffc0203bbe:	2781                	sext.w	a5,a5
ffffffffc0203bc0:	c7c1                	beqz	a5,ffffffffc0203c48 <do_pgfault+0xf4>
            // 你要编写的内容在这里，请基于上文说明以及下文的英文注释完成代码编写
            //(1）According to the mm AND addr, try
            //to load the content of right disk page
            //into the memory which page managed.
   //(1)根据内存管理信息（mm）和地址（addr），尝试将正确磁盘页的内容加载到由该页管理的内存中。
   	    swap_in(mm,addr,&page);
ffffffffc0203bc2:	85a2                	mv	a1,s0
ffffffffc0203bc4:	0030                	addi	a2,sp,8
ffffffffc0203bc6:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0203bc8:	e402                	sd	zero,8(sp)
   	    swap_in(mm,addr,&page);
ffffffffc0203bca:	be8ff0ef          	jal	ra,ffffffffc0202fb2 <swap_in>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
   //(2)根据内存管理信息（mm）、地址（addr）和页（page），设置物理地址和逻辑地址之间的映射关系。
   	    page_insert(mm->pgdir,page,addr,perm);
ffffffffc0203bce:	65a2                	ld	a1,8(sp)
ffffffffc0203bd0:	6c88                	ld	a0,24(s1)
ffffffffc0203bd2:	86ca                	mv	a3,s2
ffffffffc0203bd4:	8622                	mv	a2,s0
ffffffffc0203bd6:	e45fd0ef          	jal	ra,ffffffffc0201a1a <page_insert>
            //(3) make the page swappable.
    //(3)使该页可交换（即，允许该页在需要时被换出内存，并在需要时重新加载回内存）。
    	    swap_map_swappable(mm,addr,page,1);
ffffffffc0203bda:	6622                	ld	a2,8(sp)
ffffffffc0203bdc:	4685                	li	a3,1
ffffffffc0203bde:	85a2                	mv	a1,s0
ffffffffc0203be0:	8526                	mv	a0,s1
ffffffffc0203be2:	aacff0ef          	jal	ra,ffffffffc0202e8e <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0203be6:	6722                	ld	a4,8(sp)
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
            goto failed;
        }
   }

   ret = 0;
ffffffffc0203be8:	4781                	li	a5,0
            page->pra_vaddr = addr;
ffffffffc0203bea:	e320                	sd	s0,64(a4)
failed:
    return ret;
}
ffffffffc0203bec:	70a2                	ld	ra,40(sp)
ffffffffc0203bee:	7402                	ld	s0,32(sp)
ffffffffc0203bf0:	64e2                	ld	s1,24(sp)
ffffffffc0203bf2:	6942                	ld	s2,16(sp)
ffffffffc0203bf4:	853e                	mv	a0,a5
ffffffffc0203bf6:	6145                	addi	sp,sp,48
ffffffffc0203bf8:	8082                	ret
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203bfa:	4951                	li	s2,20
ffffffffc0203bfc:	b75d                	j	ffffffffc0203ba2 <do_pgfault+0x4e>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203bfe:	6c88                	ld	a0,24(s1)
ffffffffc0203c00:	864a                	mv	a2,s2
ffffffffc0203c02:	85a2                	mv	a1,s0
ffffffffc0203c04:	9c7fe0ef          	jal	ra,ffffffffc02025ca <pgdir_alloc_page>
   ret = 0;
ffffffffc0203c08:	4781                	li	a5,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203c0a:	f16d                	bnez	a0,ffffffffc0203bec <do_pgfault+0x98>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203c0c:	00002517          	auipc	a0,0x2
ffffffffc0203c10:	fc450513          	addi	a0,a0,-60 # ffffffffc0205bd0 <default_pmm_manager+0xb50>
ffffffffc0203c14:	caafc0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203c18:	57f1                	li	a5,-4
            goto failed;
ffffffffc0203c1a:	bfc9                	j	ffffffffc0203bec <do_pgfault+0x98>
        return lru_pgfault(mm, error_code, addr);
ffffffffc0203c1c:	8622                	mv	a2,s0
ffffffffc0203c1e:	85ca                	mv	a1,s2
ffffffffc0203c20:	8526                	mv	a0,s1
ffffffffc0203c22:	f0aff0ef          	jal	ra,ffffffffc020332c <lru_pgfault>
}
ffffffffc0203c26:	70a2                	ld	ra,40(sp)
ffffffffc0203c28:	7402                	ld	s0,32(sp)
        return lru_pgfault(mm, error_code, addr);
ffffffffc0203c2a:	87aa                	mv	a5,a0
}
ffffffffc0203c2c:	64e2                	ld	s1,24(sp)
ffffffffc0203c2e:	6942                	ld	s2,16(sp)
ffffffffc0203c30:	853e                	mv	a0,a5
ffffffffc0203c32:	6145                	addi	sp,sp,48
ffffffffc0203c34:	8082                	ret
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203c36:	85a2                	mv	a1,s0
ffffffffc0203c38:	00002517          	auipc	a0,0x2
ffffffffc0203c3c:	f6850513          	addi	a0,a0,-152 # ffffffffc0205ba0 <default_pmm_manager+0xb20>
ffffffffc0203c40:	c7efc0ef          	jal	ra,ffffffffc02000be <cprintf>
    int ret = -E_INVAL;
ffffffffc0203c44:	57f5                	li	a5,-3
        goto failed;
ffffffffc0203c46:	b75d                	j	ffffffffc0203bec <do_pgfault+0x98>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203c48:	00002517          	auipc	a0,0x2
ffffffffc0203c4c:	fb050513          	addi	a0,a0,-80 # ffffffffc0205bf8 <default_pmm_manager+0xb78>
ffffffffc0203c50:	c6efc0ef          	jal	ra,ffffffffc02000be <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203c54:	57f1                	li	a5,-4
            goto failed;
ffffffffc0203c56:	bf59                	j	ffffffffc0203bec <do_pgfault+0x98>

ffffffffc0203c58 <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0203c58:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203c5a:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0203c5c:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203c5e:	839fc0ef          	jal	ra,ffffffffc0200496 <ide_device_valid>
ffffffffc0203c62:	cd01                	beqz	a0,ffffffffc0203c7a <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203c64:	4505                	li	a0,1
ffffffffc0203c66:	837fc0ef          	jal	ra,ffffffffc020049c <ide_device_size>
}
ffffffffc0203c6a:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0203c6c:	810d                	srli	a0,a0,0x3
ffffffffc0203c6e:	0000e797          	auipc	a5,0xe
ffffffffc0203c72:	8ca7b523          	sd	a0,-1846(a5) # ffffffffc0211538 <max_swap_offset>
}
ffffffffc0203c76:	0141                	addi	sp,sp,16
ffffffffc0203c78:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203c7a:	00002617          	auipc	a2,0x2
ffffffffc0203c7e:	20e60613          	addi	a2,a2,526 # ffffffffc0205e88 <default_pmm_manager+0xe08>
ffffffffc0203c82:	45b5                	li	a1,13
ffffffffc0203c84:	00002517          	auipc	a0,0x2
ffffffffc0203c88:	22450513          	addi	a0,a0,548 # ffffffffc0205ea8 <default_pmm_manager+0xe28>
ffffffffc0203c8c:	ee4fc0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0203c90 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203c90:	1141                	addi	sp,sp,-16
ffffffffc0203c92:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203c94:	00855793          	srli	a5,a0,0x8
ffffffffc0203c98:	c7b5                	beqz	a5,ffffffffc0203d04 <swapfs_read+0x74>
ffffffffc0203c9a:	0000e717          	auipc	a4,0xe
ffffffffc0203c9e:	89e70713          	addi	a4,a4,-1890 # ffffffffc0211538 <max_swap_offset>
ffffffffc0203ca2:	6318                	ld	a4,0(a4)
ffffffffc0203ca4:	06e7f063          	bgeu	a5,a4,ffffffffc0203d04 <swapfs_read+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203ca8:	0000e717          	auipc	a4,0xe
ffffffffc0203cac:	80070713          	addi	a4,a4,-2048 # ffffffffc02114a8 <pages>
ffffffffc0203cb0:	6310                	ld	a2,0(a4)
ffffffffc0203cb2:	00001717          	auipc	a4,0x1
ffffffffc0203cb6:	01e70713          	addi	a4,a4,30 # ffffffffc0204cd0 <commands+0x858>
ffffffffc0203cba:	00002697          	auipc	a3,0x2
ffffffffc0203cbe:	46e68693          	addi	a3,a3,1134 # ffffffffc0206128 <nbase>
ffffffffc0203cc2:	40c58633          	sub	a2,a1,a2
ffffffffc0203cc6:	630c                	ld	a1,0(a4)
ffffffffc0203cc8:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cca:	0000d717          	auipc	a4,0xd
ffffffffc0203cce:	78e70713          	addi	a4,a4,1934 # ffffffffc0211458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203cd2:	02b60633          	mul	a2,a2,a1
ffffffffc0203cd6:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203cda:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203cdc:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203cde:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ce0:	00c61793          	slli	a5,a2,0xc
ffffffffc0203ce4:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203ce6:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ce8:	02e7fa63          	bgeu	a5,a4,ffffffffc0203d1c <swapfs_read+0x8c>
ffffffffc0203cec:	0000d797          	auipc	a5,0xd
ffffffffc0203cf0:	7ac78793          	addi	a5,a5,1964 # ffffffffc0211498 <va_pa_offset>
ffffffffc0203cf4:	639c                	ld	a5,0(a5)
}
ffffffffc0203cf6:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203cf8:	46a1                	li	a3,8
ffffffffc0203cfa:	963e                	add	a2,a2,a5
ffffffffc0203cfc:	4505                	li	a0,1
}
ffffffffc0203cfe:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d00:	fa2fc06f          	j	ffffffffc02004a2 <ide_read_secs>
ffffffffc0203d04:	86aa                	mv	a3,a0
ffffffffc0203d06:	00002617          	auipc	a2,0x2
ffffffffc0203d0a:	1ba60613          	addi	a2,a2,442 # ffffffffc0205ec0 <default_pmm_manager+0xe40>
ffffffffc0203d0e:	45d1                	li	a1,20
ffffffffc0203d10:	00002517          	auipc	a0,0x2
ffffffffc0203d14:	19850513          	addi	a0,a0,408 # ffffffffc0205ea8 <default_pmm_manager+0xe28>
ffffffffc0203d18:	e58fc0ef          	jal	ra,ffffffffc0200370 <__panic>
ffffffffc0203d1c:	86b2                	mv	a3,a2
ffffffffc0203d1e:	06a00593          	li	a1,106
ffffffffc0203d22:	00001617          	auipc	a2,0x1
ffffffffc0203d26:	3ae60613          	addi	a2,a2,942 # ffffffffc02050d0 <default_pmm_manager+0x50>
ffffffffc0203d2a:	00001517          	auipc	a0,0x1
ffffffffc0203d2e:	43e50513          	addi	a0,a0,1086 # ffffffffc0205168 <default_pmm_manager+0xe8>
ffffffffc0203d32:	e3efc0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0203d36 <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203d36:	1141                	addi	sp,sp,-16
ffffffffc0203d38:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d3a:	00855793          	srli	a5,a0,0x8
ffffffffc0203d3e:	c7b5                	beqz	a5,ffffffffc0203daa <swapfs_write+0x74>
ffffffffc0203d40:	0000d717          	auipc	a4,0xd
ffffffffc0203d44:	7f870713          	addi	a4,a4,2040 # ffffffffc0211538 <max_swap_offset>
ffffffffc0203d48:	6318                	ld	a4,0(a4)
ffffffffc0203d4a:	06e7f063          	bgeu	a5,a4,ffffffffc0203daa <swapfs_write+0x74>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d4e:	0000d717          	auipc	a4,0xd
ffffffffc0203d52:	75a70713          	addi	a4,a4,1882 # ffffffffc02114a8 <pages>
ffffffffc0203d56:	6310                	ld	a2,0(a4)
ffffffffc0203d58:	00001717          	auipc	a4,0x1
ffffffffc0203d5c:	f7870713          	addi	a4,a4,-136 # ffffffffc0204cd0 <commands+0x858>
ffffffffc0203d60:	00002697          	auipc	a3,0x2
ffffffffc0203d64:	3c868693          	addi	a3,a3,968 # ffffffffc0206128 <nbase>
ffffffffc0203d68:	40c58633          	sub	a2,a1,a2
ffffffffc0203d6c:	630c                	ld	a1,0(a4)
ffffffffc0203d6e:	860d                	srai	a2,a2,0x3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d70:	0000d717          	auipc	a4,0xd
ffffffffc0203d74:	6e870713          	addi	a4,a4,1768 # ffffffffc0211458 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d78:	02b60633          	mul	a2,a2,a1
ffffffffc0203d7c:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203d80:	629c                	ld	a5,0(a3)
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d82:	6318                	ld	a4,0(a4)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203d84:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d86:	00c61793          	slli	a5,a2,0xc
ffffffffc0203d8a:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203d8c:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203d8e:	02e7fa63          	bgeu	a5,a4,ffffffffc0203dc2 <swapfs_write+0x8c>
ffffffffc0203d92:	0000d797          	auipc	a5,0xd
ffffffffc0203d96:	70678793          	addi	a5,a5,1798 # ffffffffc0211498 <va_pa_offset>
ffffffffc0203d9a:	639c                	ld	a5,0(a5)
}
ffffffffc0203d9c:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203d9e:	46a1                	li	a3,8
ffffffffc0203da0:	963e                	add	a2,a2,a5
ffffffffc0203da2:	4505                	li	a0,1
}
ffffffffc0203da4:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203da6:	f20fc06f          	j	ffffffffc02004c6 <ide_write_secs>
ffffffffc0203daa:	86aa                	mv	a3,a0
ffffffffc0203dac:	00002617          	auipc	a2,0x2
ffffffffc0203db0:	11460613          	addi	a2,a2,276 # ffffffffc0205ec0 <default_pmm_manager+0xe40>
ffffffffc0203db4:	45e5                	li	a1,25
ffffffffc0203db6:	00002517          	auipc	a0,0x2
ffffffffc0203dba:	0f250513          	addi	a0,a0,242 # ffffffffc0205ea8 <default_pmm_manager+0xe28>
ffffffffc0203dbe:	db2fc0ef          	jal	ra,ffffffffc0200370 <__panic>
ffffffffc0203dc2:	86b2                	mv	a3,a2
ffffffffc0203dc4:	06a00593          	li	a1,106
ffffffffc0203dc8:	00001617          	auipc	a2,0x1
ffffffffc0203dcc:	30860613          	addi	a2,a2,776 # ffffffffc02050d0 <default_pmm_manager+0x50>
ffffffffc0203dd0:	00001517          	auipc	a0,0x1
ffffffffc0203dd4:	39850513          	addi	a0,a0,920 # ffffffffc0205168 <default_pmm_manager+0xe8>
ffffffffc0203dd8:	d98fc0ef          	jal	ra,ffffffffc0200370 <__panic>

ffffffffc0203ddc <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203ddc:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203de0:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203de2:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203de6:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203de8:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203dec:	f022                	sd	s0,32(sp)
ffffffffc0203dee:	ec26                	sd	s1,24(sp)
ffffffffc0203df0:	e84a                	sd	s2,16(sp)
ffffffffc0203df2:	f406                	sd	ra,40(sp)
ffffffffc0203df4:	e44e                	sd	s3,8(sp)
ffffffffc0203df6:	84aa                	mv	s1,a0
ffffffffc0203df8:	892e                	mv	s2,a1
ffffffffc0203dfa:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203dfe:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0203e00:	03067e63          	bgeu	a2,a6,ffffffffc0203e3c <printnum+0x60>
ffffffffc0203e04:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203e06:	00805763          	blez	s0,ffffffffc0203e14 <printnum+0x38>
ffffffffc0203e0a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203e0c:	85ca                	mv	a1,s2
ffffffffc0203e0e:	854e                	mv	a0,s3
ffffffffc0203e10:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203e12:	fc65                	bnez	s0,ffffffffc0203e0a <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e14:	1a02                	slli	s4,s4,0x20
ffffffffc0203e16:	020a5a13          	srli	s4,s4,0x20
ffffffffc0203e1a:	00002797          	auipc	a5,0x2
ffffffffc0203e1e:	25678793          	addi	a5,a5,598 # ffffffffc0206070 <error_string+0x38>
ffffffffc0203e22:	9a3e                	add	s4,s4,a5
}
ffffffffc0203e24:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e26:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0203e2a:	70a2                	ld	ra,40(sp)
ffffffffc0203e2c:	69a2                	ld	s3,8(sp)
ffffffffc0203e2e:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e30:	85ca                	mv	a1,s2
ffffffffc0203e32:	8326                	mv	t1,s1
}
ffffffffc0203e34:	6942                	ld	s2,16(sp)
ffffffffc0203e36:	64e2                	ld	s1,24(sp)
ffffffffc0203e38:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0203e3a:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0203e3c:	03065633          	divu	a2,a2,a6
ffffffffc0203e40:	8722                	mv	a4,s0
ffffffffc0203e42:	f9bff0ef          	jal	ra,ffffffffc0203ddc <printnum>
ffffffffc0203e46:	b7f9                	j	ffffffffc0203e14 <printnum+0x38>

ffffffffc0203e48 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0203e48:	7119                	addi	sp,sp,-128
ffffffffc0203e4a:	f4a6                	sd	s1,104(sp)
ffffffffc0203e4c:	f0ca                	sd	s2,96(sp)
ffffffffc0203e4e:	e8d2                	sd	s4,80(sp)
ffffffffc0203e50:	e4d6                	sd	s5,72(sp)
ffffffffc0203e52:	e0da                	sd	s6,64(sp)
ffffffffc0203e54:	fc5e                	sd	s7,56(sp)
ffffffffc0203e56:	f862                	sd	s8,48(sp)
ffffffffc0203e58:	f06a                	sd	s10,32(sp)
ffffffffc0203e5a:	fc86                	sd	ra,120(sp)
ffffffffc0203e5c:	f8a2                	sd	s0,112(sp)
ffffffffc0203e5e:	ecce                	sd	s3,88(sp)
ffffffffc0203e60:	f466                	sd	s9,40(sp)
ffffffffc0203e62:	ec6e                	sd	s11,24(sp)
ffffffffc0203e64:	892a                	mv	s2,a0
ffffffffc0203e66:	84ae                	mv	s1,a1
ffffffffc0203e68:	8d32                	mv	s10,a2
ffffffffc0203e6a:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0203e6c:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203e6e:	00002a17          	auipc	s4,0x2
ffffffffc0203e72:	072a0a13          	addi	s4,s4,114 # ffffffffc0205ee0 <default_pmm_manager+0xe60>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0203e76:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203e7a:	00002c17          	auipc	s8,0x2
ffffffffc0203e7e:	1bec0c13          	addi	s8,s8,446 # ffffffffc0206038 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e82:	000d4503          	lbu	a0,0(s10)
ffffffffc0203e86:	02500793          	li	a5,37
ffffffffc0203e8a:	001d0413          	addi	s0,s10,1
ffffffffc0203e8e:	00f50e63          	beq	a0,a5,ffffffffc0203eaa <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0203e92:	c521                	beqz	a0,ffffffffc0203eda <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e94:	02500993          	li	s3,37
ffffffffc0203e98:	a011                	j	ffffffffc0203e9c <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0203e9a:	c121                	beqz	a0,ffffffffc0203eda <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0203e9c:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203e9e:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0203ea0:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0203ea2:	fff44503          	lbu	a0,-1(s0)
ffffffffc0203ea6:	ff351ae3          	bne	a0,s3,ffffffffc0203e9a <vprintfmt+0x52>
ffffffffc0203eaa:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0203eae:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0203eb2:	4981                	li	s3,0
ffffffffc0203eb4:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0203eb6:	5cfd                	li	s9,-1
ffffffffc0203eb8:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203eba:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0203ebe:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203ec0:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0203ec4:	0ff6f693          	andi	a3,a3,255
ffffffffc0203ec8:	00140d13          	addi	s10,s0,1
ffffffffc0203ecc:	1ed5ef63          	bltu	a1,a3,ffffffffc02040ca <vprintfmt+0x282>
ffffffffc0203ed0:	068a                	slli	a3,a3,0x2
ffffffffc0203ed2:	96d2                	add	a3,a3,s4
ffffffffc0203ed4:	4294                	lw	a3,0(a3)
ffffffffc0203ed6:	96d2                	add	a3,a3,s4
ffffffffc0203ed8:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0203eda:	70e6                	ld	ra,120(sp)
ffffffffc0203edc:	7446                	ld	s0,112(sp)
ffffffffc0203ede:	74a6                	ld	s1,104(sp)
ffffffffc0203ee0:	7906                	ld	s2,96(sp)
ffffffffc0203ee2:	69e6                	ld	s3,88(sp)
ffffffffc0203ee4:	6a46                	ld	s4,80(sp)
ffffffffc0203ee6:	6aa6                	ld	s5,72(sp)
ffffffffc0203ee8:	6b06                	ld	s6,64(sp)
ffffffffc0203eea:	7be2                	ld	s7,56(sp)
ffffffffc0203eec:	7c42                	ld	s8,48(sp)
ffffffffc0203eee:	7ca2                	ld	s9,40(sp)
ffffffffc0203ef0:	7d02                	ld	s10,32(sp)
ffffffffc0203ef2:	6de2                	ld	s11,24(sp)
ffffffffc0203ef4:	6109                	addi	sp,sp,128
ffffffffc0203ef6:	8082                	ret
            padc = '-';
ffffffffc0203ef8:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203efa:	00144603          	lbu	a2,1(s0)
ffffffffc0203efe:	846a                	mv	s0,s10
ffffffffc0203f00:	b7c1                	j	ffffffffc0203ec0 <vprintfmt+0x78>
            precision = va_arg(ap, int);
ffffffffc0203f02:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0203f06:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0203f0a:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f0c:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0203f0e:	fa0dd9e3          	bgez	s11,ffffffffc0203ec0 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0203f12:	8de6                	mv	s11,s9
ffffffffc0203f14:	5cfd                	li	s9,-1
ffffffffc0203f16:	b76d                	j	ffffffffc0203ec0 <vprintfmt+0x78>
            if (width < 0)
ffffffffc0203f18:	fffdc693          	not	a3,s11
ffffffffc0203f1c:	96fd                	srai	a3,a3,0x3f
ffffffffc0203f1e:	00ddfdb3          	and	s11,s11,a3
ffffffffc0203f22:	00144603          	lbu	a2,1(s0)
ffffffffc0203f26:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f28:	846a                	mv	s0,s10
ffffffffc0203f2a:	bf59                	j	ffffffffc0203ec0 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0203f2c:	4705                	li	a4,1
ffffffffc0203f2e:	008a8593          	addi	a1,s5,8
ffffffffc0203f32:	01074463          	blt	a4,a6,ffffffffc0203f3a <vprintfmt+0xf2>
    else if (lflag) {
ffffffffc0203f36:	22080863          	beqz	a6,ffffffffc0204166 <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
ffffffffc0203f3a:	000ab603          	ld	a2,0(s5)
ffffffffc0203f3e:	46c1                	li	a3,16
ffffffffc0203f40:	8aae                	mv	s5,a1
ffffffffc0203f42:	a291                	j	ffffffffc0204086 <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
ffffffffc0203f44:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0203f48:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0203f4c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0203f4e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0203f52:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203f56:	fad56ce3          	bltu	a0,a3,ffffffffc0203f0e <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
ffffffffc0203f5a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0203f5c:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0203f60:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0203f64:	0196873b          	addw	a4,a3,s9
ffffffffc0203f68:	0017171b          	slliw	a4,a4,0x1
ffffffffc0203f6c:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0203f70:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0203f74:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0203f78:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0203f7c:	fcd57fe3          	bgeu	a0,a3,ffffffffc0203f5a <vprintfmt+0x112>
ffffffffc0203f80:	b779                	j	ffffffffc0203f0e <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
ffffffffc0203f82:	000aa503          	lw	a0,0(s5)
ffffffffc0203f86:	85a6                	mv	a1,s1
ffffffffc0203f88:	0aa1                	addi	s5,s5,8
ffffffffc0203f8a:	9902                	jalr	s2
            break;
ffffffffc0203f8c:	bddd                	j	ffffffffc0203e82 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0203f8e:	4705                	li	a4,1
ffffffffc0203f90:	008a8993          	addi	s3,s5,8
ffffffffc0203f94:	01074463          	blt	a4,a6,ffffffffc0203f9c <vprintfmt+0x154>
    else if (lflag) {
ffffffffc0203f98:	1c080463          	beqz	a6,ffffffffc0204160 <vprintfmt+0x318>
        return va_arg(*ap, long);
ffffffffc0203f9c:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc0203fa0:	1c044a63          	bltz	s0,ffffffffc0204174 <vprintfmt+0x32c>
            num = getint(&ap, lflag);
ffffffffc0203fa4:	8622                	mv	a2,s0
ffffffffc0203fa6:	8ace                	mv	s5,s3
ffffffffc0203fa8:	46a9                	li	a3,10
ffffffffc0203faa:	a8f1                	j	ffffffffc0204086 <vprintfmt+0x23e>
            err = va_arg(ap, int);
ffffffffc0203fac:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203fb0:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc0203fb2:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc0203fb4:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0203fb8:	8fb5                	xor	a5,a5,a3
ffffffffc0203fba:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0203fbe:	12d74963          	blt	a4,a3,ffffffffc02040f0 <vprintfmt+0x2a8>
ffffffffc0203fc2:	00369793          	slli	a5,a3,0x3
ffffffffc0203fc6:	97e2                	add	a5,a5,s8
ffffffffc0203fc8:	639c                	ld	a5,0(a5)
ffffffffc0203fca:	12078363          	beqz	a5,ffffffffc02040f0 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
ffffffffc0203fce:	86be                	mv	a3,a5
ffffffffc0203fd0:	00002617          	auipc	a2,0x2
ffffffffc0203fd4:	15060613          	addi	a2,a2,336 # ffffffffc0206120 <error_string+0xe8>
ffffffffc0203fd8:	85a6                	mv	a1,s1
ffffffffc0203fda:	854a                	mv	a0,s2
ffffffffc0203fdc:	1cc000ef          	jal	ra,ffffffffc02041a8 <printfmt>
ffffffffc0203fe0:	b54d                	j	ffffffffc0203e82 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0203fe2:	000ab603          	ld	a2,0(s5)
ffffffffc0203fe6:	0aa1                	addi	s5,s5,8
ffffffffc0203fe8:	1a060163          	beqz	a2,ffffffffc020418a <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
ffffffffc0203fec:	00160413          	addi	s0,a2,1
ffffffffc0203ff0:	15b05763          	blez	s11,ffffffffc020413e <vprintfmt+0x2f6>
ffffffffc0203ff4:	02d00593          	li	a1,45
ffffffffc0203ff8:	10b79d63          	bne	a5,a1,ffffffffc0204112 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0203ffc:	00064783          	lbu	a5,0(a2)
ffffffffc0204000:	0007851b          	sext.w	a0,a5
ffffffffc0204004:	c905                	beqz	a0,ffffffffc0204034 <vprintfmt+0x1ec>
ffffffffc0204006:	000cc563          	bltz	s9,ffffffffc0204010 <vprintfmt+0x1c8>
ffffffffc020400a:	3cfd                	addiw	s9,s9,-1
ffffffffc020400c:	036c8263          	beq	s9,s6,ffffffffc0204030 <vprintfmt+0x1e8>
                    putch('?', putdat);
ffffffffc0204010:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204012:	14098f63          	beqz	s3,ffffffffc0204170 <vprintfmt+0x328>
ffffffffc0204016:	3781                	addiw	a5,a5,-32
ffffffffc0204018:	14fbfc63          	bgeu	s7,a5,ffffffffc0204170 <vprintfmt+0x328>
                    putch('?', putdat);
ffffffffc020401c:	03f00513          	li	a0,63
ffffffffc0204020:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204022:	0405                	addi	s0,s0,1
ffffffffc0204024:	fff44783          	lbu	a5,-1(s0)
ffffffffc0204028:	3dfd                	addiw	s11,s11,-1
ffffffffc020402a:	0007851b          	sext.w	a0,a5
ffffffffc020402e:	fd61                	bnez	a0,ffffffffc0204006 <vprintfmt+0x1be>
            for (; width > 0; width --) {
ffffffffc0204030:	e5b059e3          	blez	s11,ffffffffc0203e82 <vprintfmt+0x3a>
ffffffffc0204034:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204036:	85a6                	mv	a1,s1
ffffffffc0204038:	02000513          	li	a0,32
ffffffffc020403c:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020403e:	e40d82e3          	beqz	s11,ffffffffc0203e82 <vprintfmt+0x3a>
ffffffffc0204042:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0204044:	85a6                	mv	a1,s1
ffffffffc0204046:	02000513          	li	a0,32
ffffffffc020404a:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc020404c:	fe0d94e3          	bnez	s11,ffffffffc0204034 <vprintfmt+0x1ec>
ffffffffc0204050:	bd0d                	j	ffffffffc0203e82 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0204052:	4705                	li	a4,1
ffffffffc0204054:	008a8593          	addi	a1,s5,8
ffffffffc0204058:	01074463          	blt	a4,a6,ffffffffc0204060 <vprintfmt+0x218>
    else if (lflag) {
ffffffffc020405c:	0e080863          	beqz	a6,ffffffffc020414c <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
ffffffffc0204060:	000ab603          	ld	a2,0(s5)
ffffffffc0204064:	46a1                	li	a3,8
ffffffffc0204066:	8aae                	mv	s5,a1
ffffffffc0204068:	a839                	j	ffffffffc0204086 <vprintfmt+0x23e>
            putch('0', putdat);
ffffffffc020406a:	03000513          	li	a0,48
ffffffffc020406e:	85a6                	mv	a1,s1
ffffffffc0204070:	e03e                	sd	a5,0(sp)
ffffffffc0204072:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0204074:	85a6                	mv	a1,s1
ffffffffc0204076:	07800513          	li	a0,120
ffffffffc020407a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020407c:	0aa1                	addi	s5,s5,8
ffffffffc020407e:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0204082:	6782                	ld	a5,0(sp)
ffffffffc0204084:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0204086:	2781                	sext.w	a5,a5
ffffffffc0204088:	876e                	mv	a4,s11
ffffffffc020408a:	85a6                	mv	a1,s1
ffffffffc020408c:	854a                	mv	a0,s2
ffffffffc020408e:	d4fff0ef          	jal	ra,ffffffffc0203ddc <printnum>
            break;
ffffffffc0204092:	bbc5                	j	ffffffffc0203e82 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0204094:	00144603          	lbu	a2,1(s0)
ffffffffc0204098:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020409a:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc020409c:	b515                	j	ffffffffc0203ec0 <vprintfmt+0x78>
            goto reswitch;
ffffffffc020409e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02040a2:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040a4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02040a6:	bd29                	j	ffffffffc0203ec0 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02040a8:	85a6                	mv	a1,s1
ffffffffc02040aa:	02500513          	li	a0,37
ffffffffc02040ae:	9902                	jalr	s2
            break;
ffffffffc02040b0:	bbc9                	j	ffffffffc0203e82 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02040b2:	4705                	li	a4,1
ffffffffc02040b4:	008a8593          	addi	a1,s5,8
ffffffffc02040b8:	01074463          	blt	a4,a6,ffffffffc02040c0 <vprintfmt+0x278>
    else if (lflag) {
ffffffffc02040bc:	08080d63          	beqz	a6,ffffffffc0204156 <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
ffffffffc02040c0:	000ab603          	ld	a2,0(s5)
ffffffffc02040c4:	46a9                	li	a3,10
ffffffffc02040c6:	8aae                	mv	s5,a1
ffffffffc02040c8:	bf7d                	j	ffffffffc0204086 <vprintfmt+0x23e>
            putch('%', putdat);
ffffffffc02040ca:	85a6                	mv	a1,s1
ffffffffc02040cc:	02500513          	li	a0,37
ffffffffc02040d0:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02040d2:	fff44703          	lbu	a4,-1(s0)
ffffffffc02040d6:	02500793          	li	a5,37
ffffffffc02040da:	8d22                	mv	s10,s0
ffffffffc02040dc:	daf703e3          	beq	a4,a5,ffffffffc0203e82 <vprintfmt+0x3a>
ffffffffc02040e0:	02500713          	li	a4,37
ffffffffc02040e4:	1d7d                	addi	s10,s10,-1
ffffffffc02040e6:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02040ea:	fee79de3          	bne	a5,a4,ffffffffc02040e4 <vprintfmt+0x29c>
ffffffffc02040ee:	bb51                	j	ffffffffc0203e82 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02040f0:	00002617          	auipc	a2,0x2
ffffffffc02040f4:	02060613          	addi	a2,a2,32 # ffffffffc0206110 <error_string+0xd8>
ffffffffc02040f8:	85a6                	mv	a1,s1
ffffffffc02040fa:	854a                	mv	a0,s2
ffffffffc02040fc:	0ac000ef          	jal	ra,ffffffffc02041a8 <printfmt>
ffffffffc0204100:	b349                	j	ffffffffc0203e82 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0204102:	00002617          	auipc	a2,0x2
ffffffffc0204106:	00660613          	addi	a2,a2,6 # ffffffffc0206108 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc020410a:	00002417          	auipc	s0,0x2
ffffffffc020410e:	fff40413          	addi	s0,s0,-1 # ffffffffc0206109 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204112:	8532                	mv	a0,a2
ffffffffc0204114:	85e6                	mv	a1,s9
ffffffffc0204116:	e032                	sd	a2,0(sp)
ffffffffc0204118:	e43e                	sd	a5,8(sp)
ffffffffc020411a:	18a000ef          	jal	ra,ffffffffc02042a4 <strnlen>
ffffffffc020411e:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0204122:	6602                	ld	a2,0(sp)
ffffffffc0204124:	01b05d63          	blez	s11,ffffffffc020413e <vprintfmt+0x2f6>
ffffffffc0204128:	67a2                	ld	a5,8(sp)
ffffffffc020412a:	2781                	sext.w	a5,a5
ffffffffc020412c:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc020412e:	6522                	ld	a0,8(sp)
ffffffffc0204130:	85a6                	mv	a1,s1
ffffffffc0204132:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204134:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204136:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204138:	6602                	ld	a2,0(sp)
ffffffffc020413a:	fe0d9ae3          	bnez	s11,ffffffffc020412e <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020413e:	00064783          	lbu	a5,0(a2)
ffffffffc0204142:	0007851b          	sext.w	a0,a5
ffffffffc0204146:	ec0510e3          	bnez	a0,ffffffffc0204006 <vprintfmt+0x1be>
ffffffffc020414a:	bb25                	j	ffffffffc0203e82 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
ffffffffc020414c:	000ae603          	lwu	a2,0(s5)
ffffffffc0204150:	46a1                	li	a3,8
ffffffffc0204152:	8aae                	mv	s5,a1
ffffffffc0204154:	bf0d                	j	ffffffffc0204086 <vprintfmt+0x23e>
ffffffffc0204156:	000ae603          	lwu	a2,0(s5)
ffffffffc020415a:	46a9                	li	a3,10
ffffffffc020415c:	8aae                	mv	s5,a1
ffffffffc020415e:	b725                	j	ffffffffc0204086 <vprintfmt+0x23e>
        return va_arg(*ap, int);
ffffffffc0204160:	000aa403          	lw	s0,0(s5)
ffffffffc0204164:	bd35                	j	ffffffffc0203fa0 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
ffffffffc0204166:	000ae603          	lwu	a2,0(s5)
ffffffffc020416a:	46c1                	li	a3,16
ffffffffc020416c:	8aae                	mv	s5,a1
ffffffffc020416e:	bf21                	j	ffffffffc0204086 <vprintfmt+0x23e>
                    putch(ch, putdat);
ffffffffc0204170:	9902                	jalr	s2
ffffffffc0204172:	bd45                	j	ffffffffc0204022 <vprintfmt+0x1da>
                putch('-', putdat);
ffffffffc0204174:	85a6                	mv	a1,s1
ffffffffc0204176:	02d00513          	li	a0,45
ffffffffc020417a:	e03e                	sd	a5,0(sp)
ffffffffc020417c:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc020417e:	8ace                	mv	s5,s3
ffffffffc0204180:	40800633          	neg	a2,s0
ffffffffc0204184:	46a9                	li	a3,10
ffffffffc0204186:	6782                	ld	a5,0(sp)
ffffffffc0204188:	bdfd                	j	ffffffffc0204086 <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
ffffffffc020418a:	01b05663          	blez	s11,ffffffffc0204196 <vprintfmt+0x34e>
ffffffffc020418e:	02d00693          	li	a3,45
ffffffffc0204192:	f6d798e3          	bne	a5,a3,ffffffffc0204102 <vprintfmt+0x2ba>
ffffffffc0204196:	00002417          	auipc	s0,0x2
ffffffffc020419a:	f7340413          	addi	s0,s0,-141 # ffffffffc0206109 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020419e:	02800513          	li	a0,40
ffffffffc02041a2:	02800793          	li	a5,40
ffffffffc02041a6:	b585                	j	ffffffffc0204006 <vprintfmt+0x1be>

ffffffffc02041a8 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02041a8:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02041aa:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02041ae:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02041b0:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02041b2:	ec06                	sd	ra,24(sp)
ffffffffc02041b4:	f83a                	sd	a4,48(sp)
ffffffffc02041b6:	fc3e                	sd	a5,56(sp)
ffffffffc02041b8:	e0c2                	sd	a6,64(sp)
ffffffffc02041ba:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02041bc:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02041be:	c8bff0ef          	jal	ra,ffffffffc0203e48 <vprintfmt>
}
ffffffffc02041c2:	60e2                	ld	ra,24(sp)
ffffffffc02041c4:	6161                	addi	sp,sp,80
ffffffffc02041c6:	8082                	ret

ffffffffc02041c8 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02041c8:	715d                	addi	sp,sp,-80
ffffffffc02041ca:	e486                	sd	ra,72(sp)
ffffffffc02041cc:	e0a2                	sd	s0,64(sp)
ffffffffc02041ce:	fc26                	sd	s1,56(sp)
ffffffffc02041d0:	f84a                	sd	s2,48(sp)
ffffffffc02041d2:	f44e                	sd	s3,40(sp)
ffffffffc02041d4:	f052                	sd	s4,32(sp)
ffffffffc02041d6:	ec56                	sd	s5,24(sp)
ffffffffc02041d8:	e85a                	sd	s6,16(sp)
ffffffffc02041da:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02041dc:	c901                	beqz	a0,ffffffffc02041ec <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02041de:	85aa                	mv	a1,a0
ffffffffc02041e0:	00002517          	auipc	a0,0x2
ffffffffc02041e4:	f4050513          	addi	a0,a0,-192 # ffffffffc0206120 <error_string+0xe8>
ffffffffc02041e8:	ed7fb0ef          	jal	ra,ffffffffc02000be <cprintf>
readline(const char *prompt) {
ffffffffc02041ec:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02041ee:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02041f0:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02041f2:	4aa9                	li	s5,10
ffffffffc02041f4:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02041f6:	0000db97          	auipc	s7,0xd
ffffffffc02041fa:	e4ab8b93          	addi	s7,s7,-438 # ffffffffc0211040 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02041fe:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0204202:	ef3fb0ef          	jal	ra,ffffffffc02000f4 <getchar>
ffffffffc0204206:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0204208:	00054b63          	bltz	a0,ffffffffc020421e <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020420c:	00a95b63          	bge	s2,a0,ffffffffc0204222 <readline+0x5a>
ffffffffc0204210:	029a5463          	bge	s4,s1,ffffffffc0204238 <readline+0x70>
        c = getchar();
ffffffffc0204214:	ee1fb0ef          	jal	ra,ffffffffc02000f4 <getchar>
ffffffffc0204218:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020421a:	fe0559e3          	bgez	a0,ffffffffc020420c <readline+0x44>
            return NULL;
ffffffffc020421e:	4501                	li	a0,0
ffffffffc0204220:	a099                	j	ffffffffc0204266 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0204222:	03341463          	bne	s0,s3,ffffffffc020424a <readline+0x82>
ffffffffc0204226:	e8b9                	bnez	s1,ffffffffc020427c <readline+0xb4>
        c = getchar();
ffffffffc0204228:	ecdfb0ef          	jal	ra,ffffffffc02000f4 <getchar>
ffffffffc020422c:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020422e:	fe0548e3          	bltz	a0,ffffffffc020421e <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204232:	fea958e3          	bge	s2,a0,ffffffffc0204222 <readline+0x5a>
ffffffffc0204236:	4481                	li	s1,0
            cputchar(c);
ffffffffc0204238:	8522                	mv	a0,s0
ffffffffc020423a:	eb9fb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i ++] = c;
ffffffffc020423e:	009b87b3          	add	a5,s7,s1
ffffffffc0204242:	00878023          	sb	s0,0(a5)
ffffffffc0204246:	2485                	addiw	s1,s1,1
ffffffffc0204248:	bf6d                	j	ffffffffc0204202 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc020424a:	01540463          	beq	s0,s5,ffffffffc0204252 <readline+0x8a>
ffffffffc020424e:	fb641ae3          	bne	s0,s6,ffffffffc0204202 <readline+0x3a>
            cputchar(c);
ffffffffc0204252:	8522                	mv	a0,s0
ffffffffc0204254:	e9ffb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            buf[i] = '\0';
ffffffffc0204258:	0000d517          	auipc	a0,0xd
ffffffffc020425c:	de850513          	addi	a0,a0,-536 # ffffffffc0211040 <buf>
ffffffffc0204260:	94aa                	add	s1,s1,a0
ffffffffc0204262:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0204266:	60a6                	ld	ra,72(sp)
ffffffffc0204268:	6406                	ld	s0,64(sp)
ffffffffc020426a:	74e2                	ld	s1,56(sp)
ffffffffc020426c:	7942                	ld	s2,48(sp)
ffffffffc020426e:	79a2                	ld	s3,40(sp)
ffffffffc0204270:	7a02                	ld	s4,32(sp)
ffffffffc0204272:	6ae2                	ld	s5,24(sp)
ffffffffc0204274:	6b42                	ld	s6,16(sp)
ffffffffc0204276:	6ba2                	ld	s7,8(sp)
ffffffffc0204278:	6161                	addi	sp,sp,80
ffffffffc020427a:	8082                	ret
            cputchar(c);
ffffffffc020427c:	4521                	li	a0,8
ffffffffc020427e:	e75fb0ef          	jal	ra,ffffffffc02000f2 <cputchar>
            i --;
ffffffffc0204282:	34fd                	addiw	s1,s1,-1
ffffffffc0204284:	bfbd                	j	ffffffffc0204202 <readline+0x3a>

ffffffffc0204286 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0204286:	00054783          	lbu	a5,0(a0)
ffffffffc020428a:	cb91                	beqz	a5,ffffffffc020429e <strlen+0x18>
    size_t cnt = 0;
ffffffffc020428c:	4781                	li	a5,0
        cnt ++;
ffffffffc020428e:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0204290:	00f50733          	add	a4,a0,a5
ffffffffc0204294:	00074703          	lbu	a4,0(a4)
ffffffffc0204298:	fb7d                	bnez	a4,ffffffffc020428e <strlen+0x8>
    }
    return cnt;
}
ffffffffc020429a:	853e                	mv	a0,a5
ffffffffc020429c:	8082                	ret
    size_t cnt = 0;
ffffffffc020429e:	4781                	li	a5,0
}
ffffffffc02042a0:	853e                	mv	a0,a5
ffffffffc02042a2:	8082                	ret

ffffffffc02042a4 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc02042a4:	c185                	beqz	a1,ffffffffc02042c4 <strnlen+0x20>
ffffffffc02042a6:	00054783          	lbu	a5,0(a0)
ffffffffc02042aa:	cf89                	beqz	a5,ffffffffc02042c4 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc02042ac:	4781                	li	a5,0
ffffffffc02042ae:	a021                	j	ffffffffc02042b6 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc02042b0:	00074703          	lbu	a4,0(a4)
ffffffffc02042b4:	c711                	beqz	a4,ffffffffc02042c0 <strnlen+0x1c>
        cnt ++;
ffffffffc02042b6:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02042b8:	00f50733          	add	a4,a0,a5
ffffffffc02042bc:	fef59ae3          	bne	a1,a5,ffffffffc02042b0 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02042c0:	853e                	mv	a0,a5
ffffffffc02042c2:	8082                	ret
    size_t cnt = 0;
ffffffffc02042c4:	4781                	li	a5,0
}
ffffffffc02042c6:	853e                	mv	a0,a5
ffffffffc02042c8:	8082                	ret

ffffffffc02042ca <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02042ca:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02042cc:	0585                	addi	a1,a1,1
ffffffffc02042ce:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02042d2:	0785                	addi	a5,a5,1
ffffffffc02042d4:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02042d8:	fb75                	bnez	a4,ffffffffc02042cc <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02042da:	8082                	ret

ffffffffc02042dc <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02042dc:	00054783          	lbu	a5,0(a0)
ffffffffc02042e0:	0005c703          	lbu	a4,0(a1)
ffffffffc02042e4:	cb91                	beqz	a5,ffffffffc02042f8 <strcmp+0x1c>
ffffffffc02042e6:	00e79c63          	bne	a5,a4,ffffffffc02042fe <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc02042ea:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02042ec:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc02042f0:	0585                	addi	a1,a1,1
ffffffffc02042f2:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02042f6:	fbe5                	bnez	a5,ffffffffc02042e6 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02042f8:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02042fa:	9d19                	subw	a0,a0,a4
ffffffffc02042fc:	8082                	ret
ffffffffc02042fe:	0007851b          	sext.w	a0,a5
ffffffffc0204302:	9d19                	subw	a0,a0,a4
ffffffffc0204304:	8082                	ret

ffffffffc0204306 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0204306:	00054783          	lbu	a5,0(a0)
ffffffffc020430a:	cb91                	beqz	a5,ffffffffc020431e <strchr+0x18>
        if (*s == c) {
ffffffffc020430c:	00b79563          	bne	a5,a1,ffffffffc0204316 <strchr+0x10>
ffffffffc0204310:	a809                	j	ffffffffc0204322 <strchr+0x1c>
ffffffffc0204312:	00b78763          	beq	a5,a1,ffffffffc0204320 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0204316:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0204318:	00054783          	lbu	a5,0(a0)
ffffffffc020431c:	fbfd                	bnez	a5,ffffffffc0204312 <strchr+0xc>
    }
    return NULL;
ffffffffc020431e:	4501                	li	a0,0
}
ffffffffc0204320:	8082                	ret
ffffffffc0204322:	8082                	ret

ffffffffc0204324 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0204324:	ca01                	beqz	a2,ffffffffc0204334 <memset+0x10>
ffffffffc0204326:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0204328:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020432a:	0785                	addi	a5,a5,1
ffffffffc020432c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0204330:	fec79de3          	bne	a5,a2,ffffffffc020432a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0204334:	8082                	ret

ffffffffc0204336 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0204336:	ca19                	beqz	a2,ffffffffc020434c <memcpy+0x16>
ffffffffc0204338:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020433a:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc020433c:	0585                	addi	a1,a1,1
ffffffffc020433e:	fff5c703          	lbu	a4,-1(a1)
ffffffffc0204342:	0785                	addi	a5,a5,1
ffffffffc0204344:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0204348:	fec59ae3          	bne	a1,a2,ffffffffc020433c <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc020434c:	8082                	ret
