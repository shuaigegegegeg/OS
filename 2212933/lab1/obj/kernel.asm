
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
#include <memlayout.h>

    .section .text,"ax",%progbits
    .globl kern_entry
kern_entry:
    la sp, bootstacktop
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp

    tail kern_init
    80200008:	a009                	j	8020000a <kern_init>

000000008020000a <kern_init>:
int kern_init(void) __attribute__((noreturn));
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
    8020000a:	00004517          	auipc	a0,0x4
    8020000e:	00650513          	addi	a0,a0,6 # 80204010 <edata>
    80200012:	00004617          	auipc	a2,0x4
    80200016:	01660613          	addi	a2,a2,22 # 80204028 <end>
int kern_init(void) {
    8020001a:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
    8020001c:	8e09                	sub	a2,a2,a0
    8020001e:	4581                	li	a1,0
int kern_init(void) {
    80200020:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
    80200022:	207000ef          	jal	ra,80200a28 <memset>

    cons_init();  // init the console
    80200026:	148000ef          	jal	ra,8020016e <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	a1658593          	addi	a1,a1,-1514 # 80200a40 <etext+0x6>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	a2e50513          	addi	a0,a0,-1490 # 80200a60 <etext+0x26>
    8020003a:	030000ef          	jal	ra,8020006a <cprintf>

    print_kerninfo();
    8020003e:	060000ef          	jal	ra,8020009e <print_kerninfo>

    // grade_backtrace();

    idt_init();  // init interrupt descriptor table
    80200042:	13c000ef          	jal	ra,8020017e <idt_init>

    // rdtime in mbare mode crashes
    clock_init();  // init clock interrupt
    80200046:	0e6000ef          	jal	ra,8020012c <clock_init>

    intr_enable();  // enable irq interrupt
    8020004a:	12e000ef          	jal	ra,80200178 <intr_enable>
    
    while (1)
        ;
    8020004e:	a001                	j	8020004e <kern_init+0x44>

0000000080200050 <cputch>:

/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void cputch(int c, int *cnt) {
    80200050:	1141                	addi	sp,sp,-16
    80200052:	e022                	sd	s0,0(sp)
    80200054:	e406                	sd	ra,8(sp)
    80200056:	842e                	mv	s0,a1
    cons_putc(c);
    80200058:	118000ef          	jal	ra,80200170 <cons_putc>
    (*cnt)++;
    8020005c:	401c                	lw	a5,0(s0)
}
    8020005e:	60a2                	ld	ra,8(sp)
    (*cnt)++;
    80200060:	2785                	addiw	a5,a5,1
    80200062:	c01c                	sw	a5,0(s0)
}
    80200064:	6402                	ld	s0,0(sp)
    80200066:	0141                	addi	sp,sp,16
    80200068:	8082                	ret

000000008020006a <cprintf>:
 * cprintf - formats a string and writes it to stdout
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...) {
    8020006a:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
    8020006c:	02810313          	addi	t1,sp,40 # 80204028 <end>
int cprintf(const char *fmt, ...) {
    80200070:	f42e                	sd	a1,40(sp)
    80200072:	f832                	sd	a2,48(sp)
    80200074:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200076:	862a                	mv	a2,a0
    80200078:	004c                	addi	a1,sp,4
    8020007a:	00000517          	auipc	a0,0x0
    8020007e:	fd650513          	addi	a0,a0,-42 # 80200050 <cputch>
    80200082:	869a                	mv	a3,t1
int cprintf(const char *fmt, ...) {
    80200084:	ec06                	sd	ra,24(sp)
    80200086:	e0ba                	sd	a4,64(sp)
    80200088:	e4be                	sd	a5,72(sp)
    8020008a:	e8c2                	sd	a6,80(sp)
    8020008c:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
    8020008e:	e41a                	sd	t1,8(sp)
    int cnt = 0;
    80200090:	c202                	sw	zero,4(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
    80200092:	59c000ef          	jal	ra,8020062e <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
    80200096:	60e2                	ld	ra,24(sp)
    80200098:	4512                	lw	a0,4(sp)
    8020009a:	6125                	addi	sp,sp,96
    8020009c:	8082                	ret

000000008020009e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
    8020009e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
    802000a0:	00001517          	auipc	a0,0x1
    802000a4:	9c850513          	addi	a0,a0,-1592 # 80200a68 <etext+0x2e>
void print_kerninfo(void) {
    802000a8:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000aa:	fc1ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000ae:	00000597          	auipc	a1,0x0
    802000b2:	f5c58593          	addi	a1,a1,-164 # 8020000a <kern_init>
    802000b6:	00001517          	auipc	a0,0x1
    802000ba:	9d250513          	addi	a0,a0,-1582 # 80200a88 <etext+0x4e>
    802000be:	fadff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c2:	00001597          	auipc	a1,0x1
    802000c6:	97858593          	addi	a1,a1,-1672 # 80200a3a <etext>
    802000ca:	00001517          	auipc	a0,0x1
    802000ce:	9de50513          	addi	a0,a0,-1570 # 80200aa8 <etext+0x6e>
    802000d2:	f99ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000d6:	00004597          	auipc	a1,0x4
    802000da:	f3a58593          	addi	a1,a1,-198 # 80204010 <edata>
    802000de:	00001517          	auipc	a0,0x1
    802000e2:	9ea50513          	addi	a0,a0,-1558 # 80200ac8 <etext+0x8e>
    802000e6:	f85ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000ea:	00004597          	auipc	a1,0x4
    802000ee:	f3e58593          	addi	a1,a1,-194 # 80204028 <end>
    802000f2:	00001517          	auipc	a0,0x1
    802000f6:	9f650513          	addi	a0,a0,-1546 # 80200ae8 <etext+0xae>
    802000fa:	f71ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
    802000fe:	00004597          	auipc	a1,0x4
    80200102:	32958593          	addi	a1,a1,809 # 80204427 <end+0x3ff>
    80200106:	00000797          	auipc	a5,0x0
    8020010a:	f0478793          	addi	a5,a5,-252 # 8020000a <kern_init>
    8020010e:	40f587b3          	sub	a5,a1,a5
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200112:	43f7d593          	srai	a1,a5,0x3f
}
    80200116:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
    80200118:	3ff5f593          	andi	a1,a1,1023
    8020011c:	95be                	add	a1,a1,a5
    8020011e:	85a9                	srai	a1,a1,0xa
    80200120:	00001517          	auipc	a0,0x1
    80200124:	9e850513          	addi	a0,a0,-1560 # 80200b08 <etext+0xce>
}
    80200128:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
    8020012a:	b781                	j	8020006a <cprintf>

000000008020012c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    8020012c:	1141                	addi	sp,sp,-16
    8020012e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
    80200130:	02000793          	li	a5,32
    80200134:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    80200138:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    8020013c:	67e1                	lui	a5,0x18
    8020013e:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200142:	953e                	add	a0,a0,a5
    80200144:	087000ef          	jal	ra,802009ca <sbi_set_timer>
}
    80200148:	60a2                	ld	ra,8(sp)
    ticks = 0;
    8020014a:	00004797          	auipc	a5,0x4
    8020014e:	ec07bb23          	sd	zero,-298(a5) # 80204020 <ticks>
    cprintf("++ setup timer interrupts\n");
    80200152:	00001517          	auipc	a0,0x1
    80200156:	9e650513          	addi	a0,a0,-1562 # 80200b38 <etext+0xfe>
}
    8020015a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
    8020015c:	b739                	j	8020006a <cprintf>

000000008020015e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
    8020015e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
    80200162:	67e1                	lui	a5,0x18
    80200164:	6a078793          	addi	a5,a5,1696 # 186a0 <BASE_ADDRESS-0x801e7960>
    80200168:	953e                	add	a0,a0,a5
    8020016a:	0610006f          	j	802009ca <sbi_set_timer>

000000008020016e <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
    8020016e:	8082                	ret

0000000080200170 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
    80200170:	0ff57513          	andi	a0,a0,255
    80200174:	03b0006f          	j	802009ae <sbi_console_putchar>

0000000080200178 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
    80200178:	100167f3          	csrrsi	a5,sstatus,2
    8020017c:	8082                	ret

000000008020017e <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    8020017e:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    80200182:	00000797          	auipc	a5,0x0
    80200186:	38a78793          	addi	a5,a5,906 # 8020050c <__alltraps>
    8020018a:	10579073          	csrw	stvec,a5
}
    8020018e:	8082                	ret

0000000080200190 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200190:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    80200192:	1141                	addi	sp,sp,-16
    80200194:	e022                	sd	s0,0(sp)
    80200196:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200198:	00001517          	auipc	a0,0x1
    8020019c:	ad850513          	addi	a0,a0,-1320 # 80200c70 <etext+0x236>
void print_regs(struct pushregs *gpr) {
    802001a0:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a2:	ec9ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001a6:	640c                	ld	a1,8(s0)
    802001a8:	00001517          	auipc	a0,0x1
    802001ac:	ae050513          	addi	a0,a0,-1312 # 80200c88 <etext+0x24e>
    802001b0:	ebbff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001b4:	680c                	ld	a1,16(s0)
    802001b6:	00001517          	auipc	a0,0x1
    802001ba:	aea50513          	addi	a0,a0,-1302 # 80200ca0 <etext+0x266>
    802001be:	eadff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001c2:	6c0c                	ld	a1,24(s0)
    802001c4:	00001517          	auipc	a0,0x1
    802001c8:	af450513          	addi	a0,a0,-1292 # 80200cb8 <etext+0x27e>
    802001cc:	e9fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001d0:	700c                	ld	a1,32(s0)
    802001d2:	00001517          	auipc	a0,0x1
    802001d6:	afe50513          	addi	a0,a0,-1282 # 80200cd0 <etext+0x296>
    802001da:	e91ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001de:	740c                	ld	a1,40(s0)
    802001e0:	00001517          	auipc	a0,0x1
    802001e4:	b0850513          	addi	a0,a0,-1272 # 80200ce8 <etext+0x2ae>
    802001e8:	e83ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001ec:	780c                	ld	a1,48(s0)
    802001ee:	00001517          	auipc	a0,0x1
    802001f2:	b1250513          	addi	a0,a0,-1262 # 80200d00 <etext+0x2c6>
    802001f6:	e75ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    802001fa:	7c0c                	ld	a1,56(s0)
    802001fc:	00001517          	auipc	a0,0x1
    80200200:	b1c50513          	addi	a0,a0,-1252 # 80200d18 <etext+0x2de>
    80200204:	e67ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    80200208:	602c                	ld	a1,64(s0)
    8020020a:	00001517          	auipc	a0,0x1
    8020020e:	b2650513          	addi	a0,a0,-1242 # 80200d30 <etext+0x2f6>
    80200212:	e59ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    80200216:	642c                	ld	a1,72(s0)
    80200218:	00001517          	auipc	a0,0x1
    8020021c:	b3050513          	addi	a0,a0,-1232 # 80200d48 <etext+0x30e>
    80200220:	e4bff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    80200224:	682c                	ld	a1,80(s0)
    80200226:	00001517          	auipc	a0,0x1
    8020022a:	b3a50513          	addi	a0,a0,-1222 # 80200d60 <etext+0x326>
    8020022e:	e3dff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200232:	6c2c                	ld	a1,88(s0)
    80200234:	00001517          	auipc	a0,0x1
    80200238:	b4450513          	addi	a0,a0,-1212 # 80200d78 <etext+0x33e>
    8020023c:	e2fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200240:	702c                	ld	a1,96(s0)
    80200242:	00001517          	auipc	a0,0x1
    80200246:	b4e50513          	addi	a0,a0,-1202 # 80200d90 <etext+0x356>
    8020024a:	e21ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    8020024e:	742c                	ld	a1,104(s0)
    80200250:	00001517          	auipc	a0,0x1
    80200254:	b5850513          	addi	a0,a0,-1192 # 80200da8 <etext+0x36e>
    80200258:	e13ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    8020025c:	782c                	ld	a1,112(s0)
    8020025e:	00001517          	auipc	a0,0x1
    80200262:	b6250513          	addi	a0,a0,-1182 # 80200dc0 <etext+0x386>
    80200266:	e05ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    8020026a:	7c2c                	ld	a1,120(s0)
    8020026c:	00001517          	auipc	a0,0x1
    80200270:	b6c50513          	addi	a0,a0,-1172 # 80200dd8 <etext+0x39e>
    80200274:	df7ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    80200278:	604c                	ld	a1,128(s0)
    8020027a:	00001517          	auipc	a0,0x1
    8020027e:	b7650513          	addi	a0,a0,-1162 # 80200df0 <etext+0x3b6>
    80200282:	de9ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    80200286:	644c                	ld	a1,136(s0)
    80200288:	00001517          	auipc	a0,0x1
    8020028c:	b8050513          	addi	a0,a0,-1152 # 80200e08 <etext+0x3ce>
    80200290:	ddbff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    80200294:	684c                	ld	a1,144(s0)
    80200296:	00001517          	auipc	a0,0x1
    8020029a:	b8a50513          	addi	a0,a0,-1142 # 80200e20 <etext+0x3e6>
    8020029e:	dcdff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002a2:	6c4c                	ld	a1,152(s0)
    802002a4:	00001517          	auipc	a0,0x1
    802002a8:	b9450513          	addi	a0,a0,-1132 # 80200e38 <etext+0x3fe>
    802002ac:	dbfff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002b0:	704c                	ld	a1,160(s0)
    802002b2:	00001517          	auipc	a0,0x1
    802002b6:	b9e50513          	addi	a0,a0,-1122 # 80200e50 <etext+0x416>
    802002ba:	db1ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002be:	744c                	ld	a1,168(s0)
    802002c0:	00001517          	auipc	a0,0x1
    802002c4:	ba850513          	addi	a0,a0,-1112 # 80200e68 <etext+0x42e>
    802002c8:	da3ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002cc:	784c                	ld	a1,176(s0)
    802002ce:	00001517          	auipc	a0,0x1
    802002d2:	bb250513          	addi	a0,a0,-1102 # 80200e80 <etext+0x446>
    802002d6:	d95ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002da:	7c4c                	ld	a1,184(s0)
    802002dc:	00001517          	auipc	a0,0x1
    802002e0:	bbc50513          	addi	a0,a0,-1092 # 80200e98 <etext+0x45e>
    802002e4:	d87ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002e8:	606c                	ld	a1,192(s0)
    802002ea:	00001517          	auipc	a0,0x1
    802002ee:	bc650513          	addi	a0,a0,-1082 # 80200eb0 <etext+0x476>
    802002f2:	d79ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002f6:	646c                	ld	a1,200(s0)
    802002f8:	00001517          	auipc	a0,0x1
    802002fc:	bd050513          	addi	a0,a0,-1072 # 80200ec8 <etext+0x48e>
    80200300:	d6bff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    80200304:	686c                	ld	a1,208(s0)
    80200306:	00001517          	auipc	a0,0x1
    8020030a:	bda50513          	addi	a0,a0,-1062 # 80200ee0 <etext+0x4a6>
    8020030e:	d5dff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200312:	6c6c                	ld	a1,216(s0)
    80200314:	00001517          	auipc	a0,0x1
    80200318:	be450513          	addi	a0,a0,-1052 # 80200ef8 <etext+0x4be>
    8020031c:	d4fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200320:	706c                	ld	a1,224(s0)
    80200322:	00001517          	auipc	a0,0x1
    80200326:	bee50513          	addi	a0,a0,-1042 # 80200f10 <etext+0x4d6>
    8020032a:	d41ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    8020032e:	746c                	ld	a1,232(s0)
    80200330:	00001517          	auipc	a0,0x1
    80200334:	bf850513          	addi	a0,a0,-1032 # 80200f28 <etext+0x4ee>
    80200338:	d33ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    8020033c:	786c                	ld	a1,240(s0)
    8020033e:	00001517          	auipc	a0,0x1
    80200342:	c0250513          	addi	a0,a0,-1022 # 80200f40 <etext+0x506>
    80200346:	d25ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020034a:	7c6c                	ld	a1,248(s0)
}
    8020034c:	6402                	ld	s0,0(sp)
    8020034e:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200350:	00001517          	auipc	a0,0x1
    80200354:	c0850513          	addi	a0,a0,-1016 # 80200f58 <etext+0x51e>
}
    80200358:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020035a:	bb01                	j	8020006a <cprintf>

000000008020035c <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    8020035c:	1141                	addi	sp,sp,-16
    8020035e:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    80200360:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    80200362:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    80200364:	00001517          	auipc	a0,0x1
    80200368:	c0c50513          	addi	a0,a0,-1012 # 80200f70 <etext+0x536>
void print_trapframe(struct trapframe *tf) {
    8020036c:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    8020036e:	cfdff0ef          	jal	ra,8020006a <cprintf>
    print_regs(&tf->gpr);
    80200372:	8522                	mv	a0,s0
    80200374:	e1dff0ef          	jal	ra,80200190 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    80200378:	10043583          	ld	a1,256(s0)
    8020037c:	00001517          	auipc	a0,0x1
    80200380:	c0c50513          	addi	a0,a0,-1012 # 80200f88 <etext+0x54e>
    80200384:	ce7ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200388:	10843583          	ld	a1,264(s0)
    8020038c:	00001517          	auipc	a0,0x1
    80200390:	c1450513          	addi	a0,a0,-1004 # 80200fa0 <etext+0x566>
    80200394:	cd7ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    80200398:	11043583          	ld	a1,272(s0)
    8020039c:	00001517          	auipc	a0,0x1
    802003a0:	c1c50513          	addi	a0,a0,-996 # 80200fb8 <etext+0x57e>
    802003a4:	cc7ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003a8:	11843583          	ld	a1,280(s0)
}
    802003ac:	6402                	ld	s0,0(sp)
    802003ae:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b0:	00001517          	auipc	a0,0x1
    802003b4:	c2050513          	addi	a0,a0,-992 # 80200fd0 <etext+0x596>
}
    802003b8:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003ba:	b945                	j	8020006a <cprintf>

00000000802003bc <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003bc:	11853783          	ld	a5,280(a0)
    switch (cause) {
    802003c0:	472d                	li	a4,11
    intptr_t cause = (tf->cause << 1) >> 1;
    802003c2:	0786                	slli	a5,a5,0x1
    802003c4:	8385                	srli	a5,a5,0x1
    switch (cause) {
    802003c6:	08f76963          	bltu	a4,a5,80200458 <interrupt_handler+0x9c>
    802003ca:	00000717          	auipc	a4,0x0
    802003ce:	78a70713          	addi	a4,a4,1930 # 80200b54 <etext+0x11a>
    802003d2:	078a                	slli	a5,a5,0x2
    802003d4:	97ba                	add	a5,a5,a4
    802003d6:	439c                	lw	a5,0(a5)
    802003d8:	97ba                	add	a5,a5,a4
    802003da:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003dc:	00001517          	auipc	a0,0x1
    802003e0:	84450513          	addi	a0,a0,-1980 # 80200c20 <etext+0x1e6>
    802003e4:	b159                	j	8020006a <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003e6:	00001517          	auipc	a0,0x1
    802003ea:	81a50513          	addi	a0,a0,-2022 # 80200c00 <etext+0x1c6>
    802003ee:	b9b5                	j	8020006a <cprintf>
            cprintf("User software interrupt\n");
    802003f0:	00000517          	auipc	a0,0x0
    802003f4:	7d050513          	addi	a0,a0,2000 # 80200bc0 <etext+0x186>
    802003f8:	b98d                	j	8020006a <cprintf>
            cprintf("Supervisor software interrupt\n");
    802003fa:	00000517          	auipc	a0,0x0
    802003fe:	7e650513          	addi	a0,a0,2022 # 80200be0 <etext+0x1a6>
    80200402:	b1a5                	j	8020006a <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
    80200404:	00001517          	auipc	a0,0x1
    80200408:	84c50513          	addi	a0,a0,-1972 # 80200c50 <etext+0x216>
    8020040c:	b9b9                	j	8020006a <cprintf>
void interrupt_handler(struct trapframe *tf) {
    8020040e:	1101                	addi	sp,sp,-32
    80200410:	e822                	sd	s0,16(sp)
    80200412:	e426                	sd	s1,8(sp)
    80200414:	e04a                	sd	s2,0(sp)
	    ticks++;
    80200416:	00004417          	auipc	s0,0x4
    8020041a:	c0a40413          	addi	s0,s0,-1014 # 80204020 <ticks>
void interrupt_handler(struct trapframe *tf) {
    8020041e:	ec06                	sd	ra,24(sp)
	    clock_set_next_event();
    80200420:	d3fff0ef          	jal	ra,8020015e <clock_set_next_event>
	    ticks++;
    80200424:	601c                	ld	a5,0(s0)
	    if(ticks==100)
    80200426:	06400713          	li	a4,100
    8020042a:	00004497          	auipc	s1,0x4
    8020042e:	be648493          	addi	s1,s1,-1050 # 80204010 <edata>
	    ticks++;
    80200432:	0785                	addi	a5,a5,1
    80200434:	00004697          	auipc	a3,0x4
    80200438:	bef6b623          	sd	a5,-1044(a3) # 80204020 <ticks>
	    if(ticks==100)
    8020043c:	00043903          	ld	s2,0(s0)
    80200440:	00e90d63          	beq	s2,a4,8020045a <interrupt_handler+0x9e>
	    if(num==10)
    80200444:	6098                	ld	a4,0(s1)
    80200446:	47a9                	li	a5,10
    80200448:	02f70f63          	beq	a4,a5,80200486 <interrupt_handler+0xca>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    8020044c:	60e2                	ld	ra,24(sp)
    8020044e:	6442                	ld	s0,16(sp)
    80200450:	64a2                	ld	s1,8(sp)
    80200452:	6902                	ld	s2,0(sp)
    80200454:	6105                	addi	sp,sp,32
    80200456:	8082                	ret
            print_trapframe(tf);
    80200458:	b711                	j	8020035c <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    8020045a:	06400593          	li	a1,100
    8020045e:	00000517          	auipc	a0,0x0
    80200462:	7e250513          	addi	a0,a0,2018 # 80200c40 <etext+0x206>
    80200466:	c05ff0ef          	jal	ra,8020006a <cprintf>
		ticks%=100;
    8020046a:	601c                	ld	a5,0(s0)
    8020046c:	0327f933          	remu	s2,a5,s2
    80200470:	00004797          	auipc	a5,0x4
    80200474:	bb27b823          	sd	s2,-1104(a5) # 80204020 <ticks>
		num++;
    80200478:	609c                	ld	a5,0(s1)
    8020047a:	0785                	addi	a5,a5,1
    8020047c:	00004717          	auipc	a4,0x4
    80200480:	b8f73a23          	sd	a5,-1132(a4) # 80204010 <edata>
    80200484:	b7c1                	j	80200444 <interrupt_handler+0x88>
}
    80200486:	6442                	ld	s0,16(sp)
    80200488:	60e2                	ld	ra,24(sp)
    8020048a:	64a2                	ld	s1,8(sp)
    8020048c:	6902                	ld	s2,0(sp)
    8020048e:	6105                	addi	sp,sp,32
		sbi_shutdown();
    80200490:	ab99                	j	802009e6 <sbi_shutdown>

0000000080200492 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    80200492:	11853783          	ld	a5,280(a0)
    80200496:	472d                	li	a4,11
    80200498:	02f76763          	bltu	a4,a5,802004c6 <exception_handler+0x34>
    8020049c:	4705                	li	a4,1
    8020049e:	00f71733          	sll	a4,a4,a5
    802004a2:	6785                	lui	a5,0x1
    802004a4:	17cd                	addi	a5,a5,-13
    802004a6:	8ff9                	and	a5,a5,a4
    802004a8:	ef91                	bnez	a5,802004c4 <exception_handler+0x32>
void exception_handler(struct trapframe *tf) {
    802004aa:	1141                	addi	sp,sp,-16
    802004ac:	e022                	sd	s0,0(sp)
    802004ae:	e406                	sd	ra,8(sp)
    802004b0:	00877793          	andi	a5,a4,8
    802004b4:	842a                	mv	s0,a0
    802004b6:	e3a1                	bnez	a5,802004f6 <exception_handler+0x64>
    802004b8:	8b11                	andi	a4,a4,4
    802004ba:	e719                	bnez	a4,802004c8 <exception_handler+0x36>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004bc:	6402                	ld	s0,0(sp)
    802004be:	60a2                	ld	ra,8(sp)
    802004c0:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004c2:	bd69                	j	8020035c <print_trapframe>
    802004c4:	8082                	ret
    802004c6:	bd59                	j	8020035c <print_trapframe>
    	    cprintf("Illegal instruction\n");
    802004c8:	00000517          	auipc	a0,0x0
    802004cc:	6c050513          	addi	a0,a0,1728 # 80200b88 <etext+0x14e>
	    cprintf("breakpoint\n");
    802004d0:	b9bff0ef          	jal	ra,8020006a <cprintf>
            cprintf("  pc 0x%08x\n", tf->epc);
    802004d4:	10843583          	ld	a1,264(s0)
    802004d8:	00000517          	auipc	a0,0x0
    802004dc:	6c850513          	addi	a0,a0,1736 # 80200ba0 <etext+0x166>
    802004e0:	b8bff0ef          	jal	ra,8020006a <cprintf>
	    tf->epc+=4;
    802004e4:	10843783          	ld	a5,264(s0)
}
    802004e8:	60a2                	ld	ra,8(sp)
	    tf->epc+=4;
    802004ea:	0791                	addi	a5,a5,4
    802004ec:	10f43423          	sd	a5,264(s0)
}
    802004f0:	6402                	ld	s0,0(sp)
    802004f2:	0141                	addi	sp,sp,16
    802004f4:	8082                	ret
	    cprintf("breakpoint\n");
    802004f6:	00000517          	auipc	a0,0x0
    802004fa:	6ba50513          	addi	a0,a0,1722 # 80200bb0 <etext+0x176>
    802004fe:	bfc9                	j	802004d0 <exception_handler+0x3e>

0000000080200500 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    80200500:	11853783          	ld	a5,280(a0)
    80200504:	0007c363          	bltz	a5,8020050a <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    80200508:	b769                	j	80200492 <exception_handler>
        interrupt_handler(tf);
    8020050a:	bd4d                	j	802003bc <interrupt_handler>

000000008020050c <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    8020050c:	14011073          	csrw	sscratch,sp
    80200510:	712d                	addi	sp,sp,-288
    80200512:	e002                	sd	zero,0(sp)
    80200514:	e406                	sd	ra,8(sp)
    80200516:	ec0e                	sd	gp,24(sp)
    80200518:	f012                	sd	tp,32(sp)
    8020051a:	f416                	sd	t0,40(sp)
    8020051c:	f81a                	sd	t1,48(sp)
    8020051e:	fc1e                	sd	t2,56(sp)
    80200520:	e0a2                	sd	s0,64(sp)
    80200522:	e4a6                	sd	s1,72(sp)
    80200524:	e8aa                	sd	a0,80(sp)
    80200526:	ecae                	sd	a1,88(sp)
    80200528:	f0b2                	sd	a2,96(sp)
    8020052a:	f4b6                	sd	a3,104(sp)
    8020052c:	f8ba                	sd	a4,112(sp)
    8020052e:	fcbe                	sd	a5,120(sp)
    80200530:	e142                	sd	a6,128(sp)
    80200532:	e546                	sd	a7,136(sp)
    80200534:	e94a                	sd	s2,144(sp)
    80200536:	ed4e                	sd	s3,152(sp)
    80200538:	f152                	sd	s4,160(sp)
    8020053a:	f556                	sd	s5,168(sp)
    8020053c:	f95a                	sd	s6,176(sp)
    8020053e:	fd5e                	sd	s7,184(sp)
    80200540:	e1e2                	sd	s8,192(sp)
    80200542:	e5e6                	sd	s9,200(sp)
    80200544:	e9ea                	sd	s10,208(sp)
    80200546:	edee                	sd	s11,216(sp)
    80200548:	f1f2                	sd	t3,224(sp)
    8020054a:	f5f6                	sd	t4,232(sp)
    8020054c:	f9fa                	sd	t5,240(sp)
    8020054e:	fdfe                	sd	t6,248(sp)
    80200550:	14001473          	csrrw	s0,sscratch,zero
    80200554:	100024f3          	csrr	s1,sstatus
    80200558:	14102973          	csrr	s2,sepc
    8020055c:	143029f3          	csrr	s3,stval
    80200560:	14202a73          	csrr	s4,scause
    80200564:	e822                	sd	s0,16(sp)
    80200566:	e226                	sd	s1,256(sp)
    80200568:	e64a                	sd	s2,264(sp)
    8020056a:	ea4e                	sd	s3,272(sp)
    8020056c:	ee52                	sd	s4,280(sp)

    move  a0, sp
    8020056e:	850a                	mv	a0,sp
    jal trap
    80200570:	f91ff0ef          	jal	ra,80200500 <trap>

0000000080200574 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    80200574:	6492                	ld	s1,256(sp)
    80200576:	6932                	ld	s2,264(sp)
    80200578:	10049073          	csrw	sstatus,s1
    8020057c:	14191073          	csrw	sepc,s2
    80200580:	60a2                	ld	ra,8(sp)
    80200582:	61e2                	ld	gp,24(sp)
    80200584:	7202                	ld	tp,32(sp)
    80200586:	72a2                	ld	t0,40(sp)
    80200588:	7342                	ld	t1,48(sp)
    8020058a:	73e2                	ld	t2,56(sp)
    8020058c:	6406                	ld	s0,64(sp)
    8020058e:	64a6                	ld	s1,72(sp)
    80200590:	6546                	ld	a0,80(sp)
    80200592:	65e6                	ld	a1,88(sp)
    80200594:	7606                	ld	a2,96(sp)
    80200596:	76a6                	ld	a3,104(sp)
    80200598:	7746                	ld	a4,112(sp)
    8020059a:	77e6                	ld	a5,120(sp)
    8020059c:	680a                	ld	a6,128(sp)
    8020059e:	68aa                	ld	a7,136(sp)
    802005a0:	694a                	ld	s2,144(sp)
    802005a2:	69ea                	ld	s3,152(sp)
    802005a4:	7a0a                	ld	s4,160(sp)
    802005a6:	7aaa                	ld	s5,168(sp)
    802005a8:	7b4a                	ld	s6,176(sp)
    802005aa:	7bea                	ld	s7,184(sp)
    802005ac:	6c0e                	ld	s8,192(sp)
    802005ae:	6cae                	ld	s9,200(sp)
    802005b0:	6d4e                	ld	s10,208(sp)
    802005b2:	6dee                	ld	s11,216(sp)
    802005b4:	7e0e                	ld	t3,224(sp)
    802005b6:	7eae                	ld	t4,232(sp)
    802005b8:	7f4e                	ld	t5,240(sp)
    802005ba:	7fee                	ld	t6,248(sp)
    802005bc:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    802005be:	10200073          	sret

00000000802005c2 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    802005c2:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005c6:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    802005c8:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005cc:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    802005ce:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    802005d2:	f022                	sd	s0,32(sp)
    802005d4:	ec26                	sd	s1,24(sp)
    802005d6:	e84a                	sd	s2,16(sp)
    802005d8:	f406                	sd	ra,40(sp)
    802005da:	e44e                	sd	s3,8(sp)
    802005dc:	84aa                	mv	s1,a0
    802005de:	892e                	mv	s2,a1
    802005e0:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    802005e4:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
    802005e6:	03067e63          	bgeu	a2,a6,80200622 <printnum+0x60>
    802005ea:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    802005ec:	00805763          	blez	s0,802005fa <printnum+0x38>
    802005f0:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    802005f2:	85ca                	mv	a1,s2
    802005f4:	854e                	mv	a0,s3
    802005f6:	9482                	jalr	s1
        while (-- width > 0)
    802005f8:	fc65                	bnez	s0,802005f0 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    802005fa:	1a02                	slli	s4,s4,0x20
    802005fc:	020a5a13          	srli	s4,s4,0x20
    80200600:	00001797          	auipc	a5,0x1
    80200604:	b7878793          	addi	a5,a5,-1160 # 80201178 <error_string+0x38>
    80200608:	9a3e                	add	s4,s4,a5
}
    8020060a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    8020060c:	000a4503          	lbu	a0,0(s4)
}
    80200610:	70a2                	ld	ra,40(sp)
    80200612:	69a2                	ld	s3,8(sp)
    80200614:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200616:	85ca                	mv	a1,s2
    80200618:	8326                	mv	t1,s1
}
    8020061a:	6942                	ld	s2,16(sp)
    8020061c:	64e2                	ld	s1,24(sp)
    8020061e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    80200620:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
    80200622:	03065633          	divu	a2,a2,a6
    80200626:	8722                	mv	a4,s0
    80200628:	f9bff0ef          	jal	ra,802005c2 <printnum>
    8020062c:	b7f9                	j	802005fa <printnum+0x38>

000000008020062e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    8020062e:	7119                	addi	sp,sp,-128
    80200630:	f4a6                	sd	s1,104(sp)
    80200632:	f0ca                	sd	s2,96(sp)
    80200634:	e8d2                	sd	s4,80(sp)
    80200636:	e4d6                	sd	s5,72(sp)
    80200638:	e0da                	sd	s6,64(sp)
    8020063a:	fc5e                	sd	s7,56(sp)
    8020063c:	f862                	sd	s8,48(sp)
    8020063e:	f06a                	sd	s10,32(sp)
    80200640:	fc86                	sd	ra,120(sp)
    80200642:	f8a2                	sd	s0,112(sp)
    80200644:	ecce                	sd	s3,88(sp)
    80200646:	f466                	sd	s9,40(sp)
    80200648:	ec6e                	sd	s11,24(sp)
    8020064a:	892a                	mv	s2,a0
    8020064c:	84ae                	mv	s1,a1
    8020064e:	8d32                	mv	s10,a2
    80200650:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    80200652:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    80200654:	00001a17          	auipc	s4,0x1
    80200658:	990a0a13          	addi	s4,s4,-1648 # 80200fe4 <etext+0x5aa>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
    8020065c:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200660:	00001c17          	auipc	s8,0x1
    80200664:	ae0c0c13          	addi	s8,s8,-1312 # 80201140 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200668:	000d4503          	lbu	a0,0(s10)
    8020066c:	02500793          	li	a5,37
    80200670:	001d0413          	addi	s0,s10,1
    80200674:	00f50e63          	beq	a0,a5,80200690 <vprintfmt+0x62>
            if (ch == '\0') {
    80200678:	c521                	beqz	a0,802006c0 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    8020067a:	02500993          	li	s3,37
    8020067e:	a011                	j	80200682 <vprintfmt+0x54>
            if (ch == '\0') {
    80200680:	c121                	beqz	a0,802006c0 <vprintfmt+0x92>
            putch(ch, putdat);
    80200682:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200684:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    80200686:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200688:	fff44503          	lbu	a0,-1(s0)
    8020068c:	ff351ae3          	bne	a0,s3,80200680 <vprintfmt+0x52>
    80200690:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    80200694:	02000793          	li	a5,32
        lflag = altflag = 0;
    80200698:	4981                	li	s3,0
    8020069a:	4801                	li	a6,0
        width = precision = -1;
    8020069c:	5cfd                	li	s9,-1
    8020069e:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
    802006a0:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
    802006a4:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
    802006a6:	fdd6069b          	addiw	a3,a2,-35
    802006aa:	0ff6f693          	andi	a3,a3,255
    802006ae:	00140d13          	addi	s10,s0,1
    802006b2:	1ed5ef63          	bltu	a1,a3,802008b0 <vprintfmt+0x282>
    802006b6:	068a                	slli	a3,a3,0x2
    802006b8:	96d2                	add	a3,a3,s4
    802006ba:	4294                	lw	a3,0(a3)
    802006bc:	96d2                	add	a3,a3,s4
    802006be:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    802006c0:	70e6                	ld	ra,120(sp)
    802006c2:	7446                	ld	s0,112(sp)
    802006c4:	74a6                	ld	s1,104(sp)
    802006c6:	7906                	ld	s2,96(sp)
    802006c8:	69e6                	ld	s3,88(sp)
    802006ca:	6a46                	ld	s4,80(sp)
    802006cc:	6aa6                	ld	s5,72(sp)
    802006ce:	6b06                	ld	s6,64(sp)
    802006d0:	7be2                	ld	s7,56(sp)
    802006d2:	7c42                	ld	s8,48(sp)
    802006d4:	7ca2                	ld	s9,40(sp)
    802006d6:	7d02                	ld	s10,32(sp)
    802006d8:	6de2                	ld	s11,24(sp)
    802006da:	6109                	addi	sp,sp,128
    802006dc:	8082                	ret
            padc = '-';
    802006de:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
    802006e0:	00144603          	lbu	a2,1(s0)
    802006e4:	846a                	mv	s0,s10
    802006e6:	b7c1                	j	802006a6 <vprintfmt+0x78>
            precision = va_arg(ap, int);
    802006e8:	000aac83          	lw	s9,0(s5)
            goto process_precision;
    802006ec:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    802006f0:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
    802006f2:	846a                	mv	s0,s10
            if (width < 0)
    802006f4:	fa0dd9e3          	bgez	s11,802006a6 <vprintfmt+0x78>
                width = precision, precision = -1;
    802006f8:	8de6                	mv	s11,s9
    802006fa:	5cfd                	li	s9,-1
    802006fc:	b76d                	j	802006a6 <vprintfmt+0x78>
            if (width < 0)
    802006fe:	fffdc693          	not	a3,s11
    80200702:	96fd                	srai	a3,a3,0x3f
    80200704:	00ddfdb3          	and	s11,s11,a3
    80200708:	00144603          	lbu	a2,1(s0)
    8020070c:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
    8020070e:	846a                	mv	s0,s10
    80200710:	bf59                	j	802006a6 <vprintfmt+0x78>
    if (lflag >= 2) {
    80200712:	4705                	li	a4,1
    80200714:	008a8593          	addi	a1,s5,8
    80200718:	01074463          	blt	a4,a6,80200720 <vprintfmt+0xf2>
    else if (lflag) {
    8020071c:	22080863          	beqz	a6,8020094c <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
    80200720:	000ab603          	ld	a2,0(s5)
    80200724:	46c1                	li	a3,16
    80200726:	8aae                	mv	s5,a1
    80200728:	a291                	j	8020086c <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
    8020072a:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
    8020072e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    80200732:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    80200734:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    80200738:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    8020073c:	fad56ce3          	bltu	a0,a3,802006f4 <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
    80200740:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    80200742:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
    80200746:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
    8020074a:	0196873b          	addw	a4,a3,s9
    8020074e:	0017171b          	slliw	a4,a4,0x1
    80200752:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
    80200756:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
    8020075a:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
    8020075e:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    80200762:	fcd57fe3          	bgeu	a0,a3,80200740 <vprintfmt+0x112>
    80200766:	b779                	j	802006f4 <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
    80200768:	000aa503          	lw	a0,0(s5)
    8020076c:	85a6                	mv	a1,s1
    8020076e:	0aa1                	addi	s5,s5,8
    80200770:	9902                	jalr	s2
            break;
    80200772:	bddd                	j	80200668 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200774:	4705                	li	a4,1
    80200776:	008a8993          	addi	s3,s5,8
    8020077a:	01074463          	blt	a4,a6,80200782 <vprintfmt+0x154>
    else if (lflag) {
    8020077e:	1c080463          	beqz	a6,80200946 <vprintfmt+0x318>
        return va_arg(*ap, long);
    80200782:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
    80200786:	1c044a63          	bltz	s0,8020095a <vprintfmt+0x32c>
            num = getint(&ap, lflag);
    8020078a:	8622                	mv	a2,s0
    8020078c:	8ace                	mv	s5,s3
    8020078e:	46a9                	li	a3,10
    80200790:	a8f1                	j	8020086c <vprintfmt+0x23e>
            err = va_arg(ap, int);
    80200792:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200796:	4719                	li	a4,6
            err = va_arg(ap, int);
    80200798:	0aa1                	addi	s5,s5,8
            if (err < 0) {
    8020079a:	41f7d69b          	sraiw	a3,a5,0x1f
    8020079e:	8fb5                	xor	a5,a5,a3
    802007a0:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    802007a4:	12d74963          	blt	a4,a3,802008d6 <vprintfmt+0x2a8>
    802007a8:	00369793          	slli	a5,a3,0x3
    802007ac:	97e2                	add	a5,a5,s8
    802007ae:	639c                	ld	a5,0(a5)
    802007b0:	12078363          	beqz	a5,802008d6 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
    802007b4:	86be                	mv	a3,a5
    802007b6:	00001617          	auipc	a2,0x1
    802007ba:	a7260613          	addi	a2,a2,-1422 # 80201228 <error_string+0xe8>
    802007be:	85a6                	mv	a1,s1
    802007c0:	854a                	mv	a0,s2
    802007c2:	1cc000ef          	jal	ra,8020098e <printfmt>
    802007c6:	b54d                	j	80200668 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
    802007c8:	000ab603          	ld	a2,0(s5)
    802007cc:	0aa1                	addi	s5,s5,8
    802007ce:	1a060163          	beqz	a2,80200970 <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
    802007d2:	00160413          	addi	s0,a2,1
    802007d6:	15b05763          	blez	s11,80200924 <vprintfmt+0x2f6>
    802007da:	02d00593          	li	a1,45
    802007de:	10b79d63          	bne	a5,a1,802008f8 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802007e2:	00064783          	lbu	a5,0(a2)
    802007e6:	0007851b          	sext.w	a0,a5
    802007ea:	c905                	beqz	a0,8020081a <vprintfmt+0x1ec>
    802007ec:	000cc563          	bltz	s9,802007f6 <vprintfmt+0x1c8>
    802007f0:	3cfd                	addiw	s9,s9,-1
    802007f2:	036c8263          	beq	s9,s6,80200816 <vprintfmt+0x1e8>
                    putch('?', putdat);
    802007f6:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    802007f8:	14098f63          	beqz	s3,80200956 <vprintfmt+0x328>
    802007fc:	3781                	addiw	a5,a5,-32
    802007fe:	14fbfc63          	bgeu	s7,a5,80200956 <vprintfmt+0x328>
                    putch('?', putdat);
    80200802:	03f00513          	li	a0,63
    80200806:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200808:	0405                	addi	s0,s0,1
    8020080a:	fff44783          	lbu	a5,-1(s0)
    8020080e:	3dfd                	addiw	s11,s11,-1
    80200810:	0007851b          	sext.w	a0,a5
    80200814:	fd61                	bnez	a0,802007ec <vprintfmt+0x1be>
            for (; width > 0; width --) {
    80200816:	e5b059e3          	blez	s11,80200668 <vprintfmt+0x3a>
    8020081a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    8020081c:	85a6                	mv	a1,s1
    8020081e:	02000513          	li	a0,32
    80200822:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200824:	e40d82e3          	beqz	s11,80200668 <vprintfmt+0x3a>
    80200828:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    8020082a:	85a6                	mv	a1,s1
    8020082c:	02000513          	li	a0,32
    80200830:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200832:	fe0d94e3          	bnez	s11,8020081a <vprintfmt+0x1ec>
    80200836:	bd0d                	j	80200668 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200838:	4705                	li	a4,1
    8020083a:	008a8593          	addi	a1,s5,8
    8020083e:	01074463          	blt	a4,a6,80200846 <vprintfmt+0x218>
    else if (lflag) {
    80200842:	0e080863          	beqz	a6,80200932 <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
    80200846:	000ab603          	ld	a2,0(s5)
    8020084a:	46a1                	li	a3,8
    8020084c:	8aae                	mv	s5,a1
    8020084e:	a839                	j	8020086c <vprintfmt+0x23e>
            putch('0', putdat);
    80200850:	03000513          	li	a0,48
    80200854:	85a6                	mv	a1,s1
    80200856:	e03e                	sd	a5,0(sp)
    80200858:	9902                	jalr	s2
            putch('x', putdat);
    8020085a:	85a6                	mv	a1,s1
    8020085c:	07800513          	li	a0,120
    80200860:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    80200862:	0aa1                	addi	s5,s5,8
    80200864:	ff8ab603          	ld	a2,-8(s5)
            goto number;
    80200868:	6782                	ld	a5,0(sp)
    8020086a:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
    8020086c:	2781                	sext.w	a5,a5
    8020086e:	876e                	mv	a4,s11
    80200870:	85a6                	mv	a1,s1
    80200872:	854a                	mv	a0,s2
    80200874:	d4fff0ef          	jal	ra,802005c2 <printnum>
            break;
    80200878:	bbc5                	j	80200668 <vprintfmt+0x3a>
            lflag ++;
    8020087a:	00144603          	lbu	a2,1(s0)
    8020087e:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200880:	846a                	mv	s0,s10
            goto reswitch;
    80200882:	b515                	j	802006a6 <vprintfmt+0x78>
            goto reswitch;
    80200884:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    80200888:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
    8020088a:	846a                	mv	s0,s10
            goto reswitch;
    8020088c:	bd29                	j	802006a6 <vprintfmt+0x78>
            putch(ch, putdat);
    8020088e:	85a6                	mv	a1,s1
    80200890:	02500513          	li	a0,37
    80200894:	9902                	jalr	s2
            break;
    80200896:	bbc9                	j	80200668 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200898:	4705                	li	a4,1
    8020089a:	008a8593          	addi	a1,s5,8
    8020089e:	01074463          	blt	a4,a6,802008a6 <vprintfmt+0x278>
    else if (lflag) {
    802008a2:	08080d63          	beqz	a6,8020093c <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
    802008a6:	000ab603          	ld	a2,0(s5)
    802008aa:	46a9                	li	a3,10
    802008ac:	8aae                	mv	s5,a1
    802008ae:	bf7d                	j	8020086c <vprintfmt+0x23e>
            putch('%', putdat);
    802008b0:	85a6                	mv	a1,s1
    802008b2:	02500513          	li	a0,37
    802008b6:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    802008b8:	fff44703          	lbu	a4,-1(s0)
    802008bc:	02500793          	li	a5,37
    802008c0:	8d22                	mv	s10,s0
    802008c2:	daf703e3          	beq	a4,a5,80200668 <vprintfmt+0x3a>
    802008c6:	02500713          	li	a4,37
    802008ca:	1d7d                	addi	s10,s10,-1
    802008cc:	fffd4783          	lbu	a5,-1(s10)
    802008d0:	fee79de3          	bne	a5,a4,802008ca <vprintfmt+0x29c>
    802008d4:	bb51                	j	80200668 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    802008d6:	00001617          	auipc	a2,0x1
    802008da:	94260613          	addi	a2,a2,-1726 # 80201218 <error_string+0xd8>
    802008de:	85a6                	mv	a1,s1
    802008e0:	854a                	mv	a0,s2
    802008e2:	0ac000ef          	jal	ra,8020098e <printfmt>
    802008e6:	b349                	j	80200668 <vprintfmt+0x3a>
                p = "(null)";
    802008e8:	00001617          	auipc	a2,0x1
    802008ec:	92860613          	addi	a2,a2,-1752 # 80201210 <error_string+0xd0>
            if (width > 0 && padc != '-') {
    802008f0:	00001417          	auipc	s0,0x1
    802008f4:	92140413          	addi	s0,s0,-1759 # 80201211 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008f8:	8532                	mv	a0,a2
    802008fa:	85e6                	mv	a1,s9
    802008fc:	e032                	sd	a2,0(sp)
    802008fe:	e43e                	sd	a5,8(sp)
    80200900:	102000ef          	jal	ra,80200a02 <strnlen>
    80200904:	40ad8dbb          	subw	s11,s11,a0
    80200908:	6602                	ld	a2,0(sp)
    8020090a:	01b05d63          	blez	s11,80200924 <vprintfmt+0x2f6>
    8020090e:	67a2                	ld	a5,8(sp)
    80200910:	2781                	sext.w	a5,a5
    80200912:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
    80200914:	6522                	ld	a0,8(sp)
    80200916:	85a6                	mv	a1,s1
    80200918:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020091a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    8020091c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020091e:	6602                	ld	a2,0(sp)
    80200920:	fe0d9ae3          	bnez	s11,80200914 <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200924:	00064783          	lbu	a5,0(a2)
    80200928:	0007851b          	sext.w	a0,a5
    8020092c:	ec0510e3          	bnez	a0,802007ec <vprintfmt+0x1be>
    80200930:	bb25                	j	80200668 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
    80200932:	000ae603          	lwu	a2,0(s5)
    80200936:	46a1                	li	a3,8
    80200938:	8aae                	mv	s5,a1
    8020093a:	bf0d                	j	8020086c <vprintfmt+0x23e>
    8020093c:	000ae603          	lwu	a2,0(s5)
    80200940:	46a9                	li	a3,10
    80200942:	8aae                	mv	s5,a1
    80200944:	b725                	j	8020086c <vprintfmt+0x23e>
        return va_arg(*ap, int);
    80200946:	000aa403          	lw	s0,0(s5)
    8020094a:	bd35                	j	80200786 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
    8020094c:	000ae603          	lwu	a2,0(s5)
    80200950:	46c1                	li	a3,16
    80200952:	8aae                	mv	s5,a1
    80200954:	bf21                	j	8020086c <vprintfmt+0x23e>
                    putch(ch, putdat);
    80200956:	9902                	jalr	s2
    80200958:	bd45                	j	80200808 <vprintfmt+0x1da>
                putch('-', putdat);
    8020095a:	85a6                	mv	a1,s1
    8020095c:	02d00513          	li	a0,45
    80200960:	e03e                	sd	a5,0(sp)
    80200962:	9902                	jalr	s2
                num = -(long long)num;
    80200964:	8ace                	mv	s5,s3
    80200966:	40800633          	neg	a2,s0
    8020096a:	46a9                	li	a3,10
    8020096c:	6782                	ld	a5,0(sp)
    8020096e:	bdfd                	j	8020086c <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
    80200970:	01b05663          	blez	s11,8020097c <vprintfmt+0x34e>
    80200974:	02d00693          	li	a3,45
    80200978:	f6d798e3          	bne	a5,a3,802008e8 <vprintfmt+0x2ba>
    8020097c:	00001417          	auipc	s0,0x1
    80200980:	89540413          	addi	s0,s0,-1899 # 80201211 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200984:	02800513          	li	a0,40
    80200988:	02800793          	li	a5,40
    8020098c:	b585                	j	802007ec <vprintfmt+0x1be>

000000008020098e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    8020098e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    80200990:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200994:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200996:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200998:	ec06                	sd	ra,24(sp)
    8020099a:	f83a                	sd	a4,48(sp)
    8020099c:	fc3e                	sd	a5,56(sp)
    8020099e:	e0c2                	sd	a6,64(sp)
    802009a0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    802009a2:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    802009a4:	c8bff0ef          	jal	ra,8020062e <vprintfmt>
}
    802009a8:	60e2                	ld	ra,24(sp)
    802009aa:	6161                	addi	sp,sp,80
    802009ac:	8082                	ret

00000000802009ae <sbi_console_putchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
    802009ae:	00003797          	auipc	a5,0x3
    802009b2:	65278793          	addi	a5,a5,1618 # 80204000 <bootstacktop>
    __asm__ volatile (
    802009b6:	6398                	ld	a4,0(a5)
    802009b8:	4781                	li	a5,0
    802009ba:	88ba                	mv	a7,a4
    802009bc:	852a                	mv	a0,a0
    802009be:	85be                	mv	a1,a5
    802009c0:	863e                	mv	a2,a5
    802009c2:	00000073          	ecall
    802009c6:	87aa                	mv	a5,a0
}
    802009c8:	8082                	ret

00000000802009ca <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
    802009ca:	00003797          	auipc	a5,0x3
    802009ce:	64e78793          	addi	a5,a5,1614 # 80204018 <SBI_SET_TIMER>
    __asm__ volatile (
    802009d2:	6398                	ld	a4,0(a5)
    802009d4:	4781                	li	a5,0
    802009d6:	88ba                	mv	a7,a4
    802009d8:	852a                	mv	a0,a0
    802009da:	85be                	mv	a1,a5
    802009dc:	863e                	mv	a2,a5
    802009de:	00000073          	ecall
    802009e2:	87aa                	mv	a5,a0
}
    802009e4:	8082                	ret

00000000802009e6 <sbi_shutdown>:


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    802009e6:	00003797          	auipc	a5,0x3
    802009ea:	62278793          	addi	a5,a5,1570 # 80204008 <SBI_SHUTDOWN>
    __asm__ volatile (
    802009ee:	6398                	ld	a4,0(a5)
    802009f0:	4781                	li	a5,0
    802009f2:	88ba                	mv	a7,a4
    802009f4:	853e                	mv	a0,a5
    802009f6:	85be                	mv	a1,a5
    802009f8:	863e                	mv	a2,a5
    802009fa:	00000073          	ecall
    802009fe:	87aa                	mv	a5,a0
    80200a00:	8082                	ret

0000000080200a02 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
    80200a02:	c185                	beqz	a1,80200a22 <strnlen+0x20>
    80200a04:	00054783          	lbu	a5,0(a0)
    80200a08:	cf89                	beqz	a5,80200a22 <strnlen+0x20>
    size_t cnt = 0;
    80200a0a:	4781                	li	a5,0
    80200a0c:	a021                	j	80200a14 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
    80200a0e:	00074703          	lbu	a4,0(a4)
    80200a12:	c711                	beqz	a4,80200a1e <strnlen+0x1c>
        cnt ++;
    80200a14:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    80200a16:	00f50733          	add	a4,a0,a5
    80200a1a:	fef59ae3          	bne	a1,a5,80200a0e <strnlen+0xc>
    }
    return cnt;
}
    80200a1e:	853e                	mv	a0,a5
    80200a20:	8082                	ret
    size_t cnt = 0;
    80200a22:	4781                	li	a5,0
}
    80200a24:	853e                	mv	a0,a5
    80200a26:	8082                	ret

0000000080200a28 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200a28:	ca01                	beqz	a2,80200a38 <memset+0x10>
    80200a2a:	962a                	add	a2,a2,a0
    char *p = s;
    80200a2c:	87aa                	mv	a5,a0
        *p ++ = c;
    80200a2e:	0785                	addi	a5,a5,1
    80200a30:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    80200a34:	fec79de3          	bne	a5,a2,80200a2e <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200a38:	8082                	ret
