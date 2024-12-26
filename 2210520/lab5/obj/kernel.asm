
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200000:	c020b2b7          	lui	t0,0xc020b
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
ffffffffc0200028:	c020b137          	lui	sp,0xc020b

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

int
kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc0200036:	000a1517          	auipc	a0,0xa1
ffffffffc020003a:	40a50513          	addi	a0,a0,1034 # ffffffffc02a1440 <edata>
ffffffffc020003e:	000ad617          	auipc	a2,0xad
ffffffffc0200042:	98a60613          	addi	a2,a2,-1654 # ffffffffc02ac9c8 <end>
kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	562060ef          	jal	ra,ffffffffc02065b0 <memset>
    cons_init();                // init the console
ffffffffc0200052:	530000ef          	jal	ra,ffffffffc0200582 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc0200056:	00006597          	auipc	a1,0x6
ffffffffc020005a:	58a58593          	addi	a1,a1,1418 # ffffffffc02065e0 <etext+0x6>
ffffffffc020005e:	00006517          	auipc	a0,0x6
ffffffffc0200062:	5a250513          	addi	a0,a0,1442 # ffffffffc0206600 <etext+0x26>
ffffffffc0200066:	128000ef          	jal	ra,ffffffffc020018e <cprintf>

    print_kerninfo();
ffffffffc020006a:	1aa000ef          	jal	ra,ffffffffc0200214 <print_kerninfo>

    // grade_backtrace();

    pmm_init();                 // init physical memory management
ffffffffc020006e:	58e020ef          	jal	ra,ffffffffc02025fc <pmm_init>

    pic_init();                 // init interrupt controller
ffffffffc0200072:	5e6000ef          	jal	ra,ffffffffc0200658 <pic_init>
    idt_init();                 // init interrupt descriptor table
ffffffffc0200076:	5e4000ef          	jal	ra,ffffffffc020065a <idt_init>

    vmm_init();                 // init virtual memory management
ffffffffc020007a:	3ac040ef          	jal	ra,ffffffffc0204426 <vmm_init>
    proc_init();                // init process table
ffffffffc020007e:	4cf050ef          	jal	ra,ffffffffc0205d4c <proc_init>
    
    ide_init();                 // init ide devices
ffffffffc0200082:	572000ef          	jal	ra,ffffffffc02005f4 <ide_init>
    swap_init();                // init swap
ffffffffc0200086:	2ca030ef          	jal	ra,ffffffffc0203350 <swap_init>

    clock_init();               // init clock interrupt
ffffffffc020008a:	4a4000ef          	jal	ra,ffffffffc020052e <clock_init>
    intr_enable();              // enable irq interrupt
ffffffffc020008e:	5be000ef          	jal	ra,ffffffffc020064c <intr_enable>
    
    cpu_idle();                 // run idle process
ffffffffc0200092:	607050ef          	jal	ra,ffffffffc0205e98 <cpu_idle>

ffffffffc0200096 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0200096:	715d                	addi	sp,sp,-80
ffffffffc0200098:	e486                	sd	ra,72(sp)
ffffffffc020009a:	e0a2                	sd	s0,64(sp)
ffffffffc020009c:	fc26                	sd	s1,56(sp)
ffffffffc020009e:	f84a                	sd	s2,48(sp)
ffffffffc02000a0:	f44e                	sd	s3,40(sp)
ffffffffc02000a2:	f052                	sd	s4,32(sp)
ffffffffc02000a4:	ec56                	sd	s5,24(sp)
ffffffffc02000a6:	e85a                	sd	s6,16(sp)
ffffffffc02000a8:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02000aa:	c901                	beqz	a0,ffffffffc02000ba <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02000ac:	85aa                	mv	a1,a0
ffffffffc02000ae:	00006517          	auipc	a0,0x6
ffffffffc02000b2:	55a50513          	addi	a0,a0,1370 # ffffffffc0206608 <etext+0x2e>
ffffffffc02000b6:	0d8000ef          	jal	ra,ffffffffc020018e <cprintf>
readline(const char *prompt) {
ffffffffc02000ba:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000bc:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000be:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000c0:	4aa9                	li	s5,10
ffffffffc02000c2:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02000c4:	000a1b97          	auipc	s7,0xa1
ffffffffc02000c8:	37cb8b93          	addi	s7,s7,892 # ffffffffc02a1440 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000cc:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc02000d0:	134000ef          	jal	ra,ffffffffc0200204 <getchar>
ffffffffc02000d4:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000d6:	00054b63          	bltz	a0,ffffffffc02000ec <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000da:	00a95b63          	bge	s2,a0,ffffffffc02000f0 <readline+0x5a>
ffffffffc02000de:	029a5463          	bge	s4,s1,ffffffffc0200106 <readline+0x70>
        c = getchar();
ffffffffc02000e2:	122000ef          	jal	ra,ffffffffc0200204 <getchar>
ffffffffc02000e6:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000e8:	fe0559e3          	bgez	a0,ffffffffc02000da <readline+0x44>
            return NULL;
ffffffffc02000ec:	4501                	li	a0,0
ffffffffc02000ee:	a099                	j	ffffffffc0200134 <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc02000f0:	03341463          	bne	s0,s3,ffffffffc0200118 <readline+0x82>
ffffffffc02000f4:	e8b9                	bnez	s1,ffffffffc020014a <readline+0xb4>
        c = getchar();
ffffffffc02000f6:	10e000ef          	jal	ra,ffffffffc0200204 <getchar>
ffffffffc02000fa:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc02000fc:	fe0548e3          	bltz	a0,ffffffffc02000ec <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200100:	fea958e3          	bge	s2,a0,ffffffffc02000f0 <readline+0x5a>
ffffffffc0200104:	4481                	li	s1,0
            cputchar(c);
ffffffffc0200106:	8522                	mv	a0,s0
ffffffffc0200108:	0ba000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            buf[i ++] = c;
ffffffffc020010c:	009b87b3          	add	a5,s7,s1
ffffffffc0200110:	00878023          	sb	s0,0(a5)
ffffffffc0200114:	2485                	addiw	s1,s1,1
ffffffffc0200116:	bf6d                	j	ffffffffc02000d0 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc0200118:	01540463          	beq	s0,s5,ffffffffc0200120 <readline+0x8a>
ffffffffc020011c:	fb641ae3          	bne	s0,s6,ffffffffc02000d0 <readline+0x3a>
            cputchar(c);
ffffffffc0200120:	8522                	mv	a0,s0
ffffffffc0200122:	0a0000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            buf[i] = '\0';
ffffffffc0200126:	000a1517          	auipc	a0,0xa1
ffffffffc020012a:	31a50513          	addi	a0,a0,794 # ffffffffc02a1440 <edata>
ffffffffc020012e:	94aa                	add	s1,s1,a0
ffffffffc0200130:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc0200134:	60a6                	ld	ra,72(sp)
ffffffffc0200136:	6406                	ld	s0,64(sp)
ffffffffc0200138:	74e2                	ld	s1,56(sp)
ffffffffc020013a:	7942                	ld	s2,48(sp)
ffffffffc020013c:	79a2                	ld	s3,40(sp)
ffffffffc020013e:	7a02                	ld	s4,32(sp)
ffffffffc0200140:	6ae2                	ld	s5,24(sp)
ffffffffc0200142:	6b42                	ld	s6,16(sp)
ffffffffc0200144:	6ba2                	ld	s7,8(sp)
ffffffffc0200146:	6161                	addi	sp,sp,80
ffffffffc0200148:	8082                	ret
            cputchar(c);
ffffffffc020014a:	4521                	li	a0,8
ffffffffc020014c:	076000ef          	jal	ra,ffffffffc02001c2 <cputchar>
            i --;
ffffffffc0200150:	34fd                	addiw	s1,s1,-1
ffffffffc0200152:	bfbd                	j	ffffffffc02000d0 <readline+0x3a>

ffffffffc0200154 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200154:	1141                	addi	sp,sp,-16
ffffffffc0200156:	e022                	sd	s0,0(sp)
ffffffffc0200158:	e406                	sd	ra,8(sp)
ffffffffc020015a:	842e                	mv	s0,a1
    cons_putc(c);
ffffffffc020015c:	428000ef          	jal	ra,ffffffffc0200584 <cons_putc>
    (*cnt) ++;
ffffffffc0200160:	401c                	lw	a5,0(s0)
}
ffffffffc0200162:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
ffffffffc0200164:	2785                	addiw	a5,a5,1
ffffffffc0200166:	c01c                	sw	a5,0(s0)
}
ffffffffc0200168:	6402                	ld	s0,0(sp)
ffffffffc020016a:	0141                	addi	sp,sp,16
ffffffffc020016c:	8082                	ret

ffffffffc020016e <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc020016e:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200170:	86ae                	mv	a3,a1
ffffffffc0200172:	862a                	mv	a2,a0
ffffffffc0200174:	006c                	addi	a1,sp,12
ffffffffc0200176:	00000517          	auipc	a0,0x0
ffffffffc020017a:	fde50513          	addi	a0,a0,-34 # ffffffffc0200154 <cputch>
vcprintf(const char *fmt, va_list ap) {
ffffffffc020017e:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200180:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200182:	010060ef          	jal	ra,ffffffffc0206192 <vprintfmt>
    return cnt;
}
ffffffffc0200186:	60e2                	ld	ra,24(sp)
ffffffffc0200188:	4532                	lw	a0,12(sp)
ffffffffc020018a:	6105                	addi	sp,sp,32
ffffffffc020018c:	8082                	ret

ffffffffc020018e <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc020018e:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200190:	02810313          	addi	t1,sp,40 # ffffffffc020b028 <boot_page_table_sv39+0x28>
cprintf(const char *fmt, ...) {
ffffffffc0200194:	f42e                	sd	a1,40(sp)
ffffffffc0200196:	f832                	sd	a2,48(sp)
ffffffffc0200198:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020019a:	862a                	mv	a2,a0
ffffffffc020019c:	004c                	addi	a1,sp,4
ffffffffc020019e:	00000517          	auipc	a0,0x0
ffffffffc02001a2:	fb650513          	addi	a0,a0,-74 # ffffffffc0200154 <cputch>
ffffffffc02001a6:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc02001a8:	ec06                	sd	ra,24(sp)
ffffffffc02001aa:	e0ba                	sd	a4,64(sp)
ffffffffc02001ac:	e4be                	sd	a5,72(sp)
ffffffffc02001ae:	e8c2                	sd	a6,80(sp)
ffffffffc02001b0:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
ffffffffc02001b2:	e41a                	sd	t1,8(sp)
    int cnt = 0;
ffffffffc02001b4:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02001b6:	7dd050ef          	jal	ra,ffffffffc0206192 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001ba:	60e2                	ld	ra,24(sp)
ffffffffc02001bc:	4512                	lw	a0,4(sp)
ffffffffc02001be:	6125                	addi	sp,sp,96
ffffffffc02001c0:	8082                	ret

ffffffffc02001c2 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc02001c2:	a6c9                	j	ffffffffc0200584 <cons_putc>

ffffffffc02001c4 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc02001c4:	1101                	addi	sp,sp,-32
ffffffffc02001c6:	e822                	sd	s0,16(sp)
ffffffffc02001c8:	ec06                	sd	ra,24(sp)
ffffffffc02001ca:	e426                	sd	s1,8(sp)
ffffffffc02001cc:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc02001ce:	00054503          	lbu	a0,0(a0)
ffffffffc02001d2:	c51d                	beqz	a0,ffffffffc0200200 <cputs+0x3c>
ffffffffc02001d4:	0405                	addi	s0,s0,1
ffffffffc02001d6:	4485                	li	s1,1
ffffffffc02001d8:	9c81                	subw	s1,s1,s0
    cons_putc(c);
ffffffffc02001da:	3aa000ef          	jal	ra,ffffffffc0200584 <cons_putc>
    (*cnt) ++;
ffffffffc02001de:	008487bb          	addw	a5,s1,s0
    while ((c = *str ++) != '\0') {
ffffffffc02001e2:	0405                	addi	s0,s0,1
ffffffffc02001e4:	fff44503          	lbu	a0,-1(s0)
ffffffffc02001e8:	f96d                	bnez	a0,ffffffffc02001da <cputs+0x16>
ffffffffc02001ea:	0017841b          	addiw	s0,a5,1
    cons_putc(c);
ffffffffc02001ee:	4529                	li	a0,10
ffffffffc02001f0:	394000ef          	jal	ra,ffffffffc0200584 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001f4:	8522                	mv	a0,s0
ffffffffc02001f6:	60e2                	ld	ra,24(sp)
ffffffffc02001f8:	6442                	ld	s0,16(sp)
ffffffffc02001fa:	64a2                	ld	s1,8(sp)
ffffffffc02001fc:	6105                	addi	sp,sp,32
ffffffffc02001fe:	8082                	ret
    while ((c = *str ++) != '\0') {
ffffffffc0200200:	4405                	li	s0,1
ffffffffc0200202:	b7f5                	j	ffffffffc02001ee <cputs+0x2a>

ffffffffc0200204 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc0200204:	1141                	addi	sp,sp,-16
ffffffffc0200206:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200208:	3b0000ef          	jal	ra,ffffffffc02005b8 <cons_getc>
ffffffffc020020c:	dd75                	beqz	a0,ffffffffc0200208 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc020020e:	60a2                	ld	ra,8(sp)
ffffffffc0200210:	0141                	addi	sp,sp,16
ffffffffc0200212:	8082                	ret

ffffffffc0200214 <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc0200214:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200216:	00006517          	auipc	a0,0x6
ffffffffc020021a:	42a50513          	addi	a0,a0,1066 # ffffffffc0206640 <etext+0x66>
void print_kerninfo(void) {
ffffffffc020021e:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200220:	f6fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200224:	00000597          	auipc	a1,0x0
ffffffffc0200228:	e1258593          	addi	a1,a1,-494 # ffffffffc0200036 <kern_init>
ffffffffc020022c:	00006517          	auipc	a0,0x6
ffffffffc0200230:	43450513          	addi	a0,a0,1076 # ffffffffc0206660 <etext+0x86>
ffffffffc0200234:	f5bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc0200238:	00006597          	auipc	a1,0x6
ffffffffc020023c:	3a258593          	addi	a1,a1,930 # ffffffffc02065da <etext>
ffffffffc0200240:	00006517          	auipc	a0,0x6
ffffffffc0200244:	44050513          	addi	a0,a0,1088 # ffffffffc0206680 <etext+0xa6>
ffffffffc0200248:	f47ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020024c:	000a1597          	auipc	a1,0xa1
ffffffffc0200250:	1f458593          	addi	a1,a1,500 # ffffffffc02a1440 <edata>
ffffffffc0200254:	00006517          	auipc	a0,0x6
ffffffffc0200258:	44c50513          	addi	a0,a0,1100 # ffffffffc02066a0 <etext+0xc6>
ffffffffc020025c:	f33ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200260:	000ac597          	auipc	a1,0xac
ffffffffc0200264:	76858593          	addi	a1,a1,1896 # ffffffffc02ac9c8 <end>
ffffffffc0200268:	00006517          	auipc	a0,0x6
ffffffffc020026c:	45850513          	addi	a0,a0,1112 # ffffffffc02066c0 <etext+0xe6>
ffffffffc0200270:	f1fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200274:	000ad597          	auipc	a1,0xad
ffffffffc0200278:	b5358593          	addi	a1,a1,-1197 # ffffffffc02acdc7 <end+0x3ff>
ffffffffc020027c:	00000797          	auipc	a5,0x0
ffffffffc0200280:	dba78793          	addi	a5,a5,-582 # ffffffffc0200036 <kern_init>
ffffffffc0200284:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200288:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020028c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020028e:	3ff5f593          	andi	a1,a1,1023
ffffffffc0200292:	95be                	add	a1,a1,a5
ffffffffc0200294:	85a9                	srai	a1,a1,0xa
ffffffffc0200296:	00006517          	auipc	a0,0x6
ffffffffc020029a:	44a50513          	addi	a0,a0,1098 # ffffffffc02066e0 <etext+0x106>
}
ffffffffc020029e:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002a0:	b5fd                	j	ffffffffc020018e <cprintf>

ffffffffc02002a2 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02002a2:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002a4:	00006617          	auipc	a2,0x6
ffffffffc02002a8:	36c60613          	addi	a2,a2,876 # ffffffffc0206610 <etext+0x36>
ffffffffc02002ac:	04d00593          	li	a1,77
ffffffffc02002b0:	00006517          	auipc	a0,0x6
ffffffffc02002b4:	37850513          	addi	a0,a0,888 # ffffffffc0206628 <etext+0x4e>
void print_stackframe(void) {
ffffffffc02002b8:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002ba:	1c6000ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02002be <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002be:	1141                	addi	sp,sp,-16
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002c0:	00006617          	auipc	a2,0x6
ffffffffc02002c4:	53060613          	addi	a2,a2,1328 # ffffffffc02067f0 <commands+0xe0>
ffffffffc02002c8:	00006597          	auipc	a1,0x6
ffffffffc02002cc:	54858593          	addi	a1,a1,1352 # ffffffffc0206810 <commands+0x100>
ffffffffc02002d0:	00006517          	auipc	a0,0x6
ffffffffc02002d4:	54850513          	addi	a0,a0,1352 # ffffffffc0206818 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002d8:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002da:	eb5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002de:	00006617          	auipc	a2,0x6
ffffffffc02002e2:	54a60613          	addi	a2,a2,1354 # ffffffffc0206828 <commands+0x118>
ffffffffc02002e6:	00006597          	auipc	a1,0x6
ffffffffc02002ea:	56a58593          	addi	a1,a1,1386 # ffffffffc0206850 <commands+0x140>
ffffffffc02002ee:	00006517          	auipc	a0,0x6
ffffffffc02002f2:	52a50513          	addi	a0,a0,1322 # ffffffffc0206818 <commands+0x108>
ffffffffc02002f6:	e99ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02002fa:	00006617          	auipc	a2,0x6
ffffffffc02002fe:	56660613          	addi	a2,a2,1382 # ffffffffc0206860 <commands+0x150>
ffffffffc0200302:	00006597          	auipc	a1,0x6
ffffffffc0200306:	57e58593          	addi	a1,a1,1406 # ffffffffc0206880 <commands+0x170>
ffffffffc020030a:	00006517          	auipc	a0,0x6
ffffffffc020030e:	50e50513          	addi	a0,a0,1294 # ffffffffc0206818 <commands+0x108>
ffffffffc0200312:	e7dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    }
    return 0;
}
ffffffffc0200316:	60a2                	ld	ra,8(sp)
ffffffffc0200318:	4501                	li	a0,0
ffffffffc020031a:	0141                	addi	sp,sp,16
ffffffffc020031c:	8082                	ret

ffffffffc020031e <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020031e:	1141                	addi	sp,sp,-16
ffffffffc0200320:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200322:	ef3ff0ef          	jal	ra,ffffffffc0200214 <print_kerninfo>
    return 0;
}
ffffffffc0200326:	60a2                	ld	ra,8(sp)
ffffffffc0200328:	4501                	li	a0,0
ffffffffc020032a:	0141                	addi	sp,sp,16
ffffffffc020032c:	8082                	ret

ffffffffc020032e <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020032e:	1141                	addi	sp,sp,-16
ffffffffc0200330:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200332:	f71ff0ef          	jal	ra,ffffffffc02002a2 <print_stackframe>
    return 0;
}
ffffffffc0200336:	60a2                	ld	ra,8(sp)
ffffffffc0200338:	4501                	li	a0,0
ffffffffc020033a:	0141                	addi	sp,sp,16
ffffffffc020033c:	8082                	ret

ffffffffc020033e <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020033e:	7115                	addi	sp,sp,-224
ffffffffc0200340:	e962                	sd	s8,144(sp)
ffffffffc0200342:	8c2a                	mv	s8,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200344:	00006517          	auipc	a0,0x6
ffffffffc0200348:	41450513          	addi	a0,a0,1044 # ffffffffc0206758 <commands+0x48>
kmonitor(struct trapframe *tf) {
ffffffffc020034c:	ed86                	sd	ra,216(sp)
ffffffffc020034e:	e9a2                	sd	s0,208(sp)
ffffffffc0200350:	e5a6                	sd	s1,200(sp)
ffffffffc0200352:	e1ca                	sd	s2,192(sp)
ffffffffc0200354:	fd4e                	sd	s3,184(sp)
ffffffffc0200356:	f952                	sd	s4,176(sp)
ffffffffc0200358:	f556                	sd	s5,168(sp)
ffffffffc020035a:	f15a                	sd	s6,160(sp)
ffffffffc020035c:	ed5e                	sd	s7,152(sp)
ffffffffc020035e:	e566                	sd	s9,136(sp)
ffffffffc0200360:	e16a                	sd	s10,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200362:	e2dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200366:	00006517          	auipc	a0,0x6
ffffffffc020036a:	41a50513          	addi	a0,a0,1050 # ffffffffc0206780 <commands+0x70>
ffffffffc020036e:	e21ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    if (tf != NULL) {
ffffffffc0200372:	000c0563          	beqz	s8,ffffffffc020037c <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc0200376:	8562                	mv	a0,s8
ffffffffc0200378:	4c8000ef          	jal	ra,ffffffffc0200840 <print_trapframe>
ffffffffc020037c:	00006c97          	auipc	s9,0x6
ffffffffc0200380:	394c8c93          	addi	s9,s9,916 # ffffffffc0206710 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc0200384:	00006997          	auipc	s3,0x6
ffffffffc0200388:	42498993          	addi	s3,s3,1060 # ffffffffc02067a8 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020038c:	00006917          	auipc	s2,0x6
ffffffffc0200390:	42490913          	addi	s2,s2,1060 # ffffffffc02067b0 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc0200394:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200396:	00006b17          	auipc	s6,0x6
ffffffffc020039a:	422b0b13          	addi	s6,s6,1058 # ffffffffc02067b8 <commands+0xa8>
    if (argc == 0) {
ffffffffc020039e:	00006a97          	auipc	s5,0x6
ffffffffc02003a2:	472a8a93          	addi	s5,s5,1138 # ffffffffc0206810 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003a6:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02003a8:	854e                	mv	a0,s3
ffffffffc02003aa:	cedff0ef          	jal	ra,ffffffffc0200096 <readline>
ffffffffc02003ae:	842a                	mv	s0,a0
ffffffffc02003b0:	dd65                	beqz	a0,ffffffffc02003a8 <kmonitor+0x6a>
ffffffffc02003b2:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02003b6:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003b8:	c999                	beqz	a1,ffffffffc02003ce <kmonitor+0x90>
ffffffffc02003ba:	854a                	mv	a0,s2
ffffffffc02003bc:	1d6060ef          	jal	ra,ffffffffc0206592 <strchr>
ffffffffc02003c0:	c925                	beqz	a0,ffffffffc0200430 <kmonitor+0xf2>
            *buf ++ = '\0';
ffffffffc02003c2:	00144583          	lbu	a1,1(s0)
ffffffffc02003c6:	00040023          	sb	zero,0(s0)
ffffffffc02003ca:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003cc:	f5fd                	bnez	a1,ffffffffc02003ba <kmonitor+0x7c>
    if (argc == 0) {
ffffffffc02003ce:	dce9                	beqz	s1,ffffffffc02003a8 <kmonitor+0x6a>
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003d0:	6582                	ld	a1,0(sp)
ffffffffc02003d2:	00006d17          	auipc	s10,0x6
ffffffffc02003d6:	33ed0d13          	addi	s10,s10,830 # ffffffffc0206710 <commands>
    if (argc == 0) {
ffffffffc02003da:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003dc:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003de:	0d61                	addi	s10,s10,24
ffffffffc02003e0:	188060ef          	jal	ra,ffffffffc0206568 <strcmp>
ffffffffc02003e4:	c919                	beqz	a0,ffffffffc02003fa <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02003e6:	2405                	addiw	s0,s0,1
ffffffffc02003e8:	09740463          	beq	s0,s7,ffffffffc0200470 <kmonitor+0x132>
ffffffffc02003ec:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc02003f0:	6582                	ld	a1,0(sp)
ffffffffc02003f2:	0d61                	addi	s10,s10,24
ffffffffc02003f4:	174060ef          	jal	ra,ffffffffc0206568 <strcmp>
ffffffffc02003f8:	f57d                	bnez	a0,ffffffffc02003e6 <kmonitor+0xa8>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc02003fa:	00141793          	slli	a5,s0,0x1
ffffffffc02003fe:	97a2                	add	a5,a5,s0
ffffffffc0200400:	078e                	slli	a5,a5,0x3
ffffffffc0200402:	97e6                	add	a5,a5,s9
ffffffffc0200404:	6b9c                	ld	a5,16(a5)
ffffffffc0200406:	8662                	mv	a2,s8
ffffffffc0200408:	002c                	addi	a1,sp,8
ffffffffc020040a:	fff4851b          	addiw	a0,s1,-1
ffffffffc020040e:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200410:	f8055ce3          	bgez	a0,ffffffffc02003a8 <kmonitor+0x6a>
}
ffffffffc0200414:	60ee                	ld	ra,216(sp)
ffffffffc0200416:	644e                	ld	s0,208(sp)
ffffffffc0200418:	64ae                	ld	s1,200(sp)
ffffffffc020041a:	690e                	ld	s2,192(sp)
ffffffffc020041c:	79ea                	ld	s3,184(sp)
ffffffffc020041e:	7a4a                	ld	s4,176(sp)
ffffffffc0200420:	7aaa                	ld	s5,168(sp)
ffffffffc0200422:	7b0a                	ld	s6,160(sp)
ffffffffc0200424:	6bea                	ld	s7,152(sp)
ffffffffc0200426:	6c4a                	ld	s8,144(sp)
ffffffffc0200428:	6caa                	ld	s9,136(sp)
ffffffffc020042a:	6d0a                	ld	s10,128(sp)
ffffffffc020042c:	612d                	addi	sp,sp,224
ffffffffc020042e:	8082                	ret
        if (*buf == '\0') {
ffffffffc0200430:	00044783          	lbu	a5,0(s0)
ffffffffc0200434:	dfc9                	beqz	a5,ffffffffc02003ce <kmonitor+0x90>
        if (argc == MAXARGS - 1) {
ffffffffc0200436:	03448863          	beq	s1,s4,ffffffffc0200466 <kmonitor+0x128>
        argv[argc ++] = buf;
ffffffffc020043a:	00349793          	slli	a5,s1,0x3
ffffffffc020043e:	0118                	addi	a4,sp,128
ffffffffc0200440:	97ba                	add	a5,a5,a4
ffffffffc0200442:	f887b023          	sd	s0,-128(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200446:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020044a:	2485                	addiw	s1,s1,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020044c:	e591                	bnez	a1,ffffffffc0200458 <kmonitor+0x11a>
ffffffffc020044e:	b749                	j	ffffffffc02003d0 <kmonitor+0x92>
            buf ++;
ffffffffc0200450:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200452:	00044583          	lbu	a1,0(s0)
ffffffffc0200456:	ddad                	beqz	a1,ffffffffc02003d0 <kmonitor+0x92>
ffffffffc0200458:	854a                	mv	a0,s2
ffffffffc020045a:	138060ef          	jal	ra,ffffffffc0206592 <strchr>
ffffffffc020045e:	d96d                	beqz	a0,ffffffffc0200450 <kmonitor+0x112>
ffffffffc0200460:	00044583          	lbu	a1,0(s0)
ffffffffc0200464:	bf91                	j	ffffffffc02003b8 <kmonitor+0x7a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200466:	45c1                	li	a1,16
ffffffffc0200468:	855a                	mv	a0,s6
ffffffffc020046a:	d25ff0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc020046e:	b7f1                	j	ffffffffc020043a <kmonitor+0xfc>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc0200470:	6582                	ld	a1,0(sp)
ffffffffc0200472:	00006517          	auipc	a0,0x6
ffffffffc0200476:	36650513          	addi	a0,a0,870 # ffffffffc02067d8 <commands+0xc8>
ffffffffc020047a:	d15ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
ffffffffc020047e:	b72d                	j	ffffffffc02003a8 <kmonitor+0x6a>

ffffffffc0200480 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc0200480:	000ac317          	auipc	t1,0xac
ffffffffc0200484:	3c030313          	addi	t1,t1,960 # ffffffffc02ac840 <is_panic>
ffffffffc0200488:	00033303          	ld	t1,0(t1)
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc020048c:	715d                	addi	sp,sp,-80
ffffffffc020048e:	ec06                	sd	ra,24(sp)
ffffffffc0200490:	e822                	sd	s0,16(sp)
ffffffffc0200492:	f436                	sd	a3,40(sp)
ffffffffc0200494:	f83a                	sd	a4,48(sp)
ffffffffc0200496:	fc3e                	sd	a5,56(sp)
ffffffffc0200498:	e0c2                	sd	a6,64(sp)
ffffffffc020049a:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc020049c:	02031c63          	bnez	t1,ffffffffc02004d4 <__panic+0x54>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02004a0:	4785                	li	a5,1
ffffffffc02004a2:	8432                	mv	s0,a2
ffffffffc02004a4:	000ac717          	auipc	a4,0xac
ffffffffc02004a8:	38f73e23          	sd	a5,924(a4) # ffffffffc02ac840 <is_panic>

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004ac:	862e                	mv	a2,a1
    va_start(ap, fmt);
ffffffffc02004ae:	103c                	addi	a5,sp,40
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004b0:	85aa                	mv	a1,a0
ffffffffc02004b2:	00006517          	auipc	a0,0x6
ffffffffc02004b6:	3de50513          	addi	a0,a0,990 # ffffffffc0206890 <commands+0x180>
    va_start(ap, fmt);
ffffffffc02004ba:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02004bc:	cd3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004c0:	65a2                	ld	a1,8(sp)
ffffffffc02004c2:	8522                	mv	a0,s0
ffffffffc02004c4:	cabff0ef          	jal	ra,ffffffffc020016e <vcprintf>
    cprintf("\n");
ffffffffc02004c8:	00007517          	auipc	a0,0x7
ffffffffc02004cc:	38050513          	addi	a0,a0,896 # ffffffffc0207848 <default_pmm_manager+0x530>
ffffffffc02004d0:	cbfff0ef          	jal	ra,ffffffffc020018e <cprintf>
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc02004d4:	4501                	li	a0,0
ffffffffc02004d6:	4581                	li	a1,0
ffffffffc02004d8:	4601                	li	a2,0
ffffffffc02004da:	48a1                	li	a7,8
ffffffffc02004dc:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004e0:	172000ef          	jal	ra,ffffffffc0200652 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004e4:	4501                	li	a0,0
ffffffffc02004e6:	e59ff0ef          	jal	ra,ffffffffc020033e <kmonitor>
ffffffffc02004ea:	bfed                	j	ffffffffc02004e4 <__panic+0x64>

ffffffffc02004ec <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004ec:	715d                	addi	sp,sp,-80
ffffffffc02004ee:	e822                	sd	s0,16(sp)
ffffffffc02004f0:	fc3e                	sd	a5,56(sp)
ffffffffc02004f2:	8432                	mv	s0,a2
    va_list ap;
    va_start(ap, fmt);
ffffffffc02004f4:	103c                	addi	a5,sp,40
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004f6:	862e                	mv	a2,a1
ffffffffc02004f8:	85aa                	mv	a1,a0
ffffffffc02004fa:	00006517          	auipc	a0,0x6
ffffffffc02004fe:	3b650513          	addi	a0,a0,950 # ffffffffc02068b0 <commands+0x1a0>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc0200502:	ec06                	sd	ra,24(sp)
ffffffffc0200504:	f436                	sd	a3,40(sp)
ffffffffc0200506:	f83a                	sd	a4,48(sp)
ffffffffc0200508:	e0c2                	sd	a6,64(sp)
ffffffffc020050a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc020050c:	e43e                	sd	a5,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc020050e:	c81ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200512:	65a2                	ld	a1,8(sp)
ffffffffc0200514:	8522                	mv	a0,s0
ffffffffc0200516:	c59ff0ef          	jal	ra,ffffffffc020016e <vcprintf>
    cprintf("\n");
ffffffffc020051a:	00007517          	auipc	a0,0x7
ffffffffc020051e:	32e50513          	addi	a0,a0,814 # ffffffffc0207848 <default_pmm_manager+0x530>
ffffffffc0200522:	c6dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    va_end(ap);
}
ffffffffc0200526:	60e2                	ld	ra,24(sp)
ffffffffc0200528:	6442                	ld	s0,16(sp)
ffffffffc020052a:	6161                	addi	sp,sp,80
ffffffffc020052c:	8082                	ret

ffffffffc020052e <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc020052e:	67e1                	lui	a5,0x18
ffffffffc0200530:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xdbd0>
ffffffffc0200534:	000ac717          	auipc	a4,0xac
ffffffffc0200538:	30f73a23          	sd	a5,788(a4) # ffffffffc02ac848 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020053c:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200540:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200542:	953e                	add	a0,a0,a5
ffffffffc0200544:	4601                	li	a2,0
ffffffffc0200546:	4881                	li	a7,0
ffffffffc0200548:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc020054c:	02000793          	li	a5,32
ffffffffc0200550:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc0200554:	00006517          	auipc	a0,0x6
ffffffffc0200558:	37c50513          	addi	a0,a0,892 # ffffffffc02068d0 <commands+0x1c0>
    ticks = 0;
ffffffffc020055c:	000ac797          	auipc	a5,0xac
ffffffffc0200560:	3207be23          	sd	zero,828(a5) # ffffffffc02ac898 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200564:	b12d                	j	ffffffffc020018e <cprintf>

ffffffffc0200566 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200566:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020056a:	000ac797          	auipc	a5,0xac
ffffffffc020056e:	2de78793          	addi	a5,a5,734 # ffffffffc02ac848 <timebase>
ffffffffc0200572:	639c                	ld	a5,0(a5)
ffffffffc0200574:	4581                	li	a1,0
ffffffffc0200576:	4601                	li	a2,0
ffffffffc0200578:	953e                	add	a0,a0,a5
ffffffffc020057a:	4881                	li	a7,0
ffffffffc020057c:	00000073          	ecall
ffffffffc0200580:	8082                	ret

ffffffffc0200582 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200582:	8082                	ret

ffffffffc0200584 <cons_putc>:
#include <sched.h>
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200584:	100027f3          	csrr	a5,sstatus
ffffffffc0200588:	8b89                	andi	a5,a5,2
ffffffffc020058a:	0ff57513          	andi	a0,a0,255
ffffffffc020058e:	e799                	bnez	a5,ffffffffc020059c <cons_putc+0x18>
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200590:	4581                	li	a1,0
ffffffffc0200592:	4601                	li	a2,0
ffffffffc0200594:	4885                	li	a7,1
ffffffffc0200596:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc020059a:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020059c:	1101                	addi	sp,sp,-32
ffffffffc020059e:	ec06                	sd	ra,24(sp)
ffffffffc02005a0:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02005a2:	0b0000ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc02005a6:	6522                	ld	a0,8(sp)
ffffffffc02005a8:	4581                	li	a1,0
ffffffffc02005aa:	4601                	li	a2,0
ffffffffc02005ac:	4885                	li	a7,1
ffffffffc02005ae:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc02005b2:	60e2                	ld	ra,24(sp)
ffffffffc02005b4:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02005b6:	a859                	j	ffffffffc020064c <intr_enable>

ffffffffc02005b8 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02005b8:	100027f3          	csrr	a5,sstatus
ffffffffc02005bc:	8b89                	andi	a5,a5,2
ffffffffc02005be:	eb89                	bnez	a5,ffffffffc02005d0 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc02005c0:	4501                	li	a0,0
ffffffffc02005c2:	4581                	li	a1,0
ffffffffc02005c4:	4601                	li	a2,0
ffffffffc02005c6:	4889                	li	a7,2
ffffffffc02005c8:	00000073          	ecall
ffffffffc02005cc:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc02005ce:	8082                	ret
int cons_getc(void) {
ffffffffc02005d0:	1101                	addi	sp,sp,-32
ffffffffc02005d2:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc02005d4:	07e000ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc02005d8:	4501                	li	a0,0
ffffffffc02005da:	4581                	li	a1,0
ffffffffc02005dc:	4601                	li	a2,0
ffffffffc02005de:	4889                	li	a7,2
ffffffffc02005e0:	00000073          	ecall
ffffffffc02005e4:	2501                	sext.w	a0,a0
ffffffffc02005e6:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005e8:	064000ef          	jal	ra,ffffffffc020064c <intr_enable>
}
ffffffffc02005ec:	60e2                	ld	ra,24(sp)
ffffffffc02005ee:	6522                	ld	a0,8(sp)
ffffffffc02005f0:	6105                	addi	sp,sp,32
ffffffffc02005f2:	8082                	ret

ffffffffc02005f4 <ide_init>:
#include <stdio.h>
#include <string.h>
#include <trap.h>
#include <riscv.h>

void ide_init(void) {}
ffffffffc02005f4:	8082                	ret

ffffffffc02005f6 <ide_device_valid>:

#define MAX_IDE 2
#define MAX_DISK_NSECS 56
static char ide[MAX_DISK_NSECS * SECTSIZE];

bool ide_device_valid(unsigned short ideno) { return ideno < MAX_IDE; }
ffffffffc02005f6:	00253513          	sltiu	a0,a0,2
ffffffffc02005fa:	8082                	ret

ffffffffc02005fc <ide_device_size>:

size_t ide_device_size(unsigned short ideno) { return MAX_DISK_NSECS; }
ffffffffc02005fc:	03800513          	li	a0,56
ffffffffc0200600:	8082                	ret

ffffffffc0200602 <ide_read_secs>:

int ide_read_secs(unsigned short ideno, uint32_t secno, void *dst,
                  size_t nsecs) {
    int iobase = secno * SECTSIZE;
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200602:	000a1797          	auipc	a5,0xa1
ffffffffc0200606:	23e78793          	addi	a5,a5,574 # ffffffffc02a1840 <ide>
ffffffffc020060a:	0095959b          	slliw	a1,a1,0x9
                  size_t nsecs) {
ffffffffc020060e:	1141                	addi	sp,sp,-16
ffffffffc0200610:	8532                	mv	a0,a2
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc0200612:	95be                	add	a1,a1,a5
ffffffffc0200614:	00969613          	slli	a2,a3,0x9
                  size_t nsecs) {
ffffffffc0200618:	e406                	sd	ra,8(sp)
    memcpy(dst, &ide[iobase], nsecs * SECTSIZE);
ffffffffc020061a:	7a9050ef          	jal	ra,ffffffffc02065c2 <memcpy>
    return 0;
}
ffffffffc020061e:	60a2                	ld	ra,8(sp)
ffffffffc0200620:	4501                	li	a0,0
ffffffffc0200622:	0141                	addi	sp,sp,16
ffffffffc0200624:	8082                	ret

ffffffffc0200626 <ide_write_secs>:

int ide_write_secs(unsigned short ideno, uint32_t secno, const void *src,
                   size_t nsecs) {
ffffffffc0200626:	8732                	mv	a4,a2
    int iobase = secno * SECTSIZE;
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200628:	0095979b          	slliw	a5,a1,0x9
ffffffffc020062c:	000a1517          	auipc	a0,0xa1
ffffffffc0200630:	21450513          	addi	a0,a0,532 # ffffffffc02a1840 <ide>
                   size_t nsecs) {
ffffffffc0200634:	1141                	addi	sp,sp,-16
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200636:	00969613          	slli	a2,a3,0x9
ffffffffc020063a:	85ba                	mv	a1,a4
ffffffffc020063c:	953e                	add	a0,a0,a5
                   size_t nsecs) {
ffffffffc020063e:	e406                	sd	ra,8(sp)
    memcpy(&ide[iobase], src, nsecs * SECTSIZE);
ffffffffc0200640:	783050ef          	jal	ra,ffffffffc02065c2 <memcpy>
    return 0;
}
ffffffffc0200644:	60a2                	ld	ra,8(sp)
ffffffffc0200646:	4501                	li	a0,0
ffffffffc0200648:	0141                	addi	sp,sp,16
ffffffffc020064a:	8082                	ret

ffffffffc020064c <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc020064c:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200650:	8082                	ret

ffffffffc0200652 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200652:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200656:	8082                	ret

ffffffffc0200658 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200658:	8082                	ret

ffffffffc020065a <idt_init>:
void
idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020065a:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020065e:	00000797          	auipc	a5,0x0
ffffffffc0200662:	66a78793          	addi	a5,a5,1642 # ffffffffc0200cc8 <__alltraps>
ffffffffc0200666:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020066a:	000407b7          	lui	a5,0x40
ffffffffc020066e:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200672:	8082                	ret

ffffffffc0200674 <print_regs>:
    cprintf("  tval 0x%08x\n", tf->tval);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs* gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200674:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs* gpr) {
ffffffffc0200676:	1141                	addi	sp,sp,-16
ffffffffc0200678:	e022                	sd	s0,0(sp)
ffffffffc020067a:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020067c:	00006517          	auipc	a0,0x6
ffffffffc0200680:	59c50513          	addi	a0,a0,1436 # ffffffffc0206c18 <commands+0x508>
void print_regs(struct pushregs* gpr) {
ffffffffc0200684:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200686:	b09ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020068a:	640c                	ld	a1,8(s0)
ffffffffc020068c:	00006517          	auipc	a0,0x6
ffffffffc0200690:	5a450513          	addi	a0,a0,1444 # ffffffffc0206c30 <commands+0x520>
ffffffffc0200694:	afbff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200698:	680c                	ld	a1,16(s0)
ffffffffc020069a:	00006517          	auipc	a0,0x6
ffffffffc020069e:	5ae50513          	addi	a0,a0,1454 # ffffffffc0206c48 <commands+0x538>
ffffffffc02006a2:	aedff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02006a6:	6c0c                	ld	a1,24(s0)
ffffffffc02006a8:	00006517          	auipc	a0,0x6
ffffffffc02006ac:	5b850513          	addi	a0,a0,1464 # ffffffffc0206c60 <commands+0x550>
ffffffffc02006b0:	adfff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02006b4:	700c                	ld	a1,32(s0)
ffffffffc02006b6:	00006517          	auipc	a0,0x6
ffffffffc02006ba:	5c250513          	addi	a0,a0,1474 # ffffffffc0206c78 <commands+0x568>
ffffffffc02006be:	ad1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02006c2:	740c                	ld	a1,40(s0)
ffffffffc02006c4:	00006517          	auipc	a0,0x6
ffffffffc02006c8:	5cc50513          	addi	a0,a0,1484 # ffffffffc0206c90 <commands+0x580>
ffffffffc02006cc:	ac3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02006d0:	780c                	ld	a1,48(s0)
ffffffffc02006d2:	00006517          	auipc	a0,0x6
ffffffffc02006d6:	5d650513          	addi	a0,a0,1494 # ffffffffc0206ca8 <commands+0x598>
ffffffffc02006da:	ab5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02006de:	7c0c                	ld	a1,56(s0)
ffffffffc02006e0:	00006517          	auipc	a0,0x6
ffffffffc02006e4:	5e050513          	addi	a0,a0,1504 # ffffffffc0206cc0 <commands+0x5b0>
ffffffffc02006e8:	aa7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02006ec:	602c                	ld	a1,64(s0)
ffffffffc02006ee:	00006517          	auipc	a0,0x6
ffffffffc02006f2:	5ea50513          	addi	a0,a0,1514 # ffffffffc0206cd8 <commands+0x5c8>
ffffffffc02006f6:	a99ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02006fa:	642c                	ld	a1,72(s0)
ffffffffc02006fc:	00006517          	auipc	a0,0x6
ffffffffc0200700:	5f450513          	addi	a0,a0,1524 # ffffffffc0206cf0 <commands+0x5e0>
ffffffffc0200704:	a8bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200708:	682c                	ld	a1,80(s0)
ffffffffc020070a:	00006517          	auipc	a0,0x6
ffffffffc020070e:	5fe50513          	addi	a0,a0,1534 # ffffffffc0206d08 <commands+0x5f8>
ffffffffc0200712:	a7dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200716:	6c2c                	ld	a1,88(s0)
ffffffffc0200718:	00006517          	auipc	a0,0x6
ffffffffc020071c:	60850513          	addi	a0,a0,1544 # ffffffffc0206d20 <commands+0x610>
ffffffffc0200720:	a6fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200724:	702c                	ld	a1,96(s0)
ffffffffc0200726:	00006517          	auipc	a0,0x6
ffffffffc020072a:	61250513          	addi	a0,a0,1554 # ffffffffc0206d38 <commands+0x628>
ffffffffc020072e:	a61ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200732:	742c                	ld	a1,104(s0)
ffffffffc0200734:	00006517          	auipc	a0,0x6
ffffffffc0200738:	61c50513          	addi	a0,a0,1564 # ffffffffc0206d50 <commands+0x640>
ffffffffc020073c:	a53ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200740:	782c                	ld	a1,112(s0)
ffffffffc0200742:	00006517          	auipc	a0,0x6
ffffffffc0200746:	62650513          	addi	a0,a0,1574 # ffffffffc0206d68 <commands+0x658>
ffffffffc020074a:	a45ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc020074e:	7c2c                	ld	a1,120(s0)
ffffffffc0200750:	00006517          	auipc	a0,0x6
ffffffffc0200754:	63050513          	addi	a0,a0,1584 # ffffffffc0206d80 <commands+0x670>
ffffffffc0200758:	a37ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020075c:	604c                	ld	a1,128(s0)
ffffffffc020075e:	00006517          	auipc	a0,0x6
ffffffffc0200762:	63a50513          	addi	a0,a0,1594 # ffffffffc0206d98 <commands+0x688>
ffffffffc0200766:	a29ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020076a:	644c                	ld	a1,136(s0)
ffffffffc020076c:	00006517          	auipc	a0,0x6
ffffffffc0200770:	64450513          	addi	a0,a0,1604 # ffffffffc0206db0 <commands+0x6a0>
ffffffffc0200774:	a1bff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200778:	684c                	ld	a1,144(s0)
ffffffffc020077a:	00006517          	auipc	a0,0x6
ffffffffc020077e:	64e50513          	addi	a0,a0,1614 # ffffffffc0206dc8 <commands+0x6b8>
ffffffffc0200782:	a0dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200786:	6c4c                	ld	a1,152(s0)
ffffffffc0200788:	00006517          	auipc	a0,0x6
ffffffffc020078c:	65850513          	addi	a0,a0,1624 # ffffffffc0206de0 <commands+0x6d0>
ffffffffc0200790:	9ffff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200794:	704c                	ld	a1,160(s0)
ffffffffc0200796:	00006517          	auipc	a0,0x6
ffffffffc020079a:	66250513          	addi	a0,a0,1634 # ffffffffc0206df8 <commands+0x6e8>
ffffffffc020079e:	9f1ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02007a2:	744c                	ld	a1,168(s0)
ffffffffc02007a4:	00006517          	auipc	a0,0x6
ffffffffc02007a8:	66c50513          	addi	a0,a0,1644 # ffffffffc0206e10 <commands+0x700>
ffffffffc02007ac:	9e3ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02007b0:	784c                	ld	a1,176(s0)
ffffffffc02007b2:	00006517          	auipc	a0,0x6
ffffffffc02007b6:	67650513          	addi	a0,a0,1654 # ffffffffc0206e28 <commands+0x718>
ffffffffc02007ba:	9d5ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02007be:	7c4c                	ld	a1,184(s0)
ffffffffc02007c0:	00006517          	auipc	a0,0x6
ffffffffc02007c4:	68050513          	addi	a0,a0,1664 # ffffffffc0206e40 <commands+0x730>
ffffffffc02007c8:	9c7ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02007cc:	606c                	ld	a1,192(s0)
ffffffffc02007ce:	00006517          	auipc	a0,0x6
ffffffffc02007d2:	68a50513          	addi	a0,a0,1674 # ffffffffc0206e58 <commands+0x748>
ffffffffc02007d6:	9b9ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02007da:	646c                	ld	a1,200(s0)
ffffffffc02007dc:	00006517          	auipc	a0,0x6
ffffffffc02007e0:	69450513          	addi	a0,a0,1684 # ffffffffc0206e70 <commands+0x760>
ffffffffc02007e4:	9abff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02007e8:	686c                	ld	a1,208(s0)
ffffffffc02007ea:	00006517          	auipc	a0,0x6
ffffffffc02007ee:	69e50513          	addi	a0,a0,1694 # ffffffffc0206e88 <commands+0x778>
ffffffffc02007f2:	99dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02007f6:	6c6c                	ld	a1,216(s0)
ffffffffc02007f8:	00006517          	auipc	a0,0x6
ffffffffc02007fc:	6a850513          	addi	a0,a0,1704 # ffffffffc0206ea0 <commands+0x790>
ffffffffc0200800:	98fff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200804:	706c                	ld	a1,224(s0)
ffffffffc0200806:	00006517          	auipc	a0,0x6
ffffffffc020080a:	6b250513          	addi	a0,a0,1714 # ffffffffc0206eb8 <commands+0x7a8>
ffffffffc020080e:	981ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200812:	746c                	ld	a1,232(s0)
ffffffffc0200814:	00006517          	auipc	a0,0x6
ffffffffc0200818:	6bc50513          	addi	a0,a0,1724 # ffffffffc0206ed0 <commands+0x7c0>
ffffffffc020081c:	973ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200820:	786c                	ld	a1,240(s0)
ffffffffc0200822:	00006517          	auipc	a0,0x6
ffffffffc0200826:	6c650513          	addi	a0,a0,1734 # ffffffffc0206ee8 <commands+0x7d8>
ffffffffc020082a:	965ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020082e:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200830:	6402                	ld	s0,0(sp)
ffffffffc0200832:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200834:	00006517          	auipc	a0,0x6
ffffffffc0200838:	6cc50513          	addi	a0,a0,1740 # ffffffffc0206f00 <commands+0x7f0>
}
ffffffffc020083c:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020083e:	ba81                	j	ffffffffc020018e <cprintf>

ffffffffc0200840 <print_trapframe>:
print_trapframe(struct trapframe *tf) {
ffffffffc0200840:	1141                	addi	sp,sp,-16
ffffffffc0200842:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200844:	85aa                	mv	a1,a0
print_trapframe(struct trapframe *tf) {
ffffffffc0200846:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200848:	00006517          	auipc	a0,0x6
ffffffffc020084c:	6d050513          	addi	a0,a0,1744 # ffffffffc0206f18 <commands+0x808>
print_trapframe(struct trapframe *tf) {
ffffffffc0200850:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200852:	93dff0ef          	jal	ra,ffffffffc020018e <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200856:	8522                	mv	a0,s0
ffffffffc0200858:	e1dff0ef          	jal	ra,ffffffffc0200674 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020085c:	10043583          	ld	a1,256(s0)
ffffffffc0200860:	00006517          	auipc	a0,0x6
ffffffffc0200864:	6d050513          	addi	a0,a0,1744 # ffffffffc0206f30 <commands+0x820>
ffffffffc0200868:	927ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020086c:	10843583          	ld	a1,264(s0)
ffffffffc0200870:	00006517          	auipc	a0,0x6
ffffffffc0200874:	6d850513          	addi	a0,a0,1752 # ffffffffc0206f48 <commands+0x838>
ffffffffc0200878:	917ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc020087c:	11043583          	ld	a1,272(s0)
ffffffffc0200880:	00006517          	auipc	a0,0x6
ffffffffc0200884:	6e050513          	addi	a0,a0,1760 # ffffffffc0206f60 <commands+0x850>
ffffffffc0200888:	907ff0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020088c:	11843583          	ld	a1,280(s0)
}
ffffffffc0200890:	6402                	ld	s0,0(sp)
ffffffffc0200892:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200894:	00006517          	auipc	a0,0x6
ffffffffc0200898:	6dc50513          	addi	a0,a0,1756 # ffffffffc0206f70 <commands+0x860>
}
ffffffffc020089c:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020089e:	8f1ff06f          	j	ffffffffc020018e <cprintf>

ffffffffc02008a2 <pgfault_handler>:
            trap_in_kernel(tf) ? 'K' : 'U',
            tf->cause == CAUSE_STORE_PAGE_FAULT ? 'W' : 'R');
}

static int
pgfault_handler(struct trapframe *tf) {
ffffffffc02008a2:	1101                	addi	sp,sp,-32
ffffffffc02008a4:	e426                	sd	s1,8(sp)
    extern struct mm_struct *check_mm_struct;
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008a6:	000ac497          	auipc	s1,0xac
ffffffffc02008aa:	10a48493          	addi	s1,s1,266 # ffffffffc02ac9b0 <check_mm_struct>
ffffffffc02008ae:	609c                	ld	a5,0(s1)
pgfault_handler(struct trapframe *tf) {
ffffffffc02008b0:	e822                	sd	s0,16(sp)
ffffffffc02008b2:	ec06                	sd	ra,24(sp)
ffffffffc02008b4:	842a                	mv	s0,a0
    if(check_mm_struct !=NULL) { //used for test check_swap
ffffffffc02008b6:	cbbd                	beqz	a5,ffffffffc020092c <pgfault_handler+0x8a>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008b8:	10053783          	ld	a5,256(a0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008bc:	11053583          	ld	a1,272(a0)
ffffffffc02008c0:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc02008c4:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02008c8:	cba1                	beqz	a5,ffffffffc0200918 <pgfault_handler+0x76>
ffffffffc02008ca:	11843703          	ld	a4,280(s0)
ffffffffc02008ce:	47bd                	li	a5,15
ffffffffc02008d0:	05700693          	li	a3,87
ffffffffc02008d4:	00f70463          	beq	a4,a5,ffffffffc02008dc <pgfault_handler+0x3a>
ffffffffc02008d8:	05200693          	li	a3,82
ffffffffc02008dc:	00006517          	auipc	a0,0x6
ffffffffc02008e0:	2bc50513          	addi	a0,a0,700 # ffffffffc0206b98 <commands+0x488>
ffffffffc02008e4:	8abff0ef          	jal	ra,ffffffffc020018e <cprintf>
            print_pgfault(tf);
        }
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc02008e8:	6088                	ld	a0,0(s1)
ffffffffc02008ea:	c129                	beqz	a0,ffffffffc020092c <pgfault_handler+0x8a>
        assert(current == idleproc);
ffffffffc02008ec:	000ac797          	auipc	a5,0xac
ffffffffc02008f0:	f8c78793          	addi	a5,a5,-116 # ffffffffc02ac878 <current>
ffffffffc02008f4:	6398                	ld	a4,0(a5)
ffffffffc02008f6:	000ac797          	auipc	a5,0xac
ffffffffc02008fa:	f8a78793          	addi	a5,a5,-118 # ffffffffc02ac880 <idleproc>
ffffffffc02008fe:	639c                	ld	a5,0(a5)
ffffffffc0200900:	04f71763          	bne	a4,a5,ffffffffc020094e <pgfault_handler+0xac>
            print_pgfault(tf);
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200904:	11043603          	ld	a2,272(s0)
ffffffffc0200908:	11843583          	ld	a1,280(s0)
}
ffffffffc020090c:	6442                	ld	s0,16(sp)
ffffffffc020090e:	60e2                	ld	ra,24(sp)
ffffffffc0200910:	64a2                	ld	s1,8(sp)
ffffffffc0200912:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200914:	0580406f          	j	ffffffffc020496c <do_pgfault>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200918:	11843703          	ld	a4,280(s0)
ffffffffc020091c:	47bd                	li	a5,15
ffffffffc020091e:	05500613          	li	a2,85
ffffffffc0200922:	05700693          	li	a3,87
ffffffffc0200926:	faf719e3          	bne	a4,a5,ffffffffc02008d8 <pgfault_handler+0x36>
ffffffffc020092a:	bf4d                	j	ffffffffc02008dc <pgfault_handler+0x3a>
        if (current == NULL) {
ffffffffc020092c:	000ac797          	auipc	a5,0xac
ffffffffc0200930:	f4c78793          	addi	a5,a5,-180 # ffffffffc02ac878 <current>
ffffffffc0200934:	639c                	ld	a5,0(a5)
ffffffffc0200936:	cf85                	beqz	a5,ffffffffc020096e <pgfault_handler+0xcc>
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200938:	11043603          	ld	a2,272(s0)
ffffffffc020093c:	11843583          	ld	a1,280(s0)
}
ffffffffc0200940:	6442                	ld	s0,16(sp)
ffffffffc0200942:	60e2                	ld	ra,24(sp)
ffffffffc0200944:	64a2                	ld	s1,8(sp)
        mm = current->mm;
ffffffffc0200946:	7788                	ld	a0,40(a5)
}
ffffffffc0200948:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc020094a:	0220406f          	j	ffffffffc020496c <do_pgfault>
        assert(current == idleproc);
ffffffffc020094e:	00006697          	auipc	a3,0x6
ffffffffc0200952:	26a68693          	addi	a3,a3,618 # ffffffffc0206bb8 <commands+0x4a8>
ffffffffc0200956:	00006617          	auipc	a2,0x6
ffffffffc020095a:	27a60613          	addi	a2,a2,634 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020095e:	06b00593          	li	a1,107
ffffffffc0200962:	00006517          	auipc	a0,0x6
ffffffffc0200966:	28650513          	addi	a0,a0,646 # ffffffffc0206be8 <commands+0x4d8>
ffffffffc020096a:	b17ff0ef          	jal	ra,ffffffffc0200480 <__panic>
            print_trapframe(tf);
ffffffffc020096e:	8522                	mv	a0,s0
ffffffffc0200970:	ed1ff0ef          	jal	ra,ffffffffc0200840 <print_trapframe>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200974:	10043783          	ld	a5,256(s0)
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200978:	11043583          	ld	a1,272(s0)
ffffffffc020097c:	04b00613          	li	a2,75
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200980:	1007f793          	andi	a5,a5,256
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc0200984:	e399                	bnez	a5,ffffffffc020098a <pgfault_handler+0xe8>
ffffffffc0200986:	05500613          	li	a2,85
ffffffffc020098a:	11843703          	ld	a4,280(s0)
ffffffffc020098e:	47bd                	li	a5,15
ffffffffc0200990:	02f70663          	beq	a4,a5,ffffffffc02009bc <pgfault_handler+0x11a>
ffffffffc0200994:	05200693          	li	a3,82
ffffffffc0200998:	00006517          	auipc	a0,0x6
ffffffffc020099c:	20050513          	addi	a0,a0,512 # ffffffffc0206b98 <commands+0x488>
ffffffffc02009a0:	feeff0ef          	jal	ra,ffffffffc020018e <cprintf>
            panic("unhandled page fault.\n");
ffffffffc02009a4:	00006617          	auipc	a2,0x6
ffffffffc02009a8:	25c60613          	addi	a2,a2,604 # ffffffffc0206c00 <commands+0x4f0>
ffffffffc02009ac:	07200593          	li	a1,114
ffffffffc02009b0:	00006517          	auipc	a0,0x6
ffffffffc02009b4:	23850513          	addi	a0,a0,568 # ffffffffc0206be8 <commands+0x4d8>
ffffffffc02009b8:	ac9ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    cprintf("page fault at 0x%08x: %c/%c\n", tf->tval,
ffffffffc02009bc:	05700693          	li	a3,87
ffffffffc02009c0:	bfe1                	j	ffffffffc0200998 <pgfault_handler+0xf6>

ffffffffc02009c2 <interrupt_handler>:

static volatile int in_swap_tick_event = 0;
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009c2:	11853783          	ld	a5,280(a0)
    switch (cause) {
ffffffffc02009c6:	472d                	li	a4,11
    intptr_t cause = (tf->cause << 1) >> 1;
ffffffffc02009c8:	0786                	slli	a5,a5,0x1
ffffffffc02009ca:	8385                	srli	a5,a5,0x1
    switch (cause) {
ffffffffc02009cc:	08f76763          	bltu	a4,a5,ffffffffc0200a5a <interrupt_handler+0x98>
ffffffffc02009d0:	00006717          	auipc	a4,0x6
ffffffffc02009d4:	f1c70713          	addi	a4,a4,-228 # ffffffffc02068ec <commands+0x1dc>
ffffffffc02009d8:	078a                	slli	a5,a5,0x2
ffffffffc02009da:	97ba                	add	a5,a5,a4
ffffffffc02009dc:	439c                	lw	a5,0(a5)
ffffffffc02009de:	97ba                	add	a5,a5,a4
ffffffffc02009e0:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc02009e2:	00006517          	auipc	a0,0x6
ffffffffc02009e6:	17650513          	addi	a0,a0,374 # ffffffffc0206b58 <commands+0x448>
ffffffffc02009ea:	fa4ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02009ee:	00006517          	auipc	a0,0x6
ffffffffc02009f2:	14a50513          	addi	a0,a0,330 # ffffffffc0206b38 <commands+0x428>
ffffffffc02009f6:	f98ff06f          	j	ffffffffc020018e <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02009fa:	00006517          	auipc	a0,0x6
ffffffffc02009fe:	0fe50513          	addi	a0,a0,254 # ffffffffc0206af8 <commands+0x3e8>
ffffffffc0200a02:	f8cff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200a06:	00006517          	auipc	a0,0x6
ffffffffc0200a0a:	11250513          	addi	a0,a0,274 # ffffffffc0206b18 <commands+0x408>
ffffffffc0200a0e:	f80ff06f          	j	ffffffffc020018e <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a12:	00006517          	auipc	a0,0x6
ffffffffc0200a16:	16650513          	addi	a0,a0,358 # ffffffffc0206b78 <commands+0x468>
ffffffffc0200a1a:	f74ff06f          	j	ffffffffc020018e <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a1e:	1141                	addi	sp,sp,-16
ffffffffc0200a20:	e406                	sd	ra,8(sp)
            clock_set_next_event();
ffffffffc0200a22:	b45ff0ef          	jal	ra,ffffffffc0200566 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0 && current) {
ffffffffc0200a26:	000ac797          	auipc	a5,0xac
ffffffffc0200a2a:	e7278793          	addi	a5,a5,-398 # ffffffffc02ac898 <ticks>
ffffffffc0200a2e:	639c                	ld	a5,0(a5)
ffffffffc0200a30:	06400713          	li	a4,100
ffffffffc0200a34:	0785                	addi	a5,a5,1
ffffffffc0200a36:	02e7f733          	remu	a4,a5,a4
ffffffffc0200a3a:	000ac697          	auipc	a3,0xac
ffffffffc0200a3e:	e4f6bf23          	sd	a5,-418(a3) # ffffffffc02ac898 <ticks>
ffffffffc0200a42:	eb09                	bnez	a4,ffffffffc0200a54 <interrupt_handler+0x92>
ffffffffc0200a44:	000ac797          	auipc	a5,0xac
ffffffffc0200a48:	e3478793          	addi	a5,a5,-460 # ffffffffc02ac878 <current>
ffffffffc0200a4c:	639c                	ld	a5,0(a5)
ffffffffc0200a4e:	c399                	beqz	a5,ffffffffc0200a54 <interrupt_handler+0x92>
                current->need_resched = 1;
ffffffffc0200a50:	4705                	li	a4,1
ffffffffc0200a52:	ef98                	sd	a4,24(a5)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a54:	60a2                	ld	ra,8(sp)
ffffffffc0200a56:	0141                	addi	sp,sp,16
ffffffffc0200a58:	8082                	ret
            print_trapframe(tf);
ffffffffc0200a5a:	b3dd                	j	ffffffffc0200840 <print_trapframe>

ffffffffc0200a5c <exception_handler>:
void kernel_execve_ret(struct trapframe *tf,uintptr_t kstacktop);
void exception_handler(struct trapframe *tf) {
    int ret;
    switch (tf->cause) {
ffffffffc0200a5c:	11853783          	ld	a5,280(a0)
ffffffffc0200a60:	473d                	li	a4,15
ffffffffc0200a62:	1af76c63          	bltu	a4,a5,ffffffffc0200c1a <exception_handler+0x1be>
ffffffffc0200a66:	00006717          	auipc	a4,0x6
ffffffffc0200a6a:	eb670713          	addi	a4,a4,-330 # ffffffffc020691c <commands+0x20c>
ffffffffc0200a6e:	078a                	slli	a5,a5,0x2
ffffffffc0200a70:	97ba                	add	a5,a5,a4
ffffffffc0200a72:	439c                	lw	a5,0(a5)
void exception_handler(struct trapframe *tf) {
ffffffffc0200a74:	1101                	addi	sp,sp,-32
ffffffffc0200a76:	e822                	sd	s0,16(sp)
ffffffffc0200a78:	ec06                	sd	ra,24(sp)
ffffffffc0200a7a:	e426                	sd	s1,8(sp)
    switch (tf->cause) {
ffffffffc0200a7c:	97ba                	add	a5,a5,a4
ffffffffc0200a7e:	842a                	mv	s0,a0
ffffffffc0200a80:	8782                	jr	a5
            //cprintf("Environment call from U-mode\n");
            tf->epc += 4;
            syscall();
            break;
        case CAUSE_SUPERVISOR_ECALL:
            cprintf("Environment call from S-mode\n");
ffffffffc0200a82:	00006517          	auipc	a0,0x6
ffffffffc0200a86:	fce50513          	addi	a0,a0,-50 # ffffffffc0206a50 <commands+0x340>
ffffffffc0200a8a:	f04ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            tf->epc += 4;
ffffffffc0200a8e:	10843783          	ld	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a92:	60e2                	ld	ra,24(sp)
ffffffffc0200a94:	64a2                	ld	s1,8(sp)
            tf->epc += 4;
ffffffffc0200a96:	0791                	addi	a5,a5,4
ffffffffc0200a98:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200a9c:	6442                	ld	s0,16(sp)
ffffffffc0200a9e:	6105                	addi	sp,sp,32
            syscall();
ffffffffc0200aa0:	5ee0506f          	j	ffffffffc020608e <syscall>
            cprintf("Environment call from H-mode\n");
ffffffffc0200aa4:	00006517          	auipc	a0,0x6
ffffffffc0200aa8:	fcc50513          	addi	a0,a0,-52 # ffffffffc0206a70 <commands+0x360>
}
ffffffffc0200aac:	6442                	ld	s0,16(sp)
ffffffffc0200aae:	60e2                	ld	ra,24(sp)
ffffffffc0200ab0:	64a2                	ld	s1,8(sp)
ffffffffc0200ab2:	6105                	addi	sp,sp,32
            cprintf("Instruction access fault\n");
ffffffffc0200ab4:	edaff06f          	j	ffffffffc020018e <cprintf>
            cprintf("Environment call from M-mode\n");
ffffffffc0200ab8:	00006517          	auipc	a0,0x6
ffffffffc0200abc:	fd850513          	addi	a0,a0,-40 # ffffffffc0206a90 <commands+0x380>
ffffffffc0200ac0:	b7f5                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Instruction page fault\n");
ffffffffc0200ac2:	00006517          	auipc	a0,0x6
ffffffffc0200ac6:	fee50513          	addi	a0,a0,-18 # ffffffffc0206ab0 <commands+0x3a0>
ffffffffc0200aca:	b7cd                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Load page fault\n");
ffffffffc0200acc:	00006517          	auipc	a0,0x6
ffffffffc0200ad0:	ffc50513          	addi	a0,a0,-4 # ffffffffc0206ac8 <commands+0x3b8>
ffffffffc0200ad4:	ebaff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200ad8:	8522                	mv	a0,s0
ffffffffc0200ada:	dc9ff0ef          	jal	ra,ffffffffc02008a2 <pgfault_handler>
ffffffffc0200ade:	84aa                	mv	s1,a0
ffffffffc0200ae0:	12051e63          	bnez	a0,ffffffffc0200c1c <exception_handler+0x1c0>
}
ffffffffc0200ae4:	60e2                	ld	ra,24(sp)
ffffffffc0200ae6:	6442                	ld	s0,16(sp)
ffffffffc0200ae8:	64a2                	ld	s1,8(sp)
ffffffffc0200aea:	6105                	addi	sp,sp,32
ffffffffc0200aec:	8082                	ret
            cprintf("Store/AMO page fault\n");
ffffffffc0200aee:	00006517          	auipc	a0,0x6
ffffffffc0200af2:	ff250513          	addi	a0,a0,-14 # ffffffffc0206ae0 <commands+0x3d0>
ffffffffc0200af6:	e98ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200afa:	8522                	mv	a0,s0
ffffffffc0200afc:	da7ff0ef          	jal	ra,ffffffffc02008a2 <pgfault_handler>
ffffffffc0200b00:	84aa                	mv	s1,a0
ffffffffc0200b02:	d16d                	beqz	a0,ffffffffc0200ae4 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200b04:	8522                	mv	a0,s0
ffffffffc0200b06:	d3bff0ef          	jal	ra,ffffffffc0200840 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200b0a:	86a6                	mv	a3,s1
ffffffffc0200b0c:	00006617          	auipc	a2,0x6
ffffffffc0200b10:	ef460613          	addi	a2,a2,-268 # ffffffffc0206a00 <commands+0x2f0>
ffffffffc0200b14:	0f800593          	li	a1,248
ffffffffc0200b18:	00006517          	auipc	a0,0x6
ffffffffc0200b1c:	0d050513          	addi	a0,a0,208 # ffffffffc0206be8 <commands+0x4d8>
ffffffffc0200b20:	961ff0ef          	jal	ra,ffffffffc0200480 <__panic>
            cprintf("Instruction address misaligned\n");
ffffffffc0200b24:	00006517          	auipc	a0,0x6
ffffffffc0200b28:	e3c50513          	addi	a0,a0,-452 # ffffffffc0206960 <commands+0x250>
ffffffffc0200b2c:	b741                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Instruction access fault\n");
ffffffffc0200b2e:	00006517          	auipc	a0,0x6
ffffffffc0200b32:	e5250513          	addi	a0,a0,-430 # ffffffffc0206980 <commands+0x270>
ffffffffc0200b36:	bf9d                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Illegal instruction\n");
ffffffffc0200b38:	00006517          	auipc	a0,0x6
ffffffffc0200b3c:	e6850513          	addi	a0,a0,-408 # ffffffffc02069a0 <commands+0x290>
ffffffffc0200b40:	b7b5                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Breakpoint\n");
ffffffffc0200b42:	00006517          	auipc	a0,0x6
ffffffffc0200b46:	e7650513          	addi	a0,a0,-394 # ffffffffc02069b8 <commands+0x2a8>
ffffffffc0200b4a:	e44ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if(tf->gpr.a7 == 10){
ffffffffc0200b4e:	6458                	ld	a4,136(s0)
ffffffffc0200b50:	47a9                	li	a5,10
ffffffffc0200b52:	f8f719e3          	bne	a4,a5,ffffffffc0200ae4 <exception_handler+0x88>
                tf->epc += 4;
ffffffffc0200b56:	10843783          	ld	a5,264(s0)
ffffffffc0200b5a:	0791                	addi	a5,a5,4
ffffffffc0200b5c:	10f43423          	sd	a5,264(s0)
                syscall();
ffffffffc0200b60:	52e050ef          	jal	ra,ffffffffc020608e <syscall>
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b64:	000ac797          	auipc	a5,0xac
ffffffffc0200b68:	d1478793          	addi	a5,a5,-748 # ffffffffc02ac878 <current>
ffffffffc0200b6c:	639c                	ld	a5,0(a5)
ffffffffc0200b6e:	8522                	mv	a0,s0
}
ffffffffc0200b70:	6442                	ld	s0,16(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b72:	6b9c                	ld	a5,16(a5)
}
ffffffffc0200b74:	60e2                	ld	ra,24(sp)
ffffffffc0200b76:	64a2                	ld	s1,8(sp)
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b78:	6589                	lui	a1,0x2
ffffffffc0200b7a:	95be                	add	a1,a1,a5
}
ffffffffc0200b7c:	6105                	addi	sp,sp,32
                kernel_execve_ret(tf,current->kstack+KSTACKSIZE);
ffffffffc0200b7e:	ac21                	j	ffffffffc0200d96 <kernel_execve_ret>
            cprintf("Load address misaligned\n");
ffffffffc0200b80:	00006517          	auipc	a0,0x6
ffffffffc0200b84:	e4850513          	addi	a0,a0,-440 # ffffffffc02069c8 <commands+0x2b8>
ffffffffc0200b88:	b715                	j	ffffffffc0200aac <exception_handler+0x50>
            cprintf("Load access fault\n");
ffffffffc0200b8a:	00006517          	auipc	a0,0x6
ffffffffc0200b8e:	e5e50513          	addi	a0,a0,-418 # ffffffffc02069e8 <commands+0x2d8>
ffffffffc0200b92:	dfcff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200b96:	8522                	mv	a0,s0
ffffffffc0200b98:	d0bff0ef          	jal	ra,ffffffffc02008a2 <pgfault_handler>
ffffffffc0200b9c:	84aa                	mv	s1,a0
ffffffffc0200b9e:	d139                	beqz	a0,ffffffffc0200ae4 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200ba0:	8522                	mv	a0,s0
ffffffffc0200ba2:	c9fff0ef          	jal	ra,ffffffffc0200840 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200ba6:	86a6                	mv	a3,s1
ffffffffc0200ba8:	00006617          	auipc	a2,0x6
ffffffffc0200bac:	e5860613          	addi	a2,a2,-424 # ffffffffc0206a00 <commands+0x2f0>
ffffffffc0200bb0:	0cd00593          	li	a1,205
ffffffffc0200bb4:	00006517          	auipc	a0,0x6
ffffffffc0200bb8:	03450513          	addi	a0,a0,52 # ffffffffc0206be8 <commands+0x4d8>
ffffffffc0200bbc:	8c5ff0ef          	jal	ra,ffffffffc0200480 <__panic>
            cprintf("Store/AMO access fault\n");
ffffffffc0200bc0:	00006517          	auipc	a0,0x6
ffffffffc0200bc4:	e7850513          	addi	a0,a0,-392 # ffffffffc0206a38 <commands+0x328>
ffffffffc0200bc8:	dc6ff0ef          	jal	ra,ffffffffc020018e <cprintf>
            if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200bcc:	8522                	mv	a0,s0
ffffffffc0200bce:	cd5ff0ef          	jal	ra,ffffffffc02008a2 <pgfault_handler>
ffffffffc0200bd2:	84aa                	mv	s1,a0
ffffffffc0200bd4:	f00508e3          	beqz	a0,ffffffffc0200ae4 <exception_handler+0x88>
                print_trapframe(tf);
ffffffffc0200bd8:	8522                	mv	a0,s0
ffffffffc0200bda:	c67ff0ef          	jal	ra,ffffffffc0200840 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200bde:	86a6                	mv	a3,s1
ffffffffc0200be0:	00006617          	auipc	a2,0x6
ffffffffc0200be4:	e2060613          	addi	a2,a2,-480 # ffffffffc0206a00 <commands+0x2f0>
ffffffffc0200be8:	0d700593          	li	a1,215
ffffffffc0200bec:	00006517          	auipc	a0,0x6
ffffffffc0200bf0:	ffc50513          	addi	a0,a0,-4 # ffffffffc0206be8 <commands+0x4d8>
ffffffffc0200bf4:	88dff0ef          	jal	ra,ffffffffc0200480 <__panic>
}
ffffffffc0200bf8:	6442                	ld	s0,16(sp)
ffffffffc0200bfa:	60e2                	ld	ra,24(sp)
ffffffffc0200bfc:	64a2                	ld	s1,8(sp)
ffffffffc0200bfe:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200c00:	b181                	j	ffffffffc0200840 <print_trapframe>
            panic("AMO address misaligned\n");
ffffffffc0200c02:	00006617          	auipc	a2,0x6
ffffffffc0200c06:	e1e60613          	addi	a2,a2,-482 # ffffffffc0206a20 <commands+0x310>
ffffffffc0200c0a:	0d100593          	li	a1,209
ffffffffc0200c0e:	00006517          	auipc	a0,0x6
ffffffffc0200c12:	fda50513          	addi	a0,a0,-38 # ffffffffc0206be8 <commands+0x4d8>
ffffffffc0200c16:	86bff0ef          	jal	ra,ffffffffc0200480 <__panic>
            print_trapframe(tf);
ffffffffc0200c1a:	b11d                	j	ffffffffc0200840 <print_trapframe>
                print_trapframe(tf);
ffffffffc0200c1c:	8522                	mv	a0,s0
ffffffffc0200c1e:	c23ff0ef          	jal	ra,ffffffffc0200840 <print_trapframe>
                panic("handle pgfault failed. %e\n", ret);
ffffffffc0200c22:	86a6                	mv	a3,s1
ffffffffc0200c24:	00006617          	auipc	a2,0x6
ffffffffc0200c28:	ddc60613          	addi	a2,a2,-548 # ffffffffc0206a00 <commands+0x2f0>
ffffffffc0200c2c:	0f100593          	li	a1,241
ffffffffc0200c30:	00006517          	auipc	a0,0x6
ffffffffc0200c34:	fb850513          	addi	a0,a0,-72 # ffffffffc0206be8 <commands+0x4d8>
ffffffffc0200c38:	849ff0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0200c3c <trap>:
 * trap - handles or dispatches an exception/interrupt. if and when trap() returns,
 * the code in kern/trap/trapentry.S restores the old CPU state saved in the
 * trapframe and then uses the iret instruction to return from the exception.
 * */
void
trap(struct trapframe *tf) {
ffffffffc0200c3c:	1101                	addi	sp,sp,-32
ffffffffc0200c3e:	e822                	sd	s0,16(sp)
    // dispatch based on what type of trap occurred
//    cputs("some trap");
    if (current == NULL) {
ffffffffc0200c40:	000ac417          	auipc	s0,0xac
ffffffffc0200c44:	c3840413          	addi	s0,s0,-968 # ffffffffc02ac878 <current>
ffffffffc0200c48:	6018                	ld	a4,0(s0)
trap(struct trapframe *tf) {
ffffffffc0200c4a:	ec06                	sd	ra,24(sp)
ffffffffc0200c4c:	e426                	sd	s1,8(sp)
ffffffffc0200c4e:	e04a                	sd	s2,0(sp)
ffffffffc0200c50:	11853683          	ld	a3,280(a0)
    if (current == NULL) {
ffffffffc0200c54:	cf1d                	beqz	a4,ffffffffc0200c92 <trap+0x56>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c56:	10053483          	ld	s1,256(a0)
        trap_dispatch(tf);
    } else {
        struct trapframe *otf = current->tf;
ffffffffc0200c5a:	0a073903          	ld	s2,160(a4)
        current->tf = tf;
ffffffffc0200c5e:	f348                	sd	a0,160(a4)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200c60:	1004f493          	andi	s1,s1,256
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c64:	0206c463          	bltz	a3,ffffffffc0200c8c <trap+0x50>
        exception_handler(tf);
ffffffffc0200c68:	df5ff0ef          	jal	ra,ffffffffc0200a5c <exception_handler>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200c6c:	601c                	ld	a5,0(s0)
ffffffffc0200c6e:	0b27b023          	sd	s2,160(a5)
        if (!in_kernel) {
ffffffffc0200c72:	e499                	bnez	s1,ffffffffc0200c80 <trap+0x44>
            if (current->flags & PF_EXITING) {
ffffffffc0200c74:	0b07a703          	lw	a4,176(a5)
ffffffffc0200c78:	8b05                	andi	a4,a4,1
ffffffffc0200c7a:	e329                	bnez	a4,ffffffffc0200cbc <trap+0x80>
                do_exit(-E_KILLED);
            }
            if (current->need_resched) {
ffffffffc0200c7c:	6f9c                	ld	a5,24(a5)
ffffffffc0200c7e:	eb85                	bnez	a5,ffffffffc0200cae <trap+0x72>
                schedule();
            }
        }
    }
}
ffffffffc0200c80:	60e2                	ld	ra,24(sp)
ffffffffc0200c82:	6442                	ld	s0,16(sp)
ffffffffc0200c84:	64a2                	ld	s1,8(sp)
ffffffffc0200c86:	6902                	ld	s2,0(sp)
ffffffffc0200c88:	6105                	addi	sp,sp,32
ffffffffc0200c8a:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200c8c:	d37ff0ef          	jal	ra,ffffffffc02009c2 <interrupt_handler>
ffffffffc0200c90:	bff1                	j	ffffffffc0200c6c <trap+0x30>
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200c92:	0006c863          	bltz	a3,ffffffffc0200ca2 <trap+0x66>
}
ffffffffc0200c96:	6442                	ld	s0,16(sp)
ffffffffc0200c98:	60e2                	ld	ra,24(sp)
ffffffffc0200c9a:	64a2                	ld	s1,8(sp)
ffffffffc0200c9c:	6902                	ld	s2,0(sp)
ffffffffc0200c9e:	6105                	addi	sp,sp,32
        exception_handler(tf);
ffffffffc0200ca0:	bb75                	j	ffffffffc0200a5c <exception_handler>
}
ffffffffc0200ca2:	6442                	ld	s0,16(sp)
ffffffffc0200ca4:	60e2                	ld	ra,24(sp)
ffffffffc0200ca6:	64a2                	ld	s1,8(sp)
ffffffffc0200ca8:	6902                	ld	s2,0(sp)
ffffffffc0200caa:	6105                	addi	sp,sp,32
        interrupt_handler(tf);
ffffffffc0200cac:	bb19                	j	ffffffffc02009c2 <interrupt_handler>
}
ffffffffc0200cae:	6442                	ld	s0,16(sp)
ffffffffc0200cb0:	60e2                	ld	ra,24(sp)
ffffffffc0200cb2:	64a2                	ld	s1,8(sp)
ffffffffc0200cb4:	6902                	ld	s2,0(sp)
ffffffffc0200cb6:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200cb8:	2e00506f          	j	ffffffffc0205f98 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200cbc:	555d                	li	a0,-9
ffffffffc0200cbe:	6dc040ef          	jal	ra,ffffffffc020539a <do_exit>
ffffffffc0200cc2:	601c                	ld	a5,0(s0)
ffffffffc0200cc4:	bf65                	j	ffffffffc0200c7c <trap+0x40>
	...

ffffffffc0200cc8 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200cc8:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200ccc:	00011463          	bnez	sp,ffffffffc0200cd4 <__alltraps+0xc>
ffffffffc0200cd0:	14002173          	csrr	sp,sscratch
ffffffffc0200cd4:	712d                	addi	sp,sp,-288
ffffffffc0200cd6:	e002                	sd	zero,0(sp)
ffffffffc0200cd8:	e406                	sd	ra,8(sp)
ffffffffc0200cda:	ec0e                	sd	gp,24(sp)
ffffffffc0200cdc:	f012                	sd	tp,32(sp)
ffffffffc0200cde:	f416                	sd	t0,40(sp)
ffffffffc0200ce0:	f81a                	sd	t1,48(sp)
ffffffffc0200ce2:	fc1e                	sd	t2,56(sp)
ffffffffc0200ce4:	e0a2                	sd	s0,64(sp)
ffffffffc0200ce6:	e4a6                	sd	s1,72(sp)
ffffffffc0200ce8:	e8aa                	sd	a0,80(sp)
ffffffffc0200cea:	ecae                	sd	a1,88(sp)
ffffffffc0200cec:	f0b2                	sd	a2,96(sp)
ffffffffc0200cee:	f4b6                	sd	a3,104(sp)
ffffffffc0200cf0:	f8ba                	sd	a4,112(sp)
ffffffffc0200cf2:	fcbe                	sd	a5,120(sp)
ffffffffc0200cf4:	e142                	sd	a6,128(sp)
ffffffffc0200cf6:	e546                	sd	a7,136(sp)
ffffffffc0200cf8:	e94a                	sd	s2,144(sp)
ffffffffc0200cfa:	ed4e                	sd	s3,152(sp)
ffffffffc0200cfc:	f152                	sd	s4,160(sp)
ffffffffc0200cfe:	f556                	sd	s5,168(sp)
ffffffffc0200d00:	f95a                	sd	s6,176(sp)
ffffffffc0200d02:	fd5e                	sd	s7,184(sp)
ffffffffc0200d04:	e1e2                	sd	s8,192(sp)
ffffffffc0200d06:	e5e6                	sd	s9,200(sp)
ffffffffc0200d08:	e9ea                	sd	s10,208(sp)
ffffffffc0200d0a:	edee                	sd	s11,216(sp)
ffffffffc0200d0c:	f1f2                	sd	t3,224(sp)
ffffffffc0200d0e:	f5f6                	sd	t4,232(sp)
ffffffffc0200d10:	f9fa                	sd	t5,240(sp)
ffffffffc0200d12:	fdfe                	sd	t6,248(sp)
ffffffffc0200d14:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200d18:	100024f3          	csrr	s1,sstatus
ffffffffc0200d1c:	14102973          	csrr	s2,sepc
ffffffffc0200d20:	143029f3          	csrr	s3,stval
ffffffffc0200d24:	14202a73          	csrr	s4,scause
ffffffffc0200d28:	e822                	sd	s0,16(sp)
ffffffffc0200d2a:	e226                	sd	s1,256(sp)
ffffffffc0200d2c:	e64a                	sd	s2,264(sp)
ffffffffc0200d2e:	ea4e                	sd	s3,272(sp)
ffffffffc0200d30:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200d32:	850a                	mv	a0,sp
    jal trap
ffffffffc0200d34:	f09ff0ef          	jal	ra,ffffffffc0200c3c <trap>

ffffffffc0200d38 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200d38:	6492                	ld	s1,256(sp)
ffffffffc0200d3a:	6932                	ld	s2,264(sp)
ffffffffc0200d3c:	1004f413          	andi	s0,s1,256
ffffffffc0200d40:	e401                	bnez	s0,ffffffffc0200d48 <__trapret+0x10>
ffffffffc0200d42:	1200                	addi	s0,sp,288
ffffffffc0200d44:	14041073          	csrw	sscratch,s0
ffffffffc0200d48:	10049073          	csrw	sstatus,s1
ffffffffc0200d4c:	14191073          	csrw	sepc,s2
ffffffffc0200d50:	60a2                	ld	ra,8(sp)
ffffffffc0200d52:	61e2                	ld	gp,24(sp)
ffffffffc0200d54:	7202                	ld	tp,32(sp)
ffffffffc0200d56:	72a2                	ld	t0,40(sp)
ffffffffc0200d58:	7342                	ld	t1,48(sp)
ffffffffc0200d5a:	73e2                	ld	t2,56(sp)
ffffffffc0200d5c:	6406                	ld	s0,64(sp)
ffffffffc0200d5e:	64a6                	ld	s1,72(sp)
ffffffffc0200d60:	6546                	ld	a0,80(sp)
ffffffffc0200d62:	65e6                	ld	a1,88(sp)
ffffffffc0200d64:	7606                	ld	a2,96(sp)
ffffffffc0200d66:	76a6                	ld	a3,104(sp)
ffffffffc0200d68:	7746                	ld	a4,112(sp)
ffffffffc0200d6a:	77e6                	ld	a5,120(sp)
ffffffffc0200d6c:	680a                	ld	a6,128(sp)
ffffffffc0200d6e:	68aa                	ld	a7,136(sp)
ffffffffc0200d70:	694a                	ld	s2,144(sp)
ffffffffc0200d72:	69ea                	ld	s3,152(sp)
ffffffffc0200d74:	7a0a                	ld	s4,160(sp)
ffffffffc0200d76:	7aaa                	ld	s5,168(sp)
ffffffffc0200d78:	7b4a                	ld	s6,176(sp)
ffffffffc0200d7a:	7bea                	ld	s7,184(sp)
ffffffffc0200d7c:	6c0e                	ld	s8,192(sp)
ffffffffc0200d7e:	6cae                	ld	s9,200(sp)
ffffffffc0200d80:	6d4e                	ld	s10,208(sp)
ffffffffc0200d82:	6dee                	ld	s11,216(sp)
ffffffffc0200d84:	7e0e                	ld	t3,224(sp)
ffffffffc0200d86:	7eae                	ld	t4,232(sp)
ffffffffc0200d88:	7f4e                	ld	t5,240(sp)
ffffffffc0200d8a:	7fee                	ld	t6,248(sp)
ffffffffc0200d8c:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200d8e:	10200073          	sret

ffffffffc0200d92 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200d92:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200d94:	b755                	j	ffffffffc0200d38 <__trapret>

ffffffffc0200d96 <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200d96:	ee058593          	addi	a1,a1,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x76e8>

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200d9a:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200d9e:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200da2:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200da6:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200daa:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200dae:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200db2:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200db6:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200dba:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200dbc:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200dbe:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200dc0:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200dc2:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200dc4:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200dc6:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200dc8:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200dca:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200dcc:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200dce:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200dd0:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200dd2:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200dd4:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200dd6:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200dd8:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200dda:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200ddc:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200dde:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200de0:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200de2:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200de4:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200de6:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200de8:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200dea:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200dec:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200dee:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200df0:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200df2:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200df4:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200df6:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200df8:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200dfa:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0200dfc:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0200dfe:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0200e00:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0200e02:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0200e04:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc0200e06:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc0200e08:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc0200e0a:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0200e0c:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0200e0e:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0200e10:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0200e12:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0200e14:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc0200e16:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc0200e18:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc0200e1a:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0200e1c:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0200e1e:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0200e20:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0200e22:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0200e24:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc0200e26:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc0200e28:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc0200e2a:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0200e2c:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0200e2e:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0200e30:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0200e32:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0200e34:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc0200e36:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc0200e38:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc0200e3a:	812e                	mv	sp,a1
ffffffffc0200e3c:	bdf5                	j	ffffffffc0200d38 <__trapret>

ffffffffc0200e3e <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e3e:	000ac797          	auipc	a5,0xac
ffffffffc0200e42:	a6278793          	addi	a5,a5,-1438 # ffffffffc02ac8a0 <free_area>
ffffffffc0200e46:	e79c                	sd	a5,8(a5)
ffffffffc0200e48:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200e4a:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200e4e:	8082                	ret

ffffffffc0200e50 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200e50:	000ac517          	auipc	a0,0xac
ffffffffc0200e54:	a6056503          	lwu	a0,-1440(a0) # ffffffffc02ac8b0 <free_area+0x10>
ffffffffc0200e58:	8082                	ret

ffffffffc0200e5a <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200e5a:	715d                	addi	sp,sp,-80
ffffffffc0200e5c:	f84a                	sd	s2,48(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200e5e:	000ac917          	auipc	s2,0xac
ffffffffc0200e62:	a4290913          	addi	s2,s2,-1470 # ffffffffc02ac8a0 <free_area>
ffffffffc0200e66:	00893783          	ld	a5,8(s2)
ffffffffc0200e6a:	e486                	sd	ra,72(sp)
ffffffffc0200e6c:	e0a2                	sd	s0,64(sp)
ffffffffc0200e6e:	fc26                	sd	s1,56(sp)
ffffffffc0200e70:	f44e                	sd	s3,40(sp)
ffffffffc0200e72:	f052                	sd	s4,32(sp)
ffffffffc0200e74:	ec56                	sd	s5,24(sp)
ffffffffc0200e76:	e85a                	sd	s6,16(sp)
ffffffffc0200e78:	e45e                	sd	s7,8(sp)
ffffffffc0200e7a:	e062                	sd	s8,0(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e7c:	31278463          	beq	a5,s2,ffffffffc0201184 <default_check+0x32a>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200e80:	ff07b703          	ld	a4,-16(a5)
ffffffffc0200e84:	8305                	srli	a4,a4,0x1
ffffffffc0200e86:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200e88:	30070263          	beqz	a4,ffffffffc020118c <default_check+0x332>
    int count = 0, total = 0;
ffffffffc0200e8c:	4401                	li	s0,0
ffffffffc0200e8e:	4481                	li	s1,0
ffffffffc0200e90:	a031                	j	ffffffffc0200e9c <default_check+0x42>
ffffffffc0200e92:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0200e96:	8b09                	andi	a4,a4,2
ffffffffc0200e98:	2e070a63          	beqz	a4,ffffffffc020118c <default_check+0x332>
        count ++, total += p->property;
ffffffffc0200e9c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200ea0:	679c                	ld	a5,8(a5)
ffffffffc0200ea2:	2485                	addiw	s1,s1,1
ffffffffc0200ea4:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ea6:	ff2796e3          	bne	a5,s2,ffffffffc0200e92 <default_check+0x38>
ffffffffc0200eaa:	89a2                	mv	s3,s0
    }
    assert(total == nr_free_pages());
ffffffffc0200eac:	046010ef          	jal	ra,ffffffffc0201ef2 <nr_free_pages>
ffffffffc0200eb0:	73351e63          	bne	a0,s3,ffffffffc02015ec <default_check+0x792>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200eb4:	4505                	li	a0,1
ffffffffc0200eb6:	76f000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0200eba:	8a2a                	mv	s4,a0
ffffffffc0200ebc:	46050863          	beqz	a0,ffffffffc020132c <default_check+0x4d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ec0:	4505                	li	a0,1
ffffffffc0200ec2:	763000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0200ec6:	89aa                	mv	s3,a0
ffffffffc0200ec8:	74050263          	beqz	a0,ffffffffc020160c <default_check+0x7b2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ecc:	4505                	li	a0,1
ffffffffc0200ece:	757000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0200ed2:	8aaa                	mv	s5,a0
ffffffffc0200ed4:	4c050c63          	beqz	a0,ffffffffc02013ac <default_check+0x552>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ed8:	2d3a0a63          	beq	s4,s3,ffffffffc02011ac <default_check+0x352>
ffffffffc0200edc:	2caa0863          	beq	s4,a0,ffffffffc02011ac <default_check+0x352>
ffffffffc0200ee0:	2ca98663          	beq	s3,a0,ffffffffc02011ac <default_check+0x352>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200ee4:	000a2783          	lw	a5,0(s4)
ffffffffc0200ee8:	2e079263          	bnez	a5,ffffffffc02011cc <default_check+0x372>
ffffffffc0200eec:	0009a783          	lw	a5,0(s3)
ffffffffc0200ef0:	2c079e63          	bnez	a5,ffffffffc02011cc <default_check+0x372>
ffffffffc0200ef4:	411c                	lw	a5,0(a0)
ffffffffc0200ef6:	2c079b63          	bnez	a5,ffffffffc02011cc <default_check+0x372>
extern size_t npage;
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page) {
    return page - pages + nbase;
ffffffffc0200efa:	000ac797          	auipc	a5,0xac
ffffffffc0200efe:	9d678793          	addi	a5,a5,-1578 # ffffffffc02ac8d0 <pages>
ffffffffc0200f02:	639c                	ld	a5,0(a5)
ffffffffc0200f04:	00008717          	auipc	a4,0x8
ffffffffc0200f08:	db470713          	addi	a4,a4,-588 # ffffffffc0208cb8 <nbase>
ffffffffc0200f0c:	6310                	ld	a2,0(a4)
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f0e:	000ac717          	auipc	a4,0xac
ffffffffc0200f12:	95270713          	addi	a4,a4,-1710 # ffffffffc02ac860 <npage>
ffffffffc0200f16:	6314                	ld	a3,0(a4)
ffffffffc0200f18:	40fa0733          	sub	a4,s4,a5
ffffffffc0200f1c:	8719                	srai	a4,a4,0x6
ffffffffc0200f1e:	9732                	add	a4,a4,a2
ffffffffc0200f20:	06b2                	slli	a3,a3,0xc
}

static inline uintptr_t
page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f22:	0732                	slli	a4,a4,0xc
ffffffffc0200f24:	2cd77463          	bgeu	a4,a3,ffffffffc02011ec <default_check+0x392>
    return page - pages + nbase;
ffffffffc0200f28:	40f98733          	sub	a4,s3,a5
ffffffffc0200f2c:	8719                	srai	a4,a4,0x6
ffffffffc0200f2e:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f30:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200f32:	4ed77d63          	bgeu	a4,a3,ffffffffc020142c <default_check+0x5d2>
    return page - pages + nbase;
ffffffffc0200f36:	40f507b3          	sub	a5,a0,a5
ffffffffc0200f3a:	8799                	srai	a5,a5,0x6
ffffffffc0200f3c:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f3e:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f40:	34d7f663          	bgeu	a5,a3,ffffffffc020128c <default_check+0x432>
    assert(alloc_page() == NULL);
ffffffffc0200f44:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200f46:	00093c03          	ld	s8,0(s2)
ffffffffc0200f4a:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200f4e:	01092b03          	lw	s6,16(s2)
    elm->prev = elm->next = elm;
ffffffffc0200f52:	000ac797          	auipc	a5,0xac
ffffffffc0200f56:	9527bb23          	sd	s2,-1706(a5) # ffffffffc02ac8a8 <free_area+0x8>
ffffffffc0200f5a:	000ac797          	auipc	a5,0xac
ffffffffc0200f5e:	9527b323          	sd	s2,-1722(a5) # ffffffffc02ac8a0 <free_area>
    nr_free = 0;
ffffffffc0200f62:	000ac797          	auipc	a5,0xac
ffffffffc0200f66:	9407a723          	sw	zero,-1714(a5) # ffffffffc02ac8b0 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200f6a:	6bb000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0200f6e:	2e051f63          	bnez	a0,ffffffffc020126c <default_check+0x412>
    free_page(p0);
ffffffffc0200f72:	4585                	li	a1,1
ffffffffc0200f74:	8552                	mv	a0,s4
ffffffffc0200f76:	737000ef          	jal	ra,ffffffffc0201eac <free_pages>
    free_page(p1);
ffffffffc0200f7a:	4585                	li	a1,1
ffffffffc0200f7c:	854e                	mv	a0,s3
ffffffffc0200f7e:	72f000ef          	jal	ra,ffffffffc0201eac <free_pages>
    free_page(p2);
ffffffffc0200f82:	4585                	li	a1,1
ffffffffc0200f84:	8556                	mv	a0,s5
ffffffffc0200f86:	727000ef          	jal	ra,ffffffffc0201eac <free_pages>
    assert(nr_free == 3);
ffffffffc0200f8a:	01092703          	lw	a4,16(s2)
ffffffffc0200f8e:	478d                	li	a5,3
ffffffffc0200f90:	2af71e63          	bne	a4,a5,ffffffffc020124c <default_check+0x3f2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f94:	4505                	li	a0,1
ffffffffc0200f96:	68f000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0200f9a:	89aa                	mv	s3,a0
ffffffffc0200f9c:	28050863          	beqz	a0,ffffffffc020122c <default_check+0x3d2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200fa0:	4505                	li	a0,1
ffffffffc0200fa2:	683000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0200fa6:	8aaa                	mv	s5,a0
ffffffffc0200fa8:	3e050263          	beqz	a0,ffffffffc020138c <default_check+0x532>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fac:	4505                	li	a0,1
ffffffffc0200fae:	677000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0200fb2:	8a2a                	mv	s4,a0
ffffffffc0200fb4:	3a050c63          	beqz	a0,ffffffffc020136c <default_check+0x512>
    assert(alloc_page() == NULL);
ffffffffc0200fb8:	4505                	li	a0,1
ffffffffc0200fba:	66b000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0200fbe:	38051763          	bnez	a0,ffffffffc020134c <default_check+0x4f2>
    free_page(p0);
ffffffffc0200fc2:	4585                	li	a1,1
ffffffffc0200fc4:	854e                	mv	a0,s3
ffffffffc0200fc6:	6e7000ef          	jal	ra,ffffffffc0201eac <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200fca:	00893783          	ld	a5,8(s2)
ffffffffc0200fce:	23278f63          	beq	a5,s2,ffffffffc020120c <default_check+0x3b2>
    assert((p = alloc_page()) == p0);
ffffffffc0200fd2:	4505                	li	a0,1
ffffffffc0200fd4:	651000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0200fd8:	32a99a63          	bne	s3,a0,ffffffffc020130c <default_check+0x4b2>
    assert(alloc_page() == NULL);
ffffffffc0200fdc:	4505                	li	a0,1
ffffffffc0200fde:	647000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0200fe2:	30051563          	bnez	a0,ffffffffc02012ec <default_check+0x492>
    assert(nr_free == 0);
ffffffffc0200fe6:	01092783          	lw	a5,16(s2)
ffffffffc0200fea:	2e079163          	bnez	a5,ffffffffc02012cc <default_check+0x472>
    free_page(p);
ffffffffc0200fee:	854e                	mv	a0,s3
ffffffffc0200ff0:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200ff2:	000ac797          	auipc	a5,0xac
ffffffffc0200ff6:	8b87b723          	sd	s8,-1874(a5) # ffffffffc02ac8a0 <free_area>
ffffffffc0200ffa:	000ac797          	auipc	a5,0xac
ffffffffc0200ffe:	8b77b723          	sd	s7,-1874(a5) # ffffffffc02ac8a8 <free_area+0x8>
    nr_free = nr_free_store;
ffffffffc0201002:	000ac797          	auipc	a5,0xac
ffffffffc0201006:	8b67a723          	sw	s6,-1874(a5) # ffffffffc02ac8b0 <free_area+0x10>
    free_page(p);
ffffffffc020100a:	6a3000ef          	jal	ra,ffffffffc0201eac <free_pages>
    free_page(p1);
ffffffffc020100e:	4585                	li	a1,1
ffffffffc0201010:	8556                	mv	a0,s5
ffffffffc0201012:	69b000ef          	jal	ra,ffffffffc0201eac <free_pages>
    free_page(p2);
ffffffffc0201016:	4585                	li	a1,1
ffffffffc0201018:	8552                	mv	a0,s4
ffffffffc020101a:	693000ef          	jal	ra,ffffffffc0201eac <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc020101e:	4515                	li	a0,5
ffffffffc0201020:	605000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0201024:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0201026:	28050363          	beqz	a0,ffffffffc02012ac <default_check+0x452>
ffffffffc020102a:	651c                	ld	a5,8(a0)
ffffffffc020102c:	8385                	srli	a5,a5,0x1
ffffffffc020102e:	8b85                	andi	a5,a5,1
    assert(!PageProperty(p0));
ffffffffc0201030:	54079e63          	bnez	a5,ffffffffc020158c <default_check+0x732>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0201034:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201036:	00093b03          	ld	s6,0(s2)
ffffffffc020103a:	00893a83          	ld	s5,8(s2)
ffffffffc020103e:	000ac797          	auipc	a5,0xac
ffffffffc0201042:	8727b123          	sd	s2,-1950(a5) # ffffffffc02ac8a0 <free_area>
ffffffffc0201046:	000ac797          	auipc	a5,0xac
ffffffffc020104a:	8727b123          	sd	s2,-1950(a5) # ffffffffc02ac8a8 <free_area+0x8>
    assert(alloc_page() == NULL);
ffffffffc020104e:	5d7000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0201052:	50051d63          	bnez	a0,ffffffffc020156c <default_check+0x712>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0201056:	08098a13          	addi	s4,s3,128
ffffffffc020105a:	8552                	mv	a0,s4
ffffffffc020105c:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc020105e:	01092b83          	lw	s7,16(s2)
    nr_free = 0;
ffffffffc0201062:	000ac797          	auipc	a5,0xac
ffffffffc0201066:	8407a723          	sw	zero,-1970(a5) # ffffffffc02ac8b0 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc020106a:	643000ef          	jal	ra,ffffffffc0201eac <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc020106e:	4511                	li	a0,4
ffffffffc0201070:	5b5000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0201074:	4c051c63          	bnez	a0,ffffffffc020154c <default_check+0x6f2>
ffffffffc0201078:	0889b783          	ld	a5,136(s3)
ffffffffc020107c:	8385                	srli	a5,a5,0x1
ffffffffc020107e:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201080:	4a078663          	beqz	a5,ffffffffc020152c <default_check+0x6d2>
ffffffffc0201084:	0909a703          	lw	a4,144(s3)
ffffffffc0201088:	478d                	li	a5,3
ffffffffc020108a:	4af71163          	bne	a4,a5,ffffffffc020152c <default_check+0x6d2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020108e:	450d                	li	a0,3
ffffffffc0201090:	595000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0201094:	8c2a                	mv	s8,a0
ffffffffc0201096:	46050b63          	beqz	a0,ffffffffc020150c <default_check+0x6b2>
    assert(alloc_page() == NULL);
ffffffffc020109a:	4505                	li	a0,1
ffffffffc020109c:	589000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc02010a0:	44051663          	bnez	a0,ffffffffc02014ec <default_check+0x692>
    assert(p0 + 2 == p1);
ffffffffc02010a4:	438a1463          	bne	s4,s8,ffffffffc02014cc <default_check+0x672>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc02010a8:	4585                	li	a1,1
ffffffffc02010aa:	854e                	mv	a0,s3
ffffffffc02010ac:	601000ef          	jal	ra,ffffffffc0201eac <free_pages>
    free_pages(p1, 3);
ffffffffc02010b0:	458d                	li	a1,3
ffffffffc02010b2:	8552                	mv	a0,s4
ffffffffc02010b4:	5f9000ef          	jal	ra,ffffffffc0201eac <free_pages>
ffffffffc02010b8:	0089b783          	ld	a5,8(s3)
    p2 = p0 + 1;
ffffffffc02010bc:	04098c13          	addi	s8,s3,64
ffffffffc02010c0:	8385                	srli	a5,a5,0x1
ffffffffc02010c2:	8b85                	andi	a5,a5,1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02010c4:	3e078463          	beqz	a5,ffffffffc02014ac <default_check+0x652>
ffffffffc02010c8:	0109a703          	lw	a4,16(s3)
ffffffffc02010cc:	4785                	li	a5,1
ffffffffc02010ce:	3cf71f63          	bne	a4,a5,ffffffffc02014ac <default_check+0x652>
ffffffffc02010d2:	008a3783          	ld	a5,8(s4)
ffffffffc02010d6:	8385                	srli	a5,a5,0x1
ffffffffc02010d8:	8b85                	andi	a5,a5,1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02010da:	3a078963          	beqz	a5,ffffffffc020148c <default_check+0x632>
ffffffffc02010de:	010a2703          	lw	a4,16(s4)
ffffffffc02010e2:	478d                	li	a5,3
ffffffffc02010e4:	3af71463          	bne	a4,a5,ffffffffc020148c <default_check+0x632>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02010e8:	4505                	li	a0,1
ffffffffc02010ea:	53b000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc02010ee:	36a99f63          	bne	s3,a0,ffffffffc020146c <default_check+0x612>
    free_page(p0);
ffffffffc02010f2:	4585                	li	a1,1
ffffffffc02010f4:	5b9000ef          	jal	ra,ffffffffc0201eac <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02010f8:	4509                	li	a0,2
ffffffffc02010fa:	52b000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc02010fe:	34aa1763          	bne	s4,a0,ffffffffc020144c <default_check+0x5f2>

    free_pages(p0, 2);
ffffffffc0201102:	4589                	li	a1,2
ffffffffc0201104:	5a9000ef          	jal	ra,ffffffffc0201eac <free_pages>
    free_page(p2);
ffffffffc0201108:	4585                	li	a1,1
ffffffffc020110a:	8562                	mv	a0,s8
ffffffffc020110c:	5a1000ef          	jal	ra,ffffffffc0201eac <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201110:	4515                	li	a0,5
ffffffffc0201112:	513000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0201116:	89aa                	mv	s3,a0
ffffffffc0201118:	48050a63          	beqz	a0,ffffffffc02015ac <default_check+0x752>
    assert(alloc_page() == NULL);
ffffffffc020111c:	4505                	li	a0,1
ffffffffc020111e:	507000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0201122:	2e051563          	bnez	a0,ffffffffc020140c <default_check+0x5b2>

    assert(nr_free == 0);
ffffffffc0201126:	01092783          	lw	a5,16(s2)
ffffffffc020112a:	2c079163          	bnez	a5,ffffffffc02013ec <default_check+0x592>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc020112e:	4595                	li	a1,5
ffffffffc0201130:	854e                	mv	a0,s3
    nr_free = nr_free_store;
ffffffffc0201132:	000ab797          	auipc	a5,0xab
ffffffffc0201136:	7777af23          	sw	s7,1918(a5) # ffffffffc02ac8b0 <free_area+0x10>
    free_list = free_list_store;
ffffffffc020113a:	000ab797          	auipc	a5,0xab
ffffffffc020113e:	7767b323          	sd	s6,1894(a5) # ffffffffc02ac8a0 <free_area>
ffffffffc0201142:	000ab797          	auipc	a5,0xab
ffffffffc0201146:	7757b323          	sd	s5,1894(a5) # ffffffffc02ac8a8 <free_area+0x8>
    free_pages(p0, 5);
ffffffffc020114a:	563000ef          	jal	ra,ffffffffc0201eac <free_pages>
    return listelm->next;
ffffffffc020114e:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201152:	01278963          	beq	a5,s2,ffffffffc0201164 <default_check+0x30a>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0201156:	ff87a703          	lw	a4,-8(a5)
ffffffffc020115a:	679c                	ld	a5,8(a5)
ffffffffc020115c:	34fd                	addiw	s1,s1,-1
ffffffffc020115e:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201160:	ff279be3          	bne	a5,s2,ffffffffc0201156 <default_check+0x2fc>
    }
    assert(count == 0);
ffffffffc0201164:	26049463          	bnez	s1,ffffffffc02013cc <default_check+0x572>
    assert(total == 0);
ffffffffc0201168:	46041263          	bnez	s0,ffffffffc02015cc <default_check+0x772>
}
ffffffffc020116c:	60a6                	ld	ra,72(sp)
ffffffffc020116e:	6406                	ld	s0,64(sp)
ffffffffc0201170:	74e2                	ld	s1,56(sp)
ffffffffc0201172:	7942                	ld	s2,48(sp)
ffffffffc0201174:	79a2                	ld	s3,40(sp)
ffffffffc0201176:	7a02                	ld	s4,32(sp)
ffffffffc0201178:	6ae2                	ld	s5,24(sp)
ffffffffc020117a:	6b42                	ld	s6,16(sp)
ffffffffc020117c:	6ba2                	ld	s7,8(sp)
ffffffffc020117e:	6c02                	ld	s8,0(sp)
ffffffffc0201180:	6161                	addi	sp,sp,80
ffffffffc0201182:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201184:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0201186:	4401                	li	s0,0
ffffffffc0201188:	4481                	li	s1,0
ffffffffc020118a:	b30d                	j	ffffffffc0200eac <default_check+0x52>
        assert(PageProperty(p));
ffffffffc020118c:	00006697          	auipc	a3,0x6
ffffffffc0201190:	dfc68693          	addi	a3,a3,-516 # ffffffffc0206f88 <commands+0x878>
ffffffffc0201194:	00006617          	auipc	a2,0x6
ffffffffc0201198:	a3c60613          	addi	a2,a2,-1476 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020119c:	0f000593          	li	a1,240
ffffffffc02011a0:	00006517          	auipc	a0,0x6
ffffffffc02011a4:	df850513          	addi	a0,a0,-520 # ffffffffc0206f98 <commands+0x888>
ffffffffc02011a8:	ad8ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02011ac:	00006697          	auipc	a3,0x6
ffffffffc02011b0:	e8468693          	addi	a3,a3,-380 # ffffffffc0207030 <commands+0x920>
ffffffffc02011b4:	00006617          	auipc	a2,0x6
ffffffffc02011b8:	a1c60613          	addi	a2,a2,-1508 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02011bc:	0bd00593          	li	a1,189
ffffffffc02011c0:	00006517          	auipc	a0,0x6
ffffffffc02011c4:	dd850513          	addi	a0,a0,-552 # ffffffffc0206f98 <commands+0x888>
ffffffffc02011c8:	ab8ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02011cc:	00006697          	auipc	a3,0x6
ffffffffc02011d0:	e8c68693          	addi	a3,a3,-372 # ffffffffc0207058 <commands+0x948>
ffffffffc02011d4:	00006617          	auipc	a2,0x6
ffffffffc02011d8:	9fc60613          	addi	a2,a2,-1540 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02011dc:	0be00593          	li	a1,190
ffffffffc02011e0:	00006517          	auipc	a0,0x6
ffffffffc02011e4:	db850513          	addi	a0,a0,-584 # ffffffffc0206f98 <commands+0x888>
ffffffffc02011e8:	a98ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02011ec:	00006697          	auipc	a3,0x6
ffffffffc02011f0:	eac68693          	addi	a3,a3,-340 # ffffffffc0207098 <commands+0x988>
ffffffffc02011f4:	00006617          	auipc	a2,0x6
ffffffffc02011f8:	9dc60613          	addi	a2,a2,-1572 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02011fc:	0c000593          	li	a1,192
ffffffffc0201200:	00006517          	auipc	a0,0x6
ffffffffc0201204:	d9850513          	addi	a0,a0,-616 # ffffffffc0206f98 <commands+0x888>
ffffffffc0201208:	a78ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(!list_empty(&free_list));
ffffffffc020120c:	00006697          	auipc	a3,0x6
ffffffffc0201210:	f1468693          	addi	a3,a3,-236 # ffffffffc0207120 <commands+0xa10>
ffffffffc0201214:	00006617          	auipc	a2,0x6
ffffffffc0201218:	9bc60613          	addi	a2,a2,-1604 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020121c:	0d900593          	li	a1,217
ffffffffc0201220:	00006517          	auipc	a0,0x6
ffffffffc0201224:	d7850513          	addi	a0,a0,-648 # ffffffffc0206f98 <commands+0x888>
ffffffffc0201228:	a58ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020122c:	00006697          	auipc	a3,0x6
ffffffffc0201230:	da468693          	addi	a3,a3,-604 # ffffffffc0206fd0 <commands+0x8c0>
ffffffffc0201234:	00006617          	auipc	a2,0x6
ffffffffc0201238:	99c60613          	addi	a2,a2,-1636 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020123c:	0d200593          	li	a1,210
ffffffffc0201240:	00006517          	auipc	a0,0x6
ffffffffc0201244:	d5850513          	addi	a0,a0,-680 # ffffffffc0206f98 <commands+0x888>
ffffffffc0201248:	a38ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(nr_free == 3);
ffffffffc020124c:	00006697          	auipc	a3,0x6
ffffffffc0201250:	ec468693          	addi	a3,a3,-316 # ffffffffc0207110 <commands+0xa00>
ffffffffc0201254:	00006617          	auipc	a2,0x6
ffffffffc0201258:	97c60613          	addi	a2,a2,-1668 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020125c:	0d000593          	li	a1,208
ffffffffc0201260:	00006517          	auipc	a0,0x6
ffffffffc0201264:	d3850513          	addi	a0,a0,-712 # ffffffffc0206f98 <commands+0x888>
ffffffffc0201268:	a18ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020126c:	00006697          	auipc	a3,0x6
ffffffffc0201270:	e8c68693          	addi	a3,a3,-372 # ffffffffc02070f8 <commands+0x9e8>
ffffffffc0201274:	00006617          	auipc	a2,0x6
ffffffffc0201278:	95c60613          	addi	a2,a2,-1700 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020127c:	0cb00593          	li	a1,203
ffffffffc0201280:	00006517          	auipc	a0,0x6
ffffffffc0201284:	d1850513          	addi	a0,a0,-744 # ffffffffc0206f98 <commands+0x888>
ffffffffc0201288:	9f8ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc020128c:	00006697          	auipc	a3,0x6
ffffffffc0201290:	e4c68693          	addi	a3,a3,-436 # ffffffffc02070d8 <commands+0x9c8>
ffffffffc0201294:	00006617          	auipc	a2,0x6
ffffffffc0201298:	93c60613          	addi	a2,a2,-1732 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020129c:	0c200593          	li	a1,194
ffffffffc02012a0:	00006517          	auipc	a0,0x6
ffffffffc02012a4:	cf850513          	addi	a0,a0,-776 # ffffffffc0206f98 <commands+0x888>
ffffffffc02012a8:	9d8ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(p0 != NULL);
ffffffffc02012ac:	00006697          	auipc	a3,0x6
ffffffffc02012b0:	ebc68693          	addi	a3,a3,-324 # ffffffffc0207168 <commands+0xa58>
ffffffffc02012b4:	00006617          	auipc	a2,0x6
ffffffffc02012b8:	91c60613          	addi	a2,a2,-1764 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02012bc:	0f800593          	li	a1,248
ffffffffc02012c0:	00006517          	auipc	a0,0x6
ffffffffc02012c4:	cd850513          	addi	a0,a0,-808 # ffffffffc0206f98 <commands+0x888>
ffffffffc02012c8:	9b8ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(nr_free == 0);
ffffffffc02012cc:	00006697          	auipc	a3,0x6
ffffffffc02012d0:	e8c68693          	addi	a3,a3,-372 # ffffffffc0207158 <commands+0xa48>
ffffffffc02012d4:	00006617          	auipc	a2,0x6
ffffffffc02012d8:	8fc60613          	addi	a2,a2,-1796 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02012dc:	0df00593          	li	a1,223
ffffffffc02012e0:	00006517          	auipc	a0,0x6
ffffffffc02012e4:	cb850513          	addi	a0,a0,-840 # ffffffffc0206f98 <commands+0x888>
ffffffffc02012e8:	998ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012ec:	00006697          	auipc	a3,0x6
ffffffffc02012f0:	e0c68693          	addi	a3,a3,-500 # ffffffffc02070f8 <commands+0x9e8>
ffffffffc02012f4:	00006617          	auipc	a2,0x6
ffffffffc02012f8:	8dc60613          	addi	a2,a2,-1828 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02012fc:	0dd00593          	li	a1,221
ffffffffc0201300:	00006517          	auipc	a0,0x6
ffffffffc0201304:	c9850513          	addi	a0,a0,-872 # ffffffffc0206f98 <commands+0x888>
ffffffffc0201308:	978ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc020130c:	00006697          	auipc	a3,0x6
ffffffffc0201310:	e2c68693          	addi	a3,a3,-468 # ffffffffc0207138 <commands+0xa28>
ffffffffc0201314:	00006617          	auipc	a2,0x6
ffffffffc0201318:	8bc60613          	addi	a2,a2,-1860 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020131c:	0dc00593          	li	a1,220
ffffffffc0201320:	00006517          	auipc	a0,0x6
ffffffffc0201324:	c7850513          	addi	a0,a0,-904 # ffffffffc0206f98 <commands+0x888>
ffffffffc0201328:	958ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc020132c:	00006697          	auipc	a3,0x6
ffffffffc0201330:	ca468693          	addi	a3,a3,-860 # ffffffffc0206fd0 <commands+0x8c0>
ffffffffc0201334:	00006617          	auipc	a2,0x6
ffffffffc0201338:	89c60613          	addi	a2,a2,-1892 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020133c:	0b900593          	li	a1,185
ffffffffc0201340:	00006517          	auipc	a0,0x6
ffffffffc0201344:	c5850513          	addi	a0,a0,-936 # ffffffffc0206f98 <commands+0x888>
ffffffffc0201348:	938ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020134c:	00006697          	auipc	a3,0x6
ffffffffc0201350:	dac68693          	addi	a3,a3,-596 # ffffffffc02070f8 <commands+0x9e8>
ffffffffc0201354:	00006617          	auipc	a2,0x6
ffffffffc0201358:	87c60613          	addi	a2,a2,-1924 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020135c:	0d600593          	li	a1,214
ffffffffc0201360:	00006517          	auipc	a0,0x6
ffffffffc0201364:	c3850513          	addi	a0,a0,-968 # ffffffffc0206f98 <commands+0x888>
ffffffffc0201368:	918ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020136c:	00006697          	auipc	a3,0x6
ffffffffc0201370:	ca468693          	addi	a3,a3,-860 # ffffffffc0207010 <commands+0x900>
ffffffffc0201374:	00006617          	auipc	a2,0x6
ffffffffc0201378:	85c60613          	addi	a2,a2,-1956 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020137c:	0d400593          	li	a1,212
ffffffffc0201380:	00006517          	auipc	a0,0x6
ffffffffc0201384:	c1850513          	addi	a0,a0,-1000 # ffffffffc0206f98 <commands+0x888>
ffffffffc0201388:	8f8ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020138c:	00006697          	auipc	a3,0x6
ffffffffc0201390:	c6468693          	addi	a3,a3,-924 # ffffffffc0206ff0 <commands+0x8e0>
ffffffffc0201394:	00006617          	auipc	a2,0x6
ffffffffc0201398:	83c60613          	addi	a2,a2,-1988 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020139c:	0d300593          	li	a1,211
ffffffffc02013a0:	00006517          	auipc	a0,0x6
ffffffffc02013a4:	bf850513          	addi	a0,a0,-1032 # ffffffffc0206f98 <commands+0x888>
ffffffffc02013a8:	8d8ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02013ac:	00006697          	auipc	a3,0x6
ffffffffc02013b0:	c6468693          	addi	a3,a3,-924 # ffffffffc0207010 <commands+0x900>
ffffffffc02013b4:	00006617          	auipc	a2,0x6
ffffffffc02013b8:	81c60613          	addi	a2,a2,-2020 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02013bc:	0bb00593          	li	a1,187
ffffffffc02013c0:	00006517          	auipc	a0,0x6
ffffffffc02013c4:	bd850513          	addi	a0,a0,-1064 # ffffffffc0206f98 <commands+0x888>
ffffffffc02013c8:	8b8ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(count == 0);
ffffffffc02013cc:	00006697          	auipc	a3,0x6
ffffffffc02013d0:	eec68693          	addi	a3,a3,-276 # ffffffffc02072b8 <commands+0xba8>
ffffffffc02013d4:	00005617          	auipc	a2,0x5
ffffffffc02013d8:	7fc60613          	addi	a2,a2,2044 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02013dc:	12500593          	li	a1,293
ffffffffc02013e0:	00006517          	auipc	a0,0x6
ffffffffc02013e4:	bb850513          	addi	a0,a0,-1096 # ffffffffc0206f98 <commands+0x888>
ffffffffc02013e8:	898ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(nr_free == 0);
ffffffffc02013ec:	00006697          	auipc	a3,0x6
ffffffffc02013f0:	d6c68693          	addi	a3,a3,-660 # ffffffffc0207158 <commands+0xa48>
ffffffffc02013f4:	00005617          	auipc	a2,0x5
ffffffffc02013f8:	7dc60613          	addi	a2,a2,2012 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02013fc:	11a00593          	li	a1,282
ffffffffc0201400:	00006517          	auipc	a0,0x6
ffffffffc0201404:	b9850513          	addi	a0,a0,-1128 # ffffffffc0206f98 <commands+0x888>
ffffffffc0201408:	878ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020140c:	00006697          	auipc	a3,0x6
ffffffffc0201410:	cec68693          	addi	a3,a3,-788 # ffffffffc02070f8 <commands+0x9e8>
ffffffffc0201414:	00005617          	auipc	a2,0x5
ffffffffc0201418:	7bc60613          	addi	a2,a2,1980 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020141c:	11800593          	li	a1,280
ffffffffc0201420:	00006517          	auipc	a0,0x6
ffffffffc0201424:	b7850513          	addi	a0,a0,-1160 # ffffffffc0206f98 <commands+0x888>
ffffffffc0201428:	858ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc020142c:	00006697          	auipc	a3,0x6
ffffffffc0201430:	c8c68693          	addi	a3,a3,-884 # ffffffffc02070b8 <commands+0x9a8>
ffffffffc0201434:	00005617          	auipc	a2,0x5
ffffffffc0201438:	79c60613          	addi	a2,a2,1948 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020143c:	0c100593          	li	a1,193
ffffffffc0201440:	00006517          	auipc	a0,0x6
ffffffffc0201444:	b5850513          	addi	a0,a0,-1192 # ffffffffc0206f98 <commands+0x888>
ffffffffc0201448:	838ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc020144c:	00006697          	auipc	a3,0x6
ffffffffc0201450:	e2c68693          	addi	a3,a3,-468 # ffffffffc0207278 <commands+0xb68>
ffffffffc0201454:	00005617          	auipc	a2,0x5
ffffffffc0201458:	77c60613          	addi	a2,a2,1916 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020145c:	11200593          	li	a1,274
ffffffffc0201460:	00006517          	auipc	a0,0x6
ffffffffc0201464:	b3850513          	addi	a0,a0,-1224 # ffffffffc0206f98 <commands+0x888>
ffffffffc0201468:	818ff0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc020146c:	00006697          	auipc	a3,0x6
ffffffffc0201470:	dec68693          	addi	a3,a3,-532 # ffffffffc0207258 <commands+0xb48>
ffffffffc0201474:	00005617          	auipc	a2,0x5
ffffffffc0201478:	75c60613          	addi	a2,a2,1884 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020147c:	11000593          	li	a1,272
ffffffffc0201480:	00006517          	auipc	a0,0x6
ffffffffc0201484:	b1850513          	addi	a0,a0,-1256 # ffffffffc0206f98 <commands+0x888>
ffffffffc0201488:	ff9fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc020148c:	00006697          	auipc	a3,0x6
ffffffffc0201490:	da468693          	addi	a3,a3,-604 # ffffffffc0207230 <commands+0xb20>
ffffffffc0201494:	00005617          	auipc	a2,0x5
ffffffffc0201498:	73c60613          	addi	a2,a2,1852 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020149c:	10e00593          	li	a1,270
ffffffffc02014a0:	00006517          	auipc	a0,0x6
ffffffffc02014a4:	af850513          	addi	a0,a0,-1288 # ffffffffc0206f98 <commands+0x888>
ffffffffc02014a8:	fd9fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02014ac:	00006697          	auipc	a3,0x6
ffffffffc02014b0:	d5c68693          	addi	a3,a3,-676 # ffffffffc0207208 <commands+0xaf8>
ffffffffc02014b4:	00005617          	auipc	a2,0x5
ffffffffc02014b8:	71c60613          	addi	a2,a2,1820 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02014bc:	10d00593          	li	a1,269
ffffffffc02014c0:	00006517          	auipc	a0,0x6
ffffffffc02014c4:	ad850513          	addi	a0,a0,-1320 # ffffffffc0206f98 <commands+0x888>
ffffffffc02014c8:	fb9fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02014cc:	00006697          	auipc	a3,0x6
ffffffffc02014d0:	d2c68693          	addi	a3,a3,-724 # ffffffffc02071f8 <commands+0xae8>
ffffffffc02014d4:	00005617          	auipc	a2,0x5
ffffffffc02014d8:	6fc60613          	addi	a2,a2,1788 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02014dc:	10800593          	li	a1,264
ffffffffc02014e0:	00006517          	auipc	a0,0x6
ffffffffc02014e4:	ab850513          	addi	a0,a0,-1352 # ffffffffc0206f98 <commands+0x888>
ffffffffc02014e8:	f99fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014ec:	00006697          	auipc	a3,0x6
ffffffffc02014f0:	c0c68693          	addi	a3,a3,-1012 # ffffffffc02070f8 <commands+0x9e8>
ffffffffc02014f4:	00005617          	auipc	a2,0x5
ffffffffc02014f8:	6dc60613          	addi	a2,a2,1756 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02014fc:	10700593          	li	a1,263
ffffffffc0201500:	00006517          	auipc	a0,0x6
ffffffffc0201504:	a9850513          	addi	a0,a0,-1384 # ffffffffc0206f98 <commands+0x888>
ffffffffc0201508:	f79fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc020150c:	00006697          	auipc	a3,0x6
ffffffffc0201510:	ccc68693          	addi	a3,a3,-820 # ffffffffc02071d8 <commands+0xac8>
ffffffffc0201514:	00005617          	auipc	a2,0x5
ffffffffc0201518:	6bc60613          	addi	a2,a2,1724 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020151c:	10600593          	li	a1,262
ffffffffc0201520:	00006517          	auipc	a0,0x6
ffffffffc0201524:	a7850513          	addi	a0,a0,-1416 # ffffffffc0206f98 <commands+0x888>
ffffffffc0201528:	f59fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc020152c:	00006697          	auipc	a3,0x6
ffffffffc0201530:	c7c68693          	addi	a3,a3,-900 # ffffffffc02071a8 <commands+0xa98>
ffffffffc0201534:	00005617          	auipc	a2,0x5
ffffffffc0201538:	69c60613          	addi	a2,a2,1692 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020153c:	10500593          	li	a1,261
ffffffffc0201540:	00006517          	auipc	a0,0x6
ffffffffc0201544:	a5850513          	addi	a0,a0,-1448 # ffffffffc0206f98 <commands+0x888>
ffffffffc0201548:	f39fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc020154c:	00006697          	auipc	a3,0x6
ffffffffc0201550:	c4468693          	addi	a3,a3,-956 # ffffffffc0207190 <commands+0xa80>
ffffffffc0201554:	00005617          	auipc	a2,0x5
ffffffffc0201558:	67c60613          	addi	a2,a2,1660 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020155c:	10400593          	li	a1,260
ffffffffc0201560:	00006517          	auipc	a0,0x6
ffffffffc0201564:	a3850513          	addi	a0,a0,-1480 # ffffffffc0206f98 <commands+0x888>
ffffffffc0201568:	f19fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(alloc_page() == NULL);
ffffffffc020156c:	00006697          	auipc	a3,0x6
ffffffffc0201570:	b8c68693          	addi	a3,a3,-1140 # ffffffffc02070f8 <commands+0x9e8>
ffffffffc0201574:	00005617          	auipc	a2,0x5
ffffffffc0201578:	65c60613          	addi	a2,a2,1628 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020157c:	0fe00593          	li	a1,254
ffffffffc0201580:	00006517          	auipc	a0,0x6
ffffffffc0201584:	a1850513          	addi	a0,a0,-1512 # ffffffffc0206f98 <commands+0x888>
ffffffffc0201588:	ef9fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(!PageProperty(p0));
ffffffffc020158c:	00006697          	auipc	a3,0x6
ffffffffc0201590:	bec68693          	addi	a3,a3,-1044 # ffffffffc0207178 <commands+0xa68>
ffffffffc0201594:	00005617          	auipc	a2,0x5
ffffffffc0201598:	63c60613          	addi	a2,a2,1596 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020159c:	0f900593          	li	a1,249
ffffffffc02015a0:	00006517          	auipc	a0,0x6
ffffffffc02015a4:	9f850513          	addi	a0,a0,-1544 # ffffffffc0206f98 <commands+0x888>
ffffffffc02015a8:	ed9fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02015ac:	00006697          	auipc	a3,0x6
ffffffffc02015b0:	cec68693          	addi	a3,a3,-788 # ffffffffc0207298 <commands+0xb88>
ffffffffc02015b4:	00005617          	auipc	a2,0x5
ffffffffc02015b8:	61c60613          	addi	a2,a2,1564 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02015bc:	11700593          	li	a1,279
ffffffffc02015c0:	00006517          	auipc	a0,0x6
ffffffffc02015c4:	9d850513          	addi	a0,a0,-1576 # ffffffffc0206f98 <commands+0x888>
ffffffffc02015c8:	eb9fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(total == 0);
ffffffffc02015cc:	00006697          	auipc	a3,0x6
ffffffffc02015d0:	cfc68693          	addi	a3,a3,-772 # ffffffffc02072c8 <commands+0xbb8>
ffffffffc02015d4:	00005617          	auipc	a2,0x5
ffffffffc02015d8:	5fc60613          	addi	a2,a2,1532 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02015dc:	12600593          	li	a1,294
ffffffffc02015e0:	00006517          	auipc	a0,0x6
ffffffffc02015e4:	9b850513          	addi	a0,a0,-1608 # ffffffffc0206f98 <commands+0x888>
ffffffffc02015e8:	e99fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(total == nr_free_pages());
ffffffffc02015ec:	00006697          	auipc	a3,0x6
ffffffffc02015f0:	9c468693          	addi	a3,a3,-1596 # ffffffffc0206fb0 <commands+0x8a0>
ffffffffc02015f4:	00005617          	auipc	a2,0x5
ffffffffc02015f8:	5dc60613          	addi	a2,a2,1500 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02015fc:	0f300593          	li	a1,243
ffffffffc0201600:	00006517          	auipc	a0,0x6
ffffffffc0201604:	99850513          	addi	a0,a0,-1640 # ffffffffc0206f98 <commands+0x888>
ffffffffc0201608:	e79fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020160c:	00006697          	auipc	a3,0x6
ffffffffc0201610:	9e468693          	addi	a3,a3,-1564 # ffffffffc0206ff0 <commands+0x8e0>
ffffffffc0201614:	00005617          	auipc	a2,0x5
ffffffffc0201618:	5bc60613          	addi	a2,a2,1468 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020161c:	0ba00593          	li	a1,186
ffffffffc0201620:	00006517          	auipc	a0,0x6
ffffffffc0201624:	97850513          	addi	a0,a0,-1672 # ffffffffc0206f98 <commands+0x888>
ffffffffc0201628:	e59fe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc020162c <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc020162c:	1141                	addi	sp,sp,-16
ffffffffc020162e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201630:	16058e63          	beqz	a1,ffffffffc02017ac <default_free_pages+0x180>
    for (; p != base + n; p ++) {
ffffffffc0201634:	00659693          	slli	a3,a1,0x6
ffffffffc0201638:	96aa                	add	a3,a3,a0
ffffffffc020163a:	02d50d63          	beq	a0,a3,ffffffffc0201674 <default_free_pages+0x48>
ffffffffc020163e:	651c                	ld	a5,8(a0)
ffffffffc0201640:	8b85                	andi	a5,a5,1
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201642:	14079563          	bnez	a5,ffffffffc020178c <default_free_pages+0x160>
ffffffffc0201646:	651c                	ld	a5,8(a0)
ffffffffc0201648:	8385                	srli	a5,a5,0x1
ffffffffc020164a:	8b85                	andi	a5,a5,1
ffffffffc020164c:	14079063          	bnez	a5,ffffffffc020178c <default_free_pages+0x160>
ffffffffc0201650:	87aa                	mv	a5,a0
ffffffffc0201652:	a809                	j	ffffffffc0201664 <default_free_pages+0x38>
ffffffffc0201654:	6798                	ld	a4,8(a5)
ffffffffc0201656:	8b05                	andi	a4,a4,1
ffffffffc0201658:	12071a63          	bnez	a4,ffffffffc020178c <default_free_pages+0x160>
ffffffffc020165c:	6798                	ld	a4,8(a5)
ffffffffc020165e:	8b09                	andi	a4,a4,2
ffffffffc0201660:	12071663          	bnez	a4,ffffffffc020178c <default_free_pages+0x160>
        p->flags = 0;
ffffffffc0201664:	0007b423          	sd	zero,8(a5)
    return page->ref;
}

static inline void
set_page_ref(struct Page *page, int val) {
    page->ref = val;
ffffffffc0201668:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc020166c:	04078793          	addi	a5,a5,64
ffffffffc0201670:	fed792e3          	bne	a5,a3,ffffffffc0201654 <default_free_pages+0x28>
    base->property = n;
ffffffffc0201674:	2581                	sext.w	a1,a1
ffffffffc0201676:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201678:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020167c:	4789                	li	a5,2
ffffffffc020167e:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201682:	000ab697          	auipc	a3,0xab
ffffffffc0201686:	21e68693          	addi	a3,a3,542 # ffffffffc02ac8a0 <free_area>
ffffffffc020168a:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc020168c:	669c                	ld	a5,8(a3)
ffffffffc020168e:	9db9                	addw	a1,a1,a4
ffffffffc0201690:	000ab717          	auipc	a4,0xab
ffffffffc0201694:	22b72023          	sw	a1,544(a4) # ffffffffc02ac8b0 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc0201698:	0cd78163          	beq	a5,a3,ffffffffc020175a <default_free_pages+0x12e>
            struct Page* page = le2page(le, page_link);
ffffffffc020169c:	fe878713          	addi	a4,a5,-24
ffffffffc02016a0:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02016a2:	4801                	li	a6,0
ffffffffc02016a4:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02016a8:	00e56a63          	bltu	a0,a4,ffffffffc02016bc <default_free_pages+0x90>
    return listelm->next;
ffffffffc02016ac:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02016ae:	04d70f63          	beq	a4,a3,ffffffffc020170c <default_free_pages+0xe0>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02016b2:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02016b4:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02016b8:	fee57ae3          	bgeu	a0,a4,ffffffffc02016ac <default_free_pages+0x80>
ffffffffc02016bc:	00080663          	beqz	a6,ffffffffc02016c8 <default_free_pages+0x9c>
ffffffffc02016c0:	000ab817          	auipc	a6,0xab
ffffffffc02016c4:	1eb83023          	sd	a1,480(a6) # ffffffffc02ac8a0 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc02016c8:	638c                	ld	a1,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02016ca:	e390                	sd	a2,0(a5)
ffffffffc02016cc:	e590                	sd	a2,8(a1)
    elm->next = next;
ffffffffc02016ce:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02016d0:	ed0c                	sd	a1,24(a0)
    if (le != &free_list) {
ffffffffc02016d2:	06d58a63          	beq	a1,a3,ffffffffc0201746 <default_free_pages+0x11a>
        if (p + p->property == base) {
ffffffffc02016d6:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc02016da:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc02016de:	02061793          	slli	a5,a2,0x20
ffffffffc02016e2:	83e9                	srli	a5,a5,0x1a
ffffffffc02016e4:	97ba                	add	a5,a5,a4
ffffffffc02016e6:	04f51b63          	bne	a0,a5,ffffffffc020173c <default_free_pages+0x110>
            p->property += base->property;
ffffffffc02016ea:	491c                	lw	a5,16(a0)
ffffffffc02016ec:	9e3d                	addw	a2,a2,a5
ffffffffc02016ee:	fec5ac23          	sw	a2,-8(a1)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02016f2:	57f5                	li	a5,-3
ffffffffc02016f4:	60f8b02f          	amoand.d	zero,a5,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02016f8:	01853803          	ld	a6,24(a0)
ffffffffc02016fc:	7110                	ld	a2,32(a0)
            base = p;
ffffffffc02016fe:	853a                	mv	a0,a4
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201700:	00c83423          	sd	a2,8(a6)
    next->prev = prev;
ffffffffc0201704:	659c                	ld	a5,8(a1)
ffffffffc0201706:	01063023          	sd	a6,0(a2)
ffffffffc020170a:	a815                	j	ffffffffc020173e <default_free_pages+0x112>
    prev->next = next->prev = elm;
ffffffffc020170c:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020170e:	f114                	sd	a3,32(a0)
ffffffffc0201710:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201712:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201714:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201716:	00d70563          	beq	a4,a3,ffffffffc0201720 <default_free_pages+0xf4>
ffffffffc020171a:	4805                	li	a6,1
ffffffffc020171c:	87ba                	mv	a5,a4
ffffffffc020171e:	bf59                	j	ffffffffc02016b4 <default_free_pages+0x88>
ffffffffc0201720:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0201722:	85be                	mv	a1,a5
    if (le != &free_list) {
ffffffffc0201724:	00d78d63          	beq	a5,a3,ffffffffc020173e <default_free_pages+0x112>
        if (p + p->property == base) {
ffffffffc0201728:	ff85a603          	lw	a2,-8(a1)
        p = le2page(le, page_link);
ffffffffc020172c:	fe858713          	addi	a4,a1,-24
        if (p + p->property == base) {
ffffffffc0201730:	02061793          	slli	a5,a2,0x20
ffffffffc0201734:	83e9                	srli	a5,a5,0x1a
ffffffffc0201736:	97ba                	add	a5,a5,a4
ffffffffc0201738:	faf509e3          	beq	a0,a5,ffffffffc02016ea <default_free_pages+0xbe>
ffffffffc020173c:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc020173e:	fe878713          	addi	a4,a5,-24
ffffffffc0201742:	00d78963          	beq	a5,a3,ffffffffc0201754 <default_free_pages+0x128>
        if (base + base->property == p) {
ffffffffc0201746:	4910                	lw	a2,16(a0)
ffffffffc0201748:	02061693          	slli	a3,a2,0x20
ffffffffc020174c:	82e9                	srli	a3,a3,0x1a
ffffffffc020174e:	96aa                	add	a3,a3,a0
ffffffffc0201750:	00d70e63          	beq	a4,a3,ffffffffc020176c <default_free_pages+0x140>
}
ffffffffc0201754:	60a2                	ld	ra,8(sp)
ffffffffc0201756:	0141                	addi	sp,sp,16
ffffffffc0201758:	8082                	ret
ffffffffc020175a:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020175c:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201760:	e398                	sd	a4,0(a5)
ffffffffc0201762:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc0201764:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201766:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201768:	0141                	addi	sp,sp,16
ffffffffc020176a:	8082                	ret
            base->property += p->property;
ffffffffc020176c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201770:	ff078693          	addi	a3,a5,-16
ffffffffc0201774:	9e39                	addw	a2,a2,a4
ffffffffc0201776:	c910                	sw	a2,16(a0)
ffffffffc0201778:	5775                	li	a4,-3
ffffffffc020177a:	60e6b02f          	amoand.d	zero,a4,(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc020177e:	6398                	ld	a4,0(a5)
ffffffffc0201780:	679c                	ld	a5,8(a5)
}
ffffffffc0201782:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201784:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0201786:	e398                	sd	a4,0(a5)
ffffffffc0201788:	0141                	addi	sp,sp,16
ffffffffc020178a:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020178c:	00006697          	auipc	a3,0x6
ffffffffc0201790:	b4c68693          	addi	a3,a3,-1204 # ffffffffc02072d8 <commands+0xbc8>
ffffffffc0201794:	00005617          	auipc	a2,0x5
ffffffffc0201798:	43c60613          	addi	a2,a2,1084 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020179c:	08300593          	li	a1,131
ffffffffc02017a0:	00005517          	auipc	a0,0x5
ffffffffc02017a4:	7f850513          	addi	a0,a0,2040 # ffffffffc0206f98 <commands+0x888>
ffffffffc02017a8:	cd9fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(n > 0);
ffffffffc02017ac:	00006697          	auipc	a3,0x6
ffffffffc02017b0:	b5468693          	addi	a3,a3,-1196 # ffffffffc0207300 <commands+0xbf0>
ffffffffc02017b4:	00005617          	auipc	a2,0x5
ffffffffc02017b8:	41c60613          	addi	a2,a2,1052 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02017bc:	08000593          	li	a1,128
ffffffffc02017c0:	00005517          	auipc	a0,0x5
ffffffffc02017c4:	7d850513          	addi	a0,a0,2008 # ffffffffc0206f98 <commands+0x888>
ffffffffc02017c8:	cb9fe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02017cc <default_alloc_pages>:
    assert(n > 0);
ffffffffc02017cc:	c959                	beqz	a0,ffffffffc0201862 <default_alloc_pages+0x96>
    if (n > nr_free) {
ffffffffc02017ce:	000ab597          	auipc	a1,0xab
ffffffffc02017d2:	0d258593          	addi	a1,a1,210 # ffffffffc02ac8a0 <free_area>
ffffffffc02017d6:	0105a803          	lw	a6,16(a1)
ffffffffc02017da:	862a                	mv	a2,a0
ffffffffc02017dc:	02081793          	slli	a5,a6,0x20
ffffffffc02017e0:	9381                	srli	a5,a5,0x20
ffffffffc02017e2:	00a7ee63          	bltu	a5,a0,ffffffffc02017fe <default_alloc_pages+0x32>
    list_entry_t *le = &free_list;
ffffffffc02017e6:	87ae                	mv	a5,a1
ffffffffc02017e8:	a801                	j	ffffffffc02017f8 <default_alloc_pages+0x2c>
        if (p->property >= n) {
ffffffffc02017ea:	ff87a703          	lw	a4,-8(a5)
ffffffffc02017ee:	02071693          	slli	a3,a4,0x20
ffffffffc02017f2:	9281                	srli	a3,a3,0x20
ffffffffc02017f4:	00c6f763          	bgeu	a3,a2,ffffffffc0201802 <default_alloc_pages+0x36>
    return listelm->next;
ffffffffc02017f8:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02017fa:	feb798e3          	bne	a5,a1,ffffffffc02017ea <default_alloc_pages+0x1e>
        return NULL;
ffffffffc02017fe:	4501                	li	a0,0
}
ffffffffc0201800:	8082                	ret
        struct Page *p = le2page(le, page_link);
ffffffffc0201802:	fe878513          	addi	a0,a5,-24
    if (page != NULL) {
ffffffffc0201806:	dd6d                	beqz	a0,ffffffffc0201800 <default_alloc_pages+0x34>
    return listelm->prev;
ffffffffc0201808:	0007b883          	ld	a7,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc020180c:	0087b303          	ld	t1,8(a5)
    prev->next = next;
ffffffffc0201810:	00060e1b          	sext.w	t3,a2
ffffffffc0201814:	0068b423          	sd	t1,8(a7)
    next->prev = prev;
ffffffffc0201818:	01133023          	sd	a7,0(t1)
        if (page->property > n) {
ffffffffc020181c:	02d67863          	bgeu	a2,a3,ffffffffc020184c <default_alloc_pages+0x80>
            struct Page *p = page + n;
ffffffffc0201820:	061a                	slli	a2,a2,0x6
ffffffffc0201822:	962a                	add	a2,a2,a0
            p->property = page->property - n;
ffffffffc0201824:	41c7073b          	subw	a4,a4,t3
ffffffffc0201828:	ca18                	sw	a4,16(a2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020182a:	00860693          	addi	a3,a2,8
ffffffffc020182e:	4709                	li	a4,2
ffffffffc0201830:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201834:	0088b703          	ld	a4,8(a7)
            list_add(prev, &(p->page_link));
ffffffffc0201838:	01860693          	addi	a3,a2,24
    prev->next = next->prev = elm;
ffffffffc020183c:	0105a803          	lw	a6,16(a1)
ffffffffc0201840:	e314                	sd	a3,0(a4)
ffffffffc0201842:	00d8b423          	sd	a3,8(a7)
    elm->next = next;
ffffffffc0201846:	f218                	sd	a4,32(a2)
    elm->prev = prev;
ffffffffc0201848:	01163c23          	sd	a7,24(a2)
        nr_free -= n;
ffffffffc020184c:	41c8083b          	subw	a6,a6,t3
ffffffffc0201850:	000ab717          	auipc	a4,0xab
ffffffffc0201854:	07072023          	sw	a6,96(a4) # ffffffffc02ac8b0 <free_area+0x10>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201858:	5775                	li	a4,-3
ffffffffc020185a:	17c1                	addi	a5,a5,-16
ffffffffc020185c:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0201860:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201862:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201864:	00006697          	auipc	a3,0x6
ffffffffc0201868:	a9c68693          	addi	a3,a3,-1380 # ffffffffc0207300 <commands+0xbf0>
ffffffffc020186c:	00005617          	auipc	a2,0x5
ffffffffc0201870:	36460613          	addi	a2,a2,868 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0201874:	06200593          	li	a1,98
ffffffffc0201878:	00005517          	auipc	a0,0x5
ffffffffc020187c:	72050513          	addi	a0,a0,1824 # ffffffffc0206f98 <commands+0x888>
default_alloc_pages(size_t n) {
ffffffffc0201880:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201882:	bfffe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0201886 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc0201886:	1141                	addi	sp,sp,-16
ffffffffc0201888:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc020188a:	c1ed                	beqz	a1,ffffffffc020196c <default_init_memmap+0xe6>
    for (; p != base + n; p ++) {
ffffffffc020188c:	00659693          	slli	a3,a1,0x6
ffffffffc0201890:	96aa                	add	a3,a3,a0
ffffffffc0201892:	02d50463          	beq	a0,a3,ffffffffc02018ba <default_init_memmap+0x34>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201896:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0201898:	87aa                	mv	a5,a0
ffffffffc020189a:	8b05                	andi	a4,a4,1
ffffffffc020189c:	e709                	bnez	a4,ffffffffc02018a6 <default_init_memmap+0x20>
ffffffffc020189e:	a07d                	j	ffffffffc020194c <default_init_memmap+0xc6>
ffffffffc02018a0:	6798                	ld	a4,8(a5)
ffffffffc02018a2:	8b05                	andi	a4,a4,1
ffffffffc02018a4:	c745                	beqz	a4,ffffffffc020194c <default_init_memmap+0xc6>
        p->flags = p->property = 0;
ffffffffc02018a6:	0007a823          	sw	zero,16(a5)
ffffffffc02018aa:	0007b423          	sd	zero,8(a5)
ffffffffc02018ae:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02018b2:	04078793          	addi	a5,a5,64
ffffffffc02018b6:	fed795e3          	bne	a5,a3,ffffffffc02018a0 <default_init_memmap+0x1a>
    base->property = n;
ffffffffc02018ba:	2581                	sext.w	a1,a1
ffffffffc02018bc:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02018be:	4789                	li	a5,2
ffffffffc02018c0:	00850713          	addi	a4,a0,8
ffffffffc02018c4:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02018c8:	000ab697          	auipc	a3,0xab
ffffffffc02018cc:	fd868693          	addi	a3,a3,-40 # ffffffffc02ac8a0 <free_area>
ffffffffc02018d0:	4a98                	lw	a4,16(a3)
    return list->next == list;
ffffffffc02018d2:	669c                	ld	a5,8(a3)
ffffffffc02018d4:	9db9                	addw	a1,a1,a4
ffffffffc02018d6:	000ab717          	auipc	a4,0xab
ffffffffc02018da:	fcb72d23          	sw	a1,-38(a4) # ffffffffc02ac8b0 <free_area+0x10>
    if (list_empty(&free_list)) {
ffffffffc02018de:	04d78a63          	beq	a5,a3,ffffffffc0201932 <default_init_memmap+0xac>
            struct Page* page = le2page(le, page_link);
ffffffffc02018e2:	fe878713          	addi	a4,a5,-24
ffffffffc02018e6:	628c                	ld	a1,0(a3)
    if (list_empty(&free_list)) {
ffffffffc02018e8:	4801                	li	a6,0
ffffffffc02018ea:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02018ee:	00e56a63          	bltu	a0,a4,ffffffffc0201902 <default_init_memmap+0x7c>
    return listelm->next;
ffffffffc02018f2:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02018f4:	02d70563          	beq	a4,a3,ffffffffc020191e <default_init_memmap+0x98>
        while ((le = list_next(le)) != &free_list) {
ffffffffc02018f8:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02018fa:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02018fe:	fee57ae3          	bgeu	a0,a4,ffffffffc02018f2 <default_init_memmap+0x6c>
ffffffffc0201902:	00080663          	beqz	a6,ffffffffc020190e <default_init_memmap+0x88>
ffffffffc0201906:	000ab717          	auipc	a4,0xab
ffffffffc020190a:	f8b73d23          	sd	a1,-102(a4) # ffffffffc02ac8a0 <free_area>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020190e:	6398                	ld	a4,0(a5)
}
ffffffffc0201910:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201912:	e390                	sd	a2,0(a5)
ffffffffc0201914:	e710                	sd	a2,8(a4)
    elm->next = next;
ffffffffc0201916:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201918:	ed18                	sd	a4,24(a0)
ffffffffc020191a:	0141                	addi	sp,sp,16
ffffffffc020191c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020191e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201920:	f114                	sd	a3,32(a0)
ffffffffc0201922:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201924:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201926:	85b2                	mv	a1,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201928:	00d70e63          	beq	a4,a3,ffffffffc0201944 <default_init_memmap+0xbe>
ffffffffc020192c:	4805                	li	a6,1
ffffffffc020192e:	87ba                	mv	a5,a4
ffffffffc0201930:	b7e9                	j	ffffffffc02018fa <default_init_memmap+0x74>
}
ffffffffc0201932:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201934:	01850713          	addi	a4,a0,24
    prev->next = next->prev = elm;
ffffffffc0201938:	e398                	sd	a4,0(a5)
ffffffffc020193a:	e798                	sd	a4,8(a5)
    elm->next = next;
ffffffffc020193c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020193e:	ed1c                	sd	a5,24(a0)
}
ffffffffc0201940:	0141                	addi	sp,sp,16
ffffffffc0201942:	8082                	ret
ffffffffc0201944:	60a2                	ld	ra,8(sp)
ffffffffc0201946:	e290                	sd	a2,0(a3)
ffffffffc0201948:	0141                	addi	sp,sp,16
ffffffffc020194a:	8082                	ret
        assert(PageReserved(p));
ffffffffc020194c:	00006697          	auipc	a3,0x6
ffffffffc0201950:	9bc68693          	addi	a3,a3,-1604 # ffffffffc0207308 <commands+0xbf8>
ffffffffc0201954:	00005617          	auipc	a2,0x5
ffffffffc0201958:	27c60613          	addi	a2,a2,636 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020195c:	04900593          	li	a1,73
ffffffffc0201960:	00005517          	auipc	a0,0x5
ffffffffc0201964:	63850513          	addi	a0,a0,1592 # ffffffffc0206f98 <commands+0x888>
ffffffffc0201968:	b19fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(n > 0);
ffffffffc020196c:	00006697          	auipc	a3,0x6
ffffffffc0201970:	99468693          	addi	a3,a3,-1644 # ffffffffc0207300 <commands+0xbf0>
ffffffffc0201974:	00005617          	auipc	a2,0x5
ffffffffc0201978:	25c60613          	addi	a2,a2,604 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020197c:	04600593          	li	a1,70
ffffffffc0201980:	00005517          	auipc	a0,0x5
ffffffffc0201984:	61850513          	addi	a0,a0,1560 # ffffffffc0206f98 <commands+0x888>
ffffffffc0201988:	af9fe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc020198c <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc020198c:	c125                	beqz	a0,ffffffffc02019ec <slob_free+0x60>
		return;

	if (size)
ffffffffc020198e:	e1a5                	bnez	a1,ffffffffc02019ee <slob_free+0x62>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201990:	100027f3          	csrr	a5,sstatus
ffffffffc0201994:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201996:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201998:	e3bd                	bnez	a5,ffffffffc02019fe <slob_free+0x72>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020199a:	000a0797          	auipc	a5,0xa0
ffffffffc020199e:	a9678793          	addi	a5,a5,-1386 # ffffffffc02a1430 <slobfree>
ffffffffc02019a2:	639c                	ld	a5,0(a5)
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019a4:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019a6:	00a7fa63          	bgeu	a5,a0,ffffffffc02019ba <slob_free+0x2e>
ffffffffc02019aa:	00e56c63          	bltu	a0,a4,ffffffffc02019c2 <slob_free+0x36>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019ae:	00e7fa63          	bgeu	a5,a4,ffffffffc02019c2 <slob_free+0x36>
    return 0;
ffffffffc02019b2:	87ba                	mv	a5,a4
ffffffffc02019b4:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019b6:	fea7eae3          	bltu	a5,a0,ffffffffc02019aa <slob_free+0x1e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019ba:	fee7ece3          	bltu	a5,a4,ffffffffc02019b2 <slob_free+0x26>
ffffffffc02019be:	fee57ae3          	bgeu	a0,a4,ffffffffc02019b2 <slob_free+0x26>
			break;

	if (b + b->units == cur->next) {
ffffffffc02019c2:	4110                	lw	a2,0(a0)
ffffffffc02019c4:	00461693          	slli	a3,a2,0x4
ffffffffc02019c8:	96aa                	add	a3,a3,a0
ffffffffc02019ca:	08d70b63          	beq	a4,a3,ffffffffc0201a60 <slob_free+0xd4>
		b->units += cur->next->units;
		b->next = cur->next->next;
	} else
		b->next = cur->next;

	if (cur + cur->units == b) {
ffffffffc02019ce:	4394                	lw	a3,0(a5)
		b->next = cur->next;
ffffffffc02019d0:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc02019d2:	00469713          	slli	a4,a3,0x4
ffffffffc02019d6:	973e                	add	a4,a4,a5
ffffffffc02019d8:	08e50f63          	beq	a0,a4,ffffffffc0201a76 <slob_free+0xea>
		cur->units += b->units;
		cur->next = b->next;
	} else
		cur->next = b;
ffffffffc02019dc:	e788                	sd	a0,8(a5)

	slobfree = cur;
ffffffffc02019de:	000a0717          	auipc	a4,0xa0
ffffffffc02019e2:	a4f73923          	sd	a5,-1454(a4) # ffffffffc02a1430 <slobfree>
    if (flag) {
ffffffffc02019e6:	c199                	beqz	a1,ffffffffc02019ec <slob_free+0x60>
        intr_enable();
ffffffffc02019e8:	c65fe06f          	j	ffffffffc020064c <intr_enable>
ffffffffc02019ec:	8082                	ret
		b->units = SLOB_UNITS(size);
ffffffffc02019ee:	05bd                	addi	a1,a1,15
ffffffffc02019f0:	8191                	srli	a1,a1,0x4
ffffffffc02019f2:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019f4:	100027f3          	csrr	a5,sstatus
ffffffffc02019f8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02019fa:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02019fc:	dfd9                	beqz	a5,ffffffffc020199a <slob_free+0xe>
{
ffffffffc02019fe:	1101                	addi	sp,sp,-32
ffffffffc0201a00:	e42a                	sd	a0,8(sp)
ffffffffc0201a02:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201a04:	c4ffe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a08:	000a0797          	auipc	a5,0xa0
ffffffffc0201a0c:	a2878793          	addi	a5,a5,-1496 # ffffffffc02a1430 <slobfree>
ffffffffc0201a10:	639c                	ld	a5,0(a5)
        return 1;
ffffffffc0201a12:	6522                	ld	a0,8(sp)
ffffffffc0201a14:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a16:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a18:	00a7fa63          	bgeu	a5,a0,ffffffffc0201a2c <slob_free+0xa0>
ffffffffc0201a1c:	00e56c63          	bltu	a0,a4,ffffffffc0201a34 <slob_free+0xa8>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a20:	00e7fa63          	bgeu	a5,a4,ffffffffc0201a34 <slob_free+0xa8>
    return 0;
ffffffffc0201a24:	87ba                	mv	a5,a4
ffffffffc0201a26:	6798                	ld	a4,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a28:	fea7eae3          	bltu	a5,a0,ffffffffc0201a1c <slob_free+0x90>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a2c:	fee7ece3          	bltu	a5,a4,ffffffffc0201a24 <slob_free+0x98>
ffffffffc0201a30:	fee57ae3          	bgeu	a0,a4,ffffffffc0201a24 <slob_free+0x98>
	if (b + b->units == cur->next) {
ffffffffc0201a34:	4110                	lw	a2,0(a0)
ffffffffc0201a36:	00461693          	slli	a3,a2,0x4
ffffffffc0201a3a:	96aa                	add	a3,a3,a0
ffffffffc0201a3c:	04d70763          	beq	a4,a3,ffffffffc0201a8a <slob_free+0xfe>
		b->next = cur->next;
ffffffffc0201a40:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201a42:	4394                	lw	a3,0(a5)
ffffffffc0201a44:	00469713          	slli	a4,a3,0x4
ffffffffc0201a48:	973e                	add	a4,a4,a5
ffffffffc0201a4a:	04e50663          	beq	a0,a4,ffffffffc0201a96 <slob_free+0x10a>
		cur->next = b;
ffffffffc0201a4e:	e788                	sd	a0,8(a5)
	slobfree = cur;
ffffffffc0201a50:	000a0717          	auipc	a4,0xa0
ffffffffc0201a54:	9ef73023          	sd	a5,-1568(a4) # ffffffffc02a1430 <slobfree>
    if (flag) {
ffffffffc0201a58:	e58d                	bnez	a1,ffffffffc0201a82 <slob_free+0xf6>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201a5a:	60e2                	ld	ra,24(sp)
ffffffffc0201a5c:	6105                	addi	sp,sp,32
ffffffffc0201a5e:	8082                	ret
		b->units += cur->next->units;
ffffffffc0201a60:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201a62:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201a64:	9e35                	addw	a2,a2,a3
ffffffffc0201a66:	c110                	sw	a2,0(a0)
	if (cur + cur->units == b) {
ffffffffc0201a68:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201a6a:	e518                	sd	a4,8(a0)
	if (cur + cur->units == b) {
ffffffffc0201a6c:	00469713          	slli	a4,a3,0x4
ffffffffc0201a70:	973e                	add	a4,a4,a5
ffffffffc0201a72:	f6e515e3          	bne	a0,a4,ffffffffc02019dc <slob_free+0x50>
		cur->units += b->units;
ffffffffc0201a76:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201a78:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201a7a:	9eb9                	addw	a3,a3,a4
ffffffffc0201a7c:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201a7e:	e790                	sd	a2,8(a5)
ffffffffc0201a80:	bfb9                	j	ffffffffc02019de <slob_free+0x52>
}
ffffffffc0201a82:	60e2                	ld	ra,24(sp)
ffffffffc0201a84:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201a86:	bc7fe06f          	j	ffffffffc020064c <intr_enable>
		b->units += cur->next->units;
ffffffffc0201a8a:	4314                	lw	a3,0(a4)
		b->next = cur->next->next;
ffffffffc0201a8c:	6718                	ld	a4,8(a4)
		b->units += cur->next->units;
ffffffffc0201a8e:	9e35                	addw	a2,a2,a3
ffffffffc0201a90:	c110                	sw	a2,0(a0)
		b->next = cur->next->next;
ffffffffc0201a92:	e518                	sd	a4,8(a0)
ffffffffc0201a94:	b77d                	j	ffffffffc0201a42 <slob_free+0xb6>
		cur->units += b->units;
ffffffffc0201a96:	4118                	lw	a4,0(a0)
		cur->next = b->next;
ffffffffc0201a98:	6510                	ld	a2,8(a0)
		cur->units += b->units;
ffffffffc0201a9a:	9eb9                	addw	a3,a3,a4
ffffffffc0201a9c:	c394                	sw	a3,0(a5)
		cur->next = b->next;
ffffffffc0201a9e:	e790                	sd	a2,8(a5)
ffffffffc0201aa0:	bf45                	j	ffffffffc0201a50 <slob_free+0xc4>

ffffffffc0201aa2 <__slob_get_free_pages.isra.0>:
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201aa2:	4785                	li	a5,1
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201aa4:	1141                	addi	sp,sp,-16
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201aa6:	00a7953b          	sllw	a0,a5,a0
static void* __slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201aaa:	e406                	sd	ra,8(sp)
  struct Page * page = alloc_pages(1 << order);
ffffffffc0201aac:	378000ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
  if(!page)
ffffffffc0201ab0:	cd1d                	beqz	a0,ffffffffc0201aee <__slob_get_free_pages.isra.0+0x4c>
    return page - pages + nbase;
ffffffffc0201ab2:	000ab797          	auipc	a5,0xab
ffffffffc0201ab6:	e1e78793          	addi	a5,a5,-482 # ffffffffc02ac8d0 <pages>
ffffffffc0201aba:	6394                	ld	a3,0(a5)
ffffffffc0201abc:	00007797          	auipc	a5,0x7
ffffffffc0201ac0:	1fc78793          	addi	a5,a5,508 # ffffffffc0208cb8 <nbase>
ffffffffc0201ac4:	8d15                	sub	a0,a0,a3
ffffffffc0201ac6:	6394                	ld	a3,0(a5)
ffffffffc0201ac8:	8519                	srai	a0,a0,0x6
    return KADDR(page2pa(page));
ffffffffc0201aca:	000ab797          	auipc	a5,0xab
ffffffffc0201ace:	d9678793          	addi	a5,a5,-618 # ffffffffc02ac860 <npage>
    return page - pages + nbase;
ffffffffc0201ad2:	9536                	add	a0,a0,a3
    return KADDR(page2pa(page));
ffffffffc0201ad4:	6398                	ld	a4,0(a5)
ffffffffc0201ad6:	00c51793          	slli	a5,a0,0xc
ffffffffc0201ada:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201adc:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201ade:	00e7fb63          	bgeu	a5,a4,ffffffffc0201af4 <__slob_get_free_pages.isra.0+0x52>
ffffffffc0201ae2:	000ab797          	auipc	a5,0xab
ffffffffc0201ae6:	dde78793          	addi	a5,a5,-546 # ffffffffc02ac8c0 <va_pa_offset>
ffffffffc0201aea:	6394                	ld	a3,0(a5)
ffffffffc0201aec:	9536                	add	a0,a0,a3
}
ffffffffc0201aee:	60a2                	ld	ra,8(sp)
ffffffffc0201af0:	0141                	addi	sp,sp,16
ffffffffc0201af2:	8082                	ret
ffffffffc0201af4:	86aa                	mv	a3,a0
ffffffffc0201af6:	00006617          	auipc	a2,0x6
ffffffffc0201afa:	87260613          	addi	a2,a2,-1934 # ffffffffc0207368 <default_pmm_manager+0x50>
ffffffffc0201afe:	06900593          	li	a1,105
ffffffffc0201b02:	00006517          	auipc	a0,0x6
ffffffffc0201b06:	88e50513          	addi	a0,a0,-1906 # ffffffffc0207390 <default_pmm_manager+0x78>
ffffffffc0201b0a:	977fe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0201b0e <slob_alloc.isra.1.constprop.3>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201b0e:	1101                	addi	sp,sp,-32
ffffffffc0201b10:	ec06                	sd	ra,24(sp)
ffffffffc0201b12:	e822                	sd	s0,16(sp)
ffffffffc0201b14:	e426                	sd	s1,8(sp)
ffffffffc0201b16:	e04a                	sd	s2,0(sp)
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201b18:	01050713          	addi	a4,a0,16
ffffffffc0201b1c:	6785                	lui	a5,0x1
ffffffffc0201b1e:	0cf77563          	bgeu	a4,a5,ffffffffc0201be8 <slob_alloc.isra.1.constprop.3+0xda>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201b22:	00f50493          	addi	s1,a0,15
ffffffffc0201b26:	8091                	srli	s1,s1,0x4
ffffffffc0201b28:	2481                	sext.w	s1,s1
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b2a:	10002673          	csrr	a2,sstatus
ffffffffc0201b2e:	8a09                	andi	a2,a2,2
ffffffffc0201b30:	e64d                	bnez	a2,ffffffffc0201bda <slob_alloc.isra.1.constprop.3+0xcc>
	prev = slobfree;
ffffffffc0201b32:	000a0917          	auipc	s2,0xa0
ffffffffc0201b36:	8fe90913          	addi	s2,s2,-1794 # ffffffffc02a1430 <slobfree>
ffffffffc0201b3a:	00093683          	ld	a3,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b3e:	669c                	ld	a5,8(a3)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b40:	4398                	lw	a4,0(a5)
ffffffffc0201b42:	0a975063          	bge	a4,s1,ffffffffc0201be2 <slob_alloc.isra.1.constprop.3+0xd4>
		if (cur == slobfree) {
ffffffffc0201b46:	00d78b63          	beq	a5,a3,ffffffffc0201b5c <slob_alloc.isra.1.constprop.3+0x4e>
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b4a:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b4c:	4018                	lw	a4,0(s0)
ffffffffc0201b4e:	02975a63          	bge	a4,s1,ffffffffc0201b82 <slob_alloc.isra.1.constprop.3+0x74>
ffffffffc0201b52:	00093683          	ld	a3,0(s2)
ffffffffc0201b56:	87a2                	mv	a5,s0
		if (cur == slobfree) {
ffffffffc0201b58:	fed799e3          	bne	a5,a3,ffffffffc0201b4a <slob_alloc.isra.1.constprop.3+0x3c>
    if (flag) {
ffffffffc0201b5c:	e225                	bnez	a2,ffffffffc0201bbc <slob_alloc.isra.1.constprop.3+0xae>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201b5e:	4501                	li	a0,0
ffffffffc0201b60:	f43ff0ef          	jal	ra,ffffffffc0201aa2 <__slob_get_free_pages.isra.0>
ffffffffc0201b64:	842a                	mv	s0,a0
			if (!cur)
ffffffffc0201b66:	cd15                	beqz	a0,ffffffffc0201ba2 <slob_alloc.isra.1.constprop.3+0x94>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201b68:	6585                	lui	a1,0x1
ffffffffc0201b6a:	e23ff0ef          	jal	ra,ffffffffc020198c <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b6e:	10002673          	csrr	a2,sstatus
ffffffffc0201b72:	8a09                	andi	a2,a2,2
ffffffffc0201b74:	ee15                	bnez	a2,ffffffffc0201bb0 <slob_alloc.isra.1.constprop.3+0xa2>
			cur = slobfree;
ffffffffc0201b76:	00093783          	ld	a5,0(s2)
	for (cur = prev->next; ; prev = cur, cur = cur->next) {
ffffffffc0201b7a:	6780                	ld	s0,8(a5)
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201b7c:	4018                	lw	a4,0(s0)
ffffffffc0201b7e:	fc974ae3          	blt	a4,s1,ffffffffc0201b52 <slob_alloc.isra.1.constprop.3+0x44>
			if (cur->units == units) /* exact fit? */
ffffffffc0201b82:	04e48963          	beq	s1,a4,ffffffffc0201bd4 <slob_alloc.isra.1.constprop.3+0xc6>
				prev->next = cur + units;
ffffffffc0201b86:	00449693          	slli	a3,s1,0x4
ffffffffc0201b8a:	96a2                	add	a3,a3,s0
ffffffffc0201b8c:	e794                	sd	a3,8(a5)
				prev->next->next = cur->next;
ffffffffc0201b8e:	640c                	ld	a1,8(s0)
				prev->next->units = cur->units - units;
ffffffffc0201b90:	9f05                	subw	a4,a4,s1
ffffffffc0201b92:	c298                	sw	a4,0(a3)
				prev->next->next = cur->next;
ffffffffc0201b94:	e68c                	sd	a1,8(a3)
				cur->units = units;
ffffffffc0201b96:	c004                	sw	s1,0(s0)
			slobfree = prev;
ffffffffc0201b98:	000a0717          	auipc	a4,0xa0
ffffffffc0201b9c:	88f73c23          	sd	a5,-1896(a4) # ffffffffc02a1430 <slobfree>
    if (flag) {
ffffffffc0201ba0:	e20d                	bnez	a2,ffffffffc0201bc2 <slob_alloc.isra.1.constprop.3+0xb4>
}
ffffffffc0201ba2:	8522                	mv	a0,s0
ffffffffc0201ba4:	60e2                	ld	ra,24(sp)
ffffffffc0201ba6:	6442                	ld	s0,16(sp)
ffffffffc0201ba8:	64a2                	ld	s1,8(sp)
ffffffffc0201baa:	6902                	ld	s2,0(sp)
ffffffffc0201bac:	6105                	addi	sp,sp,32
ffffffffc0201bae:	8082                	ret
        intr_disable();
ffffffffc0201bb0:	aa3fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc0201bb4:	4605                	li	a2,1
			cur = slobfree;
ffffffffc0201bb6:	00093783          	ld	a5,0(s2)
ffffffffc0201bba:	b7c1                	j	ffffffffc0201b7a <slob_alloc.isra.1.constprop.3+0x6c>
        intr_enable();
ffffffffc0201bbc:	a91fe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201bc0:	bf79                	j	ffffffffc0201b5e <slob_alloc.isra.1.constprop.3+0x50>
ffffffffc0201bc2:	a8bfe0ef          	jal	ra,ffffffffc020064c <intr_enable>
}
ffffffffc0201bc6:	8522                	mv	a0,s0
ffffffffc0201bc8:	60e2                	ld	ra,24(sp)
ffffffffc0201bca:	6442                	ld	s0,16(sp)
ffffffffc0201bcc:	64a2                	ld	s1,8(sp)
ffffffffc0201bce:	6902                	ld	s2,0(sp)
ffffffffc0201bd0:	6105                	addi	sp,sp,32
ffffffffc0201bd2:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201bd4:	6418                	ld	a4,8(s0)
ffffffffc0201bd6:	e798                	sd	a4,8(a5)
ffffffffc0201bd8:	b7c1                	j	ffffffffc0201b98 <slob_alloc.isra.1.constprop.3+0x8a>
        intr_disable();
ffffffffc0201bda:	a79fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc0201bde:	4605                	li	a2,1
ffffffffc0201be0:	bf89                	j	ffffffffc0201b32 <slob_alloc.isra.1.constprop.3+0x24>
		if (cur->units >= units + delta) { /* room enough? */
ffffffffc0201be2:	843e                	mv	s0,a5
ffffffffc0201be4:	87b6                	mv	a5,a3
ffffffffc0201be6:	bf71                	j	ffffffffc0201b82 <slob_alloc.isra.1.constprop.3+0x74>
  assert( (size + SLOB_UNIT) < PAGE_SIZE );
ffffffffc0201be8:	00006697          	auipc	a3,0x6
ffffffffc0201bec:	82068693          	addi	a3,a3,-2016 # ffffffffc0207408 <default_pmm_manager+0xf0>
ffffffffc0201bf0:	00005617          	auipc	a2,0x5
ffffffffc0201bf4:	fe060613          	addi	a2,a2,-32 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0201bf8:	06400593          	li	a1,100
ffffffffc0201bfc:	00006517          	auipc	a0,0x6
ffffffffc0201c00:	82c50513          	addi	a0,a0,-2004 # ffffffffc0207428 <default_pmm_manager+0x110>
ffffffffc0201c04:	87dfe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0201c08 <kmalloc_init>:
slob_init(void) {
  cprintf("use SLOB allocator\n");
}

inline void 
kmalloc_init(void) {
ffffffffc0201c08:	1141                	addi	sp,sp,-16
  cprintf("use SLOB allocator\n");
ffffffffc0201c0a:	00006517          	auipc	a0,0x6
ffffffffc0201c0e:	83650513          	addi	a0,a0,-1994 # ffffffffc0207440 <default_pmm_manager+0x128>
kmalloc_init(void) {
ffffffffc0201c12:	e406                	sd	ra,8(sp)
  cprintf("use SLOB allocator\n");
ffffffffc0201c14:	d7afe0ef          	jal	ra,ffffffffc020018e <cprintf>
    slob_init();
    cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201c18:	60a2                	ld	ra,8(sp)
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c1a:	00005517          	auipc	a0,0x5
ffffffffc0201c1e:	7ce50513          	addi	a0,a0,1998 # ffffffffc02073e8 <default_pmm_manager+0xd0>
}
ffffffffc0201c22:	0141                	addi	sp,sp,16
    cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c24:	d6afe06f          	j	ffffffffc020018e <cprintf>

ffffffffc0201c28 <kallocated>:
}

size_t
kallocated(void) {
   return slob_allocated();
}
ffffffffc0201c28:	4501                	li	a0,0
ffffffffc0201c2a:	8082                	ret

ffffffffc0201c2c <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201c2c:	1101                	addi	sp,sp,-32
ffffffffc0201c2e:	e04a                	sd	s2,0(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c30:	6905                	lui	s2,0x1
{
ffffffffc0201c32:	e822                	sd	s0,16(sp)
ffffffffc0201c34:	ec06                	sd	ra,24(sp)
ffffffffc0201c36:	e426                	sd	s1,8(sp)
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c38:	fef90793          	addi	a5,s2,-17 # fef <_binary_obj___user_faultread_out_size-0x85d9>
{
ffffffffc0201c3c:	842a                	mv	s0,a0
	if (size < PAGE_SIZE - SLOB_UNIT) {
ffffffffc0201c3e:	04a7fc63          	bgeu	a5,a0,ffffffffc0201c96 <kmalloc+0x6a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201c42:	4561                	li	a0,24
ffffffffc0201c44:	ecbff0ef          	jal	ra,ffffffffc0201b0e <slob_alloc.isra.1.constprop.3>
ffffffffc0201c48:	84aa                	mv	s1,a0
	if (!bb)
ffffffffc0201c4a:	cd21                	beqz	a0,ffffffffc0201ca2 <kmalloc+0x76>
	bb->order = find_order(size);
ffffffffc0201c4c:	0004079b          	sext.w	a5,s0
	int order = 0;
ffffffffc0201c50:	4501                	li	a0,0
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201c52:	00f95763          	bge	s2,a5,ffffffffc0201c60 <kmalloc+0x34>
ffffffffc0201c56:	6705                	lui	a4,0x1
ffffffffc0201c58:	8785                	srai	a5,a5,0x1
		order++;
ffffffffc0201c5a:	2505                	addiw	a0,a0,1
	for ( ; size > 4096 ; size >>=1)
ffffffffc0201c5c:	fef74ee3          	blt	a4,a5,ffffffffc0201c58 <kmalloc+0x2c>
	bb->order = find_order(size);
ffffffffc0201c60:	c088                	sw	a0,0(s1)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201c62:	e41ff0ef          	jal	ra,ffffffffc0201aa2 <__slob_get_free_pages.isra.0>
ffffffffc0201c66:	e488                	sd	a0,8(s1)
ffffffffc0201c68:	842a                	mv	s0,a0
	if (bb->pages) {
ffffffffc0201c6a:	c935                	beqz	a0,ffffffffc0201cde <kmalloc+0xb2>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c6c:	100027f3          	csrr	a5,sstatus
ffffffffc0201c70:	8b89                	andi	a5,a5,2
ffffffffc0201c72:	e3a1                	bnez	a5,ffffffffc0201cb2 <kmalloc+0x86>
		bb->next = bigblocks;
ffffffffc0201c74:	000ab797          	auipc	a5,0xab
ffffffffc0201c78:	bdc78793          	addi	a5,a5,-1060 # ffffffffc02ac850 <bigblocks>
ffffffffc0201c7c:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201c7e:	000ab717          	auipc	a4,0xab
ffffffffc0201c82:	bc973923          	sd	s1,-1070(a4) # ffffffffc02ac850 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201c86:	e89c                	sd	a5,16(s1)
  return __kmalloc(size, 0);
}
ffffffffc0201c88:	8522                	mv	a0,s0
ffffffffc0201c8a:	60e2                	ld	ra,24(sp)
ffffffffc0201c8c:	6442                	ld	s0,16(sp)
ffffffffc0201c8e:	64a2                	ld	s1,8(sp)
ffffffffc0201c90:	6902                	ld	s2,0(sp)
ffffffffc0201c92:	6105                	addi	sp,sp,32
ffffffffc0201c94:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201c96:	0541                	addi	a0,a0,16
ffffffffc0201c98:	e77ff0ef          	jal	ra,ffffffffc0201b0e <slob_alloc.isra.1.constprop.3>
		return m ? (void *)(m + 1) : 0;
ffffffffc0201c9c:	01050413          	addi	s0,a0,16
ffffffffc0201ca0:	f565                	bnez	a0,ffffffffc0201c88 <kmalloc+0x5c>
ffffffffc0201ca2:	4401                	li	s0,0
}
ffffffffc0201ca4:	8522                	mv	a0,s0
ffffffffc0201ca6:	60e2                	ld	ra,24(sp)
ffffffffc0201ca8:	6442                	ld	s0,16(sp)
ffffffffc0201caa:	64a2                	ld	s1,8(sp)
ffffffffc0201cac:	6902                	ld	s2,0(sp)
ffffffffc0201cae:	6105                	addi	sp,sp,32
ffffffffc0201cb0:	8082                	ret
        intr_disable();
ffffffffc0201cb2:	9a1fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201cb6:	000ab797          	auipc	a5,0xab
ffffffffc0201cba:	b9a78793          	addi	a5,a5,-1126 # ffffffffc02ac850 <bigblocks>
ffffffffc0201cbe:	639c                	ld	a5,0(a5)
		bigblocks = bb;
ffffffffc0201cc0:	000ab717          	auipc	a4,0xab
ffffffffc0201cc4:	b8973823          	sd	s1,-1136(a4) # ffffffffc02ac850 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201cc8:	e89c                	sd	a5,16(s1)
        intr_enable();
ffffffffc0201cca:	983fe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201cce:	6480                	ld	s0,8(s1)
}
ffffffffc0201cd0:	60e2                	ld	ra,24(sp)
ffffffffc0201cd2:	64a2                	ld	s1,8(sp)
ffffffffc0201cd4:	8522                	mv	a0,s0
ffffffffc0201cd6:	6442                	ld	s0,16(sp)
ffffffffc0201cd8:	6902                	ld	s2,0(sp)
ffffffffc0201cda:	6105                	addi	sp,sp,32
ffffffffc0201cdc:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201cde:	45e1                	li	a1,24
ffffffffc0201ce0:	8526                	mv	a0,s1
ffffffffc0201ce2:	cabff0ef          	jal	ra,ffffffffc020198c <slob_free>
  return __kmalloc(size, 0);
ffffffffc0201ce6:	b74d                	j	ffffffffc0201c88 <kmalloc+0x5c>

ffffffffc0201ce8 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201ce8:	c165                	beqz	a0,ffffffffc0201dc8 <kfree+0xe0>
{
ffffffffc0201cea:	1101                	addi	sp,sp,-32
ffffffffc0201cec:	e426                	sd	s1,8(sp)
ffffffffc0201cee:	ec06                	sd	ra,24(sp)
ffffffffc0201cf0:	e822                	sd	s0,16(sp)
		return;

	if (!((unsigned long)block & (PAGE_SIZE-1))) {
ffffffffc0201cf2:	03451793          	slli	a5,a0,0x34
ffffffffc0201cf6:	84aa                	mv	s1,a0
ffffffffc0201cf8:	eb8d                	bnez	a5,ffffffffc0201d2a <kfree+0x42>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201cfa:	100027f3          	csrr	a5,sstatus
ffffffffc0201cfe:	8b89                	andi	a5,a5,2
ffffffffc0201d00:	ebd9                	bnez	a5,ffffffffc0201d96 <kfree+0xae>
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d02:	000ab797          	auipc	a5,0xab
ffffffffc0201d06:	b4e78793          	addi	a5,a5,-1202 # ffffffffc02ac850 <bigblocks>
ffffffffc0201d0a:	6394                	ld	a3,0(a5)
ffffffffc0201d0c:	ce99                	beqz	a3,ffffffffc0201d2a <kfree+0x42>
			if (bb->pages == block) {
ffffffffc0201d0e:	669c                	ld	a5,8(a3)
ffffffffc0201d10:	6a80                	ld	s0,16(a3)
ffffffffc0201d12:	0af50c63          	beq	a0,a5,ffffffffc0201dca <kfree+0xe2>
    return 0;
ffffffffc0201d16:	4601                	li	a2,0
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d18:	c801                	beqz	s0,ffffffffc0201d28 <kfree+0x40>
			if (bb->pages == block) {
ffffffffc0201d1a:	6418                	ld	a4,8(s0)
ffffffffc0201d1c:	681c                	ld	a5,16(s0)
ffffffffc0201d1e:	00970e63          	beq	a4,s1,ffffffffc0201d3a <kfree+0x52>
ffffffffc0201d22:	86a2                	mv	a3,s0
ffffffffc0201d24:	843e                	mv	s0,a5
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d26:	f875                	bnez	s0,ffffffffc0201d1a <kfree+0x32>
    if (flag) {
ffffffffc0201d28:	e649                	bnez	a2,ffffffffc0201db2 <kfree+0xca>
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201d2a:	6442                	ld	s0,16(sp)
ffffffffc0201d2c:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d2e:	ff048513          	addi	a0,s1,-16
}
ffffffffc0201d32:	64a2                	ld	s1,8(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d34:	4581                	li	a1,0
}
ffffffffc0201d36:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d38:	b991                	j	ffffffffc020198c <slob_free>
				*last = bb->next;
ffffffffc0201d3a:	ea9c                	sd	a5,16(a3)
ffffffffc0201d3c:	e259                	bnez	a2,ffffffffc0201dc2 <kfree+0xda>
    return pa2page(PADDR(kva));
ffffffffc0201d3e:	c02007b7          	lui	a5,0xc0200
				__slob_free_pages((unsigned long)block, bb->order);
ffffffffc0201d42:	4018                	lw	a4,0(s0)
ffffffffc0201d44:	08f4e963          	bltu	s1,a5,ffffffffc0201dd6 <kfree+0xee>
ffffffffc0201d48:	000ab797          	auipc	a5,0xab
ffffffffc0201d4c:	b7878793          	addi	a5,a5,-1160 # ffffffffc02ac8c0 <va_pa_offset>
ffffffffc0201d50:	6394                	ld	a3,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0201d52:	000ab797          	auipc	a5,0xab
ffffffffc0201d56:	b0e78793          	addi	a5,a5,-1266 # ffffffffc02ac860 <npage>
ffffffffc0201d5a:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0201d5c:	8c95                	sub	s1,s1,a3
    if (PPN(pa) >= npage) {
ffffffffc0201d5e:	80b1                	srli	s1,s1,0xc
ffffffffc0201d60:	08f4f863          	bgeu	s1,a5,ffffffffc0201df0 <kfree+0x108>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d64:	00007797          	auipc	a5,0x7
ffffffffc0201d68:	f5478793          	addi	a5,a5,-172 # ffffffffc0208cb8 <nbase>
ffffffffc0201d6c:	639c                	ld	a5,0(a5)
ffffffffc0201d6e:	000ab697          	auipc	a3,0xab
ffffffffc0201d72:	b6268693          	addi	a3,a3,-1182 # ffffffffc02ac8d0 <pages>
ffffffffc0201d76:	6288                	ld	a0,0(a3)
ffffffffc0201d78:	8c9d                	sub	s1,s1,a5
ffffffffc0201d7a:	049a                	slli	s1,s1,0x6
  free_pages(kva2page(kva), 1 << order);
ffffffffc0201d7c:	4585                	li	a1,1
ffffffffc0201d7e:	9526                	add	a0,a0,s1
ffffffffc0201d80:	00e595bb          	sllw	a1,a1,a4
ffffffffc0201d84:	128000ef          	jal	ra,ffffffffc0201eac <free_pages>
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201d88:	8522                	mv	a0,s0
}
ffffffffc0201d8a:	6442                	ld	s0,16(sp)
ffffffffc0201d8c:	60e2                	ld	ra,24(sp)
ffffffffc0201d8e:	64a2                	ld	s1,8(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201d90:	45e1                	li	a1,24
}
ffffffffc0201d92:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d94:	bee5                	j	ffffffffc020198c <slob_free>
        intr_disable();
ffffffffc0201d96:	8bdfe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next) {
ffffffffc0201d9a:	000ab797          	auipc	a5,0xab
ffffffffc0201d9e:	ab678793          	addi	a5,a5,-1354 # ffffffffc02ac850 <bigblocks>
ffffffffc0201da2:	6394                	ld	a3,0(a5)
ffffffffc0201da4:	c699                	beqz	a3,ffffffffc0201db2 <kfree+0xca>
			if (bb->pages == block) {
ffffffffc0201da6:	669c                	ld	a5,8(a3)
ffffffffc0201da8:	6a80                	ld	s0,16(a3)
ffffffffc0201daa:	00f48763          	beq	s1,a5,ffffffffc0201db8 <kfree+0xd0>
        return 1;
ffffffffc0201dae:	4605                	li	a2,1
ffffffffc0201db0:	b7a5                	j	ffffffffc0201d18 <kfree+0x30>
        intr_enable();
ffffffffc0201db2:	89bfe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201db6:	bf95                	j	ffffffffc0201d2a <kfree+0x42>
				*last = bb->next;
ffffffffc0201db8:	000ab797          	auipc	a5,0xab
ffffffffc0201dbc:	a887bc23          	sd	s0,-1384(a5) # ffffffffc02ac850 <bigblocks>
ffffffffc0201dc0:	8436                	mv	s0,a3
ffffffffc0201dc2:	88bfe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201dc6:	bfa5                	j	ffffffffc0201d3e <kfree+0x56>
ffffffffc0201dc8:	8082                	ret
ffffffffc0201dca:	000ab797          	auipc	a5,0xab
ffffffffc0201dce:	a887b323          	sd	s0,-1402(a5) # ffffffffc02ac850 <bigblocks>
ffffffffc0201dd2:	8436                	mv	s0,a3
ffffffffc0201dd4:	b7ad                	j	ffffffffc0201d3e <kfree+0x56>
    return pa2page(PADDR(kva));
ffffffffc0201dd6:	86a6                	mv	a3,s1
ffffffffc0201dd8:	00005617          	auipc	a2,0x5
ffffffffc0201ddc:	5c860613          	addi	a2,a2,1480 # ffffffffc02073a0 <default_pmm_manager+0x88>
ffffffffc0201de0:	06e00593          	li	a1,110
ffffffffc0201de4:	00005517          	auipc	a0,0x5
ffffffffc0201de8:	5ac50513          	addi	a0,a0,1452 # ffffffffc0207390 <default_pmm_manager+0x78>
ffffffffc0201dec:	e94fe0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0201df0:	00005617          	auipc	a2,0x5
ffffffffc0201df4:	5d860613          	addi	a2,a2,1496 # ffffffffc02073c8 <default_pmm_manager+0xb0>
ffffffffc0201df8:	06200593          	li	a1,98
ffffffffc0201dfc:	00005517          	auipc	a0,0x5
ffffffffc0201e00:	59450513          	addi	a0,a0,1428 # ffffffffc0207390 <default_pmm_manager+0x78>
ffffffffc0201e04:	e7cfe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0201e08 <pa2page.part.4>:
pa2page(uintptr_t pa) {
ffffffffc0201e08:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201e0a:	00005617          	auipc	a2,0x5
ffffffffc0201e0e:	5be60613          	addi	a2,a2,1470 # ffffffffc02073c8 <default_pmm_manager+0xb0>
ffffffffc0201e12:	06200593          	li	a1,98
ffffffffc0201e16:	00005517          	auipc	a0,0x5
ffffffffc0201e1a:	57a50513          	addi	a0,a0,1402 # ffffffffc0207390 <default_pmm_manager+0x78>
pa2page(uintptr_t pa) {
ffffffffc0201e1e:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201e20:	e60fe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0201e24 <alloc_pages>:
    pmm_manager->init_memmap(base, n);
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
ffffffffc0201e24:	715d                	addi	sp,sp,-80
ffffffffc0201e26:	e0a2                	sd	s0,64(sp)
ffffffffc0201e28:	fc26                	sd	s1,56(sp)
ffffffffc0201e2a:	f84a                	sd	s2,48(sp)
ffffffffc0201e2c:	f44e                	sd	s3,40(sp)
ffffffffc0201e2e:	f052                	sd	s4,32(sp)
ffffffffc0201e30:	ec56                	sd	s5,24(sp)
ffffffffc0201e32:	e486                	sd	ra,72(sp)
ffffffffc0201e34:	842a                	mv	s0,a0
ffffffffc0201e36:	000ab497          	auipc	s1,0xab
ffffffffc0201e3a:	a8248493          	addi	s1,s1,-1406 # ffffffffc02ac8b8 <pmm_manager>
        {
            page = pmm_manager->alloc_pages(n);
        }
        local_intr_restore(intr_flag);

        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201e3e:	4985                	li	s3,1
ffffffffc0201e40:	000aba17          	auipc	s4,0xab
ffffffffc0201e44:	a30a0a13          	addi	s4,s4,-1488 # ffffffffc02ac870 <swap_init_ok>

        extern struct mm_struct *check_mm_struct;
        // cprintf("page %x, call swap_out in alloc_pages %d\n",page, n);
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e48:	0005091b          	sext.w	s2,a0
ffffffffc0201e4c:	000aba97          	auipc	s5,0xab
ffffffffc0201e50:	b64a8a93          	addi	s5,s5,-1180 # ffffffffc02ac9b0 <check_mm_struct>
ffffffffc0201e54:	a00d                	j	ffffffffc0201e76 <alloc_pages+0x52>
            page = pmm_manager->alloc_pages(n);
ffffffffc0201e56:	609c                	ld	a5,0(s1)
ffffffffc0201e58:	6f9c                	ld	a5,24(a5)
ffffffffc0201e5a:	9782                	jalr	a5
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e5c:	4601                	li	a2,0
ffffffffc0201e5e:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201e60:	ed0d                	bnez	a0,ffffffffc0201e9a <alloc_pages+0x76>
ffffffffc0201e62:	0289ec63          	bltu	s3,s0,ffffffffc0201e9a <alloc_pages+0x76>
ffffffffc0201e66:	000a2783          	lw	a5,0(s4)
ffffffffc0201e6a:	2781                	sext.w	a5,a5
ffffffffc0201e6c:	c79d                	beqz	a5,ffffffffc0201e9a <alloc_pages+0x76>
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e6e:	000ab503          	ld	a0,0(s5)
ffffffffc0201e72:	47f010ef          	jal	ra,ffffffffc0203af0 <swap_out>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201e76:	100027f3          	csrr	a5,sstatus
ffffffffc0201e7a:	8b89                	andi	a5,a5,2
            page = pmm_manager->alloc_pages(n);
ffffffffc0201e7c:	8522                	mv	a0,s0
ffffffffc0201e7e:	dfe1                	beqz	a5,ffffffffc0201e56 <alloc_pages+0x32>
        intr_disable();
ffffffffc0201e80:	fd2fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
ffffffffc0201e84:	609c                	ld	a5,0(s1)
ffffffffc0201e86:	8522                	mv	a0,s0
ffffffffc0201e88:	6f9c                	ld	a5,24(a5)
ffffffffc0201e8a:	9782                	jalr	a5
ffffffffc0201e8c:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201e8e:	fbefe0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0201e92:	6522                	ld	a0,8(sp)
        swap_out(check_mm_struct, n, 0);
ffffffffc0201e94:	4601                	li	a2,0
ffffffffc0201e96:	85ca                	mv	a1,s2
        if (page != NULL || n > 1 || swap_init_ok == 0) break;
ffffffffc0201e98:	d569                	beqz	a0,ffffffffc0201e62 <alloc_pages+0x3e>
    }
    // cprintf("n %d,get page %x, No %d in alloc_pages\n",n,page,(page-pages));
    return page;
}
ffffffffc0201e9a:	60a6                	ld	ra,72(sp)
ffffffffc0201e9c:	6406                	ld	s0,64(sp)
ffffffffc0201e9e:	74e2                	ld	s1,56(sp)
ffffffffc0201ea0:	7942                	ld	s2,48(sp)
ffffffffc0201ea2:	79a2                	ld	s3,40(sp)
ffffffffc0201ea4:	7a02                	ld	s4,32(sp)
ffffffffc0201ea6:	6ae2                	ld	s5,24(sp)
ffffffffc0201ea8:	6161                	addi	sp,sp,80
ffffffffc0201eaa:	8082                	ret

ffffffffc0201eac <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201eac:	100027f3          	csrr	a5,sstatus
ffffffffc0201eb0:	8b89                	andi	a5,a5,2
ffffffffc0201eb2:	eb89                	bnez	a5,ffffffffc0201ec4 <free_pages+0x18>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201eb4:	000ab797          	auipc	a5,0xab
ffffffffc0201eb8:	a0478793          	addi	a5,a5,-1532 # ffffffffc02ac8b8 <pmm_manager>
ffffffffc0201ebc:	639c                	ld	a5,0(a5)
ffffffffc0201ebe:	0207b303          	ld	t1,32(a5)
ffffffffc0201ec2:	8302                	jr	t1
void free_pages(struct Page *base, size_t n) {
ffffffffc0201ec4:	1101                	addi	sp,sp,-32
ffffffffc0201ec6:	ec06                	sd	ra,24(sp)
ffffffffc0201ec8:	e822                	sd	s0,16(sp)
ffffffffc0201eca:	e426                	sd	s1,8(sp)
ffffffffc0201ecc:	842a                	mv	s0,a0
ffffffffc0201ece:	84ae                	mv	s1,a1
        intr_disable();
ffffffffc0201ed0:	f82fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201ed4:	000ab797          	auipc	a5,0xab
ffffffffc0201ed8:	9e478793          	addi	a5,a5,-1564 # ffffffffc02ac8b8 <pmm_manager>
ffffffffc0201edc:	639c                	ld	a5,0(a5)
ffffffffc0201ede:	85a6                	mv	a1,s1
ffffffffc0201ee0:	8522                	mv	a0,s0
ffffffffc0201ee2:	739c                	ld	a5,32(a5)
ffffffffc0201ee4:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201ee6:	6442                	ld	s0,16(sp)
ffffffffc0201ee8:	60e2                	ld	ra,24(sp)
ffffffffc0201eea:	64a2                	ld	s1,8(sp)
ffffffffc0201eec:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201eee:	f5efe06f          	j	ffffffffc020064c <intr_enable>

ffffffffc0201ef2 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ef2:	100027f3          	csrr	a5,sstatus
ffffffffc0201ef6:	8b89                	andi	a5,a5,2
ffffffffc0201ef8:	eb89                	bnez	a5,ffffffffc0201f0a <nr_free_pages+0x18>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201efa:	000ab797          	auipc	a5,0xab
ffffffffc0201efe:	9be78793          	addi	a5,a5,-1602 # ffffffffc02ac8b8 <pmm_manager>
ffffffffc0201f02:	639c                	ld	a5,0(a5)
ffffffffc0201f04:	0287b303          	ld	t1,40(a5)
ffffffffc0201f08:	8302                	jr	t1
size_t nr_free_pages(void) {
ffffffffc0201f0a:	1141                	addi	sp,sp,-16
ffffffffc0201f0c:	e406                	sd	ra,8(sp)
ffffffffc0201f0e:	e022                	sd	s0,0(sp)
        intr_disable();
ffffffffc0201f10:	f42fe0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f14:	000ab797          	auipc	a5,0xab
ffffffffc0201f18:	9a478793          	addi	a5,a5,-1628 # ffffffffc02ac8b8 <pmm_manager>
ffffffffc0201f1c:	639c                	ld	a5,0(a5)
ffffffffc0201f1e:	779c                	ld	a5,40(a5)
ffffffffc0201f20:	9782                	jalr	a5
ffffffffc0201f22:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0201f24:	f28fe0ef          	jal	ra,ffffffffc020064c <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201f28:	8522                	mv	a0,s0
ffffffffc0201f2a:	60a2                	ld	ra,8(sp)
ffffffffc0201f2c:	6402                	ld	s0,0(sp)
ffffffffc0201f2e:	0141                	addi	sp,sp,16
ffffffffc0201f30:	8082                	ret

ffffffffc0201f32 <get_pte>:
// parameter:
//  pgdir:  the kernel virtual base address of PDT
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f32:	7139                	addi	sp,sp,-64
ffffffffc0201f34:	f426                	sd	s1,40(sp)
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201f36:	01e5d493          	srli	s1,a1,0x1e
ffffffffc0201f3a:	1ff4f493          	andi	s1,s1,511
ffffffffc0201f3e:	048e                	slli	s1,s1,0x3
ffffffffc0201f40:	94aa                	add	s1,s1,a0
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f42:	6094                	ld	a3,0(s1)
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f44:	f04a                	sd	s2,32(sp)
ffffffffc0201f46:	ec4e                	sd	s3,24(sp)
ffffffffc0201f48:	e852                	sd	s4,16(sp)
ffffffffc0201f4a:	fc06                	sd	ra,56(sp)
ffffffffc0201f4c:	f822                	sd	s0,48(sp)
ffffffffc0201f4e:	e456                	sd	s5,8(sp)
ffffffffc0201f50:	e05a                	sd	s6,0(sp)
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f52:	0016f793          	andi	a5,a3,1
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create) {
ffffffffc0201f56:	892e                	mv	s2,a1
ffffffffc0201f58:	8a32                	mv	s4,a2
ffffffffc0201f5a:	000ab997          	auipc	s3,0xab
ffffffffc0201f5e:	90698993          	addi	s3,s3,-1786 # ffffffffc02ac860 <npage>
    if (!(*pdep1 & PTE_V)) {
ffffffffc0201f62:	e7bd                	bnez	a5,ffffffffc0201fd0 <get_pte+0x9e>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0201f64:	12060c63          	beqz	a2,ffffffffc020209c <get_pte+0x16a>
ffffffffc0201f68:	4505                	li	a0,1
ffffffffc0201f6a:	ebbff0ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0201f6e:	842a                	mv	s0,a0
ffffffffc0201f70:	12050663          	beqz	a0,ffffffffc020209c <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0201f74:	000abb17          	auipc	s6,0xab
ffffffffc0201f78:	95cb0b13          	addi	s6,s6,-1700 # ffffffffc02ac8d0 <pages>
ffffffffc0201f7c:	000b3503          	ld	a0,0(s6)
ffffffffc0201f80:	00080ab7          	lui	s5,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201f84:	000ab997          	auipc	s3,0xab
ffffffffc0201f88:	8dc98993          	addi	s3,s3,-1828 # ffffffffc02ac860 <npage>
ffffffffc0201f8c:	40a40533          	sub	a0,s0,a0
ffffffffc0201f90:	8519                	srai	a0,a0,0x6
ffffffffc0201f92:	9556                	add	a0,a0,s5
ffffffffc0201f94:	0009b703          	ld	a4,0(s3)
ffffffffc0201f98:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0201f9c:	4685                	li	a3,1
ffffffffc0201f9e:	c014                	sw	a3,0(s0)
ffffffffc0201fa0:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fa2:	0532                	slli	a0,a0,0xc
ffffffffc0201fa4:	14e7f363          	bgeu	a5,a4,ffffffffc02020ea <get_pte+0x1b8>
ffffffffc0201fa8:	000ab797          	auipc	a5,0xab
ffffffffc0201fac:	91878793          	addi	a5,a5,-1768 # ffffffffc02ac8c0 <va_pa_offset>
ffffffffc0201fb0:	639c                	ld	a5,0(a5)
ffffffffc0201fb2:	6605                	lui	a2,0x1
ffffffffc0201fb4:	4581                	li	a1,0
ffffffffc0201fb6:	953e                	add	a0,a0,a5
ffffffffc0201fb8:	5f8040ef          	jal	ra,ffffffffc02065b0 <memset>
    return page - pages + nbase;
ffffffffc0201fbc:	000b3683          	ld	a3,0(s6)
ffffffffc0201fc0:	40d406b3          	sub	a3,s0,a3
ffffffffc0201fc4:	8699                	srai	a3,a3,0x6
ffffffffc0201fc6:	96d6                	add	a3,a3,s5
  asm volatile("sfence.vma");
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type) {
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201fc8:	06aa                	slli	a3,a3,0xa
ffffffffc0201fca:	0116e693          	ori	a3,a3,17
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201fce:	e094                	sd	a3,0(s1)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201fd0:	77fd                	lui	a5,0xfffff
ffffffffc0201fd2:	068a                	slli	a3,a3,0x2
ffffffffc0201fd4:	0009b703          	ld	a4,0(s3)
ffffffffc0201fd8:	8efd                	and	a3,a3,a5
ffffffffc0201fda:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201fde:	0ce7f163          	bgeu	a5,a4,ffffffffc02020a0 <get_pte+0x16e>
ffffffffc0201fe2:	000aba97          	auipc	s5,0xab
ffffffffc0201fe6:	8dea8a93          	addi	s5,s5,-1826 # ffffffffc02ac8c0 <va_pa_offset>
ffffffffc0201fea:	000ab403          	ld	s0,0(s5)
ffffffffc0201fee:	01595793          	srli	a5,s2,0x15
ffffffffc0201ff2:	1ff7f793          	andi	a5,a5,511
ffffffffc0201ff6:	96a2                	add	a3,a3,s0
ffffffffc0201ff8:	00379413          	slli	s0,a5,0x3
ffffffffc0201ffc:	9436                	add	s0,s0,a3
    if (!(*pdep0 & PTE_V)) {
ffffffffc0201ffe:	6014                	ld	a3,0(s0)
ffffffffc0202000:	0016f793          	andi	a5,a3,1
ffffffffc0202004:	e3ad                	bnez	a5,ffffffffc0202066 <get_pte+0x134>
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL) {
ffffffffc0202006:	080a0b63          	beqz	s4,ffffffffc020209c <get_pte+0x16a>
ffffffffc020200a:	4505                	li	a0,1
ffffffffc020200c:	e19ff0ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0202010:	84aa                	mv	s1,a0
ffffffffc0202012:	c549                	beqz	a0,ffffffffc020209c <get_pte+0x16a>
    return page - pages + nbase;
ffffffffc0202014:	000abb17          	auipc	s6,0xab
ffffffffc0202018:	8bcb0b13          	addi	s6,s6,-1860 # ffffffffc02ac8d0 <pages>
ffffffffc020201c:	000b3503          	ld	a0,0(s6)
ffffffffc0202020:	00080a37          	lui	s4,0x80
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202024:	0009b703          	ld	a4,0(s3)
ffffffffc0202028:	40a48533          	sub	a0,s1,a0
ffffffffc020202c:	8519                	srai	a0,a0,0x6
ffffffffc020202e:	9552                	add	a0,a0,s4
ffffffffc0202030:	00c51793          	slli	a5,a0,0xc
    page->ref = val;
ffffffffc0202034:	4685                	li	a3,1
ffffffffc0202036:	c094                	sw	a3,0(s1)
ffffffffc0202038:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc020203a:	0532                	slli	a0,a0,0xc
ffffffffc020203c:	08e7fa63          	bgeu	a5,a4,ffffffffc02020d0 <get_pte+0x19e>
ffffffffc0202040:	000ab783          	ld	a5,0(s5)
ffffffffc0202044:	6605                	lui	a2,0x1
ffffffffc0202046:	4581                	li	a1,0
ffffffffc0202048:	953e                	add	a0,a0,a5
ffffffffc020204a:	566040ef          	jal	ra,ffffffffc02065b0 <memset>
    return page - pages + nbase;
ffffffffc020204e:	000b3683          	ld	a3,0(s6)
ffffffffc0202052:	40d486b3          	sub	a3,s1,a3
ffffffffc0202056:	8699                	srai	a3,a3,0x6
ffffffffc0202058:	96d2                	add	a3,a3,s4
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020205a:	06aa                	slli	a3,a3,0xa
ffffffffc020205c:	0116e693          	ori	a3,a3,17
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202060:	e014                	sd	a3,0(s0)
ffffffffc0202062:	0009b703          	ld	a4,0(s3)
        }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202066:	068a                	slli	a3,a3,0x2
ffffffffc0202068:	757d                	lui	a0,0xfffff
ffffffffc020206a:	8ee9                	and	a3,a3,a0
ffffffffc020206c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202070:	04e7f463          	bgeu	a5,a4,ffffffffc02020b8 <get_pte+0x186>
ffffffffc0202074:	000ab503          	ld	a0,0(s5)
ffffffffc0202078:	00c95913          	srli	s2,s2,0xc
ffffffffc020207c:	1ff97913          	andi	s2,s2,511
ffffffffc0202080:	96aa                	add	a3,a3,a0
ffffffffc0202082:	00391513          	slli	a0,s2,0x3
ffffffffc0202086:	9536                	add	a0,a0,a3
}
ffffffffc0202088:	70e2                	ld	ra,56(sp)
ffffffffc020208a:	7442                	ld	s0,48(sp)
ffffffffc020208c:	74a2                	ld	s1,40(sp)
ffffffffc020208e:	7902                	ld	s2,32(sp)
ffffffffc0202090:	69e2                	ld	s3,24(sp)
ffffffffc0202092:	6a42                	ld	s4,16(sp)
ffffffffc0202094:	6aa2                	ld	s5,8(sp)
ffffffffc0202096:	6b02                	ld	s6,0(sp)
ffffffffc0202098:	6121                	addi	sp,sp,64
ffffffffc020209a:	8082                	ret
            return NULL;
ffffffffc020209c:	4501                	li	a0,0
ffffffffc020209e:	b7ed                	j	ffffffffc0202088 <get_pte+0x156>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02020a0:	00005617          	auipc	a2,0x5
ffffffffc02020a4:	2c860613          	addi	a2,a2,712 # ffffffffc0207368 <default_pmm_manager+0x50>
ffffffffc02020a8:	0e300593          	li	a1,227
ffffffffc02020ac:	00005517          	auipc	a0,0x5
ffffffffc02020b0:	3dc50513          	addi	a0,a0,988 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc02020b4:	bccfe0ef          	jal	ra,ffffffffc0200480 <__panic>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02020b8:	00005617          	auipc	a2,0x5
ffffffffc02020bc:	2b060613          	addi	a2,a2,688 # ffffffffc0207368 <default_pmm_manager+0x50>
ffffffffc02020c0:	0ee00593          	li	a1,238
ffffffffc02020c4:	00005517          	auipc	a0,0x5
ffffffffc02020c8:	3c450513          	addi	a0,a0,964 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc02020cc:	bb4fe0ef          	jal	ra,ffffffffc0200480 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02020d0:	86aa                	mv	a3,a0
ffffffffc02020d2:	00005617          	auipc	a2,0x5
ffffffffc02020d6:	29660613          	addi	a2,a2,662 # ffffffffc0207368 <default_pmm_manager+0x50>
ffffffffc02020da:	0eb00593          	li	a1,235
ffffffffc02020de:	00005517          	auipc	a0,0x5
ffffffffc02020e2:	3aa50513          	addi	a0,a0,938 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc02020e6:	b9afe0ef          	jal	ra,ffffffffc0200480 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02020ea:	86aa                	mv	a3,a0
ffffffffc02020ec:	00005617          	auipc	a2,0x5
ffffffffc02020f0:	27c60613          	addi	a2,a2,636 # ffffffffc0207368 <default_pmm_manager+0x50>
ffffffffc02020f4:	0df00593          	li	a1,223
ffffffffc02020f8:	00005517          	auipc	a0,0x5
ffffffffc02020fc:	39050513          	addi	a0,a0,912 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202100:	b80fe0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0202104 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc0202104:	1141                	addi	sp,sp,-16
ffffffffc0202106:	e022                	sd	s0,0(sp)
ffffffffc0202108:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020210a:	4601                	li	a2,0
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store) {
ffffffffc020210c:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc020210e:	e25ff0ef          	jal	ra,ffffffffc0201f32 <get_pte>
    if (ptep_store != NULL) {
ffffffffc0202112:	c011                	beqz	s0,ffffffffc0202116 <get_page+0x12>
        *ptep_store = ptep;
ffffffffc0202114:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc0202116:	c511                	beqz	a0,ffffffffc0202122 <get_page+0x1e>
ffffffffc0202118:	611c                	ld	a5,0(a0)
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc020211a:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V) {
ffffffffc020211c:	0017f713          	andi	a4,a5,1
ffffffffc0202120:	e709                	bnez	a4,ffffffffc020212a <get_page+0x26>
}
ffffffffc0202122:	60a2                	ld	ra,8(sp)
ffffffffc0202124:	6402                	ld	s0,0(sp)
ffffffffc0202126:	0141                	addi	sp,sp,16
ffffffffc0202128:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc020212a:	000aa717          	auipc	a4,0xaa
ffffffffc020212e:	73670713          	addi	a4,a4,1846 # ffffffffc02ac860 <npage>
ffffffffc0202132:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202134:	078a                	slli	a5,a5,0x2
ffffffffc0202136:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202138:	02e7f063          	bgeu	a5,a4,ffffffffc0202158 <get_page+0x54>
    return &pages[PPN(pa) - nbase];
ffffffffc020213c:	000aa717          	auipc	a4,0xaa
ffffffffc0202140:	79470713          	addi	a4,a4,1940 # ffffffffc02ac8d0 <pages>
ffffffffc0202144:	6308                	ld	a0,0(a4)
ffffffffc0202146:	60a2                	ld	ra,8(sp)
ffffffffc0202148:	6402                	ld	s0,0(sp)
ffffffffc020214a:	fff80737          	lui	a4,0xfff80
ffffffffc020214e:	97ba                	add	a5,a5,a4
ffffffffc0202150:	079a                	slli	a5,a5,0x6
ffffffffc0202152:	953e                	add	a0,a0,a5
ffffffffc0202154:	0141                	addi	sp,sp,16
ffffffffc0202156:	8082                	ret
ffffffffc0202158:	cb1ff0ef          	jal	ra,ffffffffc0201e08 <pa2page.part.4>

ffffffffc020215c <unmap_range>:
        *ptep = 0;                  //(5) clear second page table entry
        tlb_invalidate(pgdir, la);  //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020215c:	711d                	addi	sp,sp,-96
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020215e:	00c5e7b3          	or	a5,a1,a2
void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202162:	ec86                	sd	ra,88(sp)
ffffffffc0202164:	e8a2                	sd	s0,80(sp)
ffffffffc0202166:	e4a6                	sd	s1,72(sp)
ffffffffc0202168:	e0ca                	sd	s2,64(sp)
ffffffffc020216a:	fc4e                	sd	s3,56(sp)
ffffffffc020216c:	f852                	sd	s4,48(sp)
ffffffffc020216e:	f456                	sd	s5,40(sp)
ffffffffc0202170:	f05a                	sd	s6,32(sp)
ffffffffc0202172:	ec5e                	sd	s7,24(sp)
ffffffffc0202174:	e862                	sd	s8,16(sp)
ffffffffc0202176:	e466                	sd	s9,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202178:	03479713          	slli	a4,a5,0x34
ffffffffc020217c:	eb71                	bnez	a4,ffffffffc0202250 <unmap_range+0xf4>
    assert(USER_ACCESS(start, end));
ffffffffc020217e:	002007b7          	lui	a5,0x200
ffffffffc0202182:	842e                	mv	s0,a1
ffffffffc0202184:	0af5e663          	bltu	a1,a5,ffffffffc0202230 <unmap_range+0xd4>
ffffffffc0202188:	8932                	mv	s2,a2
ffffffffc020218a:	0ac5f363          	bgeu	a1,a2,ffffffffc0202230 <unmap_range+0xd4>
ffffffffc020218e:	4785                	li	a5,1
ffffffffc0202190:	07fe                	slli	a5,a5,0x1f
ffffffffc0202192:	08c7ef63          	bltu	a5,a2,ffffffffc0202230 <unmap_range+0xd4>
ffffffffc0202196:	89aa                	mv	s3,a0
            continue;
        }
        if (*ptep != 0) {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0202198:	6a05                	lui	s4,0x1
    if (PPN(pa) >= npage) {
ffffffffc020219a:	000aac97          	auipc	s9,0xaa
ffffffffc020219e:	6c6c8c93          	addi	s9,s9,1734 # ffffffffc02ac860 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02021a2:	000aac17          	auipc	s8,0xaa
ffffffffc02021a6:	72ec0c13          	addi	s8,s8,1838 # ffffffffc02ac8d0 <pages>
ffffffffc02021aa:	fff80bb7          	lui	s7,0xfff80
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02021ae:	00200b37          	lui	s6,0x200
ffffffffc02021b2:	ffe00ab7          	lui	s5,0xffe00
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc02021b6:	4601                	li	a2,0
ffffffffc02021b8:	85a2                	mv	a1,s0
ffffffffc02021ba:	854e                	mv	a0,s3
ffffffffc02021bc:	d77ff0ef          	jal	ra,ffffffffc0201f32 <get_pte>
ffffffffc02021c0:	84aa                	mv	s1,a0
        if (ptep == NULL) {
ffffffffc02021c2:	cd21                	beqz	a0,ffffffffc020221a <unmap_range+0xbe>
        if (*ptep != 0) {
ffffffffc02021c4:	611c                	ld	a5,0(a0)
ffffffffc02021c6:	e38d                	bnez	a5,ffffffffc02021e8 <unmap_range+0x8c>
        start += PGSIZE;
ffffffffc02021c8:	9452                	add	s0,s0,s4
    } while (start != 0 && start < end);
ffffffffc02021ca:	ff2466e3          	bltu	s0,s2,ffffffffc02021b6 <unmap_range+0x5a>
}
ffffffffc02021ce:	60e6                	ld	ra,88(sp)
ffffffffc02021d0:	6446                	ld	s0,80(sp)
ffffffffc02021d2:	64a6                	ld	s1,72(sp)
ffffffffc02021d4:	6906                	ld	s2,64(sp)
ffffffffc02021d6:	79e2                	ld	s3,56(sp)
ffffffffc02021d8:	7a42                	ld	s4,48(sp)
ffffffffc02021da:	7aa2                	ld	s5,40(sp)
ffffffffc02021dc:	7b02                	ld	s6,32(sp)
ffffffffc02021de:	6be2                	ld	s7,24(sp)
ffffffffc02021e0:	6c42                	ld	s8,16(sp)
ffffffffc02021e2:	6ca2                	ld	s9,8(sp)
ffffffffc02021e4:	6125                	addi	sp,sp,96
ffffffffc02021e6:	8082                	ret
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02021e8:	0017f713          	andi	a4,a5,1
ffffffffc02021ec:	df71                	beqz	a4,ffffffffc02021c8 <unmap_range+0x6c>
    if (PPN(pa) >= npage) {
ffffffffc02021ee:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc02021f2:	078a                	slli	a5,a5,0x2
ffffffffc02021f4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02021f6:	06e7fd63          	bgeu	a5,a4,ffffffffc0202270 <unmap_range+0x114>
    return &pages[PPN(pa) - nbase];
ffffffffc02021fa:	000c3503          	ld	a0,0(s8)
ffffffffc02021fe:	97de                	add	a5,a5,s7
ffffffffc0202200:	079a                	slli	a5,a5,0x6
ffffffffc0202202:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202204:	411c                	lw	a5,0(a0)
ffffffffc0202206:	fff7871b          	addiw	a4,a5,-1
ffffffffc020220a:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc020220c:	cf11                	beqz	a4,ffffffffc0202228 <unmap_range+0xcc>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc020220e:	0004b023          	sd	zero,0(s1)
}

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la) {
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202212:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc0202216:	9452                	add	s0,s0,s4
ffffffffc0202218:	bf4d                	j	ffffffffc02021ca <unmap_range+0x6e>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020221a:	945a                	add	s0,s0,s6
ffffffffc020221c:	01547433          	and	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0202220:	d45d                	beqz	s0,ffffffffc02021ce <unmap_range+0x72>
ffffffffc0202222:	f9246ae3          	bltu	s0,s2,ffffffffc02021b6 <unmap_range+0x5a>
ffffffffc0202226:	b765                	j	ffffffffc02021ce <unmap_range+0x72>
            free_page(page);
ffffffffc0202228:	4585                	li	a1,1
ffffffffc020222a:	c83ff0ef          	jal	ra,ffffffffc0201eac <free_pages>
ffffffffc020222e:	b7c5                	j	ffffffffc020220e <unmap_range+0xb2>
    assert(USER_ACCESS(start, end));
ffffffffc0202230:	00006697          	auipc	a3,0x6
ffffffffc0202234:	80068693          	addi	a3,a3,-2048 # ffffffffc0207a30 <default_pmm_manager+0x718>
ffffffffc0202238:	00005617          	auipc	a2,0x5
ffffffffc020223c:	99860613          	addi	a2,a2,-1640 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202240:	11000593          	li	a1,272
ffffffffc0202244:	00005517          	auipc	a0,0x5
ffffffffc0202248:	24450513          	addi	a0,a0,580 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc020224c:	a34fe0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202250:	00005697          	auipc	a3,0x5
ffffffffc0202254:	7b068693          	addi	a3,a3,1968 # ffffffffc0207a00 <default_pmm_manager+0x6e8>
ffffffffc0202258:	00005617          	auipc	a2,0x5
ffffffffc020225c:	97860613          	addi	a2,a2,-1672 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202260:	10f00593          	li	a1,271
ffffffffc0202264:	00005517          	auipc	a0,0x5
ffffffffc0202268:	22450513          	addi	a0,a0,548 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc020226c:	a14fe0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc0202270:	b99ff0ef          	jal	ra,ffffffffc0201e08 <pa2page.part.4>

ffffffffc0202274 <exit_range>:
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc0202274:	7119                	addi	sp,sp,-128
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202276:	00c5e7b3          	or	a5,a1,a2
void exit_range(pde_t *pgdir, uintptr_t start, uintptr_t end) {
ffffffffc020227a:	fc86                	sd	ra,120(sp)
ffffffffc020227c:	f8a2                	sd	s0,112(sp)
ffffffffc020227e:	f4a6                	sd	s1,104(sp)
ffffffffc0202280:	f0ca                	sd	s2,96(sp)
ffffffffc0202282:	ecce                	sd	s3,88(sp)
ffffffffc0202284:	e8d2                	sd	s4,80(sp)
ffffffffc0202286:	e4d6                	sd	s5,72(sp)
ffffffffc0202288:	e0da                	sd	s6,64(sp)
ffffffffc020228a:	fc5e                	sd	s7,56(sp)
ffffffffc020228c:	f862                	sd	s8,48(sp)
ffffffffc020228e:	f466                	sd	s9,40(sp)
ffffffffc0202290:	f06a                	sd	s10,32(sp)
ffffffffc0202292:	ec6e                	sd	s11,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202294:	03479713          	slli	a4,a5,0x34
ffffffffc0202298:	1c071163          	bnez	a4,ffffffffc020245a <exit_range+0x1e6>
    assert(USER_ACCESS(start, end));
ffffffffc020229c:	002007b7          	lui	a5,0x200
ffffffffc02022a0:	20f5e563          	bltu	a1,a5,ffffffffc02024aa <exit_range+0x236>
ffffffffc02022a4:	8b32                	mv	s6,a2
ffffffffc02022a6:	20c5f263          	bgeu	a1,a2,ffffffffc02024aa <exit_range+0x236>
ffffffffc02022aa:	4785                	li	a5,1
ffffffffc02022ac:	07fe                	slli	a5,a5,0x1f
ffffffffc02022ae:	1ec7ee63          	bltu	a5,a2,ffffffffc02024aa <exit_range+0x236>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02022b2:	c00009b7          	lui	s3,0xc0000
ffffffffc02022b6:	400007b7          	lui	a5,0x40000
ffffffffc02022ba:	0135f9b3          	and	s3,a1,s3
ffffffffc02022be:	99be                	add	s3,s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02022c0:	c0000337          	lui	t1,0xc0000
ffffffffc02022c4:	00698933          	add	s2,s3,t1
ffffffffc02022c8:	01e95913          	srli	s2,s2,0x1e
ffffffffc02022cc:	1ff97913          	andi	s2,s2,511
ffffffffc02022d0:	8e2a                	mv	t3,a0
ffffffffc02022d2:	090e                	slli	s2,s2,0x3
ffffffffc02022d4:	9972                	add	s2,s2,t3
ffffffffc02022d6:	00093b83          	ld	s7,0(s2)
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc02022da:	ffe004b7          	lui	s1,0xffe00
    return KADDR(page2pa(page));
ffffffffc02022de:	5dfd                	li	s11,-1
        if (pde1&PTE_V){
ffffffffc02022e0:	001bf793          	andi	a5,s7,1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc02022e4:	8ced                	and	s1,s1,a1
    if (PPN(pa) >= npage) {
ffffffffc02022e6:	000aad17          	auipc	s10,0xaa
ffffffffc02022ea:	57ad0d13          	addi	s10,s10,1402 # ffffffffc02ac860 <npage>
    return KADDR(page2pa(page));
ffffffffc02022ee:	00cddd93          	srli	s11,s11,0xc
ffffffffc02022f2:	000aa717          	auipc	a4,0xaa
ffffffffc02022f6:	5ce70713          	addi	a4,a4,1486 # ffffffffc02ac8c0 <va_pa_offset>
    return &pages[PPN(pa) - nbase];
ffffffffc02022fa:	000aae97          	auipc	t4,0xaa
ffffffffc02022fe:	5d6e8e93          	addi	t4,t4,1494 # ffffffffc02ac8d0 <pages>
        if (pde1&PTE_V){
ffffffffc0202302:	e79d                	bnez	a5,ffffffffc0202330 <exit_range+0xbc>
    } while (d1start != 0 && d1start < end);
ffffffffc0202304:	12098963          	beqz	s3,ffffffffc0202436 <exit_range+0x1c2>
ffffffffc0202308:	400007b7          	lui	a5,0x40000
ffffffffc020230c:	84ce                	mv	s1,s3
ffffffffc020230e:	97ce                	add	a5,a5,s3
ffffffffc0202310:	1369f363          	bgeu	s3,s6,ffffffffc0202436 <exit_range+0x1c2>
ffffffffc0202314:	89be                	mv	s3,a5
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0202316:	00698933          	add	s2,s3,t1
ffffffffc020231a:	01e95913          	srli	s2,s2,0x1e
ffffffffc020231e:	1ff97913          	andi	s2,s2,511
ffffffffc0202322:	090e                	slli	s2,s2,0x3
ffffffffc0202324:	9972                	add	s2,s2,t3
ffffffffc0202326:	00093b83          	ld	s7,0(s2)
        if (pde1&PTE_V){
ffffffffc020232a:	001bf793          	andi	a5,s7,1
ffffffffc020232e:	dbf9                	beqz	a5,ffffffffc0202304 <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0202330:	000d3783          	ld	a5,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202334:	0b8a                	slli	s7,s7,0x2
ffffffffc0202336:	00cbdb93          	srli	s7,s7,0xc
    if (PPN(pa) >= npage) {
ffffffffc020233a:	14fbfc63          	bgeu	s7,a5,ffffffffc0202492 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc020233e:	fff80ab7          	lui	s5,0xfff80
ffffffffc0202342:	9ade                	add	s5,s5,s7
    return page - pages + nbase;
ffffffffc0202344:	000806b7          	lui	a3,0x80
ffffffffc0202348:	96d6                	add	a3,a3,s5
ffffffffc020234a:	006a9593          	slli	a1,s5,0x6
    return KADDR(page2pa(page));
ffffffffc020234e:	01b6f633          	and	a2,a3,s11
    return page - pages + nbase;
ffffffffc0202352:	e42e                	sd	a1,8(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc0202354:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202356:	12f67263          	bgeu	a2,a5,ffffffffc020247a <exit_range+0x206>
ffffffffc020235a:	00073a03          	ld	s4,0(a4)
            free_pd0 = 1;
ffffffffc020235e:	4c85                	li	s9,1
    return &pages[PPN(pa) - nbase];
ffffffffc0202360:	fff808b7          	lui	a7,0xfff80
    return KADDR(page2pa(page));
ffffffffc0202364:	9a36                	add	s4,s4,a3
    return page - pages + nbase;
ffffffffc0202366:	00080837          	lui	a6,0x80
ffffffffc020236a:	6a85                	lui	s5,0x1
                d0start += PTSIZE;
ffffffffc020236c:	00200c37          	lui	s8,0x200
ffffffffc0202370:	a801                	j	ffffffffc0202380 <exit_range+0x10c>
                    free_pd0 = 0;
ffffffffc0202372:	4c81                	li	s9,0
                d0start += PTSIZE;
ffffffffc0202374:	94e2                	add	s1,s1,s8
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc0202376:	c0d9                	beqz	s1,ffffffffc02023fc <exit_range+0x188>
ffffffffc0202378:	0934f263          	bgeu	s1,s3,ffffffffc02023fc <exit_range+0x188>
ffffffffc020237c:	0d64fc63          	bgeu	s1,s6,ffffffffc0202454 <exit_range+0x1e0>
                pde0 = pd0[PDX0(d0start)];
ffffffffc0202380:	0154d413          	srli	s0,s1,0x15
ffffffffc0202384:	1ff47413          	andi	s0,s0,511
ffffffffc0202388:	040e                	slli	s0,s0,0x3
ffffffffc020238a:	9452                	add	s0,s0,s4
ffffffffc020238c:	601c                	ld	a5,0(s0)
                if (pde0&PTE_V) {
ffffffffc020238e:	0017f693          	andi	a3,a5,1
ffffffffc0202392:	d2e5                	beqz	a3,ffffffffc0202372 <exit_range+0xfe>
    if (PPN(pa) >= npage) {
ffffffffc0202394:	000d3583          	ld	a1,0(s10)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202398:	00279513          	slli	a0,a5,0x2
ffffffffc020239c:	8131                	srli	a0,a0,0xc
    if (PPN(pa) >= npage) {
ffffffffc020239e:	0eb57a63          	bgeu	a0,a1,ffffffffc0202492 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc02023a2:	9546                	add	a0,a0,a7
    return page - pages + nbase;
ffffffffc02023a4:	010506b3          	add	a3,a0,a6
    return KADDR(page2pa(page));
ffffffffc02023a8:	01b6f7b3          	and	a5,a3,s11
    return page - pages + nbase;
ffffffffc02023ac:	051a                	slli	a0,a0,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02023ae:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02023b0:	0cb7f563          	bgeu	a5,a1,ffffffffc020247a <exit_range+0x206>
ffffffffc02023b4:	631c                	ld	a5,0(a4)
ffffffffc02023b6:	96be                	add	a3,a3,a5
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02023b8:	015685b3          	add	a1,a3,s5
                        if (pt[i]&PTE_V){
ffffffffc02023bc:	629c                	ld	a5,0(a3)
ffffffffc02023be:	8b85                	andi	a5,a5,1
ffffffffc02023c0:	fbd5                	bnez	a5,ffffffffc0202374 <exit_range+0x100>
ffffffffc02023c2:	06a1                	addi	a3,a3,8
                    for (int i = 0;i <NPTEENTRY;i++)
ffffffffc02023c4:	fed59ce3          	bne	a1,a3,ffffffffc02023bc <exit_range+0x148>
    return &pages[PPN(pa) - nbase];
ffffffffc02023c8:	000eb783          	ld	a5,0(t4)
                        free_page(pde2page(pde0));
ffffffffc02023cc:	4585                	li	a1,1
ffffffffc02023ce:	e072                	sd	t3,0(sp)
ffffffffc02023d0:	953e                	add	a0,a0,a5
ffffffffc02023d2:	adbff0ef          	jal	ra,ffffffffc0201eac <free_pages>
                d0start += PTSIZE;
ffffffffc02023d6:	94e2                	add	s1,s1,s8
                        pd0[PDX0(d0start)] = 0;
ffffffffc02023d8:	00043023          	sd	zero,0(s0)
ffffffffc02023dc:	000aae97          	auipc	t4,0xaa
ffffffffc02023e0:	4f4e8e93          	addi	t4,t4,1268 # ffffffffc02ac8d0 <pages>
ffffffffc02023e4:	6e02                	ld	t3,0(sp)
ffffffffc02023e6:	c0000337          	lui	t1,0xc0000
ffffffffc02023ea:	fff808b7          	lui	a7,0xfff80
ffffffffc02023ee:	00080837          	lui	a6,0x80
ffffffffc02023f2:	000aa717          	auipc	a4,0xaa
ffffffffc02023f6:	4ce70713          	addi	a4,a4,1230 # ffffffffc02ac8c0 <va_pa_offset>
            } while (d0start != 0 && d0start < d1start+PDSIZE && d0start < end);
ffffffffc02023fa:	fcbd                	bnez	s1,ffffffffc0202378 <exit_range+0x104>
            if (free_pd0) {
ffffffffc02023fc:	f00c84e3          	beqz	s9,ffffffffc0202304 <exit_range+0x90>
    if (PPN(pa) >= npage) {
ffffffffc0202400:	000d3783          	ld	a5,0(s10)
ffffffffc0202404:	e072                	sd	t3,0(sp)
ffffffffc0202406:	08fbf663          	bgeu	s7,a5,ffffffffc0202492 <exit_range+0x21e>
    return &pages[PPN(pa) - nbase];
ffffffffc020240a:	000eb503          	ld	a0,0(t4)
                free_page(pde2page(pde1));
ffffffffc020240e:	67a2                	ld	a5,8(sp)
ffffffffc0202410:	4585                	li	a1,1
ffffffffc0202412:	953e                	add	a0,a0,a5
ffffffffc0202414:	a99ff0ef          	jal	ra,ffffffffc0201eac <free_pages>
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202418:	00093023          	sd	zero,0(s2)
ffffffffc020241c:	000aa717          	auipc	a4,0xaa
ffffffffc0202420:	4a470713          	addi	a4,a4,1188 # ffffffffc02ac8c0 <va_pa_offset>
ffffffffc0202424:	c0000337          	lui	t1,0xc0000
ffffffffc0202428:	6e02                	ld	t3,0(sp)
ffffffffc020242a:	000aae97          	auipc	t4,0xaa
ffffffffc020242e:	4a6e8e93          	addi	t4,t4,1190 # ffffffffc02ac8d0 <pages>
    } while (d1start != 0 && d1start < end);
ffffffffc0202432:	ec099be3          	bnez	s3,ffffffffc0202308 <exit_range+0x94>
}
ffffffffc0202436:	70e6                	ld	ra,120(sp)
ffffffffc0202438:	7446                	ld	s0,112(sp)
ffffffffc020243a:	74a6                	ld	s1,104(sp)
ffffffffc020243c:	7906                	ld	s2,96(sp)
ffffffffc020243e:	69e6                	ld	s3,88(sp)
ffffffffc0202440:	6a46                	ld	s4,80(sp)
ffffffffc0202442:	6aa6                	ld	s5,72(sp)
ffffffffc0202444:	6b06                	ld	s6,64(sp)
ffffffffc0202446:	7be2                	ld	s7,56(sp)
ffffffffc0202448:	7c42                	ld	s8,48(sp)
ffffffffc020244a:	7ca2                	ld	s9,40(sp)
ffffffffc020244c:	7d02                	ld	s10,32(sp)
ffffffffc020244e:	6de2                	ld	s11,24(sp)
ffffffffc0202450:	6109                	addi	sp,sp,128
ffffffffc0202452:	8082                	ret
            if (free_pd0) {
ffffffffc0202454:	ea0c8ae3          	beqz	s9,ffffffffc0202308 <exit_range+0x94>
ffffffffc0202458:	b765                	j	ffffffffc0202400 <exit_range+0x18c>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020245a:	00005697          	auipc	a3,0x5
ffffffffc020245e:	5a668693          	addi	a3,a3,1446 # ffffffffc0207a00 <default_pmm_manager+0x6e8>
ffffffffc0202462:	00004617          	auipc	a2,0x4
ffffffffc0202466:	76e60613          	addi	a2,a2,1902 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020246a:	12000593          	li	a1,288
ffffffffc020246e:	00005517          	auipc	a0,0x5
ffffffffc0202472:	01a50513          	addi	a0,a0,26 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202476:	80afe0ef          	jal	ra,ffffffffc0200480 <__panic>
    return KADDR(page2pa(page));
ffffffffc020247a:	00005617          	auipc	a2,0x5
ffffffffc020247e:	eee60613          	addi	a2,a2,-274 # ffffffffc0207368 <default_pmm_manager+0x50>
ffffffffc0202482:	06900593          	li	a1,105
ffffffffc0202486:	00005517          	auipc	a0,0x5
ffffffffc020248a:	f0a50513          	addi	a0,a0,-246 # ffffffffc0207390 <default_pmm_manager+0x78>
ffffffffc020248e:	ff3fd0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202492:	00005617          	auipc	a2,0x5
ffffffffc0202496:	f3660613          	addi	a2,a2,-202 # ffffffffc02073c8 <default_pmm_manager+0xb0>
ffffffffc020249a:	06200593          	li	a1,98
ffffffffc020249e:	00005517          	auipc	a0,0x5
ffffffffc02024a2:	ef250513          	addi	a0,a0,-270 # ffffffffc0207390 <default_pmm_manager+0x78>
ffffffffc02024a6:	fdbfd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02024aa:	00005697          	auipc	a3,0x5
ffffffffc02024ae:	58668693          	addi	a3,a3,1414 # ffffffffc0207a30 <default_pmm_manager+0x718>
ffffffffc02024b2:	00004617          	auipc	a2,0x4
ffffffffc02024b6:	71e60613          	addi	a2,a2,1822 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02024ba:	12100593          	li	a1,289
ffffffffc02024be:	00005517          	auipc	a0,0x5
ffffffffc02024c2:	fca50513          	addi	a0,a0,-54 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc02024c6:	fbbfd0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02024ca <page_remove>:
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02024ca:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02024cc:	4601                	li	a2,0
void page_remove(pde_t *pgdir, uintptr_t la) {
ffffffffc02024ce:	e426                	sd	s1,8(sp)
ffffffffc02024d0:	ec06                	sd	ra,24(sp)
ffffffffc02024d2:	e822                	sd	s0,16(sp)
ffffffffc02024d4:	84ae                	mv	s1,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02024d6:	a5dff0ef          	jal	ra,ffffffffc0201f32 <get_pte>
    if (ptep != NULL) {
ffffffffc02024da:	c511                	beqz	a0,ffffffffc02024e6 <page_remove+0x1c>
    if (*ptep & PTE_V) {  //(1) check if this page table entry is
ffffffffc02024dc:	611c                	ld	a5,0(a0)
ffffffffc02024de:	842a                	mv	s0,a0
ffffffffc02024e0:	0017f713          	andi	a4,a5,1
ffffffffc02024e4:	e711                	bnez	a4,ffffffffc02024f0 <page_remove+0x26>
}
ffffffffc02024e6:	60e2                	ld	ra,24(sp)
ffffffffc02024e8:	6442                	ld	s0,16(sp)
ffffffffc02024ea:	64a2                	ld	s1,8(sp)
ffffffffc02024ec:	6105                	addi	sp,sp,32
ffffffffc02024ee:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02024f0:	000aa717          	auipc	a4,0xaa
ffffffffc02024f4:	37070713          	addi	a4,a4,880 # ffffffffc02ac860 <npage>
ffffffffc02024f8:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02024fa:	078a                	slli	a5,a5,0x2
ffffffffc02024fc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02024fe:	02e7fe63          	bgeu	a5,a4,ffffffffc020253a <page_remove+0x70>
    return &pages[PPN(pa) - nbase];
ffffffffc0202502:	000aa717          	auipc	a4,0xaa
ffffffffc0202506:	3ce70713          	addi	a4,a4,974 # ffffffffc02ac8d0 <pages>
ffffffffc020250a:	6308                	ld	a0,0(a4)
ffffffffc020250c:	fff80737          	lui	a4,0xfff80
ffffffffc0202510:	97ba                	add	a5,a5,a4
ffffffffc0202512:	079a                	slli	a5,a5,0x6
ffffffffc0202514:	953e                	add	a0,a0,a5
    page->ref -= 1;
ffffffffc0202516:	411c                	lw	a5,0(a0)
ffffffffc0202518:	fff7871b          	addiw	a4,a5,-1
ffffffffc020251c:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc020251e:	cb11                	beqz	a4,ffffffffc0202532 <page_remove+0x68>
        *ptep = 0;                  //(5) clear second page table entry
ffffffffc0202520:	00043023          	sd	zero,0(s0)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202524:	12048073          	sfence.vma	s1
}
ffffffffc0202528:	60e2                	ld	ra,24(sp)
ffffffffc020252a:	6442                	ld	s0,16(sp)
ffffffffc020252c:	64a2                	ld	s1,8(sp)
ffffffffc020252e:	6105                	addi	sp,sp,32
ffffffffc0202530:	8082                	ret
            free_page(page);
ffffffffc0202532:	4585                	li	a1,1
ffffffffc0202534:	979ff0ef          	jal	ra,ffffffffc0201eac <free_pages>
ffffffffc0202538:	b7e5                	j	ffffffffc0202520 <page_remove+0x56>
ffffffffc020253a:	8cfff0ef          	jal	ra,ffffffffc0201e08 <pa2page.part.4>

ffffffffc020253e <page_insert>:
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020253e:	7179                	addi	sp,sp,-48
ffffffffc0202540:	e44e                	sd	s3,8(sp)
ffffffffc0202542:	89b2                	mv	s3,a2
ffffffffc0202544:	f022                	sd	s0,32(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202546:	4605                	li	a2,1
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc0202548:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020254a:	85ce                	mv	a1,s3
int page_insert(pde_t *pgdir, struct Page *page, uintptr_t la, uint32_t perm) {
ffffffffc020254c:	ec26                	sd	s1,24(sp)
ffffffffc020254e:	f406                	sd	ra,40(sp)
ffffffffc0202550:	e84a                	sd	s2,16(sp)
ffffffffc0202552:	e052                	sd	s4,0(sp)
ffffffffc0202554:	84b6                	mv	s1,a3
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202556:	9ddff0ef          	jal	ra,ffffffffc0201f32 <get_pte>
    if (ptep == NULL) {
ffffffffc020255a:	cd49                	beqz	a0,ffffffffc02025f4 <page_insert+0xb6>
    page->ref += 1;
ffffffffc020255c:	4014                	lw	a3,0(s0)
    if (*ptep & PTE_V) {
ffffffffc020255e:	611c                	ld	a5,0(a0)
ffffffffc0202560:	892a                	mv	s2,a0
ffffffffc0202562:	0016871b          	addiw	a4,a3,1
ffffffffc0202566:	c018                	sw	a4,0(s0)
ffffffffc0202568:	0017f713          	andi	a4,a5,1
ffffffffc020256c:	ef05                	bnez	a4,ffffffffc02025a4 <page_insert+0x66>
ffffffffc020256e:	000aa797          	auipc	a5,0xaa
ffffffffc0202572:	36278793          	addi	a5,a5,866 # ffffffffc02ac8d0 <pages>
ffffffffc0202576:	6398                	ld	a4,0(a5)
    return page - pages + nbase;
ffffffffc0202578:	8c19                	sub	s0,s0,a4
ffffffffc020257a:	000806b7          	lui	a3,0x80
ffffffffc020257e:	8419                	srai	s0,s0,0x6
ffffffffc0202580:	9436                	add	s0,s0,a3
  return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202582:	042a                	slli	s0,s0,0xa
ffffffffc0202584:	8c45                	or	s0,s0,s1
ffffffffc0202586:	00146413          	ori	s0,s0,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc020258a:	00893023          	sd	s0,0(s2)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020258e:	12098073          	sfence.vma	s3
    return 0;
ffffffffc0202592:	4501                	li	a0,0
}
ffffffffc0202594:	70a2                	ld	ra,40(sp)
ffffffffc0202596:	7402                	ld	s0,32(sp)
ffffffffc0202598:	64e2                	ld	s1,24(sp)
ffffffffc020259a:	6942                	ld	s2,16(sp)
ffffffffc020259c:	69a2                	ld	s3,8(sp)
ffffffffc020259e:	6a02                	ld	s4,0(sp)
ffffffffc02025a0:	6145                	addi	sp,sp,48
ffffffffc02025a2:	8082                	ret
    if (PPN(pa) >= npage) {
ffffffffc02025a4:	000aa717          	auipc	a4,0xaa
ffffffffc02025a8:	2bc70713          	addi	a4,a4,700 # ffffffffc02ac860 <npage>
ffffffffc02025ac:	6318                	ld	a4,0(a4)
    return pa2page(PTE_ADDR(pte));
ffffffffc02025ae:	078a                	slli	a5,a5,0x2
ffffffffc02025b0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02025b2:	04e7f363          	bgeu	a5,a4,ffffffffc02025f8 <page_insert+0xba>
    return &pages[PPN(pa) - nbase];
ffffffffc02025b6:	000aaa17          	auipc	s4,0xaa
ffffffffc02025ba:	31aa0a13          	addi	s4,s4,794 # ffffffffc02ac8d0 <pages>
ffffffffc02025be:	000a3703          	ld	a4,0(s4)
ffffffffc02025c2:	fff80537          	lui	a0,0xfff80
ffffffffc02025c6:	953e                	add	a0,a0,a5
ffffffffc02025c8:	051a                	slli	a0,a0,0x6
ffffffffc02025ca:	953a                	add	a0,a0,a4
        if (p == page) {
ffffffffc02025cc:	00a40a63          	beq	s0,a0,ffffffffc02025e0 <page_insert+0xa2>
    page->ref -= 1;
ffffffffc02025d0:	411c                	lw	a5,0(a0)
ffffffffc02025d2:	fff7869b          	addiw	a3,a5,-1
ffffffffc02025d6:	c114                	sw	a3,0(a0)
        if (page_ref(page) ==
ffffffffc02025d8:	c691                	beqz	a3,ffffffffc02025e4 <page_insert+0xa6>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02025da:	12098073          	sfence.vma	s3
ffffffffc02025de:	bf69                	j	ffffffffc0202578 <page_insert+0x3a>
ffffffffc02025e0:	c014                	sw	a3,0(s0)
    return page->ref;
ffffffffc02025e2:	bf59                	j	ffffffffc0202578 <page_insert+0x3a>
            free_page(page);
ffffffffc02025e4:	4585                	li	a1,1
ffffffffc02025e6:	8c7ff0ef          	jal	ra,ffffffffc0201eac <free_pages>
ffffffffc02025ea:	000a3703          	ld	a4,0(s4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02025ee:	12098073          	sfence.vma	s3
ffffffffc02025f2:	b759                	j	ffffffffc0202578 <page_insert+0x3a>
        return -E_NO_MEM;
ffffffffc02025f4:	5571                	li	a0,-4
ffffffffc02025f6:	bf79                	j	ffffffffc0202594 <page_insert+0x56>
ffffffffc02025f8:	811ff0ef          	jal	ra,ffffffffc0201e08 <pa2page.part.4>

ffffffffc02025fc <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc02025fc:	00005797          	auipc	a5,0x5
ffffffffc0202600:	d1c78793          	addi	a5,a5,-740 # ffffffffc0207318 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202604:	638c                	ld	a1,0(a5)
void pmm_init(void) {
ffffffffc0202606:	715d                	addi	sp,sp,-80
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202608:	00005517          	auipc	a0,0x5
ffffffffc020260c:	ea850513          	addi	a0,a0,-344 # ffffffffc02074b0 <default_pmm_manager+0x198>
void pmm_init(void) {
ffffffffc0202610:	e486                	sd	ra,72(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202612:	000aa717          	auipc	a4,0xaa
ffffffffc0202616:	2af73323          	sd	a5,678(a4) # ffffffffc02ac8b8 <pmm_manager>
void pmm_init(void) {
ffffffffc020261a:	e0a2                	sd	s0,64(sp)
ffffffffc020261c:	fc26                	sd	s1,56(sp)
ffffffffc020261e:	f84a                	sd	s2,48(sp)
ffffffffc0202620:	f44e                	sd	s3,40(sp)
ffffffffc0202622:	f052                	sd	s4,32(sp)
ffffffffc0202624:	ec56                	sd	s5,24(sp)
ffffffffc0202626:	e85a                	sd	s6,16(sp)
ffffffffc0202628:	e45e                	sd	s7,8(sp)
ffffffffc020262a:	e062                	sd	s8,0(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020262c:	000aa417          	auipc	s0,0xaa
ffffffffc0202630:	28c40413          	addi	s0,s0,652 # ffffffffc02ac8b8 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202634:	b5bfd0ef          	jal	ra,ffffffffc020018e <cprintf>
    pmm_manager->init();
ffffffffc0202638:	601c                	ld	a5,0(s0)
ffffffffc020263a:	000aa497          	auipc	s1,0xaa
ffffffffc020263e:	22648493          	addi	s1,s1,550 # ffffffffc02ac860 <npage>
ffffffffc0202642:	000aa917          	auipc	s2,0xaa
ffffffffc0202646:	28e90913          	addi	s2,s2,654 # ffffffffc02ac8d0 <pages>
ffffffffc020264a:	679c                	ld	a5,8(a5)
ffffffffc020264c:	9782                	jalr	a5
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020264e:	57f5                	li	a5,-3
ffffffffc0202650:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0202652:	00005517          	auipc	a0,0x5
ffffffffc0202656:	e7650513          	addi	a0,a0,-394 # ffffffffc02074c8 <default_pmm_manager+0x1b0>
    va_pa_offset = KERNBASE - 0x80200000;
ffffffffc020265a:	000aa717          	auipc	a4,0xaa
ffffffffc020265e:	26f73323          	sd	a5,614(a4) # ffffffffc02ac8c0 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0202662:	b2dfd0ef          	jal	ra,ffffffffc020018e <cprintf>
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202666:	46c5                	li	a3,17
ffffffffc0202668:	06ee                	slli	a3,a3,0x1b
ffffffffc020266a:	40100613          	li	a2,1025
ffffffffc020266e:	16fd                	addi	a3,a3,-1
ffffffffc0202670:	0656                	slli	a2,a2,0x15
ffffffffc0202672:	07e005b7          	lui	a1,0x7e00
ffffffffc0202676:	00005517          	auipc	a0,0x5
ffffffffc020267a:	e6a50513          	addi	a0,a0,-406 # ffffffffc02074e0 <default_pmm_manager+0x1c8>
ffffffffc020267e:	b11fd0ef          	jal	ra,ffffffffc020018e <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202682:	777d                	lui	a4,0xfffff
ffffffffc0202684:	000ab797          	auipc	a5,0xab
ffffffffc0202688:	34378793          	addi	a5,a5,835 # ffffffffc02ad9c7 <end+0xfff>
ffffffffc020268c:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc020268e:	00088737          	lui	a4,0x88
ffffffffc0202692:	000aa697          	auipc	a3,0xaa
ffffffffc0202696:	1ce6b723          	sd	a4,462(a3) # ffffffffc02ac860 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020269a:	000aa717          	auipc	a4,0xaa
ffffffffc020269e:	22f73b23          	sd	a5,566(a4) # ffffffffc02ac8d0 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02026a2:	4701                	li	a4,0
ffffffffc02026a4:	4685                	li	a3,1
ffffffffc02026a6:	fff80837          	lui	a6,0xfff80
ffffffffc02026aa:	a019                	j	ffffffffc02026b0 <pmm_init+0xb4>
ffffffffc02026ac:	00093783          	ld	a5,0(s2)
        SetPageReserved(pages + i);
ffffffffc02026b0:	00671613          	slli	a2,a4,0x6
ffffffffc02026b4:	97b2                	add	a5,a5,a2
ffffffffc02026b6:	07a1                	addi	a5,a5,8
ffffffffc02026b8:	40d7b02f          	amoor.d	zero,a3,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02026bc:	6090                	ld	a2,0(s1)
ffffffffc02026be:	0705                	addi	a4,a4,1
ffffffffc02026c0:	010607b3          	add	a5,a2,a6
ffffffffc02026c4:	fef764e3          	bltu	a4,a5,ffffffffc02026ac <pmm_init+0xb0>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02026c8:	00093503          	ld	a0,0(s2)
ffffffffc02026cc:	fe0007b7          	lui	a5,0xfe000
ffffffffc02026d0:	00661693          	slli	a3,a2,0x6
ffffffffc02026d4:	97aa                	add	a5,a5,a0
ffffffffc02026d6:	96be                	add	a3,a3,a5
ffffffffc02026d8:	c02007b7          	lui	a5,0xc0200
ffffffffc02026dc:	7af6eb63          	bltu	a3,a5,ffffffffc0202e92 <pmm_init+0x896>
ffffffffc02026e0:	000aa997          	auipc	s3,0xaa
ffffffffc02026e4:	1e098993          	addi	s3,s3,480 # ffffffffc02ac8c0 <va_pa_offset>
ffffffffc02026e8:	0009b583          	ld	a1,0(s3)
    if (freemem < mem_end) {
ffffffffc02026ec:	47c5                	li	a5,17
ffffffffc02026ee:	07ee                	slli	a5,a5,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02026f0:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end) {
ffffffffc02026f2:	02f6f763          	bgeu	a3,a5,ffffffffc0202720 <pmm_init+0x124>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02026f6:	6585                	lui	a1,0x1
ffffffffc02026f8:	15fd                	addi	a1,a1,-1
ffffffffc02026fa:	96ae                	add	a3,a3,a1
    if (PPN(pa) >= npage) {
ffffffffc02026fc:	00c6d713          	srli	a4,a3,0xc
ffffffffc0202700:	48c77863          	bgeu	a4,a2,ffffffffc0202b90 <pmm_init+0x594>
    pmm_manager->init_memmap(base, n);
ffffffffc0202704:	6010                	ld	a2,0(s0)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202706:	75fd                	lui	a1,0xfffff
ffffffffc0202708:	8eed                	and	a3,a3,a1
    return &pages[PPN(pa) - nbase];
ffffffffc020270a:	9742                	add	a4,a4,a6
    pmm_manager->init_memmap(base, n);
ffffffffc020270c:	6a10                	ld	a2,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc020270e:	40d786b3          	sub	a3,a5,a3
ffffffffc0202712:	071a                	slli	a4,a4,0x6
    pmm_manager->init_memmap(base, n);
ffffffffc0202714:	00c6d593          	srli	a1,a3,0xc
ffffffffc0202718:	953a                	add	a0,a0,a4
ffffffffc020271a:	9602                	jalr	a2
ffffffffc020271c:	0009b583          	ld	a1,0(s3)
    cprintf("vapaofset is %llu\n",va_pa_offset);
ffffffffc0202720:	00005517          	auipc	a0,0x5
ffffffffc0202724:	de850513          	addi	a0,a0,-536 # ffffffffc0207508 <default_pmm_manager+0x1f0>
ffffffffc0202728:	a67fd0ef          	jal	ra,ffffffffc020018e <cprintf>

    return page;
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc020272c:	601c                	ld	a5,0(s0)
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc020272e:	000aa417          	auipc	s0,0xaa
ffffffffc0202732:	12a40413          	addi	s0,s0,298 # ffffffffc02ac858 <boot_pgdir>
    pmm_manager->check();
ffffffffc0202736:	7b9c                	ld	a5,48(a5)
ffffffffc0202738:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020273a:	00005517          	auipc	a0,0x5
ffffffffc020273e:	de650513          	addi	a0,a0,-538 # ffffffffc0207520 <default_pmm_manager+0x208>
ffffffffc0202742:	a4dfd0ef          	jal	ra,ffffffffc020018e <cprintf>
    boot_pgdir = (pte_t*)boot_page_table_sv39;
ffffffffc0202746:	00009697          	auipc	a3,0x9
ffffffffc020274a:	8ba68693          	addi	a3,a3,-1862 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc020274e:	000aa797          	auipc	a5,0xaa
ffffffffc0202752:	10d7b523          	sd	a3,266(a5) # ffffffffc02ac858 <boot_pgdir>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc0202756:	c02007b7          	lui	a5,0xc0200
ffffffffc020275a:	10f6e8e3          	bltu	a3,a5,ffffffffc020306a <pmm_init+0xa6e>
ffffffffc020275e:	0009b783          	ld	a5,0(s3)
ffffffffc0202762:	8e9d                	sub	a3,a3,a5
ffffffffc0202764:	000aa797          	auipc	a5,0xaa
ffffffffc0202768:	16d7b223          	sd	a3,356(a5) # ffffffffc02ac8c8 <boot_cr3>
    // assert(npage <= KMEMSIZE / PGSIZE);
    // The memory starts at 2GB in RISC-V
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store=nr_free_pages();
ffffffffc020276c:	f86ff0ef          	jal	ra,ffffffffc0201ef2 <nr_free_pages>

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202770:	6098                	ld	a4,0(s1)
ffffffffc0202772:	c80007b7          	lui	a5,0xc8000
ffffffffc0202776:	83b1                	srli	a5,a5,0xc
    nr_free_store=nr_free_pages();
ffffffffc0202778:	8a2a                	mv	s4,a0
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020277a:	0ce7e8e3          	bltu	a5,a4,ffffffffc020304a <pmm_init+0xa4e>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc020277e:	6008                	ld	a0,0(s0)
ffffffffc0202780:	44050263          	beqz	a0,ffffffffc0202bc4 <pmm_init+0x5c8>
ffffffffc0202784:	03451793          	slli	a5,a0,0x34
ffffffffc0202788:	42079e63          	bnez	a5,ffffffffc0202bc4 <pmm_init+0x5c8>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc020278c:	4601                	li	a2,0
ffffffffc020278e:	4581                	li	a1,0
ffffffffc0202790:	975ff0ef          	jal	ra,ffffffffc0202104 <get_page>
ffffffffc0202794:	78051b63          	bnez	a0,ffffffffc0202f2a <pmm_init+0x92e>

    struct Page *p1, *p2;
    p1 = alloc_page();
ffffffffc0202798:	4505                	li	a0,1
ffffffffc020279a:	e8aff0ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc020279e:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc02027a0:	6008                	ld	a0,0(s0)
ffffffffc02027a2:	4681                	li	a3,0
ffffffffc02027a4:	4601                	li	a2,0
ffffffffc02027a6:	85d6                	mv	a1,s5
ffffffffc02027a8:	d97ff0ef          	jal	ra,ffffffffc020253e <page_insert>
ffffffffc02027ac:	7a051f63          	bnez	a0,ffffffffc0202f6a <pmm_init+0x96e>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc02027b0:	6008                	ld	a0,0(s0)
ffffffffc02027b2:	4601                	li	a2,0
ffffffffc02027b4:	4581                	li	a1,0
ffffffffc02027b6:	f7cff0ef          	jal	ra,ffffffffc0201f32 <get_pte>
ffffffffc02027ba:	78050863          	beqz	a0,ffffffffc0202f4a <pmm_init+0x94e>
    assert(pte2page(*ptep) == p1);
ffffffffc02027be:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02027c0:	0017f713          	andi	a4,a5,1
ffffffffc02027c4:	3e070463          	beqz	a4,ffffffffc0202bac <pmm_init+0x5b0>
    if (PPN(pa) >= npage) {
ffffffffc02027c8:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02027ca:	078a                	slli	a5,a5,0x2
ffffffffc02027cc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02027ce:	3ce7f163          	bgeu	a5,a4,ffffffffc0202b90 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc02027d2:	00093683          	ld	a3,0(s2)
ffffffffc02027d6:	fff80637          	lui	a2,0xfff80
ffffffffc02027da:	97b2                	add	a5,a5,a2
ffffffffc02027dc:	079a                	slli	a5,a5,0x6
ffffffffc02027de:	97b6                	add	a5,a5,a3
ffffffffc02027e0:	72fa9563          	bne	s5,a5,ffffffffc0202f0a <pmm_init+0x90e>
    assert(page_ref(p1) == 1);
ffffffffc02027e4:	000aab83          	lw	s7,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>
ffffffffc02027e8:	4785                	li	a5,1
ffffffffc02027ea:	70fb9063          	bne	s7,a5,ffffffffc0202eea <pmm_init+0x8ee>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc02027ee:	6008                	ld	a0,0(s0)
ffffffffc02027f0:	76fd                	lui	a3,0xfffff
ffffffffc02027f2:	611c                	ld	a5,0(a0)
ffffffffc02027f4:	078a                	slli	a5,a5,0x2
ffffffffc02027f6:	8ff5                	and	a5,a5,a3
ffffffffc02027f8:	00c7d613          	srli	a2,a5,0xc
ffffffffc02027fc:	66e67e63          	bgeu	a2,a4,ffffffffc0202e78 <pmm_init+0x87c>
ffffffffc0202800:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202804:	97e2                	add	a5,a5,s8
ffffffffc0202806:	0007bb03          	ld	s6,0(a5) # ffffffffc8000000 <end+0x7d53638>
ffffffffc020280a:	0b0a                	slli	s6,s6,0x2
ffffffffc020280c:	00db7b33          	and	s6,s6,a3
ffffffffc0202810:	00cb5793          	srli	a5,s6,0xc
ffffffffc0202814:	56e7f863          	bgeu	a5,a4,ffffffffc0202d84 <pmm_init+0x788>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202818:	4601                	li	a2,0
ffffffffc020281a:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020281c:	9b62                	add	s6,s6,s8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc020281e:	f14ff0ef          	jal	ra,ffffffffc0201f32 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202822:	0b21                	addi	s6,s6,8
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202824:	55651063          	bne	a0,s6,ffffffffc0202d64 <pmm_init+0x768>

    p2 = alloc_page();
ffffffffc0202828:	4505                	li	a0,1
ffffffffc020282a:	dfaff0ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc020282e:	8b2a                	mv	s6,a0
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202830:	6008                	ld	a0,0(s0)
ffffffffc0202832:	46d1                	li	a3,20
ffffffffc0202834:	6605                	lui	a2,0x1
ffffffffc0202836:	85da                	mv	a1,s6
ffffffffc0202838:	d07ff0ef          	jal	ra,ffffffffc020253e <page_insert>
ffffffffc020283c:	50051463          	bnez	a0,ffffffffc0202d44 <pmm_init+0x748>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202840:	6008                	ld	a0,0(s0)
ffffffffc0202842:	4601                	li	a2,0
ffffffffc0202844:	6585                	lui	a1,0x1
ffffffffc0202846:	eecff0ef          	jal	ra,ffffffffc0201f32 <get_pte>
ffffffffc020284a:	4c050d63          	beqz	a0,ffffffffc0202d24 <pmm_init+0x728>
    assert(*ptep & PTE_U);
ffffffffc020284e:	611c                	ld	a5,0(a0)
ffffffffc0202850:	0107f713          	andi	a4,a5,16
ffffffffc0202854:	4a070863          	beqz	a4,ffffffffc0202d04 <pmm_init+0x708>
    assert(*ptep & PTE_W);
ffffffffc0202858:	8b91                	andi	a5,a5,4
ffffffffc020285a:	48078563          	beqz	a5,ffffffffc0202ce4 <pmm_init+0x6e8>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc020285e:	6008                	ld	a0,0(s0)
ffffffffc0202860:	611c                	ld	a5,0(a0)
ffffffffc0202862:	8bc1                	andi	a5,a5,16
ffffffffc0202864:	46078063          	beqz	a5,ffffffffc0202cc4 <pmm_init+0x6c8>
    assert(page_ref(p2) == 1);
ffffffffc0202868:	000b2783          	lw	a5,0(s6) # 200000 <_binary_obj___user_exit_out_size+0x1f5530>
ffffffffc020286c:	43779c63          	bne	a5,s7,ffffffffc0202ca4 <pmm_init+0x6a8>

    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202870:	4681                	li	a3,0
ffffffffc0202872:	6605                	lui	a2,0x1
ffffffffc0202874:	85d6                	mv	a1,s5
ffffffffc0202876:	cc9ff0ef          	jal	ra,ffffffffc020253e <page_insert>
ffffffffc020287a:	40051563          	bnez	a0,ffffffffc0202c84 <pmm_init+0x688>
    assert(page_ref(p1) == 2);
ffffffffc020287e:	000aa703          	lw	a4,0(s5)
ffffffffc0202882:	4789                	li	a5,2
ffffffffc0202884:	3ef71063          	bne	a4,a5,ffffffffc0202c64 <pmm_init+0x668>
    assert(page_ref(p2) == 0);
ffffffffc0202888:	000b2783          	lw	a5,0(s6)
ffffffffc020288c:	3a079c63          	bnez	a5,ffffffffc0202c44 <pmm_init+0x648>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202890:	6008                	ld	a0,0(s0)
ffffffffc0202892:	4601                	li	a2,0
ffffffffc0202894:	6585                	lui	a1,0x1
ffffffffc0202896:	e9cff0ef          	jal	ra,ffffffffc0201f32 <get_pte>
ffffffffc020289a:	38050563          	beqz	a0,ffffffffc0202c24 <pmm_init+0x628>
    assert(pte2page(*ptep) == p1);
ffffffffc020289e:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc02028a0:	00177793          	andi	a5,a4,1
ffffffffc02028a4:	30078463          	beqz	a5,ffffffffc0202bac <pmm_init+0x5b0>
    if (PPN(pa) >= npage) {
ffffffffc02028a8:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02028aa:	00271793          	slli	a5,a4,0x2
ffffffffc02028ae:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02028b0:	2ed7f063          	bgeu	a5,a3,ffffffffc0202b90 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc02028b4:	00093683          	ld	a3,0(s2)
ffffffffc02028b8:	fff80637          	lui	a2,0xfff80
ffffffffc02028bc:	97b2                	add	a5,a5,a2
ffffffffc02028be:	079a                	slli	a5,a5,0x6
ffffffffc02028c0:	97b6                	add	a5,a5,a3
ffffffffc02028c2:	32fa9163          	bne	s5,a5,ffffffffc0202be4 <pmm_init+0x5e8>
    assert((*ptep & PTE_U) == 0);
ffffffffc02028c6:	8b41                	andi	a4,a4,16
ffffffffc02028c8:	70071163          	bnez	a4,ffffffffc0202fca <pmm_init+0x9ce>

    page_remove(boot_pgdir, 0x0);
ffffffffc02028cc:	6008                	ld	a0,0(s0)
ffffffffc02028ce:	4581                	li	a1,0
ffffffffc02028d0:	bfbff0ef          	jal	ra,ffffffffc02024ca <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc02028d4:	000aa703          	lw	a4,0(s5)
ffffffffc02028d8:	4785                	li	a5,1
ffffffffc02028da:	6cf71863          	bne	a4,a5,ffffffffc0202faa <pmm_init+0x9ae>
    assert(page_ref(p2) == 0);
ffffffffc02028de:	000b2783          	lw	a5,0(s6)
ffffffffc02028e2:	6a079463          	bnez	a5,ffffffffc0202f8a <pmm_init+0x98e>

    page_remove(boot_pgdir, PGSIZE);
ffffffffc02028e6:	6008                	ld	a0,0(s0)
ffffffffc02028e8:	6585                	lui	a1,0x1
ffffffffc02028ea:	be1ff0ef          	jal	ra,ffffffffc02024ca <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc02028ee:	000aa783          	lw	a5,0(s5)
ffffffffc02028f2:	50079363          	bnez	a5,ffffffffc0202df8 <pmm_init+0x7fc>
    assert(page_ref(p2) == 0);
ffffffffc02028f6:	000b2783          	lw	a5,0(s6)
ffffffffc02028fa:	4c079f63          	bnez	a5,ffffffffc0202dd8 <pmm_init+0x7dc>

    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc02028fe:	00043b03          	ld	s6,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202902:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202904:	000b3783          	ld	a5,0(s6)
ffffffffc0202908:	078a                	slli	a5,a5,0x2
ffffffffc020290a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc020290c:	28e7f263          	bgeu	a5,a4,ffffffffc0202b90 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0202910:	fff806b7          	lui	a3,0xfff80
ffffffffc0202914:	00093503          	ld	a0,0(s2)
ffffffffc0202918:	97b6                	add	a5,a5,a3
ffffffffc020291a:	079a                	slli	a5,a5,0x6
ffffffffc020291c:	00f506b3          	add	a3,a0,a5
ffffffffc0202920:	4290                	lw	a2,0(a3)
ffffffffc0202922:	4685                	li	a3,1
ffffffffc0202924:	48d61a63          	bne	a2,a3,ffffffffc0202db8 <pmm_init+0x7bc>
    return page - pages + nbase;
ffffffffc0202928:	8799                	srai	a5,a5,0x6
ffffffffc020292a:	00080ab7          	lui	s5,0x80
ffffffffc020292e:	97d6                	add	a5,a5,s5
    return KADDR(page2pa(page));
ffffffffc0202930:	00c79693          	slli	a3,a5,0xc
ffffffffc0202934:	82b1                	srli	a3,a3,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202936:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202938:	46e6f363          	bgeu	a3,a4,ffffffffc0202d9e <pmm_init+0x7a2>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
    free_page(pde2page(pd0[0]));
ffffffffc020293c:	0009b683          	ld	a3,0(s3)
ffffffffc0202940:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0202942:	639c                	ld	a5,0(a5)
ffffffffc0202944:	078a                	slli	a5,a5,0x2
ffffffffc0202946:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202948:	24e7f463          	bgeu	a5,a4,ffffffffc0202b90 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc020294c:	415787b3          	sub	a5,a5,s5
ffffffffc0202950:	079a                	slli	a5,a5,0x6
ffffffffc0202952:	953e                	add	a0,a0,a5
ffffffffc0202954:	4585                	li	a1,1
ffffffffc0202956:	d56ff0ef          	jal	ra,ffffffffc0201eac <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc020295a:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc020295e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202960:	078a                	slli	a5,a5,0x2
ffffffffc0202962:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202964:	22e7f663          	bgeu	a5,a4,ffffffffc0202b90 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0202968:	00093503          	ld	a0,0(s2)
ffffffffc020296c:	415787b3          	sub	a5,a5,s5
ffffffffc0202970:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202972:	953e                	add	a0,a0,a5
ffffffffc0202974:	4585                	li	a1,1
ffffffffc0202976:	d36ff0ef          	jal	ra,ffffffffc0201eac <free_pages>
    boot_pgdir[0] = 0;
ffffffffc020297a:	601c                	ld	a5,0(s0)
ffffffffc020297c:	0007b023          	sd	zero,0(a5)
  asm volatile("sfence.vma");
ffffffffc0202980:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202984:	d6eff0ef          	jal	ra,ffffffffc0201ef2 <nr_free_pages>
ffffffffc0202988:	68aa1163          	bne	s4,a0,ffffffffc020300a <pmm_init+0xa0e>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc020298c:	00005517          	auipc	a0,0x5
ffffffffc0202990:	ea450513          	addi	a0,a0,-348 # ffffffffc0207830 <default_pmm_manager+0x518>
ffffffffc0202994:	ffafd0ef          	jal	ra,ffffffffc020018e <cprintf>
static void check_boot_pgdir(void) {
    size_t nr_free_store;
    pte_t *ptep;
    int i;

    nr_free_store=nr_free_pages();
ffffffffc0202998:	d5aff0ef          	jal	ra,ffffffffc0201ef2 <nr_free_pages>

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc020299c:	6098                	ld	a4,0(s1)
ffffffffc020299e:	c02007b7          	lui	a5,0xc0200
    nr_free_store=nr_free_pages();
ffffffffc02029a2:	8a2a                	mv	s4,a0
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029a4:	00c71693          	slli	a3,a4,0xc
ffffffffc02029a8:	18d7f563          	bgeu	a5,a3,ffffffffc0202b32 <pmm_init+0x536>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029ac:	83b1                	srli	a5,a5,0xc
ffffffffc02029ae:	6008                	ld	a0,0(s0)
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029b0:	c0200ab7          	lui	s5,0xc0200
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029b4:	1ae7f163          	bgeu	a5,a4,ffffffffc0202b56 <pmm_init+0x55a>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02029b8:	7bfd                	lui	s7,0xfffff
ffffffffc02029ba:	6b05                	lui	s6,0x1
ffffffffc02029bc:	a029                	j	ffffffffc02029c6 <pmm_init+0x3ca>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc02029be:	00cad713          	srli	a4,s5,0xc
ffffffffc02029c2:	18f77a63          	bgeu	a4,a5,ffffffffc0202b56 <pmm_init+0x55a>
ffffffffc02029c6:	0009b583          	ld	a1,0(s3)
ffffffffc02029ca:	4601                	li	a2,0
ffffffffc02029cc:	95d6                	add	a1,a1,s5
ffffffffc02029ce:	d64ff0ef          	jal	ra,ffffffffc0201f32 <get_pte>
ffffffffc02029d2:	16050263          	beqz	a0,ffffffffc0202b36 <pmm_init+0x53a>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc02029d6:	611c                	ld	a5,0(a0)
ffffffffc02029d8:	078a                	slli	a5,a5,0x2
ffffffffc02029da:	0177f7b3          	and	a5,a5,s7
ffffffffc02029de:	19579963          	bne	a5,s5,ffffffffc0202b70 <pmm_init+0x574>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE) {
ffffffffc02029e2:	609c                	ld	a5,0(s1)
ffffffffc02029e4:	9ada                	add	s5,s5,s6
ffffffffc02029e6:	6008                	ld	a0,0(s0)
ffffffffc02029e8:	00c79713          	slli	a4,a5,0xc
ffffffffc02029ec:	fceae9e3          	bltu	s5,a4,ffffffffc02029be <pmm_init+0x3c2>
    }


    assert(boot_pgdir[0] == 0);
ffffffffc02029f0:	611c                	ld	a5,0(a0)
ffffffffc02029f2:	62079c63          	bnez	a5,ffffffffc020302a <pmm_init+0xa2e>

    struct Page *p;
    p = alloc_page();
ffffffffc02029f6:	4505                	li	a0,1
ffffffffc02029f8:	c2cff0ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc02029fc:	8aaa                	mv	s5,a0
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02029fe:	6008                	ld	a0,0(s0)
ffffffffc0202a00:	4699                	li	a3,6
ffffffffc0202a02:	10000613          	li	a2,256
ffffffffc0202a06:	85d6                	mv	a1,s5
ffffffffc0202a08:	b37ff0ef          	jal	ra,ffffffffc020253e <page_insert>
ffffffffc0202a0c:	1e051c63          	bnez	a0,ffffffffc0202c04 <pmm_init+0x608>
    assert(page_ref(p) == 1);
ffffffffc0202a10:	000aa703          	lw	a4,0(s5) # ffffffffc0200000 <kern_entry>
ffffffffc0202a14:	4785                	li	a5,1
ffffffffc0202a16:	44f71163          	bne	a4,a5,ffffffffc0202e58 <pmm_init+0x85c>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202a1a:	6008                	ld	a0,0(s0)
ffffffffc0202a1c:	6b05                	lui	s6,0x1
ffffffffc0202a1e:	4699                	li	a3,6
ffffffffc0202a20:	100b0613          	addi	a2,s6,256 # 1100 <_binary_obj___user_faultread_out_size-0x84c8>
ffffffffc0202a24:	85d6                	mv	a1,s5
ffffffffc0202a26:	b19ff0ef          	jal	ra,ffffffffc020253e <page_insert>
ffffffffc0202a2a:	40051763          	bnez	a0,ffffffffc0202e38 <pmm_init+0x83c>
    assert(page_ref(p) == 2);
ffffffffc0202a2e:	000aa703          	lw	a4,0(s5)
ffffffffc0202a32:	4789                	li	a5,2
ffffffffc0202a34:	3ef71263          	bne	a4,a5,ffffffffc0202e18 <pmm_init+0x81c>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202a38:	00005597          	auipc	a1,0x5
ffffffffc0202a3c:	f3058593          	addi	a1,a1,-208 # ffffffffc0207968 <default_pmm_manager+0x650>
ffffffffc0202a40:	10000513          	li	a0,256
ffffffffc0202a44:	313030ef          	jal	ra,ffffffffc0206556 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202a48:	100b0593          	addi	a1,s6,256
ffffffffc0202a4c:	10000513          	li	a0,256
ffffffffc0202a50:	319030ef          	jal	ra,ffffffffc0206568 <strcmp>
ffffffffc0202a54:	44051b63          	bnez	a0,ffffffffc0202eaa <pmm_init+0x8ae>
    return page - pages + nbase;
ffffffffc0202a58:	00093683          	ld	a3,0(s2)
ffffffffc0202a5c:	00080737          	lui	a4,0x80
    return KADDR(page2pa(page));
ffffffffc0202a60:	5b7d                	li	s6,-1
    return page - pages + nbase;
ffffffffc0202a62:	40da86b3          	sub	a3,s5,a3
ffffffffc0202a66:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0202a68:	609c                	ld	a5,0(s1)
    return page - pages + nbase;
ffffffffc0202a6a:	96ba                	add	a3,a3,a4
    return KADDR(page2pa(page));
ffffffffc0202a6c:	00cb5b13          	srli	s6,s6,0xc
ffffffffc0202a70:	0166f733          	and	a4,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202a74:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202a76:	10f77f63          	bgeu	a4,a5,ffffffffc0202b94 <pmm_init+0x598>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202a7a:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202a7e:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202a82:	96be                	add	a3,a3,a5
ffffffffc0202a84:	10068023          	sb	zero,256(a3) # fffffffffff80100 <end+0x3fcd3738>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202a88:	28b030ef          	jal	ra,ffffffffc0206512 <strlen>
ffffffffc0202a8c:	54051f63          	bnez	a0,ffffffffc0202fea <pmm_init+0x9ee>

    pde_t *pd1=boot_pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc0202a90:	00043b83          	ld	s7,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc0202a94:	609c                	ld	a5,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202a96:	000bb683          	ld	a3,0(s7) # fffffffffffff000 <end+0x3fd52638>
ffffffffc0202a9a:	068a                	slli	a3,a3,0x2
ffffffffc0202a9c:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202a9e:	0ef6f963          	bgeu	a3,a5,ffffffffc0202b90 <pmm_init+0x594>
    return KADDR(page2pa(page));
ffffffffc0202aa2:	0166fb33          	and	s6,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202aa6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202aa8:	0efb7663          	bgeu	s6,a5,ffffffffc0202b94 <pmm_init+0x598>
ffffffffc0202aac:	0009b983          	ld	s3,0(s3)
    free_page(p);
ffffffffc0202ab0:	4585                	li	a1,1
ffffffffc0202ab2:	8556                	mv	a0,s5
ffffffffc0202ab4:	99b6                	add	s3,s3,a3
ffffffffc0202ab6:	bf6ff0ef          	jal	ra,ffffffffc0201eac <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202aba:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage) {
ffffffffc0202abe:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ac0:	078a                	slli	a5,a5,0x2
ffffffffc0202ac2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ac4:	0ce7f663          	bgeu	a5,a4,ffffffffc0202b90 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ac8:	00093503          	ld	a0,0(s2)
ffffffffc0202acc:	fff809b7          	lui	s3,0xfff80
ffffffffc0202ad0:	97ce                	add	a5,a5,s3
ffffffffc0202ad2:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc0202ad4:	953e                	add	a0,a0,a5
ffffffffc0202ad6:	4585                	li	a1,1
ffffffffc0202ad8:	bd4ff0ef          	jal	ra,ffffffffc0201eac <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0202adc:	000bb783          	ld	a5,0(s7)
    if (PPN(pa) >= npage) {
ffffffffc0202ae0:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ae2:	078a                	slli	a5,a5,0x2
ffffffffc0202ae4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0202ae6:	0ae7f563          	bgeu	a5,a4,ffffffffc0202b90 <pmm_init+0x594>
    return &pages[PPN(pa) - nbase];
ffffffffc0202aea:	00093503          	ld	a0,0(s2)
ffffffffc0202aee:	97ce                	add	a5,a5,s3
ffffffffc0202af0:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc0202af2:	953e                	add	a0,a0,a5
ffffffffc0202af4:	4585                	li	a1,1
ffffffffc0202af6:	bb6ff0ef          	jal	ra,ffffffffc0201eac <free_pages>
    boot_pgdir[0] = 0;
ffffffffc0202afa:	601c                	ld	a5,0(s0)
ffffffffc0202afc:	0007b023          	sd	zero,0(a5) # ffffffffc0200000 <kern_entry>
  asm volatile("sfence.vma");
ffffffffc0202b00:	12000073          	sfence.vma
    flush_tlb();

    assert(nr_free_store==nr_free_pages());
ffffffffc0202b04:	beeff0ef          	jal	ra,ffffffffc0201ef2 <nr_free_pages>
ffffffffc0202b08:	3caa1163          	bne	s4,a0,ffffffffc0202eca <pmm_init+0x8ce>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202b0c:	00005517          	auipc	a0,0x5
ffffffffc0202b10:	ed450513          	addi	a0,a0,-300 # ffffffffc02079e0 <default_pmm_manager+0x6c8>
ffffffffc0202b14:	e7afd0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0202b18:	6406                	ld	s0,64(sp)
ffffffffc0202b1a:	60a6                	ld	ra,72(sp)
ffffffffc0202b1c:	74e2                	ld	s1,56(sp)
ffffffffc0202b1e:	7942                	ld	s2,48(sp)
ffffffffc0202b20:	79a2                	ld	s3,40(sp)
ffffffffc0202b22:	7a02                	ld	s4,32(sp)
ffffffffc0202b24:	6ae2                	ld	s5,24(sp)
ffffffffc0202b26:	6b42                	ld	s6,16(sp)
ffffffffc0202b28:	6ba2                	ld	s7,8(sp)
ffffffffc0202b2a:	6c02                	ld	s8,0(sp)
ffffffffc0202b2c:	6161                	addi	sp,sp,80
    kmalloc_init();
ffffffffc0202b2e:	8daff06f          	j	ffffffffc0201c08 <kmalloc_init>
ffffffffc0202b32:	6008                	ld	a0,0(s0)
ffffffffc0202b34:	bd75                	j	ffffffffc02029f0 <pmm_init+0x3f4>
        assert((ptep = get_pte(boot_pgdir, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202b36:	00005697          	auipc	a3,0x5
ffffffffc0202b3a:	d1a68693          	addi	a3,a3,-742 # ffffffffc0207850 <default_pmm_manager+0x538>
ffffffffc0202b3e:	00004617          	auipc	a2,0x4
ffffffffc0202b42:	09260613          	addi	a2,a2,146 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202b46:	22700593          	li	a1,551
ffffffffc0202b4a:	00005517          	auipc	a0,0x5
ffffffffc0202b4e:	93e50513          	addi	a0,a0,-1730 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202b52:	92ffd0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc0202b56:	86d6                	mv	a3,s5
ffffffffc0202b58:	00005617          	auipc	a2,0x5
ffffffffc0202b5c:	81060613          	addi	a2,a2,-2032 # ffffffffc0207368 <default_pmm_manager+0x50>
ffffffffc0202b60:	22700593          	li	a1,551
ffffffffc0202b64:	00005517          	auipc	a0,0x5
ffffffffc0202b68:	92450513          	addi	a0,a0,-1756 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202b6c:	915fd0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202b70:	00005697          	auipc	a3,0x5
ffffffffc0202b74:	d2068693          	addi	a3,a3,-736 # ffffffffc0207890 <default_pmm_manager+0x578>
ffffffffc0202b78:	00004617          	auipc	a2,0x4
ffffffffc0202b7c:	05860613          	addi	a2,a2,88 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202b80:	22800593          	li	a1,552
ffffffffc0202b84:	00005517          	auipc	a0,0x5
ffffffffc0202b88:	90450513          	addi	a0,a0,-1788 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202b8c:	8f5fd0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc0202b90:	a78ff0ef          	jal	ra,ffffffffc0201e08 <pa2page.part.4>
    return KADDR(page2pa(page));
ffffffffc0202b94:	00004617          	auipc	a2,0x4
ffffffffc0202b98:	7d460613          	addi	a2,a2,2004 # ffffffffc0207368 <default_pmm_manager+0x50>
ffffffffc0202b9c:	06900593          	li	a1,105
ffffffffc0202ba0:	00004517          	auipc	a0,0x4
ffffffffc0202ba4:	7f050513          	addi	a0,a0,2032 # ffffffffc0207390 <default_pmm_manager+0x78>
ffffffffc0202ba8:	8d9fd0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc0202bac:	00005617          	auipc	a2,0x5
ffffffffc0202bb0:	a7460613          	addi	a2,a2,-1420 # ffffffffc0207620 <default_pmm_manager+0x308>
ffffffffc0202bb4:	07400593          	li	a1,116
ffffffffc0202bb8:	00004517          	auipc	a0,0x4
ffffffffc0202bbc:	7d850513          	addi	a0,a0,2008 # ffffffffc0207390 <default_pmm_manager+0x78>
ffffffffc0202bc0:	8c1fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(boot_pgdir != NULL && (uint32_t)PGOFF(boot_pgdir) == 0);
ffffffffc0202bc4:	00005697          	auipc	a3,0x5
ffffffffc0202bc8:	99c68693          	addi	a3,a3,-1636 # ffffffffc0207560 <default_pmm_manager+0x248>
ffffffffc0202bcc:	00004617          	auipc	a2,0x4
ffffffffc0202bd0:	00460613          	addi	a2,a2,4 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202bd4:	1eb00593          	li	a1,491
ffffffffc0202bd8:	00005517          	auipc	a0,0x5
ffffffffc0202bdc:	8b050513          	addi	a0,a0,-1872 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202be0:	8a1fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202be4:	00005697          	auipc	a3,0x5
ffffffffc0202be8:	a6468693          	addi	a3,a3,-1436 # ffffffffc0207648 <default_pmm_manager+0x330>
ffffffffc0202bec:	00004617          	auipc	a2,0x4
ffffffffc0202bf0:	fe460613          	addi	a2,a2,-28 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202bf4:	20700593          	li	a1,519
ffffffffc0202bf8:	00005517          	auipc	a0,0x5
ffffffffc0202bfc:	89050513          	addi	a0,a0,-1904 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202c00:	881fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202c04:	00005697          	auipc	a3,0x5
ffffffffc0202c08:	cbc68693          	addi	a3,a3,-836 # ffffffffc02078c0 <default_pmm_manager+0x5a8>
ffffffffc0202c0c:	00004617          	auipc	a2,0x4
ffffffffc0202c10:	fc460613          	addi	a2,a2,-60 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202c14:	23000593          	li	a1,560
ffffffffc0202c18:	00005517          	auipc	a0,0x5
ffffffffc0202c1c:	87050513          	addi	a0,a0,-1936 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202c20:	861fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202c24:	00005697          	auipc	a3,0x5
ffffffffc0202c28:	ab468693          	addi	a3,a3,-1356 # ffffffffc02076d8 <default_pmm_manager+0x3c0>
ffffffffc0202c2c:	00004617          	auipc	a2,0x4
ffffffffc0202c30:	fa460613          	addi	a2,a2,-92 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202c34:	20600593          	li	a1,518
ffffffffc0202c38:	00005517          	auipc	a0,0x5
ffffffffc0202c3c:	85050513          	addi	a0,a0,-1968 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202c40:	841fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202c44:	00005697          	auipc	a3,0x5
ffffffffc0202c48:	b5c68693          	addi	a3,a3,-1188 # ffffffffc02077a0 <default_pmm_manager+0x488>
ffffffffc0202c4c:	00004617          	auipc	a2,0x4
ffffffffc0202c50:	f8460613          	addi	a2,a2,-124 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202c54:	20500593          	li	a1,517
ffffffffc0202c58:	00005517          	auipc	a0,0x5
ffffffffc0202c5c:	83050513          	addi	a0,a0,-2000 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202c60:	821fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0202c64:	00005697          	auipc	a3,0x5
ffffffffc0202c68:	b2468693          	addi	a3,a3,-1244 # ffffffffc0207788 <default_pmm_manager+0x470>
ffffffffc0202c6c:	00004617          	auipc	a2,0x4
ffffffffc0202c70:	f6460613          	addi	a2,a2,-156 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202c74:	20400593          	li	a1,516
ffffffffc0202c78:	00005517          	auipc	a0,0x5
ffffffffc0202c7c:	81050513          	addi	a0,a0,-2032 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202c80:	801fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_insert(boot_pgdir, p1, PGSIZE, 0) == 0);
ffffffffc0202c84:	00005697          	auipc	a3,0x5
ffffffffc0202c88:	ad468693          	addi	a3,a3,-1324 # ffffffffc0207758 <default_pmm_manager+0x440>
ffffffffc0202c8c:	00004617          	auipc	a2,0x4
ffffffffc0202c90:	f4460613          	addi	a2,a2,-188 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202c94:	20300593          	li	a1,515
ffffffffc0202c98:	00004517          	auipc	a0,0x4
ffffffffc0202c9c:	7f050513          	addi	a0,a0,2032 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202ca0:	fe0fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0202ca4:	00005697          	auipc	a3,0x5
ffffffffc0202ca8:	a9c68693          	addi	a3,a3,-1380 # ffffffffc0207740 <default_pmm_manager+0x428>
ffffffffc0202cac:	00004617          	auipc	a2,0x4
ffffffffc0202cb0:	f2460613          	addi	a2,a2,-220 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202cb4:	20100593          	li	a1,513
ffffffffc0202cb8:	00004517          	auipc	a0,0x4
ffffffffc0202cbc:	7d050513          	addi	a0,a0,2000 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202cc0:	fc0fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(boot_pgdir[0] & PTE_U);
ffffffffc0202cc4:	00005697          	auipc	a3,0x5
ffffffffc0202cc8:	a6468693          	addi	a3,a3,-1436 # ffffffffc0207728 <default_pmm_manager+0x410>
ffffffffc0202ccc:	00004617          	auipc	a2,0x4
ffffffffc0202cd0:	f0460613          	addi	a2,a2,-252 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202cd4:	20000593          	li	a1,512
ffffffffc0202cd8:	00004517          	auipc	a0,0x4
ffffffffc0202cdc:	7b050513          	addi	a0,a0,1968 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202ce0:	fa0fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0202ce4:	00005697          	auipc	a3,0x5
ffffffffc0202ce8:	a3468693          	addi	a3,a3,-1484 # ffffffffc0207718 <default_pmm_manager+0x400>
ffffffffc0202cec:	00004617          	auipc	a2,0x4
ffffffffc0202cf0:	ee460613          	addi	a2,a2,-284 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202cf4:	1ff00593          	li	a1,511
ffffffffc0202cf8:	00004517          	auipc	a0,0x4
ffffffffc0202cfc:	79050513          	addi	a0,a0,1936 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202d00:	f80fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0202d04:	00005697          	auipc	a3,0x5
ffffffffc0202d08:	a0468693          	addi	a3,a3,-1532 # ffffffffc0207708 <default_pmm_manager+0x3f0>
ffffffffc0202d0c:	00004617          	auipc	a2,0x4
ffffffffc0202d10:	ec460613          	addi	a2,a2,-316 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202d14:	1fe00593          	li	a1,510
ffffffffc0202d18:	00004517          	auipc	a0,0x4
ffffffffc0202d1c:	77050513          	addi	a0,a0,1904 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202d20:	f60fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((ptep = get_pte(boot_pgdir, PGSIZE, 0)) != NULL);
ffffffffc0202d24:	00005697          	auipc	a3,0x5
ffffffffc0202d28:	9b468693          	addi	a3,a3,-1612 # ffffffffc02076d8 <default_pmm_manager+0x3c0>
ffffffffc0202d2c:	00004617          	auipc	a2,0x4
ffffffffc0202d30:	ea460613          	addi	a2,a2,-348 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202d34:	1fd00593          	li	a1,509
ffffffffc0202d38:	00004517          	auipc	a0,0x4
ffffffffc0202d3c:	75050513          	addi	a0,a0,1872 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202d40:	f40fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_insert(boot_pgdir, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202d44:	00005697          	auipc	a3,0x5
ffffffffc0202d48:	95c68693          	addi	a3,a3,-1700 # ffffffffc02076a0 <default_pmm_manager+0x388>
ffffffffc0202d4c:	00004617          	auipc	a2,0x4
ffffffffc0202d50:	e8460613          	addi	a2,a2,-380 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202d54:	1fc00593          	li	a1,508
ffffffffc0202d58:	00004517          	auipc	a0,0x4
ffffffffc0202d5c:	73050513          	addi	a0,a0,1840 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202d60:	f20fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(get_pte(boot_pgdir, PGSIZE, 0) == ptep);
ffffffffc0202d64:	00005697          	auipc	a3,0x5
ffffffffc0202d68:	91468693          	addi	a3,a3,-1772 # ffffffffc0207678 <default_pmm_manager+0x360>
ffffffffc0202d6c:	00004617          	auipc	a2,0x4
ffffffffc0202d70:	e6460613          	addi	a2,a2,-412 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202d74:	1f900593          	li	a1,505
ffffffffc0202d78:	00004517          	auipc	a0,0x4
ffffffffc0202d7c:	71050513          	addi	a0,a0,1808 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202d80:	f00fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202d84:	86da                	mv	a3,s6
ffffffffc0202d86:	00004617          	auipc	a2,0x4
ffffffffc0202d8a:	5e260613          	addi	a2,a2,1506 # ffffffffc0207368 <default_pmm_manager+0x50>
ffffffffc0202d8e:	1f800593          	li	a1,504
ffffffffc0202d92:	00004517          	auipc	a0,0x4
ffffffffc0202d96:	6f650513          	addi	a0,a0,1782 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202d9a:	ee6fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202d9e:	86be                	mv	a3,a5
ffffffffc0202da0:	00004617          	auipc	a2,0x4
ffffffffc0202da4:	5c860613          	addi	a2,a2,1480 # ffffffffc0207368 <default_pmm_manager+0x50>
ffffffffc0202da8:	06900593          	li	a1,105
ffffffffc0202dac:	00004517          	auipc	a0,0x4
ffffffffc0202db0:	5e450513          	addi	a0,a0,1508 # ffffffffc0207390 <default_pmm_manager+0x78>
ffffffffc0202db4:	eccfd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(pde2page(boot_pgdir[0])) == 1);
ffffffffc0202db8:	00005697          	auipc	a3,0x5
ffffffffc0202dbc:	a3068693          	addi	a3,a3,-1488 # ffffffffc02077e8 <default_pmm_manager+0x4d0>
ffffffffc0202dc0:	00004617          	auipc	a2,0x4
ffffffffc0202dc4:	e1060613          	addi	a2,a2,-496 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202dc8:	21200593          	li	a1,530
ffffffffc0202dcc:	00004517          	auipc	a0,0x4
ffffffffc0202dd0:	6bc50513          	addi	a0,a0,1724 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202dd4:	eacfd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202dd8:	00005697          	auipc	a3,0x5
ffffffffc0202ddc:	9c868693          	addi	a3,a3,-1592 # ffffffffc02077a0 <default_pmm_manager+0x488>
ffffffffc0202de0:	00004617          	auipc	a2,0x4
ffffffffc0202de4:	df060613          	addi	a2,a2,-528 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202de8:	21000593          	li	a1,528
ffffffffc0202dec:	00004517          	auipc	a0,0x4
ffffffffc0202df0:	69c50513          	addi	a0,a0,1692 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202df4:	e8cfd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0202df8:	00005697          	auipc	a3,0x5
ffffffffc0202dfc:	9d868693          	addi	a3,a3,-1576 # ffffffffc02077d0 <default_pmm_manager+0x4b8>
ffffffffc0202e00:	00004617          	auipc	a2,0x4
ffffffffc0202e04:	dd060613          	addi	a2,a2,-560 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202e08:	20f00593          	li	a1,527
ffffffffc0202e0c:	00004517          	auipc	a0,0x4
ffffffffc0202e10:	67c50513          	addi	a0,a0,1660 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202e14:	e6cfd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p) == 2);
ffffffffc0202e18:	00005697          	auipc	a3,0x5
ffffffffc0202e1c:	b3868693          	addi	a3,a3,-1224 # ffffffffc0207950 <default_pmm_manager+0x638>
ffffffffc0202e20:	00004617          	auipc	a2,0x4
ffffffffc0202e24:	db060613          	addi	a2,a2,-592 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202e28:	23300593          	li	a1,563
ffffffffc0202e2c:	00004517          	auipc	a0,0x4
ffffffffc0202e30:	65c50513          	addi	a0,a0,1628 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202e34:	e4cfd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_insert(boot_pgdir, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202e38:	00005697          	auipc	a3,0x5
ffffffffc0202e3c:	ad868693          	addi	a3,a3,-1320 # ffffffffc0207910 <default_pmm_manager+0x5f8>
ffffffffc0202e40:	00004617          	auipc	a2,0x4
ffffffffc0202e44:	d9060613          	addi	a2,a2,-624 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202e48:	23200593          	li	a1,562
ffffffffc0202e4c:	00004517          	auipc	a0,0x4
ffffffffc0202e50:	63c50513          	addi	a0,a0,1596 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202e54:	e2cfd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p) == 1);
ffffffffc0202e58:	00005697          	auipc	a3,0x5
ffffffffc0202e5c:	aa068693          	addi	a3,a3,-1376 # ffffffffc02078f8 <default_pmm_manager+0x5e0>
ffffffffc0202e60:	00004617          	auipc	a2,0x4
ffffffffc0202e64:	d7060613          	addi	a2,a2,-656 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202e68:	23100593          	li	a1,561
ffffffffc0202e6c:	00004517          	auipc	a0,0x4
ffffffffc0202e70:	61c50513          	addi	a0,a0,1564 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202e74:	e0cfd0ef          	jal	ra,ffffffffc0200480 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir[0]));
ffffffffc0202e78:	86be                	mv	a3,a5
ffffffffc0202e7a:	00004617          	auipc	a2,0x4
ffffffffc0202e7e:	4ee60613          	addi	a2,a2,1262 # ffffffffc0207368 <default_pmm_manager+0x50>
ffffffffc0202e82:	1f700593          	li	a1,503
ffffffffc0202e86:	00004517          	auipc	a0,0x4
ffffffffc0202e8a:	60250513          	addi	a0,a0,1538 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202e8e:	df2fd0ef          	jal	ra,ffffffffc0200480 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202e92:	00004617          	auipc	a2,0x4
ffffffffc0202e96:	50e60613          	addi	a2,a2,1294 # ffffffffc02073a0 <default_pmm_manager+0x88>
ffffffffc0202e9a:	07f00593          	li	a1,127
ffffffffc0202e9e:	00004517          	auipc	a0,0x4
ffffffffc0202ea2:	5ea50513          	addi	a0,a0,1514 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202ea6:	ddafd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202eaa:	00005697          	auipc	a3,0x5
ffffffffc0202eae:	ad668693          	addi	a3,a3,-1322 # ffffffffc0207980 <default_pmm_manager+0x668>
ffffffffc0202eb2:	00004617          	auipc	a2,0x4
ffffffffc0202eb6:	d1e60613          	addi	a2,a2,-738 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202eba:	23700593          	li	a1,567
ffffffffc0202ebe:	00004517          	auipc	a0,0x4
ffffffffc0202ec2:	5ca50513          	addi	a0,a0,1482 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202ec6:	dbafd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc0202eca:	00005697          	auipc	a3,0x5
ffffffffc0202ece:	94668693          	addi	a3,a3,-1722 # ffffffffc0207810 <default_pmm_manager+0x4f8>
ffffffffc0202ed2:	00004617          	auipc	a2,0x4
ffffffffc0202ed6:	cfe60613          	addi	a2,a2,-770 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202eda:	24300593          	li	a1,579
ffffffffc0202ede:	00004517          	auipc	a0,0x4
ffffffffc0202ee2:	5aa50513          	addi	a0,a0,1450 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202ee6:	d9afd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202eea:	00004697          	auipc	a3,0x4
ffffffffc0202eee:	77668693          	addi	a3,a3,1910 # ffffffffc0207660 <default_pmm_manager+0x348>
ffffffffc0202ef2:	00004617          	auipc	a2,0x4
ffffffffc0202ef6:	cde60613          	addi	a2,a2,-802 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202efa:	1f500593          	li	a1,501
ffffffffc0202efe:	00004517          	auipc	a0,0x4
ffffffffc0202f02:	58a50513          	addi	a0,a0,1418 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202f06:	d7afd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0202f0a:	00004697          	auipc	a3,0x4
ffffffffc0202f0e:	73e68693          	addi	a3,a3,1854 # ffffffffc0207648 <default_pmm_manager+0x330>
ffffffffc0202f12:	00004617          	auipc	a2,0x4
ffffffffc0202f16:	cbe60613          	addi	a2,a2,-834 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202f1a:	1f400593          	li	a1,500
ffffffffc0202f1e:	00004517          	auipc	a0,0x4
ffffffffc0202f22:	56a50513          	addi	a0,a0,1386 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202f26:	d5afd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(get_page(boot_pgdir, 0x0, NULL) == NULL);
ffffffffc0202f2a:	00004697          	auipc	a3,0x4
ffffffffc0202f2e:	66e68693          	addi	a3,a3,1646 # ffffffffc0207598 <default_pmm_manager+0x280>
ffffffffc0202f32:	00004617          	auipc	a2,0x4
ffffffffc0202f36:	c9e60613          	addi	a2,a2,-866 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202f3a:	1ec00593          	li	a1,492
ffffffffc0202f3e:	00004517          	auipc	a0,0x4
ffffffffc0202f42:	54a50513          	addi	a0,a0,1354 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202f46:	d3afd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((ptep = get_pte(boot_pgdir, 0x0, 0)) != NULL);
ffffffffc0202f4a:	00004697          	auipc	a3,0x4
ffffffffc0202f4e:	6a668693          	addi	a3,a3,1702 # ffffffffc02075f0 <default_pmm_manager+0x2d8>
ffffffffc0202f52:	00004617          	auipc	a2,0x4
ffffffffc0202f56:	c7e60613          	addi	a2,a2,-898 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202f5a:	1f300593          	li	a1,499
ffffffffc0202f5e:	00004517          	auipc	a0,0x4
ffffffffc0202f62:	52a50513          	addi	a0,a0,1322 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202f66:	d1afd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_insert(boot_pgdir, p1, 0x0, 0) == 0);
ffffffffc0202f6a:	00004697          	auipc	a3,0x4
ffffffffc0202f6e:	65668693          	addi	a3,a3,1622 # ffffffffc02075c0 <default_pmm_manager+0x2a8>
ffffffffc0202f72:	00004617          	auipc	a2,0x4
ffffffffc0202f76:	c5e60613          	addi	a2,a2,-930 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202f7a:	1f000593          	li	a1,496
ffffffffc0202f7e:	00004517          	auipc	a0,0x4
ffffffffc0202f82:	50a50513          	addi	a0,a0,1290 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202f86:	cfafd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0202f8a:	00005697          	auipc	a3,0x5
ffffffffc0202f8e:	81668693          	addi	a3,a3,-2026 # ffffffffc02077a0 <default_pmm_manager+0x488>
ffffffffc0202f92:	00004617          	auipc	a2,0x4
ffffffffc0202f96:	c3e60613          	addi	a2,a2,-962 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202f9a:	20c00593          	li	a1,524
ffffffffc0202f9e:	00004517          	auipc	a0,0x4
ffffffffc0202fa2:	4ea50513          	addi	a0,a0,1258 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202fa6:	cdafd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0202faa:	00004697          	auipc	a3,0x4
ffffffffc0202fae:	6b668693          	addi	a3,a3,1718 # ffffffffc0207660 <default_pmm_manager+0x348>
ffffffffc0202fb2:	00004617          	auipc	a2,0x4
ffffffffc0202fb6:	c1e60613          	addi	a2,a2,-994 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202fba:	20b00593          	li	a1,523
ffffffffc0202fbe:	00004517          	auipc	a0,0x4
ffffffffc0202fc2:	4ca50513          	addi	a0,a0,1226 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202fc6:	cbafd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202fca:	00004697          	auipc	a3,0x4
ffffffffc0202fce:	7ee68693          	addi	a3,a3,2030 # ffffffffc02077b8 <default_pmm_manager+0x4a0>
ffffffffc0202fd2:	00004617          	auipc	a2,0x4
ffffffffc0202fd6:	bfe60613          	addi	a2,a2,-1026 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202fda:	20800593          	li	a1,520
ffffffffc0202fde:	00004517          	auipc	a0,0x4
ffffffffc0202fe2:	4aa50513          	addi	a0,a0,1194 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0202fe6:	c9afd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202fea:	00005697          	auipc	a3,0x5
ffffffffc0202fee:	9ce68693          	addi	a3,a3,-1586 # ffffffffc02079b8 <default_pmm_manager+0x6a0>
ffffffffc0202ff2:	00004617          	auipc	a2,0x4
ffffffffc0202ff6:	bde60613          	addi	a2,a2,-1058 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0202ffa:	23a00593          	li	a1,570
ffffffffc0202ffe:	00004517          	auipc	a0,0x4
ffffffffc0203002:	48a50513          	addi	a0,a0,1162 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0203006:	c7afd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(nr_free_store==nr_free_pages());
ffffffffc020300a:	00005697          	auipc	a3,0x5
ffffffffc020300e:	80668693          	addi	a3,a3,-2042 # ffffffffc0207810 <default_pmm_manager+0x4f8>
ffffffffc0203012:	00004617          	auipc	a2,0x4
ffffffffc0203016:	bbe60613          	addi	a2,a2,-1090 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020301a:	21a00593          	li	a1,538
ffffffffc020301e:	00004517          	auipc	a0,0x4
ffffffffc0203022:	46a50513          	addi	a0,a0,1130 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0203026:	c5afd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(boot_pgdir[0] == 0);
ffffffffc020302a:	00005697          	auipc	a3,0x5
ffffffffc020302e:	87e68693          	addi	a3,a3,-1922 # ffffffffc02078a8 <default_pmm_manager+0x590>
ffffffffc0203032:	00004617          	auipc	a2,0x4
ffffffffc0203036:	b9e60613          	addi	a2,a2,-1122 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020303a:	22c00593          	li	a1,556
ffffffffc020303e:	00004517          	auipc	a0,0x4
ffffffffc0203042:	44a50513          	addi	a0,a0,1098 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0203046:	c3afd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020304a:	00004697          	auipc	a3,0x4
ffffffffc020304e:	4f668693          	addi	a3,a3,1270 # ffffffffc0207540 <default_pmm_manager+0x228>
ffffffffc0203052:	00004617          	auipc	a2,0x4
ffffffffc0203056:	b7e60613          	addi	a2,a2,-1154 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020305a:	1ea00593          	li	a1,490
ffffffffc020305e:	00004517          	auipc	a0,0x4
ffffffffc0203062:	42a50513          	addi	a0,a0,1066 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0203066:	c1afd0ef          	jal	ra,ffffffffc0200480 <__panic>
    boot_cr3 = PADDR(boot_pgdir);
ffffffffc020306a:	00004617          	auipc	a2,0x4
ffffffffc020306e:	33660613          	addi	a2,a2,822 # ffffffffc02073a0 <default_pmm_manager+0x88>
ffffffffc0203072:	0c100593          	li	a1,193
ffffffffc0203076:	00004517          	auipc	a0,0x4
ffffffffc020307a:	41250513          	addi	a0,a0,1042 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc020307e:	c02fd0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0203082 <copy_range>:
               bool share) {
ffffffffc0203082:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203084:	00d667b3          	or	a5,a2,a3
               bool share) {
ffffffffc0203088:	f486                	sd	ra,104(sp)
ffffffffc020308a:	f0a2                	sd	s0,96(sp)
ffffffffc020308c:	eca6                	sd	s1,88(sp)
ffffffffc020308e:	e8ca                	sd	s2,80(sp)
ffffffffc0203090:	e4ce                	sd	s3,72(sp)
ffffffffc0203092:	e0d2                	sd	s4,64(sp)
ffffffffc0203094:	fc56                	sd	s5,56(sp)
ffffffffc0203096:	f85a                	sd	s6,48(sp)
ffffffffc0203098:	f45e                	sd	s7,40(sp)
ffffffffc020309a:	f062                	sd	s8,32(sp)
ffffffffc020309c:	ec66                	sd	s9,24(sp)
ffffffffc020309e:	e86a                	sd	s10,16(sp)
ffffffffc02030a0:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02030a2:	03479713          	slli	a4,a5,0x34
ffffffffc02030a6:	1e071863          	bnez	a4,ffffffffc0203296 <copy_range+0x214>
    assert(USER_ACCESS(start, end));
ffffffffc02030aa:	002007b7          	lui	a5,0x200
ffffffffc02030ae:	8432                	mv	s0,a2
ffffffffc02030b0:	16f66b63          	bltu	a2,a5,ffffffffc0203226 <copy_range+0x1a4>
ffffffffc02030b4:	84b6                	mv	s1,a3
ffffffffc02030b6:	16d67863          	bgeu	a2,a3,ffffffffc0203226 <copy_range+0x1a4>
ffffffffc02030ba:	4785                	li	a5,1
ffffffffc02030bc:	07fe                	slli	a5,a5,0x1f
ffffffffc02030be:	16d7e463          	bltu	a5,a3,ffffffffc0203226 <copy_range+0x1a4>
ffffffffc02030c2:	5a7d                	li	s4,-1
ffffffffc02030c4:	8aaa                	mv	s5,a0
ffffffffc02030c6:	892e                	mv	s2,a1
        start += PGSIZE;
ffffffffc02030c8:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage) {
ffffffffc02030ca:	000a9c17          	auipc	s8,0xa9
ffffffffc02030ce:	796c0c13          	addi	s8,s8,1942 # ffffffffc02ac860 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02030d2:	000a9b97          	auipc	s7,0xa9
ffffffffc02030d6:	7feb8b93          	addi	s7,s7,2046 # ffffffffc02ac8d0 <pages>
    return page - pages + nbase;
ffffffffc02030da:	00080b37          	lui	s6,0x80
    return KADDR(page2pa(page));
ffffffffc02030de:	00ca5a13          	srli	s4,s4,0xc
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc02030e2:	4601                	li	a2,0
ffffffffc02030e4:	85a2                	mv	a1,s0
ffffffffc02030e6:	854a                	mv	a0,s2
ffffffffc02030e8:	e4bfe0ef          	jal	ra,ffffffffc0201f32 <get_pte>
ffffffffc02030ec:	8caa                	mv	s9,a0
        if (ptep == NULL) {
ffffffffc02030ee:	c17d                	beqz	a0,ffffffffc02031d4 <copy_range+0x152>
        if (*ptep & PTE_V) {
ffffffffc02030f0:	611c                	ld	a5,0(a0)
ffffffffc02030f2:	8b85                	andi	a5,a5,1
ffffffffc02030f4:	e785                	bnez	a5,ffffffffc020311c <copy_range+0x9a>
        start += PGSIZE;
ffffffffc02030f6:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc02030f8:	fe9465e3          	bltu	s0,s1,ffffffffc02030e2 <copy_range+0x60>
    return 0;
ffffffffc02030fc:	4501                	li	a0,0
}
ffffffffc02030fe:	70a6                	ld	ra,104(sp)
ffffffffc0203100:	7406                	ld	s0,96(sp)
ffffffffc0203102:	64e6                	ld	s1,88(sp)
ffffffffc0203104:	6946                	ld	s2,80(sp)
ffffffffc0203106:	69a6                	ld	s3,72(sp)
ffffffffc0203108:	6a06                	ld	s4,64(sp)
ffffffffc020310a:	7ae2                	ld	s5,56(sp)
ffffffffc020310c:	7b42                	ld	s6,48(sp)
ffffffffc020310e:	7ba2                	ld	s7,40(sp)
ffffffffc0203110:	7c02                	ld	s8,32(sp)
ffffffffc0203112:	6ce2                	ld	s9,24(sp)
ffffffffc0203114:	6d42                	ld	s10,16(sp)
ffffffffc0203116:	6da2                	ld	s11,8(sp)
ffffffffc0203118:	6165                	addi	sp,sp,112
ffffffffc020311a:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL) {
ffffffffc020311c:	4605                	li	a2,1
ffffffffc020311e:	85a2                	mv	a1,s0
ffffffffc0203120:	8556                	mv	a0,s5
ffffffffc0203122:	e11fe0ef          	jal	ra,ffffffffc0201f32 <get_pte>
ffffffffc0203126:	c169                	beqz	a0,ffffffffc02031e8 <copy_range+0x166>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0203128:	000cb783          	ld	a5,0(s9)
    if (!(pte & PTE_V)) {
ffffffffc020312c:	0017f713          	andi	a4,a5,1
ffffffffc0203130:	01f7fc93          	andi	s9,a5,31
ffffffffc0203134:	14070563          	beqz	a4,ffffffffc020327e <copy_range+0x1fc>
    if (PPN(pa) >= npage) {
ffffffffc0203138:	000c3683          	ld	a3,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc020313c:	078a                	slli	a5,a5,0x2
ffffffffc020313e:	00c7d713          	srli	a4,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203142:	12d77263          	bgeu	a4,a3,ffffffffc0203266 <copy_range+0x1e4>
    return &pages[PPN(pa) - nbase];
ffffffffc0203146:	000bb783          	ld	a5,0(s7)
ffffffffc020314a:	fff806b7          	lui	a3,0xfff80
ffffffffc020314e:	9736                	add	a4,a4,a3
ffffffffc0203150:	071a                	slli	a4,a4,0x6
            struct Page *npage = alloc_page();
ffffffffc0203152:	4505                	li	a0,1
ffffffffc0203154:	00e78db3          	add	s11,a5,a4
ffffffffc0203158:	ccdfe0ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc020315c:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc020315e:	0a0d8463          	beqz	s11,ffffffffc0203206 <copy_range+0x184>
            assert(npage != NULL);
ffffffffc0203162:	c175                	beqz	a0,ffffffffc0203246 <copy_range+0x1c4>
    return page - pages + nbase;
ffffffffc0203164:	000bb703          	ld	a4,0(s7)
    return KADDR(page2pa(page));
ffffffffc0203168:	000c3603          	ld	a2,0(s8)
    return page - pages + nbase;
ffffffffc020316c:	40ed86b3          	sub	a3,s11,a4
ffffffffc0203170:	8699                	srai	a3,a3,0x6
ffffffffc0203172:	96da                	add	a3,a3,s6
    return KADDR(page2pa(page));
ffffffffc0203174:	0146f7b3          	and	a5,a3,s4
    return page2ppn(page) << PGSHIFT;
ffffffffc0203178:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020317a:	06c7fa63          	bgeu	a5,a2,ffffffffc02031ee <copy_range+0x16c>
    return page - pages + nbase;
ffffffffc020317e:	40e507b3          	sub	a5,a0,a4
    return KADDR(page2pa(page));
ffffffffc0203182:	000a9717          	auipc	a4,0xa9
ffffffffc0203186:	73e70713          	addi	a4,a4,1854 # ffffffffc02ac8c0 <va_pa_offset>
ffffffffc020318a:	6308                	ld	a0,0(a4)
    return page - pages + nbase;
ffffffffc020318c:	8799                	srai	a5,a5,0x6
ffffffffc020318e:	97da                	add	a5,a5,s6
    return KADDR(page2pa(page));
ffffffffc0203190:	0147f733          	and	a4,a5,s4
ffffffffc0203194:	00a685b3          	add	a1,a3,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0203198:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc020319a:	04c77963          	bgeu	a4,a2,ffffffffc02031ec <copy_range+0x16a>
            memcpy(dst, src, PGSIZE);
ffffffffc020319e:	6605                	lui	a2,0x1
ffffffffc02031a0:	953e                	add	a0,a0,a5
ffffffffc02031a2:	420030ef          	jal	ra,ffffffffc02065c2 <memcpy>
            ret = page_insert(to, npage, start, perm);
ffffffffc02031a6:	86e6                	mv	a3,s9
ffffffffc02031a8:	8622                	mv	a2,s0
ffffffffc02031aa:	85ea                	mv	a1,s10
ffffffffc02031ac:	8556                	mv	a0,s5
ffffffffc02031ae:	b90ff0ef          	jal	ra,ffffffffc020253e <page_insert>
            assert(ret == 0);
ffffffffc02031b2:	d131                	beqz	a0,ffffffffc02030f6 <copy_range+0x74>
ffffffffc02031b4:	00004697          	auipc	a3,0x4
ffffffffc02031b8:	2c468693          	addi	a3,a3,708 # ffffffffc0207478 <default_pmm_manager+0x160>
ffffffffc02031bc:	00004617          	auipc	a2,0x4
ffffffffc02031c0:	a1460613          	addi	a2,a2,-1516 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02031c4:	18c00593          	li	a1,396
ffffffffc02031c8:	00004517          	auipc	a0,0x4
ffffffffc02031cc:	2c050513          	addi	a0,a0,704 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc02031d0:	ab0fd0ef          	jal	ra,ffffffffc0200480 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02031d4:	002007b7          	lui	a5,0x200
ffffffffc02031d8:	943e                	add	s0,s0,a5
ffffffffc02031da:	ffe007b7          	lui	a5,0xffe00
ffffffffc02031de:	8c7d                	and	s0,s0,a5
    } while (start != 0 && start < end);
ffffffffc02031e0:	dc11                	beqz	s0,ffffffffc02030fc <copy_range+0x7a>
ffffffffc02031e2:	f09460e3          	bltu	s0,s1,ffffffffc02030e2 <copy_range+0x60>
ffffffffc02031e6:	bf19                	j	ffffffffc02030fc <copy_range+0x7a>
                return -E_NO_MEM;
ffffffffc02031e8:	5571                	li	a0,-4
ffffffffc02031ea:	bf11                	j	ffffffffc02030fe <copy_range+0x7c>
ffffffffc02031ec:	86be                	mv	a3,a5
ffffffffc02031ee:	00004617          	auipc	a2,0x4
ffffffffc02031f2:	17a60613          	addi	a2,a2,378 # ffffffffc0207368 <default_pmm_manager+0x50>
ffffffffc02031f6:	06900593          	li	a1,105
ffffffffc02031fa:	00004517          	auipc	a0,0x4
ffffffffc02031fe:	19650513          	addi	a0,a0,406 # ffffffffc0207390 <default_pmm_manager+0x78>
ffffffffc0203202:	a7efd0ef          	jal	ra,ffffffffc0200480 <__panic>
            assert(page != NULL);
ffffffffc0203206:	00004697          	auipc	a3,0x4
ffffffffc020320a:	25268693          	addi	a3,a3,594 # ffffffffc0207458 <default_pmm_manager+0x140>
ffffffffc020320e:	00004617          	auipc	a2,0x4
ffffffffc0203212:	9c260613          	addi	a2,a2,-1598 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203216:	17200593          	li	a1,370
ffffffffc020321a:	00004517          	auipc	a0,0x4
ffffffffc020321e:	26e50513          	addi	a0,a0,622 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0203222:	a5efd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0203226:	00005697          	auipc	a3,0x5
ffffffffc020322a:	80a68693          	addi	a3,a3,-2038 # ffffffffc0207a30 <default_pmm_manager+0x718>
ffffffffc020322e:	00004617          	auipc	a2,0x4
ffffffffc0203232:	9a260613          	addi	a2,a2,-1630 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203236:	15e00593          	li	a1,350
ffffffffc020323a:	00004517          	auipc	a0,0x4
ffffffffc020323e:	24e50513          	addi	a0,a0,590 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0203242:	a3efd0ef          	jal	ra,ffffffffc0200480 <__panic>
            assert(npage != NULL);
ffffffffc0203246:	00004697          	auipc	a3,0x4
ffffffffc020324a:	22268693          	addi	a3,a3,546 # ffffffffc0207468 <default_pmm_manager+0x150>
ffffffffc020324e:	00004617          	auipc	a2,0x4
ffffffffc0203252:	98260613          	addi	a2,a2,-1662 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203256:	17300593          	li	a1,371
ffffffffc020325a:	00004517          	auipc	a0,0x4
ffffffffc020325e:	22e50513          	addi	a0,a0,558 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc0203262:	a1efd0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203266:	00004617          	auipc	a2,0x4
ffffffffc020326a:	16260613          	addi	a2,a2,354 # ffffffffc02073c8 <default_pmm_manager+0xb0>
ffffffffc020326e:	06200593          	li	a1,98
ffffffffc0203272:	00004517          	auipc	a0,0x4
ffffffffc0203276:	11e50513          	addi	a0,a0,286 # ffffffffc0207390 <default_pmm_manager+0x78>
ffffffffc020327a:	a06fd0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020327e:	00004617          	auipc	a2,0x4
ffffffffc0203282:	3a260613          	addi	a2,a2,930 # ffffffffc0207620 <default_pmm_manager+0x308>
ffffffffc0203286:	07400593          	li	a1,116
ffffffffc020328a:	00004517          	auipc	a0,0x4
ffffffffc020328e:	10650513          	addi	a0,a0,262 # ffffffffc0207390 <default_pmm_manager+0x78>
ffffffffc0203292:	9eefd0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203296:	00004697          	auipc	a3,0x4
ffffffffc020329a:	76a68693          	addi	a3,a3,1898 # ffffffffc0207a00 <default_pmm_manager+0x6e8>
ffffffffc020329e:	00004617          	auipc	a2,0x4
ffffffffc02032a2:	93260613          	addi	a2,a2,-1742 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02032a6:	15d00593          	li	a1,349
ffffffffc02032aa:	00004517          	auipc	a0,0x4
ffffffffc02032ae:	1de50513          	addi	a0,a0,478 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc02032b2:	9cefd0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02032b6 <tlb_invalidate>:
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02032b6:	12058073          	sfence.vma	a1
}
ffffffffc02032ba:	8082                	ret

ffffffffc02032bc <pgdir_alloc_page>:
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02032bc:	7179                	addi	sp,sp,-48
ffffffffc02032be:	e84a                	sd	s2,16(sp)
ffffffffc02032c0:	892a                	mv	s2,a0
    struct Page *page = alloc_page();
ffffffffc02032c2:	4505                	li	a0,1
struct Page *pgdir_alloc_page(pde_t *pgdir, uintptr_t la, uint32_t perm) {
ffffffffc02032c4:	f022                	sd	s0,32(sp)
ffffffffc02032c6:	ec26                	sd	s1,24(sp)
ffffffffc02032c8:	e44e                	sd	s3,8(sp)
ffffffffc02032ca:	f406                	sd	ra,40(sp)
ffffffffc02032cc:	84ae                	mv	s1,a1
ffffffffc02032ce:	89b2                	mv	s3,a2
    struct Page *page = alloc_page();
ffffffffc02032d0:	b55fe0ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc02032d4:	842a                	mv	s0,a0
    if (page != NULL) {
ffffffffc02032d6:	cd1d                	beqz	a0,ffffffffc0203314 <pgdir_alloc_page+0x58>
        if (page_insert(pgdir, page, la, perm) != 0) {
ffffffffc02032d8:	85aa                	mv	a1,a0
ffffffffc02032da:	86ce                	mv	a3,s3
ffffffffc02032dc:	8626                	mv	a2,s1
ffffffffc02032de:	854a                	mv	a0,s2
ffffffffc02032e0:	a5eff0ef          	jal	ra,ffffffffc020253e <page_insert>
ffffffffc02032e4:	e121                	bnez	a0,ffffffffc0203324 <pgdir_alloc_page+0x68>
        if (swap_init_ok) {
ffffffffc02032e6:	000a9797          	auipc	a5,0xa9
ffffffffc02032ea:	58a78793          	addi	a5,a5,1418 # ffffffffc02ac870 <swap_init_ok>
ffffffffc02032ee:	439c                	lw	a5,0(a5)
ffffffffc02032f0:	2781                	sext.w	a5,a5
ffffffffc02032f2:	c38d                	beqz	a5,ffffffffc0203314 <pgdir_alloc_page+0x58>
            if (check_mm_struct != NULL) {
ffffffffc02032f4:	000a9797          	auipc	a5,0xa9
ffffffffc02032f8:	6bc78793          	addi	a5,a5,1724 # ffffffffc02ac9b0 <check_mm_struct>
ffffffffc02032fc:	6388                	ld	a0,0(a5)
ffffffffc02032fe:	c919                	beqz	a0,ffffffffc0203314 <pgdir_alloc_page+0x58>
                swap_map_swappable(check_mm_struct, la, page, 0);
ffffffffc0203300:	4681                	li	a3,0
ffffffffc0203302:	8622                	mv	a2,s0
ffffffffc0203304:	85a6                	mv	a1,s1
ffffffffc0203306:	7da000ef          	jal	ra,ffffffffc0203ae0 <swap_map_swappable>
                assert(page_ref(page) == 1);
ffffffffc020330a:	4018                	lw	a4,0(s0)
                page->pra_vaddr = la;
ffffffffc020330c:	fc04                	sd	s1,56(s0)
                assert(page_ref(page) == 1);
ffffffffc020330e:	4785                	li	a5,1
ffffffffc0203310:	02f71063          	bne	a4,a5,ffffffffc0203330 <pgdir_alloc_page+0x74>
}
ffffffffc0203314:	8522                	mv	a0,s0
ffffffffc0203316:	70a2                	ld	ra,40(sp)
ffffffffc0203318:	7402                	ld	s0,32(sp)
ffffffffc020331a:	64e2                	ld	s1,24(sp)
ffffffffc020331c:	6942                	ld	s2,16(sp)
ffffffffc020331e:	69a2                	ld	s3,8(sp)
ffffffffc0203320:	6145                	addi	sp,sp,48
ffffffffc0203322:	8082                	ret
            free_page(page);
ffffffffc0203324:	8522                	mv	a0,s0
ffffffffc0203326:	4585                	li	a1,1
ffffffffc0203328:	b85fe0ef          	jal	ra,ffffffffc0201eac <free_pages>
            return NULL;
ffffffffc020332c:	4401                	li	s0,0
ffffffffc020332e:	b7dd                	j	ffffffffc0203314 <pgdir_alloc_page+0x58>
                assert(page_ref(page) == 1);
ffffffffc0203330:	00004697          	auipc	a3,0x4
ffffffffc0203334:	16868693          	addi	a3,a3,360 # ffffffffc0207498 <default_pmm_manager+0x180>
ffffffffc0203338:	00004617          	auipc	a2,0x4
ffffffffc020333c:	89860613          	addi	a2,a2,-1896 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203340:	1cb00593          	li	a1,459
ffffffffc0203344:	00004517          	auipc	a0,0x4
ffffffffc0203348:	14450513          	addi	a0,a0,324 # ffffffffc0207488 <default_pmm_manager+0x170>
ffffffffc020334c:	934fd0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0203350 <swap_init>:

static void check_swap(void);

int
swap_init(void)
{
ffffffffc0203350:	7135                	addi	sp,sp,-160
ffffffffc0203352:	ed06                	sd	ra,152(sp)
ffffffffc0203354:	e922                	sd	s0,144(sp)
ffffffffc0203356:	e526                	sd	s1,136(sp)
ffffffffc0203358:	e14a                	sd	s2,128(sp)
ffffffffc020335a:	fcce                	sd	s3,120(sp)
ffffffffc020335c:	f8d2                	sd	s4,112(sp)
ffffffffc020335e:	f4d6                	sd	s5,104(sp)
ffffffffc0203360:	f0da                	sd	s6,96(sp)
ffffffffc0203362:	ecde                	sd	s7,88(sp)
ffffffffc0203364:	e8e2                	sd	s8,80(sp)
ffffffffc0203366:	e4e6                	sd	s9,72(sp)
ffffffffc0203368:	e0ea                	sd	s10,64(sp)
ffffffffc020336a:	fc6e                	sd	s11,56(sp)
     swapfs_init();
ffffffffc020336c:	790010ef          	jal	ra,ffffffffc0204afc <swapfs_init>

     // Since the IDE is faked, it can only store 7 pages at most to pass the test
     if (!(7 <= max_swap_offset &&
ffffffffc0203370:	000a9797          	auipc	a5,0xa9
ffffffffc0203374:	5f078793          	addi	a5,a5,1520 # ffffffffc02ac960 <max_swap_offset>
ffffffffc0203378:	6394                	ld	a3,0(a5)
ffffffffc020337a:	010007b7          	lui	a5,0x1000
ffffffffc020337e:	17e1                	addi	a5,a5,-8
ffffffffc0203380:	ff968713          	addi	a4,a3,-7
ffffffffc0203384:	4ae7ee63          	bltu	a5,a4,ffffffffc0203840 <swap_init+0x4f0>
        max_swap_offset < MAX_SWAP_OFFSET_LIMIT)) {
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
     }
     

     sm = &swap_manager_fifo;
ffffffffc0203388:	0009e797          	auipc	a5,0x9e
ffffffffc020338c:	06878793          	addi	a5,a5,104 # ffffffffc02a13f0 <swap_manager_fifo>
     int r = sm->init();
ffffffffc0203390:	6798                	ld	a4,8(a5)
     sm = &swap_manager_fifo;
ffffffffc0203392:	000a9697          	auipc	a3,0xa9
ffffffffc0203396:	4cf6bb23          	sd	a5,1238(a3) # ffffffffc02ac868 <sm>
     int r = sm->init();
ffffffffc020339a:	9702                	jalr	a4
ffffffffc020339c:	8aaa                	mv	s5,a0
     
     if (r == 0)
ffffffffc020339e:	c10d                	beqz	a0,ffffffffc02033c0 <swap_init+0x70>
          cprintf("SWAP: manager = %s\n", sm->name);
          check_swap();
     }

     return r;
}
ffffffffc02033a0:	60ea                	ld	ra,152(sp)
ffffffffc02033a2:	644a                	ld	s0,144(sp)
ffffffffc02033a4:	8556                	mv	a0,s5
ffffffffc02033a6:	64aa                	ld	s1,136(sp)
ffffffffc02033a8:	690a                	ld	s2,128(sp)
ffffffffc02033aa:	79e6                	ld	s3,120(sp)
ffffffffc02033ac:	7a46                	ld	s4,112(sp)
ffffffffc02033ae:	7aa6                	ld	s5,104(sp)
ffffffffc02033b0:	7b06                	ld	s6,96(sp)
ffffffffc02033b2:	6be6                	ld	s7,88(sp)
ffffffffc02033b4:	6c46                	ld	s8,80(sp)
ffffffffc02033b6:	6ca6                	ld	s9,72(sp)
ffffffffc02033b8:	6d06                	ld	s10,64(sp)
ffffffffc02033ba:	7de2                	ld	s11,56(sp)
ffffffffc02033bc:	610d                	addi	sp,sp,160
ffffffffc02033be:	8082                	ret
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02033c0:	000a9797          	auipc	a5,0xa9
ffffffffc02033c4:	4a878793          	addi	a5,a5,1192 # ffffffffc02ac868 <sm>
ffffffffc02033c8:	639c                	ld	a5,0(a5)
ffffffffc02033ca:	00004517          	auipc	a0,0x4
ffffffffc02033ce:	6fe50513          	addi	a0,a0,1790 # ffffffffc0207ac8 <default_pmm_manager+0x7b0>
    return listelm->next;
ffffffffc02033d2:	000a9417          	auipc	s0,0xa9
ffffffffc02033d6:	4ce40413          	addi	s0,s0,1230 # ffffffffc02ac8a0 <free_area>
ffffffffc02033da:	638c                	ld	a1,0(a5)
          swap_init_ok = 1;
ffffffffc02033dc:	4785                	li	a5,1
ffffffffc02033de:	000a9717          	auipc	a4,0xa9
ffffffffc02033e2:	48f72923          	sw	a5,1170(a4) # ffffffffc02ac870 <swap_init_ok>
          cprintf("SWAP: manager = %s\n", sm->name);
ffffffffc02033e6:	da9fc0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc02033ea:	641c                	ld	a5,8(s0)
check_swap(void)
{
    //backup mem env
     int ret, count = 0, total = 0, i;
     list_entry_t *le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc02033ec:	36878e63          	beq	a5,s0,ffffffffc0203768 <swap_init+0x418>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02033f0:	ff07b703          	ld	a4,-16(a5)
ffffffffc02033f4:	8305                	srli	a4,a4,0x1
ffffffffc02033f6:	8b05                	andi	a4,a4,1
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc02033f8:	36070c63          	beqz	a4,ffffffffc0203770 <swap_init+0x420>
     int ret, count = 0, total = 0, i;
ffffffffc02033fc:	4481                	li	s1,0
ffffffffc02033fe:	4901                	li	s2,0
ffffffffc0203400:	a031                	j	ffffffffc020340c <swap_init+0xbc>
ffffffffc0203402:	ff07b703          	ld	a4,-16(a5)
        assert(PageProperty(p));
ffffffffc0203406:	8b09                	andi	a4,a4,2
ffffffffc0203408:	36070463          	beqz	a4,ffffffffc0203770 <swap_init+0x420>
        count ++, total += p->property;
ffffffffc020340c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203410:	679c                	ld	a5,8(a5)
ffffffffc0203412:	2905                	addiw	s2,s2,1
ffffffffc0203414:	9cb9                	addw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203416:	fe8796e3          	bne	a5,s0,ffffffffc0203402 <swap_init+0xb2>
ffffffffc020341a:	89a6                	mv	s3,s1
     }
     assert(total == nr_free_pages());
ffffffffc020341c:	ad7fe0ef          	jal	ra,ffffffffc0201ef2 <nr_free_pages>
ffffffffc0203420:	69351863          	bne	a0,s3,ffffffffc0203ab0 <swap_init+0x760>
     cprintf("BEGIN check_swap: count %d, total %d\n",count,total);
ffffffffc0203424:	8626                	mv	a2,s1
ffffffffc0203426:	85ca                	mv	a1,s2
ffffffffc0203428:	00004517          	auipc	a0,0x4
ffffffffc020342c:	6b850513          	addi	a0,a0,1720 # ffffffffc0207ae0 <default_pmm_manager+0x7c8>
ffffffffc0203430:	d5ffc0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     //now we set the phy pages env     
     struct mm_struct *mm = mm_create();
ffffffffc0203434:	457000ef          	jal	ra,ffffffffc020408a <mm_create>
ffffffffc0203438:	8baa                	mv	s7,a0
     assert(mm != NULL);
ffffffffc020343a:	60050b63          	beqz	a0,ffffffffc0203a50 <swap_init+0x700>

     extern struct mm_struct *check_mm_struct;
     assert(check_mm_struct == NULL);
ffffffffc020343e:	000a9797          	auipc	a5,0xa9
ffffffffc0203442:	57278793          	addi	a5,a5,1394 # ffffffffc02ac9b0 <check_mm_struct>
ffffffffc0203446:	639c                	ld	a5,0(a5)
ffffffffc0203448:	62079463          	bnez	a5,ffffffffc0203a70 <swap_init+0x720>

     check_mm_struct = mm;

     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc020344c:	000a9797          	auipc	a5,0xa9
ffffffffc0203450:	40c78793          	addi	a5,a5,1036 # ffffffffc02ac858 <boot_pgdir>
ffffffffc0203454:	0007bb03          	ld	s6,0(a5)
     check_mm_struct = mm;
ffffffffc0203458:	000a9797          	auipc	a5,0xa9
ffffffffc020345c:	54a7bc23          	sd	a0,1368(a5) # ffffffffc02ac9b0 <check_mm_struct>
     assert(pgdir[0] == 0);
ffffffffc0203460:	000b3783          	ld	a5,0(s6) # 80000 <_binary_obj___user_exit_out_size+0x75530>
     pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc0203464:	01653c23          	sd	s6,24(a0)
     assert(pgdir[0] == 0);
ffffffffc0203468:	4e079863          	bnez	a5,ffffffffc0203958 <swap_init+0x608>

     struct vma_struct *vma = vma_create(BEING_CHECK_VALID_VADDR, CHECK_VALID_VADDR, VM_WRITE | VM_READ);
ffffffffc020346c:	6599                	lui	a1,0x6
ffffffffc020346e:	460d                	li	a2,3
ffffffffc0203470:	6505                	lui	a0,0x1
ffffffffc0203472:	465000ef          	jal	ra,ffffffffc02040d6 <vma_create>
ffffffffc0203476:	85aa                	mv	a1,a0
     assert(vma != NULL);
ffffffffc0203478:	50050063          	beqz	a0,ffffffffc0203978 <swap_init+0x628>

     insert_vma_struct(mm, vma);
ffffffffc020347c:	855e                	mv	a0,s7
ffffffffc020347e:	4c5000ef          	jal	ra,ffffffffc0204142 <insert_vma_struct>

     //setup the temp Page Table vaddr 0~4MB
     cprintf("setup Page Table for vaddr 0X1000, so alloc a page\n");
ffffffffc0203482:	00004517          	auipc	a0,0x4
ffffffffc0203486:	6ce50513          	addi	a0,a0,1742 # ffffffffc0207b50 <default_pmm_manager+0x838>
ffffffffc020348a:	d05fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     pte_t *temp_ptep=NULL;
     temp_ptep = get_pte(mm->pgdir, BEING_CHECK_VALID_VADDR, 1);
ffffffffc020348e:	018bb503          	ld	a0,24(s7)
ffffffffc0203492:	4605                	li	a2,1
ffffffffc0203494:	6585                	lui	a1,0x1
ffffffffc0203496:	a9dfe0ef          	jal	ra,ffffffffc0201f32 <get_pte>
     assert(temp_ptep!= NULL);
ffffffffc020349a:	4e050f63          	beqz	a0,ffffffffc0203998 <swap_init+0x648>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc020349e:	00004517          	auipc	a0,0x4
ffffffffc02034a2:	70250513          	addi	a0,a0,1794 # ffffffffc0207ba0 <default_pmm_manager+0x888>
ffffffffc02034a6:	000a9997          	auipc	s3,0xa9
ffffffffc02034aa:	43298993          	addi	s3,s3,1074 # ffffffffc02ac8d8 <check_rp>
ffffffffc02034ae:	ce1fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02034b2:	000a9a17          	auipc	s4,0xa9
ffffffffc02034b6:	446a0a13          	addi	s4,s4,1094 # ffffffffc02ac8f8 <swap_in_seq_no>
     cprintf("setup Page Table vaddr 0~4MB OVER!\n");
ffffffffc02034ba:	8c4e                	mv	s8,s3
          check_rp[i] = alloc_page();
ffffffffc02034bc:	4505                	li	a0,1
ffffffffc02034be:	967fe0ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc02034c2:	00ac3023          	sd	a0,0(s8)
          assert(check_rp[i] != NULL );
ffffffffc02034c6:	32050d63          	beqz	a0,ffffffffc0203800 <swap_init+0x4b0>
ffffffffc02034ca:	651c                	ld	a5,8(a0)
          assert(!PageProperty(check_rp[i]));
ffffffffc02034cc:	8b89                	andi	a5,a5,2
ffffffffc02034ce:	30079963          	bnez	a5,ffffffffc02037e0 <swap_init+0x490>
ffffffffc02034d2:	0c21                	addi	s8,s8,8
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02034d4:	ff4c14e3          	bne	s8,s4,ffffffffc02034bc <swap_init+0x16c>
     }
     list_entry_t free_list_store = free_list;
ffffffffc02034d8:	601c                	ld	a5,0(s0)
     assert(list_empty(&free_list));
     
     //assert(alloc_page() == NULL);
     
     unsigned int nr_free_store = nr_free;
     nr_free = 0;
ffffffffc02034da:	000a9c17          	auipc	s8,0xa9
ffffffffc02034de:	3fec0c13          	addi	s8,s8,1022 # ffffffffc02ac8d8 <check_rp>
     list_entry_t free_list_store = free_list;
ffffffffc02034e2:	ec3e                	sd	a5,24(sp)
ffffffffc02034e4:	641c                	ld	a5,8(s0)
ffffffffc02034e6:	f03e                	sd	a5,32(sp)
     unsigned int nr_free_store = nr_free;
ffffffffc02034e8:	481c                	lw	a5,16(s0)
ffffffffc02034ea:	f43e                	sd	a5,40(sp)
    elm->prev = elm->next = elm;
ffffffffc02034ec:	000a9797          	auipc	a5,0xa9
ffffffffc02034f0:	3a87be23          	sd	s0,956(a5) # ffffffffc02ac8a8 <free_area+0x8>
ffffffffc02034f4:	000a9797          	auipc	a5,0xa9
ffffffffc02034f8:	3a87b623          	sd	s0,940(a5) # ffffffffc02ac8a0 <free_area>
     nr_free = 0;
ffffffffc02034fc:	000a9797          	auipc	a5,0xa9
ffffffffc0203500:	3a07aa23          	sw	zero,948(a5) # ffffffffc02ac8b0 <free_area+0x10>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
        free_pages(check_rp[i],1);
ffffffffc0203504:	000c3503          	ld	a0,0(s8)
ffffffffc0203508:	4585                	li	a1,1
ffffffffc020350a:	0c21                	addi	s8,s8,8
ffffffffc020350c:	9a1fe0ef          	jal	ra,ffffffffc0201eac <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203510:	ff4c1ae3          	bne	s8,s4,ffffffffc0203504 <swap_init+0x1b4>
     }
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203514:	01042c03          	lw	s8,16(s0)
ffffffffc0203518:	4791                	li	a5,4
ffffffffc020351a:	50fc1b63          	bne	s8,a5,ffffffffc0203a30 <swap_init+0x6e0>
     
     cprintf("set up init env for check_swap begin!\n");
ffffffffc020351e:	00004517          	auipc	a0,0x4
ffffffffc0203522:	70a50513          	addi	a0,a0,1802 # ffffffffc0207c28 <default_pmm_manager+0x910>
ffffffffc0203526:	c69fc0ef          	jal	ra,ffffffffc020018e <cprintf>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020352a:	6685                	lui	a3,0x1
     //setup initial vir_page<->phy_page environment for page relpacement algorithm 

     
     pgfault_num=0;
ffffffffc020352c:	000a9797          	auipc	a5,0xa9
ffffffffc0203530:	3407a423          	sw	zero,840(a5) # ffffffffc02ac874 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203534:	4629                	li	a2,10
     pgfault_num=0;
ffffffffc0203536:	000a9797          	auipc	a5,0xa9
ffffffffc020353a:	33e78793          	addi	a5,a5,830 # ffffffffc02ac874 <pgfault_num>
     *(unsigned char *)0x1000 = 0x0a;
ffffffffc020353e:	00c68023          	sb	a2,0(a3) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>
     assert(pgfault_num==1);
ffffffffc0203542:	4398                	lw	a4,0(a5)
ffffffffc0203544:	4585                	li	a1,1
ffffffffc0203546:	2701                	sext.w	a4,a4
ffffffffc0203548:	38b71863          	bne	a4,a1,ffffffffc02038d8 <swap_init+0x588>
     *(unsigned char *)0x1010 = 0x0a;
ffffffffc020354c:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==1);
ffffffffc0203550:	4394                	lw	a3,0(a5)
ffffffffc0203552:	2681                	sext.w	a3,a3
ffffffffc0203554:	3ae69263          	bne	a3,a4,ffffffffc02038f8 <swap_init+0x5a8>
     *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203558:	6689                	lui	a3,0x2
ffffffffc020355a:	462d                	li	a2,11
ffffffffc020355c:	00c68023          	sb	a2,0(a3) # 2000 <_binary_obj___user_faultread_out_size-0x75c8>
     assert(pgfault_num==2);
ffffffffc0203560:	4398                	lw	a4,0(a5)
ffffffffc0203562:	4589                	li	a1,2
ffffffffc0203564:	2701                	sext.w	a4,a4
ffffffffc0203566:	2eb71963          	bne	a4,a1,ffffffffc0203858 <swap_init+0x508>
     *(unsigned char *)0x2010 = 0x0b;
ffffffffc020356a:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==2);
ffffffffc020356e:	4394                	lw	a3,0(a5)
ffffffffc0203570:	2681                	sext.w	a3,a3
ffffffffc0203572:	30e69363          	bne	a3,a4,ffffffffc0203878 <swap_init+0x528>
     *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203576:	668d                	lui	a3,0x3
ffffffffc0203578:	4631                	li	a2,12
ffffffffc020357a:	00c68023          	sb	a2,0(a3) # 3000 <_binary_obj___user_faultread_out_size-0x65c8>
     assert(pgfault_num==3);
ffffffffc020357e:	4398                	lw	a4,0(a5)
ffffffffc0203580:	458d                	li	a1,3
ffffffffc0203582:	2701                	sext.w	a4,a4
ffffffffc0203584:	30b71a63          	bne	a4,a1,ffffffffc0203898 <swap_init+0x548>
     *(unsigned char *)0x3010 = 0x0c;
ffffffffc0203588:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==3);
ffffffffc020358c:	4394                	lw	a3,0(a5)
ffffffffc020358e:	2681                	sext.w	a3,a3
ffffffffc0203590:	32e69463          	bne	a3,a4,ffffffffc02038b8 <swap_init+0x568>
     *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203594:	6691                	lui	a3,0x4
ffffffffc0203596:	4635                	li	a2,13
ffffffffc0203598:	00c68023          	sb	a2,0(a3) # 4000 <_binary_obj___user_faultread_out_size-0x55c8>
     assert(pgfault_num==4);
ffffffffc020359c:	4398                	lw	a4,0(a5)
ffffffffc020359e:	2701                	sext.w	a4,a4
ffffffffc02035a0:	37871c63          	bne	a4,s8,ffffffffc0203918 <swap_init+0x5c8>
     *(unsigned char *)0x4010 = 0x0d;
ffffffffc02035a4:	00c68823          	sb	a2,16(a3)
     assert(pgfault_num==4);
ffffffffc02035a8:	439c                	lw	a5,0(a5)
ffffffffc02035aa:	2781                	sext.w	a5,a5
ffffffffc02035ac:	38e79663          	bne	a5,a4,ffffffffc0203938 <swap_init+0x5e8>
     
     check_content_set();
     assert( nr_free == 0);         
ffffffffc02035b0:	481c                	lw	a5,16(s0)
ffffffffc02035b2:	40079363          	bnez	a5,ffffffffc02039b8 <swap_init+0x668>
ffffffffc02035b6:	000a9797          	auipc	a5,0xa9
ffffffffc02035ba:	34278793          	addi	a5,a5,834 # ffffffffc02ac8f8 <swap_in_seq_no>
ffffffffc02035be:	000a9717          	auipc	a4,0xa9
ffffffffc02035c2:	36270713          	addi	a4,a4,866 # ffffffffc02ac920 <swap_out_seq_no>
ffffffffc02035c6:	000a9617          	auipc	a2,0xa9
ffffffffc02035ca:	35a60613          	addi	a2,a2,858 # ffffffffc02ac920 <swap_out_seq_no>
     for(i = 0; i<MAX_SEQ_NO ; i++) 
         swap_out_seq_no[i]=swap_in_seq_no[i]=-1;
ffffffffc02035ce:	56fd                	li	a3,-1
ffffffffc02035d0:	c394                	sw	a3,0(a5)
ffffffffc02035d2:	c314                	sw	a3,0(a4)
ffffffffc02035d4:	0791                	addi	a5,a5,4
ffffffffc02035d6:	0711                	addi	a4,a4,4
     for(i = 0; i<MAX_SEQ_NO ; i++) 
ffffffffc02035d8:	fef61ce3          	bne	a2,a5,ffffffffc02035d0 <swap_init+0x280>
ffffffffc02035dc:	000a9697          	auipc	a3,0xa9
ffffffffc02035e0:	3a468693          	addi	a3,a3,932 # ffffffffc02ac980 <check_ptep>
ffffffffc02035e4:	000a9817          	auipc	a6,0xa9
ffffffffc02035e8:	2f480813          	addi	a6,a6,756 # ffffffffc02ac8d8 <check_rp>
ffffffffc02035ec:	6d05                	lui	s10,0x1
    if (PPN(pa) >= npage) {
ffffffffc02035ee:	000a9c97          	auipc	s9,0xa9
ffffffffc02035f2:	272c8c93          	addi	s9,s9,626 # ffffffffc02ac860 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02035f6:	00005d97          	auipc	s11,0x5
ffffffffc02035fa:	6c2d8d93          	addi	s11,s11,1730 # ffffffffc0208cb8 <nbase>
ffffffffc02035fe:	000a9c17          	auipc	s8,0xa9
ffffffffc0203602:	2d2c0c13          	addi	s8,s8,722 # ffffffffc02ac8d0 <pages>
     
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         check_ptep[i]=0;
ffffffffc0203606:	0006b023          	sd	zero,0(a3)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020360a:	4601                	li	a2,0
ffffffffc020360c:	85ea                	mv	a1,s10
ffffffffc020360e:	855a                	mv	a0,s6
ffffffffc0203610:	e842                	sd	a6,16(sp)
         check_ptep[i]=0;
ffffffffc0203612:	e436                	sd	a3,8(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc0203614:	91ffe0ef          	jal	ra,ffffffffc0201f32 <get_pte>
ffffffffc0203618:	66a2                	ld	a3,8(sp)
         //cprintf("i %d, check_ptep addr %x, value %x\n", i, check_ptep[i], *check_ptep[i]);
         assert(check_ptep[i] != NULL);
ffffffffc020361a:	6842                	ld	a6,16(sp)
         check_ptep[i] = get_pte(pgdir, (i+1)*0x1000, 0);
ffffffffc020361c:	e288                	sd	a0,0(a3)
         assert(check_ptep[i] != NULL);
ffffffffc020361e:	20050163          	beqz	a0,ffffffffc0203820 <swap_init+0x4d0>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc0203622:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V)) {
ffffffffc0203624:	0017f613          	andi	a2,a5,1
ffffffffc0203628:	1a060063          	beqz	a2,ffffffffc02037c8 <swap_init+0x478>
    if (PPN(pa) >= npage) {
ffffffffc020362c:	000cb603          	ld	a2,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203630:	078a                	slli	a5,a5,0x2
ffffffffc0203632:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203634:	14c7fe63          	bgeu	a5,a2,ffffffffc0203790 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203638:	000db703          	ld	a4,0(s11)
ffffffffc020363c:	000c3603          	ld	a2,0(s8)
ffffffffc0203640:	00083583          	ld	a1,0(a6)
ffffffffc0203644:	8f99                	sub	a5,a5,a4
ffffffffc0203646:	079a                	slli	a5,a5,0x6
ffffffffc0203648:	e43a                	sd	a4,8(sp)
ffffffffc020364a:	97b2                	add	a5,a5,a2
ffffffffc020364c:	14f59e63          	bne	a1,a5,ffffffffc02037a8 <swap_init+0x458>
ffffffffc0203650:	6785                	lui	a5,0x1
ffffffffc0203652:	9d3e                	add	s10,s10,a5
     for (i= 0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc0203654:	6795                	lui	a5,0x5
ffffffffc0203656:	06a1                	addi	a3,a3,8
ffffffffc0203658:	0821                	addi	a6,a6,8
ffffffffc020365a:	fafd16e3          	bne	s10,a5,ffffffffc0203606 <swap_init+0x2b6>
         assert((*check_ptep[i] & PTE_V));          
     }
     cprintf("set up init env for check_swap over!\n");
ffffffffc020365e:	00004517          	auipc	a0,0x4
ffffffffc0203662:	67250513          	addi	a0,a0,1650 # ffffffffc0207cd0 <default_pmm_manager+0x9b8>
ffffffffc0203666:	b29fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = sm->check_swap();
ffffffffc020366a:	000a9797          	auipc	a5,0xa9
ffffffffc020366e:	1fe78793          	addi	a5,a5,510 # ffffffffc02ac868 <sm>
ffffffffc0203672:	639c                	ld	a5,0(a5)
ffffffffc0203674:	7f9c                	ld	a5,56(a5)
ffffffffc0203676:	9782                	jalr	a5
     // now access the virt pages to test  page relpacement algorithm 
     ret=check_content_access();
     assert(ret==0);
ffffffffc0203678:	40051c63          	bnez	a0,ffffffffc0203a90 <swap_init+0x740>

     nr_free = nr_free_store;
ffffffffc020367c:	77a2                	ld	a5,40(sp)
ffffffffc020367e:	000a9717          	auipc	a4,0xa9
ffffffffc0203682:	22f72923          	sw	a5,562(a4) # ffffffffc02ac8b0 <free_area+0x10>
     free_list = free_list_store;
ffffffffc0203686:	67e2                	ld	a5,24(sp)
ffffffffc0203688:	000a9717          	auipc	a4,0xa9
ffffffffc020368c:	20f73c23          	sd	a5,536(a4) # ffffffffc02ac8a0 <free_area>
ffffffffc0203690:	7782                	ld	a5,32(sp)
ffffffffc0203692:	000a9717          	auipc	a4,0xa9
ffffffffc0203696:	20f73b23          	sd	a5,534(a4) # ffffffffc02ac8a8 <free_area+0x8>

     //restore kernel mem env
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
         free_pages(check_rp[i],1);
ffffffffc020369a:	0009b503          	ld	a0,0(s3)
ffffffffc020369e:	4585                	li	a1,1
ffffffffc02036a0:	09a1                	addi	s3,s3,8
ffffffffc02036a2:	80bfe0ef          	jal	ra,ffffffffc0201eac <free_pages>
     for (i=0;i<CHECK_VALID_PHY_PAGE_NUM;i++) {
ffffffffc02036a6:	ff499ae3          	bne	s3,s4,ffffffffc020369a <swap_init+0x34a>
     } 

     //free_page(pte2page(*temp_ptep));

     mm->pgdir = NULL;
ffffffffc02036aa:	000bbc23          	sd	zero,24(s7)
     mm_destroy(mm);
ffffffffc02036ae:	855e                	mv	a0,s7
ffffffffc02036b0:	361000ef          	jal	ra,ffffffffc0204210 <mm_destroy>
     check_mm_struct = NULL;

     pde_t *pd1=pgdir,*pd0=page2kva(pde2page(boot_pgdir[0]));
ffffffffc02036b4:	000a9797          	auipc	a5,0xa9
ffffffffc02036b8:	1a478793          	addi	a5,a5,420 # ffffffffc02ac858 <boot_pgdir>
ffffffffc02036bc:	639c                	ld	a5,0(a5)
     check_mm_struct = NULL;
ffffffffc02036be:	000a9697          	auipc	a3,0xa9
ffffffffc02036c2:	2e06b923          	sd	zero,754(a3) # ffffffffc02ac9b0 <check_mm_struct>
    if (PPN(pa) >= npage) {
ffffffffc02036c6:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc02036ca:	6394                	ld	a3,0(a5)
ffffffffc02036cc:	068a                	slli	a3,a3,0x2
ffffffffc02036ce:	82b1                	srli	a3,a3,0xc
    if (PPN(pa) >= npage) {
ffffffffc02036d0:	0ce6f063          	bgeu	a3,a4,ffffffffc0203790 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc02036d4:	67a2                	ld	a5,8(sp)
ffffffffc02036d6:	000c3503          	ld	a0,0(s8)
ffffffffc02036da:	8e9d                	sub	a3,a3,a5
ffffffffc02036dc:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc02036de:	8699                	srai	a3,a3,0x6
ffffffffc02036e0:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc02036e2:	00c69793          	slli	a5,a3,0xc
ffffffffc02036e6:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02036e8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02036ea:	2ee7f763          	bgeu	a5,a4,ffffffffc02039d8 <swap_init+0x688>
     free_page(pde2page(pd0[0]));
ffffffffc02036ee:	000a9797          	auipc	a5,0xa9
ffffffffc02036f2:	1d278793          	addi	a5,a5,466 # ffffffffc02ac8c0 <va_pa_offset>
ffffffffc02036f6:	639c                	ld	a5,0(a5)
ffffffffc02036f8:	96be                	add	a3,a3,a5
    return pa2page(PDE_ADDR(pde));
ffffffffc02036fa:	629c                	ld	a5,0(a3)
ffffffffc02036fc:	078a                	slli	a5,a5,0x2
ffffffffc02036fe:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203700:	08e7f863          	bgeu	a5,a4,ffffffffc0203790 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203704:	69a2                	ld	s3,8(sp)
ffffffffc0203706:	4585                	li	a1,1
ffffffffc0203708:	413787b3          	sub	a5,a5,s3
ffffffffc020370c:	079a                	slli	a5,a5,0x6
ffffffffc020370e:	953e                	add	a0,a0,a5
ffffffffc0203710:	f9cfe0ef          	jal	ra,ffffffffc0201eac <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc0203714:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage) {
ffffffffc0203718:	000cb703          	ld	a4,0(s9)
    return pa2page(PDE_ADDR(pde));
ffffffffc020371c:	078a                	slli	a5,a5,0x2
ffffffffc020371e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0203720:	06e7f863          	bgeu	a5,a4,ffffffffc0203790 <swap_init+0x440>
    return &pages[PPN(pa) - nbase];
ffffffffc0203724:	000c3503          	ld	a0,0(s8)
ffffffffc0203728:	413787b3          	sub	a5,a5,s3
ffffffffc020372c:	079a                	slli	a5,a5,0x6
     free_page(pde2page(pd1[0]));
ffffffffc020372e:	4585                	li	a1,1
ffffffffc0203730:	953e                	add	a0,a0,a5
ffffffffc0203732:	f7afe0ef          	jal	ra,ffffffffc0201eac <free_pages>
     pgdir[0] = 0;
ffffffffc0203736:	000b3023          	sd	zero,0(s6)
  asm volatile("sfence.vma");
ffffffffc020373a:	12000073          	sfence.vma
    return listelm->next;
ffffffffc020373e:	641c                	ld	a5,8(s0)
     flush_tlb();

     le = &free_list;
     while ((le = list_next(le)) != &free_list) {
ffffffffc0203740:	00878963          	beq	a5,s0,ffffffffc0203752 <swap_init+0x402>
         struct Page *p = le2page(le, page_link);
         count --, total -= p->property;
ffffffffc0203744:	ff87a703          	lw	a4,-8(a5)
ffffffffc0203748:	679c                	ld	a5,8(a5)
ffffffffc020374a:	397d                	addiw	s2,s2,-1
ffffffffc020374c:	9c99                	subw	s1,s1,a4
     while ((le = list_next(le)) != &free_list) {
ffffffffc020374e:	fe879be3          	bne	a5,s0,ffffffffc0203744 <swap_init+0x3f4>
     }
     assert(count==0);
ffffffffc0203752:	28091f63          	bnez	s2,ffffffffc02039f0 <swap_init+0x6a0>
     assert(total==0);
ffffffffc0203756:	2a049d63          	bnez	s1,ffffffffc0203a10 <swap_init+0x6c0>

     cprintf("check_swap() succeeded!\n");
ffffffffc020375a:	00004517          	auipc	a0,0x4
ffffffffc020375e:	5c650513          	addi	a0,a0,1478 # ffffffffc0207d20 <default_pmm_manager+0xa08>
ffffffffc0203762:	a2dfc0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0203766:	b92d                	j	ffffffffc02033a0 <swap_init+0x50>
     int ret, count = 0, total = 0, i;
ffffffffc0203768:	4481                	li	s1,0
ffffffffc020376a:	4901                	li	s2,0
     while ((le = list_next(le)) != &free_list) {
ffffffffc020376c:	4981                	li	s3,0
ffffffffc020376e:	b17d                	j	ffffffffc020341c <swap_init+0xcc>
        assert(PageProperty(p));
ffffffffc0203770:	00004697          	auipc	a3,0x4
ffffffffc0203774:	81868693          	addi	a3,a3,-2024 # ffffffffc0206f88 <commands+0x878>
ffffffffc0203778:	00003617          	auipc	a2,0x3
ffffffffc020377c:	45860613          	addi	a2,a2,1112 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203780:	0bc00593          	li	a1,188
ffffffffc0203784:	00004517          	auipc	a0,0x4
ffffffffc0203788:	33450513          	addi	a0,a0,820 # ffffffffc0207ab8 <default_pmm_manager+0x7a0>
ffffffffc020378c:	cf5fc0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203790:	00004617          	auipc	a2,0x4
ffffffffc0203794:	c3860613          	addi	a2,a2,-968 # ffffffffc02073c8 <default_pmm_manager+0xb0>
ffffffffc0203798:	06200593          	li	a1,98
ffffffffc020379c:	00004517          	auipc	a0,0x4
ffffffffc02037a0:	bf450513          	addi	a0,a0,-1036 # ffffffffc0207390 <default_pmm_manager+0x78>
ffffffffc02037a4:	cddfc0ef          	jal	ra,ffffffffc0200480 <__panic>
         assert(pte2page(*check_ptep[i]) == check_rp[i]);
ffffffffc02037a8:	00004697          	auipc	a3,0x4
ffffffffc02037ac:	50068693          	addi	a3,a3,1280 # ffffffffc0207ca8 <default_pmm_manager+0x990>
ffffffffc02037b0:	00003617          	auipc	a2,0x3
ffffffffc02037b4:	42060613          	addi	a2,a2,1056 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02037b8:	0fc00593          	li	a1,252
ffffffffc02037bc:	00004517          	auipc	a0,0x4
ffffffffc02037c0:	2fc50513          	addi	a0,a0,764 # ffffffffc0207ab8 <default_pmm_manager+0x7a0>
ffffffffc02037c4:	cbdfc0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc02037c8:	00004617          	auipc	a2,0x4
ffffffffc02037cc:	e5860613          	addi	a2,a2,-424 # ffffffffc0207620 <default_pmm_manager+0x308>
ffffffffc02037d0:	07400593          	li	a1,116
ffffffffc02037d4:	00004517          	auipc	a0,0x4
ffffffffc02037d8:	bbc50513          	addi	a0,a0,-1092 # ffffffffc0207390 <default_pmm_manager+0x78>
ffffffffc02037dc:	ca5fc0ef          	jal	ra,ffffffffc0200480 <__panic>
          assert(!PageProperty(check_rp[i]));
ffffffffc02037e0:	00004697          	auipc	a3,0x4
ffffffffc02037e4:	40068693          	addi	a3,a3,1024 # ffffffffc0207be0 <default_pmm_manager+0x8c8>
ffffffffc02037e8:	00003617          	auipc	a2,0x3
ffffffffc02037ec:	3e860613          	addi	a2,a2,1000 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02037f0:	0dd00593          	li	a1,221
ffffffffc02037f4:	00004517          	auipc	a0,0x4
ffffffffc02037f8:	2c450513          	addi	a0,a0,708 # ffffffffc0207ab8 <default_pmm_manager+0x7a0>
ffffffffc02037fc:	c85fc0ef          	jal	ra,ffffffffc0200480 <__panic>
          assert(check_rp[i] != NULL );
ffffffffc0203800:	00004697          	auipc	a3,0x4
ffffffffc0203804:	3c868693          	addi	a3,a3,968 # ffffffffc0207bc8 <default_pmm_manager+0x8b0>
ffffffffc0203808:	00003617          	auipc	a2,0x3
ffffffffc020380c:	3c860613          	addi	a2,a2,968 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203810:	0dc00593          	li	a1,220
ffffffffc0203814:	00004517          	auipc	a0,0x4
ffffffffc0203818:	2a450513          	addi	a0,a0,676 # ffffffffc0207ab8 <default_pmm_manager+0x7a0>
ffffffffc020381c:	c65fc0ef          	jal	ra,ffffffffc0200480 <__panic>
         assert(check_ptep[i] != NULL);
ffffffffc0203820:	00004697          	auipc	a3,0x4
ffffffffc0203824:	47068693          	addi	a3,a3,1136 # ffffffffc0207c90 <default_pmm_manager+0x978>
ffffffffc0203828:	00003617          	auipc	a2,0x3
ffffffffc020382c:	3a860613          	addi	a2,a2,936 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203830:	0fb00593          	li	a1,251
ffffffffc0203834:	00004517          	auipc	a0,0x4
ffffffffc0203838:	28450513          	addi	a0,a0,644 # ffffffffc0207ab8 <default_pmm_manager+0x7a0>
ffffffffc020383c:	c45fc0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("bad max_swap_offset %08x.\n", max_swap_offset);
ffffffffc0203840:	00004617          	auipc	a2,0x4
ffffffffc0203844:	25860613          	addi	a2,a2,600 # ffffffffc0207a98 <default_pmm_manager+0x780>
ffffffffc0203848:	02800593          	li	a1,40
ffffffffc020384c:	00004517          	auipc	a0,0x4
ffffffffc0203850:	26c50513          	addi	a0,a0,620 # ffffffffc0207ab8 <default_pmm_manager+0x7a0>
ffffffffc0203854:	c2dfc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==2);
ffffffffc0203858:	00004697          	auipc	a3,0x4
ffffffffc020385c:	40868693          	addi	a3,a3,1032 # ffffffffc0207c60 <default_pmm_manager+0x948>
ffffffffc0203860:	00003617          	auipc	a2,0x3
ffffffffc0203864:	37060613          	addi	a2,a2,880 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203868:	09700593          	li	a1,151
ffffffffc020386c:	00004517          	auipc	a0,0x4
ffffffffc0203870:	24c50513          	addi	a0,a0,588 # ffffffffc0207ab8 <default_pmm_manager+0x7a0>
ffffffffc0203874:	c0dfc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==2);
ffffffffc0203878:	00004697          	auipc	a3,0x4
ffffffffc020387c:	3e868693          	addi	a3,a3,1000 # ffffffffc0207c60 <default_pmm_manager+0x948>
ffffffffc0203880:	00003617          	auipc	a2,0x3
ffffffffc0203884:	35060613          	addi	a2,a2,848 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203888:	09900593          	li	a1,153
ffffffffc020388c:	00004517          	auipc	a0,0x4
ffffffffc0203890:	22c50513          	addi	a0,a0,556 # ffffffffc0207ab8 <default_pmm_manager+0x7a0>
ffffffffc0203894:	bedfc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==3);
ffffffffc0203898:	00004697          	auipc	a3,0x4
ffffffffc020389c:	3d868693          	addi	a3,a3,984 # ffffffffc0207c70 <default_pmm_manager+0x958>
ffffffffc02038a0:	00003617          	auipc	a2,0x3
ffffffffc02038a4:	33060613          	addi	a2,a2,816 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02038a8:	09b00593          	li	a1,155
ffffffffc02038ac:	00004517          	auipc	a0,0x4
ffffffffc02038b0:	20c50513          	addi	a0,a0,524 # ffffffffc0207ab8 <default_pmm_manager+0x7a0>
ffffffffc02038b4:	bcdfc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==3);
ffffffffc02038b8:	00004697          	auipc	a3,0x4
ffffffffc02038bc:	3b868693          	addi	a3,a3,952 # ffffffffc0207c70 <default_pmm_manager+0x958>
ffffffffc02038c0:	00003617          	auipc	a2,0x3
ffffffffc02038c4:	31060613          	addi	a2,a2,784 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02038c8:	09d00593          	li	a1,157
ffffffffc02038cc:	00004517          	auipc	a0,0x4
ffffffffc02038d0:	1ec50513          	addi	a0,a0,492 # ffffffffc0207ab8 <default_pmm_manager+0x7a0>
ffffffffc02038d4:	badfc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==1);
ffffffffc02038d8:	00004697          	auipc	a3,0x4
ffffffffc02038dc:	37868693          	addi	a3,a3,888 # ffffffffc0207c50 <default_pmm_manager+0x938>
ffffffffc02038e0:	00003617          	auipc	a2,0x3
ffffffffc02038e4:	2f060613          	addi	a2,a2,752 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02038e8:	09300593          	li	a1,147
ffffffffc02038ec:	00004517          	auipc	a0,0x4
ffffffffc02038f0:	1cc50513          	addi	a0,a0,460 # ffffffffc0207ab8 <default_pmm_manager+0x7a0>
ffffffffc02038f4:	b8dfc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==1);
ffffffffc02038f8:	00004697          	auipc	a3,0x4
ffffffffc02038fc:	35868693          	addi	a3,a3,856 # ffffffffc0207c50 <default_pmm_manager+0x938>
ffffffffc0203900:	00003617          	auipc	a2,0x3
ffffffffc0203904:	2d060613          	addi	a2,a2,720 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203908:	09500593          	li	a1,149
ffffffffc020390c:	00004517          	auipc	a0,0x4
ffffffffc0203910:	1ac50513          	addi	a0,a0,428 # ffffffffc0207ab8 <default_pmm_manager+0x7a0>
ffffffffc0203914:	b6dfc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==4);
ffffffffc0203918:	00004697          	auipc	a3,0x4
ffffffffc020391c:	36868693          	addi	a3,a3,872 # ffffffffc0207c80 <default_pmm_manager+0x968>
ffffffffc0203920:	00003617          	auipc	a2,0x3
ffffffffc0203924:	2b060613          	addi	a2,a2,688 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203928:	09f00593          	li	a1,159
ffffffffc020392c:	00004517          	auipc	a0,0x4
ffffffffc0203930:	18c50513          	addi	a0,a0,396 # ffffffffc0207ab8 <default_pmm_manager+0x7a0>
ffffffffc0203934:	b4dfc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgfault_num==4);
ffffffffc0203938:	00004697          	auipc	a3,0x4
ffffffffc020393c:	34868693          	addi	a3,a3,840 # ffffffffc0207c80 <default_pmm_manager+0x968>
ffffffffc0203940:	00003617          	auipc	a2,0x3
ffffffffc0203944:	29060613          	addi	a2,a2,656 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203948:	0a100593          	li	a1,161
ffffffffc020394c:	00004517          	auipc	a0,0x4
ffffffffc0203950:	16c50513          	addi	a0,a0,364 # ffffffffc0207ab8 <default_pmm_manager+0x7a0>
ffffffffc0203954:	b2dfc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(pgdir[0] == 0);
ffffffffc0203958:	00004697          	auipc	a3,0x4
ffffffffc020395c:	1d868693          	addi	a3,a3,472 # ffffffffc0207b30 <default_pmm_manager+0x818>
ffffffffc0203960:	00003617          	auipc	a2,0x3
ffffffffc0203964:	27060613          	addi	a2,a2,624 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203968:	0cc00593          	li	a1,204
ffffffffc020396c:	00004517          	auipc	a0,0x4
ffffffffc0203970:	14c50513          	addi	a0,a0,332 # ffffffffc0207ab8 <default_pmm_manager+0x7a0>
ffffffffc0203974:	b0dfc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(vma != NULL);
ffffffffc0203978:	00004697          	auipc	a3,0x4
ffffffffc020397c:	1c868693          	addi	a3,a3,456 # ffffffffc0207b40 <default_pmm_manager+0x828>
ffffffffc0203980:	00003617          	auipc	a2,0x3
ffffffffc0203984:	25060613          	addi	a2,a2,592 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203988:	0cf00593          	li	a1,207
ffffffffc020398c:	00004517          	auipc	a0,0x4
ffffffffc0203990:	12c50513          	addi	a0,a0,300 # ffffffffc0207ab8 <default_pmm_manager+0x7a0>
ffffffffc0203994:	aedfc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(temp_ptep!= NULL);
ffffffffc0203998:	00004697          	auipc	a3,0x4
ffffffffc020399c:	1f068693          	addi	a3,a3,496 # ffffffffc0207b88 <default_pmm_manager+0x870>
ffffffffc02039a0:	00003617          	auipc	a2,0x3
ffffffffc02039a4:	23060613          	addi	a2,a2,560 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02039a8:	0d700593          	li	a1,215
ffffffffc02039ac:	00004517          	auipc	a0,0x4
ffffffffc02039b0:	10c50513          	addi	a0,a0,268 # ffffffffc0207ab8 <default_pmm_manager+0x7a0>
ffffffffc02039b4:	acdfc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert( nr_free == 0);         
ffffffffc02039b8:	00003697          	auipc	a3,0x3
ffffffffc02039bc:	7a068693          	addi	a3,a3,1952 # ffffffffc0207158 <commands+0xa48>
ffffffffc02039c0:	00003617          	auipc	a2,0x3
ffffffffc02039c4:	21060613          	addi	a2,a2,528 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02039c8:	0f300593          	li	a1,243
ffffffffc02039cc:	00004517          	auipc	a0,0x4
ffffffffc02039d0:	0ec50513          	addi	a0,a0,236 # ffffffffc0207ab8 <default_pmm_manager+0x7a0>
ffffffffc02039d4:	aadfc0ef          	jal	ra,ffffffffc0200480 <__panic>
    return KADDR(page2pa(page));
ffffffffc02039d8:	00004617          	auipc	a2,0x4
ffffffffc02039dc:	99060613          	addi	a2,a2,-1648 # ffffffffc0207368 <default_pmm_manager+0x50>
ffffffffc02039e0:	06900593          	li	a1,105
ffffffffc02039e4:	00004517          	auipc	a0,0x4
ffffffffc02039e8:	9ac50513          	addi	a0,a0,-1620 # ffffffffc0207390 <default_pmm_manager+0x78>
ffffffffc02039ec:	a95fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(count==0);
ffffffffc02039f0:	00004697          	auipc	a3,0x4
ffffffffc02039f4:	31068693          	addi	a3,a3,784 # ffffffffc0207d00 <default_pmm_manager+0x9e8>
ffffffffc02039f8:	00003617          	auipc	a2,0x3
ffffffffc02039fc:	1d860613          	addi	a2,a2,472 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203a00:	11d00593          	li	a1,285
ffffffffc0203a04:	00004517          	auipc	a0,0x4
ffffffffc0203a08:	0b450513          	addi	a0,a0,180 # ffffffffc0207ab8 <default_pmm_manager+0x7a0>
ffffffffc0203a0c:	a75fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(total==0);
ffffffffc0203a10:	00004697          	auipc	a3,0x4
ffffffffc0203a14:	30068693          	addi	a3,a3,768 # ffffffffc0207d10 <default_pmm_manager+0x9f8>
ffffffffc0203a18:	00003617          	auipc	a2,0x3
ffffffffc0203a1c:	1b860613          	addi	a2,a2,440 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203a20:	11e00593          	li	a1,286
ffffffffc0203a24:	00004517          	auipc	a0,0x4
ffffffffc0203a28:	09450513          	addi	a0,a0,148 # ffffffffc0207ab8 <default_pmm_manager+0x7a0>
ffffffffc0203a2c:	a55fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(nr_free==CHECK_VALID_PHY_PAGE_NUM);
ffffffffc0203a30:	00004697          	auipc	a3,0x4
ffffffffc0203a34:	1d068693          	addi	a3,a3,464 # ffffffffc0207c00 <default_pmm_manager+0x8e8>
ffffffffc0203a38:	00003617          	auipc	a2,0x3
ffffffffc0203a3c:	19860613          	addi	a2,a2,408 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203a40:	0ea00593          	li	a1,234
ffffffffc0203a44:	00004517          	auipc	a0,0x4
ffffffffc0203a48:	07450513          	addi	a0,a0,116 # ffffffffc0207ab8 <default_pmm_manager+0x7a0>
ffffffffc0203a4c:	a35fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(mm != NULL);
ffffffffc0203a50:	00004697          	auipc	a3,0x4
ffffffffc0203a54:	0b868693          	addi	a3,a3,184 # ffffffffc0207b08 <default_pmm_manager+0x7f0>
ffffffffc0203a58:	00003617          	auipc	a2,0x3
ffffffffc0203a5c:	17860613          	addi	a2,a2,376 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203a60:	0c400593          	li	a1,196
ffffffffc0203a64:	00004517          	auipc	a0,0x4
ffffffffc0203a68:	05450513          	addi	a0,a0,84 # ffffffffc0207ab8 <default_pmm_manager+0x7a0>
ffffffffc0203a6c:	a15fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(check_mm_struct == NULL);
ffffffffc0203a70:	00004697          	auipc	a3,0x4
ffffffffc0203a74:	0a868693          	addi	a3,a3,168 # ffffffffc0207b18 <default_pmm_manager+0x800>
ffffffffc0203a78:	00003617          	auipc	a2,0x3
ffffffffc0203a7c:	15860613          	addi	a2,a2,344 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203a80:	0c700593          	li	a1,199
ffffffffc0203a84:	00004517          	auipc	a0,0x4
ffffffffc0203a88:	03450513          	addi	a0,a0,52 # ffffffffc0207ab8 <default_pmm_manager+0x7a0>
ffffffffc0203a8c:	9f5fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(ret==0);
ffffffffc0203a90:	00004697          	auipc	a3,0x4
ffffffffc0203a94:	26868693          	addi	a3,a3,616 # ffffffffc0207cf8 <default_pmm_manager+0x9e0>
ffffffffc0203a98:	00003617          	auipc	a2,0x3
ffffffffc0203a9c:	13860613          	addi	a2,a2,312 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203aa0:	10200593          	li	a1,258
ffffffffc0203aa4:	00004517          	auipc	a0,0x4
ffffffffc0203aa8:	01450513          	addi	a0,a0,20 # ffffffffc0207ab8 <default_pmm_manager+0x7a0>
ffffffffc0203aac:	9d5fc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(total == nr_free_pages());
ffffffffc0203ab0:	00003697          	auipc	a3,0x3
ffffffffc0203ab4:	50068693          	addi	a3,a3,1280 # ffffffffc0206fb0 <commands+0x8a0>
ffffffffc0203ab8:	00003617          	auipc	a2,0x3
ffffffffc0203abc:	11860613          	addi	a2,a2,280 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203ac0:	0bf00593          	li	a1,191
ffffffffc0203ac4:	00004517          	auipc	a0,0x4
ffffffffc0203ac8:	ff450513          	addi	a0,a0,-12 # ffffffffc0207ab8 <default_pmm_manager+0x7a0>
ffffffffc0203acc:	9b5fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0203ad0 <swap_init_mm>:
     return sm->init_mm(mm);
ffffffffc0203ad0:	000a9797          	auipc	a5,0xa9
ffffffffc0203ad4:	d9878793          	addi	a5,a5,-616 # ffffffffc02ac868 <sm>
ffffffffc0203ad8:	639c                	ld	a5,0(a5)
ffffffffc0203ada:	0107b303          	ld	t1,16(a5)
ffffffffc0203ade:	8302                	jr	t1

ffffffffc0203ae0 <swap_map_swappable>:
     return sm->map_swappable(mm, addr, page, swap_in);
ffffffffc0203ae0:	000a9797          	auipc	a5,0xa9
ffffffffc0203ae4:	d8878793          	addi	a5,a5,-632 # ffffffffc02ac868 <sm>
ffffffffc0203ae8:	639c                	ld	a5,0(a5)
ffffffffc0203aea:	0207b303          	ld	t1,32(a5)
ffffffffc0203aee:	8302                	jr	t1

ffffffffc0203af0 <swap_out>:
{
ffffffffc0203af0:	711d                	addi	sp,sp,-96
ffffffffc0203af2:	ec86                	sd	ra,88(sp)
ffffffffc0203af4:	e8a2                	sd	s0,80(sp)
ffffffffc0203af6:	e4a6                	sd	s1,72(sp)
ffffffffc0203af8:	e0ca                	sd	s2,64(sp)
ffffffffc0203afa:	fc4e                	sd	s3,56(sp)
ffffffffc0203afc:	f852                	sd	s4,48(sp)
ffffffffc0203afe:	f456                	sd	s5,40(sp)
ffffffffc0203b00:	f05a                	sd	s6,32(sp)
ffffffffc0203b02:	ec5e                	sd	s7,24(sp)
ffffffffc0203b04:	e862                	sd	s8,16(sp)
     for (i = 0; i != n; ++ i)
ffffffffc0203b06:	cde9                	beqz	a1,ffffffffc0203be0 <swap_out+0xf0>
ffffffffc0203b08:	8ab2                	mv	s5,a2
ffffffffc0203b0a:	892a                	mv	s2,a0
ffffffffc0203b0c:	8a2e                	mv	s4,a1
ffffffffc0203b0e:	4401                	li	s0,0
ffffffffc0203b10:	000a9997          	auipc	s3,0xa9
ffffffffc0203b14:	d5898993          	addi	s3,s3,-680 # ffffffffc02ac868 <sm>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b18:	00004b17          	auipc	s6,0x4
ffffffffc0203b1c:	288b0b13          	addi	s6,s6,648 # ffffffffc0207da0 <default_pmm_manager+0xa88>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203b20:	00004b97          	auipc	s7,0x4
ffffffffc0203b24:	268b8b93          	addi	s7,s7,616 # ffffffffc0207d88 <default_pmm_manager+0xa70>
ffffffffc0203b28:	a825                	j	ffffffffc0203b60 <swap_out+0x70>
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b2a:	67a2                	ld	a5,8(sp)
ffffffffc0203b2c:	8626                	mv	a2,s1
ffffffffc0203b2e:	85a2                	mv	a1,s0
ffffffffc0203b30:	7f94                	ld	a3,56(a5)
ffffffffc0203b32:	855a                	mv	a0,s6
     for (i = 0; i != n; ++ i)
ffffffffc0203b34:	2405                	addiw	s0,s0,1
                    cprintf("swap_out: i %d, store page in vaddr 0x%x to disk swap entry %d\n", i, v, page->pra_vaddr/PGSIZE+1);
ffffffffc0203b36:	82b1                	srli	a3,a3,0xc
ffffffffc0203b38:	0685                	addi	a3,a3,1
ffffffffc0203b3a:	e54fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203b3e:	6522                	ld	a0,8(sp)
                    free_page(page);
ffffffffc0203b40:	4585                	li	a1,1
                    *ptep = (page->pra_vaddr/PGSIZE+1)<<8;
ffffffffc0203b42:	7d1c                	ld	a5,56(a0)
ffffffffc0203b44:	83b1                	srli	a5,a5,0xc
ffffffffc0203b46:	0785                	addi	a5,a5,1
ffffffffc0203b48:	07a2                	slli	a5,a5,0x8
ffffffffc0203b4a:	00fc3023          	sd	a5,0(s8)
                    free_page(page);
ffffffffc0203b4e:	b5efe0ef          	jal	ra,ffffffffc0201eac <free_pages>
          tlb_invalidate(mm->pgdir, v);
ffffffffc0203b52:	01893503          	ld	a0,24(s2)
ffffffffc0203b56:	85a6                	mv	a1,s1
ffffffffc0203b58:	f5eff0ef          	jal	ra,ffffffffc02032b6 <tlb_invalidate>
     for (i = 0; i != n; ++ i)
ffffffffc0203b5c:	048a0d63          	beq	s4,s0,ffffffffc0203bb6 <swap_out+0xc6>
          int r = sm->swap_out_victim(mm, &page, in_tick);
ffffffffc0203b60:	0009b783          	ld	a5,0(s3)
ffffffffc0203b64:	8656                	mv	a2,s5
ffffffffc0203b66:	002c                	addi	a1,sp,8
ffffffffc0203b68:	7b9c                	ld	a5,48(a5)
ffffffffc0203b6a:	854a                	mv	a0,s2
ffffffffc0203b6c:	9782                	jalr	a5
          if (r != 0) {
ffffffffc0203b6e:	e12d                	bnez	a0,ffffffffc0203bd0 <swap_out+0xe0>
          v=page->pra_vaddr; 
ffffffffc0203b70:	67a2                	ld	a5,8(sp)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203b72:	01893503          	ld	a0,24(s2)
ffffffffc0203b76:	4601                	li	a2,0
          v=page->pra_vaddr; 
ffffffffc0203b78:	7f84                	ld	s1,56(a5)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203b7a:	85a6                	mv	a1,s1
ffffffffc0203b7c:	bb6fe0ef          	jal	ra,ffffffffc0201f32 <get_pte>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203b80:	611c                	ld	a5,0(a0)
          pte_t *ptep = get_pte(mm->pgdir, v, 0);
ffffffffc0203b82:	8c2a                	mv	s8,a0
          assert((*ptep & PTE_V) != 0);
ffffffffc0203b84:	8b85                	andi	a5,a5,1
ffffffffc0203b86:	cfb9                	beqz	a5,ffffffffc0203be4 <swap_out+0xf4>
          if (swapfs_write( (page->pra_vaddr/PGSIZE+1)<<8, page) != 0) {
ffffffffc0203b88:	65a2                	ld	a1,8(sp)
ffffffffc0203b8a:	7d9c                	ld	a5,56(a1)
ffffffffc0203b8c:	83b1                	srli	a5,a5,0xc
ffffffffc0203b8e:	00178513          	addi	a0,a5,1
ffffffffc0203b92:	0522                	slli	a0,a0,0x8
ffffffffc0203b94:	038010ef          	jal	ra,ffffffffc0204bcc <swapfs_write>
ffffffffc0203b98:	d949                	beqz	a0,ffffffffc0203b2a <swap_out+0x3a>
                    cprintf("SWAP: failed to save\n");
ffffffffc0203b9a:	855e                	mv	a0,s7
ffffffffc0203b9c:	df2fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203ba0:	0009b783          	ld	a5,0(s3)
ffffffffc0203ba4:	6622                	ld	a2,8(sp)
ffffffffc0203ba6:	4681                	li	a3,0
ffffffffc0203ba8:	739c                	ld	a5,32(a5)
ffffffffc0203baa:	85a6                	mv	a1,s1
ffffffffc0203bac:	854a                	mv	a0,s2
     for (i = 0; i != n; ++ i)
ffffffffc0203bae:	2405                	addiw	s0,s0,1
                    sm->map_swappable(mm, v, page, 0);
ffffffffc0203bb0:	9782                	jalr	a5
     for (i = 0; i != n; ++ i)
ffffffffc0203bb2:	fa8a17e3          	bne	s4,s0,ffffffffc0203b60 <swap_out+0x70>
}
ffffffffc0203bb6:	8522                	mv	a0,s0
ffffffffc0203bb8:	60e6                	ld	ra,88(sp)
ffffffffc0203bba:	6446                	ld	s0,80(sp)
ffffffffc0203bbc:	64a6                	ld	s1,72(sp)
ffffffffc0203bbe:	6906                	ld	s2,64(sp)
ffffffffc0203bc0:	79e2                	ld	s3,56(sp)
ffffffffc0203bc2:	7a42                	ld	s4,48(sp)
ffffffffc0203bc4:	7aa2                	ld	s5,40(sp)
ffffffffc0203bc6:	7b02                	ld	s6,32(sp)
ffffffffc0203bc8:	6be2                	ld	s7,24(sp)
ffffffffc0203bca:	6c42                	ld	s8,16(sp)
ffffffffc0203bcc:	6125                	addi	sp,sp,96
ffffffffc0203bce:	8082                	ret
                    cprintf("i %d, swap_out: call swap_out_victim failed\n",i);
ffffffffc0203bd0:	85a2                	mv	a1,s0
ffffffffc0203bd2:	00004517          	auipc	a0,0x4
ffffffffc0203bd6:	16e50513          	addi	a0,a0,366 # ffffffffc0207d40 <default_pmm_manager+0xa28>
ffffffffc0203bda:	db4fc0ef          	jal	ra,ffffffffc020018e <cprintf>
                  break;
ffffffffc0203bde:	bfe1                	j	ffffffffc0203bb6 <swap_out+0xc6>
     for (i = 0; i != n; ++ i)
ffffffffc0203be0:	4401                	li	s0,0
ffffffffc0203be2:	bfd1                	j	ffffffffc0203bb6 <swap_out+0xc6>
          assert((*ptep & PTE_V) != 0);
ffffffffc0203be4:	00004697          	auipc	a3,0x4
ffffffffc0203be8:	18c68693          	addi	a3,a3,396 # ffffffffc0207d70 <default_pmm_manager+0xa58>
ffffffffc0203bec:	00003617          	auipc	a2,0x3
ffffffffc0203bf0:	fe460613          	addi	a2,a2,-28 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203bf4:	06800593          	li	a1,104
ffffffffc0203bf8:	00004517          	auipc	a0,0x4
ffffffffc0203bfc:	ec050513          	addi	a0,a0,-320 # ffffffffc0207ab8 <default_pmm_manager+0x7a0>
ffffffffc0203c00:	881fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0203c04 <swap_in>:
{
ffffffffc0203c04:	7179                	addi	sp,sp,-48
ffffffffc0203c06:	e84a                	sd	s2,16(sp)
ffffffffc0203c08:	892a                	mv	s2,a0
     struct Page *result = alloc_page();
ffffffffc0203c0a:	4505                	li	a0,1
{
ffffffffc0203c0c:	ec26                	sd	s1,24(sp)
ffffffffc0203c0e:	e44e                	sd	s3,8(sp)
ffffffffc0203c10:	f406                	sd	ra,40(sp)
ffffffffc0203c12:	f022                	sd	s0,32(sp)
ffffffffc0203c14:	84ae                	mv	s1,a1
ffffffffc0203c16:	89b2                	mv	s3,a2
     struct Page *result = alloc_page();
ffffffffc0203c18:	a0cfe0ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
     assert(result!=NULL);
ffffffffc0203c1c:	c129                	beqz	a0,ffffffffc0203c5e <swap_in+0x5a>
     pte_t *ptep = get_pte(mm->pgdir, addr, 0);
ffffffffc0203c1e:	842a                	mv	s0,a0
ffffffffc0203c20:	01893503          	ld	a0,24(s2)
ffffffffc0203c24:	4601                	li	a2,0
ffffffffc0203c26:	85a6                	mv	a1,s1
ffffffffc0203c28:	b0afe0ef          	jal	ra,ffffffffc0201f32 <get_pte>
ffffffffc0203c2c:	892a                	mv	s2,a0
     if ((r = swapfs_read((*ptep), result)) != 0)
ffffffffc0203c2e:	6108                	ld	a0,0(a0)
ffffffffc0203c30:	85a2                	mv	a1,s0
ffffffffc0203c32:	703000ef          	jal	ra,ffffffffc0204b34 <swapfs_read>
     cprintf("swap_in: load disk swap entry %d with swap_page in vadr 0x%x\n", (*ptep)>>8, addr);
ffffffffc0203c36:	00093583          	ld	a1,0(s2)
ffffffffc0203c3a:	8626                	mv	a2,s1
ffffffffc0203c3c:	00004517          	auipc	a0,0x4
ffffffffc0203c40:	e1c50513          	addi	a0,a0,-484 # ffffffffc0207a58 <default_pmm_manager+0x740>
ffffffffc0203c44:	81a1                	srli	a1,a1,0x8
ffffffffc0203c46:	d48fc0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0203c4a:	70a2                	ld	ra,40(sp)
     *ptr_result=result;
ffffffffc0203c4c:	0089b023          	sd	s0,0(s3)
}
ffffffffc0203c50:	7402                	ld	s0,32(sp)
ffffffffc0203c52:	64e2                	ld	s1,24(sp)
ffffffffc0203c54:	6942                	ld	s2,16(sp)
ffffffffc0203c56:	69a2                	ld	s3,8(sp)
ffffffffc0203c58:	4501                	li	a0,0
ffffffffc0203c5a:	6145                	addi	sp,sp,48
ffffffffc0203c5c:	8082                	ret
     assert(result!=NULL);
ffffffffc0203c5e:	00004697          	auipc	a3,0x4
ffffffffc0203c62:	dea68693          	addi	a3,a3,-534 # ffffffffc0207a48 <default_pmm_manager+0x730>
ffffffffc0203c66:	00003617          	auipc	a2,0x3
ffffffffc0203c6a:	f6a60613          	addi	a2,a2,-150 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203c6e:	07e00593          	li	a1,126
ffffffffc0203c72:	00004517          	auipc	a0,0x4
ffffffffc0203c76:	e4650513          	addi	a0,a0,-442 # ffffffffc0207ab8 <default_pmm_manager+0x7a0>
ffffffffc0203c7a:	807fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0203c7e <_fifo_init_mm>:
    elm->prev = elm->next = elm;
ffffffffc0203c7e:	000a9797          	auipc	a5,0xa9
ffffffffc0203c82:	d2278793          	addi	a5,a5,-734 # ffffffffc02ac9a0 <pra_list_head>
 */
static int
_fifo_init_mm(struct mm_struct *mm)
{     
     list_init(&pra_list_head);
     mm->sm_priv = &pra_list_head;
ffffffffc0203c86:	f51c                	sd	a5,40(a0)
ffffffffc0203c88:	e79c                	sd	a5,8(a5)
ffffffffc0203c8a:	e39c                	sd	a5,0(a5)
     //cprintf(" mm->sm_priv %x in fifo_init_mm\n",mm->sm_priv);
     return 0;
}
ffffffffc0203c8c:	4501                	li	a0,0
ffffffffc0203c8e:	8082                	ret

ffffffffc0203c90 <_fifo_init>:

static int
_fifo_init(void)
{
    return 0;
}
ffffffffc0203c90:	4501                	li	a0,0
ffffffffc0203c92:	8082                	ret

ffffffffc0203c94 <_fifo_set_unswappable>:

static int
_fifo_set_unswappable(struct mm_struct *mm, uintptr_t addr)
{
    return 0;
}
ffffffffc0203c94:	4501                	li	a0,0
ffffffffc0203c96:	8082                	ret

ffffffffc0203c98 <_fifo_tick_event>:

static int
_fifo_tick_event(struct mm_struct *mm)
{ return 0; }
ffffffffc0203c98:	4501                	li	a0,0
ffffffffc0203c9a:	8082                	ret

ffffffffc0203c9c <_fifo_check_swap>:
_fifo_check_swap(void) {
ffffffffc0203c9c:	711d                	addi	sp,sp,-96
ffffffffc0203c9e:	fc4e                	sd	s3,56(sp)
ffffffffc0203ca0:	f852                	sd	s4,48(sp)
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203ca2:	00004517          	auipc	a0,0x4
ffffffffc0203ca6:	13e50513          	addi	a0,a0,318 # ffffffffc0207de0 <default_pmm_manager+0xac8>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203caa:	698d                	lui	s3,0x3
ffffffffc0203cac:	4a31                	li	s4,12
_fifo_check_swap(void) {
ffffffffc0203cae:	e8a2                	sd	s0,80(sp)
ffffffffc0203cb0:	e4a6                	sd	s1,72(sp)
ffffffffc0203cb2:	ec86                	sd	ra,88(sp)
ffffffffc0203cb4:	e0ca                	sd	s2,64(sp)
ffffffffc0203cb6:	f456                	sd	s5,40(sp)
ffffffffc0203cb8:	f05a                	sd	s6,32(sp)
ffffffffc0203cba:	ec5e                	sd	s7,24(sp)
ffffffffc0203cbc:	e862                	sd	s8,16(sp)
ffffffffc0203cbe:	e466                	sd	s9,8(sp)
    assert(pgfault_num==4);
ffffffffc0203cc0:	000a9417          	auipc	s0,0xa9
ffffffffc0203cc4:	bb440413          	addi	s0,s0,-1100 # ffffffffc02ac874 <pgfault_num>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203cc8:	cc6fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203ccc:	01498023          	sb	s4,0(s3) # 3000 <_binary_obj___user_faultread_out_size-0x65c8>
    assert(pgfault_num==4);
ffffffffc0203cd0:	4004                	lw	s1,0(s0)
ffffffffc0203cd2:	4791                	li	a5,4
ffffffffc0203cd4:	2481                	sext.w	s1,s1
ffffffffc0203cd6:	14f49963          	bne	s1,a5,ffffffffc0203e28 <_fifo_check_swap+0x18c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203cda:	00004517          	auipc	a0,0x4
ffffffffc0203cde:	14650513          	addi	a0,a0,326 # ffffffffc0207e20 <default_pmm_manager+0xb08>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203ce2:	6a85                	lui	s5,0x1
ffffffffc0203ce4:	4b29                	li	s6,10
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203ce6:	ca8fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203cea:	016a8023          	sb	s6,0(s5) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>
    assert(pgfault_num==4);
ffffffffc0203cee:	00042903          	lw	s2,0(s0)
ffffffffc0203cf2:	2901                	sext.w	s2,s2
ffffffffc0203cf4:	2a991a63          	bne	s2,s1,ffffffffc0203fa8 <_fifo_check_swap+0x30c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203cf8:	00004517          	auipc	a0,0x4
ffffffffc0203cfc:	15050513          	addi	a0,a0,336 # ffffffffc0207e48 <default_pmm_manager+0xb30>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d00:	6b91                	lui	s7,0x4
ffffffffc0203d02:	4c35                	li	s8,13
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203d04:	c8afc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203d08:	018b8023          	sb	s8,0(s7) # 4000 <_binary_obj___user_faultread_out_size-0x55c8>
    assert(pgfault_num==4);
ffffffffc0203d0c:	4004                	lw	s1,0(s0)
ffffffffc0203d0e:	2481                	sext.w	s1,s1
ffffffffc0203d10:	27249c63          	bne	s1,s2,ffffffffc0203f88 <_fifo_check_swap+0x2ec>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d14:	00004517          	auipc	a0,0x4
ffffffffc0203d18:	15c50513          	addi	a0,a0,348 # ffffffffc0207e70 <default_pmm_manager+0xb58>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d1c:	6909                	lui	s2,0x2
ffffffffc0203d1e:	4cad                	li	s9,11
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d20:	c6efc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d24:	01990023          	sb	s9,0(s2) # 2000 <_binary_obj___user_faultread_out_size-0x75c8>
    assert(pgfault_num==4);
ffffffffc0203d28:	401c                	lw	a5,0(s0)
ffffffffc0203d2a:	2781                	sext.w	a5,a5
ffffffffc0203d2c:	22979e63          	bne	a5,s1,ffffffffc0203f68 <_fifo_check_swap+0x2cc>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203d30:	00004517          	auipc	a0,0x4
ffffffffc0203d34:	16850513          	addi	a0,a0,360 # ffffffffc0207e98 <default_pmm_manager+0xb80>
ffffffffc0203d38:	c56fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203d3c:	6795                	lui	a5,0x5
ffffffffc0203d3e:	4739                	li	a4,14
ffffffffc0203d40:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x45c8>
    assert(pgfault_num==5);
ffffffffc0203d44:	4004                	lw	s1,0(s0)
ffffffffc0203d46:	4795                	li	a5,5
ffffffffc0203d48:	2481                	sext.w	s1,s1
ffffffffc0203d4a:	1ef49f63          	bne	s1,a5,ffffffffc0203f48 <_fifo_check_swap+0x2ac>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d4e:	00004517          	auipc	a0,0x4
ffffffffc0203d52:	12250513          	addi	a0,a0,290 # ffffffffc0207e70 <default_pmm_manager+0xb58>
ffffffffc0203d56:	c38fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d5a:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==5);
ffffffffc0203d5e:	401c                	lw	a5,0(s0)
ffffffffc0203d60:	2781                	sext.w	a5,a5
ffffffffc0203d62:	1c979363          	bne	a5,s1,ffffffffc0203f28 <_fifo_check_swap+0x28c>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203d66:	00004517          	auipc	a0,0x4
ffffffffc0203d6a:	0ba50513          	addi	a0,a0,186 # ffffffffc0207e20 <default_pmm_manager+0xb08>
ffffffffc0203d6e:	c20fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x1000 = 0x0a;
ffffffffc0203d72:	016a8023          	sb	s6,0(s5)
    assert(pgfault_num==6);
ffffffffc0203d76:	401c                	lw	a5,0(s0)
ffffffffc0203d78:	4719                	li	a4,6
ffffffffc0203d7a:	2781                	sext.w	a5,a5
ffffffffc0203d7c:	18e79663          	bne	a5,a4,ffffffffc0203f08 <_fifo_check_swap+0x26c>
    cprintf("write Virt Page b in fifo_check_swap\n");
ffffffffc0203d80:	00004517          	auipc	a0,0x4
ffffffffc0203d84:	0f050513          	addi	a0,a0,240 # ffffffffc0207e70 <default_pmm_manager+0xb58>
ffffffffc0203d88:	c06fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x2000 = 0x0b;
ffffffffc0203d8c:	01990023          	sb	s9,0(s2)
    assert(pgfault_num==7);
ffffffffc0203d90:	401c                	lw	a5,0(s0)
ffffffffc0203d92:	471d                	li	a4,7
ffffffffc0203d94:	2781                	sext.w	a5,a5
ffffffffc0203d96:	14e79963          	bne	a5,a4,ffffffffc0203ee8 <_fifo_check_swap+0x24c>
    cprintf("write Virt Page c in fifo_check_swap\n");
ffffffffc0203d9a:	00004517          	auipc	a0,0x4
ffffffffc0203d9e:	04650513          	addi	a0,a0,70 # ffffffffc0207de0 <default_pmm_manager+0xac8>
ffffffffc0203da2:	becfc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x3000 = 0x0c;
ffffffffc0203da6:	01498023          	sb	s4,0(s3)
    assert(pgfault_num==8);
ffffffffc0203daa:	401c                	lw	a5,0(s0)
ffffffffc0203dac:	4721                	li	a4,8
ffffffffc0203dae:	2781                	sext.w	a5,a5
ffffffffc0203db0:	10e79c63          	bne	a5,a4,ffffffffc0203ec8 <_fifo_check_swap+0x22c>
    cprintf("write Virt Page d in fifo_check_swap\n");
ffffffffc0203db4:	00004517          	auipc	a0,0x4
ffffffffc0203db8:	09450513          	addi	a0,a0,148 # ffffffffc0207e48 <default_pmm_manager+0xb30>
ffffffffc0203dbc:	bd2fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x4000 = 0x0d;
ffffffffc0203dc0:	018b8023          	sb	s8,0(s7)
    assert(pgfault_num==9);
ffffffffc0203dc4:	401c                	lw	a5,0(s0)
ffffffffc0203dc6:	4725                	li	a4,9
ffffffffc0203dc8:	2781                	sext.w	a5,a5
ffffffffc0203dca:	0ce79f63          	bne	a5,a4,ffffffffc0203ea8 <_fifo_check_swap+0x20c>
    cprintf("write Virt Page e in fifo_check_swap\n");
ffffffffc0203dce:	00004517          	auipc	a0,0x4
ffffffffc0203dd2:	0ca50513          	addi	a0,a0,202 # ffffffffc0207e98 <default_pmm_manager+0xb80>
ffffffffc0203dd6:	bb8fc0ef          	jal	ra,ffffffffc020018e <cprintf>
    *(unsigned char *)0x5000 = 0x0e;
ffffffffc0203dda:	6795                	lui	a5,0x5
ffffffffc0203ddc:	4739                	li	a4,14
ffffffffc0203dde:	00e78023          	sb	a4,0(a5) # 5000 <_binary_obj___user_faultread_out_size-0x45c8>
    assert(pgfault_num==10);
ffffffffc0203de2:	4004                	lw	s1,0(s0)
ffffffffc0203de4:	47a9                	li	a5,10
ffffffffc0203de6:	2481                	sext.w	s1,s1
ffffffffc0203de8:	0af49063          	bne	s1,a5,ffffffffc0203e88 <_fifo_check_swap+0x1ec>
    cprintf("write Virt Page a in fifo_check_swap\n");
ffffffffc0203dec:	00004517          	auipc	a0,0x4
ffffffffc0203df0:	03450513          	addi	a0,a0,52 # ffffffffc0207e20 <default_pmm_manager+0xb08>
ffffffffc0203df4:	b9afc0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203df8:	6785                	lui	a5,0x1
ffffffffc0203dfa:	0007c783          	lbu	a5,0(a5) # 1000 <_binary_obj___user_faultread_out_size-0x85c8>
ffffffffc0203dfe:	06979563          	bne	a5,s1,ffffffffc0203e68 <_fifo_check_swap+0x1cc>
    assert(pgfault_num==11);
ffffffffc0203e02:	401c                	lw	a5,0(s0)
ffffffffc0203e04:	472d                	li	a4,11
ffffffffc0203e06:	2781                	sext.w	a5,a5
ffffffffc0203e08:	04e79063          	bne	a5,a4,ffffffffc0203e48 <_fifo_check_swap+0x1ac>
}
ffffffffc0203e0c:	60e6                	ld	ra,88(sp)
ffffffffc0203e0e:	6446                	ld	s0,80(sp)
ffffffffc0203e10:	64a6                	ld	s1,72(sp)
ffffffffc0203e12:	6906                	ld	s2,64(sp)
ffffffffc0203e14:	79e2                	ld	s3,56(sp)
ffffffffc0203e16:	7a42                	ld	s4,48(sp)
ffffffffc0203e18:	7aa2                	ld	s5,40(sp)
ffffffffc0203e1a:	7b02                	ld	s6,32(sp)
ffffffffc0203e1c:	6be2                	ld	s7,24(sp)
ffffffffc0203e1e:	6c42                	ld	s8,16(sp)
ffffffffc0203e20:	6ca2                	ld	s9,8(sp)
ffffffffc0203e22:	4501                	li	a0,0
ffffffffc0203e24:	6125                	addi	sp,sp,96
ffffffffc0203e26:	8082                	ret
    assert(pgfault_num==4);
ffffffffc0203e28:	00004697          	auipc	a3,0x4
ffffffffc0203e2c:	e5868693          	addi	a3,a3,-424 # ffffffffc0207c80 <default_pmm_manager+0x968>
ffffffffc0203e30:	00003617          	auipc	a2,0x3
ffffffffc0203e34:	da060613          	addi	a2,a2,-608 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203e38:	05100593          	li	a1,81
ffffffffc0203e3c:	00004517          	auipc	a0,0x4
ffffffffc0203e40:	fcc50513          	addi	a0,a0,-52 # ffffffffc0207e08 <default_pmm_manager+0xaf0>
ffffffffc0203e44:	e3cfc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==11);
ffffffffc0203e48:	00004697          	auipc	a3,0x4
ffffffffc0203e4c:	10068693          	addi	a3,a3,256 # ffffffffc0207f48 <default_pmm_manager+0xc30>
ffffffffc0203e50:	00003617          	auipc	a2,0x3
ffffffffc0203e54:	d8060613          	addi	a2,a2,-640 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203e58:	07300593          	li	a1,115
ffffffffc0203e5c:	00004517          	auipc	a0,0x4
ffffffffc0203e60:	fac50513          	addi	a0,a0,-84 # ffffffffc0207e08 <default_pmm_manager+0xaf0>
ffffffffc0203e64:	e1cfc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(*(unsigned char *)0x1000 == 0x0a);
ffffffffc0203e68:	00004697          	auipc	a3,0x4
ffffffffc0203e6c:	0b868693          	addi	a3,a3,184 # ffffffffc0207f20 <default_pmm_manager+0xc08>
ffffffffc0203e70:	00003617          	auipc	a2,0x3
ffffffffc0203e74:	d6060613          	addi	a2,a2,-672 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203e78:	07100593          	li	a1,113
ffffffffc0203e7c:	00004517          	auipc	a0,0x4
ffffffffc0203e80:	f8c50513          	addi	a0,a0,-116 # ffffffffc0207e08 <default_pmm_manager+0xaf0>
ffffffffc0203e84:	dfcfc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==10);
ffffffffc0203e88:	00004697          	auipc	a3,0x4
ffffffffc0203e8c:	08868693          	addi	a3,a3,136 # ffffffffc0207f10 <default_pmm_manager+0xbf8>
ffffffffc0203e90:	00003617          	auipc	a2,0x3
ffffffffc0203e94:	d4060613          	addi	a2,a2,-704 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203e98:	06f00593          	li	a1,111
ffffffffc0203e9c:	00004517          	auipc	a0,0x4
ffffffffc0203ea0:	f6c50513          	addi	a0,a0,-148 # ffffffffc0207e08 <default_pmm_manager+0xaf0>
ffffffffc0203ea4:	ddcfc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==9);
ffffffffc0203ea8:	00004697          	auipc	a3,0x4
ffffffffc0203eac:	05868693          	addi	a3,a3,88 # ffffffffc0207f00 <default_pmm_manager+0xbe8>
ffffffffc0203eb0:	00003617          	auipc	a2,0x3
ffffffffc0203eb4:	d2060613          	addi	a2,a2,-736 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203eb8:	06c00593          	li	a1,108
ffffffffc0203ebc:	00004517          	auipc	a0,0x4
ffffffffc0203ec0:	f4c50513          	addi	a0,a0,-180 # ffffffffc0207e08 <default_pmm_manager+0xaf0>
ffffffffc0203ec4:	dbcfc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==8);
ffffffffc0203ec8:	00004697          	auipc	a3,0x4
ffffffffc0203ecc:	02868693          	addi	a3,a3,40 # ffffffffc0207ef0 <default_pmm_manager+0xbd8>
ffffffffc0203ed0:	00003617          	auipc	a2,0x3
ffffffffc0203ed4:	d0060613          	addi	a2,a2,-768 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203ed8:	06900593          	li	a1,105
ffffffffc0203edc:	00004517          	auipc	a0,0x4
ffffffffc0203ee0:	f2c50513          	addi	a0,a0,-212 # ffffffffc0207e08 <default_pmm_manager+0xaf0>
ffffffffc0203ee4:	d9cfc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==7);
ffffffffc0203ee8:	00004697          	auipc	a3,0x4
ffffffffc0203eec:	ff868693          	addi	a3,a3,-8 # ffffffffc0207ee0 <default_pmm_manager+0xbc8>
ffffffffc0203ef0:	00003617          	auipc	a2,0x3
ffffffffc0203ef4:	ce060613          	addi	a2,a2,-800 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203ef8:	06600593          	li	a1,102
ffffffffc0203efc:	00004517          	auipc	a0,0x4
ffffffffc0203f00:	f0c50513          	addi	a0,a0,-244 # ffffffffc0207e08 <default_pmm_manager+0xaf0>
ffffffffc0203f04:	d7cfc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==6);
ffffffffc0203f08:	00004697          	auipc	a3,0x4
ffffffffc0203f0c:	fc868693          	addi	a3,a3,-56 # ffffffffc0207ed0 <default_pmm_manager+0xbb8>
ffffffffc0203f10:	00003617          	auipc	a2,0x3
ffffffffc0203f14:	cc060613          	addi	a2,a2,-832 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203f18:	06300593          	li	a1,99
ffffffffc0203f1c:	00004517          	auipc	a0,0x4
ffffffffc0203f20:	eec50513          	addi	a0,a0,-276 # ffffffffc0207e08 <default_pmm_manager+0xaf0>
ffffffffc0203f24:	d5cfc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==5);
ffffffffc0203f28:	00004697          	auipc	a3,0x4
ffffffffc0203f2c:	f9868693          	addi	a3,a3,-104 # ffffffffc0207ec0 <default_pmm_manager+0xba8>
ffffffffc0203f30:	00003617          	auipc	a2,0x3
ffffffffc0203f34:	ca060613          	addi	a2,a2,-864 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203f38:	06000593          	li	a1,96
ffffffffc0203f3c:	00004517          	auipc	a0,0x4
ffffffffc0203f40:	ecc50513          	addi	a0,a0,-308 # ffffffffc0207e08 <default_pmm_manager+0xaf0>
ffffffffc0203f44:	d3cfc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==5);
ffffffffc0203f48:	00004697          	auipc	a3,0x4
ffffffffc0203f4c:	f7868693          	addi	a3,a3,-136 # ffffffffc0207ec0 <default_pmm_manager+0xba8>
ffffffffc0203f50:	00003617          	auipc	a2,0x3
ffffffffc0203f54:	c8060613          	addi	a2,a2,-896 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203f58:	05d00593          	li	a1,93
ffffffffc0203f5c:	00004517          	auipc	a0,0x4
ffffffffc0203f60:	eac50513          	addi	a0,a0,-340 # ffffffffc0207e08 <default_pmm_manager+0xaf0>
ffffffffc0203f64:	d1cfc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==4);
ffffffffc0203f68:	00004697          	auipc	a3,0x4
ffffffffc0203f6c:	d1868693          	addi	a3,a3,-744 # ffffffffc0207c80 <default_pmm_manager+0x968>
ffffffffc0203f70:	00003617          	auipc	a2,0x3
ffffffffc0203f74:	c6060613          	addi	a2,a2,-928 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203f78:	05a00593          	li	a1,90
ffffffffc0203f7c:	00004517          	auipc	a0,0x4
ffffffffc0203f80:	e8c50513          	addi	a0,a0,-372 # ffffffffc0207e08 <default_pmm_manager+0xaf0>
ffffffffc0203f84:	cfcfc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==4);
ffffffffc0203f88:	00004697          	auipc	a3,0x4
ffffffffc0203f8c:	cf868693          	addi	a3,a3,-776 # ffffffffc0207c80 <default_pmm_manager+0x968>
ffffffffc0203f90:	00003617          	auipc	a2,0x3
ffffffffc0203f94:	c4060613          	addi	a2,a2,-960 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203f98:	05700593          	li	a1,87
ffffffffc0203f9c:	00004517          	auipc	a0,0x4
ffffffffc0203fa0:	e6c50513          	addi	a0,a0,-404 # ffffffffc0207e08 <default_pmm_manager+0xaf0>
ffffffffc0203fa4:	cdcfc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgfault_num==4);
ffffffffc0203fa8:	00004697          	auipc	a3,0x4
ffffffffc0203fac:	cd868693          	addi	a3,a3,-808 # ffffffffc0207c80 <default_pmm_manager+0x968>
ffffffffc0203fb0:	00003617          	auipc	a2,0x3
ffffffffc0203fb4:	c2060613          	addi	a2,a2,-992 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203fb8:	05400593          	li	a1,84
ffffffffc0203fbc:	00004517          	auipc	a0,0x4
ffffffffc0203fc0:	e4c50513          	addi	a0,a0,-436 # ffffffffc0207e08 <default_pmm_manager+0xaf0>
ffffffffc0203fc4:	cbcfc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0203fc8 <_fifo_swap_out_victim>:
     list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc0203fc8:	751c                	ld	a5,40(a0)
{
ffffffffc0203fca:	1141                	addi	sp,sp,-16
ffffffffc0203fcc:	e406                	sd	ra,8(sp)
         assert(head != NULL);
ffffffffc0203fce:	cf91                	beqz	a5,ffffffffc0203fea <_fifo_swap_out_victim+0x22>
     assert(in_tick==0);
ffffffffc0203fd0:	ee0d                	bnez	a2,ffffffffc020400a <_fifo_swap_out_victim+0x42>
    return listelm->next;
ffffffffc0203fd2:	679c                	ld	a5,8(a5)
}
ffffffffc0203fd4:	60a2                	ld	ra,8(sp)
ffffffffc0203fd6:	4501                	li	a0,0
    __list_del(listelm->prev, listelm->next);
ffffffffc0203fd8:	6394                	ld	a3,0(a5)
ffffffffc0203fda:	6798                	ld	a4,8(a5)
    *ptr_page = le2page(entry, pra_page_link);
ffffffffc0203fdc:	fd878793          	addi	a5,a5,-40
    prev->next = next;
ffffffffc0203fe0:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0203fe2:	e314                	sd	a3,0(a4)
ffffffffc0203fe4:	e19c                	sd	a5,0(a1)
}
ffffffffc0203fe6:	0141                	addi	sp,sp,16
ffffffffc0203fe8:	8082                	ret
         assert(head != NULL);
ffffffffc0203fea:	00004697          	auipc	a3,0x4
ffffffffc0203fee:	f8e68693          	addi	a3,a3,-114 # ffffffffc0207f78 <default_pmm_manager+0xc60>
ffffffffc0203ff2:	00003617          	auipc	a2,0x3
ffffffffc0203ff6:	bde60613          	addi	a2,a2,-1058 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0203ffa:	04100593          	li	a1,65
ffffffffc0203ffe:	00004517          	auipc	a0,0x4
ffffffffc0204002:	e0a50513          	addi	a0,a0,-502 # ffffffffc0207e08 <default_pmm_manager+0xaf0>
ffffffffc0204006:	c7afc0ef          	jal	ra,ffffffffc0200480 <__panic>
     assert(in_tick==0);
ffffffffc020400a:	00004697          	auipc	a3,0x4
ffffffffc020400e:	f7e68693          	addi	a3,a3,-130 # ffffffffc0207f88 <default_pmm_manager+0xc70>
ffffffffc0204012:	00003617          	auipc	a2,0x3
ffffffffc0204016:	bbe60613          	addi	a2,a2,-1090 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020401a:	04200593          	li	a1,66
ffffffffc020401e:	00004517          	auipc	a0,0x4
ffffffffc0204022:	dea50513          	addi	a0,a0,-534 # ffffffffc0207e08 <default_pmm_manager+0xaf0>
ffffffffc0204026:	c5afc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc020402a <_fifo_map_swappable>:
    list_entry_t *entry=&(page->pra_page_link);
ffffffffc020402a:	02860713          	addi	a4,a2,40
    list_entry_t *head=(list_entry_t*) mm->sm_priv;
ffffffffc020402e:	751c                	ld	a5,40(a0)
    assert(entry != NULL && head != NULL);
ffffffffc0204030:	cb09                	beqz	a4,ffffffffc0204042 <_fifo_map_swappable+0x18>
ffffffffc0204032:	cb81                	beqz	a5,ffffffffc0204042 <_fifo_map_swappable+0x18>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204034:	6394                	ld	a3,0(a5)
    prev->next = next->prev = elm;
ffffffffc0204036:	e398                	sd	a4,0(a5)
}
ffffffffc0204038:	4501                	li	a0,0
ffffffffc020403a:	e698                	sd	a4,8(a3)
    elm->next = next;
ffffffffc020403c:	fa1c                	sd	a5,48(a2)
    elm->prev = prev;
ffffffffc020403e:	f614                	sd	a3,40(a2)
ffffffffc0204040:	8082                	ret
{
ffffffffc0204042:	1141                	addi	sp,sp,-16
    assert(entry != NULL && head != NULL);
ffffffffc0204044:	00004697          	auipc	a3,0x4
ffffffffc0204048:	f1468693          	addi	a3,a3,-236 # ffffffffc0207f58 <default_pmm_manager+0xc40>
ffffffffc020404c:	00003617          	auipc	a2,0x3
ffffffffc0204050:	b8460613          	addi	a2,a2,-1148 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0204054:	03200593          	li	a1,50
ffffffffc0204058:	00004517          	auipc	a0,0x4
ffffffffc020405c:	db050513          	addi	a0,a0,-592 # ffffffffc0207e08 <default_pmm_manager+0xaf0>
{
ffffffffc0204060:	e406                	sd	ra,8(sp)
    assert(entry != NULL && head != NULL);
ffffffffc0204062:	c1efc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204066 <check_vma_overlap.isra.0.part.1>:
}


// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0204066:	1141                	addi	sp,sp,-16
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0204068:	00004697          	auipc	a3,0x4
ffffffffc020406c:	f4868693          	addi	a3,a3,-184 # ffffffffc0207fb0 <default_pmm_manager+0xc98>
ffffffffc0204070:	00003617          	auipc	a2,0x3
ffffffffc0204074:	b6060613          	addi	a2,a2,-1184 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0204078:	06d00593          	li	a1,109
ffffffffc020407c:	00004517          	auipc	a0,0x4
ffffffffc0204080:	f5450513          	addi	a0,a0,-172 # ffffffffc0207fd0 <default_pmm_manager+0xcb8>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next) {
ffffffffc0204084:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0204086:	bfafc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc020408a <mm_create>:
mm_create(void) {
ffffffffc020408a:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020408c:	04000513          	li	a0,64
mm_create(void) {
ffffffffc0204090:	e022                	sd	s0,0(sp)
ffffffffc0204092:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0204094:	b99fd0ef          	jal	ra,ffffffffc0201c2c <kmalloc>
ffffffffc0204098:	842a                	mv	s0,a0
    if (mm != NULL) {
ffffffffc020409a:	c515                	beqz	a0,ffffffffc02040c6 <mm_create+0x3c>
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc020409c:	000a8797          	auipc	a5,0xa8
ffffffffc02040a0:	7d478793          	addi	a5,a5,2004 # ffffffffc02ac870 <swap_init_ok>
ffffffffc02040a4:	439c                	lw	a5,0(a5)
    elm->prev = elm->next = elm;
ffffffffc02040a6:	e408                	sd	a0,8(s0)
ffffffffc02040a8:	e008                	sd	a0,0(s0)
        mm->mmap_cache = NULL;
ffffffffc02040aa:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02040ae:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02040b2:	02052023          	sw	zero,32(a0)
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02040b6:	2781                	sext.w	a5,a5
ffffffffc02040b8:	ef81                	bnez	a5,ffffffffc02040d0 <mm_create+0x46>
        else mm->sm_priv = NULL;
ffffffffc02040ba:	02053423          	sd	zero,40(a0)
    return mm->mm_count;
}

static inline void
set_mm_count(struct mm_struct *mm, int val) {
    mm->mm_count = val;
ffffffffc02040be:	02042823          	sw	zero,48(s0)

typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock) {
    *lock = 0;
ffffffffc02040c2:	02043c23          	sd	zero,56(s0)
}
ffffffffc02040c6:	8522                	mv	a0,s0
ffffffffc02040c8:	60a2                	ld	ra,8(sp)
ffffffffc02040ca:	6402                	ld	s0,0(sp)
ffffffffc02040cc:	0141                	addi	sp,sp,16
ffffffffc02040ce:	8082                	ret
        if (swap_init_ok) swap_init_mm(mm);
ffffffffc02040d0:	a01ff0ef          	jal	ra,ffffffffc0203ad0 <swap_init_mm>
ffffffffc02040d4:	b7ed                	j	ffffffffc02040be <mm_create+0x34>

ffffffffc02040d6 <vma_create>:
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02040d6:	1101                	addi	sp,sp,-32
ffffffffc02040d8:	e04a                	sd	s2,0(sp)
ffffffffc02040da:	892a                	mv	s2,a0
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02040dc:	03000513          	li	a0,48
vma_create(uintptr_t vm_start, uintptr_t vm_end, uint32_t vm_flags) {
ffffffffc02040e0:	e822                	sd	s0,16(sp)
ffffffffc02040e2:	e426                	sd	s1,8(sp)
ffffffffc02040e4:	ec06                	sd	ra,24(sp)
ffffffffc02040e6:	84ae                	mv	s1,a1
ffffffffc02040e8:	8432                	mv	s0,a2
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02040ea:	b43fd0ef          	jal	ra,ffffffffc0201c2c <kmalloc>
    if (vma != NULL) {
ffffffffc02040ee:	c509                	beqz	a0,ffffffffc02040f8 <vma_create+0x22>
        vma->vm_start = vm_start;
ffffffffc02040f0:	01253423          	sd	s2,8(a0)
        vma->vm_end = vm_end;
ffffffffc02040f4:	e904                	sd	s1,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02040f6:	cd00                	sw	s0,24(a0)
}
ffffffffc02040f8:	60e2                	ld	ra,24(sp)
ffffffffc02040fa:	6442                	ld	s0,16(sp)
ffffffffc02040fc:	64a2                	ld	s1,8(sp)
ffffffffc02040fe:	6902                	ld	s2,0(sp)
ffffffffc0204100:	6105                	addi	sp,sp,32
ffffffffc0204102:	8082                	ret

ffffffffc0204104 <find_vma>:
    if (mm != NULL) {
ffffffffc0204104:	c51d                	beqz	a0,ffffffffc0204132 <find_vma+0x2e>
        vma = mm->mmap_cache;
ffffffffc0204106:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0204108:	c781                	beqz	a5,ffffffffc0204110 <find_vma+0xc>
ffffffffc020410a:	6798                	ld	a4,8(a5)
ffffffffc020410c:	02e5f663          	bgeu	a1,a4,ffffffffc0204138 <find_vma+0x34>
                list_entry_t *list = &(mm->mmap_list), *le = list;
ffffffffc0204110:	87aa                	mv	a5,a0
    return listelm->next;
ffffffffc0204112:	679c                	ld	a5,8(a5)
                while ((le = list_next(le)) != list) {
ffffffffc0204114:	00f50f63          	beq	a0,a5,ffffffffc0204132 <find_vma+0x2e>
                    if (vma->vm_start<=addr && addr < vma->vm_end) {
ffffffffc0204118:	fe87b703          	ld	a4,-24(a5)
ffffffffc020411c:	fee5ebe3          	bltu	a1,a4,ffffffffc0204112 <find_vma+0xe>
ffffffffc0204120:	ff07b703          	ld	a4,-16(a5)
ffffffffc0204124:	fee5f7e3          	bgeu	a1,a4,ffffffffc0204112 <find_vma+0xe>
                    vma = le2vma(le, list_link);
ffffffffc0204128:	1781                	addi	a5,a5,-32
        if (vma != NULL) {
ffffffffc020412a:	c781                	beqz	a5,ffffffffc0204132 <find_vma+0x2e>
            mm->mmap_cache = vma;
ffffffffc020412c:	e91c                	sd	a5,16(a0)
}
ffffffffc020412e:	853e                	mv	a0,a5
ffffffffc0204130:	8082                	ret
    struct vma_struct *vma = NULL;
ffffffffc0204132:	4781                	li	a5,0
}
ffffffffc0204134:	853e                	mv	a0,a5
ffffffffc0204136:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr)) {
ffffffffc0204138:	6b98                	ld	a4,16(a5)
ffffffffc020413a:	fce5fbe3          	bgeu	a1,a4,ffffffffc0204110 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc020413e:	e91c                	sd	a5,16(a0)
    return vma;
ffffffffc0204140:	b7fd                	j	ffffffffc020412e <find_vma+0x2a>

ffffffffc0204142 <insert_vma_struct>:


// insert_vma_struct -insert vma in mm's list link
void
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
    assert(vma->vm_start < vma->vm_end);
ffffffffc0204142:	6590                	ld	a2,8(a1)
ffffffffc0204144:	0105b803          	ld	a6,16(a1) # 1010 <_binary_obj___user_faultread_out_size-0x85b8>
insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma) {
ffffffffc0204148:	1141                	addi	sp,sp,-16
ffffffffc020414a:	e406                	sd	ra,8(sp)
ffffffffc020414c:	872a                	mv	a4,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc020414e:	01066863          	bltu	a2,a6,ffffffffc020415e <insert_vma_struct+0x1c>
ffffffffc0204152:	a8b9                	j	ffffffffc02041b0 <insert_vma_struct+0x6e>
    list_entry_t *le_prev = list, *le_next;

        list_entry_t *le = list;
        while ((le = list_next(le)) != list) {
            struct vma_struct *mmap_prev = le2vma(le, list_link);
            if (mmap_prev->vm_start > vma->vm_start) {
ffffffffc0204154:	fe87b683          	ld	a3,-24(a5)
ffffffffc0204158:	04d66763          	bltu	a2,a3,ffffffffc02041a6 <insert_vma_struct+0x64>
ffffffffc020415c:	873e                	mv	a4,a5
ffffffffc020415e:	671c                	ld	a5,8(a4)
        while ((le = list_next(le)) != list) {
ffffffffc0204160:	fef51ae3          	bne	a0,a5,ffffffffc0204154 <insert_vma_struct+0x12>
        }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list) {
ffffffffc0204164:	02a70463          	beq	a4,a0,ffffffffc020418c <insert_vma_struct+0x4a>
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0204168:	ff073683          	ld	a3,-16(a4)
    assert(prev->vm_start < prev->vm_end);
ffffffffc020416c:	fe873883          	ld	a7,-24(a4)
ffffffffc0204170:	08d8f063          	bgeu	a7,a3,ffffffffc02041f0 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0204174:	04d66e63          	bltu	a2,a3,ffffffffc02041d0 <insert_vma_struct+0x8e>
    }
    if (le_next != list) {
ffffffffc0204178:	00f50a63          	beq	a0,a5,ffffffffc020418c <insert_vma_struct+0x4a>
ffffffffc020417c:	fe87b683          	ld	a3,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0204180:	0506e863          	bltu	a3,a6,ffffffffc02041d0 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0204184:	ff07b603          	ld	a2,-16(a5)
ffffffffc0204188:	02c6f263          	bgeu	a3,a2,ffffffffc02041ac <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count ++;
ffffffffc020418c:	5114                	lw	a3,32(a0)
    vma->vm_mm = mm;
ffffffffc020418e:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0204190:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0204194:	e390                	sd	a2,0(a5)
ffffffffc0204196:	e710                	sd	a2,8(a4)
}
ffffffffc0204198:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc020419a:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc020419c:	f198                	sd	a4,32(a1)
    mm->map_count ++;
ffffffffc020419e:	2685                	addiw	a3,a3,1
ffffffffc02041a0:	d114                	sw	a3,32(a0)
}
ffffffffc02041a2:	0141                	addi	sp,sp,16
ffffffffc02041a4:	8082                	ret
    if (le_prev != list) {
ffffffffc02041a6:	fca711e3          	bne	a4,a0,ffffffffc0204168 <insert_vma_struct+0x26>
ffffffffc02041aa:	bfd9                	j	ffffffffc0204180 <insert_vma_struct+0x3e>
ffffffffc02041ac:	ebbff0ef          	jal	ra,ffffffffc0204066 <check_vma_overlap.isra.0.part.1>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02041b0:	00004697          	auipc	a3,0x4
ffffffffc02041b4:	f1068693          	addi	a3,a3,-240 # ffffffffc02080c0 <default_pmm_manager+0xda8>
ffffffffc02041b8:	00003617          	auipc	a2,0x3
ffffffffc02041bc:	a1860613          	addi	a2,a2,-1512 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02041c0:	07400593          	li	a1,116
ffffffffc02041c4:	00004517          	auipc	a0,0x4
ffffffffc02041c8:	e0c50513          	addi	a0,a0,-500 # ffffffffc0207fd0 <default_pmm_manager+0xcb8>
ffffffffc02041cc:	ab4fc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02041d0:	00004697          	auipc	a3,0x4
ffffffffc02041d4:	f3068693          	addi	a3,a3,-208 # ffffffffc0208100 <default_pmm_manager+0xde8>
ffffffffc02041d8:	00003617          	auipc	a2,0x3
ffffffffc02041dc:	9f860613          	addi	a2,a2,-1544 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02041e0:	06c00593          	li	a1,108
ffffffffc02041e4:	00004517          	auipc	a0,0x4
ffffffffc02041e8:	dec50513          	addi	a0,a0,-532 # ffffffffc0207fd0 <default_pmm_manager+0xcb8>
ffffffffc02041ec:	a94fc0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02041f0:	00004697          	auipc	a3,0x4
ffffffffc02041f4:	ef068693          	addi	a3,a3,-272 # ffffffffc02080e0 <default_pmm_manager+0xdc8>
ffffffffc02041f8:	00003617          	auipc	a2,0x3
ffffffffc02041fc:	9d860613          	addi	a2,a2,-1576 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0204200:	06b00593          	li	a1,107
ffffffffc0204204:	00004517          	auipc	a0,0x4
ffffffffc0204208:	dcc50513          	addi	a0,a0,-564 # ffffffffc0207fd0 <default_pmm_manager+0xcb8>
ffffffffc020420c:	a74fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204210 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void
mm_destroy(struct mm_struct *mm) {
    assert(mm_count(mm) == 0);
ffffffffc0204210:	591c                	lw	a5,48(a0)
mm_destroy(struct mm_struct *mm) {
ffffffffc0204212:	1141                	addi	sp,sp,-16
ffffffffc0204214:	e406                	sd	ra,8(sp)
ffffffffc0204216:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0204218:	e78d                	bnez	a5,ffffffffc0204242 <mm_destroy+0x32>
ffffffffc020421a:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc020421c:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list) {
ffffffffc020421e:	00a40c63          	beq	s0,a0,ffffffffc0204236 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0204222:	6118                	ld	a4,0(a0)
ffffffffc0204224:	651c                	ld	a5,8(a0)
        list_del(le);
        kfree(le2vma(le, list_link));  //kfree vma        
ffffffffc0204226:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc0204228:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020422a:	e398                	sd	a4,0(a5)
ffffffffc020422c:	abdfd0ef          	jal	ra,ffffffffc0201ce8 <kfree>
    return listelm->next;
ffffffffc0204230:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list) {
ffffffffc0204232:	fea418e3          	bne	s0,a0,ffffffffc0204222 <mm_destroy+0x12>
    }
    kfree(mm); //kfree mm
ffffffffc0204236:	8522                	mv	a0,s0
    mm=NULL;
}
ffffffffc0204238:	6402                	ld	s0,0(sp)
ffffffffc020423a:	60a2                	ld	ra,8(sp)
ffffffffc020423c:	0141                	addi	sp,sp,16
    kfree(mm); //kfree mm
ffffffffc020423e:	aabfd06f          	j	ffffffffc0201ce8 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc0204242:	00004697          	auipc	a3,0x4
ffffffffc0204246:	ede68693          	addi	a3,a3,-290 # ffffffffc0208120 <default_pmm_manager+0xe08>
ffffffffc020424a:	00003617          	auipc	a2,0x3
ffffffffc020424e:	98660613          	addi	a2,a2,-1658 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0204252:	09400593          	li	a1,148
ffffffffc0204256:	00004517          	auipc	a0,0x4
ffffffffc020425a:	d7a50513          	addi	a0,a0,-646 # ffffffffc0207fd0 <default_pmm_manager+0xcb8>
ffffffffc020425e:	a22fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204262 <mm_map>:

int
mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
       struct vma_struct **vma_store) {
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0204262:	6785                	lui	a5,0x1
       struct vma_struct **vma_store) {
ffffffffc0204264:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0204266:	17fd                	addi	a5,a5,-1
ffffffffc0204268:	787d                	lui	a6,0xfffff
       struct vma_struct **vma_store) {
ffffffffc020426a:	f822                	sd	s0,48(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020426c:	00f60433          	add	s0,a2,a5
       struct vma_struct **vma_store) {
ffffffffc0204270:	f426                	sd	s1,40(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0204272:	942e                	add	s0,s0,a1
       struct vma_struct **vma_store) {
ffffffffc0204274:	fc06                	sd	ra,56(sp)
ffffffffc0204276:	f04a                	sd	s2,32(sp)
ffffffffc0204278:	ec4e                	sd	s3,24(sp)
ffffffffc020427a:	e852                	sd	s4,16(sp)
ffffffffc020427c:	e456                	sd	s5,8(sp)
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020427e:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end)) {
ffffffffc0204282:	002007b7          	lui	a5,0x200
ffffffffc0204286:	01047433          	and	s0,s0,a6
ffffffffc020428a:	06f4e363          	bltu	s1,a5,ffffffffc02042f0 <mm_map+0x8e>
ffffffffc020428e:	0684f163          	bgeu	s1,s0,ffffffffc02042f0 <mm_map+0x8e>
ffffffffc0204292:	4785                	li	a5,1
ffffffffc0204294:	07fe                	slli	a5,a5,0x1f
ffffffffc0204296:	0487ed63          	bltu	a5,s0,ffffffffc02042f0 <mm_map+0x8e>
ffffffffc020429a:	89aa                	mv	s3,a0
ffffffffc020429c:	8a3a                	mv	s4,a4
ffffffffc020429e:	8ab6                	mv	s5,a3
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc02042a0:	c931                	beqz	a0,ffffffffc02042f4 <mm_map+0x92>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start) {
ffffffffc02042a2:	85a6                	mv	a1,s1
ffffffffc02042a4:	e61ff0ef          	jal	ra,ffffffffc0204104 <find_vma>
ffffffffc02042a8:	c501                	beqz	a0,ffffffffc02042b0 <mm_map+0x4e>
ffffffffc02042aa:	651c                	ld	a5,8(a0)
ffffffffc02042ac:	0487e263          	bltu	a5,s0,ffffffffc02042f0 <mm_map+0x8e>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02042b0:	03000513          	li	a0,48
ffffffffc02042b4:	979fd0ef          	jal	ra,ffffffffc0201c2c <kmalloc>
ffffffffc02042b8:	892a                	mv	s2,a0
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc02042ba:	5571                	li	a0,-4
    if (vma != NULL) {
ffffffffc02042bc:	02090163          	beqz	s2,ffffffffc02042de <mm_map+0x7c>

    if ((vma = vma_create(start, end, vm_flags)) == NULL) {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc02042c0:	854e                	mv	a0,s3
        vma->vm_start = vm_start;
ffffffffc02042c2:	00993423          	sd	s1,8(s2)
        vma->vm_end = vm_end;
ffffffffc02042c6:	00893823          	sd	s0,16(s2)
        vma->vm_flags = vm_flags;
ffffffffc02042ca:	01592c23          	sw	s5,24(s2)
    insert_vma_struct(mm, vma);
ffffffffc02042ce:	85ca                	mv	a1,s2
ffffffffc02042d0:	e73ff0ef          	jal	ra,ffffffffc0204142 <insert_vma_struct>
    if (vma_store != NULL) {
        *vma_store = vma;
    }
    ret = 0;
ffffffffc02042d4:	4501                	li	a0,0
    if (vma_store != NULL) {
ffffffffc02042d6:	000a0463          	beqz	s4,ffffffffc02042de <mm_map+0x7c>
        *vma_store = vma;
ffffffffc02042da:	012a3023          	sd	s2,0(s4)

out:
    return ret;
}
ffffffffc02042de:	70e2                	ld	ra,56(sp)
ffffffffc02042e0:	7442                	ld	s0,48(sp)
ffffffffc02042e2:	74a2                	ld	s1,40(sp)
ffffffffc02042e4:	7902                	ld	s2,32(sp)
ffffffffc02042e6:	69e2                	ld	s3,24(sp)
ffffffffc02042e8:	6a42                	ld	s4,16(sp)
ffffffffc02042ea:	6aa2                	ld	s5,8(sp)
ffffffffc02042ec:	6121                	addi	sp,sp,64
ffffffffc02042ee:	8082                	ret
        return -E_INVAL;
ffffffffc02042f0:	5575                	li	a0,-3
ffffffffc02042f2:	b7f5                	j	ffffffffc02042de <mm_map+0x7c>
    assert(mm != NULL);
ffffffffc02042f4:	00004697          	auipc	a3,0x4
ffffffffc02042f8:	81468693          	addi	a3,a3,-2028 # ffffffffc0207b08 <default_pmm_manager+0x7f0>
ffffffffc02042fc:	00003617          	auipc	a2,0x3
ffffffffc0204300:	8d460613          	addi	a2,a2,-1836 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0204304:	0a700593          	li	a1,167
ffffffffc0204308:	00004517          	auipc	a0,0x4
ffffffffc020430c:	cc850513          	addi	a0,a0,-824 # ffffffffc0207fd0 <default_pmm_manager+0xcb8>
ffffffffc0204310:	970fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204314 <dup_mmap>:

int
dup_mmap(struct mm_struct *to, struct mm_struct *from) {
ffffffffc0204314:	7139                	addi	sp,sp,-64
ffffffffc0204316:	fc06                	sd	ra,56(sp)
ffffffffc0204318:	f822                	sd	s0,48(sp)
ffffffffc020431a:	f426                	sd	s1,40(sp)
ffffffffc020431c:	f04a                	sd	s2,32(sp)
ffffffffc020431e:	ec4e                	sd	s3,24(sp)
ffffffffc0204320:	e852                	sd	s4,16(sp)
ffffffffc0204322:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0204324:	c535                	beqz	a0,ffffffffc0204390 <dup_mmap+0x7c>
ffffffffc0204326:	892a                	mv	s2,a0
ffffffffc0204328:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc020432a:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc020432c:	e59d                	bnez	a1,ffffffffc020435a <dup_mmap+0x46>
ffffffffc020432e:	a08d                	j	ffffffffc0204390 <dup_mmap+0x7c>
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
        if (nvma == NULL) {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0204330:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc0204332:	0157b423          	sd	s5,8(a5) # 200008 <_binary_obj___user_exit_out_size+0x1f5538>
        insert_vma_struct(to, nvma);
ffffffffc0204336:	854a                	mv	a0,s2
        vma->vm_end = vm_end;
ffffffffc0204338:	0147b823          	sd	s4,16(a5)
        vma->vm_flags = vm_flags;
ffffffffc020433c:	0137ac23          	sw	s3,24(a5)
        insert_vma_struct(to, nvma);
ffffffffc0204340:	e03ff0ef          	jal	ra,ffffffffc0204142 <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0) {
ffffffffc0204344:	ff043683          	ld	a3,-16(s0)
ffffffffc0204348:	fe843603          	ld	a2,-24(s0)
ffffffffc020434c:	6c8c                	ld	a1,24(s1)
ffffffffc020434e:	01893503          	ld	a0,24(s2)
ffffffffc0204352:	4701                	li	a4,0
ffffffffc0204354:	d2ffe0ef          	jal	ra,ffffffffc0203082 <copy_range>
ffffffffc0204358:	e105                	bnez	a0,ffffffffc0204378 <dup_mmap+0x64>
    return listelm->prev;
ffffffffc020435a:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list) {
ffffffffc020435c:	02848863          	beq	s1,s0,ffffffffc020438c <dup_mmap+0x78>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204360:	03000513          	li	a0,48
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0204364:	fe843a83          	ld	s5,-24(s0)
ffffffffc0204368:	ff043a03          	ld	s4,-16(s0)
ffffffffc020436c:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204370:	8bdfd0ef          	jal	ra,ffffffffc0201c2c <kmalloc>
ffffffffc0204374:	87aa                	mv	a5,a0
    if (vma != NULL) {
ffffffffc0204376:	fd4d                	bnez	a0,ffffffffc0204330 <dup_mmap+0x1c>
            return -E_NO_MEM;
ffffffffc0204378:	5571                	li	a0,-4
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc020437a:	70e2                	ld	ra,56(sp)
ffffffffc020437c:	7442                	ld	s0,48(sp)
ffffffffc020437e:	74a2                	ld	s1,40(sp)
ffffffffc0204380:	7902                	ld	s2,32(sp)
ffffffffc0204382:	69e2                	ld	s3,24(sp)
ffffffffc0204384:	6a42                	ld	s4,16(sp)
ffffffffc0204386:	6aa2                	ld	s5,8(sp)
ffffffffc0204388:	6121                	addi	sp,sp,64
ffffffffc020438a:	8082                	ret
    return 0;
ffffffffc020438c:	4501                	li	a0,0
ffffffffc020438e:	b7f5                	j	ffffffffc020437a <dup_mmap+0x66>
    assert(to != NULL && from != NULL);
ffffffffc0204390:	00004697          	auipc	a3,0x4
ffffffffc0204394:	cf068693          	addi	a3,a3,-784 # ffffffffc0208080 <default_pmm_manager+0xd68>
ffffffffc0204398:	00003617          	auipc	a2,0x3
ffffffffc020439c:	83860613          	addi	a2,a2,-1992 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02043a0:	0c000593          	li	a1,192
ffffffffc02043a4:	00004517          	auipc	a0,0x4
ffffffffc02043a8:	c2c50513          	addi	a0,a0,-980 # ffffffffc0207fd0 <default_pmm_manager+0xcb8>
ffffffffc02043ac:	8d4fc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02043b0 <exit_mmap>:

void
exit_mmap(struct mm_struct *mm) {
ffffffffc02043b0:	1101                	addi	sp,sp,-32
ffffffffc02043b2:	ec06                	sd	ra,24(sp)
ffffffffc02043b4:	e822                	sd	s0,16(sp)
ffffffffc02043b6:	e426                	sd	s1,8(sp)
ffffffffc02043b8:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02043ba:	c531                	beqz	a0,ffffffffc0204406 <exit_mmap+0x56>
ffffffffc02043bc:	591c                	lw	a5,48(a0)
ffffffffc02043be:	84aa                	mv	s1,a0
ffffffffc02043c0:	e3b9                	bnez	a5,ffffffffc0204406 <exit_mmap+0x56>
    return listelm->next;
ffffffffc02043c2:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc02043c4:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list) {
ffffffffc02043c8:	02850663          	beq	a0,s0,ffffffffc02043f4 <exit_mmap+0x44>
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02043cc:	ff043603          	ld	a2,-16(s0)
ffffffffc02043d0:	fe843583          	ld	a1,-24(s0)
ffffffffc02043d4:	854a                	mv	a0,s2
ffffffffc02043d6:	d87fd0ef          	jal	ra,ffffffffc020215c <unmap_range>
ffffffffc02043da:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc02043dc:	fe8498e3          	bne	s1,s0,ffffffffc02043cc <exit_mmap+0x1c>
ffffffffc02043e0:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list) {
ffffffffc02043e2:	00848c63          	beq	s1,s0,ffffffffc02043fa <exit_mmap+0x4a>
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02043e6:	ff043603          	ld	a2,-16(s0)
ffffffffc02043ea:	fe843583          	ld	a1,-24(s0)
ffffffffc02043ee:	854a                	mv	a0,s2
ffffffffc02043f0:	e85fd0ef          	jal	ra,ffffffffc0202274 <exit_range>
ffffffffc02043f4:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list) {
ffffffffc02043f6:	fe8498e3          	bne	s1,s0,ffffffffc02043e6 <exit_mmap+0x36>
    }
}
ffffffffc02043fa:	60e2                	ld	ra,24(sp)
ffffffffc02043fc:	6442                	ld	s0,16(sp)
ffffffffc02043fe:	64a2                	ld	s1,8(sp)
ffffffffc0204400:	6902                	ld	s2,0(sp)
ffffffffc0204402:	6105                	addi	sp,sp,32
ffffffffc0204404:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0204406:	00004697          	auipc	a3,0x4
ffffffffc020440a:	c9a68693          	addi	a3,a3,-870 # ffffffffc02080a0 <default_pmm_manager+0xd88>
ffffffffc020440e:	00002617          	auipc	a2,0x2
ffffffffc0204412:	7c260613          	addi	a2,a2,1986 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0204416:	0d600593          	li	a1,214
ffffffffc020441a:	00004517          	auipc	a0,0x4
ffffffffc020441e:	bb650513          	addi	a0,a0,-1098 # ffffffffc0207fd0 <default_pmm_manager+0xcb8>
ffffffffc0204422:	85efc0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204426 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void
vmm_init(void) {
ffffffffc0204426:	7139                	addi	sp,sp,-64
ffffffffc0204428:	f822                	sd	s0,48(sp)
ffffffffc020442a:	f426                	sd	s1,40(sp)
ffffffffc020442c:	fc06                	sd	ra,56(sp)
ffffffffc020442e:	f04a                	sd	s2,32(sp)
ffffffffc0204430:	ec4e                	sd	s3,24(sp)
ffffffffc0204432:	e852                	sd	s4,16(sp)
ffffffffc0204434:	e456                	sd	s5,8(sp)

static void
check_vma_struct(void) {
    // size_t nr_free_pages_store = nr_free_pages();

    struct mm_struct *mm = mm_create();
ffffffffc0204436:	c55ff0ef          	jal	ra,ffffffffc020408a <mm_create>
    assert(mm != NULL);
ffffffffc020443a:	842a                	mv	s0,a0
ffffffffc020443c:	03200493          	li	s1,50
ffffffffc0204440:	e919                	bnez	a0,ffffffffc0204456 <vmm_init+0x30>
ffffffffc0204442:	a989                	j	ffffffffc0204894 <vmm_init+0x46e>
        vma->vm_start = vm_start;
ffffffffc0204444:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204446:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204448:	00052c23          	sw	zero,24(a0)

    int i;
    for (i = step1; i >= 1; i --) {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020444c:	14ed                	addi	s1,s1,-5
ffffffffc020444e:	8522                	mv	a0,s0
ffffffffc0204450:	cf3ff0ef          	jal	ra,ffffffffc0204142 <insert_vma_struct>
    for (i = step1; i >= 1; i --) {
ffffffffc0204454:	c88d                	beqz	s1,ffffffffc0204486 <vmm_init+0x60>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0204456:	03000513          	li	a0,48
ffffffffc020445a:	fd2fd0ef          	jal	ra,ffffffffc0201c2c <kmalloc>
ffffffffc020445e:	85aa                	mv	a1,a0
ffffffffc0204460:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc0204464:	f165                	bnez	a0,ffffffffc0204444 <vmm_init+0x1e>
        assert(vma != NULL);
ffffffffc0204466:	00003697          	auipc	a3,0x3
ffffffffc020446a:	6da68693          	addi	a3,a3,1754 # ffffffffc0207b40 <default_pmm_manager+0x828>
ffffffffc020446e:	00002617          	auipc	a2,0x2
ffffffffc0204472:	76260613          	addi	a2,a2,1890 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0204476:	11300593          	li	a1,275
ffffffffc020447a:	00004517          	auipc	a0,0x4
ffffffffc020447e:	b5650513          	addi	a0,a0,-1194 # ffffffffc0207fd0 <default_pmm_manager+0xcb8>
ffffffffc0204482:	ffffb0ef          	jal	ra,ffffffffc0200480 <__panic>
    for (i = step1; i >= 1; i --) {
ffffffffc0204486:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc020448a:	1f900913          	li	s2,505
ffffffffc020448e:	a819                	j	ffffffffc02044a4 <vmm_init+0x7e>
        vma->vm_start = vm_start;
ffffffffc0204490:	e504                	sd	s1,8(a0)
        vma->vm_end = vm_end;
ffffffffc0204492:	e91c                	sd	a5,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0204494:	00052c23          	sw	zero,24(a0)
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0204498:	0495                	addi	s1,s1,5
ffffffffc020449a:	8522                	mv	a0,s0
ffffffffc020449c:	ca7ff0ef          	jal	ra,ffffffffc0204142 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i ++) {
ffffffffc02044a0:	03248a63          	beq	s1,s2,ffffffffc02044d4 <vmm_init+0xae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02044a4:	03000513          	li	a0,48
ffffffffc02044a8:	f84fd0ef          	jal	ra,ffffffffc0201c2c <kmalloc>
ffffffffc02044ac:	85aa                	mv	a1,a0
ffffffffc02044ae:	00248793          	addi	a5,s1,2
    if (vma != NULL) {
ffffffffc02044b2:	fd79                	bnez	a0,ffffffffc0204490 <vmm_init+0x6a>
        assert(vma != NULL);
ffffffffc02044b4:	00003697          	auipc	a3,0x3
ffffffffc02044b8:	68c68693          	addi	a3,a3,1676 # ffffffffc0207b40 <default_pmm_manager+0x828>
ffffffffc02044bc:	00002617          	auipc	a2,0x2
ffffffffc02044c0:	71460613          	addi	a2,a2,1812 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02044c4:	11900593          	li	a1,281
ffffffffc02044c8:	00004517          	auipc	a0,0x4
ffffffffc02044cc:	b0850513          	addi	a0,a0,-1272 # ffffffffc0207fd0 <default_pmm_manager+0xcb8>
ffffffffc02044d0:	fb1fb0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc02044d4:	6418                	ld	a4,8(s0)
ffffffffc02044d6:	479d                	li	a5,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i ++) {
ffffffffc02044d8:	1fb00593          	li	a1,507
        assert(le != &(mm->mmap_list));
ffffffffc02044dc:	2ee40063          	beq	s0,a4,ffffffffc02047bc <vmm_init+0x396>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02044e0:	fe873603          	ld	a2,-24(a4)
ffffffffc02044e4:	ffe78693          	addi	a3,a5,-2
ffffffffc02044e8:	24d61a63          	bne	a2,a3,ffffffffc020473c <vmm_init+0x316>
ffffffffc02044ec:	ff073683          	ld	a3,-16(a4)
ffffffffc02044f0:	24f69663          	bne	a3,a5,ffffffffc020473c <vmm_init+0x316>
ffffffffc02044f4:	0795                	addi	a5,a5,5
ffffffffc02044f6:	6718                	ld	a4,8(a4)
    for (i = 1; i <= step2; i ++) {
ffffffffc02044f8:	feb792e3          	bne	a5,a1,ffffffffc02044dc <vmm_init+0xb6>
ffffffffc02044fc:	491d                	li	s2,7
ffffffffc02044fe:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc0204500:	1f900a93          	li	s5,505
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0204504:	85a6                	mv	a1,s1
ffffffffc0204506:	8522                	mv	a0,s0
ffffffffc0204508:	bfdff0ef          	jal	ra,ffffffffc0204104 <find_vma>
ffffffffc020450c:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc020450e:	30050763          	beqz	a0,ffffffffc020481c <vmm_init+0x3f6>
        struct vma_struct *vma2 = find_vma(mm, i+1);
ffffffffc0204512:	00148593          	addi	a1,s1,1
ffffffffc0204516:	8522                	mv	a0,s0
ffffffffc0204518:	bedff0ef          	jal	ra,ffffffffc0204104 <find_vma>
ffffffffc020451c:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc020451e:	2c050f63          	beqz	a0,ffffffffc02047fc <vmm_init+0x3d6>
        struct vma_struct *vma3 = find_vma(mm, i+2);
ffffffffc0204522:	85ca                	mv	a1,s2
ffffffffc0204524:	8522                	mv	a0,s0
ffffffffc0204526:	bdfff0ef          	jal	ra,ffffffffc0204104 <find_vma>
        assert(vma3 == NULL);
ffffffffc020452a:	2a051963          	bnez	a0,ffffffffc02047dc <vmm_init+0x3b6>
        struct vma_struct *vma4 = find_vma(mm, i+3);
ffffffffc020452e:	00348593          	addi	a1,s1,3
ffffffffc0204532:	8522                	mv	a0,s0
ffffffffc0204534:	bd1ff0ef          	jal	ra,ffffffffc0204104 <find_vma>
        assert(vma4 == NULL);
ffffffffc0204538:	32051263          	bnez	a0,ffffffffc020485c <vmm_init+0x436>
        struct vma_struct *vma5 = find_vma(mm, i+4);
ffffffffc020453c:	00448593          	addi	a1,s1,4
ffffffffc0204540:	8522                	mv	a0,s0
ffffffffc0204542:	bc3ff0ef          	jal	ra,ffffffffc0204104 <find_vma>
        assert(vma5 == NULL);
ffffffffc0204546:	2e051b63          	bnez	a0,ffffffffc020483c <vmm_init+0x416>

        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020454a:	008a3783          	ld	a5,8(s4)
ffffffffc020454e:	20979763          	bne	a5,s1,ffffffffc020475c <vmm_init+0x336>
ffffffffc0204552:	010a3783          	ld	a5,16(s4)
ffffffffc0204556:	21279363          	bne	a5,s2,ffffffffc020475c <vmm_init+0x336>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020455a:	0089b783          	ld	a5,8(s3)
ffffffffc020455e:	20979f63          	bne	a5,s1,ffffffffc020477c <vmm_init+0x356>
ffffffffc0204562:	0109b783          	ld	a5,16(s3)
ffffffffc0204566:	21279b63          	bne	a5,s2,ffffffffc020477c <vmm_init+0x356>
ffffffffc020456a:	0495                	addi	s1,s1,5
ffffffffc020456c:	0915                	addi	s2,s2,5
    for (i = 5; i <= 5 * step2; i +=5) {
ffffffffc020456e:	f9549be3          	bne	s1,s5,ffffffffc0204504 <vmm_init+0xde>
ffffffffc0204572:	4491                	li	s1,4
    }

    for (i =4; i>=0; i--) {
ffffffffc0204574:	597d                	li	s2,-1
        struct vma_struct *vma_below_5= find_vma(mm,i);
ffffffffc0204576:	85a6                	mv	a1,s1
ffffffffc0204578:	8522                	mv	a0,s0
ffffffffc020457a:	b8bff0ef          	jal	ra,ffffffffc0204104 <find_vma>
ffffffffc020457e:	0004859b          	sext.w	a1,s1
        if (vma_below_5 != NULL ) {
ffffffffc0204582:	c90d                	beqz	a0,ffffffffc02045b4 <vmm_init+0x18e>
           cprintf("vma_below_5: i %x, start %x, end %x\n",i, vma_below_5->vm_start, vma_below_5->vm_end); 
ffffffffc0204584:	6914                	ld	a3,16(a0)
ffffffffc0204586:	6510                	ld	a2,8(a0)
ffffffffc0204588:	00004517          	auipc	a0,0x4
ffffffffc020458c:	cb050513          	addi	a0,a0,-848 # ffffffffc0208238 <default_pmm_manager+0xf20>
ffffffffc0204590:	bfffb0ef          	jal	ra,ffffffffc020018e <cprintf>
        }
        assert(vma_below_5 == NULL);
ffffffffc0204594:	00004697          	auipc	a3,0x4
ffffffffc0204598:	ccc68693          	addi	a3,a3,-820 # ffffffffc0208260 <default_pmm_manager+0xf48>
ffffffffc020459c:	00002617          	auipc	a2,0x2
ffffffffc02045a0:	63460613          	addi	a2,a2,1588 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02045a4:	13b00593          	li	a1,315
ffffffffc02045a8:	00004517          	auipc	a0,0x4
ffffffffc02045ac:	a2850513          	addi	a0,a0,-1496 # ffffffffc0207fd0 <default_pmm_manager+0xcb8>
ffffffffc02045b0:	ed1fb0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc02045b4:	14fd                	addi	s1,s1,-1
    for (i =4; i>=0; i--) {
ffffffffc02045b6:	fd2490e3          	bne	s1,s2,ffffffffc0204576 <vmm_init+0x150>
    }

    mm_destroy(mm);
ffffffffc02045ba:	8522                	mv	a0,s0
ffffffffc02045bc:	c55ff0ef          	jal	ra,ffffffffc0204210 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc02045c0:	00004517          	auipc	a0,0x4
ffffffffc02045c4:	cb850513          	addi	a0,a0,-840 # ffffffffc0208278 <default_pmm_manager+0xf60>
ffffffffc02045c8:	bc7fb0ef          	jal	ra,ffffffffc020018e <cprintf>
struct mm_struct *check_mm_struct;

// check_pgfault - check correctness of pgfault handler
static void
check_pgfault(void) {
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc02045cc:	927fd0ef          	jal	ra,ffffffffc0201ef2 <nr_free_pages>
ffffffffc02045d0:	89aa                	mv	s3,a0

    check_mm_struct = mm_create();
ffffffffc02045d2:	ab9ff0ef          	jal	ra,ffffffffc020408a <mm_create>
ffffffffc02045d6:	000a8797          	auipc	a5,0xa8
ffffffffc02045da:	3ca7bd23          	sd	a0,986(a5) # ffffffffc02ac9b0 <check_mm_struct>
ffffffffc02045de:	84aa                	mv	s1,a0
    assert(check_mm_struct != NULL);
ffffffffc02045e0:	36050663          	beqz	a0,ffffffffc020494c <vmm_init+0x526>

    struct mm_struct *mm = check_mm_struct;
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02045e4:	000a8797          	auipc	a5,0xa8
ffffffffc02045e8:	27478793          	addi	a5,a5,628 # ffffffffc02ac858 <boot_pgdir>
ffffffffc02045ec:	0007b903          	ld	s2,0(a5)
    assert(pgdir[0] == 0);
ffffffffc02045f0:	00093783          	ld	a5,0(s2)
    pde_t *pgdir = mm->pgdir = boot_pgdir;
ffffffffc02045f4:	01253c23          	sd	s2,24(a0)
    assert(pgdir[0] == 0);
ffffffffc02045f8:	2c079e63          	bnez	a5,ffffffffc02048d4 <vmm_init+0x4ae>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02045fc:	03000513          	li	a0,48
ffffffffc0204600:	e2cfd0ef          	jal	ra,ffffffffc0201c2c <kmalloc>
ffffffffc0204604:	842a                	mv	s0,a0
    if (vma != NULL) {
ffffffffc0204606:	18050b63          	beqz	a0,ffffffffc020479c <vmm_init+0x376>
        vma->vm_end = vm_end;
ffffffffc020460a:	002007b7          	lui	a5,0x200
ffffffffc020460e:	e81c                	sd	a5,16(s0)
        vma->vm_flags = vm_flags;
ffffffffc0204610:	4789                	li	a5,2

    struct vma_struct *vma = vma_create(0, PTSIZE, VM_WRITE);
    assert(vma != NULL);

    insert_vma_struct(mm, vma);
ffffffffc0204612:	85aa                	mv	a1,a0
        vma->vm_flags = vm_flags;
ffffffffc0204614:	cc1c                	sw	a5,24(s0)
    insert_vma_struct(mm, vma);
ffffffffc0204616:	8526                	mv	a0,s1
        vma->vm_start = vm_start;
ffffffffc0204618:	00043423          	sd	zero,8(s0)
    insert_vma_struct(mm, vma);
ffffffffc020461c:	b27ff0ef          	jal	ra,ffffffffc0204142 <insert_vma_struct>

    uintptr_t addr = 0x100;
    assert(find_vma(mm, addr) == vma);
ffffffffc0204620:	10000593          	li	a1,256
ffffffffc0204624:	8526                	mv	a0,s1
ffffffffc0204626:	adfff0ef          	jal	ra,ffffffffc0204104 <find_vma>
ffffffffc020462a:	10000793          	li	a5,256

    int i, sum = 0;

    for (i = 0; i < 100; i ++) {
ffffffffc020462e:	16400713          	li	a4,356
    assert(find_vma(mm, addr) == vma);
ffffffffc0204632:	2ca41163          	bne	s0,a0,ffffffffc02048f4 <vmm_init+0x4ce>
        *(char *)(addr + i) = i;
ffffffffc0204636:	00f78023          	sb	a5,0(a5) # 200000 <_binary_obj___user_exit_out_size+0x1f5530>
        sum += i;
ffffffffc020463a:	0785                	addi	a5,a5,1
    for (i = 0; i < 100; i ++) {
ffffffffc020463c:	fee79de3          	bne	a5,a4,ffffffffc0204636 <vmm_init+0x210>
        sum += i;
ffffffffc0204640:	6705                	lui	a4,0x1
    for (i = 0; i < 100; i ++) {
ffffffffc0204642:	10000793          	li	a5,256
        sum += i;
ffffffffc0204646:	35670713          	addi	a4,a4,854 # 1356 <_binary_obj___user_faultread_out_size-0x8272>
    }
    for (i = 0; i < 100; i ++) {
ffffffffc020464a:	16400613          	li	a2,356
        sum -= *(char *)(addr + i);
ffffffffc020464e:	0007c683          	lbu	a3,0(a5)
ffffffffc0204652:	0785                	addi	a5,a5,1
ffffffffc0204654:	9f15                	subw	a4,a4,a3
    for (i = 0; i < 100; i ++) {
ffffffffc0204656:	fec79ce3          	bne	a5,a2,ffffffffc020464e <vmm_init+0x228>
    }

    assert(sum == 0);
ffffffffc020465a:	2c071963          	bnez	a4,ffffffffc020492c <vmm_init+0x506>
    return pa2page(PDE_ADDR(pde));
ffffffffc020465e:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc0204662:	000a8a97          	auipc	s5,0xa8
ffffffffc0204666:	1fea8a93          	addi	s5,s5,510 # ffffffffc02ac860 <npage>
ffffffffc020466a:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020466e:	078a                	slli	a5,a5,0x2
ffffffffc0204670:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc0204672:	20e7f563          	bgeu	a5,a4,ffffffffc020487c <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc0204676:	00004697          	auipc	a3,0x4
ffffffffc020467a:	64268693          	addi	a3,a3,1602 # ffffffffc0208cb8 <nbase>
ffffffffc020467e:	0006ba03          	ld	s4,0(a3)
ffffffffc0204682:	414786b3          	sub	a3,a5,s4
ffffffffc0204686:	069a                	slli	a3,a3,0x6
    return page - pages + nbase;
ffffffffc0204688:	8699                	srai	a3,a3,0x6
ffffffffc020468a:	96d2                	add	a3,a3,s4
    return KADDR(page2pa(page));
ffffffffc020468c:	00c69793          	slli	a5,a3,0xc
ffffffffc0204690:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0204692:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204694:	28e7f063          	bgeu	a5,a4,ffffffffc0204914 <vmm_init+0x4ee>
ffffffffc0204698:	000a8797          	auipc	a5,0xa8
ffffffffc020469c:	22878793          	addi	a5,a5,552 # ffffffffc02ac8c0 <va_pa_offset>
ffffffffc02046a0:	6380                	ld	s0,0(a5)

    pde_t *pd1=pgdir,*pd0=page2kva(pde2page(pgdir[0]));
    page_remove(pgdir, ROUNDDOWN(addr, PGSIZE));
ffffffffc02046a2:	4581                	li	a1,0
ffffffffc02046a4:	854a                	mv	a0,s2
ffffffffc02046a6:	9436                	add	s0,s0,a3
ffffffffc02046a8:	e23fd0ef          	jal	ra,ffffffffc02024ca <page_remove>
    return pa2page(PDE_ADDR(pde));
ffffffffc02046ac:	601c                	ld	a5,0(s0)
    if (PPN(pa) >= npage) {
ffffffffc02046ae:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02046b2:	078a                	slli	a5,a5,0x2
ffffffffc02046b4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02046b6:	1ce7f363          	bgeu	a5,a4,ffffffffc020487c <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02046ba:	000a8417          	auipc	s0,0xa8
ffffffffc02046be:	21640413          	addi	s0,s0,534 # ffffffffc02ac8d0 <pages>
ffffffffc02046c2:	6008                	ld	a0,0(s0)
ffffffffc02046c4:	414787b3          	sub	a5,a5,s4
ffffffffc02046c8:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd0[0]));
ffffffffc02046ca:	953e                	add	a0,a0,a5
ffffffffc02046cc:	4585                	li	a1,1
ffffffffc02046ce:	fdefd0ef          	jal	ra,ffffffffc0201eac <free_pages>
    return pa2page(PDE_ADDR(pde));
ffffffffc02046d2:	00093783          	ld	a5,0(s2)
    if (PPN(pa) >= npage) {
ffffffffc02046d6:	000ab703          	ld	a4,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02046da:	078a                	slli	a5,a5,0x2
ffffffffc02046dc:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage) {
ffffffffc02046de:	18e7ff63          	bgeu	a5,a4,ffffffffc020487c <vmm_init+0x456>
    return &pages[PPN(pa) - nbase];
ffffffffc02046e2:	6008                	ld	a0,0(s0)
ffffffffc02046e4:	414787b3          	sub	a5,a5,s4
ffffffffc02046e8:	079a                	slli	a5,a5,0x6
    free_page(pde2page(pd1[0]));
ffffffffc02046ea:	4585                	li	a1,1
ffffffffc02046ec:	953e                	add	a0,a0,a5
ffffffffc02046ee:	fbefd0ef          	jal	ra,ffffffffc0201eac <free_pages>
    pgdir[0] = 0;
ffffffffc02046f2:	00093023          	sd	zero,0(s2)
  asm volatile("sfence.vma");
ffffffffc02046f6:	12000073          	sfence.vma
    flush_tlb();

    mm->pgdir = NULL;
ffffffffc02046fa:	0004bc23          	sd	zero,24(s1)
    mm_destroy(mm);
ffffffffc02046fe:	8526                	mv	a0,s1
ffffffffc0204700:	b11ff0ef          	jal	ra,ffffffffc0204210 <mm_destroy>
    check_mm_struct = NULL;
ffffffffc0204704:	000a8797          	auipc	a5,0xa8
ffffffffc0204708:	2a07b623          	sd	zero,684(a5) # ffffffffc02ac9b0 <check_mm_struct>

    assert(nr_free_pages_store == nr_free_pages());
ffffffffc020470c:	fe6fd0ef          	jal	ra,ffffffffc0201ef2 <nr_free_pages>
ffffffffc0204710:	1aa99263          	bne	s3,a0,ffffffffc02048b4 <vmm_init+0x48e>

    cprintf("check_pgfault() succeeded!\n");
ffffffffc0204714:	00004517          	auipc	a0,0x4
ffffffffc0204718:	bf450513          	addi	a0,a0,-1036 # ffffffffc0208308 <default_pmm_manager+0xff0>
ffffffffc020471c:	a73fb0ef          	jal	ra,ffffffffc020018e <cprintf>
}
ffffffffc0204720:	7442                	ld	s0,48(sp)
ffffffffc0204722:	70e2                	ld	ra,56(sp)
ffffffffc0204724:	74a2                	ld	s1,40(sp)
ffffffffc0204726:	7902                	ld	s2,32(sp)
ffffffffc0204728:	69e2                	ld	s3,24(sp)
ffffffffc020472a:	6a42                	ld	s4,16(sp)
ffffffffc020472c:	6aa2                	ld	s5,8(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc020472e:	00004517          	auipc	a0,0x4
ffffffffc0204732:	bfa50513          	addi	a0,a0,-1030 # ffffffffc0208328 <default_pmm_manager+0x1010>
}
ffffffffc0204736:	6121                	addi	sp,sp,64
    cprintf("check_vmm() succeeded.\n");
ffffffffc0204738:	a57fb06f          	j	ffffffffc020018e <cprintf>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc020473c:	00004697          	auipc	a3,0x4
ffffffffc0204740:	a1468693          	addi	a3,a3,-1516 # ffffffffc0208150 <default_pmm_manager+0xe38>
ffffffffc0204744:	00002617          	auipc	a2,0x2
ffffffffc0204748:	48c60613          	addi	a2,a2,1164 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020474c:	12200593          	li	a1,290
ffffffffc0204750:	00004517          	auipc	a0,0x4
ffffffffc0204754:	88050513          	addi	a0,a0,-1920 # ffffffffc0207fd0 <default_pmm_manager+0xcb8>
ffffffffc0204758:	d29fb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(vma1->vm_start == i  && vma1->vm_end == i  + 2);
ffffffffc020475c:	00004697          	auipc	a3,0x4
ffffffffc0204760:	a7c68693          	addi	a3,a3,-1412 # ffffffffc02081d8 <default_pmm_manager+0xec0>
ffffffffc0204764:	00002617          	auipc	a2,0x2
ffffffffc0204768:	46c60613          	addi	a2,a2,1132 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020476c:	13200593          	li	a1,306
ffffffffc0204770:	00004517          	auipc	a0,0x4
ffffffffc0204774:	86050513          	addi	a0,a0,-1952 # ffffffffc0207fd0 <default_pmm_manager+0xcb8>
ffffffffc0204778:	d09fb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(vma2->vm_start == i  && vma2->vm_end == i  + 2);
ffffffffc020477c:	00004697          	auipc	a3,0x4
ffffffffc0204780:	a8c68693          	addi	a3,a3,-1396 # ffffffffc0208208 <default_pmm_manager+0xef0>
ffffffffc0204784:	00002617          	auipc	a2,0x2
ffffffffc0204788:	44c60613          	addi	a2,a2,1100 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020478c:	13300593          	li	a1,307
ffffffffc0204790:	00004517          	auipc	a0,0x4
ffffffffc0204794:	84050513          	addi	a0,a0,-1984 # ffffffffc0207fd0 <default_pmm_manager+0xcb8>
ffffffffc0204798:	ce9fb0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(vma != NULL);
ffffffffc020479c:	00003697          	auipc	a3,0x3
ffffffffc02047a0:	3a468693          	addi	a3,a3,932 # ffffffffc0207b40 <default_pmm_manager+0x828>
ffffffffc02047a4:	00002617          	auipc	a2,0x2
ffffffffc02047a8:	42c60613          	addi	a2,a2,1068 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02047ac:	15200593          	li	a1,338
ffffffffc02047b0:	00004517          	auipc	a0,0x4
ffffffffc02047b4:	82050513          	addi	a0,a0,-2016 # ffffffffc0207fd0 <default_pmm_manager+0xcb8>
ffffffffc02047b8:	cc9fb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc02047bc:	00004697          	auipc	a3,0x4
ffffffffc02047c0:	97c68693          	addi	a3,a3,-1668 # ffffffffc0208138 <default_pmm_manager+0xe20>
ffffffffc02047c4:	00002617          	auipc	a2,0x2
ffffffffc02047c8:	40c60613          	addi	a2,a2,1036 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02047cc:	12000593          	li	a1,288
ffffffffc02047d0:	00004517          	auipc	a0,0x4
ffffffffc02047d4:	80050513          	addi	a0,a0,-2048 # ffffffffc0207fd0 <default_pmm_manager+0xcb8>
ffffffffc02047d8:	ca9fb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(vma3 == NULL);
ffffffffc02047dc:	00004697          	auipc	a3,0x4
ffffffffc02047e0:	9cc68693          	addi	a3,a3,-1588 # ffffffffc02081a8 <default_pmm_manager+0xe90>
ffffffffc02047e4:	00002617          	auipc	a2,0x2
ffffffffc02047e8:	3ec60613          	addi	a2,a2,1004 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02047ec:	12c00593          	li	a1,300
ffffffffc02047f0:	00003517          	auipc	a0,0x3
ffffffffc02047f4:	7e050513          	addi	a0,a0,2016 # ffffffffc0207fd0 <default_pmm_manager+0xcb8>
ffffffffc02047f8:	c89fb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(vma2 != NULL);
ffffffffc02047fc:	00004697          	auipc	a3,0x4
ffffffffc0204800:	99c68693          	addi	a3,a3,-1636 # ffffffffc0208198 <default_pmm_manager+0xe80>
ffffffffc0204804:	00002617          	auipc	a2,0x2
ffffffffc0204808:	3cc60613          	addi	a2,a2,972 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020480c:	12a00593          	li	a1,298
ffffffffc0204810:	00003517          	auipc	a0,0x3
ffffffffc0204814:	7c050513          	addi	a0,a0,1984 # ffffffffc0207fd0 <default_pmm_manager+0xcb8>
ffffffffc0204818:	c69fb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(vma1 != NULL);
ffffffffc020481c:	00004697          	auipc	a3,0x4
ffffffffc0204820:	96c68693          	addi	a3,a3,-1684 # ffffffffc0208188 <default_pmm_manager+0xe70>
ffffffffc0204824:	00002617          	auipc	a2,0x2
ffffffffc0204828:	3ac60613          	addi	a2,a2,940 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020482c:	12800593          	li	a1,296
ffffffffc0204830:	00003517          	auipc	a0,0x3
ffffffffc0204834:	7a050513          	addi	a0,a0,1952 # ffffffffc0207fd0 <default_pmm_manager+0xcb8>
ffffffffc0204838:	c49fb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(vma5 == NULL);
ffffffffc020483c:	00004697          	auipc	a3,0x4
ffffffffc0204840:	98c68693          	addi	a3,a3,-1652 # ffffffffc02081c8 <default_pmm_manager+0xeb0>
ffffffffc0204844:	00002617          	auipc	a2,0x2
ffffffffc0204848:	38c60613          	addi	a2,a2,908 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020484c:	13000593          	li	a1,304
ffffffffc0204850:	00003517          	auipc	a0,0x3
ffffffffc0204854:	78050513          	addi	a0,a0,1920 # ffffffffc0207fd0 <default_pmm_manager+0xcb8>
ffffffffc0204858:	c29fb0ef          	jal	ra,ffffffffc0200480 <__panic>
        assert(vma4 == NULL);
ffffffffc020485c:	00004697          	auipc	a3,0x4
ffffffffc0204860:	95c68693          	addi	a3,a3,-1700 # ffffffffc02081b8 <default_pmm_manager+0xea0>
ffffffffc0204864:	00002617          	auipc	a2,0x2
ffffffffc0204868:	36c60613          	addi	a2,a2,876 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020486c:	12e00593          	li	a1,302
ffffffffc0204870:	00003517          	auipc	a0,0x3
ffffffffc0204874:	76050513          	addi	a0,a0,1888 # ffffffffc0207fd0 <default_pmm_manager+0xcb8>
ffffffffc0204878:	c09fb0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020487c:	00003617          	auipc	a2,0x3
ffffffffc0204880:	b4c60613          	addi	a2,a2,-1204 # ffffffffc02073c8 <default_pmm_manager+0xb0>
ffffffffc0204884:	06200593          	li	a1,98
ffffffffc0204888:	00003517          	auipc	a0,0x3
ffffffffc020488c:	b0850513          	addi	a0,a0,-1272 # ffffffffc0207390 <default_pmm_manager+0x78>
ffffffffc0204890:	bf1fb0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(mm != NULL);
ffffffffc0204894:	00003697          	auipc	a3,0x3
ffffffffc0204898:	27468693          	addi	a3,a3,628 # ffffffffc0207b08 <default_pmm_manager+0x7f0>
ffffffffc020489c:	00002617          	auipc	a2,0x2
ffffffffc02048a0:	33460613          	addi	a2,a2,820 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02048a4:	10c00593          	li	a1,268
ffffffffc02048a8:	00003517          	auipc	a0,0x3
ffffffffc02048ac:	72850513          	addi	a0,a0,1832 # ffffffffc0207fd0 <default_pmm_manager+0xcb8>
ffffffffc02048b0:	bd1fb0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(nr_free_pages_store == nr_free_pages());
ffffffffc02048b4:	00004697          	auipc	a3,0x4
ffffffffc02048b8:	a2c68693          	addi	a3,a3,-1492 # ffffffffc02082e0 <default_pmm_manager+0xfc8>
ffffffffc02048bc:	00002617          	auipc	a2,0x2
ffffffffc02048c0:	31460613          	addi	a2,a2,788 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02048c4:	17000593          	li	a1,368
ffffffffc02048c8:	00003517          	auipc	a0,0x3
ffffffffc02048cc:	70850513          	addi	a0,a0,1800 # ffffffffc0207fd0 <default_pmm_manager+0xcb8>
ffffffffc02048d0:	bb1fb0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgdir[0] == 0);
ffffffffc02048d4:	00003697          	auipc	a3,0x3
ffffffffc02048d8:	25c68693          	addi	a3,a3,604 # ffffffffc0207b30 <default_pmm_manager+0x818>
ffffffffc02048dc:	00002617          	auipc	a2,0x2
ffffffffc02048e0:	2f460613          	addi	a2,a2,756 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02048e4:	14f00593          	li	a1,335
ffffffffc02048e8:	00003517          	auipc	a0,0x3
ffffffffc02048ec:	6e850513          	addi	a0,a0,1768 # ffffffffc0207fd0 <default_pmm_manager+0xcb8>
ffffffffc02048f0:	b91fb0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(find_vma(mm, addr) == vma);
ffffffffc02048f4:	00004697          	auipc	a3,0x4
ffffffffc02048f8:	9bc68693          	addi	a3,a3,-1604 # ffffffffc02082b0 <default_pmm_manager+0xf98>
ffffffffc02048fc:	00002617          	auipc	a2,0x2
ffffffffc0204900:	2d460613          	addi	a2,a2,724 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0204904:	15700593          	li	a1,343
ffffffffc0204908:	00003517          	auipc	a0,0x3
ffffffffc020490c:	6c850513          	addi	a0,a0,1736 # ffffffffc0207fd0 <default_pmm_manager+0xcb8>
ffffffffc0204910:	b71fb0ef          	jal	ra,ffffffffc0200480 <__panic>
    return KADDR(page2pa(page));
ffffffffc0204914:	00003617          	auipc	a2,0x3
ffffffffc0204918:	a5460613          	addi	a2,a2,-1452 # ffffffffc0207368 <default_pmm_manager+0x50>
ffffffffc020491c:	06900593          	li	a1,105
ffffffffc0204920:	00003517          	auipc	a0,0x3
ffffffffc0204924:	a7050513          	addi	a0,a0,-1424 # ffffffffc0207390 <default_pmm_manager+0x78>
ffffffffc0204928:	b59fb0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(sum == 0);
ffffffffc020492c:	00004697          	auipc	a3,0x4
ffffffffc0204930:	9a468693          	addi	a3,a3,-1628 # ffffffffc02082d0 <default_pmm_manager+0xfb8>
ffffffffc0204934:	00002617          	auipc	a2,0x2
ffffffffc0204938:	29c60613          	addi	a2,a2,668 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020493c:	16300593          	li	a1,355
ffffffffc0204940:	00003517          	auipc	a0,0x3
ffffffffc0204944:	69050513          	addi	a0,a0,1680 # ffffffffc0207fd0 <default_pmm_manager+0xcb8>
ffffffffc0204948:	b39fb0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(check_mm_struct != NULL);
ffffffffc020494c:	00004697          	auipc	a3,0x4
ffffffffc0204950:	94c68693          	addi	a3,a3,-1716 # ffffffffc0208298 <default_pmm_manager+0xf80>
ffffffffc0204954:	00002617          	auipc	a2,0x2
ffffffffc0204958:	27c60613          	addi	a2,a2,636 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc020495c:	14b00593          	li	a1,331
ffffffffc0204960:	00003517          	auipc	a0,0x3
ffffffffc0204964:	67050513          	addi	a0,a0,1648 # ffffffffc0207fd0 <default_pmm_manager+0xcb8>
ffffffffc0204968:	b19fb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc020496c <do_pgfault>:
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc020496c:	7139                	addi	sp,sp,-64
    int ret = -E_INVAL;
    //try to find a vma which include addr
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020496e:	85b2                	mv	a1,a2
do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0204970:	f822                	sd	s0,48(sp)
ffffffffc0204972:	f426                	sd	s1,40(sp)
ffffffffc0204974:	fc06                	sd	ra,56(sp)
ffffffffc0204976:	f04a                	sd	s2,32(sp)
ffffffffc0204978:	ec4e                	sd	s3,24(sp)
ffffffffc020497a:	8432                	mv	s0,a2
ffffffffc020497c:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc020497e:	f86ff0ef          	jal	ra,ffffffffc0204104 <find_vma>

    pgfault_num++;
ffffffffc0204982:	000a8797          	auipc	a5,0xa8
ffffffffc0204986:	ef278793          	addi	a5,a5,-270 # ffffffffc02ac874 <pgfault_num>
ffffffffc020498a:	439c                	lw	a5,0(a5)
ffffffffc020498c:	2785                	addiw	a5,a5,1
ffffffffc020498e:	000a8717          	auipc	a4,0xa8
ffffffffc0204992:	eef72323          	sw	a5,-282(a4) # ffffffffc02ac874 <pgfault_num>
    //If the addr is in the range of a mm's vma?
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0204996:	c145                	beqz	a0,ffffffffc0204a36 <do_pgfault+0xca>
ffffffffc0204998:	651c                	ld	a5,8(a0)
ffffffffc020499a:	08f46e63          	bltu	s0,a5,ffffffffc0204a36 <do_pgfault+0xca>
     *    (read  an non_existed addr && addr is readable)
     * THEN
     *    continue process
     */
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc020499e:	4d1c                	lw	a5,24(a0)
    uint32_t perm = PTE_U;
ffffffffc02049a0:	49c1                	li	s3,16
    if (vma->vm_flags & VM_WRITE) {
ffffffffc02049a2:	8b89                	andi	a5,a5,2
ffffffffc02049a4:	e3b1                	bnez	a5,ffffffffc02049e8 <do_pgfault+0x7c>
        perm |= READ_WRITE;
    }
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02049a6:	767d                	lui	a2,0xfffff

    pte_t *ptep=NULL;
  
    // try to find a pte, if pte's PT(Page Table) isn't existed, then create a PT.
    // (notice the 3th parameter '1')
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02049a8:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc02049aa:	8c71                	and	s0,s0,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc02049ac:	85a2                	mv	a1,s0
ffffffffc02049ae:	4605                	li	a2,1
ffffffffc02049b0:	d82fd0ef          	jal	ra,ffffffffc0201f32 <get_pte>
ffffffffc02049b4:	c155                	beqz	a0,ffffffffc0204a58 <do_pgfault+0xec>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) { // if the phy addr isn't exist, then alloc a page & map the phy addr with logical addr
ffffffffc02049b6:	610c                	ld	a1,0(a0)
ffffffffc02049b8:	c1a5                	beqz	a1,ffffffffc0204a18 <do_pgfault+0xac>
        *    swap_in(mm, addr, &page) : 分配一个内存页，然后根据
        *    PTE中的swap条目的addr，找到磁盘页的地址，将磁盘页的内容读入这个内存页
        *    page_insert ： 建立一个Page的phy addr与线性addr la的映射
        *    swap_map_swappable ： 设置页面可交换
        */
        if (swap_init_ok) {
ffffffffc02049ba:	000a8797          	auipc	a5,0xa8
ffffffffc02049be:	eb678793          	addi	a5,a5,-330 # ffffffffc02ac870 <swap_init_ok>
ffffffffc02049c2:	439c                	lw	a5,0(a5)
ffffffffc02049c4:	2781                	sext.w	a5,a5
ffffffffc02049c6:	c3c9                	beqz	a5,ffffffffc0204a48 <do_pgfault+0xdc>
            //(2) According to the mm,
            //addr AND page, setup the
            //map of phy addr <--->
            //logical addr
            //(3) make the page swappable.
            if((ret = swap_in(mm,addr,&page)) != 0) {
ffffffffc02049c8:	0030                	addi	a2,sp,8
ffffffffc02049ca:	85a2                	mv	a1,s0
ffffffffc02049cc:	8526                	mv	a0,s1
            struct Page *page = NULL;
ffffffffc02049ce:	e402                	sd	zero,8(sp)
            if((ret = swap_in(mm,addr,&page)) != 0) {
ffffffffc02049d0:	a34ff0ef          	jal	ra,ffffffffc0203c04 <swap_in>
ffffffffc02049d4:	892a                	mv	s2,a0
ffffffffc02049d6:	c919                	beqz	a0,ffffffffc02049ec <do_pgfault+0x80>
        }
   }
   ret = 0;
failed:
    return ret;
}
ffffffffc02049d8:	70e2                	ld	ra,56(sp)
ffffffffc02049da:	7442                	ld	s0,48(sp)
ffffffffc02049dc:	854a                	mv	a0,s2
ffffffffc02049de:	74a2                	ld	s1,40(sp)
ffffffffc02049e0:	7902                	ld	s2,32(sp)
ffffffffc02049e2:	69e2                	ld	s3,24(sp)
ffffffffc02049e4:	6121                	addi	sp,sp,64
ffffffffc02049e6:	8082                	ret
        perm |= READ_WRITE;
ffffffffc02049e8:	49dd                	li	s3,23
ffffffffc02049ea:	bf75                	j	ffffffffc02049a6 <do_pgfault+0x3a>
            page_insert(mm->pgdir,page,addr,perm);
ffffffffc02049ec:	65a2                	ld	a1,8(sp)
ffffffffc02049ee:	6c88                	ld	a0,24(s1)
ffffffffc02049f0:	86ce                	mv	a3,s3
ffffffffc02049f2:	8622                	mv	a2,s0
ffffffffc02049f4:	b4bfd0ef          	jal	ra,ffffffffc020253e <page_insert>
            swap_map_swappable(mm,addr,page,1);
ffffffffc02049f8:	6622                	ld	a2,8(sp)
ffffffffc02049fa:	85a2                	mv	a1,s0
ffffffffc02049fc:	8526                	mv	a0,s1
ffffffffc02049fe:	4685                	li	a3,1
ffffffffc0204a00:	8e0ff0ef          	jal	ra,ffffffffc0203ae0 <swap_map_swappable>
            page->pra_vaddr = addr;
ffffffffc0204a04:	67a2                	ld	a5,8(sp)
}
ffffffffc0204a06:	70e2                	ld	ra,56(sp)
ffffffffc0204a08:	854a                	mv	a0,s2
            page->pra_vaddr = addr;
ffffffffc0204a0a:	ff80                	sd	s0,56(a5)
}
ffffffffc0204a0c:	7442                	ld	s0,48(sp)
ffffffffc0204a0e:	74a2                	ld	s1,40(sp)
ffffffffc0204a10:	7902                	ld	s2,32(sp)
ffffffffc0204a12:	69e2                	ld	s3,24(sp)
ffffffffc0204a14:	6121                	addi	sp,sp,64
ffffffffc0204a16:	8082                	ret
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204a18:	6c88                	ld	a0,24(s1)
ffffffffc0204a1a:	864e                	mv	a2,s3
ffffffffc0204a1c:	85a2                	mv	a1,s0
ffffffffc0204a1e:	89ffe0ef          	jal	ra,ffffffffc02032bc <pgdir_alloc_page>
   ret = 0;
ffffffffc0204a22:	4901                	li	s2,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0204a24:	f955                	bnez	a0,ffffffffc02049d8 <do_pgfault+0x6c>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0204a26:	00003517          	auipc	a0,0x3
ffffffffc0204a2a:	60a50513          	addi	a0,a0,1546 # ffffffffc0208030 <default_pmm_manager+0xd18>
ffffffffc0204a2e:	f60fb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204a32:	5971                	li	s2,-4
            goto failed;
ffffffffc0204a34:	b755                	j	ffffffffc02049d8 <do_pgfault+0x6c>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0204a36:	85a2                	mv	a1,s0
ffffffffc0204a38:	00003517          	auipc	a0,0x3
ffffffffc0204a3c:	5a850513          	addi	a0,a0,1448 # ffffffffc0207fe0 <default_pmm_manager+0xcc8>
ffffffffc0204a40:	f4efb0ef          	jal	ra,ffffffffc020018e <cprintf>
    int ret = -E_INVAL;
ffffffffc0204a44:	5975                	li	s2,-3
        goto failed;
ffffffffc0204a46:	bf49                	j	ffffffffc02049d8 <do_pgfault+0x6c>
            cprintf("no swap_init_ok but ptep is %x, failed\n", *ptep);
ffffffffc0204a48:	00003517          	auipc	a0,0x3
ffffffffc0204a4c:	61050513          	addi	a0,a0,1552 # ffffffffc0208058 <default_pmm_manager+0xd40>
ffffffffc0204a50:	f3efb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204a54:	5971                	li	s2,-4
            goto failed;
ffffffffc0204a56:	b749                	j	ffffffffc02049d8 <do_pgfault+0x6c>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0204a58:	00003517          	auipc	a0,0x3
ffffffffc0204a5c:	5b850513          	addi	a0,a0,1464 # ffffffffc0208010 <default_pmm_manager+0xcf8>
ffffffffc0204a60:	f2efb0ef          	jal	ra,ffffffffc020018e <cprintf>
    ret = -E_NO_MEM;
ffffffffc0204a64:	5971                	li	s2,-4
        goto failed;
ffffffffc0204a66:	bf8d                	j	ffffffffc02049d8 <do_pgfault+0x6c>

ffffffffc0204a68 <user_mem_check>:

bool
user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write) {
ffffffffc0204a68:	7179                	addi	sp,sp,-48
ffffffffc0204a6a:	f022                	sd	s0,32(sp)
ffffffffc0204a6c:	f406                	sd	ra,40(sp)
ffffffffc0204a6e:	ec26                	sd	s1,24(sp)
ffffffffc0204a70:	e84a                	sd	s2,16(sp)
ffffffffc0204a72:	e44e                	sd	s3,8(sp)
ffffffffc0204a74:	e052                	sd	s4,0(sp)
ffffffffc0204a76:	842e                	mv	s0,a1
    if (mm != NULL) {
ffffffffc0204a78:	c135                	beqz	a0,ffffffffc0204adc <user_mem_check+0x74>
        if (!USER_ACCESS(addr, addr + len)) {
ffffffffc0204a7a:	002007b7          	lui	a5,0x200
ffffffffc0204a7e:	04f5e663          	bltu	a1,a5,ffffffffc0204aca <user_mem_check+0x62>
ffffffffc0204a82:	00c584b3          	add	s1,a1,a2
ffffffffc0204a86:	0495f263          	bgeu	a1,s1,ffffffffc0204aca <user_mem_check+0x62>
ffffffffc0204a8a:	4785                	li	a5,1
ffffffffc0204a8c:	07fe                	slli	a5,a5,0x1f
ffffffffc0204a8e:	0297ee63          	bltu	a5,s1,ffffffffc0204aca <user_mem_check+0x62>
ffffffffc0204a92:	892a                	mv	s2,a0
ffffffffc0204a94:	89b6                	mv	s3,a3
            }
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK)) {
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204a96:	6a05                	lui	s4,0x1
ffffffffc0204a98:	a821                	j	ffffffffc0204ab0 <user_mem_check+0x48>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204a9a:	0027f693          	andi	a3,a5,2
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204a9e:	9752                	add	a4,a4,s4
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204aa0:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204aa2:	c685                	beqz	a3,ffffffffc0204aca <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK)) {
ffffffffc0204aa4:	c399                	beqz	a5,ffffffffc0204aaa <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE) { //check stack start & size
ffffffffc0204aa6:	02e46263          	bltu	s0,a4,ffffffffc0204aca <user_mem_check+0x62>
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0204aaa:	6900                	ld	s0,16(a0)
        while (start < end) {
ffffffffc0204aac:	04947663          	bgeu	s0,s1,ffffffffc0204af8 <user_mem_check+0x90>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start) {
ffffffffc0204ab0:	85a2                	mv	a1,s0
ffffffffc0204ab2:	854a                	mv	a0,s2
ffffffffc0204ab4:	e50ff0ef          	jal	ra,ffffffffc0204104 <find_vma>
ffffffffc0204ab8:	c909                	beqz	a0,ffffffffc0204aca <user_mem_check+0x62>
ffffffffc0204aba:	6518                	ld	a4,8(a0)
ffffffffc0204abc:	00e46763          	bltu	s0,a4,ffffffffc0204aca <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ))) {
ffffffffc0204ac0:	4d1c                	lw	a5,24(a0)
ffffffffc0204ac2:	fc099ce3          	bnez	s3,ffffffffc0204a9a <user_mem_check+0x32>
ffffffffc0204ac6:	8b85                	andi	a5,a5,1
ffffffffc0204ac8:	f3ed                	bnez	a5,ffffffffc0204aaa <user_mem_check+0x42>
            return 0;
ffffffffc0204aca:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0204acc:	70a2                	ld	ra,40(sp)
ffffffffc0204ace:	7402                	ld	s0,32(sp)
ffffffffc0204ad0:	64e2                	ld	s1,24(sp)
ffffffffc0204ad2:	6942                	ld	s2,16(sp)
ffffffffc0204ad4:	69a2                	ld	s3,8(sp)
ffffffffc0204ad6:	6a02                	ld	s4,0(sp)
ffffffffc0204ad8:	6145                	addi	sp,sp,48
ffffffffc0204ada:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0204adc:	c02007b7          	lui	a5,0xc0200
ffffffffc0204ae0:	4501                	li	a0,0
ffffffffc0204ae2:	fef5e5e3          	bltu	a1,a5,ffffffffc0204acc <user_mem_check+0x64>
ffffffffc0204ae6:	962e                	add	a2,a2,a1
ffffffffc0204ae8:	fec5f2e3          	bgeu	a1,a2,ffffffffc0204acc <user_mem_check+0x64>
ffffffffc0204aec:	c8000537          	lui	a0,0xc8000
ffffffffc0204af0:	0505                	addi	a0,a0,1
ffffffffc0204af2:	00a63533          	sltu	a0,a2,a0
ffffffffc0204af6:	bfd9                	j	ffffffffc0204acc <user_mem_check+0x64>
        return 1;
ffffffffc0204af8:	4505                	li	a0,1
ffffffffc0204afa:	bfc9                	j	ffffffffc0204acc <user_mem_check+0x64>

ffffffffc0204afc <swapfs_init>:
#include <ide.h>
#include <pmm.h>
#include <assert.h>

void
swapfs_init(void) {
ffffffffc0204afc:	1141                	addi	sp,sp,-16
    static_assert((PGSIZE % SECTSIZE) == 0);
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204afe:	4505                	li	a0,1
swapfs_init(void) {
ffffffffc0204b00:	e406                	sd	ra,8(sp)
    if (!ide_device_valid(SWAP_DEV_NO)) {
ffffffffc0204b02:	af5fb0ef          	jal	ra,ffffffffc02005f6 <ide_device_valid>
ffffffffc0204b06:	cd01                	beqz	a0,ffffffffc0204b1e <swapfs_init+0x22>
        panic("swap fs isn't available.\n");
    }
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b08:	4505                	li	a0,1
ffffffffc0204b0a:	af3fb0ef          	jal	ra,ffffffffc02005fc <ide_device_size>
}
ffffffffc0204b0e:	60a2                	ld	ra,8(sp)
    max_swap_offset = ide_device_size(SWAP_DEV_NO) / (PGSIZE / SECTSIZE);
ffffffffc0204b10:	810d                	srli	a0,a0,0x3
ffffffffc0204b12:	000a8797          	auipc	a5,0xa8
ffffffffc0204b16:	e4a7b723          	sd	a0,-434(a5) # ffffffffc02ac960 <max_swap_offset>
}
ffffffffc0204b1a:	0141                	addi	sp,sp,16
ffffffffc0204b1c:	8082                	ret
        panic("swap fs isn't available.\n");
ffffffffc0204b1e:	00004617          	auipc	a2,0x4
ffffffffc0204b22:	82260613          	addi	a2,a2,-2014 # ffffffffc0208340 <default_pmm_manager+0x1028>
ffffffffc0204b26:	45b5                	li	a1,13
ffffffffc0204b28:	00004517          	auipc	a0,0x4
ffffffffc0204b2c:	83850513          	addi	a0,a0,-1992 # ffffffffc0208360 <default_pmm_manager+0x1048>
ffffffffc0204b30:	951fb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204b34 <swapfs_read>:

int
swapfs_read(swap_entry_t entry, struct Page *page) {
ffffffffc0204b34:	1141                	addi	sp,sp,-16
ffffffffc0204b36:	e406                	sd	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b38:	00855793          	srli	a5,a0,0x8
ffffffffc0204b3c:	cfb9                	beqz	a5,ffffffffc0204b9a <swapfs_read+0x66>
ffffffffc0204b3e:	000a8717          	auipc	a4,0xa8
ffffffffc0204b42:	e2270713          	addi	a4,a4,-478 # ffffffffc02ac960 <max_swap_offset>
ffffffffc0204b46:	6318                	ld	a4,0(a4)
ffffffffc0204b48:	04e7f963          	bgeu	a5,a4,ffffffffc0204b9a <swapfs_read+0x66>
    return page - pages + nbase;
ffffffffc0204b4c:	000a8717          	auipc	a4,0xa8
ffffffffc0204b50:	d8470713          	addi	a4,a4,-636 # ffffffffc02ac8d0 <pages>
ffffffffc0204b54:	6310                	ld	a2,0(a4)
ffffffffc0204b56:	00004717          	auipc	a4,0x4
ffffffffc0204b5a:	16270713          	addi	a4,a4,354 # ffffffffc0208cb8 <nbase>
ffffffffc0204b5e:	40c58633          	sub	a2,a1,a2
ffffffffc0204b62:	630c                	ld	a1,0(a4)
ffffffffc0204b64:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204b66:	000a8717          	auipc	a4,0xa8
ffffffffc0204b6a:	cfa70713          	addi	a4,a4,-774 # ffffffffc02ac860 <npage>
    return page - pages + nbase;
ffffffffc0204b6e:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204b70:	6314                	ld	a3,0(a4)
ffffffffc0204b72:	00c61713          	slli	a4,a2,0xc
ffffffffc0204b76:	8331                	srli	a4,a4,0xc
ffffffffc0204b78:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b7c:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204b7e:	02d77a63          	bgeu	a4,a3,ffffffffc0204bb2 <swapfs_read+0x7e>
ffffffffc0204b82:	000a8797          	auipc	a5,0xa8
ffffffffc0204b86:	d3e78793          	addi	a5,a5,-706 # ffffffffc02ac8c0 <va_pa_offset>
ffffffffc0204b8a:	639c                	ld	a5,0(a5)
}
ffffffffc0204b8c:	60a2                	ld	ra,8(sp)
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b8e:	46a1                	li	a3,8
ffffffffc0204b90:	963e                	add	a2,a2,a5
ffffffffc0204b92:	4505                	li	a0,1
}
ffffffffc0204b94:	0141                	addi	sp,sp,16
    return ide_read_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204b96:	a6dfb06f          	j	ffffffffc0200602 <ide_read_secs>
ffffffffc0204b9a:	86aa                	mv	a3,a0
ffffffffc0204b9c:	00003617          	auipc	a2,0x3
ffffffffc0204ba0:	7dc60613          	addi	a2,a2,2012 # ffffffffc0208378 <default_pmm_manager+0x1060>
ffffffffc0204ba4:	45d1                	li	a1,20
ffffffffc0204ba6:	00003517          	auipc	a0,0x3
ffffffffc0204baa:	7ba50513          	addi	a0,a0,1978 # ffffffffc0208360 <default_pmm_manager+0x1048>
ffffffffc0204bae:	8d3fb0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc0204bb2:	86b2                	mv	a3,a2
ffffffffc0204bb4:	06900593          	li	a1,105
ffffffffc0204bb8:	00002617          	auipc	a2,0x2
ffffffffc0204bbc:	7b060613          	addi	a2,a2,1968 # ffffffffc0207368 <default_pmm_manager+0x50>
ffffffffc0204bc0:	00002517          	auipc	a0,0x2
ffffffffc0204bc4:	7d050513          	addi	a0,a0,2000 # ffffffffc0207390 <default_pmm_manager+0x78>
ffffffffc0204bc8:	8b9fb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204bcc <swapfs_write>:

int
swapfs_write(swap_entry_t entry, struct Page *page) {
ffffffffc0204bcc:	1141                	addi	sp,sp,-16
ffffffffc0204bce:	e406                	sd	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204bd0:	00855793          	srli	a5,a0,0x8
ffffffffc0204bd4:	cfb9                	beqz	a5,ffffffffc0204c32 <swapfs_write+0x66>
ffffffffc0204bd6:	000a8717          	auipc	a4,0xa8
ffffffffc0204bda:	d8a70713          	addi	a4,a4,-630 # ffffffffc02ac960 <max_swap_offset>
ffffffffc0204bde:	6318                	ld	a4,0(a4)
ffffffffc0204be0:	04e7f963          	bgeu	a5,a4,ffffffffc0204c32 <swapfs_write+0x66>
    return page - pages + nbase;
ffffffffc0204be4:	000a8717          	auipc	a4,0xa8
ffffffffc0204be8:	cec70713          	addi	a4,a4,-788 # ffffffffc02ac8d0 <pages>
ffffffffc0204bec:	6310                	ld	a2,0(a4)
ffffffffc0204bee:	00004717          	auipc	a4,0x4
ffffffffc0204bf2:	0ca70713          	addi	a4,a4,202 # ffffffffc0208cb8 <nbase>
ffffffffc0204bf6:	40c58633          	sub	a2,a1,a2
ffffffffc0204bfa:	630c                	ld	a1,0(a4)
ffffffffc0204bfc:	8619                	srai	a2,a2,0x6
    return KADDR(page2pa(page));
ffffffffc0204bfe:	000a8717          	auipc	a4,0xa8
ffffffffc0204c02:	c6270713          	addi	a4,a4,-926 # ffffffffc02ac860 <npage>
    return page - pages + nbase;
ffffffffc0204c06:	962e                	add	a2,a2,a1
    return KADDR(page2pa(page));
ffffffffc0204c08:	6314                	ld	a3,0(a4)
ffffffffc0204c0a:	00c61713          	slli	a4,a2,0xc
ffffffffc0204c0e:	8331                	srli	a4,a4,0xc
ffffffffc0204c10:	0037959b          	slliw	a1,a5,0x3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204c14:	0632                	slli	a2,a2,0xc
    return KADDR(page2pa(page));
ffffffffc0204c16:	02d77a63          	bgeu	a4,a3,ffffffffc0204c4a <swapfs_write+0x7e>
ffffffffc0204c1a:	000a8797          	auipc	a5,0xa8
ffffffffc0204c1e:	ca678793          	addi	a5,a5,-858 # ffffffffc02ac8c0 <va_pa_offset>
ffffffffc0204c22:	639c                	ld	a5,0(a5)
}
ffffffffc0204c24:	60a2                	ld	ra,8(sp)
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c26:	46a1                	li	a3,8
ffffffffc0204c28:	963e                	add	a2,a2,a5
ffffffffc0204c2a:	4505                	li	a0,1
}
ffffffffc0204c2c:	0141                	addi	sp,sp,16
    return ide_write_secs(SWAP_DEV_NO, swap_offset(entry) * PAGE_NSECT, page2kva(page), PAGE_NSECT);
ffffffffc0204c2e:	9f9fb06f          	j	ffffffffc0200626 <ide_write_secs>
ffffffffc0204c32:	86aa                	mv	a3,a0
ffffffffc0204c34:	00003617          	auipc	a2,0x3
ffffffffc0204c38:	74460613          	addi	a2,a2,1860 # ffffffffc0208378 <default_pmm_manager+0x1060>
ffffffffc0204c3c:	45e5                	li	a1,25
ffffffffc0204c3e:	00003517          	auipc	a0,0x3
ffffffffc0204c42:	72250513          	addi	a0,a0,1826 # ffffffffc0208360 <default_pmm_manager+0x1048>
ffffffffc0204c46:	83bfb0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc0204c4a:	86b2                	mv	a3,a2
ffffffffc0204c4c:	06900593          	li	a1,105
ffffffffc0204c50:	00002617          	auipc	a2,0x2
ffffffffc0204c54:	71860613          	addi	a2,a2,1816 # ffffffffc0207368 <default_pmm_manager+0x50>
ffffffffc0204c58:	00002517          	auipc	a0,0x2
ffffffffc0204c5c:	73850513          	addi	a0,a0,1848 # ffffffffc0207390 <default_pmm_manager+0x78>
ffffffffc0204c60:	821fb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204c64 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204c64:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204c66:	9402                	jalr	s0

	jal do_exit
ffffffffc0204c68:	732000ef          	jal	ra,ffffffffc020539a <do_exit>

ffffffffc0204c6c <alloc_proc>:
void forkrets(struct trapframe *tf);
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void) {
ffffffffc0204c6c:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204c6e:	10800513          	li	a0,264
alloc_proc(void) {
ffffffffc0204c72:	e022                	sd	s0,0(sp)
ffffffffc0204c74:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204c76:	fb7fc0ef          	jal	ra,ffffffffc0201c2c <kmalloc>
ffffffffc0204c7a:	842a                	mv	s0,a0
    if (proc != NULL) {
ffffffffc0204c7c:	cd29                	beqz	a0,ffffffffc0204cd6 <alloc_proc+0x6a>
     /*
     * below fields(add in LAB5) in proc_struct need to be initialized  
     *       uint32_t wait_state;                        // waiting state
     *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
     */
        proc->state = PROC_UNINIT;
ffffffffc0204c7e:	57fd                	li	a5,-1
ffffffffc0204c80:	1782                	slli	a5,a5,0x20
ffffffffc0204c82:	e11c                	sd	a5,0(a0)
	proc->runs = 0;
	proc->kstack = 0;
	proc->need_resched = 0;
	proc->parent = NULL;
	proc->mm = NULL;
	memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204c84:	07000613          	li	a2,112
ffffffffc0204c88:	4581                	li	a1,0
	proc->runs = 0;
ffffffffc0204c8a:	00052423          	sw	zero,8(a0)
	proc->kstack = 0;
ffffffffc0204c8e:	00053823          	sd	zero,16(a0)
	proc->need_resched = 0;
ffffffffc0204c92:	00053c23          	sd	zero,24(a0)
	proc->parent = NULL;
ffffffffc0204c96:	02053023          	sd	zero,32(a0)
	proc->mm = NULL;
ffffffffc0204c9a:	02053423          	sd	zero,40(a0)
	memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0204c9e:	03050513          	addi	a0,a0,48
ffffffffc0204ca2:	10f010ef          	jal	ra,ffffffffc02065b0 <memset>
	proc->tf = NULL;
	proc->cr3 = boot_cr3;
ffffffffc0204ca6:	000a8797          	auipc	a5,0xa8
ffffffffc0204caa:	c2278793          	addi	a5,a5,-990 # ffffffffc02ac8c8 <boot_cr3>
ffffffffc0204cae:	639c                	ld	a5,0(a5)
	proc->tf = NULL;
ffffffffc0204cb0:	0a043023          	sd	zero,160(s0)
	proc->flags = 0;
ffffffffc0204cb4:	0a042823          	sw	zero,176(s0)
	proc->cr3 = boot_cr3;
ffffffffc0204cb8:	f45c                	sd	a5,168(s0)
	memset(proc->name, 0, PROC_NAME_LEN);
ffffffffc0204cba:	463d                	li	a2,15
ffffffffc0204cbc:	4581                	li	a1,0
ffffffffc0204cbe:	0b440513          	addi	a0,s0,180
ffffffffc0204cc2:	0ef010ef          	jal	ra,ffffffffc02065b0 <memset>
	proc->wait_state = 0;
ffffffffc0204cc6:	0e042623          	sw	zero,236(s0)
	proc->cptr = NULL;
ffffffffc0204cca:	0e043823          	sd	zero,240(s0)
	proc->optr = NULL;
ffffffffc0204cce:	10043023          	sd	zero,256(s0)
	proc->yptr = NULL;
ffffffffc0204cd2:	0e043c23          	sd	zero,248(s0)
	}
    return proc;
}
ffffffffc0204cd6:	8522                	mv	a0,s0
ffffffffc0204cd8:	60a2                	ld	ra,8(sp)
ffffffffc0204cda:	6402                	ld	s0,0(sp)
ffffffffc0204cdc:	0141                	addi	sp,sp,16
ffffffffc0204cde:	8082                	ret

ffffffffc0204ce0 <forkret>:
// forkret -- the first kernel entry point of a new thread/process
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void) {
    forkrets(current->tf);
ffffffffc0204ce0:	000a8797          	auipc	a5,0xa8
ffffffffc0204ce4:	b9878793          	addi	a5,a5,-1128 # ffffffffc02ac878 <current>
ffffffffc0204ce8:	639c                	ld	a5,0(a5)
ffffffffc0204cea:	73c8                	ld	a0,160(a5)
ffffffffc0204cec:	8a6fc06f          	j	ffffffffc0200d92 <forkrets>

ffffffffc0204cf0 <user_main>:

// user_main - kernel thread used to exec a user program
static int
user_main(void *arg) {
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204cf0:	000a8797          	auipc	a5,0xa8
ffffffffc0204cf4:	b8878793          	addi	a5,a5,-1144 # ffffffffc02ac878 <current>
ffffffffc0204cf8:	639c                	ld	a5,0(a5)
user_main(void *arg) {
ffffffffc0204cfa:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204cfc:	00004617          	auipc	a2,0x4
ffffffffc0204d00:	a8c60613          	addi	a2,a2,-1396 # ffffffffc0208788 <default_pmm_manager+0x1470>
ffffffffc0204d04:	43cc                	lw	a1,4(a5)
ffffffffc0204d06:	00004517          	auipc	a0,0x4
ffffffffc0204d0a:	a9250513          	addi	a0,a0,-1390 # ffffffffc0208798 <default_pmm_manager+0x1480>
user_main(void *arg) {
ffffffffc0204d0e:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204d10:	c7efb0ef          	jal	ra,ffffffffc020018e <cprintf>
ffffffffc0204d14:	00004797          	auipc	a5,0x4
ffffffffc0204d18:	a7478793          	addi	a5,a5,-1420 # ffffffffc0208788 <default_pmm_manager+0x1470>
ffffffffc0204d1c:	3fe05717          	auipc	a4,0x3fe05
ffffffffc0204d20:	5f470713          	addi	a4,a4,1524 # a310 <_binary_obj___user_forktest_out_size>
ffffffffc0204d24:	e43a                	sd	a4,8(sp)
    int64_t ret=0, len = strlen(name);
ffffffffc0204d26:	853e                	mv	a0,a5
ffffffffc0204d28:	00043717          	auipc	a4,0x43
ffffffffc0204d2c:	4c870713          	addi	a4,a4,1224 # ffffffffc02481f0 <_binary_obj___user_forktest_out_start>
ffffffffc0204d30:	f03a                	sd	a4,32(sp)
ffffffffc0204d32:	f43e                	sd	a5,40(sp)
ffffffffc0204d34:	e802                	sd	zero,16(sp)
ffffffffc0204d36:	7dc010ef          	jal	ra,ffffffffc0206512 <strlen>
ffffffffc0204d3a:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc0204d3c:	4511                	li	a0,4
ffffffffc0204d3e:	55a2                	lw	a1,40(sp)
ffffffffc0204d40:	4662                	lw	a2,24(sp)
ffffffffc0204d42:	5682                	lw	a3,32(sp)
ffffffffc0204d44:	4722                	lw	a4,8(sp)
ffffffffc0204d46:	48a9                	li	a7,10
ffffffffc0204d48:	9002                	ebreak
ffffffffc0204d4a:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc0204d4c:	65c2                	ld	a1,16(sp)
ffffffffc0204d4e:	00004517          	auipc	a0,0x4
ffffffffc0204d52:	a7250513          	addi	a0,a0,-1422 # ffffffffc02087c0 <default_pmm_manager+0x14a8>
ffffffffc0204d56:	c38fb0ef          	jal	ra,ffffffffc020018e <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204d5a:	00004617          	auipc	a2,0x4
ffffffffc0204d5e:	a7660613          	addi	a2,a2,-1418 # ffffffffc02087d0 <default_pmm_manager+0x14b8>
ffffffffc0204d62:	34d00593          	li	a1,845
ffffffffc0204d66:	00004517          	auipc	a0,0x4
ffffffffc0204d6a:	a8a50513          	addi	a0,a0,-1398 # ffffffffc02087f0 <default_pmm_manager+0x14d8>
ffffffffc0204d6e:	f12fb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204d72 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0204d72:	6d14                	ld	a3,24(a0)
put_pgdir(struct mm_struct *mm) {
ffffffffc0204d74:	1141                	addi	sp,sp,-16
ffffffffc0204d76:	e406                	sd	ra,8(sp)
ffffffffc0204d78:	c02007b7          	lui	a5,0xc0200
ffffffffc0204d7c:	04f6e263          	bltu	a3,a5,ffffffffc0204dc0 <put_pgdir+0x4e>
ffffffffc0204d80:	000a8797          	auipc	a5,0xa8
ffffffffc0204d84:	b4078793          	addi	a5,a5,-1216 # ffffffffc02ac8c0 <va_pa_offset>
ffffffffc0204d88:	6388                	ld	a0,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc0204d8a:	000a8797          	auipc	a5,0xa8
ffffffffc0204d8e:	ad678793          	addi	a5,a5,-1322 # ffffffffc02ac860 <npage>
ffffffffc0204d92:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc0204d94:	8e89                	sub	a3,a3,a0
    if (PPN(pa) >= npage) {
ffffffffc0204d96:	82b1                	srli	a3,a3,0xc
ffffffffc0204d98:	04f6f063          	bgeu	a3,a5,ffffffffc0204dd8 <put_pgdir+0x66>
    return &pages[PPN(pa) - nbase];
ffffffffc0204d9c:	00004797          	auipc	a5,0x4
ffffffffc0204da0:	f1c78793          	addi	a5,a5,-228 # ffffffffc0208cb8 <nbase>
ffffffffc0204da4:	639c                	ld	a5,0(a5)
ffffffffc0204da6:	000a8717          	auipc	a4,0xa8
ffffffffc0204daa:	b2a70713          	addi	a4,a4,-1238 # ffffffffc02ac8d0 <pages>
ffffffffc0204dae:	6308                	ld	a0,0(a4)
}
ffffffffc0204db0:	60a2                	ld	ra,8(sp)
ffffffffc0204db2:	8e9d                	sub	a3,a3,a5
ffffffffc0204db4:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0204db6:	4585                	li	a1,1
ffffffffc0204db8:	9536                	add	a0,a0,a3
}
ffffffffc0204dba:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204dbc:	8f0fd06f          	j	ffffffffc0201eac <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204dc0:	00002617          	auipc	a2,0x2
ffffffffc0204dc4:	5e060613          	addi	a2,a2,1504 # ffffffffc02073a0 <default_pmm_manager+0x88>
ffffffffc0204dc8:	06e00593          	li	a1,110
ffffffffc0204dcc:	00002517          	auipc	a0,0x2
ffffffffc0204dd0:	5c450513          	addi	a0,a0,1476 # ffffffffc0207390 <default_pmm_manager+0x78>
ffffffffc0204dd4:	eacfb0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204dd8:	00002617          	auipc	a2,0x2
ffffffffc0204ddc:	5f060613          	addi	a2,a2,1520 # ffffffffc02073c8 <default_pmm_manager+0xb0>
ffffffffc0204de0:	06200593          	li	a1,98
ffffffffc0204de4:	00002517          	auipc	a0,0x2
ffffffffc0204de8:	5ac50513          	addi	a0,a0,1452 # ffffffffc0207390 <default_pmm_manager+0x78>
ffffffffc0204dec:	e94fb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204df0 <setup_pgdir>:
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204df0:	1101                	addi	sp,sp,-32
ffffffffc0204df2:	e426                	sd	s1,8(sp)
ffffffffc0204df4:	84aa                	mv	s1,a0
    if ((page = alloc_page()) == NULL) {
ffffffffc0204df6:	4505                	li	a0,1
setup_pgdir(struct mm_struct *mm) {
ffffffffc0204df8:	ec06                	sd	ra,24(sp)
ffffffffc0204dfa:	e822                	sd	s0,16(sp)
    if ((page = alloc_page()) == NULL) {
ffffffffc0204dfc:	828fd0ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
ffffffffc0204e00:	c125                	beqz	a0,ffffffffc0204e60 <setup_pgdir+0x70>
    return page - pages + nbase;
ffffffffc0204e02:	000a8797          	auipc	a5,0xa8
ffffffffc0204e06:	ace78793          	addi	a5,a5,-1330 # ffffffffc02ac8d0 <pages>
ffffffffc0204e0a:	6394                	ld	a3,0(a5)
ffffffffc0204e0c:	00004797          	auipc	a5,0x4
ffffffffc0204e10:	eac78793          	addi	a5,a5,-340 # ffffffffc0208cb8 <nbase>
ffffffffc0204e14:	6380                	ld	s0,0(a5)
ffffffffc0204e16:	40d506b3          	sub	a3,a0,a3
    return KADDR(page2pa(page));
ffffffffc0204e1a:	000a8797          	auipc	a5,0xa8
ffffffffc0204e1e:	a4678793          	addi	a5,a5,-1466 # ffffffffc02ac860 <npage>
    return page - pages + nbase;
ffffffffc0204e22:	8699                	srai	a3,a3,0x6
ffffffffc0204e24:	96a2                	add	a3,a3,s0
    return KADDR(page2pa(page));
ffffffffc0204e26:	6398                	ld	a4,0(a5)
ffffffffc0204e28:	00c69793          	slli	a5,a3,0xc
ffffffffc0204e2c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0204e2e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204e30:	02e7fa63          	bgeu	a5,a4,ffffffffc0204e64 <setup_pgdir+0x74>
ffffffffc0204e34:	000a8797          	auipc	a5,0xa8
ffffffffc0204e38:	a8c78793          	addi	a5,a5,-1396 # ffffffffc02ac8c0 <va_pa_offset>
ffffffffc0204e3c:	6380                	ld	s0,0(a5)
    memcpy(pgdir, boot_pgdir, PGSIZE);
ffffffffc0204e3e:	000a8797          	auipc	a5,0xa8
ffffffffc0204e42:	a1a78793          	addi	a5,a5,-1510 # ffffffffc02ac858 <boot_pgdir>
ffffffffc0204e46:	638c                	ld	a1,0(a5)
ffffffffc0204e48:	9436                	add	s0,s0,a3
ffffffffc0204e4a:	6605                	lui	a2,0x1
ffffffffc0204e4c:	8522                	mv	a0,s0
ffffffffc0204e4e:	774010ef          	jal	ra,ffffffffc02065c2 <memcpy>
    return 0;
ffffffffc0204e52:	4501                	li	a0,0
    mm->pgdir = pgdir;
ffffffffc0204e54:	ec80                	sd	s0,24(s1)
}
ffffffffc0204e56:	60e2                	ld	ra,24(sp)
ffffffffc0204e58:	6442                	ld	s0,16(sp)
ffffffffc0204e5a:	64a2                	ld	s1,8(sp)
ffffffffc0204e5c:	6105                	addi	sp,sp,32
ffffffffc0204e5e:	8082                	ret
        return -E_NO_MEM;
ffffffffc0204e60:	5571                	li	a0,-4
ffffffffc0204e62:	bfd5                	j	ffffffffc0204e56 <setup_pgdir+0x66>
ffffffffc0204e64:	00002617          	auipc	a2,0x2
ffffffffc0204e68:	50460613          	addi	a2,a2,1284 # ffffffffc0207368 <default_pmm_manager+0x50>
ffffffffc0204e6c:	06900593          	li	a1,105
ffffffffc0204e70:	00002517          	auipc	a0,0x2
ffffffffc0204e74:	52050513          	addi	a0,a0,1312 # ffffffffc0207390 <default_pmm_manager+0x78>
ffffffffc0204e78:	e08fb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0204e7c <set_proc_name>:
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204e7c:	1101                	addi	sp,sp,-32
ffffffffc0204e7e:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204e80:	0b450413          	addi	s0,a0,180
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204e84:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204e86:	4641                	li	a2,16
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204e88:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204e8a:	8522                	mv	a0,s0
ffffffffc0204e8c:	4581                	li	a1,0
set_proc_name(struct proc_struct *proc, const char *name) {
ffffffffc0204e8e:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204e90:	720010ef          	jal	ra,ffffffffc02065b0 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204e94:	8522                	mv	a0,s0
}
ffffffffc0204e96:	6442                	ld	s0,16(sp)
ffffffffc0204e98:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204e9a:	85a6                	mv	a1,s1
}
ffffffffc0204e9c:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204e9e:	463d                	li	a2,15
}
ffffffffc0204ea0:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204ea2:	7200106f          	j	ffffffffc02065c2 <memcpy>

ffffffffc0204ea6 <proc_run>:
proc_run(struct proc_struct *proc) {
ffffffffc0204ea6:	1101                	addi	sp,sp,-32
    if (proc != current) {
ffffffffc0204ea8:	000a8797          	auipc	a5,0xa8
ffffffffc0204eac:	9d078793          	addi	a5,a5,-1584 # ffffffffc02ac878 <current>
proc_run(struct proc_struct *proc) {
ffffffffc0204eb0:	e426                	sd	s1,8(sp)
    if (proc != current) {
ffffffffc0204eb2:	6384                	ld	s1,0(a5)
proc_run(struct proc_struct *proc) {
ffffffffc0204eb4:	ec06                	sd	ra,24(sp)
ffffffffc0204eb6:	e822                	sd	s0,16(sp)
ffffffffc0204eb8:	e04a                	sd	s2,0(sp)
    if (proc != current) {
ffffffffc0204eba:	02a48b63          	beq	s1,a0,ffffffffc0204ef0 <proc_run+0x4a>
ffffffffc0204ebe:	842a                	mv	s0,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204ec0:	100027f3          	csrr	a5,sstatus
ffffffffc0204ec4:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204ec6:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204ec8:	e3a9                	bnez	a5,ffffffffc0204f0a <proc_run+0x64>

#define barrier() __asm__ __volatile__ ("fence" ::: "memory")

static inline void
lcr3(unsigned long cr3) {
    write_csr(satp, 0x8000000000000000 | (cr3 >> RISCV_PGSHIFT));
ffffffffc0204eca:	745c                	ld	a5,168(s0)
            current = proc;
ffffffffc0204ecc:	000a8717          	auipc	a4,0xa8
ffffffffc0204ed0:	9a873623          	sd	s0,-1620(a4) # ffffffffc02ac878 <current>
ffffffffc0204ed4:	577d                	li	a4,-1
ffffffffc0204ed6:	177e                	slli	a4,a4,0x3f
ffffffffc0204ed8:	83b1                	srli	a5,a5,0xc
ffffffffc0204eda:	8fd9                	or	a5,a5,a4
ffffffffc0204edc:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc0204ee0:	03040593          	addi	a1,s0,48
ffffffffc0204ee4:	03048513          	addi	a0,s1,48
ffffffffc0204ee8:	7cb000ef          	jal	ra,ffffffffc0205eb2 <switch_to>
    if (flag) {
ffffffffc0204eec:	00091863          	bnez	s2,ffffffffc0204efc <proc_run+0x56>
}
ffffffffc0204ef0:	60e2                	ld	ra,24(sp)
ffffffffc0204ef2:	6442                	ld	s0,16(sp)
ffffffffc0204ef4:	64a2                	ld	s1,8(sp)
ffffffffc0204ef6:	6902                	ld	s2,0(sp)
ffffffffc0204ef8:	6105                	addi	sp,sp,32
ffffffffc0204efa:	8082                	ret
ffffffffc0204efc:	6442                	ld	s0,16(sp)
ffffffffc0204efe:	60e2                	ld	ra,24(sp)
ffffffffc0204f00:	64a2                	ld	s1,8(sp)
ffffffffc0204f02:	6902                	ld	s2,0(sp)
ffffffffc0204f04:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0204f06:	f46fb06f          	j	ffffffffc020064c <intr_enable>
        intr_disable();
ffffffffc0204f0a:	f48fb0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0204f0e:	4905                	li	s2,1
ffffffffc0204f10:	bf6d                	j	ffffffffc0204eca <proc_run+0x24>

ffffffffc0204f12 <find_proc>:
    if (0 < pid && pid < MAX_PID) {
ffffffffc0204f12:	0005071b          	sext.w	a4,a0
ffffffffc0204f16:	6789                	lui	a5,0x2
ffffffffc0204f18:	fff7069b          	addiw	a3,a4,-1
ffffffffc0204f1c:	17f9                	addi	a5,a5,-2
ffffffffc0204f1e:	04d7e063          	bltu	a5,a3,ffffffffc0204f5e <find_proc+0x4c>
find_proc(int pid) {
ffffffffc0204f22:	1141                	addi	sp,sp,-16
ffffffffc0204f24:	e022                	sd	s0,0(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204f26:	45a9                	li	a1,10
ffffffffc0204f28:	842a                	mv	s0,a0
ffffffffc0204f2a:	853a                	mv	a0,a4
find_proc(int pid) {
ffffffffc0204f2c:	e406                	sd	ra,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204f2e:	1e0010ef          	jal	ra,ffffffffc020610e <hash32>
ffffffffc0204f32:	02051693          	slli	a3,a0,0x20
ffffffffc0204f36:	82f1                	srli	a3,a3,0x1c
ffffffffc0204f38:	000a4517          	auipc	a0,0xa4
ffffffffc0204f3c:	90850513          	addi	a0,a0,-1784 # ffffffffc02a8840 <hash_list>
ffffffffc0204f40:	96aa                	add	a3,a3,a0
ffffffffc0204f42:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list) {
ffffffffc0204f44:	a029                	j	ffffffffc0204f4e <find_proc+0x3c>
            if (proc->pid == pid) {
ffffffffc0204f46:	f2c7a703          	lw	a4,-212(a5) # 1f2c <_binary_obj___user_faultread_out_size-0x769c>
ffffffffc0204f4a:	00870c63          	beq	a4,s0,ffffffffc0204f62 <find_proc+0x50>
ffffffffc0204f4e:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list) {
ffffffffc0204f50:	fef69be3          	bne	a3,a5,ffffffffc0204f46 <find_proc+0x34>
}
ffffffffc0204f54:	60a2                	ld	ra,8(sp)
ffffffffc0204f56:	6402                	ld	s0,0(sp)
    return NULL;
ffffffffc0204f58:	4501                	li	a0,0
}
ffffffffc0204f5a:	0141                	addi	sp,sp,16
ffffffffc0204f5c:	8082                	ret
    return NULL;
ffffffffc0204f5e:	4501                	li	a0,0
}
ffffffffc0204f60:	8082                	ret
ffffffffc0204f62:	60a2                	ld	ra,8(sp)
ffffffffc0204f64:	6402                	ld	s0,0(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204f66:	f2878513          	addi	a0,a5,-216
}
ffffffffc0204f6a:	0141                	addi	sp,sp,16
ffffffffc0204f6c:	8082                	ret

ffffffffc0204f6e <do_fork>:
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204f6e:	7159                	addi	sp,sp,-112
ffffffffc0204f70:	e0d2                	sd	s4,64(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204f72:	000a8a17          	auipc	s4,0xa8
ffffffffc0204f76:	91ea0a13          	addi	s4,s4,-1762 # ffffffffc02ac890 <nr_process>
ffffffffc0204f7a:	000a2703          	lw	a4,0(s4)
do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf) {
ffffffffc0204f7e:	f486                	sd	ra,104(sp)
ffffffffc0204f80:	f0a2                	sd	s0,96(sp)
ffffffffc0204f82:	eca6                	sd	s1,88(sp)
ffffffffc0204f84:	e8ca                	sd	s2,80(sp)
ffffffffc0204f86:	e4ce                	sd	s3,72(sp)
ffffffffc0204f88:	fc56                	sd	s5,56(sp)
ffffffffc0204f8a:	f85a                	sd	s6,48(sp)
ffffffffc0204f8c:	f45e                	sd	s7,40(sp)
ffffffffc0204f8e:	f062                	sd	s8,32(sp)
ffffffffc0204f90:	ec66                	sd	s9,24(sp)
ffffffffc0204f92:	e86a                	sd	s10,16(sp)
ffffffffc0204f94:	e46e                	sd	s11,8(sp)
    if (nr_process >= MAX_PROCESS) {
ffffffffc0204f96:	6785                	lui	a5,0x1
ffffffffc0204f98:	30f75a63          	bge	a4,a5,ffffffffc02052ac <do_fork+0x33e>
ffffffffc0204f9c:	89aa                	mv	s3,a0
ffffffffc0204f9e:	892e                	mv	s2,a1
ffffffffc0204fa0:	84b2                	mv	s1,a2
     if((proc = alloc_proc()) == NULL) {
ffffffffc0204fa2:	ccbff0ef          	jal	ra,ffffffffc0204c6c <alloc_proc>
ffffffffc0204fa6:	842a                	mv	s0,a0
ffffffffc0204fa8:	2e050463          	beqz	a0,ffffffffc0205290 <do_fork+0x322>
    proc->parent = current;
ffffffffc0204fac:	000a8c17          	auipc	s8,0xa8
ffffffffc0204fb0:	8ccc0c13          	addi	s8,s8,-1844 # ffffffffc02ac878 <current>
ffffffffc0204fb4:	000c3783          	ld	a5,0(s8)
    assert(current->wait_state == 0);
ffffffffc0204fb8:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_faultread_out_size-0x84dc>
    proc->parent = current;
ffffffffc0204fbc:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc0204fbe:	30071563          	bnez	a4,ffffffffc02052c8 <do_fork+0x35a>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204fc2:	4509                	li	a0,2
ffffffffc0204fc4:	e61fc0ef          	jal	ra,ffffffffc0201e24 <alloc_pages>
    if (page != NULL) {
ffffffffc0204fc8:	2c050163          	beqz	a0,ffffffffc020528a <do_fork+0x31c>
    return page - pages + nbase;
ffffffffc0204fcc:	000a8a97          	auipc	s5,0xa8
ffffffffc0204fd0:	904a8a93          	addi	s5,s5,-1788 # ffffffffc02ac8d0 <pages>
ffffffffc0204fd4:	000ab683          	ld	a3,0(s5)
ffffffffc0204fd8:	00004b17          	auipc	s6,0x4
ffffffffc0204fdc:	ce0b0b13          	addi	s6,s6,-800 # ffffffffc0208cb8 <nbase>
ffffffffc0204fe0:	000b3783          	ld	a5,0(s6)
ffffffffc0204fe4:	40d506b3          	sub	a3,a0,a3
ffffffffc0204fe8:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204fea:	000a8b97          	auipc	s7,0xa8
ffffffffc0204fee:	876b8b93          	addi	s7,s7,-1930 # ffffffffc02ac860 <npage>
    return page - pages + nbase;
ffffffffc0204ff2:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0204ff4:	000bb703          	ld	a4,0(s7)
ffffffffc0204ff8:	00c69793          	slli	a5,a3,0xc
ffffffffc0204ffc:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0204ffe:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205000:	2ae7f863          	bgeu	a5,a4,ffffffffc02052b0 <do_fork+0x342>
ffffffffc0205004:	000a8c97          	auipc	s9,0xa8
ffffffffc0205008:	8bcc8c93          	addi	s9,s9,-1860 # ffffffffc02ac8c0 <va_pa_offset>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc020500c:	000c3703          	ld	a4,0(s8)
ffffffffc0205010:	000cb783          	ld	a5,0(s9)
ffffffffc0205014:	02873c03          	ld	s8,40(a4)
ffffffffc0205018:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc020501a:	e814                	sd	a3,16(s0)
    if (oldmm == NULL) {
ffffffffc020501c:	020c0863          	beqz	s8,ffffffffc020504c <do_fork+0xde>
    if (clone_flags & CLONE_VM) {
ffffffffc0205020:	1009f993          	andi	s3,s3,256
ffffffffc0205024:	1e098163          	beqz	s3,ffffffffc0205206 <do_fork+0x298>
}

static inline int
mm_count_inc(struct mm_struct *mm) {
    mm->mm_count += 1;
ffffffffc0205028:	030c2703          	lw	a4,48(s8)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020502c:	018c3783          	ld	a5,24(s8)
ffffffffc0205030:	c02006b7          	lui	a3,0xc0200
ffffffffc0205034:	2705                	addiw	a4,a4,1
ffffffffc0205036:	02ec2823          	sw	a4,48(s8)
    proc->mm = mm;
ffffffffc020503a:	03843423          	sd	s8,40(s0)
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc020503e:	2ad7e563          	bltu	a5,a3,ffffffffc02052e8 <do_fork+0x37a>
ffffffffc0205042:	000cb703          	ld	a4,0(s9)
ffffffffc0205046:	6814                	ld	a3,16(s0)
ffffffffc0205048:	8f99                	sub	a5,a5,a4
ffffffffc020504a:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc020504c:	6789                	lui	a5,0x2
ffffffffc020504e:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_faultread_out_size-0x76e8>
ffffffffc0205052:	96be                	add	a3,a3,a5
ffffffffc0205054:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0205056:	87b6                	mv	a5,a3
ffffffffc0205058:	12048813          	addi	a6,s1,288
ffffffffc020505c:	6088                	ld	a0,0(s1)
ffffffffc020505e:	648c                	ld	a1,8(s1)
ffffffffc0205060:	6890                	ld	a2,16(s1)
ffffffffc0205062:	6c98                	ld	a4,24(s1)
ffffffffc0205064:	e388                	sd	a0,0(a5)
ffffffffc0205066:	e78c                	sd	a1,8(a5)
ffffffffc0205068:	eb90                	sd	a2,16(a5)
ffffffffc020506a:	ef98                	sd	a4,24(a5)
ffffffffc020506c:	02048493          	addi	s1,s1,32
ffffffffc0205070:	02078793          	addi	a5,a5,32
ffffffffc0205074:	ff0494e3          	bne	s1,a6,ffffffffc020505c <do_fork+0xee>
    proc->tf->gpr.a0 = 0;
ffffffffc0205078:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x1a>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020507c:	12090e63          	beqz	s2,ffffffffc02051b8 <do_fork+0x24a>
ffffffffc0205080:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0205084:	00000797          	auipc	a5,0x0
ffffffffc0205088:	c5c78793          	addi	a5,a5,-932 # ffffffffc0204ce0 <forkret>
ffffffffc020508c:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020508e:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205090:	100027f3          	csrr	a5,sstatus
ffffffffc0205094:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205096:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205098:	12079f63          	bnez	a5,ffffffffc02051d6 <do_fork+0x268>
    if (++ last_pid >= MAX_PID) {
ffffffffc020509c:	0009c797          	auipc	a5,0x9c
ffffffffc02050a0:	39c78793          	addi	a5,a5,924 # ffffffffc02a1438 <last_pid.1691>
ffffffffc02050a4:	439c                	lw	a5,0(a5)
ffffffffc02050a6:	6709                	lui	a4,0x2
ffffffffc02050a8:	0017851b          	addiw	a0,a5,1
ffffffffc02050ac:	0009c697          	auipc	a3,0x9c
ffffffffc02050b0:	38a6a623          	sw	a0,908(a3) # ffffffffc02a1438 <last_pid.1691>
ffffffffc02050b4:	14e55263          	bge	a0,a4,ffffffffc02051f8 <do_fork+0x28a>
    if (last_pid >= next_safe) {
ffffffffc02050b8:	0009c797          	auipc	a5,0x9c
ffffffffc02050bc:	38478793          	addi	a5,a5,900 # ffffffffc02a143c <next_safe.1690>
ffffffffc02050c0:	439c                	lw	a5,0(a5)
ffffffffc02050c2:	000a8497          	auipc	s1,0xa8
ffffffffc02050c6:	8f648493          	addi	s1,s1,-1802 # ffffffffc02ac9b8 <proc_list>
ffffffffc02050ca:	06f54063          	blt	a0,a5,ffffffffc020512a <do_fork+0x1bc>
        next_safe = MAX_PID;
ffffffffc02050ce:	6789                	lui	a5,0x2
ffffffffc02050d0:	0009c717          	auipc	a4,0x9c
ffffffffc02050d4:	36f72623          	sw	a5,876(a4) # ffffffffc02a143c <next_safe.1690>
ffffffffc02050d8:	4581                	li	a1,0
ffffffffc02050da:	87aa                	mv	a5,a0
ffffffffc02050dc:	000a8497          	auipc	s1,0xa8
ffffffffc02050e0:	8dc48493          	addi	s1,s1,-1828 # ffffffffc02ac9b8 <proc_list>
    repeat:
ffffffffc02050e4:	6889                	lui	a7,0x2
ffffffffc02050e6:	882e                	mv	a6,a1
ffffffffc02050e8:	6609                	lui	a2,0x2
        le = list;
ffffffffc02050ea:	000a8697          	auipc	a3,0xa8
ffffffffc02050ee:	8ce68693          	addi	a3,a3,-1842 # ffffffffc02ac9b8 <proc_list>
ffffffffc02050f2:	6694                	ld	a3,8(a3)
        while ((le = list_next(le)) != list) {
ffffffffc02050f4:	00968f63          	beq	a3,s1,ffffffffc0205112 <do_fork+0x1a4>
            if (proc->pid == last_pid) {
ffffffffc02050f8:	f3c6a703          	lw	a4,-196(a3)
ffffffffc02050fc:	0ae78963          	beq	a5,a4,ffffffffc02051ae <do_fork+0x240>
            else if (proc->pid > last_pid && next_safe > proc->pid) {
ffffffffc0205100:	fee7d9e3          	bge	a5,a4,ffffffffc02050f2 <do_fork+0x184>
ffffffffc0205104:	fec757e3          	bge	a4,a2,ffffffffc02050f2 <do_fork+0x184>
ffffffffc0205108:	6694                	ld	a3,8(a3)
ffffffffc020510a:	863a                	mv	a2,a4
ffffffffc020510c:	4805                	li	a6,1
        while ((le = list_next(le)) != list) {
ffffffffc020510e:	fe9695e3          	bne	a3,s1,ffffffffc02050f8 <do_fork+0x18a>
ffffffffc0205112:	c591                	beqz	a1,ffffffffc020511e <do_fork+0x1b0>
ffffffffc0205114:	0009c717          	auipc	a4,0x9c
ffffffffc0205118:	32f72223          	sw	a5,804(a4) # ffffffffc02a1438 <last_pid.1691>
ffffffffc020511c:	853e                	mv	a0,a5
ffffffffc020511e:	00080663          	beqz	a6,ffffffffc020512a <do_fork+0x1bc>
ffffffffc0205122:	0009c797          	auipc	a5,0x9c
ffffffffc0205126:	30c7ad23          	sw	a2,794(a5) # ffffffffc02a143c <next_safe.1690>
        proc->pid = get_pid();
ffffffffc020512a:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020512c:	45a9                	li	a1,10
ffffffffc020512e:	2501                	sext.w	a0,a0
ffffffffc0205130:	7df000ef          	jal	ra,ffffffffc020610e <hash32>
ffffffffc0205134:	1502                	slli	a0,a0,0x20
ffffffffc0205136:	000a3797          	auipc	a5,0xa3
ffffffffc020513a:	70a78793          	addi	a5,a5,1802 # ffffffffc02a8840 <hash_list>
ffffffffc020513e:	8171                	srli	a0,a0,0x1c
ffffffffc0205140:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0205142:	650c                	ld	a1,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205144:	7014                	ld	a3,32(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0205146:	0d840793          	addi	a5,s0,216
    prev->next = next->prev = elm;
ffffffffc020514a:	e19c                	sd	a5,0(a1)
    __list_add(elm, listelm, listelm->next);
ffffffffc020514c:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc020514e:	e51c                	sd	a5,8(a0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc0205150:	7af8                	ld	a4,240(a3)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0205152:	0c840793          	addi	a5,s0,200
    elm->next = next;
ffffffffc0205156:	f06c                	sd	a1,224(s0)
    elm->prev = prev;
ffffffffc0205158:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc020515a:	e21c                	sd	a5,0(a2)
ffffffffc020515c:	000a8597          	auipc	a1,0xa8
ffffffffc0205160:	86f5b223          	sd	a5,-1948(a1) # ffffffffc02ac9c0 <proc_list+0x8>
    elm->next = next;
ffffffffc0205164:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc0205166:	e464                	sd	s1,200(s0)
    proc->yptr = NULL;
ffffffffc0205168:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL) {
ffffffffc020516c:	10e43023          	sd	a4,256(s0)
ffffffffc0205170:	c311                	beqz	a4,ffffffffc0205174 <do_fork+0x206>
        proc->optr->yptr = proc;
ffffffffc0205172:	ff60                	sd	s0,248(a4)
    nr_process ++;
ffffffffc0205174:	000a2783          	lw	a5,0(s4)
    proc->parent->cptr = proc;
ffffffffc0205178:	fae0                	sd	s0,240(a3)
    nr_process ++;
ffffffffc020517a:	2785                	addiw	a5,a5,1
ffffffffc020517c:	000a7717          	auipc	a4,0xa7
ffffffffc0205180:	70f72a23          	sw	a5,1812(a4) # ffffffffc02ac890 <nr_process>
    if (flag) {
ffffffffc0205184:	10091863          	bnez	s2,ffffffffc0205294 <do_fork+0x326>
    wakeup_proc(proc);
ffffffffc0205188:	8522                	mv	a0,s0
ffffffffc020518a:	593000ef          	jal	ra,ffffffffc0205f1c <wakeup_proc>
    ret = proc->pid;
ffffffffc020518e:	4048                	lw	a0,4(s0)
}
ffffffffc0205190:	70a6                	ld	ra,104(sp)
ffffffffc0205192:	7406                	ld	s0,96(sp)
ffffffffc0205194:	64e6                	ld	s1,88(sp)
ffffffffc0205196:	6946                	ld	s2,80(sp)
ffffffffc0205198:	69a6                	ld	s3,72(sp)
ffffffffc020519a:	6a06                	ld	s4,64(sp)
ffffffffc020519c:	7ae2                	ld	s5,56(sp)
ffffffffc020519e:	7b42                	ld	s6,48(sp)
ffffffffc02051a0:	7ba2                	ld	s7,40(sp)
ffffffffc02051a2:	7c02                	ld	s8,32(sp)
ffffffffc02051a4:	6ce2                	ld	s9,24(sp)
ffffffffc02051a6:	6d42                	ld	s10,16(sp)
ffffffffc02051a8:	6da2                	ld	s11,8(sp)
ffffffffc02051aa:	6165                	addi	sp,sp,112
ffffffffc02051ac:	8082                	ret
                if (++ last_pid >= next_safe) {
ffffffffc02051ae:	2785                	addiw	a5,a5,1
ffffffffc02051b0:	0ec7d563          	bge	a5,a2,ffffffffc020529a <do_fork+0x32c>
ffffffffc02051b4:	4585                	li	a1,1
ffffffffc02051b6:	bf35                	j	ffffffffc02050f2 <do_fork+0x184>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02051b8:	8936                	mv	s2,a3
ffffffffc02051ba:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02051be:	00000797          	auipc	a5,0x0
ffffffffc02051c2:	b2278793          	addi	a5,a5,-1246 # ffffffffc0204ce0 <forkret>
ffffffffc02051c6:	f81c                	sd	a5,48(s0)
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02051c8:	fc14                	sd	a3,56(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02051ca:	100027f3          	csrr	a5,sstatus
ffffffffc02051ce:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02051d0:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02051d2:	ec0785e3          	beqz	a5,ffffffffc020509c <do_fork+0x12e>
        intr_disable();
ffffffffc02051d6:	c7cfb0ef          	jal	ra,ffffffffc0200652 <intr_disable>
    if (++ last_pid >= MAX_PID) {
ffffffffc02051da:	0009c797          	auipc	a5,0x9c
ffffffffc02051de:	25e78793          	addi	a5,a5,606 # ffffffffc02a1438 <last_pid.1691>
ffffffffc02051e2:	439c                	lw	a5,0(a5)
ffffffffc02051e4:	6709                	lui	a4,0x2
        return 1;
ffffffffc02051e6:	4905                	li	s2,1
ffffffffc02051e8:	0017851b          	addiw	a0,a5,1
ffffffffc02051ec:	0009c697          	auipc	a3,0x9c
ffffffffc02051f0:	24a6a623          	sw	a0,588(a3) # ffffffffc02a1438 <last_pid.1691>
ffffffffc02051f4:	ece542e3          	blt	a0,a4,ffffffffc02050b8 <do_fork+0x14a>
        last_pid = 1;
ffffffffc02051f8:	4785                	li	a5,1
ffffffffc02051fa:	0009c717          	auipc	a4,0x9c
ffffffffc02051fe:	22f72f23          	sw	a5,574(a4) # ffffffffc02a1438 <last_pid.1691>
ffffffffc0205202:	4505                	li	a0,1
ffffffffc0205204:	b5e9                	j	ffffffffc02050ce <do_fork+0x160>
    if ((mm = mm_create()) == NULL) {
ffffffffc0205206:	e85fe0ef          	jal	ra,ffffffffc020408a <mm_create>
ffffffffc020520a:	8d2a                	mv	s10,a0
ffffffffc020520c:	c539                	beqz	a0,ffffffffc020525a <do_fork+0x2ec>
    if (setup_pgdir(mm) != 0) {
ffffffffc020520e:	be3ff0ef          	jal	ra,ffffffffc0204df0 <setup_pgdir>
ffffffffc0205212:	e949                	bnez	a0,ffffffffc02052a4 <do_fork+0x336>
}

static inline void
lock_mm(struct mm_struct *mm) {
    if (mm != NULL) {
        lock(&(mm->mm_lock));
ffffffffc0205214:	038c0d93          	addi	s11,s8,56
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0205218:	4785                	li	a5,1
ffffffffc020521a:	40fdb7af          	amoor.d	a5,a5,(s11)
ffffffffc020521e:	8b85                	andi	a5,a5,1
ffffffffc0205220:	4985                	li	s3,1
    return !test_and_set_bit(0, lock);
}

static inline void
lock(lock_t *lock) {
    while (!try_lock(lock)) {
ffffffffc0205222:	c799                	beqz	a5,ffffffffc0205230 <do_fork+0x2c2>
        schedule();
ffffffffc0205224:	575000ef          	jal	ra,ffffffffc0205f98 <schedule>
ffffffffc0205228:	413db7af          	amoor.d	a5,s3,(s11)
ffffffffc020522c:	8b85                	andi	a5,a5,1
    while (!try_lock(lock)) {
ffffffffc020522e:	fbfd                	bnez	a5,ffffffffc0205224 <do_fork+0x2b6>
        ret = dup_mmap(mm, oldmm);
ffffffffc0205230:	85e2                	mv	a1,s8
ffffffffc0205232:	856a                	mv	a0,s10
ffffffffc0205234:	8e0ff0ef          	jal	ra,ffffffffc0204314 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0205238:	57f9                	li	a5,-2
ffffffffc020523a:	60fdb7af          	amoand.d	a5,a5,(s11)
ffffffffc020523e:	8b85                	andi	a5,a5,1
    }
}

static inline void
unlock(lock_t *lock) {
    if (!test_and_clear_bit(0, lock)) {
ffffffffc0205240:	c3e9                	beqz	a5,ffffffffc0205302 <do_fork+0x394>
    if (ret != 0) {
ffffffffc0205242:	8c6a                	mv	s8,s10
ffffffffc0205244:	de0502e3          	beqz	a0,ffffffffc0205028 <do_fork+0xba>
    exit_mmap(mm);
ffffffffc0205248:	856a                	mv	a0,s10
ffffffffc020524a:	966ff0ef          	jal	ra,ffffffffc02043b0 <exit_mmap>
    put_pgdir(mm);
ffffffffc020524e:	856a                	mv	a0,s10
ffffffffc0205250:	b23ff0ef          	jal	ra,ffffffffc0204d72 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205254:	856a                	mv	a0,s10
ffffffffc0205256:	fbbfe0ef          	jal	ra,ffffffffc0204210 <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020525a:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc020525c:	c02007b7          	lui	a5,0xc0200
ffffffffc0205260:	0cf6e963          	bltu	a3,a5,ffffffffc0205332 <do_fork+0x3c4>
ffffffffc0205264:	000cb783          	ld	a5,0(s9)
    if (PPN(pa) >= npage) {
ffffffffc0205268:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc020526c:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage) {
ffffffffc0205270:	83b1                	srli	a5,a5,0xc
ffffffffc0205272:	0ae7f463          	bgeu	a5,a4,ffffffffc020531a <do_fork+0x3ac>
    return &pages[PPN(pa) - nbase];
ffffffffc0205276:	000b3703          	ld	a4,0(s6)
ffffffffc020527a:	000ab503          	ld	a0,0(s5)
ffffffffc020527e:	4589                	li	a1,2
ffffffffc0205280:	8f99                	sub	a5,a5,a4
ffffffffc0205282:	079a                	slli	a5,a5,0x6
ffffffffc0205284:	953e                	add	a0,a0,a5
ffffffffc0205286:	c27fc0ef          	jal	ra,ffffffffc0201eac <free_pages>
    kfree(proc);
ffffffffc020528a:	8522                	mv	a0,s0
ffffffffc020528c:	a5dfc0ef          	jal	ra,ffffffffc0201ce8 <kfree>
    ret = -E_NO_MEM;
ffffffffc0205290:	5571                	li	a0,-4
    return ret;
ffffffffc0205292:	bdfd                	j	ffffffffc0205190 <do_fork+0x222>
        intr_enable();
ffffffffc0205294:	bb8fb0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0205298:	bdc5                	j	ffffffffc0205188 <do_fork+0x21a>
                    if (last_pid >= MAX_PID) {
ffffffffc020529a:	0117c363          	blt	a5,a7,ffffffffc02052a0 <do_fork+0x332>
                        last_pid = 1;
ffffffffc020529e:	4785                	li	a5,1
                    goto repeat;
ffffffffc02052a0:	4585                	li	a1,1
ffffffffc02052a2:	b591                	j	ffffffffc02050e6 <do_fork+0x178>
    mm_destroy(mm);
ffffffffc02052a4:	856a                	mv	a0,s10
ffffffffc02052a6:	f6bfe0ef          	jal	ra,ffffffffc0204210 <mm_destroy>
ffffffffc02052aa:	bf45                	j	ffffffffc020525a <do_fork+0x2ec>
    int ret = -E_NO_FREE_PROC;
ffffffffc02052ac:	556d                	li	a0,-5
ffffffffc02052ae:	b5cd                	j	ffffffffc0205190 <do_fork+0x222>
    return KADDR(page2pa(page));
ffffffffc02052b0:	00002617          	auipc	a2,0x2
ffffffffc02052b4:	0b860613          	addi	a2,a2,184 # ffffffffc0207368 <default_pmm_manager+0x50>
ffffffffc02052b8:	06900593          	li	a1,105
ffffffffc02052bc:	00002517          	auipc	a0,0x2
ffffffffc02052c0:	0d450513          	addi	a0,a0,212 # ffffffffc0207390 <default_pmm_manager+0x78>
ffffffffc02052c4:	9bcfb0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(current->wait_state == 0);
ffffffffc02052c8:	00003697          	auipc	a3,0x3
ffffffffc02052cc:	29868693          	addi	a3,a3,664 # ffffffffc0208560 <default_pmm_manager+0x1248>
ffffffffc02052d0:	00002617          	auipc	a2,0x2
ffffffffc02052d4:	90060613          	addi	a2,a2,-1792 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02052d8:	1b200593          	li	a1,434
ffffffffc02052dc:	00003517          	auipc	a0,0x3
ffffffffc02052e0:	51450513          	addi	a0,a0,1300 # ffffffffc02087f0 <default_pmm_manager+0x14d8>
ffffffffc02052e4:	99cfb0ef          	jal	ra,ffffffffc0200480 <__panic>
    proc->cr3 = PADDR(mm->pgdir);
ffffffffc02052e8:	86be                	mv	a3,a5
ffffffffc02052ea:	00002617          	auipc	a2,0x2
ffffffffc02052ee:	0b660613          	addi	a2,a2,182 # ffffffffc02073a0 <default_pmm_manager+0x88>
ffffffffc02052f2:	16500593          	li	a1,357
ffffffffc02052f6:	00003517          	auipc	a0,0x3
ffffffffc02052fa:	4fa50513          	addi	a0,a0,1274 # ffffffffc02087f0 <default_pmm_manager+0x14d8>
ffffffffc02052fe:	982fb0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("Unlock failed.\n");
ffffffffc0205302:	00003617          	auipc	a2,0x3
ffffffffc0205306:	27e60613          	addi	a2,a2,638 # ffffffffc0208580 <default_pmm_manager+0x1268>
ffffffffc020530a:	03100593          	li	a1,49
ffffffffc020530e:	00003517          	auipc	a0,0x3
ffffffffc0205312:	28250513          	addi	a0,a0,642 # ffffffffc0208590 <default_pmm_manager+0x1278>
ffffffffc0205316:	96afb0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc020531a:	00002617          	auipc	a2,0x2
ffffffffc020531e:	0ae60613          	addi	a2,a2,174 # ffffffffc02073c8 <default_pmm_manager+0xb0>
ffffffffc0205322:	06200593          	li	a1,98
ffffffffc0205326:	00002517          	auipc	a0,0x2
ffffffffc020532a:	06a50513          	addi	a0,a0,106 # ffffffffc0207390 <default_pmm_manager+0x78>
ffffffffc020532e:	952fb0ef          	jal	ra,ffffffffc0200480 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0205332:	00002617          	auipc	a2,0x2
ffffffffc0205336:	06e60613          	addi	a2,a2,110 # ffffffffc02073a0 <default_pmm_manager+0x88>
ffffffffc020533a:	06e00593          	li	a1,110
ffffffffc020533e:	00002517          	auipc	a0,0x2
ffffffffc0205342:	05250513          	addi	a0,a0,82 # ffffffffc0207390 <default_pmm_manager+0x78>
ffffffffc0205346:	93afb0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc020534a <kernel_thread>:
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc020534a:	7129                	addi	sp,sp,-320
ffffffffc020534c:	fa22                	sd	s0,304(sp)
ffffffffc020534e:	f626                	sd	s1,296(sp)
ffffffffc0205350:	f24a                	sd	s2,288(sp)
ffffffffc0205352:	84ae                	mv	s1,a1
ffffffffc0205354:	892a                	mv	s2,a0
ffffffffc0205356:	8432                	mv	s0,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205358:	4581                	li	a1,0
ffffffffc020535a:	12000613          	li	a2,288
ffffffffc020535e:	850a                	mv	a0,sp
kernel_thread(int (*fn)(void *), void *arg, uint32_t clone_flags) {
ffffffffc0205360:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0205362:	24e010ef          	jal	ra,ffffffffc02065b0 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0205366:	e0ca                	sd	s2,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0205368:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc020536a:	100027f3          	csrr	a5,sstatus
ffffffffc020536e:	edd7f793          	andi	a5,a5,-291
ffffffffc0205372:	1207e793          	ori	a5,a5,288
ffffffffc0205376:	e23e                	sd	a5,256(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205378:	860a                	mv	a2,sp
ffffffffc020537a:	10046513          	ori	a0,s0,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc020537e:	00000797          	auipc	a5,0x0
ffffffffc0205382:	8e678793          	addi	a5,a5,-1818 # ffffffffc0204c64 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0205386:	4581                	li	a1,0
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0205388:	e63e                	sd	a5,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc020538a:	be5ff0ef          	jal	ra,ffffffffc0204f6e <do_fork>
}
ffffffffc020538e:	70f2                	ld	ra,312(sp)
ffffffffc0205390:	7452                	ld	s0,304(sp)
ffffffffc0205392:	74b2                	ld	s1,296(sp)
ffffffffc0205394:	7912                	ld	s2,288(sp)
ffffffffc0205396:	6131                	addi	sp,sp,320
ffffffffc0205398:	8082                	ret

ffffffffc020539a <do_exit>:
do_exit(int error_code) {
ffffffffc020539a:	7179                	addi	sp,sp,-48
ffffffffc020539c:	e84a                	sd	s2,16(sp)
    if (current == idleproc) {
ffffffffc020539e:	000a7717          	auipc	a4,0xa7
ffffffffc02053a2:	4e270713          	addi	a4,a4,1250 # ffffffffc02ac880 <idleproc>
ffffffffc02053a6:	000a7917          	auipc	s2,0xa7
ffffffffc02053aa:	4d290913          	addi	s2,s2,1234 # ffffffffc02ac878 <current>
ffffffffc02053ae:	00093783          	ld	a5,0(s2)
ffffffffc02053b2:	6318                	ld	a4,0(a4)
do_exit(int error_code) {
ffffffffc02053b4:	f406                	sd	ra,40(sp)
ffffffffc02053b6:	f022                	sd	s0,32(sp)
ffffffffc02053b8:	ec26                	sd	s1,24(sp)
ffffffffc02053ba:	e44e                	sd	s3,8(sp)
ffffffffc02053bc:	e052                	sd	s4,0(sp)
    if (current == idleproc) {
ffffffffc02053be:	0ce78c63          	beq	a5,a4,ffffffffc0205496 <do_exit+0xfc>
    if (current == initproc) {
ffffffffc02053c2:	000a7417          	auipc	s0,0xa7
ffffffffc02053c6:	4c640413          	addi	s0,s0,1222 # ffffffffc02ac888 <initproc>
ffffffffc02053ca:	6018                	ld	a4,0(s0)
ffffffffc02053cc:	0ee78b63          	beq	a5,a4,ffffffffc02054c2 <do_exit+0x128>
    struct mm_struct *mm = current->mm;
ffffffffc02053d0:	7784                	ld	s1,40(a5)
ffffffffc02053d2:	89aa                	mv	s3,a0
    if (mm != NULL) {
ffffffffc02053d4:	c48d                	beqz	s1,ffffffffc02053fe <do_exit+0x64>
        lcr3(boot_cr3);
ffffffffc02053d6:	000a7797          	auipc	a5,0xa7
ffffffffc02053da:	4f278793          	addi	a5,a5,1266 # ffffffffc02ac8c8 <boot_cr3>
ffffffffc02053de:	639c                	ld	a5,0(a5)
ffffffffc02053e0:	577d                	li	a4,-1
ffffffffc02053e2:	177e                	slli	a4,a4,0x3f
ffffffffc02053e4:	83b1                	srli	a5,a5,0xc
ffffffffc02053e6:	8fd9                	or	a5,a5,a4
ffffffffc02053e8:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc02053ec:	589c                	lw	a5,48(s1)
ffffffffc02053ee:	fff7871b          	addiw	a4,a5,-1
ffffffffc02053f2:	d898                	sw	a4,48(s1)
        if (mm_count_dec(mm) == 0) {
ffffffffc02053f4:	cf4d                	beqz	a4,ffffffffc02054ae <do_exit+0x114>
        current->mm = NULL;
ffffffffc02053f6:	00093783          	ld	a5,0(s2)
ffffffffc02053fa:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc02053fe:	00093783          	ld	a5,0(s2)
ffffffffc0205402:	470d                	li	a4,3
ffffffffc0205404:	c398                	sw	a4,0(a5)
    current->exit_code = error_code;
ffffffffc0205406:	0f37a423          	sw	s3,232(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020540a:	100027f3          	csrr	a5,sstatus
ffffffffc020540e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205410:	4a01                	li	s4,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205412:	e7e1                	bnez	a5,ffffffffc02054da <do_exit+0x140>
        proc = current->parent;
ffffffffc0205414:	00093703          	ld	a4,0(s2)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205418:	800007b7          	lui	a5,0x80000
ffffffffc020541c:	0785                	addi	a5,a5,1
        proc = current->parent;
ffffffffc020541e:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD) {
ffffffffc0205420:	0ec52703          	lw	a4,236(a0)
ffffffffc0205424:	0af70f63          	beq	a4,a5,ffffffffc02054e2 <do_exit+0x148>
ffffffffc0205428:	00093683          	ld	a3,0(s2)
                if (initproc->wait_state == WT_CHILD) {
ffffffffc020542c:	800009b7          	lui	s3,0x80000
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205430:	448d                	li	s1,3
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205432:	0985                	addi	s3,s3,1
        while (current->cptr != NULL) {
ffffffffc0205434:	7afc                	ld	a5,240(a3)
ffffffffc0205436:	cb95                	beqz	a5,ffffffffc020546a <do_exit+0xd0>
            current->cptr = proc->optr;
ffffffffc0205438:	1007b703          	ld	a4,256(a5) # ffffffff80000100 <_binary_obj___user_exit_out_size+0xffffffff7fff5630>
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc020543c:	6008                	ld	a0,0(s0)
            current->cptr = proc->optr;
ffffffffc020543e:	faf8                	sd	a4,240(a3)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205440:	7978                	ld	a4,240(a0)
            proc->yptr = NULL;
ffffffffc0205442:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL) {
ffffffffc0205446:	10e7b023          	sd	a4,256(a5)
ffffffffc020544a:	c311                	beqz	a4,ffffffffc020544e <do_exit+0xb4>
                initproc->cptr->yptr = proc;
ffffffffc020544c:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020544e:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc0205450:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc0205452:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE) {
ffffffffc0205454:	fe9710e3          	bne	a4,s1,ffffffffc0205434 <do_exit+0x9a>
                if (initproc->wait_state == WT_CHILD) {
ffffffffc0205458:	0ec52783          	lw	a5,236(a0)
ffffffffc020545c:	fd379ce3          	bne	a5,s3,ffffffffc0205434 <do_exit+0x9a>
                    wakeup_proc(initproc);
ffffffffc0205460:	2bd000ef          	jal	ra,ffffffffc0205f1c <wakeup_proc>
ffffffffc0205464:	00093683          	ld	a3,0(s2)
ffffffffc0205468:	b7f1                	j	ffffffffc0205434 <do_exit+0x9a>
    if (flag) {
ffffffffc020546a:	020a1363          	bnez	s4,ffffffffc0205490 <do_exit+0xf6>
    schedule();
ffffffffc020546e:	32b000ef          	jal	ra,ffffffffc0205f98 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0205472:	00093783          	ld	a5,0(s2)
ffffffffc0205476:	00003617          	auipc	a2,0x3
ffffffffc020547a:	0ca60613          	addi	a2,a2,202 # ffffffffc0208540 <default_pmm_manager+0x1228>
ffffffffc020547e:	20400593          	li	a1,516
ffffffffc0205482:	43d4                	lw	a3,4(a5)
ffffffffc0205484:	00003517          	auipc	a0,0x3
ffffffffc0205488:	36c50513          	addi	a0,a0,876 # ffffffffc02087f0 <default_pmm_manager+0x14d8>
ffffffffc020548c:	ff5fa0ef          	jal	ra,ffffffffc0200480 <__panic>
        intr_enable();
ffffffffc0205490:	9bcfb0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0205494:	bfe9                	j	ffffffffc020546e <do_exit+0xd4>
        panic("idleproc exit.\n");
ffffffffc0205496:	00003617          	auipc	a2,0x3
ffffffffc020549a:	08a60613          	addi	a2,a2,138 # ffffffffc0208520 <default_pmm_manager+0x1208>
ffffffffc020549e:	1d800593          	li	a1,472
ffffffffc02054a2:	00003517          	auipc	a0,0x3
ffffffffc02054a6:	34e50513          	addi	a0,a0,846 # ffffffffc02087f0 <default_pmm_manager+0x14d8>
ffffffffc02054aa:	fd7fa0ef          	jal	ra,ffffffffc0200480 <__panic>
            exit_mmap(mm);
ffffffffc02054ae:	8526                	mv	a0,s1
ffffffffc02054b0:	f01fe0ef          	jal	ra,ffffffffc02043b0 <exit_mmap>
            put_pgdir(mm);
ffffffffc02054b4:	8526                	mv	a0,s1
ffffffffc02054b6:	8bdff0ef          	jal	ra,ffffffffc0204d72 <put_pgdir>
            mm_destroy(mm);
ffffffffc02054ba:	8526                	mv	a0,s1
ffffffffc02054bc:	d55fe0ef          	jal	ra,ffffffffc0204210 <mm_destroy>
ffffffffc02054c0:	bf1d                	j	ffffffffc02053f6 <do_exit+0x5c>
        panic("initproc exit.\n");
ffffffffc02054c2:	00003617          	auipc	a2,0x3
ffffffffc02054c6:	06e60613          	addi	a2,a2,110 # ffffffffc0208530 <default_pmm_manager+0x1218>
ffffffffc02054ca:	1db00593          	li	a1,475
ffffffffc02054ce:	00003517          	auipc	a0,0x3
ffffffffc02054d2:	32250513          	addi	a0,a0,802 # ffffffffc02087f0 <default_pmm_manager+0x14d8>
ffffffffc02054d6:	fabfa0ef          	jal	ra,ffffffffc0200480 <__panic>
        intr_disable();
ffffffffc02054da:	978fb0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc02054de:	4a05                	li	s4,1
ffffffffc02054e0:	bf15                	j	ffffffffc0205414 <do_exit+0x7a>
            wakeup_proc(proc);
ffffffffc02054e2:	23b000ef          	jal	ra,ffffffffc0205f1c <wakeup_proc>
ffffffffc02054e6:	b789                	j	ffffffffc0205428 <do_exit+0x8e>

ffffffffc02054e8 <do_wait.part.1>:
do_wait(int pid, int *code_store) {
ffffffffc02054e8:	7139                	addi	sp,sp,-64
ffffffffc02054ea:	e852                	sd	s4,16(sp)
        current->wait_state = WT_CHILD;
ffffffffc02054ec:	80000a37          	lui	s4,0x80000
do_wait(int pid, int *code_store) {
ffffffffc02054f0:	f426                	sd	s1,40(sp)
ffffffffc02054f2:	f04a                	sd	s2,32(sp)
ffffffffc02054f4:	ec4e                	sd	s3,24(sp)
ffffffffc02054f6:	e456                	sd	s5,8(sp)
ffffffffc02054f8:	e05a                	sd	s6,0(sp)
ffffffffc02054fa:	fc06                	sd	ra,56(sp)
ffffffffc02054fc:	f822                	sd	s0,48(sp)
ffffffffc02054fe:	89aa                	mv	s3,a0
ffffffffc0205500:	8b2e                	mv	s6,a1
        proc = current->cptr;
ffffffffc0205502:	000a7917          	auipc	s2,0xa7
ffffffffc0205506:	37690913          	addi	s2,s2,886 # ffffffffc02ac878 <current>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020550a:	448d                	li	s1,3
        current->state = PROC_SLEEPING;
ffffffffc020550c:	4a85                	li	s5,1
        current->wait_state = WT_CHILD;
ffffffffc020550e:	0a05                	addi	s4,s4,1
    if (pid != 0) {
ffffffffc0205510:	02098f63          	beqz	s3,ffffffffc020554e <do_wait.part.1+0x66>
        proc = find_proc(pid);
ffffffffc0205514:	854e                	mv	a0,s3
ffffffffc0205516:	9fdff0ef          	jal	ra,ffffffffc0204f12 <find_proc>
ffffffffc020551a:	842a                	mv	s0,a0
        if (proc != NULL && proc->parent == current) {
ffffffffc020551c:	12050063          	beqz	a0,ffffffffc020563c <do_wait.part.1+0x154>
ffffffffc0205520:	00093703          	ld	a4,0(s2)
ffffffffc0205524:	711c                	ld	a5,32(a0)
ffffffffc0205526:	10e79b63          	bne	a5,a4,ffffffffc020563c <do_wait.part.1+0x154>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020552a:	411c                	lw	a5,0(a0)
ffffffffc020552c:	02978c63          	beq	a5,s1,ffffffffc0205564 <do_wait.part.1+0x7c>
        current->state = PROC_SLEEPING;
ffffffffc0205530:	01572023          	sw	s5,0(a4)
        current->wait_state = WT_CHILD;
ffffffffc0205534:	0f472623          	sw	s4,236(a4)
        schedule();
ffffffffc0205538:	261000ef          	jal	ra,ffffffffc0205f98 <schedule>
        if (current->flags & PF_EXITING) {
ffffffffc020553c:	00093783          	ld	a5,0(s2)
ffffffffc0205540:	0b07a783          	lw	a5,176(a5)
ffffffffc0205544:	8b85                	andi	a5,a5,1
ffffffffc0205546:	d7e9                	beqz	a5,ffffffffc0205510 <do_wait.part.1+0x28>
            do_exit(-E_KILLED);
ffffffffc0205548:	555d                	li	a0,-9
ffffffffc020554a:	e51ff0ef          	jal	ra,ffffffffc020539a <do_exit>
        proc = current->cptr;
ffffffffc020554e:	00093703          	ld	a4,0(s2)
ffffffffc0205552:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr) {
ffffffffc0205554:	e409                	bnez	s0,ffffffffc020555e <do_wait.part.1+0x76>
ffffffffc0205556:	a0dd                	j	ffffffffc020563c <do_wait.part.1+0x154>
ffffffffc0205558:	10043403          	ld	s0,256(s0)
ffffffffc020555c:	d871                	beqz	s0,ffffffffc0205530 <do_wait.part.1+0x48>
            if (proc->state == PROC_ZOMBIE) {
ffffffffc020555e:	401c                	lw	a5,0(s0)
ffffffffc0205560:	fe979ce3          	bne	a5,s1,ffffffffc0205558 <do_wait.part.1+0x70>
    if (proc == idleproc || proc == initproc) {
ffffffffc0205564:	000a7797          	auipc	a5,0xa7
ffffffffc0205568:	31c78793          	addi	a5,a5,796 # ffffffffc02ac880 <idleproc>
ffffffffc020556c:	639c                	ld	a5,0(a5)
ffffffffc020556e:	0c878d63          	beq	a5,s0,ffffffffc0205648 <do_wait.part.1+0x160>
ffffffffc0205572:	000a7797          	auipc	a5,0xa7
ffffffffc0205576:	31678793          	addi	a5,a5,790 # ffffffffc02ac888 <initproc>
ffffffffc020557a:	639c                	ld	a5,0(a5)
ffffffffc020557c:	0cf40663          	beq	s0,a5,ffffffffc0205648 <do_wait.part.1+0x160>
    if (code_store != NULL) {
ffffffffc0205580:	000b0663          	beqz	s6,ffffffffc020558c <do_wait.part.1+0xa4>
        *code_store = proc->exit_code;
ffffffffc0205584:	0e842783          	lw	a5,232(s0)
ffffffffc0205588:	00fb2023          	sw	a5,0(s6)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020558c:	100027f3          	csrr	a5,sstatus
ffffffffc0205590:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205592:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205594:	e7d5                	bnez	a5,ffffffffc0205640 <do_wait.part.1+0x158>
    __list_del(listelm->prev, listelm->next);
ffffffffc0205596:	6c70                	ld	a2,216(s0)
ffffffffc0205598:	7074                	ld	a3,224(s0)
    if (proc->optr != NULL) {
ffffffffc020559a:	10043703          	ld	a4,256(s0)
ffffffffc020559e:	7c7c                	ld	a5,248(s0)
    prev->next = next;
ffffffffc02055a0:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02055a2:	e290                	sd	a2,0(a3)
    __list_del(listelm->prev, listelm->next);
ffffffffc02055a4:	6470                	ld	a2,200(s0)
ffffffffc02055a6:	6874                	ld	a3,208(s0)
    prev->next = next;
ffffffffc02055a8:	e614                	sd	a3,8(a2)
    next->prev = prev;
ffffffffc02055aa:	e290                	sd	a2,0(a3)
ffffffffc02055ac:	c319                	beqz	a4,ffffffffc02055b2 <do_wait.part.1+0xca>
        proc->optr->yptr = proc->yptr;
ffffffffc02055ae:	ff7c                	sd	a5,248(a4)
ffffffffc02055b0:	7c7c                	ld	a5,248(s0)
    if (proc->yptr != NULL) {
ffffffffc02055b2:	c3d1                	beqz	a5,ffffffffc0205636 <do_wait.part.1+0x14e>
        proc->yptr->optr = proc->optr;
ffffffffc02055b4:	10e7b023          	sd	a4,256(a5)
    nr_process --;
ffffffffc02055b8:	000a7797          	auipc	a5,0xa7
ffffffffc02055bc:	2d878793          	addi	a5,a5,728 # ffffffffc02ac890 <nr_process>
ffffffffc02055c0:	439c                	lw	a5,0(a5)
ffffffffc02055c2:	37fd                	addiw	a5,a5,-1
ffffffffc02055c4:	000a7717          	auipc	a4,0xa7
ffffffffc02055c8:	2cf72623          	sw	a5,716(a4) # ffffffffc02ac890 <nr_process>
    if (flag) {
ffffffffc02055cc:	e1b5                	bnez	a1,ffffffffc0205630 <do_wait.part.1+0x148>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02055ce:	6814                	ld	a3,16(s0)
ffffffffc02055d0:	c02007b7          	lui	a5,0xc0200
ffffffffc02055d4:	0af6e263          	bltu	a3,a5,ffffffffc0205678 <do_wait.part.1+0x190>
ffffffffc02055d8:	000a7797          	auipc	a5,0xa7
ffffffffc02055dc:	2e878793          	addi	a5,a5,744 # ffffffffc02ac8c0 <va_pa_offset>
ffffffffc02055e0:	6398                	ld	a4,0(a5)
    if (PPN(pa) >= npage) {
ffffffffc02055e2:	000a7797          	auipc	a5,0xa7
ffffffffc02055e6:	27e78793          	addi	a5,a5,638 # ffffffffc02ac860 <npage>
ffffffffc02055ea:	639c                	ld	a5,0(a5)
    return pa2page(PADDR(kva));
ffffffffc02055ec:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage) {
ffffffffc02055ee:	82b1                	srli	a3,a3,0xc
ffffffffc02055f0:	06f6f863          	bgeu	a3,a5,ffffffffc0205660 <do_wait.part.1+0x178>
    return &pages[PPN(pa) - nbase];
ffffffffc02055f4:	00003797          	auipc	a5,0x3
ffffffffc02055f8:	6c478793          	addi	a5,a5,1732 # ffffffffc0208cb8 <nbase>
ffffffffc02055fc:	639c                	ld	a5,0(a5)
ffffffffc02055fe:	000a7717          	auipc	a4,0xa7
ffffffffc0205602:	2d270713          	addi	a4,a4,722 # ffffffffc02ac8d0 <pages>
ffffffffc0205606:	6308                	ld	a0,0(a4)
ffffffffc0205608:	8e9d                	sub	a3,a3,a5
ffffffffc020560a:	069a                	slli	a3,a3,0x6
ffffffffc020560c:	9536                	add	a0,a0,a3
ffffffffc020560e:	4589                	li	a1,2
ffffffffc0205610:	89dfc0ef          	jal	ra,ffffffffc0201eac <free_pages>
    kfree(proc);
ffffffffc0205614:	8522                	mv	a0,s0
ffffffffc0205616:	ed2fc0ef          	jal	ra,ffffffffc0201ce8 <kfree>
    return 0;
ffffffffc020561a:	4501                	li	a0,0
}
ffffffffc020561c:	70e2                	ld	ra,56(sp)
ffffffffc020561e:	7442                	ld	s0,48(sp)
ffffffffc0205620:	74a2                	ld	s1,40(sp)
ffffffffc0205622:	7902                	ld	s2,32(sp)
ffffffffc0205624:	69e2                	ld	s3,24(sp)
ffffffffc0205626:	6a42                	ld	s4,16(sp)
ffffffffc0205628:	6aa2                	ld	s5,8(sp)
ffffffffc020562a:	6b02                	ld	s6,0(sp)
ffffffffc020562c:	6121                	addi	sp,sp,64
ffffffffc020562e:	8082                	ret
        intr_enable();
ffffffffc0205630:	81cfb0ef          	jal	ra,ffffffffc020064c <intr_enable>
ffffffffc0205634:	bf69                	j	ffffffffc02055ce <do_wait.part.1+0xe6>
       proc->parent->cptr = proc->optr;
ffffffffc0205636:	701c                	ld	a5,32(s0)
ffffffffc0205638:	fbf8                	sd	a4,240(a5)
ffffffffc020563a:	bfbd                	j	ffffffffc02055b8 <do_wait.part.1+0xd0>
    return -E_BAD_PROC;
ffffffffc020563c:	5579                	li	a0,-2
ffffffffc020563e:	bff9                	j	ffffffffc020561c <do_wait.part.1+0x134>
        intr_disable();
ffffffffc0205640:	812fb0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0205644:	4585                	li	a1,1
ffffffffc0205646:	bf81                	j	ffffffffc0205596 <do_wait.part.1+0xae>
        panic("wait idleproc or initproc.\n");
ffffffffc0205648:	00003617          	auipc	a2,0x3
ffffffffc020564c:	f6060613          	addi	a2,a2,-160 # ffffffffc02085a8 <default_pmm_manager+0x1290>
ffffffffc0205650:	2fb00593          	li	a1,763
ffffffffc0205654:	00003517          	auipc	a0,0x3
ffffffffc0205658:	19c50513          	addi	a0,a0,412 # ffffffffc02087f0 <default_pmm_manager+0x14d8>
ffffffffc020565c:	e25fa0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0205660:	00002617          	auipc	a2,0x2
ffffffffc0205664:	d6860613          	addi	a2,a2,-664 # ffffffffc02073c8 <default_pmm_manager+0xb0>
ffffffffc0205668:	06200593          	li	a1,98
ffffffffc020566c:	00002517          	auipc	a0,0x2
ffffffffc0205670:	d2450513          	addi	a0,a0,-732 # ffffffffc0207390 <default_pmm_manager+0x78>
ffffffffc0205674:	e0dfa0ef          	jal	ra,ffffffffc0200480 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0205678:	00002617          	auipc	a2,0x2
ffffffffc020567c:	d2860613          	addi	a2,a2,-728 # ffffffffc02073a0 <default_pmm_manager+0x88>
ffffffffc0205680:	06e00593          	li	a1,110
ffffffffc0205684:	00002517          	auipc	a0,0x2
ffffffffc0205688:	d0c50513          	addi	a0,a0,-756 # ffffffffc0207390 <default_pmm_manager+0x78>
ffffffffc020568c:	df5fa0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0205690 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg) {
ffffffffc0205690:	1141                	addi	sp,sp,-16
ffffffffc0205692:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0205694:	85ffc0ef          	jal	ra,ffffffffc0201ef2 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc0205698:	d90fc0ef          	jal	ra,ffffffffc0201c28 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc020569c:	4601                	li	a2,0
ffffffffc020569e:	4581                	li	a1,0
ffffffffc02056a0:	fffff517          	auipc	a0,0xfffff
ffffffffc02056a4:	65050513          	addi	a0,a0,1616 # ffffffffc0204cf0 <user_main>
ffffffffc02056a8:	ca3ff0ef          	jal	ra,ffffffffc020534a <kernel_thread>
    if (pid <= 0) {
ffffffffc02056ac:	00a04563          	bgtz	a0,ffffffffc02056b6 <init_main+0x26>
ffffffffc02056b0:	a841                	j	ffffffffc0205740 <init_main+0xb0>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0) {
        schedule();
ffffffffc02056b2:	0e7000ef          	jal	ra,ffffffffc0205f98 <schedule>
    if (code_store != NULL) {
ffffffffc02056b6:	4581                	li	a1,0
ffffffffc02056b8:	4501                	li	a0,0
ffffffffc02056ba:	e2fff0ef          	jal	ra,ffffffffc02054e8 <do_wait.part.1>
    while (do_wait(0, NULL) == 0) {
ffffffffc02056be:	d975                	beqz	a0,ffffffffc02056b2 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc02056c0:	00003517          	auipc	a0,0x3
ffffffffc02056c4:	f2850513          	addi	a0,a0,-216 # ffffffffc02085e8 <default_pmm_manager+0x12d0>
ffffffffc02056c8:	ac7fa0ef          	jal	ra,ffffffffc020018e <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02056cc:	000a7797          	auipc	a5,0xa7
ffffffffc02056d0:	1bc78793          	addi	a5,a5,444 # ffffffffc02ac888 <initproc>
ffffffffc02056d4:	639c                	ld	a5,0(a5)
ffffffffc02056d6:	7bf8                	ld	a4,240(a5)
ffffffffc02056d8:	e721                	bnez	a4,ffffffffc0205720 <init_main+0x90>
ffffffffc02056da:	7ff8                	ld	a4,248(a5)
ffffffffc02056dc:	e331                	bnez	a4,ffffffffc0205720 <init_main+0x90>
ffffffffc02056de:	1007b703          	ld	a4,256(a5)
ffffffffc02056e2:	ef1d                	bnez	a4,ffffffffc0205720 <init_main+0x90>
    assert(nr_process == 2);
ffffffffc02056e4:	000a7717          	auipc	a4,0xa7
ffffffffc02056e8:	1ac70713          	addi	a4,a4,428 # ffffffffc02ac890 <nr_process>
ffffffffc02056ec:	4314                	lw	a3,0(a4)
ffffffffc02056ee:	4709                	li	a4,2
ffffffffc02056f0:	0ae69463          	bne	a3,a4,ffffffffc0205798 <init_main+0x108>
    return listelm->next;
ffffffffc02056f4:	000a7697          	auipc	a3,0xa7
ffffffffc02056f8:	2c468693          	addi	a3,a3,708 # ffffffffc02ac9b8 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02056fc:	6698                	ld	a4,8(a3)
ffffffffc02056fe:	0c878793          	addi	a5,a5,200
ffffffffc0205702:	06f71b63          	bne	a4,a5,ffffffffc0205778 <init_main+0xe8>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205706:	629c                	ld	a5,0(a3)
ffffffffc0205708:	04f71863          	bne	a4,a5,ffffffffc0205758 <init_main+0xc8>

    cprintf("init check memory pass.\n");
ffffffffc020570c:	00003517          	auipc	a0,0x3
ffffffffc0205710:	fc450513          	addi	a0,a0,-60 # ffffffffc02086d0 <default_pmm_manager+0x13b8>
ffffffffc0205714:	a7bfa0ef          	jal	ra,ffffffffc020018e <cprintf>
    return 0;
}
ffffffffc0205718:	60a2                	ld	ra,8(sp)
ffffffffc020571a:	4501                	li	a0,0
ffffffffc020571c:	0141                	addi	sp,sp,16
ffffffffc020571e:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0205720:	00003697          	auipc	a3,0x3
ffffffffc0205724:	ef068693          	addi	a3,a3,-272 # ffffffffc0208610 <default_pmm_manager+0x12f8>
ffffffffc0205728:	00001617          	auipc	a2,0x1
ffffffffc020572c:	4a860613          	addi	a2,a2,1192 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0205730:	36000593          	li	a1,864
ffffffffc0205734:	00003517          	auipc	a0,0x3
ffffffffc0205738:	0bc50513          	addi	a0,a0,188 # ffffffffc02087f0 <default_pmm_manager+0x14d8>
ffffffffc020573c:	d45fa0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("create user_main failed.\n");
ffffffffc0205740:	00003617          	auipc	a2,0x3
ffffffffc0205744:	e8860613          	addi	a2,a2,-376 # ffffffffc02085c8 <default_pmm_manager+0x12b0>
ffffffffc0205748:	35800593          	li	a1,856
ffffffffc020574c:	00003517          	auipc	a0,0x3
ffffffffc0205750:	0a450513          	addi	a0,a0,164 # ffffffffc02087f0 <default_pmm_manager+0x14d8>
ffffffffc0205754:	d2dfa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205758:	00003697          	auipc	a3,0x3
ffffffffc020575c:	f4868693          	addi	a3,a3,-184 # ffffffffc02086a0 <default_pmm_manager+0x1388>
ffffffffc0205760:	00001617          	auipc	a2,0x1
ffffffffc0205764:	47060613          	addi	a2,a2,1136 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0205768:	36300593          	li	a1,867
ffffffffc020576c:	00003517          	auipc	a0,0x3
ffffffffc0205770:	08450513          	addi	a0,a0,132 # ffffffffc02087f0 <default_pmm_manager+0x14d8>
ffffffffc0205774:	d0dfa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205778:	00003697          	auipc	a3,0x3
ffffffffc020577c:	ef868693          	addi	a3,a3,-264 # ffffffffc0208670 <default_pmm_manager+0x1358>
ffffffffc0205780:	00001617          	auipc	a2,0x1
ffffffffc0205784:	45060613          	addi	a2,a2,1104 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0205788:	36200593          	li	a1,866
ffffffffc020578c:	00003517          	auipc	a0,0x3
ffffffffc0205790:	06450513          	addi	a0,a0,100 # ffffffffc02087f0 <default_pmm_manager+0x14d8>
ffffffffc0205794:	cedfa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(nr_process == 2);
ffffffffc0205798:	00003697          	auipc	a3,0x3
ffffffffc020579c:	ec868693          	addi	a3,a3,-312 # ffffffffc0208660 <default_pmm_manager+0x1348>
ffffffffc02057a0:	00001617          	auipc	a2,0x1
ffffffffc02057a4:	43060613          	addi	a2,a2,1072 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc02057a8:	36100593          	li	a1,865
ffffffffc02057ac:	00003517          	auipc	a0,0x3
ffffffffc02057b0:	04450513          	addi	a0,a0,68 # ffffffffc02087f0 <default_pmm_manager+0x14d8>
ffffffffc02057b4:	ccdfa0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc02057b8 <do_execve>:
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02057b8:	7135                	addi	sp,sp,-160
ffffffffc02057ba:	f8d2                	sd	s4,112(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02057bc:	000a7a17          	auipc	s4,0xa7
ffffffffc02057c0:	0bca0a13          	addi	s4,s4,188 # ffffffffc02ac878 <current>
ffffffffc02057c4:	000a3783          	ld	a5,0(s4)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02057c8:	e14a                	sd	s2,128(sp)
ffffffffc02057ca:	e922                	sd	s0,144(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02057cc:	0287b903          	ld	s2,40(a5)
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02057d0:	fcce                	sd	s3,120(sp)
ffffffffc02057d2:	f0da                	sd	s6,96(sp)
ffffffffc02057d4:	89aa                	mv	s3,a0
ffffffffc02057d6:	842e                	mv	s0,a1
ffffffffc02057d8:	8b32                	mv	s6,a2
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02057da:	4681                	li	a3,0
ffffffffc02057dc:	862e                	mv	a2,a1
ffffffffc02057de:	85aa                	mv	a1,a0
ffffffffc02057e0:	854a                	mv	a0,s2
do_execve(const char *name, size_t len, unsigned char *binary, size_t size) {
ffffffffc02057e2:	ed06                	sd	ra,152(sp)
ffffffffc02057e4:	e526                	sd	s1,136(sp)
ffffffffc02057e6:	f4d6                	sd	s5,104(sp)
ffffffffc02057e8:	ecde                	sd	s7,88(sp)
ffffffffc02057ea:	e8e2                	sd	s8,80(sp)
ffffffffc02057ec:	e4e6                	sd	s9,72(sp)
ffffffffc02057ee:	e0ea                	sd	s10,64(sp)
ffffffffc02057f0:	fc6e                	sd	s11,56(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0)) {
ffffffffc02057f2:	a76ff0ef          	jal	ra,ffffffffc0204a68 <user_mem_check>
ffffffffc02057f6:	40050263          	beqz	a0,ffffffffc0205bfa <do_execve+0x442>
    memset(local_name, 0, sizeof(local_name));
ffffffffc02057fa:	4641                	li	a2,16
ffffffffc02057fc:	4581                	li	a1,0
ffffffffc02057fe:	1008                	addi	a0,sp,32
ffffffffc0205800:	5b1000ef          	jal	ra,ffffffffc02065b0 <memset>
    memcpy(local_name, name, len);
ffffffffc0205804:	47bd                	li	a5,15
ffffffffc0205806:	8622                	mv	a2,s0
ffffffffc0205808:	0687ee63          	bltu	a5,s0,ffffffffc0205884 <do_execve+0xcc>
ffffffffc020580c:	85ce                	mv	a1,s3
ffffffffc020580e:	1008                	addi	a0,sp,32
ffffffffc0205810:	5b3000ef          	jal	ra,ffffffffc02065c2 <memcpy>
    if (mm != NULL) {
ffffffffc0205814:	06090f63          	beqz	s2,ffffffffc0205892 <do_execve+0xda>
        cputs("mm != NULL");
ffffffffc0205818:	00002517          	auipc	a0,0x2
ffffffffc020581c:	2f050513          	addi	a0,a0,752 # ffffffffc0207b08 <default_pmm_manager+0x7f0>
ffffffffc0205820:	9a5fa0ef          	jal	ra,ffffffffc02001c4 <cputs>
        lcr3(boot_cr3);
ffffffffc0205824:	000a7797          	auipc	a5,0xa7
ffffffffc0205828:	0a478793          	addi	a5,a5,164 # ffffffffc02ac8c8 <boot_cr3>
ffffffffc020582c:	639c                	ld	a5,0(a5)
ffffffffc020582e:	577d                	li	a4,-1
ffffffffc0205830:	177e                	slli	a4,a4,0x3f
ffffffffc0205832:	83b1                	srli	a5,a5,0xc
ffffffffc0205834:	8fd9                	or	a5,a5,a4
ffffffffc0205836:	18079073          	csrw	satp,a5
ffffffffc020583a:	03092783          	lw	a5,48(s2)
ffffffffc020583e:	fff7871b          	addiw	a4,a5,-1
ffffffffc0205842:	02e92823          	sw	a4,48(s2)
        if (mm_count_dec(mm) == 0) {
ffffffffc0205846:	28070c63          	beqz	a4,ffffffffc0205ade <do_execve+0x326>
        current->mm = NULL;
ffffffffc020584a:	000a3783          	ld	a5,0(s4)
ffffffffc020584e:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL) {
ffffffffc0205852:	839fe0ef          	jal	ra,ffffffffc020408a <mm_create>
ffffffffc0205856:	892a                	mv	s2,a0
ffffffffc0205858:	c135                	beqz	a0,ffffffffc02058bc <do_execve+0x104>
    if (setup_pgdir(mm) != 0) {
ffffffffc020585a:	d96ff0ef          	jal	ra,ffffffffc0204df0 <setup_pgdir>
ffffffffc020585e:	e931                	bnez	a0,ffffffffc02058b2 <do_execve+0xfa>
    if (elf->e_magic != ELF_MAGIC) {
ffffffffc0205860:	000b2703          	lw	a4,0(s6)
ffffffffc0205864:	464c47b7          	lui	a5,0x464c4
ffffffffc0205868:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464b9aaf>
ffffffffc020586c:	04f70a63          	beq	a4,a5,ffffffffc02058c0 <do_execve+0x108>
    put_pgdir(mm);
ffffffffc0205870:	854a                	mv	a0,s2
ffffffffc0205872:	d00ff0ef          	jal	ra,ffffffffc0204d72 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205876:	854a                	mv	a0,s2
ffffffffc0205878:	999fe0ef          	jal	ra,ffffffffc0204210 <mm_destroy>
        ret = -E_INVAL_ELF;
ffffffffc020587c:	59e1                	li	s3,-8
    do_exit(ret);
ffffffffc020587e:	854e                	mv	a0,s3
ffffffffc0205880:	b1bff0ef          	jal	ra,ffffffffc020539a <do_exit>
    memcpy(local_name, name, len);
ffffffffc0205884:	463d                	li	a2,15
ffffffffc0205886:	85ce                	mv	a1,s3
ffffffffc0205888:	1008                	addi	a0,sp,32
ffffffffc020588a:	539000ef          	jal	ra,ffffffffc02065c2 <memcpy>
    if (mm != NULL) {
ffffffffc020588e:	f80915e3          	bnez	s2,ffffffffc0205818 <do_execve+0x60>
    if (current->mm != NULL) {
ffffffffc0205892:	000a3783          	ld	a5,0(s4)
ffffffffc0205896:	779c                	ld	a5,40(a5)
ffffffffc0205898:	dfcd                	beqz	a5,ffffffffc0205852 <do_execve+0x9a>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc020589a:	00003617          	auipc	a2,0x3
ffffffffc020589e:	afe60613          	addi	a2,a2,-1282 # ffffffffc0208398 <default_pmm_manager+0x1080>
ffffffffc02058a2:	20e00593          	li	a1,526
ffffffffc02058a6:	00003517          	auipc	a0,0x3
ffffffffc02058aa:	f4a50513          	addi	a0,a0,-182 # ffffffffc02087f0 <default_pmm_manager+0x14d8>
ffffffffc02058ae:	bd3fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    mm_destroy(mm);
ffffffffc02058b2:	854a                	mv	a0,s2
ffffffffc02058b4:	95dfe0ef          	jal	ra,ffffffffc0204210 <mm_destroy>
    int ret = -E_NO_MEM;
ffffffffc02058b8:	59f1                	li	s3,-4
ffffffffc02058ba:	b7d1                	j	ffffffffc020587e <do_execve+0xc6>
ffffffffc02058bc:	59f1                	li	s3,-4
ffffffffc02058be:	b7c1                	j	ffffffffc020587e <do_execve+0xc6>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02058c0:	038b5703          	lhu	a4,56(s6)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc02058c4:	020b3403          	ld	s0,32(s6)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02058c8:	00371793          	slli	a5,a4,0x3
ffffffffc02058cc:	8f99                	sub	a5,a5,a4
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc02058ce:	945a                	add	s0,s0,s6
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02058d0:	078e                	slli	a5,a5,0x3
ffffffffc02058d2:	97a2                	add	a5,a5,s0
ffffffffc02058d4:	ec3e                	sd	a5,24(sp)
    for (; ph < ph_end; ph ++) {
ffffffffc02058d6:	02f47b63          	bgeu	s0,a5,ffffffffc020590c <do_execve+0x154>
    return KADDR(page2pa(page));
ffffffffc02058da:	5bfd                	li	s7,-1
ffffffffc02058dc:	00cbd793          	srli	a5,s7,0xc
    return page - pages + nbase;
ffffffffc02058e0:	000a7d97          	auipc	s11,0xa7
ffffffffc02058e4:	ff0d8d93          	addi	s11,s11,-16 # ffffffffc02ac8d0 <pages>
ffffffffc02058e8:	00003d17          	auipc	s10,0x3
ffffffffc02058ec:	3d0d0d13          	addi	s10,s10,976 # ffffffffc0208cb8 <nbase>
    return KADDR(page2pa(page));
ffffffffc02058f0:	e43e                	sd	a5,8(sp)
ffffffffc02058f2:	000a7c97          	auipc	s9,0xa7
ffffffffc02058f6:	f6ec8c93          	addi	s9,s9,-146 # ffffffffc02ac860 <npage>
        if (ph->p_type != ELF_PT_LOAD) {
ffffffffc02058fa:	4018                	lw	a4,0(s0)
ffffffffc02058fc:	4785                	li	a5,1
ffffffffc02058fe:	0ef70d63          	beq	a4,a5,ffffffffc02059f8 <do_execve+0x240>
    for (; ph < ph_end; ph ++) {
ffffffffc0205902:	67e2                	ld	a5,24(sp)
ffffffffc0205904:	03840413          	addi	s0,s0,56
ffffffffc0205908:	fef469e3          	bltu	s0,a5,ffffffffc02058fa <do_execve+0x142>
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0) {
ffffffffc020590c:	4701                	li	a4,0
ffffffffc020590e:	46ad                	li	a3,11
ffffffffc0205910:	00100637          	lui	a2,0x100
ffffffffc0205914:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0205918:	854a                	mv	a0,s2
ffffffffc020591a:	949fe0ef          	jal	ra,ffffffffc0204262 <mm_map>
ffffffffc020591e:	89aa                	mv	s3,a0
ffffffffc0205920:	1a051563          	bnez	a0,ffffffffc0205aca <do_execve+0x312>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205924:	01893503          	ld	a0,24(s2)
ffffffffc0205928:	467d                	li	a2,31
ffffffffc020592a:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc020592e:	98ffd0ef          	jal	ra,ffffffffc02032bc <pgdir_alloc_page>
ffffffffc0205932:	36050063          	beqz	a0,ffffffffc0205c92 <do_execve+0x4da>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205936:	01893503          	ld	a0,24(s2)
ffffffffc020593a:	467d                	li	a2,31
ffffffffc020593c:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0205940:	97dfd0ef          	jal	ra,ffffffffc02032bc <pgdir_alloc_page>
ffffffffc0205944:	32050763          	beqz	a0,ffffffffc0205c72 <do_execve+0x4ba>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205948:	01893503          	ld	a0,24(s2)
ffffffffc020594c:	467d                	li	a2,31
ffffffffc020594e:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0205952:	96bfd0ef          	jal	ra,ffffffffc02032bc <pgdir_alloc_page>
ffffffffc0205956:	2e050e63          	beqz	a0,ffffffffc0205c52 <do_execve+0x49a>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc020595a:	01893503          	ld	a0,24(s2)
ffffffffc020595e:	467d                	li	a2,31
ffffffffc0205960:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0205964:	959fd0ef          	jal	ra,ffffffffc02032bc <pgdir_alloc_page>
ffffffffc0205968:	2c050563          	beqz	a0,ffffffffc0205c32 <do_execve+0x47a>
    mm->mm_count += 1;
ffffffffc020596c:	03092783          	lw	a5,48(s2)
    current->mm = mm;
ffffffffc0205970:	000a3603          	ld	a2,0(s4)
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205974:	01893683          	ld	a3,24(s2)
ffffffffc0205978:	2785                	addiw	a5,a5,1
ffffffffc020597a:	02f92823          	sw	a5,48(s2)
    current->mm = mm;
ffffffffc020597e:	03263423          	sd	s2,40(a2) # 100028 <_binary_obj___user_exit_out_size+0xf5558>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205982:	c02007b7          	lui	a5,0xc0200
ffffffffc0205986:	28f6ea63          	bltu	a3,a5,ffffffffc0205c1a <do_execve+0x462>
ffffffffc020598a:	000a7797          	auipc	a5,0xa7
ffffffffc020598e:	f3678793          	addi	a5,a5,-202 # ffffffffc02ac8c0 <va_pa_offset>
ffffffffc0205992:	639c                	ld	a5,0(a5)
ffffffffc0205994:	577d                	li	a4,-1
ffffffffc0205996:	177e                	slli	a4,a4,0x3f
ffffffffc0205998:	8e9d                	sub	a3,a3,a5
ffffffffc020599a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020599e:	f654                	sd	a3,168(a2)
ffffffffc02059a0:	8fd9                	or	a5,a5,a4
ffffffffc02059a2:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc02059a6:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02059a8:	4581                	li	a1,0
ffffffffc02059aa:	12000613          	li	a2,288
ffffffffc02059ae:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc02059b0:	10043483          	ld	s1,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02059b4:	3fd000ef          	jal	ra,ffffffffc02065b0 <memset>
    tf->epc = elf->e_entry;
ffffffffc02059b8:	018b3703          	ld	a4,24(s6)
     tf->gpr.sp = USTACKTOP;
ffffffffc02059bc:	4785                	li	a5,1
    set_proc_name(current, local_name);
ffffffffc02059be:	000a3503          	ld	a0,0(s4)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc02059c2:	edf4f493          	andi	s1,s1,-289
     tf->gpr.sp = USTACKTOP;
ffffffffc02059c6:	07fe                	slli	a5,a5,0x1f
ffffffffc02059c8:	e81c                	sd	a5,16(s0)
    tf->epc = elf->e_entry;
ffffffffc02059ca:	10e43423          	sd	a4,264(s0)
    tf->status = sstatus & ~(SSTATUS_SPP | SSTATUS_SPIE);
ffffffffc02059ce:	10943023          	sd	s1,256(s0)
    set_proc_name(current, local_name);
ffffffffc02059d2:	100c                	addi	a1,sp,32
ffffffffc02059d4:	ca8ff0ef          	jal	ra,ffffffffc0204e7c <set_proc_name>
}
ffffffffc02059d8:	60ea                	ld	ra,152(sp)
ffffffffc02059da:	644a                	ld	s0,144(sp)
ffffffffc02059dc:	854e                	mv	a0,s3
ffffffffc02059de:	64aa                	ld	s1,136(sp)
ffffffffc02059e0:	690a                	ld	s2,128(sp)
ffffffffc02059e2:	79e6                	ld	s3,120(sp)
ffffffffc02059e4:	7a46                	ld	s4,112(sp)
ffffffffc02059e6:	7aa6                	ld	s5,104(sp)
ffffffffc02059e8:	7b06                	ld	s6,96(sp)
ffffffffc02059ea:	6be6                	ld	s7,88(sp)
ffffffffc02059ec:	6c46                	ld	s8,80(sp)
ffffffffc02059ee:	6ca6                	ld	s9,72(sp)
ffffffffc02059f0:	6d06                	ld	s10,64(sp)
ffffffffc02059f2:	7de2                	ld	s11,56(sp)
ffffffffc02059f4:	610d                	addi	sp,sp,160
ffffffffc02059f6:	8082                	ret
        if (ph->p_filesz > ph->p_memsz) {
ffffffffc02059f8:	7410                	ld	a2,40(s0)
ffffffffc02059fa:	701c                	ld	a5,32(s0)
ffffffffc02059fc:	20f66163          	bltu	a2,a5,ffffffffc0205bfe <do_execve+0x446>
        if (ph->p_flags & ELF_PF_X) vm_flags |= VM_EXEC;
ffffffffc0205a00:	405c                	lw	a5,4(s0)
ffffffffc0205a02:	0017f693          	andi	a3,a5,1
ffffffffc0205a06:	c291                	beqz	a3,ffffffffc0205a0a <do_execve+0x252>
ffffffffc0205a08:	4691                	li	a3,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a0a:	0027f713          	andi	a4,a5,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a0e:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205a10:	0e071163          	bnez	a4,ffffffffc0205af2 <do_execve+0x33a>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205a14:	4745                	li	a4,17
ffffffffc0205a16:	e03a                	sd	a4,0(sp)
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a18:	c789                	beqz	a5,ffffffffc0205a22 <do_execve+0x26a>
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205a1a:	47cd                	li	a5,19
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205a1c:	0016e693          	ori	a3,a3,1
        if (vm_flags & VM_READ) perm |= PTE_R;
ffffffffc0205a20:	e03e                	sd	a5,0(sp)
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205a22:	0026f793          	andi	a5,a3,2
ffffffffc0205a26:	ebe9                	bnez	a5,ffffffffc0205af8 <do_execve+0x340>
        if (vm_flags & VM_EXEC) perm |= PTE_X;
ffffffffc0205a28:	0046f793          	andi	a5,a3,4
ffffffffc0205a2c:	c789                	beqz	a5,ffffffffc0205a36 <do_execve+0x27e>
ffffffffc0205a2e:	6782                	ld	a5,0(sp)
ffffffffc0205a30:	0087e793          	ori	a5,a5,8
ffffffffc0205a34:	e03e                	sd	a5,0(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0) {
ffffffffc0205a36:	680c                	ld	a1,16(s0)
ffffffffc0205a38:	4701                	li	a4,0
ffffffffc0205a3a:	854a                	mv	a0,s2
ffffffffc0205a3c:	827fe0ef          	jal	ra,ffffffffc0204262 <mm_map>
ffffffffc0205a40:	89aa                	mv	s3,a0
ffffffffc0205a42:	e541                	bnez	a0,ffffffffc0205aca <do_execve+0x312>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205a44:	01043b83          	ld	s7,16(s0)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205a48:	02043983          	ld	s3,32(s0)
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205a4c:	00843a83          	ld	s5,8(s0)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205a50:	77fd                	lui	a5,0xfffff
        end = ph->p_va + ph->p_filesz;
ffffffffc0205a52:	99de                	add	s3,s3,s7
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205a54:	9ada                	add	s5,s5,s6
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205a56:	00fbfc33          	and	s8,s7,a5
        while (start < end) {
ffffffffc0205a5a:	053bef63          	bltu	s7,s3,ffffffffc0205ab8 <do_execve+0x300>
ffffffffc0205a5e:	aa61                	j	ffffffffc0205bf6 <do_execve+0x43e>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205a60:	6785                	lui	a5,0x1
ffffffffc0205a62:	418b8533          	sub	a0,s7,s8
ffffffffc0205a66:	9c3e                	add	s8,s8,a5
ffffffffc0205a68:	417c0833          	sub	a6,s8,s7
            if (end < la) {
ffffffffc0205a6c:	0189f463          	bgeu	s3,s8,ffffffffc0205a74 <do_execve+0x2bc>
                size -= la - end;
ffffffffc0205a70:	41798833          	sub	a6,s3,s7
    return page - pages + nbase;
ffffffffc0205a74:	000db683          	ld	a3,0(s11)
ffffffffc0205a78:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205a7c:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205a7e:	40d486b3          	sub	a3,s1,a3
ffffffffc0205a82:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205a84:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205a88:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205a8a:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205a8e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205a90:	16c5f963          	bgeu	a1,a2,ffffffffc0205c02 <do_execve+0x44a>
ffffffffc0205a94:	000a7797          	auipc	a5,0xa7
ffffffffc0205a98:	e2c78793          	addi	a5,a5,-468 # ffffffffc02ac8c0 <va_pa_offset>
ffffffffc0205a9c:	0007b883          	ld	a7,0(a5)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205aa0:	85d6                	mv	a1,s5
ffffffffc0205aa2:	8642                	mv	a2,a6
ffffffffc0205aa4:	96c6                	add	a3,a3,a7
ffffffffc0205aa6:	9536                	add	a0,a0,a3
            start += size, from += size;
ffffffffc0205aa8:	9bc2                	add	s7,s7,a6
ffffffffc0205aaa:	e842                	sd	a6,16(sp)
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205aac:	317000ef          	jal	ra,ffffffffc02065c2 <memcpy>
            start += size, from += size;
ffffffffc0205ab0:	6842                	ld	a6,16(sp)
ffffffffc0205ab2:	9ac2                	add	s5,s5,a6
        while (start < end) {
ffffffffc0205ab4:	053bf563          	bgeu	s7,s3,ffffffffc0205afe <do_execve+0x346>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205ab8:	01893503          	ld	a0,24(s2)
ffffffffc0205abc:	6602                	ld	a2,0(sp)
ffffffffc0205abe:	85e2                	mv	a1,s8
ffffffffc0205ac0:	ffcfd0ef          	jal	ra,ffffffffc02032bc <pgdir_alloc_page>
ffffffffc0205ac4:	84aa                	mv	s1,a0
ffffffffc0205ac6:	fd49                	bnez	a0,ffffffffc0205a60 <do_execve+0x2a8>
        ret = -E_NO_MEM;
ffffffffc0205ac8:	59f1                	li	s3,-4
    exit_mmap(mm);
ffffffffc0205aca:	854a                	mv	a0,s2
ffffffffc0205acc:	8e5fe0ef          	jal	ra,ffffffffc02043b0 <exit_mmap>
    put_pgdir(mm);
ffffffffc0205ad0:	854a                	mv	a0,s2
ffffffffc0205ad2:	aa0ff0ef          	jal	ra,ffffffffc0204d72 <put_pgdir>
    mm_destroy(mm);
ffffffffc0205ad6:	854a                	mv	a0,s2
ffffffffc0205ad8:	f38fe0ef          	jal	ra,ffffffffc0204210 <mm_destroy>
    return ret;
ffffffffc0205adc:	b34d                	j	ffffffffc020587e <do_execve+0xc6>
            exit_mmap(mm);
ffffffffc0205ade:	854a                	mv	a0,s2
ffffffffc0205ae0:	8d1fe0ef          	jal	ra,ffffffffc02043b0 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205ae4:	854a                	mv	a0,s2
ffffffffc0205ae6:	a8cff0ef          	jal	ra,ffffffffc0204d72 <put_pgdir>
            mm_destroy(mm);
ffffffffc0205aea:	854a                	mv	a0,s2
ffffffffc0205aec:	f24fe0ef          	jal	ra,ffffffffc0204210 <mm_destroy>
ffffffffc0205af0:	bba9                	j	ffffffffc020584a <do_execve+0x92>
        if (ph->p_flags & ELF_PF_W) vm_flags |= VM_WRITE;
ffffffffc0205af2:	0026e693          	ori	a3,a3,2
        if (ph->p_flags & ELF_PF_R) vm_flags |= VM_READ;
ffffffffc0205af6:	f395                	bnez	a5,ffffffffc0205a1a <do_execve+0x262>
        if (vm_flags & VM_WRITE) perm |= (PTE_W | PTE_R);
ffffffffc0205af8:	47dd                	li	a5,23
ffffffffc0205afa:	e03e                	sd	a5,0(sp)
ffffffffc0205afc:	b735                	j	ffffffffc0205a28 <do_execve+0x270>
ffffffffc0205afe:	01043983          	ld	s3,16(s0)
        end = ph->p_va + ph->p_memsz;
ffffffffc0205b02:	7414                	ld	a3,40(s0)
ffffffffc0205b04:	99b6                	add	s3,s3,a3
        if (start < la) {
ffffffffc0205b06:	098bf163          	bgeu	s7,s8,ffffffffc0205b88 <do_execve+0x3d0>
            if (start == end) {
ffffffffc0205b0a:	df798ce3          	beq	s3,s7,ffffffffc0205902 <do_execve+0x14a>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205b0e:	6505                	lui	a0,0x1
ffffffffc0205b10:	955e                	add	a0,a0,s7
ffffffffc0205b12:	41850533          	sub	a0,a0,s8
                size -= la - end;
ffffffffc0205b16:	41798ab3          	sub	s5,s3,s7
            if (end < la) {
ffffffffc0205b1a:	0d89fb63          	bgeu	s3,s8,ffffffffc0205bf0 <do_execve+0x438>
    return page - pages + nbase;
ffffffffc0205b1e:	000db683          	ld	a3,0(s11)
ffffffffc0205b22:	000d3583          	ld	a1,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205b26:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205b28:	40d486b3          	sub	a3,s1,a3
ffffffffc0205b2c:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205b2e:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205b32:	96ae                	add	a3,a3,a1
    return KADDR(page2pa(page));
ffffffffc0205b34:	00f6f5b3          	and	a1,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205b38:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205b3a:	0cc5f463          	bgeu	a1,a2,ffffffffc0205c02 <do_execve+0x44a>
ffffffffc0205b3e:	000a7617          	auipc	a2,0xa7
ffffffffc0205b42:	d8260613          	addi	a2,a2,-638 # ffffffffc02ac8c0 <va_pa_offset>
ffffffffc0205b46:	00063803          	ld	a6,0(a2)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205b4a:	4581                	li	a1,0
ffffffffc0205b4c:	8656                	mv	a2,s5
ffffffffc0205b4e:	96c2                	add	a3,a3,a6
ffffffffc0205b50:	9536                	add	a0,a0,a3
ffffffffc0205b52:	25f000ef          	jal	ra,ffffffffc02065b0 <memset>
            start += size;
ffffffffc0205b56:	017a8733          	add	a4,s5,s7
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205b5a:	0389f463          	bgeu	s3,s8,ffffffffc0205b82 <do_execve+0x3ca>
ffffffffc0205b5e:	dae982e3          	beq	s3,a4,ffffffffc0205902 <do_execve+0x14a>
ffffffffc0205b62:	00003697          	auipc	a3,0x3
ffffffffc0205b66:	85e68693          	addi	a3,a3,-1954 # ffffffffc02083c0 <default_pmm_manager+0x10a8>
ffffffffc0205b6a:	00001617          	auipc	a2,0x1
ffffffffc0205b6e:	06660613          	addi	a2,a2,102 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0205b72:	26300593          	li	a1,611
ffffffffc0205b76:	00003517          	auipc	a0,0x3
ffffffffc0205b7a:	c7a50513          	addi	a0,a0,-902 # ffffffffc02087f0 <default_pmm_manager+0x14d8>
ffffffffc0205b7e:	903fa0ef          	jal	ra,ffffffffc0200480 <__panic>
ffffffffc0205b82:	ff8710e3          	bne	a4,s8,ffffffffc0205b62 <do_execve+0x3aa>
ffffffffc0205b86:	8be2                	mv	s7,s8
ffffffffc0205b88:	000a7a97          	auipc	s5,0xa7
ffffffffc0205b8c:	d38a8a93          	addi	s5,s5,-712 # ffffffffc02ac8c0 <va_pa_offset>
        while (start < end) {
ffffffffc0205b90:	053be763          	bltu	s7,s3,ffffffffc0205bde <do_execve+0x426>
ffffffffc0205b94:	b3bd                	j	ffffffffc0205902 <do_execve+0x14a>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205b96:	6785                	lui	a5,0x1
ffffffffc0205b98:	418b8533          	sub	a0,s7,s8
ffffffffc0205b9c:	9c3e                	add	s8,s8,a5
ffffffffc0205b9e:	417c0633          	sub	a2,s8,s7
            if (end < la) {
ffffffffc0205ba2:	0189f463          	bgeu	s3,s8,ffffffffc0205baa <do_execve+0x3f2>
                size -= la - end;
ffffffffc0205ba6:	41798633          	sub	a2,s3,s7
    return page - pages + nbase;
ffffffffc0205baa:	000db683          	ld	a3,0(s11)
ffffffffc0205bae:	000d3803          	ld	a6,0(s10)
    return KADDR(page2pa(page));
ffffffffc0205bb2:	67a2                	ld	a5,8(sp)
    return page - pages + nbase;
ffffffffc0205bb4:	40d486b3          	sub	a3,s1,a3
ffffffffc0205bb8:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0205bba:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205bbe:	96c2                	add	a3,a3,a6
    return KADDR(page2pa(page));
ffffffffc0205bc0:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205bc4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205bc6:	02b87e63          	bgeu	a6,a1,ffffffffc0205c02 <do_execve+0x44a>
ffffffffc0205bca:	000ab803          	ld	a6,0(s5)
            start += size;
ffffffffc0205bce:	9bb2                	add	s7,s7,a2
            memset(page2kva(page) + off, 0, size);
ffffffffc0205bd0:	4581                	li	a1,0
ffffffffc0205bd2:	96c2                	add	a3,a3,a6
ffffffffc0205bd4:	9536                	add	a0,a0,a3
ffffffffc0205bd6:	1db000ef          	jal	ra,ffffffffc02065b0 <memset>
        while (start < end) {
ffffffffc0205bda:	d33bf4e3          	bgeu	s7,s3,ffffffffc0205902 <do_execve+0x14a>
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL) {
ffffffffc0205bde:	01893503          	ld	a0,24(s2)
ffffffffc0205be2:	6602                	ld	a2,0(sp)
ffffffffc0205be4:	85e2                	mv	a1,s8
ffffffffc0205be6:	ed6fd0ef          	jal	ra,ffffffffc02032bc <pgdir_alloc_page>
ffffffffc0205bea:	84aa                	mv	s1,a0
ffffffffc0205bec:	f54d                	bnez	a0,ffffffffc0205b96 <do_execve+0x3de>
ffffffffc0205bee:	bde9                	j	ffffffffc0205ac8 <do_execve+0x310>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205bf0:	417c0ab3          	sub	s5,s8,s7
ffffffffc0205bf4:	b72d                	j	ffffffffc0205b1e <do_execve+0x366>
        while (start < end) {
ffffffffc0205bf6:	89de                	mv	s3,s7
ffffffffc0205bf8:	b729                	j	ffffffffc0205b02 <do_execve+0x34a>
        return -E_INVAL;
ffffffffc0205bfa:	59f5                	li	s3,-3
ffffffffc0205bfc:	bbf1                	j	ffffffffc02059d8 <do_execve+0x220>
            ret = -E_INVAL_ELF;
ffffffffc0205bfe:	59e1                	li	s3,-8
ffffffffc0205c00:	b5e9                	j	ffffffffc0205aca <do_execve+0x312>
ffffffffc0205c02:	00001617          	auipc	a2,0x1
ffffffffc0205c06:	76660613          	addi	a2,a2,1894 # ffffffffc0207368 <default_pmm_manager+0x50>
ffffffffc0205c0a:	06900593          	li	a1,105
ffffffffc0205c0e:	00001517          	auipc	a0,0x1
ffffffffc0205c12:	78250513          	addi	a0,a0,1922 # ffffffffc0207390 <default_pmm_manager+0x78>
ffffffffc0205c16:	86bfa0ef          	jal	ra,ffffffffc0200480 <__panic>
    current->cr3 = PADDR(mm->pgdir);
ffffffffc0205c1a:	00001617          	auipc	a2,0x1
ffffffffc0205c1e:	78660613          	addi	a2,a2,1926 # ffffffffc02073a0 <default_pmm_manager+0x88>
ffffffffc0205c22:	27e00593          	li	a1,638
ffffffffc0205c26:	00003517          	auipc	a0,0x3
ffffffffc0205c2a:	bca50513          	addi	a0,a0,-1078 # ffffffffc02087f0 <default_pmm_manager+0x14d8>
ffffffffc0205c2e:	853fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-4*PGSIZE , PTE_USER) != NULL);
ffffffffc0205c32:	00003697          	auipc	a3,0x3
ffffffffc0205c36:	8a668693          	addi	a3,a3,-1882 # ffffffffc02084d8 <default_pmm_manager+0x11c0>
ffffffffc0205c3a:	00001617          	auipc	a2,0x1
ffffffffc0205c3e:	f9660613          	addi	a2,a2,-106 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0205c42:	27900593          	li	a1,633
ffffffffc0205c46:	00003517          	auipc	a0,0x3
ffffffffc0205c4a:	baa50513          	addi	a0,a0,-1110 # ffffffffc02087f0 <default_pmm_manager+0x14d8>
ffffffffc0205c4e:	833fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-3*PGSIZE , PTE_USER) != NULL);
ffffffffc0205c52:	00003697          	auipc	a3,0x3
ffffffffc0205c56:	83e68693          	addi	a3,a3,-1986 # ffffffffc0208490 <default_pmm_manager+0x1178>
ffffffffc0205c5a:	00001617          	auipc	a2,0x1
ffffffffc0205c5e:	f7660613          	addi	a2,a2,-138 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0205c62:	27800593          	li	a1,632
ffffffffc0205c66:	00003517          	auipc	a0,0x3
ffffffffc0205c6a:	b8a50513          	addi	a0,a0,-1142 # ffffffffc02087f0 <default_pmm_manager+0x14d8>
ffffffffc0205c6e:	813fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-2*PGSIZE , PTE_USER) != NULL);
ffffffffc0205c72:	00002697          	auipc	a3,0x2
ffffffffc0205c76:	7d668693          	addi	a3,a3,2006 # ffffffffc0208448 <default_pmm_manager+0x1130>
ffffffffc0205c7a:	00001617          	auipc	a2,0x1
ffffffffc0205c7e:	f5660613          	addi	a2,a2,-170 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0205c82:	27700593          	li	a1,631
ffffffffc0205c86:	00003517          	auipc	a0,0x3
ffffffffc0205c8a:	b6a50513          	addi	a0,a0,-1174 # ffffffffc02087f0 <default_pmm_manager+0x14d8>
ffffffffc0205c8e:	ff2fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP-PGSIZE , PTE_USER) != NULL);
ffffffffc0205c92:	00002697          	auipc	a3,0x2
ffffffffc0205c96:	76e68693          	addi	a3,a3,1902 # ffffffffc0208400 <default_pmm_manager+0x10e8>
ffffffffc0205c9a:	00001617          	auipc	a2,0x1
ffffffffc0205c9e:	f3660613          	addi	a2,a2,-202 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0205ca2:	27600593          	li	a1,630
ffffffffc0205ca6:	00003517          	auipc	a0,0x3
ffffffffc0205caa:	b4a50513          	addi	a0,a0,-1206 # ffffffffc02087f0 <default_pmm_manager+0x14d8>
ffffffffc0205cae:	fd2fa0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0205cb2 <do_yield>:
    current->need_resched = 1;
ffffffffc0205cb2:	000a7797          	auipc	a5,0xa7
ffffffffc0205cb6:	bc678793          	addi	a5,a5,-1082 # ffffffffc02ac878 <current>
ffffffffc0205cba:	639c                	ld	a5,0(a5)
ffffffffc0205cbc:	4705                	li	a4,1
}
ffffffffc0205cbe:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0205cc0:	ef98                	sd	a4,24(a5)
}
ffffffffc0205cc2:	8082                	ret

ffffffffc0205cc4 <do_wait>:
do_wait(int pid, int *code_store) {
ffffffffc0205cc4:	1101                	addi	sp,sp,-32
ffffffffc0205cc6:	e822                	sd	s0,16(sp)
ffffffffc0205cc8:	e426                	sd	s1,8(sp)
ffffffffc0205cca:	ec06                	sd	ra,24(sp)
ffffffffc0205ccc:	842e                	mv	s0,a1
ffffffffc0205cce:	84aa                	mv	s1,a0
    if (code_store != NULL) {
ffffffffc0205cd0:	cd81                	beqz	a1,ffffffffc0205ce8 <do_wait+0x24>
    struct mm_struct *mm = current->mm;
ffffffffc0205cd2:	000a7797          	auipc	a5,0xa7
ffffffffc0205cd6:	ba678793          	addi	a5,a5,-1114 # ffffffffc02ac878 <current>
ffffffffc0205cda:	639c                	ld	a5,0(a5)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1)) {
ffffffffc0205cdc:	4685                	li	a3,1
ffffffffc0205cde:	4611                	li	a2,4
ffffffffc0205ce0:	7788                	ld	a0,40(a5)
ffffffffc0205ce2:	d87fe0ef          	jal	ra,ffffffffc0204a68 <user_mem_check>
ffffffffc0205ce6:	c909                	beqz	a0,ffffffffc0205cf8 <do_wait+0x34>
ffffffffc0205ce8:	85a2                	mv	a1,s0
}
ffffffffc0205cea:	6442                	ld	s0,16(sp)
ffffffffc0205cec:	60e2                	ld	ra,24(sp)
ffffffffc0205cee:	8526                	mv	a0,s1
ffffffffc0205cf0:	64a2                	ld	s1,8(sp)
ffffffffc0205cf2:	6105                	addi	sp,sp,32
ffffffffc0205cf4:	ff4ff06f          	j	ffffffffc02054e8 <do_wait.part.1>
ffffffffc0205cf8:	60e2                	ld	ra,24(sp)
ffffffffc0205cfa:	6442                	ld	s0,16(sp)
ffffffffc0205cfc:	64a2                	ld	s1,8(sp)
ffffffffc0205cfe:	5575                	li	a0,-3
ffffffffc0205d00:	6105                	addi	sp,sp,32
ffffffffc0205d02:	8082                	ret

ffffffffc0205d04 <do_kill>:
do_kill(int pid) {
ffffffffc0205d04:	1141                	addi	sp,sp,-16
ffffffffc0205d06:	e406                	sd	ra,8(sp)
ffffffffc0205d08:	e022                	sd	s0,0(sp)
    if ((proc = find_proc(pid)) != NULL) {
ffffffffc0205d0a:	a08ff0ef          	jal	ra,ffffffffc0204f12 <find_proc>
ffffffffc0205d0e:	cd0d                	beqz	a0,ffffffffc0205d48 <do_kill+0x44>
        if (!(proc->flags & PF_EXITING)) {
ffffffffc0205d10:	0b052703          	lw	a4,176(a0)
ffffffffc0205d14:	00177693          	andi	a3,a4,1
ffffffffc0205d18:	e695                	bnez	a3,ffffffffc0205d44 <do_kill+0x40>
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205d1a:	0ec52683          	lw	a3,236(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205d1e:	00176713          	ori	a4,a4,1
ffffffffc0205d22:	0ae52823          	sw	a4,176(a0)
            return 0;
ffffffffc0205d26:	4401                	li	s0,0
            if (proc->wait_state & WT_INTERRUPTED) {
ffffffffc0205d28:	0006c763          	bltz	a3,ffffffffc0205d36 <do_kill+0x32>
}
ffffffffc0205d2c:	8522                	mv	a0,s0
ffffffffc0205d2e:	60a2                	ld	ra,8(sp)
ffffffffc0205d30:	6402                	ld	s0,0(sp)
ffffffffc0205d32:	0141                	addi	sp,sp,16
ffffffffc0205d34:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205d36:	1e6000ef          	jal	ra,ffffffffc0205f1c <wakeup_proc>
}
ffffffffc0205d3a:	8522                	mv	a0,s0
ffffffffc0205d3c:	60a2                	ld	ra,8(sp)
ffffffffc0205d3e:	6402                	ld	s0,0(sp)
ffffffffc0205d40:	0141                	addi	sp,sp,16
ffffffffc0205d42:	8082                	ret
        return -E_KILLED;
ffffffffc0205d44:	545d                	li	s0,-9
ffffffffc0205d46:	b7dd                	j	ffffffffc0205d2c <do_kill+0x28>
    return -E_INVAL;
ffffffffc0205d48:	5475                	li	s0,-3
ffffffffc0205d4a:	b7cd                	j	ffffffffc0205d2c <do_kill+0x28>

ffffffffc0205d4c <proc_init>:
    elm->prev = elm->next = elm;
ffffffffc0205d4c:	000a7797          	auipc	a5,0xa7
ffffffffc0205d50:	c6c78793          	addi	a5,a5,-916 # ffffffffc02ac9b8 <proc_list>

// proc_init - set up the first kernel thread idleproc "idle" by itself and 
//           - create the second kernel thread init_main
void
proc_init(void) {
ffffffffc0205d54:	1101                	addi	sp,sp,-32
ffffffffc0205d56:	000a7717          	auipc	a4,0xa7
ffffffffc0205d5a:	c6f73523          	sd	a5,-918(a4) # ffffffffc02ac9c0 <proc_list+0x8>
ffffffffc0205d5e:	000a7717          	auipc	a4,0xa7
ffffffffc0205d62:	c4f73d23          	sd	a5,-934(a4) # ffffffffc02ac9b8 <proc_list>
ffffffffc0205d66:	ec06                	sd	ra,24(sp)
ffffffffc0205d68:	e822                	sd	s0,16(sp)
ffffffffc0205d6a:	e426                	sd	s1,8(sp)
ffffffffc0205d6c:	000a3797          	auipc	a5,0xa3
ffffffffc0205d70:	ad478793          	addi	a5,a5,-1324 # ffffffffc02a8840 <hash_list>
ffffffffc0205d74:	000a7717          	auipc	a4,0xa7
ffffffffc0205d78:	acc70713          	addi	a4,a4,-1332 # ffffffffc02ac840 <is_panic>
ffffffffc0205d7c:	e79c                	sd	a5,8(a5)
ffffffffc0205d7e:	e39c                	sd	a5,0(a5)
ffffffffc0205d80:	07c1                	addi	a5,a5,16
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i ++) {
ffffffffc0205d82:	fee79de3          	bne	a5,a4,ffffffffc0205d7c <proc_init+0x30>
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL) {
ffffffffc0205d86:	ee7fe0ef          	jal	ra,ffffffffc0204c6c <alloc_proc>
ffffffffc0205d8a:	000a7717          	auipc	a4,0xa7
ffffffffc0205d8e:	aea73b23          	sd	a0,-1290(a4) # ffffffffc02ac880 <idleproc>
ffffffffc0205d92:	000a7497          	auipc	s1,0xa7
ffffffffc0205d96:	aee48493          	addi	s1,s1,-1298 # ffffffffc02ac880 <idleproc>
ffffffffc0205d9a:	c559                	beqz	a0,ffffffffc0205e28 <proc_init+0xdc>
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0205d9c:	4709                	li	a4,2
ffffffffc0205d9e:	e118                	sd	a4,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
    idleproc->need_resched = 1;
ffffffffc0205da0:	4405                	li	s0,1
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205da2:	00003717          	auipc	a4,0x3
ffffffffc0205da6:	25e70713          	addi	a4,a4,606 # ffffffffc0209000 <bootstack>
    set_proc_name(idleproc, "idle");
ffffffffc0205daa:	00003597          	auipc	a1,0x3
ffffffffc0205dae:	95e58593          	addi	a1,a1,-1698 # ffffffffc0208708 <default_pmm_manager+0x13f0>
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0205db2:	e918                	sd	a4,16(a0)
    idleproc->need_resched = 1;
ffffffffc0205db4:	ed00                	sd	s0,24(a0)
    set_proc_name(idleproc, "idle");
ffffffffc0205db6:	8c6ff0ef          	jal	ra,ffffffffc0204e7c <set_proc_name>
    nr_process ++;
ffffffffc0205dba:	000a7797          	auipc	a5,0xa7
ffffffffc0205dbe:	ad678793          	addi	a5,a5,-1322 # ffffffffc02ac890 <nr_process>
ffffffffc0205dc2:	439c                	lw	a5,0(a5)

    current = idleproc;
ffffffffc0205dc4:	6098                	ld	a4,0(s1)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205dc6:	4601                	li	a2,0
    nr_process ++;
ffffffffc0205dc8:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205dca:	4581                	li	a1,0
ffffffffc0205dcc:	00000517          	auipc	a0,0x0
ffffffffc0205dd0:	8c450513          	addi	a0,a0,-1852 # ffffffffc0205690 <init_main>
    nr_process ++;
ffffffffc0205dd4:	000a7697          	auipc	a3,0xa7
ffffffffc0205dd8:	aaf6ae23          	sw	a5,-1348(a3) # ffffffffc02ac890 <nr_process>
    current = idleproc;
ffffffffc0205ddc:	000a7797          	auipc	a5,0xa7
ffffffffc0205de0:	a8e7be23          	sd	a4,-1380(a5) # ffffffffc02ac878 <current>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205de4:	d66ff0ef          	jal	ra,ffffffffc020534a <kernel_thread>
    if (pid <= 0) {
ffffffffc0205de8:	08a05c63          	blez	a0,ffffffffc0205e80 <proc_init+0x134>
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205dec:	926ff0ef          	jal	ra,ffffffffc0204f12 <find_proc>
    set_proc_name(initproc, "init");
ffffffffc0205df0:	00003597          	auipc	a1,0x3
ffffffffc0205df4:	94058593          	addi	a1,a1,-1728 # ffffffffc0208730 <default_pmm_manager+0x1418>
    initproc = find_proc(pid);
ffffffffc0205df8:	000a7797          	auipc	a5,0xa7
ffffffffc0205dfc:	a8a7b823          	sd	a0,-1392(a5) # ffffffffc02ac888 <initproc>
    set_proc_name(initproc, "init");
ffffffffc0205e00:	87cff0ef          	jal	ra,ffffffffc0204e7c <set_proc_name>

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205e04:	609c                	ld	a5,0(s1)
ffffffffc0205e06:	cfa9                	beqz	a5,ffffffffc0205e60 <proc_init+0x114>
ffffffffc0205e08:	43dc                	lw	a5,4(a5)
ffffffffc0205e0a:	ebb9                	bnez	a5,ffffffffc0205e60 <proc_init+0x114>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205e0c:	000a7797          	auipc	a5,0xa7
ffffffffc0205e10:	a7c78793          	addi	a5,a5,-1412 # ffffffffc02ac888 <initproc>
ffffffffc0205e14:	639c                	ld	a5,0(a5)
ffffffffc0205e16:	c78d                	beqz	a5,ffffffffc0205e40 <proc_init+0xf4>
ffffffffc0205e18:	43dc                	lw	a5,4(a5)
ffffffffc0205e1a:	02879363          	bne	a5,s0,ffffffffc0205e40 <proc_init+0xf4>
}
ffffffffc0205e1e:	60e2                	ld	ra,24(sp)
ffffffffc0205e20:	6442                	ld	s0,16(sp)
ffffffffc0205e22:	64a2                	ld	s1,8(sp)
ffffffffc0205e24:	6105                	addi	sp,sp,32
ffffffffc0205e26:	8082                	ret
        panic("cannot alloc idleproc.\n");
ffffffffc0205e28:	00003617          	auipc	a2,0x3
ffffffffc0205e2c:	8c860613          	addi	a2,a2,-1848 # ffffffffc02086f0 <default_pmm_manager+0x13d8>
ffffffffc0205e30:	37500593          	li	a1,885
ffffffffc0205e34:	00003517          	auipc	a0,0x3
ffffffffc0205e38:	9bc50513          	addi	a0,a0,-1604 # ffffffffc02087f0 <default_pmm_manager+0x14d8>
ffffffffc0205e3c:	e44fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205e40:	00003697          	auipc	a3,0x3
ffffffffc0205e44:	92068693          	addi	a3,a3,-1760 # ffffffffc0208760 <default_pmm_manager+0x1448>
ffffffffc0205e48:	00001617          	auipc	a2,0x1
ffffffffc0205e4c:	d8860613          	addi	a2,a2,-632 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0205e50:	38a00593          	li	a1,906
ffffffffc0205e54:	00003517          	auipc	a0,0x3
ffffffffc0205e58:	99c50513          	addi	a0,a0,-1636 # ffffffffc02087f0 <default_pmm_manager+0x14d8>
ffffffffc0205e5c:	e24fa0ef          	jal	ra,ffffffffc0200480 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205e60:	00003697          	auipc	a3,0x3
ffffffffc0205e64:	8d868693          	addi	a3,a3,-1832 # ffffffffc0208738 <default_pmm_manager+0x1420>
ffffffffc0205e68:	00001617          	auipc	a2,0x1
ffffffffc0205e6c:	d6860613          	addi	a2,a2,-664 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0205e70:	38900593          	li	a1,905
ffffffffc0205e74:	00003517          	auipc	a0,0x3
ffffffffc0205e78:	97c50513          	addi	a0,a0,-1668 # ffffffffc02087f0 <default_pmm_manager+0x14d8>
ffffffffc0205e7c:	e04fa0ef          	jal	ra,ffffffffc0200480 <__panic>
        panic("create init_main failed.\n");
ffffffffc0205e80:	00003617          	auipc	a2,0x3
ffffffffc0205e84:	89060613          	addi	a2,a2,-1904 # ffffffffc0208710 <default_pmm_manager+0x13f8>
ffffffffc0205e88:	38300593          	li	a1,899
ffffffffc0205e8c:	00003517          	auipc	a0,0x3
ffffffffc0205e90:	96450513          	addi	a0,a0,-1692 # ffffffffc02087f0 <default_pmm_manager+0x14d8>
ffffffffc0205e94:	decfa0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0205e98 <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void
cpu_idle(void) {
ffffffffc0205e98:	1141                	addi	sp,sp,-16
ffffffffc0205e9a:	e022                	sd	s0,0(sp)
ffffffffc0205e9c:	e406                	sd	ra,8(sp)
ffffffffc0205e9e:	000a7417          	auipc	s0,0xa7
ffffffffc0205ea2:	9da40413          	addi	s0,s0,-1574 # ffffffffc02ac878 <current>
    while (1) {
        if (current->need_resched) {
ffffffffc0205ea6:	6018                	ld	a4,0(s0)
ffffffffc0205ea8:	6f1c                	ld	a5,24(a4)
ffffffffc0205eaa:	dffd                	beqz	a5,ffffffffc0205ea8 <cpu_idle+0x10>
            schedule();
ffffffffc0205eac:	0ec000ef          	jal	ra,ffffffffc0205f98 <schedule>
ffffffffc0205eb0:	bfdd                	j	ffffffffc0205ea6 <cpu_idle+0xe>

ffffffffc0205eb2 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0205eb2:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0205eb6:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0205eba:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0205ebc:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0205ebe:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0205ec2:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0205ec6:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0205eca:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0205ece:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0205ed2:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0205ed6:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0205eda:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0205ede:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0205ee2:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0205ee6:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0205eea:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0205eee:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0205ef0:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0205ef2:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0205ef6:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0205efa:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0205efe:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0205f02:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0205f06:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0205f0a:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0205f0e:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0205f12:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0205f16:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0205f1a:	8082                	ret

ffffffffc0205f1c <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f1c:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0205f1e:	1101                	addi	sp,sp,-32
ffffffffc0205f20:	ec06                	sd	ra,24(sp)
ffffffffc0205f22:	e822                	sd	s0,16(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f24:	478d                	li	a5,3
ffffffffc0205f26:	04f70a63          	beq	a4,a5,ffffffffc0205f7a <wakeup_proc+0x5e>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f2a:	100027f3          	csrr	a5,sstatus
ffffffffc0205f2e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205f30:	4401                	li	s0,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f32:	ef8d                	bnez	a5,ffffffffc0205f6c <wakeup_proc+0x50>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205f34:	4789                	li	a5,2
ffffffffc0205f36:	00f70f63          	beq	a4,a5,ffffffffc0205f54 <wakeup_proc+0x38>
            proc->state = PROC_RUNNABLE;
ffffffffc0205f3a:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc0205f3c:	0e052623          	sw	zero,236(a0)
    if (flag) {
ffffffffc0205f40:	e409                	bnez	s0,ffffffffc0205f4a <wakeup_proc+0x2e>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205f42:	60e2                	ld	ra,24(sp)
ffffffffc0205f44:	6442                	ld	s0,16(sp)
ffffffffc0205f46:	6105                	addi	sp,sp,32
ffffffffc0205f48:	8082                	ret
ffffffffc0205f4a:	6442                	ld	s0,16(sp)
ffffffffc0205f4c:	60e2                	ld	ra,24(sp)
ffffffffc0205f4e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205f50:	efcfa06f          	j	ffffffffc020064c <intr_enable>
            warn("wakeup runnable process.\n");
ffffffffc0205f54:	00003617          	auipc	a2,0x3
ffffffffc0205f58:	8ec60613          	addi	a2,a2,-1812 # ffffffffc0208840 <default_pmm_manager+0x1528>
ffffffffc0205f5c:	45c9                	li	a1,18
ffffffffc0205f5e:	00003517          	auipc	a0,0x3
ffffffffc0205f62:	8ca50513          	addi	a0,a0,-1846 # ffffffffc0208828 <default_pmm_manager+0x1510>
ffffffffc0205f66:	d86fa0ef          	jal	ra,ffffffffc02004ec <__warn>
ffffffffc0205f6a:	bfd9                	j	ffffffffc0205f40 <wakeup_proc+0x24>
ffffffffc0205f6c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0205f6e:	ee4fa0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc0205f72:	6522                	ld	a0,8(sp)
ffffffffc0205f74:	4405                	li	s0,1
ffffffffc0205f76:	4118                	lw	a4,0(a0)
ffffffffc0205f78:	bf75                	j	ffffffffc0205f34 <wakeup_proc+0x18>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205f7a:	00003697          	auipc	a3,0x3
ffffffffc0205f7e:	88e68693          	addi	a3,a3,-1906 # ffffffffc0208808 <default_pmm_manager+0x14f0>
ffffffffc0205f82:	00001617          	auipc	a2,0x1
ffffffffc0205f86:	c4e60613          	addi	a2,a2,-946 # ffffffffc0206bd0 <commands+0x4c0>
ffffffffc0205f8a:	45a5                	li	a1,9
ffffffffc0205f8c:	00003517          	auipc	a0,0x3
ffffffffc0205f90:	89c50513          	addi	a0,a0,-1892 # ffffffffc0208828 <default_pmm_manager+0x1510>
ffffffffc0205f94:	cecfa0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc0205f98 <schedule>:

void
schedule(void) {
ffffffffc0205f98:	1141                	addi	sp,sp,-16
ffffffffc0205f9a:	e406                	sd	ra,8(sp)
ffffffffc0205f9c:	e022                	sd	s0,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f9e:	100027f3          	csrr	a5,sstatus
ffffffffc0205fa2:	8b89                	andi	a5,a5,2
ffffffffc0205fa4:	4401                	li	s0,0
ffffffffc0205fa6:	e3d1                	bnez	a5,ffffffffc020602a <schedule+0x92>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205fa8:	000a7797          	auipc	a5,0xa7
ffffffffc0205fac:	8d078793          	addi	a5,a5,-1840 # ffffffffc02ac878 <current>
ffffffffc0205fb0:	0007b883          	ld	a7,0(a5)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205fb4:	000a7797          	auipc	a5,0xa7
ffffffffc0205fb8:	8cc78793          	addi	a5,a5,-1844 # ffffffffc02ac880 <idleproc>
ffffffffc0205fbc:	6388                	ld	a0,0(a5)
        current->need_resched = 0;
ffffffffc0205fbe:	0008bc23          	sd	zero,24(a7) # 2018 <_binary_obj___user_faultread_out_size-0x75b0>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205fc2:	04a88e63          	beq	a7,a0,ffffffffc020601e <schedule+0x86>
ffffffffc0205fc6:	0c888693          	addi	a3,a7,200
ffffffffc0205fca:	000a7617          	auipc	a2,0xa7
ffffffffc0205fce:	9ee60613          	addi	a2,a2,-1554 # ffffffffc02ac9b8 <proc_list>
        le = last;
ffffffffc0205fd2:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc0205fd4:	4581                	li	a1,0
        do {
            if ((le = list_next(le)) != &proc_list) {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205fd6:	4809                	li	a6,2
    return listelm->next;
ffffffffc0205fd8:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list) {
ffffffffc0205fda:	00c78863          	beq	a5,a2,ffffffffc0205fea <schedule+0x52>
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205fde:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0205fe2:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE) {
ffffffffc0205fe6:	01070463          	beq	a4,a6,ffffffffc0205fee <schedule+0x56>
                    break;
                }
            }
        } while (le != last);
ffffffffc0205fea:	fef697e3          	bne	a3,a5,ffffffffc0205fd8 <schedule+0x40>
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0205fee:	c589                	beqz	a1,ffffffffc0205ff8 <schedule+0x60>
ffffffffc0205ff0:	4198                	lw	a4,0(a1)
ffffffffc0205ff2:	4789                	li	a5,2
ffffffffc0205ff4:	00f70e63          	beq	a4,a5,ffffffffc0206010 <schedule+0x78>
            next = idleproc;
        }
        next->runs ++;
ffffffffc0205ff8:	451c                	lw	a5,8(a0)
ffffffffc0205ffa:	2785                	addiw	a5,a5,1
ffffffffc0205ffc:	c51c                	sw	a5,8(a0)
        if (next != current) {
ffffffffc0205ffe:	00a88463          	beq	a7,a0,ffffffffc0206006 <schedule+0x6e>
            proc_run(next);
ffffffffc0206002:	ea5fe0ef          	jal	ra,ffffffffc0204ea6 <proc_run>
    if (flag) {
ffffffffc0206006:	e419                	bnez	s0,ffffffffc0206014 <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206008:	60a2                	ld	ra,8(sp)
ffffffffc020600a:	6402                	ld	s0,0(sp)
ffffffffc020600c:	0141                	addi	sp,sp,16
ffffffffc020600e:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE) {
ffffffffc0206010:	852e                	mv	a0,a1
ffffffffc0206012:	b7dd                	j	ffffffffc0205ff8 <schedule+0x60>
}
ffffffffc0206014:	6402                	ld	s0,0(sp)
ffffffffc0206016:	60a2                	ld	ra,8(sp)
ffffffffc0206018:	0141                	addi	sp,sp,16
        intr_enable();
ffffffffc020601a:	e32fa06f          	j	ffffffffc020064c <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020601e:	000a7617          	auipc	a2,0xa7
ffffffffc0206022:	99a60613          	addi	a2,a2,-1638 # ffffffffc02ac9b8 <proc_list>
ffffffffc0206026:	86b2                	mv	a3,a2
ffffffffc0206028:	b76d                	j	ffffffffc0205fd2 <schedule+0x3a>
        intr_disable();
ffffffffc020602a:	e28fa0ef          	jal	ra,ffffffffc0200652 <intr_disable>
        return 1;
ffffffffc020602e:	4405                	li	s0,1
ffffffffc0206030:	bfa5                	j	ffffffffc0205fa8 <schedule+0x10>

ffffffffc0206032 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0206032:	000a7797          	auipc	a5,0xa7
ffffffffc0206036:	84678793          	addi	a5,a5,-1978 # ffffffffc02ac878 <current>
ffffffffc020603a:	639c                	ld	a5,0(a5)
}
ffffffffc020603c:	43c8                	lw	a0,4(a5)
ffffffffc020603e:	8082                	ret

ffffffffc0206040 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0206040:	4501                	li	a0,0
ffffffffc0206042:	8082                	ret

ffffffffc0206044 <sys_putc>:
    cputchar(c);
ffffffffc0206044:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0206046:	1141                	addi	sp,sp,-16
ffffffffc0206048:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc020604a:	978fa0ef          	jal	ra,ffffffffc02001c2 <cputchar>
}
ffffffffc020604e:	60a2                	ld	ra,8(sp)
ffffffffc0206050:	4501                	li	a0,0
ffffffffc0206052:	0141                	addi	sp,sp,16
ffffffffc0206054:	8082                	ret

ffffffffc0206056 <sys_kill>:
    return do_kill(pid);
ffffffffc0206056:	4108                	lw	a0,0(a0)
ffffffffc0206058:	cadff06f          	j	ffffffffc0205d04 <do_kill>

ffffffffc020605c <sys_yield>:
    return do_yield();
ffffffffc020605c:	c57ff06f          	j	ffffffffc0205cb2 <do_yield>

ffffffffc0206060 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0206060:	6d14                	ld	a3,24(a0)
ffffffffc0206062:	6910                	ld	a2,16(a0)
ffffffffc0206064:	650c                	ld	a1,8(a0)
ffffffffc0206066:	6108                	ld	a0,0(a0)
ffffffffc0206068:	f50ff06f          	j	ffffffffc02057b8 <do_execve>

ffffffffc020606c <sys_wait>:
    return do_wait(pid, store);
ffffffffc020606c:	650c                	ld	a1,8(a0)
ffffffffc020606e:	4108                	lw	a0,0(a0)
ffffffffc0206070:	c55ff06f          	j	ffffffffc0205cc4 <do_wait>

ffffffffc0206074 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0206074:	000a7797          	auipc	a5,0xa7
ffffffffc0206078:	80478793          	addi	a5,a5,-2044 # ffffffffc02ac878 <current>
ffffffffc020607c:	639c                	ld	a5,0(a5)
    return do_fork(0, stack, tf);
ffffffffc020607e:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc0206080:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0206082:	6a0c                	ld	a1,16(a2)
ffffffffc0206084:	eebfe06f          	j	ffffffffc0204f6e <do_fork>

ffffffffc0206088 <sys_exit>:
    return do_exit(error_code);
ffffffffc0206088:	4108                	lw	a0,0(a0)
ffffffffc020608a:	b10ff06f          	j	ffffffffc020539a <do_exit>

ffffffffc020608e <syscall>:
};

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
ffffffffc020608e:	715d                	addi	sp,sp,-80
ffffffffc0206090:	fc26                	sd	s1,56(sp)
    struct trapframe *tf = current->tf;
ffffffffc0206092:	000a6497          	auipc	s1,0xa6
ffffffffc0206096:	7e648493          	addi	s1,s1,2022 # ffffffffc02ac878 <current>
ffffffffc020609a:	6098                	ld	a4,0(s1)
syscall(void) {
ffffffffc020609c:	e0a2                	sd	s0,64(sp)
ffffffffc020609e:	f84a                	sd	s2,48(sp)
    struct trapframe *tf = current->tf;
ffffffffc02060a0:	7340                	ld	s0,160(a4)
syscall(void) {
ffffffffc02060a2:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02060a4:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc02060a6:	05042903          	lw	s2,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc02060aa:	0327ee63          	bltu	a5,s2,ffffffffc02060e6 <syscall+0x58>
        if (syscalls[num] != NULL) {
ffffffffc02060ae:	00391713          	slli	a4,s2,0x3
ffffffffc02060b2:	00002797          	auipc	a5,0x2
ffffffffc02060b6:	7f678793          	addi	a5,a5,2038 # ffffffffc02088a8 <syscalls>
ffffffffc02060ba:	97ba                	add	a5,a5,a4
ffffffffc02060bc:	639c                	ld	a5,0(a5)
ffffffffc02060be:	c785                	beqz	a5,ffffffffc02060e6 <syscall+0x58>
            arg[0] = tf->gpr.a1;
ffffffffc02060c0:	6c28                	ld	a0,88(s0)
            arg[1] = tf->gpr.a2;
ffffffffc02060c2:	702c                	ld	a1,96(s0)
            arg[2] = tf->gpr.a3;
ffffffffc02060c4:	7430                	ld	a2,104(s0)
            arg[3] = tf->gpr.a4;
ffffffffc02060c6:	7834                	ld	a3,112(s0)
            arg[4] = tf->gpr.a5;
ffffffffc02060c8:	7c38                	ld	a4,120(s0)
            arg[0] = tf->gpr.a1;
ffffffffc02060ca:	e42a                	sd	a0,8(sp)
            arg[1] = tf->gpr.a2;
ffffffffc02060cc:	e82e                	sd	a1,16(sp)
            arg[2] = tf->gpr.a3;
ffffffffc02060ce:	ec32                	sd	a2,24(sp)
            arg[3] = tf->gpr.a4;
ffffffffc02060d0:	f036                	sd	a3,32(sp)
            arg[4] = tf->gpr.a5;
ffffffffc02060d2:	f43a                	sd	a4,40(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc02060d4:	0028                	addi	a0,sp,8
ffffffffc02060d6:	9782                	jalr	a5
ffffffffc02060d8:	e828                	sd	a0,80(s0)
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc02060da:	60a6                	ld	ra,72(sp)
ffffffffc02060dc:	6406                	ld	s0,64(sp)
ffffffffc02060de:	74e2                	ld	s1,56(sp)
ffffffffc02060e0:	7942                	ld	s2,48(sp)
ffffffffc02060e2:	6161                	addi	sp,sp,80
ffffffffc02060e4:	8082                	ret
    print_trapframe(tf);
ffffffffc02060e6:	8522                	mv	a0,s0
ffffffffc02060e8:	f58fa0ef          	jal	ra,ffffffffc0200840 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc02060ec:	609c                	ld	a5,0(s1)
ffffffffc02060ee:	86ca                	mv	a3,s2
ffffffffc02060f0:	00002617          	auipc	a2,0x2
ffffffffc02060f4:	77060613          	addi	a2,a2,1904 # ffffffffc0208860 <default_pmm_manager+0x1548>
ffffffffc02060f8:	43d8                	lw	a4,4(a5)
ffffffffc02060fa:	06300593          	li	a1,99
ffffffffc02060fe:	0b478793          	addi	a5,a5,180
ffffffffc0206102:	00002517          	auipc	a0,0x2
ffffffffc0206106:	78e50513          	addi	a0,a0,1934 # ffffffffc0208890 <default_pmm_manager+0x1578>
ffffffffc020610a:	b76fa0ef          	jal	ra,ffffffffc0200480 <__panic>

ffffffffc020610e <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc020610e:	9e3707b7          	lui	a5,0x9e370
ffffffffc0206112:	2785                	addiw	a5,a5,1
ffffffffc0206114:	02f5053b          	mulw	a0,a0,a5
    return (hash >> (32 - bits));
ffffffffc0206118:	02000793          	li	a5,32
ffffffffc020611c:	40b785bb          	subw	a1,a5,a1
}
ffffffffc0206120:	00b5553b          	srlw	a0,a0,a1
ffffffffc0206124:	8082                	ret

ffffffffc0206126 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0206126:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020612a:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc020612c:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206130:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0206132:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206136:	f022                	sd	s0,32(sp)
ffffffffc0206138:	ec26                	sd	s1,24(sp)
ffffffffc020613a:	e84a                	sd	s2,16(sp)
ffffffffc020613c:	f406                	sd	ra,40(sp)
ffffffffc020613e:	e44e                	sd	s3,8(sp)
ffffffffc0206140:	84aa                	mv	s1,a0
ffffffffc0206142:	892e                	mv	s2,a1
ffffffffc0206144:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0206148:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc020614a:	03067e63          	bgeu	a2,a6,ffffffffc0206186 <printnum+0x60>
ffffffffc020614e:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0206150:	00805763          	blez	s0,ffffffffc020615e <printnum+0x38>
ffffffffc0206154:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0206156:	85ca                	mv	a1,s2
ffffffffc0206158:	854e                	mv	a0,s3
ffffffffc020615a:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020615c:	fc65                	bnez	s0,ffffffffc0206154 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020615e:	1a02                	slli	s4,s4,0x20
ffffffffc0206160:	020a5a13          	srli	s4,s4,0x20
ffffffffc0206164:	00003797          	auipc	a5,0x3
ffffffffc0206168:	a6478793          	addi	a5,a5,-1436 # ffffffffc0208bc8 <error_string+0xc8>
ffffffffc020616c:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc020616e:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206170:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0206174:	70a2                	ld	ra,40(sp)
ffffffffc0206176:	69a2                	ld	s3,8(sp)
ffffffffc0206178:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020617a:	85ca                	mv	a1,s2
ffffffffc020617c:	8326                	mv	t1,s1
}
ffffffffc020617e:	6942                	ld	s2,16(sp)
ffffffffc0206180:	64e2                	ld	s1,24(sp)
ffffffffc0206182:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206184:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0206186:	03065633          	divu	a2,a2,a6
ffffffffc020618a:	8722                	mv	a4,s0
ffffffffc020618c:	f9bff0ef          	jal	ra,ffffffffc0206126 <printnum>
ffffffffc0206190:	b7f9                	j	ffffffffc020615e <printnum+0x38>

ffffffffc0206192 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0206192:	7119                	addi	sp,sp,-128
ffffffffc0206194:	f4a6                	sd	s1,104(sp)
ffffffffc0206196:	f0ca                	sd	s2,96(sp)
ffffffffc0206198:	e8d2                	sd	s4,80(sp)
ffffffffc020619a:	e4d6                	sd	s5,72(sp)
ffffffffc020619c:	e0da                	sd	s6,64(sp)
ffffffffc020619e:	fc5e                	sd	s7,56(sp)
ffffffffc02061a0:	f862                	sd	s8,48(sp)
ffffffffc02061a2:	f06a                	sd	s10,32(sp)
ffffffffc02061a4:	fc86                	sd	ra,120(sp)
ffffffffc02061a6:	f8a2                	sd	s0,112(sp)
ffffffffc02061a8:	ecce                	sd	s3,88(sp)
ffffffffc02061aa:	f466                	sd	s9,40(sp)
ffffffffc02061ac:	ec6e                	sd	s11,24(sp)
ffffffffc02061ae:	892a                	mv	s2,a0
ffffffffc02061b0:	84ae                	mv	s1,a1
ffffffffc02061b2:	8d32                	mv	s10,a2
ffffffffc02061b4:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc02061b6:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02061b8:	00002a17          	auipc	s4,0x2
ffffffffc02061bc:	7f0a0a13          	addi	s4,s4,2032 # ffffffffc02089a8 <syscalls+0x100>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02061c0:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02061c4:	00003c17          	auipc	s8,0x3
ffffffffc02061c8:	93cc0c13          	addi	s8,s8,-1732 # ffffffffc0208b00 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02061cc:	000d4503          	lbu	a0,0(s10)
ffffffffc02061d0:	02500793          	li	a5,37
ffffffffc02061d4:	001d0413          	addi	s0,s10,1
ffffffffc02061d8:	00f50e63          	beq	a0,a5,ffffffffc02061f4 <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc02061dc:	c521                	beqz	a0,ffffffffc0206224 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02061de:	02500993          	li	s3,37
ffffffffc02061e2:	a011                	j	ffffffffc02061e6 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc02061e4:	c121                	beqz	a0,ffffffffc0206224 <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc02061e6:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02061e8:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc02061ea:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02061ec:	fff44503          	lbu	a0,-1(s0)
ffffffffc02061f0:	ff351ae3          	bne	a0,s3,ffffffffc02061e4 <vprintfmt+0x52>
ffffffffc02061f4:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc02061f8:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc02061fc:	4981                	li	s3,0
ffffffffc02061fe:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0206200:	5cfd                	li	s9,-1
ffffffffc0206202:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206204:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0206208:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020620a:	fdd6069b          	addiw	a3,a2,-35
ffffffffc020620e:	0ff6f693          	andi	a3,a3,255
ffffffffc0206212:	00140d13          	addi	s10,s0,1
ffffffffc0206216:	1ed5ef63          	bltu	a1,a3,ffffffffc0206414 <vprintfmt+0x282>
ffffffffc020621a:	068a                	slli	a3,a3,0x2
ffffffffc020621c:	96d2                	add	a3,a3,s4
ffffffffc020621e:	4294                	lw	a3,0(a3)
ffffffffc0206220:	96d2                	add	a3,a3,s4
ffffffffc0206222:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0206224:	70e6                	ld	ra,120(sp)
ffffffffc0206226:	7446                	ld	s0,112(sp)
ffffffffc0206228:	74a6                	ld	s1,104(sp)
ffffffffc020622a:	7906                	ld	s2,96(sp)
ffffffffc020622c:	69e6                	ld	s3,88(sp)
ffffffffc020622e:	6a46                	ld	s4,80(sp)
ffffffffc0206230:	6aa6                	ld	s5,72(sp)
ffffffffc0206232:	6b06                	ld	s6,64(sp)
ffffffffc0206234:	7be2                	ld	s7,56(sp)
ffffffffc0206236:	7c42                	ld	s8,48(sp)
ffffffffc0206238:	7ca2                	ld	s9,40(sp)
ffffffffc020623a:	7d02                	ld	s10,32(sp)
ffffffffc020623c:	6de2                	ld	s11,24(sp)
ffffffffc020623e:	6109                	addi	sp,sp,128
ffffffffc0206240:	8082                	ret
            padc = '-';
ffffffffc0206242:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206244:	00144603          	lbu	a2,1(s0)
ffffffffc0206248:	846a                	mv	s0,s10
ffffffffc020624a:	b7c1                	j	ffffffffc020620a <vprintfmt+0x78>
            precision = va_arg(ap, int);
ffffffffc020624c:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc0206250:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc0206254:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206256:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0206258:	fa0dd9e3          	bgez	s11,ffffffffc020620a <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc020625c:	8de6                	mv	s11,s9
ffffffffc020625e:	5cfd                	li	s9,-1
ffffffffc0206260:	b76d                	j	ffffffffc020620a <vprintfmt+0x78>
            if (width < 0)
ffffffffc0206262:	fffdc693          	not	a3,s11
ffffffffc0206266:	96fd                	srai	a3,a3,0x3f
ffffffffc0206268:	00ddfdb3          	and	s11,s11,a3
ffffffffc020626c:	00144603          	lbu	a2,1(s0)
ffffffffc0206270:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206272:	846a                	mv	s0,s10
ffffffffc0206274:	bf59                	j	ffffffffc020620a <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0206276:	4705                	li	a4,1
ffffffffc0206278:	008a8593          	addi	a1,s5,8
ffffffffc020627c:	01074463          	blt	a4,a6,ffffffffc0206284 <vprintfmt+0xf2>
    else if (lflag) {
ffffffffc0206280:	22080863          	beqz	a6,ffffffffc02064b0 <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
ffffffffc0206284:	000ab603          	ld	a2,0(s5)
ffffffffc0206288:	46c1                	li	a3,16
ffffffffc020628a:	8aae                	mv	s5,a1
ffffffffc020628c:	a291                	j	ffffffffc02063d0 <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
ffffffffc020628e:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc0206292:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206296:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0206298:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc020629c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02062a0:	fad56ce3          	bltu	a0,a3,ffffffffc0206258 <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
ffffffffc02062a4:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02062a6:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc02062aa:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02062ae:	0196873b          	addw	a4,a3,s9
ffffffffc02062b2:	0017171b          	slliw	a4,a4,0x1
ffffffffc02062b6:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc02062ba:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc02062be:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc02062c2:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc02062c6:	fcd57fe3          	bgeu	a0,a3,ffffffffc02062a4 <vprintfmt+0x112>
ffffffffc02062ca:	b779                	j	ffffffffc0206258 <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
ffffffffc02062cc:	000aa503          	lw	a0,0(s5)
ffffffffc02062d0:	85a6                	mv	a1,s1
ffffffffc02062d2:	0aa1                	addi	s5,s5,8
ffffffffc02062d4:	9902                	jalr	s2
            break;
ffffffffc02062d6:	bddd                	j	ffffffffc02061cc <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02062d8:	4705                	li	a4,1
ffffffffc02062da:	008a8993          	addi	s3,s5,8
ffffffffc02062de:	01074463          	blt	a4,a6,ffffffffc02062e6 <vprintfmt+0x154>
    else if (lflag) {
ffffffffc02062e2:	1c080463          	beqz	a6,ffffffffc02064aa <vprintfmt+0x318>
        return va_arg(*ap, long);
ffffffffc02062e6:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02062ea:	1c044a63          	bltz	s0,ffffffffc02064be <vprintfmt+0x32c>
            num = getint(&ap, lflag);
ffffffffc02062ee:	8622                	mv	a2,s0
ffffffffc02062f0:	8ace                	mv	s5,s3
ffffffffc02062f2:	46a9                	li	a3,10
ffffffffc02062f4:	a8f1                	j	ffffffffc02063d0 <vprintfmt+0x23e>
            err = va_arg(ap, int);
ffffffffc02062f6:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02062fa:	4761                	li	a4,24
            err = va_arg(ap, int);
ffffffffc02062fc:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02062fe:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc0206302:	8fb5                	xor	a5,a5,a3
ffffffffc0206304:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206308:	12d74963          	blt	a4,a3,ffffffffc020643a <vprintfmt+0x2a8>
ffffffffc020630c:	00369793          	slli	a5,a3,0x3
ffffffffc0206310:	97e2                	add	a5,a5,s8
ffffffffc0206312:	639c                	ld	a5,0(a5)
ffffffffc0206314:	12078363          	beqz	a5,ffffffffc020643a <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
ffffffffc0206318:	86be                	mv	a3,a5
ffffffffc020631a:	00000617          	auipc	a2,0x0
ffffffffc020631e:	2ee60613          	addi	a2,a2,750 # ffffffffc0206608 <etext+0x2e>
ffffffffc0206322:	85a6                	mv	a1,s1
ffffffffc0206324:	854a                	mv	a0,s2
ffffffffc0206326:	1cc000ef          	jal	ra,ffffffffc02064f2 <printfmt>
ffffffffc020632a:	b54d                	j	ffffffffc02061cc <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020632c:	000ab603          	ld	a2,0(s5)
ffffffffc0206330:	0aa1                	addi	s5,s5,8
ffffffffc0206332:	1a060163          	beqz	a2,ffffffffc02064d4 <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
ffffffffc0206336:	00160413          	addi	s0,a2,1
ffffffffc020633a:	15b05763          	blez	s11,ffffffffc0206488 <vprintfmt+0x2f6>
ffffffffc020633e:	02d00593          	li	a1,45
ffffffffc0206342:	10b79d63          	bne	a5,a1,ffffffffc020645c <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206346:	00064783          	lbu	a5,0(a2)
ffffffffc020634a:	0007851b          	sext.w	a0,a5
ffffffffc020634e:	c905                	beqz	a0,ffffffffc020637e <vprintfmt+0x1ec>
ffffffffc0206350:	000cc563          	bltz	s9,ffffffffc020635a <vprintfmt+0x1c8>
ffffffffc0206354:	3cfd                	addiw	s9,s9,-1
ffffffffc0206356:	036c8263          	beq	s9,s6,ffffffffc020637a <vprintfmt+0x1e8>
                    putch('?', putdat);
ffffffffc020635a:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020635c:	14098f63          	beqz	s3,ffffffffc02064ba <vprintfmt+0x328>
ffffffffc0206360:	3781                	addiw	a5,a5,-32
ffffffffc0206362:	14fbfc63          	bgeu	s7,a5,ffffffffc02064ba <vprintfmt+0x328>
                    putch('?', putdat);
ffffffffc0206366:	03f00513          	li	a0,63
ffffffffc020636a:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020636c:	0405                	addi	s0,s0,1
ffffffffc020636e:	fff44783          	lbu	a5,-1(s0)
ffffffffc0206372:	3dfd                	addiw	s11,s11,-1
ffffffffc0206374:	0007851b          	sext.w	a0,a5
ffffffffc0206378:	fd61                	bnez	a0,ffffffffc0206350 <vprintfmt+0x1be>
            for (; width > 0; width --) {
ffffffffc020637a:	e5b059e3          	blez	s11,ffffffffc02061cc <vprintfmt+0x3a>
ffffffffc020637e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0206380:	85a6                	mv	a1,s1
ffffffffc0206382:	02000513          	li	a0,32
ffffffffc0206386:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206388:	e40d82e3          	beqz	s11,ffffffffc02061cc <vprintfmt+0x3a>
ffffffffc020638c:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020638e:	85a6                	mv	a1,s1
ffffffffc0206390:	02000513          	li	a0,32
ffffffffc0206394:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0206396:	fe0d94e3          	bnez	s11,ffffffffc020637e <vprintfmt+0x1ec>
ffffffffc020639a:	bd0d                	j	ffffffffc02061cc <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc020639c:	4705                	li	a4,1
ffffffffc020639e:	008a8593          	addi	a1,s5,8
ffffffffc02063a2:	01074463          	blt	a4,a6,ffffffffc02063aa <vprintfmt+0x218>
    else if (lflag) {
ffffffffc02063a6:	0e080863          	beqz	a6,ffffffffc0206496 <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
ffffffffc02063aa:	000ab603          	ld	a2,0(s5)
ffffffffc02063ae:	46a1                	li	a3,8
ffffffffc02063b0:	8aae                	mv	s5,a1
ffffffffc02063b2:	a839                	j	ffffffffc02063d0 <vprintfmt+0x23e>
            putch('0', putdat);
ffffffffc02063b4:	03000513          	li	a0,48
ffffffffc02063b8:	85a6                	mv	a1,s1
ffffffffc02063ba:	e03e                	sd	a5,0(sp)
ffffffffc02063bc:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc02063be:	85a6                	mv	a1,s1
ffffffffc02063c0:	07800513          	li	a0,120
ffffffffc02063c4:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02063c6:	0aa1                	addi	s5,s5,8
ffffffffc02063c8:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc02063cc:	6782                	ld	a5,0(sp)
ffffffffc02063ce:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc02063d0:	2781                	sext.w	a5,a5
ffffffffc02063d2:	876e                	mv	a4,s11
ffffffffc02063d4:	85a6                	mv	a1,s1
ffffffffc02063d6:	854a                	mv	a0,s2
ffffffffc02063d8:	d4fff0ef          	jal	ra,ffffffffc0206126 <printnum>
            break;
ffffffffc02063dc:	bbc5                	j	ffffffffc02061cc <vprintfmt+0x3a>
            lflag ++;
ffffffffc02063de:	00144603          	lbu	a2,1(s0)
ffffffffc02063e2:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063e4:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02063e6:	b515                	j	ffffffffc020620a <vprintfmt+0x78>
            goto reswitch;
ffffffffc02063e8:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02063ec:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063ee:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02063f0:	bd29                	j	ffffffffc020620a <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02063f2:	85a6                	mv	a1,s1
ffffffffc02063f4:	02500513          	li	a0,37
ffffffffc02063f8:	9902                	jalr	s2
            break;
ffffffffc02063fa:	bbc9                	j	ffffffffc02061cc <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02063fc:	4705                	li	a4,1
ffffffffc02063fe:	008a8593          	addi	a1,s5,8
ffffffffc0206402:	01074463          	blt	a4,a6,ffffffffc020640a <vprintfmt+0x278>
    else if (lflag) {
ffffffffc0206406:	08080d63          	beqz	a6,ffffffffc02064a0 <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
ffffffffc020640a:	000ab603          	ld	a2,0(s5)
ffffffffc020640e:	46a9                	li	a3,10
ffffffffc0206410:	8aae                	mv	s5,a1
ffffffffc0206412:	bf7d                	j	ffffffffc02063d0 <vprintfmt+0x23e>
            putch('%', putdat);
ffffffffc0206414:	85a6                	mv	a1,s1
ffffffffc0206416:	02500513          	li	a0,37
ffffffffc020641a:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc020641c:	fff44703          	lbu	a4,-1(s0)
ffffffffc0206420:	02500793          	li	a5,37
ffffffffc0206424:	8d22                	mv	s10,s0
ffffffffc0206426:	daf703e3          	beq	a4,a5,ffffffffc02061cc <vprintfmt+0x3a>
ffffffffc020642a:	02500713          	li	a4,37
ffffffffc020642e:	1d7d                	addi	s10,s10,-1
ffffffffc0206430:	fffd4783          	lbu	a5,-1(s10)
ffffffffc0206434:	fee79de3          	bne	a5,a4,ffffffffc020642e <vprintfmt+0x29c>
ffffffffc0206438:	bb51                	j	ffffffffc02061cc <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020643a:	00003617          	auipc	a2,0x3
ffffffffc020643e:	86e60613          	addi	a2,a2,-1938 # ffffffffc0208ca8 <error_string+0x1a8>
ffffffffc0206442:	85a6                	mv	a1,s1
ffffffffc0206444:	854a                	mv	a0,s2
ffffffffc0206446:	0ac000ef          	jal	ra,ffffffffc02064f2 <printfmt>
ffffffffc020644a:	b349                	j	ffffffffc02061cc <vprintfmt+0x3a>
                p = "(null)";
ffffffffc020644c:	00003617          	auipc	a2,0x3
ffffffffc0206450:	85460613          	addi	a2,a2,-1964 # ffffffffc0208ca0 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
ffffffffc0206454:	00003417          	auipc	s0,0x3
ffffffffc0206458:	84d40413          	addi	s0,s0,-1971 # ffffffffc0208ca1 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020645c:	8532                	mv	a0,a2
ffffffffc020645e:	85e6                	mv	a1,s9
ffffffffc0206460:	e032                	sd	a2,0(sp)
ffffffffc0206462:	e43e                	sd	a5,8(sp)
ffffffffc0206464:	0cc000ef          	jal	ra,ffffffffc0206530 <strnlen>
ffffffffc0206468:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020646c:	6602                	ld	a2,0(sp)
ffffffffc020646e:	01b05d63          	blez	s11,ffffffffc0206488 <vprintfmt+0x2f6>
ffffffffc0206472:	67a2                	ld	a5,8(sp)
ffffffffc0206474:	2781                	sext.w	a5,a5
ffffffffc0206476:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0206478:	6522                	ld	a0,8(sp)
ffffffffc020647a:	85a6                	mv	a1,s1
ffffffffc020647c:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020647e:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc0206480:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206482:	6602                	ld	a2,0(sp)
ffffffffc0206484:	fe0d9ae3          	bnez	s11,ffffffffc0206478 <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206488:	00064783          	lbu	a5,0(a2)
ffffffffc020648c:	0007851b          	sext.w	a0,a5
ffffffffc0206490:	ec0510e3          	bnez	a0,ffffffffc0206350 <vprintfmt+0x1be>
ffffffffc0206494:	bb25                	j	ffffffffc02061cc <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
ffffffffc0206496:	000ae603          	lwu	a2,0(s5)
ffffffffc020649a:	46a1                	li	a3,8
ffffffffc020649c:	8aae                	mv	s5,a1
ffffffffc020649e:	bf0d                	j	ffffffffc02063d0 <vprintfmt+0x23e>
ffffffffc02064a0:	000ae603          	lwu	a2,0(s5)
ffffffffc02064a4:	46a9                	li	a3,10
ffffffffc02064a6:	8aae                	mv	s5,a1
ffffffffc02064a8:	b725                	j	ffffffffc02063d0 <vprintfmt+0x23e>
        return va_arg(*ap, int);
ffffffffc02064aa:	000aa403          	lw	s0,0(s5)
ffffffffc02064ae:	bd35                	j	ffffffffc02062ea <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
ffffffffc02064b0:	000ae603          	lwu	a2,0(s5)
ffffffffc02064b4:	46c1                	li	a3,16
ffffffffc02064b6:	8aae                	mv	s5,a1
ffffffffc02064b8:	bf21                	j	ffffffffc02063d0 <vprintfmt+0x23e>
                    putch(ch, putdat);
ffffffffc02064ba:	9902                	jalr	s2
ffffffffc02064bc:	bd45                	j	ffffffffc020636c <vprintfmt+0x1da>
                putch('-', putdat);
ffffffffc02064be:	85a6                	mv	a1,s1
ffffffffc02064c0:	02d00513          	li	a0,45
ffffffffc02064c4:	e03e                	sd	a5,0(sp)
ffffffffc02064c6:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc02064c8:	8ace                	mv	s5,s3
ffffffffc02064ca:	40800633          	neg	a2,s0
ffffffffc02064ce:	46a9                	li	a3,10
ffffffffc02064d0:	6782                	ld	a5,0(sp)
ffffffffc02064d2:	bdfd                	j	ffffffffc02063d0 <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
ffffffffc02064d4:	01b05663          	blez	s11,ffffffffc02064e0 <vprintfmt+0x34e>
ffffffffc02064d8:	02d00693          	li	a3,45
ffffffffc02064dc:	f6d798e3          	bne	a5,a3,ffffffffc020644c <vprintfmt+0x2ba>
ffffffffc02064e0:	00002417          	auipc	s0,0x2
ffffffffc02064e4:	7c140413          	addi	s0,s0,1985 # ffffffffc0208ca1 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02064e8:	02800513          	li	a0,40
ffffffffc02064ec:	02800793          	li	a5,40
ffffffffc02064f0:	b585                	j	ffffffffc0206350 <vprintfmt+0x1be>

ffffffffc02064f2 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02064f2:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02064f4:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02064f8:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02064fa:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02064fc:	ec06                	sd	ra,24(sp)
ffffffffc02064fe:	f83a                	sd	a4,48(sp)
ffffffffc0206500:	fc3e                	sd	a5,56(sp)
ffffffffc0206502:	e0c2                	sd	a6,64(sp)
ffffffffc0206504:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0206506:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0206508:	c8bff0ef          	jal	ra,ffffffffc0206192 <vprintfmt>
}
ffffffffc020650c:	60e2                	ld	ra,24(sp)
ffffffffc020650e:	6161                	addi	sp,sp,80
ffffffffc0206510:	8082                	ret

ffffffffc0206512 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0206512:	00054783          	lbu	a5,0(a0)
ffffffffc0206516:	cb91                	beqz	a5,ffffffffc020652a <strlen+0x18>
    size_t cnt = 0;
ffffffffc0206518:	4781                	li	a5,0
        cnt ++;
ffffffffc020651a:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc020651c:	00f50733          	add	a4,a0,a5
ffffffffc0206520:	00074703          	lbu	a4,0(a4)
ffffffffc0206524:	fb7d                	bnez	a4,ffffffffc020651a <strlen+0x8>
    }
    return cnt;
}
ffffffffc0206526:	853e                	mv	a0,a5
ffffffffc0206528:	8082                	ret
    size_t cnt = 0;
ffffffffc020652a:	4781                	li	a5,0
}
ffffffffc020652c:	853e                	mv	a0,a5
ffffffffc020652e:	8082                	ret

ffffffffc0206530 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206530:	c185                	beqz	a1,ffffffffc0206550 <strnlen+0x20>
ffffffffc0206532:	00054783          	lbu	a5,0(a0)
ffffffffc0206536:	cf89                	beqz	a5,ffffffffc0206550 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc0206538:	4781                	li	a5,0
ffffffffc020653a:	a021                	j	ffffffffc0206542 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc020653c:	00074703          	lbu	a4,0(a4)
ffffffffc0206540:	c711                	beqz	a4,ffffffffc020654c <strnlen+0x1c>
        cnt ++;
ffffffffc0206542:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0206544:	00f50733          	add	a4,a0,a5
ffffffffc0206548:	fef59ae3          	bne	a1,a5,ffffffffc020653c <strnlen+0xc>
    }
    return cnt;
}
ffffffffc020654c:	853e                	mv	a0,a5
ffffffffc020654e:	8082                	ret
    size_t cnt = 0;
ffffffffc0206550:	4781                	li	a5,0
}
ffffffffc0206552:	853e                	mv	a0,a5
ffffffffc0206554:	8082                	ret

ffffffffc0206556 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc0206556:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc0206558:	0585                	addi	a1,a1,1
ffffffffc020655a:	fff5c703          	lbu	a4,-1(a1)
ffffffffc020655e:	0785                	addi	a5,a5,1
ffffffffc0206560:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0206564:	fb75                	bnez	a4,ffffffffc0206558 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0206566:	8082                	ret

ffffffffc0206568 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206568:	00054783          	lbu	a5,0(a0)
ffffffffc020656c:	0005c703          	lbu	a4,0(a1)
ffffffffc0206570:	cb91                	beqz	a5,ffffffffc0206584 <strcmp+0x1c>
ffffffffc0206572:	00e79c63          	bne	a5,a4,ffffffffc020658a <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0206576:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206578:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc020657c:	0585                	addi	a1,a1,1
ffffffffc020657e:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206582:	fbe5                	bnez	a5,ffffffffc0206572 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206584:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0206586:	9d19                	subw	a0,a0,a4
ffffffffc0206588:	8082                	ret
ffffffffc020658a:	0007851b          	sext.w	a0,a5
ffffffffc020658e:	9d19                	subw	a0,a0,a4
ffffffffc0206590:	8082                	ret

ffffffffc0206592 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0206592:	00054783          	lbu	a5,0(a0)
ffffffffc0206596:	cb91                	beqz	a5,ffffffffc02065aa <strchr+0x18>
        if (*s == c) {
ffffffffc0206598:	00b79563          	bne	a5,a1,ffffffffc02065a2 <strchr+0x10>
ffffffffc020659c:	a809                	j	ffffffffc02065ae <strchr+0x1c>
ffffffffc020659e:	00b78763          	beq	a5,a1,ffffffffc02065ac <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc02065a2:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc02065a4:	00054783          	lbu	a5,0(a0)
ffffffffc02065a8:	fbfd                	bnez	a5,ffffffffc020659e <strchr+0xc>
    }
    return NULL;
ffffffffc02065aa:	4501                	li	a0,0
}
ffffffffc02065ac:	8082                	ret
ffffffffc02065ae:	8082                	ret

ffffffffc02065b0 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc02065b0:	ca01                	beqz	a2,ffffffffc02065c0 <memset+0x10>
ffffffffc02065b2:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc02065b4:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc02065b6:	0785                	addi	a5,a5,1
ffffffffc02065b8:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc02065bc:	fec79de3          	bne	a5,a2,ffffffffc02065b6 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc02065c0:	8082                	ret

ffffffffc02065c2 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc02065c2:	ca19                	beqz	a2,ffffffffc02065d8 <memcpy+0x16>
ffffffffc02065c4:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc02065c6:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc02065c8:	0585                	addi	a1,a1,1
ffffffffc02065ca:	fff5c703          	lbu	a4,-1(a1)
ffffffffc02065ce:	0785                	addi	a5,a5,1
ffffffffc02065d0:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc02065d4:	fec59ae3          	bne	a1,a2,ffffffffc02065c8 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02065d8:	8082                	ret
