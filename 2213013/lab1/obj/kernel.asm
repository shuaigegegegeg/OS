
bin/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080200000 <kern_entry>:
    80200000:	00004117          	auipc	sp,0x4
    80200004:	00010113          	mv	sp,sp
    80200008:	a009                	j	8020000a <kern_init>

000000008020000a <kern_init>:
    8020000a:	00004517          	auipc	a0,0x4
    8020000e:	00650513          	addi	a0,a0,6 # 80204010 <ticks>
    80200012:	00004617          	auipc	a2,0x4
    80200016:	00e60613          	addi	a2,a2,14 # 80204020 <end>
    8020001a:	1141                	addi	sp,sp,-16
    8020001c:	8e09                	sub	a2,a2,a0
    8020001e:	4581                	li	a1,0
    80200020:	e406                	sd	ra,8(sp)
    80200022:	1e1000ef          	jal	ra,80200a02 <memset>
    80200026:	14a000ef          	jal	ra,80200170 <cons_init>
    8020002a:	00001597          	auipc	a1,0x1
    8020002e:	9ee58593          	addi	a1,a1,-1554 # 80200a18 <etext+0x4>
    80200032:	00001517          	auipc	a0,0x1
    80200036:	a0650513          	addi	a0,a0,-1530 # 80200a38 <etext+0x24>
    8020003a:	0be000ef          	jal	ra,802000f8 <cprintf>
    8020003e:	012000ef          	jal	ra,80200050 <print_kerninfo>
    80200042:	13e000ef          	jal	ra,80200180 <idt_init>
    80200046:	0e8000ef          	jal	ra,8020012e <clock_init>
    8020004a:	130000ef          	jal	ra,8020017a <intr_enable>
    8020004e:	a001                	j	8020004e <kern_init+0x44>

0000000080200050 <print_kerninfo>:
    80200050:	1141                	addi	sp,sp,-16
    80200052:	00001517          	auipc	a0,0x1
    80200056:	9ee50513          	addi	a0,a0,-1554 # 80200a40 <etext+0x2c>
    8020005a:	e406                	sd	ra,8(sp)
    8020005c:	09c000ef          	jal	ra,802000f8 <cprintf>
    80200060:	00000597          	auipc	a1,0x0
    80200064:	faa58593          	addi	a1,a1,-86 # 8020000a <kern_init>
    80200068:	00001517          	auipc	a0,0x1
    8020006c:	9f850513          	addi	a0,a0,-1544 # 80200a60 <etext+0x4c>
    80200070:	088000ef          	jal	ra,802000f8 <cprintf>
    80200074:	00001597          	auipc	a1,0x1
    80200078:	9a058593          	addi	a1,a1,-1632 # 80200a14 <etext>
    8020007c:	00001517          	auipc	a0,0x1
    80200080:	a0450513          	addi	a0,a0,-1532 # 80200a80 <etext+0x6c>
    80200084:	074000ef          	jal	ra,802000f8 <cprintf>
    80200088:	00004597          	auipc	a1,0x4
    8020008c:	f8858593          	addi	a1,a1,-120 # 80204010 <ticks>
    80200090:	00001517          	auipc	a0,0x1
    80200094:	a1050513          	addi	a0,a0,-1520 # 80200aa0 <etext+0x8c>
    80200098:	060000ef          	jal	ra,802000f8 <cprintf>
    8020009c:	00004597          	auipc	a1,0x4
    802000a0:	f8458593          	addi	a1,a1,-124 # 80204020 <end>
    802000a4:	00001517          	auipc	a0,0x1
    802000a8:	a1c50513          	addi	a0,a0,-1508 # 80200ac0 <etext+0xac>
    802000ac:	04c000ef          	jal	ra,802000f8 <cprintf>
    802000b0:	00004597          	auipc	a1,0x4
    802000b4:	36f58593          	addi	a1,a1,879 # 8020441f <end+0x3ff>
    802000b8:	00000797          	auipc	a5,0x0
    802000bc:	f5278793          	addi	a5,a5,-174 # 8020000a <kern_init>
    802000c0:	40f587b3          	sub	a5,a1,a5
    802000c4:	43f7d593          	srai	a1,a5,0x3f
    802000c8:	60a2                	ld	ra,8(sp)
    802000ca:	3ff5f593          	andi	a1,a1,1023
    802000ce:	95be                	add	a1,a1,a5
    802000d0:	85a9                	srai	a1,a1,0xa
    802000d2:	00001517          	auipc	a0,0x1
    802000d6:	a0e50513          	addi	a0,a0,-1522 # 80200ae0 <etext+0xcc>
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
    802000fa:	02810313          	addi	t1,sp,40 # 80204028 <end+0x8>
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
    80200122:	4f4000ef          	jal	ra,80200616 <vprintfmt>
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
    80200146:	06d000ef          	jal	ra,802009b2 <sbi_set_timer>
    8020014a:	60a2                	ld	ra,8(sp)
    8020014c:	00004797          	auipc	a5,0x4
    80200150:	ec07b223          	sd	zero,-316(a5) # 80204010 <ticks>
    80200154:	00001517          	auipc	a0,0x1
    80200158:	9bc50513          	addi	a0,a0,-1604 # 80200b10 <etext+0xfc>
    8020015c:	0141                	addi	sp,sp,16
    8020015e:	bf69                	j	802000f8 <cprintf>

0000000080200160 <clock_set_next_event>:
    80200160:	c0102573          	rdtime	a0
    80200164:	67e1                	lui	a5,0x18
    80200166:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0x801e7960>
    8020016a:	953e                	add	a0,a0,a5
    8020016c:	0470006f          	j	802009b2 <sbi_set_timer>

0000000080200170 <cons_init>:
    80200170:	8082                	ret

0000000080200172 <cons_putc>:
    80200172:	0ff57513          	andi	a0,a0,255
    80200176:	0230006f          	j	80200998 <sbi_console_putchar>

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
    80200188:	37078793          	addi	a5,a5,880 # 802004f4 <__alltraps>
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
    8020019e:	99650513          	addi	a0,a0,-1642 # 80200b30 <etext+0x11c>
void print_regs(struct pushregs *gpr) {
    802001a2:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
    802001a4:	f55ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
    802001a8:	640c                	ld	a1,8(s0)
    802001aa:	00001517          	auipc	a0,0x1
    802001ae:	99e50513          	addi	a0,a0,-1634 # 80200b48 <etext+0x134>
    802001b2:	f47ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
    802001b6:	680c                	ld	a1,16(s0)
    802001b8:	00001517          	auipc	a0,0x1
    802001bc:	9a850513          	addi	a0,a0,-1624 # 80200b60 <etext+0x14c>
    802001c0:	f39ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
    802001c4:	6c0c                	ld	a1,24(s0)
    802001c6:	00001517          	auipc	a0,0x1
    802001ca:	9b250513          	addi	a0,a0,-1614 # 80200b78 <etext+0x164>
    802001ce:	f2bff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
    802001d2:	700c                	ld	a1,32(s0)
    802001d4:	00001517          	auipc	a0,0x1
    802001d8:	9bc50513          	addi	a0,a0,-1604 # 80200b90 <etext+0x17c>
    802001dc:	f1dff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
    802001e0:	740c                	ld	a1,40(s0)
    802001e2:	00001517          	auipc	a0,0x1
    802001e6:	9c650513          	addi	a0,a0,-1594 # 80200ba8 <etext+0x194>
    802001ea:	f0fff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
    802001ee:	780c                	ld	a1,48(s0)
    802001f0:	00001517          	auipc	a0,0x1
    802001f4:	9d050513          	addi	a0,a0,-1584 # 80200bc0 <etext+0x1ac>
    802001f8:	f01ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
    802001fc:	7c0c                	ld	a1,56(s0)
    802001fe:	00001517          	auipc	a0,0x1
    80200202:	9da50513          	addi	a0,a0,-1574 # 80200bd8 <etext+0x1c4>
    80200206:	ef3ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
    8020020a:	602c                	ld	a1,64(s0)
    8020020c:	00001517          	auipc	a0,0x1
    80200210:	9e450513          	addi	a0,a0,-1564 # 80200bf0 <etext+0x1dc>
    80200214:	ee5ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
    80200218:	642c                	ld	a1,72(s0)
    8020021a:	00001517          	auipc	a0,0x1
    8020021e:	9ee50513          	addi	a0,a0,-1554 # 80200c08 <etext+0x1f4>
    80200222:	ed7ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
    80200226:	682c                	ld	a1,80(s0)
    80200228:	00001517          	auipc	a0,0x1
    8020022c:	9f850513          	addi	a0,a0,-1544 # 80200c20 <etext+0x20c>
    80200230:	ec9ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
    80200234:	6c2c                	ld	a1,88(s0)
    80200236:	00001517          	auipc	a0,0x1
    8020023a:	a0250513          	addi	a0,a0,-1534 # 80200c38 <etext+0x224>
    8020023e:	ebbff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
    80200242:	702c                	ld	a1,96(s0)
    80200244:	00001517          	auipc	a0,0x1
    80200248:	a0c50513          	addi	a0,a0,-1524 # 80200c50 <etext+0x23c>
    8020024c:	eadff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
    80200250:	742c                	ld	a1,104(s0)
    80200252:	00001517          	auipc	a0,0x1
    80200256:	a1650513          	addi	a0,a0,-1514 # 80200c68 <etext+0x254>
    8020025a:	e9fff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
    8020025e:	782c                	ld	a1,112(s0)
    80200260:	00001517          	auipc	a0,0x1
    80200264:	a2050513          	addi	a0,a0,-1504 # 80200c80 <etext+0x26c>
    80200268:	e91ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
    8020026c:	7c2c                	ld	a1,120(s0)
    8020026e:	00001517          	auipc	a0,0x1
    80200272:	a2a50513          	addi	a0,a0,-1494 # 80200c98 <etext+0x284>
    80200276:	e83ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
    8020027a:	604c                	ld	a1,128(s0)
    8020027c:	00001517          	auipc	a0,0x1
    80200280:	a3450513          	addi	a0,a0,-1484 # 80200cb0 <etext+0x29c>
    80200284:	e75ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
    80200288:	644c                	ld	a1,136(s0)
    8020028a:	00001517          	auipc	a0,0x1
    8020028e:	a3e50513          	addi	a0,a0,-1474 # 80200cc8 <etext+0x2b4>
    80200292:	e67ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
    80200296:	684c                	ld	a1,144(s0)
    80200298:	00001517          	auipc	a0,0x1
    8020029c:	a4850513          	addi	a0,a0,-1464 # 80200ce0 <etext+0x2cc>
    802002a0:	e59ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
    802002a4:	6c4c                	ld	a1,152(s0)
    802002a6:	00001517          	auipc	a0,0x1
    802002aa:	a5250513          	addi	a0,a0,-1454 # 80200cf8 <etext+0x2e4>
    802002ae:	e4bff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
    802002b2:	704c                	ld	a1,160(s0)
    802002b4:	00001517          	auipc	a0,0x1
    802002b8:	a5c50513          	addi	a0,a0,-1444 # 80200d10 <etext+0x2fc>
    802002bc:	e3dff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
    802002c0:	744c                	ld	a1,168(s0)
    802002c2:	00001517          	auipc	a0,0x1
    802002c6:	a6650513          	addi	a0,a0,-1434 # 80200d28 <etext+0x314>
    802002ca:	e2fff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
    802002ce:	784c                	ld	a1,176(s0)
    802002d0:	00001517          	auipc	a0,0x1
    802002d4:	a7050513          	addi	a0,a0,-1424 # 80200d40 <etext+0x32c>
    802002d8:	e21ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
    802002dc:	7c4c                	ld	a1,184(s0)
    802002de:	00001517          	auipc	a0,0x1
    802002e2:	a7a50513          	addi	a0,a0,-1414 # 80200d58 <etext+0x344>
    802002e6:	e13ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
    802002ea:	606c                	ld	a1,192(s0)
    802002ec:	00001517          	auipc	a0,0x1
    802002f0:	a8450513          	addi	a0,a0,-1404 # 80200d70 <etext+0x35c>
    802002f4:	e05ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
    802002f8:	646c                	ld	a1,200(s0)
    802002fa:	00001517          	auipc	a0,0x1
    802002fe:	a8e50513          	addi	a0,a0,-1394 # 80200d88 <etext+0x374>
    80200302:	df7ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
    80200306:	686c                	ld	a1,208(s0)
    80200308:	00001517          	auipc	a0,0x1
    8020030c:	a9850513          	addi	a0,a0,-1384 # 80200da0 <etext+0x38c>
    80200310:	de9ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
    80200314:	6c6c                	ld	a1,216(s0)
    80200316:	00001517          	auipc	a0,0x1
    8020031a:	aa250513          	addi	a0,a0,-1374 # 80200db8 <etext+0x3a4>
    8020031e:	ddbff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
    80200322:	706c                	ld	a1,224(s0)
    80200324:	00001517          	auipc	a0,0x1
    80200328:	aac50513          	addi	a0,a0,-1364 # 80200dd0 <etext+0x3bc>
    8020032c:	dcdff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
    80200330:	746c                	ld	a1,232(s0)
    80200332:	00001517          	auipc	a0,0x1
    80200336:	ab650513          	addi	a0,a0,-1354 # 80200de8 <etext+0x3d4>
    8020033a:	dbfff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
    8020033e:	786c                	ld	a1,240(s0)
    80200340:	00001517          	auipc	a0,0x1
    80200344:	ac050513          	addi	a0,a0,-1344 # 80200e00 <etext+0x3ec>
    80200348:	db1ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
    8020034c:	7c6c                	ld	a1,248(s0)
}
    8020034e:	6402                	ld	s0,0(sp)
    80200350:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
    80200352:	00001517          	auipc	a0,0x1
    80200356:	ac650513          	addi	a0,a0,-1338 # 80200e18 <etext+0x404>
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
    8020036a:	aca50513          	addi	a0,a0,-1334 # 80200e30 <etext+0x41c>
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
    80200382:	aca50513          	addi	a0,a0,-1334 # 80200e48 <etext+0x434>
    80200386:	d73ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
    8020038a:	10843583          	ld	a1,264(s0)
    8020038e:	00001517          	auipc	a0,0x1
    80200392:	ad250513          	addi	a0,a0,-1326 # 80200e60 <etext+0x44c>
    80200396:	d63ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    8020039a:	11043583          	ld	a1,272(s0)
    8020039e:	00001517          	auipc	a0,0x1
    802003a2:	ada50513          	addi	a0,a0,-1318 # 80200e78 <etext+0x464>
    802003a6:	d53ff0ef          	jal	ra,802000f8 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
    802003aa:	11843583          	ld	a1,280(s0)
}
    802003ae:	6402                	ld	s0,0(sp)
    802003b0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
    802003b2:	00001517          	auipc	a0,0x1
    802003b6:	ade50513          	addi	a0,a0,-1314 # 80200e90 <etext+0x47c>
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
    802003d0:	b8c70713          	addi	a4,a4,-1140 # 80200f58 <etext+0x544>
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
    802003e2:	b2a50513          	addi	a0,a0,-1238 # 80200f08 <etext+0x4f4>
    802003e6:	bb09                	j	802000f8 <cprintf>
            cprintf("Hypervisor software interrupt\n");
    802003e8:	00001517          	auipc	a0,0x1
    802003ec:	b0050513          	addi	a0,a0,-1280 # 80200ee8 <etext+0x4d4>
    802003f0:	b321                	j	802000f8 <cprintf>
            cprintf("User software interrupt\n");
    802003f2:	00001517          	auipc	a0,0x1
    802003f6:	ab650513          	addi	a0,a0,-1354 # 80200ea8 <etext+0x494>
    802003fa:	b9fd                	j	802000f8 <cprintf>
            cprintf("Supervisor software interrupt\n");
    802003fc:	00001517          	auipc	a0,0x1
    80200400:	acc50513          	addi	a0,a0,-1332 # 80200ec8 <etext+0x4b4>
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
    80200410:	c0440413          	addi	s0,s0,-1020 # 80204010 <ticks>
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
    80200434:	b0850513          	addi	a0,a0,-1272 # 80200f38 <etext+0x524>
    80200438:	b1c1                	j	802000f8 <cprintf>
            print_trapframe(tf);
    8020043a:	b715                	j	8020035e <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
    8020043c:	06400593          	li	a1,100
    80200440:	00001517          	auipc	a0,0x1
    80200444:	ae850513          	addi	a0,a0,-1304 # 80200f28 <etext+0x514>
    80200448:	cb1ff0ef          	jal	ra,802000f8 <cprintf>
                if(ticks%(10*TICK_NUM)==0){
    8020044c:	601c                	ld	a5,0(s0)
    8020044e:	3e800713          	li	a4,1000
    80200452:	02e7f7b3          	remu	a5,a5,a4
    80200456:	fbe9                	bnez	a5,80200428 <interrupt_handler+0x6a>
}
    80200458:	6402                	ld	s0,0(sp)
    8020045a:	60a2                	ld	ra,8(sp)
    8020045c:	0141                	addi	sp,sp,16
                    sbi_shutdown();
    8020045e:	a3bd                	j	802009cc <sbi_shutdown>

0000000080200460 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
    80200460:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
    80200464:	1141                	addi	sp,sp,-16
    80200466:	e022                	sd	s0,0(sp)
    80200468:	e406                	sd	ra,8(sp)
    switch (tf->cause) {
    8020046a:	470d                	li	a4,3
void exception_handler(struct trapframe *tf) {
    8020046c:	842a                	mv	s0,a0
    switch (tf->cause) {
    8020046e:	04e78663          	beq	a5,a4,802004ba <exception_handler+0x5a>
    80200472:	02f76c63          	bltu	a4,a5,802004aa <exception_handler+0x4a>
    80200476:	4709                	li	a4,2
    80200478:	02e79563          	bne	a5,a4,802004a2 <exception_handler+0x42>
             /* LAB1 CHALLENGE3   2213013 :  */
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
           cprintf("Exception type:Illegal instruction\n");
    8020047c:	00001517          	auipc	a0,0x1
    80200480:	b0c50513          	addi	a0,a0,-1268 # 80200f88 <etext+0x574>
    80200484:	c75ff0ef          	jal	ra,802000f8 <cprintf>
            cprintf("Illegal instruction caught at 0x%08x\n", tf->epc);
    80200488:	10843583          	ld	a1,264(s0)
    8020048c:	00001517          	auipc	a0,0x1
    80200490:	b2450513          	addi	a0,a0,-1244 # 80200fb0 <etext+0x59c>
    80200494:	c65ff0ef          	jal	ra,802000f8 <cprintf>
            tf->epc += 4; // 更新异常指令地址到下一条指令，假设指令长度为 4 字节
    80200498:	10843783          	ld	a5,264(s0)
    8020049c:	0791                	addi	a5,a5,4
    8020049e:	10f43423          	sd	a5,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
    802004a2:	60a2                	ld	ra,8(sp)
    802004a4:	6402                	ld	s0,0(sp)
    802004a6:	0141                	addi	sp,sp,16
    802004a8:	8082                	ret
    switch (tf->cause) {
    802004aa:	17f1                	addi	a5,a5,-4
    802004ac:	471d                	li	a4,7
    802004ae:	fef77ae3          	bgeu	a4,a5,802004a2 <exception_handler+0x42>
}
    802004b2:	6402                	ld	s0,0(sp)
    802004b4:	60a2                	ld	ra,8(sp)
    802004b6:	0141                	addi	sp,sp,16
            print_trapframe(tf);
    802004b8:	b55d                	j	8020035e <print_trapframe>
           cprintf("Exception type: breakpoint\n");
    802004ba:	00001517          	auipc	a0,0x1
    802004be:	b1e50513          	addi	a0,a0,-1250 # 80200fd8 <etext+0x5c4>
    802004c2:	c37ff0ef          	jal	ra,802000f8 <cprintf>
            cprintf("ebreak caught at 0x%08x\n", tf->epc);
    802004c6:	10843583          	ld	a1,264(s0)
    802004ca:	00001517          	auipc	a0,0x1
    802004ce:	b2e50513          	addi	a0,a0,-1234 # 80200ff8 <etext+0x5e4>
    802004d2:	c27ff0ef          	jal	ra,802000f8 <cprintf>
            tf->epc += 4; // 更新异常指令地址到下一条指令，假设指令长度为 4 字节
    802004d6:	10843783          	ld	a5,264(s0)
}
    802004da:	60a2                	ld	ra,8(sp)
            tf->epc += 4; // 更新异常指令地址到下一条指令，假设指令长度为 4 字节
    802004dc:	0791                	addi	a5,a5,4
    802004de:	10f43423          	sd	a5,264(s0)
}
    802004e2:	6402                	ld	s0,0(sp)
    802004e4:	0141                	addi	sp,sp,16
    802004e6:	8082                	ret

00000000802004e8 <trap>:

/* trap_dispatch - dispatch based on what type of trap occurred */
static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
    802004e8:	11853783          	ld	a5,280(a0)
    802004ec:	0007c363          	bltz	a5,802004f2 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
    802004f0:	bf85                	j	80200460 <exception_handler>
        interrupt_handler(tf);
    802004f2:	b5f1                	j	802003be <interrupt_handler>

00000000802004f4 <__alltraps>:
    802004f4:	14011073          	csrw	sscratch,sp
    802004f8:	712d                	addi	sp,sp,-288
    802004fa:	e002                	sd	zero,0(sp)
    802004fc:	e406                	sd	ra,8(sp)
    802004fe:	ec0e                	sd	gp,24(sp)
    80200500:	f012                	sd	tp,32(sp)
    80200502:	f416                	sd	t0,40(sp)
    80200504:	f81a                	sd	t1,48(sp)
    80200506:	fc1e                	sd	t2,56(sp)
    80200508:	e0a2                	sd	s0,64(sp)
    8020050a:	e4a6                	sd	s1,72(sp)
    8020050c:	e8aa                	sd	a0,80(sp)
    8020050e:	ecae                	sd	a1,88(sp)
    80200510:	f0b2                	sd	a2,96(sp)
    80200512:	f4b6                	sd	a3,104(sp)
    80200514:	f8ba                	sd	a4,112(sp)
    80200516:	fcbe                	sd	a5,120(sp)
    80200518:	e142                	sd	a6,128(sp)
    8020051a:	e546                	sd	a7,136(sp)
    8020051c:	e94a                	sd	s2,144(sp)
    8020051e:	ed4e                	sd	s3,152(sp)
    80200520:	f152                	sd	s4,160(sp)
    80200522:	f556                	sd	s5,168(sp)
    80200524:	f95a                	sd	s6,176(sp)
    80200526:	fd5e                	sd	s7,184(sp)
    80200528:	e1e2                	sd	s8,192(sp)
    8020052a:	e5e6                	sd	s9,200(sp)
    8020052c:	e9ea                	sd	s10,208(sp)
    8020052e:	edee                	sd	s11,216(sp)
    80200530:	f1f2                	sd	t3,224(sp)
    80200532:	f5f6                	sd	t4,232(sp)
    80200534:	f9fa                	sd	t5,240(sp)
    80200536:	fdfe                	sd	t6,248(sp)
    80200538:	14001473          	csrrw	s0,sscratch,zero
    8020053c:	100024f3          	csrr	s1,sstatus
    80200540:	14102973          	csrr	s2,sepc
    80200544:	143029f3          	csrr	s3,stval
    80200548:	14202a73          	csrr	s4,scause
    8020054c:	e822                	sd	s0,16(sp)
    8020054e:	e226                	sd	s1,256(sp)
    80200550:	e64a                	sd	s2,264(sp)
    80200552:	ea4e                	sd	s3,272(sp)
    80200554:	ee52                	sd	s4,280(sp)
    80200556:	850a                	mv	a0,sp
    80200558:	f91ff0ef          	jal	ra,802004e8 <trap>

000000008020055c <__trapret>:
    8020055c:	6492                	ld	s1,256(sp)
    8020055e:	6932                	ld	s2,264(sp)
    80200560:	10049073          	csrw	sstatus,s1
    80200564:	14191073          	csrw	sepc,s2
    80200568:	60a2                	ld	ra,8(sp)
    8020056a:	61e2                	ld	gp,24(sp)
    8020056c:	7202                	ld	tp,32(sp)
    8020056e:	72a2                	ld	t0,40(sp)
    80200570:	7342                	ld	t1,48(sp)
    80200572:	73e2                	ld	t2,56(sp)
    80200574:	6406                	ld	s0,64(sp)
    80200576:	64a6                	ld	s1,72(sp)
    80200578:	6546                	ld	a0,80(sp)
    8020057a:	65e6                	ld	a1,88(sp)
    8020057c:	7606                	ld	a2,96(sp)
    8020057e:	76a6                	ld	a3,104(sp)
    80200580:	7746                	ld	a4,112(sp)
    80200582:	77e6                	ld	a5,120(sp)
    80200584:	680a                	ld	a6,128(sp)
    80200586:	68aa                	ld	a7,136(sp)
    80200588:	694a                	ld	s2,144(sp)
    8020058a:	69ea                	ld	s3,152(sp)
    8020058c:	7a0a                	ld	s4,160(sp)
    8020058e:	7aaa                	ld	s5,168(sp)
    80200590:	7b4a                	ld	s6,176(sp)
    80200592:	7bea                	ld	s7,184(sp)
    80200594:	6c0e                	ld	s8,192(sp)
    80200596:	6cae                	ld	s9,200(sp)
    80200598:	6d4e                	ld	s10,208(sp)
    8020059a:	6dee                	ld	s11,216(sp)
    8020059c:	7e0e                	ld	t3,224(sp)
    8020059e:	7eae                	ld	t4,232(sp)
    802005a0:	7f4e                	ld	t5,240(sp)
    802005a2:	7fee                	ld	t6,248(sp)
    802005a4:	6142                	ld	sp,16(sp)
    802005a6:	10200073          	sret

00000000802005aa <printnum>:
    802005aa:	02069813          	slli	a6,a3,0x20
    802005ae:	7179                	addi	sp,sp,-48
    802005b0:	02085813          	srli	a6,a6,0x20
    802005b4:	e052                	sd	s4,0(sp)
    802005b6:	03067a33          	remu	s4,a2,a6
    802005ba:	f022                	sd	s0,32(sp)
    802005bc:	ec26                	sd	s1,24(sp)
    802005be:	e84a                	sd	s2,16(sp)
    802005c0:	f406                	sd	ra,40(sp)
    802005c2:	e44e                	sd	s3,8(sp)
    802005c4:	84aa                	mv	s1,a0
    802005c6:	892e                	mv	s2,a1
    802005c8:	fff7041b          	addiw	s0,a4,-1
    802005cc:	2a01                	sext.w	s4,s4
    802005ce:	03067e63          	bgeu	a2,a6,8020060a <printnum+0x60>
    802005d2:	89be                	mv	s3,a5
    802005d4:	00805763          	blez	s0,802005e2 <printnum+0x38>
    802005d8:	347d                	addiw	s0,s0,-1
    802005da:	85ca                	mv	a1,s2
    802005dc:	854e                	mv	a0,s3
    802005de:	9482                	jalr	s1
    802005e0:	fc65                	bnez	s0,802005d8 <printnum+0x2e>
    802005e2:	1a02                	slli	s4,s4,0x20
    802005e4:	00001797          	auipc	a5,0x1
    802005e8:	a3478793          	addi	a5,a5,-1484 # 80201018 <etext+0x604>
    802005ec:	020a5a13          	srli	s4,s4,0x20
    802005f0:	9a3e                	add	s4,s4,a5
    802005f2:	7402                	ld	s0,32(sp)
    802005f4:	000a4503          	lbu	a0,0(s4)
    802005f8:	70a2                	ld	ra,40(sp)
    802005fa:	69a2                	ld	s3,8(sp)
    802005fc:	6a02                	ld	s4,0(sp)
    802005fe:	85ca                	mv	a1,s2
    80200600:	87a6                	mv	a5,s1
    80200602:	6942                	ld	s2,16(sp)
    80200604:	64e2                	ld	s1,24(sp)
    80200606:	6145                	addi	sp,sp,48
    80200608:	8782                	jr	a5
    8020060a:	03065633          	divu	a2,a2,a6
    8020060e:	8722                	mv	a4,s0
    80200610:	f9bff0ef          	jal	ra,802005aa <printnum>
    80200614:	b7f9                	j	802005e2 <printnum+0x38>

0000000080200616 <vprintfmt>:
    80200616:	7119                	addi	sp,sp,-128
    80200618:	f4a6                	sd	s1,104(sp)
    8020061a:	f0ca                	sd	s2,96(sp)
    8020061c:	ecce                	sd	s3,88(sp)
    8020061e:	e8d2                	sd	s4,80(sp)
    80200620:	e4d6                	sd	s5,72(sp)
    80200622:	e0da                	sd	s6,64(sp)
    80200624:	fc5e                	sd	s7,56(sp)
    80200626:	f06a                	sd	s10,32(sp)
    80200628:	fc86                	sd	ra,120(sp)
    8020062a:	f8a2                	sd	s0,112(sp)
    8020062c:	f862                	sd	s8,48(sp)
    8020062e:	f466                	sd	s9,40(sp)
    80200630:	ec6e                	sd	s11,24(sp)
    80200632:	892a                	mv	s2,a0
    80200634:	84ae                	mv	s1,a1
    80200636:	8d32                	mv	s10,a2
    80200638:	8a36                	mv	s4,a3
    8020063a:	02500993          	li	s3,37
    8020063e:	5b7d                	li	s6,-1
    80200640:	00001a97          	auipc	s5,0x1
    80200644:	a0ca8a93          	addi	s5,s5,-1524 # 8020104c <etext+0x638>
    80200648:	00001b97          	auipc	s7,0x1
    8020064c:	be0b8b93          	addi	s7,s7,-1056 # 80201228 <error_string>
    80200650:	000d4503          	lbu	a0,0(s10)
    80200654:	001d0413          	addi	s0,s10,1
    80200658:	01350a63          	beq	a0,s3,8020066c <vprintfmt+0x56>
    8020065c:	c121                	beqz	a0,8020069c <vprintfmt+0x86>
    8020065e:	85a6                	mv	a1,s1
    80200660:	0405                	addi	s0,s0,1
    80200662:	9902                	jalr	s2
    80200664:	fff44503          	lbu	a0,-1(s0)
    80200668:	ff351ae3          	bne	a0,s3,8020065c <vprintfmt+0x46>
    8020066c:	00044603          	lbu	a2,0(s0)
    80200670:	02000793          	li	a5,32
    80200674:	4c81                	li	s9,0
    80200676:	4881                	li	a7,0
    80200678:	5c7d                	li	s8,-1
    8020067a:	5dfd                	li	s11,-1
    8020067c:	05500513          	li	a0,85
    80200680:	4825                	li	a6,9
    80200682:	fdd6059b          	addiw	a1,a2,-35
    80200686:	0ff5f593          	andi	a1,a1,255
    8020068a:	00140d13          	addi	s10,s0,1
    8020068e:	04b56263          	bltu	a0,a1,802006d2 <vprintfmt+0xbc>
    80200692:	058a                	slli	a1,a1,0x2
    80200694:	95d6                	add	a1,a1,s5
    80200696:	4194                	lw	a3,0(a1)
    80200698:	96d6                	add	a3,a3,s5
    8020069a:	8682                	jr	a3
    8020069c:	70e6                	ld	ra,120(sp)
    8020069e:	7446                	ld	s0,112(sp)
    802006a0:	74a6                	ld	s1,104(sp)
    802006a2:	7906                	ld	s2,96(sp)
    802006a4:	69e6                	ld	s3,88(sp)
    802006a6:	6a46                	ld	s4,80(sp)
    802006a8:	6aa6                	ld	s5,72(sp)
    802006aa:	6b06                	ld	s6,64(sp)
    802006ac:	7be2                	ld	s7,56(sp)
    802006ae:	7c42                	ld	s8,48(sp)
    802006b0:	7ca2                	ld	s9,40(sp)
    802006b2:	7d02                	ld	s10,32(sp)
    802006b4:	6de2                	ld	s11,24(sp)
    802006b6:	6109                	addi	sp,sp,128
    802006b8:	8082                	ret
    802006ba:	87b2                	mv	a5,a2
    802006bc:	00144603          	lbu	a2,1(s0)
    802006c0:	846a                	mv	s0,s10
    802006c2:	00140d13          	addi	s10,s0,1
    802006c6:	fdd6059b          	addiw	a1,a2,-35
    802006ca:	0ff5f593          	andi	a1,a1,255
    802006ce:	fcb572e3          	bgeu	a0,a1,80200692 <vprintfmt+0x7c>
    802006d2:	85a6                	mv	a1,s1
    802006d4:	02500513          	li	a0,37
    802006d8:	9902                	jalr	s2
    802006da:	fff44783          	lbu	a5,-1(s0)
    802006de:	8d22                	mv	s10,s0
    802006e0:	f73788e3          	beq	a5,s3,80200650 <vprintfmt+0x3a>
    802006e4:	ffed4783          	lbu	a5,-2(s10)
    802006e8:	1d7d                	addi	s10,s10,-1
    802006ea:	ff379de3          	bne	a5,s3,802006e4 <vprintfmt+0xce>
    802006ee:	b78d                	j	80200650 <vprintfmt+0x3a>
    802006f0:	fd060c1b          	addiw	s8,a2,-48
    802006f4:	00144603          	lbu	a2,1(s0)
    802006f8:	846a                	mv	s0,s10
    802006fa:	fd06069b          	addiw	a3,a2,-48
    802006fe:	0006059b          	sext.w	a1,a2
    80200702:	02d86463          	bltu	a6,a3,8020072a <vprintfmt+0x114>
    80200706:	00144603          	lbu	a2,1(s0)
    8020070a:	002c169b          	slliw	a3,s8,0x2
    8020070e:	0186873b          	addw	a4,a3,s8
    80200712:	0017171b          	slliw	a4,a4,0x1
    80200716:	9f2d                	addw	a4,a4,a1
    80200718:	fd06069b          	addiw	a3,a2,-48
    8020071c:	0405                	addi	s0,s0,1
    8020071e:	fd070c1b          	addiw	s8,a4,-48
    80200722:	0006059b          	sext.w	a1,a2
    80200726:	fed870e3          	bgeu	a6,a3,80200706 <vprintfmt+0xf0>
    8020072a:	f40ddce3          	bgez	s11,80200682 <vprintfmt+0x6c>
    8020072e:	8de2                	mv	s11,s8
    80200730:	5c7d                	li	s8,-1
    80200732:	bf81                	j	80200682 <vprintfmt+0x6c>
    80200734:	fffdc693          	not	a3,s11
    80200738:	96fd                	srai	a3,a3,0x3f
    8020073a:	00ddfdb3          	and	s11,s11,a3
    8020073e:	00144603          	lbu	a2,1(s0)
    80200742:	2d81                	sext.w	s11,s11
    80200744:	846a                	mv	s0,s10
    80200746:	bf35                	j	80200682 <vprintfmt+0x6c>
    80200748:	000a2c03          	lw	s8,0(s4)
    8020074c:	00144603          	lbu	a2,1(s0)
    80200750:	0a21                	addi	s4,s4,8
    80200752:	846a                	mv	s0,s10
    80200754:	bfd9                	j	8020072a <vprintfmt+0x114>
    80200756:	4705                	li	a4,1
    80200758:	008a0593          	addi	a1,s4,8
    8020075c:	01174463          	blt	a4,a7,80200764 <vprintfmt+0x14e>
    80200760:	1a088e63          	beqz	a7,8020091c <vprintfmt+0x306>
    80200764:	000a3603          	ld	a2,0(s4)
    80200768:	46c1                	li	a3,16
    8020076a:	8a2e                	mv	s4,a1
    8020076c:	2781                	sext.w	a5,a5
    8020076e:	876e                	mv	a4,s11
    80200770:	85a6                	mv	a1,s1
    80200772:	854a                	mv	a0,s2
    80200774:	e37ff0ef          	jal	ra,802005aa <printnum>
    80200778:	bde1                	j	80200650 <vprintfmt+0x3a>
    8020077a:	000a2503          	lw	a0,0(s4)
    8020077e:	85a6                	mv	a1,s1
    80200780:	0a21                	addi	s4,s4,8
    80200782:	9902                	jalr	s2
    80200784:	b5f1                	j	80200650 <vprintfmt+0x3a>
    80200786:	4705                	li	a4,1
    80200788:	008a0593          	addi	a1,s4,8
    8020078c:	01174463          	blt	a4,a7,80200794 <vprintfmt+0x17e>
    80200790:	18088163          	beqz	a7,80200912 <vprintfmt+0x2fc>
    80200794:	000a3603          	ld	a2,0(s4)
    80200798:	46a9                	li	a3,10
    8020079a:	8a2e                	mv	s4,a1
    8020079c:	bfc1                	j	8020076c <vprintfmt+0x156>
    8020079e:	00144603          	lbu	a2,1(s0)
    802007a2:	4c85                	li	s9,1
    802007a4:	846a                	mv	s0,s10
    802007a6:	bdf1                	j	80200682 <vprintfmt+0x6c>
    802007a8:	85a6                	mv	a1,s1
    802007aa:	02500513          	li	a0,37
    802007ae:	9902                	jalr	s2
    802007b0:	b545                	j	80200650 <vprintfmt+0x3a>
    802007b2:	00144603          	lbu	a2,1(s0)
    802007b6:	2885                	addiw	a7,a7,1
    802007b8:	846a                	mv	s0,s10
    802007ba:	b5e1                	j	80200682 <vprintfmt+0x6c>
    802007bc:	4705                	li	a4,1
    802007be:	008a0593          	addi	a1,s4,8
    802007c2:	01174463          	blt	a4,a7,802007ca <vprintfmt+0x1b4>
    802007c6:	14088163          	beqz	a7,80200908 <vprintfmt+0x2f2>
    802007ca:	000a3603          	ld	a2,0(s4)
    802007ce:	46a1                	li	a3,8
    802007d0:	8a2e                	mv	s4,a1
    802007d2:	bf69                	j	8020076c <vprintfmt+0x156>
    802007d4:	03000513          	li	a0,48
    802007d8:	85a6                	mv	a1,s1
    802007da:	e03e                	sd	a5,0(sp)
    802007dc:	9902                	jalr	s2
    802007de:	85a6                	mv	a1,s1
    802007e0:	07800513          	li	a0,120
    802007e4:	9902                	jalr	s2
    802007e6:	0a21                	addi	s4,s4,8
    802007e8:	6782                	ld	a5,0(sp)
    802007ea:	46c1                	li	a3,16
    802007ec:	ff8a3603          	ld	a2,-8(s4)
    802007f0:	bfb5                	j	8020076c <vprintfmt+0x156>
    802007f2:	000a3403          	ld	s0,0(s4)
    802007f6:	008a0713          	addi	a4,s4,8
    802007fa:	e03a                	sd	a4,0(sp)
    802007fc:	14040263          	beqz	s0,80200940 <vprintfmt+0x32a>
    80200800:	0fb05763          	blez	s11,802008ee <vprintfmt+0x2d8>
    80200804:	02d00693          	li	a3,45
    80200808:	0cd79163          	bne	a5,a3,802008ca <vprintfmt+0x2b4>
    8020080c:	00044783          	lbu	a5,0(s0)
    80200810:	0007851b          	sext.w	a0,a5
    80200814:	cf85                	beqz	a5,8020084c <vprintfmt+0x236>
    80200816:	00140a13          	addi	s4,s0,1
    8020081a:	05e00413          	li	s0,94
    8020081e:	000c4563          	bltz	s8,80200828 <vprintfmt+0x212>
    80200822:	3c7d                	addiw	s8,s8,-1
    80200824:	036c0263          	beq	s8,s6,80200848 <vprintfmt+0x232>
    80200828:	85a6                	mv	a1,s1
    8020082a:	0e0c8e63          	beqz	s9,80200926 <vprintfmt+0x310>
    8020082e:	3781                	addiw	a5,a5,-32
    80200830:	0ef47b63          	bgeu	s0,a5,80200926 <vprintfmt+0x310>
    80200834:	03f00513          	li	a0,63
    80200838:	9902                	jalr	s2
    8020083a:	000a4783          	lbu	a5,0(s4)
    8020083e:	3dfd                	addiw	s11,s11,-1
    80200840:	0a05                	addi	s4,s4,1
    80200842:	0007851b          	sext.w	a0,a5
    80200846:	ffe1                	bnez	a5,8020081e <vprintfmt+0x208>
    80200848:	01b05963          	blez	s11,8020085a <vprintfmt+0x244>
    8020084c:	3dfd                	addiw	s11,s11,-1
    8020084e:	85a6                	mv	a1,s1
    80200850:	02000513          	li	a0,32
    80200854:	9902                	jalr	s2
    80200856:	fe0d9be3          	bnez	s11,8020084c <vprintfmt+0x236>
    8020085a:	6a02                	ld	s4,0(sp)
    8020085c:	bbd5                	j	80200650 <vprintfmt+0x3a>
    8020085e:	4705                	li	a4,1
    80200860:	008a0c93          	addi	s9,s4,8
    80200864:	01174463          	blt	a4,a7,8020086c <vprintfmt+0x256>
    80200868:	08088d63          	beqz	a7,80200902 <vprintfmt+0x2ec>
    8020086c:	000a3403          	ld	s0,0(s4)
    80200870:	0a044d63          	bltz	s0,8020092a <vprintfmt+0x314>
    80200874:	8622                	mv	a2,s0
    80200876:	8a66                	mv	s4,s9
    80200878:	46a9                	li	a3,10
    8020087a:	bdcd                	j	8020076c <vprintfmt+0x156>
    8020087c:	000a2783          	lw	a5,0(s4)
    80200880:	4719                	li	a4,6
    80200882:	0a21                	addi	s4,s4,8
    80200884:	41f7d69b          	sraiw	a3,a5,0x1f
    80200888:	8fb5                	xor	a5,a5,a3
    8020088a:	40d786bb          	subw	a3,a5,a3
    8020088e:	02d74163          	blt	a4,a3,802008b0 <vprintfmt+0x29a>
    80200892:	00369793          	slli	a5,a3,0x3
    80200896:	97de                	add	a5,a5,s7
    80200898:	639c                	ld	a5,0(a5)
    8020089a:	cb99                	beqz	a5,802008b0 <vprintfmt+0x29a>
    8020089c:	86be                	mv	a3,a5
    8020089e:	00000617          	auipc	a2,0x0
    802008a2:	7aa60613          	addi	a2,a2,1962 # 80201048 <etext+0x634>
    802008a6:	85a6                	mv	a1,s1
    802008a8:	854a                	mv	a0,s2
    802008aa:	0ce000ef          	jal	ra,80200978 <printfmt>
    802008ae:	b34d                	j	80200650 <vprintfmt+0x3a>
    802008b0:	00000617          	auipc	a2,0x0
    802008b4:	78860613          	addi	a2,a2,1928 # 80201038 <etext+0x624>
    802008b8:	85a6                	mv	a1,s1
    802008ba:	854a                	mv	a0,s2
    802008bc:	0bc000ef          	jal	ra,80200978 <printfmt>
    802008c0:	bb41                	j	80200650 <vprintfmt+0x3a>
    802008c2:	00000417          	auipc	s0,0x0
    802008c6:	76e40413          	addi	s0,s0,1902 # 80201030 <etext+0x61c>
    802008ca:	85e2                	mv	a1,s8
    802008cc:	8522                	mv	a0,s0
    802008ce:	e43e                	sd	a5,8(sp)
    802008d0:	116000ef          	jal	ra,802009e6 <strnlen>
    802008d4:	40ad8dbb          	subw	s11,s11,a0
    802008d8:	01b05b63          	blez	s11,802008ee <vprintfmt+0x2d8>
    802008dc:	67a2                	ld	a5,8(sp)
    802008de:	00078a1b          	sext.w	s4,a5
    802008e2:	3dfd                	addiw	s11,s11,-1
    802008e4:	85a6                	mv	a1,s1
    802008e6:	8552                	mv	a0,s4
    802008e8:	9902                	jalr	s2
    802008ea:	fe0d9ce3          	bnez	s11,802008e2 <vprintfmt+0x2cc>
    802008ee:	00044783          	lbu	a5,0(s0)
    802008f2:	00140a13          	addi	s4,s0,1
    802008f6:	0007851b          	sext.w	a0,a5
    802008fa:	d3a5                	beqz	a5,8020085a <vprintfmt+0x244>
    802008fc:	05e00413          	li	s0,94
    80200900:	bf39                	j	8020081e <vprintfmt+0x208>
    80200902:	000a2403          	lw	s0,0(s4)
    80200906:	b7ad                	j	80200870 <vprintfmt+0x25a>
    80200908:	000a6603          	lwu	a2,0(s4)
    8020090c:	46a1                	li	a3,8
    8020090e:	8a2e                	mv	s4,a1
    80200910:	bdb1                	j	8020076c <vprintfmt+0x156>
    80200912:	000a6603          	lwu	a2,0(s4)
    80200916:	46a9                	li	a3,10
    80200918:	8a2e                	mv	s4,a1
    8020091a:	bd89                	j	8020076c <vprintfmt+0x156>
    8020091c:	000a6603          	lwu	a2,0(s4)
    80200920:	46c1                	li	a3,16
    80200922:	8a2e                	mv	s4,a1
    80200924:	b5a1                	j	8020076c <vprintfmt+0x156>
    80200926:	9902                	jalr	s2
    80200928:	bf09                	j	8020083a <vprintfmt+0x224>
    8020092a:	85a6                	mv	a1,s1
    8020092c:	02d00513          	li	a0,45
    80200930:	e03e                	sd	a5,0(sp)
    80200932:	9902                	jalr	s2
    80200934:	6782                	ld	a5,0(sp)
    80200936:	8a66                	mv	s4,s9
    80200938:	40800633          	neg	a2,s0
    8020093c:	46a9                	li	a3,10
    8020093e:	b53d                	j	8020076c <vprintfmt+0x156>
    80200940:	03b05163          	blez	s11,80200962 <vprintfmt+0x34c>
    80200944:	02d00693          	li	a3,45
    80200948:	f6d79de3          	bne	a5,a3,802008c2 <vprintfmt+0x2ac>
    8020094c:	00000417          	auipc	s0,0x0
    80200950:	6e440413          	addi	s0,s0,1764 # 80201030 <etext+0x61c>
    80200954:	02800793          	li	a5,40
    80200958:	02800513          	li	a0,40
    8020095c:	00140a13          	addi	s4,s0,1
    80200960:	bd6d                	j	8020081a <vprintfmt+0x204>
    80200962:	00000a17          	auipc	s4,0x0
    80200966:	6cfa0a13          	addi	s4,s4,1743 # 80201031 <etext+0x61d>
    8020096a:	02800513          	li	a0,40
    8020096e:	02800793          	li	a5,40
    80200972:	05e00413          	li	s0,94
    80200976:	b565                	j	8020081e <vprintfmt+0x208>

0000000080200978 <printfmt>:
    80200978:	715d                	addi	sp,sp,-80
    8020097a:	02810313          	addi	t1,sp,40
    8020097e:	f436                	sd	a3,40(sp)
    80200980:	869a                	mv	a3,t1
    80200982:	ec06                	sd	ra,24(sp)
    80200984:	f83a                	sd	a4,48(sp)
    80200986:	fc3e                	sd	a5,56(sp)
    80200988:	e0c2                	sd	a6,64(sp)
    8020098a:	e4c6                	sd	a7,72(sp)
    8020098c:	e41a                	sd	t1,8(sp)
    8020098e:	c89ff0ef          	jal	ra,80200616 <vprintfmt>
    80200992:	60e2                	ld	ra,24(sp)
    80200994:	6161                	addi	sp,sp,80
    80200996:	8082                	ret

0000000080200998 <sbi_console_putchar>:
    80200998:	4781                	li	a5,0
    8020099a:	00003717          	auipc	a4,0x3
    8020099e:	66673703          	ld	a4,1638(a4) # 80204000 <SBI_CONSOLE_PUTCHAR>
    802009a2:	88ba                	mv	a7,a4
    802009a4:	852a                	mv	a0,a0
    802009a6:	85be                	mv	a1,a5
    802009a8:	863e                	mv	a2,a5
    802009aa:	00000073          	ecall
    802009ae:	87aa                	mv	a5,a0
    802009b0:	8082                	ret

00000000802009b2 <sbi_set_timer>:
    802009b2:	4781                	li	a5,0
    802009b4:	00003717          	auipc	a4,0x3
    802009b8:	66473703          	ld	a4,1636(a4) # 80204018 <SBI_SET_TIMER>
    802009bc:	88ba                	mv	a7,a4
    802009be:	852a                	mv	a0,a0
    802009c0:	85be                	mv	a1,a5
    802009c2:	863e                	mv	a2,a5
    802009c4:	00000073          	ecall
    802009c8:	87aa                	mv	a5,a0
    802009ca:	8082                	ret

00000000802009cc <sbi_shutdown>:
    802009cc:	4781                	li	a5,0
    802009ce:	00003717          	auipc	a4,0x3
    802009d2:	63a73703          	ld	a4,1594(a4) # 80204008 <SBI_SHUTDOWN>
    802009d6:	88ba                	mv	a7,a4
    802009d8:	853e                	mv	a0,a5
    802009da:	85be                	mv	a1,a5
    802009dc:	863e                	mv	a2,a5
    802009de:	00000073          	ecall
    802009e2:	87aa                	mv	a5,a0
    802009e4:	8082                	ret

00000000802009e6 <strnlen>:
    802009e6:	4781                	li	a5,0
    802009e8:	e589                	bnez	a1,802009f2 <strnlen+0xc>
    802009ea:	a811                	j	802009fe <strnlen+0x18>
    802009ec:	0785                	addi	a5,a5,1
    802009ee:	00f58863          	beq	a1,a5,802009fe <strnlen+0x18>
    802009f2:	00f50733          	add	a4,a0,a5
    802009f6:	00074703          	lbu	a4,0(a4)
    802009fa:	fb6d                	bnez	a4,802009ec <strnlen+0x6>
    802009fc:	85be                	mv	a1,a5
    802009fe:	852e                	mv	a0,a1
    80200a00:	8082                	ret

0000000080200a02 <memset>:
    80200a02:	ca01                	beqz	a2,80200a12 <memset+0x10>
    80200a04:	962a                	add	a2,a2,a0
    80200a06:	87aa                	mv	a5,a0
    80200a08:	0785                	addi	a5,a5,1
    80200a0a:	feb78fa3          	sb	a1,-1(a5)
    80200a0e:	fec79de3          	bne	a5,a2,80200a08 <memset+0x6>
    80200a12:	8082                	ret
