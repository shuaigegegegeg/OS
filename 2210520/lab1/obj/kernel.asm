
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
    80200022:	1f3000ef          	jal	ra,80200a14 <memset>

    cons_init();  // init the console
    80200026:	148000ef          	jal	ra,8020016e <cons_init>

    const char *message = "(THU.CST) os is loading ...\n";
    cprintf("%s\n\n", message);
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	9fe58593          	addi	a1,a1,-1538 # 80200a28 <etext+0x2>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	a1650513          	addi	a0,a0,-1514 # 80200a48 <etext+0x22>
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
    80200092:	588000ef          	jal	ra,8020061a <vprintfmt>
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
    802000a4:	9b050513          	addi	a0,a0,-1616 # 80200a50 <etext+0x2a>
void print_kerninfo(void) {
    802000a8:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
    802000aa:	fc1ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  entry  0x%016x (virtual)\n", kern_init);
    802000ae:	00000597          	auipc	a1,0x0
    802000b2:	f5c58593          	addi	a1,a1,-164 # 8020000a <kern_init>
    802000b6:	00001517          	auipc	a0,0x1
    802000ba:	9ba50513          	addi	a0,a0,-1606 # 80200a70 <etext+0x4a>
    802000be:	fadff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  etext  0x%016x (virtual)\n", etext);
    802000c2:	00001597          	auipc	a1,0x1
    802000c6:	96458593          	addi	a1,a1,-1692 # 80200a26 <etext>
    802000ca:	00001517          	auipc	a0,0x1
    802000ce:	9c650513          	addi	a0,a0,-1594 # 80200a90 <etext+0x6a>
    802000d2:	f99ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  edata  0x%016x (virtual)\n", edata);
    802000d6:	00004597          	auipc	a1,0x4
    802000da:	f3a58593          	addi	a1,a1,-198 # 80204010 <edata>
    802000de:	00001517          	auipc	a0,0x1
    802000e2:	9d250513          	addi	a0,a0,-1582 # 80200ab0 <etext+0x8a>
    802000e6:	f85ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  end    0x%016x (virtual)\n", end);
    802000ea:	00004597          	auipc	a1,0x4
    802000ee:	f3e58593          	addi	a1,a1,-194 # 80204028 <end>
    802000f2:	00001517          	auipc	a0,0x1
    802000f6:	9de50513          	addi	a0,a0,-1570 # 80200ad0 <etext+0xaa>
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
    80200124:	9d050513          	addi	a0,a0,-1584 # 80200af0 <etext+0xca>
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
    80200144:	073000ef          	jal	ra,802009b6 <sbi_set_timer>
}
    80200148:	60a2                	ld	ra,8(sp)
    ticks = 0;
    8020014a:	00004797          	auipc	a5,0x4
    8020014e:	ec07bb23          	sd	zero,-298(a5) # 80204020 <ticks>
    cprintf("++ setup timer interrupts\n");
    80200152:	00001517          	auipc	a0,0x1
    80200156:	9ce50513          	addi	a0,a0,-1586 # 80200b20 <etext+0xfa>
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
    8020016a:	04d0006f          	j	802009b6 <sbi_set_timer>

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
    80200174:	0270006f          	j	8020099a <sbi_console_putchar>

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
    80200186:	37678793          	addi	a5,a5,886 # 802004f8 <__alltraps>
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
    8020019c:	ae050513          	addi	a0,a0,-1312 # 80200c78 <etext+0x252>
void print_regs(struct pushregs *gpr) {
    802001a0:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a2:	ec9ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001a6:	640c                	ld	a1,8(s0)
    802001a8:	00001517          	auipc	a0,0x1
    802001ac:	ae850513          	addi	a0,a0,-1304 # 80200c90 <etext+0x26a>
    802001b0:	ebbff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001b4:	680c                	ld	a1,16(s0)
    802001b6:	00001517          	auipc	a0,0x1
    802001ba:	af250513          	addi	a0,a0,-1294 # 80200ca8 <etext+0x282>
    802001be:	eadff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001c2:	6c0c                	ld	a1,24(s0)
    802001c4:	00001517          	auipc	a0,0x1
    802001c8:	afc50513          	addi	a0,a0,-1284 # 80200cc0 <etext+0x29a>
    802001cc:	e9fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001d0:	700c                	ld	a1,32(s0)
    802001d2:	00001517          	auipc	a0,0x1
    802001d6:	b0650513          	addi	a0,a0,-1274 # 80200cd8 <etext+0x2b2>
    802001da:	e91ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001de:	740c                	ld	a1,40(s0)
    802001e0:	00001517          	auipc	a0,0x1
    802001e4:	b1050513          	addi	a0,a0,-1264 # 80200cf0 <etext+0x2ca>
    802001e8:	e83ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001ec:	780c                	ld	a1,48(s0)
    802001ee:	00001517          	auipc	a0,0x1
    802001f2:	b1a50513          	addi	a0,a0,-1254 # 80200d08 <etext+0x2e2>
    802001f6:	e75ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    802001fa:	7c0c                	ld	a1,56(s0)
    802001fc:	00001517          	auipc	a0,0x1
    80200200:	b2450513          	addi	a0,a0,-1244 # 80200d20 <etext+0x2fa>
    80200204:	e67ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    80200208:	602c                	ld	a1,64(s0)
    8020020a:	00001517          	auipc	a0,0x1
    8020020e:	b2e50513          	addi	a0,a0,-1234 # 80200d38 <etext+0x312>
    80200212:	e59ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    80200216:	642c                	ld	a1,72(s0)
    80200218:	00001517          	auipc	a0,0x1
    8020021c:	b3850513          	addi	a0,a0,-1224 # 80200d50 <etext+0x32a>
    80200220:	e4bff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    80200224:	682c                	ld	a1,80(s0)
    80200226:	00001517          	auipc	a0,0x1
    8020022a:	b4250513          	addi	a0,a0,-1214 # 80200d68 <etext+0x342>
    8020022e:	e3dff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200232:	6c2c                	ld	a1,88(s0)
    80200234:	00001517          	auipc	a0,0x1
    80200238:	b4c50513          	addi	a0,a0,-1204 # 80200d80 <etext+0x35a>
    8020023c:	e2fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200240:	702c                	ld	a1,96(s0)
    80200242:	00001517          	auipc	a0,0x1
    80200246:	b5650513          	addi	a0,a0,-1194 # 80200d98 <etext+0x372>
    8020024a:	e21ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    8020024e:	742c                	ld	a1,104(s0)
    80200250:	00001517          	auipc	a0,0x1
    80200254:	b6050513          	addi	a0,a0,-1184 # 80200db0 <etext+0x38a>
    80200258:	e13ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    8020025c:	782c                	ld	a1,112(s0)
    8020025e:	00001517          	auipc	a0,0x1
    80200262:	b6a50513          	addi	a0,a0,-1174 # 80200dc8 <etext+0x3a2>
    80200266:	e05ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    8020026a:	7c2c                	ld	a1,120(s0)
    8020026c:	00001517          	auipc	a0,0x1
    80200270:	b7450513          	addi	a0,a0,-1164 # 80200de0 <etext+0x3ba>
    80200274:	df7ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    80200278:	604c                	ld	a1,128(s0)
    8020027a:	00001517          	auipc	a0,0x1
    8020027e:	b7e50513          	addi	a0,a0,-1154 # 80200df8 <etext+0x3d2>
    80200282:	de9ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    80200286:	644c                	ld	a1,136(s0)
    80200288:	00001517          	auipc	a0,0x1
    8020028c:	b8850513          	addi	a0,a0,-1144 # 80200e10 <etext+0x3ea>
    80200290:	ddbff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    80200294:	684c                	ld	a1,144(s0)
    80200296:	00001517          	auipc	a0,0x1
    8020029a:	b9250513          	addi	a0,a0,-1134 # 80200e28 <etext+0x402>
    8020029e:	dcdff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002a2:	6c4c                	ld	a1,152(s0)
    802002a4:	00001517          	auipc	a0,0x1
    802002a8:	b9c50513          	addi	a0,a0,-1124 # 80200e40 <etext+0x41a>
    802002ac:	dbfff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002b0:	704c                	ld	a1,160(s0)
    802002b2:	00001517          	auipc	a0,0x1
    802002b6:	ba650513          	addi	a0,a0,-1114 # 80200e58 <etext+0x432>
    802002ba:	db1ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002be:	744c                	ld	a1,168(s0)
    802002c0:	00001517          	auipc	a0,0x1
    802002c4:	bb050513          	addi	a0,a0,-1104 # 80200e70 <etext+0x44a>
    802002c8:	da3ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002cc:	784c                	ld	a1,176(s0)
    802002ce:	00001517          	auipc	a0,0x1
    802002d2:	bba50513          	addi	a0,a0,-1094 # 80200e88 <etext+0x462>
    802002d6:	d95ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002da:	7c4c                	ld	a1,184(s0)
    802002dc:	00001517          	auipc	a0,0x1
    802002e0:	bc450513          	addi	a0,a0,-1084 # 80200ea0 <etext+0x47a>
    802002e4:	d87ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002e8:	606c                	ld	a1,192(s0)
    802002ea:	00001517          	auipc	a0,0x1
    802002ee:	bce50513          	addi	a0,a0,-1074 # 80200eb8 <etext+0x492>
    802002f2:	d79ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002f6:	646c                	ld	a1,200(s0)
    802002f8:	00001517          	auipc	a0,0x1
    802002fc:	bd850513          	addi	a0,a0,-1064 # 80200ed0 <etext+0x4aa>
    80200300:	d6bff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    80200304:	686c                	ld	a1,208(s0)
    80200306:	00001517          	auipc	a0,0x1
    8020030a:	be250513          	addi	a0,a0,-1054 # 80200ee8 <etext+0x4c2>
    8020030e:	d5dff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200312:	6c6c                	ld	a1,216(s0)
    80200314:	00001517          	auipc	a0,0x1
    80200318:	bec50513          	addi	a0,a0,-1044 # 80200f00 <etext+0x4da>
    8020031c:	d4fff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200320:	706c                	ld	a1,224(s0)
    80200322:	00001517          	auipc	a0,0x1
    80200326:	bf650513          	addi	a0,a0,-1034 # 80200f18 <etext+0x4f2>
    8020032a:	d41ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    8020032e:	746c                	ld	a1,232(s0)
    80200330:	00001517          	auipc	a0,0x1
    80200334:	c0050513          	addi	a0,a0,-1024 # 80200f30 <etext+0x50a>
    80200338:	d33ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    8020033c:	786c                	ld	a1,240(s0)
    8020033e:	00001517          	auipc	a0,0x1
    80200342:	c0a50513          	addi	a0,a0,-1014 # 80200f48 <etext+0x522>
    80200346:	d25ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020034a:	7c6c                	ld	a1,248(s0)
}
    8020034c:	6402                	ld	s0,0(sp)
    8020034e:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200350:	00001517          	auipc	a0,0x1
    80200354:	c1050513          	addi	a0,a0,-1008 # 80200f60 <etext+0x53a>
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
    80200368:	c1450513          	addi	a0,a0,-1004 # 80200f78 <etext+0x552>
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
    80200380:	c1450513          	addi	a0,a0,-1004 # 80200f90 <etext+0x56a>
    80200384:	ce7ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    80200388:	10843583          	ld	a1,264(s0)
    8020038c:	00001517          	auipc	a0,0x1
    80200390:	c1c50513          	addi	a0,a0,-996 # 80200fa8 <etext+0x582>
    80200394:	cd7ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    80200398:	11043583          	ld	a1,272(s0)
    8020039c:	00001517          	auipc	a0,0x1
    802003a0:	c2450513          	addi	a0,a0,-988 # 80200fc0 <etext+0x59a>
    802003a4:	cc7ff0ef          	jal	ra,8020006a <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003a8:	11843583          	ld	a1,280(s0)
}
    802003ac:	6402                	ld	s0,0(sp)
    802003ae:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b0:	00001517          	auipc	a0,0x1
    802003b4:	c2850513          	addi	a0,a0,-984 # 80200fd8 <etext+0x5b2>
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
    802003c6:	08f76463          	bltu	a4,a5,8020044e <interrupt_handler+0x92>
    802003ca:	00000717          	auipc	a4,0x0
    802003ce:	77270713          	addi	a4,a4,1906 # 80200b3c <etext+0x116>
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
    802003e0:	84c50513          	addi	a0,a0,-1972 # 80200c28 <etext+0x202>
    802003e4:	b159                	j	8020006a <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003e6:	00001517          	auipc	a0,0x1
    802003ea:	82250513          	addi	a0,a0,-2014 # 80200c08 <etext+0x1e2>
    802003ee:	b9b5                	j	8020006a <cprintf>
            cprintf("User software interrupt\n");
    802003f0:	00000517          	auipc	a0,0x0
    802003f4:	7d850513          	addi	a0,a0,2008 # 80200bc8 <etext+0x1a2>
    802003f8:	b98d                	j	8020006a <cprintf>
            cprintf("Supervisor software interrupt\n");
    802003fa:	00000517          	auipc	a0,0x0
    802003fe:	7ee50513          	addi	a0,a0,2030 # 80200be8 <etext+0x1c2>
    80200402:	b1a5                	j	8020006a <cprintf>
            break;
        case IRQ_U_EXT:
            cprintf("User software interrupt\n");
            break;
        case IRQ_S_EXT:
            cprintf("Supervisor external interrupt\n");
    80200404:	00001517          	auipc	a0,0x1
    80200408:	85450513          	addi	a0,a0,-1964 # 80200c58 <etext+0x232>
    8020040c:	b9b9                	j	8020006a <cprintf>
void interrupt_handler(struct trapframe *tf) {
    8020040e:	1141                	addi	sp,sp,-16
    80200410:	e022                	sd	s0,0(sp)
    80200412:	e406                	sd	ra,8(sp)
            clock_set_next_event();
    80200414:	d4bff0ef          	jal	ra,8020015e <clock_set_next_event>
            ticks=ticks+1;
    80200418:	00004717          	auipc	a4,0x4
    8020041c:	c0870713          	addi	a4,a4,-1016 # 80204020 <ticks>
    80200420:	631c                	ld	a5,0(a4)
            if(ticks==TICK_NUM)
    80200422:	06400693          	li	a3,100
    80200426:	00004417          	auipc	s0,0x4
    8020042a:	bea40413          	addi	s0,s0,-1046 # 80204010 <edata>
            ticks=ticks+1;
    8020042e:	0785                	addi	a5,a5,1
    80200430:	00004617          	auipc	a2,0x4
    80200434:	bef63823          	sd	a5,-1040(a2) # 80204020 <ticks>
            if(ticks==TICK_NUM)
    80200438:	631c                	ld	a5,0(a4)
    8020043a:	00d78b63          	beq	a5,a3,80200450 <interrupt_handler+0x94>
            if(num==10)
    8020043e:	6018                	ld	a4,0(s0)
    80200440:	47a9                	li	a5,10
    80200442:	02f70a63          	beq	a4,a5,80200476 <interrupt_handler+0xba>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200446:	60a2                	ld	ra,8(sp)
    80200448:	6402                	ld	s0,0(sp)
    8020044a:	0141                	addi	sp,sp,16
    8020044c:	8082                	ret
            print_trapframe(tf);
    8020044e:	b739                	j	8020035c <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    80200450:	06400593          	li	a1,100
    80200454:	00000517          	auipc	a0,0x0
    80200458:	7f450513          	addi	a0,a0,2036 # 80200c48 <etext+0x222>
    8020045c:	c0fff0ef          	jal	ra,8020006a <cprintf>
            	ticks=0;
    80200460:	00004797          	auipc	a5,0x4
    80200464:	bc07b023          	sd	zero,-1088(a5) # 80204020 <ticks>
            	num++;
    80200468:	601c                	ld	a5,0(s0)
    8020046a:	0785                	addi	a5,a5,1
    8020046c:	00004717          	auipc	a4,0x4
    80200470:	baf73223          	sd	a5,-1116(a4) # 80204010 <edata>
    80200474:	b7e9                	j	8020043e <interrupt_handler+0x82>
}
    80200476:	6402                	ld	s0,0(sp)
    80200478:	60a2                	ld	ra,8(sp)
    8020047a:	0141                	addi	sp,sp,16
            	sbi_shutdown();
    8020047c:	ab99                	j	802009d2 <sbi_shutdown>

000000008020047e <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    8020047e:	11853783          	ld	a5,280(a0)
    80200482:	472d                	li	a4,11
    80200484:	02f76763          	bltu	a4,a5,802004b2 <exception_handler+0x34>
    80200488:	4705                	li	a4,1
    8020048a:	00f71733          	sll	a4,a4,a5
    8020048e:	6785                	lui	a5,0x1
    80200490:	17cd                	addi	a5,a5,-13
    80200492:	8ff9                	and	a5,a5,a4
    80200494:	ef91                	bnez	a5,802004b0 <exception_handler+0x32>
void exception_handler(struct trapframe *tf) {
    80200496:	1141                	addi	sp,sp,-16
    80200498:	e022                	sd	s0,0(sp)
    8020049a:	e406                	sd	ra,8(sp)
    8020049c:	00877793          	andi	a5,a4,8
    802004a0:	842a                	mv	s0,a0
    802004a2:	e3a1                	bnez	a5,802004e2 <exception_handler+0x64>
    802004a4:	8b11                	andi	a4,a4,4
    802004a6:	e719                	bnez	a4,802004b4 <exception_handler+0x36>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004a8:	6402                	ld	s0,0(sp)
    802004aa:	60a2                	ld	ra,8(sp)
    802004ac:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004ae:	b57d                	j	8020035c <print_trapframe>
    802004b0:	8082                	ret
    802004b2:	b56d                	j	8020035c <print_trapframe>
            cprintf("Exception type:Illegal instruction\n");  
    802004b4:	00000517          	auipc	a0,0x0
    802004b8:	6bc50513          	addi	a0,a0,1724 # 80200b70 <etext+0x14a>
            cprintf("Exception type: breakpoint\n");  
    802004bc:	bafff0ef          	jal	ra,8020006a <cprintf>
    	    cprintf("EPC: 0x%08x\n", tf->epc);    
    802004c0:	10843583          	ld	a1,264(s0)
    802004c4:	00000517          	auipc	a0,0x0
    802004c8:	6d450513          	addi	a0,a0,1748 # 80200b98 <etext+0x172>
    802004cc:	b9fff0ef          	jal	ra,8020006a <cprintf>
    	    tf->epc += 4; 
    802004d0:	10843783          	ld	a5,264(s0)
}
    802004d4:	60a2                	ld	ra,8(sp)
    	    tf->epc += 4; 
    802004d6:	0791                	addi	a5,a5,4
    802004d8:	10f43423          	sd	a5,264(s0)
}
    802004dc:	6402                	ld	s0,0(sp)
    802004de:	0141                	addi	sp,sp,16
    802004e0:	8082                	ret
            cprintf("Exception type: breakpoint\n");  
    802004e2:	00000517          	auipc	a0,0x0
    802004e6:	6c650513          	addi	a0,a0,1734 # 80200ba8 <etext+0x182>
    802004ea:	bfc9                	j	802004bc <exception_handler+0x3e>

00000000802004ec <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    802004ec:	11853783          	ld	a5,280(a0)
    802004f0:	0007c363          	bltz	a5,802004f6 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    802004f4:	b769                	j	8020047e <exception_handler>
        interrupt_handler(tf);
    802004f6:	b5d9                	j	802003bc <interrupt_handler>

00000000802004f8 <__alltraps>:
    .endm

    .globl __alltraps
.align(2)
__alltraps:
    SAVE_ALL
    802004f8:	14011073          	csrw	sscratch,sp
    802004fc:	712d                	addi	sp,sp,-288
    802004fe:	e002                	sd	zero,0(sp)
    80200500:	e406                	sd	ra,8(sp)
    80200502:	ec0e                	sd	gp,24(sp)
    80200504:	f012                	sd	tp,32(sp)
    80200506:	f416                	sd	t0,40(sp)
    80200508:	f81a                	sd	t1,48(sp)
    8020050a:	fc1e                	sd	t2,56(sp)
    8020050c:	e0a2                	sd	s0,64(sp)
    8020050e:	e4a6                	sd	s1,72(sp)
    80200510:	e8aa                	sd	a0,80(sp)
    80200512:	ecae                	sd	a1,88(sp)
    80200514:	f0b2                	sd	a2,96(sp)
    80200516:	f4b6                	sd	a3,104(sp)
    80200518:	f8ba                	sd	a4,112(sp)
    8020051a:	fcbe                	sd	a5,120(sp)
    8020051c:	e142                	sd	a6,128(sp)
    8020051e:	e546                	sd	a7,136(sp)
    80200520:	e94a                	sd	s2,144(sp)
    80200522:	ed4e                	sd	s3,152(sp)
    80200524:	f152                	sd	s4,160(sp)
    80200526:	f556                	sd	s5,168(sp)
    80200528:	f95a                	sd	s6,176(sp)
    8020052a:	fd5e                	sd	s7,184(sp)
    8020052c:	e1e2                	sd	s8,192(sp)
    8020052e:	e5e6                	sd	s9,200(sp)
    80200530:	e9ea                	sd	s10,208(sp)
    80200532:	edee                	sd	s11,216(sp)
    80200534:	f1f2                	sd	t3,224(sp)
    80200536:	f5f6                	sd	t4,232(sp)
    80200538:	f9fa                	sd	t5,240(sp)
    8020053a:	fdfe                	sd	t6,248(sp)
    8020053c:	14001473          	csrrw	s0,sscratch,zero
    80200540:	100024f3          	csrr	s1,sstatus
    80200544:	14102973          	csrr	s2,sepc
    80200548:	143029f3          	csrr	s3,stval
    8020054c:	14202a73          	csrr	s4,scause
    80200550:	e822                	sd	s0,16(sp)
    80200552:	e226                	sd	s1,256(sp)
    80200554:	e64a                	sd	s2,264(sp)
    80200556:	ea4e                	sd	s3,272(sp)
    80200558:	ee52                	sd	s4,280(sp)

    move  a0, sp
    8020055a:	850a                	mv	a0,sp
    jal trap
    8020055c:	f91ff0ef          	jal	ra,802004ec <trap>

0000000080200560 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
    80200560:	6492                	ld	s1,256(sp)
    80200562:	6932                	ld	s2,264(sp)
    80200564:	10049073          	csrw	sstatus,s1
    80200568:	14191073          	csrw	sepc,s2
    8020056c:	60a2                	ld	ra,8(sp)
    8020056e:	61e2                	ld	gp,24(sp)
    80200570:	7202                	ld	tp,32(sp)
    80200572:	72a2                	ld	t0,40(sp)
    80200574:	7342                	ld	t1,48(sp)
    80200576:	73e2                	ld	t2,56(sp)
    80200578:	6406                	ld	s0,64(sp)
    8020057a:	64a6                	ld	s1,72(sp)
    8020057c:	6546                	ld	a0,80(sp)
    8020057e:	65e6                	ld	a1,88(sp)
    80200580:	7606                	ld	a2,96(sp)
    80200582:	76a6                	ld	a3,104(sp)
    80200584:	7746                	ld	a4,112(sp)
    80200586:	77e6                	ld	a5,120(sp)
    80200588:	680a                	ld	a6,128(sp)
    8020058a:	68aa                	ld	a7,136(sp)
    8020058c:	694a                	ld	s2,144(sp)
    8020058e:	69ea                	ld	s3,152(sp)
    80200590:	7a0a                	ld	s4,160(sp)
    80200592:	7aaa                	ld	s5,168(sp)
    80200594:	7b4a                	ld	s6,176(sp)
    80200596:	7bea                	ld	s7,184(sp)
    80200598:	6c0e                	ld	s8,192(sp)
    8020059a:	6cae                	ld	s9,200(sp)
    8020059c:	6d4e                	ld	s10,208(sp)
    8020059e:	6dee                	ld	s11,216(sp)
    802005a0:	7e0e                	ld	t3,224(sp)
    802005a2:	7eae                	ld	t4,232(sp)
    802005a4:	7f4e                	ld	t5,240(sp)
    802005a6:	7fee                	ld	t6,248(sp)
    802005a8:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
    802005aa:	10200073          	sret

00000000802005ae <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
    802005ae:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005b2:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
    802005b4:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
    802005b8:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
    802005ba:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
    802005be:	f022                	sd	s0,32(sp)
    802005c0:	ec26                	sd	s1,24(sp)
    802005c2:	e84a                	sd	s2,16(sp)
    802005c4:	f406                	sd	ra,40(sp)
    802005c6:	e44e                	sd	s3,8(sp)
    802005c8:	84aa                	mv	s1,a0
    802005ca:	892e                	mv	s2,a1
    802005cc:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
    802005d0:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
    802005d2:	03067e63          	bgeu	a2,a6,8020060e <printnum+0x60>
    802005d6:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
    802005d8:	00805763          	blez	s0,802005e6 <printnum+0x38>
    802005dc:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
    802005de:	85ca                	mv	a1,s2
    802005e0:	854e                	mv	a0,s3
    802005e2:	9482                	jalr	s1
        while (-- width > 0)
    802005e4:	fc65                	bnez	s0,802005dc <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
    802005e6:	1a02                	slli	s4,s4,0x20
    802005e8:	020a5a13          	srli	s4,s4,0x20
    802005ec:	00001797          	auipc	a5,0x1
    802005f0:	b9478793          	addi	a5,a5,-1132 # 80201180 <error_string+0x38>
    802005f4:	9a3e                	add	s4,s4,a5
}
    802005f6:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
    802005f8:	000a4503          	lbu	a0,0(s4)
}
    802005fc:	70a2                	ld	ra,40(sp)
    802005fe:	69a2                	ld	s3,8(sp)
    80200600:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
    80200602:	85ca                	mv	a1,s2
    80200604:	8326                	mv	t1,s1
}
    80200606:	6942                	ld	s2,16(sp)
    80200608:	64e2                	ld	s1,24(sp)
    8020060a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
    8020060c:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
    8020060e:	03065633          	divu	a2,a2,a6
    80200612:	8722                	mv	a4,s0
    80200614:	f9bff0ef          	jal	ra,802005ae <printnum>
    80200618:	b7f9                	j	802005e6 <printnum+0x38>

000000008020061a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
    8020061a:	7119                	addi	sp,sp,-128
    8020061c:	f4a6                	sd	s1,104(sp)
    8020061e:	f0ca                	sd	s2,96(sp)
    80200620:	e8d2                	sd	s4,80(sp)
    80200622:	e4d6                	sd	s5,72(sp)
    80200624:	e0da                	sd	s6,64(sp)
    80200626:	fc5e                	sd	s7,56(sp)
    80200628:	f862                	sd	s8,48(sp)
    8020062a:	f06a                	sd	s10,32(sp)
    8020062c:	fc86                	sd	ra,120(sp)
    8020062e:	f8a2                	sd	s0,112(sp)
    80200630:	ecce                	sd	s3,88(sp)
    80200632:	f466                	sd	s9,40(sp)
    80200634:	ec6e                	sd	s11,24(sp)
    80200636:	892a                	mv	s2,a0
    80200638:	84ae                	mv	s1,a1
    8020063a:	8d32                	mv	s10,a2
    8020063c:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
    8020063e:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
    80200640:	00001a17          	auipc	s4,0x1
    80200644:	9aca0a13          	addi	s4,s4,-1620 # 80200fec <etext+0x5c6>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
    80200648:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    8020064c:	00001c17          	auipc	s8,0x1
    80200650:	afcc0c13          	addi	s8,s8,-1284 # 80201148 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200654:	000d4503          	lbu	a0,0(s10)
    80200658:	02500793          	li	a5,37
    8020065c:	001d0413          	addi	s0,s10,1
    80200660:	00f50e63          	beq	a0,a5,8020067c <vprintfmt+0x62>
            if (ch == '\0') {
    80200664:	c521                	beqz	a0,802006ac <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200666:	02500993          	li	s3,37
    8020066a:	a011                	j	8020066e <vprintfmt+0x54>
            if (ch == '\0') {
    8020066c:	c121                	beqz	a0,802006ac <vprintfmt+0x92>
            putch(ch, putdat);
    8020066e:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200670:	0405                	addi	s0,s0,1
            putch(ch, putdat);
    80200672:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
    80200674:	fff44503          	lbu	a0,-1(s0)
    80200678:	ff351ae3          	bne	a0,s3,8020066c <vprintfmt+0x52>
    8020067c:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
    80200680:	02000793          	li	a5,32
        lflag = altflag = 0;
    80200684:	4981                	li	s3,0
    80200686:	4801                	li	a6,0
        width = precision = -1;
    80200688:	5cfd                	li	s9,-1
    8020068a:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
    8020068c:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
    80200690:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
    80200692:	fdd6069b          	addiw	a3,a2,-35
    80200696:	0ff6f693          	andi	a3,a3,255
    8020069a:	00140d13          	addi	s10,s0,1
    8020069e:	1ed5ef63          	bltu	a1,a3,8020089c <vprintfmt+0x282>
    802006a2:	068a                	slli	a3,a3,0x2
    802006a4:	96d2                	add	a3,a3,s4
    802006a6:	4294                	lw	a3,0(a3)
    802006a8:	96d2                	add	a3,a3,s4
    802006aa:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
    802006ac:	70e6                	ld	ra,120(sp)
    802006ae:	7446                	ld	s0,112(sp)
    802006b0:	74a6                	ld	s1,104(sp)
    802006b2:	7906                	ld	s2,96(sp)
    802006b4:	69e6                	ld	s3,88(sp)
    802006b6:	6a46                	ld	s4,80(sp)
    802006b8:	6aa6                	ld	s5,72(sp)
    802006ba:	6b06                	ld	s6,64(sp)
    802006bc:	7be2                	ld	s7,56(sp)
    802006be:	7c42                	ld	s8,48(sp)
    802006c0:	7ca2                	ld	s9,40(sp)
    802006c2:	7d02                	ld	s10,32(sp)
    802006c4:	6de2                	ld	s11,24(sp)
    802006c6:	6109                	addi	sp,sp,128
    802006c8:	8082                	ret
            padc = '-';
    802006ca:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
    802006cc:	00144603          	lbu	a2,1(s0)
    802006d0:	846a                	mv	s0,s10
    802006d2:	b7c1                	j	80200692 <vprintfmt+0x78>
            precision = va_arg(ap, int);
    802006d4:	000aac83          	lw	s9,0(s5)
            goto process_precision;
    802006d8:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
    802006dc:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
    802006de:	846a                	mv	s0,s10
            if (width < 0)
    802006e0:	fa0dd9e3          	bgez	s11,80200692 <vprintfmt+0x78>
                width = precision, precision = -1;
    802006e4:	8de6                	mv	s11,s9
    802006e6:	5cfd                	li	s9,-1
    802006e8:	b76d                	j	80200692 <vprintfmt+0x78>
            if (width < 0)
    802006ea:	fffdc693          	not	a3,s11
    802006ee:	96fd                	srai	a3,a3,0x3f
    802006f0:	00ddfdb3          	and	s11,s11,a3
    802006f4:	00144603          	lbu	a2,1(s0)
    802006f8:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
    802006fa:	846a                	mv	s0,s10
    802006fc:	bf59                	j	80200692 <vprintfmt+0x78>
    if (lflag >= 2) {
    802006fe:	4705                	li	a4,1
    80200700:	008a8593          	addi	a1,s5,8
    80200704:	01074463          	blt	a4,a6,8020070c <vprintfmt+0xf2>
    else if (lflag) {
    80200708:	22080863          	beqz	a6,80200938 <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
    8020070c:	000ab603          	ld	a2,0(s5)
    80200710:	46c1                	li	a3,16
    80200712:	8aae                	mv	s5,a1
    80200714:	a291                	j	80200858 <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
    80200716:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
    8020071a:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
    8020071e:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
    80200720:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
    80200724:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    80200728:	fad56ce3          	bltu	a0,a3,802006e0 <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
    8020072c:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
    8020072e:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
    80200732:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
    80200736:	0196873b          	addw	a4,a3,s9
    8020073a:	0017171b          	slliw	a4,a4,0x1
    8020073e:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
    80200742:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
    80200746:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
    8020074a:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
    8020074e:	fcd57fe3          	bgeu	a0,a3,8020072c <vprintfmt+0x112>
    80200752:	b779                	j	802006e0 <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
    80200754:	000aa503          	lw	a0,0(s5)
    80200758:	85a6                	mv	a1,s1
    8020075a:	0aa1                	addi	s5,s5,8
    8020075c:	9902                	jalr	s2
            break;
    8020075e:	bddd                	j	80200654 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200760:	4705                	li	a4,1
    80200762:	008a8993          	addi	s3,s5,8
    80200766:	01074463          	blt	a4,a6,8020076e <vprintfmt+0x154>
    else if (lflag) {
    8020076a:	1c080463          	beqz	a6,80200932 <vprintfmt+0x318>
        return va_arg(*ap, long);
    8020076e:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
    80200772:	1c044a63          	bltz	s0,80200946 <vprintfmt+0x32c>
            num = getint(&ap, lflag);
    80200776:	8622                	mv	a2,s0
    80200778:	8ace                	mv	s5,s3
    8020077a:	46a9                	li	a3,10
    8020077c:	a8f1                	j	80200858 <vprintfmt+0x23e>
            err = va_arg(ap, int);
    8020077e:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200782:	4719                	li	a4,6
            err = va_arg(ap, int);
    80200784:	0aa1                	addi	s5,s5,8
            if (err < 0) {
    80200786:	41f7d69b          	sraiw	a3,a5,0x1f
    8020078a:	8fb5                	xor	a5,a5,a3
    8020078c:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
    80200790:	12d74963          	blt	a4,a3,802008c2 <vprintfmt+0x2a8>
    80200794:	00369793          	slli	a5,a3,0x3
    80200798:	97e2                	add	a5,a5,s8
    8020079a:	639c                	ld	a5,0(a5)
    8020079c:	12078363          	beqz	a5,802008c2 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
    802007a0:	86be                	mv	a3,a5
    802007a2:	00001617          	auipc	a2,0x1
    802007a6:	a8e60613          	addi	a2,a2,-1394 # 80201230 <error_string+0xe8>
    802007aa:	85a6                	mv	a1,s1
    802007ac:	854a                	mv	a0,s2
    802007ae:	1cc000ef          	jal	ra,8020097a <printfmt>
    802007b2:	b54d                	j	80200654 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
    802007b4:	000ab603          	ld	a2,0(s5)
    802007b8:	0aa1                	addi	s5,s5,8
    802007ba:	1a060163          	beqz	a2,8020095c <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
    802007be:	00160413          	addi	s0,a2,1
    802007c2:	15b05763          	blez	s11,80200910 <vprintfmt+0x2f6>
    802007c6:	02d00593          	li	a1,45
    802007ca:	10b79d63          	bne	a5,a1,802008e4 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802007ce:	00064783          	lbu	a5,0(a2)
    802007d2:	0007851b          	sext.w	a0,a5
    802007d6:	c905                	beqz	a0,80200806 <vprintfmt+0x1ec>
    802007d8:	000cc563          	bltz	s9,802007e2 <vprintfmt+0x1c8>
    802007dc:	3cfd                	addiw	s9,s9,-1
    802007de:	036c8263          	beq	s9,s6,80200802 <vprintfmt+0x1e8>
                    putch('?', putdat);
    802007e2:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
    802007e4:	14098f63          	beqz	s3,80200942 <vprintfmt+0x328>
    802007e8:	3781                	addiw	a5,a5,-32
    802007ea:	14fbfc63          	bgeu	s7,a5,80200942 <vprintfmt+0x328>
                    putch('?', putdat);
    802007ee:	03f00513          	li	a0,63
    802007f2:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    802007f4:	0405                	addi	s0,s0,1
    802007f6:	fff44783          	lbu	a5,-1(s0)
    802007fa:	3dfd                	addiw	s11,s11,-1
    802007fc:	0007851b          	sext.w	a0,a5
    80200800:	fd61                	bnez	a0,802007d8 <vprintfmt+0x1be>
            for (; width > 0; width --) {
    80200802:	e5b059e3          	blez	s11,80200654 <vprintfmt+0x3a>
    80200806:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200808:	85a6                	mv	a1,s1
    8020080a:	02000513          	li	a0,32
    8020080e:	9902                	jalr	s2
            for (; width > 0; width --) {
    80200810:	e40d82e3          	beqz	s11,80200654 <vprintfmt+0x3a>
    80200814:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
    80200816:	85a6                	mv	a1,s1
    80200818:	02000513          	li	a0,32
    8020081c:	9902                	jalr	s2
            for (; width > 0; width --) {
    8020081e:	fe0d94e3          	bnez	s11,80200806 <vprintfmt+0x1ec>
    80200822:	bd0d                	j	80200654 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200824:	4705                	li	a4,1
    80200826:	008a8593          	addi	a1,s5,8
    8020082a:	01074463          	blt	a4,a6,80200832 <vprintfmt+0x218>
    else if (lflag) {
    8020082e:	0e080863          	beqz	a6,8020091e <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
    80200832:	000ab603          	ld	a2,0(s5)
    80200836:	46a1                	li	a3,8
    80200838:	8aae                	mv	s5,a1
    8020083a:	a839                	j	80200858 <vprintfmt+0x23e>
            putch('0', putdat);
    8020083c:	03000513          	li	a0,48
    80200840:	85a6                	mv	a1,s1
    80200842:	e03e                	sd	a5,0(sp)
    80200844:	9902                	jalr	s2
            putch('x', putdat);
    80200846:	85a6                	mv	a1,s1
    80200848:	07800513          	li	a0,120
    8020084c:	9902                	jalr	s2
            num = (unsigned long long)va_arg(ap, void *);
    8020084e:	0aa1                	addi	s5,s5,8
    80200850:	ff8ab603          	ld	a2,-8(s5)
            goto number;
    80200854:	6782                	ld	a5,0(sp)
    80200856:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
    80200858:	2781                	sext.w	a5,a5
    8020085a:	876e                	mv	a4,s11
    8020085c:	85a6                	mv	a1,s1
    8020085e:	854a                	mv	a0,s2
    80200860:	d4fff0ef          	jal	ra,802005ae <printnum>
            break;
    80200864:	bbc5                	j	80200654 <vprintfmt+0x3a>
            lflag ++;
    80200866:	00144603          	lbu	a2,1(s0)
    8020086a:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
    8020086c:	846a                	mv	s0,s10
            goto reswitch;
    8020086e:	b515                	j	80200692 <vprintfmt+0x78>
            goto reswitch;
    80200870:	00144603          	lbu	a2,1(s0)
            altflag = 1;
    80200874:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
    80200876:	846a                	mv	s0,s10
            goto reswitch;
    80200878:	bd29                	j	80200692 <vprintfmt+0x78>
            putch(ch, putdat);
    8020087a:	85a6                	mv	a1,s1
    8020087c:	02500513          	li	a0,37
    80200880:	9902                	jalr	s2
            break;
    80200882:	bbc9                	j	80200654 <vprintfmt+0x3a>
    if (lflag >= 2) {
    80200884:	4705                	li	a4,1
    80200886:	008a8593          	addi	a1,s5,8
    8020088a:	01074463          	blt	a4,a6,80200892 <vprintfmt+0x278>
    else if (lflag) {
    8020088e:	08080d63          	beqz	a6,80200928 <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
    80200892:	000ab603          	ld	a2,0(s5)
    80200896:	46a9                	li	a3,10
    80200898:	8aae                	mv	s5,a1
    8020089a:	bf7d                	j	80200858 <vprintfmt+0x23e>
            putch('%', putdat);
    8020089c:	85a6                	mv	a1,s1
    8020089e:	02500513          	li	a0,37
    802008a2:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
    802008a4:	fff44703          	lbu	a4,-1(s0)
    802008a8:	02500793          	li	a5,37
    802008ac:	8d22                	mv	s10,s0
    802008ae:	daf703e3          	beq	a4,a5,80200654 <vprintfmt+0x3a>
    802008b2:	02500713          	li	a4,37
    802008b6:	1d7d                	addi	s10,s10,-1
    802008b8:	fffd4783          	lbu	a5,-1(s10)
    802008bc:	fee79de3          	bne	a5,a4,802008b6 <vprintfmt+0x29c>
    802008c0:	bb51                	j	80200654 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
    802008c2:	00001617          	auipc	a2,0x1
    802008c6:	95e60613          	addi	a2,a2,-1698 # 80201220 <error_string+0xd8>
    802008ca:	85a6                	mv	a1,s1
    802008cc:	854a                	mv	a0,s2
    802008ce:	0ac000ef          	jal	ra,8020097a <printfmt>
    802008d2:	b349                	j	80200654 <vprintfmt+0x3a>
                p = "(null)";
    802008d4:	00001617          	auipc	a2,0x1
    802008d8:	94460613          	addi	a2,a2,-1724 # 80201218 <error_string+0xd0>
            if (width > 0 && padc != '-') {
    802008dc:	00001417          	auipc	s0,0x1
    802008e0:	93d40413          	addi	s0,s0,-1731 # 80201219 <error_string+0xd1>
                for (width -= strnlen(p, precision); width > 0; width --) {
    802008e4:	8532                	mv	a0,a2
    802008e6:	85e6                	mv	a1,s9
    802008e8:	e032                	sd	a2,0(sp)
    802008ea:	e43e                	sd	a5,8(sp)
    802008ec:	102000ef          	jal	ra,802009ee <strnlen>
    802008f0:	40ad8dbb          	subw	s11,s11,a0
    802008f4:	6602                	ld	a2,0(sp)
    802008f6:	01b05d63          	blez	s11,80200910 <vprintfmt+0x2f6>
    802008fa:	67a2                	ld	a5,8(sp)
    802008fc:	2781                	sext.w	a5,a5
    802008fe:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
    80200900:	6522                	ld	a0,8(sp)
    80200902:	85a6                	mv	a1,s1
    80200904:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
    80200906:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
    80200908:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
    8020090a:	6602                	ld	a2,0(sp)
    8020090c:	fe0d9ae3          	bnez	s11,80200900 <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200910:	00064783          	lbu	a5,0(a2)
    80200914:	0007851b          	sext.w	a0,a5
    80200918:	ec0510e3          	bnez	a0,802007d8 <vprintfmt+0x1be>
    8020091c:	bb25                	j	80200654 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
    8020091e:	000ae603          	lwu	a2,0(s5)
    80200922:	46a1                	li	a3,8
    80200924:	8aae                	mv	s5,a1
    80200926:	bf0d                	j	80200858 <vprintfmt+0x23e>
    80200928:	000ae603          	lwu	a2,0(s5)
    8020092c:	46a9                	li	a3,10
    8020092e:	8aae                	mv	s5,a1
    80200930:	b725                	j	80200858 <vprintfmt+0x23e>
        return va_arg(*ap, int);
    80200932:	000aa403          	lw	s0,0(s5)
    80200936:	bd35                	j	80200772 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
    80200938:	000ae603          	lwu	a2,0(s5)
    8020093c:	46c1                	li	a3,16
    8020093e:	8aae                	mv	s5,a1
    80200940:	bf21                	j	80200858 <vprintfmt+0x23e>
                    putch(ch, putdat);
    80200942:	9902                	jalr	s2
    80200944:	bd45                	j	802007f4 <vprintfmt+0x1da>
                putch('-', putdat);
    80200946:	85a6                	mv	a1,s1
    80200948:	02d00513          	li	a0,45
    8020094c:	e03e                	sd	a5,0(sp)
    8020094e:	9902                	jalr	s2
                num = -(long long)num;
    80200950:	8ace                	mv	s5,s3
    80200952:	40800633          	neg	a2,s0
    80200956:	46a9                	li	a3,10
    80200958:	6782                	ld	a5,0(sp)
    8020095a:	bdfd                	j	80200858 <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
    8020095c:	01b05663          	blez	s11,80200968 <vprintfmt+0x34e>
    80200960:	02d00693          	li	a3,45
    80200964:	f6d798e3          	bne	a5,a3,802008d4 <vprintfmt+0x2ba>
    80200968:	00001417          	auipc	s0,0x1
    8020096c:	8b140413          	addi	s0,s0,-1871 # 80201219 <error_string+0xd1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
    80200970:	02800513          	li	a0,40
    80200974:	02800793          	li	a5,40
    80200978:	b585                	j	802007d8 <vprintfmt+0x1be>

000000008020097a <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    8020097a:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
    8020097c:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200980:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200982:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
    80200984:	ec06                	sd	ra,24(sp)
    80200986:	f83a                	sd	a4,48(sp)
    80200988:	fc3e                	sd	a5,56(sp)
    8020098a:	e0c2                	sd	a6,64(sp)
    8020098c:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
    8020098e:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
    80200990:	c8bff0ef          	jal	ra,8020061a <vprintfmt>
}
    80200994:	60e2                	ld	ra,24(sp)
    80200996:	6161                	addi	sp,sp,80
    80200998:	8082                	ret

000000008020099a <sbi_console_putchar>:

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
    8020099a:	00003797          	auipc	a5,0x3
    8020099e:	66678793          	addi	a5,a5,1638 # 80204000 <bootstacktop>
    __asm__ volatile (
    802009a2:	6398                	ld	a4,0(a5)
    802009a4:	4781                	li	a5,0
    802009a6:	88ba                	mv	a7,a4
    802009a8:	852a                	mv	a0,a0
    802009aa:	85be                	mv	a1,a5
    802009ac:	863e                	mv	a2,a5
    802009ae:	00000073          	ecall
    802009b2:	87aa                	mv	a5,a0
}
    802009b4:	8082                	ret

00000000802009b6 <sbi_set_timer>:

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
    802009b6:	00003797          	auipc	a5,0x3
    802009ba:	66278793          	addi	a5,a5,1634 # 80204018 <SBI_SET_TIMER>
    __asm__ volatile (
    802009be:	6398                	ld	a4,0(a5)
    802009c0:	4781                	li	a5,0
    802009c2:	88ba                	mv	a7,a4
    802009c4:	852a                	mv	a0,a0
    802009c6:	85be                	mv	a1,a5
    802009c8:	863e                	mv	a2,a5
    802009ca:	00000073          	ecall
    802009ce:	87aa                	mv	a5,a0
}
    802009d0:	8082                	ret

00000000802009d2 <sbi_shutdown>:


void sbi_shutdown(void)
{
    sbi_call(SBI_SHUTDOWN,0,0,0);
    802009d2:	00003797          	auipc	a5,0x3
    802009d6:	63678793          	addi	a5,a5,1590 # 80204008 <SBI_SHUTDOWN>
    __asm__ volatile (
    802009da:	6398                	ld	a4,0(a5)
    802009dc:	4781                	li	a5,0
    802009de:	88ba                	mv	a7,a4
    802009e0:	853e                	mv	a0,a5
    802009e2:	85be                	mv	a1,a5
    802009e4:	863e                	mv	a2,a5
    802009e6:	00000073          	ecall
    802009ea:	87aa                	mv	a5,a0
    802009ec:	8082                	ret

00000000802009ee <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
    802009ee:	c185                	beqz	a1,80200a0e <strnlen+0x20>
    802009f0:	00054783          	lbu	a5,0(a0)
    802009f4:	cf89                	beqz	a5,80200a0e <strnlen+0x20>
    size_t cnt = 0;
    802009f6:	4781                	li	a5,0
    802009f8:	a021                	j	80200a00 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
    802009fa:	00074703          	lbu	a4,0(a4)
    802009fe:	c711                	beqz	a4,80200a0a <strnlen+0x1c>
        cnt ++;
    80200a00:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
    80200a02:	00f50733          	add	a4,a0,a5
    80200a06:	fef59ae3          	bne	a1,a5,802009fa <strnlen+0xc>
    }
    return cnt;
}
    80200a0a:	853e                	mv	a0,a5
    80200a0c:	8082                	ret
    size_t cnt = 0;
    80200a0e:	4781                	li	a5,0
}
    80200a10:	853e                	mv	a0,a5
    80200a12:	8082                	ret

0000000080200a14 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
    80200a14:	ca01                	beqz	a2,80200a24 <memset+0x10>
    80200a16:	962a                	add	a2,a2,a0
    char *p = s;
    80200a18:	87aa                	mv	a5,a0
        *p ++ = c;
    80200a1a:	0785                	addi	a5,a5,1
    80200a1c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
    80200a20:	fec79de3          	bne	a5,a2,80200a1a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
    80200a24:	8082                	ret
