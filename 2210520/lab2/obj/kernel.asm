
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
ffffffffc0200042:	52260613          	addi	a2,a2,1314 # ffffffffc0206560 <end>
int kern_init(void) {
ffffffffc0200046:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc0200048:	8e09                	sub	a2,a2,a0
ffffffffc020004a:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020004c:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020004e:	400010ef          	jal	ra,ffffffffc020144e <memset>
    cons_init();  // init the console
ffffffffc0200052:	3f8000ef          	jal	ra,ffffffffc020044a <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200056:	00001517          	auipc	a0,0x1
ffffffffc020005a:	40a50513          	addi	a0,a0,1034 # ffffffffc0201460 <etext>
ffffffffc020005e:	08e000ef          	jal	ra,ffffffffc02000ec <cputs>

    print_kerninfo();
ffffffffc0200062:	0da000ef          	jal	ra,ffffffffc020013c <print_kerninfo>

    // grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200066:	3fe000ef          	jal	ra,ffffffffc0200464 <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020006a:	4c9000ef          	jal	ra,ffffffffc0200d32 <pmm_init>

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
ffffffffc02000aa:	6a3000ef          	jal	ra,ffffffffc0200f4c <vprintfmt>
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
ffffffffc02000de:	66f000ef          	jal	ra,ffffffffc0200f4c <vprintfmt>
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
ffffffffc020013e:	00001517          	auipc	a0,0x1
ffffffffc0200142:	37250513          	addi	a0,a0,882 # ffffffffc02014b0 <etext+0x50>
void print_kerninfo(void) {
ffffffffc0200146:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200148:	f6fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc020014c:	00000597          	auipc	a1,0x0
ffffffffc0200150:	eea58593          	addi	a1,a1,-278 # ffffffffc0200036 <kern_init>
ffffffffc0200154:	00001517          	auipc	a0,0x1
ffffffffc0200158:	37c50513          	addi	a0,a0,892 # ffffffffc02014d0 <etext+0x70>
ffffffffc020015c:	f5bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc0200160:	00001597          	auipc	a1,0x1
ffffffffc0200164:	30058593          	addi	a1,a1,768 # ffffffffc0201460 <etext>
ffffffffc0200168:	00001517          	auipc	a0,0x1
ffffffffc020016c:	38850513          	addi	a0,a0,904 # ffffffffc02014f0 <etext+0x90>
ffffffffc0200170:	f47ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200174:	00006597          	auipc	a1,0x6
ffffffffc0200178:	e9c58593          	addi	a1,a1,-356 # ffffffffc0206010 <edata>
ffffffffc020017c:	00001517          	auipc	a0,0x1
ffffffffc0200180:	39450513          	addi	a0,a0,916 # ffffffffc0201510 <etext+0xb0>
ffffffffc0200184:	f33ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200188:	00006597          	auipc	a1,0x6
ffffffffc020018c:	3d858593          	addi	a1,a1,984 # ffffffffc0206560 <end>
ffffffffc0200190:	00001517          	auipc	a0,0x1
ffffffffc0200194:	3a050513          	addi	a0,a0,928 # ffffffffc0201530 <etext+0xd0>
ffffffffc0200198:	f1fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020019c:	00006597          	auipc	a1,0x6
ffffffffc02001a0:	7c358593          	addi	a1,a1,1987 # ffffffffc020695f <end+0x3ff>
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
ffffffffc02001be:	00001517          	auipc	a0,0x1
ffffffffc02001c2:	39250513          	addi	a0,a0,914 # ffffffffc0201550 <etext+0xf0>
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
ffffffffc02001cc:	00001617          	auipc	a2,0x1
ffffffffc02001d0:	2b460613          	addi	a2,a2,692 # ffffffffc0201480 <etext+0x20>
ffffffffc02001d4:	04e00593          	li	a1,78
ffffffffc02001d8:	00001517          	auipc	a0,0x1
ffffffffc02001dc:	2c050513          	addi	a0,a0,704 # ffffffffc0201498 <etext+0x38>
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
ffffffffc02001e8:	00001617          	auipc	a2,0x1
ffffffffc02001ec:	47860613          	addi	a2,a2,1144 # ffffffffc0201660 <commands+0xe0>
ffffffffc02001f0:	00001597          	auipc	a1,0x1
ffffffffc02001f4:	49058593          	addi	a1,a1,1168 # ffffffffc0201680 <commands+0x100>
ffffffffc02001f8:	00001517          	auipc	a0,0x1
ffffffffc02001fc:	49050513          	addi	a0,a0,1168 # ffffffffc0201688 <commands+0x108>
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200200:	e406                	sd	ra,8(sp)
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc0200202:	eb5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200206:	00001617          	auipc	a2,0x1
ffffffffc020020a:	49260613          	addi	a2,a2,1170 # ffffffffc0201698 <commands+0x118>
ffffffffc020020e:	00001597          	auipc	a1,0x1
ffffffffc0200212:	4b258593          	addi	a1,a1,1202 # ffffffffc02016c0 <commands+0x140>
ffffffffc0200216:	00001517          	auipc	a0,0x1
ffffffffc020021a:	47250513          	addi	a0,a0,1138 # ffffffffc0201688 <commands+0x108>
ffffffffc020021e:	e99ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
ffffffffc0200222:	00001617          	auipc	a2,0x1
ffffffffc0200226:	4ae60613          	addi	a2,a2,1198 # ffffffffc02016d0 <commands+0x150>
ffffffffc020022a:	00001597          	auipc	a1,0x1
ffffffffc020022e:	4c658593          	addi	a1,a1,1222 # ffffffffc02016f0 <commands+0x170>
ffffffffc0200232:	00001517          	auipc	a0,0x1
ffffffffc0200236:	45650513          	addi	a0,a0,1110 # ffffffffc0201688 <commands+0x108>
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
ffffffffc020026c:	00001517          	auipc	a0,0x1
ffffffffc0200270:	35c50513          	addi	a0,a0,860 # ffffffffc02015c8 <commands+0x48>
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
ffffffffc020028e:	00001517          	auipc	a0,0x1
ffffffffc0200292:	36250513          	addi	a0,a0,866 # ffffffffc02015f0 <commands+0x70>
ffffffffc0200296:	e21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    if (tf != NULL) {
ffffffffc020029a:	000c0563          	beqz	s8,ffffffffc02002a4 <kmonitor+0x3e>
        print_trapframe(tf);
ffffffffc020029e:	8562                	mv	a0,s8
ffffffffc02002a0:	3a2000ef          	jal	ra,ffffffffc0200642 <print_trapframe>
ffffffffc02002a4:	00001c97          	auipc	s9,0x1
ffffffffc02002a8:	2dcc8c93          	addi	s9,s9,732 # ffffffffc0201580 <commands>
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002ac:	00001997          	auipc	s3,0x1
ffffffffc02002b0:	36c98993          	addi	s3,s3,876 # ffffffffc0201618 <commands+0x98>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002b4:	00001917          	auipc	s2,0x1
ffffffffc02002b8:	36c90913          	addi	s2,s2,876 # ffffffffc0201620 <commands+0xa0>
        if (argc == MAXARGS - 1) {
ffffffffc02002bc:	4a3d                	li	s4,15
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc02002be:	00001b17          	auipc	s6,0x1
ffffffffc02002c2:	36ab0b13          	addi	s6,s6,874 # ffffffffc0201628 <commands+0xa8>
    if (argc == 0) {
ffffffffc02002c6:	00001a97          	auipc	s5,0x1
ffffffffc02002ca:	3baa8a93          	addi	s5,s5,954 # ffffffffc0201680 <commands+0x100>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002ce:	4b8d                	li	s7,3
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002d0:	854e                	mv	a0,s3
ffffffffc02002d2:	7fb000ef          	jal	ra,ffffffffc02012cc <readline>
ffffffffc02002d6:	842a                	mv	s0,a0
ffffffffc02002d8:	dd65                	beqz	a0,ffffffffc02002d0 <kmonitor+0x6a>
ffffffffc02002da:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002de:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002e0:	c999                	beqz	a1,ffffffffc02002f6 <kmonitor+0x90>
ffffffffc02002e2:	854a                	mv	a0,s2
ffffffffc02002e4:	14c010ef          	jal	ra,ffffffffc0201430 <strchr>
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
ffffffffc02002fa:	00001d17          	auipc	s10,0x1
ffffffffc02002fe:	286d0d13          	addi	s10,s10,646 # ffffffffc0201580 <commands>
    if (argc == 0) {
ffffffffc0200302:	8556                	mv	a0,s5
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200304:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200306:	0d61                	addi	s10,s10,24
ffffffffc0200308:	0fe010ef          	jal	ra,ffffffffc0201406 <strcmp>
ffffffffc020030c:	c919                	beqz	a0,ffffffffc0200322 <kmonitor+0xbc>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020030e:	2405                	addiw	s0,s0,1
ffffffffc0200310:	09740463          	beq	s0,s7,ffffffffc0200398 <kmonitor+0x132>
ffffffffc0200314:	000d3503          	ld	a0,0(s10)
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200318:	6582                	ld	a1,0(sp)
ffffffffc020031a:	0d61                	addi	s10,s10,24
ffffffffc020031c:	0ea010ef          	jal	ra,ffffffffc0201406 <strcmp>
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
ffffffffc0200382:	0ae010ef          	jal	ra,ffffffffc0201430 <strchr>
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
ffffffffc020039a:	00001517          	auipc	a0,0x1
ffffffffc020039e:	2ae50513          	addi	a0,a0,686 # ffffffffc0201648 <commands+0xc8>
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
ffffffffc02003da:	00001517          	auipc	a0,0x1
ffffffffc02003de:	32650513          	addi	a0,a0,806 # ffffffffc0201700 <commands+0x180>
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
ffffffffc02003f4:	18850513          	addi	a0,a0,392 # ffffffffc0201578 <etext+0x118>
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
ffffffffc0200420:	787000ef          	jal	ra,ffffffffc02013a6 <sbi_set_timer>
}
ffffffffc0200424:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc0200426:	00006797          	auipc	a5,0x6
ffffffffc020042a:	0007b523          	sd	zero,10(a5) # ffffffffc0206430 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020042e:	00001517          	auipc	a0,0x1
ffffffffc0200432:	2f250513          	addi	a0,a0,754 # ffffffffc0201720 <commands+0x1a0>
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
ffffffffc0200446:	7610006f          	j	ffffffffc02013a6 <sbi_set_timer>

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
ffffffffc0200450:	73b0006f          	j	ffffffffc020138a <sbi_console_putchar>

ffffffffc0200454 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200454:	76f0006f          	j	ffffffffc02013c2 <sbi_console_getchar>

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
ffffffffc020047e:	00001517          	auipc	a0,0x1
ffffffffc0200482:	3ba50513          	addi	a0,a0,954 # ffffffffc0201838 <commands+0x2b8>
void print_regs(struct pushregs *gpr) {
ffffffffc0200486:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200488:	c2fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020048c:	640c                	ld	a1,8(s0)
ffffffffc020048e:	00001517          	auipc	a0,0x1
ffffffffc0200492:	3c250513          	addi	a0,a0,962 # ffffffffc0201850 <commands+0x2d0>
ffffffffc0200496:	c21ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020049a:	680c                	ld	a1,16(s0)
ffffffffc020049c:	00001517          	auipc	a0,0x1
ffffffffc02004a0:	3cc50513          	addi	a0,a0,972 # ffffffffc0201868 <commands+0x2e8>
ffffffffc02004a4:	c13ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc02004a8:	6c0c                	ld	a1,24(s0)
ffffffffc02004aa:	00001517          	auipc	a0,0x1
ffffffffc02004ae:	3d650513          	addi	a0,a0,982 # ffffffffc0201880 <commands+0x300>
ffffffffc02004b2:	c05ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc02004b6:	700c                	ld	a1,32(s0)
ffffffffc02004b8:	00001517          	auipc	a0,0x1
ffffffffc02004bc:	3e050513          	addi	a0,a0,992 # ffffffffc0201898 <commands+0x318>
ffffffffc02004c0:	bf7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc02004c4:	740c                	ld	a1,40(s0)
ffffffffc02004c6:	00001517          	auipc	a0,0x1
ffffffffc02004ca:	3ea50513          	addi	a0,a0,1002 # ffffffffc02018b0 <commands+0x330>
ffffffffc02004ce:	be9ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc02004d2:	780c                	ld	a1,48(s0)
ffffffffc02004d4:	00001517          	auipc	a0,0x1
ffffffffc02004d8:	3f450513          	addi	a0,a0,1012 # ffffffffc02018c8 <commands+0x348>
ffffffffc02004dc:	bdbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc02004e0:	7c0c                	ld	a1,56(s0)
ffffffffc02004e2:	00001517          	auipc	a0,0x1
ffffffffc02004e6:	3fe50513          	addi	a0,a0,1022 # ffffffffc02018e0 <commands+0x360>
ffffffffc02004ea:	bcdff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc02004ee:	602c                	ld	a1,64(s0)
ffffffffc02004f0:	00001517          	auipc	a0,0x1
ffffffffc02004f4:	40850513          	addi	a0,a0,1032 # ffffffffc02018f8 <commands+0x378>
ffffffffc02004f8:	bbfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02004fc:	642c                	ld	a1,72(s0)
ffffffffc02004fe:	00001517          	auipc	a0,0x1
ffffffffc0200502:	41250513          	addi	a0,a0,1042 # ffffffffc0201910 <commands+0x390>
ffffffffc0200506:	bb1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc020050a:	682c                	ld	a1,80(s0)
ffffffffc020050c:	00001517          	auipc	a0,0x1
ffffffffc0200510:	41c50513          	addi	a0,a0,1052 # ffffffffc0201928 <commands+0x3a8>
ffffffffc0200514:	ba3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200518:	6c2c                	ld	a1,88(s0)
ffffffffc020051a:	00001517          	auipc	a0,0x1
ffffffffc020051e:	42650513          	addi	a0,a0,1062 # ffffffffc0201940 <commands+0x3c0>
ffffffffc0200522:	b95ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200526:	702c                	ld	a1,96(s0)
ffffffffc0200528:	00001517          	auipc	a0,0x1
ffffffffc020052c:	43050513          	addi	a0,a0,1072 # ffffffffc0201958 <commands+0x3d8>
ffffffffc0200530:	b87ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc0200534:	742c                	ld	a1,104(s0)
ffffffffc0200536:	00001517          	auipc	a0,0x1
ffffffffc020053a:	43a50513          	addi	a0,a0,1082 # ffffffffc0201970 <commands+0x3f0>
ffffffffc020053e:	b79ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc0200542:	782c                	ld	a1,112(s0)
ffffffffc0200544:	00001517          	auipc	a0,0x1
ffffffffc0200548:	44450513          	addi	a0,a0,1092 # ffffffffc0201988 <commands+0x408>
ffffffffc020054c:	b6bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200550:	7c2c                	ld	a1,120(s0)
ffffffffc0200552:	00001517          	auipc	a0,0x1
ffffffffc0200556:	44e50513          	addi	a0,a0,1102 # ffffffffc02019a0 <commands+0x420>
ffffffffc020055a:	b5dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc020055e:	604c                	ld	a1,128(s0)
ffffffffc0200560:	00001517          	auipc	a0,0x1
ffffffffc0200564:	45850513          	addi	a0,a0,1112 # ffffffffc02019b8 <commands+0x438>
ffffffffc0200568:	b4fff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc020056c:	644c                	ld	a1,136(s0)
ffffffffc020056e:	00001517          	auipc	a0,0x1
ffffffffc0200572:	46250513          	addi	a0,a0,1122 # ffffffffc02019d0 <commands+0x450>
ffffffffc0200576:	b41ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc020057a:	684c                	ld	a1,144(s0)
ffffffffc020057c:	00001517          	auipc	a0,0x1
ffffffffc0200580:	46c50513          	addi	a0,a0,1132 # ffffffffc02019e8 <commands+0x468>
ffffffffc0200584:	b33ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200588:	6c4c                	ld	a1,152(s0)
ffffffffc020058a:	00001517          	auipc	a0,0x1
ffffffffc020058e:	47650513          	addi	a0,a0,1142 # ffffffffc0201a00 <commands+0x480>
ffffffffc0200592:	b25ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200596:	704c                	ld	a1,160(s0)
ffffffffc0200598:	00001517          	auipc	a0,0x1
ffffffffc020059c:	48050513          	addi	a0,a0,1152 # ffffffffc0201a18 <commands+0x498>
ffffffffc02005a0:	b17ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02005a4:	744c                	ld	a1,168(s0)
ffffffffc02005a6:	00001517          	auipc	a0,0x1
ffffffffc02005aa:	48a50513          	addi	a0,a0,1162 # ffffffffc0201a30 <commands+0x4b0>
ffffffffc02005ae:	b09ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc02005b2:	784c                	ld	a1,176(s0)
ffffffffc02005b4:	00001517          	auipc	a0,0x1
ffffffffc02005b8:	49450513          	addi	a0,a0,1172 # ffffffffc0201a48 <commands+0x4c8>
ffffffffc02005bc:	afbff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc02005c0:	7c4c                	ld	a1,184(s0)
ffffffffc02005c2:	00001517          	auipc	a0,0x1
ffffffffc02005c6:	49e50513          	addi	a0,a0,1182 # ffffffffc0201a60 <commands+0x4e0>
ffffffffc02005ca:	aedff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc02005ce:	606c                	ld	a1,192(s0)
ffffffffc02005d0:	00001517          	auipc	a0,0x1
ffffffffc02005d4:	4a850513          	addi	a0,a0,1192 # ffffffffc0201a78 <commands+0x4f8>
ffffffffc02005d8:	adfff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc02005dc:	646c                	ld	a1,200(s0)
ffffffffc02005de:	00001517          	auipc	a0,0x1
ffffffffc02005e2:	4b250513          	addi	a0,a0,1202 # ffffffffc0201a90 <commands+0x510>
ffffffffc02005e6:	ad1ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc02005ea:	686c                	ld	a1,208(s0)
ffffffffc02005ec:	00001517          	auipc	a0,0x1
ffffffffc02005f0:	4bc50513          	addi	a0,a0,1212 # ffffffffc0201aa8 <commands+0x528>
ffffffffc02005f4:	ac3ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc02005f8:	6c6c                	ld	a1,216(s0)
ffffffffc02005fa:	00001517          	auipc	a0,0x1
ffffffffc02005fe:	4c650513          	addi	a0,a0,1222 # ffffffffc0201ac0 <commands+0x540>
ffffffffc0200602:	ab5ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200606:	706c                	ld	a1,224(s0)
ffffffffc0200608:	00001517          	auipc	a0,0x1
ffffffffc020060c:	4d050513          	addi	a0,a0,1232 # ffffffffc0201ad8 <commands+0x558>
ffffffffc0200610:	aa7ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200614:	746c                	ld	a1,232(s0)
ffffffffc0200616:	00001517          	auipc	a0,0x1
ffffffffc020061a:	4da50513          	addi	a0,a0,1242 # ffffffffc0201af0 <commands+0x570>
ffffffffc020061e:	a99ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200622:	786c                	ld	a1,240(s0)
ffffffffc0200624:	00001517          	auipc	a0,0x1
ffffffffc0200628:	4e450513          	addi	a0,a0,1252 # ffffffffc0201b08 <commands+0x588>
ffffffffc020062c:	a8bff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200630:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200632:	6402                	ld	s0,0(sp)
ffffffffc0200634:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200636:	00001517          	auipc	a0,0x1
ffffffffc020063a:	4ea50513          	addi	a0,a0,1258 # ffffffffc0201b20 <commands+0x5a0>
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
ffffffffc020064a:	00001517          	auipc	a0,0x1
ffffffffc020064e:	4ee50513          	addi	a0,a0,1262 # ffffffffc0201b38 <commands+0x5b8>
void print_trapframe(struct trapframe *tf) {
ffffffffc0200652:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200654:	a63ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200658:	8522                	mv	a0,s0
ffffffffc020065a:	e1dff0ef          	jal	ra,ffffffffc0200476 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc020065e:	10043583          	ld	a1,256(s0)
ffffffffc0200662:	00001517          	auipc	a0,0x1
ffffffffc0200666:	4ee50513          	addi	a0,a0,1262 # ffffffffc0201b50 <commands+0x5d0>
ffffffffc020066a:	a4dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc020066e:	10843583          	ld	a1,264(s0)
ffffffffc0200672:	00001517          	auipc	a0,0x1
ffffffffc0200676:	4f650513          	addi	a0,a0,1270 # ffffffffc0201b68 <commands+0x5e8>
ffffffffc020067a:	a3dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc020067e:	11043583          	ld	a1,272(s0)
ffffffffc0200682:	00001517          	auipc	a0,0x1
ffffffffc0200686:	4fe50513          	addi	a0,a0,1278 # ffffffffc0201b80 <commands+0x600>
ffffffffc020068a:	a2dff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc020068e:	11843583          	ld	a1,280(s0)
}
ffffffffc0200692:	6402                	ld	s0,0(sp)
ffffffffc0200694:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200696:	00001517          	auipc	a0,0x1
ffffffffc020069a:	50250513          	addi	a0,a0,1282 # ffffffffc0201b98 <commands+0x618>
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
ffffffffc02006b4:	08c70713          	addi	a4,a4,140 # ffffffffc020173c <commands+0x1bc>
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
ffffffffc02006c6:	10e50513          	addi	a0,a0,270 # ffffffffc02017d0 <commands+0x250>
ffffffffc02006ca:	b2f5                	j	ffffffffc02000b6 <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc02006cc:	00001517          	auipc	a0,0x1
ffffffffc02006d0:	0e450513          	addi	a0,a0,228 # ffffffffc02017b0 <commands+0x230>
ffffffffc02006d4:	b2cd                	j	ffffffffc02000b6 <cprintf>
            cprintf("User software interrupt\n");
ffffffffc02006d6:	00001517          	auipc	a0,0x1
ffffffffc02006da:	09a50513          	addi	a0,a0,154 # ffffffffc0201770 <commands+0x1f0>
ffffffffc02006de:	bae1                	j	ffffffffc02000b6 <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc02006e0:	00001517          	auipc	a0,0x1
ffffffffc02006e4:	11050513          	addi	a0,a0,272 # ffffffffc02017f0 <commands+0x270>
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
ffffffffc020071a:	10250513          	addi	a0,a0,258 # ffffffffc0201818 <commands+0x298>
ffffffffc020071e:	ba61                	j	ffffffffc02000b6 <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200720:	00001517          	auipc	a0,0x1
ffffffffc0200724:	07050513          	addi	a0,a0,112 # ffffffffc0201790 <commands+0x210>
ffffffffc0200728:	b279                	j	ffffffffc02000b6 <cprintf>
            print_trapframe(tf);
ffffffffc020072a:	bf21                	j	ffffffffc0200642 <print_trapframe>
}
ffffffffc020072c:	60a2                	ld	ra,8(sp)
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc020072e:	06400593          	li	a1,100
ffffffffc0200732:	00001517          	auipc	a0,0x1
ffffffffc0200736:	0d650513          	addi	a0,a0,214 # ffffffffc0201808 <commands+0x288>
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

ffffffffc020080a <buddy_system_init>:

// 初始化预算系统的链表和空闲块数量
static void
buddy_system_init(void) {
    // 遍历每个级别的链表
    for(int i = 0; i < MAX_ORDER; i++) {
ffffffffc020080a:	00006797          	auipc	a5,0x6
ffffffffc020080e:	c2e78793          	addi	a5,a5,-978 # ffffffffc0206438 <free_area>
ffffffffc0200812:	00006717          	auipc	a4,0x6
ffffffffc0200816:	d2e70713          	addi	a4,a4,-722 # ffffffffc0206540 <satp_physical>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020081a:	e79c                	sd	a5,8(a5)
ffffffffc020081c:	e39c                	sd	a5,0(a5)
        // 初始化链表
        list_init(&(free_area[i].free_list));
        // 设置空闲块数量为0
        free_area[i].nr_free = 0;
ffffffffc020081e:	0007a823          	sw	zero,16(a5)
ffffffffc0200822:	07e1                	addi	a5,a5,24
    for(int i = 0; i < MAX_ORDER; i++) {
ffffffffc0200824:	fee79be3          	bne	a5,a4,ffffffffc020081a <buddy_system_init+0x10>
    }
}
ffffffffc0200828:	8082                	ret

ffffffffc020082a <split_page>:
        p += order_size;
    }
}

// 取出高一级的空闲链表中的一个块，将其分为两个较小的快，大小是order-1，加入到较低一级的链表中，注意nr_free数量的变化
static void split_page(int order) {
ffffffffc020082a:	7179                	addi	sp,sp,-48
ffffffffc020082c:	ec26                	sd	s1,24(sp)
ffffffffc020082e:	00151493          	slli	s1,a0,0x1
ffffffffc0200832:	e052                	sd	s4,0(sp)
ffffffffc0200834:	00a48a33          	add	s4,s1,a0
ffffffffc0200838:	e44e                	sd	s3,8(sp)
ffffffffc020083a:	0a0e                	slli	s4,s4,0x3
 * list_empty - tests whether a list is empty
 * @list:       the list to test.
 * */
static inline bool
list_empty(list_entry_t *list) {
    return list->next == list;
ffffffffc020083c:	00006997          	auipc	s3,0x6
ffffffffc0200840:	bfc98993          	addi	s3,s3,-1028 # ffffffffc0206438 <free_area>
ffffffffc0200844:	014987b3          	add	a5,s3,s4
ffffffffc0200848:	f022                	sd	s0,32(sp)
ffffffffc020084a:	6780                	ld	s0,8(a5)
ffffffffc020084c:	e84a                	sd	s2,16(sp)
ffffffffc020084e:	f406                	sd	ra,40(sp)
ffffffffc0200850:	892a                	mv	s2,a0
    if(list_empty(&(free_list(order)))) {
ffffffffc0200852:	06f40e63          	beq	s0,a5,ffffffffc02008ce <split_page+0xa4>
    }
    list_entry_t* le = list_next(&(free_list(order)));
    struct Page *page = le2page(le, page_link);
    // 将页面从链表中删除
    list_del(&(page->page_link));
    nr_free(order) -= 1;
ffffffffc0200856:	94ca                	add	s1,s1,s2
    uint32_t n = 1 << (order - 1);
ffffffffc0200858:	4705                	li	a4,1
ffffffffc020085a:	397d                	addiw	s2,s2,-1
ffffffffc020085c:	0127173b          	sllw	a4,a4,s2
    nr_free(order) -= 1;
ffffffffc0200860:	048e                	slli	s1,s1,0x3
    __list_del(listelm->prev, listelm->next);
ffffffffc0200862:	600c                	ld	a1,0(s0)
ffffffffc0200864:	6410                	ld	a2,8(s0)
ffffffffc0200866:	94ce                	add	s1,s1,s3
    struct Page *p = page + n;
ffffffffc0200868:	02071513          	slli	a0,a4,0x20
    nr_free(order) -= 1;
ffffffffc020086c:	4894                	lw	a3,16(s1)
    struct Page *p = page + n;
ffffffffc020086e:	9101                	srli	a0,a0,0x20
ffffffffc0200870:	00251793          	slli	a5,a0,0x2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0200874:	e590                	sd	a2,8(a1)
ffffffffc0200876:	97aa                	add	a5,a5,a0
    next->prev = prev;
ffffffffc0200878:	e20c                	sd	a1,0(a2)
    nr_free(order) -= 1;
ffffffffc020087a:	36fd                	addiw	a3,a3,-1
    struct Page *p = page + n;
ffffffffc020087c:	078e                	slli	a5,a5,0x3
    nr_free(order) -= 1;
ffffffffc020087e:	c894                	sw	a3,16(s1)
    struct Page *p = page + n;
ffffffffc0200880:	17a1                	addi	a5,a5,-24
ffffffffc0200882:	97a2                	add	a5,a5,s0
    page->property = n;
ffffffffc0200884:	fee42c23          	sw	a4,-8(s0)
    p->property = n;
ffffffffc0200888:	cb98                	sw	a4,16(a5)
 *
 * Note that @nr may be almost arbitrarily large; this function is not
 * restricted to acting on a single-word quantity.
 * */
static inline void set_bit(int nr, volatile void *addr) {
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020088a:	00878693          	addi	a3,a5,8
ffffffffc020088e:	4709                	li	a4,2
ffffffffc0200890:	40e6b02f          	amoor.d	zero,a4,(a3)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200894:	00191713          	slli	a4,s2,0x1
ffffffffc0200898:	974a                	add	a4,a4,s2
ffffffffc020089a:	070e                	slli	a4,a4,0x3
ffffffffc020089c:	974e                	add	a4,a4,s3
ffffffffc020089e:	6710                	ld	a2,8(a4)
    SetPageProperty(p);
    // 将两个较小的块加入到较低一级的链表中
    list_add(&(free_list(order-1)),&(page->page_link));
ffffffffc02008a0:	1a21                	addi	s4,s4,-24
    prev->next = next->prev = elm;
ffffffffc02008a2:	e700                	sd	s0,8(a4)
ffffffffc02008a4:	99d2                	add	s3,s3,s4
    elm->prev = prev;
ffffffffc02008a6:	01343023          	sd	s3,0(s0)
    list_add(&(page->page_link),&(p->page_link));
ffffffffc02008aa:	01878593          	addi	a1,a5,24
    nr_free(order-1) += 2;
ffffffffc02008ae:	4b14                	lw	a3,16(a4)
    prev->next = next->prev = elm;
ffffffffc02008b0:	e20c                	sd	a1,0(a2)
ffffffffc02008b2:	e40c                	sd	a1,8(s0)
    elm->prev = prev;
ffffffffc02008b4:	ef80                	sd	s0,24(a5)
    return;
}
ffffffffc02008b6:	70a2                	ld	ra,40(sp)
ffffffffc02008b8:	7402                	ld	s0,32(sp)
    elm->next = next;
ffffffffc02008ba:	f390                	sd	a2,32(a5)
    nr_free(order-1) += 2;
ffffffffc02008bc:	0026879b          	addiw	a5,a3,2
ffffffffc02008c0:	cb1c                	sw	a5,16(a4)
}
ffffffffc02008c2:	64e2                	ld	s1,24(sp)
ffffffffc02008c4:	6942                	ld	s2,16(sp)
ffffffffc02008c6:	69a2                	ld	s3,8(sp)
ffffffffc02008c8:	6a02                	ld	s4,0(sp)
ffffffffc02008ca:	6145                	addi	sp,sp,48
ffffffffc02008cc:	8082                	ret
        split_page(order + 1);
ffffffffc02008ce:	2505                	addiw	a0,a0,1
ffffffffc02008d0:	f5bff0ef          	jal	ra,ffffffffc020082a <split_page>
ffffffffc02008d4:	6400                	ld	s0,8(s0)
ffffffffc02008d6:	b741                	j	ffffffffc0200856 <split_page+0x2c>

ffffffffc02008d8 <add_page>:
    return page;
}

// 先将块按照地址从小到大的顺序加入到指定序号的链表当中
static void add_page(uint32_t order, struct Page* base) {
    if (list_empty(&(free_list(order)))) {
ffffffffc02008d8:	1502                	slli	a0,a0,0x20
ffffffffc02008da:	9101                	srli	a0,a0,0x20
ffffffffc02008dc:	00151713          	slli	a4,a0,0x1
ffffffffc02008e0:	972a                	add	a4,a4,a0
ffffffffc02008e2:	00006797          	auipc	a5,0x6
ffffffffc02008e6:	b5678793          	addi	a5,a5,-1194 # ffffffffc0206438 <free_area>
ffffffffc02008ea:	070e                	slli	a4,a4,0x3
ffffffffc02008ec:	973e                	add	a4,a4,a5
    return list->next == list;
ffffffffc02008ee:	671c                	ld	a5,8(a4)
                // 找到合适的位置插入页面
                list_add_before(le, &(base->page_link));
                break;
            } else if (list_next(le) == &(free_list(order))) {
                // 如果当前页面是链表的最后一个，将页面加入到链表的尾部
                list_add(le, &(base->page_link));
ffffffffc02008f0:	01858613          	addi	a2,a1,24
    if (list_empty(&(free_list(order)))) {
ffffffffc02008f4:	04f70063          	beq	a4,a5,ffffffffc0200934 <add_page+0x5c>
            struct Page* page = le2page(le, page_link);
ffffffffc02008f8:	fe878693          	addi	a3,a5,-24
        while ((le = list_next(le)) != &(free_list(order))) {
ffffffffc02008fc:	00f70c63          	beq	a4,a5,ffffffffc0200914 <add_page+0x3c>
            if (base < page) {
ffffffffc0200900:	02d5e263          	bltu	a1,a3,ffffffffc0200924 <add_page+0x4c>
    return listelm->next;
ffffffffc0200904:	6794                	ld	a3,8(a5)
            } else if (list_next(le) == &(free_list(order))) {
ffffffffc0200906:	00d70863          	beq	a4,a3,ffffffffc0200916 <add_page+0x3e>
static void add_page(uint32_t order, struct Page* base) {
ffffffffc020090a:	87b6                	mv	a5,a3
            struct Page* page = le2page(le, page_link);
ffffffffc020090c:	fe878693          	addi	a3,a5,-24
        while ((le = list_next(le)) != &(free_list(order))) {
ffffffffc0200910:	fef718e3          	bne	a4,a5,ffffffffc0200900 <add_page+0x28>
            }
        }
    }
}
ffffffffc0200914:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0200916:	e310                	sd	a2,0(a4)
ffffffffc0200918:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020091a:	f198                	sd	a4,32(a1)
    elm->prev = prev;
ffffffffc020091c:	6794                	ld	a3,8(a5)
ffffffffc020091e:	ed9c                	sd	a5,24(a1)
static void add_page(uint32_t order, struct Page* base) {
ffffffffc0200920:	87b6                	mv	a5,a3
ffffffffc0200922:	b7ed                	j	ffffffffc020090c <add_page+0x34>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200924:	6398                	ld	a4,0(a5)
                list_add_before(le, &(base->page_link));
ffffffffc0200926:	01858693          	addi	a3,a1,24
    prev->next = next->prev = elm;
ffffffffc020092a:	e394                	sd	a3,0(a5)
ffffffffc020092c:	e714                	sd	a3,8(a4)
    elm->next = next;
ffffffffc020092e:	f19c                	sd	a5,32(a1)
    elm->prev = prev;
ffffffffc0200930:	ed98                	sd	a4,24(a1)
ffffffffc0200932:	8082                	ret
        list_add(&(free_list(order)), &(base->page_link));
ffffffffc0200934:	01858793          	addi	a5,a1,24
    prev->next = next->prev = elm;
ffffffffc0200938:	e31c                	sd	a5,0(a4)
ffffffffc020093a:	e71c                	sd	a5,8(a4)
    elm->next = next;
ffffffffc020093c:	f198                	sd	a4,32(a1)
    elm->prev = prev;
ffffffffc020093e:	ed98                	sd	a4,24(a1)
ffffffffc0200940:	8082                	ret

ffffffffc0200942 <buddy_system_nr_free_pages>:

// 计算空闲页面的数量，空闲块*块大小（与链表序号有关）
static size_t
buddy_system_nr_free_pages(void) {
    size_t num = 0;
    for(int i = 0; i < MAX_ORDER; i++) {
ffffffffc0200942:	00006697          	auipc	a3,0x6
ffffffffc0200946:	b0668693          	addi	a3,a3,-1274 # ffffffffc0206448 <free_area+0x10>
ffffffffc020094a:	4701                	li	a4,0
    size_t num = 0;
ffffffffc020094c:	4501                	li	a0,0
    for(int i = 0; i < MAX_ORDER; i++) {
ffffffffc020094e:	462d                	li	a2,11
        num += nr_free(i) << i;
ffffffffc0200950:	429c                	lw	a5,0(a3)
ffffffffc0200952:	06e1                	addi	a3,a3,24
ffffffffc0200954:	00e797bb          	sllw	a5,a5,a4
ffffffffc0200958:	1782                	slli	a5,a5,0x20
ffffffffc020095a:	9381                	srli	a5,a5,0x20
    for(int i = 0; i < MAX_ORDER; i++) {
ffffffffc020095c:	2705                	addiw	a4,a4,1
        num += nr_free(i) << i;
ffffffffc020095e:	953e                	add	a0,a0,a5
    for(int i = 0; i < MAX_ORDER; i++) {
ffffffffc0200960:	fec718e3          	bne	a4,a2,ffffffffc0200950 <buddy_system_nr_free_pages+0xe>
    }
    return num;
}
ffffffffc0200964:	8082                	ret

ffffffffc0200966 <buddy_system_check>:
    free_page(p2);
}

// 预算系统的检查函数，目前为空
static void
buddy_system_check(void) {}
ffffffffc0200966:	8082                	ret

ffffffffc0200968 <buddy_system_free_pages>:
buddy_system_free_pages(struct Page *base, size_t n) {
ffffffffc0200968:	7139                	addi	sp,sp,-64
ffffffffc020096a:	fc06                	sd	ra,56(sp)
ffffffffc020096c:	f822                	sd	s0,48(sp)
ffffffffc020096e:	f426                	sd	s1,40(sp)
ffffffffc0200970:	f04a                	sd	s2,32(sp)
ffffffffc0200972:	ec4e                	sd	s3,24(sp)
ffffffffc0200974:	e852                	sd	s4,16(sp)
ffffffffc0200976:	e456                	sd	s5,8(sp)
    assert(n > 0);
ffffffffc0200978:	1a058663          	beqz	a1,ffffffffc0200b24 <buddy_system_free_pages+0x1bc>
    assert(IS_POWER_OF_2(n));
ffffffffc020097c:	fff58793          	addi	a5,a1,-1
ffffffffc0200980:	8fed                	and	a5,a5,a1
ffffffffc0200982:	18079163          	bnez	a5,ffffffffc0200b04 <buddy_system_free_pages+0x19c>
    assert(n < (1 << (MAX_ORDER - 1)));
ffffffffc0200986:	3ff00793          	li	a5,1023
ffffffffc020098a:	1ab7ed63          	bltu	a5,a1,ffffffffc0200b44 <buddy_system_free_pages+0x1dc>
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020098e:	651c                	ld	a5,8(a0)
    for (; p != base + n; p ++) {
ffffffffc0200990:	00259693          	slli	a3,a1,0x2
ffffffffc0200994:	96ae                	add	a3,a3,a1
ffffffffc0200996:	068e                	slli	a3,a3,0x3
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200998:	8b85                	andi	a5,a5,1
ffffffffc020099a:	892a                	mv	s2,a0
    for (; p != base + n; p ++) {
ffffffffc020099c:	96aa                	add	a3,a3,a0
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020099e:	14079363          	bnez	a5,ffffffffc0200ae4 <buddy_system_free_pages+0x17c>
ffffffffc02009a2:	651c                	ld	a5,8(a0)
ffffffffc02009a4:	8385                	srli	a5,a5,0x1
ffffffffc02009a6:	8b85                	andi	a5,a5,1
ffffffffc02009a8:	12079e63          	bnez	a5,ffffffffc0200ae4 <buddy_system_free_pages+0x17c>
ffffffffc02009ac:	87aa                	mv	a5,a0
ffffffffc02009ae:	a809                	j	ffffffffc02009c0 <buddy_system_free_pages+0x58>
ffffffffc02009b0:	6798                	ld	a4,8(a5)
ffffffffc02009b2:	8b05                	andi	a4,a4,1
ffffffffc02009b4:	12071863          	bnez	a4,ffffffffc0200ae4 <buddy_system_free_pages+0x17c>
ffffffffc02009b8:	6798                	ld	a4,8(a5)
ffffffffc02009ba:	8b09                	andi	a4,a4,2
ffffffffc02009bc:	12071463          	bnez	a4,ffffffffc0200ae4 <buddy_system_free_pages+0x17c>
        p->flags = 0;
ffffffffc02009c0:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02009c4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02009c8:	02878793          	addi	a5,a5,40
ffffffffc02009cc:	fed792e3          	bne	a5,a3,ffffffffc02009b0 <buddy_system_free_pages+0x48>
    base->property = n;
ffffffffc02009d0:	00b92823          	sw	a1,16(s2)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02009d4:	4789                	li	a5,2
ffffffffc02009d6:	00890713          	addi	a4,s2,8
ffffffffc02009da:	40f7302f          	amoor.d	zero,a5,(a4)
    while (temp != 1) {//找到能将此内存块放入的链表序号，根据幂次方的大小对序号进行加法运算，直到确定序号
ffffffffc02009de:	4785                	li	a5,1
ffffffffc02009e0:	0ef58c63          	beq	a1,a5,ffffffffc0200ad8 <buddy_system_free_pages+0x170>
    uint32_t order = 0;
ffffffffc02009e4:	4481                	li	s1,0
        temp >>= 1;
ffffffffc02009e6:	8185                	srli	a1,a1,0x1
        order++;
ffffffffc02009e8:	2485                	addiw	s1,s1,1
    while (temp != 1) {//找到能将此内存块放入的链表序号，根据幂次方的大小对序号进行加法运算，直到确定序号
ffffffffc02009ea:	fef59ee3          	bne	a1,a5,ffffffffc02009e6 <buddy_system_free_pages+0x7e>
    add_page(order,base);
ffffffffc02009ee:	85ca                	mv	a1,s2
ffffffffc02009f0:	8526                	mv	a0,s1
ffffffffc02009f2:	ee7ff0ef          	jal	ra,ffffffffc02008d8 <add_page>
    if (order == MAX_ORDER - 1) {//没有更大的内存块了，升不了级了
ffffffffc02009f6:	47a9                	li	a5,10
ffffffffc02009f8:	06f48763          	beq	s1,a5,ffffffffc0200a66 <buddy_system_free_pages+0xfe>
ffffffffc02009fc:	00006a97          	auipc	s5,0x6
ffffffffc0200a00:	a3ca8a93          	addi	s5,s5,-1476 # ffffffffc0206438 <free_area>
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0200a04:	59f5                	li	s3,-3
ffffffffc0200a06:	4a29                	li	s4,10
    if (le != &(free_list(order))) {
ffffffffc0200a08:	02049793          	slli	a5,s1,0x20
ffffffffc0200a0c:	9381                	srli	a5,a5,0x20
ffffffffc0200a0e:	00179413          	slli	s0,a5,0x1
ffffffffc0200a12:	943e                	add	s0,s0,a5
    return listelm->prev;
ffffffffc0200a14:	01893703          	ld	a4,24(s2)
ffffffffc0200a18:	040e                	slli	s0,s0,0x3
ffffffffc0200a1a:	9456                	add	s0,s0,s5
ffffffffc0200a1c:	2485                	addiw	s1,s1,1
ffffffffc0200a1e:	02870063          	beq	a4,s0,ffffffffc0200a3e <buddy_system_free_pages+0xd6>
        if (p + p->property == base) {//若是连续内存
ffffffffc0200a22:	ff872603          	lw	a2,-8(a4)
        struct Page *p = le2page(le, page_link);
ffffffffc0200a26:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base) {//若是连续内存
ffffffffc0200a2a:	02061693          	slli	a3,a2,0x20
ffffffffc0200a2e:	9281                	srli	a3,a3,0x20
ffffffffc0200a30:	00269793          	slli	a5,a3,0x2
ffffffffc0200a34:	97b6                	add	a5,a5,a3
ffffffffc0200a36:	078e                	slli	a5,a5,0x3
ffffffffc0200a38:	97ae                	add	a5,a5,a1
ffffffffc0200a3a:	06f90963          	beq	s2,a5,ffffffffc0200aac <buddy_system_free_pages+0x144>
    return listelm->next;
ffffffffc0200a3e:	02093703          	ld	a4,32(s2)
    if (le != &(free_list(order))) {
ffffffffc0200a42:	02e40063          	beq	s0,a4,ffffffffc0200a62 <buddy_system_free_pages+0xfa>
        if (base + base->property == p) {
ffffffffc0200a46:	01092583          	lw	a1,16(s2)
        struct Page *p = le2page(le, page_link);
ffffffffc0200a4a:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc0200a4e:	02059613          	slli	a2,a1,0x20
ffffffffc0200a52:	9201                	srli	a2,a2,0x20
ffffffffc0200a54:	00261793          	slli	a5,a2,0x2
ffffffffc0200a58:	97b2                	add	a5,a5,a2
ffffffffc0200a5a:	078e                	slli	a5,a5,0x3
ffffffffc0200a5c:	97ca                	add	a5,a5,s2
ffffffffc0200a5e:	00f68d63          	beq	a3,a5,ffffffffc0200a78 <buddy_system_free_pages+0x110>
    if (order == MAX_ORDER - 1) {//没有更大的内存块了，升不了级了
ffffffffc0200a62:	fb4493e3          	bne	s1,s4,ffffffffc0200a08 <buddy_system_free_pages+0xa0>
}
ffffffffc0200a66:	70e2                	ld	ra,56(sp)
ffffffffc0200a68:	7442                	ld	s0,48(sp)
ffffffffc0200a6a:	74a2                	ld	s1,40(sp)
ffffffffc0200a6c:	7902                	ld	s2,32(sp)
ffffffffc0200a6e:	69e2                	ld	s3,24(sp)
ffffffffc0200a70:	6a42                	ld	s4,16(sp)
ffffffffc0200a72:	6aa2                	ld	s5,8(sp)
ffffffffc0200a74:	6121                	addi	sp,sp,64
ffffffffc0200a76:	8082                	ret
            base->property += p->property;
ffffffffc0200a78:	ff872783          	lw	a5,-8(a4)
ffffffffc0200a7c:	9dbd                	addw	a1,a1,a5
ffffffffc0200a7e:	00b92823          	sw	a1,16(s2)
ffffffffc0200a82:	ff070793          	addi	a5,a4,-16
ffffffffc0200a86:	6137b02f          	amoand.d	zero,s3,(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200a8a:	671c                	ld	a5,8(a4)
ffffffffc0200a8c:	6314                	ld	a3,0(a4)
                add_page(order+1,base);
ffffffffc0200a8e:	85ca                	mv	a1,s2
ffffffffc0200a90:	8526                	mv	a0,s1
    prev->next = next;
ffffffffc0200a92:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0200a94:	e394                	sd	a3,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200a96:	01893703          	ld	a4,24(s2)
ffffffffc0200a9a:	02093783          	ld	a5,32(s2)
    prev->next = next;
ffffffffc0200a9e:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200aa0:	e398                	sd	a4,0(a5)
ffffffffc0200aa2:	e37ff0ef          	jal	ra,ffffffffc02008d8 <add_page>
    if (order == MAX_ORDER - 1) {//没有更大的内存块了，升不了级了
ffffffffc0200aa6:	f74491e3          	bne	s1,s4,ffffffffc0200a08 <buddy_system_free_pages+0xa0>
ffffffffc0200aaa:	bf75                	j	ffffffffc0200a66 <buddy_system_free_pages+0xfe>
            p->property += base->property;
ffffffffc0200aac:	01092783          	lw	a5,16(s2)
ffffffffc0200ab0:	9e3d                	addw	a2,a2,a5
ffffffffc0200ab2:	fec72c23          	sw	a2,-8(a4)
ffffffffc0200ab6:	00890793          	addi	a5,s2,8
ffffffffc0200aba:	6137b02f          	amoand.d	zero,s3,(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200abe:	02093783          	ld	a5,32(s2)
                add_page(order+1,base);
ffffffffc0200ac2:	8526                	mv	a0,s1
            base = p;
ffffffffc0200ac4:	892e                	mv	s2,a1
    prev->next = next;
ffffffffc0200ac6:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200ac8:	e398                	sd	a4,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200aca:	6314                	ld	a3,0(a4)
ffffffffc0200acc:	671c                	ld	a5,8(a4)
    prev->next = next;
ffffffffc0200ace:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0200ad0:	e394                	sd	a3,0(a5)
                add_page(order+1,base);
ffffffffc0200ad2:	e07ff0ef          	jal	ra,ffffffffc02008d8 <add_page>
ffffffffc0200ad6:	b7a5                	j	ffffffffc0200a3e <buddy_system_free_pages+0xd6>
    add_page(order,base);
ffffffffc0200ad8:	85ca                	mv	a1,s2
ffffffffc0200ada:	4501                	li	a0,0
ffffffffc0200adc:	dfdff0ef          	jal	ra,ffffffffc02008d8 <add_page>
    uint32_t order = 0;
ffffffffc0200ae0:	4481                	li	s1,0
ffffffffc0200ae2:	bf29                	j	ffffffffc02009fc <buddy_system_free_pages+0x94>
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0200ae4:	00001697          	auipc	a3,0x1
ffffffffc0200ae8:	12468693          	addi	a3,a3,292 # ffffffffc0201c08 <commands+0x688>
ffffffffc0200aec:	00001617          	auipc	a2,0x1
ffffffffc0200af0:	0cc60613          	addi	a2,a2,204 # ffffffffc0201bb8 <commands+0x638>
ffffffffc0200af4:	0be00593          	li	a1,190
ffffffffc0200af8:	00001517          	auipc	a0,0x1
ffffffffc0200afc:	0d850513          	addi	a0,a0,216 # ffffffffc0201bd0 <commands+0x650>
ffffffffc0200b00:	8a9ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(IS_POWER_OF_2(n));
ffffffffc0200b04:	00001697          	auipc	a3,0x1
ffffffffc0200b08:	0ec68693          	addi	a3,a3,236 # ffffffffc0201bf0 <commands+0x670>
ffffffffc0200b0c:	00001617          	auipc	a2,0x1
ffffffffc0200b10:	0ac60613          	addi	a2,a2,172 # ffffffffc0201bb8 <commands+0x638>
ffffffffc0200b14:	0b900593          	li	a1,185
ffffffffc0200b18:	00001517          	auipc	a0,0x1
ffffffffc0200b1c:	0b850513          	addi	a0,a0,184 # ffffffffc0201bd0 <commands+0x650>
ffffffffc0200b20:	889ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(n > 0);
ffffffffc0200b24:	00001697          	auipc	a3,0x1
ffffffffc0200b28:	08c68693          	addi	a3,a3,140 # ffffffffc0201bb0 <commands+0x630>
ffffffffc0200b2c:	00001617          	auipc	a2,0x1
ffffffffc0200b30:	08c60613          	addi	a2,a2,140 # ffffffffc0201bb8 <commands+0x638>
ffffffffc0200b34:	0b800593          	li	a1,184
ffffffffc0200b38:	00001517          	auipc	a0,0x1
ffffffffc0200b3c:	09850513          	addi	a0,a0,152 # ffffffffc0201bd0 <commands+0x650>
ffffffffc0200b40:	869ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(n < (1 << (MAX_ORDER - 1)));
ffffffffc0200b44:	00001697          	auipc	a3,0x1
ffffffffc0200b48:	0ec68693          	addi	a3,a3,236 # ffffffffc0201c30 <commands+0x6b0>
ffffffffc0200b4c:	00001617          	auipc	a2,0x1
ffffffffc0200b50:	06c60613          	addi	a2,a2,108 # ffffffffc0201bb8 <commands+0x638>
ffffffffc0200b54:	0ba00593          	li	a1,186
ffffffffc0200b58:	00001517          	auipc	a0,0x1
ffffffffc0200b5c:	07850513          	addi	a0,a0,120 # ffffffffc0201bd0 <commands+0x650>
ffffffffc0200b60:	849ff0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc0200b64 <buddy_system_alloc_pages>:
buddy_system_alloc_pages(size_t n) {
ffffffffc0200b64:	1101                	addi	sp,sp,-32
ffffffffc0200b66:	ec06                	sd	ra,24(sp)
ffffffffc0200b68:	e822                	sd	s0,16(sp)
ffffffffc0200b6a:	e426                	sd	s1,8(sp)
    assert(n > 0);
ffffffffc0200b6c:	c95d                	beqz	a0,ffffffffc0200c22 <buddy_system_alloc_pages+0xbe>
    while (n < (1 << order)) {
ffffffffc0200b6e:	3ff00793          	li	a5,1023
    uint32_t order = MAX_ORDER - 1;
ffffffffc0200b72:	4729                	li	a4,10
    while (n < (1 << order)) {
ffffffffc0200b74:	4605                	li	a2,1
ffffffffc0200b76:	00a7f463          	bgeu	a5,a0,ffffffffc0200b7e <buddy_system_alloc_pages+0x1a>
ffffffffc0200b7a:	a871                	j	ffffffffc0200c16 <buddy_system_alloc_pages+0xb2>
        order -= 1;
ffffffffc0200b7c:	873e                	mv	a4,a5
ffffffffc0200b7e:	fff7079b          	addiw	a5,a4,-1
    while (n < (1 << order)) {
ffffffffc0200b82:	00f616bb          	sllw	a3,a2,a5
ffffffffc0200b86:	fed56be3          	bltu	a0,a3,ffffffffc0200b7c <buddy_system_alloc_pages+0x18>
    for (int i = order; i < MAX_ORDER; i++) flag += nr_free(i);
ffffffffc0200b8a:	0007061b          	sext.w	a2,a4
ffffffffc0200b8e:	47a9                	li	a5,10
ffffffffc0200b90:	08c7c363          	blt	a5,a2,ffffffffc0200c16 <buddy_system_alloc_pages+0xb2>
ffffffffc0200b94:	45a9                	li	a1,10
ffffffffc0200b96:	9d99                	subw	a1,a1,a4
ffffffffc0200b98:	1582                	slli	a1,a1,0x20
ffffffffc0200b9a:	9181                	srli	a1,a1,0x20
ffffffffc0200b9c:	00c586b3          	add	a3,a1,a2
ffffffffc0200ba0:	00169593          	slli	a1,a3,0x1
ffffffffc0200ba4:	00161793          	slli	a5,a2,0x1
ffffffffc0200ba8:	95b6                	add	a1,a1,a3
ffffffffc0200baa:	97b2                	add	a5,a5,a2
ffffffffc0200bac:	00006697          	auipc	a3,0x6
ffffffffc0200bb0:	8a468693          	addi	a3,a3,-1884 # ffffffffc0206450 <free_area+0x18>
ffffffffc0200bb4:	078e                	slli	a5,a5,0x3
ffffffffc0200bb6:	00006497          	auipc	s1,0x6
ffffffffc0200bba:	88248493          	addi	s1,s1,-1918 # ffffffffc0206438 <free_area>
ffffffffc0200bbe:	058e                	slli	a1,a1,0x3
ffffffffc0200bc0:	95b6                	add	a1,a1,a3
ffffffffc0200bc2:	97a6                	add	a5,a5,s1
    uint32_t flag = 0;
ffffffffc0200bc4:	4681                	li	a3,0
    for (int i = order; i < MAX_ORDER; i++) flag += nr_free(i);
ffffffffc0200bc6:	4b90                	lw	a2,16(a5)
ffffffffc0200bc8:	07e1                	addi	a5,a5,24
ffffffffc0200bca:	9eb1                	addw	a3,a3,a2
ffffffffc0200bcc:	feb79de3          	bne	a5,a1,ffffffffc0200bc6 <buddy_system_alloc_pages+0x62>
    if(flag == 0) return NULL;
ffffffffc0200bd0:	c2b9                	beqz	a3,ffffffffc0200c16 <buddy_system_alloc_pages+0xb2>
    if(list_empty(&(free_list(order)))) {
ffffffffc0200bd2:	02071693          	slli	a3,a4,0x20
ffffffffc0200bd6:	9281                	srli	a3,a3,0x20
ffffffffc0200bd8:	00169793          	slli	a5,a3,0x1
ffffffffc0200bdc:	97b6                	add	a5,a5,a3
ffffffffc0200bde:	078e                	slli	a5,a5,0x3
ffffffffc0200be0:	94be                	add	s1,s1,a5
    return list->next == list;
ffffffffc0200be2:	6480                	ld	s0,8(s1)
ffffffffc0200be4:	02848263          	beq	s1,s0,ffffffffc0200c08 <buddy_system_alloc_pages+0xa4>
    __list_del(listelm->prev, listelm->next);
ffffffffc0200be8:	6018                	ld	a4,0(s0)
ffffffffc0200bea:	641c                	ld	a5,8(s0)
    page = le2page(le, page_link);
ffffffffc0200bec:	fe840513          	addi	a0,s0,-24
    prev->next = next;
ffffffffc0200bf0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0200bf2:	e398                	sd	a4,0(a5)
ffffffffc0200bf4:	57f5                	li	a5,-3
ffffffffc0200bf6:	ff040713          	addi	a4,s0,-16
ffffffffc0200bfa:	60f7302f          	amoand.d	zero,a5,(a4)
}
ffffffffc0200bfe:	60e2                	ld	ra,24(sp)
ffffffffc0200c00:	6442                	ld	s0,16(sp)
ffffffffc0200c02:	64a2                	ld	s1,8(sp)
ffffffffc0200c04:	6105                	addi	sp,sp,32
ffffffffc0200c06:	8082                	ret
        split_page(order + 1);
ffffffffc0200c08:	0017051b          	addiw	a0,a4,1
ffffffffc0200c0c:	c1fff0ef          	jal	ra,ffffffffc020082a <split_page>
    return list->next == list;
ffffffffc0200c10:	6400                	ld	s0,8(s0)
    if(list_empty(&(free_list(order)))) return NULL;
ffffffffc0200c12:	fc849be3          	bne	s1,s0,ffffffffc0200be8 <buddy_system_alloc_pages+0x84>
}
ffffffffc0200c16:	60e2                	ld	ra,24(sp)
ffffffffc0200c18:	6442                	ld	s0,16(sp)
ffffffffc0200c1a:	64a2                	ld	s1,8(sp)
    if(flag == 0) return NULL;
ffffffffc0200c1c:	4501                	li	a0,0
}
ffffffffc0200c1e:	6105                	addi	sp,sp,32
ffffffffc0200c20:	8082                	ret
    assert(n > 0);
ffffffffc0200c22:	00001697          	auipc	a3,0x1
ffffffffc0200c26:	f8e68693          	addi	a3,a3,-114 # ffffffffc0201bb0 <commands+0x630>
ffffffffc0200c2a:	00001617          	auipc	a2,0x1
ffffffffc0200c2e:	f8e60613          	addi	a2,a2,-114 # ffffffffc0201bb8 <commands+0x638>
ffffffffc0200c32:	05e00593          	li	a1,94
ffffffffc0200c36:	00001517          	auipc	a0,0x1
ffffffffc0200c3a:	f9a50513          	addi	a0,a0,-102 # ffffffffc0201bd0 <commands+0x650>
ffffffffc0200c3e:	f6aff0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc0200c42 <buddy_system_init_memmap>:
buddy_system_init_memmap(struct Page *base, size_t n) {
ffffffffc0200c42:	1141                	addi	sp,sp,-16
ffffffffc0200c44:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200c46:	c5f1                	beqz	a1,ffffffffc0200d12 <buddy_system_init_memmap+0xd0>
    for (; p != base + n; p ++) {
ffffffffc0200c48:	00259693          	slli	a3,a1,0x2
ffffffffc0200c4c:	96ae                	add	a3,a3,a1
ffffffffc0200c4e:	068e                	slli	a3,a3,0x3
ffffffffc0200c50:	96aa                	add	a3,a3,a0
ffffffffc0200c52:	02d50463          	beq	a0,a3,ffffffffc0200c7a <buddy_system_init_memmap+0x38>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200c56:	6518                	ld	a4,8(a0)
        assert(PageReserved(p));
ffffffffc0200c58:	87aa                	mv	a5,a0
ffffffffc0200c5a:	8b05                	andi	a4,a4,1
ffffffffc0200c5c:	e709                	bnez	a4,ffffffffc0200c66 <buddy_system_init_memmap+0x24>
ffffffffc0200c5e:	a851                	j	ffffffffc0200cf2 <buddy_system_init_memmap+0xb0>
ffffffffc0200c60:	6798                	ld	a4,8(a5)
ffffffffc0200c62:	8b05                	andi	a4,a4,1
ffffffffc0200c64:	c759                	beqz	a4,ffffffffc0200cf2 <buddy_system_init_memmap+0xb0>
        p->flags = p->property = 0;
ffffffffc0200c66:	0007a823          	sw	zero,16(a5)
ffffffffc0200c6a:	0007b423          	sd	zero,8(a5)
ffffffffc0200c6e:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0200c72:	02878793          	addi	a5,a5,40
ffffffffc0200c76:	fed795e3          	bne	a5,a3,ffffffffc0200c60 <buddy_system_init_memmap+0x1e>
    uint32_t order = MAX_ORDER - 1;
ffffffffc0200c7a:	4729                	li	a4,10
    uint32_t order_size = 1 << order;
ffffffffc0200c7c:	40000693          	li	a3,1024
ffffffffc0200c80:	00005e17          	auipc	t3,0x5
ffffffffc0200c84:	7b8e0e13          	addi	t3,t3,1976 # ffffffffc0206438 <free_area>
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0200c88:	4309                	li	t1,2
        p->property = order_size;
ffffffffc0200c8a:	c914                	sw	a3,16(a0)
ffffffffc0200c8c:	00850793          	addi	a5,a0,8
ffffffffc0200c90:	4067b02f          	amoor.d	zero,t1,(a5)
        nr_free(order) += 1;
ffffffffc0200c94:	02071793          	slli	a5,a4,0x20
ffffffffc0200c98:	9381                	srli	a5,a5,0x20
ffffffffc0200c9a:	00179613          	slli	a2,a5,0x1
ffffffffc0200c9e:	963e                	add	a2,a2,a5
ffffffffc0200ca0:	060e                	slli	a2,a2,0x3
ffffffffc0200ca2:	9672                	add	a2,a2,t3
ffffffffc0200ca4:	01062803          	lw	a6,16(a2)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0200ca8:	00063883          	ld	a7,0(a2)
        list_add_before(&(free_list(order)), &(p->page_link));
ffffffffc0200cac:	01850793          	addi	a5,a0,24
        nr_free(order) += 1;
ffffffffc0200cb0:	2805                	addiw	a6,a6,1
    prev->next = next->prev = elm;
ffffffffc0200cb2:	e21c                	sd	a5,0(a2)
ffffffffc0200cb4:	01062823          	sw	a6,16(a2)
ffffffffc0200cb8:	00f8b423          	sd	a5,8(a7)
        curr_size -= order_size;
ffffffffc0200cbc:	02069793          	slli	a5,a3,0x20
ffffffffc0200cc0:	9381                	srli	a5,a5,0x20
    elm->next = next;
ffffffffc0200cc2:	f110                	sd	a2,32(a0)
    elm->prev = prev;
ffffffffc0200cc4:	01153c23          	sd	a7,24(a0)
ffffffffc0200cc8:	8d9d                	sub	a1,a1,a5
        while(order > 0 && curr_size < order_size) {
ffffffffc0200cca:	cb19                	beqz	a4,ffffffffc0200ce0 <buddy_system_init_memmap+0x9e>
ffffffffc0200ccc:	00f5fa63          	bgeu	a1,a5,ffffffffc0200ce0 <buddy_system_init_memmap+0x9e>
            order_size >>= 1;
ffffffffc0200cd0:	0016d79b          	srliw	a5,a3,0x1
ffffffffc0200cd4:	0007869b          	sext.w	a3,a5
            order -= 1;
ffffffffc0200cd8:	377d                	addiw	a4,a4,-1
ffffffffc0200cda:	1782                	slli	a5,a5,0x20
ffffffffc0200cdc:	9381                	srli	a5,a5,0x20
        while(order > 0 && curr_size < order_size) {
ffffffffc0200cde:	f77d                	bnez	a4,ffffffffc0200ccc <buddy_system_init_memmap+0x8a>
        p += order_size;
ffffffffc0200ce0:	00279613          	slli	a2,a5,0x2
ffffffffc0200ce4:	97b2                	add	a5,a5,a2
ffffffffc0200ce6:	078e                	slli	a5,a5,0x3
ffffffffc0200ce8:	953e                	add	a0,a0,a5
    while (curr_size != 0) {
ffffffffc0200cea:	f1c5                	bnez	a1,ffffffffc0200c8a <buddy_system_init_memmap+0x48>
}
ffffffffc0200cec:	60a2                	ld	ra,8(sp)
ffffffffc0200cee:	0141                	addi	sp,sp,16
ffffffffc0200cf0:	8082                	ret
        assert(PageReserved(p));
ffffffffc0200cf2:	00001697          	auipc	a3,0x1
ffffffffc0200cf6:	f5e68693          	addi	a3,a3,-162 # ffffffffc0201c50 <commands+0x6d0>
ffffffffc0200cfa:	00001617          	auipc	a2,0x1
ffffffffc0200cfe:	ebe60613          	addi	a2,a2,-322 # ffffffffc0201bb8 <commands+0x638>
ffffffffc0200d02:	02800593          	li	a1,40
ffffffffc0200d06:	00001517          	auipc	a0,0x1
ffffffffc0200d0a:	eca50513          	addi	a0,a0,-310 # ffffffffc0201bd0 <commands+0x650>
ffffffffc0200d0e:	e9aff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    assert(n > 0);
ffffffffc0200d12:	00001697          	auipc	a3,0x1
ffffffffc0200d16:	e9e68693          	addi	a3,a3,-354 # ffffffffc0201bb0 <commands+0x630>
ffffffffc0200d1a:	00001617          	auipc	a2,0x1
ffffffffc0200d1e:	e9e60613          	addi	a2,a2,-354 # ffffffffc0201bb8 <commands+0x638>
ffffffffc0200d22:	02300593          	li	a1,35
ffffffffc0200d26:	00001517          	auipc	a0,0x1
ffffffffc0200d2a:	eaa50513          	addi	a0,a0,-342 # ffffffffc0201bd0 <commands+0x650>
ffffffffc0200d2e:	e7aff0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc0200d32 <pmm_init>:
static void check_alloc_page(void);

// init_pmm_manager - initialize a pmm_manager instance
static void init_pmm_manager(void) {
    //pmm_manager = &best_fit_pmm_manager;
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200d32:	00001797          	auipc	a5,0x1
ffffffffc0200d36:	f2e78793          	addi	a5,a5,-210 # ffffffffc0201c60 <buddy_system_pmm_manager>
    //pmm_manager = &default_pmm_manager;
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200d3a:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc0200d3c:	1101                	addi	sp,sp,-32
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200d3e:	00001517          	auipc	a0,0x1
ffffffffc0200d42:	f7a50513          	addi	a0,a0,-134 # ffffffffc0201cb8 <buddy_system_pmm_manager+0x58>
void pmm_init(void) {
ffffffffc0200d46:	ec06                	sd	ra,24(sp)
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200d48:	00006717          	auipc	a4,0x6
ffffffffc0200d4c:	80f73023          	sd	a5,-2048(a4) # ffffffffc0206548 <pmm_manager>
void pmm_init(void) {
ffffffffc0200d50:	e822                	sd	s0,16(sp)
ffffffffc0200d52:	e426                	sd	s1,8(sp)
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0200d54:	00005417          	auipc	s0,0x5
ffffffffc0200d58:	7f440413          	addi	s0,s0,2036 # ffffffffc0206548 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0200d5c:	b5aff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pmm_manager->init();
ffffffffc0200d60:	601c                	ld	a5,0(s0)
ffffffffc0200d62:	679c                	ld	a5,8(a5)
ffffffffc0200d64:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200d66:	57f5                	li	a5,-3
ffffffffc0200d68:	07fa                	slli	a5,a5,0x1e
    cprintf("physcial memory map:\n");
ffffffffc0200d6a:	00001517          	auipc	a0,0x1
ffffffffc0200d6e:	f6650513          	addi	a0,a0,-154 # ffffffffc0201cd0 <buddy_system_pmm_manager+0x70>
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0200d72:	00005717          	auipc	a4,0x5
ffffffffc0200d76:	7cf73f23          	sd	a5,2014(a4) # ffffffffc0206550 <va_pa_offset>
    cprintf("physcial memory map:\n");
ffffffffc0200d7a:	b3cff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0200d7e:	46c5                	li	a3,17
ffffffffc0200d80:	06ee                	slli	a3,a3,0x1b
ffffffffc0200d82:	40100613          	li	a2,1025
ffffffffc0200d86:	16fd                	addi	a3,a3,-1
ffffffffc0200d88:	0656                	slli	a2,a2,0x15
ffffffffc0200d8a:	07e005b7          	lui	a1,0x7e00
ffffffffc0200d8e:	00001517          	auipc	a0,0x1
ffffffffc0200d92:	f5a50513          	addi	a0,a0,-166 # ffffffffc0201ce8 <buddy_system_pmm_manager+0x88>
ffffffffc0200d96:	b20ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200d9a:	777d                	lui	a4,0xfffff
ffffffffc0200d9c:	00006797          	auipc	a5,0x6
ffffffffc0200da0:	7c378793          	addi	a5,a5,1987 # ffffffffc020755f <end+0xfff>
ffffffffc0200da4:	8ff9                	and	a5,a5,a4
    npage = maxpa / PGSIZE;
ffffffffc0200da6:	00088737          	lui	a4,0x88
ffffffffc0200daa:	00005697          	auipc	a3,0x5
ffffffffc0200dae:	66e6b723          	sd	a4,1646(a3) # ffffffffc0206418 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0200db2:	4601                	li	a2,0
ffffffffc0200db4:	00005717          	auipc	a4,0x5
ffffffffc0200db8:	7af73223          	sd	a5,1956(a4) # ffffffffc0206558 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200dbc:	4681                	li	a3,0
ffffffffc0200dbe:	00005897          	auipc	a7,0x5
ffffffffc0200dc2:	65a88893          	addi	a7,a7,1626 # ffffffffc0206418 <npage>
ffffffffc0200dc6:	00005597          	auipc	a1,0x5
ffffffffc0200dca:	79258593          	addi	a1,a1,1938 # ffffffffc0206558 <pages>
ffffffffc0200dce:	4805                	li	a6,1
ffffffffc0200dd0:	fff80537          	lui	a0,0xfff80
ffffffffc0200dd4:	a011                	j	ffffffffc0200dd8 <pmm_init+0xa6>
ffffffffc0200dd6:	619c                	ld	a5,0(a1)
        SetPageReserved(pages + i);
ffffffffc0200dd8:	97b2                	add	a5,a5,a2
ffffffffc0200dda:	07a1                	addi	a5,a5,8
ffffffffc0200ddc:	4107b02f          	amoor.d	zero,a6,(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0200de0:	0008b703          	ld	a4,0(a7)
ffffffffc0200de4:	0685                	addi	a3,a3,1
ffffffffc0200de6:	02860613          	addi	a2,a2,40
ffffffffc0200dea:	00a707b3          	add	a5,a4,a0
ffffffffc0200dee:	fef6e4e3          	bltu	a3,a5,ffffffffc0200dd6 <pmm_init+0xa4>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200df2:	6190                	ld	a2,0(a1)
ffffffffc0200df4:	00271793          	slli	a5,a4,0x2
ffffffffc0200df8:	97ba                	add	a5,a5,a4
ffffffffc0200dfa:	fec006b7          	lui	a3,0xfec00
ffffffffc0200dfe:	078e                	slli	a5,a5,0x3
ffffffffc0200e00:	96b2                	add	a3,a3,a2
ffffffffc0200e02:	96be                	add	a3,a3,a5
ffffffffc0200e04:	c02007b7          	lui	a5,0xc0200
ffffffffc0200e08:	08f6e863          	bltu	a3,a5,ffffffffc0200e98 <pmm_init+0x166>
ffffffffc0200e0c:	00005497          	auipc	s1,0x5
ffffffffc0200e10:	74448493          	addi	s1,s1,1860 # ffffffffc0206550 <va_pa_offset>
ffffffffc0200e14:	609c                	ld	a5,0(s1)
    if (freemem < mem_end) {
ffffffffc0200e16:	45c5                	li	a1,17
ffffffffc0200e18:	05ee                	slli	a1,a1,0x1b
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200e1a:	8e9d                	sub	a3,a3,a5
    if (freemem < mem_end) {
ffffffffc0200e1c:	04b6e963          	bltu	a3,a1,ffffffffc0200e6e <pmm_init+0x13c>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0200e20:	601c                	ld	a5,0(s0)
ffffffffc0200e22:	7b9c                	ld	a5,48(a5)
ffffffffc0200e24:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0200e26:	00001517          	auipc	a0,0x1
ffffffffc0200e2a:	f5a50513          	addi	a0,a0,-166 # ffffffffc0201d80 <buddy_system_pmm_manager+0x120>
ffffffffc0200e2e:	a88ff0ef          	jal	ra,ffffffffc02000b6 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0200e32:	00004697          	auipc	a3,0x4
ffffffffc0200e36:	1ce68693          	addi	a3,a3,462 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0200e3a:	00005797          	auipc	a5,0x5
ffffffffc0200e3e:	5ed7b323          	sd	a3,1510(a5) # ffffffffc0206420 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200e42:	c02007b7          	lui	a5,0xc0200
ffffffffc0200e46:	06f6e563          	bltu	a3,a5,ffffffffc0200eb0 <pmm_init+0x17e>
ffffffffc0200e4a:	609c                	ld	a5,0(s1)
}
ffffffffc0200e4c:	6442                	ld	s0,16(sp)
ffffffffc0200e4e:	60e2                	ld	ra,24(sp)
ffffffffc0200e50:	64a2                	ld	s1,8(sp)
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200e52:	85b6                	mv	a1,a3
    satp_physical = PADDR(satp_virtual);
ffffffffc0200e54:	8e9d                	sub	a3,a3,a5
ffffffffc0200e56:	00005797          	auipc	a5,0x5
ffffffffc0200e5a:	6ed7b523          	sd	a3,1770(a5) # ffffffffc0206540 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200e5e:	00001517          	auipc	a0,0x1
ffffffffc0200e62:	f4250513          	addi	a0,a0,-190 # ffffffffc0201da0 <buddy_system_pmm_manager+0x140>
ffffffffc0200e66:	8636                	mv	a2,a3
}
ffffffffc0200e68:	6105                	addi	sp,sp,32
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc0200e6a:	a4cff06f          	j	ffffffffc02000b6 <cprintf>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0200e6e:	6785                	lui	a5,0x1
ffffffffc0200e70:	17fd                	addi	a5,a5,-1
ffffffffc0200e72:	96be                	add	a3,a3,a5
ffffffffc0200e74:	77fd                	lui	a5,0xfffff
ffffffffc0200e76:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc0200e78:	00c6d793          	srli	a5,a3,0xc
ffffffffc0200e7c:	04e7f663          	bgeu	a5,a4,ffffffffc0200ec8 <pmm_init+0x196>
    pmm_manager->init_memmap(base, n);
ffffffffc0200e80:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0200e82:	97aa                	add	a5,a5,a0
ffffffffc0200e84:	00279513          	slli	a0,a5,0x2
ffffffffc0200e88:	953e                	add	a0,a0,a5
ffffffffc0200e8a:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0200e8c:	8d95                	sub	a1,a1,a3
ffffffffc0200e8e:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0200e90:	81b1                	srli	a1,a1,0xc
ffffffffc0200e92:	9532                	add	a0,a0,a2
ffffffffc0200e94:	9782                	jalr	a5
ffffffffc0200e96:	b769                	j	ffffffffc0200e20 <pmm_init+0xee>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0200e98:	00001617          	auipc	a2,0x1
ffffffffc0200e9c:	e8060613          	addi	a2,a2,-384 # ffffffffc0201d18 <buddy_system_pmm_manager+0xb8>
ffffffffc0200ea0:	07100593          	li	a1,113
ffffffffc0200ea4:	00001517          	auipc	a0,0x1
ffffffffc0200ea8:	e9c50513          	addi	a0,a0,-356 # ffffffffc0201d40 <buddy_system_pmm_manager+0xe0>
ffffffffc0200eac:	cfcff0ef          	jal	ra,ffffffffc02003a8 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0200eb0:	00001617          	auipc	a2,0x1
ffffffffc0200eb4:	e6860613          	addi	a2,a2,-408 # ffffffffc0201d18 <buddy_system_pmm_manager+0xb8>
ffffffffc0200eb8:	08c00593          	li	a1,140
ffffffffc0200ebc:	00001517          	auipc	a0,0x1
ffffffffc0200ec0:	e8450513          	addi	a0,a0,-380 # ffffffffc0201d40 <buddy_system_pmm_manager+0xe0>
ffffffffc0200ec4:	ce4ff0ef          	jal	ra,ffffffffc02003a8 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0200ec8:	00001617          	auipc	a2,0x1
ffffffffc0200ecc:	e8860613          	addi	a2,a2,-376 # ffffffffc0201d50 <buddy_system_pmm_manager+0xf0>
ffffffffc0200ed0:	06b00593          	li	a1,107
ffffffffc0200ed4:	00001517          	auipc	a0,0x1
ffffffffc0200ed8:	e9c50513          	addi	a0,a0,-356 # ffffffffc0201d70 <buddy_system_pmm_manager+0x110>
ffffffffc0200edc:	cccff0ef          	jal	ra,ffffffffc02003a8 <__panic>

ffffffffc0200ee0 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0200ee0:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200ee4:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
ffffffffc0200ee6:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200eea:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0200eec:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0200ef0:	f022                	sd	s0,32(sp)
ffffffffc0200ef2:	ec26                	sd	s1,24(sp)
ffffffffc0200ef4:	e84a                	sd	s2,16(sp)
ffffffffc0200ef6:	f406                	sd	ra,40(sp)
ffffffffc0200ef8:	e44e                	sd	s3,8(sp)
ffffffffc0200efa:	84aa                	mv	s1,a0
ffffffffc0200efc:	892e                	mv	s2,a1
ffffffffc0200efe:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
ffffffffc0200f02:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
ffffffffc0200f04:	03067e63          	bgeu	a2,a6,ffffffffc0200f40 <printnum+0x60>
ffffffffc0200f08:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0200f0a:	00805763          	blez	s0,ffffffffc0200f18 <printnum+0x38>
ffffffffc0200f0e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0200f10:	85ca                	mv	a1,s2
ffffffffc0200f12:	854e                	mv	a0,s3
ffffffffc0200f14:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0200f16:	fc65                	bnez	s0,ffffffffc0200f0e <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200f18:	1a02                	slli	s4,s4,0x20
ffffffffc0200f1a:	020a5a13          	srli	s4,s4,0x20
ffffffffc0200f1e:	00001797          	auipc	a5,0x1
ffffffffc0200f22:	05278793          	addi	a5,a5,82 # ffffffffc0201f70 <error_string+0x38>
ffffffffc0200f26:	9a3e                	add	s4,s4,a5
}
ffffffffc0200f28:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200f2a:	000a4503          	lbu	a0,0(s4)
}
ffffffffc0200f2e:	70a2                	ld	ra,40(sp)
ffffffffc0200f30:	69a2                	ld	s3,8(sp)
ffffffffc0200f32:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200f34:	85ca                	mv	a1,s2
ffffffffc0200f36:	8326                	mv	t1,s1
}
ffffffffc0200f38:	6942                	ld	s2,16(sp)
ffffffffc0200f3a:	64e2                	ld	s1,24(sp)
ffffffffc0200f3c:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0200f3e:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0200f40:	03065633          	divu	a2,a2,a6
ffffffffc0200f44:	8722                	mv	a4,s0
ffffffffc0200f46:	f9bff0ef          	jal	ra,ffffffffc0200ee0 <printnum>
ffffffffc0200f4a:	b7f9                	j	ffffffffc0200f18 <printnum+0x38>

ffffffffc0200f4c <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0200f4c:	7119                	addi	sp,sp,-128
ffffffffc0200f4e:	f4a6                	sd	s1,104(sp)
ffffffffc0200f50:	f0ca                	sd	s2,96(sp)
ffffffffc0200f52:	e8d2                	sd	s4,80(sp)
ffffffffc0200f54:	e4d6                	sd	s5,72(sp)
ffffffffc0200f56:	e0da                	sd	s6,64(sp)
ffffffffc0200f58:	fc5e                	sd	s7,56(sp)
ffffffffc0200f5a:	f862                	sd	s8,48(sp)
ffffffffc0200f5c:	f06a                	sd	s10,32(sp)
ffffffffc0200f5e:	fc86                	sd	ra,120(sp)
ffffffffc0200f60:	f8a2                	sd	s0,112(sp)
ffffffffc0200f62:	ecce                	sd	s3,88(sp)
ffffffffc0200f64:	f466                	sd	s9,40(sp)
ffffffffc0200f66:	ec6e                	sd	s11,24(sp)
ffffffffc0200f68:	892a                	mv	s2,a0
ffffffffc0200f6a:	84ae                	mv	s1,a1
ffffffffc0200f6c:	8d32                	mv	s10,a2
ffffffffc0200f6e:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
ffffffffc0200f70:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200f72:	00001a17          	auipc	s4,0x1
ffffffffc0200f76:	e6ea0a13          	addi	s4,s4,-402 # ffffffffc0201de0 <buddy_system_pmm_manager+0x180>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0200f7a:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0200f7e:	00001c17          	auipc	s8,0x1
ffffffffc0200f82:	fbac0c13          	addi	s8,s8,-70 # ffffffffc0201f38 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200f86:	000d4503          	lbu	a0,0(s10)
ffffffffc0200f8a:	02500793          	li	a5,37
ffffffffc0200f8e:	001d0413          	addi	s0,s10,1
ffffffffc0200f92:	00f50e63          	beq	a0,a5,ffffffffc0200fae <vprintfmt+0x62>
            if (ch == '\0') {
ffffffffc0200f96:	c521                	beqz	a0,ffffffffc0200fde <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200f98:	02500993          	li	s3,37
ffffffffc0200f9c:	a011                	j	ffffffffc0200fa0 <vprintfmt+0x54>
            if (ch == '\0') {
ffffffffc0200f9e:	c121                	beqz	a0,ffffffffc0200fde <vprintfmt+0x92>
            putch(ch, putdat);
ffffffffc0200fa0:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200fa2:	0405                	addi	s0,s0,1
            putch(ch, putdat);
ffffffffc0200fa4:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0200fa6:	fff44503          	lbu	a0,-1(s0)
ffffffffc0200faa:	ff351ae3          	bne	a0,s3,ffffffffc0200f9e <vprintfmt+0x52>
ffffffffc0200fae:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
ffffffffc0200fb2:	02000793          	li	a5,32
        lflag = altflag = 0;
ffffffffc0200fb6:	4981                	li	s3,0
ffffffffc0200fb8:	4801                	li	a6,0
        width = precision = -1;
ffffffffc0200fba:	5cfd                	li	s9,-1
ffffffffc0200fbc:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200fbe:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
ffffffffc0200fc2:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200fc4:	fdd6069b          	addiw	a3,a2,-35
ffffffffc0200fc8:	0ff6f693          	andi	a3,a3,255
ffffffffc0200fcc:	00140d13          	addi	s10,s0,1
ffffffffc0200fd0:	1ed5ef63          	bltu	a1,a3,ffffffffc02011ce <vprintfmt+0x282>
ffffffffc0200fd4:	068a                	slli	a3,a3,0x2
ffffffffc0200fd6:	96d2                	add	a3,a3,s4
ffffffffc0200fd8:	4294                	lw	a3,0(a3)
ffffffffc0200fda:	96d2                	add	a3,a3,s4
ffffffffc0200fdc:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0200fde:	70e6                	ld	ra,120(sp)
ffffffffc0200fe0:	7446                	ld	s0,112(sp)
ffffffffc0200fe2:	74a6                	ld	s1,104(sp)
ffffffffc0200fe4:	7906                	ld	s2,96(sp)
ffffffffc0200fe6:	69e6                	ld	s3,88(sp)
ffffffffc0200fe8:	6a46                	ld	s4,80(sp)
ffffffffc0200fea:	6aa6                	ld	s5,72(sp)
ffffffffc0200fec:	6b06                	ld	s6,64(sp)
ffffffffc0200fee:	7be2                	ld	s7,56(sp)
ffffffffc0200ff0:	7c42                	ld	s8,48(sp)
ffffffffc0200ff2:	7ca2                	ld	s9,40(sp)
ffffffffc0200ff4:	7d02                	ld	s10,32(sp)
ffffffffc0200ff6:	6de2                	ld	s11,24(sp)
ffffffffc0200ff8:	6109                	addi	sp,sp,128
ffffffffc0200ffa:	8082                	ret
            padc = '-';
ffffffffc0200ffc:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0200ffe:	00144603          	lbu	a2,1(s0)
ffffffffc0201002:	846a                	mv	s0,s10
ffffffffc0201004:	b7c1                	j	ffffffffc0200fc4 <vprintfmt+0x78>
            precision = va_arg(ap, int);
ffffffffc0201006:	000aac83          	lw	s9,0(s5)
            goto process_precision;
ffffffffc020100a:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
ffffffffc020100e:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201010:	846a                	mv	s0,s10
            if (width < 0)
ffffffffc0201012:	fa0dd9e3          	bgez	s11,ffffffffc0200fc4 <vprintfmt+0x78>
                width = precision, precision = -1;
ffffffffc0201016:	8de6                	mv	s11,s9
ffffffffc0201018:	5cfd                	li	s9,-1
ffffffffc020101a:	b76d                	j	ffffffffc0200fc4 <vprintfmt+0x78>
            if (width < 0)
ffffffffc020101c:	fffdc693          	not	a3,s11
ffffffffc0201020:	96fd                	srai	a3,a3,0x3f
ffffffffc0201022:	00ddfdb3          	and	s11,s11,a3
ffffffffc0201026:	00144603          	lbu	a2,1(s0)
ffffffffc020102a:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020102c:	846a                	mv	s0,s10
ffffffffc020102e:	bf59                	j	ffffffffc0200fc4 <vprintfmt+0x78>
    if (lflag >= 2) {
ffffffffc0201030:	4705                	li	a4,1
ffffffffc0201032:	008a8593          	addi	a1,s5,8
ffffffffc0201036:	01074463          	blt	a4,a6,ffffffffc020103e <vprintfmt+0xf2>
    else if (lflag) {
ffffffffc020103a:	22080863          	beqz	a6,ffffffffc020126a <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
ffffffffc020103e:	000ab603          	ld	a2,0(s5)
ffffffffc0201042:	46c1                	li	a3,16
ffffffffc0201044:	8aae                	mv	s5,a1
ffffffffc0201046:	a291                	j	ffffffffc020118a <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
ffffffffc0201048:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
ffffffffc020104c:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201050:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
ffffffffc0201052:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
ffffffffc0201056:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc020105a:	fad56ce3          	bltu	a0,a3,ffffffffc0201012 <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
ffffffffc020105e:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201060:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
ffffffffc0201064:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201068:	0196873b          	addw	a4,a3,s9
ffffffffc020106c:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201070:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
ffffffffc0201074:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
ffffffffc0201078:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc020107c:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201080:	fcd57fe3          	bgeu	a0,a3,ffffffffc020105e <vprintfmt+0x112>
ffffffffc0201084:	b779                	j	ffffffffc0201012 <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
ffffffffc0201086:	000aa503          	lw	a0,0(s5)
ffffffffc020108a:	85a6                	mv	a1,s1
ffffffffc020108c:	0aa1                	addi	s5,s5,8
ffffffffc020108e:	9902                	jalr	s2
            break;
ffffffffc0201090:	bddd                	j	ffffffffc0200f86 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201092:	4705                	li	a4,1
ffffffffc0201094:	008a8993          	addi	s3,s5,8
ffffffffc0201098:	01074463          	blt	a4,a6,ffffffffc02010a0 <vprintfmt+0x154>
    else if (lflag) {
ffffffffc020109c:	1c080463          	beqz	a6,ffffffffc0201264 <vprintfmt+0x318>
        return va_arg(*ap, long);
ffffffffc02010a0:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
ffffffffc02010a4:	1c044a63          	bltz	s0,ffffffffc0201278 <vprintfmt+0x32c>
            num = getint(&ap, lflag);
ffffffffc02010a8:	8622                	mv	a2,s0
ffffffffc02010aa:	8ace                	mv	s5,s3
ffffffffc02010ac:	46a9                	li	a3,10
ffffffffc02010ae:	a8f1                	j	ffffffffc020118a <vprintfmt+0x23e>
            err = va_arg(ap, int);
ffffffffc02010b0:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02010b4:	4719                	li	a4,6
            err = va_arg(ap, int);
ffffffffc02010b6:	0aa1                	addi	s5,s5,8
            if (err < 0) {
ffffffffc02010b8:	41f7d69b          	sraiw	a3,a5,0x1f
ffffffffc02010bc:	8fb5                	xor	a5,a5,a3
ffffffffc02010be:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02010c2:	12d74963          	blt	a4,a3,ffffffffc02011f4 <vprintfmt+0x2a8>
ffffffffc02010c6:	00369793          	slli	a5,a3,0x3
ffffffffc02010ca:	97e2                	add	a5,a5,s8
ffffffffc02010cc:	639c                	ld	a5,0(a5)
ffffffffc02010ce:	12078363          	beqz	a5,ffffffffc02011f4 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
ffffffffc02010d2:	86be                	mv	a3,a5
ffffffffc02010d4:	00001617          	auipc	a2,0x1
ffffffffc02010d8:	f4c60613          	addi	a2,a2,-180 # ffffffffc0202020 <error_string+0xe8>
ffffffffc02010dc:	85a6                	mv	a1,s1
ffffffffc02010de:	854a                	mv	a0,s2
ffffffffc02010e0:	1cc000ef          	jal	ra,ffffffffc02012ac <printfmt>
ffffffffc02010e4:	b54d                	j	ffffffffc0200f86 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02010e6:	000ab603          	ld	a2,0(s5)
ffffffffc02010ea:	0aa1                	addi	s5,s5,8
ffffffffc02010ec:	1a060163          	beqz	a2,ffffffffc020128e <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
ffffffffc02010f0:	00160413          	addi	s0,a2,1
ffffffffc02010f4:	15b05763          	blez	s11,ffffffffc0201242 <vprintfmt+0x2f6>
ffffffffc02010f8:	02d00593          	li	a1,45
ffffffffc02010fc:	10b79d63          	bne	a5,a1,ffffffffc0201216 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201100:	00064783          	lbu	a5,0(a2)
ffffffffc0201104:	0007851b          	sext.w	a0,a5
ffffffffc0201108:	c905                	beqz	a0,ffffffffc0201138 <vprintfmt+0x1ec>
ffffffffc020110a:	000cc563          	bltz	s9,ffffffffc0201114 <vprintfmt+0x1c8>
ffffffffc020110e:	3cfd                	addiw	s9,s9,-1
ffffffffc0201110:	036c8263          	beq	s9,s6,ffffffffc0201134 <vprintfmt+0x1e8>
                    putch('?', putdat);
ffffffffc0201114:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201116:	14098f63          	beqz	s3,ffffffffc0201274 <vprintfmt+0x328>
ffffffffc020111a:	3781                	addiw	a5,a5,-32
ffffffffc020111c:	14fbfc63          	bgeu	s7,a5,ffffffffc0201274 <vprintfmt+0x328>
                    putch('?', putdat);
ffffffffc0201120:	03f00513          	li	a0,63
ffffffffc0201124:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201126:	0405                	addi	s0,s0,1
ffffffffc0201128:	fff44783          	lbu	a5,-1(s0)
ffffffffc020112c:	3dfd                	addiw	s11,s11,-1
ffffffffc020112e:	0007851b          	sext.w	a0,a5
ffffffffc0201132:	fd61                	bnez	a0,ffffffffc020110a <vprintfmt+0x1be>
            for (; width > 0; width --) {
ffffffffc0201134:	e5b059e3          	blez	s11,ffffffffc0200f86 <vprintfmt+0x3a>
ffffffffc0201138:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc020113a:	85a6                	mv	a1,s1
ffffffffc020113c:	02000513          	li	a0,32
ffffffffc0201140:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201142:	e40d82e3          	beqz	s11,ffffffffc0200f86 <vprintfmt+0x3a>
ffffffffc0201146:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
ffffffffc0201148:	85a6                	mv	a1,s1
ffffffffc020114a:	02000513          	li	a0,32
ffffffffc020114e:	9902                	jalr	s2
            for (; width > 0; width --) {
ffffffffc0201150:	fe0d94e3          	bnez	s11,ffffffffc0201138 <vprintfmt+0x1ec>
ffffffffc0201154:	bd0d                	j	ffffffffc0200f86 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc0201156:	4705                	li	a4,1
ffffffffc0201158:	008a8593          	addi	a1,s5,8
ffffffffc020115c:	01074463          	blt	a4,a6,ffffffffc0201164 <vprintfmt+0x218>
    else if (lflag) {
ffffffffc0201160:	0e080863          	beqz	a6,ffffffffc0201250 <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
ffffffffc0201164:	000ab603          	ld	a2,0(s5)
ffffffffc0201168:	46a1                	li	a3,8
ffffffffc020116a:	8aae                	mv	s5,a1
ffffffffc020116c:	a839                	j	ffffffffc020118a <vprintfmt+0x23e>
            putch('0', putdat);
ffffffffc020116e:	03000513          	li	a0,48
ffffffffc0201172:	85a6                	mv	a1,s1
ffffffffc0201174:	e03e                	sd	a5,0(sp)
ffffffffc0201176:	9902                	jalr	s2
            putch('x', putdat);
ffffffffc0201178:	85a6                	mv	a1,s1
ffffffffc020117a:	07800513          	li	a0,120
ffffffffc020117e:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201180:	0aa1                	addi	s5,s5,8
ffffffffc0201182:	ff8ab603          	ld	a2,-8(s5)
            goto number;
ffffffffc0201186:	6782                	ld	a5,0(sp)
ffffffffc0201188:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020118a:	2781                	sext.w	a5,a5
ffffffffc020118c:	876e                	mv	a4,s11
ffffffffc020118e:	85a6                	mv	a1,s1
ffffffffc0201190:	854a                	mv	a0,s2
ffffffffc0201192:	d4fff0ef          	jal	ra,ffffffffc0200ee0 <printnum>
            break;
ffffffffc0201196:	bbc5                	j	ffffffffc0200f86 <vprintfmt+0x3a>
            lflag ++;
ffffffffc0201198:	00144603          	lbu	a2,1(s0)
ffffffffc020119c:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020119e:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02011a0:	b515                	j	ffffffffc0200fc4 <vprintfmt+0x78>
            goto reswitch;
ffffffffc02011a2:	00144603          	lbu	a2,1(s0)
            altflag = 1;
ffffffffc02011a6:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02011a8:	846a                	mv	s0,s10
            goto reswitch;
ffffffffc02011aa:	bd29                	j	ffffffffc0200fc4 <vprintfmt+0x78>
            putch(ch, putdat);
ffffffffc02011ac:	85a6                	mv	a1,s1
ffffffffc02011ae:	02500513          	li	a0,37
ffffffffc02011b2:	9902                	jalr	s2
            break;
ffffffffc02011b4:	bbc9                	j	ffffffffc0200f86 <vprintfmt+0x3a>
    if (lflag >= 2) {
ffffffffc02011b6:	4705                	li	a4,1
ffffffffc02011b8:	008a8593          	addi	a1,s5,8
ffffffffc02011bc:	01074463          	blt	a4,a6,ffffffffc02011c4 <vprintfmt+0x278>
    else if (lflag) {
ffffffffc02011c0:	08080d63          	beqz	a6,ffffffffc020125a <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
ffffffffc02011c4:	000ab603          	ld	a2,0(s5)
ffffffffc02011c8:	46a9                	li	a3,10
ffffffffc02011ca:	8aae                	mv	s5,a1
ffffffffc02011cc:	bf7d                	j	ffffffffc020118a <vprintfmt+0x23e>
            putch('%', putdat);
ffffffffc02011ce:	85a6                	mv	a1,s1
ffffffffc02011d0:	02500513          	li	a0,37
ffffffffc02011d4:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02011d6:	fff44703          	lbu	a4,-1(s0)
ffffffffc02011da:	02500793          	li	a5,37
ffffffffc02011de:	8d22                	mv	s10,s0
ffffffffc02011e0:	daf703e3          	beq	a4,a5,ffffffffc0200f86 <vprintfmt+0x3a>
ffffffffc02011e4:	02500713          	li	a4,37
ffffffffc02011e8:	1d7d                	addi	s10,s10,-1
ffffffffc02011ea:	fffd4783          	lbu	a5,-1(s10)
ffffffffc02011ee:	fee79de3          	bne	a5,a4,ffffffffc02011e8 <vprintfmt+0x29c>
ffffffffc02011f2:	bb51                	j	ffffffffc0200f86 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02011f4:	00001617          	auipc	a2,0x1
ffffffffc02011f8:	e1c60613          	addi	a2,a2,-484 # ffffffffc0202010 <error_string+0xd8>
ffffffffc02011fc:	85a6                	mv	a1,s1
ffffffffc02011fe:	854a                	mv	a0,s2
ffffffffc0201200:	0ac000ef          	jal	ra,ffffffffc02012ac <printfmt>
ffffffffc0201204:	b349                	j	ffffffffc0200f86 <vprintfmt+0x3a>
                p = "(null)";
ffffffffc0201206:	00001617          	auipc	a2,0x1
ffffffffc020120a:	e0260613          	addi	a2,a2,-510 # ffffffffc0202008 <error_string+0xd0>
            if (width > 0 && padc != '-') {
ffffffffc020120e:	00001417          	auipc	s0,0x1
ffffffffc0201212:	dfb40413          	addi	s0,s0,-517 # ffffffffc0202009 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201216:	8532                	mv	a0,a2
ffffffffc0201218:	85e6                	mv	a1,s9
ffffffffc020121a:	e032                	sd	a2,0(sp)
ffffffffc020121c:	e43e                	sd	a5,8(sp)
ffffffffc020121e:	1c2000ef          	jal	ra,ffffffffc02013e0 <strnlen>
ffffffffc0201222:	40ad8dbb          	subw	s11,s11,a0
ffffffffc0201226:	6602                	ld	a2,0(sp)
ffffffffc0201228:	01b05d63          	blez	s11,ffffffffc0201242 <vprintfmt+0x2f6>
ffffffffc020122c:	67a2                	ld	a5,8(sp)
ffffffffc020122e:	2781                	sext.w	a5,a5
ffffffffc0201230:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
ffffffffc0201232:	6522                	ld	a0,8(sp)
ffffffffc0201234:	85a6                	mv	a1,s1
ffffffffc0201236:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201238:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
ffffffffc020123a:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020123c:	6602                	ld	a2,0(sp)
ffffffffc020123e:	fe0d9ae3          	bnez	s11,ffffffffc0201232 <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201242:	00064783          	lbu	a5,0(a2)
ffffffffc0201246:	0007851b          	sext.w	a0,a5
ffffffffc020124a:	ec0510e3          	bnez	a0,ffffffffc020110a <vprintfmt+0x1be>
ffffffffc020124e:	bb25                	j	ffffffffc0200f86 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
ffffffffc0201250:	000ae603          	lwu	a2,0(s5)
ffffffffc0201254:	46a1                	li	a3,8
ffffffffc0201256:	8aae                	mv	s5,a1
ffffffffc0201258:	bf0d                	j	ffffffffc020118a <vprintfmt+0x23e>
ffffffffc020125a:	000ae603          	lwu	a2,0(s5)
ffffffffc020125e:	46a9                	li	a3,10
ffffffffc0201260:	8aae                	mv	s5,a1
ffffffffc0201262:	b725                	j	ffffffffc020118a <vprintfmt+0x23e>
        return va_arg(*ap, int);
ffffffffc0201264:	000aa403          	lw	s0,0(s5)
ffffffffc0201268:	bd35                	j	ffffffffc02010a4 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
ffffffffc020126a:	000ae603          	lwu	a2,0(s5)
ffffffffc020126e:	46c1                	li	a3,16
ffffffffc0201270:	8aae                	mv	s5,a1
ffffffffc0201272:	bf21                	j	ffffffffc020118a <vprintfmt+0x23e>
                    putch(ch, putdat);
ffffffffc0201274:	9902                	jalr	s2
ffffffffc0201276:	bd45                	j	ffffffffc0201126 <vprintfmt+0x1da>
                putch('-', putdat);
ffffffffc0201278:	85a6                	mv	a1,s1
ffffffffc020127a:	02d00513          	li	a0,45
ffffffffc020127e:	e03e                	sd	a5,0(sp)
ffffffffc0201280:	9902                	jalr	s2
                num = -(long long)num;
ffffffffc0201282:	8ace                	mv	s5,s3
ffffffffc0201284:	40800633          	neg	a2,s0
ffffffffc0201288:	46a9                	li	a3,10
ffffffffc020128a:	6782                	ld	a5,0(sp)
ffffffffc020128c:	bdfd                	j	ffffffffc020118a <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
ffffffffc020128e:	01b05663          	blez	s11,ffffffffc020129a <vprintfmt+0x34e>
ffffffffc0201292:	02d00693          	li	a3,45
ffffffffc0201296:	f6d798e3          	bne	a5,a3,ffffffffc0201206 <vprintfmt+0x2ba>
ffffffffc020129a:	00001417          	auipc	s0,0x1
ffffffffc020129e:	d6f40413          	addi	s0,s0,-657 # ffffffffc0202009 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02012a2:	02800513          	li	a0,40
ffffffffc02012a6:	02800793          	li	a5,40
ffffffffc02012aa:	b585                	j	ffffffffc020110a <vprintfmt+0x1be>

ffffffffc02012ac <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02012ac:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02012ae:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02012b2:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02012b4:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02012b6:	ec06                	sd	ra,24(sp)
ffffffffc02012b8:	f83a                	sd	a4,48(sp)
ffffffffc02012ba:	fc3e                	sd	a5,56(sp)
ffffffffc02012bc:	e0c2                	sd	a6,64(sp)
ffffffffc02012be:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02012c0:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02012c2:	c8bff0ef          	jal	ra,ffffffffc0200f4c <vprintfmt>
}
ffffffffc02012c6:	60e2                	ld	ra,24(sp)
ffffffffc02012c8:	6161                	addi	sp,sp,80
ffffffffc02012ca:	8082                	ret

ffffffffc02012cc <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02012cc:	715d                	addi	sp,sp,-80
ffffffffc02012ce:	e486                	sd	ra,72(sp)
ffffffffc02012d0:	e0a2                	sd	s0,64(sp)
ffffffffc02012d2:	fc26                	sd	s1,56(sp)
ffffffffc02012d4:	f84a                	sd	s2,48(sp)
ffffffffc02012d6:	f44e                	sd	s3,40(sp)
ffffffffc02012d8:	f052                	sd	s4,32(sp)
ffffffffc02012da:	ec56                	sd	s5,24(sp)
ffffffffc02012dc:	e85a                	sd	s6,16(sp)
ffffffffc02012de:	e45e                	sd	s7,8(sp)
    if (prompt != NULL) {
ffffffffc02012e0:	c901                	beqz	a0,ffffffffc02012f0 <readline+0x24>
        cprintf("%s", prompt);
ffffffffc02012e2:	85aa                	mv	a1,a0
ffffffffc02012e4:	00001517          	auipc	a0,0x1
ffffffffc02012e8:	d3c50513          	addi	a0,a0,-708 # ffffffffc0202020 <error_string+0xe8>
ffffffffc02012ec:	dcbfe0ef          	jal	ra,ffffffffc02000b6 <cprintf>
readline(const char *prompt) {
ffffffffc02012f0:	4481                	li	s1,0
    while (1) {
        c = getchar();
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02012f2:	497d                	li	s2,31
            cputchar(c);
            buf[i ++] = c;
        }
        else if (c == '\b' && i > 0) {
ffffffffc02012f4:	49a1                	li	s3,8
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02012f6:	4aa9                	li	s5,10
ffffffffc02012f8:	4b35                	li	s6,13
            buf[i ++] = c;
ffffffffc02012fa:	00005b97          	auipc	s7,0x5
ffffffffc02012fe:	d16b8b93          	addi	s7,s7,-746 # ffffffffc0206010 <edata>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201302:	3fe00a13          	li	s4,1022
        c = getchar();
ffffffffc0201306:	e27fe0ef          	jal	ra,ffffffffc020012c <getchar>
ffffffffc020130a:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020130c:	00054b63          	bltz	a0,ffffffffc0201322 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201310:	00a95b63          	bge	s2,a0,ffffffffc0201326 <readline+0x5a>
ffffffffc0201314:	029a5463          	bge	s4,s1,ffffffffc020133c <readline+0x70>
        c = getchar();
ffffffffc0201318:	e15fe0ef          	jal	ra,ffffffffc020012c <getchar>
ffffffffc020131c:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc020131e:	fe0559e3          	bgez	a0,ffffffffc0201310 <readline+0x44>
            return NULL;
ffffffffc0201322:	4501                	li	a0,0
ffffffffc0201324:	a099                	j	ffffffffc020136a <readline+0x9e>
        else if (c == '\b' && i > 0) {
ffffffffc0201326:	03341463          	bne	s0,s3,ffffffffc020134e <readline+0x82>
ffffffffc020132a:	e8b9                	bnez	s1,ffffffffc0201380 <readline+0xb4>
        c = getchar();
ffffffffc020132c:	e01fe0ef          	jal	ra,ffffffffc020012c <getchar>
ffffffffc0201330:	842a                	mv	s0,a0
        if (c < 0) {
ffffffffc0201332:	fe0548e3          	bltz	a0,ffffffffc0201322 <readline+0x56>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201336:	fea958e3          	bge	s2,a0,ffffffffc0201326 <readline+0x5a>
ffffffffc020133a:	4481                	li	s1,0
            cputchar(c);
ffffffffc020133c:	8522                	mv	a0,s0
ffffffffc020133e:	dadfe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i ++] = c;
ffffffffc0201342:	009b87b3          	add	a5,s7,s1
ffffffffc0201346:	00878023          	sb	s0,0(a5)
ffffffffc020134a:	2485                	addiw	s1,s1,1
ffffffffc020134c:	bf6d                	j	ffffffffc0201306 <readline+0x3a>
        else if (c == '\n' || c == '\r') {
ffffffffc020134e:	01540463          	beq	s0,s5,ffffffffc0201356 <readline+0x8a>
ffffffffc0201352:	fb641ae3          	bne	s0,s6,ffffffffc0201306 <readline+0x3a>
            cputchar(c);
ffffffffc0201356:	8522                	mv	a0,s0
ffffffffc0201358:	d93fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            buf[i] = '\0';
ffffffffc020135c:	00005517          	auipc	a0,0x5
ffffffffc0201360:	cb450513          	addi	a0,a0,-844 # ffffffffc0206010 <edata>
ffffffffc0201364:	94aa                	add	s1,s1,a0
ffffffffc0201366:	00048023          	sb	zero,0(s1)
            return buf;
        }
    }
}
ffffffffc020136a:	60a6                	ld	ra,72(sp)
ffffffffc020136c:	6406                	ld	s0,64(sp)
ffffffffc020136e:	74e2                	ld	s1,56(sp)
ffffffffc0201370:	7942                	ld	s2,48(sp)
ffffffffc0201372:	79a2                	ld	s3,40(sp)
ffffffffc0201374:	7a02                	ld	s4,32(sp)
ffffffffc0201376:	6ae2                	ld	s5,24(sp)
ffffffffc0201378:	6b42                	ld	s6,16(sp)
ffffffffc020137a:	6ba2                	ld	s7,8(sp)
ffffffffc020137c:	6161                	addi	sp,sp,80
ffffffffc020137e:	8082                	ret
            cputchar(c);
ffffffffc0201380:	4521                	li	a0,8
ffffffffc0201382:	d69fe0ef          	jal	ra,ffffffffc02000ea <cputchar>
            i --;
ffffffffc0201386:	34fd                	addiw	s1,s1,-1
ffffffffc0201388:	bfbd                	j	ffffffffc0201306 <readline+0x3a>

ffffffffc020138a <sbi_console_putchar>:
    );
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
ffffffffc020138a:	00005797          	auipc	a5,0x5
ffffffffc020138e:	c7e78793          	addi	a5,a5,-898 # ffffffffc0206008 <SBI_CONSOLE_PUTCHAR>
    __asm__ volatile (
ffffffffc0201392:	6398                	ld	a4,0(a5)
ffffffffc0201394:	4781                	li	a5,0
ffffffffc0201396:	88ba                	mv	a7,a4
ffffffffc0201398:	852a                	mv	a0,a0
ffffffffc020139a:	85be                	mv	a1,a5
ffffffffc020139c:	863e                	mv	a2,a5
ffffffffc020139e:	00000073          	ecall
ffffffffc02013a2:	87aa                	mv	a5,a0
}
ffffffffc02013a4:	8082                	ret

ffffffffc02013a6 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
ffffffffc02013a6:	00005797          	auipc	a5,0x5
ffffffffc02013aa:	08278793          	addi	a5,a5,130 # ffffffffc0206428 <SBI_SET_TIMER>
    __asm__ volatile (
ffffffffc02013ae:	6398                	ld	a4,0(a5)
ffffffffc02013b0:	4781                	li	a5,0
ffffffffc02013b2:	88ba                	mv	a7,a4
ffffffffc02013b4:	852a                	mv	a0,a0
ffffffffc02013b6:	85be                	mv	a1,a5
ffffffffc02013b8:	863e                	mv	a2,a5
ffffffffc02013ba:	00000073          	ecall
ffffffffc02013be:	87aa                	mv	a5,a0
}
ffffffffc02013c0:	8082                	ret

ffffffffc02013c2 <sbi_console_getchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
ffffffffc02013c2:	00005797          	auipc	a5,0x5
ffffffffc02013c6:	c3e78793          	addi	a5,a5,-962 # ffffffffc0206000 <SBI_CONSOLE_GETCHAR>
    __asm__ volatile (
ffffffffc02013ca:	639c                	ld	a5,0(a5)
ffffffffc02013cc:	4501                	li	a0,0
ffffffffc02013ce:	88be                	mv	a7,a5
ffffffffc02013d0:	852a                	mv	a0,a0
ffffffffc02013d2:	85aa                	mv	a1,a0
ffffffffc02013d4:	862a                	mv	a2,a0
ffffffffc02013d6:	00000073          	ecall
ffffffffc02013da:	852a                	mv	a0,a0
ffffffffc02013dc:	2501                	sext.w	a0,a0
ffffffffc02013de:	8082                	ret

ffffffffc02013e0 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
ffffffffc02013e0:	c185                	beqz	a1,ffffffffc0201400 <strnlen+0x20>
ffffffffc02013e2:	00054783          	lbu	a5,0(a0)
ffffffffc02013e6:	cf89                	beqz	a5,ffffffffc0201400 <strnlen+0x20>
    size_t cnt = 0;
ffffffffc02013e8:	4781                	li	a5,0
ffffffffc02013ea:	a021                	j	ffffffffc02013f2 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
ffffffffc02013ec:	00074703          	lbu	a4,0(a4)
ffffffffc02013f0:	c711                	beqz	a4,ffffffffc02013fc <strnlen+0x1c>
        cnt ++;
ffffffffc02013f2:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02013f4:	00f50733          	add	a4,a0,a5
ffffffffc02013f8:	fef59ae3          	bne	a1,a5,ffffffffc02013ec <strnlen+0xc>
    }
    return cnt;
}
ffffffffc02013fc:	853e                	mv	a0,a5
ffffffffc02013fe:	8082                	ret
    size_t cnt = 0;
ffffffffc0201400:	4781                	li	a5,0
}
ffffffffc0201402:	853e                	mv	a0,a5
ffffffffc0201404:	8082                	ret

ffffffffc0201406 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201406:	00054783          	lbu	a5,0(a0)
ffffffffc020140a:	0005c703          	lbu	a4,0(a1)
ffffffffc020140e:	cb91                	beqz	a5,ffffffffc0201422 <strcmp+0x1c>
ffffffffc0201410:	00e79c63          	bne	a5,a4,ffffffffc0201428 <strcmp+0x22>
        s1 ++, s2 ++;
ffffffffc0201414:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201416:	00054783          	lbu	a5,0(a0)
        s1 ++, s2 ++;
ffffffffc020141a:	0585                	addi	a1,a1,1
ffffffffc020141c:	0005c703          	lbu	a4,0(a1)
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201420:	fbe5                	bnez	a5,ffffffffc0201410 <strcmp+0xa>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201422:	4501                	li	a0,0
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201424:	9d19                	subw	a0,a0,a4
ffffffffc0201426:	8082                	ret
ffffffffc0201428:	0007851b          	sext.w	a0,a5
ffffffffc020142c:	9d19                	subw	a0,a0,a4
ffffffffc020142e:	8082                	ret

ffffffffc0201430 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201430:	00054783          	lbu	a5,0(a0)
ffffffffc0201434:	cb91                	beqz	a5,ffffffffc0201448 <strchr+0x18>
        if (*s == c) {
ffffffffc0201436:	00b79563          	bne	a5,a1,ffffffffc0201440 <strchr+0x10>
ffffffffc020143a:	a809                	j	ffffffffc020144c <strchr+0x1c>
ffffffffc020143c:	00b78763          	beq	a5,a1,ffffffffc020144a <strchr+0x1a>
            return (char *)s;
        }
        s ++;
ffffffffc0201440:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201442:	00054783          	lbu	a5,0(a0)
ffffffffc0201446:	fbfd                	bnez	a5,ffffffffc020143c <strchr+0xc>
    }
    return NULL;
ffffffffc0201448:	4501                	li	a0,0
}
ffffffffc020144a:	8082                	ret
ffffffffc020144c:	8082                	ret

ffffffffc020144e <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020144e:	ca01                	beqz	a2,ffffffffc020145e <memset+0x10>
ffffffffc0201450:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201452:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201454:	0785                	addi	a5,a5,1
ffffffffc0201456:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020145a:	fec79de3          	bne	a5,a2,ffffffffc0201454 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020145e:	8082                	ret
