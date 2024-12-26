
obj/__user_forktree.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	0c2000ef          	jal	ra,8000e2 <umain>
1:  j 1b
  800024:	a001                	j	800024 <_start+0x4>

0000000000800026 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800026:	1141                	addi	sp,sp,-16
  800028:	e022                	sd	s0,0(sp)
  80002a:	e406                	sd	ra,8(sp)
  80002c:	842e                	mv	s0,a1
    sys_putc(c);
  80002e:	092000ef          	jal	ra,8000c0 <sys_putc>
    (*cnt) ++;
  800032:	401c                	lw	a5,0(s0)
}
  800034:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  800036:	2785                	addiw	a5,a5,1
  800038:	c01c                	sw	a5,0(s0)
}
  80003a:	6402                	ld	s0,0(sp)
  80003c:	0141                	addi	sp,sp,16
  80003e:	8082                	ret

0000000000800040 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  800040:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  800042:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  800046:	f42e                	sd	a1,40(sp)
  800048:	f832                	sd	a2,48(sp)
  80004a:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  80004c:	862a                	mv	a2,a0
  80004e:	004c                	addi	a1,sp,4
  800050:	00000517          	auipc	a0,0x0
  800054:	fd650513          	addi	a0,a0,-42 # 800026 <cputch>
  800058:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  80005a:	ec06                	sd	ra,24(sp)
  80005c:	e0ba                	sd	a4,64(sp)
  80005e:	e4be                	sd	a5,72(sp)
  800060:	e8c2                	sd	a6,80(sp)
  800062:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  800064:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  800066:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800068:	10c000ef          	jal	ra,800174 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  80006c:	60e2                	ld	ra,24(sp)
  80006e:	4512                	lw	a0,4(sp)
  800070:	6125                	addi	sp,sp,96
  800072:	8082                	ret

0000000000800074 <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int64_t num, ...) {
  800074:	7175                	addi	sp,sp,-144
  800076:	f8ba                	sd	a4,112(sp)
    va_list ap;
    va_start(ap, num);
    uint64_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint64_t);
  800078:	e0ba                	sd	a4,64(sp)
  80007a:	0118                	addi	a4,sp,128
syscall(int64_t num, ...) {
  80007c:	e42a                	sd	a0,8(sp)
  80007e:	ecae                	sd	a1,88(sp)
  800080:	f0b2                	sd	a2,96(sp)
  800082:	f4b6                	sd	a3,104(sp)
  800084:	fcbe                	sd	a5,120(sp)
  800086:	e142                	sd	a6,128(sp)
  800088:	e546                	sd	a7,136(sp)
        a[i] = va_arg(ap, uint64_t);
  80008a:	f42e                	sd	a1,40(sp)
  80008c:	f832                	sd	a2,48(sp)
  80008e:	fc36                	sd	a3,56(sp)
  800090:	f03a                	sd	a4,32(sp)
  800092:	e4be                	sd	a5,72(sp)
    }
    va_end(ap);

    asm volatile (
  800094:	6522                	ld	a0,8(sp)
  800096:	75a2                	ld	a1,40(sp)
  800098:	7642                	ld	a2,48(sp)
  80009a:	76e2                	ld	a3,56(sp)
  80009c:	6706                	ld	a4,64(sp)
  80009e:	67a6                	ld	a5,72(sp)
  8000a0:	00000073          	ecall
  8000a4:	00a13e23          	sd	a0,28(sp)
        "sd a0, %0"
        : "=m" (ret)
        : "m"(num), "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4])
        :"memory");
    return ret;
}
  8000a8:	4572                	lw	a0,28(sp)
  8000aa:	6149                	addi	sp,sp,144
  8000ac:	8082                	ret

00000000008000ae <sys_exit>:

int
sys_exit(int64_t error_code) {
    return syscall(SYS_exit, error_code);
  8000ae:	85aa                	mv	a1,a0
  8000b0:	4505                	li	a0,1
  8000b2:	b7c9                	j	800074 <syscall>

00000000008000b4 <sys_fork>:
}

int
sys_fork(void) {
    return syscall(SYS_fork);
  8000b4:	4509                	li	a0,2
  8000b6:	bf7d                	j	800074 <syscall>

00000000008000b8 <sys_yield>:
    return syscall(SYS_wait, pid, store);
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  8000b8:	4529                	li	a0,10
  8000ba:	bf6d                	j	800074 <syscall>

00000000008000bc <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  8000bc:	4549                	li	a0,18
  8000be:	bf5d                	j	800074 <syscall>

00000000008000c0 <sys_putc>:
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  8000c0:	85aa                	mv	a1,a0
  8000c2:	4579                	li	a0,30
  8000c4:	bf45                	j	800074 <syscall>

00000000008000c6 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000c6:	1141                	addi	sp,sp,-16
  8000c8:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000ca:	fe5ff0ef          	jal	ra,8000ae <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000ce:	00000517          	auipc	a0,0x0
  8000d2:	55a50513          	addi	a0,a0,1370 # 800628 <main+0x1e>
  8000d6:	f6bff0ef          	jal	ra,800040 <cprintf>
    while (1);
  8000da:	a001                	j	8000da <exit+0x14>

00000000008000dc <fork>:
}

int
fork(void) {
    return sys_fork();
  8000dc:	bfe1                	j	8000b4 <sys_fork>

00000000008000de <yield>:
    return sys_wait(pid, store);
}

void
yield(void) {
    sys_yield();
  8000de:	bfe9                	j	8000b8 <sys_yield>

00000000008000e0 <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  8000e0:	bff1                	j	8000bc <sys_getpid>

00000000008000e2 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000e2:	1141                	addi	sp,sp,-16
  8000e4:	e406                	sd	ra,8(sp)
    int ret = main();
  8000e6:	524000ef          	jal	ra,80060a <main>
    exit(ret);
  8000ea:	fddff0ef          	jal	ra,8000c6 <exit>

00000000008000ee <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000ee:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000f2:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  8000f4:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000f8:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8000fa:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  8000fe:	f022                	sd	s0,32(sp)
  800100:	ec26                	sd	s1,24(sp)
  800102:	e84a                	sd	s2,16(sp)
  800104:	f406                	sd	ra,40(sp)
  800106:	e44e                	sd	s3,8(sp)
  800108:	84aa                	mv	s1,a0
  80010a:	892e                	mv	s2,a1
  80010c:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800110:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800112:	03067e63          	bgeu	a2,a6,80014e <printnum+0x60>
  800116:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800118:	00805763          	blez	s0,800126 <printnum+0x38>
  80011c:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80011e:	85ca                	mv	a1,s2
  800120:	854e                	mv	a0,s3
  800122:	9482                	jalr	s1
        while (-- width > 0)
  800124:	fc65                	bnez	s0,80011c <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800126:	1a02                	slli	s4,s4,0x20
  800128:	020a5a13          	srli	s4,s4,0x20
  80012c:	00000797          	auipc	a5,0x0
  800130:	73478793          	addi	a5,a5,1844 # 800860 <error_string+0xc8>
  800134:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800136:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800138:	000a4503          	lbu	a0,0(s4)
}
  80013c:	70a2                	ld	ra,40(sp)
  80013e:	69a2                	ld	s3,8(sp)
  800140:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800142:	85ca                	mv	a1,s2
  800144:	8326                	mv	t1,s1
}
  800146:	6942                	ld	s2,16(sp)
  800148:	64e2                	ld	s1,24(sp)
  80014a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  80014c:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  80014e:	03065633          	divu	a2,a2,a6
  800152:	8722                	mv	a4,s0
  800154:	f9bff0ef          	jal	ra,8000ee <printnum>
  800158:	b7f9                	j	800126 <printnum+0x38>

000000000080015a <sprintputch>:
 * @ch:         the character will be printed
 * @b:          the buffer to place the character @ch
 * */
static void
sprintputch(int ch, struct sprintbuf *b) {
    b->cnt ++;
  80015a:	499c                	lw	a5,16(a1)
    if (b->buf < b->ebuf) {
  80015c:	6198                	ld	a4,0(a1)
  80015e:	6594                	ld	a3,8(a1)
    b->cnt ++;
  800160:	2785                	addiw	a5,a5,1
  800162:	c99c                	sw	a5,16(a1)
    if (b->buf < b->ebuf) {
  800164:	00d77763          	bgeu	a4,a3,800172 <sprintputch+0x18>
        *b->buf ++ = ch;
  800168:	00170793          	addi	a5,a4,1
  80016c:	e19c                	sd	a5,0(a1)
  80016e:	00a70023          	sb	a0,0(a4)
    }
}
  800172:	8082                	ret

0000000000800174 <vprintfmt>:
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800174:	7119                	addi	sp,sp,-128
  800176:	f4a6                	sd	s1,104(sp)
  800178:	f0ca                	sd	s2,96(sp)
  80017a:	e8d2                	sd	s4,80(sp)
  80017c:	e4d6                	sd	s5,72(sp)
  80017e:	e0da                	sd	s6,64(sp)
  800180:	fc5e                	sd	s7,56(sp)
  800182:	f862                	sd	s8,48(sp)
  800184:	f06a                	sd	s10,32(sp)
  800186:	fc86                	sd	ra,120(sp)
  800188:	f8a2                	sd	s0,112(sp)
  80018a:	ecce                	sd	s3,88(sp)
  80018c:	f466                	sd	s9,40(sp)
  80018e:	ec6e                	sd	s11,24(sp)
  800190:	892a                	mv	s2,a0
  800192:	84ae                	mv	s1,a1
  800194:	8d32                	mv	s10,a2
  800196:	8ab6                	mv	s5,a3
        width = precision = -1;
  800198:	5b7d                	li	s6,-1
        switch (ch = *(unsigned char *)fmt ++) {
  80019a:	00000a17          	auipc	s4,0x0
  80019e:	4a2a0a13          	addi	s4,s4,1186 # 80063c <main+0x32>
                if (altflag && (ch < ' ' || ch > '~')) {
  8001a2:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001a6:	00000c17          	auipc	s8,0x0
  8001aa:	5f2c0c13          	addi	s8,s8,1522 # 800798 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001ae:	000d4503          	lbu	a0,0(s10)
  8001b2:	02500793          	li	a5,37
  8001b6:	001d0413          	addi	s0,s10,1
  8001ba:	00f50e63          	beq	a0,a5,8001d6 <vprintfmt+0x62>
            if (ch == '\0') {
  8001be:	c521                	beqz	a0,800206 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001c0:	02500993          	li	s3,37
  8001c4:	a011                	j	8001c8 <vprintfmt+0x54>
            if (ch == '\0') {
  8001c6:	c121                	beqz	a0,800206 <vprintfmt+0x92>
            putch(ch, putdat);
  8001c8:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001ca:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  8001cc:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001ce:	fff44503          	lbu	a0,-1(s0)
  8001d2:	ff351ae3          	bne	a0,s3,8001c6 <vprintfmt+0x52>
  8001d6:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  8001da:	02000793          	li	a5,32
        lflag = altflag = 0;
  8001de:	4981                	li	s3,0
  8001e0:	4801                	li	a6,0
        width = precision = -1;
  8001e2:	5cfd                	li	s9,-1
  8001e4:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  8001e6:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  8001ea:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  8001ec:	fdd6069b          	addiw	a3,a2,-35
  8001f0:	0ff6f693          	andi	a3,a3,255
  8001f4:	00140d13          	addi	s10,s0,1
  8001f8:	1ed5ef63          	bltu	a1,a3,8003f6 <vprintfmt+0x282>
  8001fc:	068a                	slli	a3,a3,0x2
  8001fe:	96d2                	add	a3,a3,s4
  800200:	4294                	lw	a3,0(a3)
  800202:	96d2                	add	a3,a3,s4
  800204:	8682                	jr	a3
}
  800206:	70e6                	ld	ra,120(sp)
  800208:	7446                	ld	s0,112(sp)
  80020a:	74a6                	ld	s1,104(sp)
  80020c:	7906                	ld	s2,96(sp)
  80020e:	69e6                	ld	s3,88(sp)
  800210:	6a46                	ld	s4,80(sp)
  800212:	6aa6                	ld	s5,72(sp)
  800214:	6b06                	ld	s6,64(sp)
  800216:	7be2                	ld	s7,56(sp)
  800218:	7c42                	ld	s8,48(sp)
  80021a:	7ca2                	ld	s9,40(sp)
  80021c:	7d02                	ld	s10,32(sp)
  80021e:	6de2                	ld	s11,24(sp)
  800220:	6109                	addi	sp,sp,128
  800222:	8082                	ret
            padc = '-';
  800224:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
  800226:	00144603          	lbu	a2,1(s0)
  80022a:	846a                	mv	s0,s10
  80022c:	b7c1                	j	8001ec <vprintfmt+0x78>
            precision = va_arg(ap, int);
  80022e:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  800232:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800236:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  800238:	846a                	mv	s0,s10
            if (width < 0)
  80023a:	fa0dd9e3          	bgez	s11,8001ec <vprintfmt+0x78>
                width = precision, precision = -1;
  80023e:	8de6                	mv	s11,s9
  800240:	5cfd                	li	s9,-1
  800242:	b76d                	j	8001ec <vprintfmt+0x78>
            if (width < 0)
  800244:	fffdc693          	not	a3,s11
  800248:	96fd                	srai	a3,a3,0x3f
  80024a:	00ddfdb3          	and	s11,s11,a3
  80024e:	00144603          	lbu	a2,1(s0)
  800252:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  800254:	846a                	mv	s0,s10
  800256:	bf59                	j	8001ec <vprintfmt+0x78>
    if (lflag >= 2) {
  800258:	4705                	li	a4,1
  80025a:	008a8593          	addi	a1,s5,8
  80025e:	01074463          	blt	a4,a6,800266 <vprintfmt+0xf2>
    else if (lflag) {
  800262:	22080863          	beqz	a6,800492 <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
  800266:	000ab603          	ld	a2,0(s5)
  80026a:	46c1                	li	a3,16
  80026c:	8aae                	mv	s5,a1
  80026e:	a291                	j	8003b2 <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
  800270:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  800274:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800278:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  80027a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  80027e:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800282:	fad56ce3          	bltu	a0,a3,80023a <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
  800286:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800288:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  80028c:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  800290:	0196873b          	addw	a4,a3,s9
  800294:	0017171b          	slliw	a4,a4,0x1
  800298:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  80029c:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  8002a0:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002a4:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8002a8:	fcd57fe3          	bgeu	a0,a3,800286 <vprintfmt+0x112>
  8002ac:	b779                	j	80023a <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
  8002ae:	000aa503          	lw	a0,0(s5)
  8002b2:	85a6                	mv	a1,s1
  8002b4:	0aa1                	addi	s5,s5,8
  8002b6:	9902                	jalr	s2
            break;
  8002b8:	bddd                	j	8001ae <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002ba:	4705                	li	a4,1
  8002bc:	008a8993          	addi	s3,s5,8
  8002c0:	01074463          	blt	a4,a6,8002c8 <vprintfmt+0x154>
    else if (lflag) {
  8002c4:	1c080463          	beqz	a6,80048c <vprintfmt+0x318>
        return va_arg(*ap, long);
  8002c8:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  8002cc:	1c044a63          	bltz	s0,8004a0 <vprintfmt+0x32c>
            num = getint(&ap, lflag);
  8002d0:	8622                	mv	a2,s0
  8002d2:	8ace                	mv	s5,s3
  8002d4:	46a9                	li	a3,10
  8002d6:	a8f1                	j	8003b2 <vprintfmt+0x23e>
            err = va_arg(ap, int);
  8002d8:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002dc:	4761                	li	a4,24
            err = va_arg(ap, int);
  8002de:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  8002e0:	41f7d69b          	sraiw	a3,a5,0x1f
  8002e4:	8fb5                	xor	a5,a5,a3
  8002e6:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002ea:	12d74963          	blt	a4,a3,80041c <vprintfmt+0x2a8>
  8002ee:	00369793          	slli	a5,a3,0x3
  8002f2:	97e2                	add	a5,a5,s8
  8002f4:	639c                	ld	a5,0(a5)
  8002f6:	12078363          	beqz	a5,80041c <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
  8002fa:	86be                	mv	a3,a5
  8002fc:	00000617          	auipc	a2,0x0
  800300:	65460613          	addi	a2,a2,1620 # 800950 <error_string+0x1b8>
  800304:	85a6                	mv	a1,s1
  800306:	854a                	mv	a0,s2
  800308:	1cc000ef          	jal	ra,8004d4 <printfmt>
  80030c:	b54d                	j	8001ae <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  80030e:	000ab603          	ld	a2,0(s5)
  800312:	0aa1                	addi	s5,s5,8
  800314:	1a060163          	beqz	a2,8004b6 <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
  800318:	00160413          	addi	s0,a2,1
  80031c:	15b05763          	blez	s11,80046a <vprintfmt+0x2f6>
  800320:	02d00593          	li	a1,45
  800324:	10b79d63          	bne	a5,a1,80043e <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800328:	00064783          	lbu	a5,0(a2)
  80032c:	0007851b          	sext.w	a0,a5
  800330:	c905                	beqz	a0,800360 <vprintfmt+0x1ec>
  800332:	000cc563          	bltz	s9,80033c <vprintfmt+0x1c8>
  800336:	3cfd                	addiw	s9,s9,-1
  800338:	036c8263          	beq	s9,s6,80035c <vprintfmt+0x1e8>
                    putch('?', putdat);
  80033c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  80033e:	14098f63          	beqz	s3,80049c <vprintfmt+0x328>
  800342:	3781                	addiw	a5,a5,-32
  800344:	14fbfc63          	bgeu	s7,a5,80049c <vprintfmt+0x328>
                    putch('?', putdat);
  800348:	03f00513          	li	a0,63
  80034c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80034e:	0405                	addi	s0,s0,1
  800350:	fff44783          	lbu	a5,-1(s0)
  800354:	3dfd                	addiw	s11,s11,-1
  800356:	0007851b          	sext.w	a0,a5
  80035a:	fd61                	bnez	a0,800332 <vprintfmt+0x1be>
            for (; width > 0; width --) {
  80035c:	e5b059e3          	blez	s11,8001ae <vprintfmt+0x3a>
  800360:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800362:	85a6                	mv	a1,s1
  800364:	02000513          	li	a0,32
  800368:	9902                	jalr	s2
            for (; width > 0; width --) {
  80036a:	e40d82e3          	beqz	s11,8001ae <vprintfmt+0x3a>
  80036e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800370:	85a6                	mv	a1,s1
  800372:	02000513          	li	a0,32
  800376:	9902                	jalr	s2
            for (; width > 0; width --) {
  800378:	fe0d94e3          	bnez	s11,800360 <vprintfmt+0x1ec>
  80037c:	bd0d                	j	8001ae <vprintfmt+0x3a>
    if (lflag >= 2) {
  80037e:	4705                	li	a4,1
  800380:	008a8593          	addi	a1,s5,8
  800384:	01074463          	blt	a4,a6,80038c <vprintfmt+0x218>
    else if (lflag) {
  800388:	0e080863          	beqz	a6,800478 <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
  80038c:	000ab603          	ld	a2,0(s5)
  800390:	46a1                	li	a3,8
  800392:	8aae                	mv	s5,a1
  800394:	a839                	j	8003b2 <vprintfmt+0x23e>
            putch('0', putdat);
  800396:	03000513          	li	a0,48
  80039a:	85a6                	mv	a1,s1
  80039c:	e03e                	sd	a5,0(sp)
  80039e:	9902                	jalr	s2
            putch('x', putdat);
  8003a0:	85a6                	mv	a1,s1
  8003a2:	07800513          	li	a0,120
  8003a6:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8003a8:	0aa1                	addi	s5,s5,8
  8003aa:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  8003ae:	6782                	ld	a5,0(sp)
  8003b0:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  8003b2:	2781                	sext.w	a5,a5
  8003b4:	876e                	mv	a4,s11
  8003b6:	85a6                	mv	a1,s1
  8003b8:	854a                	mv	a0,s2
  8003ba:	d35ff0ef          	jal	ra,8000ee <printnum>
            break;
  8003be:	bbc5                	j	8001ae <vprintfmt+0x3a>
            lflag ++;
  8003c0:	00144603          	lbu	a2,1(s0)
  8003c4:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  8003c6:	846a                	mv	s0,s10
            goto reswitch;
  8003c8:	b515                	j	8001ec <vprintfmt+0x78>
            goto reswitch;
  8003ca:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  8003ce:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  8003d0:	846a                	mv	s0,s10
            goto reswitch;
  8003d2:	bd29                	j	8001ec <vprintfmt+0x78>
            putch(ch, putdat);
  8003d4:	85a6                	mv	a1,s1
  8003d6:	02500513          	li	a0,37
  8003da:	9902                	jalr	s2
            break;
  8003dc:	bbc9                	j	8001ae <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003de:	4705                	li	a4,1
  8003e0:	008a8593          	addi	a1,s5,8
  8003e4:	01074463          	blt	a4,a6,8003ec <vprintfmt+0x278>
    else if (lflag) {
  8003e8:	08080d63          	beqz	a6,800482 <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
  8003ec:	000ab603          	ld	a2,0(s5)
  8003f0:	46a9                	li	a3,10
  8003f2:	8aae                	mv	s5,a1
  8003f4:	bf7d                	j	8003b2 <vprintfmt+0x23e>
            putch('%', putdat);
  8003f6:	85a6                	mv	a1,s1
  8003f8:	02500513          	li	a0,37
  8003fc:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  8003fe:	fff44703          	lbu	a4,-1(s0)
  800402:	02500793          	li	a5,37
  800406:	8d22                	mv	s10,s0
  800408:	daf703e3          	beq	a4,a5,8001ae <vprintfmt+0x3a>
  80040c:	02500713          	li	a4,37
  800410:	1d7d                	addi	s10,s10,-1
  800412:	fffd4783          	lbu	a5,-1(s10)
  800416:	fee79de3          	bne	a5,a4,800410 <vprintfmt+0x29c>
  80041a:	bb51                	j	8001ae <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  80041c:	00000617          	auipc	a2,0x0
  800420:	52460613          	addi	a2,a2,1316 # 800940 <error_string+0x1a8>
  800424:	85a6                	mv	a1,s1
  800426:	854a                	mv	a0,s2
  800428:	0ac000ef          	jal	ra,8004d4 <printfmt>
  80042c:	b349                	j	8001ae <vprintfmt+0x3a>
                p = "(null)";
  80042e:	00000617          	auipc	a2,0x0
  800432:	50a60613          	addi	a2,a2,1290 # 800938 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  800436:	00000417          	auipc	s0,0x0
  80043a:	50340413          	addi	s0,s0,1283 # 800939 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80043e:	8532                	mv	a0,a2
  800440:	85e6                	mv	a1,s9
  800442:	e032                	sd	a2,0(sp)
  800444:	e43e                	sd	a5,8(sp)
  800446:	120000ef          	jal	ra,800566 <strnlen>
  80044a:	40ad8dbb          	subw	s11,s11,a0
  80044e:	6602                	ld	a2,0(sp)
  800450:	01b05d63          	blez	s11,80046a <vprintfmt+0x2f6>
  800454:	67a2                	ld	a5,8(sp)
  800456:	2781                	sext.w	a5,a5
  800458:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  80045a:	6522                	ld	a0,8(sp)
  80045c:	85a6                	mv	a1,s1
  80045e:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  800460:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  800462:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  800464:	6602                	ld	a2,0(sp)
  800466:	fe0d9ae3          	bnez	s11,80045a <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80046a:	00064783          	lbu	a5,0(a2)
  80046e:	0007851b          	sext.w	a0,a5
  800472:	ec0510e3          	bnez	a0,800332 <vprintfmt+0x1be>
  800476:	bb25                	j	8001ae <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
  800478:	000ae603          	lwu	a2,0(s5)
  80047c:	46a1                	li	a3,8
  80047e:	8aae                	mv	s5,a1
  800480:	bf0d                	j	8003b2 <vprintfmt+0x23e>
  800482:	000ae603          	lwu	a2,0(s5)
  800486:	46a9                	li	a3,10
  800488:	8aae                	mv	s5,a1
  80048a:	b725                	j	8003b2 <vprintfmt+0x23e>
        return va_arg(*ap, int);
  80048c:	000aa403          	lw	s0,0(s5)
  800490:	bd35                	j	8002cc <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
  800492:	000ae603          	lwu	a2,0(s5)
  800496:	46c1                	li	a3,16
  800498:	8aae                	mv	s5,a1
  80049a:	bf21                	j	8003b2 <vprintfmt+0x23e>
                    putch(ch, putdat);
  80049c:	9902                	jalr	s2
  80049e:	bd45                	j	80034e <vprintfmt+0x1da>
                putch('-', putdat);
  8004a0:	85a6                	mv	a1,s1
  8004a2:	02d00513          	li	a0,45
  8004a6:	e03e                	sd	a5,0(sp)
  8004a8:	9902                	jalr	s2
                num = -(long long)num;
  8004aa:	8ace                	mv	s5,s3
  8004ac:	40800633          	neg	a2,s0
  8004b0:	46a9                	li	a3,10
  8004b2:	6782                	ld	a5,0(sp)
  8004b4:	bdfd                	j	8003b2 <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
  8004b6:	01b05663          	blez	s11,8004c2 <vprintfmt+0x34e>
  8004ba:	02d00693          	li	a3,45
  8004be:	f6d798e3          	bne	a5,a3,80042e <vprintfmt+0x2ba>
  8004c2:	00000417          	auipc	s0,0x0
  8004c6:	47740413          	addi	s0,s0,1143 # 800939 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004ca:	02800513          	li	a0,40
  8004ce:	02800793          	li	a5,40
  8004d2:	b585                	j	800332 <vprintfmt+0x1be>

00000000008004d4 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004d4:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004d6:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004da:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004dc:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004de:	ec06                	sd	ra,24(sp)
  8004e0:	f83a                	sd	a4,48(sp)
  8004e2:	fc3e                	sd	a5,56(sp)
  8004e4:	e0c2                	sd	a6,64(sp)
  8004e6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004e8:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004ea:	c8bff0ef          	jal	ra,800174 <vprintfmt>
}
  8004ee:	60e2                	ld	ra,24(sp)
  8004f0:	6161                	addi	sp,sp,80
  8004f2:	8082                	ret

00000000008004f4 <vsnprintf>:
 * Call this function if you are already dealing with a va_list.
 * Or you probably want snprintf() instead.
 * */
int
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
    struct sprintbuf b = {str, str + size - 1, 0};
  8004f4:	15fd                	addi	a1,a1,-1
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  8004f6:	7179                	addi	sp,sp,-48
    struct sprintbuf b = {str, str + size - 1, 0};
  8004f8:	95aa                	add	a1,a1,a0
vsnprintf(char *str, size_t size, const char *fmt, va_list ap) {
  8004fa:	f406                	sd	ra,40(sp)
    struct sprintbuf b = {str, str + size - 1, 0};
  8004fc:	e42a                	sd	a0,8(sp)
  8004fe:	e82e                	sd	a1,16(sp)
  800500:	cc02                	sw	zero,24(sp)
    if (str == NULL || b.buf > b.ebuf) {
  800502:	c10d                	beqz	a0,800524 <vsnprintf+0x30>
  800504:	02a5e063          	bltu	a1,a0,800524 <vsnprintf+0x30>
        return -E_INVAL;
    }
    // print the string to the buffer
    vprintfmt((void*)sprintputch, &b, fmt, ap);
  800508:	00000517          	auipc	a0,0x0
  80050c:	c5250513          	addi	a0,a0,-942 # 80015a <sprintputch>
  800510:	002c                	addi	a1,sp,8
  800512:	c63ff0ef          	jal	ra,800174 <vprintfmt>
    // null terminate the buffer
    *b.buf = '\0';
  800516:	67a2                	ld	a5,8(sp)
  800518:	00078023          	sb	zero,0(a5)
    return b.cnt;
  80051c:	4562                	lw	a0,24(sp)
}
  80051e:	70a2                	ld	ra,40(sp)
  800520:	6145                	addi	sp,sp,48
  800522:	8082                	ret
        return -E_INVAL;
  800524:	5575                	li	a0,-3
  800526:	bfe5                	j	80051e <vsnprintf+0x2a>

0000000000800528 <snprintf>:
snprintf(char *str, size_t size, const char *fmt, ...) {
  800528:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80052a:	02810313          	addi	t1,sp,40
snprintf(char *str, size_t size, const char *fmt, ...) {
  80052e:	f436                	sd	a3,40(sp)
    cnt = vsnprintf(str, size, fmt, ap);
  800530:	869a                	mv	a3,t1
snprintf(char *str, size_t size, const char *fmt, ...) {
  800532:	ec06                	sd	ra,24(sp)
  800534:	f83a                	sd	a4,48(sp)
  800536:	fc3e                	sd	a5,56(sp)
  800538:	e0c2                	sd	a6,64(sp)
  80053a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  80053c:	e41a                	sd	t1,8(sp)
    cnt = vsnprintf(str, size, fmt, ap);
  80053e:	fb7ff0ef          	jal	ra,8004f4 <vsnprintf>
}
  800542:	60e2                	ld	ra,24(sp)
  800544:	6161                	addi	sp,sp,80
  800546:	8082                	ret

0000000000800548 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
  800548:	00054783          	lbu	a5,0(a0)
  80054c:	cb91                	beqz	a5,800560 <strlen+0x18>
    size_t cnt = 0;
  80054e:	4781                	li	a5,0
        cnt ++;
  800550:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
  800552:	00f50733          	add	a4,a0,a5
  800556:	00074703          	lbu	a4,0(a4)
  80055a:	fb7d                	bnez	a4,800550 <strlen+0x8>
    }
    return cnt;
}
  80055c:	853e                	mv	a0,a5
  80055e:	8082                	ret
    size_t cnt = 0;
  800560:	4781                	li	a5,0
}
  800562:	853e                	mv	a0,a5
  800564:	8082                	ret

0000000000800566 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  800566:	c185                	beqz	a1,800586 <strnlen+0x20>
  800568:	00054783          	lbu	a5,0(a0)
  80056c:	cf89                	beqz	a5,800586 <strnlen+0x20>
    size_t cnt = 0;
  80056e:	4781                	li	a5,0
  800570:	a021                	j	800578 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  800572:	00074703          	lbu	a4,0(a4)
  800576:	c711                	beqz	a4,800582 <strnlen+0x1c>
        cnt ++;
  800578:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  80057a:	00f50733          	add	a4,a0,a5
  80057e:	fef59ae3          	bne	a1,a5,800572 <strnlen+0xc>
    }
    return cnt;
}
  800582:	853e                	mv	a0,a5
  800584:	8082                	ret
    size_t cnt = 0;
  800586:	4781                	li	a5,0
}
  800588:	853e                	mv	a0,a5
  80058a:	8082                	ret

000000000080058c <forktree>:
        exit(0);
    }
}

void
forktree(const char *cur) {
  80058c:	1141                	addi	sp,sp,-16
  80058e:	e406                	sd	ra,8(sp)
  800590:	e022                	sd	s0,0(sp)
  800592:	842a                	mv	s0,a0
    cprintf("%04x: I am '%s'\n", getpid(), cur);
  800594:	b4dff0ef          	jal	ra,8000e0 <getpid>
  800598:	8622                	mv	a2,s0
  80059a:	85aa                	mv	a1,a0
  80059c:	00000517          	auipc	a0,0x0
  8005a0:	3c450513          	addi	a0,a0,964 # 800960 <error_string+0x1c8>
  8005a4:	a9dff0ef          	jal	ra,800040 <cprintf>

    forkchild(cur, '0');
  8005a8:	8522                	mv	a0,s0
  8005aa:	03000593          	li	a1,48
  8005ae:	012000ef          	jal	ra,8005c0 <forkchild>
    forkchild(cur, '1');
  8005b2:	8522                	mv	a0,s0
}
  8005b4:	6402                	ld	s0,0(sp)
  8005b6:	60a2                	ld	ra,8(sp)
    forkchild(cur, '1');
  8005b8:	03100593          	li	a1,49
}
  8005bc:	0141                	addi	sp,sp,16
    forkchild(cur, '1');
  8005be:	a009                	j	8005c0 <forkchild>

00000000008005c0 <forkchild>:
forkchild(const char *cur, char branch) {
  8005c0:	7179                	addi	sp,sp,-48
  8005c2:	f022                	sd	s0,32(sp)
  8005c4:	ec26                	sd	s1,24(sp)
  8005c6:	f406                	sd	ra,40(sp)
  8005c8:	842a                	mv	s0,a0
  8005ca:	84ae                	mv	s1,a1
    if (strlen(cur) >= DEPTH)
  8005cc:	f7dff0ef          	jal	ra,800548 <strlen>
  8005d0:	478d                	li	a5,3
  8005d2:	00a7f763          	bgeu	a5,a0,8005e0 <forkchild+0x20>
}
  8005d6:	70a2                	ld	ra,40(sp)
  8005d8:	7402                	ld	s0,32(sp)
  8005da:	64e2                	ld	s1,24(sp)
  8005dc:	6145                	addi	sp,sp,48
  8005de:	8082                	ret
    snprintf(nxt, DEPTH + 1, "%s%c", cur, branch);
  8005e0:	8726                	mv	a4,s1
  8005e2:	86a2                	mv	a3,s0
  8005e4:	00000617          	auipc	a2,0x0
  8005e8:	37460613          	addi	a2,a2,884 # 800958 <error_string+0x1c0>
  8005ec:	4595                	li	a1,5
  8005ee:	0028                	addi	a0,sp,8
  8005f0:	f39ff0ef          	jal	ra,800528 <snprintf>
    if (fork() == 0) {
  8005f4:	ae9ff0ef          	jal	ra,8000dc <fork>
  8005f8:	fd79                	bnez	a0,8005d6 <forkchild+0x16>
        forktree(nxt);
  8005fa:	0028                	addi	a0,sp,8
  8005fc:	f91ff0ef          	jal	ra,80058c <forktree>
        yield();
  800600:	adfff0ef          	jal	ra,8000de <yield>
        exit(0);
  800604:	4501                	li	a0,0
  800606:	ac1ff0ef          	jal	ra,8000c6 <exit>

000000000080060a <main>:

int
main(void) {
  80060a:	1141                	addi	sp,sp,-16
    forktree("");
  80060c:	00000517          	auipc	a0,0x0
  800610:	36450513          	addi	a0,a0,868 # 800970 <error_string+0x1d8>
main(void) {
  800614:	e406                	sd	ra,8(sp)
    forktree("");
  800616:	f77ff0ef          	jal	ra,80058c <forktree>
    return 0;
}
  80061a:	60a2                	ld	ra,8(sp)
  80061c:	4501                	li	a0,0
  80061e:	0141                	addi	sp,sp,16
  800620:	8082                	ret
