
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
ffffffffc0200028:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc020002c:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200030:	03628293          	addi	t0,t0,54 # ffffffffc0200036 <kern_init>
    jr t0
ffffffffc0200034:	8282                	jr	t0

ffffffffc0200036 <kern_init>:
void grade_backtrace(void);


int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	00006517          	auipc	a0,0x6
ffffffffc020003a:	fda50513          	addi	a0,a0,-38 # ffffffffc0206010 <edata>
ffffffffc020003e:	00006617          	auipc	a2,0x6
ffffffffc0200042:	43260613          	addi	a2,a2,1074 # ffffffffc0206470 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	247010ef          	jal	ra,ffffffffc0201a94 <memset>
    cons_init();  // init the console
ffffffffc0200052:	3f8000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00002517          	auipc	a0,0x2
ffffffffc020005a:	a5250513          	addi	a0,a0,-1454 # ffffffffc0201aa8 <etext+0x2>
ffffffffc020005e:	08e000ef          	jal	ra,ffffffffc02000ec <cputs>

    print_kerninfo();
ffffffffc0200062:	0da000ef          	jal	ra,ffffffffc020013c <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	3fe000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	30e010ef          	jal	ra,ffffffffc0201378 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc020006e:	3f6000ef          	jal	ra,ffffffffc0200464 <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200072:	396000ef          	jal	ra,ffffffffc0200408 <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200076:	3e2000ef          	jal	ra,ffffffffc0200458 <intr_enable>



    /* do nothing */
    while (1)
        ;
ffffffffc020007a:	a001                	j	ffffffffc020007a <kern_init+0x44>

ffffffffc020007c <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc020007c:	1141                	addi	sp,sp,-16
ffffffffc020007e:	e022                	sd	s0,0(sp)
ffffffffc0200080:	e406                	sd	ra,8(sp)
ffffffffc0200082:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc0200084:	3c8000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200088:	401c                	lw	a5,0(s0)
}
ffffffffc020008a:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc020008c:	2785                	addiw	a5,a5,1
ffffffffc020008e:	c01c                	sw	a5,0(s0)
}
ffffffffc0200090:	6402                	ld	s0,0(sp)
ffffffffc0200092:	0141                	addi	sp,sp,16
ffffffffc0200094:	8082                	ret

ffffffffc0200096 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200096:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200098:	86ae                	mv	a3,a1
ffffffffc020009a:	862a                	mv	a2,a0
ffffffffc020009c:	006c                	addi	a1,sp,12
ffffffffc020009e:	00000517          	auipc	a0,0x0
ffffffffc02000a2:	fde50513          	addi	a0,a0,-34 # ffffffffc020007c <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000a6:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000a8:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000aa:	4e8010ef          	jal	ra,ffffffffc0201592 <vprintfmt>
    return cnt;
}
ffffffffc02000ae:	60e2                	ld	ra,24(sp)
ffffffffc02000b0:	4532                	lw	a0,12(sp)
ffffffffc02000b2:	6105                	addi	sp,sp,32
ffffffffc02000b4:	8082                	ret

ffffffffc02000b6 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc02000b6:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc02000b8:	02810313          	addi	t1,sp,40 # ffffffffc0205028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc02000bc:	f42e                	sd	a1,40(sp)
ffffffffc02000be:	f832                	sd	a2,48(sp)
ffffffffc02000c0:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000c2:	862a                	mv	a2,a0
ffffffffc02000c4:	004c                	addi	a1,sp,4
ffffffffc02000c6:	00000517          	auipc	a0,0x0
ffffffffc02000ca:	fb650513          	addi	a0,a0,-74 # ffffffffc020007c <cputch>
ffffffffc02000ce:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02000d0:	ec06                	sd	ra,24(sp)
ffffffffc02000d2:	e0ba                	sd	a4,64(sp)
ffffffffc02000d4:	e4be                	sd	a5,72(sp)
ffffffffc02000d6:	e8c2                	sd	a6,80(sp)
ffffffffc02000d8:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02000da:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02000dc:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000de:	4b4010ef          	jal	ra,ffffffffc0201592 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02000e2:	60e2                	ld	ra,24(sp)
ffffffffc02000e4:	4512                	lw	a0,4(sp)
ffffffffc02000e6:	6125                	addi	sp,sp,96
ffffffffc02000e8:	8082                	ret

ffffffffc02000ea <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02000ea:	a68d                	j	ffffffffc020044c <cons_putc>

ffffffffc02000ec <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02000ec:	1101                	addi	sp,sp,-32
ffffffffc02000ee:	e822                	sd	s0,16(sp)
ffffffffc02000f0:	ec06                	sd	ra,24(sp)
ffffffffc02000f2:	e426                	sd	s1,8(sp)
ffffffffc02000f4:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02000f6:	00054503          	lbu	a0,0(a0)
ffffffffc02000fa:	c51d                	beqz	a0,ffffffffc0200128 <cputs+0x3c>
ffffffffc02000fc:	0405                	addi	s0,s0,1
ffffffffc02000fe:	4485                	li	s1,1
ffffffffc0200100:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc0200102:	34a000ef          	jal	ra,ffffffffc020044c <cons_putc>
    (*cnt) ++;
ffffffffc0200106:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc020010a:	0405                	addi	s0,s0,1
ffffffffc020010c:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200110:	f96d                	bnez	a0,ffffffffc0200102 <cputs+0x16>
ffffffffc0200112:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc0200116:	4529                	li	a0,10
ffffffffc0200118:	334000ef          	jal	ra,ffffffffc020044c <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc020011c:	8522                	mv	a0,s0
ffffffffc020011e:	60e2                	ld	ra,24(sp)
ffffffffc0200120:	6442                	ld	s0,16(sp)
ffffffffc0200122:	64a2                	ld	s1,8(sp)
ffffffffc0200124:	6105                	addi	sp,sp,32
ffffffffc0200126:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200128:	4405                	li	s0,1
ffffffffc020012a:	b7f5                	j	ffffffffc0200116 <cputs+0x2a>

ffffffffc020012c <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020012c:	1141                	addi	sp,sp,-16
ffffffffc020012e:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200130:	324000ef          	jal	ra,ffffffffc0200454 <cons_getc>
ffffffffc0200134:	dd75                	beqz	a0,ffffffffc0200130 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200136:	60a2                	ld	ra,8(sp)
ffffffffc0200138:	0141                	addi	sp,sp,16
ffffffffc020013a:	8082                	ret

ffffffffc020013c <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020013c:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020013e:	00002517          	auipc	a0,0x2
ffffffffc0200142:	9ba50513          	addi	a0,a0,-1606 # ffffffffc0201af8 <etext+0x52>
void print_kerninfo(void) {
ffffffffc0200146:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200148:	f6fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014c:	00000597          	auipc	a1,0x0
ffffffffc0200150:	eea58593          	addi	a1,a1,-278 # ffffffffc0200036 <kern_init>
ffffffffc0200154:	00002517          	auipc	a0,0x2
ffffffffc0200158:	9c450513          	addi	a0,a0,-1596 # ffffffffc0201b18 <etext+0x72>
ffffffffc020015c:	f5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200160:	00002597          	auipc	a1,0x2
ffffffffc0200164:	94658593          	addi	a1,a1,-1722 # ffffffffc0201aa6 <etext>
ffffffffc0200168:	00002517          	auipc	a0,0x2
ffffffffc020016c:	9d050513          	addi	a0,a0,-1584 # ffffffffc0201b38 <etext+0x92>
ffffffffc0200170:	f47ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200174:	00006597          	auipc	a1,0x6
ffffffffc0200178:	e9c58593          	addi	a1,a1,-356 # ffffffffc0206010 <edata>
ffffffffc020017c:	00002517          	auipc	a0,0x2
ffffffffc0200180:	9dc50513          	addi	a0,a0,-1572 # ffffffffc0201b58 <etext+0xb2>
ffffffffc0200184:	f33ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200188:	00006597          	auipc	a1,0x6
ffffffffc020018c:	2e858593          	addi	a1,a1,744 # ffffffffc0206470 <end>
ffffffffc0200190:	00002517          	auipc	a0,0x2
ffffffffc0200194:	9e850513          	addi	a0,a0,-1560 # ffffffffc0201b78 <etext+0xd2>
ffffffffc0200198:	f1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019c:	00006597          	auipc	a1,0x6
ffffffffc02001a0:	6d358593          	addi	a1,a1,1747 # ffffffffc020686f <end+0x3ff>
ffffffffc02001a4:	00000797          	auipc	a5,0x0
ffffffffc02001a8:	e9278793          	addi	a5,a5,-366 # ffffffffc0200036 <kern_init>
ffffffffc02001ac:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b0:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02001b4:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001b6:	3ff5f593          	andi	a1,a1,1023
ffffffffc02001ba:	95be                	add	a1,a1,a5
ffffffffc02001bc:	85a9                	srai	a1,a1,0xa
ffffffffc02001be:	00002517          	auipc	a0,0x2
ffffffffc02001c2:	9da50513          	addi	a0,a0,-1574 # ffffffffc0201b98 <etext+0xf2>
}
ffffffffc02001c6:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02001c8:	b5fd                	j	ffffffffc02000b6 <cprintf>

ffffffffc02001ca <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02001ca:	1141                	addi	sp,sp,-16

    panic("Not Implemented!");
ffffffffc02001cc:	00002617          	auipc	a2,0x2
ffffffffc02001d0:	8fc60613          	addi	a2,a2,-1796 # ffffffffc0201ac8 <etext+0x22>
ffffffffc02001d4:	04e00593          	li	a1,78
ffffffffc02001d8:	00002517          	auipc	a0,0x2
ffffffffc02001dc:	90850513          	addi	a0,a0,-1784 # ffffffffc0201ae0 <etext+0x3a>
void print_stackframe(void) {
ffffffffc02001e0:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02001e2:	1c6000ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc02001e6 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02001e6:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02001e8:	00002617          	auipc	a2,0x2
ffffffffc02001ec:	ac060613          	addi	a2,a2,-1344 # ffffffffc0201ca8 <commands+0xe0>
ffffffffc02001f0:	00002597          	auipc	a1,0x2
ffffffffc02001f4:	ad858593          	addi	a1,a1,-1320 # ffffffffc0201cc8 <commands+0x100>
ffffffffc02001f8:	00002517          	auipc	a0,0x2
ffffffffc02001fc:	ad850513          	addi	a0,a0,-1320 # ffffffffc0201cd0 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200200:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200202:	eb5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200206:	00002617          	auipc	a2,0x2
ffffffffc020020a:	ada60613          	addi	a2,a2,-1318 # ffffffffc0201ce0 <commands+0x118>
ffffffffc020020e:	00002597          	auipc	a1,0x2
ffffffffc0200212:	afa58593          	addi	a1,a1,-1286 # ffffffffc0201d08 <commands+0x140>
ffffffffc0200216:	00002517          	auipc	a0,0x2
ffffffffc020021a:	aba50513          	addi	a0,a0,-1350 # ffffffffc0201cd0 <commands+0x108>
ffffffffc020021e:	e99ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200222:	00002617          	auipc	a2,0x2
ffffffffc0200226:	af660613          	addi	a2,a2,-1290 # ffffffffc0201d18 <commands+0x150>
ffffffffc020022a:	00002597          	auipc	a1,0x2
ffffffffc020022e:	b0e58593          	addi	a1,a1,-1266 # ffffffffc0201d38 <commands+0x170>
ffffffffc0200232:	00002517          	auipc	a0,0x2
ffffffffc0200236:	a9e50513          	addi	a0,a0,-1378 # ffffffffc0201cd0 <commands+0x108>
ffffffffc020023a:	e7dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    }
    return 0;
}
ffffffffc020023e:	60a2                	ld	ra,8(sp)
ffffffffc0200240:	4501                	li	a0,0
ffffffffc0200242:	0141                	addi	sp,sp,16
ffffffffc0200244:	8082                	ret

ffffffffc0200246 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200246:	1141                	addi	sp,sp,-16
ffffffffc0200248:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020024a:	ef3ff0ef          	jal	ra,ffffffffc020013c <print_kerninfo>
    return 0;
}
ffffffffc020024e:	60a2                	ld	ra,8(sp)
ffffffffc0200250:	4501                	li	a0,0
ffffffffc0200252:	0141                	addi	sp,sp,16
ffffffffc0200254:	8082                	ret

ffffffffc0200256 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200256:	1141                	addi	sp,sp,-16
ffffffffc0200258:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020025a:	f71ff0ef          	jal	ra,ffffffffc02001ca <print_stackframe>
    return 0;
}
ffffffffc020025e:	60a2                	ld	ra,8(sp)
ffffffffc0200260:	4501                	li	a0,0
ffffffffc0200262:	0141                	addi	sp,sp,16
ffffffffc0200264:	8082                	ret

ffffffffc0200266 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc0200266:	7115                	addi	sp,sp,-224
ffffffffc0200268:	e962                	sd	s8,144(sp)
ffffffffc020026a:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020026c:	00002517          	auipc	a0,0x2
ffffffffc0200270:	9a450513          	addi	a0,a0,-1628 # ffffffffc0201c10 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc0200274:	ed86                	sd	ra,216(sp)
ffffffffc0200276:	e9a2                	sd	s0,208(sp)
ffffffffc0200278:	e5a6                	sd	s1,200(sp)
ffffffffc020027a:	e1ca                	sd	s2,192(sp)
ffffffffc020027c:	fd4e                	sd	s3,184(sp)
ffffffffc020027e:	f952                	sd	s4,176(sp)
ffffffffc0200280:	f556                	sd	s5,168(sp)
ffffffffc0200282:	f15a                	sd	s6,160(sp)
ffffffffc0200284:	ed5e                	sd	s7,152(sp)
ffffffffc0200286:	e566                	sd	s9,136(sp)
ffffffffc0200288:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020028a:	e2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020028e:	00002517          	auipc	a0,0x2
ffffffffc0200292:	9aa50513          	addi	a0,a0,-1622 # ffffffffc0201c38 <commands+0x70>
ffffffffc0200296:	e21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029a:	000c0563          	beqz	s8,ffffffffc02002a4 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029e:	8562                	mv	a0,s8
ffffffffc02002a0:	3a2000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a4:	00002c97          	auipc	s9,0x2
ffffffffc02002a8:	924c8c93          	addi	s9,s9,-1756 # ffffffffc0201bc8 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ac:	00002997          	auipc	s3,0x2
ffffffffc02002b0:	9b498993          	addi	s3,s3,-1612 # ffffffffc0201c60 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b4:	00002917          	auipc	s2,0x2
ffffffffc02002b8:	9b490913          	addi	s2,s2,-1612 # ffffffffc0201c68 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002bc:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002be:	00002b17          	auipc	s6,0x2
ffffffffc02002c2:	9b2b0b13          	addi	s6,s6,-1614 # ffffffffc0201c70 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002c6:	00002a97          	auipc	s5,0x2
ffffffffc02002ca:	a02a8a93          	addi	s5,s5,-1534 # ffffffffc0201cc8 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002ce:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d0:	854e                	mv	a0,s3
ffffffffc02002d2:	640010ef          	jal	ra,ffffffffc0201912 <readline>
ffffffffc02002d6:	842a                	mv	s0,a0
ffffffffc02002d8:	dd65                	beqz	a0,ffffffffc02002d0 <kmonitor+0x6a>
ffffffffc02002da:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002de:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e0:	c999                	beqz	a1,ffffffffc02002f6 <kmonitor+0x90>
ffffffffc02002e2:	854a                	mv	a0,s2
ffffffffc02002e4:	792010ef          	jal	ra,ffffffffc0201a76 <strchr>
ffffffffc02002e8:	c925                	beqz	a0,ffffffffc0200358 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02002ea:	00144583          	lbu	a1,1(s0)
ffffffffc02002ee:	00040023          	sb	zero,0(s0)
ffffffffc02002f2:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002f4:	f5fd                	bnez	a1,ffffffffc02002e2 <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02002f6:	dce9                	beqz	s1,ffffffffc02002d0 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02002f8:	6582                	ld	a1,0(sp)
ffffffffc02002fa:	00002d17          	auipc	s10,0x2
ffffffffc02002fe:	8ced0d13          	addi	s10,s10,-1842 # ffffffffc0201bc8 <commands>
    if (argc == 0) {
ffffffffc0200302:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200304:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
ffffffffc0200308:	744010ef          	jal	ra,ffffffffc0201a4c <strcmp>
ffffffffc020030c:	c919                	beqz	a0,ffffffffc0200322 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020030e:	2405                	addiw	s0,s0,1
ffffffffc0200310:	09740463          	beq	s0,s7,ffffffffc0200398 <kmonitor+0x132>
ffffffffc0200314:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200318:	6582                	ld	a1,0(sp)
ffffffffc020031a:	0d61                	addi	s10,s10,24
ffffffffc020031c:	730010ef          	jal	ra,ffffffffc0201a4c <strcmp>
ffffffffc0200320:	f57d                	bnez	a0,ffffffffc020030e <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200322:	00141793          	slli	a5,s0,0x1
ffffffffc0200326:	97a2                	add	a5,a5,s0
ffffffffc0200328:	078e                	slli	a5,a5,0x3
ffffffffc020032a:	97e6                	add	a5,a5,s9
ffffffffc020032c:	6b9c                	ld	a5,16(a5)
ffffffffc020032e:	8662                	mv	a2,s8
ffffffffc0200330:	002c                	addi	a1,sp,8
ffffffffc0200332:	fff4851b          	addiw	a0,s1,-1
ffffffffc0200336:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200338:	f8055ce3          	bgez	a0,ffffffffc02002d0 <kmonitor+0x6a>
}
ffffffffc020033c:	60ee                	ld	ra,216(sp)
ffffffffc020033e:	644e                	ld	s0,208(sp)
ffffffffc0200340:	64ae                	ld	s1,200(sp)
ffffffffc0200342:	690e                	ld	s2,192(sp)
ffffffffc0200344:	79ea                	ld	s3,184(sp)
ffffffffc0200346:	7a4a                	ld	s4,176(sp)
ffffffffc0200348:	7aaa                	ld	s5,168(sp)
ffffffffc020034a:	7b0a                	ld	s6,160(sp)
ffffffffc020034c:	6bea                	ld	s7,152(sp)
ffffffffc020034e:	6c4a                	ld	s8,144(sp)
ffffffffc0200350:	6caa                	ld	s9,136(sp)
ffffffffc0200352:	6d0a                	ld	s10,128(sp)
ffffffffc0200354:	612d                	addi	sp,sp,224
ffffffffc0200356:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200358:	00044783          	lbu	a5,0(s0)
ffffffffc020035c:	dfc9                	beqz	a5,ffffffffc02002f6 <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc020035e:	03448863          	beq	s1,s4,ffffffffc020038e <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc0200362:	00349793          	slli	a5,s1,0x3
ffffffffc0200366:	0118                	addi	a4,sp,128
ffffffffc0200368:	97ba                	add	a5,a5,a4
ffffffffc020036a:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020036e:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc0200372:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200374:	e591                	bnez	a1,ffffffffc0200380 <kmonitor+0x11a>
ffffffffc0200376:	b749                	j	ffffffffc02002f8 <kmonitor+0x92>
            buf ++;
ffffffffc0200378:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020037a:	00044583          	lbu	a1,0(s0)
ffffffffc020037e:	ddad                	beqz	a1,ffffffffc02002f8 <kmonitor+0x92>
ffffffffc0200380:	854a                	mv	a0,s2
ffffffffc0200382:	6f4010ef          	jal	ra,ffffffffc0201a76 <strchr>
ffffffffc0200386:	d96d                	beqz	a0,ffffffffc0200378 <kmonitor+0x112>
ffffffffc0200388:	00044583          	lbu	a1,0(s0)
ffffffffc020038c:	bf91                	j	ffffffffc02002e0 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020038e:	45c1                	li	a1,16
ffffffffc0200390:	855a                	mv	a0,s6
ffffffffc0200392:	d25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200396:	b7f1                	j	ffffffffc0200362 <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200398:	6582                	ld	a1,0(sp)
ffffffffc020039a:	00002517          	auipc	a0,0x2
ffffffffc020039e:	8f650513          	addi	a0,a0,-1802 # ffffffffc0201c90 <commands+0xc8>
ffffffffc02003a2:	d15ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    return 0;
ffffffffc02003a6:	b72d                	j	ffffffffc02002d0 <kmonitor+0x6a>

ffffffffc02003a8 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003a8:	00006317          	auipc	t1,0x6
ffffffffc02003ac:	06830313          	addi	t1,t1,104 # ffffffffc0206410 <is_panic>
ffffffffc02003b0:	00032303          	lw	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003b4:	715d                	addi	sp,sp,-80
ffffffffc02003b6:	ec06                	sd	ra,24(sp)
ffffffffc02003b8:	e822                	sd	s0,16(sp)
ffffffffc02003ba:	f436                	sd	a3,40(sp)
ffffffffc02003bc:	f83a                	sd	a4,48(sp)
ffffffffc02003be:	fc3e                	sd	a5,56(sp)
ffffffffc02003c0:	e0c2                	sd	a6,64(sp)
ffffffffc02003c2:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003c4:	02031c63          	bnez	t1,ffffffffc02003fc <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003c8:	4785                	li	a5,1
ffffffffc02003ca:	8432                	mv	s0,a2
ffffffffc02003cc:	00006717          	auipc	a4,0x6
ffffffffc02003d0:	04f72223          	sw	a5,68(a4) # ffffffffc0206410 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d4:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02003d6:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003d8:	85aa                	mv	a1,a0
ffffffffc02003da:	00002517          	auipc	a0,0x2
ffffffffc02003de:	96e50513          	addi	a0,a0,-1682 # ffffffffc0201d48 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02003e2:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e4:	cd3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003e8:	65a2                	ld	a1,8(sp)
ffffffffc02003ea:	8522                	mv	a0,s0
ffffffffc02003ec:	cabff0ef          	jal	ra,ffffffffc0200096 <vcprintf>
    cprintf("\n");
ffffffffc02003f0:	00001517          	auipc	a0,0x1
ffffffffc02003f4:	7d050513          	addi	a0,a0,2000 # ffffffffc0201bc0 <etext+0x11a>
ffffffffc02003f8:	cbfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc02003fc:	062000ef          	jal	ra,ffffffffc020045e <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200400:	4501                	li	a0,0
ffffffffc0200402:	e65ff0ef          	jal	ra,ffffffffc0200266 <kmonitor>
ffffffffc0200406:	bfed                	j	ffffffffc0200400 <__panic+0x58>

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
ffffffffc020041a:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc020041e:	953e                	add	a0,a0,a5
ffffffffc0200420:	5cc010ef          	jal	ra,ffffffffc02019ec <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0007b523          	sd	zero,10(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00002517          	auipc	a0,0x2
ffffffffc0200432:	93a50513          	addi	a0,a0,-1734 # ffffffffc0201d68 <commands+0x1a0>
}
ffffffffc0200436:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc0200438:	b9bd                	j	ffffffffc02000b6 <cprintf>

ffffffffc020043a <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020043a:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020043e:	67e1                	lui	a5,0x18
ffffffffc0200440:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0xffffffffc01e7960>
ffffffffc0200444:	953e                	add	a0,a0,a5
ffffffffc0200446:	5a60106f          	j	ffffffffc02019ec <sbi_set_timer>

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
ffffffffc0200450:	5800106f          	j	ffffffffc02019d0 <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	5b40106f          	j	ffffffffc0201a08 <sbi_console_getchar>

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
ffffffffc020046c:	2ec78793          	addi	a5,a5,748 # ffffffffc0200754 <__alltraps>
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
ffffffffc020047e:	00002517          	auipc	a0,0x2
ffffffffc0200482:	a0250513          	addi	a0,a0,-1534 # ffffffffc0201e80 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00002517          	auipc	a0,0x2
ffffffffc0200492:	a0a50513          	addi	a0,a0,-1526 # ffffffffc0201e98 <commands+0x2d0>
ffffffffc0200496:	c21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	a1450513          	addi	a0,a0,-1516 # ffffffffc0201eb0 <commands+0x2e8>
ffffffffc02004a4:	c13ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	a1e50513          	addi	a0,a0,-1506 # ffffffffc0201ec8 <commands+0x300>
ffffffffc02004b2:	c05ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00002517          	auipc	a0,0x2
ffffffffc02004bc:	a2850513          	addi	a0,a0,-1496 # ffffffffc0201ee0 <commands+0x318>
ffffffffc02004c0:	bf7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00002517          	auipc	a0,0x2
ffffffffc02004ca:	a3250513          	addi	a0,a0,-1486 # ffffffffc0201ef8 <commands+0x330>
ffffffffc02004ce:	be9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00002517          	auipc	a0,0x2
ffffffffc02004d8:	a3c50513          	addi	a0,a0,-1476 # ffffffffc0201f10 <commands+0x348>
ffffffffc02004dc:	bdbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00002517          	auipc	a0,0x2
ffffffffc02004e6:	a4650513          	addi	a0,a0,-1466 # ffffffffc0201f28 <commands+0x360>
ffffffffc02004ea:	bcdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00002517          	auipc	a0,0x2
ffffffffc02004f4:	a5050513          	addi	a0,a0,-1456 # ffffffffc0201f40 <commands+0x378>
ffffffffc02004f8:	bbfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00002517          	auipc	a0,0x2
ffffffffc0200502:	a5a50513          	addi	a0,a0,-1446 # ffffffffc0201f58 <commands+0x390>
ffffffffc0200506:	bb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00002517          	auipc	a0,0x2
ffffffffc0200510:	a6450513          	addi	a0,a0,-1436 # ffffffffc0201f70 <commands+0x3a8>
ffffffffc0200514:	ba3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00002517          	auipc	a0,0x2
ffffffffc020051e:	a6e50513          	addi	a0,a0,-1426 # ffffffffc0201f88 <commands+0x3c0>
ffffffffc0200522:	b95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00002517          	auipc	a0,0x2
ffffffffc020052c:	a7850513          	addi	a0,a0,-1416 # ffffffffc0201fa0 <commands+0x3d8>
ffffffffc0200530:	b87ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00002517          	auipc	a0,0x2
ffffffffc020053a:	a8250513          	addi	a0,a0,-1406 # ffffffffc0201fb8 <commands+0x3f0>
ffffffffc020053e:	b79ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00002517          	auipc	a0,0x2
ffffffffc0200548:	a8c50513          	addi	a0,a0,-1396 # ffffffffc0201fd0 <commands+0x408>
ffffffffc020054c:	b6bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00002517          	auipc	a0,0x2
ffffffffc0200556:	a9650513          	addi	a0,a0,-1386 # ffffffffc0201fe8 <commands+0x420>
ffffffffc020055a:	b5dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00002517          	auipc	a0,0x2
ffffffffc0200564:	aa050513          	addi	a0,a0,-1376 # ffffffffc0202000 <commands+0x438>
ffffffffc0200568:	b4fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00002517          	auipc	a0,0x2
ffffffffc0200572:	aaa50513          	addi	a0,a0,-1366 # ffffffffc0202018 <commands+0x450>
ffffffffc0200576:	b41ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00002517          	auipc	a0,0x2
ffffffffc0200580:	ab450513          	addi	a0,a0,-1356 # ffffffffc0202030 <commands+0x468>
ffffffffc0200584:	b33ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00002517          	auipc	a0,0x2
ffffffffc020058e:	abe50513          	addi	a0,a0,-1346 # ffffffffc0202048 <commands+0x480>
ffffffffc0200592:	b25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00002517          	auipc	a0,0x2
ffffffffc020059c:	ac850513          	addi	a0,a0,-1336 # ffffffffc0202060 <commands+0x498>
ffffffffc02005a0:	b17ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00002517          	auipc	a0,0x2
ffffffffc02005aa:	ad250513          	addi	a0,a0,-1326 # ffffffffc0202078 <commands+0x4b0>
ffffffffc02005ae:	b09ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00002517          	auipc	a0,0x2
ffffffffc02005b8:	adc50513          	addi	a0,a0,-1316 # ffffffffc0202090 <commands+0x4c8>
ffffffffc02005bc:	afbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00002517          	auipc	a0,0x2
ffffffffc02005c6:	ae650513          	addi	a0,a0,-1306 # ffffffffc02020a8 <commands+0x4e0>
ffffffffc02005ca:	aedff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00002517          	auipc	a0,0x2
ffffffffc02005d4:	af050513          	addi	a0,a0,-1296 # ffffffffc02020c0 <commands+0x4f8>
ffffffffc02005d8:	adfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00002517          	auipc	a0,0x2
ffffffffc02005e2:	afa50513          	addi	a0,a0,-1286 # ffffffffc02020d8 <commands+0x510>
ffffffffc02005e6:	ad1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00002517          	auipc	a0,0x2
ffffffffc02005f0:	b0450513          	addi	a0,a0,-1276 # ffffffffc02020f0 <commands+0x528>
ffffffffc02005f4:	ac3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00002517          	auipc	a0,0x2
ffffffffc02005fe:	b0e50513          	addi	a0,a0,-1266 # ffffffffc0202108 <commands+0x540>
ffffffffc0200602:	ab5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00002517          	auipc	a0,0x2
ffffffffc020060c:	b1850513          	addi	a0,a0,-1256 # ffffffffc0202120 <commands+0x558>
ffffffffc0200610:	aa7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00002517          	auipc	a0,0x2
ffffffffc020061a:	b2250513          	addi	a0,a0,-1246 # ffffffffc0202138 <commands+0x570>
ffffffffc020061e:	a99ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00002517          	auipc	a0,0x2
ffffffffc0200628:	b2c50513          	addi	a0,a0,-1236 # ffffffffc0202150 <commands+0x588>
ffffffffc020062c:	a8bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00002517          	auipc	a0,0x2
ffffffffc020063a:	b3250513          	addi	a0,a0,-1230 # ffffffffc0202168 <commands+0x5a0>
}
ffffffffc020063e:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200640:	bc9d                	j	ffffffffc02000b6 <cprintf>

ffffffffc0200642 <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc0200642:	1141                	addi	sp,sp,-16
ffffffffc0200644:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200646:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc0200648:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc020064a:	00002517          	auipc	a0,0x2
ffffffffc020064e:	b3650513          	addi	a0,a0,-1226 # ffffffffc0202180 <commands+0x5b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a63ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00002517          	auipc	a0,0x2
ffffffffc0200666:	b3650513          	addi	a0,a0,-1226 # ffffffffc0202198 <commands+0x5d0>
ffffffffc020066a:	a4dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00002517          	auipc	a0,0x2
ffffffffc0200676:	b3e50513          	addi	a0,a0,-1218 # ffffffffc02021b0 <commands+0x5e8>
ffffffffc020067a:	a3dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00002517          	auipc	a0,0x2
ffffffffc0200686:	b4650513          	addi	a0,a0,-1210 # ffffffffc02021c8 <commands+0x600>
ffffffffc020068a:	a2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00002517          	auipc	a0,0x2
ffffffffc020069a:	b4a50513          	addi	a0,a0,-1206 # ffffffffc02021e0 <commands+0x618>
}
ffffffffc020069e:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02006a0:	bc19                	j	ffffffffc02000b6 <cprintf>

ffffffffc02006a2 <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a2:	11853783          	ld	a5,280(a0)
    switch (cause) {
ffffffffc02006a6:	472d                	li	a4,11
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02006a8:	0786                	slli	a5,a5,0x1
ffffffffc02006aa:	8385                	srli	a5,a5,0x1
    switch (cause) {
ffffffffc02006ac:	06f76f63          	bltu	a4,a5,ffffffffc020072a <interrupt_handler+0x88>
ffffffffc02006b0:	00001717          	auipc	a4,0x1
ffffffffc02006b4:	6d470713          	addi	a4,a4,1748 # ffffffffc0201d84 <commands+0x1bc>
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
ffffffffc02006c6:	75650513          	addi	a0,a0,1878 # ffffffffc0201e18 <commands+0x250>
ffffffffc02006ca:	b2f5                	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	72c50513          	addi	a0,a0,1836 # ffffffffc0201df8 <commands+0x230>
ffffffffc02006d4:	b2cd                	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	6e250513          	addi	a0,a0,1762 # ffffffffc0201db8 <commands+0x1f0>
ffffffffc02006de:	bae1                	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	75850513          	addi	a0,a0,1880 # ffffffffc0201e38 <commands+0x270>
ffffffffc02006e8:	b2f9                	j	ffffffffc02000b6 <cprintf>
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
ffffffffc02006f2:	00006797          	auipc	a5,0x6
ffffffffc02006f6:	d3e78793          	addi	a5,a5,-706 # ffffffffc0206430 <ticks>
ffffffffc02006fa:	639c                	ld	a5,0(a5)
ffffffffc02006fc:	06400713          	li	a4,100
ffffffffc0200700:	0785                	addi	a5,a5,1
ffffffffc0200702:	02e7f733          	remu	a4,a5,a4
ffffffffc0200706:	00006697          	auipc	a3,0x6
ffffffffc020070a:	d2f6b523          	sd	a5,-726(a3) # ffffffffc0206430 <ticks>
ffffffffc020070e:	cf19                	beqz	a4,ffffffffc020072c <interrupt_handler+0x8a>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200710:	60a2                	ld	ra,8(sp)
ffffffffc0200712:	0141                	addi	sp,sp,16
ffffffffc0200714:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200716:	00001517          	auipc	a0,0x1
ffffffffc020071a:	74a50513          	addi	a0,a0,1866 # ffffffffc0201e60 <commands+0x298>
ffffffffc020071e:	ba61                	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200720:	00001517          	auipc	a0,0x1
ffffffffc0200724:	6b850513          	addi	a0,a0,1720 # ffffffffc0201dd8 <commands+0x210>
ffffffffc0200728:	b279                	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc020072a:	bf21                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc020072c:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020072e:	06400593          	li	a1,100
ffffffffc0200732:	00001517          	auipc	a0,0x1
ffffffffc0200736:	71e50513          	addi	a0,a0,1822 # ffffffffc0201e50 <commands+0x288>
}
ffffffffc020073a:	0141                	addi	sp,sp,16
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020073c:	baad                	j	ffffffffc02000b6 <cprintf>

ffffffffc020073e <trap>:
            break;
    }
}

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc020073e:	11853783          	ld	a5,280(a0)
ffffffffc0200742:	0007c763          	bltz	a5,ffffffffc0200750 <trap+0x12>
    switch (tf->cause) {
ffffffffc0200746:	472d                	li	a4,11
ffffffffc0200748:	00f76363          	bltu	a4,a5,ffffffffc020074e <trap+0x10>
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void trap(struct trapframe *tf) {
    // dispatch based on what type of trap occurred
    trap_dispatch(tf);
}
ffffffffc020074c:	8082                	ret
            print_trapframe(tf);
ffffffffc020074e:	bdd5                	j	ffffffffc0200642 <print_trapframe>
        interrupt_handler(tf);
ffffffffc0200750:	bf89                	j	ffffffffc02006a2 <interrupt_handler>
	...

ffffffffc0200754 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200754:	14011073          	csrw	sscratch,sp
ffffffffc0200758:	712d                	addi	sp,sp,-288
ffffffffc020075a:	e002                	sd	zero,0(sp)
ffffffffc020075c:	e406                	sd	ra,8(sp)
ffffffffc020075e:	ec0e                	sd	gp,24(sp)
ffffffffc0200760:	f012                	sd	tp,32(sp)
ffffffffc0200762:	f416                	sd	t0,40(sp)
ffffffffc0200764:	f81a                	sd	t1,48(sp)
ffffffffc0200766:	fc1e                	sd	t2,56(sp)
ffffffffc0200768:	e0a2                	sd	s0,64(sp)
ffffffffc020076a:	e4a6                	sd	s1,72(sp)
ffffffffc020076c:	e8aa                	sd	a0,80(sp)
ffffffffc020076e:	ecae                	sd	a1,88(sp)
ffffffffc0200770:	f0b2                	sd	a2,96(sp)
ffffffffc0200772:	f4b6                	sd	a3,104(sp)
ffffffffc0200774:	f8ba                	sd	a4,112(sp)
ffffffffc0200776:	fcbe                	sd	a5,120(sp)
ffffffffc0200778:	e142                	sd	a6,128(sp)
ffffffffc020077a:	e546                	sd	a7,136(sp)
ffffffffc020077c:	e94a                	sd	s2,144(sp)
ffffffffc020077e:	ed4e                	sd	s3,152(sp)
ffffffffc0200780:	f152                	sd	s4,160(sp)
ffffffffc0200782:	f556                	sd	s5,168(sp)
ffffffffc0200784:	f95a                	sd	s6,176(sp)
ffffffffc0200786:	fd5e                	sd	s7,184(sp)
ffffffffc0200788:	e1e2                	sd	s8,192(sp)
ffffffffc020078a:	e5e6                	sd	s9,200(sp)
ffffffffc020078c:	e9ea                	sd	s10,208(sp)
ffffffffc020078e:	edee                	sd	s11,216(sp)
ffffffffc0200790:	f1f2                	sd	t3,224(sp)
ffffffffc0200792:	f5f6                	sd	t4,232(sp)
ffffffffc0200794:	f9fa                	sd	t5,240(sp)
ffffffffc0200796:	fdfe                	sd	t6,248(sp)
ffffffffc0200798:	14001473          	csrrw	s0,sscratch,zero
ffffffffc020079c:	100024f3          	csrr	s1,sstatus
ffffffffc02007a0:	14102973          	csrr	s2,sepc
ffffffffc02007a4:	143029f3          	csrr	s3,stval
ffffffffc02007a8:	14202a73          	csrr	s4,scause
ffffffffc02007ac:	e822                	sd	s0,16(sp)
ffffffffc02007ae:	e226                	sd	s1,256(sp)
ffffffffc02007b0:	e64a                	sd	s2,264(sp)
ffffffffc02007b2:	ea4e                	sd	s3,272(sp)
ffffffffc02007b4:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc02007b6:	850a                	mv	a0,sp
    jal trap
ffffffffc02007b8:	f87ff0ef          	jal	ra,ffffffffc020073e <trap>

ffffffffc02007bc <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc02007bc:	6492                	ld	s1,256(sp)
ffffffffc02007be:	6932                	ld	s2,264(sp)
ffffffffc02007c0:	10049073          	csrw	sstatus,s1
ffffffffc02007c4:	14191073          	csrw	sepc,s2
ffffffffc02007c8:	60a2                	ld	ra,8(sp)
ffffffffc02007ca:	61e2                	ld	gp,24(sp)
ffffffffc02007cc:	7202                	ld	tp,32(sp)
ffffffffc02007ce:	72a2                	ld	t0,40(sp)
ffffffffc02007d0:	7342                	ld	t1,48(sp)
ffffffffc02007d2:	73e2                	ld	t2,56(sp)
ffffffffc02007d4:	6406                	ld	s0,64(sp)
ffffffffc02007d6:	64a6                	ld	s1,72(sp)
ffffffffc02007d8:	6546                	ld	a0,80(sp)
ffffffffc02007da:	65e6                	ld	a1,88(sp)
ffffffffc02007dc:	7606                	ld	a2,96(sp)
ffffffffc02007de:	76a6                	ld	a3,104(sp)
ffffffffc02007e0:	7746                	ld	a4,112(sp)
ffffffffc02007e2:	77e6                	ld	a5,120(sp)
ffffffffc02007e4:	680a                	ld	a6,128(sp)
ffffffffc02007e6:	68aa                	ld	a7,136(sp)
ffffffffc02007e8:	694a                	ld	s2,144(sp)
ffffffffc02007ea:	69ea                	ld	s3,152(sp)
ffffffffc02007ec:	7a0a                	ld	s4,160(sp)
ffffffffc02007ee:	7aaa                	ld	s5,168(sp)
ffffffffc02007f0:	7b4a                	ld	s6,176(sp)
ffffffffc02007f2:	7bea                	ld	s7,184(sp)
ffffffffc02007f4:	6c0e                	ld	s8,192(sp)
ffffffffc02007f6:	6cae                	ld	s9,200(sp)
ffffffffc02007f8:	6d4e                	ld	s10,208(sp)
ffffffffc02007fa:	6dee                	ld	s11,216(sp)
ffffffffc02007fc:	7e0e                	ld	t3,224(sp)
ffffffffc02007fe:	7eae                	ld	t4,232(sp)
ffffffffc0200800:	7f4e                	ld	t5,240(sp)
ffffffffc0200802:	7fee                	ld	t6,248(sp)
ffffffffc0200804:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200806:	10200073          	sret

ffffffffc020080a <best_fit_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020080a:	00006797          	auipc	a5,0x6
ffffffffc020080e:	c2e78793          	addi	a5,a5,-978 # ffffffffc0206438 <free_area>
ffffffffc0200812:	e79c                	sd	a5,8(a5)
ffffffffc0200814:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
best_fit_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200816:	0007a823          	sw	zero,16(a5)
}
ffffffffc020081a:	8082                	ret

ffffffffc020081c <best_fit_nr_free_pages>:
}

static size_t
best_fit_nr_free_pages(void) {
    return nr_free;
}
ffffffffc020081c:	00006517          	auipc	a0,0x6
ffffffffc0200820:	c2c56503          	lwu	a0,-980(a0) # ffffffffc0206448 <free_area+0x10>
ffffffffc0200824:	8082                	ret

ffffffffc0200826 <best_fit_alloc_pages>:
    assert(n > 0);
ffffffffc0200826:	c15d                	beqz	a0,ffffffffc02008cc <best_fit_alloc_pages+0xa6>
    if (n > nr_free) {
ffffffffc0200828:	00006617          	auipc	a2,0x6
ffffffffc020082c:	c1060613          	addi	a2,a2,-1008 # ffffffffc0206438 <free_area>
ffffffffc0200830:	01062803          	lw	a6,16(a2)
ffffffffc0200834:	86aa                	mv	a3,a0
ffffffffc0200836:	02081793          	slli	a5,a6,0x20
ffffffffc020083a:	9381                	srli	a5,a5,0x20
ffffffffc020083c:	08a7e663          	bltu	a5,a0,ffffffffc02008c8 <best_fit_alloc_pages+0xa2>
    size_t min_size = nr_free + 1;
ffffffffc0200840:	0018059b          	addiw	a1,a6,1
ffffffffc0200844:	1582                	slli	a1,a1,0x20
ffffffffc0200846:	9181                	srli	a1,a1,0x20
    list_entry_t *le = &free_list;
ffffffffc0200848:	87b2                	mv	a5,a2
    struct Page *page = NULL;
ffffffffc020084a:	4501                	li	a0,0
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc020084c:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc020084e:	00c78e63          	beq	a5,a2,ffffffffc020086a <best_fit_alloc_pages+0x44>
        if (p->property >= n&&p->property< min_size) {
ffffffffc0200852:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0200856:	fed76be3          	bltu	a4,a3,ffffffffc020084c <best_fit_alloc_pages+0x26>
ffffffffc020085a:	feb779e3          	bgeu	a4,a1,ffffffffc020084c <best_fit_alloc_pages+0x26>
        struct Page *p = le2page(le, page_link);
ffffffffc020085e:	fe878513          	addi	a0,a5,-24
ffffffffc0200862:	679c                	ld	a5,8(a5)
ffffffffc0200864:	85ba                	mv	a1,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200866:	fec796e3          	bne	a5,a2,ffffffffc0200852 <best_fit_alloc_pages+0x2c>
    if (page != NULL) {
ffffffffc020086a:	c125                	beqz	a0,ffffffffc02008ca <best_fit_alloc_pages+0xa4>
    __list_del(listelm->prev, listelm->next);
ffffffffc020086c:	7118                	ld	a4,32(a0)
 * list_prev - get the previous entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_prev(list_entry_t *listelm) {
    return listelm->prev;
ffffffffc020086e:	6d10                	ld	a2,24(a0)
        if (page->property > n) {
ffffffffc0200870:	490c                	lw	a1,16(a0)
ffffffffc0200872:	0006889b          	sext.w	a7,a3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200876:	e618                	sd	a4,8(a2)
    next->prev = prev;
ffffffffc0200878:	e310                	sd	a2,0(a4)
ffffffffc020087a:	02059713          	slli	a4,a1,0x20
ffffffffc020087e:	9301                	srli	a4,a4,0x20
ffffffffc0200880:	02e6f863          	bgeu	a3,a4,ffffffffc02008b0 <best_fit_alloc_pages+0x8a>
            struct Page *p = page + n;
ffffffffc0200884:	00269713          	slli	a4,a3,0x2
ffffffffc0200888:	9736                	add	a4,a4,a3
ffffffffc020088a:	070e                	slli	a4,a4,0x3
ffffffffc020088c:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc020088e:	411585bb          	subw	a1,a1,a7
ffffffffc0200892:	cb0c                	sw	a1,16(a4)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200894:	4689                	li	a3,2
ffffffffc0200896:	00870593          	addi	a1,a4,8
ffffffffc020089a:	40d5b02f          	amoor.d	zero,a3,(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc020089e:	6614                	ld	a3,8(a2)
            list_add(prev, &(p->page_link));
ffffffffc02008a0:	01870593          	addi	a1,a4,24
    prev->next = next->prev = elm;
ffffffffc02008a4:	0107a803          	lw	a6,16(a5)
ffffffffc02008a8:	e28c                	sd	a1,0(a3)
ffffffffc02008aa:	e60c                	sd	a1,8(a2)
    elm->next = next;
ffffffffc02008ac:	f314                	sd	a3,32(a4)
    elm->prev = prev;
ffffffffc02008ae:	ef10                	sd	a2,24(a4)
        nr_free -= n;
ffffffffc02008b0:	4118083b          	subw	a6,a6,a7
ffffffffc02008b4:	00006797          	auipc	a5,0x6
ffffffffc02008b8:	b907aa23          	sw	a6,-1132(a5) # ffffffffc0206448 <free_area+0x10>
 * clear_bit - Atomically clears a bit in memory
 * @nr:     the bit to clear
 * @addr:   the address to start counting from
 * */
static inline void clear_bit(int nr, volatile void *addr) {
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02008bc:	57f5                	li	a5,-3
ffffffffc02008be:	00850713          	addi	a4,a0,8
ffffffffc02008c2:	60f7302f          	amoand.d	zero,a5,(a4)
ffffffffc02008c6:	8082                	ret
        return NULL;
ffffffffc02008c8:	4501                	li	a0,0
}
ffffffffc02008ca:	8082                	ret
best_fit_alloc_pages(size_t n) {
ffffffffc02008cc:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02008ce:	00002697          	auipc	a3,0x2
ffffffffc02008d2:	92a68693          	addi	a3,a3,-1750 # ffffffffc02021f8 <commands+0x630>
ffffffffc02008d6:	00002617          	auipc	a2,0x2
ffffffffc02008da:	92a60613          	addi	a2,a2,-1750 # ffffffffc0202200 <commands+0x638>
ffffffffc02008de:	06a00593          	li	a1,106
ffffffffc02008e2:	00002517          	auipc	a0,0x2
ffffffffc02008e6:	93650513          	addi	a0,a0,-1738 # ffffffffc0202218 <commands+0x650>
best_fit_alloc_pages(size_t n) {
ffffffffc02008ea:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02008ec:	abdff0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc02008f0 <best_fit_check>:
}

// LAB2: below code is used to check the best fit allocation algorithm 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
best_fit_check(void) {
ffffffffc02008f0:	715d                	addi	sp,sp,-80
ffffffffc02008f2:	f84a                	sd	s2,48(sp)
    return listelm->next;
ffffffffc02008f4:	00006917          	auipc	s2,0x6
ffffffffc02008f8:	b4490913          	addi	s2,s2,-1212 # ffffffffc0206438 <free_area>
ffffffffc02008fc:	00893783          	ld	a5,8(s2)
ffffffffc0200900:	e486                	sd	ra,72(sp)
ffffffffc0200902:	e0a2                	sd	s0,64(sp)
ffffffffc0200904:	fc26                	sd	s1,56(sp)
ffffffffc0200906:	f44e                	sd	s3,40(sp)
ffffffffc0200908:	f052                	sd	s4,32(sp)
ffffffffc020090a:	ec56                	sd	s5,24(sp)
ffffffffc020090c:	e85a                	sd	s6,16(sp)
ffffffffc020090e:	e45e                	sd	s7,8(sp)
ffffffffc0200910:	e062                	sd	s8,0(sp)
    int score = 0 ,sumscore = 6;
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200912:	2d278363          	beq	a5,s2,ffffffffc0200bd8 <best_fit_check+0x2e8>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200916:	ff07b703          	ld	a4,-16(a5)
ffffffffc020091a:	8305                	srli	a4,a4,0x1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020091c:	8b05                	andi	a4,a4,1
ffffffffc020091e:	2c070163          	beqz	a4,ffffffffc0200be0 <best_fit_check+0x2f0>
    int count = 0, total = 0;
ffffffffc0200922:	4401                	li	s0,0
ffffffffc0200924:	4481                	li	s1,0
ffffffffc0200926:	a031                	j	ffffffffc0200932 <best_fit_check+0x42>
ffffffffc0200928:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc020092c:	8b09                	andi	a4,a4,2
ffffffffc020092e:	2a070963          	beqz	a4,ffffffffc0200be0 <best_fit_check+0x2f0>
        count ++, total += p->property;
ffffffffc0200932:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200936:	679c                	ld	a5,8(a5)
ffffffffc0200938:	2485                	addiw	s1,s1,1
ffffffffc020093a:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc020093c:	ff2796e3          	bne	a5,s2,ffffffffc0200928 <best_fit_check+0x38>
ffffffffc0200940:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200942:	1f7000ef          	jal	ra,ffffffffc0201338 <nr_free_pages>
ffffffffc0200946:	37351d63          	bne	a0,s3,ffffffffc0200cc0 <best_fit_check+0x3d0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020094a:	4505                	li	a0,1
ffffffffc020094c:	163000ef          	jal	ra,ffffffffc02012ae <alloc_pages>
ffffffffc0200950:	8a2a                	mv	s4,a0
ffffffffc0200952:	3a050763          	beqz	a0,ffffffffc0200d00 <best_fit_check+0x410>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200956:	4505                	li	a0,1
ffffffffc0200958:	157000ef          	jal	ra,ffffffffc02012ae <alloc_pages>
ffffffffc020095c:	89aa                	mv	s3,a0
ffffffffc020095e:	38050163          	beqz	a0,ffffffffc0200ce0 <best_fit_check+0x3f0>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200962:	4505                	li	a0,1
ffffffffc0200964:	14b000ef          	jal	ra,ffffffffc02012ae <alloc_pages>
ffffffffc0200968:	8aaa                	mv	s5,a0
ffffffffc020096a:	30050b63          	beqz	a0,ffffffffc0200c80 <best_fit_check+0x390>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc020096e:	293a0963          	beq	s4,s3,ffffffffc0200c00 <best_fit_check+0x310>
ffffffffc0200972:	28aa0763          	beq	s4,a0,ffffffffc0200c00 <best_fit_check+0x310>
ffffffffc0200976:	28a98563          	beq	s3,a0,ffffffffc0200c00 <best_fit_check+0x310>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020097a:	000a2783          	lw	a5,0(s4)
ffffffffc020097e:	2a079163          	bnez	a5,ffffffffc0200c20 <best_fit_check+0x330>
ffffffffc0200982:	0009a783          	lw	a5,0(s3)
ffffffffc0200986:	28079d63          	bnez	a5,ffffffffc0200c20 <best_fit_check+0x330>
ffffffffc020098a:	411c                	lw	a5,0(a0)
ffffffffc020098c:	28079a63          	bnez	a5,ffffffffc0200c20 <best_fit_check+0x330>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200990:	00006797          	auipc	a5,0x6
ffffffffc0200994:	ad878793          	addi	a5,a5,-1320 # ffffffffc0206468 <pages>
ffffffffc0200998:	639c                	ld	a5,0(a5)
ffffffffc020099a:	00002717          	auipc	a4,0x2
ffffffffc020099e:	89670713          	addi	a4,a4,-1898 # ffffffffc0202230 <commands+0x668>
ffffffffc02009a2:	630c                	ld	a1,0(a4)
ffffffffc02009a4:	40fa0733          	sub	a4,s4,a5
ffffffffc02009a8:	870d                	srai	a4,a4,0x3
ffffffffc02009aa:	02b70733          	mul	a4,a4,a1
ffffffffc02009ae:	00002697          	auipc	a3,0x2
ffffffffc02009b2:	f4268693          	addi	a3,a3,-190 # ffffffffc02028f0 <nbase>
ffffffffc02009b6:	6290                	ld	a2,0(a3)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02009b8:	00006697          	auipc	a3,0x6
ffffffffc02009bc:	a6068693          	addi	a3,a3,-1440 # ffffffffc0206418 <npage>
ffffffffc02009c0:	6294                	ld	a3,0(a3)
ffffffffc02009c2:	06b2                	slli	a3,a3,0xc
ffffffffc02009c4:	9732                	add	a4,a4,a2

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc02009c6:	0732                	slli	a4,a4,0xc
ffffffffc02009c8:	26d77c63          	bgeu	a4,a3,ffffffffc0200c40 <best_fit_check+0x350>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009cc:	40f98733          	sub	a4,s3,a5
ffffffffc02009d0:	870d                	srai	a4,a4,0x3
ffffffffc02009d2:	02b70733          	mul	a4,a4,a1
ffffffffc02009d6:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02009d8:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02009da:	42d77363          	bgeu	a4,a3,ffffffffc0200e00 <best_fit_check+0x510>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc02009de:	40f507b3          	sub	a5,a0,a5
ffffffffc02009e2:	878d                	srai	a5,a5,0x3
ffffffffc02009e4:	02b787b3          	mul	a5,a5,a1
ffffffffc02009e8:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc02009ea:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02009ec:	3ed7fa63          	bgeu	a5,a3,ffffffffc0200de0 <best_fit_check+0x4f0>
    assert(alloc_page() == NULL);
ffffffffc02009f0:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02009f2:	00093c03          	ld	s8,0(s2)
ffffffffc02009f6:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc02009fa:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc02009fe:	00006797          	auipc	a5,0x6
ffffffffc0200a02:	a527b123          	sd	s2,-1470(a5) # ffffffffc0206440 <free_area+0x8>
ffffffffc0200a06:	00006797          	auipc	a5,0x6
ffffffffc0200a0a:	a327b923          	sd	s2,-1486(a5) # ffffffffc0206438 <free_area>
    nr_free = 0;
ffffffffc0200a0e:	00006797          	auipc	a5,0x6
ffffffffc0200a12:	a207ad23          	sw	zero,-1478(a5) # ffffffffc0206448 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200a16:	099000ef          	jal	ra,ffffffffc02012ae <alloc_pages>
ffffffffc0200a1a:	3a051363          	bnez	a0,ffffffffc0200dc0 <best_fit_check+0x4d0>
    free_page(p0);
ffffffffc0200a1e:	4585                	li	a1,1
ffffffffc0200a20:	8552                	mv	a0,s4
ffffffffc0200a22:	0d1000ef          	jal	ra,ffffffffc02012f2 <free_pages>
    free_page(p1);
ffffffffc0200a26:	4585                	li	a1,1
ffffffffc0200a28:	854e                	mv	a0,s3
ffffffffc0200a2a:	0c9000ef          	jal	ra,ffffffffc02012f2 <free_pages>
    free_page(p2);
ffffffffc0200a2e:	4585                	li	a1,1
ffffffffc0200a30:	8556                	mv	a0,s5
ffffffffc0200a32:	0c1000ef          	jal	ra,ffffffffc02012f2 <free_pages>
    assert(nr_free == 3);
ffffffffc0200a36:	01092703          	lw	a4,16(s2)
ffffffffc0200a3a:	478d                	li	a5,3
ffffffffc0200a3c:	36f71263          	bne	a4,a5,ffffffffc0200da0 <best_fit_check+0x4b0>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200a40:	4505                	li	a0,1
ffffffffc0200a42:	06d000ef          	jal	ra,ffffffffc02012ae <alloc_pages>
ffffffffc0200a46:	89aa                	mv	s3,a0
ffffffffc0200a48:	32050c63          	beqz	a0,ffffffffc0200d80 <best_fit_check+0x490>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200a4c:	4505                	li	a0,1
ffffffffc0200a4e:	061000ef          	jal	ra,ffffffffc02012ae <alloc_pages>
ffffffffc0200a52:	8aaa                	mv	s5,a0
ffffffffc0200a54:	30050663          	beqz	a0,ffffffffc0200d60 <best_fit_check+0x470>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200a58:	4505                	li	a0,1
ffffffffc0200a5a:	055000ef          	jal	ra,ffffffffc02012ae <alloc_pages>
ffffffffc0200a5e:	8a2a                	mv	s4,a0
ffffffffc0200a60:	2e050063          	beqz	a0,ffffffffc0200d40 <best_fit_check+0x450>
    assert(alloc_page() == NULL);
ffffffffc0200a64:	4505                	li	a0,1
ffffffffc0200a66:	049000ef          	jal	ra,ffffffffc02012ae <alloc_pages>
ffffffffc0200a6a:	2a051b63          	bnez	a0,ffffffffc0200d20 <best_fit_check+0x430>
    free_page(p0);
ffffffffc0200a6e:	4585                	li	a1,1
ffffffffc0200a70:	854e                	mv	a0,s3
ffffffffc0200a72:	081000ef          	jal	ra,ffffffffc02012f2 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200a76:	00893783          	ld	a5,8(s2)
ffffffffc0200a7a:	1f278363          	beq	a5,s2,ffffffffc0200c60 <best_fit_check+0x370>
    assert((p = alloc_page()) == p0);
ffffffffc0200a7e:	4505                	li	a0,1
ffffffffc0200a80:	02f000ef          	jal	ra,ffffffffc02012ae <alloc_pages>
ffffffffc0200a84:	54a99e63          	bne	s3,a0,ffffffffc0200fe0 <best_fit_check+0x6f0>
    assert(alloc_page() == NULL);
ffffffffc0200a88:	4505                	li	a0,1
ffffffffc0200a8a:	025000ef          	jal	ra,ffffffffc02012ae <alloc_pages>
ffffffffc0200a8e:	52051963          	bnez	a0,ffffffffc0200fc0 <best_fit_check+0x6d0>
    assert(nr_free == 0);
ffffffffc0200a92:	01092783          	lw	a5,16(s2)
ffffffffc0200a96:	50079563          	bnez	a5,ffffffffc0200fa0 <best_fit_check+0x6b0>
    free_page(p);
ffffffffc0200a9a:	854e                	mv	a0,s3
ffffffffc0200a9c:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200a9e:	00006797          	auipc	a5,0x6
ffffffffc0200aa2:	9987bd23          	sd	s8,-1638(a5) # ffffffffc0206438 <free_area>
ffffffffc0200aa6:	00006797          	auipc	a5,0x6
ffffffffc0200aaa:	9977bd23          	sd	s7,-1638(a5) # ffffffffc0206440 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0200aae:	00006797          	auipc	a5,0x6
ffffffffc0200ab2:	9967ad23          	sw	s6,-1638(a5) # ffffffffc0206448 <free_area+0x10>
    free_page(p);
ffffffffc0200ab6:	03d000ef          	jal	ra,ffffffffc02012f2 <free_pages>
    free_page(p1);
ffffffffc0200aba:	4585                	li	a1,1
ffffffffc0200abc:	8556                	mv	a0,s5
ffffffffc0200abe:	035000ef          	jal	ra,ffffffffc02012f2 <free_pages>
    free_page(p2);
ffffffffc0200ac2:	4585                	li	a1,1
ffffffffc0200ac4:	8552                	mv	a0,s4
ffffffffc0200ac6:	02d000ef          	jal	ra,ffffffffc02012f2 <free_pages>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200aca:	4515                	li	a0,5
ffffffffc0200acc:	7e2000ef          	jal	ra,ffffffffc02012ae <alloc_pages>
ffffffffc0200ad0:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200ad2:	4a050763          	beqz	a0,ffffffffc0200f80 <best_fit_check+0x690>
ffffffffc0200ad6:	651c                	ld	a5,8(a0)
ffffffffc0200ad8:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200ada:	8b85                	andi	a5,a5,1
ffffffffc0200adc:	48079263          	bnez	a5,ffffffffc0200f60 <best_fit_check+0x670>
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200ae0:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200ae2:	00093b03          	ld	s6,0(s2)
ffffffffc0200ae6:	00893a83          	ld	s5,8(s2)
ffffffffc0200aea:	00006797          	auipc	a5,0x6
ffffffffc0200aee:	9527b723          	sd	s2,-1714(a5) # ffffffffc0206438 <free_area>
ffffffffc0200af2:	00006797          	auipc	a5,0x6
ffffffffc0200af6:	9527b723          	sd	s2,-1714(a5) # ffffffffc0206440 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc0200afa:	7b4000ef          	jal	ra,ffffffffc02012ae <alloc_pages>
ffffffffc0200afe:	44051163          	bnez	a0,ffffffffc0200f40 <best_fit_check+0x650>
    #endif
    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    // * - - * -
    free_pages(p0 + 1, 2);
ffffffffc0200b02:	4589                	li	a1,2
ffffffffc0200b04:	02898513          	addi	a0,s3,40
    unsigned int nr_free_store = nr_free;
ffffffffc0200b08:	01092b83          	lw	s7,16(s2)
    free_pages(p0 + 4, 1);
ffffffffc0200b0c:	0a098c13          	addi	s8,s3,160
    nr_free = 0;
ffffffffc0200b10:	00006797          	auipc	a5,0x6
ffffffffc0200b14:	9207ac23          	sw	zero,-1736(a5) # ffffffffc0206448 <free_area+0x10>
    free_pages(p0 + 1, 2);
ffffffffc0200b18:	7da000ef          	jal	ra,ffffffffc02012f2 <free_pages>
    free_pages(p0 + 4, 1);
ffffffffc0200b1c:	8562                	mv	a0,s8
ffffffffc0200b1e:	4585                	li	a1,1
ffffffffc0200b20:	7d2000ef          	jal	ra,ffffffffc02012f2 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200b24:	4511                	li	a0,4
ffffffffc0200b26:	788000ef          	jal	ra,ffffffffc02012ae <alloc_pages>
ffffffffc0200b2a:	3e051b63          	bnez	a0,ffffffffc0200f20 <best_fit_check+0x630>
ffffffffc0200b2e:	0309b783          	ld	a5,48(s3)
ffffffffc0200b32:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200b34:	8b85                	andi	a5,a5,1
ffffffffc0200b36:	3c078563          	beqz	a5,ffffffffc0200f00 <best_fit_check+0x610>
ffffffffc0200b3a:	0389a703          	lw	a4,56(s3)
ffffffffc0200b3e:	4789                	li	a5,2
ffffffffc0200b40:	3cf71063          	bne	a4,a5,ffffffffc0200f00 <best_fit_check+0x610>
    // * - - * *
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200b44:	4505                	li	a0,1
ffffffffc0200b46:	768000ef          	jal	ra,ffffffffc02012ae <alloc_pages>
ffffffffc0200b4a:	8a2a                	mv	s4,a0
ffffffffc0200b4c:	38050a63          	beqz	a0,ffffffffc0200ee0 <best_fit_check+0x5f0>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200b50:	4509                	li	a0,2
ffffffffc0200b52:	75c000ef          	jal	ra,ffffffffc02012ae <alloc_pages>
ffffffffc0200b56:	36050563          	beqz	a0,ffffffffc0200ec0 <best_fit_check+0x5d0>
    assert(p0 + 4 == p1);
ffffffffc0200b5a:	354c1363          	bne	s8,s4,ffffffffc0200ea0 <best_fit_check+0x5b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    p2 = p0 + 1;
    free_pages(p0, 5);
ffffffffc0200b5e:	854e                	mv	a0,s3
ffffffffc0200b60:	4595                	li	a1,5
ffffffffc0200b62:	790000ef          	jal	ra,ffffffffc02012f2 <free_pages>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200b66:	4515                	li	a0,5
ffffffffc0200b68:	746000ef          	jal	ra,ffffffffc02012ae <alloc_pages>
ffffffffc0200b6c:	89aa                	mv	s3,a0
ffffffffc0200b6e:	30050963          	beqz	a0,ffffffffc0200e80 <best_fit_check+0x590>
    assert(alloc_page() == NULL);
ffffffffc0200b72:	4505                	li	a0,1
ffffffffc0200b74:	73a000ef          	jal	ra,ffffffffc02012ae <alloc_pages>
ffffffffc0200b78:	2e051463          	bnez	a0,ffffffffc0200e60 <best_fit_check+0x570>

    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
    assert(nr_free == 0);
ffffffffc0200b7c:	01092783          	lw	a5,16(s2)
ffffffffc0200b80:	2c079063          	bnez	a5,ffffffffc0200e40 <best_fit_check+0x550>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200b84:	4595                	li	a1,5
ffffffffc0200b86:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0200b88:	00006797          	auipc	a5,0x6
ffffffffc0200b8c:	8d77a023          	sw	s7,-1856(a5) # ffffffffc0206448 <free_area+0x10>
    free_list = free_list_store;
ffffffffc0200b90:	00006797          	auipc	a5,0x6
ffffffffc0200b94:	8b67b423          	sd	s6,-1880(a5) # ffffffffc0206438 <free_area>
ffffffffc0200b98:	00006797          	auipc	a5,0x6
ffffffffc0200b9c:	8b57b423          	sd	s5,-1880(a5) # ffffffffc0206440 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc0200ba0:	752000ef          	jal	ra,ffffffffc02012f2 <free_pages>
    return listelm->next;
ffffffffc0200ba4:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ba8:	01278963          	beq	a5,s2,ffffffffc0200bba <best_fit_check+0x2ca>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200bac:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200bb0:	679c                	ld	a5,8(a5)
ffffffffc0200bb2:	34fd                	addiw	s1,s1,-1
ffffffffc0200bb4:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bb6:	ff279be3          	bne	a5,s2,ffffffffc0200bac <best_fit_check+0x2bc>
    }
    assert(count == 0);
ffffffffc0200bba:	26049363          	bnez	s1,ffffffffc0200e20 <best_fit_check+0x530>
    assert(total == 0);
ffffffffc0200bbe:	e06d                	bnez	s0,ffffffffc0200ca0 <best_fit_check+0x3b0>
    #ifdef ucore_test
    score += 1;
    cprintf("grading: %d / %d points\n",score, sumscore);
    #endif
}
ffffffffc0200bc0:	60a6                	ld	ra,72(sp)
ffffffffc0200bc2:	6406                	ld	s0,64(sp)
ffffffffc0200bc4:	74e2                	ld	s1,56(sp)
ffffffffc0200bc6:	7942                	ld	s2,48(sp)
ffffffffc0200bc8:	79a2                	ld	s3,40(sp)
ffffffffc0200bca:	7a02                	ld	s4,32(sp)
ffffffffc0200bcc:	6ae2                	ld	s5,24(sp)
ffffffffc0200bce:	6b42                	ld	s6,16(sp)
ffffffffc0200bd0:	6ba2                	ld	s7,8(sp)
ffffffffc0200bd2:	6c02                	ld	s8,0(sp)
ffffffffc0200bd4:	6161                	addi	sp,sp,80
ffffffffc0200bd6:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200bd8:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0200bda:	4401                	li	s0,0
ffffffffc0200bdc:	4481                	li	s1,0
ffffffffc0200bde:	b395                	j	ffffffffc0200942 <best_fit_check+0x52>
        assert(PageProperty(p));
ffffffffc0200be0:	00001697          	auipc	a3,0x1
ffffffffc0200be4:	65868693          	addi	a3,a3,1624 # ffffffffc0202238 <commands+0x670>
ffffffffc0200be8:	00001617          	auipc	a2,0x1
ffffffffc0200bec:	61860613          	addi	a2,a2,1560 # ffffffffc0202200 <commands+0x638>
ffffffffc0200bf0:	10900593          	li	a1,265
ffffffffc0200bf4:	00001517          	auipc	a0,0x1
ffffffffc0200bf8:	62450513          	addi	a0,a0,1572 # ffffffffc0202218 <commands+0x650>
ffffffffc0200bfc:	facff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200c00:	00001697          	auipc	a3,0x1
ffffffffc0200c04:	6c868693          	addi	a3,a3,1736 # ffffffffc02022c8 <commands+0x700>
ffffffffc0200c08:	00001617          	auipc	a2,0x1
ffffffffc0200c0c:	5f860613          	addi	a2,a2,1528 # ffffffffc0202200 <commands+0x638>
ffffffffc0200c10:	0d500593          	li	a1,213
ffffffffc0200c14:	00001517          	auipc	a0,0x1
ffffffffc0200c18:	60450513          	addi	a0,a0,1540 # ffffffffc0202218 <commands+0x650>
ffffffffc0200c1c:	f8cff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200c20:	00001697          	auipc	a3,0x1
ffffffffc0200c24:	6d068693          	addi	a3,a3,1744 # ffffffffc02022f0 <commands+0x728>
ffffffffc0200c28:	00001617          	auipc	a2,0x1
ffffffffc0200c2c:	5d860613          	addi	a2,a2,1496 # ffffffffc0202200 <commands+0x638>
ffffffffc0200c30:	0d600593          	li	a1,214
ffffffffc0200c34:	00001517          	auipc	a0,0x1
ffffffffc0200c38:	5e450513          	addi	a0,a0,1508 # ffffffffc0202218 <commands+0x650>
ffffffffc0200c3c:	f6cff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200c40:	00001697          	auipc	a3,0x1
ffffffffc0200c44:	6f068693          	addi	a3,a3,1776 # ffffffffc0202330 <commands+0x768>
ffffffffc0200c48:	00001617          	auipc	a2,0x1
ffffffffc0200c4c:	5b860613          	addi	a2,a2,1464 # ffffffffc0202200 <commands+0x638>
ffffffffc0200c50:	0d800593          	li	a1,216
ffffffffc0200c54:	00001517          	auipc	a0,0x1
ffffffffc0200c58:	5c450513          	addi	a0,a0,1476 # ffffffffc0202218 <commands+0x650>
ffffffffc0200c5c:	f4cff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(!list_empty(&free_list));
ffffffffc0200c60:	00001697          	auipc	a3,0x1
ffffffffc0200c64:	75868693          	addi	a3,a3,1880 # ffffffffc02023b8 <commands+0x7f0>
ffffffffc0200c68:	00001617          	auipc	a2,0x1
ffffffffc0200c6c:	59860613          	addi	a2,a2,1432 # ffffffffc0202200 <commands+0x638>
ffffffffc0200c70:	0f100593          	li	a1,241
ffffffffc0200c74:	00001517          	auipc	a0,0x1
ffffffffc0200c78:	5a450513          	addi	a0,a0,1444 # ffffffffc0202218 <commands+0x650>
ffffffffc0200c7c:	f2cff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200c80:	00001697          	auipc	a3,0x1
ffffffffc0200c84:	62868693          	addi	a3,a3,1576 # ffffffffc02022a8 <commands+0x6e0>
ffffffffc0200c88:	00001617          	auipc	a2,0x1
ffffffffc0200c8c:	57860613          	addi	a2,a2,1400 # ffffffffc0202200 <commands+0x638>
ffffffffc0200c90:	0d300593          	li	a1,211
ffffffffc0200c94:	00001517          	auipc	a0,0x1
ffffffffc0200c98:	58450513          	addi	a0,a0,1412 # ffffffffc0202218 <commands+0x650>
ffffffffc0200c9c:	f0cff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(total == 0);
ffffffffc0200ca0:	00002697          	auipc	a3,0x2
ffffffffc0200ca4:	84868693          	addi	a3,a3,-1976 # ffffffffc02024e8 <commands+0x920>
ffffffffc0200ca8:	00001617          	auipc	a2,0x1
ffffffffc0200cac:	55860613          	addi	a2,a2,1368 # ffffffffc0202200 <commands+0x638>
ffffffffc0200cb0:	14b00593          	li	a1,331
ffffffffc0200cb4:	00001517          	auipc	a0,0x1
ffffffffc0200cb8:	56450513          	addi	a0,a0,1380 # ffffffffc0202218 <commands+0x650>
ffffffffc0200cbc:	eecff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(total == nr_free_pages());
ffffffffc0200cc0:	00001697          	auipc	a3,0x1
ffffffffc0200cc4:	58868693          	addi	a3,a3,1416 # ffffffffc0202248 <commands+0x680>
ffffffffc0200cc8:	00001617          	auipc	a2,0x1
ffffffffc0200ccc:	53860613          	addi	a2,a2,1336 # ffffffffc0202200 <commands+0x638>
ffffffffc0200cd0:	10c00593          	li	a1,268
ffffffffc0200cd4:	00001517          	auipc	a0,0x1
ffffffffc0200cd8:	54450513          	addi	a0,a0,1348 # ffffffffc0202218 <commands+0x650>
ffffffffc0200cdc:	eccff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ce0:	00001697          	auipc	a3,0x1
ffffffffc0200ce4:	5a868693          	addi	a3,a3,1448 # ffffffffc0202288 <commands+0x6c0>
ffffffffc0200ce8:	00001617          	auipc	a2,0x1
ffffffffc0200cec:	51860613          	addi	a2,a2,1304 # ffffffffc0202200 <commands+0x638>
ffffffffc0200cf0:	0d200593          	li	a1,210
ffffffffc0200cf4:	00001517          	auipc	a0,0x1
ffffffffc0200cf8:	52450513          	addi	a0,a0,1316 # ffffffffc0202218 <commands+0x650>
ffffffffc0200cfc:	eacff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d00:	00001697          	auipc	a3,0x1
ffffffffc0200d04:	56868693          	addi	a3,a3,1384 # ffffffffc0202268 <commands+0x6a0>
ffffffffc0200d08:	00001617          	auipc	a2,0x1
ffffffffc0200d0c:	4f860613          	addi	a2,a2,1272 # ffffffffc0202200 <commands+0x638>
ffffffffc0200d10:	0d100593          	li	a1,209
ffffffffc0200d14:	00001517          	auipc	a0,0x1
ffffffffc0200d18:	50450513          	addi	a0,a0,1284 # ffffffffc0202218 <commands+0x650>
ffffffffc0200d1c:	e8cff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200d20:	00001697          	auipc	a3,0x1
ffffffffc0200d24:	67068693          	addi	a3,a3,1648 # ffffffffc0202390 <commands+0x7c8>
ffffffffc0200d28:	00001617          	auipc	a2,0x1
ffffffffc0200d2c:	4d860613          	addi	a2,a2,1240 # ffffffffc0202200 <commands+0x638>
ffffffffc0200d30:	0ee00593          	li	a1,238
ffffffffc0200d34:	00001517          	auipc	a0,0x1
ffffffffc0200d38:	4e450513          	addi	a0,a0,1252 # ffffffffc0202218 <commands+0x650>
ffffffffc0200d3c:	e6cff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d40:	00001697          	auipc	a3,0x1
ffffffffc0200d44:	56868693          	addi	a3,a3,1384 # ffffffffc02022a8 <commands+0x6e0>
ffffffffc0200d48:	00001617          	auipc	a2,0x1
ffffffffc0200d4c:	4b860613          	addi	a2,a2,1208 # ffffffffc0202200 <commands+0x638>
ffffffffc0200d50:	0ec00593          	li	a1,236
ffffffffc0200d54:	00001517          	auipc	a0,0x1
ffffffffc0200d58:	4c450513          	addi	a0,a0,1220 # ffffffffc0202218 <commands+0x650>
ffffffffc0200d5c:	e4cff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d60:	00001697          	auipc	a3,0x1
ffffffffc0200d64:	52868693          	addi	a3,a3,1320 # ffffffffc0202288 <commands+0x6c0>
ffffffffc0200d68:	00001617          	auipc	a2,0x1
ffffffffc0200d6c:	49860613          	addi	a2,a2,1176 # ffffffffc0202200 <commands+0x638>
ffffffffc0200d70:	0eb00593          	li	a1,235
ffffffffc0200d74:	00001517          	auipc	a0,0x1
ffffffffc0200d78:	4a450513          	addi	a0,a0,1188 # ffffffffc0202218 <commands+0x650>
ffffffffc0200d7c:	e2cff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d80:	00001697          	auipc	a3,0x1
ffffffffc0200d84:	4e868693          	addi	a3,a3,1256 # ffffffffc0202268 <commands+0x6a0>
ffffffffc0200d88:	00001617          	auipc	a2,0x1
ffffffffc0200d8c:	47860613          	addi	a2,a2,1144 # ffffffffc0202200 <commands+0x638>
ffffffffc0200d90:	0ea00593          	li	a1,234
ffffffffc0200d94:	00001517          	auipc	a0,0x1
ffffffffc0200d98:	48450513          	addi	a0,a0,1156 # ffffffffc0202218 <commands+0x650>
ffffffffc0200d9c:	e0cff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(nr_free == 3);
ffffffffc0200da0:	00001697          	auipc	a3,0x1
ffffffffc0200da4:	60868693          	addi	a3,a3,1544 # ffffffffc02023a8 <commands+0x7e0>
ffffffffc0200da8:	00001617          	auipc	a2,0x1
ffffffffc0200dac:	45860613          	addi	a2,a2,1112 # ffffffffc0202200 <commands+0x638>
ffffffffc0200db0:	0e800593          	li	a1,232
ffffffffc0200db4:	00001517          	auipc	a0,0x1
ffffffffc0200db8:	46450513          	addi	a0,a0,1124 # ffffffffc0202218 <commands+0x650>
ffffffffc0200dbc:	decff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200dc0:	00001697          	auipc	a3,0x1
ffffffffc0200dc4:	5d068693          	addi	a3,a3,1488 # ffffffffc0202390 <commands+0x7c8>
ffffffffc0200dc8:	00001617          	auipc	a2,0x1
ffffffffc0200dcc:	43860613          	addi	a2,a2,1080 # ffffffffc0202200 <commands+0x638>
ffffffffc0200dd0:	0e300593          	li	a1,227
ffffffffc0200dd4:	00001517          	auipc	a0,0x1
ffffffffc0200dd8:	44450513          	addi	a0,a0,1092 # ffffffffc0202218 <commands+0x650>
ffffffffc0200ddc:	dccff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200de0:	00001697          	auipc	a3,0x1
ffffffffc0200de4:	59068693          	addi	a3,a3,1424 # ffffffffc0202370 <commands+0x7a8>
ffffffffc0200de8:	00001617          	auipc	a2,0x1
ffffffffc0200dec:	41860613          	addi	a2,a2,1048 # ffffffffc0202200 <commands+0x638>
ffffffffc0200df0:	0da00593          	li	a1,218
ffffffffc0200df4:	00001517          	auipc	a0,0x1
ffffffffc0200df8:	42450513          	addi	a0,a0,1060 # ffffffffc0202218 <commands+0x650>
ffffffffc0200dfc:	dacff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200e00:	00001697          	auipc	a3,0x1
ffffffffc0200e04:	55068693          	addi	a3,a3,1360 # ffffffffc0202350 <commands+0x788>
ffffffffc0200e08:	00001617          	auipc	a2,0x1
ffffffffc0200e0c:	3f860613          	addi	a2,a2,1016 # ffffffffc0202200 <commands+0x638>
ffffffffc0200e10:	0d900593          	li	a1,217
ffffffffc0200e14:	00001517          	auipc	a0,0x1
ffffffffc0200e18:	40450513          	addi	a0,a0,1028 # ffffffffc0202218 <commands+0x650>
ffffffffc0200e1c:	d8cff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(count == 0);
ffffffffc0200e20:	00001697          	auipc	a3,0x1
ffffffffc0200e24:	6b868693          	addi	a3,a3,1720 # ffffffffc02024d8 <commands+0x910>
ffffffffc0200e28:	00001617          	auipc	a2,0x1
ffffffffc0200e2c:	3d860613          	addi	a2,a2,984 # ffffffffc0202200 <commands+0x638>
ffffffffc0200e30:	14a00593          	li	a1,330
ffffffffc0200e34:	00001517          	auipc	a0,0x1
ffffffffc0200e38:	3e450513          	addi	a0,a0,996 # ffffffffc0202218 <commands+0x650>
ffffffffc0200e3c:	d6cff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(nr_free == 0);
ffffffffc0200e40:	00001697          	auipc	a3,0x1
ffffffffc0200e44:	5b068693          	addi	a3,a3,1456 # ffffffffc02023f0 <commands+0x828>
ffffffffc0200e48:	00001617          	auipc	a2,0x1
ffffffffc0200e4c:	3b860613          	addi	a2,a2,952 # ffffffffc0202200 <commands+0x638>
ffffffffc0200e50:	13f00593          	li	a1,319
ffffffffc0200e54:	00001517          	auipc	a0,0x1
ffffffffc0200e58:	3c450513          	addi	a0,a0,964 # ffffffffc0202218 <commands+0x650>
ffffffffc0200e5c:	d4cff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200e60:	00001697          	auipc	a3,0x1
ffffffffc0200e64:	53068693          	addi	a3,a3,1328 # ffffffffc0202390 <commands+0x7c8>
ffffffffc0200e68:	00001617          	auipc	a2,0x1
ffffffffc0200e6c:	39860613          	addi	a2,a2,920 # ffffffffc0202200 <commands+0x638>
ffffffffc0200e70:	13900593          	li	a1,313
ffffffffc0200e74:	00001517          	auipc	a0,0x1
ffffffffc0200e78:	3a450513          	addi	a0,a0,932 # ffffffffc0202218 <commands+0x650>
ffffffffc0200e7c:	d2cff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200e80:	00001697          	auipc	a3,0x1
ffffffffc0200e84:	63868693          	addi	a3,a3,1592 # ffffffffc02024b8 <commands+0x8f0>
ffffffffc0200e88:	00001617          	auipc	a2,0x1
ffffffffc0200e8c:	37860613          	addi	a2,a2,888 # ffffffffc0202200 <commands+0x638>
ffffffffc0200e90:	13800593          	li	a1,312
ffffffffc0200e94:	00001517          	auipc	a0,0x1
ffffffffc0200e98:	38450513          	addi	a0,a0,900 # ffffffffc0202218 <commands+0x650>
ffffffffc0200e9c:	d0cff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(p0 + 4 == p1);
ffffffffc0200ea0:	00001697          	auipc	a3,0x1
ffffffffc0200ea4:	60868693          	addi	a3,a3,1544 # ffffffffc02024a8 <commands+0x8e0>
ffffffffc0200ea8:	00001617          	auipc	a2,0x1
ffffffffc0200eac:	35860613          	addi	a2,a2,856 # ffffffffc0202200 <commands+0x638>
ffffffffc0200eb0:	13000593          	li	a1,304
ffffffffc0200eb4:	00001517          	auipc	a0,0x1
ffffffffc0200eb8:	36450513          	addi	a0,a0,868 # ffffffffc0202218 <commands+0x650>
ffffffffc0200ebc:	cecff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(alloc_pages(2) != NULL);      // best fit feature
ffffffffc0200ec0:	00001697          	auipc	a3,0x1
ffffffffc0200ec4:	5d068693          	addi	a3,a3,1488 # ffffffffc0202490 <commands+0x8c8>
ffffffffc0200ec8:	00001617          	auipc	a2,0x1
ffffffffc0200ecc:	33860613          	addi	a2,a2,824 # ffffffffc0202200 <commands+0x638>
ffffffffc0200ed0:	12f00593          	li	a1,303
ffffffffc0200ed4:	00001517          	auipc	a0,0x1
ffffffffc0200ed8:	34450513          	addi	a0,a0,836 # ffffffffc0202218 <commands+0x650>
ffffffffc0200edc:	cccff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p1 = alloc_pages(1)) != NULL);
ffffffffc0200ee0:	00001697          	auipc	a3,0x1
ffffffffc0200ee4:	59068693          	addi	a3,a3,1424 # ffffffffc0202470 <commands+0x8a8>
ffffffffc0200ee8:	00001617          	auipc	a2,0x1
ffffffffc0200eec:	31860613          	addi	a2,a2,792 # ffffffffc0202200 <commands+0x638>
ffffffffc0200ef0:	12e00593          	li	a1,302
ffffffffc0200ef4:	00001517          	auipc	a0,0x1
ffffffffc0200ef8:	32450513          	addi	a0,a0,804 # ffffffffc0202218 <commands+0x650>
ffffffffc0200efc:	cacff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(PageProperty(p0 + 1) && p0[1].property == 2);
ffffffffc0200f00:	00001697          	auipc	a3,0x1
ffffffffc0200f04:	54068693          	addi	a3,a3,1344 # ffffffffc0202440 <commands+0x878>
ffffffffc0200f08:	00001617          	auipc	a2,0x1
ffffffffc0200f0c:	2f860613          	addi	a2,a2,760 # ffffffffc0202200 <commands+0x638>
ffffffffc0200f10:	12c00593          	li	a1,300
ffffffffc0200f14:	00001517          	auipc	a0,0x1
ffffffffc0200f18:	30450513          	addi	a0,a0,772 # ffffffffc0202218 <commands+0x650>
ffffffffc0200f1c:	c8cff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0200f20:	00001697          	auipc	a3,0x1
ffffffffc0200f24:	50868693          	addi	a3,a3,1288 # ffffffffc0202428 <commands+0x860>
ffffffffc0200f28:	00001617          	auipc	a2,0x1
ffffffffc0200f2c:	2d860613          	addi	a2,a2,728 # ffffffffc0202200 <commands+0x638>
ffffffffc0200f30:	12b00593          	li	a1,299
ffffffffc0200f34:	00001517          	auipc	a0,0x1
ffffffffc0200f38:	2e450513          	addi	a0,a0,740 # ffffffffc0202218 <commands+0x650>
ffffffffc0200f3c:	c6cff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200f40:	00001697          	auipc	a3,0x1
ffffffffc0200f44:	45068693          	addi	a3,a3,1104 # ffffffffc0202390 <commands+0x7c8>
ffffffffc0200f48:	00001617          	auipc	a2,0x1
ffffffffc0200f4c:	2b860613          	addi	a2,a2,696 # ffffffffc0202200 <commands+0x638>
ffffffffc0200f50:	11f00593          	li	a1,287
ffffffffc0200f54:	00001517          	auipc	a0,0x1
ffffffffc0200f58:	2c450513          	addi	a0,a0,708 # ffffffffc0202218 <commands+0x650>
ffffffffc0200f5c:	c4cff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(!PageProperty(p0));
ffffffffc0200f60:	00001697          	auipc	a3,0x1
ffffffffc0200f64:	4b068693          	addi	a3,a3,1200 # ffffffffc0202410 <commands+0x848>
ffffffffc0200f68:	00001617          	auipc	a2,0x1
ffffffffc0200f6c:	29860613          	addi	a2,a2,664 # ffffffffc0202200 <commands+0x638>
ffffffffc0200f70:	11600593          	li	a1,278
ffffffffc0200f74:	00001517          	auipc	a0,0x1
ffffffffc0200f78:	2a450513          	addi	a0,a0,676 # ffffffffc0202218 <commands+0x650>
ffffffffc0200f7c:	c2cff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(p0 != NULL);
ffffffffc0200f80:	00001697          	auipc	a3,0x1
ffffffffc0200f84:	48068693          	addi	a3,a3,1152 # ffffffffc0202400 <commands+0x838>
ffffffffc0200f88:	00001617          	auipc	a2,0x1
ffffffffc0200f8c:	27860613          	addi	a2,a2,632 # ffffffffc0202200 <commands+0x638>
ffffffffc0200f90:	11500593          	li	a1,277
ffffffffc0200f94:	00001517          	auipc	a0,0x1
ffffffffc0200f98:	28450513          	addi	a0,a0,644 # ffffffffc0202218 <commands+0x650>
ffffffffc0200f9c:	c0cff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(nr_free == 0);
ffffffffc0200fa0:	00001697          	auipc	a3,0x1
ffffffffc0200fa4:	45068693          	addi	a3,a3,1104 # ffffffffc02023f0 <commands+0x828>
ffffffffc0200fa8:	00001617          	auipc	a2,0x1
ffffffffc0200fac:	25860613          	addi	a2,a2,600 # ffffffffc0202200 <commands+0x638>
ffffffffc0200fb0:	0f700593          	li	a1,247
ffffffffc0200fb4:	00001517          	auipc	a0,0x1
ffffffffc0200fb8:	26450513          	addi	a0,a0,612 # ffffffffc0202218 <commands+0x650>
ffffffffc0200fbc:	becff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0200fc0:	00001697          	auipc	a3,0x1
ffffffffc0200fc4:	3d068693          	addi	a3,a3,976 # ffffffffc0202390 <commands+0x7c8>
ffffffffc0200fc8:	00001617          	auipc	a2,0x1
ffffffffc0200fcc:	23860613          	addi	a2,a2,568 # ffffffffc0202200 <commands+0x638>
ffffffffc0200fd0:	0f500593          	li	a1,245
ffffffffc0200fd4:	00001517          	auipc	a0,0x1
ffffffffc0200fd8:	24450513          	addi	a0,a0,580 # ffffffffc0202218 <commands+0x650>
ffffffffc0200fdc:	bccff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0200fe0:	00001697          	auipc	a3,0x1
ffffffffc0200fe4:	3f068693          	addi	a3,a3,1008 # ffffffffc02023d0 <commands+0x808>
ffffffffc0200fe8:	00001617          	auipc	a2,0x1
ffffffffc0200fec:	21860613          	addi	a2,a2,536 # ffffffffc0202200 <commands+0x638>
ffffffffc0200ff0:	0f400593          	li	a1,244
ffffffffc0200ff4:	00001517          	auipc	a0,0x1
ffffffffc0200ff8:	22450513          	addi	a0,a0,548 # ffffffffc0202218 <commands+0x650>
ffffffffc0200ffc:	bacff0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc0201000 <best_fit_free_pages>:
best_fit_free_pages(struct Page *base, size_t n) {
ffffffffc0201000:	1141                	addi	sp,sp,-16
ffffffffc0201002:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201004:	18058063          	beqz	a1,ffffffffc0201184 <best_fit_free_pages+0x184>
    for (; p != base + n; p ++) {
ffffffffc0201008:	00259693          	slli	a3,a1,0x2
ffffffffc020100c:	96ae                	add	a3,a3,a1
ffffffffc020100e:	068e                	slli	a3,a3,0x3
ffffffffc0201010:	96aa                	add	a3,a3,a0
ffffffffc0201012:	02d50d63          	beq	a0,a3,ffffffffc020104c <best_fit_free_pages+0x4c>
ffffffffc0201016:	651c                	ld	a5,8(a0)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201018:	8b85                	andi	a5,a5,1
ffffffffc020101a:	14079563          	bnez	a5,ffffffffc0201164 <best_fit_free_pages+0x164>
ffffffffc020101e:	651c                	ld	a5,8(a0)
ffffffffc0201020:	8385                	srli	a5,a5,0x1
ffffffffc0201022:	8b85                	andi	a5,a5,1
ffffffffc0201024:	14079063          	bnez	a5,ffffffffc0201164 <best_fit_free_pages+0x164>
ffffffffc0201028:	87aa                	mv	a5,a0
ffffffffc020102a:	a809                	j	ffffffffc020103c <best_fit_free_pages+0x3c>
ffffffffc020102c:	6798                	ld	a4,8(a5)
ffffffffc020102e:	8b05                	andi	a4,a4,1
ffffffffc0201030:	12071a63          	bnez	a4,ffffffffc0201164 <best_fit_free_pages+0x164>
ffffffffc0201034:	6798                	ld	a4,8(a5)
ffffffffc0201036:	8b09                	andi	a4,a4,2
ffffffffc0201038:	12071663          	bnez	a4,ffffffffc0201164 <best_fit_free_pages+0x164>
        p->flags = 0;
ffffffffc020103c:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0201040:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201044:	02878793          	addi	a5,a5,40
ffffffffc0201048:	fed792e3          	bne	a5,a3,ffffffffc020102c <best_fit_free_pages+0x2c>
    base->property = n;
ffffffffc020104c:	2581                	sext.w	a1,a1
ffffffffc020104e:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201050:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201054:	4789                	li	a5,2
ffffffffc0201056:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n; 
ffffffffc020105a:	00005697          	auipc	a3,0x5
ffffffffc020105e:	3de68693          	addi	a3,a3,990 # ffffffffc0206438 <free_area>
ffffffffc0201062:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc0201064:	669c                	ld	a5,8(a3)
ffffffffc0201066:	9db9                	addw	a1,a1,a4
ffffffffc0201068:	00005717          	auipc	a4,0x5
ffffffffc020106c:	3eb72023          	sw	a1,992(a4) # ffffffffc0206448 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201070:	08d78f63          	beq	a5,a3,ffffffffc020110e <best_fit_free_pages+0x10e>
            struct Page* page = le2page(le, page_link);
ffffffffc0201074:	fe878713          	addi	a4,a5,-24
ffffffffc0201078:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020107a:	4801                	li	a6,0
ffffffffc020107c:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201080:	00e56a63          	bltu	a0,a4,ffffffffc0201094 <best_fit_free_pages+0x94>
    return listelm->next;
ffffffffc0201084:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201086:	02d70563          	beq	a4,a3,ffffffffc02010b0 <best_fit_free_pages+0xb0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020108a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020108c:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201090:	fee57ae3          	bgeu	a0,a4,ffffffffc0201084 <best_fit_free_pages+0x84>
ffffffffc0201094:	00080663          	beqz	a6,ffffffffc02010a0 <best_fit_free_pages+0xa0>
ffffffffc0201098:	00005817          	auipc	a6,0x5
ffffffffc020109c:	3ab83023          	sd	a1,928(a6) # ffffffffc0206438 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02010a0:	638c                	ld	a1,0(a5)
    prev->next = next->prev = elm;
ffffffffc02010a2:	e390                	sd	a2,0(a5)
ffffffffc02010a4:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02010a6:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02010a8:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc02010aa:	02d59163          	bne	a1,a3,ffffffffc02010cc <best_fit_free_pages+0xcc>
ffffffffc02010ae:	a091                	j	ffffffffc02010f2 <best_fit_free_pages+0xf2>
    prev->next = next->prev = elm;
ffffffffc02010b0:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02010b2:	f114                	sd	a3,32(a0)
ffffffffc02010b4:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02010b6:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02010b8:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02010ba:	00d70563          	beq	a4,a3,ffffffffc02010c4 <best_fit_free_pages+0xc4>
ffffffffc02010be:	4805                	li	a6,1
ffffffffc02010c0:	87ba                	mv	a5,a4
ffffffffc02010c2:	b7e9                	j	ffffffffc020108c <best_fit_free_pages+0x8c>
ffffffffc02010c4:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02010c6:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc02010c8:	02d78163          	beq	a5,a3,ffffffffc02010ea <best_fit_free_pages+0xea>
    	if(p + p->property == base){
ffffffffc02010cc:	ff85a803          	lw	a6,-8(a1)
        p = le2page(le, page_link);
ffffffffc02010d0:	fe858613          	addi	a2,a1,-24
    	if(p + p->property == base){
ffffffffc02010d4:	02081713          	slli	a4,a6,0x20
ffffffffc02010d8:	9301                	srli	a4,a4,0x20
ffffffffc02010da:	00271793          	slli	a5,a4,0x2
ffffffffc02010de:	97ba                	add	a5,a5,a4
ffffffffc02010e0:	078e                	slli	a5,a5,0x3
ffffffffc02010e2:	97b2                	add	a5,a5,a2
ffffffffc02010e4:	02f50e63          	beq	a0,a5,ffffffffc0201120 <best_fit_free_pages+0x120>
ffffffffc02010e8:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc02010ea:	fe878713          	addi	a4,a5,-24
ffffffffc02010ee:	00d78d63          	beq	a5,a3,ffffffffc0201108 <best_fit_free_pages+0x108>
        if (base + base->property == p) {
ffffffffc02010f2:	490c                	lw	a1,16(a0)
ffffffffc02010f4:	02059613          	slli	a2,a1,0x20
ffffffffc02010f8:	9201                	srli	a2,a2,0x20
ffffffffc02010fa:	00261693          	slli	a3,a2,0x2
ffffffffc02010fe:	96b2                	add	a3,a3,a2
ffffffffc0201100:	068e                	slli	a3,a3,0x3
ffffffffc0201102:	96aa                	add	a3,a3,a0
ffffffffc0201104:	04d70063          	beq	a4,a3,ffffffffc0201144 <best_fit_free_pages+0x144>
}
ffffffffc0201108:	60a2                	ld	ra,8(sp)
ffffffffc020110a:	0141                	addi	sp,sp,16
ffffffffc020110c:	8082                	ret
ffffffffc020110e:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201110:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201114:	e398                	sd	a4,0(a5)
ffffffffc0201116:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201118:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020111a:	ed1c                	sd	a5,24(a0)
}
ffffffffc020111c:	0141                	addi	sp,sp,16
ffffffffc020111e:	8082                	ret
		p->property += base->property;
ffffffffc0201120:	491c                	lw	a5,16(a0)
ffffffffc0201122:	0107883b          	addw	a6,a5,a6
ffffffffc0201126:	ff05ac23          	sw	a6,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020112a:	57f5                	li	a5,-3
ffffffffc020112c:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201130:	01853803          	ld	a6,24(a0)
ffffffffc0201134:	7118                	ld	a4,32(a0)
		base = p;
ffffffffc0201136:	8532                	mv	a0,a2
    prev->next = next;
ffffffffc0201138:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc020113c:	659c                	ld	a5,8(a1)
ffffffffc020113e:	01073023          	sd	a6,0(a4)
ffffffffc0201142:	b765                	j	ffffffffc02010ea <best_fit_free_pages+0xea>
            base->property += p->property;
ffffffffc0201144:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201148:	ff078693          	addi	a3,a5,-16
ffffffffc020114c:	9db9                	addw	a1,a1,a4
ffffffffc020114e:	c90c                	sw	a1,16(a0)
ffffffffc0201150:	5775                	li	a4,-3
ffffffffc0201152:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201156:	6398                	ld	a4,0(a5)
ffffffffc0201158:	679c                	ld	a5,8(a5)
}
ffffffffc020115a:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020115c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020115e:	e398                	sd	a4,0(a5)
ffffffffc0201160:	0141                	addi	sp,sp,16
ffffffffc0201162:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201164:	00001697          	auipc	a3,0x1
ffffffffc0201168:	39468693          	addi	a3,a3,916 # ffffffffc02024f8 <commands+0x930>
ffffffffc020116c:	00001617          	auipc	a2,0x1
ffffffffc0201170:	09460613          	addi	a2,a2,148 # ffffffffc0202200 <commands+0x638>
ffffffffc0201174:	09100593          	li	a1,145
ffffffffc0201178:	00001517          	auipc	a0,0x1
ffffffffc020117c:	0a050513          	addi	a0,a0,160 # ffffffffc0202218 <commands+0x650>
ffffffffc0201180:	a28ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(n > 0);
ffffffffc0201184:	00001697          	auipc	a3,0x1
ffffffffc0201188:	07468693          	addi	a3,a3,116 # ffffffffc02021f8 <commands+0x630>
ffffffffc020118c:	00001617          	auipc	a2,0x1
ffffffffc0201190:	07460613          	addi	a2,a2,116 # ffffffffc0202200 <commands+0x638>
ffffffffc0201194:	08e00593          	li	a1,142
ffffffffc0201198:	00001517          	auipc	a0,0x1
ffffffffc020119c:	08050513          	addi	a0,a0,128 # ffffffffc0202218 <commands+0x650>
ffffffffc02011a0:	a08ff0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc02011a4 <best_fit_init_memmap>:
best_fit_init_memmap(struct Page *base, size_t n) {
ffffffffc02011a4:	1141                	addi	sp,sp,-16
ffffffffc02011a6:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02011a8:	c1fd                	beqz	a1,ffffffffc020128e <best_fit_init_memmap+0xea>
    for (; p != base + n; p ++) {
ffffffffc02011aa:	00259693          	slli	a3,a1,0x2
ffffffffc02011ae:	96ae                	add	a3,a3,a1
ffffffffc02011b0:	068e                	slli	a3,a3,0x3
ffffffffc02011b2:	96aa                	add	a3,a3,a0
ffffffffc02011b4:	02d50463          	beq	a0,a3,ffffffffc02011dc <best_fit_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02011b8:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc02011ba:	87aa                	mv	a5,a0
ffffffffc02011bc:	8b05                	andi	a4,a4,1
ffffffffc02011be:	e709                	bnez	a4,ffffffffc02011c8 <best_fit_init_memmap+0x24>
ffffffffc02011c0:	a07d                	j	ffffffffc020126e <best_fit_init_memmap+0xca>
ffffffffc02011c2:	6798                	ld	a4,8(a5)
ffffffffc02011c4:	8b05                	andi	a4,a4,1
ffffffffc02011c6:	c745                	beqz	a4,ffffffffc020126e <best_fit_init_memmap+0xca>
	p->flags = p->property = 0;
ffffffffc02011c8:	0007a823          	sw	zero,16(a5)
ffffffffc02011cc:	0007b423          	sd	zero,8(a5)
ffffffffc02011d0:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02011d4:	02878793          	addi	a5,a5,40
ffffffffc02011d8:	fed795e3          	bne	a5,a3,ffffffffc02011c2 <best_fit_init_memmap+0x1e>
    base->property = n;
ffffffffc02011dc:	2581                	sext.w	a1,a1
ffffffffc02011de:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02011e0:	4789                	li	a5,2
ffffffffc02011e2:	00850713          	addi	a4,a0,8
ffffffffc02011e6:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02011ea:	00005697          	auipc	a3,0x5
ffffffffc02011ee:	24e68693          	addi	a3,a3,590 # ffffffffc0206438 <free_area>
ffffffffc02011f2:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02011f4:	669c                	ld	a5,8(a3)
ffffffffc02011f6:	9db9                	addw	a1,a1,a4
ffffffffc02011f8:	00005717          	auipc	a4,0x5
ffffffffc02011fc:	24b72823          	sw	a1,592(a4) # ffffffffc0206448 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201200:	04d78a63          	beq	a5,a3,ffffffffc0201254 <best_fit_init_memmap+0xb0>
            struct Page* page = le2page(le, page_link);
ffffffffc0201204:	fe878713          	addi	a4,a5,-24
ffffffffc0201208:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc020120a:	4801                	li	a6,0
ffffffffc020120c:	01850613          	addi	a2,a0,24
	    if(base<page){
ffffffffc0201210:	00e56a63          	bltu	a0,a4,ffffffffc0201224 <best_fit_init_memmap+0x80>
    return listelm->next;
ffffffffc0201214:	6798                	ld	a4,8(a5)
	    } else if (list_next(le) == &free_list){
ffffffffc0201216:	02d70563          	beq	a4,a3,ffffffffc0201240 <best_fit_init_memmap+0x9c>
        while ((le = list_next(le)) != &free_list) {
ffffffffc020121a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020121c:	fe878713          	addi	a4,a5,-24
	    if(base<page){
ffffffffc0201220:	fee57ae3          	bgeu	a0,a4,ffffffffc0201214 <best_fit_init_memmap+0x70>
ffffffffc0201224:	00080663          	beqz	a6,ffffffffc0201230 <best_fit_init_memmap+0x8c>
ffffffffc0201228:	00005717          	auipc	a4,0x5
ffffffffc020122c:	20b73823          	sd	a1,528(a4) # ffffffffc0206438 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201230:	6398                	ld	a4,0(a5)
}
ffffffffc0201232:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201234:	e390                	sd	a2,0(a5)
ffffffffc0201236:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201238:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020123a:	ed18                	sd	a4,24(a0)
ffffffffc020123c:	0141                	addi	sp,sp,16
ffffffffc020123e:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201240:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201242:	f114                	sd	a3,32(a0)
ffffffffc0201244:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201246:	ed1c                	sd	a5,24(a0)
	    	list_add(le,&(base->page_link));
ffffffffc0201248:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc020124a:	00d70e63          	beq	a4,a3,ffffffffc0201266 <best_fit_init_memmap+0xc2>
ffffffffc020124e:	4805                	li	a6,1
ffffffffc0201250:	87ba                	mv	a5,a4
ffffffffc0201252:	b7e9                	j	ffffffffc020121c <best_fit_init_memmap+0x78>
}
ffffffffc0201254:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201256:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc020125a:	e398                	sd	a4,0(a5)
ffffffffc020125c:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020125e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201260:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201262:	0141                	addi	sp,sp,16
ffffffffc0201264:	8082                	ret
ffffffffc0201266:	60a2                	ld	ra,8(sp)
ffffffffc0201268:	e290                	sd	a2,0(a3)
ffffffffc020126a:	0141                	addi	sp,sp,16
ffffffffc020126c:	8082                	ret
        assert(PageReserved(p));
ffffffffc020126e:	00001697          	auipc	a3,0x1
ffffffffc0201272:	2b268693          	addi	a3,a3,690 # ffffffffc0202520 <commands+0x958>
ffffffffc0201276:	00001617          	auipc	a2,0x1
ffffffffc020127a:	f8a60613          	addi	a2,a2,-118 # ffffffffc0202200 <commands+0x638>
ffffffffc020127e:	04a00593          	li	a1,74
ffffffffc0201282:	00001517          	auipc	a0,0x1
ffffffffc0201286:	f9650513          	addi	a0,a0,-106 # ffffffffc0202218 <commands+0x650>
ffffffffc020128a:	91eff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(n > 0);
ffffffffc020128e:	00001697          	auipc	a3,0x1
ffffffffc0201292:	f6a68693          	addi	a3,a3,-150 # ffffffffc02021f8 <commands+0x630>
ffffffffc0201296:	00001617          	auipc	a2,0x1
ffffffffc020129a:	f6a60613          	addi	a2,a2,-150 # ffffffffc0202200 <commands+0x638>
ffffffffc020129e:	04700593          	li	a1,71
ffffffffc02012a2:	00001517          	auipc	a0,0x1
ffffffffc02012a6:	f7650513          	addi	a0,a0,-138 # ffffffffc0202218 <commands+0x650>
ffffffffc02012aa:	8feff0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc02012ae <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02012ae:	100027f3          	csrr	a5,sstatus
ffffffffc02012b2:	8b89                	andi	a5,a5,2
ffffffffc02012b4:	eb89                	bnez	a5,ffffffffc02012c6 <alloc_pages+0x18>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02012b6:	00005797          	auipc	a5,0x5
ffffffffc02012ba:	1a278793          	addi	a5,a5,418 # ffffffffc0206458 <pmm_manager>
ffffffffc02012be:	639c                	ld	a5,0(a5)
ffffffffc02012c0:	0187b303          	ld	t1,24(a5)
ffffffffc02012c4:	8302                	jr	t1
struct Page *alloc_pages(size_t n) {
ffffffffc02012c6:	1141                	addi	sp,sp,-16
ffffffffc02012c8:	e406                	sd	ra,8(sp)
ffffffffc02012ca:	e022                	sd	s0,0(sp)
ffffffffc02012cc:	842a                	mv	s0,a0
        intr_disable();
ffffffffc02012ce:	990ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02012d2:	00005797          	auipc	a5,0x5
ffffffffc02012d6:	18678793          	addi	a5,a5,390 # ffffffffc0206458 <pmm_manager>
ffffffffc02012da:	639c                	ld	a5,0(a5)
ffffffffc02012dc:	8522                	mv	a0,s0
ffffffffc02012de:	6f9c                	ld	a5,24(a5)
ffffffffc02012e0:	9782                	jalr	a5
ffffffffc02012e2:	842a                	mv	s0,a0
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc02012e4:	974ff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc02012e8:	8522                	mv	a0,s0
ffffffffc02012ea:	60a2                	ld	ra,8(sp)
ffffffffc02012ec:	6402                	ld	s0,0(sp)
ffffffffc02012ee:	0141                	addi	sp,sp,16
ffffffffc02012f0:	8082                	ret

ffffffffc02012f2 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02012f2:	100027f3          	csrr	a5,sstatus
ffffffffc02012f6:	8b89                	andi	a5,a5,2
ffffffffc02012f8:	eb89                	bnez	a5,ffffffffc020130a <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc02012fa:	00005797          	auipc	a5,0x5
ffffffffc02012fe:	15e78793          	addi	a5,a5,350 # ffffffffc0206458 <pmm_manager>
ffffffffc0201302:	639c                	ld	a5,0(a5)
ffffffffc0201304:	0207b303          	ld	t1,32(a5)
ffffffffc0201308:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc020130a:	1101                	addi	sp,sp,-32
ffffffffc020130c:	ec06                	sd	ra,24(sp)
ffffffffc020130e:	e822                	sd	s0,16(sp)
ffffffffc0201310:	e426                	sd	s1,8(sp)
ffffffffc0201312:	842a                	mv	s0,a0
ffffffffc0201314:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201316:	948ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020131a:	00005797          	auipc	a5,0x5
ffffffffc020131e:	13e78793          	addi	a5,a5,318 # ffffffffc0206458 <pmm_manager>
ffffffffc0201322:	639c                	ld	a5,0(a5)
ffffffffc0201324:	85a6                	mv	a1,s1
ffffffffc0201326:	8522                	mv	a0,s0
ffffffffc0201328:	739c                	ld	a5,32(a5)
ffffffffc020132a:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc020132c:	6442                	ld	s0,16(sp)
ffffffffc020132e:	60e2                	ld	ra,24(sp)
ffffffffc0201330:	64a2                	ld	s1,8(sp)
ffffffffc0201332:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201334:	924ff06f          	j	ffffffffc0200458 <intr_enable>

ffffffffc0201338 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201338:	100027f3          	csrr	a5,sstatus
ffffffffc020133c:	8b89                	andi	a5,a5,2
ffffffffc020133e:	eb89                	bnez	a5,ffffffffc0201350 <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201340:	00005797          	auipc	a5,0x5
ffffffffc0201344:	11878793          	addi	a5,a5,280 # ffffffffc0206458 <pmm_manager>
ffffffffc0201348:	639c                	ld	a5,0(a5)
ffffffffc020134a:	0287b303          	ld	t1,40(a5)
ffffffffc020134e:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201350:	1141                	addi	sp,sp,-16
ffffffffc0201352:	e406                	sd	ra,8(sp)
ffffffffc0201354:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201356:	908ff0ef          	jal	ra,ffffffffc020045e <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc020135a:	00005797          	auipc	a5,0x5
ffffffffc020135e:	0fe78793          	addi	a5,a5,254 # ffffffffc0206458 <pmm_manager>
ffffffffc0201362:	639c                	ld	a5,0(a5)
ffffffffc0201364:	779c                	ld	a5,40(a5)
ffffffffc0201366:	9782                	jalr	a5
ffffffffc0201368:	842a                	mv	s0,a0
        intr_enable();
ffffffffc020136a:	8eeff0ef          	jal	ra,ffffffffc0200458 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc020136e:	8522                	mv	a0,s0
ffffffffc0201370:	60a2                	ld	ra,8(sp)
ffffffffc0201372:	6402                	ld	s0,0(sp)
ffffffffc0201374:	0141                	addi	sp,sp,16
ffffffffc0201376:	8082                	ret

ffffffffc0201378 <pmm_init>:
    pmm_manager = &best_fit_pmm_manager;
ffffffffc0201378:	00001797          	auipc	a5,0x1
ffffffffc020137c:	1b878793          	addi	a5,a5,440 # ffffffffc0202530 <best_fit_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201380:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0201382:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201384:	00001517          	auipc	a0,0x1
ffffffffc0201388:	1fc50513          	addi	a0,a0,508 # ffffffffc0202580 <best_fit_pmm_manager+0x50>
void pmm_init(void) {
ffffffffc020138c:	ec06                	sd	ra,24(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc020138e:	00005717          	auipc	a4,0x5
ffffffffc0201392:	0cf73523          	sd	a5,202(a4) # ffffffffc0206458 <pmm_manager>
void pmm_init(void) {
ffffffffc0201396:	e822                	sd	s0,16(sp)
ffffffffc0201398:	e426                	sd	s1,8(sp)
    pmm_manager = &best_fit_pmm_manager;
ffffffffc020139a:	00005417          	auipc	s0,0x5
ffffffffc020139e:	0be40413          	addi	s0,s0,190 # ffffffffc0206458 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02013a2:	d15fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc02013a6:	601c                	ld	a5,0(s0)
ffffffffc02013a8:	679c                	ld	a5,8(a5)
ffffffffc02013aa:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02013ac:	57f5                	li	a5,-3
ffffffffc02013ae:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc02013b0:	00001517          	auipc	a0,0x1
ffffffffc02013b4:	1e850513          	addi	a0,a0,488 # ffffffffc0202598 <best_fit_pmm_manager+0x68>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02013b8:	00005717          	auipc	a4,0x5
ffffffffc02013bc:	0af73423          	sd	a5,168(a4) # ffffffffc0206460 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc02013c0:	cf7fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02013c4:	46c5                	li	a3,17
ffffffffc02013c6:	06ee                	slli	a3,a3,0x1b
ffffffffc02013c8:	40100613          	li	a2,1025
ffffffffc02013cc:	16fd                	addi	a3,a3,-1
ffffffffc02013ce:	0656                	slli	a2,a2,0x15
ffffffffc02013d0:	07e005b7          	lui	a1,0x7e00
ffffffffc02013d4:	00001517          	auipc	a0,0x1
ffffffffc02013d8:	1dc50513          	addi	a0,a0,476 # ffffffffc02025b0 <best_fit_pmm_manager+0x80>
ffffffffc02013dc:	cdbfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02013e0:	777d                	lui	a4,0xfffff
ffffffffc02013e2:	00006797          	auipc	a5,0x6
ffffffffc02013e6:	08d78793          	addi	a5,a5,141 # ffffffffc020746f <end+0xfff>
ffffffffc02013ea:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc02013ec:	00088737          	lui	a4,0x88
ffffffffc02013f0:	00005697          	auipc	a3,0x5
ffffffffc02013f4:	02e6b423          	sd	a4,40(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02013f8:	4601                	li	a2,0
ffffffffc02013fa:	00005717          	auipc	a4,0x5
ffffffffc02013fe:	06f73723          	sd	a5,110(a4) # ffffffffc0206468 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201402:	4681                	li	a3,0
ffffffffc0201404:	00005897          	auipc	a7,0x5
ffffffffc0201408:	01488893          	addi	a7,a7,20 # ffffffffc0206418 <npage>
ffffffffc020140c:	00005597          	auipc	a1,0x5
ffffffffc0201410:	05c58593          	addi	a1,a1,92 # ffffffffc0206468 <pages>
ffffffffc0201414:	4805                	li	a6,1
ffffffffc0201416:	fff80537          	lui	a0,0xfff80
ffffffffc020141a:	a011                	j	ffffffffc020141e <pmm_init+0xa6>
ffffffffc020141c:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc020141e:	97b2                	add	a5,a5,a2
ffffffffc0201420:	07a1                	addi	a5,a5,8
ffffffffc0201422:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201426:	0008b703          	ld	a4,0(a7)
ffffffffc020142a:	0685                	addi	a3,a3,1
ffffffffc020142c:	02860613          	addi	a2,a2,40
ffffffffc0201430:	00a707b3          	add	a5,a4,a0
ffffffffc0201434:	fef6e4e3          	bltu	a3,a5,ffffffffc020141c <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201438:	6190                	ld	a2,0(a1)
ffffffffc020143a:	00271793          	slli	a5,a4,0x2
ffffffffc020143e:	97ba                	add	a5,a5,a4
ffffffffc0201440:	fec006b7          	lui	a3,0xfec00
ffffffffc0201444:	078e                	slli	a5,a5,0x3
ffffffffc0201446:	96b2                	add	a3,a3,a2
ffffffffc0201448:	96be                	add	a3,a3,a5
ffffffffc020144a:	c02007b7          	lui	a5,0xc0200
ffffffffc020144e:	08f6e863          	bltu	a3,a5,ffffffffc02014de <pmm_init+0x166>
ffffffffc0201452:	00005497          	auipc	s1,0x5
ffffffffc0201456:	00e48493          	addi	s1,s1,14 # ffffffffc0206460 <va_pa_offset>
ffffffffc020145a:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc020145c:	45c5                	li	a1,17
ffffffffc020145e:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201460:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc0201462:	04b6e963          	bltu	a3,a1,ffffffffc02014b4 <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201466:	601c                	ld	a5,0(s0)
ffffffffc0201468:	7b9c                	ld	a5,48(a5)
ffffffffc020146a:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020146c:	00001517          	auipc	a0,0x1
ffffffffc0201470:	1dc50513          	addi	a0,a0,476 # ffffffffc0202648 <best_fit_pmm_manager+0x118>
ffffffffc0201474:	c43fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201478:	00004697          	auipc	a3,0x4
ffffffffc020147c:	b8868693          	addi	a3,a3,-1144 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0201480:	00005797          	auipc	a5,0x5
ffffffffc0201484:	fad7b023          	sd	a3,-96(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201488:	c02007b7          	lui	a5,0xc0200
ffffffffc020148c:	06f6e563          	bltu	a3,a5,ffffffffc02014f6 <pmm_init+0x17e>
ffffffffc0201490:	609c                	ld	a5,0(s1)
}
ffffffffc0201492:	6442                	ld	s0,16(sp)
ffffffffc0201494:	60e2                	ld	ra,24(sp)
ffffffffc0201496:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0201498:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc020149a:	8e9d                	sub	a3,a3,a5
ffffffffc020149c:	00005797          	auipc	a5,0x5
ffffffffc02014a0:	fad7ba23          	sd	a3,-76(a5) # ffffffffc0206450 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02014a4:	00001517          	auipc	a0,0x1
ffffffffc02014a8:	1c450513          	addi	a0,a0,452 # ffffffffc0202668 <best_fit_pmm_manager+0x138>
ffffffffc02014ac:	8636                	mv	a2,a3
}
ffffffffc02014ae:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02014b0:	c07fe06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02014b4:	6785                	lui	a5,0x1
ffffffffc02014b6:	17fd                	addi	a5,a5,-1
ffffffffc02014b8:	96be                	add	a3,a3,a5
ffffffffc02014ba:	77fd                	lui	a5,0xfffff
ffffffffc02014bc:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02014be:	00c6d793          	srli	a5,a3,0xc
ffffffffc02014c2:	04e7f663          	bgeu	a5,a4,ffffffffc020150e <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc02014c6:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02014c8:	97aa                	add	a5,a5,a0
ffffffffc02014ca:	00279513          	slli	a0,a5,0x2
ffffffffc02014ce:	953e                	add	a0,a0,a5
ffffffffc02014d0:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02014d2:	8d95                	sub	a1,a1,a3
ffffffffc02014d4:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02014d6:	81b1                	srli	a1,a1,0xc
ffffffffc02014d8:	9532                	add	a0,a0,a2
ffffffffc02014da:	9782                	jalr	a5
ffffffffc02014dc:	b769                	j	ffffffffc0201466 <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02014de:	00001617          	auipc	a2,0x1
ffffffffc02014e2:	10260613          	addi	a2,a2,258 # ffffffffc02025e0 <best_fit_pmm_manager+0xb0>
ffffffffc02014e6:	06e00593          	li	a1,110
ffffffffc02014ea:	00001517          	auipc	a0,0x1
ffffffffc02014ee:	11e50513          	addi	a0,a0,286 # ffffffffc0202608 <best_fit_pmm_manager+0xd8>
ffffffffc02014f2:	eb7fe0ef          	jal	ra,ffffffffc02003a8 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02014f6:	00001617          	auipc	a2,0x1
ffffffffc02014fa:	0ea60613          	addi	a2,a2,234 # ffffffffc02025e0 <best_fit_pmm_manager+0xb0>
ffffffffc02014fe:	08900593          	li	a1,137
ffffffffc0201502:	00001517          	auipc	a0,0x1
ffffffffc0201506:	10650513          	addi	a0,a0,262 # ffffffffc0202608 <best_fit_pmm_manager+0xd8>
ffffffffc020150a:	e9ffe0ef          	jal	ra,ffffffffc02003a8 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020150e:	00001617          	auipc	a2,0x1
ffffffffc0201512:	10a60613          	addi	a2,a2,266 # ffffffffc0202618 <best_fit_pmm_manager+0xe8>
ffffffffc0201516:	06b00593          	li	a1,107
ffffffffc020151a:	00001517          	auipc	a0,0x1
ffffffffc020151e:	11e50513          	addi	a0,a0,286 # ffffffffc0202638 <best_fit_pmm_manager+0x108>
ffffffffc0201522:	e87fe0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc0201526 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201526:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020152a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020152c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201530:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201532:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201536:	f022                	sd	s0,32(sp)
ffffffffc0201538:	ec26                	sd	s1,24(sp)
ffffffffc020153a:	e84a                	sd	s2,16(sp)
ffffffffc020153c:	f406                	sd	ra,40(sp)
ffffffffc020153e:	e44e                	sd	s3,8(sp)
ffffffffc0201540:	84aa                	mv	s1,a0
ffffffffc0201542:	892e                	mv	s2,a1
ffffffffc0201544:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0201548:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc020154a:	03067e63          	bgeu	a2,a6,ffffffffc0201586 <printnum+0x60>
ffffffffc020154e:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201550:	00805763          	blez	s0,ffffffffc020155e <printnum+0x38>
ffffffffc0201554:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201556:	85ca                	mv	a1,s2
ffffffffc0201558:	854e                	mv	a0,s3
ffffffffc020155a:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020155c:	fc65                	bnez	s0,ffffffffc0201554 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020155e:	1a02                	slli	s4,s4,0x20
ffffffffc0201560:	020a5a13          	srli	s4,s4,0x20
ffffffffc0201564:	00001797          	auipc	a5,0x1
ffffffffc0201568:	2d478793          	addi	a5,a5,724 # ffffffffc0202838 <error_string+0x38>
ffffffffc020156c:	9a3e                	add	s4,s4,a5
}
ffffffffc020156e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201570:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0201574:	70a2                	ld	ra,40(sp)
ffffffffc0201576:	69a2                	ld	s3,8(sp)
ffffffffc0201578:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020157a:	85ca                	mv	a1,s2
ffffffffc020157c:	8326                	mv	t1,s1
}
ffffffffc020157e:	6942                	ld	s2,16(sp)
ffffffffc0201580:	64e2                	ld	s1,24(sp)
ffffffffc0201582:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201584:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201586:	03065633          	divu	a2,a2,a6
ffffffffc020158a:	8722                	mv	a4,s0
ffffffffc020158c:	f9bff0ef          	jal	ra,ffffffffc0201526 <printnum>
ffffffffc0201590:	b7f9                	j	ffffffffc020155e <printnum+0x38>

ffffffffc0201592 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201592:	7119                	addi	sp,sp,-128
ffffffffc0201594:	f4a6                	sd	s1,104(sp)
ffffffffc0201596:	f0ca                	sd	s2,96(sp)
ffffffffc0201598:	e8d2                	sd	s4,80(sp)
ffffffffc020159a:	e4d6                	sd	s5,72(sp)
ffffffffc020159c:	e0da                	sd	s6,64(sp)
ffffffffc020159e:	fc5e                	sd	s7,56(sp)
ffffffffc02015a0:	f862                	sd	s8,48(sp)
ffffffffc02015a2:	f06a                	sd	s10,32(sp)
ffffffffc02015a4:	fc86                	sd	ra,120(sp)
ffffffffc02015a6:	f8a2                	sd	s0,112(sp)
ffffffffc02015a8:	ecce                	sd	s3,88(sp)
ffffffffc02015aa:	f466                	sd	s9,40(sp)
ffffffffc02015ac:	ec6e                	sd	s11,24(sp)
ffffffffc02015ae:	892a                	mv	s2,a0
ffffffffc02015b0:	84ae                	mv	s1,a1
ffffffffc02015b2:	8d32                	mv	s10,a2
ffffffffc02015b4:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02015b6:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015b8:	00001a17          	auipc	s4,0x1
ffffffffc02015bc:	0f0a0a13          	addi	s4,s4,240 # ffffffffc02026a8 <best_fit_pmm_manager+0x178>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02015c0:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02015c4:	00001c17          	auipc	s8,0x1
ffffffffc02015c8:	23cc0c13          	addi	s8,s8,572 # ffffffffc0202800 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02015cc:	000d4503          	lbu	a0,0(s10)
ffffffffc02015d0:	02500793          	li	a5,37
ffffffffc02015d4:	001d0413          	addi	s0,s10,1
ffffffffc02015d8:	00f50e63          	beq	a0,a5,ffffffffc02015f4 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02015dc:	c521                	beqz	a0,ffffffffc0201624 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02015de:	02500993          	li	s3,37
ffffffffc02015e2:	a011                	j	ffffffffc02015e6 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc02015e4:	c121                	beqz	a0,ffffffffc0201624 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc02015e6:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02015e8:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02015ea:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02015ec:	fff44503          	lbu	a0,-1(s0)
ffffffffc02015f0:	ff351ae3          	bne	a0,s3,ffffffffc02015e4 <vprintfmt+0x52>
ffffffffc02015f4:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02015f8:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02015fc:	4981                	li	s3,0
ffffffffc02015fe:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0201600:	5cfd                	li	s9,-1
ffffffffc0201602:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201604:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0201608:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020160a:	fdd6069b          	addiw	a3,a2,-35
ffffffffc020160e:	0ff6f693          	andi	a3,a3,255
ffffffffc0201612:	00140d13          	addi	s10,s0,1
ffffffffc0201616:	1ed5ef63          	bltu	a1,a3,ffffffffc0201814 <vprintfmt+0x282>
ffffffffc020161a:	068a                	slli	a3,a3,0x2
ffffffffc020161c:	96d2                	add	a3,a3,s4
ffffffffc020161e:	4294                	lw	a3,0(a3)
ffffffffc0201620:	96d2                	add	a3,a3,s4
ffffffffc0201622:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201624:	70e6                	ld	ra,120(sp)
ffffffffc0201626:	7446                	ld	s0,112(sp)
ffffffffc0201628:	74a6                	ld	s1,104(sp)
ffffffffc020162a:	7906                	ld	s2,96(sp)
ffffffffc020162c:	69e6                	ld	s3,88(sp)
ffffffffc020162e:	6a46                	ld	s4,80(sp)
ffffffffc0201630:	6aa6                	ld	s5,72(sp)
ffffffffc0201632:	6b06                	ld	s6,64(sp)
ffffffffc0201634:	7be2                	ld	s7,56(sp)
ffffffffc0201636:	7c42                	ld	s8,48(sp)
ffffffffc0201638:	7ca2                	ld	s9,40(sp)
ffffffffc020163a:	7d02                	ld	s10,32(sp)
ffffffffc020163c:	6de2                	ld	s11,24(sp)
ffffffffc020163e:	6109                	addi	sp,sp,128
ffffffffc0201640:	8082                	ret
            padc = '-';
ffffffffc0201642:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201644:	00144603          	lbu	a2,1(s0)
ffffffffc0201648:	846a                	mv	s0,s10
ffffffffc020164a:	b7c1                	j	ffffffffc020160a <vprintfmt+0x78>
            precision = va_arg(ap, int);
ffffffffc020164c:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0201650:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0201654:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201656:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0201658:	fa0dd9e3          	bgez	s11,ffffffffc020160a <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc020165c:	8de6                	mv	s11,s9
ffffffffc020165e:	5cfd                	li	s9,-1
ffffffffc0201660:	b76d                	j	ffffffffc020160a <vprintfmt+0x78>
            if (width < 0)
ffffffffc0201662:	fffdc693          	not	a3,s11
ffffffffc0201666:	96fd                	srai	a3,a3,0x3f
ffffffffc0201668:	00ddfdb3          	and	s11,s11,a3
ffffffffc020166c:	00144603          	lbu	a2,1(s0)
ffffffffc0201670:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201672:	846a                	mv	s0,s10
ffffffffc0201674:	bf59                	j	ffffffffc020160a <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0201676:	4705                	li	a4,1
ffffffffc0201678:	008a8593          	addi	a1,s5,8
ffffffffc020167c:	01074463          	blt	a4,a6,ffffffffc0201684 <vprintfmt+0xf2>
    else if (lflag) {
ffffffffc0201680:	22080863          	beqz	a6,ffffffffc02018b0 <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
ffffffffc0201684:	000ab603          	ld	a2,0(s5)
ffffffffc0201688:	46c1                	li	a3,16
ffffffffc020168a:	8aae                	mv	s5,a1
ffffffffc020168c:	a291                	j	ffffffffc02017d0 <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
ffffffffc020168e:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0201692:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201696:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201698:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020169c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02016a0:	fad56ce3          	bltu	a0,a3,ffffffffc0201658 <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
ffffffffc02016a4:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02016a6:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc02016aa:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02016ae:	0196873b          	addw	a4,a3,s9
ffffffffc02016b2:	0017171b          	slliw	a4,a4,0x1
ffffffffc02016b6:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc02016ba:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc02016be:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02016c2:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02016c6:	fcd57fe3          	bgeu	a0,a3,ffffffffc02016a4 <vprintfmt+0x112>
ffffffffc02016ca:	b779                	j	ffffffffc0201658 <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
ffffffffc02016cc:	000aa503          	lw	a0,0(s5)
ffffffffc02016d0:	85a6                	mv	a1,s1
ffffffffc02016d2:	0aa1                	addi	s5,s5,8
ffffffffc02016d4:	9902                	jalr	s2
            break;
ffffffffc02016d6:	bddd                	j	ffffffffc02015cc <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02016d8:	4705                	li	a4,1
ffffffffc02016da:	008a8993          	addi	s3,s5,8
ffffffffc02016de:	01074463          	blt	a4,a6,ffffffffc02016e6 <vprintfmt+0x154>
    else if (lflag) {
ffffffffc02016e2:	1c080463          	beqz	a6,ffffffffc02018aa <vprintfmt+0x318>
        return va_arg(*ap, long);
ffffffffc02016e6:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02016ea:	1c044a63          	bltz	s0,ffffffffc02018be <vprintfmt+0x32c>
            num = getint(&ap, lflag);
ffffffffc02016ee:	8622                	mv	a2,s0
ffffffffc02016f0:	8ace                	mv	s5,s3
ffffffffc02016f2:	46a9                	li	a3,10
ffffffffc02016f4:	a8f1                	j	ffffffffc02017d0 <vprintfmt+0x23e>
            err = va_arg(ap, int);
ffffffffc02016f6:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02016fa:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02016fc:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02016fe:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0201702:	8fb5                	xor	a5,a5,a3
ffffffffc0201704:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201708:	12d74963          	blt	a4,a3,ffffffffc020183a <vprintfmt+0x2a8>
ffffffffc020170c:	00369793          	slli	a5,a3,0x3
ffffffffc0201710:	97e2                	add	a5,a5,s8
ffffffffc0201712:	639c                	ld	a5,0(a5)
ffffffffc0201714:	12078363          	beqz	a5,ffffffffc020183a <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201718:	86be                	mv	a3,a5
ffffffffc020171a:	00001617          	auipc	a2,0x1
ffffffffc020171e:	1ce60613          	addi	a2,a2,462 # ffffffffc02028e8 <error_string+0xe8>
ffffffffc0201722:	85a6                	mv	a1,s1
ffffffffc0201724:	854a                	mv	a0,s2
ffffffffc0201726:	1cc000ef          	jal	ra,ffffffffc02018f2 <printfmt>
ffffffffc020172a:	b54d                	j	ffffffffc02015cc <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020172c:	000ab603          	ld	a2,0(s5)
ffffffffc0201730:	0aa1                	addi	s5,s5,8
ffffffffc0201732:	1a060163          	beqz	a2,ffffffffc02018d4 <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
ffffffffc0201736:	00160413          	addi	s0,a2,1
ffffffffc020173a:	15b05763          	blez	s11,ffffffffc0201888 <vprintfmt+0x2f6>
ffffffffc020173e:	02d00593          	li	a1,45
ffffffffc0201742:	10b79d63          	bne	a5,a1,ffffffffc020185c <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201746:	00064783          	lbu	a5,0(a2)
ffffffffc020174a:	0007851b          	sext.w	a0,a5
ffffffffc020174e:	c905                	beqz	a0,ffffffffc020177e <vprintfmt+0x1ec>
ffffffffc0201750:	000cc563          	bltz	s9,ffffffffc020175a <vprintfmt+0x1c8>
ffffffffc0201754:	3cfd                	addiw	s9,s9,-1
ffffffffc0201756:	036c8263          	beq	s9,s6,ffffffffc020177a <vprintfmt+0x1e8>
                    putch('?', putdat);
ffffffffc020175a:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020175c:	14098f63          	beqz	s3,ffffffffc02018ba <vprintfmt+0x328>
ffffffffc0201760:	3781                	addiw	a5,a5,-32
ffffffffc0201762:	14fbfc63          	bgeu	s7,a5,ffffffffc02018ba <vprintfmt+0x328>
                    putch('?', putdat);
ffffffffc0201766:	03f00513          	li	a0,63
ffffffffc020176a:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020176c:	0405                	addi	s0,s0,1
ffffffffc020176e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201772:	3dfd                	addiw	s11,s11,-1
ffffffffc0201774:	0007851b          	sext.w	a0,a5
ffffffffc0201778:	fd61                	bnez	a0,ffffffffc0201750 <vprintfmt+0x1be>
            for (; width > 0; width --) {
ffffffffc020177a:	e5b059e3          	blez	s11,ffffffffc02015cc <vprintfmt+0x3a>
ffffffffc020177e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201780:	85a6                	mv	a1,s1
ffffffffc0201782:	02000513          	li	a0,32
ffffffffc0201786:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201788:	e40d82e3          	beqz	s11,ffffffffc02015cc <vprintfmt+0x3a>
ffffffffc020178c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020178e:	85a6                	mv	a1,s1
ffffffffc0201790:	02000513          	li	a0,32
ffffffffc0201794:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201796:	fe0d94e3          	bnez	s11,ffffffffc020177e <vprintfmt+0x1ec>
ffffffffc020179a:	bd0d                	j	ffffffffc02015cc <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020179c:	4705                	li	a4,1
ffffffffc020179e:	008a8593          	addi	a1,s5,8
ffffffffc02017a2:	01074463          	blt	a4,a6,ffffffffc02017aa <vprintfmt+0x218>
    else if (lflag) {
ffffffffc02017a6:	0e080863          	beqz	a6,ffffffffc0201896 <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
ffffffffc02017aa:	000ab603          	ld	a2,0(s5)
ffffffffc02017ae:	46a1                	li	a3,8
ffffffffc02017b0:	8aae                	mv	s5,a1
ffffffffc02017b2:	a839                	j	ffffffffc02017d0 <vprintfmt+0x23e>
            putch('0', putdat);
ffffffffc02017b4:	03000513          	li	a0,48
ffffffffc02017b8:	85a6                	mv	a1,s1
ffffffffc02017ba:	e03e                	sd	a5,0(sp)
ffffffffc02017bc:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02017be:	85a6                	mv	a1,s1
ffffffffc02017c0:	07800513          	li	a0,120
ffffffffc02017c4:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02017c6:	0aa1                	addi	s5,s5,8
ffffffffc02017c8:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc02017cc:	6782                	ld	a5,0(sp)
ffffffffc02017ce:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02017d0:	2781                	sext.w	a5,a5
ffffffffc02017d2:	876e                	mv	a4,s11
ffffffffc02017d4:	85a6                	mv	a1,s1
ffffffffc02017d6:	854a                	mv	a0,s2
ffffffffc02017d8:	d4fff0ef          	jal	ra,ffffffffc0201526 <printnum>
            break;
ffffffffc02017dc:	bbc5                	j	ffffffffc02015cc <vprintfmt+0x3a>
            lflag ++;
ffffffffc02017de:	00144603          	lbu	a2,1(s0)
ffffffffc02017e2:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017e4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02017e6:	b515                	j	ffffffffc020160a <vprintfmt+0x78>
            goto reswitch;
ffffffffc02017e8:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02017ec:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02017ee:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02017f0:	bd29                	j	ffffffffc020160a <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02017f2:	85a6                	mv	a1,s1
ffffffffc02017f4:	02500513          	li	a0,37
ffffffffc02017f8:	9902                	jalr	s2
            break;
ffffffffc02017fa:	bbc9                	j	ffffffffc02015cc <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02017fc:	4705                	li	a4,1
ffffffffc02017fe:	008a8593          	addi	a1,s5,8
ffffffffc0201802:	01074463          	blt	a4,a6,ffffffffc020180a <vprintfmt+0x278>
    else if (lflag) {
ffffffffc0201806:	08080d63          	beqz	a6,ffffffffc02018a0 <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
ffffffffc020180a:	000ab603          	ld	a2,0(s5)
ffffffffc020180e:	46a9                	li	a3,10
ffffffffc0201810:	8aae                	mv	s5,a1
ffffffffc0201812:	bf7d                	j	ffffffffc02017d0 <vprintfmt+0x23e>
            putch('%', putdat);
ffffffffc0201814:	85a6                	mv	a1,s1
ffffffffc0201816:	02500513          	li	a0,37
ffffffffc020181a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020181c:	fff44703          	lbu	a4,-1(s0)
ffffffffc0201820:	02500793          	li	a5,37
ffffffffc0201824:	8d22                	mv	s10,s0
ffffffffc0201826:	daf703e3          	beq	a4,a5,ffffffffc02015cc <vprintfmt+0x3a>
ffffffffc020182a:	02500713          	li	a4,37
ffffffffc020182e:	1d7d                	addi	s10,s10,-1
ffffffffc0201830:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0201834:	fee79de3          	bne	a5,a4,ffffffffc020182e <vprintfmt+0x29c>
ffffffffc0201838:	bb51                	j	ffffffffc02015cc <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020183a:	00001617          	auipc	a2,0x1
ffffffffc020183e:	09e60613          	addi	a2,a2,158 # ffffffffc02028d8 <error_string+0xd8>
ffffffffc0201842:	85a6                	mv	a1,s1
ffffffffc0201844:	854a                	mv	a0,s2
ffffffffc0201846:	0ac000ef          	jal	ra,ffffffffc02018f2 <printfmt>
ffffffffc020184a:	b349                	j	ffffffffc02015cc <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020184c:	00001617          	auipc	a2,0x1
ffffffffc0201850:	08460613          	addi	a2,a2,132 # ffffffffc02028d0 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc0201854:	00001417          	auipc	s0,0x1
ffffffffc0201858:	07d40413          	addi	s0,s0,125 # ffffffffc02028d1 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020185c:	8532                	mv	a0,a2
ffffffffc020185e:	85e6                	mv	a1,s9
ffffffffc0201860:	e032                	sd	a2,0(sp)
ffffffffc0201862:	e43e                	sd	a5,8(sp)
ffffffffc0201864:	1c2000ef          	jal	ra,ffffffffc0201a26 <strnlen>
ffffffffc0201868:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020186c:	6602                	ld	a2,0(sp)
ffffffffc020186e:	01b05d63          	blez	s11,ffffffffc0201888 <vprintfmt+0x2f6>
ffffffffc0201872:	67a2                	ld	a5,8(sp)
ffffffffc0201874:	2781                	sext.w	a5,a5
ffffffffc0201876:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0201878:	6522                	ld	a0,8(sp)
ffffffffc020187a:	85a6                	mv	a1,s1
ffffffffc020187c:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020187e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0201880:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201882:	6602                	ld	a2,0(sp)
ffffffffc0201884:	fe0d9ae3          	bnez	s11,ffffffffc0201878 <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201888:	00064783          	lbu	a5,0(a2)
ffffffffc020188c:	0007851b          	sext.w	a0,a5
ffffffffc0201890:	ec0510e3          	bnez	a0,ffffffffc0201750 <vprintfmt+0x1be>
ffffffffc0201894:	bb25                	j	ffffffffc02015cc <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
ffffffffc0201896:	000ae603          	lwu	a2,0(s5)
ffffffffc020189a:	46a1                	li	a3,8
ffffffffc020189c:	8aae                	mv	s5,a1
ffffffffc020189e:	bf0d                	j	ffffffffc02017d0 <vprintfmt+0x23e>
ffffffffc02018a0:	000ae603          	lwu	a2,0(s5)
ffffffffc02018a4:	46a9                	li	a3,10
ffffffffc02018a6:	8aae                	mv	s5,a1
ffffffffc02018a8:	b725                	j	ffffffffc02017d0 <vprintfmt+0x23e>
        return va_arg(*ap, int);
ffffffffc02018aa:	000aa403          	lw	s0,0(s5)
ffffffffc02018ae:	bd35                	j	ffffffffc02016ea <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
ffffffffc02018b0:	000ae603          	lwu	a2,0(s5)
ffffffffc02018b4:	46c1                	li	a3,16
ffffffffc02018b6:	8aae                	mv	s5,a1
ffffffffc02018b8:	bf21                	j	ffffffffc02017d0 <vprintfmt+0x23e>
                    putch(ch, putdat);
ffffffffc02018ba:	9902                	jalr	s2
ffffffffc02018bc:	bd45                	j	ffffffffc020176c <vprintfmt+0x1da>
                putch('-', putdat);
ffffffffc02018be:	85a6                	mv	a1,s1
ffffffffc02018c0:	02d00513          	li	a0,45
ffffffffc02018c4:	e03e                	sd	a5,0(sp)
ffffffffc02018c6:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02018c8:	8ace                	mv	s5,s3
ffffffffc02018ca:	40800633          	neg	a2,s0
ffffffffc02018ce:	46a9                	li	a3,10
ffffffffc02018d0:	6782                	ld	a5,0(sp)
ffffffffc02018d2:	bdfd                	j	ffffffffc02017d0 <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
ffffffffc02018d4:	01b05663          	blez	s11,ffffffffc02018e0 <vprintfmt+0x34e>
ffffffffc02018d8:	02d00693          	li	a3,45
ffffffffc02018dc:	f6d798e3          	bne	a5,a3,ffffffffc020184c <vprintfmt+0x2ba>
ffffffffc02018e0:	00001417          	auipc	s0,0x1
ffffffffc02018e4:	ff140413          	addi	s0,s0,-15 # ffffffffc02028d1 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02018e8:	02800513          	li	a0,40
ffffffffc02018ec:	02800793          	li	a5,40
ffffffffc02018f0:	b585                	j	ffffffffc0201750 <vprintfmt+0x1be>

ffffffffc02018f2 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02018f2:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02018f4:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02018f8:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02018fa:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02018fc:	ec06                	sd	ra,24(sp)
ffffffffc02018fe:	f83a                	sd	a4,48(sp)
ffffffffc0201900:	fc3e                	sd	a5,56(sp)
ffffffffc0201902:	e0c2                	sd	a6,64(sp)
ffffffffc0201904:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201906:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201908:	c8bff0ef          	jal	ra,ffffffffc0201592 <vprintfmt>
}
ffffffffc020190c:	60e2                	ld	ra,24(sp)
ffffffffc020190e:	6161                	addi	sp,sp,80
ffffffffc0201910:	8082                	ret

ffffffffc0201912 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201912:	715d                	addi	sp,sp,-80
ffffffffc0201914:	e486                	sd	ra,72(sp)
ffffffffc0201916:	e0a2                	sd	s0,64(sp)
ffffffffc0201918:	fc26                	sd	s1,56(sp)
ffffffffc020191a:	f84a                	sd	s2,48(sp)
ffffffffc020191c:	f44e                	sd	s3,40(sp)
ffffffffc020191e:	f052                	sd	s4,32(sp)
ffffffffc0201920:	ec56                	sd	s5,24(sp)
ffffffffc0201922:	e85a                	sd	s6,16(sp)
ffffffffc0201924:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc0201926:	c901                	beqz	a0,ffffffffc0201936 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc0201928:	85aa                	mv	a1,a0
ffffffffc020192a:	00001517          	auipc	a0,0x1
ffffffffc020192e:	fbe50513          	addi	a0,a0,-66 # ffffffffc02028e8 <error_string+0xe8>
ffffffffc0201932:	f84fe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc0201936:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201938:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc020193a:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc020193c:	4aa9                	li	s5,10
ffffffffc020193e:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc0201940:	00004b97          	auipc	s7,0x4
ffffffffc0201944:	6d0b8b93          	addi	s7,s7,1744 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201948:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc020194c:	fe0fe0ef          	jal	ra,ffffffffc020012c <getchar>
ffffffffc0201950:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201952:	00054b63          	bltz	a0,ffffffffc0201968 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201956:	00a95b63          	bge	s2,a0,ffffffffc020196c <readline+0x5a>
ffffffffc020195a:	029a5463          	bge	s4,s1,ffffffffc0201982 <readline+0x70>
        c = getchar();
ffffffffc020195e:	fcefe0ef          	jal	ra,ffffffffc020012c <getchar>
ffffffffc0201962:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201964:	fe0559e3          	bgez	a0,ffffffffc0201956 <readline+0x44>
            return NULL;
ffffffffc0201968:	4501                	li	a0,0
ffffffffc020196a:	a099                	j	ffffffffc02019b0 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc020196c:	03341463          	bne	s0,s3,ffffffffc0201994 <readline+0x82>
ffffffffc0201970:	e8b9                	bnez	s1,ffffffffc02019c6 <readline+0xb4>
        c = getchar();
ffffffffc0201972:	fbafe0ef          	jal	ra,ffffffffc020012c <getchar>
ffffffffc0201976:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201978:	fe0548e3          	bltz	a0,ffffffffc0201968 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020197c:	fea958e3          	bge	s2,a0,ffffffffc020196c <readline+0x5a>
ffffffffc0201980:	4481                	li	s1,0
            cputchar(c);
ffffffffc0201982:	8522                	mv	a0,s0
ffffffffc0201984:	f66fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc0201988:	009b87b3          	add	a5,s7,s1
ffffffffc020198c:	00878023          	sb	s0,0(a5)
ffffffffc0201990:	2485                	addiw	s1,s1,1
ffffffffc0201992:	bf6d                	j	ffffffffc020194c <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0201994:	01540463          	beq	s0,s5,ffffffffc020199c <readline+0x8a>
ffffffffc0201998:	fb641ae3          	bne	s0,s6,ffffffffc020194c <readline+0x3a>
            cputchar(c);
ffffffffc020199c:	8522                	mv	a0,s0
ffffffffc020199e:	f4cfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc02019a2:	00004517          	auipc	a0,0x4
ffffffffc02019a6:	66e50513          	addi	a0,a0,1646 # ffffffffc0206010 <edata>
ffffffffc02019aa:	94aa                	add	s1,s1,a0
ffffffffc02019ac:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc02019b0:	60a6                	ld	ra,72(sp)
ffffffffc02019b2:	6406                	ld	s0,64(sp)
ffffffffc02019b4:	74e2                	ld	s1,56(sp)
ffffffffc02019b6:	7942                	ld	s2,48(sp)
ffffffffc02019b8:	79a2                	ld	s3,40(sp)
ffffffffc02019ba:	7a02                	ld	s4,32(sp)
ffffffffc02019bc:	6ae2                	ld	s5,24(sp)
ffffffffc02019be:	6b42                	ld	s6,16(sp)
ffffffffc02019c0:	6ba2                	ld	s7,8(sp)
ffffffffc02019c2:	6161                	addi	sp,sp,80
ffffffffc02019c4:	8082                	ret
            cputchar(c);
ffffffffc02019c6:	4521                	li	a0,8
ffffffffc02019c8:	f22fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc02019cc:	34fd                	addiw	s1,s1,-1
ffffffffc02019ce:	bfbd                	j	ffffffffc020194c <readline+0x3a>

ffffffffc02019d0 <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc02019d0:	00004797          	auipc	a5,0x4
ffffffffc02019d4:	63878793          	addi	a5,a5,1592 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc02019d8:	6398                	ld	a4,0(a5)
ffffffffc02019da:	4781                	li	a5,0
ffffffffc02019dc:	88ba                	mv	a7,a4
ffffffffc02019de:	852a                	mv	a0,a0
ffffffffc02019e0:	85be                	mv	a1,a5
ffffffffc02019e2:	863e                	mv	a2,a5
ffffffffc02019e4:	00000073          	ecall
ffffffffc02019e8:	87aa                	mv	a5,a0
}
ffffffffc02019ea:	8082                	ret

ffffffffc02019ec <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc02019ec:	00005797          	auipc	a5,0x5
ffffffffc02019f0:	a3c78793          	addi	a5,a5,-1476 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc02019f4:	6398                	ld	a4,0(a5)
ffffffffc02019f6:	4781                	li	a5,0
ffffffffc02019f8:	88ba                	mv	a7,a4
ffffffffc02019fa:	852a                	mv	a0,a0
ffffffffc02019fc:	85be                	mv	a1,a5
ffffffffc02019fe:	863e                	mv	a2,a5
ffffffffc0201a00:	00000073          	ecall
ffffffffc0201a04:	87aa                	mv	a5,a0
}
ffffffffc0201a06:	8082                	ret

ffffffffc0201a08 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc0201a08:	00004797          	auipc	a5,0x4
ffffffffc0201a0c:	5f878793          	addi	a5,a5,1528 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc0201a10:	639c                	ld	a5,0(a5)
ffffffffc0201a12:	4501                	li	a0,0
ffffffffc0201a14:	88be                	mv	a7,a5
ffffffffc0201a16:	852a                	mv	a0,a0
ffffffffc0201a18:	85aa                	mv	a1,a0
ffffffffc0201a1a:	862a                	mv	a2,a0
ffffffffc0201a1c:	00000073          	ecall
ffffffffc0201a20:	852a                	mv	a0,a0
ffffffffc0201a22:	2501                	sext.w	a0,a0
ffffffffc0201a24:	8082                	ret

ffffffffc0201a26 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a26:	c185                	beqz	a1,ffffffffc0201a46 <strnlen+0x20>
ffffffffc0201a28:	00054783          	lbu	a5,0(a0)
ffffffffc0201a2c:	cf89                	beqz	a5,ffffffffc0201a46 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0201a2e:	4781                	li	a5,0
ffffffffc0201a30:	a021                	j	ffffffffc0201a38 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a32:	00074703          	lbu	a4,0(a4)
ffffffffc0201a36:	c711                	beqz	a4,ffffffffc0201a42 <strnlen+0x1c>
        cnt ++;
ffffffffc0201a38:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201a3a:	00f50733          	add	a4,a0,a5
ffffffffc0201a3e:	fef59ae3          	bne	a1,a5,ffffffffc0201a32 <strnlen+0xc>
    }
    return cnt;
}
ffffffffc0201a42:	853e                	mv	a0,a5
ffffffffc0201a44:	8082                	ret
    size_t cnt = 0;
ffffffffc0201a46:	4781                	li	a5,0
}
ffffffffc0201a48:	853e                	mv	a0,a5
ffffffffc0201a4a:	8082                	ret

ffffffffc0201a4c <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a4c:	00054783          	lbu	a5,0(a0)
ffffffffc0201a50:	0005c703          	lbu	a4,0(a1)
ffffffffc0201a54:	cb91                	beqz	a5,ffffffffc0201a68 <strcmp+0x1c>
ffffffffc0201a56:	00e79c63          	bne	a5,a4,ffffffffc0201a6e <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0201a5a:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a5c:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc0201a60:	0585                	addi	a1,a1,1
ffffffffc0201a62:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201a66:	fbe5                	bnez	a5,ffffffffc0201a56 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201a68:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201a6a:	9d19                	subw	a0,a0,a4
ffffffffc0201a6c:	8082                	ret
ffffffffc0201a6e:	0007851b          	sext.w	a0,a5
ffffffffc0201a72:	9d19                	subw	a0,a0,a4
ffffffffc0201a74:	8082                	ret

ffffffffc0201a76 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201a76:	00054783          	lbu	a5,0(a0)
ffffffffc0201a7a:	cb91                	beqz	a5,ffffffffc0201a8e <strchr+0x18>
        if (*s == c) {
ffffffffc0201a7c:	00b79563          	bne	a5,a1,ffffffffc0201a86 <strchr+0x10>
ffffffffc0201a80:	a809                	j	ffffffffc0201a92 <strchr+0x1c>
ffffffffc0201a82:	00b78763          	beq	a5,a1,ffffffffc0201a90 <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0201a86:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201a88:	00054783          	lbu	a5,0(a0)
ffffffffc0201a8c:	fbfd                	bnez	a5,ffffffffc0201a82 <strchr+0xc>
    }
    return NULL;
ffffffffc0201a8e:	4501                	li	a0,0
}
ffffffffc0201a90:	8082                	ret
ffffffffc0201a92:	8082                	ret

ffffffffc0201a94 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201a94:	ca01                	beqz	a2,ffffffffc0201aa4 <memset+0x10>
ffffffffc0201a96:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201a98:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201a9a:	0785                	addi	a5,a5,1
ffffffffc0201a9c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201aa0:	fec79de3          	bne	a5,a2,ffffffffc0201a9a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201aa4:	8082                	ret
