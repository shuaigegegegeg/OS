
obj/__user_faultread.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	0b0000ef          	jal	ra,8000d0 <umain>
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
  80002e:	086000ef          	jal	ra,8000b4 <sys_putc>
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
  800068:	0e0000ef          	jal	ra,800148 <vprintfmt>
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

00000000008000b4 <sys_putc>:
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  8000b4:	85aa                	mv	a1,a0
  8000b6:	4579                	li	a0,30
  8000b8:	bf75                	j	800074 <syscall>

00000000008000ba <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000ba:	1141                	addi	sp,sp,-16
  8000bc:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000be:	ff1ff0ef          	jal	ra,8000ae <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000c2:	00000517          	auipc	a0,0x0
  8000c6:	43650513          	addi	a0,a0,1078 # 8004f8 <main+0xa>
  8000ca:	f77ff0ef          	jal	ra,800040 <cprintf>
    while (1);
  8000ce:	a001                	j	8000ce <exit+0x14>

00000000008000d0 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000d0:	1141                	addi	sp,sp,-16
  8000d2:	e406                	sd	ra,8(sp)
    int ret = main();
  8000d4:	41a000ef          	jal	ra,8004ee <main>
    exit(ret);
  8000d8:	fe3ff0ef          	jal	ra,8000ba <exit>

00000000008000dc <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000dc:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000e0:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  8000e2:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000e6:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8000e8:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  8000ec:	f022                	sd	s0,32(sp)
  8000ee:	ec26                	sd	s1,24(sp)
  8000f0:	e84a                	sd	s2,16(sp)
  8000f2:	f406                	sd	ra,40(sp)
  8000f4:	e44e                	sd	s3,8(sp)
  8000f6:	84aa                	mv	s1,a0
  8000f8:	892e                	mv	s2,a1
  8000fa:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  8000fe:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800100:	03067e63          	bgeu	a2,a6,80013c <printnum+0x60>
  800104:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800106:	00805763          	blez	s0,800114 <printnum+0x38>
  80010a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80010c:	85ca                	mv	a1,s2
  80010e:	854e                	mv	a0,s3
  800110:	9482                	jalr	s1
        while (-- width > 0)
  800112:	fc65                	bnez	s0,80010a <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800114:	1a02                	slli	s4,s4,0x20
  800116:	020a5a13          	srli	s4,s4,0x20
  80011a:	00000797          	auipc	a5,0x0
  80011e:	61678793          	addi	a5,a5,1558 # 800730 <error_string+0xc8>
  800122:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800124:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800126:	000a4503          	lbu	a0,0(s4)
}
  80012a:	70a2                	ld	ra,40(sp)
  80012c:	69a2                	ld	s3,8(sp)
  80012e:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800130:	85ca                	mv	a1,s2
  800132:	8326                	mv	t1,s1
}
  800134:	6942                	ld	s2,16(sp)
  800136:	64e2                	ld	s1,24(sp)
  800138:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  80013a:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  80013c:	03065633          	divu	a2,a2,a6
  800140:	8722                	mv	a4,s0
  800142:	f9bff0ef          	jal	ra,8000dc <printnum>
  800146:	b7f9                	j	800114 <printnum+0x38>

0000000000800148 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800148:	7119                	addi	sp,sp,-128
  80014a:	f4a6                	sd	s1,104(sp)
  80014c:	f0ca                	sd	s2,96(sp)
  80014e:	e8d2                	sd	s4,80(sp)
  800150:	e4d6                	sd	s5,72(sp)
  800152:	e0da                	sd	s6,64(sp)
  800154:	fc5e                	sd	s7,56(sp)
  800156:	f862                	sd	s8,48(sp)
  800158:	f06a                	sd	s10,32(sp)
  80015a:	fc86                	sd	ra,120(sp)
  80015c:	f8a2                	sd	s0,112(sp)
  80015e:	ecce                	sd	s3,88(sp)
  800160:	f466                	sd	s9,40(sp)
  800162:	ec6e                	sd	s11,24(sp)
  800164:	892a                	mv	s2,a0
  800166:	84ae                	mv	s1,a1
  800168:	8d32                	mv	s10,a2
  80016a:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  80016c:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  80016e:	00000a17          	auipc	s4,0x0
  800172:	39ea0a13          	addi	s4,s4,926 # 80050c <main+0x1e>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  800176:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80017a:	00000c17          	auipc	s8,0x0
  80017e:	4eec0c13          	addi	s8,s8,1262 # 800668 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800182:	000d4503          	lbu	a0,0(s10)
  800186:	02500793          	li	a5,37
  80018a:	001d0413          	addi	s0,s10,1
  80018e:	00f50e63          	beq	a0,a5,8001aa <vprintfmt+0x62>
            if (ch == '\0') {
  800192:	c521                	beqz	a0,8001da <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800194:	02500993          	li	s3,37
  800198:	a011                	j	80019c <vprintfmt+0x54>
            if (ch == '\0') {
  80019a:	c121                	beqz	a0,8001da <vprintfmt+0x92>
            putch(ch, putdat);
  80019c:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80019e:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  8001a0:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001a2:	fff44503          	lbu	a0,-1(s0)
  8001a6:	ff351ae3          	bne	a0,s3,80019a <vprintfmt+0x52>
  8001aa:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  8001ae:	02000793          	li	a5,32
        lflag = altflag = 0;
  8001b2:	4981                	li	s3,0
  8001b4:	4801                	li	a6,0
        width = precision = -1;
  8001b6:	5cfd                	li	s9,-1
  8001b8:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  8001ba:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  8001be:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  8001c0:	fdd6069b          	addiw	a3,a2,-35
  8001c4:	0ff6f693          	andi	a3,a3,255
  8001c8:	00140d13          	addi	s10,s0,1
  8001cc:	1ed5ef63          	bltu	a1,a3,8003ca <vprintfmt+0x282>
  8001d0:	068a                	slli	a3,a3,0x2
  8001d2:	96d2                	add	a3,a3,s4
  8001d4:	4294                	lw	a3,0(a3)
  8001d6:	96d2                	add	a3,a3,s4
  8001d8:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001da:	70e6                	ld	ra,120(sp)
  8001dc:	7446                	ld	s0,112(sp)
  8001de:	74a6                	ld	s1,104(sp)
  8001e0:	7906                	ld	s2,96(sp)
  8001e2:	69e6                	ld	s3,88(sp)
  8001e4:	6a46                	ld	s4,80(sp)
  8001e6:	6aa6                	ld	s5,72(sp)
  8001e8:	6b06                	ld	s6,64(sp)
  8001ea:	7be2                	ld	s7,56(sp)
  8001ec:	7c42                	ld	s8,48(sp)
  8001ee:	7ca2                	ld	s9,40(sp)
  8001f0:	7d02                	ld	s10,32(sp)
  8001f2:	6de2                	ld	s11,24(sp)
  8001f4:	6109                	addi	sp,sp,128
  8001f6:	8082                	ret
            padc = '-';
  8001f8:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
  8001fa:	00144603          	lbu	a2,1(s0)
  8001fe:	846a                	mv	s0,s10
  800200:	b7c1                	j	8001c0 <vprintfmt+0x78>
            precision = va_arg(ap, int);
  800202:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  800206:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  80020a:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  80020c:	846a                	mv	s0,s10
            if (width < 0)
  80020e:	fa0dd9e3          	bgez	s11,8001c0 <vprintfmt+0x78>
                width = precision, precision = -1;
  800212:	8de6                	mv	s11,s9
  800214:	5cfd                	li	s9,-1
  800216:	b76d                	j	8001c0 <vprintfmt+0x78>
            if (width < 0)
  800218:	fffdc693          	not	a3,s11
  80021c:	96fd                	srai	a3,a3,0x3f
  80021e:	00ddfdb3          	and	s11,s11,a3
  800222:	00144603          	lbu	a2,1(s0)
  800226:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  800228:	846a                	mv	s0,s10
  80022a:	bf59                	j	8001c0 <vprintfmt+0x78>
    if (lflag >= 2) {
  80022c:	4705                	li	a4,1
  80022e:	008a8593          	addi	a1,s5,8
  800232:	01074463          	blt	a4,a6,80023a <vprintfmt+0xf2>
    else if (lflag) {
  800236:	22080863          	beqz	a6,800466 <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
  80023a:	000ab603          	ld	a2,0(s5)
  80023e:	46c1                	li	a3,16
  800240:	8aae                	mv	s5,a1
  800242:	a291                	j	800386 <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
  800244:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  800248:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  80024c:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  80024e:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800252:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800256:	fad56ce3          	bltu	a0,a3,80020e <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
  80025a:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  80025c:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  800260:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  800264:	0196873b          	addw	a4,a3,s9
  800268:	0017171b          	slliw	a4,a4,0x1
  80026c:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  800270:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  800274:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800278:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  80027c:	fcd57fe3          	bgeu	a0,a3,80025a <vprintfmt+0x112>
  800280:	b779                	j	80020e <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
  800282:	000aa503          	lw	a0,0(s5)
  800286:	85a6                	mv	a1,s1
  800288:	0aa1                	addi	s5,s5,8
  80028a:	9902                	jalr	s2
            break;
  80028c:	bddd                	j	800182 <vprintfmt+0x3a>
    if (lflag >= 2) {
  80028e:	4705                	li	a4,1
  800290:	008a8993          	addi	s3,s5,8
  800294:	01074463          	blt	a4,a6,80029c <vprintfmt+0x154>
    else if (lflag) {
  800298:	1c080463          	beqz	a6,800460 <vprintfmt+0x318>
        return va_arg(*ap, long);
  80029c:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  8002a0:	1c044a63          	bltz	s0,800474 <vprintfmt+0x32c>
            num = getint(&ap, lflag);
  8002a4:	8622                	mv	a2,s0
  8002a6:	8ace                	mv	s5,s3
  8002a8:	46a9                	li	a3,10
  8002aa:	a8f1                	j	800386 <vprintfmt+0x23e>
            err = va_arg(ap, int);
  8002ac:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002b0:	4761                	li	a4,24
            err = va_arg(ap, int);
  8002b2:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  8002b4:	41f7d69b          	sraiw	a3,a5,0x1f
  8002b8:	8fb5                	xor	a5,a5,a3
  8002ba:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002be:	12d74963          	blt	a4,a3,8003f0 <vprintfmt+0x2a8>
  8002c2:	00369793          	slli	a5,a3,0x3
  8002c6:	97e2                	add	a5,a5,s8
  8002c8:	639c                	ld	a5,0(a5)
  8002ca:	12078363          	beqz	a5,8003f0 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
  8002ce:	86be                	mv	a3,a5
  8002d0:	00000617          	auipc	a2,0x0
  8002d4:	55060613          	addi	a2,a2,1360 # 800820 <error_string+0x1b8>
  8002d8:	85a6                	mv	a1,s1
  8002da:	854a                	mv	a0,s2
  8002dc:	1cc000ef          	jal	ra,8004a8 <printfmt>
  8002e0:	b54d                	j	800182 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  8002e2:	000ab603          	ld	a2,0(s5)
  8002e6:	0aa1                	addi	s5,s5,8
  8002e8:	1a060163          	beqz	a2,80048a <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
  8002ec:	00160413          	addi	s0,a2,1
  8002f0:	15b05763          	blez	s11,80043e <vprintfmt+0x2f6>
  8002f4:	02d00593          	li	a1,45
  8002f8:	10b79d63          	bne	a5,a1,800412 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8002fc:	00064783          	lbu	a5,0(a2)
  800300:	0007851b          	sext.w	a0,a5
  800304:	c905                	beqz	a0,800334 <vprintfmt+0x1ec>
  800306:	000cc563          	bltz	s9,800310 <vprintfmt+0x1c8>
  80030a:	3cfd                	addiw	s9,s9,-1
  80030c:	036c8263          	beq	s9,s6,800330 <vprintfmt+0x1e8>
                    putch('?', putdat);
  800310:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800312:	14098f63          	beqz	s3,800470 <vprintfmt+0x328>
  800316:	3781                	addiw	a5,a5,-32
  800318:	14fbfc63          	bgeu	s7,a5,800470 <vprintfmt+0x328>
                    putch('?', putdat);
  80031c:	03f00513          	li	a0,63
  800320:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800322:	0405                	addi	s0,s0,1
  800324:	fff44783          	lbu	a5,-1(s0)
  800328:	3dfd                	addiw	s11,s11,-1
  80032a:	0007851b          	sext.w	a0,a5
  80032e:	fd61                	bnez	a0,800306 <vprintfmt+0x1be>
            for (; width > 0; width --) {
  800330:	e5b059e3          	blez	s11,800182 <vprintfmt+0x3a>
  800334:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800336:	85a6                	mv	a1,s1
  800338:	02000513          	li	a0,32
  80033c:	9902                	jalr	s2
            for (; width > 0; width --) {
  80033e:	e40d82e3          	beqz	s11,800182 <vprintfmt+0x3a>
  800342:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800344:	85a6                	mv	a1,s1
  800346:	02000513          	li	a0,32
  80034a:	9902                	jalr	s2
            for (; width > 0; width --) {
  80034c:	fe0d94e3          	bnez	s11,800334 <vprintfmt+0x1ec>
  800350:	bd0d                	j	800182 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800352:	4705                	li	a4,1
  800354:	008a8593          	addi	a1,s5,8
  800358:	01074463          	blt	a4,a6,800360 <vprintfmt+0x218>
    else if (lflag) {
  80035c:	0e080863          	beqz	a6,80044c <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
  800360:	000ab603          	ld	a2,0(s5)
  800364:	46a1                	li	a3,8
  800366:	8aae                	mv	s5,a1
  800368:	a839                	j	800386 <vprintfmt+0x23e>
            putch('0', putdat);
  80036a:	03000513          	li	a0,48
  80036e:	85a6                	mv	a1,s1
  800370:	e03e                	sd	a5,0(sp)
  800372:	9902                	jalr	s2
            putch('x', putdat);
  800374:	85a6                	mv	a1,s1
  800376:	07800513          	li	a0,120
  80037a:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  80037c:	0aa1                	addi	s5,s5,8
  80037e:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  800382:	6782                	ld	a5,0(sp)
  800384:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  800386:	2781                	sext.w	a5,a5
  800388:	876e                	mv	a4,s11
  80038a:	85a6                	mv	a1,s1
  80038c:	854a                	mv	a0,s2
  80038e:	d4fff0ef          	jal	ra,8000dc <printnum>
            break;
  800392:	bbc5                	j	800182 <vprintfmt+0x3a>
            lflag ++;
  800394:	00144603          	lbu	a2,1(s0)
  800398:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  80039a:	846a                	mv	s0,s10
            goto reswitch;
  80039c:	b515                	j	8001c0 <vprintfmt+0x78>
            goto reswitch;
  80039e:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  8003a2:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  8003a4:	846a                	mv	s0,s10
            goto reswitch;
  8003a6:	bd29                	j	8001c0 <vprintfmt+0x78>
            putch(ch, putdat);
  8003a8:	85a6                	mv	a1,s1
  8003aa:	02500513          	li	a0,37
  8003ae:	9902                	jalr	s2
            break;
  8003b0:	bbc9                	j	800182 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003b2:	4705                	li	a4,1
  8003b4:	008a8593          	addi	a1,s5,8
  8003b8:	01074463          	blt	a4,a6,8003c0 <vprintfmt+0x278>
    else if (lflag) {
  8003bc:	08080d63          	beqz	a6,800456 <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
  8003c0:	000ab603          	ld	a2,0(s5)
  8003c4:	46a9                	li	a3,10
  8003c6:	8aae                	mv	s5,a1
  8003c8:	bf7d                	j	800386 <vprintfmt+0x23e>
            putch('%', putdat);
  8003ca:	85a6                	mv	a1,s1
  8003cc:	02500513          	li	a0,37
  8003d0:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  8003d2:	fff44703          	lbu	a4,-1(s0)
  8003d6:	02500793          	li	a5,37
  8003da:	8d22                	mv	s10,s0
  8003dc:	daf703e3          	beq	a4,a5,800182 <vprintfmt+0x3a>
  8003e0:	02500713          	li	a4,37
  8003e4:	1d7d                	addi	s10,s10,-1
  8003e6:	fffd4783          	lbu	a5,-1(s10)
  8003ea:	fee79de3          	bne	a5,a4,8003e4 <vprintfmt+0x29c>
  8003ee:	bb51                	j	800182 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  8003f0:	00000617          	auipc	a2,0x0
  8003f4:	42060613          	addi	a2,a2,1056 # 800810 <error_string+0x1a8>
  8003f8:	85a6                	mv	a1,s1
  8003fa:	854a                	mv	a0,s2
  8003fc:	0ac000ef          	jal	ra,8004a8 <printfmt>
  800400:	b349                	j	800182 <vprintfmt+0x3a>
                p = "(null)";
  800402:	00000617          	auipc	a2,0x0
  800406:	40660613          	addi	a2,a2,1030 # 800808 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  80040a:	00000417          	auipc	s0,0x0
  80040e:	3ff40413          	addi	s0,s0,1023 # 800809 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800412:	8532                	mv	a0,a2
  800414:	85e6                	mv	a1,s9
  800416:	e032                	sd	a2,0(sp)
  800418:	e43e                	sd	a5,8(sp)
  80041a:	0ae000ef          	jal	ra,8004c8 <strnlen>
  80041e:	40ad8dbb          	subw	s11,s11,a0
  800422:	6602                	ld	a2,0(sp)
  800424:	01b05d63          	blez	s11,80043e <vprintfmt+0x2f6>
  800428:	67a2                	ld	a5,8(sp)
  80042a:	2781                	sext.w	a5,a5
  80042c:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  80042e:	6522                	ld	a0,8(sp)
  800430:	85a6                	mv	a1,s1
  800432:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  800434:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  800436:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  800438:	6602                	ld	a2,0(sp)
  80043a:	fe0d9ae3          	bnez	s11,80042e <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80043e:	00064783          	lbu	a5,0(a2)
  800442:	0007851b          	sext.w	a0,a5
  800446:	ec0510e3          	bnez	a0,800306 <vprintfmt+0x1be>
  80044a:	bb25                	j	800182 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
  80044c:	000ae603          	lwu	a2,0(s5)
  800450:	46a1                	li	a3,8
  800452:	8aae                	mv	s5,a1
  800454:	bf0d                	j	800386 <vprintfmt+0x23e>
  800456:	000ae603          	lwu	a2,0(s5)
  80045a:	46a9                	li	a3,10
  80045c:	8aae                	mv	s5,a1
  80045e:	b725                	j	800386 <vprintfmt+0x23e>
        return va_arg(*ap, int);
  800460:	000aa403          	lw	s0,0(s5)
  800464:	bd35                	j	8002a0 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
  800466:	000ae603          	lwu	a2,0(s5)
  80046a:	46c1                	li	a3,16
  80046c:	8aae                	mv	s5,a1
  80046e:	bf21                	j	800386 <vprintfmt+0x23e>
                    putch(ch, putdat);
  800470:	9902                	jalr	s2
  800472:	bd45                	j	800322 <vprintfmt+0x1da>
                putch('-', putdat);
  800474:	85a6                	mv	a1,s1
  800476:	02d00513          	li	a0,45
  80047a:	e03e                	sd	a5,0(sp)
  80047c:	9902                	jalr	s2
                num = -(long long)num;
  80047e:	8ace                	mv	s5,s3
  800480:	40800633          	neg	a2,s0
  800484:	46a9                	li	a3,10
  800486:	6782                	ld	a5,0(sp)
  800488:	bdfd                	j	800386 <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
  80048a:	01b05663          	blez	s11,800496 <vprintfmt+0x34e>
  80048e:	02d00693          	li	a3,45
  800492:	f6d798e3          	bne	a5,a3,800402 <vprintfmt+0x2ba>
  800496:	00000417          	auipc	s0,0x0
  80049a:	37340413          	addi	s0,s0,883 # 800809 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80049e:	02800513          	li	a0,40
  8004a2:	02800793          	li	a5,40
  8004a6:	b585                	j	800306 <vprintfmt+0x1be>

00000000008004a8 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004a8:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004aa:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004ae:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004b0:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004b2:	ec06                	sd	ra,24(sp)
  8004b4:	f83a                	sd	a4,48(sp)
  8004b6:	fc3e                	sd	a5,56(sp)
  8004b8:	e0c2                	sd	a6,64(sp)
  8004ba:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004bc:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004be:	c8bff0ef          	jal	ra,800148 <vprintfmt>
}
  8004c2:	60e2                	ld	ra,24(sp)
  8004c4:	6161                	addi	sp,sp,80
  8004c6:	8082                	ret

00000000008004c8 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  8004c8:	c185                	beqz	a1,8004e8 <strnlen+0x20>
  8004ca:	00054783          	lbu	a5,0(a0)
  8004ce:	cf89                	beqz	a5,8004e8 <strnlen+0x20>
    size_t cnt = 0;
  8004d0:	4781                	li	a5,0
  8004d2:	a021                	j	8004da <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  8004d4:	00074703          	lbu	a4,0(a4)
  8004d8:	c711                	beqz	a4,8004e4 <strnlen+0x1c>
        cnt ++;
  8004da:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8004dc:	00f50733          	add	a4,a0,a5
  8004e0:	fef59ae3          	bne	a1,a5,8004d4 <strnlen+0xc>
    }
    return cnt;
}
  8004e4:	853e                	mv	a0,a5
  8004e6:	8082                	ret
    size_t cnt = 0;
  8004e8:	4781                	li	a5,0
}
  8004ea:	853e                	mv	a0,a5
  8004ec:	8082                	ret

00000000008004ee <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
    cprintf("I read %8x from 0.\n", *(unsigned int *)0);
  8004ee:	00002783          	lw	a5,0(zero) # 0 <_start-0x800020>
  8004f2:	9002                	ebreak
