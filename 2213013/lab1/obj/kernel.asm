
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp
    80200008:	a009                	j	8020000a <kern_init>

000000008020000a <kern_init>:
    8020000a:	00004517          	auipc	a0,0x4
    8020000e:	ffe50513          	addi	a0,a0,-2 # 80204008 <ticks>
    80200012:	00004617          	auipc	a2,0x4
    80200016:	00660613          	addi	a2,a2,6 # 80204018 <end>
    8020001a:	1141                	addi	sp,sp,-16
    8020001c:	8e09                	sub	a2,a2,a0
    8020001e:	4581                	li	a1,0
    80200020:	e406                	sd	ra,8(sp)
    80200022:	1c3000ef          	jal	ra,802009e4 <memset>
    80200026:	14a000ef          	jal	ra,80200170 <cons_init>
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	9ce58593          	addi	a1,a1,-1586 # 802009f8 <etext+0x2>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	9e650513          	addi	a0,a0,-1562 # 80200a18 <etext+0x22>
    8020003a:	0be000ef          	jal	ra,802000f8 <cprintf>
    8020003e:	012000ef          	jal	ra,80200050 <print_kerninfo>
    80200042:	13e000ef          	jal	ra,80200180 <idt_init>
    80200046:	0e8000ef          	jal	ra,8020012e <clock_init>
    8020004a:	130000ef          	jal	ra,8020017a <intr_enable>
    8020004e:	a001                	j	8020004e <kern_init+0x44>

0000000080200050 <print_kerninfo>:
    80200050:	1141                	addi	sp,sp,-16
    80200052:	00001517          	auipc	a0,0x1
    80200056:	9ce50513          	addi	a0,a0,-1586 # 80200a20 <etext+0x2a>
    8020005a:	e406                	sd	ra,8(sp)
    8020005c:	09c000ef          	jal	ra,802000f8 <cprintf>
    80200060:	00000597          	auipc	a1,0x0
    80200064:	faa58593          	addi	a1,a1,-86 # 8020000a <kern_init>
    80200068:	00001517          	auipc	a0,0x1
    8020006c:	9d850513          	addi	a0,a0,-1576 # 80200a40 <etext+0x4a>
    80200070:	088000ef          	jal	ra,802000f8 <cprintf>
    80200074:	00001597          	auipc	a1,0x1
    80200078:	98258593          	addi	a1,a1,-1662 # 802009f6 <etext>
    8020007c:	00001517          	auipc	a0,0x1
    80200080:	9e450513          	addi	a0,a0,-1564 # 80200a60 <etext+0x6a>
    80200084:	074000ef          	jal	ra,802000f8 <cprintf>
    80200088:	00004597          	auipc	a1,0x4
    8020008c:	f8058593          	addi	a1,a1,-128 # 80204008 <ticks>
    80200090:	00001517          	auipc	a0,0x1
    80200094:	9f050513          	addi	a0,a0,-1552 # 80200a80 <etext+0x8a>
    80200098:	060000ef          	jal	ra,802000f8 <cprintf>
    8020009c:	00004597          	auipc	a1,0x4
    802000a0:	f7c58593          	addi	a1,a1,-132 # 80204018 <end>
    802000a4:	00001517          	auipc	a0,0x1
    802000a8:	9fc50513          	addi	a0,a0,-1540 # 80200aa0 <etext+0xaa>
    802000ac:	04c000ef          	jal	ra,802000f8 <cprintf>
    802000b0:	00004597          	auipc	a1,0x4
    802000b4:	36758593          	addi	a1,a1,871 # 80204417 <end+0x3ff>
    802000b8:	00000797          	auipc	a5,0x0
    802000bc:	f5278793          	addi	a5,a5,-174 # 8020000a <kern_init>
    802000c0:	40f587b3          	sub	a5,a1,a5
    802000c4:	43f7d593          	srai	a1,a5,0x3f
    802000c8:	60a2                	ld	ra,8(sp)
    802000ca:	3ff5f593          	andi	a1,a1,1023
    802000ce:	95be                	add	a1,a1,a5
    802000d0:	85a9                	srai	a1,a1,0xa
    802000d2:	00001517          	auipc	a0,0x1
    802000d6:	9ee50513          	addi	a0,a0,-1554 # 80200ac0 <etext+0xca>
    802000da:	0141                	addi	sp,sp,16
    802000dc:	a831                	j	802000f8 <cprintf>

00000000802000de <cputch>:
    802000de:	1141                	addi	sp,sp,-16
    802000e0:	e022                	sd	s0,0(sp)
    802000e2:	e406                	sd	ra,8(sp)
    802000e4:	842e                	mv	s0,a1
    802000e6:	08c000ef          	jal	ra,80200172 <cons_putc>
    802000ea:	401c                	lw	a5,0(s0)
    802000ec:	60a2                	ld	ra,8(sp)
    802000ee:	2785                	addiw	a5,a5,1
    802000f0:	c01c                	sw	a5,0(s0)
    802000f2:	6402                	ld	s0,0(sp)
    802000f4:	0141                	addi	sp,sp,16
    802000f6:	8082                	ret

00000000802000f8 <cprintf>:
    802000f8:	711d                	addi	sp,sp,-96
    802000fa:	02810313          	addi	t1,sp,40 # 80204028 <end+0x10>
    802000fe:	8e2a                	mv	t3,a0
    80200100:	f42e                	sd	a1,40(sp)
    80200102:	f832                	sd	a2,48(sp)
    80200104:	fc36                	sd	a3,56(sp)
    80200106:	00000517          	auipc	a0,0x0
    8020010a:	fd850513          	addi	a0,a0,-40 # 802000de <cputch>
    8020010e:	004c                	addi	a1,sp,4
    80200110:	869a                	mv	a3,t1
    80200112:	8672                	mv	a2,t3
    80200114:	ec06                	sd	ra,24(sp)
    80200116:	e0ba                	sd	a4,64(sp)
    80200118:	e4be                	sd	a5,72(sp)
    8020011a:	e8c2                	sd	a6,80(sp)
    8020011c:	ecc6                	sd	a7,88(sp)
    8020011e:	e41a                	sd	t1,8(sp)
    80200120:	c202                	sw	zero,4(sp)
    80200122:	4f0000ef          	jal	ra,80200612 <vprintfmt>
    80200126:	60e2                	ld	ra,24(sp)
    80200128:	4512                	lw	a0,4(sp)
    8020012a:	6125                	addi	sp,sp,96
    8020012c:	8082                	ret

000000008020012e <clock_init>:
    8020012e:	1141                	addi	sp,sp,-16
    80200130:	e406                	sd	ra,8(sp)
    80200132:	02000793          	li	a5,32
    80200136:	1047a7f3          	csrrs	a5,sie,a5
    8020013a:	c0102573          	rdtime	a0
    8020013e:	67e1                	lui	a5,0x18
    80200140:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    80200144:	953e                	add	a0,a0,a5
    80200146:	069000ef          	jal	ra,802009ae <sbi_set_timer>
    8020014a:	60a2                	ld	ra,8(sp)
    8020014c:	00004797          	auipc	a5,0x4
    80200150:	ea07be23          	sd	zero,-324(a5) # 80204008 <ticks>
    80200154:	00001517          	auipc	a0,0x1
    80200158:	99c50513          	addi	a0,a0,-1636 # 80200af0 <etext+0xfa>
    8020015c:	0141                	addi	sp,sp,16
    8020015e:	bf69                	j	802000f8 <cprintf>

0000000080200160 <clock_set_next_event>:
    80200160:	c0102573          	rdtime	a0
    80200164:	67e1                	lui	a5,0x18
    80200166:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    8020016a:	953e                	add	a0,a0,a5
    8020016c:	0430006f          	j	802009ae <sbi_set_timer>

0000000080200170 <cons_init>:
    80200170:	8082                	ret

0000000080200172 <cons_putc>:
    80200172:	0ff57513          	andi	a0,a0,255
    80200176:	01f0006f          	j	80200994 <sbi_console_putchar>

000000008020017a <intr_enable>:
    8020017a:	100167f3          	csrrsi	a5,sstatus,2
    8020017e:	8082                	ret

0000000080200180 <idt_init>:
 */
void idt_init(void) {
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
    80200180:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
    80200184:	00000797          	auipc	a5,0x0
    80200188:	36c78793          	addi	a5,a5,876 # 802004f0 <__alltraps>
    8020018c:	10579073          	csrw	stvec,a5
}
    80200190:	8082                	ret

0000000080200192 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
    80200192:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
    80200194:	1141                	addi	sp,sp,-16
    80200196:	e022                	sd	s0,0(sp)
    80200198:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
    8020019a:	00001517          	auipc	a0,0x1
    8020019e:	97650513          	addi	a0,a0,-1674 # 80200b10 <etext+0x11a>
void print_regs(struct pushregs *gpr) {
    802001a2:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a4:	f55ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001a8:	640c                	ld	a1,8(s0)
    802001aa:	00001517          	auipc	a0,0x1
    802001ae:	97e50513          	addi	a0,a0,-1666 # 80200b28 <etext+0x132>
    802001b2:	f47ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001b6:	680c                	ld	a1,16(s0)
    802001b8:	00001517          	auipc	a0,0x1
    802001bc:	98850513          	addi	a0,a0,-1656 # 80200b40 <etext+0x14a>
    802001c0:	f39ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001c4:	6c0c                	ld	a1,24(s0)
    802001c6:	00001517          	auipc	a0,0x1
    802001ca:	99250513          	addi	a0,a0,-1646 # 80200b58 <etext+0x162>
    802001ce:	f2bff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001d2:	700c                	ld	a1,32(s0)
    802001d4:	00001517          	auipc	a0,0x1
    802001d8:	99c50513          	addi	a0,a0,-1636 # 80200b70 <etext+0x17a>
    802001dc:	f1dff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001e0:	740c                	ld	a1,40(s0)
    802001e2:	00001517          	auipc	a0,0x1
    802001e6:	9a650513          	addi	a0,a0,-1626 # 80200b88 <etext+0x192>
    802001ea:	f0fff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001ee:	780c                	ld	a1,48(s0)
    802001f0:	00001517          	auipc	a0,0x1
    802001f4:	9b050513          	addi	a0,a0,-1616 # 80200ba0 <etext+0x1aa>
    802001f8:	f01ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    802001fc:	7c0c                	ld	a1,56(s0)
    802001fe:	00001517          	auipc	a0,0x1
    80200202:	9ba50513          	addi	a0,a0,-1606 # 80200bb8 <etext+0x1c2>
    80200206:	ef3ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    8020020a:	602c                	ld	a1,64(s0)
    8020020c:	00001517          	auipc	a0,0x1
    80200210:	9c450513          	addi	a0,a0,-1596 # 80200bd0 <etext+0x1da>
    80200214:	ee5ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    80200218:	642c                	ld	a1,72(s0)
    8020021a:	00001517          	auipc	a0,0x1
    8020021e:	9ce50513          	addi	a0,a0,-1586 # 80200be8 <etext+0x1f2>
    80200222:	ed7ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    80200226:	682c                	ld	a1,80(s0)
    80200228:	00001517          	auipc	a0,0x1
    8020022c:	9d850513          	addi	a0,a0,-1576 # 80200c00 <etext+0x20a>
    80200230:	ec9ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200234:	6c2c                	ld	a1,88(s0)
    80200236:	00001517          	auipc	a0,0x1
    8020023a:	9e250513          	addi	a0,a0,-1566 # 80200c18 <etext+0x222>
    8020023e:	ebbff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200242:	702c                	ld	a1,96(s0)
    80200244:	00001517          	auipc	a0,0x1
    80200248:	9ec50513          	addi	a0,a0,-1556 # 80200c30 <etext+0x23a>
    8020024c:	eadff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200250:	742c                	ld	a1,104(s0)
    80200252:	00001517          	auipc	a0,0x1
    80200256:	9f650513          	addi	a0,a0,-1546 # 80200c48 <etext+0x252>
    8020025a:	e9fff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    8020025e:	782c                	ld	a1,112(s0)
    80200260:	00001517          	auipc	a0,0x1
    80200264:	a0050513          	addi	a0,a0,-1536 # 80200c60 <etext+0x26a>
    80200268:	e91ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    8020026c:	7c2c                	ld	a1,120(s0)
    8020026e:	00001517          	auipc	a0,0x1
    80200272:	a0a50513          	addi	a0,a0,-1526 # 80200c78 <etext+0x282>
    80200276:	e83ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    8020027a:	604c                	ld	a1,128(s0)
    8020027c:	00001517          	auipc	a0,0x1
    80200280:	a1450513          	addi	a0,a0,-1516 # 80200c90 <etext+0x29a>
    80200284:	e75ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    80200288:	644c                	ld	a1,136(s0)
    8020028a:	00001517          	auipc	a0,0x1
    8020028e:	a1e50513          	addi	a0,a0,-1506 # 80200ca8 <etext+0x2b2>
    80200292:	e67ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    80200296:	684c                	ld	a1,144(s0)
    80200298:	00001517          	auipc	a0,0x1
    8020029c:	a2850513          	addi	a0,a0,-1496 # 80200cc0 <etext+0x2ca>
    802002a0:	e59ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002a4:	6c4c                	ld	a1,152(s0)
    802002a6:	00001517          	auipc	a0,0x1
    802002aa:	a3250513          	addi	a0,a0,-1486 # 80200cd8 <etext+0x2e2>
    802002ae:	e4bff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002b2:	704c                	ld	a1,160(s0)
    802002b4:	00001517          	auipc	a0,0x1
    802002b8:	a3c50513          	addi	a0,a0,-1476 # 80200cf0 <etext+0x2fa>
    802002bc:	e3dff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002c0:	744c                	ld	a1,168(s0)
    802002c2:	00001517          	auipc	a0,0x1
    802002c6:	a4650513          	addi	a0,a0,-1466 # 80200d08 <etext+0x312>
    802002ca:	e2fff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002ce:	784c                	ld	a1,176(s0)
    802002d0:	00001517          	auipc	a0,0x1
    802002d4:	a5050513          	addi	a0,a0,-1456 # 80200d20 <etext+0x32a>
    802002d8:	e21ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002dc:	7c4c                	ld	a1,184(s0)
    802002de:	00001517          	auipc	a0,0x1
    802002e2:	a5a50513          	addi	a0,a0,-1446 # 80200d38 <etext+0x342>
    802002e6:	e13ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002ea:	606c                	ld	a1,192(s0)
    802002ec:	00001517          	auipc	a0,0x1
    802002f0:	a6450513          	addi	a0,a0,-1436 # 80200d50 <etext+0x35a>
    802002f4:	e05ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002f8:	646c                	ld	a1,200(s0)
    802002fa:	00001517          	auipc	a0,0x1
    802002fe:	a6e50513          	addi	a0,a0,-1426 # 80200d68 <etext+0x372>
    80200302:	df7ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    80200306:	686c                	ld	a1,208(s0)
    80200308:	00001517          	auipc	a0,0x1
    8020030c:	a7850513          	addi	a0,a0,-1416 # 80200d80 <etext+0x38a>
    80200310:	de9ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200314:	6c6c                	ld	a1,216(s0)
    80200316:	00001517          	auipc	a0,0x1
    8020031a:	a8250513          	addi	a0,a0,-1406 # 80200d98 <etext+0x3a2>
    8020031e:	ddbff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200322:	706c                	ld	a1,224(s0)
    80200324:	00001517          	auipc	a0,0x1
    80200328:	a8c50513          	addi	a0,a0,-1396 # 80200db0 <etext+0x3ba>
    8020032c:	dcdff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200330:	746c                	ld	a1,232(s0)
    80200332:	00001517          	auipc	a0,0x1
    80200336:	a9650513          	addi	a0,a0,-1386 # 80200dc8 <etext+0x3d2>
    8020033a:	dbfff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    8020033e:	786c                	ld	a1,240(s0)
    80200340:	00001517          	auipc	a0,0x1
    80200344:	aa050513          	addi	a0,a0,-1376 # 80200de0 <etext+0x3ea>
    80200348:	db1ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020034c:	7c6c                	ld	a1,248(s0)
}
    8020034e:	6402                	ld	s0,0(sp)
    80200350:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200352:	00001517          	auipc	a0,0x1
    80200356:	aa650513          	addi	a0,a0,-1370 # 80200df8 <etext+0x402>
}
    8020035a:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020035c:	bb71                	j	802000f8 <cprintf>

000000008020035e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
    8020035e:	1141                	addi	sp,sp,-16
    80200360:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
    80200362:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
    80200364:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
    80200366:	00001517          	auipc	a0,0x1
    8020036a:	aaa50513          	addi	a0,a0,-1366 # 80200e10 <etext+0x41a>
void print_trapframe(struct trapframe *tf) {
    8020036e:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
    80200370:	d89ff0ef          	jal	ra,802000f8 <cprintf>
    print_regs(&tf->gpr);
    80200374:	8522                	mv	a0,s0
    80200376:	e1dff0ef          	jal	ra,80200192 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
    8020037a:	10043583          	ld	a1,256(s0)
    8020037e:	00001517          	auipc	a0,0x1
    80200382:	aaa50513          	addi	a0,a0,-1366 # 80200e28 <etext+0x432>
    80200386:	d73ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    8020038a:	10843583          	ld	a1,264(s0)
    8020038e:	00001517          	auipc	a0,0x1
    80200392:	ab250513          	addi	a0,a0,-1358 # 80200e40 <etext+0x44a>
    80200396:	d63ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    8020039a:	11043583          	ld	a1,272(s0)
    8020039e:	00001517          	auipc	a0,0x1
    802003a2:	aba50513          	addi	a0,a0,-1350 # 80200e58 <etext+0x462>
    802003a6:	d53ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003aa:	11843583          	ld	a1,280(s0)
}
    802003ae:	6402                	ld	s0,0(sp)
    802003b0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b2:	00001517          	auipc	a0,0x1
    802003b6:	abe50513          	addi	a0,a0,-1346 # 80200e70 <etext+0x47a>
}
    802003ba:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
    802003bc:	bb35                	j	802000f8 <cprintf>

00000000802003be <interrupt_handler>:

void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    802003be:	11853783          	ld	a5,280(a0)
    802003c2:	472d                	li	a4,11
    802003c4:	0786                	slli	a5,a5,0x1
    802003c6:	8385                	srli	a5,a5,0x1
    802003c8:	06f76963          	bltu	a4,a5,8020043a <interrupt_handler+0x7c>
    802003cc:	00001717          	auipc	a4,0x1
    802003d0:	b6c70713          	addi	a4,a4,-1172 # 80200f38 <etext+0x542>
    802003d4:	078a                	slli	a5,a5,0x2
    802003d6:	97ba                	add	a5,a5,a4
    802003d8:	439c                	lw	a5,0(a5)
    802003da:	97ba                	add	a5,a5,a4
    802003dc:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
    802003de:	00001517          	auipc	a0,0x1
    802003e2:	b0a50513          	addi	a0,a0,-1270 # 80200ee8 <etext+0x4f2>
    802003e6:	bb09                	j	802000f8 <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003e8:	00001517          	auipc	a0,0x1
    802003ec:	ae050513          	addi	a0,a0,-1312 # 80200ec8 <etext+0x4d2>
    802003f0:	b321                	j	802000f8 <cprintf>
            cprintf("User software interrupt\n");
    802003f2:	00001517          	auipc	a0,0x1
    802003f6:	a9650513          	addi	a0,a0,-1386 # 80200e88 <etext+0x492>
    802003fa:	b9fd                	j	802000f8 <cprintf>
            cprintf("Supervisor software interrupt\n");
    802003fc:	00001517          	auipc	a0,0x1
    80200400:	aac50513          	addi	a0,a0,-1364 # 80200ea8 <etext+0x4b2>
    80200404:	b9d5                	j	802000f8 <cprintf>
void interrupt_handler(struct trapframe *tf) {
    80200406:	1141                	addi	sp,sp,-16
    80200408:	e022                	sd	s0,0(sp)
    8020040a:	e406                	sd	ra,8(sp)
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
           
           clock_set_next_event();//发生这次时钟中断的时候，我们要设置下一次时钟中断
            if (++ticks % TICK_NUM == 0) {
    8020040c:	00004417          	auipc	s0,0x4
    80200410:	bfc40413          	addi	s0,s0,-1028 # 80204008 <ticks>
           clock_set_next_event();//发生这次时钟中断的时候，我们要设置下一次时钟中断
    80200414:	d4dff0ef          	jal	ra,80200160 <clock_set_next_event>
            if (++ticks % TICK_NUM == 0) {
    80200418:	601c                	ld	a5,0(s0)
    8020041a:	06400713          	li	a4,100
    8020041e:	0785                	addi	a5,a5,1
    80200420:	02e7f733          	remu	a4,a5,a4
    80200424:	e01c                	sd	a5,0(s0)
    80200426:	cb19                	beqz	a4,8020043c <interrupt_handler+0x7e>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    80200428:	60a2                	ld	ra,8(sp)
    8020042a:	6402                	ld	s0,0(sp)
    8020042c:	0141                	addi	sp,sp,16
    8020042e:	8082                	ret
            cprintf("Supervisor external interrupt\n");
    80200430:	00001517          	auipc	a0,0x1
    80200434:	ae850513          	addi	a0,a0,-1304 # 80200f18 <etext+0x522>
    80200438:	b1c1                	j	802000f8 <cprintf>
            print_trapframe(tf);
    8020043a:	b715                	j	8020035e <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    8020043c:	06400593          	li	a1,100
    80200440:	00001517          	auipc	a0,0x1
    80200444:	ac850513          	addi	a0,a0,-1336 # 80200f08 <etext+0x512>
    80200448:	cb1ff0ef          	jal	ra,802000f8 <cprintf>
                if(ticks%(10*TICK_NUM)==0){
    8020044c:	601c                	ld	a5,0(s0)
    8020044e:	3e800713          	li	a4,1000
    80200452:	02e7f7b3          	remu	a5,a5,a4
    80200456:	fbe9                	bnez	a5,80200428 <interrupt_handler+0x6a>
                      asm volatile(
    80200458:	9002                	ebreak
    8020045a:	b7f9                	j	80200428 <interrupt_handler+0x6a>

000000008020045c <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    8020045c:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
    80200460:	1141                	addi	sp,sp,-16
    80200462:	e022                	sd	s0,0(sp)
    80200464:	e406                	sd	ra,8(sp)
    switch (tf->cause) {
    80200466:	470d                	li	a4,3
void exception_handler(struct trapframe *tf) {
    80200468:	842a                	mv	s0,a0
    switch (tf->cause) {
    8020046a:	04e78663          	beq	a5,a4,802004b6 <exception_handler+0x5a>
    8020046e:	02f76c63          	bltu	a4,a5,802004a6 <exception_handler+0x4a>
    80200472:	4709                	li	a4,2
    80200474:	02e79563          	bne	a5,a4,8020049e <exception_handler+0x42>
             /* LAB1 CHALLENGE3   2213013 :  */
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
           cprintf("Exception type:Illegal instruction\n");
    80200478:	00001517          	auipc	a0,0x1
    8020047c:	af050513          	addi	a0,a0,-1296 # 80200f68 <etext+0x572>
    80200480:	c79ff0ef          	jal	ra,802000f8 <cprintf>
            cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
    80200484:	10843583          	ld	a1,264(s0)
    80200488:	00001517          	auipc	a0,0x1
    8020048c:	b0850513          	addi	a0,a0,-1272 # 80200f90 <etext+0x59a>
    80200490:	c69ff0ef          	jal	ra,802000f8 <cprintf>
            tf->epc += 4; // 更新异常指令地址到下一条指令，假设指令长度为 4 字节
    80200494:	10843783          	ld	a5,264(s0)
    80200498:	0791                	addi	a5,a5,4
    8020049a:	10f43423          	sd	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    8020049e:	60a2                	ld	ra,8(sp)
    802004a0:	6402                	ld	s0,0(sp)
    802004a2:	0141                	addi	sp,sp,16
    802004a4:	8082                	ret
    switch (tf->cause) {
    802004a6:	17f1                	addi	a5,a5,-4
    802004a8:	471d                	li	a4,7
    802004aa:	fef77ae3          	bgeu	a4,a5,8020049e <exception_handler+0x42>
}
    802004ae:	6402                	ld	s0,0(sp)
    802004b0:	60a2                	ld	ra,8(sp)
    802004b2:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004b4:	b56d                	j	8020035e <print_trapframe>
           cprintf("Exception type: breakpoint\n");
    802004b6:	00001517          	auipc	a0,0x1
    802004ba:	b0250513          	addi	a0,a0,-1278 # 80200fb8 <etext+0x5c2>
    802004be:	c3bff0ef          	jal	ra,802000f8 <cprintf>
            cprintf("ebreak caught at 0x%08x\n", tf->epc);
    802004c2:	10843583          	ld	a1,264(s0)
    802004c6:	00001517          	auipc	a0,0x1
    802004ca:	b1250513          	addi	a0,a0,-1262 # 80200fd8 <etext+0x5e2>
    802004ce:	c2bff0ef          	jal	ra,802000f8 <cprintf>
            tf->epc += 2; // 更新异常指令地址到下一条指令，假设指令长度为 4 字节
    802004d2:	10843783          	ld	a5,264(s0)
}
    802004d6:	60a2                	ld	ra,8(sp)
            tf->epc += 2; // 更新异常指令地址到下一条指令，假设指令长度为 4 字节
    802004d8:	0789                	addi	a5,a5,2
    802004da:	10f43423          	sd	a5,264(s0)
}
    802004de:	6402                	ld	s0,0(sp)
    802004e0:	0141                	addi	sp,sp,16
    802004e2:	8082                	ret

00000000802004e4 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    802004e4:	11853783          	ld	a5,280(a0)
    802004e8:	0007c363          	bltz	a5,802004ee <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    802004ec:	bf85                	j	8020045c <exception_handler>
        interrupt_handler(tf);
    802004ee:	bdc1                	j	802003be <interrupt_handler>

00000000802004f0 <__alltraps>:
    802004f0:	14011073          	csrw	sscratch,sp
    802004f4:	712d                	addi	sp,sp,-288
    802004f6:	e002                	sd	zero,0(sp)
    802004f8:	e406                	sd	ra,8(sp)
    802004fa:	ec0e                	sd	gp,24(sp)
    802004fc:	f012                	sd	tp,32(sp)
    802004fe:	f416                	sd	t0,40(sp)
    80200500:	f81a                	sd	t1,48(sp)
    80200502:	fc1e                	sd	t2,56(sp)
    80200504:	e0a2                	sd	s0,64(sp)
    80200506:	e4a6                	sd	s1,72(sp)
    80200508:	e8aa                	sd	a0,80(sp)
    8020050a:	ecae                	sd	a1,88(sp)
    8020050c:	f0b2                	sd	a2,96(sp)
    8020050e:	f4b6                	sd	a3,104(sp)
    80200510:	f8ba                	sd	a4,112(sp)
    80200512:	fcbe                	sd	a5,120(sp)
    80200514:	e142                	sd	a6,128(sp)
    80200516:	e546                	sd	a7,136(sp)
    80200518:	e94a                	sd	s2,144(sp)
    8020051a:	ed4e                	sd	s3,152(sp)
    8020051c:	f152                	sd	s4,160(sp)
    8020051e:	f556                	sd	s5,168(sp)
    80200520:	f95a                	sd	s6,176(sp)
    80200522:	fd5e                	sd	s7,184(sp)
    80200524:	e1e2                	sd	s8,192(sp)
    80200526:	e5e6                	sd	s9,200(sp)
    80200528:	e9ea                	sd	s10,208(sp)
    8020052a:	edee                	sd	s11,216(sp)
    8020052c:	f1f2                	sd	t3,224(sp)
    8020052e:	f5f6                	sd	t4,232(sp)
    80200530:	f9fa                	sd	t5,240(sp)
    80200532:	fdfe                	sd	t6,248(sp)
    80200534:	14001473          	csrrw	s0,sscratch,zero
    80200538:	100024f3          	csrr	s1,sstatus
    8020053c:	14102973          	csrr	s2,sepc
    80200540:	143029f3          	csrr	s3,stval
    80200544:	14202a73          	csrr	s4,scause
    80200548:	e822                	sd	s0,16(sp)
    8020054a:	e226                	sd	s1,256(sp)
    8020054c:	e64a                	sd	s2,264(sp)
    8020054e:	ea4e                	sd	s3,272(sp)
    80200550:	ee52                	sd	s4,280(sp)
    80200552:	850a                	mv	a0,sp
    80200554:	f91ff0ef          	jal	ra,802004e4 <trap>

0000000080200558 <__trapret>:
    80200558:	6492                	ld	s1,256(sp)
    8020055a:	6932                	ld	s2,264(sp)
    8020055c:	10049073          	csrw	sstatus,s1
    80200560:	14191073          	csrw	sepc,s2
    80200564:	60a2                	ld	ra,8(sp)
    80200566:	61e2                	ld	gp,24(sp)
    80200568:	7202                	ld	tp,32(sp)
    8020056a:	72a2                	ld	t0,40(sp)
    8020056c:	7342                	ld	t1,48(sp)
    8020056e:	73e2                	ld	t2,56(sp)
    80200570:	6406                	ld	s0,64(sp)
    80200572:	64a6                	ld	s1,72(sp)
    80200574:	6546                	ld	a0,80(sp)
    80200576:	65e6                	ld	a1,88(sp)
    80200578:	7606                	ld	a2,96(sp)
    8020057a:	76a6                	ld	a3,104(sp)
    8020057c:	7746                	ld	a4,112(sp)
    8020057e:	77e6                	ld	a5,120(sp)
    80200580:	680a                	ld	a6,128(sp)
    80200582:	68aa                	ld	a7,136(sp)
    80200584:	694a                	ld	s2,144(sp)
    80200586:	69ea                	ld	s3,152(sp)
    80200588:	7a0a                	ld	s4,160(sp)
    8020058a:	7aaa                	ld	s5,168(sp)
    8020058c:	7b4a                	ld	s6,176(sp)
    8020058e:	7bea                	ld	s7,184(sp)
    80200590:	6c0e                	ld	s8,192(sp)
    80200592:	6cae                	ld	s9,200(sp)
    80200594:	6d4e                	ld	s10,208(sp)
    80200596:	6dee                	ld	s11,216(sp)
    80200598:	7e0e                	ld	t3,224(sp)
    8020059a:	7eae                	ld	t4,232(sp)
    8020059c:	7f4e                	ld	t5,240(sp)
    8020059e:	7fee                	ld	t6,248(sp)
    802005a0:	6142                	ld	sp,16(sp)
    802005a2:	10200073          	sret

00000000802005a6 <printnum>:
    802005a6:	02069813          	slli	a6,a3,0x20
    802005aa:	7179                	addi	sp,sp,-48
    802005ac:	02085813          	srli	a6,a6,0x20
    802005b0:	e052                	sd	s4,0(sp)
    802005b2:	03067a33          	remu	s4,a2,a6
    802005b6:	f022                	sd	s0,32(sp)
    802005b8:	ec26                	sd	s1,24(sp)
    802005ba:	e84a                	sd	s2,16(sp)
    802005bc:	f406                	sd	ra,40(sp)
    802005be:	e44e                	sd	s3,8(sp)
    802005c0:	84aa                	mv	s1,a0
    802005c2:	892e                	mv	s2,a1
    802005c4:	fff7041b          	addiw	s0,a4,-1
    802005c8:	2a01                	sext.w	s4,s4
    802005ca:	03067e63          	bgeu	a2,a6,80200606 <printnum+0x60>
    802005ce:	89be                	mv	s3,a5
    802005d0:	00805763          	blez	s0,802005de <printnum+0x38>
    802005d4:	347d                	addiw	s0,s0,-1
    802005d6:	85ca                	mv	a1,s2
    802005d8:	854e                	mv	a0,s3
    802005da:	9482                	jalr	s1
    802005dc:	fc65                	bnez	s0,802005d4 <printnum+0x2e>
    802005de:	1a02                	slli	s4,s4,0x20
    802005e0:	00001797          	auipc	a5,0x1
    802005e4:	a1878793          	addi	a5,a5,-1512 # 80200ff8 <etext+0x602>
    802005e8:	020a5a13          	srli	s4,s4,0x20
    802005ec:	9a3e                	add	s4,s4,a5
    802005ee:	7402                	ld	s0,32(sp)
    802005f0:	000a4503          	lbu	a0,0(s4)
    802005f4:	70a2                	ld	ra,40(sp)
    802005f6:	69a2                	ld	s3,8(sp)
    802005f8:	6a02                	ld	s4,0(sp)
    802005fa:	85ca                	mv	a1,s2
    802005fc:	87a6                	mv	a5,s1
    802005fe:	6942                	ld	s2,16(sp)
    80200600:	64e2                	ld	s1,24(sp)
    80200602:	6145                	addi	sp,sp,48
    80200604:	8782                	jr	a5
    80200606:	03065633          	divu	a2,a2,a6
    8020060a:	8722                	mv	a4,s0
    8020060c:	f9bff0ef          	jal	ra,802005a6 <printnum>
    80200610:	b7f9                	j	802005de <printnum+0x38>

0000000080200612 <vprintfmt>:
    80200612:	7119                	addi	sp,sp,-128
    80200614:	f4a6                	sd	s1,104(sp)
    80200616:	f0ca                	sd	s2,96(sp)
    80200618:	ecce                	sd	s3,88(sp)
    8020061a:	e8d2                	sd	s4,80(sp)
    8020061c:	e4d6                	sd	s5,72(sp)
    8020061e:	e0da                	sd	s6,64(sp)
    80200620:	fc5e                	sd	s7,56(sp)
    80200622:	f06a                	sd	s10,32(sp)
    80200624:	fc86                	sd	ra,120(sp)
    80200626:	f8a2                	sd	s0,112(sp)
    80200628:	f862                	sd	s8,48(sp)
    8020062a:	f466                	sd	s9,40(sp)
    8020062c:	ec6e                	sd	s11,24(sp)
    8020062e:	892a                	mv	s2,a0
    80200630:	84ae                	mv	s1,a1
    80200632:	8d32                	mv	s10,a2
    80200634:	8a36                	mv	s4,a3
    80200636:	02500993          	li	s3,37
    8020063a:	5b7d                	li	s6,-1
    8020063c:	00001a97          	auipc	s5,0x1
    80200640:	9f0a8a93          	addi	s5,s5,-1552 # 8020102c <etext+0x636>
    80200644:	00001b97          	auipc	s7,0x1
    80200648:	bc4b8b93          	addi	s7,s7,-1084 # 80201208 <error_string>
    8020064c:	000d4503          	lbu	a0,0(s10)
    80200650:	001d0413          	addi	s0,s10,1
    80200654:	01350a63          	beq	a0,s3,80200668 <vprintfmt+0x56>
    80200658:	c121                	beqz	a0,80200698 <vprintfmt+0x86>
    8020065a:	85a6                	mv	a1,s1
    8020065c:	0405                	addi	s0,s0,1
    8020065e:	9902                	jalr	s2
    80200660:	fff44503          	lbu	a0,-1(s0)
    80200664:	ff351ae3          	bne	a0,s3,80200658 <vprintfmt+0x46>
    80200668:	00044603          	lbu	a2,0(s0)
    8020066c:	02000793          	li	a5,32
    80200670:	4c81                	li	s9,0
    80200672:	4881                	li	a7,0
    80200674:	5c7d                	li	s8,-1
    80200676:	5dfd                	li	s11,-1
    80200678:	05500513          	li	a0,85
    8020067c:	4825                	li	a6,9
    8020067e:	fdd6059b          	addiw	a1,a2,-35
    80200682:	0ff5f593          	andi	a1,a1,255
    80200686:	00140d13          	addi	s10,s0,1
    8020068a:	04b56263          	bltu	a0,a1,802006ce <vprintfmt+0xbc>
    8020068e:	058a                	slli	a1,a1,0x2
    80200690:	95d6                	add	a1,a1,s5
    80200692:	4194                	lw	a3,0(a1)
    80200694:	96d6                	add	a3,a3,s5
    80200696:	8682                	jr	a3
    80200698:	70e6                	ld	ra,120(sp)
    8020069a:	7446                	ld	s0,112(sp)
    8020069c:	74a6                	ld	s1,104(sp)
    8020069e:	7906                	ld	s2,96(sp)
    802006a0:	69e6                	ld	s3,88(sp)
    802006a2:	6a46                	ld	s4,80(sp)
    802006a4:	6aa6                	ld	s5,72(sp)
    802006a6:	6b06                	ld	s6,64(sp)
    802006a8:	7be2                	ld	s7,56(sp)
    802006aa:	7c42                	ld	s8,48(sp)
    802006ac:	7ca2                	ld	s9,40(sp)
    802006ae:	7d02                	ld	s10,32(sp)
    802006b0:	6de2                	ld	s11,24(sp)
    802006b2:	6109                	addi	sp,sp,128
    802006b4:	8082                	ret
    802006b6:	87b2                	mv	a5,a2
    802006b8:	00144603          	lbu	a2,1(s0)
    802006bc:	846a                	mv	s0,s10
    802006be:	00140d13          	addi	s10,s0,1
    802006c2:	fdd6059b          	addiw	a1,a2,-35
    802006c6:	0ff5f593          	andi	a1,a1,255
    802006ca:	fcb572e3          	bgeu	a0,a1,8020068e <vprintfmt+0x7c>
    802006ce:	85a6                	mv	a1,s1
    802006d0:	02500513          	li	a0,37
    802006d4:	9902                	jalr	s2
    802006d6:	fff44783          	lbu	a5,-1(s0)
    802006da:	8d22                	mv	s10,s0
    802006dc:	f73788e3          	beq	a5,s3,8020064c <vprintfmt+0x3a>
    802006e0:	ffed4783          	lbu	a5,-2(s10)
    802006e4:	1d7d                	addi	s10,s10,-1
    802006e6:	ff379de3          	bne	a5,s3,802006e0 <vprintfmt+0xce>
    802006ea:	b78d                	j	8020064c <vprintfmt+0x3a>
    802006ec:	fd060c1b          	addiw	s8,a2,-48
    802006f0:	00144603          	lbu	a2,1(s0)
    802006f4:	846a                	mv	s0,s10
    802006f6:	fd06069b          	addiw	a3,a2,-48
    802006fa:	0006059b          	sext.w	a1,a2
    802006fe:	02d86463          	bltu	a6,a3,80200726 <vprintfmt+0x114>
    80200702:	00144603          	lbu	a2,1(s0)
    80200706:	002c169b          	slliw	a3,s8,0x2
    8020070a:	0186873b          	addw	a4,a3,s8
    8020070e:	0017171b          	slliw	a4,a4,0x1
    80200712:	9f2d                	addw	a4,a4,a1
    80200714:	fd06069b          	addiw	a3,a2,-48
    80200718:	0405                	addi	s0,s0,1
    8020071a:	fd070c1b          	addiw	s8,a4,-48
    8020071e:	0006059b          	sext.w	a1,a2
    80200722:	fed870e3          	bgeu	a6,a3,80200702 <vprintfmt+0xf0>
    80200726:	f40ddce3          	bgez	s11,8020067e <vprintfmt+0x6c>
    8020072a:	8de2                	mv	s11,s8
    8020072c:	5c7d                	li	s8,-1
    8020072e:	bf81                	j	8020067e <vprintfmt+0x6c>
    80200730:	fffdc693          	not	a3,s11
    80200734:	96fd                	srai	a3,a3,0x3f
    80200736:	00ddfdb3          	and	s11,s11,a3
    8020073a:	00144603          	lbu	a2,1(s0)
    8020073e:	2d81                	sext.w	s11,s11
    80200740:	846a                	mv	s0,s10
    80200742:	bf35                	j	8020067e <vprintfmt+0x6c>
    80200744:	000a2c03          	lw	s8,0(s4)
    80200748:	00144603          	lbu	a2,1(s0)
    8020074c:	0a21                	addi	s4,s4,8
    8020074e:	846a                	mv	s0,s10
    80200750:	bfd9                	j	80200726 <vprintfmt+0x114>
    80200752:	4705                	li	a4,1
    80200754:	008a0593          	addi	a1,s4,8
    80200758:	01174463          	blt	a4,a7,80200760 <vprintfmt+0x14e>
    8020075c:	1a088e63          	beqz	a7,80200918 <vprintfmt+0x306>
    80200760:	000a3603          	ld	a2,0(s4)
    80200764:	46c1                	li	a3,16
    80200766:	8a2e                	mv	s4,a1
    80200768:	2781                	sext.w	a5,a5
    8020076a:	876e                	mv	a4,s11
    8020076c:	85a6                	mv	a1,s1
    8020076e:	854a                	mv	a0,s2
    80200770:	e37ff0ef          	jal	ra,802005a6 <printnum>
    80200774:	bde1                	j	8020064c <vprintfmt+0x3a>
    80200776:	000a2503          	lw	a0,0(s4)
    8020077a:	85a6                	mv	a1,s1
    8020077c:	0a21                	addi	s4,s4,8
    8020077e:	9902                	jalr	s2
    80200780:	b5f1                	j	8020064c <vprintfmt+0x3a>
    80200782:	4705                	li	a4,1
    80200784:	008a0593          	addi	a1,s4,8
    80200788:	01174463          	blt	a4,a7,80200790 <vprintfmt+0x17e>
    8020078c:	18088163          	beqz	a7,8020090e <vprintfmt+0x2fc>
    80200790:	000a3603          	ld	a2,0(s4)
    80200794:	46a9                	li	a3,10
    80200796:	8a2e                	mv	s4,a1
    80200798:	bfc1                	j	80200768 <vprintfmt+0x156>
    8020079a:	00144603          	lbu	a2,1(s0)
    8020079e:	4c85                	li	s9,1
    802007a0:	846a                	mv	s0,s10
    802007a2:	bdf1                	j	8020067e <vprintfmt+0x6c>
    802007a4:	85a6                	mv	a1,s1
    802007a6:	02500513          	li	a0,37
    802007aa:	9902                	jalr	s2
    802007ac:	b545                	j	8020064c <vprintfmt+0x3a>
    802007ae:	00144603          	lbu	a2,1(s0)
    802007b2:	2885                	addiw	a7,a7,1
    802007b4:	846a                	mv	s0,s10
    802007b6:	b5e1                	j	8020067e <vprintfmt+0x6c>
    802007b8:	4705                	li	a4,1
    802007ba:	008a0593          	addi	a1,s4,8
    802007be:	01174463          	blt	a4,a7,802007c6 <vprintfmt+0x1b4>
    802007c2:	14088163          	beqz	a7,80200904 <vprintfmt+0x2f2>
    802007c6:	000a3603          	ld	a2,0(s4)
    802007ca:	46a1                	li	a3,8
    802007cc:	8a2e                	mv	s4,a1
    802007ce:	bf69                	j	80200768 <vprintfmt+0x156>
    802007d0:	03000513          	li	a0,48
    802007d4:	85a6                	mv	a1,s1
    802007d6:	e03e                	sd	a5,0(sp)
    802007d8:	9902                	jalr	s2
    802007da:	85a6                	mv	a1,s1
    802007dc:	07800513          	li	a0,120
    802007e0:	9902                	jalr	s2
    802007e2:	0a21                	addi	s4,s4,8
    802007e4:	6782                	ld	a5,0(sp)
    802007e6:	46c1                	li	a3,16
    802007e8:	ff8a3603          	ld	a2,-8(s4)
    802007ec:	bfb5                	j	80200768 <vprintfmt+0x156>
    802007ee:	000a3403          	ld	s0,0(s4)
    802007f2:	008a0713          	addi	a4,s4,8
    802007f6:	e03a                	sd	a4,0(sp)
    802007f8:	14040263          	beqz	s0,8020093c <vprintfmt+0x32a>
    802007fc:	0fb05763          	blez	s11,802008ea <vprintfmt+0x2d8>
    80200800:	02d00693          	li	a3,45
    80200804:	0cd79163          	bne	a5,a3,802008c6 <vprintfmt+0x2b4>
    80200808:	00044783          	lbu	a5,0(s0)
    8020080c:	0007851b          	sext.w	a0,a5
    80200810:	cf85                	beqz	a5,80200848 <vprintfmt+0x236>
    80200812:	00140a13          	addi	s4,s0,1
    80200816:	05e00413          	li	s0,94
    8020081a:	000c4563          	bltz	s8,80200824 <vprintfmt+0x212>
    8020081e:	3c7d                	addiw	s8,s8,-1
    80200820:	036c0263          	beq	s8,s6,80200844 <vprintfmt+0x232>
    80200824:	85a6                	mv	a1,s1
    80200826:	0e0c8e63          	beqz	s9,80200922 <vprintfmt+0x310>
    8020082a:	3781                	addiw	a5,a5,-32
    8020082c:	0ef47b63          	bgeu	s0,a5,80200922 <vprintfmt+0x310>
    80200830:	03f00513          	li	a0,63
    80200834:	9902                	jalr	s2
    80200836:	000a4783          	lbu	a5,0(s4)
    8020083a:	3dfd                	addiw	s11,s11,-1
    8020083c:	0a05                	addi	s4,s4,1
    8020083e:	0007851b          	sext.w	a0,a5
    80200842:	ffe1                	bnez	a5,8020081a <vprintfmt+0x208>
    80200844:	01b05963          	blez	s11,80200856 <vprintfmt+0x244>
    80200848:	3dfd                	addiw	s11,s11,-1
    8020084a:	85a6                	mv	a1,s1
    8020084c:	02000513          	li	a0,32
    80200850:	9902                	jalr	s2
    80200852:	fe0d9be3          	bnez	s11,80200848 <vprintfmt+0x236>
    80200856:	6a02                	ld	s4,0(sp)
    80200858:	bbd5                	j	8020064c <vprintfmt+0x3a>
    8020085a:	4705                	li	a4,1
    8020085c:	008a0c93          	addi	s9,s4,8
    80200860:	01174463          	blt	a4,a7,80200868 <vprintfmt+0x256>
    80200864:	08088d63          	beqz	a7,802008fe <vprintfmt+0x2ec>
    80200868:	000a3403          	ld	s0,0(s4)
    8020086c:	0a044d63          	bltz	s0,80200926 <vprintfmt+0x314>
    80200870:	8622                	mv	a2,s0
    80200872:	8a66                	mv	s4,s9
    80200874:	46a9                	li	a3,10
    80200876:	bdcd                	j	80200768 <vprintfmt+0x156>
    80200878:	000a2783          	lw	a5,0(s4)
    8020087c:	4719                	li	a4,6
    8020087e:	0a21                	addi	s4,s4,8
    80200880:	41f7d69b          	sraiw	a3,a5,0x1f
    80200884:	8fb5                	xor	a5,a5,a3
    80200886:	40d786bb          	subw	a3,a5,a3
    8020088a:	02d74163          	blt	a4,a3,802008ac <vprintfmt+0x29a>
    8020088e:	00369793          	slli	a5,a3,0x3
    80200892:	97de                	add	a5,a5,s7
    80200894:	639c                	ld	a5,0(a5)
    80200896:	cb99                	beqz	a5,802008ac <vprintfmt+0x29a>
    80200898:	86be                	mv	a3,a5
    8020089a:	00000617          	auipc	a2,0x0
    8020089e:	78e60613          	addi	a2,a2,1934 # 80201028 <etext+0x632>
    802008a2:	85a6                	mv	a1,s1
    802008a4:	854a                	mv	a0,s2
    802008a6:	0ce000ef          	jal	ra,80200974 <printfmt>
    802008aa:	b34d                	j	8020064c <vprintfmt+0x3a>
    802008ac:	00000617          	auipc	a2,0x0
    802008b0:	76c60613          	addi	a2,a2,1900 # 80201018 <etext+0x622>
    802008b4:	85a6                	mv	a1,s1
    802008b6:	854a                	mv	a0,s2
    802008b8:	0bc000ef          	jal	ra,80200974 <printfmt>
    802008bc:	bb41                	j	8020064c <vprintfmt+0x3a>
    802008be:	00000417          	auipc	s0,0x0
    802008c2:	75240413          	addi	s0,s0,1874 # 80201010 <etext+0x61a>
    802008c6:	85e2                	mv	a1,s8
    802008c8:	8522                	mv	a0,s0
    802008ca:	e43e                	sd	a5,8(sp)
    802008cc:	0fc000ef          	jal	ra,802009c8 <strnlen>
    802008d0:	40ad8dbb          	subw	s11,s11,a0
    802008d4:	01b05b63          	blez	s11,802008ea <vprintfmt+0x2d8>
    802008d8:	67a2                	ld	a5,8(sp)
    802008da:	00078a1b          	sext.w	s4,a5
    802008de:	3dfd                	addiw	s11,s11,-1
    802008e0:	85a6                	mv	a1,s1
    802008e2:	8552                	mv	a0,s4
    802008e4:	9902                	jalr	s2
    802008e6:	fe0d9ce3          	bnez	s11,802008de <vprintfmt+0x2cc>
    802008ea:	00044783          	lbu	a5,0(s0)
    802008ee:	00140a13          	addi	s4,s0,1
    802008f2:	0007851b          	sext.w	a0,a5
    802008f6:	d3a5                	beqz	a5,80200856 <vprintfmt+0x244>
    802008f8:	05e00413          	li	s0,94
    802008fc:	bf39                	j	8020081a <vprintfmt+0x208>
    802008fe:	000a2403          	lw	s0,0(s4)
    80200902:	b7ad                	j	8020086c <vprintfmt+0x25a>
    80200904:	000a6603          	lwu	a2,0(s4)
    80200908:	46a1                	li	a3,8
    8020090a:	8a2e                	mv	s4,a1
    8020090c:	bdb1                	j	80200768 <vprintfmt+0x156>
    8020090e:	000a6603          	lwu	a2,0(s4)
    80200912:	46a9                	li	a3,10
    80200914:	8a2e                	mv	s4,a1
    80200916:	bd89                	j	80200768 <vprintfmt+0x156>
    80200918:	000a6603          	lwu	a2,0(s4)
    8020091c:	46c1                	li	a3,16
    8020091e:	8a2e                	mv	s4,a1
    80200920:	b5a1                	j	80200768 <vprintfmt+0x156>
    80200922:	9902                	jalr	s2
    80200924:	bf09                	j	80200836 <vprintfmt+0x224>
    80200926:	85a6                	mv	a1,s1
    80200928:	02d00513          	li	a0,45
    8020092c:	e03e                	sd	a5,0(sp)
    8020092e:	9902                	jalr	s2
    80200930:	6782                	ld	a5,0(sp)
    80200932:	8a66                	mv	s4,s9
    80200934:	40800633          	neg	a2,s0
    80200938:	46a9                	li	a3,10
    8020093a:	b53d                	j	80200768 <vprintfmt+0x156>
    8020093c:	03b05163          	blez	s11,8020095e <vprintfmt+0x34c>
    80200940:	02d00693          	li	a3,45
    80200944:	f6d79de3          	bne	a5,a3,802008be <vprintfmt+0x2ac>
    80200948:	00000417          	auipc	s0,0x0
    8020094c:	6c840413          	addi	s0,s0,1736 # 80201010 <etext+0x61a>
    80200950:	02800793          	li	a5,40
    80200954:	02800513          	li	a0,40
    80200958:	00140a13          	addi	s4,s0,1
    8020095c:	bd6d                	j	80200816 <vprintfmt+0x204>
    8020095e:	00000a17          	auipc	s4,0x0
    80200962:	6b3a0a13          	addi	s4,s4,1715 # 80201011 <etext+0x61b>
    80200966:	02800513          	li	a0,40
    8020096a:	02800793          	li	a5,40
    8020096e:	05e00413          	li	s0,94
    80200972:	b565                	j	8020081a <vprintfmt+0x208>

0000000080200974 <printfmt>:
    80200974:	715d                	addi	sp,sp,-80
    80200976:	02810313          	addi	t1,sp,40
    8020097a:	f436                	sd	a3,40(sp)
    8020097c:	869a                	mv	a3,t1
    8020097e:	ec06                	sd	ra,24(sp)
    80200980:	f83a                	sd	a4,48(sp)
    80200982:	fc3e                	sd	a5,56(sp)
    80200984:	e0c2                	sd	a6,64(sp)
    80200986:	e4c6                	sd	a7,72(sp)
    80200988:	e41a                	sd	t1,8(sp)
    8020098a:	c89ff0ef          	jal	ra,80200612 <vprintfmt>
    8020098e:	60e2                	ld	ra,24(sp)
    80200990:	6161                	addi	sp,sp,80
    80200992:	8082                	ret

0000000080200994 <sbi_console_putchar>:
    80200994:	4781                	li	a5,0
    80200996:	00003717          	auipc	a4,0x3
    8020099a:	66a73703          	ld	a4,1642(a4) # 80204000 <SBI_CONSOLE_PUTCHAR>
    8020099e:	88ba                	mv	a7,a4
    802009a0:	852a                	mv	a0,a0
    802009a2:	85be                	mv	a1,a5
    802009a4:	863e                	mv	a2,a5
    802009a6:	00000073          	ecall
    802009aa:	87aa                	mv	a5,a0
    802009ac:	8082                	ret

00000000802009ae <sbi_set_timer>:
    802009ae:	4781                	li	a5,0
    802009b0:	00003717          	auipc	a4,0x3
    802009b4:	66073703          	ld	a4,1632(a4) # 80204010 <SBI_SET_TIMER>
    802009b8:	88ba                	mv	a7,a4
    802009ba:	852a                	mv	a0,a0
    802009bc:	85be                	mv	a1,a5
    802009be:	863e                	mv	a2,a5
    802009c0:	00000073          	ecall
    802009c4:	87aa                	mv	a5,a0
    802009c6:	8082                	ret

00000000802009c8 <strnlen>:
    802009c8:	4781                	li	a5,0
    802009ca:	e589                	bnez	a1,802009d4 <strnlen+0xc>
    802009cc:	a811                	j	802009e0 <strnlen+0x18>
    802009ce:	0785                	addi	a5,a5,1
    802009d0:	00f58863          	beq	a1,a5,802009e0 <strnlen+0x18>
    802009d4:	00f50733          	add	a4,a0,a5
    802009d8:	00074703          	lbu	a4,0(a4)
    802009dc:	fb6d                	bnez	a4,802009ce <strnlen+0x6>
    802009de:	85be                	mv	a1,a5
    802009e0:	852e                	mv	a0,a1
    802009e2:	8082                	ret

00000000802009e4 <memset>:
    802009e4:	ca01                	beqz	a2,802009f4 <memset+0x10>
    802009e6:	962a                	add	a2,a2,a0
    802009e8:	87aa                	mv	a5,a0
    802009ea:	0785                	addi	a5,a5,1
    802009ec:	feb78fa3          	sb	a1,-1(a5)
    802009f0:	fec79de3          	bne	a5,a2,802009ea <memset+0x6>
    802009f4:	8082                	ret
