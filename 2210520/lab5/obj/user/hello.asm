
obj/__user_hello.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	0b6000ef          	jal	ra,8000d6 <umain>
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
  80002e:	08a000ef          	jal	ra,8000b8 <sys_putc>
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
  800068:	0e6000ef          	jal	ra,80014e <vprintfmt>
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

00000000008000b4 <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  8000b4:	4549                	li	a0,18
  8000b6:	bf7d                	j	800074 <syscall>

00000000008000b8 <sys_putc>:
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  8000b8:	85aa                	mv	a1,a0
  8000ba:	4579                	li	a0,30
  8000bc:	bf65                	j	800074 <syscall>

00000000008000be <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000be:	1141                	addi	sp,sp,-16
  8000c0:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000c2:	fedff0ef          	jal	ra,8000ae <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000c6:	00000517          	auipc	a0,0x0
  8000ca:	46a50513          	addi	a0,a0,1130 # 800530 <main+0x3c>
  8000ce:	f73ff0ef          	jal	ra,800040 <cprintf>
    while (1);
  8000d2:	a001                	j	8000d2 <exit+0x14>

00000000008000d4 <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  8000d4:	b7c5                	j	8000b4 <sys_getpid>

00000000008000d6 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000d6:	1141                	addi	sp,sp,-16
  8000d8:	e406                	sd	ra,8(sp)
    int ret = main();
  8000da:	41a000ef          	jal	ra,8004f4 <main>
    exit(ret);
  8000de:	fe1ff0ef          	jal	ra,8000be <exit>

00000000008000e2 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000e2:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000e6:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  8000e8:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000ec:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8000ee:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  8000f2:	f022                	sd	s0,32(sp)
  8000f4:	ec26                	sd	s1,24(sp)
  8000f6:	e84a                	sd	s2,16(sp)
  8000f8:	f406                	sd	ra,40(sp)
  8000fa:	e44e                	sd	s3,8(sp)
  8000fc:	84aa                	mv	s1,a0
  8000fe:	892e                	mv	s2,a1
  800100:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800104:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800106:	03067e63          	bgeu	a2,a6,800142 <printnum+0x60>
  80010a:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80010c:	00805763          	blez	s0,80011a <printnum+0x38>
  800110:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800112:	85ca                	mv	a1,s2
  800114:	854e                	mv	a0,s3
  800116:	9482                	jalr	s1
        while (-- width > 0)
  800118:	fc65                	bnez	s0,800110 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80011a:	1a02                	slli	s4,s4,0x20
  80011c:	020a5a13          	srli	s4,s4,0x20
  800120:	00000797          	auipc	a5,0x0
  800124:	64878793          	addi	a5,a5,1608 # 800768 <error_string+0xc8>
  800128:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  80012a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80012c:	000a4503          	lbu	a0,0(s4)
}
  800130:	70a2                	ld	ra,40(sp)
  800132:	69a2                	ld	s3,8(sp)
  800134:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800136:	85ca                	mv	a1,s2
  800138:	8326                	mv	t1,s1
}
  80013a:	6942                	ld	s2,16(sp)
  80013c:	64e2                	ld	s1,24(sp)
  80013e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800140:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  800142:	03065633          	divu	a2,a2,a6
  800146:	8722                	mv	a4,s0
  800148:	f9bff0ef          	jal	ra,8000e2 <printnum>
  80014c:	b7f9                	j	80011a <printnum+0x38>

000000000080014e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  80014e:	7119                	addi	sp,sp,-128
  800150:	f4a6                	sd	s1,104(sp)
  800152:	f0ca                	sd	s2,96(sp)
  800154:	e8d2                	sd	s4,80(sp)
  800156:	e4d6                	sd	s5,72(sp)
  800158:	e0da                	sd	s6,64(sp)
  80015a:	fc5e                	sd	s7,56(sp)
  80015c:	f862                	sd	s8,48(sp)
  80015e:	f06a                	sd	s10,32(sp)
  800160:	fc86                	sd	ra,120(sp)
  800162:	f8a2                	sd	s0,112(sp)
  800164:	ecce                	sd	s3,88(sp)
  800166:	f466                	sd	s9,40(sp)
  800168:	ec6e                	sd	s11,24(sp)
  80016a:	892a                	mv	s2,a0
  80016c:	84ae                	mv	s1,a1
  80016e:	8d32                	mv	s10,a2
  800170:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800172:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  800174:	00000a17          	auipc	s4,0x0
  800178:	3d0a0a13          	addi	s4,s4,976 # 800544 <main+0x50>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  80017c:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800180:	00000c17          	auipc	s8,0x0
  800184:	520c0c13          	addi	s8,s8,1312 # 8006a0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800188:	000d4503          	lbu	a0,0(s10)
  80018c:	02500793          	li	a5,37
  800190:	001d0413          	addi	s0,s10,1
  800194:	00f50e63          	beq	a0,a5,8001b0 <vprintfmt+0x62>
            if (ch == '\0') {
  800198:	c521                	beqz	a0,8001e0 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80019a:	02500993          	li	s3,37
  80019e:	a011                	j	8001a2 <vprintfmt+0x54>
            if (ch == '\0') {
  8001a0:	c121                	beqz	a0,8001e0 <vprintfmt+0x92>
            putch(ch, putdat);
  8001a2:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001a4:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  8001a6:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001a8:	fff44503          	lbu	a0,-1(s0)
  8001ac:	ff351ae3          	bne	a0,s3,8001a0 <vprintfmt+0x52>
  8001b0:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  8001b4:	02000793          	li	a5,32
        lflag = altflag = 0;
  8001b8:	4981                	li	s3,0
  8001ba:	4801                	li	a6,0
        width = precision = -1;
  8001bc:	5cfd                	li	s9,-1
  8001be:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  8001c0:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  8001c4:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  8001c6:	fdd6069b          	addiw	a3,a2,-35
  8001ca:	0ff6f693          	andi	a3,a3,255
  8001ce:	00140d13          	addi	s10,s0,1
  8001d2:	1ed5ef63          	bltu	a1,a3,8003d0 <vprintfmt+0x282>
  8001d6:	068a                	slli	a3,a3,0x2
  8001d8:	96d2                	add	a3,a3,s4
  8001da:	4294                	lw	a3,0(a3)
  8001dc:	96d2                	add	a3,a3,s4
  8001de:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001e0:	70e6                	ld	ra,120(sp)
  8001e2:	7446                	ld	s0,112(sp)
  8001e4:	74a6                	ld	s1,104(sp)
  8001e6:	7906                	ld	s2,96(sp)
  8001e8:	69e6                	ld	s3,88(sp)
  8001ea:	6a46                	ld	s4,80(sp)
  8001ec:	6aa6                	ld	s5,72(sp)
  8001ee:	6b06                	ld	s6,64(sp)
  8001f0:	7be2                	ld	s7,56(sp)
  8001f2:	7c42                	ld	s8,48(sp)
  8001f4:	7ca2                	ld	s9,40(sp)
  8001f6:	7d02                	ld	s10,32(sp)
  8001f8:	6de2                	ld	s11,24(sp)
  8001fa:	6109                	addi	sp,sp,128
  8001fc:	8082                	ret
            padc = '-';
  8001fe:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
  800200:	00144603          	lbu	a2,1(s0)
  800204:	846a                	mv	s0,s10
  800206:	b7c1                	j	8001c6 <vprintfmt+0x78>
            precision = va_arg(ap, int);
  800208:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  80020c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800210:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  800212:	846a                	mv	s0,s10
            if (width < 0)
  800214:	fa0dd9e3          	bgez	s11,8001c6 <vprintfmt+0x78>
                width = precision, precision = -1;
  800218:	8de6                	mv	s11,s9
  80021a:	5cfd                	li	s9,-1
  80021c:	b76d                	j	8001c6 <vprintfmt+0x78>
            if (width < 0)
  80021e:	fffdc693          	not	a3,s11
  800222:	96fd                	srai	a3,a3,0x3f
  800224:	00ddfdb3          	and	s11,s11,a3
  800228:	00144603          	lbu	a2,1(s0)
  80022c:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  80022e:	846a                	mv	s0,s10
  800230:	bf59                	j	8001c6 <vprintfmt+0x78>
    if (lflag >= 2) {
  800232:	4705                	li	a4,1
  800234:	008a8593          	addi	a1,s5,8
  800238:	01074463          	blt	a4,a6,800240 <vprintfmt+0xf2>
    else if (lflag) {
  80023c:	22080863          	beqz	a6,80046c <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
  800240:	000ab603          	ld	a2,0(s5)
  800244:	46c1                	li	a3,16
  800246:	8aae                	mv	s5,a1
  800248:	a291                	j	80038c <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
  80024a:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  80024e:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800252:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  800254:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  800258:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  80025c:	fad56ce3          	bltu	a0,a3,800214 <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
  800260:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800262:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  800266:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  80026a:	0196873b          	addw	a4,a3,s9
  80026e:	0017171b          	slliw	a4,a4,0x1
  800272:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  800276:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  80027a:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  80027e:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800282:	fcd57fe3          	bgeu	a0,a3,800260 <vprintfmt+0x112>
  800286:	b779                	j	800214 <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
  800288:	000aa503          	lw	a0,0(s5)
  80028c:	85a6                	mv	a1,s1
  80028e:	0aa1                	addi	s5,s5,8
  800290:	9902                	jalr	s2
            break;
  800292:	bddd                	j	800188 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800294:	4705                	li	a4,1
  800296:	008a8993          	addi	s3,s5,8
  80029a:	01074463          	blt	a4,a6,8002a2 <vprintfmt+0x154>
    else if (lflag) {
  80029e:	1c080463          	beqz	a6,800466 <vprintfmt+0x318>
        return va_arg(*ap, long);
  8002a2:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  8002a6:	1c044a63          	bltz	s0,80047a <vprintfmt+0x32c>
            num = getint(&ap, lflag);
  8002aa:	8622                	mv	a2,s0
  8002ac:	8ace                	mv	s5,s3
  8002ae:	46a9                	li	a3,10
  8002b0:	a8f1                	j	80038c <vprintfmt+0x23e>
            err = va_arg(ap, int);
  8002b2:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002b6:	4761                	li	a4,24
            err = va_arg(ap, int);
  8002b8:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  8002ba:	41f7d69b          	sraiw	a3,a5,0x1f
  8002be:	8fb5                	xor	a5,a5,a3
  8002c0:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002c4:	12d74963          	blt	a4,a3,8003f6 <vprintfmt+0x2a8>
  8002c8:	00369793          	slli	a5,a3,0x3
  8002cc:	97e2                	add	a5,a5,s8
  8002ce:	639c                	ld	a5,0(a5)
  8002d0:	12078363          	beqz	a5,8003f6 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
  8002d4:	86be                	mv	a3,a5
  8002d6:	00000617          	auipc	a2,0x0
  8002da:	58260613          	addi	a2,a2,1410 # 800858 <error_string+0x1b8>
  8002de:	85a6                	mv	a1,s1
  8002e0:	854a                	mv	a0,s2
  8002e2:	1cc000ef          	jal	ra,8004ae <printfmt>
  8002e6:	b54d                	j	800188 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  8002e8:	000ab603          	ld	a2,0(s5)
  8002ec:	0aa1                	addi	s5,s5,8
  8002ee:	1a060163          	beqz	a2,800490 <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
  8002f2:	00160413          	addi	s0,a2,1
  8002f6:	15b05763          	blez	s11,800444 <vprintfmt+0x2f6>
  8002fa:	02d00593          	li	a1,45
  8002fe:	10b79d63          	bne	a5,a1,800418 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800302:	00064783          	lbu	a5,0(a2)
  800306:	0007851b          	sext.w	a0,a5
  80030a:	c905                	beqz	a0,80033a <vprintfmt+0x1ec>
  80030c:	000cc563          	bltz	s9,800316 <vprintfmt+0x1c8>
  800310:	3cfd                	addiw	s9,s9,-1
  800312:	036c8263          	beq	s9,s6,800336 <vprintfmt+0x1e8>
                    putch('?', putdat);
  800316:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800318:	14098f63          	beqz	s3,800476 <vprintfmt+0x328>
  80031c:	3781                	addiw	a5,a5,-32
  80031e:	14fbfc63          	bgeu	s7,a5,800476 <vprintfmt+0x328>
                    putch('?', putdat);
  800322:	03f00513          	li	a0,63
  800326:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800328:	0405                	addi	s0,s0,1
  80032a:	fff44783          	lbu	a5,-1(s0)
  80032e:	3dfd                	addiw	s11,s11,-1
  800330:	0007851b          	sext.w	a0,a5
  800334:	fd61                	bnez	a0,80030c <vprintfmt+0x1be>
            for (; width > 0; width --) {
  800336:	e5b059e3          	blez	s11,800188 <vprintfmt+0x3a>
  80033a:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  80033c:	85a6                	mv	a1,s1
  80033e:	02000513          	li	a0,32
  800342:	9902                	jalr	s2
            for (; width > 0; width --) {
  800344:	e40d82e3          	beqz	s11,800188 <vprintfmt+0x3a>
  800348:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  80034a:	85a6                	mv	a1,s1
  80034c:	02000513          	li	a0,32
  800350:	9902                	jalr	s2
            for (; width > 0; width --) {
  800352:	fe0d94e3          	bnez	s11,80033a <vprintfmt+0x1ec>
  800356:	bd0d                	j	800188 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800358:	4705                	li	a4,1
  80035a:	008a8593          	addi	a1,s5,8
  80035e:	01074463          	blt	a4,a6,800366 <vprintfmt+0x218>
    else if (lflag) {
  800362:	0e080863          	beqz	a6,800452 <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
  800366:	000ab603          	ld	a2,0(s5)
  80036a:	46a1                	li	a3,8
  80036c:	8aae                	mv	s5,a1
  80036e:	a839                	j	80038c <vprintfmt+0x23e>
            putch('0', putdat);
  800370:	03000513          	li	a0,48
  800374:	85a6                	mv	a1,s1
  800376:	e03e                	sd	a5,0(sp)
  800378:	9902                	jalr	s2
            putch('x', putdat);
  80037a:	85a6                	mv	a1,s1
  80037c:	07800513          	li	a0,120
  800380:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800382:	0aa1                	addi	s5,s5,8
  800384:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  800388:	6782                	ld	a5,0(sp)
  80038a:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  80038c:	2781                	sext.w	a5,a5
  80038e:	876e                	mv	a4,s11
  800390:	85a6                	mv	a1,s1
  800392:	854a                	mv	a0,s2
  800394:	d4fff0ef          	jal	ra,8000e2 <printnum>
            break;
  800398:	bbc5                	j	800188 <vprintfmt+0x3a>
            lflag ++;
  80039a:	00144603          	lbu	a2,1(s0)
  80039e:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  8003a0:	846a                	mv	s0,s10
            goto reswitch;
  8003a2:	b515                	j	8001c6 <vprintfmt+0x78>
            goto reswitch;
  8003a4:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  8003a8:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  8003aa:	846a                	mv	s0,s10
            goto reswitch;
  8003ac:	bd29                	j	8001c6 <vprintfmt+0x78>
            putch(ch, putdat);
  8003ae:	85a6                	mv	a1,s1
  8003b0:	02500513          	li	a0,37
  8003b4:	9902                	jalr	s2
            break;
  8003b6:	bbc9                	j	800188 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003b8:	4705                	li	a4,1
  8003ba:	008a8593          	addi	a1,s5,8
  8003be:	01074463          	blt	a4,a6,8003c6 <vprintfmt+0x278>
    else if (lflag) {
  8003c2:	08080d63          	beqz	a6,80045c <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
  8003c6:	000ab603          	ld	a2,0(s5)
  8003ca:	46a9                	li	a3,10
  8003cc:	8aae                	mv	s5,a1
  8003ce:	bf7d                	j	80038c <vprintfmt+0x23e>
            putch('%', putdat);
  8003d0:	85a6                	mv	a1,s1
  8003d2:	02500513          	li	a0,37
  8003d6:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  8003d8:	fff44703          	lbu	a4,-1(s0)
  8003dc:	02500793          	li	a5,37
  8003e0:	8d22                	mv	s10,s0
  8003e2:	daf703e3          	beq	a4,a5,800188 <vprintfmt+0x3a>
  8003e6:	02500713          	li	a4,37
  8003ea:	1d7d                	addi	s10,s10,-1
  8003ec:	fffd4783          	lbu	a5,-1(s10)
  8003f0:	fee79de3          	bne	a5,a4,8003ea <vprintfmt+0x29c>
  8003f4:	bb51                	j	800188 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  8003f6:	00000617          	auipc	a2,0x0
  8003fa:	45260613          	addi	a2,a2,1106 # 800848 <error_string+0x1a8>
  8003fe:	85a6                	mv	a1,s1
  800400:	854a                	mv	a0,s2
  800402:	0ac000ef          	jal	ra,8004ae <printfmt>
  800406:	b349                	j	800188 <vprintfmt+0x3a>
                p = "(null)";
  800408:	00000617          	auipc	a2,0x0
  80040c:	43860613          	addi	a2,a2,1080 # 800840 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  800410:	00000417          	auipc	s0,0x0
  800414:	43140413          	addi	s0,s0,1073 # 800841 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800418:	8532                	mv	a0,a2
  80041a:	85e6                	mv	a1,s9
  80041c:	e032                	sd	a2,0(sp)
  80041e:	e43e                	sd	a5,8(sp)
  800420:	0ae000ef          	jal	ra,8004ce <strnlen>
  800424:	40ad8dbb          	subw	s11,s11,a0
  800428:	6602                	ld	a2,0(sp)
  80042a:	01b05d63          	blez	s11,800444 <vprintfmt+0x2f6>
  80042e:	67a2                	ld	a5,8(sp)
  800430:	2781                	sext.w	a5,a5
  800432:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  800434:	6522                	ld	a0,8(sp)
  800436:	85a6                	mv	a1,s1
  800438:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  80043a:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  80043c:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  80043e:	6602                	ld	a2,0(sp)
  800440:	fe0d9ae3          	bnez	s11,800434 <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800444:	00064783          	lbu	a5,0(a2)
  800448:	0007851b          	sext.w	a0,a5
  80044c:	ec0510e3          	bnez	a0,80030c <vprintfmt+0x1be>
  800450:	bb25                	j	800188 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
  800452:	000ae603          	lwu	a2,0(s5)
  800456:	46a1                	li	a3,8
  800458:	8aae                	mv	s5,a1
  80045a:	bf0d                	j	80038c <vprintfmt+0x23e>
  80045c:	000ae603          	lwu	a2,0(s5)
  800460:	46a9                	li	a3,10
  800462:	8aae                	mv	s5,a1
  800464:	b725                	j	80038c <vprintfmt+0x23e>
        return va_arg(*ap, int);
  800466:	000aa403          	lw	s0,0(s5)
  80046a:	bd35                	j	8002a6 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
  80046c:	000ae603          	lwu	a2,0(s5)
  800470:	46c1                	li	a3,16
  800472:	8aae                	mv	s5,a1
  800474:	bf21                	j	80038c <vprintfmt+0x23e>
                    putch(ch, putdat);
  800476:	9902                	jalr	s2
  800478:	bd45                	j	800328 <vprintfmt+0x1da>
                putch('-', putdat);
  80047a:	85a6                	mv	a1,s1
  80047c:	02d00513          	li	a0,45
  800480:	e03e                	sd	a5,0(sp)
  800482:	9902                	jalr	s2
                num = -(long long)num;
  800484:	8ace                	mv	s5,s3
  800486:	40800633          	neg	a2,s0
  80048a:	46a9                	li	a3,10
  80048c:	6782                	ld	a5,0(sp)
  80048e:	bdfd                	j	80038c <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
  800490:	01b05663          	blez	s11,80049c <vprintfmt+0x34e>
  800494:	02d00693          	li	a3,45
  800498:	f6d798e3          	bne	a5,a3,800408 <vprintfmt+0x2ba>
  80049c:	00000417          	auipc	s0,0x0
  8004a0:	3a540413          	addi	s0,s0,933 # 800841 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004a4:	02800513          	li	a0,40
  8004a8:	02800793          	li	a5,40
  8004ac:	b585                	j	80030c <vprintfmt+0x1be>

00000000008004ae <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004ae:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004b0:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004b4:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004b6:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004b8:	ec06                	sd	ra,24(sp)
  8004ba:	f83a                	sd	a4,48(sp)
  8004bc:	fc3e                	sd	a5,56(sp)
  8004be:	e0c2                	sd	a6,64(sp)
  8004c0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004c2:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004c4:	c8bff0ef          	jal	ra,80014e <vprintfmt>
}
  8004c8:	60e2                	ld	ra,24(sp)
  8004ca:	6161                	addi	sp,sp,80
  8004cc:	8082                	ret

00000000008004ce <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  8004ce:	c185                	beqz	a1,8004ee <strnlen+0x20>
  8004d0:	00054783          	lbu	a5,0(a0)
  8004d4:	cf89                	beqz	a5,8004ee <strnlen+0x20>
    size_t cnt = 0;
  8004d6:	4781                	li	a5,0
  8004d8:	a021                	j	8004e0 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  8004da:	00074703          	lbu	a4,0(a4)
  8004de:	c711                	beqz	a4,8004ea <strnlen+0x1c>
        cnt ++;
  8004e0:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8004e2:	00f50733          	add	a4,a0,a5
  8004e6:	fef59ae3          	bne	a1,a5,8004da <strnlen+0xc>
    }
    return cnt;
}
  8004ea:	853e                	mv	a0,a5
  8004ec:	8082                	ret
    size_t cnt = 0;
  8004ee:	4781                	li	a5,0
}
  8004f0:	853e                	mv	a0,a5
  8004f2:	8082                	ret

00000000008004f4 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  8004f4:	1141                	addi	sp,sp,-16
    cprintf("Hello world!!.\n");
  8004f6:	00000517          	auipc	a0,0x0
  8004fa:	36a50513          	addi	a0,a0,874 # 800860 <error_string+0x1c0>
main(void) {
  8004fe:	e406                	sd	ra,8(sp)
    cprintf("Hello world!!.\n");
  800500:	b41ff0ef          	jal	ra,800040 <cprintf>
    cprintf("I am process %d.\n", getpid());
  800504:	bd1ff0ef          	jal	ra,8000d4 <getpid>
  800508:	85aa                	mv	a1,a0
  80050a:	00000517          	auipc	a0,0x0
  80050e:	36650513          	addi	a0,a0,870 # 800870 <error_string+0x1d0>
  800512:	b2fff0ef          	jal	ra,800040 <cprintf>
    cprintf("hello pass.\n");
  800516:	00000517          	auipc	a0,0x0
  80051a:	37250513          	addi	a0,a0,882 # 800888 <error_string+0x1e8>
  80051e:	b23ff0ef          	jal	ra,800040 <cprintf>
    return 0;
}
  800522:	60a2                	ld	ra,8(sp)
  800524:	4501                	li	a0,0
  800526:	0141                	addi	sp,sp,16
  800528:	8082                	ret
