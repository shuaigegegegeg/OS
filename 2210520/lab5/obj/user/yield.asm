
obj/__user_yield.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	0bc000ef          	jal	ra,8000dc <umain>
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
  80002e:	08e000ef          	jal	ra,8000bc <sys_putc>
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
  800068:	0ec000ef          	jal	ra,800154 <vprintfmt>
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

00000000008000b4 <sys_yield>:
    return syscall(SYS_wait, pid, store);
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  8000b4:	4529                	li	a0,10
  8000b6:	bf7d                	j	800074 <syscall>

00000000008000b8 <sys_getpid>:
    return syscall(SYS_kill, pid);
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  8000b8:	4549                	li	a0,18
  8000ba:	bf6d                	j	800074 <syscall>

00000000008000bc <sys_putc>:
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  8000bc:	85aa                	mv	a1,a0
  8000be:	4579                	li	a0,30
  8000c0:	bf55                	j	800074 <syscall>

00000000008000c2 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  8000c2:	1141                	addi	sp,sp,-16
  8000c4:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  8000c6:	fe9ff0ef          	jal	ra,8000ae <sys_exit>
    cprintf("BUG: exit failed.\n");
  8000ca:	00000517          	auipc	a0,0x0
  8000ce:	49e50513          	addi	a0,a0,1182 # 800568 <main+0x6e>
  8000d2:	f6fff0ef          	jal	ra,800040 <cprintf>
    while (1);
  8000d6:	a001                	j	8000d6 <exit+0x14>

00000000008000d8 <yield>:
    return sys_wait(pid, store);
}

void
yield(void) {
    sys_yield();
  8000d8:	bff1                	j	8000b4 <sys_yield>

00000000008000da <getpid>:
    return sys_kill(pid);
}

int
getpid(void) {
    return sys_getpid();
  8000da:	bff9                	j	8000b8 <sys_getpid>

00000000008000dc <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  8000dc:	1141                	addi	sp,sp,-16
  8000de:	e406                	sd	ra,8(sp)
    int ret = main();
  8000e0:	41a000ef          	jal	ra,8004fa <main>
    exit(ret);
  8000e4:	fdfff0ef          	jal	ra,8000c2 <exit>

00000000008000e8 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  8000e8:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000ec:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  8000ee:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  8000f2:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  8000f4:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  8000f8:	f022                	sd	s0,32(sp)
  8000fa:	ec26                	sd	s1,24(sp)
  8000fc:	e84a                	sd	s2,16(sp)
  8000fe:	f406                	sd	ra,40(sp)
  800100:	e44e                	sd	s3,8(sp)
  800102:	84aa                	mv	s1,a0
  800104:	892e                	mv	s2,a1
  800106:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  80010a:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  80010c:	03067e63          	bgeu	a2,a6,800148 <printnum+0x60>
  800110:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800112:	00805763          	blez	s0,800120 <printnum+0x38>
  800116:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800118:	85ca                	mv	a1,s2
  80011a:	854e                	mv	a0,s3
  80011c:	9482                	jalr	s1
        while (-- width > 0)
  80011e:	fc65                	bnez	s0,800116 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800120:	1a02                	slli	s4,s4,0x20
  800122:	020a5a13          	srli	s4,s4,0x20
  800126:	00000797          	auipc	a5,0x0
  80012a:	67a78793          	addi	a5,a5,1658 # 8007a0 <error_string+0xc8>
  80012e:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800130:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800132:	000a4503          	lbu	a0,0(s4)
}
  800136:	70a2                	ld	ra,40(sp)
  800138:	69a2                	ld	s3,8(sp)
  80013a:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  80013c:	85ca                	mv	a1,s2
  80013e:	8326                	mv	t1,s1
}
  800140:	6942                	ld	s2,16(sp)
  800142:	64e2                	ld	s1,24(sp)
  800144:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  800146:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  800148:	03065633          	divu	a2,a2,a6
  80014c:	8722                	mv	a4,s0
  80014e:	f9bff0ef          	jal	ra,8000e8 <printnum>
  800152:	b7f9                	j	800120 <printnum+0x38>

0000000000800154 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  800154:	7119                	addi	sp,sp,-128
  800156:	f4a6                	sd	s1,104(sp)
  800158:	f0ca                	sd	s2,96(sp)
  80015a:	e8d2                	sd	s4,80(sp)
  80015c:	e4d6                	sd	s5,72(sp)
  80015e:	e0da                	sd	s6,64(sp)
  800160:	fc5e                	sd	s7,56(sp)
  800162:	f862                	sd	s8,48(sp)
  800164:	f06a                	sd	s10,32(sp)
  800166:	fc86                	sd	ra,120(sp)
  800168:	f8a2                	sd	s0,112(sp)
  80016a:	ecce                	sd	s3,88(sp)
  80016c:	f466                	sd	s9,40(sp)
  80016e:	ec6e                	sd	s11,24(sp)
  800170:	892a                	mv	s2,a0
  800172:	84ae                	mv	s1,a1
  800174:	8d32                	mv	s10,a2
  800176:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  800178:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  80017a:	00000a17          	auipc	s4,0x0
  80017e:	402a0a13          	addi	s4,s4,1026 # 80057c <main+0x82>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  800182:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800186:	00000c17          	auipc	s8,0x0
  80018a:	552c0c13          	addi	s8,s8,1362 # 8006d8 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80018e:	000d4503          	lbu	a0,0(s10)
  800192:	02500793          	li	a5,37
  800196:	001d0413          	addi	s0,s10,1
  80019a:	00f50e63          	beq	a0,a5,8001b6 <vprintfmt+0x62>
            if (ch == '\0') {
  80019e:	c521                	beqz	a0,8001e6 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001a0:	02500993          	li	s3,37
  8001a4:	a011                	j	8001a8 <vprintfmt+0x54>
            if (ch == '\0') {
  8001a6:	c121                	beqz	a0,8001e6 <vprintfmt+0x92>
            putch(ch, putdat);
  8001a8:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001aa:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  8001ac:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001ae:	fff44503          	lbu	a0,-1(s0)
  8001b2:	ff351ae3          	bne	a0,s3,8001a6 <vprintfmt+0x52>
  8001b6:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  8001ba:	02000793          	li	a5,32
        lflag = altflag = 0;
  8001be:	4981                	li	s3,0
  8001c0:	4801                	li	a6,0
        width = precision = -1;
  8001c2:	5cfd                	li	s9,-1
  8001c4:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  8001c6:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  8001ca:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  8001cc:	fdd6069b          	addiw	a3,a2,-35
  8001d0:	0ff6f693          	andi	a3,a3,255
  8001d4:	00140d13          	addi	s10,s0,1
  8001d8:	1ed5ef63          	bltu	a1,a3,8003d6 <vprintfmt+0x282>
  8001dc:	068a                	slli	a3,a3,0x2
  8001de:	96d2                	add	a3,a3,s4
  8001e0:	4294                	lw	a3,0(a3)
  8001e2:	96d2                	add	a3,a3,s4
  8001e4:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  8001e6:	70e6                	ld	ra,120(sp)
  8001e8:	7446                	ld	s0,112(sp)
  8001ea:	74a6                	ld	s1,104(sp)
  8001ec:	7906                	ld	s2,96(sp)
  8001ee:	69e6                	ld	s3,88(sp)
  8001f0:	6a46                	ld	s4,80(sp)
  8001f2:	6aa6                	ld	s5,72(sp)
  8001f4:	6b06                	ld	s6,64(sp)
  8001f6:	7be2                	ld	s7,56(sp)
  8001f8:	7c42                	ld	s8,48(sp)
  8001fa:	7ca2                	ld	s9,40(sp)
  8001fc:	7d02                	ld	s10,32(sp)
  8001fe:	6de2                	ld	s11,24(sp)
  800200:	6109                	addi	sp,sp,128
  800202:	8082                	ret
            padc = '-';
  800204:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
  800206:	00144603          	lbu	a2,1(s0)
  80020a:	846a                	mv	s0,s10
  80020c:	b7c1                	j	8001cc <vprintfmt+0x78>
            precision = va_arg(ap, int);
  80020e:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  800212:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800216:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  800218:	846a                	mv	s0,s10
            if (width < 0)
  80021a:	fa0dd9e3          	bgez	s11,8001cc <vprintfmt+0x78>
                width = precision, precision = -1;
  80021e:	8de6                	mv	s11,s9
  800220:	5cfd                	li	s9,-1
  800222:	b76d                	j	8001cc <vprintfmt+0x78>
            if (width < 0)
  800224:	fffdc693          	not	a3,s11
  800228:	96fd                	srai	a3,a3,0x3f
  80022a:	00ddfdb3          	and	s11,s11,a3
  80022e:	00144603          	lbu	a2,1(s0)
  800232:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  800234:	846a                	mv	s0,s10
  800236:	bf59                	j	8001cc <vprintfmt+0x78>
    if (lflag >= 2) {
  800238:	4705                	li	a4,1
  80023a:	008a8593          	addi	a1,s5,8
  80023e:	01074463          	blt	a4,a6,800246 <vprintfmt+0xf2>
    else if (lflag) {
  800242:	22080863          	beqz	a6,800472 <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
  800246:	000ab603          	ld	a2,0(s5)
  80024a:	46c1                	li	a3,16
  80024c:	8aae                	mv	s5,a1
  80024e:	a291                	j	800392 <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
  800250:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  800254:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  800258:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  80025a:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  80025e:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800262:	fad56ce3          	bltu	a0,a3,80021a <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
  800266:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  800268:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  80026c:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  800270:	0196873b          	addw	a4,a3,s9
  800274:	0017171b          	slliw	a4,a4,0x1
  800278:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  80027c:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  800280:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  800284:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800288:	fcd57fe3          	bgeu	a0,a3,800266 <vprintfmt+0x112>
  80028c:	b779                	j	80021a <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
  80028e:	000aa503          	lw	a0,0(s5)
  800292:	85a6                	mv	a1,s1
  800294:	0aa1                	addi	s5,s5,8
  800296:	9902                	jalr	s2
            break;
  800298:	bddd                	j	80018e <vprintfmt+0x3a>
    if (lflag >= 2) {
  80029a:	4705                	li	a4,1
  80029c:	008a8993          	addi	s3,s5,8
  8002a0:	01074463          	blt	a4,a6,8002a8 <vprintfmt+0x154>
    else if (lflag) {
  8002a4:	1c080463          	beqz	a6,80046c <vprintfmt+0x318>
        return va_arg(*ap, long);
  8002a8:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  8002ac:	1c044a63          	bltz	s0,800480 <vprintfmt+0x32c>
            num = getint(&ap, lflag);
  8002b0:	8622                	mv	a2,s0
  8002b2:	8ace                	mv	s5,s3
  8002b4:	46a9                	li	a3,10
  8002b6:	a8f1                	j	800392 <vprintfmt+0x23e>
            err = va_arg(ap, int);
  8002b8:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002bc:	4761                	li	a4,24
            err = va_arg(ap, int);
  8002be:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  8002c0:	41f7d69b          	sraiw	a3,a5,0x1f
  8002c4:	8fb5                	xor	a5,a5,a3
  8002c6:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8002ca:	12d74963          	blt	a4,a3,8003fc <vprintfmt+0x2a8>
  8002ce:	00369793          	slli	a5,a3,0x3
  8002d2:	97e2                	add	a5,a5,s8
  8002d4:	639c                	ld	a5,0(a5)
  8002d6:	12078363          	beqz	a5,8003fc <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
  8002da:	86be                	mv	a3,a5
  8002dc:	00000617          	auipc	a2,0x0
  8002e0:	5b460613          	addi	a2,a2,1460 # 800890 <error_string+0x1b8>
  8002e4:	85a6                	mv	a1,s1
  8002e6:	854a                	mv	a0,s2
  8002e8:	1cc000ef          	jal	ra,8004b4 <printfmt>
  8002ec:	b54d                	j	80018e <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  8002ee:	000ab603          	ld	a2,0(s5)
  8002f2:	0aa1                	addi	s5,s5,8
  8002f4:	1a060163          	beqz	a2,800496 <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
  8002f8:	00160413          	addi	s0,a2,1
  8002fc:	15b05763          	blez	s11,80044a <vprintfmt+0x2f6>
  800300:	02d00593          	li	a1,45
  800304:	10b79d63          	bne	a5,a1,80041e <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800308:	00064783          	lbu	a5,0(a2)
  80030c:	0007851b          	sext.w	a0,a5
  800310:	c905                	beqz	a0,800340 <vprintfmt+0x1ec>
  800312:	000cc563          	bltz	s9,80031c <vprintfmt+0x1c8>
  800316:	3cfd                	addiw	s9,s9,-1
  800318:	036c8263          	beq	s9,s6,80033c <vprintfmt+0x1e8>
                    putch('?', putdat);
  80031c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  80031e:	14098f63          	beqz	s3,80047c <vprintfmt+0x328>
  800322:	3781                	addiw	a5,a5,-32
  800324:	14fbfc63          	bgeu	s7,a5,80047c <vprintfmt+0x328>
                    putch('?', putdat);
  800328:	03f00513          	li	a0,63
  80032c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80032e:	0405                	addi	s0,s0,1
  800330:	fff44783          	lbu	a5,-1(s0)
  800334:	3dfd                	addiw	s11,s11,-1
  800336:	0007851b          	sext.w	a0,a5
  80033a:	fd61                	bnez	a0,800312 <vprintfmt+0x1be>
            for (; width > 0; width --) {
  80033c:	e5b059e3          	blez	s11,80018e <vprintfmt+0x3a>
  800340:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800342:	85a6                	mv	a1,s1
  800344:	02000513          	li	a0,32
  800348:	9902                	jalr	s2
            for (; width > 0; width --) {
  80034a:	e40d82e3          	beqz	s11,80018e <vprintfmt+0x3a>
  80034e:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800350:	85a6                	mv	a1,s1
  800352:	02000513          	li	a0,32
  800356:	9902                	jalr	s2
            for (; width > 0; width --) {
  800358:	fe0d94e3          	bnez	s11,800340 <vprintfmt+0x1ec>
  80035c:	bd0d                	j	80018e <vprintfmt+0x3a>
    if (lflag >= 2) {
  80035e:	4705                	li	a4,1
  800360:	008a8593          	addi	a1,s5,8
  800364:	01074463          	blt	a4,a6,80036c <vprintfmt+0x218>
    else if (lflag) {
  800368:	0e080863          	beqz	a6,800458 <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
  80036c:	000ab603          	ld	a2,0(s5)
  800370:	46a1                	li	a3,8
  800372:	8aae                	mv	s5,a1
  800374:	a839                	j	800392 <vprintfmt+0x23e>
            putch('0', putdat);
  800376:	03000513          	li	a0,48
  80037a:	85a6                	mv	a1,s1
  80037c:	e03e                	sd	a5,0(sp)
  80037e:	9902                	jalr	s2
            putch('x', putdat);
  800380:	85a6                	mv	a1,s1
  800382:	07800513          	li	a0,120
  800386:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800388:	0aa1                	addi	s5,s5,8
  80038a:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  80038e:	6782                	ld	a5,0(sp)
  800390:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  800392:	2781                	sext.w	a5,a5
  800394:	876e                	mv	a4,s11
  800396:	85a6                	mv	a1,s1
  800398:	854a                	mv	a0,s2
  80039a:	d4fff0ef          	jal	ra,8000e8 <printnum>
            break;
  80039e:	bbc5                	j	80018e <vprintfmt+0x3a>
            lflag ++;
  8003a0:	00144603          	lbu	a2,1(s0)
  8003a4:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  8003a6:	846a                	mv	s0,s10
            goto reswitch;
  8003a8:	b515                	j	8001cc <vprintfmt+0x78>
            goto reswitch;
  8003aa:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  8003ae:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  8003b0:	846a                	mv	s0,s10
            goto reswitch;
  8003b2:	bd29                	j	8001cc <vprintfmt+0x78>
            putch(ch, putdat);
  8003b4:	85a6                	mv	a1,s1
  8003b6:	02500513          	li	a0,37
  8003ba:	9902                	jalr	s2
            break;
  8003bc:	bbc9                	j	80018e <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003be:	4705                	li	a4,1
  8003c0:	008a8593          	addi	a1,s5,8
  8003c4:	01074463          	blt	a4,a6,8003cc <vprintfmt+0x278>
    else if (lflag) {
  8003c8:	08080d63          	beqz	a6,800462 <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
  8003cc:	000ab603          	ld	a2,0(s5)
  8003d0:	46a9                	li	a3,10
  8003d2:	8aae                	mv	s5,a1
  8003d4:	bf7d                	j	800392 <vprintfmt+0x23e>
            putch('%', putdat);
  8003d6:	85a6                	mv	a1,s1
  8003d8:	02500513          	li	a0,37
  8003dc:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  8003de:	fff44703          	lbu	a4,-1(s0)
  8003e2:	02500793          	li	a5,37
  8003e6:	8d22                	mv	s10,s0
  8003e8:	daf703e3          	beq	a4,a5,80018e <vprintfmt+0x3a>
  8003ec:	02500713          	li	a4,37
  8003f0:	1d7d                	addi	s10,s10,-1
  8003f2:	fffd4783          	lbu	a5,-1(s10)
  8003f6:	fee79de3          	bne	a5,a4,8003f0 <vprintfmt+0x29c>
  8003fa:	bb51                	j	80018e <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  8003fc:	00000617          	auipc	a2,0x0
  800400:	48460613          	addi	a2,a2,1156 # 800880 <error_string+0x1a8>
  800404:	85a6                	mv	a1,s1
  800406:	854a                	mv	a0,s2
  800408:	0ac000ef          	jal	ra,8004b4 <printfmt>
  80040c:	b349                	j	80018e <vprintfmt+0x3a>
                p = "(null)";
  80040e:	00000617          	auipc	a2,0x0
  800412:	46a60613          	addi	a2,a2,1130 # 800878 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  800416:	00000417          	auipc	s0,0x0
  80041a:	46340413          	addi	s0,s0,1123 # 800879 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80041e:	8532                	mv	a0,a2
  800420:	85e6                	mv	a1,s9
  800422:	e032                	sd	a2,0(sp)
  800424:	e43e                	sd	a5,8(sp)
  800426:	0ae000ef          	jal	ra,8004d4 <strnlen>
  80042a:	40ad8dbb          	subw	s11,s11,a0
  80042e:	6602                	ld	a2,0(sp)
  800430:	01b05d63          	blez	s11,80044a <vprintfmt+0x2f6>
  800434:	67a2                	ld	a5,8(sp)
  800436:	2781                	sext.w	a5,a5
  800438:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  80043a:	6522                	ld	a0,8(sp)
  80043c:	85a6                	mv	a1,s1
  80043e:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  800440:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  800442:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  800444:	6602                	ld	a2,0(sp)
  800446:	fe0d9ae3          	bnez	s11,80043a <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80044a:	00064783          	lbu	a5,0(a2)
  80044e:	0007851b          	sext.w	a0,a5
  800452:	ec0510e3          	bnez	a0,800312 <vprintfmt+0x1be>
  800456:	bb25                	j	80018e <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
  800458:	000ae603          	lwu	a2,0(s5)
  80045c:	46a1                	li	a3,8
  80045e:	8aae                	mv	s5,a1
  800460:	bf0d                	j	800392 <vprintfmt+0x23e>
  800462:	000ae603          	lwu	a2,0(s5)
  800466:	46a9                	li	a3,10
  800468:	8aae                	mv	s5,a1
  80046a:	b725                	j	800392 <vprintfmt+0x23e>
        return va_arg(*ap, int);
  80046c:	000aa403          	lw	s0,0(s5)
  800470:	bd35                	j	8002ac <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
  800472:	000ae603          	lwu	a2,0(s5)
  800476:	46c1                	li	a3,16
  800478:	8aae                	mv	s5,a1
  80047a:	bf21                	j	800392 <vprintfmt+0x23e>
                    putch(ch, putdat);
  80047c:	9902                	jalr	s2
  80047e:	bd45                	j	80032e <vprintfmt+0x1da>
                putch('-', putdat);
  800480:	85a6                	mv	a1,s1
  800482:	02d00513          	li	a0,45
  800486:	e03e                	sd	a5,0(sp)
  800488:	9902                	jalr	s2
                num = -(long long)num;
  80048a:	8ace                	mv	s5,s3
  80048c:	40800633          	neg	a2,s0
  800490:	46a9                	li	a3,10
  800492:	6782                	ld	a5,0(sp)
  800494:	bdfd                	j	800392 <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
  800496:	01b05663          	blez	s11,8004a2 <vprintfmt+0x34e>
  80049a:	02d00693          	li	a3,45
  80049e:	f6d798e3          	bne	a5,a3,80040e <vprintfmt+0x2ba>
  8004a2:	00000417          	auipc	s0,0x0
  8004a6:	3d740413          	addi	s0,s0,983 # 800879 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004aa:	02800513          	li	a0,40
  8004ae:	02800793          	li	a5,40
  8004b2:	b585                	j	800312 <vprintfmt+0x1be>

00000000008004b4 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004b4:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  8004b6:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004ba:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004bc:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  8004be:	ec06                	sd	ra,24(sp)
  8004c0:	f83a                	sd	a4,48(sp)
  8004c2:	fc3e                	sd	a5,56(sp)
  8004c4:	e0c2                	sd	a6,64(sp)
  8004c6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  8004c8:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  8004ca:	c8bff0ef          	jal	ra,800154 <vprintfmt>
}
  8004ce:	60e2                	ld	ra,24(sp)
  8004d0:	6161                	addi	sp,sp,80
  8004d2:	8082                	ret

00000000008004d4 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  8004d4:	c185                	beqz	a1,8004f4 <strnlen+0x20>
  8004d6:	00054783          	lbu	a5,0(a0)
  8004da:	cf89                	beqz	a5,8004f4 <strnlen+0x20>
    size_t cnt = 0;
  8004dc:	4781                	li	a5,0
  8004de:	a021                	j	8004e6 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  8004e0:	00074703          	lbu	a4,0(a4)
  8004e4:	c711                	beqz	a4,8004f0 <strnlen+0x1c>
        cnt ++;
  8004e6:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  8004e8:	00f50733          	add	a4,a0,a5
  8004ec:	fef59ae3          	bne	a1,a5,8004e0 <strnlen+0xc>
    }
    return cnt;
}
  8004f0:	853e                	mv	a0,a5
  8004f2:	8082                	ret
    size_t cnt = 0;
  8004f4:	4781                	li	a5,0
}
  8004f6:	853e                	mv	a0,a5
  8004f8:	8082                	ret

00000000008004fa <main>:
#include <ulib.h>
#include <stdio.h>

int
main(void) {
  8004fa:	1101                	addi	sp,sp,-32
  8004fc:	ec06                	sd	ra,24(sp)
  8004fe:	e822                	sd	s0,16(sp)
  800500:	e426                	sd	s1,8(sp)
  800502:	e04a                	sd	s2,0(sp)
    int i;
    cprintf("Hello, I am process %d.\n", getpid());
  800504:	bd7ff0ef          	jal	ra,8000da <getpid>
  800508:	85aa                	mv	a1,a0
  80050a:	00000517          	auipc	a0,0x0
  80050e:	38e50513          	addi	a0,a0,910 # 800898 <error_string+0x1c0>
  800512:	b2fff0ef          	jal	ra,800040 <cprintf>
    for (i = 0; i < 5; i ++) {
  800516:	4401                	li	s0,0
        yield();
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  800518:	00000917          	auipc	s2,0x0
  80051c:	3a090913          	addi	s2,s2,928 # 8008b8 <error_string+0x1e0>
    for (i = 0; i < 5; i ++) {
  800520:	4495                	li	s1,5
        yield();
  800522:	bb7ff0ef          	jal	ra,8000d8 <yield>
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  800526:	bb5ff0ef          	jal	ra,8000da <getpid>
  80052a:	8622                	mv	a2,s0
  80052c:	85aa                	mv	a1,a0
    for (i = 0; i < 5; i ++) {
  80052e:	2405                	addiw	s0,s0,1
        cprintf("Back in process %d, iteration %d.\n", getpid(), i);
  800530:	854a                	mv	a0,s2
  800532:	b0fff0ef          	jal	ra,800040 <cprintf>
    for (i = 0; i < 5; i ++) {
  800536:	fe9416e3          	bne	s0,s1,800522 <main+0x28>
    }
    cprintf("All done in process %d.\n", getpid());
  80053a:	ba1ff0ef          	jal	ra,8000da <getpid>
  80053e:	85aa                	mv	a1,a0
  800540:	00000517          	auipc	a0,0x0
  800544:	3a050513          	addi	a0,a0,928 # 8008e0 <error_string+0x208>
  800548:	af9ff0ef          	jal	ra,800040 <cprintf>
    cprintf("yield pass.\n");
  80054c:	00000517          	auipc	a0,0x0
  800550:	3b450513          	addi	a0,a0,948 # 800900 <error_string+0x228>
  800554:	aedff0ef          	jal	ra,800040 <cprintf>
    return 0;
}
  800558:	60e2                	ld	ra,24(sp)
  80055a:	6442                	ld	s0,16(sp)
  80055c:	64a2                	ld	s1,8(sp)
  80055e:	6902                	ld	s2,0(sp)
  800560:	4501                	li	a0,0
  800562:	6105                	addi	sp,sp,32
  800564:	8082                	ret
