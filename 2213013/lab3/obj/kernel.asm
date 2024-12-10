
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
ffffffffc0200024:	c0209137          	lui	sp,0xc0209

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200028:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020002c:	03228293          	addi	t0,t0,50 # ffffffffc0200032 <kern_init>
    jr t0
ffffffffc0200030:	8282                	jr	t0

ffffffffc0200032 <kern_init>:


int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200032:	0000a517          	auipc	a0,0xa
ffffffffc0200036:	00e50513          	addi	a0,a0,14 # ffffffffc020a040 <ide>
ffffffffc020003a:	00011617          	auipc	a2,0x11
ffffffffc020003e:	53260613          	addi	a2,a2,1330 # ffffffffc021156c <end>
kern_init(void) {
ffffffffc0200042:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200044:	8e09                	sub	a2,a2,a0
ffffffffc0200046:	4581                	li	a1,0
kern_init(void) {
ffffffffc0200048:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004a:	49c040ef          	jal	ra,ffffffffc02044e6 <memset>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020004e:	00004597          	auipc	a1,0x4
ffffffffc0200052:	4c258593          	addi	a1,a1,1218 # ffffffffc0204510 <etext>
ffffffffc0200056:	00004517          	auipc	a0,0x4
ffffffffc020005a:	4da50513          	addi	a0,a0,1242 # ffffffffc0204530 <etext+0x20>
ffffffffc020005e:	05c000ef          	jal	ra,ffffffffc02000ba <cprintf>

    print_kerninfo();
ffffffffc0200062:	0a0000ef          	jal	ra,ffffffffc0200102 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc0200066:	35d010ef          	jal	ra,ffffffffc0201bc2 <pmm_init>

    idt_init();                 // init interrupt descriptor table
ffffffffc020006a:	4fa000ef          	jal	ra,ffffffffc0200564 <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020006e:	71a030ef          	jal	ra,ffffffffc0203788 <vmm_init>

    ide_init();                 // init ide devices
ffffffffc0200072:	420000ef          	jal	ra,ffffffffc0200492 <ide_init>
    swap_init();                // init swap
ffffffffc0200076:	1b1020ef          	jal	ra,ffffffffc0202a26 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020007a:	356000ef          	jal	ra,ffffffffc02003d0 <clock_init>
    // intr_enable();              // enable irq interrupt



    /* do nothing */
    while (1);
ffffffffc020007e:	a001                	j	ffffffffc020007e <kern_init+0x4c>

ffffffffc0200080 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200080:	1141                	addi	sp,sp,-16
ffffffffc0200082:	e022                	sd	s0,0(sp)
ffffffffc0200084:	e406                	sd	ra,8(sp)
ffffffffc0200086:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200088:	39a000ef          	jal	ra,ffffffffc0200422 <cons_putc>
    (*cnt) ++;
ffffffffc020008c:	401c                	lw	a5,0(s0)
}
ffffffffc020008e:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200090:	2785                	addiw	a5,a5,1
ffffffffc0200092:	c01c                	sw	a5,0(s0)
}
ffffffffc0200094:	6402                	ld	s0,0(sp)
ffffffffc0200096:	0141                	addi	sp,sp,16
ffffffffc0200098:	8082                	ret

ffffffffc020009a <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020009a:	1101                	addi	sp,sp,-32
ffffffffc020009c:	862a                	mv	a2,a0
ffffffffc020009e:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000a0:	00000517          	auipc	a0,0x0
ffffffffc02000a4:	fe050513          	addi	a0,a0,-32 # ffffffffc0200080 <cputch>
ffffffffc02000a8:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000aa:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000ac:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000ae:	787030ef          	jal	ra,ffffffffc0204034 <vprintfmt>
    return cnt;
}
ffffffffc02000b2:	60e2                	ld	ra,24(sp)
ffffffffc02000b4:	4532                	lw	a0,12(sp)
ffffffffc02000b6:	6105                	addi	sp,sp,32
ffffffffc02000b8:	8082                	ret

ffffffffc02000ba <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000ba:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000bc:	02810313          	addi	t1,sp,40 # ffffffffc0209028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000c0:	8e2a                	mv	t3,a0
ffffffffc02000c2:	f42e                	sd	a1,40(sp)
ffffffffc02000c4:	f832                	sd	a2,48(sp)
ffffffffc02000c6:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c8:	00000517          	auipc	a0,0x0
ffffffffc02000cc:	fb850513          	addi	a0,a0,-72 # ffffffffc0200080 <cputch>
ffffffffc02000d0:	004c                	addi	a1,sp,4
ffffffffc02000d2:	869a                	mv	a3,t1
ffffffffc02000d4:	8672                	mv	a2,t3
cprintf(const char *fmt, ...) {
ffffffffc02000d6:	ec06                	sd	ra,24(sp)
ffffffffc02000d8:	e0ba                	sd	a4,64(sp)
ffffffffc02000da:	e4be                	sd	a5,72(sp)
ffffffffc02000dc:	e8c2                	sd	a6,80(sp)
ffffffffc02000de:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000e0:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000e2:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000e4:	751030ef          	jal	ra,ffffffffc0204034 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e8:	60e2                	ld	ra,24(sp)
ffffffffc02000ea:	4512                	lw	a0,4(sp)
ffffffffc02000ec:	6125                	addi	sp,sp,96
ffffffffc02000ee:	8082                	ret

ffffffffc02000f0 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000f0:	ae0d                	j	ffffffffc0200422 <cons_putc>

ffffffffc02000f2 <getchar>:
    return cnt;
}

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc02000f2:	1141                	addi	sp,sp,-16
ffffffffc02000f4:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc02000f6:	360000ef          	jal	ra,ffffffffc0200456 <cons_getc>
ffffffffc02000fa:	dd75                	beqz	a0,ffffffffc02000f6 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc02000fc:	60a2                	ld	ra,8(sp)
ffffffffc02000fe:	0141                	addi	sp,sp,16
ffffffffc0200100:	8082                	ret

ffffffffc0200102 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200102:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200104:	00004517          	auipc	a0,0x4
ffffffffc0200108:	43450513          	addi	a0,a0,1076 # ffffffffc0204538 <etext+0x28>
void print_kerninfo(void) {
ffffffffc020010c:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc020010e:	fadff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200112:	00000597          	auipc	a1,0x0
ffffffffc0200116:	f2058593          	addi	a1,a1,-224 # ffffffffc0200032 <kern_init>
ffffffffc020011a:	00004517          	auipc	a0,0x4
ffffffffc020011e:	43e50513          	addi	a0,a0,1086 # ffffffffc0204558 <etext+0x48>
ffffffffc0200122:	f99ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200126:	00004597          	auipc	a1,0x4
ffffffffc020012a:	3ea58593          	addi	a1,a1,1002 # ffffffffc0204510 <etext>
ffffffffc020012e:	00004517          	auipc	a0,0x4
ffffffffc0200132:	44a50513          	addi	a0,a0,1098 # ffffffffc0204578 <etext+0x68>
ffffffffc0200136:	f85ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020013a:	0000a597          	auipc	a1,0xa
ffffffffc020013e:	f0658593          	addi	a1,a1,-250 # ffffffffc020a040 <ide>
ffffffffc0200142:	00004517          	auipc	a0,0x4
ffffffffc0200146:	45650513          	addi	a0,a0,1110 # ffffffffc0204598 <etext+0x88>
ffffffffc020014a:	f71ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc020014e:	00011597          	auipc	a1,0x11
ffffffffc0200152:	41e58593          	addi	a1,a1,1054 # ffffffffc021156c <end>
ffffffffc0200156:	00004517          	auipc	a0,0x4
ffffffffc020015a:	46250513          	addi	a0,a0,1122 # ffffffffc02045b8 <etext+0xa8>
ffffffffc020015e:	f5dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200162:	00012597          	auipc	a1,0x12
ffffffffc0200166:	80958593          	addi	a1,a1,-2039 # ffffffffc021196b <end+0x3ff>
ffffffffc020016a:	00000797          	auipc	a5,0x0
ffffffffc020016e:	ec878793          	addi	a5,a5,-312 # ffffffffc0200032 <kern_init>
ffffffffc0200172:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200176:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020017a:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020017c:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200180:	95be                	add	a1,a1,a5
ffffffffc0200182:	85a9                	srai	a1,a1,0xa
ffffffffc0200184:	00004517          	auipc	a0,0x4
ffffffffc0200188:	45450513          	addi	a0,a0,1108 # ffffffffc02045d8 <etext+0xc8>
}
ffffffffc020018c:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020018e:	b735                	j	ffffffffc02000ba <cprintf>

ffffffffc0200190 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc0200190:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc0200192:	00004617          	auipc	a2,0x4
ffffffffc0200196:	47660613          	addi	a2,a2,1142 # ffffffffc0204608 <etext+0xf8>
ffffffffc020019a:	04e00593          	li	a1,78
ffffffffc020019e:	00004517          	auipc	a0,0x4
ffffffffc02001a2:	48250513          	addi	a0,a0,1154 # ffffffffc0204620 <etext+0x110>
void print_stackframe(void) {
ffffffffc02001a6:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001a8:	1cc000ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02001ac <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001ac:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001ae:	00004617          	auipc	a2,0x4
ffffffffc02001b2:	48a60613          	addi	a2,a2,1162 # ffffffffc0204638 <etext+0x128>
ffffffffc02001b6:	00004597          	auipc	a1,0x4
ffffffffc02001ba:	4a258593          	addi	a1,a1,1186 # ffffffffc0204658 <etext+0x148>
ffffffffc02001be:	00004517          	auipc	a0,0x4
ffffffffc02001c2:	4a250513          	addi	a0,a0,1186 # ffffffffc0204660 <etext+0x150>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001c6:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001c8:	ef3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02001cc:	00004617          	auipc	a2,0x4
ffffffffc02001d0:	4a460613          	addi	a2,a2,1188 # ffffffffc0204670 <etext+0x160>
ffffffffc02001d4:	00004597          	auipc	a1,0x4
ffffffffc02001d8:	4c458593          	addi	a1,a1,1220 # ffffffffc0204698 <etext+0x188>
ffffffffc02001dc:	00004517          	auipc	a0,0x4
ffffffffc02001e0:	48450513          	addi	a0,a0,1156 # ffffffffc0204660 <etext+0x150>
ffffffffc02001e4:	ed7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc02001e8:	00004617          	auipc	a2,0x4
ffffffffc02001ec:	4c060613          	addi	a2,a2,1216 # ffffffffc02046a8 <etext+0x198>
ffffffffc02001f0:	00004597          	auipc	a1,0x4
ffffffffc02001f4:	4d858593          	addi	a1,a1,1240 # ffffffffc02046c8 <etext+0x1b8>
ffffffffc02001f8:	00004517          	auipc	a0,0x4
ffffffffc02001fc:	46850513          	addi	a0,a0,1128 # ffffffffc0204660 <etext+0x150>
ffffffffc0200200:	ebbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    }
    return 0;
}
ffffffffc0200204:	60a2                	ld	ra,8(sp)
ffffffffc0200206:	4501                	li	a0,0
ffffffffc0200208:	0141                	addi	sp,sp,16
ffffffffc020020a:	8082                	ret

ffffffffc020020c <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020020c:	1141                	addi	sp,sp,-16
ffffffffc020020e:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200210:	ef3ff0ef          	jal	ra,ffffffffc0200102 <print_kerninfo>
    return 0;
}
ffffffffc0200214:	60a2                	ld	ra,8(sp)
ffffffffc0200216:	4501                	li	a0,0
ffffffffc0200218:	0141                	addi	sp,sp,16
ffffffffc020021a:	8082                	ret

ffffffffc020021c <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020021c:	1141                	addi	sp,sp,-16
ffffffffc020021e:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200220:	f71ff0ef          	jal	ra,ffffffffc0200190 <print_stackframe>
    return 0;
}
ffffffffc0200224:	60a2                	ld	ra,8(sp)
ffffffffc0200226:	4501                	li	a0,0
ffffffffc0200228:	0141                	addi	sp,sp,16
ffffffffc020022a:	8082                	ret

ffffffffc020022c <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020022c:	7115                	addi	sp,sp,-224
ffffffffc020022e:	ed5e                	sd	s7,152(sp)
ffffffffc0200230:	8baa                	mv	s7,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200232:	00004517          	auipc	a0,0x4
ffffffffc0200236:	4a650513          	addi	a0,a0,1190 # ffffffffc02046d8 <etext+0x1c8>
kmonitor(struct trapframe *tf) {
ffffffffc020023a:	ed86                	sd	ra,216(sp)
ffffffffc020023c:	e9a2                	sd	s0,208(sp)
ffffffffc020023e:	e5a6                	sd	s1,200(sp)
ffffffffc0200240:	e1ca                	sd	s2,192(sp)
ffffffffc0200242:	fd4e                	sd	s3,184(sp)
ffffffffc0200244:	f952                	sd	s4,176(sp)
ffffffffc0200246:	f556                	sd	s5,168(sp)
ffffffffc0200248:	f15a                	sd	s6,160(sp)
ffffffffc020024a:	e962                	sd	s8,144(sp)
ffffffffc020024c:	e566                	sd	s9,136(sp)
ffffffffc020024e:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200250:	e6bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200254:	00004517          	auipc	a0,0x4
ffffffffc0200258:	4ac50513          	addi	a0,a0,1196 # ffffffffc0204700 <etext+0x1f0>
ffffffffc020025c:	e5fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    if (tf != NULL) {
ffffffffc0200260:	000b8563          	beqz	s7,ffffffffc020026a <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200264:	855e                	mv	a0,s7
ffffffffc0200266:	4e8000ef          	jal	ra,ffffffffc020074e <print_trapframe>
ffffffffc020026a:	00004c17          	auipc	s8,0x4
ffffffffc020026e:	4fec0c13          	addi	s8,s8,1278 # ffffffffc0204768 <commands>
        if ((buf = readline("")) != NULL) {
ffffffffc0200272:	00006917          	auipc	s2,0x6
ffffffffc0200276:	92690913          	addi	s2,s2,-1754 # ffffffffc0205b98 <default_pmm_manager+0x948>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020027a:	00004497          	auipc	s1,0x4
ffffffffc020027e:	4ae48493          	addi	s1,s1,1198 # ffffffffc0204728 <etext+0x218>
        if (argc == MAXARGS - 1) {
ffffffffc0200282:	49bd                	li	s3,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200284:	00004b17          	auipc	s6,0x4
ffffffffc0200288:	4acb0b13          	addi	s6,s6,1196 # ffffffffc0204730 <etext+0x220>
        argv[argc ++] = buf;
ffffffffc020028c:	00004a17          	auipc	s4,0x4
ffffffffc0200290:	3cca0a13          	addi	s4,s4,972 # ffffffffc0204658 <etext+0x148>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200294:	4a8d                	li	s5,3
        if ((buf = readline("")) != NULL) {
ffffffffc0200296:	854a                	mv	a0,s2
ffffffffc0200298:	11e040ef          	jal	ra,ffffffffc02043b6 <readline>
ffffffffc020029c:	842a                	mv	s0,a0
ffffffffc020029e:	dd65                	beqz	a0,ffffffffc0200296 <kmonitor+0x6a>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002a0:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002a4:	4c81                	li	s9,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002a6:	e1bd                	bnez	a1,ffffffffc020030c <kmonitor+0xe0>
    if (argc == 0) {
ffffffffc02002a8:	fe0c87e3          	beqz	s9,ffffffffc0200296 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002ac:	6582                	ld	a1,0(sp)
ffffffffc02002ae:	00004d17          	auipc	s10,0x4
ffffffffc02002b2:	4bad0d13          	addi	s10,s10,1210 # ffffffffc0204768 <commands>
        argv[argc ++] = buf;
ffffffffc02002b6:	8552                	mv	a0,s4
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002b8:	4401                	li	s0,0
ffffffffc02002ba:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002bc:	1f6040ef          	jal	ra,ffffffffc02044b2 <strcmp>
ffffffffc02002c0:	c919                	beqz	a0,ffffffffc02002d6 <kmonitor+0xaa>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002c2:	2405                	addiw	s0,s0,1
ffffffffc02002c4:	0b540063          	beq	s0,s5,ffffffffc0200364 <kmonitor+0x138>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002c8:	000d3503          	ld	a0,0(s10)
ffffffffc02002cc:	6582                	ld	a1,0(sp)
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002ce:	0d61                	addi	s10,s10,24
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002d0:	1e2040ef          	jal	ra,ffffffffc02044b2 <strcmp>
ffffffffc02002d4:	f57d                	bnez	a0,ffffffffc02002c2 <kmonitor+0x96>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02002d6:	00141793          	slli	a5,s0,0x1
ffffffffc02002da:	97a2                	add	a5,a5,s0
ffffffffc02002dc:	078e                	slli	a5,a5,0x3
ffffffffc02002de:	97e2                	add	a5,a5,s8
ffffffffc02002e0:	6b9c                	ld	a5,16(a5)
ffffffffc02002e2:	865e                	mv	a2,s7
ffffffffc02002e4:	002c                	addi	a1,sp,8
ffffffffc02002e6:	fffc851b          	addiw	a0,s9,-1
ffffffffc02002ea:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02002ec:	fa0555e3          	bgez	a0,ffffffffc0200296 <kmonitor+0x6a>
}
ffffffffc02002f0:	60ee                	ld	ra,216(sp)
ffffffffc02002f2:	644e                	ld	s0,208(sp)
ffffffffc02002f4:	64ae                	ld	s1,200(sp)
ffffffffc02002f6:	690e                	ld	s2,192(sp)
ffffffffc02002f8:	79ea                	ld	s3,184(sp)
ffffffffc02002fa:	7a4a                	ld	s4,176(sp)
ffffffffc02002fc:	7aaa                	ld	s5,168(sp)
ffffffffc02002fe:	7b0a                	ld	s6,160(sp)
ffffffffc0200300:	6bea                	ld	s7,152(sp)
ffffffffc0200302:	6c4a                	ld	s8,144(sp)
ffffffffc0200304:	6caa                	ld	s9,136(sp)
ffffffffc0200306:	6d0a                	ld	s10,128(sp)
ffffffffc0200308:	612d                	addi	sp,sp,224
ffffffffc020030a:	8082                	ret
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020030c:	8526                	mv	a0,s1
ffffffffc020030e:	1c2040ef          	jal	ra,ffffffffc02044d0 <strchr>
ffffffffc0200312:	c901                	beqz	a0,ffffffffc0200322 <kmonitor+0xf6>
ffffffffc0200314:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc0200318:	00040023          	sb	zero,0(s0)
ffffffffc020031c:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020031e:	d5c9                	beqz	a1,ffffffffc02002a8 <kmonitor+0x7c>
ffffffffc0200320:	b7f5                	j	ffffffffc020030c <kmonitor+0xe0>
        if (*buf == '\0') {
ffffffffc0200322:	00044783          	lbu	a5,0(s0)
ffffffffc0200326:	d3c9                	beqz	a5,ffffffffc02002a8 <kmonitor+0x7c>
        if (argc == MAXARGS - 1) {
ffffffffc0200328:	033c8963          	beq	s9,s3,ffffffffc020035a <kmonitor+0x12e>
        argv[argc ++] = buf;
ffffffffc020032c:	003c9793          	slli	a5,s9,0x3
ffffffffc0200330:	0118                	addi	a4,sp,128
ffffffffc0200332:	97ba                	add	a5,a5,a4
ffffffffc0200334:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200338:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020033c:	2c85                	addiw	s9,s9,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020033e:	e591                	bnez	a1,ffffffffc020034a <kmonitor+0x11e>
ffffffffc0200340:	b7b5                	j	ffffffffc02002ac <kmonitor+0x80>
ffffffffc0200342:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200346:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200348:	d1a5                	beqz	a1,ffffffffc02002a8 <kmonitor+0x7c>
ffffffffc020034a:	8526                	mv	a0,s1
ffffffffc020034c:	184040ef          	jal	ra,ffffffffc02044d0 <strchr>
ffffffffc0200350:	d96d                	beqz	a0,ffffffffc0200342 <kmonitor+0x116>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200352:	00044583          	lbu	a1,0(s0)
ffffffffc0200356:	d9a9                	beqz	a1,ffffffffc02002a8 <kmonitor+0x7c>
ffffffffc0200358:	bf55                	j	ffffffffc020030c <kmonitor+0xe0>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020035a:	45c1                	li	a1,16
ffffffffc020035c:	855a                	mv	a0,s6
ffffffffc020035e:	d5dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0200362:	b7e9                	j	ffffffffc020032c <kmonitor+0x100>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200364:	6582                	ld	a1,0(sp)
ffffffffc0200366:	00004517          	auipc	a0,0x4
ffffffffc020036a:	3ea50513          	addi	a0,a0,1002 # ffffffffc0204750 <etext+0x240>
ffffffffc020036e:	d4dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    return 0;
ffffffffc0200372:	b715                	j	ffffffffc0200296 <kmonitor+0x6a>

ffffffffc0200374 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200374:	00011317          	auipc	t1,0x11
ffffffffc0200378:	18430313          	addi	t1,t1,388 # ffffffffc02114f8 <is_panic>
ffffffffc020037c:	00032e03          	lw	t3,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200380:	715d                	addi	sp,sp,-80
ffffffffc0200382:	ec06                	sd	ra,24(sp)
ffffffffc0200384:	e822                	sd	s0,16(sp)
ffffffffc0200386:	f436                	sd	a3,40(sp)
ffffffffc0200388:	f83a                	sd	a4,48(sp)
ffffffffc020038a:	fc3e                	sd	a5,56(sp)
ffffffffc020038c:	e0c2                	sd	a6,64(sp)
ffffffffc020038e:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200390:	020e1a63          	bnez	t3,ffffffffc02003c4 <__panic+0x50>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200394:	4785                	li	a5,1
ffffffffc0200396:	00f32023          	sw	a5,0(t1)

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc020039a:	8432                	mv	s0,a2
ffffffffc020039c:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020039e:	862e                	mv	a2,a1
ffffffffc02003a0:	85aa                	mv	a1,a0
ffffffffc02003a2:	00004517          	auipc	a0,0x4
ffffffffc02003a6:	40e50513          	addi	a0,a0,1038 # ffffffffc02047b0 <commands+0x48>
    va_start(ap, fmt);
ffffffffc02003aa:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003ac:	d0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003b0:	65a2                	ld	a1,8(sp)
ffffffffc02003b2:	8522                	mv	a0,s0
ffffffffc02003b4:	ce7ff0ef          	jal	ra,ffffffffc020009a <vcprintf>
    cprintf("\n");
ffffffffc02003b8:	00005517          	auipc	a0,0x5
ffffffffc02003bc:	33050513          	addi	a0,a0,816 # ffffffffc02056e8 <default_pmm_manager+0x498>
ffffffffc02003c0:	cfbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003c4:	12a000ef          	jal	ra,ffffffffc02004ee <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02003c8:	4501                	li	a0,0
ffffffffc02003ca:	e63ff0ef          	jal	ra,ffffffffc020022c <kmonitor>
    while (1) {
ffffffffc02003ce:	bfed                	j	ffffffffc02003c8 <__panic+0x54>

ffffffffc02003d0 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02003d0:	67e1                	lui	a5,0x18
ffffffffc02003d2:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc02003d6:	00011717          	auipc	a4,0x11
ffffffffc02003da:	12f73923          	sd	a5,306(a4) # ffffffffc0211508 <timebase>
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
ffffffffc02003fa:	3da50513          	addi	a0,a0,986 # ffffffffc02047d0 <commands+0x68>
    ticks = 0;
ffffffffc02003fe:	00011797          	auipc	a5,0x11
ffffffffc0200402:	1007b123          	sd	zero,258(a5) # ffffffffc0211500 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200406:	b955                	j	ffffffffc02000ba <cprintf>

ffffffffc0200408 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200408:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020040c:	00011797          	auipc	a5,0x11
ffffffffc0200410:	0fc7b783          	ld	a5,252(a5) # ffffffffc0211508 <timebase>
ffffffffc0200414:	953e                	add	a0,a0,a5
ffffffffc0200416:	4581                	li	a1,0
ffffffffc0200418:	4601                	li	a2,0
ffffffffc020041a:	4881                	li	a7,0
ffffffffc020041c:	00000073          	ecall
ffffffffc0200420:	8082                	ret

ffffffffc0200422 <cons_putc>:
#include <intr.h>
#include <mmu.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200422:	100027f3          	csrr	a5,sstatus
ffffffffc0200426:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200428:	0ff57513          	andi	a0,a0,255
ffffffffc020042c:	e799                	bnez	a5,ffffffffc020043a <cons_putc+0x18>
ffffffffc020042e:	4581                	li	a1,0
ffffffffc0200430:	4601                	li	a2,0
ffffffffc0200432:	4885                	li	a7,1
ffffffffc0200434:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200438:	8082                	ret

/* cons_init - initializes the console devices */
void cons_init(void) {}

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020043a:	1101                	addi	sp,sp,-32
ffffffffc020043c:	ec06                	sd	ra,24(sp)
ffffffffc020043e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200440:	0ae000ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0200444:	6522                	ld	a0,8(sp)
ffffffffc0200446:	4581                	li	a1,0
ffffffffc0200448:	4601                	li	a2,0
ffffffffc020044a:	4885                	li	a7,1
ffffffffc020044c:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200450:	60e2                	ld	ra,24(sp)
ffffffffc0200452:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200454:	a851                	j	ffffffffc02004e8 <intr_enable>

ffffffffc0200456 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200456:	100027f3          	csrr	a5,sstatus
ffffffffc020045a:	8b89                	andi	a5,a5,2
ffffffffc020045c:	eb89                	bnez	a5,ffffffffc020046e <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc020045e:	4501                	li	a0,0
ffffffffc0200460:	4581                	li	a1,0
ffffffffc0200462:	4601                	li	a2,0
ffffffffc0200464:	4889                	li	a7,2
ffffffffc0200466:	00000073          	ecall
ffffffffc020046a:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020046c:	8082                	ret
int cons_getc(void) {
ffffffffc020046e:	1101                	addi	sp,sp,-32
ffffffffc0200470:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200472:	07c000ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0200476:	4501                	li	a0,0
ffffffffc0200478:	4581                	li	a1,0
ffffffffc020047a:	4601                	li	a2,0
ffffffffc020047c:	4889                	li	a7,2
ffffffffc020047e:	00000073          	ecall
ffffffffc0200482:	2501                	sext.w	a0,a0
ffffffffc0200484:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0200486:	062000ef          	jal	ra,ffffffffc02004e8 <intr_enable>
}
ffffffffc020048a:	60e2                	ld	ra,24(sp)
ffffffffc020048c:	6522                	ld	a0,8(sp)
ffffffffc020048e:	6105                	addi	sp,sp,32
ffffffffc0200490:	8082                	ret

ffffffffc0200492 <ide_init>:
#include <string.h>
#include <trap.h>
#include <riscv.h>

// 函数定义，目前函数体为空，推测是用于初始化IDE相关的设备或资源等，后续可能会添加具体的初始化代码，比如配置寄存器等操作
void ide_init(void) {}
ffffffffc0200492:	8082                	ret

ffffffffc0200494 <ide_device_valid>:
// 相当于在内核的静态存储区划分出一块内存来模拟“硬盘”
static char ide[MAX_DISK_NSECS * SECTSIZE];

// 函数用于验证给定的IDE设备编号是否有效，通过比较设备编号是否小于最大支持的IDE设备数量（MAX_IDE）来判断
// 返回值为布尔类型，小于则返回true，表示设备编号有效，否则返回false
bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc0200494:	00253513          	sltiu	a0,a0,2
ffffffffc0200498:	8082                	ret

ffffffffc020049a <ide_device_size>:

// 函数用于获取指定IDE设备的大小（以扇区数量表示），目前只是简单返回预定义的最大扇区数量（MAX_DISK_NSECS）
// 实际可能需要根据不同设备的实际情况进行更灵活的调整，比如不同设备有不同容量时查询对应实际容量
size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc020049a:	03800513          	li	a0,56
ffffffffc020049e:	8082                	ret

ffffffffc02004a0 <ide_read_secs>:
                  size_t nsecs) {
    // 计算读取数据在模拟磁盘数据缓存数组（ide）中的起始偏移量，通过扇区号乘以扇区大小得到
    int iobase = secno * SECTSIZE;
    // 使用memcpy函数将从ide数组中以iobase为起始位置、长度为nsecs * SECTSIZE的数据复制到dst所指向的目标内存地址中
    // 从而实现模拟的磁盘扇区数据读取操作，这里其实就是在内存里进行数据复制来模拟磁盘读取
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004a0:	0000a797          	auipc	a5,0xa
ffffffffc02004a4:	ba078793          	addi	a5,a5,-1120 # ffffffffc020a040 <ide>
    int iobase = secno * SECTSIZE;
ffffffffc02004a8:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc02004ac:	1141                	addi	sp,sp,-16
ffffffffc02004ae:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004b0:	95be                	add	a1,a1,a5
ffffffffc02004b2:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc02004b6:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc02004b8:	040040ef          	jal	ra,ffffffffc02044f8 <memcpy>
    // 返回0表示读取操作正常完成，实际更完善的代码可能会根据不同错误情况返回不同错误码来反馈读取中的问题
    return 0;
}
ffffffffc02004bc:	60a2                	ld	ra,8(sp)
ffffffffc02004be:	4501                	li	a0,0
ffffffffc02004c0:	0141                	addi	sp,sp,16
ffffffffc02004c2:	8082                	ret

ffffffffc02004c4 <ide_write_secs>:
// - src: 是一个指向源内存地址的指针，这个内存地址存放着要写入磁盘的数据，调用者需要保证这个内存区域的数据在写入过程中保持有效
// - nsecs: 表示要写入的扇区数量，即写入操作的数据长度（以扇区为单位）
int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
    // 计算在模拟磁盘数据缓存数组（ide）中写入数据的起始偏移量，计算方式与读取函数中一样，通过扇区号乘以扇区大小得到
    int iobase = secno * SECTSIZE;
ffffffffc02004c4:	0095979b          	slliw	a5,a1,0x9
    // 使用memcpy函数将src所指向的内存区域中长度为nsecs * SECTSIZE的数据复制到ide数组以iobase为起始的位置中，完成模拟的磁盘扇区数据写入操作
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004c8:	0000a517          	auipc	a0,0xa
ffffffffc02004cc:	b7850513          	addi	a0,a0,-1160 # ffffffffc020a040 <ide>
                   size_t nsecs) {
ffffffffc02004d0:	1141                	addi	sp,sp,-16
ffffffffc02004d2:	85b2                	mv	a1,a2
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004d4:	953e                	add	a0,a0,a5
ffffffffc02004d6:	00969613          	slli	a2,a3,0x9
                   size_t nsecs) {
ffffffffc02004da:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc02004dc:	01c040ef          	jal	ra,ffffffffc02044f8 <memcpy>
    // 返回0表示写入操作顺利结束，更完善的代码可能会根据实际错误情况返回不同错误码来反馈写入中的问题
    return 0;
ffffffffc02004e0:	60a2                	ld	ra,8(sp)
ffffffffc02004e2:	4501                	li	a0,0
ffffffffc02004e4:	0141                	addi	sp,sp,16
ffffffffc02004e6:	8082                	ret

ffffffffc02004e8 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004e8:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02004ec:	8082                	ret

ffffffffc02004ee <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02004ee:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <pgfault_handler>:
    set_csr(sstatus, SSTATUS_SUM);
}

/* trap_in_kernel - test if trap happened in kernel */
bool trap_in_kernel(struct trapframe *tf) {
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004f4:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int pgfault_handler(struct trapframe *tf) {
ffffffffc02004f8:	1141                	addi	sp,sp,-16
ffffffffc02004fa:	e022                	sd	s0,0(sp)
ffffffffc02004fc:	e406                	sd	ra,8(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02004fe:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200502:	11053583          	ld	a1,272(a0)
static int pgfault_handler(struct trapframe *tf) {
ffffffffc0200506:	842a                	mv	s0,a0
    cprintf("page fault at 0x%08x: %c/%c\n", tf->badvaddr,
ffffffffc0200508:	05500613          	li	a2,85
ffffffffc020050c:	c399                	beqz	a5,ffffffffc0200512 <pgfault_handler+0x1e>
ffffffffc020050e:	04b00613          	li	a2,75
ffffffffc0200512:	11843703          	ld	a4,280(s0)
ffffffffc0200516:	47bd                	li	a5,15
ffffffffc0200518:	05700693          	li	a3,87
ffffffffc020051c:	00f70463          	beq	a4,a5,ffffffffc0200524 <pgfault_handler+0x30>
ffffffffc0200520:	05200693          	li	a3,82
ffffffffc0200524:	00004517          	auipc	a0,0x4
ffffffffc0200528:	2cc50513          	addi	a0,a0,716 # ffffffffc02047f0 <commands+0x88>
ffffffffc020052c:	b8fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    extern struct mm_struct *check_mm_struct;
    print_pgfault(tf);
    if (check_mm_struct != NULL) {
ffffffffc0200530:	00011517          	auipc	a0,0x11
ffffffffc0200534:	03053503          	ld	a0,48(a0) # ffffffffc0211560 <check_mm_struct>
ffffffffc0200538:	c911                	beqz	a0,ffffffffc020054c <pgfault_handler+0x58>
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc020053a:	11043603          	ld	a2,272(s0)
ffffffffc020053e:	11843583          	ld	a1,280(s0)
    }
    panic("unhandled page fault.\n");
}
ffffffffc0200542:	6402                	ld	s0,0(sp)
ffffffffc0200544:	60a2                	ld	ra,8(sp)
ffffffffc0200546:	0141                	addi	sp,sp,16
        return do_pgfault(check_mm_struct, tf->cause, tf->badvaddr);
ffffffffc0200548:	0190306f          	j	ffffffffc0203d60 <do_pgfault>
    panic("unhandled page fault.\n");
ffffffffc020054c:	00004617          	auipc	a2,0x4
ffffffffc0200550:	2c460613          	addi	a2,a2,708 # ffffffffc0204810 <commands+0xa8>
ffffffffc0200554:	07800593          	li	a1,120
ffffffffc0200558:	00004517          	auipc	a0,0x4
ffffffffc020055c:	2d050513          	addi	a0,a0,720 # ffffffffc0204828 <commands+0xc0>
ffffffffc0200560:	e15ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0200564 <idt_init>:
    write_csr(sscratch, 0);
ffffffffc0200564:	14005073          	csrwi	sscratch,0
    write_csr(stvec, &__alltraps);
ffffffffc0200568:	00000797          	auipc	a5,0x0
ffffffffc020056c:	48878793          	addi	a5,a5,1160 # ffffffffc02009f0 <__alltraps>
ffffffffc0200570:	10579073          	csrw	stvec,a5
    set_csr(sstatus, SSTATUS_SIE);
ffffffffc0200574:	100167f3          	csrrsi	a5,sstatus,2
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200578:	000407b7          	lui	a5,0x40
ffffffffc020057c:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200580:	8082                	ret

ffffffffc0200582 <print_regs>:
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200582:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc0200584:	1141                	addi	sp,sp,-16
ffffffffc0200586:	e022                	sd	s0,0(sp)
ffffffffc0200588:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020058a:	00004517          	auipc	a0,0x4
ffffffffc020058e:	2b650513          	addi	a0,a0,694 # ffffffffc0204840 <commands+0xd8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200592:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200594:	b27ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200598:	640c                	ld	a1,8(s0)
ffffffffc020059a:	00004517          	auipc	a0,0x4
ffffffffc020059e:	2be50513          	addi	a0,a0,702 # ffffffffc0204858 <commands+0xf0>
ffffffffc02005a2:	b19ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02005a6:	680c                	ld	a1,16(s0)
ffffffffc02005a8:	00004517          	auipc	a0,0x4
ffffffffc02005ac:	2c850513          	addi	a0,a0,712 # ffffffffc0204870 <commands+0x108>
ffffffffc02005b0:	b0bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02005b4:	6c0c                	ld	a1,24(s0)
ffffffffc02005b6:	00004517          	auipc	a0,0x4
ffffffffc02005ba:	2d250513          	addi	a0,a0,722 # ffffffffc0204888 <commands+0x120>
ffffffffc02005be:	afdff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02005c2:	700c                	ld	a1,32(s0)
ffffffffc02005c4:	00004517          	auipc	a0,0x4
ffffffffc02005c8:	2dc50513          	addi	a0,a0,732 # ffffffffc02048a0 <commands+0x138>
ffffffffc02005cc:	aefff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02005d0:	740c                	ld	a1,40(s0)
ffffffffc02005d2:	00004517          	auipc	a0,0x4
ffffffffc02005d6:	2e650513          	addi	a0,a0,742 # ffffffffc02048b8 <commands+0x150>
ffffffffc02005da:	ae1ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02005de:	780c                	ld	a1,48(s0)
ffffffffc02005e0:	00004517          	auipc	a0,0x4
ffffffffc02005e4:	2f050513          	addi	a0,a0,752 # ffffffffc02048d0 <commands+0x168>
ffffffffc02005e8:	ad3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02005ec:	7c0c                	ld	a1,56(s0)
ffffffffc02005ee:	00004517          	auipc	a0,0x4
ffffffffc02005f2:	2fa50513          	addi	a0,a0,762 # ffffffffc02048e8 <commands+0x180>
ffffffffc02005f6:	ac5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02005fa:	602c                	ld	a1,64(s0)
ffffffffc02005fc:	00004517          	auipc	a0,0x4
ffffffffc0200600:	30450513          	addi	a0,a0,772 # ffffffffc0204900 <commands+0x198>
ffffffffc0200604:	ab7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200608:	642c                	ld	a1,72(s0)
ffffffffc020060a:	00004517          	auipc	a0,0x4
ffffffffc020060e:	30e50513          	addi	a0,a0,782 # ffffffffc0204918 <commands+0x1b0>
ffffffffc0200612:	aa9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200616:	682c                	ld	a1,80(s0)
ffffffffc0200618:	00004517          	auipc	a0,0x4
ffffffffc020061c:	31850513          	addi	a0,a0,792 # ffffffffc0204930 <commands+0x1c8>
ffffffffc0200620:	a9bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200624:	6c2c                	ld	a1,88(s0)
ffffffffc0200626:	00004517          	auipc	a0,0x4
ffffffffc020062a:	32250513          	addi	a0,a0,802 # ffffffffc0204948 <commands+0x1e0>
ffffffffc020062e:	a8dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200632:	702c                	ld	a1,96(s0)
ffffffffc0200634:	00004517          	auipc	a0,0x4
ffffffffc0200638:	32c50513          	addi	a0,a0,812 # ffffffffc0204960 <commands+0x1f8>
ffffffffc020063c:	a7fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200640:	742c                	ld	a1,104(s0)
ffffffffc0200642:	00004517          	auipc	a0,0x4
ffffffffc0200646:	33650513          	addi	a0,a0,822 # ffffffffc0204978 <commands+0x210>
ffffffffc020064a:	a71ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020064e:	782c                	ld	a1,112(s0)
ffffffffc0200650:	00004517          	auipc	a0,0x4
ffffffffc0200654:	34050513          	addi	a0,a0,832 # ffffffffc0204990 <commands+0x228>
ffffffffc0200658:	a63ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020065c:	7c2c                	ld	a1,120(s0)
ffffffffc020065e:	00004517          	auipc	a0,0x4
ffffffffc0200662:	34a50513          	addi	a0,a0,842 # ffffffffc02049a8 <commands+0x240>
ffffffffc0200666:	a55ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020066a:	604c                	ld	a1,128(s0)
ffffffffc020066c:	00004517          	auipc	a0,0x4
ffffffffc0200670:	35450513          	addi	a0,a0,852 # ffffffffc02049c0 <commands+0x258>
ffffffffc0200674:	a47ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200678:	644c                	ld	a1,136(s0)
ffffffffc020067a:	00004517          	auipc	a0,0x4
ffffffffc020067e:	35e50513          	addi	a0,a0,862 # ffffffffc02049d8 <commands+0x270>
ffffffffc0200682:	a39ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200686:	684c                	ld	a1,144(s0)
ffffffffc0200688:	00004517          	auipc	a0,0x4
ffffffffc020068c:	36850513          	addi	a0,a0,872 # ffffffffc02049f0 <commands+0x288>
ffffffffc0200690:	a2bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200694:	6c4c                	ld	a1,152(s0)
ffffffffc0200696:	00004517          	auipc	a0,0x4
ffffffffc020069a:	37250513          	addi	a0,a0,882 # ffffffffc0204a08 <commands+0x2a0>
ffffffffc020069e:	a1dff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02006a2:	704c                	ld	a1,160(s0)
ffffffffc02006a4:	00004517          	auipc	a0,0x4
ffffffffc02006a8:	37c50513          	addi	a0,a0,892 # ffffffffc0204a20 <commands+0x2b8>
ffffffffc02006ac:	a0fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02006b0:	744c                	ld	a1,168(s0)
ffffffffc02006b2:	00004517          	auipc	a0,0x4
ffffffffc02006b6:	38650513          	addi	a0,a0,902 # ffffffffc0204a38 <commands+0x2d0>
ffffffffc02006ba:	a01ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02006be:	784c                	ld	a1,176(s0)
ffffffffc02006c0:	00004517          	auipc	a0,0x4
ffffffffc02006c4:	39050513          	addi	a0,a0,912 # ffffffffc0204a50 <commands+0x2e8>
ffffffffc02006c8:	9f3ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02006cc:	7c4c                	ld	a1,184(s0)
ffffffffc02006ce:	00004517          	auipc	a0,0x4
ffffffffc02006d2:	39a50513          	addi	a0,a0,922 # ffffffffc0204a68 <commands+0x300>
ffffffffc02006d6:	9e5ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02006da:	606c                	ld	a1,192(s0)
ffffffffc02006dc:	00004517          	auipc	a0,0x4
ffffffffc02006e0:	3a450513          	addi	a0,a0,932 # ffffffffc0204a80 <commands+0x318>
ffffffffc02006e4:	9d7ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02006e8:	646c                	ld	a1,200(s0)
ffffffffc02006ea:	00004517          	auipc	a0,0x4
ffffffffc02006ee:	3ae50513          	addi	a0,a0,942 # ffffffffc0204a98 <commands+0x330>
ffffffffc02006f2:	9c9ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02006f6:	686c                	ld	a1,208(s0)
ffffffffc02006f8:	00004517          	auipc	a0,0x4
ffffffffc02006fc:	3b850513          	addi	a0,a0,952 # ffffffffc0204ab0 <commands+0x348>
ffffffffc0200700:	9bbff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200704:	6c6c                	ld	a1,216(s0)
ffffffffc0200706:	00004517          	auipc	a0,0x4
ffffffffc020070a:	3c250513          	addi	a0,a0,962 # ffffffffc0204ac8 <commands+0x360>
ffffffffc020070e:	9adff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200712:	706c                	ld	a1,224(s0)
ffffffffc0200714:	00004517          	auipc	a0,0x4
ffffffffc0200718:	3cc50513          	addi	a0,a0,972 # ffffffffc0204ae0 <commands+0x378>
ffffffffc020071c:	99fff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200720:	746c                	ld	a1,232(s0)
ffffffffc0200722:	00004517          	auipc	a0,0x4
ffffffffc0200726:	3d650513          	addi	a0,a0,982 # ffffffffc0204af8 <commands+0x390>
ffffffffc020072a:	991ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020072e:	786c                	ld	a1,240(s0)
ffffffffc0200730:	00004517          	auipc	a0,0x4
ffffffffc0200734:	3e050513          	addi	a0,a0,992 # ffffffffc0204b10 <commands+0x3a8>
ffffffffc0200738:	983ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020073c:	7c6c                	ld	a1,248(s0)
}
ffffffffc020073e:	6402                	ld	s0,0(sp)
ffffffffc0200740:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200742:	00004517          	auipc	a0,0x4
ffffffffc0200746:	3e650513          	addi	a0,a0,998 # ffffffffc0204b28 <commands+0x3c0>
}
ffffffffc020074a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020074c:	b2bd                	j	ffffffffc02000ba <cprintf>

ffffffffc020074e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020074e:	1141                	addi	sp,sp,-16
ffffffffc0200750:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200752:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200754:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200756:	00004517          	auipc	a0,0x4
ffffffffc020075a:	3ea50513          	addi	a0,a0,1002 # ffffffffc0204b40 <commands+0x3d8>
void print_trapframe(struct trapframe *tf) {
ffffffffc020075e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200760:	95bff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200764:	8522                	mv	a0,s0
ffffffffc0200766:	e1dff0ef          	jal	ra,ffffffffc0200582 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020076a:	10043583          	ld	a1,256(s0)
ffffffffc020076e:	00004517          	auipc	a0,0x4
ffffffffc0200772:	3ea50513          	addi	a0,a0,1002 # ffffffffc0204b58 <commands+0x3f0>
ffffffffc0200776:	945ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020077a:	10843583          	ld	a1,264(s0)
ffffffffc020077e:	00004517          	auipc	a0,0x4
ffffffffc0200782:	3f250513          	addi	a0,a0,1010 # ffffffffc0204b70 <commands+0x408>
ffffffffc0200786:	935ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020078a:	11043583          	ld	a1,272(s0)
ffffffffc020078e:	00004517          	auipc	a0,0x4
ffffffffc0200792:	3fa50513          	addi	a0,a0,1018 # ffffffffc0204b88 <commands+0x420>
ffffffffc0200796:	925ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020079a:	11843583          	ld	a1,280(s0)
}
ffffffffc020079e:	6402                	ld	s0,0(sp)
ffffffffc02007a0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007a2:	00004517          	auipc	a0,0x4
ffffffffc02007a6:	3fe50513          	addi	a0,a0,1022 # ffffffffc0204ba0 <commands+0x438>
}
ffffffffc02007aa:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02007ac:	90fff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc02007b0 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02007b0:	11853783          	ld	a5,280(a0)
ffffffffc02007b4:	472d                	li	a4,11
ffffffffc02007b6:	0786                	slli	a5,a5,0x1
ffffffffc02007b8:	8385                	srli	a5,a5,0x1
ffffffffc02007ba:	06f76c63          	bltu	a4,a5,ffffffffc0200832 <interrupt_handler+0x82>
ffffffffc02007be:	00004717          	auipc	a4,0x4
ffffffffc02007c2:	4aa70713          	addi	a4,a4,1194 # ffffffffc0204c68 <commands+0x500>
ffffffffc02007c6:	078a                	slli	a5,a5,0x2
ffffffffc02007c8:	97ba                	add	a5,a5,a4
ffffffffc02007ca:	439c                	lw	a5,0(a5)
ffffffffc02007cc:	97ba                	add	a5,a5,a4
ffffffffc02007ce:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02007d0:	00004517          	auipc	a0,0x4
ffffffffc02007d4:	44850513          	addi	a0,a0,1096 # ffffffffc0204c18 <commands+0x4b0>
ffffffffc02007d8:	8e3ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02007dc:	00004517          	auipc	a0,0x4
ffffffffc02007e0:	41c50513          	addi	a0,a0,1052 # ffffffffc0204bf8 <commands+0x490>
ffffffffc02007e4:	8d7ff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02007e8:	00004517          	auipc	a0,0x4
ffffffffc02007ec:	3d050513          	addi	a0,a0,976 # ffffffffc0204bb8 <commands+0x450>
ffffffffc02007f0:	8cbff06f          	j	ffffffffc02000ba <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc02007f4:	00004517          	auipc	a0,0x4
ffffffffc02007f8:	3e450513          	addi	a0,a0,996 # ffffffffc0204bd8 <commands+0x470>
ffffffffc02007fc:	8bfff06f          	j	ffffffffc02000ba <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200800:	1141                	addi	sp,sp,-16
ffffffffc0200802:	e406                	sd	ra,8(sp)
            // "All bits besides SSIP and USIP in the sip register are
            // read-only." -- privileged spec1.9.1, 4.1.4, p59
            // In fact, Call sbi_set_timer will clear STIP, or you can clear it
            // directly.
            // clear_csr(sip, SIP_STIP);
            clock_set_next_event();
ffffffffc0200804:	c05ff0ef          	jal	ra,ffffffffc0200408 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
ffffffffc0200808:	00011697          	auipc	a3,0x11
ffffffffc020080c:	cf868693          	addi	a3,a3,-776 # ffffffffc0211500 <ticks>
ffffffffc0200810:	629c                	ld	a5,0(a3)
ffffffffc0200812:	06400713          	li	a4,100
ffffffffc0200816:	0785                	addi	a5,a5,1
ffffffffc0200818:	02e7f733          	remu	a4,a5,a4
ffffffffc020081c:	e29c                	sd	a5,0(a3)
ffffffffc020081e:	cb19                	beqz	a4,ffffffffc0200834 <interrupt_handler+0x84>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200820:	60a2                	ld	ra,8(sp)
ffffffffc0200822:	0141                	addi	sp,sp,16
ffffffffc0200824:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200826:	00004517          	auipc	a0,0x4
ffffffffc020082a:	42250513          	addi	a0,a0,1058 # ffffffffc0204c48 <commands+0x4e0>
ffffffffc020082e:	88dff06f          	j	ffffffffc02000ba <cprintf>
            print_trapframe(tf);
ffffffffc0200832:	bf31                	j	ffffffffc020074e <print_trapframe>
}
ffffffffc0200834:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200836:	06400593          	li	a1,100
ffffffffc020083a:	00004517          	auipc	a0,0x4
ffffffffc020083e:	3fe50513          	addi	a0,a0,1022 # ffffffffc0204c38 <commands+0x4d0>
}
ffffffffc0200842:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200844:	877ff06f          	j	ffffffffc02000ba <cprintf>

ffffffffc0200848 <exception_handler>:


void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200848:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc020084c:	1101                	addi	sp,sp,-32
ffffffffc020084e:	e822                	sd	s0,16(sp)
ffffffffc0200850:	ec06                	sd	ra,24(sp)
ffffffffc0200852:	e426                	sd	s1,8(sp)
ffffffffc0200854:	473d                	li	a4,15
ffffffffc0200856:	842a                	mv	s0,a0
ffffffffc0200858:	14f76a63          	bltu	a4,a5,ffffffffc02009ac <exception_handler+0x164>
ffffffffc020085c:	00004717          	auipc	a4,0x4
ffffffffc0200860:	5f470713          	addi	a4,a4,1524 # ffffffffc0204e50 <commands+0x6e8>
ffffffffc0200864:	078a                	slli	a5,a5,0x2
ffffffffc0200866:	97ba                	add	a5,a5,a4
ffffffffc0200868:	439c                	lw	a5,0(a5)
ffffffffc020086a:	97ba                	add	a5,a5,a4
ffffffffc020086c:	8782                	jr	a5
                print_trapframe(tf);
                panic("handle pgfault failed. %e\n", ret);
            }
            break;
        case CAUSE_STORE_PAGE_FAULT:
            cprintf("Store/AMO page fault\n");
ffffffffc020086e:	00004517          	auipc	a0,0x4
ffffffffc0200872:	5ca50513          	addi	a0,a0,1482 # ffffffffc0204e38 <commands+0x6d0>
ffffffffc0200876:	845ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc020087a:	8522                	mv	a0,s0
ffffffffc020087c:	c79ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc0200880:	84aa                	mv	s1,a0
ffffffffc0200882:	12051b63          	bnez	a0,ffffffffc02009b8 <exception_handler+0x170>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200886:	60e2                	ld	ra,24(sp)
ffffffffc0200888:	6442                	ld	s0,16(sp)
ffffffffc020088a:	64a2                	ld	s1,8(sp)
ffffffffc020088c:	6105                	addi	sp,sp,32
ffffffffc020088e:	8082                	ret
            cprintf("Instruction address misaligned\n");
ffffffffc0200890:	00004517          	auipc	a0,0x4
ffffffffc0200894:	40850513          	addi	a0,a0,1032 # ffffffffc0204c98 <commands+0x530>
}
ffffffffc0200898:	6442                	ld	s0,16(sp)
ffffffffc020089a:	60e2                	ld	ra,24(sp)
ffffffffc020089c:	64a2                	ld	s1,8(sp)
ffffffffc020089e:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc02008a0:	81bff06f          	j	ffffffffc02000ba <cprintf>
ffffffffc02008a4:	00004517          	auipc	a0,0x4
ffffffffc02008a8:	41450513          	addi	a0,a0,1044 # ffffffffc0204cb8 <commands+0x550>
ffffffffc02008ac:	b7f5                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc02008ae:	00004517          	auipc	a0,0x4
ffffffffc02008b2:	42a50513          	addi	a0,a0,1066 # ffffffffc0204cd8 <commands+0x570>
ffffffffc02008b6:	b7cd                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc02008b8:	00004517          	auipc	a0,0x4
ffffffffc02008bc:	43850513          	addi	a0,a0,1080 # ffffffffc0204cf0 <commands+0x588>
ffffffffc02008c0:	bfe1                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load address misaligned\n");
ffffffffc02008c2:	00004517          	auipc	a0,0x4
ffffffffc02008c6:	43e50513          	addi	a0,a0,1086 # ffffffffc0204d00 <commands+0x598>
ffffffffc02008ca:	b7f9                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc02008cc:	00004517          	auipc	a0,0x4
ffffffffc02008d0:	45450513          	addi	a0,a0,1108 # ffffffffc0204d20 <commands+0x5b8>
ffffffffc02008d4:	fe6ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc02008d8:	8522                	mv	a0,s0
ffffffffc02008da:	c1bff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc02008de:	84aa                	mv	s1,a0
ffffffffc02008e0:	d15d                	beqz	a0,ffffffffc0200886 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc02008e2:	8522                	mv	a0,s0
ffffffffc02008e4:	e6bff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02008e8:	86a6                	mv	a3,s1
ffffffffc02008ea:	00004617          	auipc	a2,0x4
ffffffffc02008ee:	44e60613          	addi	a2,a2,1102 # ffffffffc0204d38 <commands+0x5d0>
ffffffffc02008f2:	0ca00593          	li	a1,202
ffffffffc02008f6:	00004517          	auipc	a0,0x4
ffffffffc02008fa:	f3250513          	addi	a0,a0,-206 # ffffffffc0204828 <commands+0xc0>
ffffffffc02008fe:	a77ff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("AMO address misaligned\n");
ffffffffc0200902:	00004517          	auipc	a0,0x4
ffffffffc0200906:	45650513          	addi	a0,a0,1110 # ffffffffc0204d58 <commands+0x5f0>
ffffffffc020090a:	b779                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Store/AMO access fault\n");
ffffffffc020090c:	00004517          	auipc	a0,0x4
ffffffffc0200910:	46450513          	addi	a0,a0,1124 # ffffffffc0204d70 <commands+0x608>
ffffffffc0200914:	fa6ff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200918:	8522                	mv	a0,s0
ffffffffc020091a:	bdbff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc020091e:	84aa                	mv	s1,a0
ffffffffc0200920:	d13d                	beqz	a0,ffffffffc0200886 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc0200922:	8522                	mv	a0,s0
ffffffffc0200924:	e2bff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200928:	86a6                	mv	a3,s1
ffffffffc020092a:	00004617          	auipc	a2,0x4
ffffffffc020092e:	40e60613          	addi	a2,a2,1038 # ffffffffc0204d38 <commands+0x5d0>
ffffffffc0200932:	0d400593          	li	a1,212
ffffffffc0200936:	00004517          	auipc	a0,0x4
ffffffffc020093a:	ef250513          	addi	a0,a0,-270 # ffffffffc0204828 <commands+0xc0>
ffffffffc020093e:	a37ff0ef          	jal	ra,ffffffffc0200374 <__panic>
            cprintf("Environment call from U-mode\n");
ffffffffc0200942:	00004517          	auipc	a0,0x4
ffffffffc0200946:	44650513          	addi	a0,a0,1094 # ffffffffc0204d88 <commands+0x620>
ffffffffc020094a:	b7b9                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from S-mode\n");
ffffffffc020094c:	00004517          	auipc	a0,0x4
ffffffffc0200950:	45c50513          	addi	a0,a0,1116 # ffffffffc0204da8 <commands+0x640>
ffffffffc0200954:	b791                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from H-mode\n");
ffffffffc0200956:	00004517          	auipc	a0,0x4
ffffffffc020095a:	47250513          	addi	a0,a0,1138 # ffffffffc0204dc8 <commands+0x660>
ffffffffc020095e:	bf2d                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Environment call from M-mode\n");
ffffffffc0200960:	00004517          	auipc	a0,0x4
ffffffffc0200964:	48850513          	addi	a0,a0,1160 # ffffffffc0204de8 <commands+0x680>
ffffffffc0200968:	bf05                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc020096a:	00004517          	auipc	a0,0x4
ffffffffc020096e:	49e50513          	addi	a0,a0,1182 # ffffffffc0204e08 <commands+0x6a0>
ffffffffc0200972:	b71d                	j	ffffffffc0200898 <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200974:	00004517          	auipc	a0,0x4
ffffffffc0200978:	4ac50513          	addi	a0,a0,1196 # ffffffffc0204e20 <commands+0x6b8>
ffffffffc020097c:	f3eff0ef          	jal	ra,ffffffffc02000ba <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200980:	8522                	mv	a0,s0
ffffffffc0200982:	b73ff0ef          	jal	ra,ffffffffc02004f4 <pgfault_handler>
ffffffffc0200986:	84aa                	mv	s1,a0
ffffffffc0200988:	ee050fe3          	beqz	a0,ffffffffc0200886 <exception_handler+0x3e>
                print_trapframe(tf);
ffffffffc020098c:	8522                	mv	a0,s0
ffffffffc020098e:	dc1ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200992:	86a6                	mv	a3,s1
ffffffffc0200994:	00004617          	auipc	a2,0x4
ffffffffc0200998:	3a460613          	addi	a2,a2,932 # ffffffffc0204d38 <commands+0x5d0>
ffffffffc020099c:	0ea00593          	li	a1,234
ffffffffc02009a0:	00004517          	auipc	a0,0x4
ffffffffc02009a4:	e8850513          	addi	a0,a0,-376 # ffffffffc0204828 <commands+0xc0>
ffffffffc02009a8:	9cdff0ef          	jal	ra,ffffffffc0200374 <__panic>
            print_trapframe(tf);
ffffffffc02009ac:	8522                	mv	a0,s0
}
ffffffffc02009ae:	6442                	ld	s0,16(sp)
ffffffffc02009b0:	60e2                	ld	ra,24(sp)
ffffffffc02009b2:	64a2                	ld	s1,8(sp)
ffffffffc02009b4:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc02009b6:	bb61                	j	ffffffffc020074e <print_trapframe>
                print_trapframe(tf);
ffffffffc02009b8:	8522                	mv	a0,s0
ffffffffc02009ba:	d95ff0ef          	jal	ra,ffffffffc020074e <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc02009be:	86a6                	mv	a3,s1
ffffffffc02009c0:	00004617          	auipc	a2,0x4
ffffffffc02009c4:	37860613          	addi	a2,a2,888 # ffffffffc0204d38 <commands+0x5d0>
ffffffffc02009c8:	0f100593          	li	a1,241
ffffffffc02009cc:	00004517          	auipc	a0,0x4
ffffffffc02009d0:	e5c50513          	addi	a0,a0,-420 # ffffffffc0204828 <commands+0xc0>
ffffffffc02009d4:	9a1ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02009d8 <trap>:
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    if ((intptr_t)tf->cause < 0) {
ffffffffc02009d8:	11853783          	ld	a5,280(a0)
ffffffffc02009dc:	0007c363          	bltz	a5,ffffffffc02009e2 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc02009e0:	b5a5                	j	ffffffffc0200848 <exception_handler>
        interrupt_handler(tf);
ffffffffc02009e2:	b3f9                	j	ffffffffc02007b0 <interrupt_handler>
	...

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
ffffffffc0200a52:	f87ff0ef          	jal	ra,ffffffffc02009d8 <trap>

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
ffffffffc0200ab0:	00010797          	auipc	a5,0x10
ffffffffc0200ab4:	59078793          	addi	a5,a5,1424 # ffffffffc0211040 <free_area>
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
ffffffffc0200ac2:	00010517          	auipc	a0,0x10
ffffffffc0200ac6:	58e56503          	lwu	a0,1422(a0) # ffffffffc0211050 <free_area+0x10>
ffffffffc0200aca:	8082                	ret

ffffffffc0200acc <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200acc:	715d                	addi	sp,sp,-80
ffffffffc0200ace:	e0a2                	sd	s0,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200ad0:	00010417          	auipc	s0,0x10
ffffffffc0200ad4:	57040413          	addi	s0,s0,1392 # ffffffffc0211040 <free_area>
ffffffffc0200ad8:	641c                	ld	a5,8(s0)
ffffffffc0200ada:	e486                	sd	ra,72(sp)
ffffffffc0200adc:	fc26                	sd	s1,56(sp)
ffffffffc0200ade:	f84a                	sd	s2,48(sp)
ffffffffc0200ae0:	f44e                	sd	s3,40(sp)
ffffffffc0200ae2:	f052                	sd	s4,32(sp)
ffffffffc0200ae4:	ec56                	sd	s5,24(sp)
ffffffffc0200ae6:	e85a                	sd	s6,16(sp)
ffffffffc0200ae8:	e45e                	sd	s7,8(sp)
ffffffffc0200aea:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200aec:	2c878763          	beq	a5,s0,ffffffffc0200dba <default_check+0x2ee>
    int count = 0, total = 0;
ffffffffc0200af0:	4481                	li	s1,0
ffffffffc0200af2:	4901                	li	s2,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200af4:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200af8:	8b09                	andi	a4,a4,2
ffffffffc0200afa:	2c070463          	beqz	a4,ffffffffc0200dc2 <default_check+0x2f6>
        count ++, total += p->property;
ffffffffc0200afe:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200b02:	679c                	ld	a5,8(a5)
ffffffffc0200b04:	2905                	addiw	s2,s2,1
ffffffffc0200b06:	9cb9                	addw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200b08:	fe8796e3          	bne	a5,s0,ffffffffc0200af4 <default_check+0x28>
    }
    assert(total == nr_free_pages());
ffffffffc0200b0c:	89a6                	mv	s3,s1
ffffffffc0200b0e:	491000ef          	jal	ra,ffffffffc020179e <nr_free_pages>
ffffffffc0200b12:	71351863          	bne	a0,s3,ffffffffc0201222 <default_check+0x756>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200b16:	4505                	li	a0,1
ffffffffc0200b18:	3b5000ef          	jal	ra,ffffffffc02016cc <alloc_pages>
ffffffffc0200b1c:	8a2a                	mv	s4,a0
ffffffffc0200b1e:	44050263          	beqz	a0,ffffffffc0200f62 <default_check+0x496>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200b22:	4505                	li	a0,1
ffffffffc0200b24:	3a9000ef          	jal	ra,ffffffffc02016cc <alloc_pages>
ffffffffc0200b28:	89aa                	mv	s3,a0
ffffffffc0200b2a:	70050c63          	beqz	a0,ffffffffc0201242 <default_check+0x776>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200b2e:	4505                	li	a0,1
ffffffffc0200b30:	39d000ef          	jal	ra,ffffffffc02016cc <alloc_pages>
ffffffffc0200b34:	8aaa                	mv	s5,a0
ffffffffc0200b36:	4a050663          	beqz	a0,ffffffffc0200fe2 <default_check+0x516>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200b3a:	2b3a0463          	beq	s4,s3,ffffffffc0200de2 <default_check+0x316>
ffffffffc0200b3e:	2aaa0263          	beq	s4,a0,ffffffffc0200de2 <default_check+0x316>
ffffffffc0200b42:	2aa98063          	beq	s3,a0,ffffffffc0200de2 <default_check+0x316>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200b46:	000a2783          	lw	a5,0(s4)
ffffffffc0200b4a:	2a079c63          	bnez	a5,ffffffffc0200e02 <default_check+0x336>
ffffffffc0200b4e:	0009a783          	lw	a5,0(s3)
ffffffffc0200b52:	2a079863          	bnez	a5,ffffffffc0200e02 <default_check+0x336>
ffffffffc0200b56:	411c                	lw	a5,0(a0)
ffffffffc0200b58:	2a079563          	bnez	a5,ffffffffc0200e02 <default_check+0x336>
extern const size_t nbase;
// 声明一个外部的无符号整数类型（uint_t）变量va_pa_offset，可能表示虚拟地址与物理地址之间的偏移量，用于地址转换等相关计算
extern uint_t va_pa_offset;

// 内联函数，用于将Page结构体指针转换为对应的页号（PPN，物理页号相关概念，在mmu.h等相关头文件中有定义），通过计算页面在pages数组中的相对位置加上nbase得到
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b5c:	00011797          	auipc	a5,0x11
ffffffffc0200b60:	9cc7b783          	ld	a5,-1588(a5) # ffffffffc0211528 <pages>
ffffffffc0200b64:	40fa0733          	sub	a4,s4,a5
ffffffffc0200b68:	870d                	srai	a4,a4,0x3
ffffffffc0200b6a:	00005597          	auipc	a1,0x5
ffffffffc0200b6e:	7ce5b583          	ld	a1,1998(a1) # ffffffffc0206338 <error_string+0x38>
ffffffffc0200b72:	02b70733          	mul	a4,a4,a1
ffffffffc0200b76:	00005617          	auipc	a2,0x5
ffffffffc0200b7a:	7ca63603          	ld	a2,1994(a2) # ffffffffc0206340 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200b7e:	00011697          	auipc	a3,0x11
ffffffffc0200b82:	9a26b683          	ld	a3,-1630(a3) # ffffffffc0211520 <npage>
ffffffffc0200b86:	06b2                	slli	a3,a3,0xc
ffffffffc0200b88:	9732                	add	a4,a4,a2

// 内联函数，用于将Page结构体指针转换为对应的物理地址，先通过page2ppn获取页号，然后将页号左移PGSHIFT位（PGSHIFT表示页面大小以2为底的对数，也就是页面偏移量的位数，用于计算物理地址）得到物理地址
static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b8a:	0732                	slli	a4,a4,0xc
ffffffffc0200b8c:	28d77b63          	bgeu	a4,a3,ffffffffc0200e22 <default_check+0x356>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200b90:	40f98733          	sub	a4,s3,a5
ffffffffc0200b94:	870d                	srai	a4,a4,0x3
ffffffffc0200b96:	02b70733          	mul	a4,a4,a1
ffffffffc0200b9a:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200b9c:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200b9e:	4cd77263          	bgeu	a4,a3,ffffffffc0201062 <default_check+0x596>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200ba2:	40f507b3          	sub	a5,a0,a5
ffffffffc0200ba6:	878d                	srai	a5,a5,0x3
ffffffffc0200ba8:	02b787b3          	mul	a5,a5,a1
ffffffffc0200bac:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200bae:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200bb0:	30d7f963          	bgeu	a5,a3,ffffffffc0200ec2 <default_check+0x3f6>
    assert(alloc_page() == NULL);
ffffffffc0200bb4:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200bb6:	00043c03          	ld	s8,0(s0)
ffffffffc0200bba:	00843b83          	ld	s7,8(s0)
    unsigned int nr_free_store = nr_free;
ffffffffc0200bbe:	01042b03          	lw	s6,16(s0)
    elm->prev = elm->next = elm;
ffffffffc0200bc2:	e400                	sd	s0,8(s0)
ffffffffc0200bc4:	e000                	sd	s0,0(s0)
    nr_free = 0;
ffffffffc0200bc6:	00010797          	auipc	a5,0x10
ffffffffc0200bca:	4807a523          	sw	zero,1162(a5) # ffffffffc0211050 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200bce:	2ff000ef          	jal	ra,ffffffffc02016cc <alloc_pages>
ffffffffc0200bd2:	2c051863          	bnez	a0,ffffffffc0200ea2 <default_check+0x3d6>
    free_page(p0);
ffffffffc0200bd6:	4585                	li	a1,1
ffffffffc0200bd8:	8552                	mv	a0,s4
ffffffffc0200bda:	385000ef          	jal	ra,ffffffffc020175e <free_pages>
    free_page(p1);
ffffffffc0200bde:	4585                	li	a1,1
ffffffffc0200be0:	854e                	mv	a0,s3
ffffffffc0200be2:	37d000ef          	jal	ra,ffffffffc020175e <free_pages>
    free_page(p2);
ffffffffc0200be6:	4585                	li	a1,1
ffffffffc0200be8:	8556                	mv	a0,s5
ffffffffc0200bea:	375000ef          	jal	ra,ffffffffc020175e <free_pages>
    assert(nr_free == 3);
ffffffffc0200bee:	4818                	lw	a4,16(s0)
ffffffffc0200bf0:	478d                	li	a5,3
ffffffffc0200bf2:	28f71863          	bne	a4,a5,ffffffffc0200e82 <default_check+0x3b6>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200bf6:	4505                	li	a0,1
ffffffffc0200bf8:	2d5000ef          	jal	ra,ffffffffc02016cc <alloc_pages>
ffffffffc0200bfc:	89aa                	mv	s3,a0
ffffffffc0200bfe:	26050263          	beqz	a0,ffffffffc0200e62 <default_check+0x396>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200c02:	4505                	li	a0,1
ffffffffc0200c04:	2c9000ef          	jal	ra,ffffffffc02016cc <alloc_pages>
ffffffffc0200c08:	8aaa                	mv	s5,a0
ffffffffc0200c0a:	3a050c63          	beqz	a0,ffffffffc0200fc2 <default_check+0x4f6>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c0e:	4505                	li	a0,1
ffffffffc0200c10:	2bd000ef          	jal	ra,ffffffffc02016cc <alloc_pages>
ffffffffc0200c14:	8a2a                	mv	s4,a0
ffffffffc0200c16:	38050663          	beqz	a0,ffffffffc0200fa2 <default_check+0x4d6>
    assert(alloc_page() == NULL);
ffffffffc0200c1a:	4505                	li	a0,1
ffffffffc0200c1c:	2b1000ef          	jal	ra,ffffffffc02016cc <alloc_pages>
ffffffffc0200c20:	36051163          	bnez	a0,ffffffffc0200f82 <default_check+0x4b6>
    free_page(p0);
ffffffffc0200c24:	4585                	li	a1,1
ffffffffc0200c26:	854e                	mv	a0,s3
ffffffffc0200c28:	337000ef          	jal	ra,ffffffffc020175e <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200c2c:	641c                	ld	a5,8(s0)
ffffffffc0200c2e:	20878a63          	beq	a5,s0,ffffffffc0200e42 <default_check+0x376>
    assert((p = alloc_page()) == p0);
ffffffffc0200c32:	4505                	li	a0,1
ffffffffc0200c34:	299000ef          	jal	ra,ffffffffc02016cc <alloc_pages>
ffffffffc0200c38:	30a99563          	bne	s3,a0,ffffffffc0200f42 <default_check+0x476>
    assert(alloc_page() == NULL);
ffffffffc0200c3c:	4505                	li	a0,1
ffffffffc0200c3e:	28f000ef          	jal	ra,ffffffffc02016cc <alloc_pages>
ffffffffc0200c42:	2e051063          	bnez	a0,ffffffffc0200f22 <default_check+0x456>
    assert(nr_free == 0);
ffffffffc0200c46:	481c                	lw	a5,16(s0)
ffffffffc0200c48:	2a079d63          	bnez	a5,ffffffffc0200f02 <default_check+0x436>
    free_page(p);
ffffffffc0200c4c:	854e                	mv	a0,s3
ffffffffc0200c4e:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200c50:	01843023          	sd	s8,0(s0)
ffffffffc0200c54:	01743423          	sd	s7,8(s0)
    nr_free = nr_free_store;
ffffffffc0200c58:	01642823          	sw	s6,16(s0)
    free_page(p);
ffffffffc0200c5c:	303000ef          	jal	ra,ffffffffc020175e <free_pages>
    free_page(p1);
ffffffffc0200c60:	4585                	li	a1,1
ffffffffc0200c62:	8556                	mv	a0,s5
ffffffffc0200c64:	2fb000ef          	jal	ra,ffffffffc020175e <free_pages>
    free_page(p2);
ffffffffc0200c68:	4585                	li	a1,1
ffffffffc0200c6a:	8552                	mv	a0,s4
ffffffffc0200c6c:	2f3000ef          	jal	ra,ffffffffc020175e <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200c70:	4515                	li	a0,5
ffffffffc0200c72:	25b000ef          	jal	ra,ffffffffc02016cc <alloc_pages>
ffffffffc0200c76:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200c78:	26050563          	beqz	a0,ffffffffc0200ee2 <default_check+0x416>
ffffffffc0200c7c:	651c                	ld	a5,8(a0)
ffffffffc0200c7e:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200c80:	8b85                	andi	a5,a5,1
ffffffffc0200c82:	54079063          	bnez	a5,ffffffffc02011c2 <default_check+0x6f6>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200c86:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200c88:	00043b03          	ld	s6,0(s0)
ffffffffc0200c8c:	00843a83          	ld	s5,8(s0)
ffffffffc0200c90:	e000                	sd	s0,0(s0)
ffffffffc0200c92:	e400                	sd	s0,8(s0)
    assert(alloc_page() == NULL);
ffffffffc0200c94:	239000ef          	jal	ra,ffffffffc02016cc <alloc_pages>
ffffffffc0200c98:	50051563          	bnez	a0,ffffffffc02011a2 <default_check+0x6d6>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200c9c:	09098a13          	addi	s4,s3,144
ffffffffc0200ca0:	8552                	mv	a0,s4
ffffffffc0200ca2:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200ca4:	01042b83          	lw	s7,16(s0)
    nr_free = 0;
ffffffffc0200ca8:	00010797          	auipc	a5,0x10
ffffffffc0200cac:	3a07a423          	sw	zero,936(a5) # ffffffffc0211050 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200cb0:	2af000ef          	jal	ra,ffffffffc020175e <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200cb4:	4511                	li	a0,4
ffffffffc0200cb6:	217000ef          	jal	ra,ffffffffc02016cc <alloc_pages>
ffffffffc0200cba:	4c051463          	bnez	a0,ffffffffc0201182 <default_check+0x6b6>
ffffffffc0200cbe:	0989b783          	ld	a5,152(s3)
ffffffffc0200cc2:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200cc4:	8b85                	andi	a5,a5,1
ffffffffc0200cc6:	48078e63          	beqz	a5,ffffffffc0201162 <default_check+0x696>
ffffffffc0200cca:	0a89a703          	lw	a4,168(s3)
ffffffffc0200cce:	478d                	li	a5,3
ffffffffc0200cd0:	48f71963          	bne	a4,a5,ffffffffc0201162 <default_check+0x696>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200cd4:	450d                	li	a0,3
ffffffffc0200cd6:	1f7000ef          	jal	ra,ffffffffc02016cc <alloc_pages>
ffffffffc0200cda:	8c2a                	mv	s8,a0
ffffffffc0200cdc:	46050363          	beqz	a0,ffffffffc0201142 <default_check+0x676>
    assert(alloc_page() == NULL);
ffffffffc0200ce0:	4505                	li	a0,1
ffffffffc0200ce2:	1eb000ef          	jal	ra,ffffffffc02016cc <alloc_pages>
ffffffffc0200ce6:	42051e63          	bnez	a0,ffffffffc0201122 <default_check+0x656>
    assert(p0 + 2 == p1);
ffffffffc0200cea:	418a1c63          	bne	s4,s8,ffffffffc0201102 <default_check+0x636>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200cee:	4585                	li	a1,1
ffffffffc0200cf0:	854e                	mv	a0,s3
ffffffffc0200cf2:	26d000ef          	jal	ra,ffffffffc020175e <free_pages>
    free_pages(p1, 3);
ffffffffc0200cf6:	458d                	li	a1,3
ffffffffc0200cf8:	8552                	mv	a0,s4
ffffffffc0200cfa:	265000ef          	jal	ra,ffffffffc020175e <free_pages>
ffffffffc0200cfe:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc0200d02:	04898c13          	addi	s8,s3,72
ffffffffc0200d06:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200d08:	8b85                	andi	a5,a5,1
ffffffffc0200d0a:	3c078c63          	beqz	a5,ffffffffc02010e2 <default_check+0x616>
ffffffffc0200d0e:	0189a703          	lw	a4,24(s3)
ffffffffc0200d12:	4785                	li	a5,1
ffffffffc0200d14:	3cf71763          	bne	a4,a5,ffffffffc02010e2 <default_check+0x616>
ffffffffc0200d18:	008a3783          	ld	a5,8(s4)
ffffffffc0200d1c:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200d1e:	8b85                	andi	a5,a5,1
ffffffffc0200d20:	3a078163          	beqz	a5,ffffffffc02010c2 <default_check+0x5f6>
ffffffffc0200d24:	018a2703          	lw	a4,24(s4)
ffffffffc0200d28:	478d                	li	a5,3
ffffffffc0200d2a:	38f71c63          	bne	a4,a5,ffffffffc02010c2 <default_check+0x5f6>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200d2e:	4505                	li	a0,1
ffffffffc0200d30:	19d000ef          	jal	ra,ffffffffc02016cc <alloc_pages>
ffffffffc0200d34:	36a99763          	bne	s3,a0,ffffffffc02010a2 <default_check+0x5d6>
    free_page(p0);
ffffffffc0200d38:	4585                	li	a1,1
ffffffffc0200d3a:	225000ef          	jal	ra,ffffffffc020175e <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200d3e:	4509                	li	a0,2
ffffffffc0200d40:	18d000ef          	jal	ra,ffffffffc02016cc <alloc_pages>
ffffffffc0200d44:	32aa1f63          	bne	s4,a0,ffffffffc0201082 <default_check+0x5b6>

    free_pages(p0, 2);
ffffffffc0200d48:	4589                	li	a1,2
ffffffffc0200d4a:	215000ef          	jal	ra,ffffffffc020175e <free_pages>
    free_page(p2);
ffffffffc0200d4e:	4585                	li	a1,1
ffffffffc0200d50:	8562                	mv	a0,s8
ffffffffc0200d52:	20d000ef          	jal	ra,ffffffffc020175e <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200d56:	4515                	li	a0,5
ffffffffc0200d58:	175000ef          	jal	ra,ffffffffc02016cc <alloc_pages>
ffffffffc0200d5c:	89aa                	mv	s3,a0
ffffffffc0200d5e:	48050263          	beqz	a0,ffffffffc02011e2 <default_check+0x716>
    assert(alloc_page() == NULL);
ffffffffc0200d62:	4505                	li	a0,1
ffffffffc0200d64:	169000ef          	jal	ra,ffffffffc02016cc <alloc_pages>
ffffffffc0200d68:	2c051d63          	bnez	a0,ffffffffc0201042 <default_check+0x576>

    assert(nr_free == 0);
ffffffffc0200d6c:	481c                	lw	a5,16(s0)
ffffffffc0200d6e:	2a079a63          	bnez	a5,ffffffffc0201022 <default_check+0x556>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200d72:	4595                	li	a1,5
ffffffffc0200d74:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200d76:	01742823          	sw	s7,16(s0)
    free_list = free_list_store;
ffffffffc0200d7a:	01643023          	sd	s6,0(s0)
ffffffffc0200d7e:	01543423          	sd	s5,8(s0)
    free_pages(p0, 5);
ffffffffc0200d82:	1dd000ef          	jal	ra,ffffffffc020175e <free_pages>
    return listelm->next;
ffffffffc0200d86:	641c                	ld	a5,8(s0)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d88:	00878963          	beq	a5,s0,ffffffffc0200d9a <default_check+0x2ce>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200d8c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200d90:	679c                	ld	a5,8(a5)
ffffffffc0200d92:	397d                	addiw	s2,s2,-1
ffffffffc0200d94:	9c99                	subw	s1,s1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d96:	fe879be3          	bne	a5,s0,ffffffffc0200d8c <default_check+0x2c0>
    }
    assert(count == 0);
ffffffffc0200d9a:	26091463          	bnez	s2,ffffffffc0201002 <default_check+0x536>
    assert(total == 0);
ffffffffc0200d9e:	46049263          	bnez	s1,ffffffffc0201202 <default_check+0x736>
}
ffffffffc0200da2:	60a6                	ld	ra,72(sp)
ffffffffc0200da4:	6406                	ld	s0,64(sp)
ffffffffc0200da6:	74e2                	ld	s1,56(sp)
ffffffffc0200da8:	7942                	ld	s2,48(sp)
ffffffffc0200daa:	79a2                	ld	s3,40(sp)
ffffffffc0200dac:	7a02                	ld	s4,32(sp)
ffffffffc0200dae:	6ae2                	ld	s5,24(sp)
ffffffffc0200db0:	6b42                	ld	s6,16(sp)
ffffffffc0200db2:	6ba2                	ld	s7,8(sp)
ffffffffc0200db4:	6c02                	ld	s8,0(sp)
ffffffffc0200db6:	6161                	addi	sp,sp,80
ffffffffc0200db8:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200dba:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200dbc:	4481                	li	s1,0
ffffffffc0200dbe:	4901                	li	s2,0
ffffffffc0200dc0:	b3b9                	j	ffffffffc0200b0e <default_check+0x42>
        assert(PageProperty(p));
ffffffffc0200dc2:	00004697          	auipc	a3,0x4
ffffffffc0200dc6:	0ce68693          	addi	a3,a3,206 # ffffffffc0204e90 <commands+0x728>
ffffffffc0200dca:	00004617          	auipc	a2,0x4
ffffffffc0200dce:	0d660613          	addi	a2,a2,214 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0200dd2:	0f000593          	li	a1,240
ffffffffc0200dd6:	00004517          	auipc	a0,0x4
ffffffffc0200dda:	0e250513          	addi	a0,a0,226 # ffffffffc0204eb8 <commands+0x750>
ffffffffc0200dde:	d96ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200de2:	00004697          	auipc	a3,0x4
ffffffffc0200de6:	16e68693          	addi	a3,a3,366 # ffffffffc0204f50 <commands+0x7e8>
ffffffffc0200dea:	00004617          	auipc	a2,0x4
ffffffffc0200dee:	0b660613          	addi	a2,a2,182 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0200df2:	0bd00593          	li	a1,189
ffffffffc0200df6:	00004517          	auipc	a0,0x4
ffffffffc0200dfa:	0c250513          	addi	a0,a0,194 # ffffffffc0204eb8 <commands+0x750>
ffffffffc0200dfe:	d76ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200e02:	00004697          	auipc	a3,0x4
ffffffffc0200e06:	17668693          	addi	a3,a3,374 # ffffffffc0204f78 <commands+0x810>
ffffffffc0200e0a:	00004617          	auipc	a2,0x4
ffffffffc0200e0e:	09660613          	addi	a2,a2,150 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0200e12:	0be00593          	li	a1,190
ffffffffc0200e16:	00004517          	auipc	a0,0x4
ffffffffc0200e1a:	0a250513          	addi	a0,a0,162 # ffffffffc0204eb8 <commands+0x750>
ffffffffc0200e1e:	d56ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200e22:	00004697          	auipc	a3,0x4
ffffffffc0200e26:	19668693          	addi	a3,a3,406 # ffffffffc0204fb8 <commands+0x850>
ffffffffc0200e2a:	00004617          	auipc	a2,0x4
ffffffffc0200e2e:	07660613          	addi	a2,a2,118 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0200e32:	0c000593          	li	a1,192
ffffffffc0200e36:	00004517          	auipc	a0,0x4
ffffffffc0200e3a:	08250513          	addi	a0,a0,130 # ffffffffc0204eb8 <commands+0x750>
ffffffffc0200e3e:	d36ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200e42:	00004697          	auipc	a3,0x4
ffffffffc0200e46:	1fe68693          	addi	a3,a3,510 # ffffffffc0205040 <commands+0x8d8>
ffffffffc0200e4a:	00004617          	auipc	a2,0x4
ffffffffc0200e4e:	05660613          	addi	a2,a2,86 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0200e52:	0d900593          	li	a1,217
ffffffffc0200e56:	00004517          	auipc	a0,0x4
ffffffffc0200e5a:	06250513          	addi	a0,a0,98 # ffffffffc0204eb8 <commands+0x750>
ffffffffc0200e5e:	d16ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e62:	00004697          	auipc	a3,0x4
ffffffffc0200e66:	08e68693          	addi	a3,a3,142 # ffffffffc0204ef0 <commands+0x788>
ffffffffc0200e6a:	00004617          	auipc	a2,0x4
ffffffffc0200e6e:	03660613          	addi	a2,a2,54 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0200e72:	0d200593          	li	a1,210
ffffffffc0200e76:	00004517          	auipc	a0,0x4
ffffffffc0200e7a:	04250513          	addi	a0,a0,66 # ffffffffc0204eb8 <commands+0x750>
ffffffffc0200e7e:	cf6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 3);
ffffffffc0200e82:	00004697          	auipc	a3,0x4
ffffffffc0200e86:	1ae68693          	addi	a3,a3,430 # ffffffffc0205030 <commands+0x8c8>
ffffffffc0200e8a:	00004617          	auipc	a2,0x4
ffffffffc0200e8e:	01660613          	addi	a2,a2,22 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0200e92:	0d000593          	li	a1,208
ffffffffc0200e96:	00004517          	auipc	a0,0x4
ffffffffc0200e9a:	02250513          	addi	a0,a0,34 # ffffffffc0204eb8 <commands+0x750>
ffffffffc0200e9e:	cd6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200ea2:	00004697          	auipc	a3,0x4
ffffffffc0200ea6:	17668693          	addi	a3,a3,374 # ffffffffc0205018 <commands+0x8b0>
ffffffffc0200eaa:	00004617          	auipc	a2,0x4
ffffffffc0200eae:	ff660613          	addi	a2,a2,-10 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0200eb2:	0cb00593          	li	a1,203
ffffffffc0200eb6:	00004517          	auipc	a0,0x4
ffffffffc0200eba:	00250513          	addi	a0,a0,2 # ffffffffc0204eb8 <commands+0x750>
ffffffffc0200ebe:	cb6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200ec2:	00004697          	auipc	a3,0x4
ffffffffc0200ec6:	13668693          	addi	a3,a3,310 # ffffffffc0204ff8 <commands+0x890>
ffffffffc0200eca:	00004617          	auipc	a2,0x4
ffffffffc0200ece:	fd660613          	addi	a2,a2,-42 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0200ed2:	0c200593          	li	a1,194
ffffffffc0200ed6:	00004517          	auipc	a0,0x4
ffffffffc0200eda:	fe250513          	addi	a0,a0,-30 # ffffffffc0204eb8 <commands+0x750>
ffffffffc0200ede:	c96ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 != NULL);
ffffffffc0200ee2:	00004697          	auipc	a3,0x4
ffffffffc0200ee6:	1a668693          	addi	a3,a3,422 # ffffffffc0205088 <commands+0x920>
ffffffffc0200eea:	00004617          	auipc	a2,0x4
ffffffffc0200eee:	fb660613          	addi	a2,a2,-74 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0200ef2:	0f800593          	li	a1,248
ffffffffc0200ef6:	00004517          	auipc	a0,0x4
ffffffffc0200efa:	fc250513          	addi	a0,a0,-62 # ffffffffc0204eb8 <commands+0x750>
ffffffffc0200efe:	c76ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc0200f02:	00004697          	auipc	a3,0x4
ffffffffc0200f06:	17668693          	addi	a3,a3,374 # ffffffffc0205078 <commands+0x910>
ffffffffc0200f0a:	00004617          	auipc	a2,0x4
ffffffffc0200f0e:	f9660613          	addi	a2,a2,-106 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0200f12:	0df00593          	li	a1,223
ffffffffc0200f16:	00004517          	auipc	a0,0x4
ffffffffc0200f1a:	fa250513          	addi	a0,a0,-94 # ffffffffc0204eb8 <commands+0x750>
ffffffffc0200f1e:	c56ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f22:	00004697          	auipc	a3,0x4
ffffffffc0200f26:	0f668693          	addi	a3,a3,246 # ffffffffc0205018 <commands+0x8b0>
ffffffffc0200f2a:	00004617          	auipc	a2,0x4
ffffffffc0200f2e:	f7660613          	addi	a2,a2,-138 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0200f32:	0dd00593          	li	a1,221
ffffffffc0200f36:	00004517          	auipc	a0,0x4
ffffffffc0200f3a:	f8250513          	addi	a0,a0,-126 # ffffffffc0204eb8 <commands+0x750>
ffffffffc0200f3e:	c36ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200f42:	00004697          	auipc	a3,0x4
ffffffffc0200f46:	11668693          	addi	a3,a3,278 # ffffffffc0205058 <commands+0x8f0>
ffffffffc0200f4a:	00004617          	auipc	a2,0x4
ffffffffc0200f4e:	f5660613          	addi	a2,a2,-170 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0200f52:	0dc00593          	li	a1,220
ffffffffc0200f56:	00004517          	auipc	a0,0x4
ffffffffc0200f5a:	f6250513          	addi	a0,a0,-158 # ffffffffc0204eb8 <commands+0x750>
ffffffffc0200f5e:	c16ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f62:	00004697          	auipc	a3,0x4
ffffffffc0200f66:	f8e68693          	addi	a3,a3,-114 # ffffffffc0204ef0 <commands+0x788>
ffffffffc0200f6a:	00004617          	auipc	a2,0x4
ffffffffc0200f6e:	f3660613          	addi	a2,a2,-202 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0200f72:	0b900593          	li	a1,185
ffffffffc0200f76:	00004517          	auipc	a0,0x4
ffffffffc0200f7a:	f4250513          	addi	a0,a0,-190 # ffffffffc0204eb8 <commands+0x750>
ffffffffc0200f7e:	bf6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f82:	00004697          	auipc	a3,0x4
ffffffffc0200f86:	09668693          	addi	a3,a3,150 # ffffffffc0205018 <commands+0x8b0>
ffffffffc0200f8a:	00004617          	auipc	a2,0x4
ffffffffc0200f8e:	f1660613          	addi	a2,a2,-234 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0200f92:	0d600593          	li	a1,214
ffffffffc0200f96:	00004517          	auipc	a0,0x4
ffffffffc0200f9a:	f2250513          	addi	a0,a0,-222 # ffffffffc0204eb8 <commands+0x750>
ffffffffc0200f9e:	bd6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fa2:	00004697          	auipc	a3,0x4
ffffffffc0200fa6:	f8e68693          	addi	a3,a3,-114 # ffffffffc0204f30 <commands+0x7c8>
ffffffffc0200faa:	00004617          	auipc	a2,0x4
ffffffffc0200fae:	ef660613          	addi	a2,a2,-266 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0200fb2:	0d400593          	li	a1,212
ffffffffc0200fb6:	00004517          	auipc	a0,0x4
ffffffffc0200fba:	f0250513          	addi	a0,a0,-254 # ffffffffc0204eb8 <commands+0x750>
ffffffffc0200fbe:	bb6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200fc2:	00004697          	auipc	a3,0x4
ffffffffc0200fc6:	f4e68693          	addi	a3,a3,-178 # ffffffffc0204f10 <commands+0x7a8>
ffffffffc0200fca:	00004617          	auipc	a2,0x4
ffffffffc0200fce:	ed660613          	addi	a2,a2,-298 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0200fd2:	0d300593          	li	a1,211
ffffffffc0200fd6:	00004517          	auipc	a0,0x4
ffffffffc0200fda:	ee250513          	addi	a0,a0,-286 # ffffffffc0204eb8 <commands+0x750>
ffffffffc0200fde:	b96ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fe2:	00004697          	auipc	a3,0x4
ffffffffc0200fe6:	f4e68693          	addi	a3,a3,-178 # ffffffffc0204f30 <commands+0x7c8>
ffffffffc0200fea:	00004617          	auipc	a2,0x4
ffffffffc0200fee:	eb660613          	addi	a2,a2,-330 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0200ff2:	0bb00593          	li	a1,187
ffffffffc0200ff6:	00004517          	auipc	a0,0x4
ffffffffc0200ffa:	ec250513          	addi	a0,a0,-318 # ffffffffc0204eb8 <commands+0x750>
ffffffffc0200ffe:	b76ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(count == 0);
ffffffffc0201002:	00004697          	auipc	a3,0x4
ffffffffc0201006:	1d668693          	addi	a3,a3,470 # ffffffffc02051d8 <commands+0xa70>
ffffffffc020100a:	00004617          	auipc	a2,0x4
ffffffffc020100e:	e9660613          	addi	a2,a2,-362 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0201012:	12500593          	li	a1,293
ffffffffc0201016:	00004517          	auipc	a0,0x4
ffffffffc020101a:	ea250513          	addi	a0,a0,-350 # ffffffffc0204eb8 <commands+0x750>
ffffffffc020101e:	b56ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free == 0);
ffffffffc0201022:	00004697          	auipc	a3,0x4
ffffffffc0201026:	05668693          	addi	a3,a3,86 # ffffffffc0205078 <commands+0x910>
ffffffffc020102a:	00004617          	auipc	a2,0x4
ffffffffc020102e:	e7660613          	addi	a2,a2,-394 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0201032:	11a00593          	li	a1,282
ffffffffc0201036:	00004517          	auipc	a0,0x4
ffffffffc020103a:	e8250513          	addi	a0,a0,-382 # ffffffffc0204eb8 <commands+0x750>
ffffffffc020103e:	b36ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201042:	00004697          	auipc	a3,0x4
ffffffffc0201046:	fd668693          	addi	a3,a3,-42 # ffffffffc0205018 <commands+0x8b0>
ffffffffc020104a:	00004617          	auipc	a2,0x4
ffffffffc020104e:	e5660613          	addi	a2,a2,-426 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0201052:	11800593          	li	a1,280
ffffffffc0201056:	00004517          	auipc	a0,0x4
ffffffffc020105a:	e6250513          	addi	a0,a0,-414 # ffffffffc0204eb8 <commands+0x750>
ffffffffc020105e:	b16ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201062:	00004697          	auipc	a3,0x4
ffffffffc0201066:	f7668693          	addi	a3,a3,-138 # ffffffffc0204fd8 <commands+0x870>
ffffffffc020106a:	00004617          	auipc	a2,0x4
ffffffffc020106e:	e3660613          	addi	a2,a2,-458 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0201072:	0c100593          	li	a1,193
ffffffffc0201076:	00004517          	auipc	a0,0x4
ffffffffc020107a:	e4250513          	addi	a0,a0,-446 # ffffffffc0204eb8 <commands+0x750>
ffffffffc020107e:	af6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201082:	00004697          	auipc	a3,0x4
ffffffffc0201086:	11668693          	addi	a3,a3,278 # ffffffffc0205198 <commands+0xa30>
ffffffffc020108a:	00004617          	auipc	a2,0x4
ffffffffc020108e:	e1660613          	addi	a2,a2,-490 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0201092:	11200593          	li	a1,274
ffffffffc0201096:	00004517          	auipc	a0,0x4
ffffffffc020109a:	e2250513          	addi	a0,a0,-478 # ffffffffc0204eb8 <commands+0x750>
ffffffffc020109e:	ad6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02010a2:	00004697          	auipc	a3,0x4
ffffffffc02010a6:	0d668693          	addi	a3,a3,214 # ffffffffc0205178 <commands+0xa10>
ffffffffc02010aa:	00004617          	auipc	a2,0x4
ffffffffc02010ae:	df660613          	addi	a2,a2,-522 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02010b2:	11000593          	li	a1,272
ffffffffc02010b6:	00004517          	auipc	a0,0x4
ffffffffc02010ba:	e0250513          	addi	a0,a0,-510 # ffffffffc0204eb8 <commands+0x750>
ffffffffc02010be:	ab6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02010c2:	00004697          	auipc	a3,0x4
ffffffffc02010c6:	08e68693          	addi	a3,a3,142 # ffffffffc0205150 <commands+0x9e8>
ffffffffc02010ca:	00004617          	auipc	a2,0x4
ffffffffc02010ce:	dd660613          	addi	a2,a2,-554 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02010d2:	10e00593          	li	a1,270
ffffffffc02010d6:	00004517          	auipc	a0,0x4
ffffffffc02010da:	de250513          	addi	a0,a0,-542 # ffffffffc0204eb8 <commands+0x750>
ffffffffc02010de:	a96ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02010e2:	00004697          	auipc	a3,0x4
ffffffffc02010e6:	04668693          	addi	a3,a3,70 # ffffffffc0205128 <commands+0x9c0>
ffffffffc02010ea:	00004617          	auipc	a2,0x4
ffffffffc02010ee:	db660613          	addi	a2,a2,-586 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02010f2:	10d00593          	li	a1,269
ffffffffc02010f6:	00004517          	auipc	a0,0x4
ffffffffc02010fa:	dc250513          	addi	a0,a0,-574 # ffffffffc0204eb8 <commands+0x750>
ffffffffc02010fe:	a76ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201102:	00004697          	auipc	a3,0x4
ffffffffc0201106:	01668693          	addi	a3,a3,22 # ffffffffc0205118 <commands+0x9b0>
ffffffffc020110a:	00004617          	auipc	a2,0x4
ffffffffc020110e:	d9660613          	addi	a2,a2,-618 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0201112:	10800593          	li	a1,264
ffffffffc0201116:	00004517          	auipc	a0,0x4
ffffffffc020111a:	da250513          	addi	a0,a0,-606 # ffffffffc0204eb8 <commands+0x750>
ffffffffc020111e:	a56ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201122:	00004697          	auipc	a3,0x4
ffffffffc0201126:	ef668693          	addi	a3,a3,-266 # ffffffffc0205018 <commands+0x8b0>
ffffffffc020112a:	00004617          	auipc	a2,0x4
ffffffffc020112e:	d7660613          	addi	a2,a2,-650 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0201132:	10700593          	li	a1,263
ffffffffc0201136:	00004517          	auipc	a0,0x4
ffffffffc020113a:	d8250513          	addi	a0,a0,-638 # ffffffffc0204eb8 <commands+0x750>
ffffffffc020113e:	a36ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201142:	00004697          	auipc	a3,0x4
ffffffffc0201146:	fb668693          	addi	a3,a3,-74 # ffffffffc02050f8 <commands+0x990>
ffffffffc020114a:	00004617          	auipc	a2,0x4
ffffffffc020114e:	d5660613          	addi	a2,a2,-682 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0201152:	10600593          	li	a1,262
ffffffffc0201156:	00004517          	auipc	a0,0x4
ffffffffc020115a:	d6250513          	addi	a0,a0,-670 # ffffffffc0204eb8 <commands+0x750>
ffffffffc020115e:	a16ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201162:	00004697          	auipc	a3,0x4
ffffffffc0201166:	f6668693          	addi	a3,a3,-154 # ffffffffc02050c8 <commands+0x960>
ffffffffc020116a:	00004617          	auipc	a2,0x4
ffffffffc020116e:	d3660613          	addi	a2,a2,-714 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0201172:	10500593          	li	a1,261
ffffffffc0201176:	00004517          	auipc	a0,0x4
ffffffffc020117a:	d4250513          	addi	a0,a0,-702 # ffffffffc0204eb8 <commands+0x750>
ffffffffc020117e:	9f6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201182:	00004697          	auipc	a3,0x4
ffffffffc0201186:	f2e68693          	addi	a3,a3,-210 # ffffffffc02050b0 <commands+0x948>
ffffffffc020118a:	00004617          	auipc	a2,0x4
ffffffffc020118e:	d1660613          	addi	a2,a2,-746 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0201192:	10400593          	li	a1,260
ffffffffc0201196:	00004517          	auipc	a0,0x4
ffffffffc020119a:	d2250513          	addi	a0,a0,-734 # ffffffffc0204eb8 <commands+0x750>
ffffffffc020119e:	9d6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011a2:	00004697          	auipc	a3,0x4
ffffffffc02011a6:	e7668693          	addi	a3,a3,-394 # ffffffffc0205018 <commands+0x8b0>
ffffffffc02011aa:	00004617          	auipc	a2,0x4
ffffffffc02011ae:	cf660613          	addi	a2,a2,-778 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02011b2:	0fe00593          	li	a1,254
ffffffffc02011b6:	00004517          	auipc	a0,0x4
ffffffffc02011ba:	d0250513          	addi	a0,a0,-766 # ffffffffc0204eb8 <commands+0x750>
ffffffffc02011be:	9b6ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(!PageProperty(p0));
ffffffffc02011c2:	00004697          	auipc	a3,0x4
ffffffffc02011c6:	ed668693          	addi	a3,a3,-298 # ffffffffc0205098 <commands+0x930>
ffffffffc02011ca:	00004617          	auipc	a2,0x4
ffffffffc02011ce:	cd660613          	addi	a2,a2,-810 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02011d2:	0f900593          	li	a1,249
ffffffffc02011d6:	00004517          	auipc	a0,0x4
ffffffffc02011da:	ce250513          	addi	a0,a0,-798 # ffffffffc0204eb8 <commands+0x750>
ffffffffc02011de:	996ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02011e2:	00004697          	auipc	a3,0x4
ffffffffc02011e6:	fd668693          	addi	a3,a3,-42 # ffffffffc02051b8 <commands+0xa50>
ffffffffc02011ea:	00004617          	auipc	a2,0x4
ffffffffc02011ee:	cb660613          	addi	a2,a2,-842 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02011f2:	11700593          	li	a1,279
ffffffffc02011f6:	00004517          	auipc	a0,0x4
ffffffffc02011fa:	cc250513          	addi	a0,a0,-830 # ffffffffc0204eb8 <commands+0x750>
ffffffffc02011fe:	976ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == 0);
ffffffffc0201202:	00004697          	auipc	a3,0x4
ffffffffc0201206:	fe668693          	addi	a3,a3,-26 # ffffffffc02051e8 <commands+0xa80>
ffffffffc020120a:	00004617          	auipc	a2,0x4
ffffffffc020120e:	c9660613          	addi	a2,a2,-874 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0201212:	12600593          	li	a1,294
ffffffffc0201216:	00004517          	auipc	a0,0x4
ffffffffc020121a:	ca250513          	addi	a0,a0,-862 # ffffffffc0204eb8 <commands+0x750>
ffffffffc020121e:	956ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(total == nr_free_pages());
ffffffffc0201222:	00004697          	auipc	a3,0x4
ffffffffc0201226:	cae68693          	addi	a3,a3,-850 # ffffffffc0204ed0 <commands+0x768>
ffffffffc020122a:	00004617          	auipc	a2,0x4
ffffffffc020122e:	c7660613          	addi	a2,a2,-906 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0201232:	0f300593          	li	a1,243
ffffffffc0201236:	00004517          	auipc	a0,0x4
ffffffffc020123a:	c8250513          	addi	a0,a0,-894 # ffffffffc0204eb8 <commands+0x750>
ffffffffc020123e:	936ff0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201242:	00004697          	auipc	a3,0x4
ffffffffc0201246:	cce68693          	addi	a3,a3,-818 # ffffffffc0204f10 <commands+0x7a8>
ffffffffc020124a:	00004617          	auipc	a2,0x4
ffffffffc020124e:	c5660613          	addi	a2,a2,-938 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0201252:	0ba00593          	li	a1,186
ffffffffc0201256:	00004517          	auipc	a0,0x4
ffffffffc020125a:	c6250513          	addi	a0,a0,-926 # ffffffffc0204eb8 <commands+0x750>
ffffffffc020125e:	916ff0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201262 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201262:	1141                	addi	sp,sp,-16
ffffffffc0201264:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201266:	14058a63          	beqz	a1,ffffffffc02013ba <default_free_pages+0x158>
    for (; p != base + n; p ++) {
ffffffffc020126a:	00359693          	slli	a3,a1,0x3
ffffffffc020126e:	96ae                	add	a3,a3,a1
ffffffffc0201270:	068e                	slli	a3,a3,0x3
ffffffffc0201272:	96aa                	add	a3,a3,a0
ffffffffc0201274:	87aa                	mv	a5,a0
ffffffffc0201276:	02d50263          	beq	a0,a3,ffffffffc020129a <default_free_pages+0x38>
ffffffffc020127a:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020127c:	8b05                	andi	a4,a4,1
ffffffffc020127e:	10071e63          	bnez	a4,ffffffffc020139a <default_free_pages+0x138>
ffffffffc0201282:	6798                	ld	a4,8(a5)
ffffffffc0201284:	8b09                	andi	a4,a4,2
ffffffffc0201286:	10071a63          	bnez	a4,ffffffffc020139a <default_free_pages+0x138>
        p->flags = 0;
ffffffffc020128a:	0007b423          	sd	zero,8(a5)

// 内联函数，用于获取页面结构体（Page结构体）的引用计数，返回Page结构体中ref成员的值（ref成员可能用于记录页面被引用的次数，在内存管理中用于判断页面是否可以释放等情况）
static inline int page_ref(struct Page *page) { return page->ref; }

// 内联函数，用于设置页面结构体（Page结构体）的引用计数为指定的值（val），直接对Page结构体中的ref成员进行赋值操作
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc020128e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201292:	04878793          	addi	a5,a5,72
ffffffffc0201296:	fed792e3          	bne	a5,a3,ffffffffc020127a <default_free_pages+0x18>
    base->property = n;
ffffffffc020129a:	2581                	sext.w	a1,a1
ffffffffc020129c:	cd0c                	sw	a1,24(a0)
    SetPageProperty(base);
ffffffffc020129e:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02012a2:	4789                	li	a5,2
ffffffffc02012a4:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02012a8:	00010697          	auipc	a3,0x10
ffffffffc02012ac:	d9868693          	addi	a3,a3,-616 # ffffffffc0211040 <free_area>
ffffffffc02012b0:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02012b2:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02012b4:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc02012b8:	9db9                	addw	a1,a1,a4
ffffffffc02012ba:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02012bc:	0ad78863          	beq	a5,a3,ffffffffc020136c <default_free_pages+0x10a>
            struct Page* page = le2page(le, page_link);
ffffffffc02012c0:	fe078713          	addi	a4,a5,-32
ffffffffc02012c4:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02012c8:	4581                	li	a1,0
            if (base < page) {
ffffffffc02012ca:	00e56a63          	bltu	a0,a4,ffffffffc02012de <default_free_pages+0x7c>
    return listelm->next;
ffffffffc02012ce:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02012d0:	06d70263          	beq	a4,a3,ffffffffc0201334 <default_free_pages+0xd2>
    for (; p != base + n; p ++) {
ffffffffc02012d4:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02012d6:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc02012da:	fee57ae3          	bgeu	a0,a4,ffffffffc02012ce <default_free_pages+0x6c>
ffffffffc02012de:	c199                	beqz	a1,ffffffffc02012e4 <default_free_pages+0x82>
ffffffffc02012e0:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02012e4:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02012e6:	e390                	sd	a2,0(a5)
ffffffffc02012e8:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc02012ea:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc02012ec:	f118                	sd	a4,32(a0)
    if (le != &free_list) {
ffffffffc02012ee:	02d70063          	beq	a4,a3,ffffffffc020130e <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc02012f2:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc02012f6:	fe070593          	addi	a1,a4,-32
        if (p + p->property == base) {
ffffffffc02012fa:	02081613          	slli	a2,a6,0x20
ffffffffc02012fe:	9201                	srli	a2,a2,0x20
ffffffffc0201300:	00361793          	slli	a5,a2,0x3
ffffffffc0201304:	97b2                	add	a5,a5,a2
ffffffffc0201306:	078e                	slli	a5,a5,0x3
ffffffffc0201308:	97ae                	add	a5,a5,a1
ffffffffc020130a:	02f50f63          	beq	a0,a5,ffffffffc0201348 <default_free_pages+0xe6>
    return listelm->next;
ffffffffc020130e:	7518                	ld	a4,40(a0)
    if (le != &free_list) {
ffffffffc0201310:	00d70f63          	beq	a4,a3,ffffffffc020132e <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc0201314:	4d0c                	lw	a1,24(a0)
        p = le2page(le, page_link);
ffffffffc0201316:	fe070693          	addi	a3,a4,-32
        if (base + base->property == p) {
ffffffffc020131a:	02059613          	slli	a2,a1,0x20
ffffffffc020131e:	9201                	srli	a2,a2,0x20
ffffffffc0201320:	00361793          	slli	a5,a2,0x3
ffffffffc0201324:	97b2                	add	a5,a5,a2
ffffffffc0201326:	078e                	slli	a5,a5,0x3
ffffffffc0201328:	97aa                	add	a5,a5,a0
ffffffffc020132a:	04f68863          	beq	a3,a5,ffffffffc020137a <default_free_pages+0x118>
}
ffffffffc020132e:	60a2                	ld	ra,8(sp)
ffffffffc0201330:	0141                	addi	sp,sp,16
ffffffffc0201332:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201334:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201336:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0201338:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020133a:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc020133c:	02d70563          	beq	a4,a3,ffffffffc0201366 <default_free_pages+0x104>
    prev->next = next->prev = elm;
ffffffffc0201340:	8832                	mv	a6,a2
ffffffffc0201342:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc0201344:	87ba                	mv	a5,a4
ffffffffc0201346:	bf41                	j	ffffffffc02012d6 <default_free_pages+0x74>
            p->property += base->property;
ffffffffc0201348:	4d1c                	lw	a5,24(a0)
ffffffffc020134a:	0107883b          	addw	a6,a5,a6
ffffffffc020134e:	ff072c23          	sw	a6,-8(a4)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201352:	57f5                	li	a5,-3
ffffffffc0201354:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201358:	7110                	ld	a2,32(a0)
ffffffffc020135a:	751c                	ld	a5,40(a0)
            base = p;
ffffffffc020135c:	852e                	mv	a0,a1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020135e:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc0201360:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc0201362:	e390                	sd	a2,0(a5)
ffffffffc0201364:	b775                	j	ffffffffc0201310 <default_free_pages+0xae>
ffffffffc0201366:	e290                	sd	a2,0(a3)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201368:	873e                	mv	a4,a5
ffffffffc020136a:	b761                	j	ffffffffc02012f2 <default_free_pages+0x90>
}
ffffffffc020136c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020136e:	e390                	sd	a2,0(a5)
ffffffffc0201370:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201372:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201374:	f11c                	sd	a5,32(a0)
ffffffffc0201376:	0141                	addi	sp,sp,16
ffffffffc0201378:	8082                	ret
            base->property += p->property;
ffffffffc020137a:	ff872783          	lw	a5,-8(a4)
ffffffffc020137e:	fe870693          	addi	a3,a4,-24
ffffffffc0201382:	9dbd                	addw	a1,a1,a5
ffffffffc0201384:	cd0c                	sw	a1,24(a0)
ffffffffc0201386:	57f5                	li	a5,-3
ffffffffc0201388:	60f6b02f          	amoand.d	zero,a5,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020138c:	6314                	ld	a3,0(a4)
ffffffffc020138e:	671c                	ld	a5,8(a4)
}
ffffffffc0201390:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201392:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0201394:	e394                	sd	a3,0(a5)
ffffffffc0201396:	0141                	addi	sp,sp,16
ffffffffc0201398:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020139a:	00004697          	auipc	a3,0x4
ffffffffc020139e:	e6668693          	addi	a3,a3,-410 # ffffffffc0205200 <commands+0xa98>
ffffffffc02013a2:	00004617          	auipc	a2,0x4
ffffffffc02013a6:	afe60613          	addi	a2,a2,-1282 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02013aa:	08300593          	li	a1,131
ffffffffc02013ae:	00004517          	auipc	a0,0x4
ffffffffc02013b2:	b0a50513          	addi	a0,a0,-1270 # ffffffffc0204eb8 <commands+0x750>
ffffffffc02013b6:	fbffe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc02013ba:	00004697          	auipc	a3,0x4
ffffffffc02013be:	e3e68693          	addi	a3,a3,-450 # ffffffffc02051f8 <commands+0xa90>
ffffffffc02013c2:	00004617          	auipc	a2,0x4
ffffffffc02013c6:	ade60613          	addi	a2,a2,-1314 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02013ca:	08000593          	li	a1,128
ffffffffc02013ce:	00004517          	auipc	a0,0x4
ffffffffc02013d2:	aea50513          	addi	a0,a0,-1302 # ffffffffc0204eb8 <commands+0x750>
ffffffffc02013d6:	f9ffe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02013da <default_alloc_pages>:
    assert(n > 0);
ffffffffc02013da:	c959                	beqz	a0,ffffffffc0201470 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc02013dc:	00010597          	auipc	a1,0x10
ffffffffc02013e0:	c6458593          	addi	a1,a1,-924 # ffffffffc0211040 <free_area>
ffffffffc02013e4:	0105a803          	lw	a6,16(a1)
ffffffffc02013e8:	862a                	mv	a2,a0
ffffffffc02013ea:	02081793          	slli	a5,a6,0x20
ffffffffc02013ee:	9381                	srli	a5,a5,0x20
ffffffffc02013f0:	00a7ee63          	bltu	a5,a0,ffffffffc020140c <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02013f4:	87ae                	mv	a5,a1
ffffffffc02013f6:	a801                	j	ffffffffc0201406 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02013f8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02013fc:	02071693          	slli	a3,a4,0x20
ffffffffc0201400:	9281                	srli	a3,a3,0x20
ffffffffc0201402:	00c6f763          	bgeu	a3,a2,ffffffffc0201410 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc0201406:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201408:	feb798e3          	bne	a5,a1,ffffffffc02013f8 <default_alloc_pages+0x1e>
        return NULL;
ffffffffc020140c:	4501                	li	a0,0
}
ffffffffc020140e:	8082                	ret
    return listelm->prev;
ffffffffc0201410:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201414:	0087b303          	ld	t1,8(a5)
        struct Page *p = le2page(le, page_link);
ffffffffc0201418:	fe078513          	addi	a0,a5,-32
            p->property = page->property - n;
ffffffffc020141c:	00060e1b          	sext.w	t3,a2
    prev->next = next;
ffffffffc0201420:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201424:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc0201428:	02d67b63          	bgeu	a2,a3,ffffffffc020145e <default_alloc_pages+0x84>
            struct Page *p = page + n;
ffffffffc020142c:	00361693          	slli	a3,a2,0x3
ffffffffc0201430:	96b2                	add	a3,a3,a2
ffffffffc0201432:	068e                	slli	a3,a3,0x3
ffffffffc0201434:	96aa                	add	a3,a3,a0
            p->property = page->property - n;
ffffffffc0201436:	41c7073b          	subw	a4,a4,t3
ffffffffc020143a:	ce98                	sw	a4,24(a3)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020143c:	00868613          	addi	a2,a3,8
ffffffffc0201440:	4709                	li	a4,2
ffffffffc0201442:	40e6302f          	amoor.d	zero,a4,(a2)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201446:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc020144a:	02068613          	addi	a2,a3,32
        nr_free -= n;
ffffffffc020144e:	0105a803          	lw	a6,16(a1)
    prev->next = next->prev = elm;
ffffffffc0201452:	e310                	sd	a2,0(a4)
ffffffffc0201454:	00c8b423          	sd	a2,8(a7)
    elm->next = next;
ffffffffc0201458:	f698                	sd	a4,40(a3)
    elm->prev = prev;
ffffffffc020145a:	0316b023          	sd	a7,32(a3)
ffffffffc020145e:	41c8083b          	subw	a6,a6,t3
ffffffffc0201462:	0105a823          	sw	a6,16(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201466:	5775                	li	a4,-3
ffffffffc0201468:	17a1                	addi	a5,a5,-24
ffffffffc020146a:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc020146e:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201470:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201472:	00004697          	auipc	a3,0x4
ffffffffc0201476:	d8668693          	addi	a3,a3,-634 # ffffffffc02051f8 <commands+0xa90>
ffffffffc020147a:	00004617          	auipc	a2,0x4
ffffffffc020147e:	a2660613          	addi	a2,a2,-1498 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0201482:	06200593          	li	a1,98
ffffffffc0201486:	00004517          	auipc	a0,0x4
ffffffffc020148a:	a3250513          	addi	a0,a0,-1486 # ffffffffc0204eb8 <commands+0x750>
default_alloc_pages(size_t n) {
ffffffffc020148e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201490:	ee5fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201494 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201494:	1141                	addi	sp,sp,-16
ffffffffc0201496:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201498:	c9e1                	beqz	a1,ffffffffc0201568 <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc020149a:	00359693          	slli	a3,a1,0x3
ffffffffc020149e:	96ae                	add	a3,a3,a1
ffffffffc02014a0:	068e                	slli	a3,a3,0x3
ffffffffc02014a2:	96aa                	add	a3,a3,a0
ffffffffc02014a4:	87aa                	mv	a5,a0
ffffffffc02014a6:	00d50f63          	beq	a0,a3,ffffffffc02014c4 <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02014aa:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02014ac:	8b05                	andi	a4,a4,1
ffffffffc02014ae:	cf49                	beqz	a4,ffffffffc0201548 <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc02014b0:	0007ac23          	sw	zero,24(a5)
ffffffffc02014b4:	0007b423          	sd	zero,8(a5)
ffffffffc02014b8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02014bc:	04878793          	addi	a5,a5,72
ffffffffc02014c0:	fed795e3          	bne	a5,a3,ffffffffc02014aa <default_init_memmap+0x16>
    base->property = n;
ffffffffc02014c4:	2581                	sext.w	a1,a1
ffffffffc02014c6:	cd0c                	sw	a1,24(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02014c8:	4789                	li	a5,2
ffffffffc02014ca:	00850713          	addi	a4,a0,8
ffffffffc02014ce:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02014d2:	00010697          	auipc	a3,0x10
ffffffffc02014d6:	b6e68693          	addi	a3,a3,-1170 # ffffffffc0211040 <free_area>
ffffffffc02014da:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02014dc:	669c                	ld	a5,8(a3)
        list_add(&free_list, &(base->page_link));
ffffffffc02014de:	02050613          	addi	a2,a0,32
    nr_free += n;
ffffffffc02014e2:	9db9                	addw	a1,a1,a4
ffffffffc02014e4:	ca8c                	sw	a1,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02014e6:	04d78a63          	beq	a5,a3,ffffffffc020153a <default_init_memmap+0xa6>
            struct Page* page = le2page(le, page_link);
ffffffffc02014ea:	fe078713          	addi	a4,a5,-32
ffffffffc02014ee:	0006b803          	ld	a6,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02014f2:	4581                	li	a1,0
            if (base < page) {
ffffffffc02014f4:	00e56a63          	bltu	a0,a4,ffffffffc0201508 <default_init_memmap+0x74>
    return listelm->next;
ffffffffc02014f8:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02014fa:	02d70263          	beq	a4,a3,ffffffffc020151e <default_init_memmap+0x8a>
    for (; p != base + n; p ++) {
ffffffffc02014fe:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201500:	fe078713          	addi	a4,a5,-32
            if (base < page) {
ffffffffc0201504:	fee57ae3          	bgeu	a0,a4,ffffffffc02014f8 <default_init_memmap+0x64>
ffffffffc0201508:	c199                	beqz	a1,ffffffffc020150e <default_init_memmap+0x7a>
ffffffffc020150a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020150e:	6398                	ld	a4,0(a5)
}
ffffffffc0201510:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201512:	e390                	sd	a2,0(a5)
ffffffffc0201514:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201516:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201518:	f118                	sd	a4,32(a0)
ffffffffc020151a:	0141                	addi	sp,sp,16
ffffffffc020151c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020151e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201520:	f514                	sd	a3,40(a0)
    return listelm->next;
ffffffffc0201522:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201524:	f11c                	sd	a5,32(a0)
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201526:	00d70663          	beq	a4,a3,ffffffffc0201532 <default_init_memmap+0x9e>
    prev->next = next->prev = elm;
ffffffffc020152a:	8832                	mv	a6,a2
ffffffffc020152c:	4585                	li	a1,1
    for (; p != base + n; p ++) {
ffffffffc020152e:	87ba                	mv	a5,a4
ffffffffc0201530:	bfc1                	j	ffffffffc0201500 <default_init_memmap+0x6c>
}
ffffffffc0201532:	60a2                	ld	ra,8(sp)
ffffffffc0201534:	e290                	sd	a2,0(a3)
ffffffffc0201536:	0141                	addi	sp,sp,16
ffffffffc0201538:	8082                	ret
ffffffffc020153a:	60a2                	ld	ra,8(sp)
ffffffffc020153c:	e390                	sd	a2,0(a5)
ffffffffc020153e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201540:	f51c                	sd	a5,40(a0)
    elm->prev = prev;
ffffffffc0201542:	f11c                	sd	a5,32(a0)
ffffffffc0201544:	0141                	addi	sp,sp,16
ffffffffc0201546:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201548:	00004697          	auipc	a3,0x4
ffffffffc020154c:	ce068693          	addi	a3,a3,-800 # ffffffffc0205228 <commands+0xac0>
ffffffffc0201550:	00004617          	auipc	a2,0x4
ffffffffc0201554:	95060613          	addi	a2,a2,-1712 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0201558:	04900593          	li	a1,73
ffffffffc020155c:	00004517          	auipc	a0,0x4
ffffffffc0201560:	95c50513          	addi	a0,a0,-1700 # ffffffffc0204eb8 <commands+0x750>
ffffffffc0201564:	e11fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0);
ffffffffc0201568:	00004697          	auipc	a3,0x4
ffffffffc020156c:	c9068693          	addi	a3,a3,-880 # ffffffffc02051f8 <commands+0xa90>
ffffffffc0201570:	00004617          	auipc	a2,0x4
ffffffffc0201574:	93060613          	addi	a2,a2,-1744 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0201578:	04600593          	li	a1,70
ffffffffc020157c:	00004517          	auipc	a0,0x4
ffffffffc0201580:	93c50513          	addi	a0,a0,-1732 # ffffffffc0204eb8 <commands+0x750>
ffffffffc0201584:	df1fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201588 <lru_pgfault>:
        *ptep &= ~PTE_R;
    }
    return 0;
}

int lru_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0201588:	7179                	addi	sp,sp,-48
ffffffffc020158a:	ec26                	sd	s1,24(sp)
    cprintf("lru page fault at 0x%x\n", addr);
ffffffffc020158c:	85b2                	mv	a1,a2
int lru_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020158e:	84aa                	mv	s1,a0
    cprintf("lru page fault at 0x%x\n", addr);
ffffffffc0201590:	00004517          	auipc	a0,0x4
ffffffffc0201594:	cf850513          	addi	a0,a0,-776 # ffffffffc0205288 <default_pmm_manager+0x38>
int lru_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0201598:	e84a                	sd	s2,16(sp)
ffffffffc020159a:	f406                	sd	ra,40(sp)
ffffffffc020159c:	f022                	sd	s0,32(sp)
ffffffffc020159e:	e44e                	sd	s3,8(sp)
ffffffffc02015a0:	8932                	mv	s2,a2
    cprintf("lru page fault at 0x%x\n", addr);
ffffffffc02015a2:	b19fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    // 设置所有页面不可读
    if(swap_init_ok) 
ffffffffc02015a6:	00010797          	auipc	a5,0x10
ffffffffc02015aa:	faa7a783          	lw	a5,-86(a5) # ffffffffc0211550 <swap_init_ok>
ffffffffc02015ae:	ebc9                	bnez	a5,ffffffffc0201640 <lru_pgfault+0xb8>
        unable_page_read(mm);
    // 将需要获得的页面设置为可读
    pte_t* ptep = NULL;
    ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc02015b0:	6c88                	ld	a0,24(s1)
ffffffffc02015b2:	4601                	li	a2,0
ffffffffc02015b4:	85ca                	mv	a1,s2
ffffffffc02015b6:	222000ef          	jal	ra,ffffffffc02017d8 <get_pte>
    *ptep |= PTE_R;
ffffffffc02015ba:	6114                	ld	a3,0(a0)
    if(!swap_init_ok) 
ffffffffc02015bc:	00010717          	auipc	a4,0x10
ffffffffc02015c0:	f9472703          	lw	a4,-108(a4) # ffffffffc0211550 <swap_init_ok>
    *ptep |= PTE_R;
ffffffffc02015c4:	0026e793          	ori	a5,a3,2
ffffffffc02015c8:	e11c                	sd	a5,0(a0)
    if(!swap_init_ok) 
ffffffffc02015ca:	eb09                	bnez	a4,ffffffffc02015dc <lru_pgfault+0x54>
            list_add(head, le);
            break;
        }
    }
    return 0;
}
ffffffffc02015cc:	70a2                	ld	ra,40(sp)
ffffffffc02015ce:	7402                	ld	s0,32(sp)
ffffffffc02015d0:	64e2                	ld	s1,24(sp)
ffffffffc02015d2:	6942                	ld	s2,16(sp)
ffffffffc02015d4:	69a2                	ld	s3,8(sp)
ffffffffc02015d6:	4501                	li	a0,0
ffffffffc02015d8:	6145                	addi	sp,sp,48
ffffffffc02015da:	8082                	ret
    if (!(pte & PTE_V)) {
ffffffffc02015dc:	8a85                	andi	a3,a3,1
ffffffffc02015de:	c2d9                	beqz	a3,ffffffffc0201664 <lru_pgfault+0xdc>
    return pa2page(PTE_ADDR(pte));
ffffffffc02015e0:	078a                	slli	a5,a5,0x2
ffffffffc02015e2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02015e4:	00010717          	auipc	a4,0x10
ffffffffc02015e8:	f3c73703          	ld	a4,-196(a4) # ffffffffc0211520 <npage>
ffffffffc02015ec:	08e7f863          	bgeu	a5,a4,ffffffffc020167c <lru_pgfault+0xf4>
    return &pages[PPN(pa) - nbase];
ffffffffc02015f0:	00005717          	auipc	a4,0x5
ffffffffc02015f4:	d5073703          	ld	a4,-688(a4) # ffffffffc0206340 <nbase>
ffffffffc02015f8:	8f99                	sub	a5,a5,a4
ffffffffc02015fa:	00379613          	slli	a2,a5,0x3
    list_entry_t *head=(list_entry_t*) mm->sm_priv, *le = head;
ffffffffc02015fe:	7494                	ld	a3,40(s1)
ffffffffc0201600:	97b2                	add	a5,a5,a2
ffffffffc0201602:	078e                	slli	a5,a5,0x3
ffffffffc0201604:	00010617          	auipc	a2,0x10
ffffffffc0201608:	f2463603          	ld	a2,-220(a2) # ffffffffc0211528 <pages>
ffffffffc020160c:	963e                	add	a2,a2,a5
ffffffffc020160e:	87b6                	mv	a5,a3
    return listelm->prev;
ffffffffc0201610:	639c                	ld	a5,0(a5)
    while ((le = list_prev(le)) != head)
ffffffffc0201612:	faf68de3          	beq	a3,a5,ffffffffc02015cc <lru_pgfault+0x44>
        struct Page* curr = le2page(le, pra_page_link);
ffffffffc0201616:	fd078713          	addi	a4,a5,-48
        if(page == curr) {
ffffffffc020161a:	fee61be3          	bne	a2,a4,ffffffffc0201610 <lru_pgfault+0x88>
    __list_del(listelm->prev, listelm->next);
ffffffffc020161e:	638c                	ld	a1,0(a5)
ffffffffc0201620:	6790                	ld	a2,8(a5)
}
ffffffffc0201622:	70a2                	ld	ra,40(sp)
ffffffffc0201624:	7402                	ld	s0,32(sp)
    prev->next = next;
ffffffffc0201626:	e590                	sd	a2,8(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201628:	6698                	ld	a4,8(a3)
    next->prev = prev;
ffffffffc020162a:	e20c                	sd	a1,0(a2)
ffffffffc020162c:	64e2                	ld	s1,24(sp)
    prev->next = next->prev = elm;
ffffffffc020162e:	e31c                	sd	a5,0(a4)
ffffffffc0201630:	e69c                	sd	a5,8(a3)
    elm->next = next;
ffffffffc0201632:	e798                	sd	a4,8(a5)
    elm->prev = prev;
ffffffffc0201634:	e394                	sd	a3,0(a5)
ffffffffc0201636:	6942                	ld	s2,16(sp)
ffffffffc0201638:	69a2                	ld	s3,8(sp)
ffffffffc020163a:	4501                	li	a0,0
ffffffffc020163c:	6145                	addi	sp,sp,48
ffffffffc020163e:	8082                	ret
    list_entry_t *head=(list_entry_t*) mm->sm_priv, *le = head;
ffffffffc0201640:	0284b983          	ld	s3,40(s1)
    return listelm->prev;
ffffffffc0201644:	0009b403          	ld	s0,0(s3)
    while ((le = list_prev(le)) != head)
ffffffffc0201648:	f68984e3          	beq	s3,s0,ffffffffc02015b0 <lru_pgfault+0x28>
        ptep = get_pte(mm->pgdir, page->pra_vaddr, 0);
ffffffffc020164c:	680c                	ld	a1,16(s0)
ffffffffc020164e:	6c88                	ld	a0,24(s1)
ffffffffc0201650:	4601                	li	a2,0
ffffffffc0201652:	186000ef          	jal	ra,ffffffffc02017d8 <get_pte>
        *ptep &= ~PTE_R;
ffffffffc0201656:	611c                	ld	a5,0(a0)
ffffffffc0201658:	6000                	ld	s0,0(s0)
ffffffffc020165a:	9bf5                	andi	a5,a5,-3
ffffffffc020165c:	e11c                	sd	a5,0(a0)
    while ((le = list_prev(le)) != head)
ffffffffc020165e:	fe8997e3          	bne	s3,s0,ffffffffc020164c <lru_pgfault+0xc4>
ffffffffc0201662:	b7b9                	j	ffffffffc02015b0 <lru_pgfault+0x28>
        panic("pte2page called with invalid pte");
ffffffffc0201664:	00004617          	auipc	a2,0x4
ffffffffc0201668:	c3c60613          	addi	a2,a2,-964 # ffffffffc02052a0 <default_pmm_manager+0x50>
ffffffffc020166c:	08e00593          	li	a1,142
ffffffffc0201670:	00004517          	auipc	a0,0x4
ffffffffc0201674:	c5850513          	addi	a0,a0,-936 # ffffffffc02052c8 <default_pmm_manager+0x78>
ffffffffc0201678:	cfdfe0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020167c:	00004617          	auipc	a2,0x4
ffffffffc0201680:	c5c60613          	addi	a2,a2,-932 # ffffffffc02052d8 <default_pmm_manager+0x88>
ffffffffc0201684:	08000593          	li	a1,128
ffffffffc0201688:	00004517          	auipc	a0,0x4
ffffffffc020168c:	c4050513          	addi	a0,a0,-960 # ffffffffc02052c8 <default_pmm_manager+0x78>
ffffffffc0201690:	ce5fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0201694 <pa2page.part.0>:
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc0201694:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201696:	00004617          	auipc	a2,0x4
ffffffffc020169a:	c4260613          	addi	a2,a2,-958 # ffffffffc02052d8 <default_pmm_manager+0x88>
ffffffffc020169e:	08000593          	li	a1,128
ffffffffc02016a2:	00004517          	auipc	a0,0x4
ffffffffc02016a6:	c2650513          	addi	a0,a0,-986 # ffffffffc02052c8 <default_pmm_manager+0x78>
static inline struct Page *pa2page(uintptr_t pa) {
ffffffffc02016aa:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc02016ac:	cc9fe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02016b0 <pte2page.part.0>:
static inline struct Page *pte2page(pte_t pte) {
ffffffffc02016b0:	1141                	addi	sp,sp,-16
        panic("pte2page called with invalid pte");
ffffffffc02016b2:	00004617          	auipc	a2,0x4
ffffffffc02016b6:	bee60613          	addi	a2,a2,-1042 # ffffffffc02052a0 <default_pmm_manager+0x50>
ffffffffc02016ba:	08e00593          	li	a1,142
ffffffffc02016be:	00004517          	auipc	a0,0x4
ffffffffc02016c2:	c0a50513          	addi	a0,a0,-1014 # ffffffffc02052c8 <default_pmm_manager+0x78>
static inline struct Page *pte2page(pte_t pte) {
ffffffffc02016c6:	e406                	sd	ra,8(sp)
        panic("pte2page called with invalid pte");
ffffffffc02016c8:	cadfe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02016cc <alloc_pages>:

// alloc_pages - 用于分配连续的n个页面大小（PAGESIZE，通常等同于PGSIZE，即一个页面的字节数）的内存
// 它在一个循环中尝试进行内存分配，通过先保存中断状态（使用local_intr_save函数，可能是用于在多核等环境下避免分配过程被中断干扰），然后调用具体物理内存管理实现的alloc_pages函数进行内存分配
// 如果分配成功（page指针不为NULL）或者要分配的页面数量大于1（可能对于多页分配有不同处理逻辑）或者交换初始化未完成（swap_init_ok == 0，swap_init_ok应该是在其他地方定义的表示交换功能初始化状态的变量），则跳出循环
// 如果分配失败且不满足上述跳出条件，则调用swap_out函数（可能涉及将内存页面交换到磁盘等交换空间的操作，具体依赖于swap相关的实现逻辑）尝试释放一些内存以便再次进行分配，最后返回分配得到的页面指针（如果分配成功）或者NULL（分配失败）
struct Page *alloc_pages(size_t n) {
ffffffffc02016cc:	7139                	addi	sp,sp,-64
ffffffffc02016ce:	f426                	sd	s1,40(sp)
ffffffffc02016d0:	f04a                	sd	s2,32(sp)
ffffffffc02016d2:	ec4e                	sd	s3,24(sp)
ffffffffc02016d4:	e852                	sd	s4,16(sp)
ffffffffc02016d6:	e456                	sd	s5,8(sp)
ffffffffc02016d8:	e05a                	sd	s6,0(sp)
ffffffffc02016da:	fc06                	sd	ra,56(sp)
ffffffffc02016dc:	f822                	sd	s0,48(sp)
ffffffffc02016de:	84aa                	mv	s1,a0
ffffffffc02016e0:	00010917          	auipc	s2,0x10
ffffffffc02016e4:	e5090913          	addi	s2,s2,-432 # ffffffffc0211530 <pmm_manager>
    while (1) {
        local_intr_save(intr_flag);
        { page = pmm_manager->alloc_pages(n); }
        local_intr_restore(intr_flag);

        if (page!= NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc02016e8:	4a05                	li	s4,1
ffffffffc02016ea:	00010a97          	auipc	s5,0x10
ffffffffc02016ee:	e66a8a93          	addi	s5,s5,-410 # ffffffffc0211550 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc02016f2:	0005099b          	sext.w	s3,a0
ffffffffc02016f6:	00010b17          	auipc	s6,0x10
ffffffffc02016fa:	e6ab0b13          	addi	s6,s6,-406 # ffffffffc0211560 <check_mm_struct>
ffffffffc02016fe:	a01d                	j	ffffffffc0201724 <alloc_pages+0x58>
        { page = pmm_manager->alloc_pages(n); }
ffffffffc0201700:	00093783          	ld	a5,0(s2)
ffffffffc0201704:	6f9c                	ld	a5,24(a5)
ffffffffc0201706:	9782                	jalr	a5
ffffffffc0201708:	842a                	mv	s0,a0
        swap_out(check_mm_struct, n, 0);
ffffffffc020170a:	4601                	li	a2,0
ffffffffc020170c:	85ce                	mv	a1,s3
        if (page!= NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc020170e:	ec0d                	bnez	s0,ffffffffc0201748 <alloc_pages+0x7c>
ffffffffc0201710:	029a6c63          	bltu	s4,s1,ffffffffc0201748 <alloc_pages+0x7c>
ffffffffc0201714:	000aa783          	lw	a5,0(s5)
ffffffffc0201718:	2781                	sext.w	a5,a5
ffffffffc020171a:	c79d                	beqz	a5,ffffffffc0201748 <alloc_pages+0x7c>
        swap_out(check_mm_struct, n, 0);
ffffffffc020171c:	000b3503          	ld	a0,0(s6)
ffffffffc0201720:	189010ef          	jal	ra,ffffffffc02030a8 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201724:	100027f3          	csrr	a5,sstatus
ffffffffc0201728:	8b89                	andi	a5,a5,2
        { page = pmm_manager->alloc_pages(n); }
ffffffffc020172a:	8526                	mv	a0,s1
ffffffffc020172c:	dbf1                	beqz	a5,ffffffffc0201700 <alloc_pages+0x34>
        intr_disable();
ffffffffc020172e:	dc1fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0201732:	00093783          	ld	a5,0(s2)
ffffffffc0201736:	8526                	mv	a0,s1
ffffffffc0201738:	6f9c                	ld	a5,24(a5)
ffffffffc020173a:	9782                	jalr	a5
ffffffffc020173c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020173e:	dabfe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201742:	4601                	li	a2,0
ffffffffc0201744:	85ce                	mv	a1,s3
        if (page!= NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201746:	d469                	beqz	s0,ffffffffc0201710 <alloc_pages+0x44>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201748:	70e2                	ld	ra,56(sp)
ffffffffc020174a:	8522                	mv	a0,s0
ffffffffc020174c:	7442                	ld	s0,48(sp)
ffffffffc020174e:	74a2                	ld	s1,40(sp)
ffffffffc0201750:	7902                	ld	s2,32(sp)
ffffffffc0201752:	69e2                	ld	s3,24(sp)
ffffffffc0201754:	6a42                	ld	s4,16(sp)
ffffffffc0201756:	6aa2                	ld	s5,8(sp)
ffffffffc0201758:	6b02                	ld	s6,0(sp)
ffffffffc020175a:	6121                	addi	sp,sp,64
ffffffffc020175c:	8082                	ret

ffffffffc020175e <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020175e:	100027f3          	csrr	a5,sstatus
ffffffffc0201762:	8b89                	andi	a5,a5,2
ffffffffc0201764:	e799                	bnez	a5,ffffffffc0201772 <free_pages+0x14>
// free_pages - 用于释放连续的n个页面大小的内存，通过先保存中断状态（防止在释放过程中被中断干扰内存管理数据结构的一致性），然后调用具体物理内存管理实现的free_pages函数来释放由base指针指向起始位置的n个页面内存
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;

    local_intr_save(intr_flag);
    { pmm_manager->free_pages(base, n); }
ffffffffc0201766:	00010797          	auipc	a5,0x10
ffffffffc020176a:	dca7b783          	ld	a5,-566(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc020176e:	739c                	ld	a5,32(a5)
ffffffffc0201770:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201772:	1101                	addi	sp,sp,-32
ffffffffc0201774:	ec06                	sd	ra,24(sp)
ffffffffc0201776:	e822                	sd	s0,16(sp)
ffffffffc0201778:	e426                	sd	s1,8(sp)
ffffffffc020177a:	842a                	mv	s0,a0
ffffffffc020177c:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc020177e:	d71fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201782:	00010797          	auipc	a5,0x10
ffffffffc0201786:	dae7b783          	ld	a5,-594(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc020178a:	739c                	ld	a5,32(a5)
ffffffffc020178c:	85a6                	mv	a1,s1
ffffffffc020178e:	8522                	mv	a0,s0
ffffffffc0201790:	9782                	jalr	a5
    local_intr_restore(intr_flag);
}
ffffffffc0201792:	6442                	ld	s0,16(sp)
ffffffffc0201794:	60e2                	ld	ra,24(sp)
ffffffffc0201796:	64a2                	ld	s1,8(sp)
ffffffffc0201798:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020179a:	d4ffe06f          	j	ffffffffc02004e8 <intr_enable>

ffffffffc020179e <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020179e:	100027f3          	csrr	a5,sstatus
ffffffffc02017a2:	8b89                	andi	a5,a5,2
ffffffffc02017a4:	e799                	bnez	a5,ffffffffc02017b2 <nr_free_pages+0x14>
// nr_free_pages - 用于获取当前空闲内存的大小（以页面数量表示），同样先保存中断状态，然后调用具体物理内存管理实现的nr_free_pages函数获取空闲页面数量，最后恢复中断状态并返回获取到的空闲页面数量值
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02017a6:	00010797          	auipc	a5,0x10
ffffffffc02017aa:	d8a7b783          	ld	a5,-630(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc02017ae:	779c                	ld	a5,40(a5)
ffffffffc02017b0:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc02017b2:	1141                	addi	sp,sp,-16
ffffffffc02017b4:	e406                	sd	ra,8(sp)
ffffffffc02017b6:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc02017b8:	d37fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02017bc:	00010797          	auipc	a5,0x10
ffffffffc02017c0:	d747b783          	ld	a5,-652(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc02017c4:	779c                	ld	a5,40(a5)
ffffffffc02017c6:	9782                	jalr	a5
ffffffffc02017c8:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02017ca:	d1ffe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc02017ce:	60a2                	ld	ra,8(sp)
ffffffffc02017d0:	8522                	mv	a0,s0
ffffffffc02017d2:	6402                	ld	s0,0(sp)
ffffffffc02017d4:	0141                	addi	sp,sp,16
ffffffffc02017d6:	8082                	ret

ffffffffc02017d8 <get_pte>:
    /*
     * 如果需要访问物理地址，请使用KADDR()函数进行转换，建议阅读pmm.h文件获取更多有用的宏定义和函数等信息
     * 以下注释提供了一些可能在代码实现中有用的宏和函数说明，帮助完成代码逻辑
     */
    // 根据线性地址la获取其在第一级页目录中的索引（PDX1(la)），然后获取对应的页目录项指针pdep1
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02017d8:	01e5d793          	srli	a5,a1,0x1e
ffffffffc02017dc:	1ff7f793          	andi	a5,a5,511
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02017e0:	715d                	addi	sp,sp,-80
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02017e2:	078e                	slli	a5,a5,0x3
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02017e4:	fc26                	sd	s1,56(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc02017e6:	00f504b3          	add	s1,a0,a5
    // 检查该页目录项的有效位（PTE_V）是否未设置，即对应的页表是否不存在（在这个两级页表结构中，第一级页目录项指向第二级页表）
    if (!(*pdep1 & PTE_V)) {
ffffffffc02017ea:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc02017ec:	f84a                	sd	s2,48(sp)
ffffffffc02017ee:	f44e                	sd	s3,40(sp)
ffffffffc02017f0:	f052                	sd	s4,32(sp)
ffffffffc02017f2:	e486                	sd	ra,72(sp)
ffffffffc02017f4:	e0a2                	sd	s0,64(sp)
ffffffffc02017f6:	ec56                	sd	s5,24(sp)
ffffffffc02017f8:	e85a                	sd	s6,16(sp)
ffffffffc02017fa:	e45e                	sd	s7,8(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc02017fc:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201800:	892e                	mv	s2,a1
ffffffffc0201802:	8a32                	mv	s4,a2
ffffffffc0201804:	00010997          	auipc	s3,0x10
ffffffffc0201808:	d1c98993          	addi	s3,s3,-740 # ffffffffc0211520 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc020180c:	efb5                	bnez	a5,ffffffffc0201888 <get_pte+0xb0>
        struct Page *page;
        // 如果create为false（即不允许创建新页面来构建页表）或者分配页面失败（alloc_page返回NULL），则直接返回NULL，表示无法获取到对应的页表项
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc020180e:	14060c63          	beqz	a2,ffffffffc0201966 <get_pte+0x18e>
ffffffffc0201812:	4505                	li	a0,1
ffffffffc0201814:	eb9ff0ef          	jal	ra,ffffffffc02016cc <alloc_pages>
ffffffffc0201818:	842a                	mv	s0,a0
ffffffffc020181a:	14050663          	beqz	a0,ffffffffc0201966 <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020181e:	00010b97          	auipc	s7,0x10
ffffffffc0201822:	d0ab8b93          	addi	s7,s7,-758 # ffffffffc0211528 <pages>
ffffffffc0201826:	000bb503          	ld	a0,0(s7)
ffffffffc020182a:	00005b17          	auipc	s6,0x5
ffffffffc020182e:	b0eb3b03          	ld	s6,-1266(s6) # ffffffffc0206338 <error_string+0x38>
ffffffffc0201832:	00080ab7          	lui	s5,0x80
ffffffffc0201836:	40a40533          	sub	a0,s0,a0
ffffffffc020183a:	850d                	srai	a0,a0,0x3
ffffffffc020183c:	03650533          	mul	a0,a0,s6
        set_page_ref(page, 1);
        // 获取刚分配页面的物理地址，通过page2pa函数将页面结构体指针转换为对应的物理地址
        uintptr_t pa = page2pa(page);
        // 使用KADDR函数将物理地址转换为内核虚拟地址，然后将对应的内存区域（大小为一个页面，PGSIZE字节）清零
        // 这一步可能是为了初始化新分配的页表页面内容，确保其处于一个初始的、可使用的状态
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201840:	00010997          	auipc	s3,0x10
ffffffffc0201844:	ce098993          	addi	s3,s3,-800 # ffffffffc0211520 <npage>
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201848:	4785                	li	a5,1
ffffffffc020184a:	0009b703          	ld	a4,0(s3)
ffffffffc020184e:	c01c                	sw	a5,0(s0)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201850:	9556                	add	a0,a0,s5
ffffffffc0201852:	00c51793          	slli	a5,a0,0xc
ffffffffc0201856:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201858:	0532                	slli	a0,a0,0xc
ffffffffc020185a:	14e7fd63          	bgeu	a5,a4,ffffffffc02019b4 <get_pte+0x1dc>
ffffffffc020185e:	00010797          	auipc	a5,0x10
ffffffffc0201862:	cda7b783          	ld	a5,-806(a5) # ffffffffc0211538 <va_pa_offset>
ffffffffc0201866:	6605                	lui	a2,0x1
ffffffffc0201868:	4581                	li	a1,0
ffffffffc020186a:	953e                	add	a0,a0,a5
ffffffffc020186c:	47b020ef          	jal	ra,ffffffffc02044e6 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201870:	000bb683          	ld	a3,0(s7)
ffffffffc0201874:	40d406b3          	sub	a3,s0,a3
ffffffffc0201878:	868d                	srai	a3,a3,0x3
ffffffffc020187a:	036686b3          	mul	a3,a3,s6
ffffffffc020187e:	96d6                	add	a3,a3,s5
// 内联函数，通过内联汇编指令（"sfence.vma"，在某些架构中用于刷新内存管理相关的硬件缓存，确保内存一致性等情况）来刷新转换旁视缓冲器（TLB），可能在更新页表等操作后调用
static inline void flush_tlb() { asm volatile("sfence.vma"); }

// 内联函数，用于根据给定的页号（ppn）和权限类型（type）构造一个页表项（PTE），通过将页号左移PTE_PPN_SHIFT位，然后与有效位（PTE_V）以及给定的权限类型按位或操作得到页表项的值
static inline pte_t pte_create(uintptr_t ppn, int type) {
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201880:	06aa                	slli	a3,a3,0xa
ffffffffc0201882:	0116e693          	ori	a3,a3,17
        // 根据刚分配页面的页号（通过page2ppn获取）以及设置有效位（PTE_V）和用户可访问位（PTE_U，这里假设一般创建的页表项用户可访问，具体根据实际需求可能不同）构造页目录项的值，并赋值给对应的页目录项指针指向的位置
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201886:	e094                	sd	a3,0(s1)
    }
    // 根据第一级页目录项指向的页表（先通过KADDR和PDE_ADDR宏获取其物理地址对应的内核虚拟地址，再进行类型转换），获取对应线性地址在第二级页表中的索引（PDX0(la)），从而得到对应的第二级页表项指针pdep0
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201888:	77fd                	lui	a5,0xfffff
ffffffffc020188a:	068a                	slli	a3,a3,0x2
ffffffffc020188c:	0009b703          	ld	a4,0(s3)
ffffffffc0201890:	8efd                	and	a3,a3,a5
ffffffffc0201892:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201896:	0ce7fa63          	bgeu	a5,a4,ffffffffc020196a <get_pte+0x192>
ffffffffc020189a:	00010a97          	auipc	s5,0x10
ffffffffc020189e:	c9ea8a93          	addi	s5,s5,-866 # ffffffffc0211538 <va_pa_offset>
ffffffffc02018a2:	000ab403          	ld	s0,0(s5)
ffffffffc02018a6:	01595793          	srli	a5,s2,0x15
ffffffffc02018aa:	1ff7f793          	andi	a5,a5,511
ffffffffc02018ae:	96a2                	add	a3,a3,s0
ffffffffc02018b0:	00379413          	slli	s0,a5,0x3
ffffffffc02018b4:	9436                	add	s0,s0,a3
//    pde_t *pdep0 = &((pde_t *)(PDE_ADDR(*pdep1)))[PDX0(la)];
    // 同样检查该第二级页表项的有效位（PTE_V）是否未设置，即对应的映射关系是否还未建立
    if (!(*pdep0 & PTE_V)) {
ffffffffc02018b6:	6014                	ld	a3,0(s0)
ffffffffc02018b8:	0016f793          	andi	a5,a3,1
ffffffffc02018bc:	ebad                	bnez	a5,ffffffffc020192e <get_pte+0x156>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc02018be:	0a0a0463          	beqz	s4,ffffffffc0201966 <get_pte+0x18e>
ffffffffc02018c2:	4505                	li	a0,1
ffffffffc02018c4:	e09ff0ef          	jal	ra,ffffffffc02016cc <alloc_pages>
ffffffffc02018c8:	84aa                	mv	s1,a0
ffffffffc02018ca:	cd51                	beqz	a0,ffffffffc0201966 <get_pte+0x18e>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018cc:	00010b97          	auipc	s7,0x10
ffffffffc02018d0:	c5cb8b93          	addi	s7,s7,-932 # ffffffffc0211528 <pages>
ffffffffc02018d4:	000bb503          	ld	a0,0(s7)
ffffffffc02018d8:	00005b17          	auipc	s6,0x5
ffffffffc02018dc:	a60b3b03          	ld	s6,-1440(s6) # ffffffffc0206338 <error_string+0x38>
ffffffffc02018e0:	00080a37          	lui	s4,0x80
ffffffffc02018e4:	40a48533          	sub	a0,s1,a0
ffffffffc02018e8:	850d                	srai	a0,a0,0x3
ffffffffc02018ea:	03650533          	mul	a0,a0,s6
static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02018ee:	4785                	li	a5,1
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        // 与上面类似，将新分配用于页表项的页面内存区域清零，这里使用KADDR将物理地址转换为内核虚拟地址后进行操作，确保在虚拟地址空间对应的内存区域被初始化
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02018f0:	0009b703          	ld	a4,0(s3)
ffffffffc02018f4:	c09c                	sw	a5,0(s1)
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02018f6:	9552                	add	a0,a0,s4
ffffffffc02018f8:	00c51793          	slli	a5,a0,0xc
ffffffffc02018fc:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02018fe:	0532                	slli	a0,a0,0xc
ffffffffc0201900:	08e7fd63          	bgeu	a5,a4,ffffffffc020199a <get_pte+0x1c2>
ffffffffc0201904:	000ab783          	ld	a5,0(s5)
ffffffffc0201908:	6605                	lui	a2,0x1
ffffffffc020190a:	4581                	li	a1,0
ffffffffc020190c:	953e                	add	a0,a0,a5
ffffffffc020190e:	3d9020ef          	jal	ra,ffffffffc02044e6 <memset>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201912:	000bb683          	ld	a3,0(s7)
ffffffffc0201916:	40d486b3          	sub	a3,s1,a3
ffffffffc020191a:	868d                	srai	a3,a3,0x3
ffffffffc020191c:	036686b3          	mul	a3,a3,s6
ffffffffc0201920:	96d2                	add	a3,a3,s4
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201922:	06aa                	slli	a3,a3,0xa
ffffffffc0201924:	0116e693          	ori	a3,a3,17
 //   	memset(pa, 0, PGSIZE);  // 原代码此处有误，不能直接用物理地址操作内存（除非在特定的直接访问物理内存的环境下），应通过内核虚拟地址访问内存
        // 根据新分配页面的页号构造页表项的值，同样设置有效位以及用户可访问位，然后赋值给对应的第二级页表项指针指向的位置，完成页表项的创建和映射关系的初步建立
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201928:	e014                	sd	a3,0(s0)
    }
    // 最后，根据第二级页表项所在的页表（通过KADDR和PDE_ADDR获取内核虚拟地址）以及线性地址在页表中的索引（PTX(la)），返回对应的页表项指针，即获取到了最终用于映射该线性地址的页表项
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020192a:	0009b703          	ld	a4,0(s3)
ffffffffc020192e:	068a                	slli	a3,a3,0x2
ffffffffc0201930:	757d                	lui	a0,0xfffff
ffffffffc0201932:	8ee9                	and	a3,a3,a0
ffffffffc0201934:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201938:	04e7f563          	bgeu	a5,a4,ffffffffc0201982 <get_pte+0x1aa>
ffffffffc020193c:	000ab503          	ld	a0,0(s5)
ffffffffc0201940:	00c95913          	srli	s2,s2,0xc
ffffffffc0201944:	1ff97913          	andi	s2,s2,511
ffffffffc0201948:	96aa                	add	a3,a3,a0
ffffffffc020194a:	00391513          	slli	a0,s2,0x3
ffffffffc020194e:	9536                	add	a0,a0,a3
}
ffffffffc0201950:	60a6                	ld	ra,72(sp)
ffffffffc0201952:	6406                	ld	s0,64(sp)
ffffffffc0201954:	74e2                	ld	s1,56(sp)
ffffffffc0201956:	7942                	ld	s2,48(sp)
ffffffffc0201958:	79a2                	ld	s3,40(sp)
ffffffffc020195a:	7a02                	ld	s4,32(sp)
ffffffffc020195c:	6ae2                	ld	s5,24(sp)
ffffffffc020195e:	6b42                	ld	s6,16(sp)
ffffffffc0201960:	6ba2                	ld	s7,8(sp)
ffffffffc0201962:	6161                	addi	sp,sp,80
ffffffffc0201964:	8082                	ret
            return NULL;
ffffffffc0201966:	4501                	li	a0,0
ffffffffc0201968:	b7e5                	j	ffffffffc0201950 <get_pte+0x178>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020196a:	00004617          	auipc	a2,0x4
ffffffffc020196e:	98e60613          	addi	a2,a2,-1650 # ffffffffc02052f8 <default_pmm_manager+0xa8>
ffffffffc0201972:	10c00593          	li	a1,268
ffffffffc0201976:	00004517          	auipc	a0,0x4
ffffffffc020197a:	9aa50513          	addi	a0,a0,-1622 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc020197e:	9f7fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201982:	00004617          	auipc	a2,0x4
ffffffffc0201986:	97660613          	addi	a2,a2,-1674 # ffffffffc02052f8 <default_pmm_manager+0xa8>
ffffffffc020198a:	11d00593          	li	a1,285
ffffffffc020198e:	00004517          	auipc	a0,0x4
ffffffffc0201992:	99250513          	addi	a0,a0,-1646 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc0201996:	9dffe0ef          	jal	ra,ffffffffc0200374 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020199a:	86aa                	mv	a3,a0
ffffffffc020199c:	00004617          	auipc	a2,0x4
ffffffffc02019a0:	95c60613          	addi	a2,a2,-1700 # ffffffffc02052f8 <default_pmm_manager+0xa8>
ffffffffc02019a4:	11700593          	li	a1,279
ffffffffc02019a8:	00004517          	auipc	a0,0x4
ffffffffc02019ac:	97850513          	addi	a0,a0,-1672 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc02019b0:	9c5fe0ef          	jal	ra,ffffffffc0200374 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02019b4:	86aa                	mv	a3,a0
ffffffffc02019b6:	00004617          	auipc	a2,0x4
ffffffffc02019ba:	94260613          	addi	a2,a2,-1726 # ffffffffc02052f8 <default_pmm_manager+0xa8>
ffffffffc02019be:	10700593          	li	a1,263
ffffffffc02019c2:	00004517          	auipc	a0,0x4
ffffffffc02019c6:	95e50513          	addi	a0,a0,-1698 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc02019ca:	9abfe0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02019ce <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
// 根据给定的页目录（pgdir）和线性地址（la），获取对应的页面结构体指针，如果ptep_store指针不为NULL，还会将对应的页表项指针存储到ptep_store指向的位置
// 返回值：如果能找到有效的页表项且对应的页面存在，则返回对应的页面结构体指针；否则返回NULL
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02019ce:	1141                	addi	sp,sp,-16
ffffffffc02019d0:	e022                	sd	s0,0(sp)
ffffffffc02019d2:	8432                	mv	s0,a2
    // 首先调用get_pte函数获取对应线性地址la的页表项指针
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02019d4:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc02019d6:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02019d8:	e01ff0ef          	jal	ra,ffffffffc02017d8 <get_pte>
    // 如果ptep_store指针不为NULL，将获取到的页表项指针存储到ptep_store指向的位置
    if (ptep_store!= NULL) {
ffffffffc02019dc:	c011                	beqz	s0,ffffffffc02019e0 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc02019de:	e008                	sd	a0,0(s0)
    }
    // 如果获取到的页表项指针不为NULL且该页表项的有效位（PTE_V）被设置，表示对应的页面存在且映射关系有效，通过pte2page函数将页表项转换为对应的页面结构体指针并返回
    if (ptep!= NULL && *ptep & PTE_V) {
ffffffffc02019e0:	c511                	beqz	a0,ffffffffc02019ec <get_page+0x1e>
ffffffffc02019e2:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    // 如果上述条件不满足，即无法获取到有效的页面映射，返回NULL
    return NULL;
ffffffffc02019e4:	4501                	li	a0,0
    if (ptep!= NULL && *ptep & PTE_V) {
ffffffffc02019e6:	0017f713          	andi	a4,a5,1
ffffffffc02019ea:	e709                	bnez	a4,ffffffffc02019f4 <get_page+0x26>
}
ffffffffc02019ec:	60a2                	ld	ra,8(sp)
ffffffffc02019ee:	6402                	ld	s0,0(sp)
ffffffffc02019f0:	0141                	addi	sp,sp,16
ffffffffc02019f2:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc02019f4:	078a                	slli	a5,a5,0x2
ffffffffc02019f6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02019f8:	00010717          	auipc	a4,0x10
ffffffffc02019fc:	b2873703          	ld	a4,-1240(a4) # ffffffffc0211520 <npage>
ffffffffc0201a00:	02e7f263          	bgeu	a5,a4,ffffffffc0201a24 <get_page+0x56>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a04:	fff80537          	lui	a0,0xfff80
ffffffffc0201a08:	97aa                	add	a5,a5,a0
ffffffffc0201a0a:	60a2                	ld	ra,8(sp)
ffffffffc0201a0c:	6402                	ld	s0,0(sp)
ffffffffc0201a0e:	00379513          	slli	a0,a5,0x3
ffffffffc0201a12:	97aa                	add	a5,a5,a0
ffffffffc0201a14:	078e                	slli	a5,a5,0x3
ffffffffc0201a16:	00010517          	auipc	a0,0x10
ffffffffc0201a1a:	b1253503          	ld	a0,-1262(a0) # ffffffffc0211528 <pages>
ffffffffc0201a1e:	953e                	add	a0,a0,a5
ffffffffc0201a20:	0141                	addi	sp,sp,16
ffffffffc0201a22:	8082                	ret
ffffffffc0201a24:	c71ff0ef          	jal	ra,ffffffffc0201694 <pa2page.part.0>

ffffffffc0201a28 <page_remove>:
}

// page_remove - free an Page which is related linear address la and has an
// validated pte
// 释放与线性地址la相关且具有有效页表项的页面，此函数通过先获取对应线性地址的页表项，然后调用page_remove_pte函数来完成实际的页面释放和页表项清理工作
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201a28:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201a2a:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc0201a2c:	ec06                	sd	ra,24(sp)
ffffffffc0201a2e:	e822                	sd	s0,16(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0201a30:	da9ff0ef          	jal	ra,ffffffffc02017d8 <get_pte>
    if (ptep!= NULL) {
ffffffffc0201a34:	c511                	beqz	a0,ffffffffc0201a40 <page_remove+0x18>
    if (*ptep & PTE_V) {  
ffffffffc0201a36:	611c                	ld	a5,0(a0)
ffffffffc0201a38:	842a                	mv	s0,a0
ffffffffc0201a3a:	0017f713          	andi	a4,a5,1
ffffffffc0201a3e:	e709                	bnez	a4,ffffffffc0201a48 <page_remove+0x20>
        page_remove_pte(pgdir, la, ptep);
    }
}
ffffffffc0201a40:	60e2                	ld	ra,24(sp)
ffffffffc0201a42:	6442                	ld	s0,16(sp)
ffffffffc0201a44:	6105                	addi	sp,sp,32
ffffffffc0201a46:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201a48:	078a                	slli	a5,a5,0x2
ffffffffc0201a4a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201a4c:	00010717          	auipc	a4,0x10
ffffffffc0201a50:	ad473703          	ld	a4,-1324(a4) # ffffffffc0211520 <npage>
ffffffffc0201a54:	06e7f563          	bgeu	a5,a4,ffffffffc0201abe <page_remove+0x96>
    return &pages[PPN(pa) - nbase];
ffffffffc0201a58:	fff80737          	lui	a4,0xfff80
ffffffffc0201a5c:	97ba                	add	a5,a5,a4
ffffffffc0201a5e:	00379513          	slli	a0,a5,0x3
ffffffffc0201a62:	97aa                	add	a5,a5,a0
ffffffffc0201a64:	078e                	slli	a5,a5,0x3
ffffffffc0201a66:	00010517          	auipc	a0,0x10
ffffffffc0201a6a:	ac253503          	ld	a0,-1342(a0) # ffffffffc0211528 <pages>
ffffffffc0201a6e:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0201a70:	411c                	lw	a5,0(a0)
ffffffffc0201a72:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201a76:	c118                	sw	a4,0(a0)
        if (page_ref(page) == 0) {  
ffffffffc0201a78:	cb09                	beqz	a4,ffffffffc0201a8a <page_remove+0x62>
        *ptep = 0;  
ffffffffc0201a7a:	00043023          	sd	zero,0(s0)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201a7e:	12000073          	sfence.vma
}
ffffffffc0201a82:	60e2                	ld	ra,24(sp)
ffffffffc0201a84:	6442                	ld	s0,16(sp)
ffffffffc0201a86:	6105                	addi	sp,sp,32
ffffffffc0201a88:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a8a:	100027f3          	csrr	a5,sstatus
ffffffffc0201a8e:	8b89                	andi	a5,a5,2
ffffffffc0201a90:	eb89                	bnez	a5,ffffffffc0201aa2 <page_remove+0x7a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201a92:	00010797          	auipc	a5,0x10
ffffffffc0201a96:	a9e7b783          	ld	a5,-1378(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0201a9a:	739c                	ld	a5,32(a5)
ffffffffc0201a9c:	4585                	li	a1,1
ffffffffc0201a9e:	9782                	jalr	a5
    if (flag) {
ffffffffc0201aa0:	bfe9                	j	ffffffffc0201a7a <page_remove+0x52>
        intr_disable();
ffffffffc0201aa2:	e42a                	sd	a0,8(sp)
ffffffffc0201aa4:	a4bfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0201aa8:	00010797          	auipc	a5,0x10
ffffffffc0201aac:	a887b783          	ld	a5,-1400(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0201ab0:	739c                	ld	a5,32(a5)
ffffffffc0201ab2:	6522                	ld	a0,8(sp)
ffffffffc0201ab4:	4585                	li	a1,1
ffffffffc0201ab6:	9782                	jalr	a5
        intr_enable();
ffffffffc0201ab8:	a31fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0201abc:	bf7d                	j	ffffffffc0201a7a <page_remove+0x52>
ffffffffc0201abe:	bd7ff0ef          	jal	ra,ffffffffc0201694 <pa2page.part.0>

ffffffffc0201ac2 <page_insert>:
//  page:  需要映射的页面结构体指针，代表要将哪个物理页面映射到指定的线性地址上
//  la:    需要映射的线性地址（Linear Address），指定了要建立映射关系的目标线性地址
//  perm:  页面的权限设置，用于设置对应页表项中关于页面访问权限的相关位（如可读、可写、可执行等权限组合），通过一些预定义的位标志来表示（在相关头文件中有定义）
// 返回值：始终返回0，表示操作成功（如果操作失败，例如内存不足无法创建页表项等情况，会通过其他方式返回错误信息或者进行错误处理，比如在get_pte函数中返回NULL等）
// 注意：由于插入页面映射会改变页表（PT）内容，所以需要使相应的转换旁视缓冲器（TLB）项无效，以保证地址转换的缓存数据一致性
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201ac2:	7179                	addi	sp,sp,-48
ffffffffc0201ac4:	87b2                	mv	a5,a2
ffffffffc0201ac6:	f022                	sd	s0,32(sp)
    // 首先调用get_pte函数获取对应线性地址la的页表项指针，如果create参数为1（这里调用时传入的是1），表示如果页表项不存在则会尝试创建
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201ac8:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201aca:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201acc:	85be                	mv	a1,a5
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0201ace:	ec26                	sd	s1,24(sp)
ffffffffc0201ad0:	f406                	sd	ra,40(sp)
ffffffffc0201ad2:	e84a                	sd	s2,16(sp)
ffffffffc0201ad4:	e44e                	sd	s3,8(sp)
ffffffffc0201ad6:	e052                	sd	s4,0(sp)
ffffffffc0201ad8:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0201ada:	cffff0ef          	jal	ra,ffffffffc02017d8 <get_pte>
    // 如果获取页表项指针失败（返回NULL），可能是内存不足等原因无法创建页表项，此时返回-E_NO_MEM错误码，表示没有足够内存来完成操作
    if (ptep == NULL) {
ffffffffc0201ade:	cd71                	beqz	a0,ffffffffc0201bba <page_insert+0xf8>
    page->ref += 1;
ffffffffc0201ae0:	4014                	lw	a3,0(s0)
        return -E_NO_MEM;
    }
    // 增加要插入映射的页面的引用计数，因为又有一处（这里是通过页表项建立的映射关系）引用了该页面，通过page_ref_inc函数实现引用计数加1操作
    page_ref_inc(page);
    // 检查获取到的页表项的有效位（PTE_V）是否已被设置，即是否已经存在映射关系
    if (*ptep & PTE_V) {
ffffffffc0201ae2:	611c                	ld	a5,0(a0)
ffffffffc0201ae4:	89aa                	mv	s3,a0
ffffffffc0201ae6:	0016871b          	addiw	a4,a3,1
ffffffffc0201aea:	c018                	sw	a4,0(s0)
ffffffffc0201aec:	0017f713          	andi	a4,a5,1
ffffffffc0201af0:	e331                	bnez	a4,ffffffffc0201b34 <page_insert+0x72>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201af2:	00010797          	auipc	a5,0x10
ffffffffc0201af6:	a367b783          	ld	a5,-1482(a5) # ffffffffc0211528 <pages>
ffffffffc0201afa:	40f407b3          	sub	a5,s0,a5
ffffffffc0201afe:	878d                	srai	a5,a5,0x3
ffffffffc0201b00:	00005417          	auipc	s0,0x5
ffffffffc0201b04:	83843403          	ld	s0,-1992(s0) # ffffffffc0206338 <error_string+0x38>
ffffffffc0201b08:	028787b3          	mul	a5,a5,s0
ffffffffc0201b0c:	00080437          	lui	s0,0x80
ffffffffc0201b10:	97a2                	add	a5,a5,s0
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201b12:	07aa                	slli	a5,a5,0xa
ffffffffc0201b14:	8cdd                	or	s1,s1,a5
ffffffffc0201b16:	0014e493          	ori	s1,s1,1
            // 如果存在的映射关系对应的页面与要插入映射的页面不同，说明需要替换原来的映射关系，先调用page_remove_pte函数释放原来的页面并清理对应的页表项
            page_remove_pte(pgdir, la, ptep);
        }
    }
    // 根据要插入映射的页面的页号（通过page2ppn获取）以及设置有效位（PTE_V）和传入的权限参数（perm）构造新的页表项值，并赋值给对应的页表项指针指向的位置，完成页面到线性地址的映射关系建立，并设置相应的权限
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0201b1a:	0099b023          	sd	s1,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201b1e:	12000073          	sfence.vma
    // 调用tlb_invalidate函数使与该线性地址相关的TLB项无效，确保处理器后续进行地址转换时使用最新的映射关系缓存数据
    tlb_invalidate(pgdir, la);
    return 0;
ffffffffc0201b22:	4501                	li	a0,0
}
ffffffffc0201b24:	70a2                	ld	ra,40(sp)
ffffffffc0201b26:	7402                	ld	s0,32(sp)
ffffffffc0201b28:	64e2                	ld	s1,24(sp)
ffffffffc0201b2a:	6942                	ld	s2,16(sp)
ffffffffc0201b2c:	69a2                	ld	s3,8(sp)
ffffffffc0201b2e:	6a02                	ld	s4,0(sp)
ffffffffc0201b30:	6145                	addi	sp,sp,48
ffffffffc0201b32:	8082                	ret
    return pa2page(PTE_ADDR(pte));
ffffffffc0201b34:	00279713          	slli	a4,a5,0x2
ffffffffc0201b38:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201b3a:	00010797          	auipc	a5,0x10
ffffffffc0201b3e:	9e67b783          	ld	a5,-1562(a5) # ffffffffc0211520 <npage>
ffffffffc0201b42:	06f77e63          	bgeu	a4,a5,ffffffffc0201bbe <page_insert+0xfc>
    return &pages[PPN(pa) - nbase];
ffffffffc0201b46:	fff807b7          	lui	a5,0xfff80
ffffffffc0201b4a:	973e                	add	a4,a4,a5
ffffffffc0201b4c:	00010a17          	auipc	s4,0x10
ffffffffc0201b50:	9dca0a13          	addi	s4,s4,-1572 # ffffffffc0211528 <pages>
ffffffffc0201b54:	000a3783          	ld	a5,0(s4)
ffffffffc0201b58:	00371913          	slli	s2,a4,0x3
ffffffffc0201b5c:	993a                	add	s2,s2,a4
ffffffffc0201b5e:	090e                	slli	s2,s2,0x3
ffffffffc0201b60:	993e                	add	s2,s2,a5
        if (p == page) {
ffffffffc0201b62:	03240063          	beq	s0,s2,ffffffffc0201b82 <page_insert+0xc0>
    page->ref -= 1;
ffffffffc0201b66:	00092783          	lw	a5,0(s2)
ffffffffc0201b6a:	fff7871b          	addiw	a4,a5,-1
ffffffffc0201b6e:	00e92023          	sw	a4,0(s2)
        if (page_ref(page) == 0) {  
ffffffffc0201b72:	cb11                	beqz	a4,ffffffffc0201b86 <page_insert+0xc4>
        *ptep = 0;  
ffffffffc0201b74:	0009b023          	sd	zero,0(s3)
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc0201b78:	12000073          	sfence.vma
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201b7c:	000a3783          	ld	a5,0(s4)
}
ffffffffc0201b80:	bfad                	j	ffffffffc0201afa <page_insert+0x38>
    page->ref -= 1;
ffffffffc0201b82:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc0201b84:	bf9d                	j	ffffffffc0201afa <page_insert+0x38>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b86:	100027f3          	csrr	a5,sstatus
ffffffffc0201b8a:	8b89                	andi	a5,a5,2
ffffffffc0201b8c:	eb91                	bnez	a5,ffffffffc0201ba0 <page_insert+0xde>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201b8e:	00010797          	auipc	a5,0x10
ffffffffc0201b92:	9a27b783          	ld	a5,-1630(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0201b96:	739c                	ld	a5,32(a5)
ffffffffc0201b98:	4585                	li	a1,1
ffffffffc0201b9a:	854a                	mv	a0,s2
ffffffffc0201b9c:	9782                	jalr	a5
    if (flag) {
ffffffffc0201b9e:	bfd9                	j	ffffffffc0201b74 <page_insert+0xb2>
        intr_disable();
ffffffffc0201ba0:	94ffe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0201ba4:	00010797          	auipc	a5,0x10
ffffffffc0201ba8:	98c7b783          	ld	a5,-1652(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0201bac:	739c                	ld	a5,32(a5)
ffffffffc0201bae:	4585                	li	a1,1
ffffffffc0201bb0:	854a                	mv	a0,s2
ffffffffc0201bb2:	9782                	jalr	a5
        intr_enable();
ffffffffc0201bb4:	935fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0201bb8:	bf75                	j	ffffffffc0201b74 <page_insert+0xb2>
        return -E_NO_MEM;
ffffffffc0201bba:	5571                	li	a0,-4
ffffffffc0201bbc:	b7a5                	j	ffffffffc0201b24 <page_insert+0x62>
ffffffffc0201bbe:	ad7ff0ef          	jal	ra,ffffffffc0201694 <pa2page.part.0>

ffffffffc0201bc2 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201bc2:	00003797          	auipc	a5,0x3
ffffffffc0201bc6:	68e78793          	addi	a5,a5,1678 # ffffffffc0205250 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201bca:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0201bcc:	7159                	addi	sp,sp,-112
ffffffffc0201bce:	f45e                	sd	s7,40(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201bd0:	00003517          	auipc	a0,0x3
ffffffffc0201bd4:	76050513          	addi	a0,a0,1888 # ffffffffc0205330 <default_pmm_manager+0xe0>
    pmm_manager = &default_pmm_manager;
ffffffffc0201bd8:	00010b97          	auipc	s7,0x10
ffffffffc0201bdc:	958b8b93          	addi	s7,s7,-1704 # ffffffffc0211530 <pmm_manager>
void pmm_init(void) {
ffffffffc0201be0:	f486                	sd	ra,104(sp)
ffffffffc0201be2:	f0a2                	sd	s0,96(sp)
ffffffffc0201be4:	eca6                	sd	s1,88(sp)
ffffffffc0201be6:	e8ca                	sd	s2,80(sp)
ffffffffc0201be8:	e4ce                	sd	s3,72(sp)
ffffffffc0201bea:	f85a                	sd	s6,48(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201bec:	00fbb023          	sd	a5,0(s7)
void pmm_init(void) {
ffffffffc0201bf0:	e0d2                	sd	s4,64(sp)
ffffffffc0201bf2:	fc56                	sd	s5,56(sp)
ffffffffc0201bf4:	f062                	sd	s8,32(sp)
ffffffffc0201bf6:	ec66                	sd	s9,24(sp)
ffffffffc0201bf8:	e86a                	sd	s10,16(sp)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201bfa:	cc0fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pmm_manager->init();
ffffffffc0201bfe:	000bb783          	ld	a5,0(s7)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201c02:	4445                	li	s0,17
ffffffffc0201c04:	40100913          	li	s2,1025
    pmm_manager->init();
ffffffffc0201c08:	679c                	ld	a5,8(a5)
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201c0a:	00010997          	auipc	s3,0x10
ffffffffc0201c0e:	92e98993          	addi	s3,s3,-1746 # ffffffffc0211538 <va_pa_offset>
    npage = maxpa / PGSIZE;
ffffffffc0201c12:	00010497          	auipc	s1,0x10
ffffffffc0201c16:	90e48493          	addi	s1,s1,-1778 # ffffffffc0211520 <npage>
    pmm_manager->init();
ffffffffc0201c1a:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201c1c:	57f5                	li	a5,-3
ffffffffc0201c1e:	07fa                	slli	a5,a5,0x1e
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201c20:	07e006b7          	lui	a3,0x7e00
ffffffffc0201c24:	01b41613          	slli	a2,s0,0x1b
ffffffffc0201c28:	01591593          	slli	a1,s2,0x15
ffffffffc0201c2c:	00003517          	auipc	a0,0x3
ffffffffc0201c30:	71c50513          	addi	a0,a0,1820 # ffffffffc0205348 <default_pmm_manager+0xf8>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc0201c34:	00f9b023          	sd	a5,0(s3)
    cprintf("membegin %llx memend %llx mem_size %llx\n",mem_begin, mem_end, mem_size);
ffffffffc0201c38:	c82fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("physcial memory map:\n");
ffffffffc0201c3c:	00003517          	auipc	a0,0x3
ffffffffc0201c40:	73c50513          	addi	a0,a0,1852 # ffffffffc0205378 <default_pmm_manager+0x128>
ffffffffc0201c44:	c76fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0201c48:	01b41693          	slli	a3,s0,0x1b
ffffffffc0201c4c:	16fd                	addi	a3,a3,-1
ffffffffc0201c4e:	07e005b7          	lui	a1,0x7e00
ffffffffc0201c52:	01591613          	slli	a2,s2,0x15
ffffffffc0201c56:	00003517          	auipc	a0,0x3
ffffffffc0201c5a:	73a50513          	addi	a0,a0,1850 # ffffffffc0205390 <default_pmm_manager+0x140>
ffffffffc0201c5e:	c5cfe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201c62:	777d                	lui	a4,0xfffff
ffffffffc0201c64:	00011797          	auipc	a5,0x11
ffffffffc0201c68:	90778793          	addi	a5,a5,-1785 # ffffffffc021256b <end+0xfff>
ffffffffc0201c6c:	8ff9                	and	a5,a5,a4
ffffffffc0201c6e:	00010b17          	auipc	s6,0x10
ffffffffc0201c72:	8bab0b13          	addi	s6,s6,-1862 # ffffffffc0211528 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201c76:	00088737          	lui	a4,0x88
ffffffffc0201c7a:	e098                	sd	a4,0(s1)
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201c7c:	00fb3023          	sd	a5,0(s6)
ffffffffc0201c80:	4681                	li	a3,0
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201c82:	4701                	li	a4,0
ffffffffc0201c84:	4505                	li	a0,1
ffffffffc0201c86:	fff805b7          	lui	a1,0xfff80
ffffffffc0201c8a:	a019                	j	ffffffffc0201c90 <pmm_init+0xce>
        SetPageReserved(pages + i);
ffffffffc0201c8c:	000b3783          	ld	a5,0(s6)
ffffffffc0201c90:	97b6                	add	a5,a5,a3
ffffffffc0201c92:	07a1                	addi	a5,a5,8
ffffffffc0201c94:	40a7b02f          	amoor.d	zero,a0,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201c98:	609c                	ld	a5,0(s1)
ffffffffc0201c9a:	0705                	addi	a4,a4,1
ffffffffc0201c9c:	04868693          	addi	a3,a3,72 # 7e00048 <kern_entry-0xffffffffb83fffb8>
ffffffffc0201ca0:	00b78633          	add	a2,a5,a1
ffffffffc0201ca4:	fec764e3          	bltu	a4,a2,ffffffffc0201c8c <pmm_init+0xca>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201ca8:	000b3503          	ld	a0,0(s6)
ffffffffc0201cac:	00379693          	slli	a3,a5,0x3
ffffffffc0201cb0:	96be                	add	a3,a3,a5
ffffffffc0201cb2:	fdc00737          	lui	a4,0xfdc00
ffffffffc0201cb6:	972a                	add	a4,a4,a0
ffffffffc0201cb8:	068e                	slli	a3,a3,0x3
ffffffffc0201cba:	96ba                	add	a3,a3,a4
ffffffffc0201cbc:	c0200737          	lui	a4,0xc0200
ffffffffc0201cc0:	64e6e463          	bltu	a3,a4,ffffffffc0202308 <pmm_init+0x746>
ffffffffc0201cc4:	0009b703          	ld	a4,0(s3)
    if (freemem < mem_end) {
ffffffffc0201cc8:	4645                	li	a2,17
ffffffffc0201cca:	066e                	slli	a2,a2,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201ccc:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc0201cce:	4ec6e263          	bltu	a3,a2,ffffffffc02021b2 <pmm_init+0x5f0>

// check_alloc_page函数用于检查物理内存分配功能的正确性。
// 它通过调用物理内存管理实例（pmm_manager）的check函数来进行具体的检查操作，
// 然后输出提示信息表示检查成功，意味着内存分配相关的函数和机制按预期工作，没有出现明显错误。
static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201cd2:	000bb783          	ld	a5,0(s7)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201cd6:	00010917          	auipc	s2,0x10
ffffffffc0201cda:	84290913          	addi	s2,s2,-1982 # ffffffffc0211518 <boot_pgdir>
    pmm_manager->check();
ffffffffc0201cde:	7b9c                	ld	a5,48(a5)
ffffffffc0201ce0:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201ce2:	00003517          	auipc	a0,0x3
ffffffffc0201ce6:	6fe50513          	addi	a0,a0,1790 # ffffffffc02053e0 <default_pmm_manager+0x190>
ffffffffc0201cea:	bd0fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0201cee:	00007697          	auipc	a3,0x7
ffffffffc0201cf2:	31268693          	addi	a3,a3,786 # ffffffffc0209000 <boot_page_table_sv39>
ffffffffc0201cf6:	00d93023          	sd	a3,0(s2)
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0201cfa:	c02007b7          	lui	a5,0xc0200
ffffffffc0201cfe:	62f6e163          	bltu	a3,a5,ffffffffc0202320 <pmm_init+0x75e>
ffffffffc0201d02:	0009b783          	ld	a5,0(s3)
ffffffffc0201d06:	8e9d                	sub	a3,a3,a5
ffffffffc0201d08:	00010797          	auipc	a5,0x10
ffffffffc0201d0c:	80d7b423          	sd	a3,-2040(a5) # ffffffffc0211510 <boot_cr3>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d10:	100027f3          	csrr	a5,sstatus
ffffffffc0201d14:	8b89                	andi	a5,a5,2
ffffffffc0201d16:	4c079763          	bnez	a5,ffffffffc02021e4 <pmm_init+0x622>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201d1a:	000bb783          	ld	a5,0(s7)
ffffffffc0201d1e:	779c                	ld	a5,40(a5)
ffffffffc0201d20:	9782                	jalr	a5
ffffffffc0201d22:	842a                	mv	s0,a0
    size_t nr_free_store;
    nr_free_store = nr_free_pages();

    // 断言检查系统总的页面数量（npage）不超过内核内存顶部地址（KERNTOP）对应的页面数量（通过除以页面大小PGSIZE得到页面数量），
    // 确保内存管理中涉及的页面范围没有超出合理界限，避免出现越界等错误情况。
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0201d24:	6098                	ld	a4,0(s1)
ffffffffc0201d26:	c80007b7          	lui	a5,0xc8000
ffffffffc0201d2a:	83b1                	srli	a5,a5,0xc
ffffffffc0201d2c:	62e7e663          	bltu	a5,a4,ffffffffc0202358 <pmm_init+0x796>
    // 断言检查启动时的页目录（boot_pgdir）不为NULL，并且其在页面内的偏移量（通过PGOFF宏获取）为0，
    // 即确保页目录的地址是按页面大小对齐的，符合内存管理中对地址对齐的要求。
    assert(boot_pgdir!= NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0201d30:	00093503          	ld	a0,0(s2)
ffffffffc0201d34:	60050263          	beqz	a0,ffffffffc0202338 <pmm_init+0x776>
ffffffffc0201d38:	03451793          	slli	a5,a0,0x34
ffffffffc0201d3c:	5e079e63          	bnez	a5,ffffffffc0202338 <pmm_init+0x776>
    // 断言检查通过页目录（boot_pgdir）获取线性地址为0x0对应的页面结构体指针应该为NULL，
    // 因为初始情况下可能该地址并没有映射有效的页面，用于检查获取页面操作的初始正确性。
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0201d40:	4601                	li	a2,0
ffffffffc0201d42:	4581                	li	a1,0
ffffffffc0201d44:	c8bff0ef          	jal	ra,ffffffffc02019ce <get_page>
ffffffffc0201d48:	66051a63          	bnez	a0,ffffffffc02023bc <pmm_init+0x7fa>

    // 分配一个页面，通过调用alloc_page函数获取页面结构体指针，并将其存储在p1变量中，用于后续一系列关于页面插入、引用计数等操作的测试。
    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0201d4c:	4505                	li	a0,1
ffffffffc0201d4e:	97fff0ef          	jal	ra,ffffffffc02016cc <alloc_pages>
ffffffffc0201d52:	8a2a                	mv	s4,a0
    // 调用page_insert函数尝试将刚才分配的p1页面插入到页目录（boot_pgdir）中，对应线性地址为0x0，权限设置为0（具体权限含义需看相关定义，可能表示无特定权限），
    // 断言检查插入操作返回值为0，表示插入成功。
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0201d54:	00093503          	ld	a0,0(s2)
ffffffffc0201d58:	4681                	li	a3,0
ffffffffc0201d5a:	4601                	li	a2,0
ffffffffc0201d5c:	85d2                	mv	a1,s4
ffffffffc0201d5e:	d65ff0ef          	jal	ra,ffffffffc0201ac2 <page_insert>
ffffffffc0201d62:	62051d63          	bnez	a0,ffffffffc020239c <pmm_init+0x7da>
    // 调用get_pte函数获取对应线性地址0x0的页表项（PTE）指针，存储在ptep变量中，
    // 断言检查获取到的页表项指针不为NULL，确保能正确获取到页表项。
    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0))!= NULL);
ffffffffc0201d66:	00093503          	ld	a0,0(s2)
ffffffffc0201d6a:	4601                	li	a2,0
ffffffffc0201d6c:	4581                	li	a1,0
ffffffffc0201d6e:	a6bff0ef          	jal	ra,ffffffffc02017d8 <get_pte>
ffffffffc0201d72:	60050563          	beqz	a0,ffffffffc020237c <pmm_init+0x7ba>
    // 调用pte2page函数根据获取到的页表项指针获取对应的页面结构体指针，断言检查得到的页面结构体指针与之前分配的p1页面指针相同，
    // 验证通过页表项获取页面的操作正确性以及页面插入后映射关系的准确性。
    assert(pte2page(*ptep) == p1);
ffffffffc0201d76:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201d78:	0017f713          	andi	a4,a5,1
ffffffffc0201d7c:	5e070e63          	beqz	a4,ffffffffc0202378 <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc0201d80:	6090                	ld	a2,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201d82:	078a                	slli	a5,a5,0x2
ffffffffc0201d84:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201d86:	56c7ff63          	bgeu	a5,a2,ffffffffc0202304 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d8a:	fff80737          	lui	a4,0xfff80
ffffffffc0201d8e:	97ba                	add	a5,a5,a4
ffffffffc0201d90:	000b3683          	ld	a3,0(s6)
ffffffffc0201d94:	00379713          	slli	a4,a5,0x3
ffffffffc0201d98:	97ba                	add	a5,a5,a4
ffffffffc0201d9a:	078e                	slli	a5,a5,0x3
ffffffffc0201d9c:	97b6                	add	a5,a5,a3
ffffffffc0201d9e:	14fa18e3          	bne	s4,a5,ffffffffc02026ee <pmm_init+0xb2c>
    // 断言检查p1页面的引用计数为1，因为刚插入到页目录的映射关系中，理论上只有这一处引用，确保引用计数符合预期。
    assert(page_ref(p1) == 1);
ffffffffc0201da2:	000a2703          	lw	a4,0(s4)
ffffffffc0201da6:	4785                	li	a5,1
ffffffffc0201da8:	16f71fe3          	bne	a4,a5,ffffffffc0202726 <pmm_init+0xb64>

    // 通过一系列地址转换和页表项获取操作，找到对应页面大小（PGSIZE）偏移后的线性地址（即地址为PGSIZE处）对应的页表项指针，
    // 具体操作涉及先通过KADDR、PDE_ADDR等宏进行地址转换和页表项索引计算，这里得到的ptep指针应该指向预期的页表项位置，用于后续验证。
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0201dac:	00093503          	ld	a0,0(s2)
ffffffffc0201db0:	77fd                	lui	a5,0xfffff
ffffffffc0201db2:	6114                	ld	a3,0(a0)
ffffffffc0201db4:	068a                	slli	a3,a3,0x2
ffffffffc0201db6:	8efd                	and	a3,a3,a5
ffffffffc0201db8:	00c6d713          	srli	a4,a3,0xc
ffffffffc0201dbc:	14c779e3          	bgeu	a4,a2,ffffffffc020270e <pmm_init+0xb4c>
ffffffffc0201dc0:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201dc4:	96e2                	add	a3,a3,s8
ffffffffc0201dc6:	0006ba83          	ld	s5,0(a3)
ffffffffc0201dca:	0a8a                	slli	s5,s5,0x2
ffffffffc0201dcc:	00fafab3          	and	s5,s5,a5
ffffffffc0201dd0:	00cad793          	srli	a5,s5,0xc
ffffffffc0201dd4:	66c7f463          	bgeu	a5,a2,ffffffffc020243c <pmm_init+0x87a>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201dd8:	4601                	li	a2,0
ffffffffc0201dda:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201ddc:	9ae2                	add	s5,s5,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201dde:	9fbff0ef          	jal	ra,ffffffffc02017d8 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0201de2:	0aa1                	addi	s5,s5,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0201de4:	63551c63          	bne	a0,s5,ffffffffc020241c <pmm_init+0x85a>

    // 再分配一个页面，将其指针存储在p2变量中，同样用于后续测试页面插入、权限验证等操作。
    p2 = alloc_page();
ffffffffc0201de8:	4505                	li	a0,1
ffffffffc0201dea:	8e3ff0ef          	jal	ra,ffffffffc02016cc <alloc_pages>
ffffffffc0201dee:	8aaa                	mv	s5,a0
    // 调用page_insert函数将p2页面插入到页目录（boot_pgdir）中，对应线性地址为PGSIZE，权限设置为用户可访问（PTE_U）和可写（PTE_W），
    // 断言检查插入操作返回值为0，表示插入成功。
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0201df0:	00093503          	ld	a0,0(s2)
ffffffffc0201df4:	46d1                	li	a3,20
ffffffffc0201df6:	6605                	lui	a2,0x1
ffffffffc0201df8:	85d6                	mv	a1,s5
ffffffffc0201dfa:	cc9ff0ef          	jal	ra,ffffffffc0201ac2 <page_insert>
ffffffffc0201dfe:	5c051f63          	bnez	a0,ffffffffc02023dc <pmm_init+0x81a>
    // 再次获取对应线性地址PGSIZE的页表项指针，断言检查获取到的页表项指针不为NULL，确保能正确获取到页表项。
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0))!= NULL);
ffffffffc0201e02:	00093503          	ld	a0,0(s2)
ffffffffc0201e06:	4601                	li	a2,0
ffffffffc0201e08:	6585                	lui	a1,0x1
ffffffffc0201e0a:	9cfff0ef          	jal	ra,ffffffffc02017d8 <get_pte>
ffffffffc0201e0e:	12050ce3          	beqz	a0,ffffffffc0202746 <pmm_init+0xb84>
    // 断言检查获取到的页表项设置了用户可访问位（PTE_U），验证权限设置是否正确。
    assert(*ptep & PTE_U);
ffffffffc0201e12:	611c                	ld	a5,0(a0)
ffffffffc0201e14:	0107f713          	andi	a4,a5,16
ffffffffc0201e18:	72070f63          	beqz	a4,ffffffffc0202556 <pmm_init+0x994>
    // 断言检查获取到的页表项设置了可写位（PTE_W），进一步验证权限设置的正确性。
    assert(*ptep & PTE_W);
ffffffffc0201e1c:	8b91                	andi	a5,a5,4
ffffffffc0201e1e:	6e078c63          	beqz	a5,ffffffffc0202516 <pmm_init+0x954>
    // 断言检查页目录（boot_pgdir）的第一个页目录项（boot_pgdir[0]）设置了用户可访问位（PTE_U），确保页目录相关权限设置符合预期。
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0201e22:	00093503          	ld	a0,0(s2)
ffffffffc0201e26:	611c                	ld	a5,0(a0)
ffffffffc0201e28:	8bc1                	andi	a5,a5,16
ffffffffc0201e2a:	6c078663          	beqz	a5,ffffffffc02024f6 <pmm_init+0x934>
    // 断言检查p2页面的引用计数为1，因为刚插入到页目录的映射关系中，理论上只有这一处引用，确保引用计数符合预期。
    assert(page_ref(p2) == 1);
ffffffffc0201e2e:	000aa703          	lw	a4,0(s5)
ffffffffc0201e32:	4785                	li	a5,1
ffffffffc0201e34:	5cf71463          	bne	a4,a5,ffffffffc02023fc <pmm_init+0x83a>

    // 再次调用page_insert函数尝试将p1页面插入到页目录（boot_pgdir）中，对应线性地址为PGSIZE，权限设置为0，
    // 断言检查插入操作返回值为0，表示插入成功，这里可能模拟了页面重新映射等情况的测试。
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0201e38:	4681                	li	a3,0
ffffffffc0201e3a:	6605                	lui	a2,0x1
ffffffffc0201e3c:	85d2                	mv	a1,s4
ffffffffc0201e3e:	c85ff0ef          	jal	ra,ffffffffc0201ac2 <page_insert>
ffffffffc0201e42:	66051a63          	bnez	a0,ffffffffc02024b6 <pmm_init+0x8f4>
    // 断言检查p1页面的引用计数变为2，因为现在有两处映射关系引用了该页面（之前在地址0x0和现在又在地址PGSIZE处插入了映射），确保引用计数更新正确。
    assert(page_ref(p1) == 2);
ffffffffc0201e46:	000a2703          	lw	a4,0(s4)
ffffffffc0201e4a:	4789                	li	a5,2
ffffffffc0201e4c:	64f71563          	bne	a4,a5,ffffffffc0202496 <pmm_init+0x8d4>
    // 断言检查p2页面的引用计数变为0，因为刚才将相同线性地址（PGSIZE）的映射替换为了p1页面，p2页面不再被该映射引用，确保引用计数更新正确。
    assert(page_ref(p2) == 0);
ffffffffc0201e50:	000aa783          	lw	a5,0(s5)
ffffffffc0201e54:	62079163          	bnez	a5,ffffffffc0202476 <pmm_init+0x8b4>
    // 再次获取对应线性地址PGSIZE的页表项指针，断言检查获取到的页表项指针不为NULL，确保能正确获取到页表项。
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0))!= NULL);
ffffffffc0201e58:	00093503          	ld	a0,0(s2)
ffffffffc0201e5c:	4601                	li	a2,0
ffffffffc0201e5e:	6585                	lui	a1,0x1
ffffffffc0201e60:	979ff0ef          	jal	ra,ffffffffc02017d8 <get_pte>
ffffffffc0201e64:	5e050963          	beqz	a0,ffffffffc0202456 <pmm_init+0x894>
    // 调用pte2page函数根据获取到的页表项指针获取对应的页面结构体指针，断言检查得到的页面结构体指针与p1页面指针相同，
    // 验证重新映射后通过页表项获取页面的操作正确性以及页面替换后的映射关系准确性。
    assert(pte2page(*ptep) == p1);
ffffffffc0201e68:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0201e6a:	00177793          	andi	a5,a4,1
ffffffffc0201e6e:	50078563          	beqz	a5,ffffffffc0202378 <pmm_init+0x7b6>
    if (PPN(pa) >= npage) {
ffffffffc0201e72:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0201e74:	00271793          	slli	a5,a4,0x2
ffffffffc0201e78:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201e7a:	48d7f563          	bgeu	a5,a3,ffffffffc0202304 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e7e:	fff806b7          	lui	a3,0xfff80
ffffffffc0201e82:	97b6                	add	a5,a5,a3
ffffffffc0201e84:	000b3603          	ld	a2,0(s6)
ffffffffc0201e88:	00379693          	slli	a3,a5,0x3
ffffffffc0201e8c:	97b6                	add	a5,a5,a3
ffffffffc0201e8e:	078e                	slli	a5,a5,0x3
ffffffffc0201e90:	97b2                	add	a5,a5,a2
ffffffffc0201e92:	72fa1263          	bne	s4,a5,ffffffffc02025b6 <pmm_init+0x9f4>
    // 断言检查获取到的页表项没有设置用户可访问位（PTE_U），验证权限设置是否按照预期在重新映射时被正确更新。
    assert((*ptep & PTE_U) == 0);
ffffffffc0201e96:	8b41                	andi	a4,a4,16
ffffffffc0201e98:	6e071f63          	bnez	a4,ffffffffc0202596 <pmm_init+0x9d4>

    // 调用page_remove函数移除页目录（boot_pgdir）中对应线性地址0x0的页面映射关系，用于测试页面释放和引用计数更新等操作。
    page_remove(boot_pgdir, 0x0);
ffffffffc0201e9c:	00093503          	ld	a0,0(s2)
ffffffffc0201ea0:	4581                	li	a1,0
ffffffffc0201ea2:	b87ff0ef          	jal	ra,ffffffffc0201a28 <page_remove>
    // 断言检查p1页面的引用计数变为1，因为刚才移除了一处对该页面的映射引用，确保引用计数更新正确。
    assert(page_ref(p1) == 1);
ffffffffc0201ea6:	000a2703          	lw	a4,0(s4)
ffffffffc0201eaa:	4785                	li	a5,1
ffffffffc0201eac:	6cf71563          	bne	a4,a5,ffffffffc0202576 <pmm_init+0x9b4>
    // 断言检查p2页面的引用计数依然为0，确保其引用计数没有受到影响，符合预期情况。
    assert(page_ref(p2) == 0);
ffffffffc0201eb0:	000aa783          	lw	a5,0(s5)
ffffffffc0201eb4:	78079d63          	bnez	a5,ffffffffc020264e <pmm_init+0xa8c>

    // 调用page_remove函数移除页目录（boot_pgdir）中对应线性地址PGSIZE的页面映射关系，进一步测试页面释放和引用计数更新等操作。
    page_remove(boot_pgdir, PGSIZE);
ffffffffc0201eb8:	00093503          	ld	a0,0(s2)
ffffffffc0201ebc:	6585                	lui	a1,0x1
ffffffffc0201ebe:	b6bff0ef          	jal	ra,ffffffffc0201a28 <page_remove>
    // 断言检查p1页面的引用计数变为0，因为现在所有对该页面的映射引用都被移除了，确保引用计数更新正确，并且此时该页面应该可以被释放了。
    assert(page_ref(p1) == 0);
ffffffffc0201ec2:	000a2783          	lw	a5,0(s4)
ffffffffc0201ec6:	76079463          	bnez	a5,ffffffffc020262e <pmm_init+0xa6c>
    // 断言检查p2页面的引用计数依然为0，确保其引用计数没有受到影响，符合预期情况。
    assert(page_ref(p2) == 0);
ffffffffc0201eca:	000aa783          	lw	a5,0(s5)
ffffffffc0201ece:	74079063          	bnez	a5,ffffffffc020260e <pmm_init+0xa4c>

    // 断言检查通过页目录（boot_pgdir）的第一个页目录项（boot_pgdir[0]）获取到的页面（通过pde2page函数）的引用计数为1，
    // 这里应该是检查页目录项对应的页面引用情况是否符合预期，确保没有出现意外的引用计数错误。
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0201ed2:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0201ed6:	6090                	ld	a2,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201ed8:	000a3783          	ld	a5,0(s4)
ffffffffc0201edc:	078a                	slli	a5,a5,0x2
ffffffffc0201ede:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201ee0:	42c7f263          	bgeu	a5,a2,ffffffffc0202304 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201ee4:	fff80737          	lui	a4,0xfff80
ffffffffc0201ee8:	973e                	add	a4,a4,a5
ffffffffc0201eea:	00371793          	slli	a5,a4,0x3
ffffffffc0201eee:	000b3503          	ld	a0,0(s6)
ffffffffc0201ef2:	97ba                	add	a5,a5,a4
ffffffffc0201ef4:	078e                	slli	a5,a5,0x3
static inline int page_ref(struct Page *page) { return page->ref; }
ffffffffc0201ef6:	00f50733          	add	a4,a0,a5
ffffffffc0201efa:	4314                	lw	a3,0(a4)
ffffffffc0201efc:	4705                	li	a4,1
ffffffffc0201efe:	6ee69863          	bne	a3,a4,ffffffffc02025ee <pmm_init+0xa2c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0201f02:	4037d693          	srai	a3,a5,0x3
ffffffffc0201f06:	00004c97          	auipc	s9,0x4
ffffffffc0201f0a:	432cbc83          	ld	s9,1074(s9) # ffffffffc0206338 <error_string+0x38>
ffffffffc0201f0e:	039686b3          	mul	a3,a3,s9
ffffffffc0201f12:	000805b7          	lui	a1,0x80
ffffffffc0201f16:	96ae                	add	a3,a3,a1
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f18:	00c69713          	slli	a4,a3,0xc
ffffffffc0201f1c:	8331                	srli	a4,a4,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201f1e:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0201f20:	6ac77b63          	bgeu	a4,a2,ffffffffc02025d6 <pmm_init+0xa14>

    // 获取页目录（boot_pgdir）的指针以及通过页目录项（boot_pgdir[0]）获取对应的页表所在页面的内核虚拟地址对应的指针，分别存储在pd1和pd0变量中，
    // 用于后续释放相关页面的操作，这里涉及到多层地址转换和页表、页目录结构的操作。
    pde_t *pd1 = boot_pgdir, *pd0 = page2kva(pde2page(boot_pgdir[0]));
    // 调用free_page函数释放通过pd0指向的页表所在页面，进行内存回收操作。
    free_page(pde2page(pd0[0]));
ffffffffc0201f24:	0009b703          	ld	a4,0(s3)
ffffffffc0201f28:	96ba                	add	a3,a3,a4
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f2a:	629c                	ld	a5,0(a3)
ffffffffc0201f2c:	078a                	slli	a5,a5,0x2
ffffffffc0201f2e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f30:	3cc7fa63          	bgeu	a5,a2,ffffffffc0202304 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f34:	8f8d                	sub	a5,a5,a1
ffffffffc0201f36:	00379713          	slli	a4,a5,0x3
ffffffffc0201f3a:	97ba                	add	a5,a5,a4
ffffffffc0201f3c:	078e                	slli	a5,a5,0x3
ffffffffc0201f3e:	953e                	add	a0,a0,a5
ffffffffc0201f40:	100027f3          	csrr	a5,sstatus
ffffffffc0201f44:	8b89                	andi	a5,a5,2
ffffffffc0201f46:	2e079963          	bnez	a5,ffffffffc0202238 <pmm_init+0x676>
    { pmm_manager->free_pages(base, n); }
ffffffffc0201f4a:	000bb783          	ld	a5,0(s7)
ffffffffc0201f4e:	4585                	li	a1,1
ffffffffc0201f50:	739c                	ld	a5,32(a5)
ffffffffc0201f52:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f54:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc0201f58:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0201f5a:	078a                	slli	a5,a5,0x2
ffffffffc0201f5c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0201f5e:	3ae7f363          	bgeu	a5,a4,ffffffffc0202304 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0201f62:	fff80737          	lui	a4,0xfff80
ffffffffc0201f66:	97ba                	add	a5,a5,a4
ffffffffc0201f68:	000b3503          	ld	a0,0(s6)
ffffffffc0201f6c:	00379713          	slli	a4,a5,0x3
ffffffffc0201f70:	97ba                	add	a5,a5,a4
ffffffffc0201f72:	078e                	slli	a5,a5,0x3
ffffffffc0201f74:	953e                	add	a0,a0,a5
ffffffffc0201f76:	100027f3          	csrr	a5,sstatus
ffffffffc0201f7a:	8b89                	andi	a5,a5,2
ffffffffc0201f7c:	2a079263          	bnez	a5,ffffffffc0202220 <pmm_init+0x65e>
ffffffffc0201f80:	000bb783          	ld	a5,0(s7)
ffffffffc0201f84:	4585                	li	a1,1
ffffffffc0201f86:	739c                	ld	a5,32(a5)
ffffffffc0201f88:	9782                	jalr	a5
    // 调用free_page函数释放通过pd1指向的页目录所在页面，进行内存回收操作，这里假设页目录所在页面也是可以动态分配和释放的情况（具体依实现而定）。
    free_page(pde2page(pd1[0]));
    // 将页目录（boot_pgdir）的第一个页目录项清零，解除其对应的映射关系（如果有的话），重置页目录的初始状态。
    boot_pgdir[0] = 0;
ffffffffc0201f8a:	00093783          	ld	a5,0(s2)
ffffffffc0201f8e:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fdeda94>
ffffffffc0201f92:	100027f3          	csrr	a5,sstatus
ffffffffc0201f96:	8b89                	andi	a5,a5,2
ffffffffc0201f98:	26079a63          	bnez	a5,ffffffffc020220c <pmm_init+0x64a>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201f9c:	000bb783          	ld	a5,0(s7)
ffffffffc0201fa0:	779c                	ld	a5,40(a5)
ffffffffc0201fa2:	9782                	jalr	a5
ffffffffc0201fa4:	8a2a                	mv	s4,a0

    // 断言检查当前空闲页面数量（通过再次调用nr_free_pages函数获取）与之前记录的空闲页面数量（nr_free_store）相等，
    // 验证经过一系列页面分配、插入、移除和释放操作后，空闲页面数量统计是否正确，确保内存管理对空闲页面数量的维护准确无误。
    assert(nr_free_store == nr_free_pages());
ffffffffc0201fa6:	73441463          	bne	s0,s4,ffffffffc02026ce <pmm_init+0xb0c>

    // 输出提示信息，表示对页目录相关检查成功，意味着页目录及其涉及的页面映射等操作在上述各种测试情况下都按预期工作，没有出现明显错误。
    cprintf("check_pgdir() succeeded!\n");
ffffffffc0201faa:	00003517          	auipc	a0,0x3
ffffffffc0201fae:	72650513          	addi	a0,a0,1830 # ffffffffc02056d0 <default_pmm_manager+0x480>
ffffffffc0201fb2:	908fe0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0201fb6:	100027f3          	csrr	a5,sstatus
ffffffffc0201fba:	8b89                	andi	a5,a5,2
ffffffffc0201fbc:	22079e63          	bnez	a5,ffffffffc02021f8 <pmm_init+0x636>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0201fc0:	000bb783          	ld	a5,0(s7)
ffffffffc0201fc4:	779c                	ld	a5,40(a5)
ffffffffc0201fc6:	9782                	jalr	a5
ffffffffc0201fc8:	8c2a                	mv	s8,a0
    // 后续在执行一系列与页面操作相关的测试后，可以通过对比这个值来检查操作过程中是否存在空闲页面数量统计错误等问题。
    nr_free_store = nr_free_pages();

    // 以下循环遍历从内核虚拟地址基址（KERNBASE）开始，按照页面大小（PGSIZE）为步长，一直到系统总的页面数量（npage）所对应的内存范围。
    // 目的是检查在这个范围内的每个页面大小的线性地址对应的页表项是否能正确获取，以及页表项中的地址信息是否与当前线性地址匹配，以此验证页目录中映射关系的准确性以及整个虚拟内存映射的正确性。
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201fca:	6098                	ld	a4,0(s1)
ffffffffc0201fcc:	c0200437          	lui	s0,0xc0200
        // 对于每个线性地址，调用get_pte函数尝试获取对应的页表项（PTE）指针，传入启动时的页目录（boot_pgdir）、将线性地址转换为内核虚拟地址（通过KADDR函数）以及设置create参数为0（表示仅获取，不创建新的页表项）。
        // 然后使用断言检查获取到的页表项指针不为NULL，确保能够正确获取到对应的页表项，这意味着页目录到页表的映射关系在理论上是正确建立的。
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0))!= NULL);
        // 进一步断言检查获取到的页表项中存储的地址信息（通过PTE_ADDR宏获取，具体实现可能是提取页表项中表示地址的相关位）与当前线性地址（i）相等，
        // 这验证了页表项所记录的地址映射关系是准确的，即从线性地址能正确映射到对应的物理地址（通过页表项间接体现）。
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201fd0:	7afd                	lui	s5,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0201fd2:	00c71793          	slli	a5,a4,0xc
ffffffffc0201fd6:	6a05                	lui	s4,0x1
ffffffffc0201fd8:	02f47c63          	bgeu	s0,a5,ffffffffc0202010 <pmm_init+0x44e>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0))!= NULL);
ffffffffc0201fdc:	00c45793          	srli	a5,s0,0xc
ffffffffc0201fe0:	00093503          	ld	a0,0(s2)
ffffffffc0201fe4:	30e7f363          	bgeu	a5,a4,ffffffffc02022ea <pmm_init+0x728>
ffffffffc0201fe8:	0009b583          	ld	a1,0(s3)
ffffffffc0201fec:	4601                	li	a2,0
ffffffffc0201fee:	95a2                	add	a1,a1,s0
ffffffffc0201ff0:	fe8ff0ef          	jal	ra,ffffffffc02017d8 <get_pte>
ffffffffc0201ff4:	2c050b63          	beqz	a0,ffffffffc02022ca <pmm_init+0x708>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0201ff8:	611c                	ld	a5,0(a0)
ffffffffc0201ffa:	078a                	slli	a5,a5,0x2
ffffffffc0201ffc:	0157f7b3          	and	a5,a5,s5
ffffffffc0202000:	2a879563          	bne	a5,s0,ffffffffc02022aa <pmm_init+0x6e8>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc0202004:	6098                	ld	a4,0(s1)
ffffffffc0202006:	9452                	add	s0,s0,s4
ffffffffc0202008:	00c71793          	slli	a5,a4,0xc
ffffffffc020200c:	fcf468e3          	bltu	s0,a5,ffffffffc0201fdc <pmm_init+0x41a>
    }

    // 断言检查启动时的页目录（boot_pgdir）的第一个页目录项（boot_pgdir[0]）的值为0。
    // 这可能是基于特定的初始化要求或者当前检查阶段的预期状态进行的验证，也许表示该页目录项在当前情况下没有有效的映射或者处于默认的未设置状态等，具体含义要结合整个内存管理的初始化逻辑来理解。
    assert(boot_pgdir[0] == 0);
ffffffffc0202010:	00093783          	ld	a5,0(s2)
ffffffffc0202014:	639c                	ld	a5,0(a5)
ffffffffc0202016:	68079c63          	bnez	a5,ffffffffc02026ae <pmm_init+0xaec>

    // 分配一个页面，通过调用alloc_page函数获取页面结构体指针，并将其存储在p变量中。
    // 这个页面将用于后续测试页面插入到页目录的不同线性地址、页面引用计数以及基于映射后的内存访问等相关操作。
    struct Page *p;
    p = alloc_page();
ffffffffc020201a:	4505                	li	a0,1
ffffffffc020201c:	eb0ff0ef          	jal	ra,ffffffffc02016cc <alloc_pages>
ffffffffc0202020:	8aaa                	mv	s5,a0

    // 调用page_insert函数将刚才分配的页面（p）插入到启动时的页目录（boot_pgdir）中，对应线性地址设置为0x100，权限设置为可写（PTE_W）和可读（PTE_R）。
    // 然后使用断言检查插入操作返回值为0，表示页面插入及映射关系建立成功。
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202022:	00093503          	ld	a0,0(s2)
ffffffffc0202026:	4699                	li	a3,6
ffffffffc0202028:	10000613          	li	a2,256
ffffffffc020202c:	85d6                	mv	a1,s5
ffffffffc020202e:	a95ff0ef          	jal	ra,ffffffffc0201ac2 <page_insert>
ffffffffc0202032:	64051e63          	bnez	a0,ffffffffc020268e <pmm_init+0xacc>
    // 断言检查页面（p）的引用计数为1，因为刚插入到页目录的一个映射关系中，理论上此时该页面只有这一处引用，以此验证页面引用计数机制在插入操作后的正确性。
    assert(page_ref(p) == 1);
ffffffffc0202036:	000aa703          	lw	a4,0(s5) # fffffffffffff000 <end+0x3fdeda94>
ffffffffc020203a:	4785                	li	a5,1
ffffffffc020203c:	62f71963          	bne	a4,a5,ffffffffc020266e <pmm_init+0xaac>

    // 再次调用page_insert函数，将同一个页面（p）插入到启动时的页目录（boot_pgdir）中，但这次对应线性地址设置为0x100 + PGSIZE（即在上一个映射地址基础上偏移一个页面大小），权限同样设置为可写（PTE_W）和可读（PTE_R）。
    // 再次使用断言检查插入操作返回值为0，表示第二次页面插入及映射关系建立成功，模拟了同一个页面在不同线性地址建立映射的情况。
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202040:	00093503          	ld	a0,0(s2)
ffffffffc0202044:	6405                	lui	s0,0x1
ffffffffc0202046:	4699                	li	a3,6
ffffffffc0202048:	10040613          	addi	a2,s0,256 # 1100 <kern_entry-0xffffffffc01fef00>
ffffffffc020204c:	85d6                	mv	a1,s5
ffffffffc020204e:	a75ff0ef          	jal	ra,ffffffffc0201ac2 <page_insert>
ffffffffc0202052:	48051263          	bnez	a0,ffffffffc02024d6 <pmm_init+0x914>
    // 断言检查页面（p）的引用计数变为2，因为现在该页面通过两个不同的线性地址映射关系被引用，确保页面引用计数能正确随着映射关系的增加而更新，验证引用计数机制的准确性。
    assert(page_ref(p) == 2);
ffffffffc0202056:	000aa703          	lw	a4,0(s5)
ffffffffc020205a:	4789                	li	a5,2
ffffffffc020205c:	74f71563          	bne	a4,a5,ffffffffc02027a6 <pmm_init+0xbe4>

    // 定义一个字符串常量，内容为 "ucore: Hello world!!"，用于后续测试基于映射后的内存写入和读取操作是否正确。
    const char *str = "ucore: Hello world!!";
    // 使用strcpy函数将字符串复制到线性地址为0x100的内存位置（通过之前建立的页面映射关系，实际会写入到对应的物理页面内存中），
    // 这测试了基于映射后的内存写入操作是否能正常进行，以及写入的数据是否能正确存储在对应的内存位置。
    strcpy((void *)0x100, str);
ffffffffc0202060:	00003597          	auipc	a1,0x3
ffffffffc0202064:	7a858593          	addi	a1,a1,1960 # ffffffffc0205808 <default_pmm_manager+0x5b8>
ffffffffc0202068:	10000513          	li	a0,256
ffffffffc020206c:	434020ef          	jal	ra,ffffffffc02044a0 <strcpy>
    // 使用strcmp函数比较线性地址为0x100和0x100 + PGSIZE处的字符串内容是否相等，由于前面将相同的字符串复制到了这两个通过同一个页面映射的不同线性地址位置，所以理论上它们应该相等。
    // 通过这个断言检查验证基于页面映射的内存读取操作以及内存中数据一致性是否正确，即从不同映射地址读取到的数据应该是一样的（因为都映射到同一个物理页面）。
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202070:	10040593          	addi	a1,s0,256
ffffffffc0202074:	10000513          	li	a0,256
ffffffffc0202078:	43a020ef          	jal	ra,ffffffffc02044b2 <strcmp>
ffffffffc020207c:	70051563          	bnez	a0,ffffffffc0202786 <pmm_init+0xbc4>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202080:	000b3683          	ld	a3,0(s6)
ffffffffc0202084:	00080d37          	lui	s10,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202088:	547d                	li	s0,-1
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc020208a:	40da86b3          	sub	a3,s5,a3
ffffffffc020208e:	868d                	srai	a3,a3,0x3
ffffffffc0202090:	039686b3          	mul	a3,a3,s9
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0202094:	609c                	ld	a5,0(s1)
ffffffffc0202096:	8031                	srli	s0,s0,0xc
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0202098:	96ea                	add	a3,a3,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc020209a:	0086f733          	and	a4,a3,s0
    return page2ppn(page) << PGSHIFT;
ffffffffc020209e:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02020a0:	52f77b63          	bgeu	a4,a5,ffffffffc02025d6 <pmm_init+0xa14>

    // 通过page2kva函数将页面结构体指针（p）转换为对应的内核虚拟地址，然后找到该虚拟地址偏移0x100位置的字符，并将其赋值为'\0'，
    // 这相当于修改了之前存储在对应内存位置的字符串内容，将其变为空字符串，用于测试内存数据的可修改性以及后续对字符串长度检查的操作。
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02020a4:	0009b783          	ld	a5,0(s3)
    // 使用strlen函数检查线性地址为0x100处的字符串长度是否变为0，验证前面修改字符串内容的操作是否生效，进一步测试基于页面映射的内存修改和读取操作的正确性。
    assert(strlen((const char *)0x100) == 0);
ffffffffc02020a8:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc02020ac:	96be                	add	a3,a3,a5
ffffffffc02020ae:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fd6eb94>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02020b2:	3b8020ef          	jal	ra,ffffffffc020446a <strlen>
ffffffffc02020b6:	6a051863          	bnez	a0,ffffffffc0202766 <pmm_init+0xba4>

    // 获取启动时的页目录（boot_pgdir）的指针并存储在pd1变量中，同时通过一系列地址转换和页表、页目录相关操作获取对应页目录项（boot_pgdir[0]）指向的页表所在页面的内核虚拟地址对应的指针，并存储在pd0变量中。
    // 这些指针将用于后续释放相关页面的操作，涉及到多层内存结构的操作和管理，释放这些页面是为了还原内存状态并检查内存回收等相关功能是否正确。
    pde_t *pd1 = boot_pgdir, *pd0 = page2kva(pde2page(boot_pgdir[0]));
ffffffffc02020ba:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02020be:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc02020c0:	000a3783          	ld	a5,0(s4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc02020c4:	078a                	slli	a5,a5,0x2
ffffffffc02020c6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02020c8:	22e7fe63          	bgeu	a5,a4,ffffffffc0202304 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc02020cc:	41a787b3          	sub	a5,a5,s10
ffffffffc02020d0:	00379693          	slli	a3,a5,0x3
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02020d4:	96be                	add	a3,a3,a5
ffffffffc02020d6:	03968cb3          	mul	s9,a3,s9
ffffffffc02020da:	01ac86b3          	add	a3,s9,s10
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02020de:	8c75                	and	s0,s0,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02020e0:	06b2                	slli	a3,a3,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02020e2:	4ee47a63          	bgeu	s0,a4,ffffffffc02025d6 <pmm_init+0xa14>
ffffffffc02020e6:	0009b403          	ld	s0,0(s3)
ffffffffc02020ea:	9436                	add	s0,s0,a3
ffffffffc02020ec:	100027f3          	csrr	a5,sstatus
ffffffffc02020f0:	8b89                	andi	a5,a5,2
ffffffffc02020f2:	1a079163          	bnez	a5,ffffffffc0202294 <pmm_init+0x6d2>
    { pmm_manager->free_pages(base, n); }
ffffffffc02020f6:	000bb783          	ld	a5,0(s7)
ffffffffc02020fa:	4585                	li	a1,1
ffffffffc02020fc:	8556                	mv	a0,s5
ffffffffc02020fe:	739c                	ld	a5,32(a5)
ffffffffc0202100:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202102:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202104:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202106:	078a                	slli	a5,a5,0x2
ffffffffc0202108:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020210a:	1ee7fd63          	bgeu	a5,a4,ffffffffc0202304 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc020210e:	fff80737          	lui	a4,0xfff80
ffffffffc0202112:	97ba                	add	a5,a5,a4
ffffffffc0202114:	000b3503          	ld	a0,0(s6)
ffffffffc0202118:	00379713          	slli	a4,a5,0x3
ffffffffc020211c:	97ba                	add	a5,a5,a4
ffffffffc020211e:	078e                	slli	a5,a5,0x3
ffffffffc0202120:	953e                	add	a0,a0,a5
ffffffffc0202122:	100027f3          	csrr	a5,sstatus
ffffffffc0202126:	8b89                	andi	a5,a5,2
ffffffffc0202128:	14079a63          	bnez	a5,ffffffffc020227c <pmm_init+0x6ba>
ffffffffc020212c:	000bb783          	ld	a5,0(s7)
ffffffffc0202130:	4585                	li	a1,1
ffffffffc0202132:	739c                	ld	a5,32(a5)
ffffffffc0202134:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202136:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage) {
ffffffffc020213a:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc020213c:	078a                	slli	a5,a5,0x2
ffffffffc020213e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202140:	1ce7f263          	bgeu	a5,a4,ffffffffc0202304 <pmm_init+0x742>
    return &pages[PPN(pa) - nbase];
ffffffffc0202144:	fff80737          	lui	a4,0xfff80
ffffffffc0202148:	97ba                	add	a5,a5,a4
ffffffffc020214a:	000b3503          	ld	a0,0(s6)
ffffffffc020214e:	00379713          	slli	a4,a5,0x3
ffffffffc0202152:	97ba                	add	a5,a5,a4
ffffffffc0202154:	078e                	slli	a5,a5,0x3
ffffffffc0202156:	953e                	add	a0,a0,a5
ffffffffc0202158:	100027f3          	csrr	a5,sstatus
ffffffffc020215c:	8b89                	andi	a5,a5,2
ffffffffc020215e:	10079363          	bnez	a5,ffffffffc0202264 <pmm_init+0x6a2>
ffffffffc0202162:	000bb783          	ld	a5,0(s7)
ffffffffc0202166:	4585                	li	a1,1
ffffffffc0202168:	739c                	ld	a5,32(a5)
ffffffffc020216a:	9782                	jalr	a5
    // 调用free_page函数释放通过pd0指针指向的页表所在页面，将对应的页表占用的物理内存也进行回收，确保内存管理中涉及的页表页面能正确释放。
    free_page(pde2page(pd0[0]));
    // 调用free_page函数释放通过pd1指针指向的页目录所在页面，将页目录占用的物理内存也进行回收，同样是为了完整地还原内存状态并检查内存释放相关功能的正确性（假设页目录所在页面也是可以动态分配和释放的情况，具体依实现而定）。
    free_page(pde2page(pd1[0]));
    // 将启动时的页目录（boot_pgdir）的第一个页目录项清零，解除其对应的映射关系（如果有的话），将页目录的相关状态重置为初始的、未设置映射的状态，为后续可能的重新初始化或其他操作做准备。
    boot_pgdir[0] = 0;
ffffffffc020216c:	00093783          	ld	a5,0(s2)
ffffffffc0202170:	0007b023          	sd	zero,0(a5)
ffffffffc0202174:	100027f3          	csrr	a5,sstatus
ffffffffc0202178:	8b89                	andi	a5,a5,2
ffffffffc020217a:	0c079b63          	bnez	a5,ffffffffc0202250 <pmm_init+0x68e>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc020217e:	000bb783          	ld	a5,0(s7)
ffffffffc0202182:	779c                	ld	a5,40(a5)
ffffffffc0202184:	9782                	jalr	a5
ffffffffc0202186:	842a                	mv	s0,a0

    // 断言检查当前系统的空闲页面数量（通过再次调用nr_free_pages函数获取）与之前记录的空闲页面数量（nr_free_store）相等，
    // 这验证了经过一系列页面分配、插入、内存操作以及页面释放等操作后，内存管理模块对空闲页面数量的统计是准确的，没有出现空闲页面数量计算错误等问题，确保整个内存管理机制在这些操作过程中的稳定性和正确性。
    assert(nr_free_store == nr_free_pages());
ffffffffc0202188:	3a8c1763          	bne	s8,s0,ffffffffc0202536 <pmm_init+0x974>
}
ffffffffc020218c:	7406                	ld	s0,96(sp)
ffffffffc020218e:	70a6                	ld	ra,104(sp)
ffffffffc0202190:	64e6                	ld	s1,88(sp)
ffffffffc0202192:	6946                	ld	s2,80(sp)
ffffffffc0202194:	69a6                	ld	s3,72(sp)
ffffffffc0202196:	6a06                	ld	s4,64(sp)
ffffffffc0202198:	7ae2                	ld	s5,56(sp)
ffffffffc020219a:	7b42                	ld	s6,48(sp)
ffffffffc020219c:	7ba2                	ld	s7,40(sp)
ffffffffc020219e:	7c02                	ld	s8,32(sp)
ffffffffc02021a0:	6ce2                	ld	s9,24(sp)
ffffffffc02021a2:	6d42                	ld	s10,16(sp)

    // 输出提示信息，表示对启动时的页目录相关的检查操作成功完成，意味着上述各种针对页目录、页面映射、内存操作以及空闲页面数量等方面的检查都通过了，没有发现明显的错误，整个启动阶段的内存管理相关功能按预期工作。
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02021a4:	00003517          	auipc	a0,0x3
ffffffffc02021a8:	6dc50513          	addi	a0,a0,1756 # ffffffffc0205880 <default_pmm_manager+0x630>
}
ffffffffc02021ac:	6165                	addi	sp,sp,112
    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc02021ae:	f0dfd06f          	j	ffffffffc02000ba <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02021b2:	6705                	lui	a4,0x1
ffffffffc02021b4:	177d                	addi	a4,a4,-1
ffffffffc02021b6:	96ba                	add	a3,a3,a4
ffffffffc02021b8:	777d                	lui	a4,0xfffff
ffffffffc02021ba:	8f75                	and	a4,a4,a3
    if (PPN(pa) >= npage) {
ffffffffc02021bc:	00c75693          	srli	a3,a4,0xc
ffffffffc02021c0:	14f6f263          	bgeu	a3,a5,ffffffffc0202304 <pmm_init+0x742>
    pmm_manager->init_memmap(base, n);
ffffffffc02021c4:	000bb803          	ld	a6,0(s7)
    return &pages[PPN(pa) - nbase];
ffffffffc02021c8:	95b6                	add	a1,a1,a3
ffffffffc02021ca:	00359793          	slli	a5,a1,0x3
ffffffffc02021ce:	97ae                	add	a5,a5,a1
ffffffffc02021d0:	01083683          	ld	a3,16(a6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02021d4:	40e60733          	sub	a4,a2,a4
ffffffffc02021d8:	078e                	slli	a5,a5,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02021da:	00c75593          	srli	a1,a4,0xc
ffffffffc02021de:	953e                	add	a0,a0,a5
ffffffffc02021e0:	9682                	jalr	a3
}
ffffffffc02021e2:	bcc5                	j	ffffffffc0201cd2 <pmm_init+0x110>
        intr_disable();
ffffffffc02021e4:	b0afe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc02021e8:	000bb783          	ld	a5,0(s7)
ffffffffc02021ec:	779c                	ld	a5,40(a5)
ffffffffc02021ee:	9782                	jalr	a5
ffffffffc02021f0:	842a                	mv	s0,a0
        intr_enable();
ffffffffc02021f2:	af6fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02021f6:	b63d                	j	ffffffffc0201d24 <pmm_init+0x162>
        intr_disable();
ffffffffc02021f8:	af6fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02021fc:	000bb783          	ld	a5,0(s7)
ffffffffc0202200:	779c                	ld	a5,40(a5)
ffffffffc0202202:	9782                	jalr	a5
ffffffffc0202204:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202206:	ae2fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020220a:	b3c1                	j	ffffffffc0201fca <pmm_init+0x408>
        intr_disable();
ffffffffc020220c:	ae2fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202210:	000bb783          	ld	a5,0(s7)
ffffffffc0202214:	779c                	ld	a5,40(a5)
ffffffffc0202216:	9782                	jalr	a5
ffffffffc0202218:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc020221a:	acefe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020221e:	b361                	j	ffffffffc0201fa6 <pmm_init+0x3e4>
ffffffffc0202220:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202222:	accfe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202226:	000bb783          	ld	a5,0(s7)
ffffffffc020222a:	6522                	ld	a0,8(sp)
ffffffffc020222c:	4585                	li	a1,1
ffffffffc020222e:	739c                	ld	a5,32(a5)
ffffffffc0202230:	9782                	jalr	a5
        intr_enable();
ffffffffc0202232:	ab6fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202236:	bb91                	j	ffffffffc0201f8a <pmm_init+0x3c8>
ffffffffc0202238:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020223a:	ab4fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc020223e:	000bb783          	ld	a5,0(s7)
ffffffffc0202242:	6522                	ld	a0,8(sp)
ffffffffc0202244:	4585                	li	a1,1
ffffffffc0202246:	739c                	ld	a5,32(a5)
ffffffffc0202248:	9782                	jalr	a5
        intr_enable();
ffffffffc020224a:	a9efe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020224e:	b319                	j	ffffffffc0201f54 <pmm_init+0x392>
        intr_disable();
ffffffffc0202250:	a9efe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { ret = pmm_manager->nr_free_pages(); }
ffffffffc0202254:	000bb783          	ld	a5,0(s7)
ffffffffc0202258:	779c                	ld	a5,40(a5)
ffffffffc020225a:	9782                	jalr	a5
ffffffffc020225c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020225e:	a8afe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202262:	b71d                	j	ffffffffc0202188 <pmm_init+0x5c6>
ffffffffc0202264:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202266:	a88fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020226a:	000bb783          	ld	a5,0(s7)
ffffffffc020226e:	6522                	ld	a0,8(sp)
ffffffffc0202270:	4585                	li	a1,1
ffffffffc0202272:	739c                	ld	a5,32(a5)
ffffffffc0202274:	9782                	jalr	a5
        intr_enable();
ffffffffc0202276:	a72fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc020227a:	bdcd                	j	ffffffffc020216c <pmm_init+0x5aa>
ffffffffc020227c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020227e:	a70fe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202282:	000bb783          	ld	a5,0(s7)
ffffffffc0202286:	6522                	ld	a0,8(sp)
ffffffffc0202288:	4585                	li	a1,1
ffffffffc020228a:	739c                	ld	a5,32(a5)
ffffffffc020228c:	9782                	jalr	a5
        intr_enable();
ffffffffc020228e:	a5afe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202292:	b555                	j	ffffffffc0202136 <pmm_init+0x574>
        intr_disable();
ffffffffc0202294:	a5afe0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc0202298:	000bb783          	ld	a5,0(s7)
ffffffffc020229c:	4585                	li	a1,1
ffffffffc020229e:	8556                	mv	a0,s5
ffffffffc02022a0:	739c                	ld	a5,32(a5)
ffffffffc02022a2:	9782                	jalr	a5
        intr_enable();
ffffffffc02022a4:	a44fe0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc02022a8:	bda9                	j	ffffffffc0202102 <pmm_init+0x540>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02022aa:	00003697          	auipc	a3,0x3
ffffffffc02022ae:	48668693          	addi	a3,a3,1158 # ffffffffc0205730 <default_pmm_manager+0x4e0>
ffffffffc02022b2:	00003617          	auipc	a2,0x3
ffffffffc02022b6:	bee60613          	addi	a2,a2,-1042 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02022ba:	22e00593          	li	a1,558
ffffffffc02022be:	00003517          	auipc	a0,0x3
ffffffffc02022c2:	06250513          	addi	a0,a0,98 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc02022c6:	8aefe0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0))!= NULL);
ffffffffc02022ca:	00003697          	auipc	a3,0x3
ffffffffc02022ce:	42668693          	addi	a3,a3,1062 # ffffffffc02056f0 <default_pmm_manager+0x4a0>
ffffffffc02022d2:	00003617          	auipc	a2,0x3
ffffffffc02022d6:	bce60613          	addi	a2,a2,-1074 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02022da:	22b00593          	li	a1,555
ffffffffc02022de:	00003517          	auipc	a0,0x3
ffffffffc02022e2:	04250513          	addi	a0,a0,66 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc02022e6:	88efe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc02022ea:	86a2                	mv	a3,s0
ffffffffc02022ec:	00003617          	auipc	a2,0x3
ffffffffc02022f0:	00c60613          	addi	a2,a2,12 # ffffffffc02052f8 <default_pmm_manager+0xa8>
ffffffffc02022f4:	22b00593          	li	a1,555
ffffffffc02022f8:	00003517          	auipc	a0,0x3
ffffffffc02022fc:	02850513          	addi	a0,a0,40 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc0202300:	874fe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0202304:	b90ff0ef          	jal	ra,ffffffffc0201694 <pa2page.part.0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202308:	00003617          	auipc	a2,0x3
ffffffffc020230c:	0b060613          	addi	a2,a2,176 # ffffffffc02053b8 <default_pmm_manager+0x168>
ffffffffc0202310:	08a00593          	li	a1,138
ffffffffc0202314:	00003517          	auipc	a0,0x3
ffffffffc0202318:	00c50513          	addi	a0,a0,12 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc020231c:	858fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202320:	00003617          	auipc	a2,0x3
ffffffffc0202324:	09860613          	addi	a2,a2,152 # ffffffffc02053b8 <default_pmm_manager+0x168>
ffffffffc0202328:	0d200593          	li	a1,210
ffffffffc020232c:	00003517          	auipc	a0,0x3
ffffffffc0202330:	ff450513          	addi	a0,a0,-12 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc0202334:	840fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir!= NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202338:	00003697          	auipc	a3,0x3
ffffffffc020233c:	0e868693          	addi	a3,a3,232 # ffffffffc0205420 <default_pmm_manager+0x1d0>
ffffffffc0202340:	00003617          	auipc	a2,0x3
ffffffffc0202344:	b6060613          	addi	a2,a2,-1184 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202348:	1be00593          	li	a1,446
ffffffffc020234c:	00003517          	auipc	a0,0x3
ffffffffc0202350:	fd450513          	addi	a0,a0,-44 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc0202354:	820fe0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202358:	00003697          	auipc	a3,0x3
ffffffffc020235c:	0a868693          	addi	a3,a3,168 # ffffffffc0205400 <default_pmm_manager+0x1b0>
ffffffffc0202360:	00003617          	auipc	a2,0x3
ffffffffc0202364:	b4060613          	addi	a2,a2,-1216 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202368:	1bb00593          	li	a1,443
ffffffffc020236c:	00003517          	auipc	a0,0x3
ffffffffc0202370:	fb450513          	addi	a0,a0,-76 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc0202374:	800fe0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0202378:	b38ff0ef          	jal	ra,ffffffffc02016b0 <pte2page.part.0>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0))!= NULL);
ffffffffc020237c:	00003697          	auipc	a3,0x3
ffffffffc0202380:	13468693          	addi	a3,a3,308 # ffffffffc02054b0 <default_pmm_manager+0x260>
ffffffffc0202384:	00003617          	auipc	a2,0x3
ffffffffc0202388:	b1c60613          	addi	a2,a2,-1252 # ffffffffc0204ea0 <commands+0x738>
ffffffffc020238c:	1cc00593          	li	a1,460
ffffffffc0202390:	00003517          	auipc	a0,0x3
ffffffffc0202394:	f9050513          	addi	a0,a0,-112 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc0202398:	fddfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc020239c:	00003697          	auipc	a3,0x3
ffffffffc02023a0:	0e468693          	addi	a3,a3,228 # ffffffffc0205480 <default_pmm_manager+0x230>
ffffffffc02023a4:	00003617          	auipc	a2,0x3
ffffffffc02023a8:	afc60613          	addi	a2,a2,-1284 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02023ac:	1c800593          	li	a1,456
ffffffffc02023b0:	00003517          	auipc	a0,0x3
ffffffffc02023b4:	f7050513          	addi	a0,a0,-144 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc02023b8:	fbdfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc02023bc:	00003697          	auipc	a3,0x3
ffffffffc02023c0:	09c68693          	addi	a3,a3,156 # ffffffffc0205458 <default_pmm_manager+0x208>
ffffffffc02023c4:	00003617          	auipc	a2,0x3
ffffffffc02023c8:	adc60613          	addi	a2,a2,-1316 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02023cc:	1c100593          	li	a1,449
ffffffffc02023d0:	00003517          	auipc	a0,0x3
ffffffffc02023d4:	f5050513          	addi	a0,a0,-176 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc02023d8:	f9dfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02023dc:	00003697          	auipc	a3,0x3
ffffffffc02023e0:	15c68693          	addi	a3,a3,348 # ffffffffc0205538 <default_pmm_manager+0x2e8>
ffffffffc02023e4:	00003617          	auipc	a2,0x3
ffffffffc02023e8:	abc60613          	addi	a2,a2,-1348 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02023ec:	1dd00593          	li	a1,477
ffffffffc02023f0:	00003517          	auipc	a0,0x3
ffffffffc02023f4:	f3050513          	addi	a0,a0,-208 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc02023f8:	f7dfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02023fc:	00003697          	auipc	a3,0x3
ffffffffc0202400:	1dc68693          	addi	a3,a3,476 # ffffffffc02055d8 <default_pmm_manager+0x388>
ffffffffc0202404:	00003617          	auipc	a2,0x3
ffffffffc0202408:	a9c60613          	addi	a2,a2,-1380 # ffffffffc0204ea0 <commands+0x738>
ffffffffc020240c:	1e700593          	li	a1,487
ffffffffc0202410:	00003517          	auipc	a0,0x3
ffffffffc0202414:	f1050513          	addi	a0,a0,-240 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc0202418:	f5dfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020241c:	00003697          	auipc	a3,0x3
ffffffffc0202420:	0f468693          	addi	a3,a3,244 # ffffffffc0205510 <default_pmm_manager+0x2c0>
ffffffffc0202424:	00003617          	auipc	a2,0x3
ffffffffc0202428:	a7c60613          	addi	a2,a2,-1412 # ffffffffc0204ea0 <commands+0x738>
ffffffffc020242c:	1d700593          	li	a1,471
ffffffffc0202430:	00003517          	auipc	a0,0x3
ffffffffc0202434:	ef050513          	addi	a0,a0,-272 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc0202438:	f3dfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020243c:	86d6                	mv	a3,s5
ffffffffc020243e:	00003617          	auipc	a2,0x3
ffffffffc0202442:	eba60613          	addi	a2,a2,-326 # ffffffffc02052f8 <default_pmm_manager+0xa8>
ffffffffc0202446:	1d600593          	li	a1,470
ffffffffc020244a:	00003517          	auipc	a0,0x3
ffffffffc020244e:	ed650513          	addi	a0,a0,-298 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc0202452:	f23fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0))!= NULL);
ffffffffc0202456:	00003697          	auipc	a3,0x3
ffffffffc020245a:	11a68693          	addi	a3,a3,282 # ffffffffc0205570 <default_pmm_manager+0x320>
ffffffffc020245e:	00003617          	auipc	a2,0x3
ffffffffc0202462:	a4260613          	addi	a2,a2,-1470 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202466:	1f100593          	li	a1,497
ffffffffc020246a:	00003517          	auipc	a0,0x3
ffffffffc020246e:	eb650513          	addi	a0,a0,-330 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc0202472:	f03fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202476:	00003697          	auipc	a3,0x3
ffffffffc020247a:	1c268693          	addi	a3,a3,450 # ffffffffc0205638 <default_pmm_manager+0x3e8>
ffffffffc020247e:	00003617          	auipc	a2,0x3
ffffffffc0202482:	a2260613          	addi	a2,a2,-1502 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202486:	1ef00593          	li	a1,495
ffffffffc020248a:	00003517          	auipc	a0,0x3
ffffffffc020248e:	e9650513          	addi	a0,a0,-362 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc0202492:	ee3fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202496:	00003697          	auipc	a3,0x3
ffffffffc020249a:	18a68693          	addi	a3,a3,394 # ffffffffc0205620 <default_pmm_manager+0x3d0>
ffffffffc020249e:	00003617          	auipc	a2,0x3
ffffffffc02024a2:	a0260613          	addi	a2,a2,-1534 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02024a6:	1ed00593          	li	a1,493
ffffffffc02024aa:	00003517          	auipc	a0,0x3
ffffffffc02024ae:	e7650513          	addi	a0,a0,-394 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc02024b2:	ec3fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc02024b6:	00003697          	auipc	a3,0x3
ffffffffc02024ba:	13a68693          	addi	a3,a3,314 # ffffffffc02055f0 <default_pmm_manager+0x3a0>
ffffffffc02024be:	00003617          	auipc	a2,0x3
ffffffffc02024c2:	9e260613          	addi	a2,a2,-1566 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02024c6:	1eb00593          	li	a1,491
ffffffffc02024ca:	00003517          	auipc	a0,0x3
ffffffffc02024ce:	e5650513          	addi	a0,a0,-426 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc02024d2:	ea3fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02024d6:	00003697          	auipc	a3,0x3
ffffffffc02024da:	2da68693          	addi	a3,a3,730 # ffffffffc02057b0 <default_pmm_manager+0x560>
ffffffffc02024de:	00003617          	auipc	a2,0x3
ffffffffc02024e2:	9c260613          	addi	a2,a2,-1598 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02024e6:	24200593          	li	a1,578
ffffffffc02024ea:	00003517          	auipc	a0,0x3
ffffffffc02024ee:	e3650513          	addi	a0,a0,-458 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc02024f2:	e83fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc02024f6:	00003697          	auipc	a3,0x3
ffffffffc02024fa:	0ca68693          	addi	a3,a3,202 # ffffffffc02055c0 <default_pmm_manager+0x370>
ffffffffc02024fe:	00003617          	auipc	a2,0x3
ffffffffc0202502:	9a260613          	addi	a2,a2,-1630 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202506:	1e500593          	li	a1,485
ffffffffc020250a:	00003517          	auipc	a0,0x3
ffffffffc020250e:	e1650513          	addi	a0,a0,-490 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc0202512:	e63fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202516:	00003697          	auipc	a3,0x3
ffffffffc020251a:	09a68693          	addi	a3,a3,154 # ffffffffc02055b0 <default_pmm_manager+0x360>
ffffffffc020251e:	00003617          	auipc	a2,0x3
ffffffffc0202522:	98260613          	addi	a2,a2,-1662 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202526:	1e300593          	li	a1,483
ffffffffc020252a:	00003517          	auipc	a0,0x3
ffffffffc020252e:	df650513          	addi	a0,a0,-522 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc0202532:	e43fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0202536:	00003697          	auipc	a3,0x3
ffffffffc020253a:	17268693          	addi	a3,a3,370 # ffffffffc02056a8 <default_pmm_manager+0x458>
ffffffffc020253e:	00003617          	auipc	a2,0x3
ffffffffc0202542:	96260613          	addi	a2,a2,-1694 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202546:	26300593          	li	a1,611
ffffffffc020254a:	00003517          	auipc	a0,0x3
ffffffffc020254e:	dd650513          	addi	a0,a0,-554 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc0202552:	e23fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202556:	00003697          	auipc	a3,0x3
ffffffffc020255a:	04a68693          	addi	a3,a3,74 # ffffffffc02055a0 <default_pmm_manager+0x350>
ffffffffc020255e:	00003617          	auipc	a2,0x3
ffffffffc0202562:	94260613          	addi	a2,a2,-1726 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202566:	1e100593          	li	a1,481
ffffffffc020256a:	00003517          	auipc	a0,0x3
ffffffffc020256e:	db650513          	addi	a0,a0,-586 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc0202572:	e03fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202576:	00003697          	auipc	a3,0x3
ffffffffc020257a:	f8268693          	addi	a3,a3,-126 # ffffffffc02054f8 <default_pmm_manager+0x2a8>
ffffffffc020257e:	00003617          	auipc	a2,0x3
ffffffffc0202582:	92260613          	addi	a2,a2,-1758 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202586:	1fb00593          	li	a1,507
ffffffffc020258a:	00003517          	auipc	a0,0x3
ffffffffc020258e:	d9650513          	addi	a0,a0,-618 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc0202592:	de3fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202596:	00003697          	auipc	a3,0x3
ffffffffc020259a:	0ba68693          	addi	a3,a3,186 # ffffffffc0205650 <default_pmm_manager+0x400>
ffffffffc020259e:	00003617          	auipc	a2,0x3
ffffffffc02025a2:	90260613          	addi	a2,a2,-1790 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02025a6:	1f600593          	li	a1,502
ffffffffc02025aa:	00003517          	auipc	a0,0x3
ffffffffc02025ae:	d7650513          	addi	a0,a0,-650 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc02025b2:	dc3fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02025b6:	00003697          	auipc	a3,0x3
ffffffffc02025ba:	f2a68693          	addi	a3,a3,-214 # ffffffffc02054e0 <default_pmm_manager+0x290>
ffffffffc02025be:	00003617          	auipc	a2,0x3
ffffffffc02025c2:	8e260613          	addi	a2,a2,-1822 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02025c6:	1f400593          	li	a1,500
ffffffffc02025ca:	00003517          	auipc	a0,0x3
ffffffffc02025ce:	d5650513          	addi	a0,a0,-682 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc02025d2:	da3fd0ef          	jal	ra,ffffffffc0200374 <__panic>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02025d6:	00003617          	auipc	a2,0x3
ffffffffc02025da:	d2260613          	addi	a2,a2,-734 # ffffffffc02052f8 <default_pmm_manager+0xa8>
ffffffffc02025de:	08600593          	li	a1,134
ffffffffc02025e2:	00003517          	auipc	a0,0x3
ffffffffc02025e6:	ce650513          	addi	a0,a0,-794 # ffffffffc02052c8 <default_pmm_manager+0x78>
ffffffffc02025ea:	d8bfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02025ee:	00003697          	auipc	a3,0x3
ffffffffc02025f2:	09268693          	addi	a3,a3,146 # ffffffffc0205680 <default_pmm_manager+0x430>
ffffffffc02025f6:	00003617          	auipc	a2,0x3
ffffffffc02025fa:	8aa60613          	addi	a2,a2,-1878 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02025fe:	20800593          	li	a1,520
ffffffffc0202602:	00003517          	auipc	a0,0x3
ffffffffc0202606:	d1e50513          	addi	a0,a0,-738 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc020260a:	d6bfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020260e:	00003697          	auipc	a3,0x3
ffffffffc0202612:	02a68693          	addi	a3,a3,42 # ffffffffc0205638 <default_pmm_manager+0x3e8>
ffffffffc0202616:	00003617          	auipc	a2,0x3
ffffffffc020261a:	88a60613          	addi	a2,a2,-1910 # ffffffffc0204ea0 <commands+0x738>
ffffffffc020261e:	20400593          	li	a1,516
ffffffffc0202622:	00003517          	auipc	a0,0x3
ffffffffc0202626:	cfe50513          	addi	a0,a0,-770 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc020262a:	d4bfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc020262e:	00003697          	auipc	a3,0x3
ffffffffc0202632:	03a68693          	addi	a3,a3,58 # ffffffffc0205668 <default_pmm_manager+0x418>
ffffffffc0202636:	00003617          	auipc	a2,0x3
ffffffffc020263a:	86a60613          	addi	a2,a2,-1942 # ffffffffc0204ea0 <commands+0x738>
ffffffffc020263e:	20200593          	li	a1,514
ffffffffc0202642:	00003517          	auipc	a0,0x3
ffffffffc0202646:	cde50513          	addi	a0,a0,-802 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc020264a:	d2bfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020264e:	00003697          	auipc	a3,0x3
ffffffffc0202652:	fea68693          	addi	a3,a3,-22 # ffffffffc0205638 <default_pmm_manager+0x3e8>
ffffffffc0202656:	00003617          	auipc	a2,0x3
ffffffffc020265a:	84a60613          	addi	a2,a2,-1974 # ffffffffc0204ea0 <commands+0x738>
ffffffffc020265e:	1fd00593          	li	a1,509
ffffffffc0202662:	00003517          	auipc	a0,0x3
ffffffffc0202666:	cbe50513          	addi	a0,a0,-834 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc020266a:	d0bfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 1);
ffffffffc020266e:	00003697          	auipc	a3,0x3
ffffffffc0202672:	12a68693          	addi	a3,a3,298 # ffffffffc0205798 <default_pmm_manager+0x548>
ffffffffc0202676:	00003617          	auipc	a2,0x3
ffffffffc020267a:	82a60613          	addi	a2,a2,-2006 # ffffffffc0204ea0 <commands+0x738>
ffffffffc020267e:	23e00593          	li	a1,574
ffffffffc0202682:	00003517          	auipc	a0,0x3
ffffffffc0202686:	c9e50513          	addi	a0,a0,-866 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc020268a:	cebfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020268e:	00003697          	auipc	a3,0x3
ffffffffc0202692:	0d268693          	addi	a3,a3,210 # ffffffffc0205760 <default_pmm_manager+0x510>
ffffffffc0202696:	00003617          	auipc	a2,0x3
ffffffffc020269a:	80a60613          	addi	a2,a2,-2038 # ffffffffc0204ea0 <commands+0x738>
ffffffffc020269e:	23c00593          	li	a1,572
ffffffffc02026a2:	00003517          	auipc	a0,0x3
ffffffffc02026a6:	c7e50513          	addi	a0,a0,-898 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc02026aa:	ccbfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc02026ae:	00003697          	auipc	a3,0x3
ffffffffc02026b2:	09a68693          	addi	a3,a3,154 # ffffffffc0205748 <default_pmm_manager+0x4f8>
ffffffffc02026b6:	00002617          	auipc	a2,0x2
ffffffffc02026ba:	7ea60613          	addi	a2,a2,2026 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02026be:	23300593          	li	a1,563
ffffffffc02026c2:	00003517          	auipc	a0,0x3
ffffffffc02026c6:	c5e50513          	addi	a0,a0,-930 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc02026ca:	cabfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc02026ce:	00003697          	auipc	a3,0x3
ffffffffc02026d2:	fda68693          	addi	a3,a3,-38 # ffffffffc02056a8 <default_pmm_manager+0x458>
ffffffffc02026d6:	00002617          	auipc	a2,0x2
ffffffffc02026da:	7ca60613          	addi	a2,a2,1994 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02026de:	21600593          	li	a1,534
ffffffffc02026e2:	00003517          	auipc	a0,0x3
ffffffffc02026e6:	c3e50513          	addi	a0,a0,-962 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc02026ea:	c8bfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02026ee:	00003697          	auipc	a3,0x3
ffffffffc02026f2:	df268693          	addi	a3,a3,-526 # ffffffffc02054e0 <default_pmm_manager+0x290>
ffffffffc02026f6:	00002617          	auipc	a2,0x2
ffffffffc02026fa:	7aa60613          	addi	a2,a2,1962 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02026fe:	1cf00593          	li	a1,463
ffffffffc0202702:	00003517          	auipc	a0,0x3
ffffffffc0202706:	c1e50513          	addi	a0,a0,-994 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc020270a:	c6bfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc020270e:	00003617          	auipc	a2,0x3
ffffffffc0202712:	bea60613          	addi	a2,a2,-1046 # ffffffffc02052f8 <default_pmm_manager+0xa8>
ffffffffc0202716:	1d500593          	li	a1,469
ffffffffc020271a:	00003517          	auipc	a0,0x3
ffffffffc020271e:	c0650513          	addi	a0,a0,-1018 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc0202722:	c53fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202726:	00003697          	auipc	a3,0x3
ffffffffc020272a:	dd268693          	addi	a3,a3,-558 # ffffffffc02054f8 <default_pmm_manager+0x2a8>
ffffffffc020272e:	00002617          	auipc	a2,0x2
ffffffffc0202732:	77260613          	addi	a2,a2,1906 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202736:	1d100593          	li	a1,465
ffffffffc020273a:	00003517          	auipc	a0,0x3
ffffffffc020273e:	be650513          	addi	a0,a0,-1050 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc0202742:	c33fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0))!= NULL);
ffffffffc0202746:	00003697          	auipc	a3,0x3
ffffffffc020274a:	e2a68693          	addi	a3,a3,-470 # ffffffffc0205570 <default_pmm_manager+0x320>
ffffffffc020274e:	00002617          	auipc	a2,0x2
ffffffffc0202752:	75260613          	addi	a2,a2,1874 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202756:	1df00593          	li	a1,479
ffffffffc020275a:	00003517          	auipc	a0,0x3
ffffffffc020275e:	bc650513          	addi	a0,a0,-1082 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc0202762:	c13fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202766:	00003697          	auipc	a3,0x3
ffffffffc020276a:	0f268693          	addi	a3,a3,242 # ffffffffc0205858 <default_pmm_manager+0x608>
ffffffffc020276e:	00002617          	auipc	a2,0x2
ffffffffc0202772:	73260613          	addi	a2,a2,1842 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202776:	25300593          	li	a1,595
ffffffffc020277a:	00003517          	auipc	a0,0x3
ffffffffc020277e:	ba650513          	addi	a0,a0,-1114 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc0202782:	bf3fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202786:	00003697          	auipc	a3,0x3
ffffffffc020278a:	09a68693          	addi	a3,a3,154 # ffffffffc0205820 <default_pmm_manager+0x5d0>
ffffffffc020278e:	00002617          	auipc	a2,0x2
ffffffffc0202792:	71260613          	addi	a2,a2,1810 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202796:	24d00593          	li	a1,589
ffffffffc020279a:	00003517          	auipc	a0,0x3
ffffffffc020279e:	b8650513          	addi	a0,a0,-1146 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc02027a2:	bd3fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(page_ref(p) == 2);
ffffffffc02027a6:	00003697          	auipc	a3,0x3
ffffffffc02027aa:	04a68693          	addi	a3,a3,74 # ffffffffc02057f0 <default_pmm_manager+0x5a0>
ffffffffc02027ae:	00002617          	auipc	a2,0x2
ffffffffc02027b2:	6f260613          	addi	a2,a2,1778 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02027b6:	24400593          	li	a1,580
ffffffffc02027ba:	00003517          	auipc	a0,0x3
ffffffffc02027be:	b6650513          	addi	a0,a0,-1178 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc02027c2:	bb3fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02027c6 <tlb_invalidate>:
static inline void flush_tlb() { asm volatile("sfence.vma"); }
ffffffffc02027c6:	12000073          	sfence.vma
void tlb_invalidate(pde_t *pgdir, uintptr_t la) { flush_tlb(); }
ffffffffc02027ca:	8082                	ret

ffffffffc02027cc <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02027cc:	7179                	addi	sp,sp,-48
ffffffffc02027ce:	e84a                	sd	s2,16(sp)
ffffffffc02027d0:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02027d2:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02027d4:	f022                	sd	s0,32(sp)
ffffffffc02027d6:	ec26                	sd	s1,24(sp)
ffffffffc02027d8:	e44e                	sd	s3,8(sp)
ffffffffc02027da:	f406                	sd	ra,40(sp)
ffffffffc02027dc:	84ae                	mv	s1,a1
ffffffffc02027de:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc02027e0:	eedfe0ef          	jal	ra,ffffffffc02016cc <alloc_pages>
ffffffffc02027e4:	842a                	mv	s0,a0
    if (page!= NULL) {
ffffffffc02027e6:	cd09                	beqz	a0,ffffffffc0202800 <pgdir_alloc_page+0x34>
        if (page_insert(pgdir, page, la, perm)!= 0) {
ffffffffc02027e8:	85aa                	mv	a1,a0
ffffffffc02027ea:	86ce                	mv	a3,s3
ffffffffc02027ec:	8626                	mv	a2,s1
ffffffffc02027ee:	854a                	mv	a0,s2
ffffffffc02027f0:	ad2ff0ef          	jal	ra,ffffffffc0201ac2 <page_insert>
ffffffffc02027f4:	ed21                	bnez	a0,ffffffffc020284c <pgdir_alloc_page+0x80>
        if (swap_init_ok) {
ffffffffc02027f6:	0000f797          	auipc	a5,0xf
ffffffffc02027fa:	d5a7a783          	lw	a5,-678(a5) # ffffffffc0211550 <swap_init_ok>
ffffffffc02027fe:	eb89                	bnez	a5,ffffffffc0202810 <pgdir_alloc_page+0x44>
}
ffffffffc0202800:	70a2                	ld	ra,40(sp)
ffffffffc0202802:	8522                	mv	a0,s0
ffffffffc0202804:	7402                	ld	s0,32(sp)
ffffffffc0202806:	64e2                	ld	s1,24(sp)
ffffffffc0202808:	6942                	ld	s2,16(sp)
ffffffffc020280a:	69a2                	ld	s3,8(sp)
ffffffffc020280c:	6145                	addi	sp,sp,48
ffffffffc020280e:	8082                	ret
            swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0202810:	4681                	li	a3,0
ffffffffc0202812:	8622                	mv	a2,s0
ffffffffc0202814:	85a6                	mv	a1,s1
ffffffffc0202816:	0000f517          	auipc	a0,0xf
ffffffffc020281a:	d4a53503          	ld	a0,-694(a0) # ffffffffc0211560 <check_mm_struct>
ffffffffc020281e:	07f000ef          	jal	ra,ffffffffc020309c <swap_map_swappable>
            assert(page_ref(page) == 1);
ffffffffc0202822:	4018                	lw	a4,0(s0)
            page->pra_vaddr = la;
ffffffffc0202824:	e024                	sd	s1,64(s0)
            assert(page_ref(page) == 1);
ffffffffc0202826:	4785                	li	a5,1
ffffffffc0202828:	fcf70ce3          	beq	a4,a5,ffffffffc0202800 <pgdir_alloc_page+0x34>
ffffffffc020282c:	00003697          	auipc	a3,0x3
ffffffffc0202830:	07468693          	addi	a3,a3,116 # ffffffffc02058a0 <default_pmm_manager+0x650>
ffffffffc0202834:	00002617          	auipc	a2,0x2
ffffffffc0202838:	66c60613          	addi	a2,a2,1644 # ffffffffc0204ea0 <commands+0x738>
ffffffffc020283c:	19900593          	li	a1,409
ffffffffc0202840:	00003517          	auipc	a0,0x3
ffffffffc0202844:	ae050513          	addi	a0,a0,-1312 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc0202848:	b2dfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020284c:	100027f3          	csrr	a5,sstatus
ffffffffc0202850:	8b89                	andi	a5,a5,2
ffffffffc0202852:	eb99                	bnez	a5,ffffffffc0202868 <pgdir_alloc_page+0x9c>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202854:	0000f797          	auipc	a5,0xf
ffffffffc0202858:	cdc7b783          	ld	a5,-804(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc020285c:	739c                	ld	a5,32(a5)
ffffffffc020285e:	8522                	mv	a0,s0
ffffffffc0202860:	4585                	li	a1,1
ffffffffc0202862:	9782                	jalr	a5
            return NULL;
ffffffffc0202864:	4401                	li	s0,0
ffffffffc0202866:	bf69                	j	ffffffffc0202800 <pgdir_alloc_page+0x34>
        intr_disable();
ffffffffc0202868:	c87fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
    { pmm_manager->free_pages(base, n); }
ffffffffc020286c:	0000f797          	auipc	a5,0xf
ffffffffc0202870:	cc47b783          	ld	a5,-828(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc0202874:	739c                	ld	a5,32(a5)
ffffffffc0202876:	8522                	mv	a0,s0
ffffffffc0202878:	4585                	li	a1,1
ffffffffc020287a:	9782                	jalr	a5
            return NULL;
ffffffffc020287c:	4401                	li	s0,0
        intr_enable();
ffffffffc020287e:	c6bfd0ef          	jal	ra,ffffffffc02004e8 <intr_enable>
ffffffffc0202882:	bfbd                	j	ffffffffc0202800 <pgdir_alloc_page+0x34>

ffffffffc0202884 <kmalloc>:
}

// kmalloc函数用于在内核空间中分配指定大小（n字节）的内存块。
// 它通过计算需要分配的页面数量，调用alloc_pages函数获取相应的物理页面，然后将页面转换为对应的内核虚拟地址并返回，以供内核其他部分使用。
void *kmalloc(size_t n) {
ffffffffc0202884:	1141                	addi	sp,sp,-16
    void *ptr = NULL;
    struct Page *base = NULL;
    // 首先进行断言检查，确保要分配的内存大小（n）大于0且小于一个特定的限制值（1024 * 0124，这里可能是基于系统内存资源限制或者设计考虑设定的一个合理上限，防止不合理的大内存分配请求）。
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202886:	67d5                	lui	a5,0x15
void *kmalloc(size_t n) {
ffffffffc0202888:	e406                	sd	ra,8(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc020288a:	fff50713          	addi	a4,a0,-1
ffffffffc020288e:	17f9                	addi	a5,a5,-2
ffffffffc0202890:	04e7ea63          	bltu	a5,a4,ffffffffc02028e4 <kmalloc+0x60>
    // 计算需要分配的页面数量，通过将请求分配的内存大小（n）加上页面大小（PGSIZE）减1后再除以页面大小（PGSIZE）来向上取整得到页面数量。
    // 例如，如果n小于PGSIZE，也会分配一个页面；如果n刚好是PGSIZE的整数倍，则分配对应整数倍数量的页面，确保分配的内存能完整覆盖请求的大小。
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0202894:	6785                	lui	a5,0x1
ffffffffc0202896:	17fd                	addi	a5,a5,-1
ffffffffc0202898:	953e                	add	a0,a0,a5
    // 调用alloc_pages函数分配指定数量（num_pages）的物理页面，返回对应的页面结构体指针，并将其存储在base变量中。
    // 如果分配成功，base将指向分配到的连续物理页面的起始页面结构体；如果分配失败（例如内存不足等原因），base将为NULL。
    base = alloc_pages(num_pages);
ffffffffc020289a:	8131                	srli	a0,a0,0xc
ffffffffc020289c:	e31fe0ef          	jal	ra,ffffffffc02016cc <alloc_pages>
    // 使用断言检查分配操作是否成功，即base指针不为NULL，确保能获取到有效的物理页面来满足内存分配请求。
    assert(base!= NULL);
ffffffffc02028a0:	cd3d                	beqz	a0,ffffffffc020291e <kmalloc+0x9a>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02028a2:	0000f797          	auipc	a5,0xf
ffffffffc02028a6:	c867b783          	ld	a5,-890(a5) # ffffffffc0211528 <pages>
ffffffffc02028aa:	8d1d                	sub	a0,a0,a5
ffffffffc02028ac:	00004697          	auipc	a3,0x4
ffffffffc02028b0:	a8c6b683          	ld	a3,-1396(a3) # ffffffffc0206338 <error_string+0x38>
ffffffffc02028b4:	850d                	srai	a0,a0,0x3
ffffffffc02028b6:	02d50533          	mul	a0,a0,a3
ffffffffc02028ba:	000806b7          	lui	a3,0x80
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02028be:	0000f717          	auipc	a4,0xf
ffffffffc02028c2:	c6273703          	ld	a4,-926(a4) # ffffffffc0211520 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02028c6:	9536                	add	a0,a0,a3
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02028c8:	00c51793          	slli	a5,a0,0xc
ffffffffc02028cc:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02028ce:	0532                	slli	a0,a0,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc02028d0:	02e7fa63          	bgeu	a5,a4,ffffffffc0202904 <kmalloc+0x80>
    // 通过page2kva函数将分配到的物理页面（base）转换为对应的内核虚拟地址，这个虚拟地址就是分配给调用者使用的内存块的起始地址，将其存储在ptr变量中。
    ptr = page2kva(base);
    // 最后返回分配到的内存块的内核虚拟地址指针，供调用者使用，调用者可以通过这个指针在分配的内存区域进行读写等操作，就好像操作普通的内存空间一样，实际上背后是通过页表等机制映射到对应的物理页面上的。
    return ptr;
}
ffffffffc02028d4:	60a2                	ld	ra,8(sp)
ffffffffc02028d6:	0000f797          	auipc	a5,0xf
ffffffffc02028da:	c627b783          	ld	a5,-926(a5) # ffffffffc0211538 <va_pa_offset>
ffffffffc02028de:	953e                	add	a0,a0,a5
ffffffffc02028e0:	0141                	addi	sp,sp,16
ffffffffc02028e2:	8082                	ret
    assert(n > 0 && n < 1024 * 0124);
ffffffffc02028e4:	00003697          	auipc	a3,0x3
ffffffffc02028e8:	fd468693          	addi	a3,a3,-44 # ffffffffc02058b8 <default_pmm_manager+0x668>
ffffffffc02028ec:	00002617          	auipc	a2,0x2
ffffffffc02028f0:	5b460613          	addi	a2,a2,1460 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02028f4:	26f00593          	li	a1,623
ffffffffc02028f8:	00003517          	auipc	a0,0x3
ffffffffc02028fc:	a2850513          	addi	a0,a0,-1496 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc0202900:	a75fd0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0202904:	86aa                	mv	a3,a0
ffffffffc0202906:	00003617          	auipc	a2,0x3
ffffffffc020290a:	9f260613          	addi	a2,a2,-1550 # ffffffffc02052f8 <default_pmm_manager+0xa8>
ffffffffc020290e:	08600593          	li	a1,134
ffffffffc0202912:	00003517          	auipc	a0,0x3
ffffffffc0202916:	9b650513          	addi	a0,a0,-1610 # ffffffffc02052c8 <default_pmm_manager+0x78>
ffffffffc020291a:	a5bfd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(base!= NULL);
ffffffffc020291e:	00003697          	auipc	a3,0x3
ffffffffc0202922:	fba68693          	addi	a3,a3,-70 # ffffffffc02058d8 <default_pmm_manager+0x688>
ffffffffc0202926:	00002617          	auipc	a2,0x2
ffffffffc020292a:	57a60613          	addi	a2,a2,1402 # ffffffffc0204ea0 <commands+0x738>
ffffffffc020292e:	27700593          	li	a1,631
ffffffffc0202932:	00003517          	auipc	a0,0x3
ffffffffc0202936:	9ee50513          	addi	a0,a0,-1554 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc020293a:	a3bfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc020293e <kfree>:

// kfree函数用于释放之前通过kmalloc函数在内核空间中分配的内存块。
// 它根据传入的内存块指针（ptr）和内存块大小（n），计算出对应的页面数量，然后调用free_pages函数将这些页面释放回空闲内存池，完成内存回收操作。
void kfree(void *ptr, size_t n) {
ffffffffc020293e:	1101                	addi	sp,sp,-32
    // 首先进行断言检查，确保要释放的内存大小（n）大于0且小于一个特定的限制值（1024 * 0124，与kmalloc函数中的限制对应，确保释放操作的参数合理性）。
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202940:	67d5                	lui	a5,0x15
void kfree(void *ptr, size_t n) {
ffffffffc0202942:	ec06                	sd	ra,24(sp)
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202944:	fff58713          	addi	a4,a1,-1
ffffffffc0202948:	17f9                	addi	a5,a5,-2
ffffffffc020294a:	0ae7ee63          	bltu	a5,a4,ffffffffc0202a06 <kfree+0xc8>
    // 再次进行断言检查，确保传入的内存块指针（ptr）不为NULL，因为不能释放一个空指针指向的内存，防止出现错误操作。
    assert(ptr!= NULL);
ffffffffc020294e:	cd41                	beqz	a0,ffffffffc02029e6 <kfree+0xa8>
    struct Page *base = NULL;
    // 计算需要释放的页面数量，计算方式与kmalloc函数中类似，通过将内存块大小（n）加上页面大小（PGSIZE）减1后再除以页面大小（PGSIZE）来向上取整得到页面数量，确保能准确释放对应内存块所占用的所有页面。
    int num_pages = (n + PGSIZE - 1) / PGSIZE;
ffffffffc0202950:	6785                	lui	a5,0x1
ffffffffc0202952:	17fd                	addi	a5,a5,-1
ffffffffc0202954:	95be                	add	a1,a1,a5
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc0202956:	c02007b7          	lui	a5,0xc0200
ffffffffc020295a:	81b1                	srli	a1,a1,0xc
ffffffffc020295c:	06f56863          	bltu	a0,a5,ffffffffc02029cc <kfree+0x8e>
ffffffffc0202960:	0000f697          	auipc	a3,0xf
ffffffffc0202964:	bd86b683          	ld	a3,-1064(a3) # ffffffffc0211538 <va_pa_offset>
ffffffffc0202968:	8d15                	sub	a0,a0,a3
    if (PPN(pa) >= npage) {
ffffffffc020296a:	8131                	srli	a0,a0,0xc
ffffffffc020296c:	0000f797          	auipc	a5,0xf
ffffffffc0202970:	bb47b783          	ld	a5,-1100(a5) # ffffffffc0211520 <npage>
ffffffffc0202974:	04f57a63          	bgeu	a0,a5,ffffffffc02029c8 <kfree+0x8a>
    return &pages[PPN(pa) - nbase];
ffffffffc0202978:	fff806b7          	lui	a3,0xfff80
ffffffffc020297c:	9536                	add	a0,a0,a3
ffffffffc020297e:	00351793          	slli	a5,a0,0x3
ffffffffc0202982:	953e                	add	a0,a0,a5
ffffffffc0202984:	050e                	slli	a0,a0,0x3
ffffffffc0202986:	0000f797          	auipc	a5,0xf
ffffffffc020298a:	ba27b783          	ld	a5,-1118(a5) # ffffffffc0211528 <pages>
ffffffffc020298e:	953e                	add	a0,a0,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202990:	100027f3          	csrr	a5,sstatus
ffffffffc0202994:	8b89                	andi	a5,a5,2
ffffffffc0202996:	eb89                	bnez	a5,ffffffffc02029a8 <kfree+0x6a>
    { pmm_manager->free_pages(base, n); }
ffffffffc0202998:	0000f797          	auipc	a5,0xf
ffffffffc020299c:	b987b783          	ld	a5,-1128(a5) # ffffffffc0211530 <pmm_manager>
    // 通过kva2page函数将传入的内存块指针（ptr）转换为对应的页面结构体指针，找到该内存块所对应的起始物理页面结构体，将其存储在base变量中，以便后续调用free_pages函数进行页面释放操作。
    base = kva2page(ptr);
    // 调用free_pages函数释放由base指针指向的起始位置的指定数量（num_pages）的页面，将这些页面占用的物理内存释放回空闲内存池，完成内存回收操作，使这些内存可以被后续的内存分配请求再次使用。
    free_pages(base, num_pages);
}
ffffffffc02029a0:	60e2                	ld	ra,24(sp)
    { pmm_manager->free_pages(base, n); }
ffffffffc02029a2:	739c                	ld	a5,32(a5)
}
ffffffffc02029a4:	6105                	addi	sp,sp,32
    { pmm_manager->free_pages(base, n); }
ffffffffc02029a6:	8782                	jr	a5
        intr_disable();
ffffffffc02029a8:	e42a                	sd	a0,8(sp)
ffffffffc02029aa:	e02e                	sd	a1,0(sp)
ffffffffc02029ac:	b43fd0ef          	jal	ra,ffffffffc02004ee <intr_disable>
ffffffffc02029b0:	0000f797          	auipc	a5,0xf
ffffffffc02029b4:	b807b783          	ld	a5,-1152(a5) # ffffffffc0211530 <pmm_manager>
ffffffffc02029b8:	6582                	ld	a1,0(sp)
ffffffffc02029ba:	6522                	ld	a0,8(sp)
ffffffffc02029bc:	739c                	ld	a5,32(a5)
ffffffffc02029be:	9782                	jalr	a5
}
ffffffffc02029c0:	60e2                	ld	ra,24(sp)
ffffffffc02029c2:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02029c4:	b25fd06f          	j	ffffffffc02004e8 <intr_enable>
ffffffffc02029c8:	ccdfe0ef          	jal	ra,ffffffffc0201694 <pa2page.part.0>
static inline struct Page *kva2page(void *kva) { return pa2page(PADDR(kva)); }
ffffffffc02029cc:	86aa                	mv	a3,a0
ffffffffc02029ce:	00003617          	auipc	a2,0x3
ffffffffc02029d2:	9ea60613          	addi	a2,a2,-1558 # ffffffffc02053b8 <default_pmm_manager+0x168>
ffffffffc02029d6:	08900593          	li	a1,137
ffffffffc02029da:	00003517          	auipc	a0,0x3
ffffffffc02029de:	8ee50513          	addi	a0,a0,-1810 # ffffffffc02052c8 <default_pmm_manager+0x78>
ffffffffc02029e2:	993fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(ptr!= NULL);
ffffffffc02029e6:	00003697          	auipc	a3,0x3
ffffffffc02029ea:	f0268693          	addi	a3,a3,-254 # ffffffffc02058e8 <default_pmm_manager+0x698>
ffffffffc02029ee:	00002617          	auipc	a2,0x2
ffffffffc02029f2:	4b260613          	addi	a2,a2,1202 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02029f6:	28400593          	li	a1,644
ffffffffc02029fa:	00003517          	auipc	a0,0x3
ffffffffc02029fe:	92650513          	addi	a0,a0,-1754 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc0202a02:	973fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(n > 0 && n < 1024 * 0124);
ffffffffc0202a06:	00003697          	auipc	a3,0x3
ffffffffc0202a0a:	eb268693          	addi	a3,a3,-334 # ffffffffc02058b8 <default_pmm_manager+0x668>
ffffffffc0202a0e:	00002617          	auipc	a2,0x2
ffffffffc0202a12:	49260613          	addi	a2,a2,1170 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202a16:	28200593          	li	a1,642
ffffffffc0202a1a:	00003517          	auipc	a0,0x3
ffffffffc0202a1e:	90650513          	addi	a0,a0,-1786 # ffffffffc0205320 <default_pmm_manager+0xd0>
ffffffffc0202a22:	953fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0202a26 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0202a26:	7135                	addi	sp,sp,-160
ffffffffc0202a28:	ed06                	sd	ra,152(sp)
ffffffffc0202a2a:	e922                	sd	s0,144(sp)
ffffffffc0202a2c:	e526                	sd	s1,136(sp)
ffffffffc0202a2e:	e14a                	sd	s2,128(sp)
ffffffffc0202a30:	fcce                	sd	s3,120(sp)
ffffffffc0202a32:	f8d2                	sd	s4,112(sp)
ffffffffc0202a34:	f4d6                	sd	s5,104(sp)
ffffffffc0202a36:	f0da                	sd	s6,96(sp)
ffffffffc0202a38:	ecde                	sd	s7,88(sp)
ffffffffc0202a3a:	e8e2                	sd	s8,80(sp)
ffffffffc0202a3c:	e4e6                	sd	s9,72(sp)
ffffffffc0202a3e:	e0ea                	sd	s10,64(sp)
ffffffffc0202a40:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc0202a42:	416010ef          	jal	ra,ffffffffc0203e58 <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0202a46:	0000f697          	auipc	a3,0xf
ffffffffc0202a4a:	afa6b683          	ld	a3,-1286(a3) # ffffffffc0211540 <max_swap_offset>
ffffffffc0202a4e:	010007b7          	lui	a5,0x1000
ffffffffc0202a52:	ff968713          	addi	a4,a3,-7
ffffffffc0202a56:	17e1                	addi	a5,a5,-8
ffffffffc0202a58:	3ee7e063          	bltu	a5,a4,ffffffffc0202e38 <swap_init+0x412>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }

     //sm = &swap_manager_fifo;//use first in first out Page Replacement Algorithm
     sm = &swap_manager_clock;
ffffffffc0202a5c:	00007797          	auipc	a5,0x7
ffffffffc0202a60:	5a478793          	addi	a5,a5,1444 # ffffffffc020a000 <swap_manager_clock>
     int r = sm->init();
ffffffffc0202a64:	6798                	ld	a4,8(a5)
     sm = &swap_manager_clock;
ffffffffc0202a66:	0000fb17          	auipc	s6,0xf
ffffffffc0202a6a:	ae2b0b13          	addi	s6,s6,-1310 # ffffffffc0211548 <sm>
ffffffffc0202a6e:	00fb3023          	sd	a5,0(s6)
     int r = sm->init();
ffffffffc0202a72:	9702                	jalr	a4
ffffffffc0202a74:	89aa                	mv	s3,a0
     
     if (r == 0)
ffffffffc0202a76:	c10d                	beqz	a0,ffffffffc0202a98 <swap_init+0x72>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc0202a78:	60ea                	ld	ra,152(sp)
ffffffffc0202a7a:	644a                	ld	s0,144(sp)
ffffffffc0202a7c:	64aa                	ld	s1,136(sp)
ffffffffc0202a7e:	690a                	ld	s2,128(sp)
ffffffffc0202a80:	7a46                	ld	s4,112(sp)
ffffffffc0202a82:	7aa6                	ld	s5,104(sp)
ffffffffc0202a84:	7b06                	ld	s6,96(sp)
ffffffffc0202a86:	6be6                	ld	s7,88(sp)
ffffffffc0202a88:	6c46                	ld	s8,80(sp)
ffffffffc0202a8a:	6ca6                	ld	s9,72(sp)
ffffffffc0202a8c:	6d06                	ld	s10,64(sp)
ffffffffc0202a8e:	7de2                	ld	s11,56(sp)
ffffffffc0202a90:	854e                	mv	a0,s3
ffffffffc0202a92:	79e6                	ld	s3,120(sp)
ffffffffc0202a94:	610d                	addi	sp,sp,160
ffffffffc0202a96:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202a98:	000b3783          	ld	a5,0(s6)
ffffffffc0202a9c:	00003517          	auipc	a0,0x3
ffffffffc0202aa0:	e8c50513          	addi	a0,a0,-372 # ffffffffc0205928 <default_pmm_manager+0x6d8>
    return listelm->next;
ffffffffc0202aa4:	0000e497          	auipc	s1,0xe
ffffffffc0202aa8:	59c48493          	addi	s1,s1,1436 # ffffffffc0211040 <free_area>
ffffffffc0202aac:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc0202aae:	4785                	li	a5,1
ffffffffc0202ab0:	0000f717          	auipc	a4,0xf
ffffffffc0202ab4:	aaf72023          	sw	a5,-1376(a4) # ffffffffc0211550 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc0202ab8:	e02fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
ffffffffc0202abc:	649c                	ld	a5,8(s1)

static void
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
ffffffffc0202abe:	4401                	li	s0,0
ffffffffc0202ac0:	4d01                	li	s10,0
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202ac2:	2c978163          	beq	a5,s1,ffffffffc0202d84 <swap_init+0x35e>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0202ac6:	fe87b703          	ld	a4,-24(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0202aca:	8b09                	andi	a4,a4,2
ffffffffc0202acc:	2a070e63          	beqz	a4,ffffffffc0202d88 <swap_init+0x362>
        count ++, total += p->property;
ffffffffc0202ad0:	ff87a703          	lw	a4,-8(a5)
ffffffffc0202ad4:	679c                	ld	a5,8(a5)
ffffffffc0202ad6:	2d05                	addiw	s10,s10,1
ffffffffc0202ad8:	9c39                	addw	s0,s0,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202ada:	fe9796e3          	bne	a5,s1,ffffffffc0202ac6 <swap_init+0xa0>
     }
     assert(total == nr_free_pages());
ffffffffc0202ade:	8922                	mv	s2,s0
ffffffffc0202ae0:	cbffe0ef          	jal	ra,ffffffffc020179e <nr_free_pages>
ffffffffc0202ae4:	47251663          	bne	a0,s2,ffffffffc0202f50 <swap_init+0x52a>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0202ae8:	8622                	mv	a2,s0
ffffffffc0202aea:	85ea                	mv	a1,s10
ffffffffc0202aec:	00003517          	auipc	a0,0x3
ffffffffc0202af0:	e5450513          	addi	a0,a0,-428 # ffffffffc0205940 <default_pmm_manager+0x6f0>
ffffffffc0202af4:	dc6fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0202af8:	2d5000ef          	jal	ra,ffffffffc02035cc <mm_create>
ffffffffc0202afc:	8aaa                	mv	s5,a0
     assert(mm != NULL);
ffffffffc0202afe:	52050963          	beqz	a0,ffffffffc0203030 <swap_init+0x60a>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc0202b02:	0000f797          	auipc	a5,0xf
ffffffffc0202b06:	a5e78793          	addi	a5,a5,-1442 # ffffffffc0211560 <check_mm_struct>
ffffffffc0202b0a:	6398                	ld	a4,0(a5)
ffffffffc0202b0c:	54071263          	bnez	a4,ffffffffc0203050 <swap_init+0x62a>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202b10:	0000fb97          	auipc	s7,0xf
ffffffffc0202b14:	a08bbb83          	ld	s7,-1528(s7) # ffffffffc0211518 <boot_pgdir>
     assert(pgdir[0] == 0);
ffffffffc0202b18:	000bb703          	ld	a4,0(s7)
     check_mm_struct = mm;
ffffffffc0202b1c:	e388                	sd	a0,0(a5)
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0202b1e:	01753c23          	sd	s7,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0202b22:	3c071763          	bnez	a4,ffffffffc0202ef0 <swap_init+0x4ca>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc0202b26:	6599                	lui	a1,0x6
ffffffffc0202b28:	460d                	li	a2,3
ffffffffc0202b2a:	6505                	lui	a0,0x1
ffffffffc0202b2c:	2e9000ef          	jal	ra,ffffffffc0203614 <vma_create>
ffffffffc0202b30:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0202b32:	3c050f63          	beqz	a0,ffffffffc0202f10 <swap_init+0x4ea>

     insert_vma_struct(mm, vma);
ffffffffc0202b36:	8556                	mv	a0,s5
ffffffffc0202b38:	34b000ef          	jal	ra,ffffffffc0203682 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0202b3c:	00003517          	auipc	a0,0x3
ffffffffc0202b40:	e7450513          	addi	a0,a0,-396 # ffffffffc02059b0 <default_pmm_manager+0x760>
ffffffffc0202b44:	d76fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc0202b48:	018ab503          	ld	a0,24(s5)
ffffffffc0202b4c:	4605                	li	a2,1
ffffffffc0202b4e:	6585                	lui	a1,0x1
ffffffffc0202b50:	c89fe0ef          	jal	ra,ffffffffc02017d8 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc0202b54:	3c050e63          	beqz	a0,ffffffffc0202f30 <swap_init+0x50a>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202b58:	00003517          	auipc	a0,0x3
ffffffffc0202b5c:	ea850513          	addi	a0,a0,-344 # ffffffffc0205a00 <default_pmm_manager+0x7b0>
ffffffffc0202b60:	0000e917          	auipc	s2,0xe
ffffffffc0202b64:	51890913          	addi	s2,s2,1304 # ffffffffc0211078 <check_rp>
ffffffffc0202b68:	d52fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b6c:	0000ea17          	auipc	s4,0xe
ffffffffc0202b70:	52ca0a13          	addi	s4,s4,1324 # ffffffffc0211098 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc0202b74:	8c4a                	mv	s8,s2
          check_rp[i] = alloc_page();
ffffffffc0202b76:	4505                	li	a0,1
ffffffffc0202b78:	b55fe0ef          	jal	ra,ffffffffc02016cc <alloc_pages>
ffffffffc0202b7c:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc0202b80:	28050c63          	beqz	a0,ffffffffc0202e18 <swap_init+0x3f2>
ffffffffc0202b84:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc0202b86:	8b89                	andi	a5,a5,2
ffffffffc0202b88:	26079863          	bnez	a5,ffffffffc0202df8 <swap_init+0x3d2>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202b8c:	0c21                	addi	s8,s8,8
ffffffffc0202b8e:	ff4c14e3          	bne	s8,s4,ffffffffc0202b76 <swap_init+0x150>
     }
     list_entry_t free_list_store = free_list;
ffffffffc0202b92:	609c                	ld	a5,0(s1)
ffffffffc0202b94:	0084bd83          	ld	s11,8(s1)
    elm->prev = elm->next = elm;
ffffffffc0202b98:	e084                	sd	s1,0(s1)
ffffffffc0202b9a:	f03e                	sd	a5,32(sp)
     list_init(&free_list);
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
ffffffffc0202b9c:	489c                	lw	a5,16(s1)
ffffffffc0202b9e:	e484                	sd	s1,8(s1)
     nr_free = 0;
ffffffffc0202ba0:	0000ec17          	auipc	s8,0xe
ffffffffc0202ba4:	4d8c0c13          	addi	s8,s8,1240 # ffffffffc0211078 <check_rp>
     unsigned int nr_free_store = nr_free;
ffffffffc0202ba8:	f43e                	sd	a5,40(sp)
     nr_free = 0;
ffffffffc0202baa:	0000e797          	auipc	a5,0xe
ffffffffc0202bae:	4a07a323          	sw	zero,1190(a5) # ffffffffc0211050 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0202bb2:	000c3503          	ld	a0,0(s8)
ffffffffc0202bb6:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202bb8:	0c21                	addi	s8,s8,8
        free_pages(check_rp[i],1);
ffffffffc0202bba:	ba5fe0ef          	jal	ra,ffffffffc020175e <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202bbe:	ff4c1ae3          	bne	s8,s4,ffffffffc0202bb2 <swap_init+0x18c>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0202bc2:	0104ac03          	lw	s8,16(s1)
ffffffffc0202bc6:	4791                	li	a5,4
ffffffffc0202bc8:	4afc1463          	bne	s8,a5,ffffffffc0203070 <swap_init+0x64a>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc0202bcc:	00003517          	auipc	a0,0x3
ffffffffc0202bd0:	ebc50513          	addi	a0,a0,-324 # ffffffffc0205a88 <default_pmm_manager+0x838>
ffffffffc0202bd4:	ce6fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202bd8:	6605                	lui	a2,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc0202bda:	0000f797          	auipc	a5,0xf
ffffffffc0202bde:	9807a723          	sw	zero,-1650(a5) # ffffffffc0211568 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0202be2:	4529                	li	a0,10
ffffffffc0202be4:	00a60023          	sb	a0,0(a2) # 1000 <kern_entry-0xffffffffc01ff000>
     assert(pgfault_num==1);
ffffffffc0202be8:	0000f597          	auipc	a1,0xf
ffffffffc0202bec:	9805a583          	lw	a1,-1664(a1) # ffffffffc0211568 <pgfault_num>
ffffffffc0202bf0:	4805                	li	a6,1
ffffffffc0202bf2:	0000f797          	auipc	a5,0xf
ffffffffc0202bf6:	97678793          	addi	a5,a5,-1674 # ffffffffc0211568 <pgfault_num>
ffffffffc0202bfa:	3f059b63          	bne	a1,a6,ffffffffc0202ff0 <swap_init+0x5ca>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc0202bfe:	00a60823          	sb	a0,16(a2)
     assert(pgfault_num==1);
ffffffffc0202c02:	4390                	lw	a2,0(a5)
ffffffffc0202c04:	2601                	sext.w	a2,a2
ffffffffc0202c06:	40b61563          	bne	a2,a1,ffffffffc0203010 <swap_init+0x5ea>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0202c0a:	6589                	lui	a1,0x2
ffffffffc0202c0c:	452d                	li	a0,11
ffffffffc0202c0e:	00a58023          	sb	a0,0(a1) # 2000 <kern_entry-0xffffffffc01fe000>
     assert(pgfault_num==2);
ffffffffc0202c12:	4390                	lw	a2,0(a5)
ffffffffc0202c14:	4809                	li	a6,2
ffffffffc0202c16:	2601                	sext.w	a2,a2
ffffffffc0202c18:	35061c63          	bne	a2,a6,ffffffffc0202f70 <swap_init+0x54a>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc0202c1c:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==2);
ffffffffc0202c20:	438c                	lw	a1,0(a5)
ffffffffc0202c22:	2581                	sext.w	a1,a1
ffffffffc0202c24:	36c59663          	bne	a1,a2,ffffffffc0202f90 <swap_init+0x56a>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0202c28:	658d                	lui	a1,0x3
ffffffffc0202c2a:	4531                	li	a0,12
ffffffffc0202c2c:	00a58023          	sb	a0,0(a1) # 3000 <kern_entry-0xffffffffc01fd000>
     assert(pgfault_num==3);
ffffffffc0202c30:	4390                	lw	a2,0(a5)
ffffffffc0202c32:	480d                	li	a6,3
ffffffffc0202c34:	2601                	sext.w	a2,a2
ffffffffc0202c36:	37061d63          	bne	a2,a6,ffffffffc0202fb0 <swap_init+0x58a>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0202c3a:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==3);
ffffffffc0202c3e:	438c                	lw	a1,0(a5)
ffffffffc0202c40:	2581                	sext.w	a1,a1
ffffffffc0202c42:	38c59763          	bne	a1,a2,ffffffffc0202fd0 <swap_init+0x5aa>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0202c46:	6591                	lui	a1,0x4
ffffffffc0202c48:	4535                	li	a0,13
ffffffffc0202c4a:	00a58023          	sb	a0,0(a1) # 4000 <kern_entry-0xffffffffc01fc000>
     assert(pgfault_num==4);
ffffffffc0202c4e:	4390                	lw	a2,0(a5)
ffffffffc0202c50:	2601                	sext.w	a2,a2
ffffffffc0202c52:	21861f63          	bne	a2,s8,ffffffffc0202e70 <swap_init+0x44a>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc0202c56:	00a58823          	sb	a0,16(a1)
     assert(pgfault_num==4);
ffffffffc0202c5a:	439c                	lw	a5,0(a5)
ffffffffc0202c5c:	2781                	sext.w	a5,a5
ffffffffc0202c5e:	22c79963          	bne	a5,a2,ffffffffc0202e90 <swap_init+0x46a>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc0202c62:	489c                	lw	a5,16(s1)
ffffffffc0202c64:	24079663          	bnez	a5,ffffffffc0202eb0 <swap_init+0x48a>
ffffffffc0202c68:	0000e797          	auipc	a5,0xe
ffffffffc0202c6c:	43078793          	addi	a5,a5,1072 # ffffffffc0211098 <swap_in_seq_no>
ffffffffc0202c70:	0000e617          	auipc	a2,0xe
ffffffffc0202c74:	45060613          	addi	a2,a2,1104 # ffffffffc02110c0 <swap_out_seq_no>
ffffffffc0202c78:	0000e517          	auipc	a0,0xe
ffffffffc0202c7c:	44850513          	addi	a0,a0,1096 # ffffffffc02110c0 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc0202c80:	55fd                	li	a1,-1
ffffffffc0202c82:	c38c                	sw	a1,0(a5)
ffffffffc0202c84:	c20c                	sw	a1,0(a2)
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc0202c86:	0791                	addi	a5,a5,4
ffffffffc0202c88:	0611                	addi	a2,a2,4
ffffffffc0202c8a:	fef51ce3          	bne	a0,a5,ffffffffc0202c82 <swap_init+0x25c>
ffffffffc0202c8e:	0000e817          	auipc	a6,0xe
ffffffffc0202c92:	3ca80813          	addi	a6,a6,970 # ffffffffc0211058 <check_ptep>
ffffffffc0202c96:	0000e897          	auipc	a7,0xe
ffffffffc0202c9a:	3e288893          	addi	a7,a7,994 # ffffffffc0211078 <check_rp>
ffffffffc0202c9e:	6585                	lui	a1,0x1
    return &pages[PPN(pa) - nbase];
ffffffffc0202ca0:	0000fc97          	auipc	s9,0xf
ffffffffc0202ca4:	888c8c93          	addi	s9,s9,-1912 # ffffffffc0211528 <pages>
ffffffffc0202ca8:	00003c17          	auipc	s8,0x3
ffffffffc0202cac:	698c0c13          	addi	s8,s8,1688 # ffffffffc0206340 <nbase>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0202cb0:	00083023          	sd	zero,0(a6)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202cb4:	4601                	li	a2,0
ffffffffc0202cb6:	855e                	mv	a0,s7
ffffffffc0202cb8:	ec46                	sd	a7,24(sp)
ffffffffc0202cba:	e82e                	sd	a1,16(sp)
         check_ptep[i]=0;
ffffffffc0202cbc:	e442                	sd	a6,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202cbe:	b1bfe0ef          	jal	ra,ffffffffc02017d8 <get_pte>
ffffffffc0202cc2:	6822                	ld	a6,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc0202cc4:	65c2                	ld	a1,16(sp)
ffffffffc0202cc6:	68e2                	ld	a7,24(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0202cc8:	00a83023          	sd	a0,0(a6)
         assert(check_ptep[i] != NULL);
ffffffffc0202ccc:	0000f317          	auipc	t1,0xf
ffffffffc0202cd0:	85430313          	addi	t1,t1,-1964 # ffffffffc0211520 <npage>
ffffffffc0202cd4:	16050e63          	beqz	a0,ffffffffc0202e50 <swap_init+0x42a>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202cd8:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0202cda:	0017f613          	andi	a2,a5,1
ffffffffc0202cde:	0e060563          	beqz	a2,ffffffffc0202dc8 <swap_init+0x3a2>
    if (PPN(pa) >= npage) {
ffffffffc0202ce2:	00033603          	ld	a2,0(t1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202ce6:	078a                	slli	a5,a5,0x2
ffffffffc0202ce8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202cea:	0ec7fb63          	bgeu	a5,a2,ffffffffc0202de0 <swap_init+0x3ba>
    return &pages[PPN(pa) - nbase];
ffffffffc0202cee:	000c3603          	ld	a2,0(s8)
ffffffffc0202cf2:	000cb503          	ld	a0,0(s9)
ffffffffc0202cf6:	0008bf03          	ld	t5,0(a7)
ffffffffc0202cfa:	8f91                	sub	a5,a5,a2
ffffffffc0202cfc:	00379613          	slli	a2,a5,0x3
ffffffffc0202d00:	97b2                	add	a5,a5,a2
ffffffffc0202d02:	078e                	slli	a5,a5,0x3
ffffffffc0202d04:	97aa                	add	a5,a5,a0
ffffffffc0202d06:	0aff1163          	bne	t5,a5,ffffffffc0202da8 <swap_init+0x382>
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202d0a:	6785                	lui	a5,0x1
ffffffffc0202d0c:	95be                	add	a1,a1,a5
ffffffffc0202d0e:	6795                	lui	a5,0x5
ffffffffc0202d10:	0821                	addi	a6,a6,8
ffffffffc0202d12:	08a1                	addi	a7,a7,8
ffffffffc0202d14:	f8f59ee3          	bne	a1,a5,ffffffffc0202cb0 <swap_init+0x28a>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc0202d18:	00003517          	auipc	a0,0x3
ffffffffc0202d1c:	e1850513          	addi	a0,a0,-488 # ffffffffc0205b30 <default_pmm_manager+0x8e0>
ffffffffc0202d20:	b9afd0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = sm->check_swap();
ffffffffc0202d24:	000b3783          	ld	a5,0(s6)
ffffffffc0202d28:	7f9c                	ld	a5,56(a5)
ffffffffc0202d2a:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0202d2c:	1a051263          	bnez	a0,ffffffffc0202ed0 <swap_init+0x4aa>
     
     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc0202d30:	00093503          	ld	a0,0(s2)
ffffffffc0202d34:	4585                	li	a1,1
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202d36:	0921                	addi	s2,s2,8
         free_pages(check_rp[i],1);
ffffffffc0202d38:	a27fe0ef          	jal	ra,ffffffffc020175e <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0202d3c:	ff491ae3          	bne	s2,s4,ffffffffc0202d30 <swap_init+0x30a>
     } 

     //free_page(pte2page(*temp_ptep));
     
     mm_destroy(mm);
ffffffffc0202d40:	8556                	mv	a0,s5
ffffffffc0202d42:	211000ef          	jal	ra,ffffffffc0203752 <mm_destroy>
         
     nr_free = nr_free_store;
ffffffffc0202d46:	77a2                	ld	a5,40(sp)
     free_list = free_list_store;
ffffffffc0202d48:	01b4b423          	sd	s11,8(s1)
     nr_free = nr_free_store;
ffffffffc0202d4c:	c89c                	sw	a5,16(s1)
     free_list = free_list_store;
ffffffffc0202d4e:	7782                	ld	a5,32(sp)
ffffffffc0202d50:	e09c                	sd	a5,0(s1)

     
     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202d52:	009d8a63          	beq	s11,s1,ffffffffc0202d66 <swap_init+0x340>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0202d56:	ff8da783          	lw	a5,-8(s11)
    return listelm->next;
ffffffffc0202d5a:	008dbd83          	ld	s11,8(s11)
ffffffffc0202d5e:	3d7d                	addiw	s10,s10,-1
ffffffffc0202d60:	9c1d                	subw	s0,s0,a5
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202d62:	fe9d9ae3          	bne	s11,s1,ffffffffc0202d56 <swap_init+0x330>
     }
     cprintf("count is %d, total is %d\n",count,total);
ffffffffc0202d66:	8622                	mv	a2,s0
ffffffffc0202d68:	85ea                	mv	a1,s10
ffffffffc0202d6a:	00003517          	auipc	a0,0x3
ffffffffc0202d6e:	df650513          	addi	a0,a0,-522 # ffffffffc0205b60 <default_pmm_manager+0x910>
ffffffffc0202d72:	b48fd0ef          	jal	ra,ffffffffc02000ba <cprintf>
     //assert(count == 0);
     
     cprintf("check_swap() succeeded!\n");
ffffffffc0202d76:	00003517          	auipc	a0,0x3
ffffffffc0202d7a:	e0a50513          	addi	a0,a0,-502 # ffffffffc0205b80 <default_pmm_manager+0x930>
ffffffffc0202d7e:	b3cfd0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0202d82:	b9dd                	j	ffffffffc0202a78 <swap_init+0x52>
     while ((le = list_next(le)) != &free_list) {
ffffffffc0202d84:	4901                	li	s2,0
ffffffffc0202d86:	bba9                	j	ffffffffc0202ae0 <swap_init+0xba>
        assert(PageProperty(p));
ffffffffc0202d88:	00002697          	auipc	a3,0x2
ffffffffc0202d8c:	10868693          	addi	a3,a3,264 # ffffffffc0204e90 <commands+0x728>
ffffffffc0202d90:	00002617          	auipc	a2,0x2
ffffffffc0202d94:	11060613          	addi	a2,a2,272 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202d98:	0bc00593          	li	a1,188
ffffffffc0202d9c:	00003517          	auipc	a0,0x3
ffffffffc0202da0:	b7c50513          	addi	a0,a0,-1156 # ffffffffc0205918 <default_pmm_manager+0x6c8>
ffffffffc0202da4:	dd0fd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0202da8:	00003697          	auipc	a3,0x3
ffffffffc0202dac:	d6068693          	addi	a3,a3,-672 # ffffffffc0205b08 <default_pmm_manager+0x8b8>
ffffffffc0202db0:	00002617          	auipc	a2,0x2
ffffffffc0202db4:	0f060613          	addi	a2,a2,240 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202db8:	0fc00593          	li	a1,252
ffffffffc0202dbc:	00003517          	auipc	a0,0x3
ffffffffc0202dc0:	b5c50513          	addi	a0,a0,-1188 # ffffffffc0205918 <default_pmm_manager+0x6c8>
ffffffffc0202dc4:	db0fd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202dc8:	00002617          	auipc	a2,0x2
ffffffffc0202dcc:	4d860613          	addi	a2,a2,1240 # ffffffffc02052a0 <default_pmm_manager+0x50>
ffffffffc0202dd0:	08e00593          	li	a1,142
ffffffffc0202dd4:	00002517          	auipc	a0,0x2
ffffffffc0202dd8:	4f450513          	addi	a0,a0,1268 # ffffffffc02052c8 <default_pmm_manager+0x78>
ffffffffc0202ddc:	d98fd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202de0:	00002617          	auipc	a2,0x2
ffffffffc0202de4:	4f860613          	addi	a2,a2,1272 # ffffffffc02052d8 <default_pmm_manager+0x88>
ffffffffc0202de8:	08000593          	li	a1,128
ffffffffc0202dec:	00002517          	auipc	a0,0x2
ffffffffc0202df0:	4dc50513          	addi	a0,a0,1244 # ffffffffc02052c8 <default_pmm_manager+0x78>
ffffffffc0202df4:	d80fd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc0202df8:	00003697          	auipc	a3,0x3
ffffffffc0202dfc:	c4868693          	addi	a3,a3,-952 # ffffffffc0205a40 <default_pmm_manager+0x7f0>
ffffffffc0202e00:	00002617          	auipc	a2,0x2
ffffffffc0202e04:	0a060613          	addi	a2,a2,160 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202e08:	0dd00593          	li	a1,221
ffffffffc0202e0c:	00003517          	auipc	a0,0x3
ffffffffc0202e10:	b0c50513          	addi	a0,a0,-1268 # ffffffffc0205918 <default_pmm_manager+0x6c8>
ffffffffc0202e14:	d60fd0ef          	jal	ra,ffffffffc0200374 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0202e18:	00003697          	auipc	a3,0x3
ffffffffc0202e1c:	c1068693          	addi	a3,a3,-1008 # ffffffffc0205a28 <default_pmm_manager+0x7d8>
ffffffffc0202e20:	00002617          	auipc	a2,0x2
ffffffffc0202e24:	08060613          	addi	a2,a2,128 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202e28:	0dc00593          	li	a1,220
ffffffffc0202e2c:	00003517          	auipc	a0,0x3
ffffffffc0202e30:	aec50513          	addi	a0,a0,-1300 # ffffffffc0205918 <default_pmm_manager+0x6c8>
ffffffffc0202e34:	d40fd0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0202e38:	00003617          	auipc	a2,0x3
ffffffffc0202e3c:	ac060613          	addi	a2,a2,-1344 # ffffffffc02058f8 <default_pmm_manager+0x6a8>
ffffffffc0202e40:	02800593          	li	a1,40
ffffffffc0202e44:	00003517          	auipc	a0,0x3
ffffffffc0202e48:	ad450513          	addi	a0,a0,-1324 # ffffffffc0205918 <default_pmm_manager+0x6c8>
ffffffffc0202e4c:	d28fd0ef          	jal	ra,ffffffffc0200374 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0202e50:	00003697          	auipc	a3,0x3
ffffffffc0202e54:	ca068693          	addi	a3,a3,-864 # ffffffffc0205af0 <default_pmm_manager+0x8a0>
ffffffffc0202e58:	00002617          	auipc	a2,0x2
ffffffffc0202e5c:	04860613          	addi	a2,a2,72 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202e60:	0fb00593          	li	a1,251
ffffffffc0202e64:	00003517          	auipc	a0,0x3
ffffffffc0202e68:	ab450513          	addi	a0,a0,-1356 # ffffffffc0205918 <default_pmm_manager+0x6c8>
ffffffffc0202e6c:	d08fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==4);
ffffffffc0202e70:	00003697          	auipc	a3,0x3
ffffffffc0202e74:	c7068693          	addi	a3,a3,-912 # ffffffffc0205ae0 <default_pmm_manager+0x890>
ffffffffc0202e78:	00002617          	auipc	a2,0x2
ffffffffc0202e7c:	02860613          	addi	a2,a2,40 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202e80:	09f00593          	li	a1,159
ffffffffc0202e84:	00003517          	auipc	a0,0x3
ffffffffc0202e88:	a9450513          	addi	a0,a0,-1388 # ffffffffc0205918 <default_pmm_manager+0x6c8>
ffffffffc0202e8c:	ce8fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==4);
ffffffffc0202e90:	00003697          	auipc	a3,0x3
ffffffffc0202e94:	c5068693          	addi	a3,a3,-944 # ffffffffc0205ae0 <default_pmm_manager+0x890>
ffffffffc0202e98:	00002617          	auipc	a2,0x2
ffffffffc0202e9c:	00860613          	addi	a2,a2,8 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202ea0:	0a100593          	li	a1,161
ffffffffc0202ea4:	00003517          	auipc	a0,0x3
ffffffffc0202ea8:	a7450513          	addi	a0,a0,-1420 # ffffffffc0205918 <default_pmm_manager+0x6c8>
ffffffffc0202eac:	cc8fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert( nr_free == 0);         
ffffffffc0202eb0:	00002697          	auipc	a3,0x2
ffffffffc0202eb4:	1c868693          	addi	a3,a3,456 # ffffffffc0205078 <commands+0x910>
ffffffffc0202eb8:	00002617          	auipc	a2,0x2
ffffffffc0202ebc:	fe860613          	addi	a2,a2,-24 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202ec0:	0f300593          	li	a1,243
ffffffffc0202ec4:	00003517          	auipc	a0,0x3
ffffffffc0202ec8:	a5450513          	addi	a0,a0,-1452 # ffffffffc0205918 <default_pmm_manager+0x6c8>
ffffffffc0202ecc:	ca8fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(ret==0);
ffffffffc0202ed0:	00003697          	auipc	a3,0x3
ffffffffc0202ed4:	c8868693          	addi	a3,a3,-888 # ffffffffc0205b58 <default_pmm_manager+0x908>
ffffffffc0202ed8:	00002617          	auipc	a2,0x2
ffffffffc0202edc:	fc860613          	addi	a2,a2,-56 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202ee0:	10200593          	li	a1,258
ffffffffc0202ee4:	00003517          	auipc	a0,0x3
ffffffffc0202ee8:	a3450513          	addi	a0,a0,-1484 # ffffffffc0205918 <default_pmm_manager+0x6c8>
ffffffffc0202eec:	c88fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0202ef0:	00003697          	auipc	a3,0x3
ffffffffc0202ef4:	aa068693          	addi	a3,a3,-1376 # ffffffffc0205990 <default_pmm_manager+0x740>
ffffffffc0202ef8:	00002617          	auipc	a2,0x2
ffffffffc0202efc:	fa860613          	addi	a2,a2,-88 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202f00:	0cc00593          	li	a1,204
ffffffffc0202f04:	00003517          	auipc	a0,0x3
ffffffffc0202f08:	a1450513          	addi	a0,a0,-1516 # ffffffffc0205918 <default_pmm_manager+0x6c8>
ffffffffc0202f0c:	c68fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(vma != NULL);
ffffffffc0202f10:	00003697          	auipc	a3,0x3
ffffffffc0202f14:	a9068693          	addi	a3,a3,-1392 # ffffffffc02059a0 <default_pmm_manager+0x750>
ffffffffc0202f18:	00002617          	auipc	a2,0x2
ffffffffc0202f1c:	f8860613          	addi	a2,a2,-120 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202f20:	0cf00593          	li	a1,207
ffffffffc0202f24:	00003517          	auipc	a0,0x3
ffffffffc0202f28:	9f450513          	addi	a0,a0,-1548 # ffffffffc0205918 <default_pmm_manager+0x6c8>
ffffffffc0202f2c:	c48fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0202f30:	00003697          	auipc	a3,0x3
ffffffffc0202f34:	ab868693          	addi	a3,a3,-1352 # ffffffffc02059e8 <default_pmm_manager+0x798>
ffffffffc0202f38:	00002617          	auipc	a2,0x2
ffffffffc0202f3c:	f6860613          	addi	a2,a2,-152 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202f40:	0d700593          	li	a1,215
ffffffffc0202f44:	00003517          	auipc	a0,0x3
ffffffffc0202f48:	9d450513          	addi	a0,a0,-1580 # ffffffffc0205918 <default_pmm_manager+0x6c8>
ffffffffc0202f4c:	c28fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(total == nr_free_pages());
ffffffffc0202f50:	00002697          	auipc	a3,0x2
ffffffffc0202f54:	f8068693          	addi	a3,a3,-128 # ffffffffc0204ed0 <commands+0x768>
ffffffffc0202f58:	00002617          	auipc	a2,0x2
ffffffffc0202f5c:	f4860613          	addi	a2,a2,-184 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202f60:	0bf00593          	li	a1,191
ffffffffc0202f64:	00003517          	auipc	a0,0x3
ffffffffc0202f68:	9b450513          	addi	a0,a0,-1612 # ffffffffc0205918 <default_pmm_manager+0x6c8>
ffffffffc0202f6c:	c08fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==2);
ffffffffc0202f70:	00003697          	auipc	a3,0x3
ffffffffc0202f74:	b5068693          	addi	a3,a3,-1200 # ffffffffc0205ac0 <default_pmm_manager+0x870>
ffffffffc0202f78:	00002617          	auipc	a2,0x2
ffffffffc0202f7c:	f2860613          	addi	a2,a2,-216 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202f80:	09700593          	li	a1,151
ffffffffc0202f84:	00003517          	auipc	a0,0x3
ffffffffc0202f88:	99450513          	addi	a0,a0,-1644 # ffffffffc0205918 <default_pmm_manager+0x6c8>
ffffffffc0202f8c:	be8fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==2);
ffffffffc0202f90:	00003697          	auipc	a3,0x3
ffffffffc0202f94:	b3068693          	addi	a3,a3,-1232 # ffffffffc0205ac0 <default_pmm_manager+0x870>
ffffffffc0202f98:	00002617          	auipc	a2,0x2
ffffffffc0202f9c:	f0860613          	addi	a2,a2,-248 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202fa0:	09900593          	li	a1,153
ffffffffc0202fa4:	00003517          	auipc	a0,0x3
ffffffffc0202fa8:	97450513          	addi	a0,a0,-1676 # ffffffffc0205918 <default_pmm_manager+0x6c8>
ffffffffc0202fac:	bc8fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==3);
ffffffffc0202fb0:	00003697          	auipc	a3,0x3
ffffffffc0202fb4:	b2068693          	addi	a3,a3,-1248 # ffffffffc0205ad0 <default_pmm_manager+0x880>
ffffffffc0202fb8:	00002617          	auipc	a2,0x2
ffffffffc0202fbc:	ee860613          	addi	a2,a2,-280 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202fc0:	09b00593          	li	a1,155
ffffffffc0202fc4:	00003517          	auipc	a0,0x3
ffffffffc0202fc8:	95450513          	addi	a0,a0,-1708 # ffffffffc0205918 <default_pmm_manager+0x6c8>
ffffffffc0202fcc:	ba8fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==3);
ffffffffc0202fd0:	00003697          	auipc	a3,0x3
ffffffffc0202fd4:	b0068693          	addi	a3,a3,-1280 # ffffffffc0205ad0 <default_pmm_manager+0x880>
ffffffffc0202fd8:	00002617          	auipc	a2,0x2
ffffffffc0202fdc:	ec860613          	addi	a2,a2,-312 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0202fe0:	09d00593          	li	a1,157
ffffffffc0202fe4:	00003517          	auipc	a0,0x3
ffffffffc0202fe8:	93450513          	addi	a0,a0,-1740 # ffffffffc0205918 <default_pmm_manager+0x6c8>
ffffffffc0202fec:	b88fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==1);
ffffffffc0202ff0:	00003697          	auipc	a3,0x3
ffffffffc0202ff4:	ac068693          	addi	a3,a3,-1344 # ffffffffc0205ab0 <default_pmm_manager+0x860>
ffffffffc0202ff8:	00002617          	auipc	a2,0x2
ffffffffc0202ffc:	ea860613          	addi	a2,a2,-344 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203000:	09300593          	li	a1,147
ffffffffc0203004:	00003517          	auipc	a0,0x3
ffffffffc0203008:	91450513          	addi	a0,a0,-1772 # ffffffffc0205918 <default_pmm_manager+0x6c8>
ffffffffc020300c:	b68fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(pgfault_num==1);
ffffffffc0203010:	00003697          	auipc	a3,0x3
ffffffffc0203014:	aa068693          	addi	a3,a3,-1376 # ffffffffc0205ab0 <default_pmm_manager+0x860>
ffffffffc0203018:	00002617          	auipc	a2,0x2
ffffffffc020301c:	e8860613          	addi	a2,a2,-376 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203020:	09500593          	li	a1,149
ffffffffc0203024:	00003517          	auipc	a0,0x3
ffffffffc0203028:	8f450513          	addi	a0,a0,-1804 # ffffffffc0205918 <default_pmm_manager+0x6c8>
ffffffffc020302c:	b48fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(mm != NULL);
ffffffffc0203030:	00003697          	auipc	a3,0x3
ffffffffc0203034:	93868693          	addi	a3,a3,-1736 # ffffffffc0205968 <default_pmm_manager+0x718>
ffffffffc0203038:	00002617          	auipc	a2,0x2
ffffffffc020303c:	e6860613          	addi	a2,a2,-408 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203040:	0c400593          	li	a1,196
ffffffffc0203044:	00003517          	auipc	a0,0x3
ffffffffc0203048:	8d450513          	addi	a0,a0,-1836 # ffffffffc0205918 <default_pmm_manager+0x6c8>
ffffffffc020304c:	b28fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203050:	00003697          	auipc	a3,0x3
ffffffffc0203054:	92868693          	addi	a3,a3,-1752 # ffffffffc0205978 <default_pmm_manager+0x728>
ffffffffc0203058:	00002617          	auipc	a2,0x2
ffffffffc020305c:	e4860613          	addi	a2,a2,-440 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203060:	0c700593          	li	a1,199
ffffffffc0203064:	00003517          	auipc	a0,0x3
ffffffffc0203068:	8b450513          	addi	a0,a0,-1868 # ffffffffc0205918 <default_pmm_manager+0x6c8>
ffffffffc020306c:	b08fd0ef          	jal	ra,ffffffffc0200374 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203070:	00003697          	auipc	a3,0x3
ffffffffc0203074:	9f068693          	addi	a3,a3,-1552 # ffffffffc0205a60 <default_pmm_manager+0x810>
ffffffffc0203078:	00002617          	auipc	a2,0x2
ffffffffc020307c:	e2860613          	addi	a2,a2,-472 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203080:	0ea00593          	li	a1,234
ffffffffc0203084:	00003517          	auipc	a0,0x3
ffffffffc0203088:	89450513          	addi	a0,a0,-1900 # ffffffffc0205918 <default_pmm_manager+0x6c8>
ffffffffc020308c:	ae8fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203090 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203090:	0000e797          	auipc	a5,0xe
ffffffffc0203094:	4b87b783          	ld	a5,1208(a5) # ffffffffc0211548 <sm>
ffffffffc0203098:	6b9c                	ld	a5,16(a5)
ffffffffc020309a:	8782                	jr	a5

ffffffffc020309c <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc020309c:	0000e797          	auipc	a5,0xe
ffffffffc02030a0:	4ac7b783          	ld	a5,1196(a5) # ffffffffc0211548 <sm>
ffffffffc02030a4:	739c                	ld	a5,32(a5)
ffffffffc02030a6:	8782                	jr	a5

ffffffffc02030a8 <swap_out>:
{
ffffffffc02030a8:	711d                	addi	sp,sp,-96
ffffffffc02030aa:	ec86                	sd	ra,88(sp)
ffffffffc02030ac:	e8a2                	sd	s0,80(sp)
ffffffffc02030ae:	e4a6                	sd	s1,72(sp)
ffffffffc02030b0:	e0ca                	sd	s2,64(sp)
ffffffffc02030b2:	fc4e                	sd	s3,56(sp)
ffffffffc02030b4:	f852                	sd	s4,48(sp)
ffffffffc02030b6:	f456                	sd	s5,40(sp)
ffffffffc02030b8:	f05a                	sd	s6,32(sp)
ffffffffc02030ba:	ec5e                	sd	s7,24(sp)
ffffffffc02030bc:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc02030be:	cde9                	beqz	a1,ffffffffc0203198 <swap_out+0xf0>
ffffffffc02030c0:	8a2e                	mv	s4,a1
ffffffffc02030c2:	892a                	mv	s2,a0
ffffffffc02030c4:	8ab2                	mv	s5,a2
ffffffffc02030c6:	4401                	li	s0,0
ffffffffc02030c8:	0000e997          	auipc	s3,0xe
ffffffffc02030cc:	48098993          	addi	s3,s3,1152 # ffffffffc0211548 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02030d0:	00003b17          	auipc	s6,0x3
ffffffffc02030d4:	b30b0b13          	addi	s6,s6,-1232 # ffffffffc0205c00 <default_pmm_manager+0x9b0>
                    cprintf("SWAP: failed to save\n");
ffffffffc02030d8:	00003b97          	auipc	s7,0x3
ffffffffc02030dc:	b10b8b93          	addi	s7,s7,-1264 # ffffffffc0205be8 <default_pmm_manager+0x998>
ffffffffc02030e0:	a825                	j	ffffffffc0203118 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02030e2:	67a2                	ld	a5,8(sp)
ffffffffc02030e4:	8626                	mv	a2,s1
ffffffffc02030e6:	85a2                	mv	a1,s0
ffffffffc02030e8:	63b4                	ld	a3,64(a5)
ffffffffc02030ea:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc02030ec:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc02030ee:	82b1                	srli	a3,a3,0xc
ffffffffc02030f0:	0685                	addi	a3,a3,1
ffffffffc02030f2:	fc9fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc02030f6:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc02030f8:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc02030fa:	613c                	ld	a5,64(a0)
ffffffffc02030fc:	83b1                	srli	a5,a5,0xc
ffffffffc02030fe:	0785                	addi	a5,a5,1
ffffffffc0203100:	07a2                	slli	a5,a5,0x8
ffffffffc0203102:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203106:	e58fe0ef          	jal	ra,ffffffffc020175e <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc020310a:	01893503          	ld	a0,24(s2)
ffffffffc020310e:	85a6                	mv	a1,s1
ffffffffc0203110:	eb6ff0ef          	jal	ra,ffffffffc02027c6 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203114:	048a0d63          	beq	s4,s0,ffffffffc020316e <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203118:	0009b783          	ld	a5,0(s3)
ffffffffc020311c:	8656                	mv	a2,s5
ffffffffc020311e:	002c                	addi	a1,sp,8
ffffffffc0203120:	7b9c                	ld	a5,48(a5)
ffffffffc0203122:	854a                	mv	a0,s2
ffffffffc0203124:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203126:	e12d                	bnez	a0,ffffffffc0203188 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203128:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020312a:	01893503          	ld	a0,24(s2)
ffffffffc020312e:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203130:	63a4                	ld	s1,64(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203132:	85a6                	mv	a1,s1
ffffffffc0203134:	ea4fe0ef          	jal	ra,ffffffffc02017d8 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203138:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc020313a:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc020313c:	8b85                	andi	a5,a5,1
ffffffffc020313e:	cfb9                	beqz	a5,ffffffffc020319c <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203140:	65a2                	ld	a1,8(sp)
ffffffffc0203142:	61bc                	ld	a5,64(a1)
ffffffffc0203144:	83b1                	srli	a5,a5,0xc
ffffffffc0203146:	0785                	addi	a5,a5,1
ffffffffc0203148:	00879513          	slli	a0,a5,0x8
ffffffffc020314c:	5e1000ef          	jal	ra,ffffffffc0203f2c <swapfs_write>
ffffffffc0203150:	d949                	beqz	a0,ffffffffc02030e2 <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203152:	855e                	mv	a0,s7
ffffffffc0203154:	f67fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203158:	0009b783          	ld	a5,0(s3)
ffffffffc020315c:	6622                	ld	a2,8(sp)
ffffffffc020315e:	4681                	li	a3,0
ffffffffc0203160:	739c                	ld	a5,32(a5)
ffffffffc0203162:	85a6                	mv	a1,s1
ffffffffc0203164:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203166:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203168:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc020316a:	fa8a17e3          	bne	s4,s0,ffffffffc0203118 <swap_out+0x70>
}
ffffffffc020316e:	60e6                	ld	ra,88(sp)
ffffffffc0203170:	8522                	mv	a0,s0
ffffffffc0203172:	6446                	ld	s0,80(sp)
ffffffffc0203174:	64a6                	ld	s1,72(sp)
ffffffffc0203176:	6906                	ld	s2,64(sp)
ffffffffc0203178:	79e2                	ld	s3,56(sp)
ffffffffc020317a:	7a42                	ld	s4,48(sp)
ffffffffc020317c:	7aa2                	ld	s5,40(sp)
ffffffffc020317e:	7b02                	ld	s6,32(sp)
ffffffffc0203180:	6be2                	ld	s7,24(sp)
ffffffffc0203182:	6c42                	ld	s8,16(sp)
ffffffffc0203184:	6125                	addi	sp,sp,96
ffffffffc0203186:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203188:	85a2                	mv	a1,s0
ffffffffc020318a:	00003517          	auipc	a0,0x3
ffffffffc020318e:	a1650513          	addi	a0,a0,-1514 # ffffffffc0205ba0 <default_pmm_manager+0x950>
ffffffffc0203192:	f29fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
                  break;
ffffffffc0203196:	bfe1                	j	ffffffffc020316e <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203198:	4401                	li	s0,0
ffffffffc020319a:	bfd1                	j	ffffffffc020316e <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc020319c:	00003697          	auipc	a3,0x3
ffffffffc02031a0:	a3468693          	addi	a3,a3,-1484 # ffffffffc0205bd0 <default_pmm_manager+0x980>
ffffffffc02031a4:	00002617          	auipc	a2,0x2
ffffffffc02031a8:	cfc60613          	addi	a2,a2,-772 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02031ac:	06800593          	li	a1,104
ffffffffc02031b0:	00002517          	auipc	a0,0x2
ffffffffc02031b4:	76850513          	addi	a0,a0,1896 # ffffffffc0205918 <default_pmm_manager+0x6c8>
ffffffffc02031b8:	9bcfd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02031bc <swap_in>:
{
ffffffffc02031bc:	7179                	addi	sp,sp,-48
ffffffffc02031be:	e84a                	sd	s2,16(sp)
ffffffffc02031c0:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc02031c2:	4505                	li	a0,1
{
ffffffffc02031c4:	ec26                	sd	s1,24(sp)
ffffffffc02031c6:	e44e                	sd	s3,8(sp)
ffffffffc02031c8:	f406                	sd	ra,40(sp)
ffffffffc02031ca:	f022                	sd	s0,32(sp)
ffffffffc02031cc:	84ae                	mv	s1,a1
ffffffffc02031ce:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc02031d0:	cfcfe0ef          	jal	ra,ffffffffc02016cc <alloc_pages>
     assert(result!=NULL);
ffffffffc02031d4:	c129                	beqz	a0,ffffffffc0203216 <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc02031d6:	842a                	mv	s0,a0
ffffffffc02031d8:	01893503          	ld	a0,24(s2)
ffffffffc02031dc:	4601                	li	a2,0
ffffffffc02031de:	85a6                	mv	a1,s1
ffffffffc02031e0:	df8fe0ef          	jal	ra,ffffffffc02017d8 <get_pte>
ffffffffc02031e4:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc02031e6:	6108                	ld	a0,0(a0)
ffffffffc02031e8:	85a2                	mv	a1,s0
ffffffffc02031ea:	4a7000ef          	jal	ra,ffffffffc0203e90 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc02031ee:	00093583          	ld	a1,0(s2)
ffffffffc02031f2:	8626                	mv	a2,s1
ffffffffc02031f4:	00003517          	auipc	a0,0x3
ffffffffc02031f8:	a5c50513          	addi	a0,a0,-1444 # ffffffffc0205c50 <default_pmm_manager+0xa00>
ffffffffc02031fc:	81a1                	srli	a1,a1,0x8
ffffffffc02031fe:	ebdfc0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc0203202:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203204:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203208:	7402                	ld	s0,32(sp)
ffffffffc020320a:	64e2                	ld	s1,24(sp)
ffffffffc020320c:	6942                	ld	s2,16(sp)
ffffffffc020320e:	69a2                	ld	s3,8(sp)
ffffffffc0203210:	4501                	li	a0,0
ffffffffc0203212:	6145                	addi	sp,sp,48
ffffffffc0203214:	8082                	ret
     assert(result!=NULL);
ffffffffc0203216:	00003697          	auipc	a3,0x3
ffffffffc020321a:	a2a68693          	addi	a3,a3,-1494 # ffffffffc0205c40 <default_pmm_manager+0x9f0>
ffffffffc020321e:	00002617          	auipc	a2,0x2
ffffffffc0203222:	c8260613          	addi	a2,a2,-894 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203226:	07e00593          	li	a1,126
ffffffffc020322a:	00002517          	auipc	a0,0x2
ffffffffc020322e:	6ee50513          	addi	a0,a0,1774 # ffffffffc0205918 <default_pmm_manager+0x6c8>
ffffffffc0203232:	942fd0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203236 <_clock_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203236:	0000e797          	auipc	a5,0xe
ffffffffc020323a:	eb278793          	addi	a5,a5,-334 # ffffffffc02110e8 <pra_list_head>
     // 初始化当前指针curr_ptr指向pra_list_head，表示当前页面替换位置为链表头
     // 将mm的私有成员指针指向pra_list_head，用于后续的页面替换算法操作

    list_init(&pra_list_head);
    curr_ptr = &pra_list_head;
    mm->sm_priv = &pra_list_head;
ffffffffc020323e:	f51c                	sd	a5,40(a0)
ffffffffc0203240:	e79c                	sd	a5,8(a5)
ffffffffc0203242:	e39c                	sd	a5,0(a5)
    curr_ptr = &pra_list_head;
ffffffffc0203244:	0000e717          	auipc	a4,0xe
ffffffffc0203248:	30f73a23          	sd	a5,788(a4) # ffffffffc0211558 <curr_ptr>

     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
    return 0;
}
ffffffffc020324c:	4501                	li	a0,0
ffffffffc020324e:	8082                	ret

ffffffffc0203250 <_clock_init>:

static int
_clock_init(void)
{
    return 0;
}
ffffffffc0203250:	4501                	li	a0,0
ffffffffc0203252:	8082                	ret

ffffffffc0203254 <_clock_set_unswappable>:

static int
_clock_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203254:	4501                	li	a0,0
ffffffffc0203256:	8082                	ret

ffffffffc0203258 <_clock_tick_event>:

static int
_clock_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203258:	4501                	li	a0,0
ffffffffc020325a:	8082                	ret

ffffffffc020325c <_clock_check_swap>:
_clock_check_swap(void) {
ffffffffc020325c:	1141                	addi	sp,sp,-16
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc020325e:	4731                	li	a4,12
_clock_check_swap(void) {
ffffffffc0203260:	e406                	sd	ra,8(sp)
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203262:	678d                	lui	a5,0x3
ffffffffc0203264:	00e78023          	sb	a4,0(a5) # 3000 <kern_entry-0xffffffffc01fd000>
    assert(pgfault_num==4);
ffffffffc0203268:	0000e697          	auipc	a3,0xe
ffffffffc020326c:	3006a683          	lw	a3,768(a3) # ffffffffc0211568 <pgfault_num>
ffffffffc0203270:	4711                	li	a4,4
ffffffffc0203272:	0ae69363          	bne	a3,a4,ffffffffc0203318 <_clock_check_swap+0xbc>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203276:	6705                	lui	a4,0x1
ffffffffc0203278:	4629                	li	a2,10
ffffffffc020327a:	0000e797          	auipc	a5,0xe
ffffffffc020327e:	2ee78793          	addi	a5,a5,750 # ffffffffc0211568 <pgfault_num>
ffffffffc0203282:	00c70023          	sb	a2,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
    assert(pgfault_num==4);
ffffffffc0203286:	4398                	lw	a4,0(a5)
ffffffffc0203288:	2701                	sext.w	a4,a4
ffffffffc020328a:	20d71763          	bne	a4,a3,ffffffffc0203498 <_clock_check_swap+0x23c>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc020328e:	6691                	lui	a3,0x4
ffffffffc0203290:	4635                	li	a2,13
ffffffffc0203292:	00c68023          	sb	a2,0(a3) # 4000 <kern_entry-0xffffffffc01fc000>
    assert(pgfault_num==4);
ffffffffc0203296:	4394                	lw	a3,0(a5)
ffffffffc0203298:	2681                	sext.w	a3,a3
ffffffffc020329a:	1ce69f63          	bne	a3,a4,ffffffffc0203478 <_clock_check_swap+0x21c>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc020329e:	6709                	lui	a4,0x2
ffffffffc02032a0:	462d                	li	a2,11
ffffffffc02032a2:	00c70023          	sb	a2,0(a4) # 2000 <kern_entry-0xffffffffc01fe000>
    assert(pgfault_num==4);
ffffffffc02032a6:	4398                	lw	a4,0(a5)
ffffffffc02032a8:	2701                	sext.w	a4,a4
ffffffffc02032aa:	1ad71763          	bne	a4,a3,ffffffffc0203458 <_clock_check_swap+0x1fc>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02032ae:	6715                	lui	a4,0x5
ffffffffc02032b0:	46b9                	li	a3,14
ffffffffc02032b2:	00d70023          	sb	a3,0(a4) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc02032b6:	4398                	lw	a4,0(a5)
ffffffffc02032b8:	4695                	li	a3,5
ffffffffc02032ba:	2701                	sext.w	a4,a4
ffffffffc02032bc:	16d71e63          	bne	a4,a3,ffffffffc0203438 <_clock_check_swap+0x1dc>
    assert(pgfault_num==5);
ffffffffc02032c0:	4394                	lw	a3,0(a5)
ffffffffc02032c2:	2681                	sext.w	a3,a3
ffffffffc02032c4:	14e69a63          	bne	a3,a4,ffffffffc0203418 <_clock_check_swap+0x1bc>
    assert(pgfault_num==5);
ffffffffc02032c8:	4398                	lw	a4,0(a5)
ffffffffc02032ca:	2701                	sext.w	a4,a4
ffffffffc02032cc:	12d71663          	bne	a4,a3,ffffffffc02033f8 <_clock_check_swap+0x19c>
    assert(pgfault_num==5);
ffffffffc02032d0:	4394                	lw	a3,0(a5)
ffffffffc02032d2:	2681                	sext.w	a3,a3
ffffffffc02032d4:	10e69263          	bne	a3,a4,ffffffffc02033d8 <_clock_check_swap+0x17c>
    assert(pgfault_num==5);
ffffffffc02032d8:	4398                	lw	a4,0(a5)
ffffffffc02032da:	2701                	sext.w	a4,a4
ffffffffc02032dc:	0cd71e63          	bne	a4,a3,ffffffffc02033b8 <_clock_check_swap+0x15c>
    assert(pgfault_num==5);
ffffffffc02032e0:	4394                	lw	a3,0(a5)
ffffffffc02032e2:	2681                	sext.w	a3,a3
ffffffffc02032e4:	0ae69a63          	bne	a3,a4,ffffffffc0203398 <_clock_check_swap+0x13c>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc02032e8:	6715                	lui	a4,0x5
ffffffffc02032ea:	46b9                	li	a3,14
ffffffffc02032ec:	00d70023          	sb	a3,0(a4) # 5000 <kern_entry-0xffffffffc01fb000>
    assert(pgfault_num==5);
ffffffffc02032f0:	4398                	lw	a4,0(a5)
ffffffffc02032f2:	4695                	li	a3,5
ffffffffc02032f4:	2701                	sext.w	a4,a4
ffffffffc02032f6:	08d71163          	bne	a4,a3,ffffffffc0203378 <_clock_check_swap+0x11c>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc02032fa:	6705                	lui	a4,0x1
ffffffffc02032fc:	00074683          	lbu	a3,0(a4) # 1000 <kern_entry-0xffffffffc01ff000>
ffffffffc0203300:	4729                	li	a4,10
ffffffffc0203302:	04e69b63          	bne	a3,a4,ffffffffc0203358 <_clock_check_swap+0xfc>
    assert(pgfault_num==6);
ffffffffc0203306:	439c                	lw	a5,0(a5)
ffffffffc0203308:	4719                	li	a4,6
ffffffffc020330a:	2781                	sext.w	a5,a5
ffffffffc020330c:	02e79663          	bne	a5,a4,ffffffffc0203338 <_clock_check_swap+0xdc>
}
ffffffffc0203310:	60a2                	ld	ra,8(sp)
ffffffffc0203312:	4501                	li	a0,0
ffffffffc0203314:	0141                	addi	sp,sp,16
ffffffffc0203316:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203318:	00002697          	auipc	a3,0x2
ffffffffc020331c:	7c868693          	addi	a3,a3,1992 # ffffffffc0205ae0 <default_pmm_manager+0x890>
ffffffffc0203320:	00002617          	auipc	a2,0x2
ffffffffc0203324:	b8060613          	addi	a2,a2,-1152 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203328:	09100593          	li	a1,145
ffffffffc020332c:	00003517          	auipc	a0,0x3
ffffffffc0203330:	96450513          	addi	a0,a0,-1692 # ffffffffc0205c90 <default_pmm_manager+0xa40>
ffffffffc0203334:	840fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==6);
ffffffffc0203338:	00003697          	auipc	a3,0x3
ffffffffc020333c:	9a868693          	addi	a3,a3,-1624 # ffffffffc0205ce0 <default_pmm_manager+0xa90>
ffffffffc0203340:	00002617          	auipc	a2,0x2
ffffffffc0203344:	b6060613          	addi	a2,a2,-1184 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203348:	0a800593          	li	a1,168
ffffffffc020334c:	00003517          	auipc	a0,0x3
ffffffffc0203350:	94450513          	addi	a0,a0,-1724 # ffffffffc0205c90 <default_pmm_manager+0xa40>
ffffffffc0203354:	820fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203358:	00003697          	auipc	a3,0x3
ffffffffc020335c:	96068693          	addi	a3,a3,-1696 # ffffffffc0205cb8 <default_pmm_manager+0xa68>
ffffffffc0203360:	00002617          	auipc	a2,0x2
ffffffffc0203364:	b4060613          	addi	a2,a2,-1216 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203368:	0a600593          	li	a1,166
ffffffffc020336c:	00003517          	auipc	a0,0x3
ffffffffc0203370:	92450513          	addi	a0,a0,-1756 # ffffffffc0205c90 <default_pmm_manager+0xa40>
ffffffffc0203374:	800fd0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc0203378:	00003697          	auipc	a3,0x3
ffffffffc020337c:	93068693          	addi	a3,a3,-1744 # ffffffffc0205ca8 <default_pmm_manager+0xa58>
ffffffffc0203380:	00002617          	auipc	a2,0x2
ffffffffc0203384:	b2060613          	addi	a2,a2,-1248 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203388:	0a500593          	li	a1,165
ffffffffc020338c:	00003517          	auipc	a0,0x3
ffffffffc0203390:	90450513          	addi	a0,a0,-1788 # ffffffffc0205c90 <default_pmm_manager+0xa40>
ffffffffc0203394:	fe1fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc0203398:	00003697          	auipc	a3,0x3
ffffffffc020339c:	91068693          	addi	a3,a3,-1776 # ffffffffc0205ca8 <default_pmm_manager+0xa58>
ffffffffc02033a0:	00002617          	auipc	a2,0x2
ffffffffc02033a4:	b0060613          	addi	a2,a2,-1280 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02033a8:	0a300593          	li	a1,163
ffffffffc02033ac:	00003517          	auipc	a0,0x3
ffffffffc02033b0:	8e450513          	addi	a0,a0,-1820 # ffffffffc0205c90 <default_pmm_manager+0xa40>
ffffffffc02033b4:	fc1fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc02033b8:	00003697          	auipc	a3,0x3
ffffffffc02033bc:	8f068693          	addi	a3,a3,-1808 # ffffffffc0205ca8 <default_pmm_manager+0xa58>
ffffffffc02033c0:	00002617          	auipc	a2,0x2
ffffffffc02033c4:	ae060613          	addi	a2,a2,-1312 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02033c8:	0a100593          	li	a1,161
ffffffffc02033cc:	00003517          	auipc	a0,0x3
ffffffffc02033d0:	8c450513          	addi	a0,a0,-1852 # ffffffffc0205c90 <default_pmm_manager+0xa40>
ffffffffc02033d4:	fa1fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc02033d8:	00003697          	auipc	a3,0x3
ffffffffc02033dc:	8d068693          	addi	a3,a3,-1840 # ffffffffc0205ca8 <default_pmm_manager+0xa58>
ffffffffc02033e0:	00002617          	auipc	a2,0x2
ffffffffc02033e4:	ac060613          	addi	a2,a2,-1344 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02033e8:	09f00593          	li	a1,159
ffffffffc02033ec:	00003517          	auipc	a0,0x3
ffffffffc02033f0:	8a450513          	addi	a0,a0,-1884 # ffffffffc0205c90 <default_pmm_manager+0xa40>
ffffffffc02033f4:	f81fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc02033f8:	00003697          	auipc	a3,0x3
ffffffffc02033fc:	8b068693          	addi	a3,a3,-1872 # ffffffffc0205ca8 <default_pmm_manager+0xa58>
ffffffffc0203400:	00002617          	auipc	a2,0x2
ffffffffc0203404:	aa060613          	addi	a2,a2,-1376 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203408:	09d00593          	li	a1,157
ffffffffc020340c:	00003517          	auipc	a0,0x3
ffffffffc0203410:	88450513          	addi	a0,a0,-1916 # ffffffffc0205c90 <default_pmm_manager+0xa40>
ffffffffc0203414:	f61fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc0203418:	00003697          	auipc	a3,0x3
ffffffffc020341c:	89068693          	addi	a3,a3,-1904 # ffffffffc0205ca8 <default_pmm_manager+0xa58>
ffffffffc0203420:	00002617          	auipc	a2,0x2
ffffffffc0203424:	a8060613          	addi	a2,a2,-1408 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203428:	09b00593          	li	a1,155
ffffffffc020342c:	00003517          	auipc	a0,0x3
ffffffffc0203430:	86450513          	addi	a0,a0,-1948 # ffffffffc0205c90 <default_pmm_manager+0xa40>
ffffffffc0203434:	f41fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==5);
ffffffffc0203438:	00003697          	auipc	a3,0x3
ffffffffc020343c:	87068693          	addi	a3,a3,-1936 # ffffffffc0205ca8 <default_pmm_manager+0xa58>
ffffffffc0203440:	00002617          	auipc	a2,0x2
ffffffffc0203444:	a6060613          	addi	a2,a2,-1440 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203448:	09900593          	li	a1,153
ffffffffc020344c:	00003517          	auipc	a0,0x3
ffffffffc0203450:	84450513          	addi	a0,a0,-1980 # ffffffffc0205c90 <default_pmm_manager+0xa40>
ffffffffc0203454:	f21fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc0203458:	00002697          	auipc	a3,0x2
ffffffffc020345c:	68868693          	addi	a3,a3,1672 # ffffffffc0205ae0 <default_pmm_manager+0x890>
ffffffffc0203460:	00002617          	auipc	a2,0x2
ffffffffc0203464:	a4060613          	addi	a2,a2,-1472 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203468:	09700593          	li	a1,151
ffffffffc020346c:	00003517          	auipc	a0,0x3
ffffffffc0203470:	82450513          	addi	a0,a0,-2012 # ffffffffc0205c90 <default_pmm_manager+0xa40>
ffffffffc0203474:	f01fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc0203478:	00002697          	auipc	a3,0x2
ffffffffc020347c:	66868693          	addi	a3,a3,1640 # ffffffffc0205ae0 <default_pmm_manager+0x890>
ffffffffc0203480:	00002617          	auipc	a2,0x2
ffffffffc0203484:	a2060613          	addi	a2,a2,-1504 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203488:	09500593          	li	a1,149
ffffffffc020348c:	00003517          	auipc	a0,0x3
ffffffffc0203490:	80450513          	addi	a0,a0,-2044 # ffffffffc0205c90 <default_pmm_manager+0xa40>
ffffffffc0203494:	ee1fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgfault_num==4);
ffffffffc0203498:	00002697          	auipc	a3,0x2
ffffffffc020349c:	64868693          	addi	a3,a3,1608 # ffffffffc0205ae0 <default_pmm_manager+0x890>
ffffffffc02034a0:	00002617          	auipc	a2,0x2
ffffffffc02034a4:	a0060613          	addi	a2,a2,-1536 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02034a8:	09300593          	li	a1,147
ffffffffc02034ac:	00002517          	auipc	a0,0x2
ffffffffc02034b0:	7e450513          	addi	a0,a0,2020 # ffffffffc0205c90 <default_pmm_manager+0xa40>
ffffffffc02034b4:	ec1fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02034b8 <_clock_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc02034b8:	7514                	ld	a3,40(a0)
{
ffffffffc02034ba:	1141                	addi	sp,sp,-16
ffffffffc02034bc:	e406                	sd	ra,8(sp)
        assert(head != NULL);
ffffffffc02034be:	c2d1                	beqz	a3,ffffffffc0203542 <_clock_swap_out_victim+0x8a>
    assert(in_tick==0);
ffffffffc02034c0:	e22d                	bnez	a2,ffffffffc0203522 <_clock_swap_out_victim+0x6a>
    return listelm->next;
ffffffffc02034c2:	0000e617          	auipc	a2,0xe
ffffffffc02034c6:	09660613          	addi	a2,a2,150 # ffffffffc0211558 <curr_ptr>
ffffffffc02034ca:	621c                	ld	a5,0(a2)
ffffffffc02034cc:	852e                	mv	a0,a1
ffffffffc02034ce:	678c                	ld	a1,8(a5)
ffffffffc02034d0:	a039                	j	ffffffffc02034de <_clock_swap_out_victim+0x26>
        if(!page->visited) {
ffffffffc02034d2:	fe05b703          	ld	a4,-32(a1) # fe0 <kern_entry-0xffffffffc01ff020>
ffffffffc02034d6:	cf11                	beqz	a4,ffffffffc02034f2 <_clock_swap_out_victim+0x3a>
            page->visited = 0;
ffffffffc02034d8:	fe05b023          	sd	zero,-32(a1)
    while (1) {
ffffffffc02034dc:	85be                	mv	a1,a5
ffffffffc02034de:	659c                	ld	a5,8(a1)
        if(curr_ptr == head) {
ffffffffc02034e0:	feb699e3          	bne	a3,a1,ffffffffc02034d2 <_clock_swap_out_victim+0x1a>
            if(curr_ptr == head) {
ffffffffc02034e4:	02d78863          	beq	a5,a3,ffffffffc0203514 <_clock_swap_out_victim+0x5c>
    __list_del(listelm->prev, listelm->next);
ffffffffc02034e8:	85be                	mv	a1,a5
        if(!page->visited) {
ffffffffc02034ea:	fe05b703          	ld	a4,-32(a1)
ffffffffc02034ee:	679c                	ld	a5,8(a5)
ffffffffc02034f0:	f765                	bnez	a4,ffffffffc02034d8 <_clock_swap_out_victim+0x20>
ffffffffc02034f2:	6198                	ld	a4,0(a1)
        struct Page* page = le2page(curr_ptr, pra_page_link);
ffffffffc02034f4:	fd058693          	addi	a3,a1,-48
ffffffffc02034f8:	e20c                	sd	a1,0(a2)
            *ptr_page = page;
ffffffffc02034fa:	e114                	sd	a3,0(a0)
    prev->next = next;
ffffffffc02034fc:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02034fe:	e398                	sd	a4,0(a5)
            cprintf("curr_ptr %p\n",curr_ptr);
ffffffffc0203500:	00003517          	auipc	a0,0x3
ffffffffc0203504:	81050513          	addi	a0,a0,-2032 # ffffffffc0205d10 <default_pmm_manager+0xac0>
ffffffffc0203508:	bb3fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
}
ffffffffc020350c:	60a2                	ld	ra,8(sp)
ffffffffc020350e:	4501                	li	a0,0
ffffffffc0203510:	0141                	addi	sp,sp,16
ffffffffc0203512:	8082                	ret
ffffffffc0203514:	60a2                	ld	ra,8(sp)
ffffffffc0203516:	e214                	sd	a3,0(a2)
                *ptr_page = NULL;
ffffffffc0203518:	00053023          	sd	zero,0(a0)
}
ffffffffc020351c:	4501                	li	a0,0
ffffffffc020351e:	0141                	addi	sp,sp,16
ffffffffc0203520:	8082                	ret
    assert(in_tick==0);
ffffffffc0203522:	00002697          	auipc	a3,0x2
ffffffffc0203526:	7de68693          	addi	a3,a3,2014 # ffffffffc0205d00 <default_pmm_manager+0xab0>
ffffffffc020352a:	00002617          	auipc	a2,0x2
ffffffffc020352e:	97660613          	addi	a2,a2,-1674 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203532:	04c00593          	li	a1,76
ffffffffc0203536:	00002517          	auipc	a0,0x2
ffffffffc020353a:	75a50513          	addi	a0,a0,1882 # ffffffffc0205c90 <default_pmm_manager+0xa40>
ffffffffc020353e:	e37fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(head != NULL);
ffffffffc0203542:	00002697          	auipc	a3,0x2
ffffffffc0203546:	7ae68693          	addi	a3,a3,1966 # ffffffffc0205cf0 <default_pmm_manager+0xaa0>
ffffffffc020354a:	00002617          	auipc	a2,0x2
ffffffffc020354e:	95660613          	addi	a2,a2,-1706 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203552:	04b00593          	li	a1,75
ffffffffc0203556:	00002517          	auipc	a0,0x2
ffffffffc020355a:	73a50513          	addi	a0,a0,1850 # ffffffffc0205c90 <default_pmm_manager+0xa40>
ffffffffc020355e:	e17fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203562 <_clock_map_swappable>:
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203562:	0000e797          	auipc	a5,0xe
ffffffffc0203566:	ff67b783          	ld	a5,-10(a5) # ffffffffc0211558 <curr_ptr>
ffffffffc020356a:	cf89                	beqz	a5,ffffffffc0203584 <_clock_map_swappable+0x22>
    list_add_before((list_entry_t*) mm->sm_priv,entry);
ffffffffc020356c:	751c                	ld	a5,40(a0)
ffffffffc020356e:	03060713          	addi	a4,a2,48
}
ffffffffc0203572:	4501                	li	a0,0
    __list_add(elm, listelm->prev, listelm);
ffffffffc0203574:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0203576:	e398                	sd	a4,0(a5)
ffffffffc0203578:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc020357a:	fe1c                	sd	a5,56(a2)
    page->visited = 1;
ffffffffc020357c:	4785                	li	a5,1
    elm->prev = prev;
ffffffffc020357e:	fa14                	sd	a3,48(a2)
ffffffffc0203580:	ea1c                	sd	a5,16(a2)
}
ffffffffc0203582:	8082                	ret
{
ffffffffc0203584:	1141                	addi	sp,sp,-16
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc0203586:	00002697          	auipc	a3,0x2
ffffffffc020358a:	79a68693          	addi	a3,a3,1946 # ffffffffc0205d20 <default_pmm_manager+0xad0>
ffffffffc020358e:	00002617          	auipc	a2,0x2
ffffffffc0203592:	91260613          	addi	a2,a2,-1774 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203596:	03800593          	li	a1,56
ffffffffc020359a:	00002517          	auipc	a0,0x2
ffffffffc020359e:	6f650513          	addi	a0,a0,1782 # ffffffffc0205c90 <default_pmm_manager+0xa40>
{
ffffffffc02035a2:	e406                	sd	ra,8(sp)
    assert(entry != NULL && curr_ptr != NULL);
ffffffffc02035a4:	dd1fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02035a8 <check_vma_overlap.part.0>:
}

// check_vma_overlap - check if vma1 overlaps vma2?
// check_vma_overlap函数是一个内联静态函数，用于检查两个vma_struct结构体所表示的虚拟内存区域是否有重叠情况，通过断言来确保相关的地址范围条件满足不重叠的要求。
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02035a8:	1141                	addi	sp,sp,-16
    // 断言检查前一个vma的起始地址小于其结束地址，确保前一个vma的地址范围表示合理。
    assert(prev->vm_start < prev->vm_end);
    // 断言检查前一个vma的结束地址小于等于后一个vma的起始地址，确保两个vma的地址范围没有重叠，按照内存管理要求有序排列。
    assert(prev->vm_end <= next->vm_start);
    // 断言检查后一个vma的起始地址小于其结束地址，确保后一个vma的地址范围表示合理。
    assert(next->vm_start < next->vm_end);
ffffffffc02035aa:	00002697          	auipc	a3,0x2
ffffffffc02035ae:	7b668693          	addi	a3,a3,1974 # ffffffffc0205d60 <default_pmm_manager+0xb10>
ffffffffc02035b2:	00002617          	auipc	a2,0x2
ffffffffc02035b6:	8ee60613          	addi	a2,a2,-1810 # ffffffffc0204ea0 <commands+0x738>
ffffffffc02035ba:	0a100593          	li	a1,161
ffffffffc02035be:	00002517          	auipc	a0,0x2
ffffffffc02035c2:	7c250513          	addi	a0,a0,1986 # ffffffffc0205d80 <default_pmm_manager+0xb30>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc02035c6:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02035c8:	dadfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc02035cc <mm_create>:
mm_create(void) {
ffffffffc02035cc:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02035ce:	03000513          	li	a0,48
mm_create(void) {
ffffffffc02035d2:	e022                	sd	s0,0(sp)
ffffffffc02035d4:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02035d6:	aaeff0ef          	jal	ra,ffffffffc0202884 <kmalloc>
ffffffffc02035da:	842a                	mv	s0,a0
    if (mm!= NULL) {
ffffffffc02035dc:	c105                	beqz	a0,ffffffffc02035fc <mm_create+0x30>
    elm->prev = elm->next = elm;
ffffffffc02035de:	e408                	sd	a0,8(s0)
ffffffffc02035e0:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02035e2:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02035e6:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02035ea:	02052023          	sw	zero,32(a0)
        if (swap_init_ok)
ffffffffc02035ee:	0000e797          	auipc	a5,0xe
ffffffffc02035f2:	f627a783          	lw	a5,-158(a5) # ffffffffc0211550 <swap_init_ok>
ffffffffc02035f6:	eb81                	bnez	a5,ffffffffc0203606 <mm_create+0x3a>
            mm->sm_priv = NULL;
ffffffffc02035f8:	02053423          	sd	zero,40(a0)
}
ffffffffc02035fc:	60a2                	ld	ra,8(sp)
ffffffffc02035fe:	8522                	mv	a0,s0
ffffffffc0203600:	6402                	ld	s0,0(sp)
ffffffffc0203602:	0141                	addi	sp,sp,16
ffffffffc0203604:	8082                	ret
            swap_init_mm(mm);
ffffffffc0203606:	a8bff0ef          	jal	ra,ffffffffc0203090 <swap_init_mm>
}
ffffffffc020360a:	60a2                	ld	ra,8(sp)
ffffffffc020360c:	8522                	mv	a0,s0
ffffffffc020360e:	6402                	ld	s0,0(sp)
ffffffffc0203610:	0141                	addi	sp,sp,16
ffffffffc0203612:	8082                	ret

ffffffffc0203614 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc0203614:	1101                	addi	sp,sp,-32
ffffffffc0203616:	e04a                	sd	s2,0(sp)
ffffffffc0203618:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020361a:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint_t vm_flags) {
ffffffffc020361e:	e822                	sd	s0,16(sp)
ffffffffc0203620:	e426                	sd	s1,8(sp)
ffffffffc0203622:	ec06                	sd	ra,24(sp)
ffffffffc0203624:	84ae                	mv	s1,a1
ffffffffc0203626:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203628:	a5cff0ef          	jal	ra,ffffffffc0202884 <kmalloc>
    if (vma!= NULL) {
ffffffffc020362c:	c509                	beqz	a0,ffffffffc0203636 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc020362e:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc0203632:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203634:	ed00                	sd	s0,24(a0)
}
ffffffffc0203636:	60e2                	ld	ra,24(sp)
ffffffffc0203638:	6442                	ld	s0,16(sp)
ffffffffc020363a:	64a2                	ld	s1,8(sp)
ffffffffc020363c:	6902                	ld	s2,0(sp)
ffffffffc020363e:	6105                	addi	sp,sp,32
ffffffffc0203640:	8082                	ret

ffffffffc0203642 <find_vma>:
find_vma(struct mm_struct *mm, uintptr_t addr) {
ffffffffc0203642:	86aa                	mv	a3,a0
    if (mm!= NULL) {
ffffffffc0203644:	c505                	beqz	a0,ffffffffc020366c <find_vma+0x2a>
        vma = mm->mmap_cache;
ffffffffc0203646:	6908                	ld	a0,16(a0)
        if (!(vma!= NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203648:	c501                	beqz	a0,ffffffffc0203650 <find_vma+0xe>
ffffffffc020364a:	651c                	ld	a5,8(a0)
ffffffffc020364c:	02f5f263          	bgeu	a1,a5,ffffffffc0203670 <find_vma+0x2e>
    return listelm->next;
ffffffffc0203650:	669c                	ld	a5,8(a3)
            while ((le = list_next(le))!= list) {
ffffffffc0203652:	00f68d63          	beq	a3,a5,ffffffffc020366c <find_vma+0x2a>
                if (vma->vm_start <= addr && addr < vma->vm_end) {
ffffffffc0203656:	fe87b703          	ld	a4,-24(a5)
ffffffffc020365a:	00e5e663          	bltu	a1,a4,ffffffffc0203666 <find_vma+0x24>
ffffffffc020365e:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203662:	00e5ec63          	bltu	a1,a4,ffffffffc020367a <find_vma+0x38>
ffffffffc0203666:	679c                	ld	a5,8(a5)
            while ((le = list_next(le))!= list) {
ffffffffc0203668:	fef697e3          	bne	a3,a5,ffffffffc0203656 <find_vma+0x14>
    struct vma_struct *vma = NULL;
ffffffffc020366c:	4501                	li	a0,0
}
ffffffffc020366e:	8082                	ret
        if (!(vma!= NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0203670:	691c                	ld	a5,16(a0)
ffffffffc0203672:	fcf5ffe3          	bgeu	a1,a5,ffffffffc0203650 <find_vma+0xe>
            mm->mmap_cache = vma;
ffffffffc0203676:	ea88                	sd	a0,16(a3)
ffffffffc0203678:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc020367a:	fe078513          	addi	a0,a5,-32
            mm->mmap_cache = vma;
ffffffffc020367e:	ea88                	sd	a0,16(a3)
ffffffffc0203680:	8082                	ret

ffffffffc0203682 <insert_vma_struct>:
// insert_vma_struct -insert vma in mm's list link
// insert_vma_struct函数用于将一个vma_struct结构体插入到指定mm_struct结构体管理的链表中，插入时会按照虚拟内存区域的起始地址顺序进行插入，并检查是否有地址重叠等情况。
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    // 首先通过断言检查传入的vma结构体的起始地址小于其结束地址，确保vma的地址范围表示合理，符合虚拟内存区域的定义。
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203682:	6590                	ld	a2,8(a1)
ffffffffc0203684:	0105b803          	ld	a6,16(a1)
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0203688:	1141                	addi	sp,sp,-16
ffffffffc020368a:	e406                	sd	ra,8(sp)
ffffffffc020368c:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc020368e:	01066763          	bltu	a2,a6,ffffffffc020369c <insert_vma_struct+0x1a>
ffffffffc0203692:	a085                	j	ffffffffc02036f2 <insert_vma_struct+0x70>

    list_entry_t *le = list;
    // 遍历mm管理的vma链表，通过比较每个vma的起始地址与要插入的vma的起始地址大小，找到合适的插入位置，即找到第一个起始地址大于要插入vma起始地址的现有vma所在的链表节点位置（le），那么要插入的vma就应该插入到该节点的前面。
    while ((le = list_next(le))!= list) {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0203694:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203698:	04e66863          	bltu	a2,a4,ffffffffc02036e8 <insert_vma_struct+0x66>
ffffffffc020369c:	86be                	mv	a3,a5
ffffffffc020369e:	679c                	ld	a5,8(a5)
    while ((le = list_next(le))!= list) {
ffffffffc02036a0:	fef51ae3          	bne	a0,a5,ffffffffc0203694 <insert_vma_struct+0x12>
    // 获取找到的插入位置的下一个链表节点指针，用于后续检查地址重叠等情况以及进行链表插入操作。
    le_next = list_next(le_prev);

    /* check overlap */
    // 如果找到的插入位置的前一个节点不是链表头（即存在前一个vma），则调用check_vma_overlap函数检查要插入的vma与前一个vma是否有地址重叠情况，确保插入操作不会破坏已有的虚拟内存区域顺序和不重叠要求。
    if (le_prev!= list) {
ffffffffc02036a4:	02a68463          	beq	a3,a0,ffffffffc02036cc <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02036a8:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02036ac:	fe86b883          	ld	a7,-24(a3)
ffffffffc02036b0:	08e8f163          	bgeu	a7,a4,ffffffffc0203732 <insert_vma_struct+0xb0>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02036b4:	04e66f63          	bltu	a2,a4,ffffffffc0203712 <insert_vma_struct+0x90>
    }
    // 如果找到的插入位置的下一个节点不是链表头（即存在后一个vma），则调用check_vma_overlap函数检查要插入的vma与后一个vma是否有地址重叠情况，同样确保插入操作不会破坏已有的虚拟内存区域顺序和不重叠要求。
    if (le_next!= list) {
ffffffffc02036b8:	00f50a63          	beq	a0,a5,ffffffffc02036cc <insert_vma_struct+0x4a>
        if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc02036bc:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02036c0:	05076963          	bltu	a4,a6,ffffffffc0203712 <insert_vma_struct+0x90>
    assert(next->vm_start < next->vm_end);
ffffffffc02036c4:	ff07b603          	ld	a2,-16(a5)
ffffffffc02036c8:	02c77363          	bgeu	a4,a2,ffffffffc02036ee <insert_vma_struct+0x6c>
    vma->vm_mm = mm;
    // 将vma结构体的链表节点插入到找到的插入位置（le_prev节点后面），通过调用list_add_after函数（自定义的链表插入函数）实现链表插入操作，将vma添加到mm管理的vma链表中。
    list_add_after(le_prev, &(vma->list_link));

    // 将mm结构体中管理的vma结构体数量（map_count）加1，表示增加了一个虚拟内存区域。
    mm->map_count++;
ffffffffc02036cc:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc02036ce:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc02036d0:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc02036d4:	e390                	sd	a2,0(a5)
ffffffffc02036d6:	e690                	sd	a2,8(a3)
}
ffffffffc02036d8:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc02036da:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02036dc:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc02036de:	0017079b          	addiw	a5,a4,1
ffffffffc02036e2:	d11c                	sw	a5,32(a0)
}
ffffffffc02036e4:	0141                	addi	sp,sp,16
ffffffffc02036e6:	8082                	ret
    if (le_prev!= list) {
ffffffffc02036e8:	fca690e3          	bne	a3,a0,ffffffffc02036a8 <insert_vma_struct+0x26>
ffffffffc02036ec:	bfd1                	j	ffffffffc02036c0 <insert_vma_struct+0x3e>
ffffffffc02036ee:	ebbff0ef          	jal	ra,ffffffffc02035a8 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02036f2:	00002697          	auipc	a3,0x2
ffffffffc02036f6:	69e68693          	addi	a3,a3,1694 # ffffffffc0205d90 <default_pmm_manager+0xb40>
ffffffffc02036fa:	00001617          	auipc	a2,0x1
ffffffffc02036fe:	7a660613          	addi	a2,a2,1958 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203702:	0a900593          	li	a1,169
ffffffffc0203706:	00002517          	auipc	a0,0x2
ffffffffc020370a:	67a50513          	addi	a0,a0,1658 # ffffffffc0205d80 <default_pmm_manager+0xb30>
ffffffffc020370e:	c67fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203712:	00002697          	auipc	a3,0x2
ffffffffc0203716:	6be68693          	addi	a3,a3,1726 # ffffffffc0205dd0 <default_pmm_manager+0xb80>
ffffffffc020371a:	00001617          	auipc	a2,0x1
ffffffffc020371e:	78660613          	addi	a2,a2,1926 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203722:	09f00593          	li	a1,159
ffffffffc0203726:	00002517          	auipc	a0,0x2
ffffffffc020372a:	65a50513          	addi	a0,a0,1626 # ffffffffc0205d80 <default_pmm_manager+0xb30>
ffffffffc020372e:	c47fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203732:	00002697          	auipc	a3,0x2
ffffffffc0203736:	67e68693          	addi	a3,a3,1662 # ffffffffc0205db0 <default_pmm_manager+0xb60>
ffffffffc020373a:	00001617          	auipc	a2,0x1
ffffffffc020373e:	76660613          	addi	a2,a2,1894 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203742:	09d00593          	li	a1,157
ffffffffc0203746:	00002517          	auipc	a0,0x2
ffffffffc020374a:	63a50513          	addi	a0,a0,1594 # ffffffffc0205d80 <default_pmm_manager+0xb30>
ffffffffc020374e:	c27fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203752 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
// 该函数用于释放给定的mm_struct结构体以及其内部管理的所有虚拟内存区域相关资源，完成内存回收操作。
void
mm_destroy(struct mm_struct *mm) {
ffffffffc0203752:	1141                	addi	sp,sp,-16
ffffffffc0203754:	e022                	sd	s0,0(sp)
ffffffffc0203756:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203758:	6508                	ld	a0,8(a0)
ffffffffc020375a:	e406                	sd	ra,8(sp)
    // 获取mm结构体中管理vma链表的链表头节点指针，同时初始化一个临时指针le用于后续遍历链表操作。
    list_entry_t *list = &(mm->mmap_list), *le;
    // 开始循环遍历mm管理的vma链表，只要le通过list_next获取到的下一个节点不是链表头（意味着还没遍历完整个链表），就执行循环体内容。
    while ((le = list_next(list))!= list) {
ffffffffc020375c:	00a40e63          	beq	s0,a0,ffffffffc0203778 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203760:	6118                	ld	a4,0(a0)
ffffffffc0203762:	651c                	ld	a5,8(a0)
        // 先将当前节点从链表中删除，调用list_del函数（应该是自定义的链表节点删除操作函数）来实现。
        list_del(le);
        // 调用kfree函数（通常是内核空间的内存释放函数，用于回收之前通过kmalloc等分配的内存）释放当前节点对应的vma_struct结构体所占用的内存空间，
        // 传入通过le2vma宏（用于从链表节点获取对应的vma_struct结构体指针）转换得到的vma结构体指针以及vma_struct结构体的大小作为参数，确保正确释放内存。
        kfree(le2vma(le, list_link), sizeof(struct vma_struct));  
ffffffffc0203764:	03000593          	li	a1,48
ffffffffc0203768:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc020376a:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020376c:	e398                	sd	a4,0(a5)
ffffffffc020376e:	9d0ff0ef          	jal	ra,ffffffffc020293e <kfree>
    return listelm->next;
ffffffffc0203772:	6408                	ld	a0,8(s0)
    while ((le = list_next(list))!= list) {
ffffffffc0203774:	fea416e3          	bne	s0,a0,ffffffffc0203760 <mm_destroy+0xe>
    }
    // 释放mm_struct结构体自身所占用的内存空间，同样使用kfree函数进行释放，传入mm指针以及mm_struct结构体的大小作为参数。
    kfree(mm, sizeof(struct mm_struct)); 
ffffffffc0203778:	8522                	mv	a0,s0
    // 将mm指针赋值为NULL，虽然这一步在函数外部可能意义不大（因为mm是函数参数，外部的指针变量本身不会因为这里的赋值而改变），
    // 但在函数内部逻辑上表示该结构体已经被释放，避免后续误操作这个已经释放的指针。
    mm = NULL;
}
ffffffffc020377a:	6402                	ld	s0,0(sp)
ffffffffc020377c:	60a2                	ld	ra,8(sp)
    kfree(mm, sizeof(struct mm_struct)); 
ffffffffc020377e:	03000593          	li	a1,48
}
ffffffffc0203782:	0141                	addi	sp,sp,16
    kfree(mm, sizeof(struct mm_struct)); 
ffffffffc0203784:	9baff06f          	j	ffffffffc020293e <kfree>

ffffffffc0203788 <vmm_init>:

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
// 该函数作为虚拟内存管理（VMM）的初始化入口函数，目前其功能主要是调用check_vmm函数来检查虚拟内存管理机制的正确性。
void
vmm_init(void) {
ffffffffc0203788:	715d                	addi	sp,sp,-80
ffffffffc020378a:	e486                	sd	ra,72(sp)
ffffffffc020378c:	f44e                	sd	s3,40(sp)
ffffffffc020378e:	f052                	sd	s4,32(sp)
ffffffffc0203790:	e0a2                	sd	s0,64(sp)
ffffffffc0203792:	fc26                	sd	s1,56(sp)
ffffffffc0203794:	f84a                	sd	s2,48(sp)
ffffffffc0203796:	ec56                	sd	s5,24(sp)
ffffffffc0203798:	e85a                	sd	s6,16(sp)
ffffffffc020379a:	e45e                	sd	s7,8(sp)
// 此函数用于检查整个虚拟内存管理（VMM）机制的正确性，通过调用其他相关的检查函数并结合空闲页面数量的验证来完成检查工作。
static void
check_vmm(void) {
    // 首先获取并记录当前系统中空闲页面的数量，通过调用nr_free_pages函数来获取空闲页面数，并将其存储在nr_free_pages_store变量中，
    // 后续在执行一系列检查操作后，可以通过对比这个值来检查操作过程中是否存在空闲页面数量统计错误等问题，以此验证内存管理操作对空闲页面数量的影响是否符合预期。
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020379c:	802fe0ef          	jal	ra,ffffffffc020179e <nr_free_pages>
ffffffffc02037a0:	89aa                	mv	s3,a0

static void
check_vma_struct(void) {
    // 首先获取并记录当前系统中空闲页面的数量，与前面的类似，通过调用nr_free_pages函数来获取空闲页面数，并将其存储在nr_free_pages_store变量中，
    // 后续在执行一系列与vma相关操作的测试后，通过对比这个值来验证操作过程中是否存在空闲页面数量统计错误等问题，以此检查vma相关操作对内存管理的影响是否正确。
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02037a2:	ffdfd0ef          	jal	ra,ffffffffc020179e <nr_free_pages>
ffffffffc02037a6:	8a2a                	mv	s4,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02037a8:	03000513          	li	a0,48
ffffffffc02037ac:	8d8ff0ef          	jal	ra,ffffffffc0202884 <kmalloc>
    if (mm!= NULL) {
ffffffffc02037b0:	56050863          	beqz	a0,ffffffffc0203d20 <vmm_init+0x598>
    elm->prev = elm->next = elm;
ffffffffc02037b4:	e508                	sd	a0,8(a0)
ffffffffc02037b6:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc02037b8:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02037bc:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02037c0:	02052023          	sw	zero,32(a0)
        if (swap_init_ok)
ffffffffc02037c4:	0000e797          	auipc	a5,0xe
ffffffffc02037c8:	d8c7a783          	lw	a5,-628(a5) # ffffffffc0211550 <swap_init_ok>
ffffffffc02037cc:	84aa                	mv	s1,a0
ffffffffc02037ce:	e7b9                	bnez	a5,ffffffffc020381c <vmm_init+0x94>
            mm->sm_priv = NULL;
ffffffffc02037d0:	02053423          	sd	zero,40(a0)
vmm_init(void) {
ffffffffc02037d4:	03200413          	li	s0,50
ffffffffc02037d8:	a811                	j	ffffffffc02037ec <vmm_init+0x64>
        vma->vm_start = vm_start;
ffffffffc02037da:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc02037dc:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02037de:	00053c23          	sd	zero,24(a0)
    int step1 = 10, step2 = step1 * 10;

    int i;
    // 第一个循环，从step1开始递减到1，每次循环创建一个新的vma_struct结构体实例，通过调用vma_create函数传入相应的起始地址（i * 5）、结束地址（i * 5 + 2）以及默认标志位（0）来初始化vma，
    // 然后通过断言检查vma创建是否成功（返回的vma指针不为NULL），并调用insert_vma_struct函数将创建好的vma插入到刚才创建的mm结构体管理的链表中，模拟添加多个不同范围的虚拟内存区域的情况。
    for (i = step1; i >= 1; i--) {
ffffffffc02037e2:	146d                	addi	s0,s0,-5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma!= NULL);
        insert_vma_struct(mm, vma);
ffffffffc02037e4:	8526                	mv	a0,s1
ffffffffc02037e6:	e9dff0ef          	jal	ra,ffffffffc0203682 <insert_vma_struct>
    for (i = step1; i >= 1; i--) {
ffffffffc02037ea:	cc05                	beqz	s0,ffffffffc0203822 <vmm_init+0x9a>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02037ec:	03000513          	li	a0,48
ffffffffc02037f0:	894ff0ef          	jal	ra,ffffffffc0202884 <kmalloc>
ffffffffc02037f4:	85aa                	mv	a1,a0
ffffffffc02037f6:	00240793          	addi	a5,s0,2
    if (vma!= NULL) {
ffffffffc02037fa:	f165                	bnez	a0,ffffffffc02037da <vmm_init+0x52>
        assert(vma!= NULL);
ffffffffc02037fc:	00002697          	auipc	a3,0x2
ffffffffc0203800:	7e468693          	addi	a3,a3,2020 # ffffffffc0205fe0 <default_pmm_manager+0xd90>
ffffffffc0203804:	00001617          	auipc	a2,0x1
ffffffffc0203808:	69c60613          	addi	a2,a2,1692 # ffffffffc0204ea0 <commands+0x738>
ffffffffc020380c:	11300593          	li	a1,275
ffffffffc0203810:	00002517          	auipc	a0,0x2
ffffffffc0203814:	57050513          	addi	a0,a0,1392 # ffffffffc0205d80 <default_pmm_manager+0xb30>
ffffffffc0203818:	b5dfc0ef          	jal	ra,ffffffffc0200374 <__panic>
            swap_init_mm(mm);
ffffffffc020381c:	875ff0ef          	jal	ra,ffffffffc0203090 <swap_init_mm>
ffffffffc0203820:	bf55                	j	ffffffffc02037d4 <vmm_init+0x4c>
ffffffffc0203822:	03700413          	li	s0,55
    }

    // 第二个循环，从step1 + 1开始递增到step2，同样每次循环创建一个新的vma_struct结构体实例，并进行插入操作，进一步丰富mm结构体管理的虚拟内存区域情况，模拟更多不同范围的vma插入到同一个mm管理的链表中。
    for (i = step1 + 1; i <= step2; i++) {
ffffffffc0203826:	1f900913          	li	s2,505
ffffffffc020382a:	a819                	j	ffffffffc0203840 <vmm_init+0xb8>
        vma->vm_start = vm_start;
ffffffffc020382c:	e500                	sd	s0,8(a0)
        vma->vm_end = vm_end;
ffffffffc020382e:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203830:	00053c23          	sd	zero,24(a0)
    for (i = step1 + 1; i <= step2; i++) {
ffffffffc0203834:	0415                	addi	s0,s0,5
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma!= NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203836:	8526                	mv	a0,s1
ffffffffc0203838:	e4bff0ef          	jal	ra,ffffffffc0203682 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++) {
ffffffffc020383c:	03240a63          	beq	s0,s2,ffffffffc0203870 <vmm_init+0xe8>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203840:	03000513          	li	a0,48
ffffffffc0203844:	840ff0ef          	jal	ra,ffffffffc0202884 <kmalloc>
ffffffffc0203848:	85aa                	mv	a1,a0
ffffffffc020384a:	00240793          	addi	a5,s0,2
    if (vma!= NULL) {
ffffffffc020384e:	fd79                	bnez	a0,ffffffffc020382c <vmm_init+0xa4>
        assert(vma!= NULL);
ffffffffc0203850:	00002697          	auipc	a3,0x2
ffffffffc0203854:	79068693          	addi	a3,a3,1936 # ffffffffc0205fe0 <default_pmm_manager+0xd90>
ffffffffc0203858:	00001617          	auipc	a2,0x1
ffffffffc020385c:	64860613          	addi	a2,a2,1608 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203860:	11a00593          	li	a1,282
ffffffffc0203864:	00002517          	auipc	a0,0x2
ffffffffc0203868:	51c50513          	addi	a0,a0,1308 # ffffffffc0205d80 <default_pmm_manager+0xb30>
ffffffffc020386c:	b09fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    return listelm->next;
ffffffffc0203870:	649c                	ld	a5,8(s1)
ffffffffc0203872:	471d                	li	a4,7
    // 获取mm结构体中管理vma链表的链表头节点的下一个节点指针（即第一个vma对应的链表节点），用于后续遍历链表验证每个vma的属性是否正确。
    list_entry_t *le = list_next(&(mm->mmap_list));

    // 循环遍历mm管理的vma链表，从第一个vma开始（通过前面获取的le指针），按照顺序依次验证每个vma的起始地址和结束地址是否符合预期（通过断言检查是否等于当前循环次数i对应的计算值），
    // 每次循环获取下一个链表节点（通过list_next函数），确保整个链表中所有vma的属性都符合创建时设置的预期值，以此检查vma插入和链表维护的正确性。
    for (i = 1; i <= step2; i++) {
ffffffffc0203874:	1fb00593          	li	a1,507
        assert(le!= &(mm->mmap_list));
ffffffffc0203878:	2ef48463          	beq	s1,a5,ffffffffc0203b60 <vmm_init+0x3d8>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020387c:	fe87b603          	ld	a2,-24(a5)
ffffffffc0203880:	ffe70693          	addi	a3,a4,-2
ffffffffc0203884:	26d61e63          	bne	a2,a3,ffffffffc0203b00 <vmm_init+0x378>
ffffffffc0203888:	ff07b683          	ld	a3,-16(a5)
ffffffffc020388c:	26e69a63          	bne	a3,a4,ffffffffc0203b00 <vmm_init+0x378>
    for (i = 1; i <= step2; i++) {
ffffffffc0203890:	0715                	addi	a4,a4,5
ffffffffc0203892:	679c                	ld	a5,8(a5)
ffffffffc0203894:	feb712e3          	bne	a4,a1,ffffffffc0203878 <vmm_init+0xf0>
ffffffffc0203898:	4b1d                	li	s6,7
ffffffffc020389a:	4415                	li	s0,5
        le = list_next(le);
    }

    // 另一个循环，从5开始，每次增加5（步长为5），直到达到5 * step2，用于测试查找vma的功能，通过调用find_vma函数查找每个地址对应的vma，
    // 然后通过一系列断言检查查找结果是否符合预期，比如地址i、i + 1应该能找到对应的vma，而地址i + 2、i + 3、i + 4等应该查找不到（返回NULL），同时验证找到的vma的起始地址和结束地址是否正确，以此检查vma查找功能的准确性。
    for (i = 5; i <= 5 * step2; i += 5) {
ffffffffc020389c:	1f900b93          	li	s7,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc02038a0:	85a2                	mv	a1,s0
ffffffffc02038a2:	8526                	mv	a0,s1
ffffffffc02038a4:	d9fff0ef          	jal	ra,ffffffffc0203642 <find_vma>
ffffffffc02038a8:	892a                	mv	s2,a0
        assert(vma1!= NULL);
ffffffffc02038aa:	2c050b63          	beqz	a0,ffffffffc0203b80 <vmm_init+0x3f8>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc02038ae:	00140593          	addi	a1,s0,1
ffffffffc02038b2:	8526                	mv	a0,s1
ffffffffc02038b4:	d8fff0ef          	jal	ra,ffffffffc0203642 <find_vma>
ffffffffc02038b8:	8aaa                	mv	s5,a0
        assert(vma2!= NULL);
ffffffffc02038ba:	2e050363          	beqz	a0,ffffffffc0203ba0 <vmm_init+0x418>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc02038be:	85da                	mv	a1,s6
ffffffffc02038c0:	8526                	mv	a0,s1
ffffffffc02038c2:	d81ff0ef          	jal	ra,ffffffffc0203642 <find_vma>
        assert(vma3 == NULL);
ffffffffc02038c6:	2e051d63          	bnez	a0,ffffffffc0203bc0 <vmm_init+0x438>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc02038ca:	00340593          	addi	a1,s0,3
ffffffffc02038ce:	8526                	mv	a0,s1
ffffffffc02038d0:	d73ff0ef          	jal	ra,ffffffffc0203642 <find_vma>
        assert(vma4 == NULL);
ffffffffc02038d4:	30051663          	bnez	a0,ffffffffc0203be0 <vmm_init+0x458>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc02038d8:	00440593          	addi	a1,s0,4
ffffffffc02038dc:	8526                	mv	a0,s1
ffffffffc02038de:	d65ff0ef          	jal	ra,ffffffffc0203642 <find_vma>
        assert(vma5 == NULL);
ffffffffc02038e2:	30051f63          	bnez	a0,ffffffffc0203c00 <vmm_init+0x478>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc02038e6:	00893783          	ld	a5,8(s2)
ffffffffc02038ea:	24879b63          	bne	a5,s0,ffffffffc0203b40 <vmm_init+0x3b8>
ffffffffc02038ee:	01093783          	ld	a5,16(s2)
ffffffffc02038f2:	25679763          	bne	a5,s6,ffffffffc0203b40 <vmm_init+0x3b8>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc02038f6:	008ab783          	ld	a5,8(s5)
ffffffffc02038fa:	22879363          	bne	a5,s0,ffffffffc0203b20 <vmm_init+0x398>
ffffffffc02038fe:	010ab783          	ld	a5,16(s5)
ffffffffc0203902:	21679f63          	bne	a5,s6,ffffffffc0203b20 <vmm_init+0x398>
    for (i = 5; i <= 5 * step2; i += 5) {
ffffffffc0203906:	0415                	addi	s0,s0,5
ffffffffc0203908:	0b15                	addi	s6,s6,5
ffffffffc020390a:	f9741be3          	bne	s0,s7,ffffffffc02038a0 <vmm_init+0x118>
ffffffffc020390e:	4411                	li	s0,4
    }

    // 再一个循环，从4开始递减到0，用于检查查找小于特定范围（这里可能以5为界限相关情况）的地址对应的vma是否返回NULL（即不存在对应的vma），
    // 如果查找到的vma不为NULL，则输出该vma的相关信息（通过cprintf函数），同时通过断言检查查找结果应该为NULL，以此验证查找边界情况和不存在对应vma时的返回值正确性。
    for (i = 4; i >= 0; i--) {
ffffffffc0203910:	597d                	li	s2,-1
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc0203912:	85a2                	mv	a1,s0
ffffffffc0203914:	8526                	mv	a0,s1
ffffffffc0203916:	d2dff0ef          	jal	ra,ffffffffc0203642 <find_vma>
ffffffffc020391a:	0004059b          	sext.w	a1,s0
        if (vma_below_5!= NULL) {
ffffffffc020391e:	c90d                	beqz	a0,ffffffffc0203950 <vmm_init+0x1c8>
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc0203920:	6914                	ld	a3,16(a0)
ffffffffc0203922:	6510                	ld	a2,8(a0)
ffffffffc0203924:	00002517          	auipc	a0,0x2
ffffffffc0203928:	5cc50513          	addi	a0,a0,1484 # ffffffffc0205ef0 <default_pmm_manager+0xca0>
ffffffffc020392c:	f8efc0ef          	jal	ra,ffffffffc02000ba <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0203930:	00002697          	auipc	a3,0x2
ffffffffc0203934:	5e868693          	addi	a3,a3,1512 # ffffffffc0205f18 <default_pmm_manager+0xcc8>
ffffffffc0203938:	00001617          	auipc	a2,0x1
ffffffffc020393c:	56860613          	addi	a2,a2,1384 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203940:	14300593          	li	a1,323
ffffffffc0203944:	00002517          	auipc	a0,0x2
ffffffffc0203948:	43c50513          	addi	a0,a0,1084 # ffffffffc0205d80 <default_pmm_manager+0xb30>
ffffffffc020394c:	a29fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    for (i = 4; i >= 0; i--) {
ffffffffc0203950:	147d                	addi	s0,s0,-1
ffffffffc0203952:	fd2410e3          	bne	s0,s2,ffffffffc0203912 <vmm_init+0x18a>
ffffffffc0203956:	a811                	j	ffffffffc020396a <vmm_init+0x1e2>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203958:	6118                	ld	a4,0(a0)
ffffffffc020395a:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link), sizeof(struct vma_struct));  
ffffffffc020395c:	03000593          	li	a1,48
ffffffffc0203960:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203962:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203964:	e398                	sd	a4,0(a5)
ffffffffc0203966:	fd9fe0ef          	jal	ra,ffffffffc020293e <kfree>
    return listelm->next;
ffffffffc020396a:	6488                	ld	a0,8(s1)
    while ((le = list_next(list))!= list) {
ffffffffc020396c:	fea496e3          	bne	s1,a0,ffffffffc0203958 <vmm_init+0x1d0>
    kfree(mm, sizeof(struct mm_struct)); 
ffffffffc0203970:	03000593          	li	a1,48
ffffffffc0203974:	8526                	mv	a0,s1
ffffffffc0203976:	fc9fe0ef          	jal	ra,ffffffffc020293e <kfree>
    // 调用mm_destroy函数释放之前创建并用于测试的mm结构体及其管理的所有vma相关资源，完成内存回收操作，还原内存状态，同时也检查资源释放功能是否正确执行。
    mm_destroy(mm);

    // 通过断言检查当前系统实际的空闲页面数量（再次调用nr_free_pages函数获取）与最初记录的空闲页面数量（nr_free_pages_store）是否相等，
    // 如果相等则说明经过一系列与vma相关的创建、插入、查找以及释放等操作后，空闲页面数量的变化符合预期，间接验证了vma相关操作在内存管理方面的正确性。
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020397a:	e25fd0ef          	jal	ra,ffffffffc020179e <nr_free_pages>
ffffffffc020397e:	3caa1163          	bne	s4,a0,ffffffffc0203d40 <vmm_init+0x5b8>

    // 输出提示信息，表示对虚拟内存区域（vma_struct）相关操作的检查成功完成，意味着上述针对vma的各项检查都通过了，没有发现明显的错误，vma相关功能按预期工作。
    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203982:	00002517          	auipc	a0,0x2
ffffffffc0203986:	5d650513          	addi	a0,a0,1494 # ffffffffc0205f58 <default_pmm_manager+0xd08>
ffffffffc020398a:	f30fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
check_pgfault(void) {
    // 以下这行代码原本可能是用于定义一个函数内局部的标识字符串变量，但被注释掉了。
    // char *name = "check_pgfault";

    // 获取当前系统中空闲页面的数量，并存储在nr_free_pages_store变量中，后续将通过对比这个值来检查页面错误处理相关操作前后空闲页面数量是否符合预期，以此验证内存管理的正确性。
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020398e:	e11fd0ef          	jal	ra,ffffffffc020179e <nr_free_pages>
ffffffffc0203992:	84aa                	mv	s1,a0
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203994:	03000513          	li	a0,48
ffffffffc0203998:	eedfe0ef          	jal	ra,ffffffffc0202884 <kmalloc>
ffffffffc020399c:	842a                	mv	s0,a0
    if (mm!= NULL) {
ffffffffc020399e:	2a050163          	beqz	a0,ffffffffc0203c40 <vmm_init+0x4b8>
        if (swap_init_ok)
ffffffffc02039a2:	0000e797          	auipc	a5,0xe
ffffffffc02039a6:	bae7a783          	lw	a5,-1106(a5) # ffffffffc0211550 <swap_init_ok>
    elm->prev = elm->next = elm;
ffffffffc02039aa:	e508                	sd	a0,8(a0)
ffffffffc02039ac:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc02039ae:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02039b2:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02039b6:	02052023          	sw	zero,32(a0)
        if (swap_init_ok)
ffffffffc02039ba:	14079063          	bnez	a5,ffffffffc0203afa <vmm_init+0x372>
            mm->sm_priv = NULL;
ffffffffc02039be:	02053423          	sd	zero,40(a0)
    // 通过断言检查创建的mm_struct结构体是否成功（即指针不为NULL），若为NULL则说明内存分配或初始化出现问题，不符合预期。
    assert(check_mm_struct!= NULL);
    // 将创建好的mm_struct结构体指针赋值给局部变量mm，方便后续操作，mm结构体在后续模拟页面错误处理过程中扮演着关键角色，它管理着相关的虚拟内存区域等信息。
    struct mm_struct *mm = check_mm_struct;
    // 获取mm结构体中的页目录表（Page Directory Table，PDT）指针，并将其赋值为系统启动时的页目录表指针（boot_pgdir，这应该是一个全局定义的表示初始页目录表的变量），这样就建立了当前模拟环境与系统初始页目录的关联。
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02039c2:	0000e917          	auipc	s2,0xe
ffffffffc02039c6:	b5693903          	ld	s2,-1194(s2) # ffffffffc0211518 <boot_pgdir>
    // 通过断言检查页目录表的第一个条目（pgdir[0]）的值是否为0，这可能是基于特定的初始化要求或者当前测试场景下页目录表的预期初始状态进行的验证，确保初始状态符合预期设定。
    assert(pgdir[0] == 0);
ffffffffc02039ca:	00093783          	ld	a5,0(s2)
    check_mm_struct = mm_create();
ffffffffc02039ce:	0000e717          	auipc	a4,0xe
ffffffffc02039d2:	b8873923          	sd	s0,-1134(a4) # ffffffffc0211560 <check_mm_struct>
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02039d6:	01243c23          	sd	s2,24(s0)
    assert(pgdir[0] == 0);
ffffffffc02039da:	24079363          	bnez	a5,ffffffffc0203c20 <vmm_init+0x498>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02039de:	03000513          	li	a0,48
ffffffffc02039e2:	ea3fe0ef          	jal	ra,ffffffffc0202884 <kmalloc>
ffffffffc02039e6:	8a2a                	mv	s4,a0
    if (vma!= NULL) {
ffffffffc02039e8:	28050063          	beqz	a0,ffffffffc0203c68 <vmm_init+0x4e0>
        vma->vm_end = vm_end;
ffffffffc02039ec:	002007b7          	lui	a5,0x200
ffffffffc02039f0:	00fa3823          	sd	a5,16(s4)
        vma->vm_flags = vm_flags;
ffffffffc02039f4:	4789                	li	a5,2
    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    // 通过断言检查vma创建是否成功（返回的vma指针不为NULL），若创建失败则不符合预期，后续基于这个虚拟内存区域的模拟操作将无法正常进行。
    assert(vma!= NULL);

    // 调用insert_vma_struct函数将刚创建的vma结构体插入到mm结构体管理的虚拟内存区域链表中，这样mm结构体就正式管理了这个虚拟内存区域，建立起了完整的内存管理结构关联关系，模拟出正常的内存管理配置情况。
    insert_vma_struct(mm, vma);
ffffffffc02039f6:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc02039f8:	00fa3c23          	sd	a5,24(s4)
    insert_vma_struct(mm, vma);
ffffffffc02039fc:	8522                	mv	a0,s0
        vma->vm_start = vm_start;
ffffffffc02039fe:	000a3423          	sd	zero,8(s4)
    insert_vma_struct(mm, vma);
ffffffffc0203a02:	c81ff0ef          	jal	ra,ffffffffc0203682 <insert_vma_struct>

    // 定义一个虚拟地址变量addr并赋值为0x100，用于模拟后续触发页面错误的访问地址，这个地址需要落在前面创建并插入的虚拟内存区域范围内才有意义，以便后续验证相关的查找等操作是否正确。
    uintptr_t addr = 0x100;
    // 通过断言检查调用find_vma函数查找该地址对应的vma是否就是之前创建并插入的那个vma，以此验证find_vma函数在这种场景下能否正确找到对应的虚拟内存区域，确保内存区域查找功能的准确性。
    assert(find_vma(mm, addr) == vma);
ffffffffc0203a06:	10000593          	li	a1,256
ffffffffc0203a0a:	8522                	mv	a0,s0
ffffffffc0203a0c:	c37ff0ef          	jal	ra,ffffffffc0203642 <find_vma>
ffffffffc0203a10:	10000793          	li	a5,256

    int i, sum = 0;
    // 以下循环从0到99，模拟对虚拟地址addr开始的一段内存区域进行写入操作，每次将当前地址（addr + i）处的字节赋值为当前循环次数i，并将这个值累加到sum变量中，这一步是为了后续验证内存读写操作的正确性做准备，先模拟正常的内存写入情况。
    for (i = 0; i < 100; i++) {
ffffffffc0203a14:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0203a18:	26aa1863          	bne	s4,a0,ffffffffc0203c88 <vmm_init+0x500>
        *(char *)(addr + i) = i;
ffffffffc0203a1c:	00f78023          	sb	a5,0(a5) # 200000 <kern_entry-0xffffffffc0000000>
    for (i = 0; i < 100; i++) {
ffffffffc0203a20:	0785                	addi	a5,a5,1
ffffffffc0203a22:	fee79de3          	bne	a5,a4,ffffffffc0203a1c <vmm_init+0x294>
        sum += i;
ffffffffc0203a26:	6705                	lui	a4,0x1
ffffffffc0203a28:	10000793          	li	a5,256
ffffffffc0203a2c:	35670713          	addi	a4,a4,854 # 1356 <kern_entry-0xffffffffc01fecaa>
    }
    // 下面这个循环同样从0到99，模拟对之前写入的内存区域进行读取操作，每次从当前地址（addr + i）处读取一个字节的值，并从sum变量中减去这个值，理论上经过写入和读取相同数据后，sum最终应该为0，通过这个操作以及后续的断言检查来验证内存读写功能在没有页面错误等异常情况下的数据一致性。
    for (i = 0; i < 100; i++) {
ffffffffc0203a30:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc0203a34:	0007c683          	lbu	a3,0(a5)
    for (i = 0; i < 100; i++) {
ffffffffc0203a38:	0785                	addi	a5,a5,1
        sum -= *(char *)(addr + i);
ffffffffc0203a3a:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i++) {
ffffffffc0203a3c:	fec79ce3          	bne	a5,a2,ffffffffc0203a34 <vmm_init+0x2ac>
    }
    // 通过断言检查sum的值是否为0，若为0则说明前面的内存读写操作按预期执行，没有出现数据不一致等问题，为后续制造页面错误情况做对比基础，只有在正常读写没问题的情况下，才能更好地验证页面错误处理机制的正确性。
    assert(sum == 0);
ffffffffc0203a40:	26071463          	bnez	a4,ffffffffc0203ca8 <vmm_init+0x520>

    // 调用page_remove函数移除页目录表（pgdir）中对应于给定虚拟地址（通过ROUNDDOWN宏将addr按页面大小向下取整后的地址）的页面映射关系，模拟制造页面错误情况，即对应的页面被移除后，再访问该地址就会触发页面错误，这是模拟页面错误发生的关键操作步骤。
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc0203a44:	4581                	li	a1,0
ffffffffc0203a46:	854a                	mv	a0,s2
ffffffffc0203a48:	fe1fd0ef          	jal	ra,ffffffffc0201a28 <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203a4c:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0203a50:	0000e717          	auipc	a4,0xe
ffffffffc0203a54:	ad073703          	ld	a4,-1328(a4) # ffffffffc0211520 <npage>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203a58:	078a                	slli	a5,a5,0x2
ffffffffc0203a5a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203a5c:	26e7f663          	bgeu	a5,a4,ffffffffc0203cc8 <vmm_init+0x540>
    return &pages[PPN(pa) - nbase];
ffffffffc0203a60:	00003717          	auipc	a4,0x3
ffffffffc0203a64:	8e073703          	ld	a4,-1824(a4) # ffffffffc0206340 <nbase>
ffffffffc0203a68:	8f99                	sub	a5,a5,a4
ffffffffc0203a6a:	00379713          	slli	a4,a5,0x3
ffffffffc0203a6e:	97ba                	add	a5,a5,a4
ffffffffc0203a70:	078e                	slli	a5,a5,0x3

    // 调用free_page函数释放通过页目录表项（pgdir[0]）获取到的页面（通过pde2page函数将页目录表项转换为对应的页面结构体指针），进行内存回收操作，进一步改变内存状态，模拟页面错误发生后的内存资源调整情况，符合真实场景下页面错误处理时可能涉及的资源释放操作。
    free_page(pde2page(pgdir[0]));
ffffffffc0203a72:	0000e517          	auipc	a0,0xe
ffffffffc0203a76:	ab653503          	ld	a0,-1354(a0) # ffffffffc0211528 <pages>
ffffffffc0203a7a:	953e                	add	a0,a0,a5
ffffffffc0203a7c:	4585                	li	a1,1
ffffffffc0203a7e:	ce1fd0ef          	jal	ra,ffffffffc020175e <free_pages>
    return listelm->next;
ffffffffc0203a82:	6408                	ld	a0,8(s0)

    // 将页目录表的第一个条目（pgdir[0]）赋值为0，重置页目录表的相关状态，可能是模拟更彻底的页面错误处理后的页目录表清理操作，确保处于一个符合预期的初始状态（或者测试后续相关功能能正确处理这种情况），为后续的资源释放及整个mm结构体的销毁做准备。
    pgdir[0] = 0;
ffffffffc0203a84:	00093023          	sd	zero,0(s2)

    // 将mm结构体中的页目录表指针设置为NULL，表示解除与当前页目录表的关联，模拟内存管理结构在页面错误处理后的相关状态变化情况，进一步完善整个页面错误处理流程的模拟操作。
    mm->pgdir = NULL;
ffffffffc0203a88:	00043c23          	sd	zero,24(s0)
    while ((le = list_next(list))!= list) {
ffffffffc0203a8c:	00a40e63          	beq	s0,a0,ffffffffc0203aa8 <vmm_init+0x320>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203a90:	6118                	ld	a4,0(a0)
ffffffffc0203a92:	651c                	ld	a5,8(a0)
        kfree(le2vma(le, list_link), sizeof(struct vma_struct));  
ffffffffc0203a94:	03000593          	li	a1,48
ffffffffc0203a98:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0203a9a:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203a9c:	e398                	sd	a4,0(a5)
ffffffffc0203a9e:	ea1fe0ef          	jal	ra,ffffffffc020293e <kfree>
    return listelm->next;
ffffffffc0203aa2:	6408                	ld	a0,8(s0)
    while ((le = list_next(list))!= list) {
ffffffffc0203aa4:	fea416e3          	bne	s0,a0,ffffffffc0203a90 <vmm_init+0x308>
    kfree(mm, sizeof(struct mm_struct)); 
ffffffffc0203aa8:	03000593          	li	a1,48
ffffffffc0203aac:	8522                	mv	a0,s0
ffffffffc0203aae:	e91fe0ef          	jal	ra,ffffffffc020293e <kfree>
    mm_destroy(mm);

    // 将全局的check_mm_struct指针设置为NULL，因为之前创建用于测试的mm结构体已经被销毁，这里将其对应的全局指针置空，避免后续误操作这个已经释放的结构指针。
    check_mm_struct = NULL;
    // 根据注释说明（Sv39第二级页表多占了一个内存页的情况相关），将记录的空闲页面数量减1，这里可能是基于特定的内存管理架构和设计，在进行相关检查操作后需要对空闲页面数量的预期值进行相应调整，以符合实际的内存占用情况。
    nr_free_pages_store--;
ffffffffc0203ab2:	14fd                	addi	s1,s1,-1
    check_mm_struct = NULL;
ffffffffc0203ab4:	0000e797          	auipc	a5,0xe
ffffffffc0203ab8:	aa07b623          	sd	zero,-1364(a5) # ffffffffc0211560 <check_mm_struct>

    // 通过断言检查当前系统实际的空闲页面数量（再次调用nr_free_pages函数获取）与调整后的预期空闲页面数量（nr_free_pages_store）是否相等，若相等则说明经过一系列涉及页面错误处理模拟操作后，空闲页面数量的变化符合预期，间接验证了页面错误处理机制在内存管理方面的正确性，包括资源释放、内存状态重置等操作都没有对空闲页面数量统计造成错误影响。
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203abc:	ce3fd0ef          	jal	ra,ffffffffc020179e <nr_free_pages>
ffffffffc0203ac0:	22a49063          	bne	s1,a0,ffffffffc0203ce0 <vmm_init+0x558>

    // 输出提示信息，表示对页面错误处理程序（pgfault handler）的检查成功完成，意味着上述各项针对页面错误处理相关的模拟操作及验证都通过了，没有发现明显的错误，页面错误处理相关功能按预期工作。
    cprintf("check_pgfault() succeeded!\n");
ffffffffc0203ac4:	00002517          	auipc	a0,0x2
ffffffffc0203ac8:	4e450513          	addi	a0,a0,1252 # ffffffffc0205fa8 <default_pmm_manager+0xd58>
ffffffffc0203acc:	deefc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203ad0:	ccffd0ef          	jal	ra,ffffffffc020179e <nr_free_pages>
    nr_free_pages_store--;  
ffffffffc0203ad4:	19fd                	addi	s3,s3,-1
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203ad6:	22a99563          	bne	s3,a0,ffffffffc0203d00 <vmm_init+0x578>
}
ffffffffc0203ada:	6406                	ld	s0,64(sp)
ffffffffc0203adc:	60a6                	ld	ra,72(sp)
ffffffffc0203ade:	74e2                	ld	s1,56(sp)
ffffffffc0203ae0:	7942                	ld	s2,48(sp)
ffffffffc0203ae2:	79a2                	ld	s3,40(sp)
ffffffffc0203ae4:	7a02                	ld	s4,32(sp)
ffffffffc0203ae6:	6ae2                	ld	s5,24(sp)
ffffffffc0203ae8:	6b42                	ld	s6,16(sp)
ffffffffc0203aea:	6ba2                	ld	s7,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203aec:	00002517          	auipc	a0,0x2
ffffffffc0203af0:	4dc50513          	addi	a0,a0,1244 # ffffffffc0205fc8 <default_pmm_manager+0xd78>
}
ffffffffc0203af4:	6161                	addi	sp,sp,80
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203af6:	dc4fc06f          	j	ffffffffc02000ba <cprintf>
            swap_init_mm(mm);
ffffffffc0203afa:	d96ff0ef          	jal	ra,ffffffffc0203090 <swap_init_mm>
ffffffffc0203afe:	b5d1                	j	ffffffffc02039c2 <vmm_init+0x23a>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203b00:	00002697          	auipc	a3,0x2
ffffffffc0203b04:	30868693          	addi	a3,a3,776 # ffffffffc0205e08 <default_pmm_manager+0xbb8>
ffffffffc0203b08:	00001617          	auipc	a2,0x1
ffffffffc0203b0c:	39860613          	addi	a2,a2,920 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203b10:	12600593          	li	a1,294
ffffffffc0203b14:	00002517          	auipc	a0,0x2
ffffffffc0203b18:	26c50513          	addi	a0,a0,620 # ffffffffc0205d80 <default_pmm_manager+0xb30>
ffffffffc0203b1c:	859fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203b20:	00002697          	auipc	a3,0x2
ffffffffc0203b24:	3a068693          	addi	a3,a3,928 # ffffffffc0205ec0 <default_pmm_manager+0xc70>
ffffffffc0203b28:	00001617          	auipc	a2,0x1
ffffffffc0203b2c:	37860613          	addi	a2,a2,888 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203b30:	13900593          	li	a1,313
ffffffffc0203b34:	00002517          	auipc	a0,0x2
ffffffffc0203b38:	24c50513          	addi	a0,a0,588 # ffffffffc0205d80 <default_pmm_manager+0xb30>
ffffffffc0203b3c:	839fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203b40:	00002697          	auipc	a3,0x2
ffffffffc0203b44:	35068693          	addi	a3,a3,848 # ffffffffc0205e90 <default_pmm_manager+0xc40>
ffffffffc0203b48:	00001617          	auipc	a2,0x1
ffffffffc0203b4c:	35860613          	addi	a2,a2,856 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203b50:	13800593          	li	a1,312
ffffffffc0203b54:	00002517          	auipc	a0,0x2
ffffffffc0203b58:	22c50513          	addi	a0,a0,556 # ffffffffc0205d80 <default_pmm_manager+0xb30>
ffffffffc0203b5c:	819fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(le!= &(mm->mmap_list));
ffffffffc0203b60:	00002697          	auipc	a3,0x2
ffffffffc0203b64:	29068693          	addi	a3,a3,656 # ffffffffc0205df0 <default_pmm_manager+0xba0>
ffffffffc0203b68:	00001617          	auipc	a2,0x1
ffffffffc0203b6c:	33860613          	addi	a2,a2,824 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203b70:	12400593          	li	a1,292
ffffffffc0203b74:	00002517          	auipc	a0,0x2
ffffffffc0203b78:	20c50513          	addi	a0,a0,524 # ffffffffc0205d80 <default_pmm_manager+0xb30>
ffffffffc0203b7c:	ff8fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma1!= NULL);
ffffffffc0203b80:	00002697          	auipc	a3,0x2
ffffffffc0203b84:	2c068693          	addi	a3,a3,704 # ffffffffc0205e40 <default_pmm_manager+0xbf0>
ffffffffc0203b88:	00001617          	auipc	a2,0x1
ffffffffc0203b8c:	31860613          	addi	a2,a2,792 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203b90:	12e00593          	li	a1,302
ffffffffc0203b94:	00002517          	auipc	a0,0x2
ffffffffc0203b98:	1ec50513          	addi	a0,a0,492 # ffffffffc0205d80 <default_pmm_manager+0xb30>
ffffffffc0203b9c:	fd8fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma2!= NULL);
ffffffffc0203ba0:	00002697          	auipc	a3,0x2
ffffffffc0203ba4:	2b068693          	addi	a3,a3,688 # ffffffffc0205e50 <default_pmm_manager+0xc00>
ffffffffc0203ba8:	00001617          	auipc	a2,0x1
ffffffffc0203bac:	2f860613          	addi	a2,a2,760 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203bb0:	13000593          	li	a1,304
ffffffffc0203bb4:	00002517          	auipc	a0,0x2
ffffffffc0203bb8:	1cc50513          	addi	a0,a0,460 # ffffffffc0205d80 <default_pmm_manager+0xb30>
ffffffffc0203bbc:	fb8fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma3 == NULL);
ffffffffc0203bc0:	00002697          	auipc	a3,0x2
ffffffffc0203bc4:	2a068693          	addi	a3,a3,672 # ffffffffc0205e60 <default_pmm_manager+0xc10>
ffffffffc0203bc8:	00001617          	auipc	a2,0x1
ffffffffc0203bcc:	2d860613          	addi	a2,a2,728 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203bd0:	13200593          	li	a1,306
ffffffffc0203bd4:	00002517          	auipc	a0,0x2
ffffffffc0203bd8:	1ac50513          	addi	a0,a0,428 # ffffffffc0205d80 <default_pmm_manager+0xb30>
ffffffffc0203bdc:	f98fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma4 == NULL);
ffffffffc0203be0:	00002697          	auipc	a3,0x2
ffffffffc0203be4:	29068693          	addi	a3,a3,656 # ffffffffc0205e70 <default_pmm_manager+0xc20>
ffffffffc0203be8:	00001617          	auipc	a2,0x1
ffffffffc0203bec:	2b860613          	addi	a2,a2,696 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203bf0:	13400593          	li	a1,308
ffffffffc0203bf4:	00002517          	auipc	a0,0x2
ffffffffc0203bf8:	18c50513          	addi	a0,a0,396 # ffffffffc0205d80 <default_pmm_manager+0xb30>
ffffffffc0203bfc:	f78fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        assert(vma5 == NULL);
ffffffffc0203c00:	00002697          	auipc	a3,0x2
ffffffffc0203c04:	28068693          	addi	a3,a3,640 # ffffffffc0205e80 <default_pmm_manager+0xc30>
ffffffffc0203c08:	00001617          	auipc	a2,0x1
ffffffffc0203c0c:	29860613          	addi	a2,a2,664 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203c10:	13600593          	li	a1,310
ffffffffc0203c14:	00002517          	auipc	a0,0x2
ffffffffc0203c18:	16c50513          	addi	a0,a0,364 # ffffffffc0205d80 <default_pmm_manager+0xb30>
ffffffffc0203c1c:	f58fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(pgdir[0] == 0);
ffffffffc0203c20:	00002697          	auipc	a3,0x2
ffffffffc0203c24:	d7068693          	addi	a3,a3,-656 # ffffffffc0205990 <default_pmm_manager+0x740>
ffffffffc0203c28:	00001617          	auipc	a2,0x1
ffffffffc0203c2c:	27860613          	addi	a2,a2,632 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203c30:	16800593          	li	a1,360
ffffffffc0203c34:	00002517          	auipc	a0,0x2
ffffffffc0203c38:	14c50513          	addi	a0,a0,332 # ffffffffc0205d80 <default_pmm_manager+0xb30>
ffffffffc0203c3c:	f38fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(check_mm_struct!= NULL);
ffffffffc0203c40:	00002697          	auipc	a3,0x2
ffffffffc0203c44:	3b068693          	addi	a3,a3,944 # ffffffffc0205ff0 <default_pmm_manager+0xda0>
ffffffffc0203c48:	00001617          	auipc	a2,0x1
ffffffffc0203c4c:	25860613          	addi	a2,a2,600 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203c50:	16200593          	li	a1,354
ffffffffc0203c54:	00002517          	auipc	a0,0x2
ffffffffc0203c58:	12c50513          	addi	a0,a0,300 # ffffffffc0205d80 <default_pmm_manager+0xb30>
    check_mm_struct = mm_create();
ffffffffc0203c5c:	0000e797          	auipc	a5,0xe
ffffffffc0203c60:	9007b223          	sd	zero,-1788(a5) # ffffffffc0211560 <check_mm_struct>
    assert(check_mm_struct!= NULL);
ffffffffc0203c64:	f10fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(vma!= NULL);
ffffffffc0203c68:	00002697          	auipc	a3,0x2
ffffffffc0203c6c:	37868693          	addi	a3,a3,888 # ffffffffc0205fe0 <default_pmm_manager+0xd90>
ffffffffc0203c70:	00001617          	auipc	a2,0x1
ffffffffc0203c74:	23060613          	addi	a2,a2,560 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203c78:	16d00593          	li	a1,365
ffffffffc0203c7c:	00002517          	auipc	a0,0x2
ffffffffc0203c80:	10450513          	addi	a0,a0,260 # ffffffffc0205d80 <default_pmm_manager+0xb30>
ffffffffc0203c84:	ef0fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc0203c88:	00002697          	auipc	a3,0x2
ffffffffc0203c8c:	2f068693          	addi	a3,a3,752 # ffffffffc0205f78 <default_pmm_manager+0xd28>
ffffffffc0203c90:	00001617          	auipc	a2,0x1
ffffffffc0203c94:	21060613          	addi	a2,a2,528 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203c98:	17500593          	li	a1,373
ffffffffc0203c9c:	00002517          	auipc	a0,0x2
ffffffffc0203ca0:	0e450513          	addi	a0,a0,228 # ffffffffc0205d80 <default_pmm_manager+0xb30>
ffffffffc0203ca4:	ed0fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(sum == 0);
ffffffffc0203ca8:	00002697          	auipc	a3,0x2
ffffffffc0203cac:	2f068693          	addi	a3,a3,752 # ffffffffc0205f98 <default_pmm_manager+0xd48>
ffffffffc0203cb0:	00001617          	auipc	a2,0x1
ffffffffc0203cb4:	1f060613          	addi	a2,a2,496 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203cb8:	18200593          	li	a1,386
ffffffffc0203cbc:	00002517          	auipc	a0,0x2
ffffffffc0203cc0:	0c450513          	addi	a0,a0,196 # ffffffffc0205d80 <default_pmm_manager+0xb30>
ffffffffc0203cc4:	eb0fc0ef          	jal	ra,ffffffffc0200374 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203cc8:	00001617          	auipc	a2,0x1
ffffffffc0203ccc:	61060613          	addi	a2,a2,1552 # ffffffffc02052d8 <default_pmm_manager+0x88>
ffffffffc0203cd0:	08000593          	li	a1,128
ffffffffc0203cd4:	00001517          	auipc	a0,0x1
ffffffffc0203cd8:	5f450513          	addi	a0,a0,1524 # ffffffffc02052c8 <default_pmm_manager+0x78>
ffffffffc0203cdc:	e98fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203ce0:	00002697          	auipc	a3,0x2
ffffffffc0203ce4:	25068693          	addi	a3,a3,592 # ffffffffc0205f30 <default_pmm_manager+0xce0>
ffffffffc0203ce8:	00001617          	auipc	a2,0x1
ffffffffc0203cec:	1b860613          	addi	a2,a2,440 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203cf0:	19800593          	li	a1,408
ffffffffc0203cf4:	00002517          	auipc	a0,0x2
ffffffffc0203cf8:	08c50513          	addi	a0,a0,140 # ffffffffc0205d80 <default_pmm_manager+0xb30>
ffffffffc0203cfc:	e78fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203d00:	00002697          	auipc	a3,0x2
ffffffffc0203d04:	23068693          	addi	a3,a3,560 # ffffffffc0205f30 <default_pmm_manager+0xce0>
ffffffffc0203d08:	00001617          	auipc	a2,0x1
ffffffffc0203d0c:	19860613          	addi	a2,a2,408 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203d10:	0fb00593          	li	a1,251
ffffffffc0203d14:	00002517          	auipc	a0,0x2
ffffffffc0203d18:	06c50513          	addi	a0,a0,108 # ffffffffc0205d80 <default_pmm_manager+0xb30>
ffffffffc0203d1c:	e58fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(mm!= NULL);
ffffffffc0203d20:	00002697          	auipc	a3,0x2
ffffffffc0203d24:	2e868693          	addi	a3,a3,744 # ffffffffc0206008 <default_pmm_manager+0xdb8>
ffffffffc0203d28:	00001617          	auipc	a2,0x1
ffffffffc0203d2c:	17860613          	addi	a2,a2,376 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203d30:	10900593          	li	a1,265
ffffffffc0203d34:	00002517          	auipc	a0,0x2
ffffffffc0203d38:	04c50513          	addi	a0,a0,76 # ffffffffc0205d80 <default_pmm_manager+0xb30>
ffffffffc0203d3c:	e38fc0ef          	jal	ra,ffffffffc0200374 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc0203d40:	00002697          	auipc	a3,0x2
ffffffffc0203d44:	1f068693          	addi	a3,a3,496 # ffffffffc0205f30 <default_pmm_manager+0xce0>
ffffffffc0203d48:	00001617          	auipc	a2,0x1
ffffffffc0203d4c:	15860613          	addi	a2,a2,344 # ffffffffc0204ea0 <commands+0x738>
ffffffffc0203d50:	14b00593          	li	a1,331
ffffffffc0203d54:	00002517          	auipc	a0,0x2
ffffffffc0203d58:	02c50513          	addi	a0,a0,44 # ffffffffc0205d80 <default_pmm_manager+0xb30>
ffffffffc0203d5c:	e18fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203d60 <do_pgfault>:
 *    - P标志（第0位）：表示异常是由于页面不存在（值为0），还是由于访问权限违规或者使用了保留位（值为1）所导致的。
 *    - W/R标志（第1位）：表示引发异常的内存访问操作是读操作（值为0）还是写操作（值为1）。
 *    - U/S标志（第1位）：表示处理器在发生异常时是处于用户模式（值为1）还是超级用户（也叫内核、监督者等，值为0）模式。
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203d60:	7179                	addi	sp,sp,-48
ffffffffc0203d62:	ec26                	sd	s1,24(sp)
ffffffffc0203d64:	84aa                	mv	s1,a0
    pte_t* temp = NULL;
temp = get_pte(mm->pgdir, addr, 0);
ffffffffc0203d66:	6d08                	ld	a0,24(a0)
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203d68:	f022                	sd	s0,32(sp)
ffffffffc0203d6a:	8432                	mv	s0,a2
ffffffffc0203d6c:	e84a                	sd	s2,16(sp)
temp = get_pte(mm->pgdir, addr, 0);
ffffffffc0203d6e:	4601                	li	a2,0
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203d70:	892e                	mv	s2,a1
temp = get_pte(mm->pgdir, addr, 0);
ffffffffc0203d72:	85a2                	mv	a1,s0
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203d74:	f406                	sd	ra,40(sp)
temp = get_pte(mm->pgdir, addr, 0);
ffffffffc0203d76:	a63fd0ef          	jal	ra,ffffffffc02017d8 <get_pte>
if(temp != NULL && (*temp & (PTE_V | PTE_R))) {
ffffffffc0203d7a:	c501                	beqz	a0,ffffffffc0203d82 <do_pgfault+0x22>
ffffffffc0203d7c:	611c                	ld	a5,0(a0)
ffffffffc0203d7e:	8b8d                	andi	a5,a5,3
ffffffffc0203d80:	e3cd                	bnez	a5,ffffffffc0203e22 <do_pgfault+0xc2>
    int ret = -E_INVAL;

    // 尝试在给定的mm_struct结构体所管理的虚拟内存区域中查找包含指定地址（addr）的虚拟内存区域（vma_struct），
    // 通过调用find_vma函数来实现查找功能，返回查找到的vma_struct结构体指针并存储在vma变量中，
    // 后续会基于这个vma来进一步判断地址的合法性以及进行相应的页面错误处理操作，例如判断地址是否在合法的虚拟内存区域范围内等。
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203d82:	85a2                	mv	a1,s0
ffffffffc0203d84:	8526                	mv	a0,s1
ffffffffc0203d86:	8bdff0ef          	jal	ra,ffffffffc0203642 <find_vma>

    // 将全局的页面错误发生次数（pgfault_num）加1，每次进入这个页面错误处理函数就表示发生了一次新的页面错误，
    // 通过这个变量可以统计页面错误出现的频率等信息，对于调试、分析系统的内存访问情况以及评估页面错误处理机制的性能等方面都有帮助。
    pgfault_num++;
ffffffffc0203d8a:	0000d797          	auipc	a5,0xd
ffffffffc0203d8e:	7de7a783          	lw	a5,2014(a5) # ffffffffc0211568 <pgfault_num>
ffffffffc0203d92:	2785                	addiw	a5,a5,1
ffffffffc0203d94:	0000d717          	auipc	a4,0xd
ffffffffc0203d98:	7cf72a23          	sw	a5,2004(a4) # ffffffffc0211568 <pgfault_num>

    // 判断触发页面错误的地址（addr）是否在mm结构体管理的某个虚拟内存区域（vma）范围内，
    // 如果vma为NULL（意味着没有找到对应的虚拟内存区域）或者vma的起始地址大于addr（说明给定地址不在找到的vma范围内），
    // 那么这个地址就是不合法的，无法进行有效的页面错误处理，此时会输出相应的提示信息（通过cprintf函数），
    // 并跳转到failed标签处，最终返回错误码（当前的ret值，即 -E_INVAL）表示处理失败。
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203d9c:	cd49                	beqz	a0,ffffffffc0203e36 <do_pgfault+0xd6>
ffffffffc0203d9e:	651c                	ld	a5,8(a0)
ffffffffc0203da0:	08f46b63          	bltu	s0,a5,ffffffffc0203e36 <do_pgfault+0xd6>
     * 二是对不存在的页面地址，但该地址具有可写权限的情况下进行写入操作；
     * 三是对不存在的页面地址，但该地址具有可读权限的情况下进行读取操作。
     * 这种判断是基于内存访问权限和页面存在与否的逻辑来决定是否可以进一步处理页面错误，以恢复正常的内存访问。
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203da4:	6d1c                	ld	a5,24(a0)
ffffffffc0203da6:	4941                	li	s2,16
ffffffffc0203da8:	8b89                	andi	a5,a5,2
ffffffffc0203daa:	ebb1                	bnez	a5,ffffffffc0203dfe <do_pgfault+0x9e>
    }
    perm &= ~PTE_R;
    // 将触发页面错误的地址（addr）按照页面大小向下取整，通过调用ROUNDDOWN宏（这个宏应该在其他地方定义，用于按页面大小对齐地址）来实现。
    // 这样做的目的是在处理页面相关操作时，确保处理的是页面粒度的地址，符合内存管理中以页面为单位进行映射、分配等操作的要求，
    // 后续关于页面表项查找、页面分配以及页面与地址映射等操作都是基于这个取整后的地址来进行的。
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203dac:	767d                	lui	a2,0xfffff
    * 通过这个指针可以访问和操作整个页表体系，用于查找、创建以及维护页面的虚拟地址到物理地址的映射关系，是内存管理中非常关键的一个数据结构指针。
    *
    */


    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203dae:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203db0:	8c71                	and	s0,s0,a2
    ptep = get_pte(mm->pgdir, addr, 1);  //(1) try to find a pte, if pte's
ffffffffc0203db2:	85a2                	mv	a1,s0
ffffffffc0203db4:	4605                	li	a2,1
ffffffffc0203db6:	a23fd0ef          	jal	ra,ffffffffc02017d8 <get_pte>
                                         //create a PT.
    // 调用get_pte函数尝试获取对应于给定地址（addr）的页面表项（PTE），传入mm结构体中的页目录表指针（mm->pgdir）以及地址（addr），
    // 第三个参数1表示如果对应的页表（Page Table，PT）不存在，则分配一个页面用于创建该页表，
    // 返回获取到的页面表项的内核虚拟地址存储在ptep指针中，后续将基于这个表项进行相关判断和操作，例如判断页面是否存在、进行页面交换等处理。

    if (*ptep == 0) {
ffffffffc0203dba:	610c                	ld	a1,0(a0)
ffffffffc0203dbc:	c1b9                	beqz	a1,ffffffffc0203e02 <do_pgfault+0xa2>
        *
        *    swap_map_swappable ： 设置页面可交换
        *    含义：该函数用于设置页面是否可交换的属性，在内存管理中，有些页面可能需要在内存和磁盘之间进行交换（比如内存不足时将部分页面换出到磁盘），
        *    通过这个函数可以标记页面是否可以参与这样的交换操作，以便交换管理器等相关模块进行管理和调度。
        */
        if (swap_init_ok) {
ffffffffc0203dbe:	0000d797          	auipc	a5,0xd
ffffffffc0203dc2:	7927a783          	lw	a5,1938(a5) # ffffffffc0211550 <swap_init_ok>
ffffffffc0203dc6:	c3c9                	beqz	a5,ffffffffc0203e48 <do_pgfault+0xe8>
            // (1）According to the mm AND addr, try
            // to load the content of right disk page
            // into the memory which page managed.
            // 调用swap_in函数，根据传入的mm结构体和地址（addr），分配一个内存页，并根据页面表项（PTE）中的交换条目地址信息，
            // 找到磁盘页的地址，然后将磁盘页的内容读入这个新分配的内存页中，完成从磁盘加载数据到内存的操作，为后续恢复页面映射做准备。
            swap_in(mm, addr, &page);
ffffffffc0203dc8:	85a2                	mv	a1,s0
ffffffffc0203dca:	0030                	addi	a2,sp,8
ffffffffc0203dcc:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc0203dce:	e402                	sd	zero,8(sp)
            swap_in(mm, addr, &page);
ffffffffc0203dd0:	becff0ef          	jal	ra,ffffffffc02031bc <swap_in>
            // map of phy addr <--->
            // logical addr
            // 调用page_insert函数，根据传入的mm结构体、页面指针（page）、地址（addr）以及权限（perm），
            // 建立页面的物理地址与线性地址（即逻辑地址）之间的映射关系，使得内存中的页面能够正确地对应到虚拟地址空间中，
            // 恢复因页面交换等原因导致的映射缺失情况，确保可以通过虚拟地址访问到正确的物理页面。
            page_insert(mm->pgdir, page, addr, perm);
ffffffffc0203dd4:	65a2                	ld	a1,8(sp)
ffffffffc0203dd6:	6c88                	ld	a0,24(s1)
ffffffffc0203dd8:	86ca                	mv	a3,s2
ffffffffc0203dda:	8622                	mv	a2,s0
ffffffffc0203ddc:	ce7fd0ef          	jal	ra,ffffffffc0201ac2 <page_insert>
            // (3) make the page swappable.
            // 调用swap_map_swappable函数，设置刚才加载数据并建立映射的页面为可交换状态，这样该页面后续在内存紧张等情况下可以被交换管理器合理地换出到磁盘或者从磁盘换入内存，
            // 实现内存资源的动态管理，同时传入参数1表示设置为可交换（具体参数含义可能根据函数定义来确定，这里推测1表示可交换的设置值）。
            swap_map_swappable(mm, addr, page, 1);
ffffffffc0203de0:	6622                	ld	a2,8(sp)
ffffffffc0203de2:	4685                	li	a3,1
ffffffffc0203de4:	85a2                	mv	a1,s0
ffffffffc0203de6:	8526                	mv	a0,s1
ffffffffc0203de8:	ab4ff0ef          	jal	ra,ffffffffc020309c <swap_map_swappable>
            // 将页面结构体（page）中的pra_vaddr成员变量设置为当前处理的地址（addr），这个操作可能是用于记录页面对应的虚拟地址相关信息，
            // 方便后续在内存管理的其他操作（比如页面查找、验证等）中使用，建立页面与虚拟地址之间更明确的关联关系。
            page->pra_vaddr = addr;
ffffffffc0203dec:	67a2                	ld	a5,8(sp)
        }
    }

   // 如果前面的页面错误处理操作都顺利完成，没有出现错误（比如页面分配成功、从磁盘加载数据及建立映射等操作都成功执行），
   // 则将返回值ret设置为0，表示页面错误处理成功，后续调用该函数的地方可以根据这个返回值判断处理结果并进行相应的后续操作。
    ret = 0;
ffffffffc0203dee:	4501                	li	a0,0
            page->pra_vaddr = addr;
ffffffffc0203df0:	e3a0                	sd	s0,64(a5)
failed:
    // 当出现错误情况（如地址不合法、页面分配失败、交换相关操作失败等）时，代码会通过goto语句跳转到这里，
    // 然后直接返回当前的ret值，这个值可能是之前设置的表示错误的代码（如 -E_INVAL 或 -E_NO_MEM），
    // 从而将页面错误处理的结果返回给调用者，调用者可以根据返回的错误码采取进一步的措施，比如向用户报告错误、进行错误记录或者尝试其他的恢复策略等。
    return ret;
ffffffffc0203df2:	70a2                	ld	ra,40(sp)
ffffffffc0203df4:	7402                	ld	s0,32(sp)
ffffffffc0203df6:	64e2                	ld	s1,24(sp)
ffffffffc0203df8:	6942                	ld	s2,16(sp)
ffffffffc0203dfa:	6145                	addi	sp,sp,48
ffffffffc0203dfc:	8082                	ret
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203dfe:	4951                	li	s2,20
ffffffffc0203e00:	b775                	j	ffffffffc0203dac <do_pgfault+0x4c>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203e02:	6c88                	ld	a0,24(s1)
ffffffffc0203e04:	864a                	mv	a2,s2
ffffffffc0203e06:	85a2                	mv	a1,s0
ffffffffc0203e08:	9c5fe0ef          	jal	ra,ffffffffc02027cc <pgdir_alloc_page>
ffffffffc0203e0c:	87aa                	mv	a5,a0
    ret = 0;
ffffffffc0203e0e:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203e10:	f3ed                	bnez	a5,ffffffffc0203df2 <do_pgfault+0x92>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203e12:	00002517          	auipc	a0,0x2
ffffffffc0203e16:	23650513          	addi	a0,a0,566 # ffffffffc0206048 <default_pmm_manager+0xdf8>
ffffffffc0203e1a:	aa0fc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203e1e:	5571                	li	a0,-4
            goto failed;
ffffffffc0203e20:	bfc9                	j	ffffffffc0203df2 <do_pgfault+0x92>
    return lru_pgfault(mm, error_code, addr);
ffffffffc0203e22:	8622                	mv	a2,s0
ffffffffc0203e24:	7402                	ld	s0,32(sp)
ffffffffc0203e26:	70a2                	ld	ra,40(sp)
    return lru_pgfault(mm, error_code, addr);
ffffffffc0203e28:	85ca                	mv	a1,s2
ffffffffc0203e2a:	8526                	mv	a0,s1
ffffffffc0203e2c:	6942                	ld	s2,16(sp)
ffffffffc0203e2e:	64e2                	ld	s1,24(sp)
ffffffffc0203e30:	6145                	addi	sp,sp,48
    return lru_pgfault(mm, error_code, addr);
ffffffffc0203e32:	f56fd06f          	j	ffffffffc0201588 <lru_pgfault>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203e36:	85a2                	mv	a1,s0
ffffffffc0203e38:	00002517          	auipc	a0,0x2
ffffffffc0203e3c:	1e050513          	addi	a0,a0,480 # ffffffffc0206018 <default_pmm_manager+0xdc8>
ffffffffc0203e40:	a7afc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    int ret = -E_INVAL;
ffffffffc0203e44:	5575                	li	a0,-3
        goto failed;
ffffffffc0203e46:	b775                	j	ffffffffc0203df2 <do_pgfault+0x92>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0203e48:	00002517          	auipc	a0,0x2
ffffffffc0203e4c:	22850513          	addi	a0,a0,552 # ffffffffc0206070 <default_pmm_manager+0xe20>
ffffffffc0203e50:	a6afc0ef          	jal	ra,ffffffffc02000ba <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203e54:	5571                	li	a0,-4
            goto failed;
ffffffffc0203e56:	bf71                	j	ffffffffc0203df2 <do_pgfault+0x92>

ffffffffc0203e58 <swapfs_init>:
#include <pmm.h>
// 包含断言相关头文件，用于在代码中进行条件断言检查，确保程序运行时某些关键条件满足
#include <assert.h>

// 函数用于初始化交换文件系统相关的资源和进行一些必要的检查
void swapfs_init(void) {
ffffffffc0203e58:	1141                	addi	sp,sp,-16
    // 使用静态断言检查页面大小（PGSIZE）是否是磁盘扇区大小（SECTSIZE）的整数倍，这是为了保证后续以扇区为单位进行数据交换等操作时能正确对齐
    static_assert((PGSIZE % SECTSIZE) == 0);
    // 调用ide_device_valid函数验证交换设备编号（SWAP_DEV_NO，定义为1）对应的设备是否有效
    // 如果设备无效（返回false），则调用panic函数（应该是系统的错误处理函数，用于终止程序并输出错误信息）提示交换文件系统不可用
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203e5a:	4505                	li	a0,1
void swapfs_init(void) {
ffffffffc0203e5c:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0203e5e:	e36fc0ef          	jal	ra,ffffffffc0200494 <ide_device_valid>
ffffffffc0203e62:	cd01                	beqz	a0,ffffffffc0203e7a <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    // 计算并赋值最大交换偏移量（max_swap_offset），通过获取交换设备（SWAP_DEV_NO对应的设备）的大小（以扇区数量表示，调用ide_device_size函数获取）除以一页需要的扇区数量（PAGE_NSECT）得到
    // 这个偏移量可能用于后续在交换空间中定位数据等操作
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PAGE_NSECT);//最大扇区数量56/单页所占扇区数量8=7
ffffffffc0203e64:	4505                	li	a0,1
ffffffffc0203e66:	e34fc0ef          	jal	ra,ffffffffc020049a <ide_device_size>
}
ffffffffc0203e6a:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PAGE_NSECT);//最大扇区数量56/单页所占扇区数量8=7
ffffffffc0203e6c:	810d                	srli	a0,a0,0x3
ffffffffc0203e6e:	0000d797          	auipc	a5,0xd
ffffffffc0203e72:	6ca7b923          	sd	a0,1746(a5) # ffffffffc0211540 <max_swap_offset>
}
ffffffffc0203e76:	0141                	addi	sp,sp,16
ffffffffc0203e78:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0203e7a:	00002617          	auipc	a2,0x2
ffffffffc0203e7e:	21e60613          	addi	a2,a2,542 # ffffffffc0206098 <default_pmm_manager+0xe48>
ffffffffc0203e82:	45dd                	li	a1,23
ffffffffc0203e84:	00002517          	auipc	a0,0x2
ffffffffc0203e88:	23450513          	addi	a0,a0,564 # ffffffffc02060b8 <default_pmm_manager+0xe68>
ffffffffc0203e8c:	ce8fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203e90 <swapfs_read>:

// 函数用于模拟从交换文件系统（也就是模拟的“硬盘”交换区）读取数据到指定的页面中
// 参数说明：
// - entry: 交换项相关的结构体（swap_entry_t类型，具体定义应该在swap.h等相关头文件中），可能包含了交换数据在交换区中的位置等信息
// - page: 指向Page结构体的指针（Page结构体应该与页面管理相关，定义在其他地方），表示要将读取的数据存入的目标页面
int swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0203e90:	1141                	addi	sp,sp,-16
ffffffffc0203e92:	e406                	sd	ra,8(sp)
    // 函数从调用ide_read_secs交换设备（SWAP_DEV_NO对应的设备，即模拟的“硬盘”）读取数据
    // 读取的起始扇区号通过swap_offset函数（应该是根据entry计算得到起始扇区号相关的函数，定义在其他地方）乘以一页需要的扇区数量（PAGE_NSECT）得到
    // 读取的数据要存入的目标内存地址通过page2kva函数（应该是将页面结构体转换为对应的内存地址的函数，定义在其他地方）得到，读取的数据长度为一页需要的扇区数量（PAGE_NSECT）
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203e94:	00855793          	srli	a5,a0,0x8
ffffffffc0203e98:	c3a5                	beqz	a5,ffffffffc0203ef8 <swapfs_read+0x68>
ffffffffc0203e9a:	0000d717          	auipc	a4,0xd
ffffffffc0203e9e:	6a673703          	ld	a4,1702(a4) # ffffffffc0211540 <max_swap_offset>
ffffffffc0203ea2:	04e7fb63          	bgeu	a5,a4,ffffffffc0203ef8 <swapfs_read+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203ea6:	0000d617          	auipc	a2,0xd
ffffffffc0203eaa:	68263603          	ld	a2,1666(a2) # ffffffffc0211528 <pages>
ffffffffc0203eae:	8d91                	sub	a1,a1,a2
ffffffffc0203eb0:	4035d613          	srai	a2,a1,0x3
ffffffffc0203eb4:	00002597          	auipc	a1,0x2
ffffffffc0203eb8:	4845b583          	ld	a1,1156(a1) # ffffffffc0206338 <error_string+0x38>
ffffffffc0203ebc:	02b60633          	mul	a2,a2,a1
ffffffffc0203ec0:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203ec4:	00002797          	auipc	a5,0x2
ffffffffc0203ec8:	47c7b783          	ld	a5,1148(a5) # ffffffffc0206340 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ecc:	0000d717          	auipc	a4,0xd
ffffffffc0203ed0:	65473703          	ld	a4,1620(a4) # ffffffffc0211520 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203ed4:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ed6:	00c61793          	slli	a5,a2,0xc
ffffffffc0203eda:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203edc:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203ede:	02e7fa63          	bgeu	a5,a4,ffffffffc0203f12 <swapfs_read+0x82>
}
ffffffffc0203ee2:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ee4:	0000d797          	auipc	a5,0xd
ffffffffc0203ee8:	6547b783          	ld	a5,1620(a5) # ffffffffc0211538 <va_pa_offset>
ffffffffc0203eec:	46a1                	li	a3,8
ffffffffc0203eee:	963e                	add	a2,a2,a5
ffffffffc0203ef0:	4505                	li	a0,1
}
ffffffffc0203ef2:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203ef4:	dacfc06f          	j	ffffffffc02004a0 <ide_read_secs>
ffffffffc0203ef8:	86aa                	mv	a3,a0
ffffffffc0203efa:	00002617          	auipc	a2,0x2
ffffffffc0203efe:	1d660613          	addi	a2,a2,470 # ffffffffc02060d0 <default_pmm_manager+0xe80>
ffffffffc0203f02:	02600593          	li	a1,38
ffffffffc0203f06:	00002517          	auipc	a0,0x2
ffffffffc0203f0a:	1b250513          	addi	a0,a0,434 # ffffffffc02060b8 <default_pmm_manager+0xe68>
ffffffffc0203f0e:	c66fc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203f12:	86b2                	mv	a3,a2
ffffffffc0203f14:	08600593          	li	a1,134
ffffffffc0203f18:	00001617          	auipc	a2,0x1
ffffffffc0203f1c:	3e060613          	addi	a2,a2,992 # ffffffffc02052f8 <default_pmm_manager+0xa8>
ffffffffc0203f20:	00001517          	auipc	a0,0x1
ffffffffc0203f24:	3a850513          	addi	a0,a0,936 # ffffffffc02052c8 <default_pmm_manager+0x78>
ffffffffc0203f28:	c4cfc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203f2c <swapfs_write>:

// 函数用于模拟将指定页面的数据写入到交换文件系统（模拟的“硬盘”交换区）中
// 参数说明：
// - entry: 交换项相关的结构体（swap_entry_t类型），包含了写入数据在交换区中的目标位置等信息
// - page: 指向Page结构体的指针，表示要写入的源页面数据
int swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0203f2c:	1141                	addi	sp,sp,-16
ffffffffc0203f2e:	e406                	sd	ra,8(sp)
    // 调用ide_write_secs函数向交换设备（SWAP_DEV_NO对应的设备）写入数据
    // 写入的起始扇区号通过swap_offset函数乘以一页需要的扇区数量（PAGE_NSECT）得到
    // 写入的源数据地址通过page2kva函数得到，写入的数据长度为一页需要的扇区数量（PAGE_NSECT）
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f30:	00855793          	srli	a5,a0,0x8
ffffffffc0203f34:	c3a5                	beqz	a5,ffffffffc0203f94 <swapfs_write+0x68>
ffffffffc0203f36:	0000d717          	auipc	a4,0xd
ffffffffc0203f3a:	60a73703          	ld	a4,1546(a4) # ffffffffc0211540 <max_swap_offset>
ffffffffc0203f3e:	04e7fb63          	bgeu	a5,a4,ffffffffc0203f94 <swapfs_write+0x68>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203f42:	0000d617          	auipc	a2,0xd
ffffffffc0203f46:	5e663603          	ld	a2,1510(a2) # ffffffffc0211528 <pages>
ffffffffc0203f4a:	8d91                	sub	a1,a1,a2
ffffffffc0203f4c:	4035d613          	srai	a2,a1,0x3
ffffffffc0203f50:	00002597          	auipc	a1,0x2
ffffffffc0203f54:	3e85b583          	ld	a1,1000(a1) # ffffffffc0206338 <error_string+0x38>
ffffffffc0203f58:	02b60633          	mul	a2,a2,a1
ffffffffc0203f5c:	0037959b          	slliw	a1,a5,0x3
ffffffffc0203f60:	00002797          	auipc	a5,0x2
ffffffffc0203f64:	3e07b783          	ld	a5,992(a5) # ffffffffc0206340 <nbase>
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f68:	0000d717          	auipc	a4,0xd
ffffffffc0203f6c:	5b873703          	ld	a4,1464(a4) # ffffffffc0211520 <npage>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0203f70:	963e                	add	a2,a2,a5
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f72:	00c61793          	slli	a5,a2,0xc
ffffffffc0203f76:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0203f78:	0632                	slli	a2,a2,0xc
static inline void *page2kva(struct Page *page) { return KADDR(page2pa(page)); }
ffffffffc0203f7a:	02e7fa63          	bgeu	a5,a4,ffffffffc0203fae <swapfs_write+0x82>
ffffffffc0203f7e:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f80:	0000d797          	auipc	a5,0xd
ffffffffc0203f84:	5b87b783          	ld	a5,1464(a5) # ffffffffc0211538 <va_pa_offset>
ffffffffc0203f88:	46a1                	li	a3,8
ffffffffc0203f8a:	963e                	add	a2,a2,a5
ffffffffc0203f8c:	4505                	li	a0,1
ffffffffc0203f8e:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0203f90:	d34fc06f          	j	ffffffffc02004c4 <ide_write_secs>
ffffffffc0203f94:	86aa                	mv	a3,a0
ffffffffc0203f96:	00002617          	auipc	a2,0x2
ffffffffc0203f9a:	13a60613          	addi	a2,a2,314 # ffffffffc02060d0 <default_pmm_manager+0xe80>
ffffffffc0203f9e:	03100593          	li	a1,49
ffffffffc0203fa2:	00002517          	auipc	a0,0x2
ffffffffc0203fa6:	11650513          	addi	a0,a0,278 # ffffffffc02060b8 <default_pmm_manager+0xe68>
ffffffffc0203faa:	bcafc0ef          	jal	ra,ffffffffc0200374 <__panic>
ffffffffc0203fae:	86b2                	mv	a3,a2
ffffffffc0203fb0:	08600593          	li	a1,134
ffffffffc0203fb4:	00001617          	auipc	a2,0x1
ffffffffc0203fb8:	34460613          	addi	a2,a2,836 # ffffffffc02052f8 <default_pmm_manager+0xa8>
ffffffffc0203fbc:	00001517          	auipc	a0,0x1
ffffffffc0203fc0:	30c50513          	addi	a0,a0,780 # ffffffffc02052c8 <default_pmm_manager+0x78>
ffffffffc0203fc4:	bb0fc0ef          	jal	ra,ffffffffc0200374 <__panic>

ffffffffc0203fc8 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0203fc8:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203fcc:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0203fce:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203fd2:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0203fd4:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0203fd8:	f022                	sd	s0,32(sp)
ffffffffc0203fda:	ec26                	sd	s1,24(sp)
ffffffffc0203fdc:	e84a                	sd	s2,16(sp)
ffffffffc0203fde:	f406                	sd	ra,40(sp)
ffffffffc0203fe0:	e44e                	sd	s3,8(sp)
ffffffffc0203fe2:	84aa                	mv	s1,a0
ffffffffc0203fe4:	892e                	mv	s2,a1
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0203fe6:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0203fea:	2a01                	sext.w	s4,s4
    if (num >= base) {
ffffffffc0203fec:	03067e63          	bgeu	a2,a6,ffffffffc0204028 <printnum+0x60>
ffffffffc0203ff0:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0203ff2:	00805763          	blez	s0,ffffffffc0204000 <printnum+0x38>
ffffffffc0203ff6:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0203ff8:	85ca                	mv	a1,s2
ffffffffc0203ffa:	854e                	mv	a0,s3
ffffffffc0203ffc:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0203ffe:	fc65                	bnez	s0,ffffffffc0203ff6 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204000:	1a02                	slli	s4,s4,0x20
ffffffffc0204002:	00002797          	auipc	a5,0x2
ffffffffc0204006:	0ee78793          	addi	a5,a5,238 # ffffffffc02060f0 <default_pmm_manager+0xea0>
ffffffffc020400a:	020a5a13          	srli	s4,s4,0x20
ffffffffc020400e:	9a3e                	add	s4,s4,a5
}
ffffffffc0204010:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204012:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0204016:	70a2                	ld	ra,40(sp)
ffffffffc0204018:	69a2                	ld	s3,8(sp)
ffffffffc020401a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020401c:	85ca                	mv	a1,s2
ffffffffc020401e:	87a6                	mv	a5,s1
}
ffffffffc0204020:	6942                	ld	s2,16(sp)
ffffffffc0204022:	64e2                	ld	s1,24(sp)
ffffffffc0204024:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0204026:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0204028:	03065633          	divu	a2,a2,a6
ffffffffc020402c:	8722                	mv	a4,s0
ffffffffc020402e:	f9bff0ef          	jal	ra,ffffffffc0203fc8 <printnum>
ffffffffc0204032:	b7f9                	j	ffffffffc0204000 <printnum+0x38>

ffffffffc0204034 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0204034:	7119                	addi	sp,sp,-128
ffffffffc0204036:	f4a6                	sd	s1,104(sp)
ffffffffc0204038:	f0ca                	sd	s2,96(sp)
ffffffffc020403a:	ecce                	sd	s3,88(sp)
ffffffffc020403c:	e8d2                	sd	s4,80(sp)
ffffffffc020403e:	e4d6                	sd	s5,72(sp)
ffffffffc0204040:	e0da                	sd	s6,64(sp)
ffffffffc0204042:	fc5e                	sd	s7,56(sp)
ffffffffc0204044:	f06a                	sd	s10,32(sp)
ffffffffc0204046:	fc86                	sd	ra,120(sp)
ffffffffc0204048:	f8a2                	sd	s0,112(sp)
ffffffffc020404a:	f862                	sd	s8,48(sp)
ffffffffc020404c:	f466                	sd	s9,40(sp)
ffffffffc020404e:	ec6e                	sd	s11,24(sp)
ffffffffc0204050:	892a                	mv	s2,a0
ffffffffc0204052:	84ae                	mv	s1,a1
ffffffffc0204054:	8d32                	mv	s10,a2
ffffffffc0204056:	8a36                	mv	s4,a3
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204058:	02500993          	li	s3,37
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc020405c:	5b7d                	li	s6,-1
ffffffffc020405e:	00002a97          	auipc	s5,0x2
ffffffffc0204062:	0c6a8a93          	addi	s5,s5,198 # ffffffffc0206124 <default_pmm_manager+0xed4>
        case 'e':
            err = va_arg(ap, int);
            if (err < 0) {
                err = -err;
            }
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0204066:	00002b97          	auipc	s7,0x2
ffffffffc020406a:	29ab8b93          	addi	s7,s7,666 # ffffffffc0206300 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020406e:	000d4503          	lbu	a0,0(s10) # 80000 <kern_entry-0xffffffffc0180000>
ffffffffc0204072:	001d0413          	addi	s0,s10,1
ffffffffc0204076:	01350a63          	beq	a0,s3,ffffffffc020408a <vprintfmt+0x56>
            if (ch == '\0') {
ffffffffc020407a:	c121                	beqz	a0,ffffffffc02040ba <vprintfmt+0x86>
            putch(ch, putdat);
ffffffffc020407c:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020407e:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0204080:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0204082:	fff44503          	lbu	a0,-1(s0)
ffffffffc0204086:	ff351ae3          	bne	a0,s3,ffffffffc020407a <vprintfmt+0x46>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020408a:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc020408e:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0204092:	4c81                	li	s9,0
ffffffffc0204094:	4881                	li	a7,0
        width = precision = -1;
ffffffffc0204096:	5c7d                	li	s8,-1
ffffffffc0204098:	5dfd                	li	s11,-1
ffffffffc020409a:	05500513          	li	a0,85
                if (ch < '0' || ch > '9') {
ffffffffc020409e:	4825                	li	a6,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040a0:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02040a4:	0ff5f593          	andi	a1,a1,255
ffffffffc02040a8:	00140d13          	addi	s10,s0,1
ffffffffc02040ac:	04b56263          	bltu	a0,a1,ffffffffc02040f0 <vprintfmt+0xbc>
ffffffffc02040b0:	058a                	slli	a1,a1,0x2
ffffffffc02040b2:	95d6                	add	a1,a1,s5
ffffffffc02040b4:	4194                	lw	a3,0(a1)
ffffffffc02040b6:	96d6                	add	a3,a3,s5
ffffffffc02040b8:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02040ba:	70e6                	ld	ra,120(sp)
ffffffffc02040bc:	7446                	ld	s0,112(sp)
ffffffffc02040be:	74a6                	ld	s1,104(sp)
ffffffffc02040c0:	7906                	ld	s2,96(sp)
ffffffffc02040c2:	69e6                	ld	s3,88(sp)
ffffffffc02040c4:	6a46                	ld	s4,80(sp)
ffffffffc02040c6:	6aa6                	ld	s5,72(sp)
ffffffffc02040c8:	6b06                	ld	s6,64(sp)
ffffffffc02040ca:	7be2                	ld	s7,56(sp)
ffffffffc02040cc:	7c42                	ld	s8,48(sp)
ffffffffc02040ce:	7ca2                	ld	s9,40(sp)
ffffffffc02040d0:	7d02                	ld	s10,32(sp)
ffffffffc02040d2:	6de2                	ld	s11,24(sp)
ffffffffc02040d4:	6109                	addi	sp,sp,128
ffffffffc02040d6:	8082                	ret
            padc = '0';
ffffffffc02040d8:	87b2                	mv	a5,a2
            goto reswitch;
ffffffffc02040da:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02040de:	846a                	mv	s0,s10
ffffffffc02040e0:	00140d13          	addi	s10,s0,1
ffffffffc02040e4:	fdd6059b          	addiw	a1,a2,-35
ffffffffc02040e8:	0ff5f593          	andi	a1,a1,255
ffffffffc02040ec:	fcb572e3          	bgeu	a0,a1,ffffffffc02040b0 <vprintfmt+0x7c>
            putch('%', putdat);
ffffffffc02040f0:	85a6                	mv	a1,s1
ffffffffc02040f2:	02500513          	li	a0,37
ffffffffc02040f6:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02040f8:	fff44783          	lbu	a5,-1(s0)
ffffffffc02040fc:	8d22                	mv	s10,s0
ffffffffc02040fe:	f73788e3          	beq	a5,s3,ffffffffc020406e <vprintfmt+0x3a>
ffffffffc0204102:	ffed4783          	lbu	a5,-2(s10)
ffffffffc0204106:	1d7d                	addi	s10,s10,-1
ffffffffc0204108:	ff379de3          	bne	a5,s3,ffffffffc0204102 <vprintfmt+0xce>
ffffffffc020410c:	b78d                	j	ffffffffc020406e <vprintfmt+0x3a>
                precision = precision * 10 + ch - '0';
ffffffffc020410e:	fd060c1b          	addiw	s8,a2,-48
                ch = *fmt;
ffffffffc0204112:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204116:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0204118:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020411c:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204120:	02d86463          	bltu	a6,a3,ffffffffc0204148 <vprintfmt+0x114>
                ch = *fmt;
ffffffffc0204124:	00144603          	lbu	a2,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0204128:	002c169b          	slliw	a3,s8,0x2
ffffffffc020412c:	0186873b          	addw	a4,a3,s8
ffffffffc0204130:	0017171b          	slliw	a4,a4,0x1
ffffffffc0204134:	9f2d                	addw	a4,a4,a1
                if (ch < '0' || ch > '9') {
ffffffffc0204136:	fd06069b          	addiw	a3,a2,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc020413a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc020413c:	fd070c1b          	addiw	s8,a4,-48
                ch = *fmt;
ffffffffc0204140:	0006059b          	sext.w	a1,a2
                if (ch < '0' || ch > '9') {
ffffffffc0204144:	fed870e3          	bgeu	a6,a3,ffffffffc0204124 <vprintfmt+0xf0>
            if (width < 0)
ffffffffc0204148:	f40ddce3          	bgez	s11,ffffffffc02040a0 <vprintfmt+0x6c>
                width = precision, precision = -1;
ffffffffc020414c:	8de2                	mv	s11,s8
ffffffffc020414e:	5c7d                	li	s8,-1
ffffffffc0204150:	bf81                	j	ffffffffc02040a0 <vprintfmt+0x6c>
            if (width < 0)
ffffffffc0204152:	fffdc693          	not	a3,s11
ffffffffc0204156:	96fd                	srai	a3,a3,0x3f
ffffffffc0204158:	00ddfdb3          	and	s11,s11,a3
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020415c:	00144603          	lbu	a2,1(s0)
ffffffffc0204160:	2d81                	sext.w	s11,s11
ffffffffc0204162:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc0204164:	bf35                	j	ffffffffc02040a0 <vprintfmt+0x6c>
            precision = va_arg(ap, int);
ffffffffc0204166:	000a2c03          	lw	s8,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020416a:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020416e:	0a21                	addi	s4,s4,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0204170:	846a                	mv	s0,s10
            goto process_precision;
ffffffffc0204172:	bfd9                	j	ffffffffc0204148 <vprintfmt+0x114>
    if (lflag >= 2) {
ffffffffc0204174:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0204176:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020417a:	01174463          	blt	a4,a7,ffffffffc0204182 <vprintfmt+0x14e>
    else if (lflag) {
ffffffffc020417e:	1a088e63          	beqz	a7,ffffffffc020433a <vprintfmt+0x306>
        return va_arg(*ap, unsigned long);
ffffffffc0204182:	000a3603          	ld	a2,0(s4)
ffffffffc0204186:	46c1                	li	a3,16
ffffffffc0204188:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020418a:	2781                	sext.w	a5,a5
ffffffffc020418c:	876e                	mv	a4,s11
ffffffffc020418e:	85a6                	mv	a1,s1
ffffffffc0204190:	854a                	mv	a0,s2
ffffffffc0204192:	e37ff0ef          	jal	ra,ffffffffc0203fc8 <printnum>
            break;
ffffffffc0204196:	bde1                	j	ffffffffc020406e <vprintfmt+0x3a>
            putch(va_arg(ap, int), putdat);
ffffffffc0204198:	000a2503          	lw	a0,0(s4)
ffffffffc020419c:	85a6                	mv	a1,s1
ffffffffc020419e:	0a21                	addi	s4,s4,8
ffffffffc02041a0:	9902                	jalr	s2
            break;
ffffffffc02041a2:	b5f1                	j	ffffffffc020406e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02041a4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02041a6:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02041aa:	01174463          	blt	a4,a7,ffffffffc02041b2 <vprintfmt+0x17e>
    else if (lflag) {
ffffffffc02041ae:	18088163          	beqz	a7,ffffffffc0204330 <vprintfmt+0x2fc>
        return va_arg(*ap, unsigned long);
ffffffffc02041b2:	000a3603          	ld	a2,0(s4)
ffffffffc02041b6:	46a9                	li	a3,10
ffffffffc02041b8:	8a2e                	mv	s4,a1
ffffffffc02041ba:	bfc1                	j	ffffffffc020418a <vprintfmt+0x156>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041bc:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02041c0:	4c85                	li	s9,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041c2:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02041c4:	bdf1                	j	ffffffffc02040a0 <vprintfmt+0x6c>
            putch(ch, putdat);
ffffffffc02041c6:	85a6                	mv	a1,s1
ffffffffc02041c8:	02500513          	li	a0,37
ffffffffc02041cc:	9902                	jalr	s2
            break;
ffffffffc02041ce:	b545                	j	ffffffffc020406e <vprintfmt+0x3a>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041d0:	00144603          	lbu	a2,1(s0)
            lflag ++;
ffffffffc02041d4:	2885                	addiw	a7,a7,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02041d6:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02041d8:	b5e1                	j	ffffffffc02040a0 <vprintfmt+0x6c>
    if (lflag >= 2) {
ffffffffc02041da:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02041dc:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02041e0:	01174463          	blt	a4,a7,ffffffffc02041e8 <vprintfmt+0x1b4>
    else if (lflag) {
ffffffffc02041e4:	14088163          	beqz	a7,ffffffffc0204326 <vprintfmt+0x2f2>
        return va_arg(*ap, unsigned long);
ffffffffc02041e8:	000a3603          	ld	a2,0(s4)
ffffffffc02041ec:	46a1                	li	a3,8
ffffffffc02041ee:	8a2e                	mv	s4,a1
ffffffffc02041f0:	bf69                	j	ffffffffc020418a <vprintfmt+0x156>
            putch('0', putdat);
ffffffffc02041f2:	03000513          	li	a0,48
ffffffffc02041f6:	85a6                	mv	a1,s1
ffffffffc02041f8:	e03e                	sd	a5,0(sp)
ffffffffc02041fa:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02041fc:	85a6                	mv	a1,s1
ffffffffc02041fe:	07800513          	li	a0,120
ffffffffc0204202:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0204204:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0204206:	6782                	ld	a5,0(sp)
ffffffffc0204208:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020420a:	ff8a3603          	ld	a2,-8(s4)
            goto number;
ffffffffc020420e:	bfb5                	j	ffffffffc020418a <vprintfmt+0x156>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204210:	000a3403          	ld	s0,0(s4)
ffffffffc0204214:	008a0713          	addi	a4,s4,8
ffffffffc0204218:	e03a                	sd	a4,0(sp)
ffffffffc020421a:	14040263          	beqz	s0,ffffffffc020435e <vprintfmt+0x32a>
            if (width > 0 && padc != '-') {
ffffffffc020421e:	0fb05763          	blez	s11,ffffffffc020430c <vprintfmt+0x2d8>
ffffffffc0204222:	02d00693          	li	a3,45
ffffffffc0204226:	0cd79163          	bne	a5,a3,ffffffffc02042e8 <vprintfmt+0x2b4>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020422a:	00044783          	lbu	a5,0(s0)
ffffffffc020422e:	0007851b          	sext.w	a0,a5
ffffffffc0204232:	cf85                	beqz	a5,ffffffffc020426a <vprintfmt+0x236>
ffffffffc0204234:	00140a13          	addi	s4,s0,1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204238:	05e00413          	li	s0,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020423c:	000c4563          	bltz	s8,ffffffffc0204246 <vprintfmt+0x212>
ffffffffc0204240:	3c7d                	addiw	s8,s8,-1
ffffffffc0204242:	036c0263          	beq	s8,s6,ffffffffc0204266 <vprintfmt+0x232>
                    putch('?', putdat);
ffffffffc0204246:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204248:	0e0c8e63          	beqz	s9,ffffffffc0204344 <vprintfmt+0x310>
ffffffffc020424c:	3781                	addiw	a5,a5,-32
ffffffffc020424e:	0ef47b63          	bgeu	s0,a5,ffffffffc0204344 <vprintfmt+0x310>
                    putch('?', putdat);
ffffffffc0204252:	03f00513          	li	a0,63
ffffffffc0204256:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204258:	000a4783          	lbu	a5,0(s4)
ffffffffc020425c:	3dfd                	addiw	s11,s11,-1
ffffffffc020425e:	0a05                	addi	s4,s4,1
ffffffffc0204260:	0007851b          	sext.w	a0,a5
ffffffffc0204264:	ffe1                	bnez	a5,ffffffffc020423c <vprintfmt+0x208>
            for (; width > 0; width --) {
ffffffffc0204266:	01b05963          	blez	s11,ffffffffc0204278 <vprintfmt+0x244>
ffffffffc020426a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020426c:	85a6                	mv	a1,s1
ffffffffc020426e:	02000513          	li	a0,32
ffffffffc0204272:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0204274:	fe0d9be3          	bnez	s11,ffffffffc020426a <vprintfmt+0x236>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0204278:	6a02                	ld	s4,0(sp)
ffffffffc020427a:	bbd5                	j	ffffffffc020406e <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020427c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020427e:	008a0c93          	addi	s9,s4,8
    if (lflag >= 2) {
ffffffffc0204282:	01174463          	blt	a4,a7,ffffffffc020428a <vprintfmt+0x256>
    else if (lflag) {
ffffffffc0204286:	08088d63          	beqz	a7,ffffffffc0204320 <vprintfmt+0x2ec>
        return va_arg(*ap, long);
ffffffffc020428a:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc020428e:	0a044d63          	bltz	s0,ffffffffc0204348 <vprintfmt+0x314>
            num = getint(&ap, lflag);
ffffffffc0204292:	8622                	mv	a2,s0
ffffffffc0204294:	8a66                	mv	s4,s9
ffffffffc0204296:	46a9                	li	a3,10
ffffffffc0204298:	bdcd                	j	ffffffffc020418a <vprintfmt+0x156>
            err = va_arg(ap, int);
ffffffffc020429a:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020429e:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02042a0:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc02042a2:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02042a6:	8fb5                	xor	a5,a5,a3
ffffffffc02042a8:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02042ac:	02d74163          	blt	a4,a3,ffffffffc02042ce <vprintfmt+0x29a>
ffffffffc02042b0:	00369793          	slli	a5,a3,0x3
ffffffffc02042b4:	97de                	add	a5,a5,s7
ffffffffc02042b6:	639c                	ld	a5,0(a5)
ffffffffc02042b8:	cb99                	beqz	a5,ffffffffc02042ce <vprintfmt+0x29a>
                printfmt(putch, putdat, "%s", p);
ffffffffc02042ba:	86be                	mv	a3,a5
ffffffffc02042bc:	00002617          	auipc	a2,0x2
ffffffffc02042c0:	e6460613          	addi	a2,a2,-412 # ffffffffc0206120 <default_pmm_manager+0xed0>
ffffffffc02042c4:	85a6                	mv	a1,s1
ffffffffc02042c6:	854a                	mv	a0,s2
ffffffffc02042c8:	0ce000ef          	jal	ra,ffffffffc0204396 <printfmt>
ffffffffc02042cc:	b34d                	j	ffffffffc020406e <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02042ce:	00002617          	auipc	a2,0x2
ffffffffc02042d2:	e4260613          	addi	a2,a2,-446 # ffffffffc0206110 <default_pmm_manager+0xec0>
ffffffffc02042d6:	85a6                	mv	a1,s1
ffffffffc02042d8:	854a                	mv	a0,s2
ffffffffc02042da:	0bc000ef          	jal	ra,ffffffffc0204396 <printfmt>
ffffffffc02042de:	bb41                	j	ffffffffc020406e <vprintfmt+0x3a>
                p = "(null)";
ffffffffc02042e0:	00002417          	auipc	s0,0x2
ffffffffc02042e4:	e2840413          	addi	s0,s0,-472 # ffffffffc0206108 <default_pmm_manager+0xeb8>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc02042e8:	85e2                	mv	a1,s8
ffffffffc02042ea:	8522                	mv	a0,s0
ffffffffc02042ec:	e43e                	sd	a5,8(sp)
ffffffffc02042ee:	196000ef          	jal	ra,ffffffffc0204484 <strnlen>
ffffffffc02042f2:	40ad8dbb          	subw	s11,s11,a0
ffffffffc02042f6:	01b05b63          	blez	s11,ffffffffc020430c <vprintfmt+0x2d8>
                    putch(padc, putdat);
ffffffffc02042fa:	67a2                	ld	a5,8(sp)
ffffffffc02042fc:	00078a1b          	sext.w	s4,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204300:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0204302:	85a6                	mv	a1,s1
ffffffffc0204304:	8552                	mv	a0,s4
ffffffffc0204306:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0204308:	fe0d9ce3          	bnez	s11,ffffffffc0204300 <vprintfmt+0x2cc>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020430c:	00044783          	lbu	a5,0(s0)
ffffffffc0204310:	00140a13          	addi	s4,s0,1
ffffffffc0204314:	0007851b          	sext.w	a0,a5
ffffffffc0204318:	d3a5                	beqz	a5,ffffffffc0204278 <vprintfmt+0x244>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020431a:	05e00413          	li	s0,94
ffffffffc020431e:	bf39                	j	ffffffffc020423c <vprintfmt+0x208>
        return va_arg(*ap, int);
ffffffffc0204320:	000a2403          	lw	s0,0(s4)
ffffffffc0204324:	b7ad                	j	ffffffffc020428e <vprintfmt+0x25a>
        return va_arg(*ap, unsigned int);
ffffffffc0204326:	000a6603          	lwu	a2,0(s4)
ffffffffc020432a:	46a1                	li	a3,8
ffffffffc020432c:	8a2e                	mv	s4,a1
ffffffffc020432e:	bdb1                	j	ffffffffc020418a <vprintfmt+0x156>
ffffffffc0204330:	000a6603          	lwu	a2,0(s4)
ffffffffc0204334:	46a9                	li	a3,10
ffffffffc0204336:	8a2e                	mv	s4,a1
ffffffffc0204338:	bd89                	j	ffffffffc020418a <vprintfmt+0x156>
ffffffffc020433a:	000a6603          	lwu	a2,0(s4)
ffffffffc020433e:	46c1                	li	a3,16
ffffffffc0204340:	8a2e                	mv	s4,a1
ffffffffc0204342:	b5a1                	j	ffffffffc020418a <vprintfmt+0x156>
                    putch(ch, putdat);
ffffffffc0204344:	9902                	jalr	s2
ffffffffc0204346:	bf09                	j	ffffffffc0204258 <vprintfmt+0x224>
                putch('-', putdat);
ffffffffc0204348:	85a6                	mv	a1,s1
ffffffffc020434a:	02d00513          	li	a0,45
ffffffffc020434e:	e03e                	sd	a5,0(sp)
ffffffffc0204350:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0204352:	6782                	ld	a5,0(sp)
ffffffffc0204354:	8a66                	mv	s4,s9
ffffffffc0204356:	40800633          	neg	a2,s0
ffffffffc020435a:	46a9                	li	a3,10
ffffffffc020435c:	b53d                	j	ffffffffc020418a <vprintfmt+0x156>
            if (width > 0 && padc != '-') {
ffffffffc020435e:	03b05163          	blez	s11,ffffffffc0204380 <vprintfmt+0x34c>
ffffffffc0204362:	02d00693          	li	a3,45
ffffffffc0204366:	f6d79de3          	bne	a5,a3,ffffffffc02042e0 <vprintfmt+0x2ac>
                p = "(null)";
ffffffffc020436a:	00002417          	auipc	s0,0x2
ffffffffc020436e:	d9e40413          	addi	s0,s0,-610 # ffffffffc0206108 <default_pmm_manager+0xeb8>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0204372:	02800793          	li	a5,40
ffffffffc0204376:	02800513          	li	a0,40
ffffffffc020437a:	00140a13          	addi	s4,s0,1
ffffffffc020437e:	bd6d                	j	ffffffffc0204238 <vprintfmt+0x204>
ffffffffc0204380:	00002a17          	auipc	s4,0x2
ffffffffc0204384:	d89a0a13          	addi	s4,s4,-631 # ffffffffc0206109 <default_pmm_manager+0xeb9>
ffffffffc0204388:	02800513          	li	a0,40
ffffffffc020438c:	02800793          	li	a5,40
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0204390:	05e00413          	li	s0,94
ffffffffc0204394:	b565                	j	ffffffffc020423c <vprintfmt+0x208>

ffffffffc0204396 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0204396:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0204398:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020439c:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020439e:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02043a0:	ec06                	sd	ra,24(sp)
ffffffffc02043a2:	f83a                	sd	a4,48(sp)
ffffffffc02043a4:	fc3e                	sd	a5,56(sp)
ffffffffc02043a6:	e0c2                	sd	a6,64(sp)
ffffffffc02043a8:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02043aa:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02043ac:	c89ff0ef          	jal	ra,ffffffffc0204034 <vprintfmt>
}
ffffffffc02043b0:	60e2                	ld	ra,24(sp)
ffffffffc02043b2:	6161                	addi	sp,sp,80
ffffffffc02043b4:	8082                	ret

ffffffffc02043b6 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02043b6:	715d                	addi	sp,sp,-80
ffffffffc02043b8:	e486                	sd	ra,72(sp)
ffffffffc02043ba:	e0a6                	sd	s1,64(sp)
ffffffffc02043bc:	fc4a                	sd	s2,56(sp)
ffffffffc02043be:	f84e                	sd	s3,48(sp)
ffffffffc02043c0:	f452                	sd	s4,40(sp)
ffffffffc02043c2:	f056                	sd	s5,32(sp)
ffffffffc02043c4:	ec5a                	sd	s6,24(sp)
ffffffffc02043c6:	e85e                	sd	s7,16(sp)
    if (prompt != NULL) {
ffffffffc02043c8:	c901                	beqz	a0,ffffffffc02043d8 <readline+0x22>
ffffffffc02043ca:	85aa                	mv	a1,a0
        cprintf("%s", prompt);
ffffffffc02043cc:	00002517          	auipc	a0,0x2
ffffffffc02043d0:	d5450513          	addi	a0,a0,-684 # ffffffffc0206120 <default_pmm_manager+0xed0>
ffffffffc02043d4:	ce7fb0ef          	jal	ra,ffffffffc02000ba <cprintf>
readline(const char *prompt) {
ffffffffc02043d8:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02043da:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02043dc:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02043de:	4aa9                	li	s5,10
ffffffffc02043e0:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02043e2:	0000db97          	auipc	s7,0xd
ffffffffc02043e6:	d16b8b93          	addi	s7,s7,-746 # ffffffffc02110f8 <buf>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02043ea:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02043ee:	d05fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc02043f2:	00054a63          	bltz	a0,ffffffffc0204406 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02043f6:	00a95a63          	bge	s2,a0,ffffffffc020440a <readline+0x54>
ffffffffc02043fa:	029a5263          	bge	s4,s1,ffffffffc020441e <readline+0x68>
        c = getchar();
ffffffffc02043fe:	cf5fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc0204402:	fe055ae3          	bgez	a0,ffffffffc02043f6 <readline+0x40>
            return NULL;
ffffffffc0204406:	4501                	li	a0,0
ffffffffc0204408:	a091                	j	ffffffffc020444c <readline+0x96>
        else if (c == '\b' && i > 0) {
ffffffffc020440a:	03351463          	bne	a0,s3,ffffffffc0204432 <readline+0x7c>
ffffffffc020440e:	e8a9                	bnez	s1,ffffffffc0204460 <readline+0xaa>
        c = getchar();
ffffffffc0204410:	ce3fb0ef          	jal	ra,ffffffffc02000f2 <getchar>
        if (c < 0) {
ffffffffc0204414:	fe0549e3          	bltz	a0,ffffffffc0204406 <readline+0x50>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0204418:	fea959e3          	bge	s2,a0,ffffffffc020440a <readline+0x54>
ffffffffc020441c:	4481                	li	s1,0
            cputchar(c);
ffffffffc020441e:	e42a                	sd	a0,8(sp)
ffffffffc0204420:	cd1fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i ++] = c;
ffffffffc0204424:	6522                	ld	a0,8(sp)
ffffffffc0204426:	009b87b3          	add	a5,s7,s1
ffffffffc020442a:	2485                	addiw	s1,s1,1
ffffffffc020442c:	00a78023          	sb	a0,0(a5)
ffffffffc0204430:	bf7d                	j	ffffffffc02043ee <readline+0x38>
        else if (c == '\n' || c == '\r') {
ffffffffc0204432:	01550463          	beq	a0,s5,ffffffffc020443a <readline+0x84>
ffffffffc0204436:	fb651ce3          	bne	a0,s6,ffffffffc02043ee <readline+0x38>
            cputchar(c);
ffffffffc020443a:	cb7fb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            buf[i] = '\0';
ffffffffc020443e:	0000d517          	auipc	a0,0xd
ffffffffc0204442:	cba50513          	addi	a0,a0,-838 # ffffffffc02110f8 <buf>
ffffffffc0204446:	94aa                	add	s1,s1,a0
ffffffffc0204448:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc020444c:	60a6                	ld	ra,72(sp)
ffffffffc020444e:	6486                	ld	s1,64(sp)
ffffffffc0204450:	7962                	ld	s2,56(sp)
ffffffffc0204452:	79c2                	ld	s3,48(sp)
ffffffffc0204454:	7a22                	ld	s4,40(sp)
ffffffffc0204456:	7a82                	ld	s5,32(sp)
ffffffffc0204458:	6b62                	ld	s6,24(sp)
ffffffffc020445a:	6bc2                	ld	s7,16(sp)
ffffffffc020445c:	6161                	addi	sp,sp,80
ffffffffc020445e:	8082                	ret
            cputchar(c);
ffffffffc0204460:	4521                	li	a0,8
ffffffffc0204462:	c8ffb0ef          	jal	ra,ffffffffc02000f0 <cputchar>
            i --;
ffffffffc0204466:	34fd                	addiw	s1,s1,-1
ffffffffc0204468:	b759                	j	ffffffffc02043ee <readline+0x38>

ffffffffc020446a <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc020446a:	00054783          	lbu	a5,0(a0)
strlen(const char *s) {
ffffffffc020446e:	872a                	mv	a4,a0
    size_t cnt = 0;
ffffffffc0204470:	4501                	li	a0,0
    while (*s ++ != '\0') {
ffffffffc0204472:	cb81                	beqz	a5,ffffffffc0204482 <strlen+0x18>
        cnt ++;
ffffffffc0204474:	0505                	addi	a0,a0,1
    while (*s ++ != '\0') {
ffffffffc0204476:	00a707b3          	add	a5,a4,a0
ffffffffc020447a:	0007c783          	lbu	a5,0(a5)
ffffffffc020447e:	fbfd                	bnez	a5,ffffffffc0204474 <strlen+0xa>
ffffffffc0204480:	8082                	ret
    }
    return cnt;
}
ffffffffc0204482:	8082                	ret

ffffffffc0204484 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0204484:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0204486:	e589                	bnez	a1,ffffffffc0204490 <strnlen+0xc>
ffffffffc0204488:	a811                	j	ffffffffc020449c <strnlen+0x18>
        cnt ++;
ffffffffc020448a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020448c:	00f58863          	beq	a1,a5,ffffffffc020449c <strnlen+0x18>
ffffffffc0204490:	00f50733          	add	a4,a0,a5
ffffffffc0204494:	00074703          	lbu	a4,0(a4)
ffffffffc0204498:	fb6d                	bnez	a4,ffffffffc020448a <strnlen+0x6>
ffffffffc020449a:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc020449c:	852e                	mv	a0,a1
ffffffffc020449e:	8082                	ret

ffffffffc02044a0 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02044a0:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02044a2:	0005c703          	lbu	a4,0(a1)
ffffffffc02044a6:	0785                	addi	a5,a5,1
ffffffffc02044a8:	0585                	addi	a1,a1,1
ffffffffc02044aa:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02044ae:	fb75                	bnez	a4,ffffffffc02044a2 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02044b0:	8082                	ret

ffffffffc02044b2 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02044b2:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02044b6:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02044ba:	cb89                	beqz	a5,ffffffffc02044cc <strcmp+0x1a>
        s1 ++, s2 ++;
ffffffffc02044bc:	0505                	addi	a0,a0,1
ffffffffc02044be:	0585                	addi	a1,a1,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02044c0:	fee789e3          	beq	a5,a4,ffffffffc02044b2 <strcmp>
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02044c4:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02044c8:	9d19                	subw	a0,a0,a4
ffffffffc02044ca:	8082                	ret
ffffffffc02044cc:	4501                	li	a0,0
ffffffffc02044ce:	bfed                	j	ffffffffc02044c8 <strcmp+0x16>

ffffffffc02044d0 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc02044d0:	00054783          	lbu	a5,0(a0)
ffffffffc02044d4:	c799                	beqz	a5,ffffffffc02044e2 <strchr+0x12>
        if (*s == c) {
ffffffffc02044d6:	00f58763          	beq	a1,a5,ffffffffc02044e4 <strchr+0x14>
    while (*s != '\0') {
ffffffffc02044da:	00154783          	lbu	a5,1(a0)
            return (char *)s;
        }
        s ++;
ffffffffc02044de:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02044e0:	fbfd                	bnez	a5,ffffffffc02044d6 <strchr+0x6>
    }
    return NULL;
ffffffffc02044e2:	4501                	li	a0,0
}
ffffffffc02044e4:	8082                	ret

ffffffffc02044e6 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02044e6:	ca01                	beqz	a2,ffffffffc02044f6 <memset+0x10>
ffffffffc02044e8:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02044ea:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02044ec:	0785                	addi	a5,a5,1
ffffffffc02044ee:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02044f2:	fec79de3          	bne	a5,a2,ffffffffc02044ec <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02044f6:	8082                	ret

ffffffffc02044f8 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02044f8:	ca19                	beqz	a2,ffffffffc020450e <memcpy+0x16>
ffffffffc02044fa:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02044fc:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02044fe:	0005c703          	lbu	a4,0(a1)
ffffffffc0204502:	0585                	addi	a1,a1,1
ffffffffc0204504:	0785                	addi	a5,a5,1
ffffffffc0204506:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc020450a:	fec59ae3          	bne	a1,a2,ffffffffc02044fe <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc020450e:	8082                	ret
