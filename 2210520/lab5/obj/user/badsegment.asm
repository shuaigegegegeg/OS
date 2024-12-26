
obj/__user_badsegment.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	110000ef          	jal	ra,800130 <umain>
1:  j 1b
  800024:	a001                	j	800024 <_start+0x4>

0000000000800026 <__panic>:
#include <stdio.h>
#include <ulib.h>
#include <error.h>

void
__panic(const char *file, int line, const char *fmt, ...) {
  800026:	715d                	addi	sp,sp,-80
  800028:	e822                	sd	s0,16(sp)
  80002a:	fc3e                	sd	a5,56(sp)
  80002c:	8432                	mv	s0,a2
    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  80002e:	103c                	addi	a5,sp,40
    cprintf("user panic at %s:%d:\n    ", file, line);
  800030:	862e                	mv	a2,a1
  800032:	85aa                	mv	a1,a0
  800034:	00000517          	auipc	a0,0x0
  800038:	53450513          	addi	a0,a0,1332 # 800568 <main+0x1a>
__panic(const char *file, int line, const char *fmt, ...) {
  80003c:	ec06                	sd	ra,24(sp)
  80003e:	f436                	sd	a3,40(sp)
  800040:	f83a                	sd	a4,48(sp)
  800042:	e0c2                	sd	a6,64(sp)
  800044:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800046:	e43e                	sd	a5,8(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  800048:	058000ef          	jal	ra,8000a0 <cprintf>
    vcprintf(fmt, ap);
  80004c:	65a2                	ld	a1,8(sp)
  80004e:	8522                	mv	a0,s0
  800050:	030000ef          	jal	ra,800080 <vcprintf>
    cprintf("\n");
  800054:	00000517          	auipc	a0,0x0
  800058:	53450513          	addi	a0,a0,1332 # 800588 <main+0x3a>
  80005c:	044000ef          	jal	ra,8000a0 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800060:	5559                	li	a0,-10
  800062:	0b8000ef          	jal	ra,80011a <exit>

0000000000800066 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800066:	1141                	addi	sp,sp,-16
  800068:	e022                	sd	s0,0(sp)
  80006a:	e406                	sd	ra,8(sp)
  80006c:	842e                	mv	s0,a1
    sys_putc(c);
  80006e:	0a6000ef          	jal	ra,800114 <sys_putc>
    (*cnt) ++;
  800072:	401c                	lw	a5,0(s0)
}
  800074:	60a2                	ld	ra,8(sp)
    (*cnt) ++;
  800076:	2785                	addiw	a5,a5,1
  800078:	c01c                	sw	a5,0(s0)
}
  80007a:	6402                	ld	s0,0(sp)
  80007c:	0141                	addi	sp,sp,16
  80007e:	8082                	ret

0000000000800080 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  800080:	1101                	addi	sp,sp,-32
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800082:	86ae                	mv	a3,a1
  800084:	862a                	mv	a2,a0
  800086:	006c                	addi	a1,sp,12
  800088:	00000517          	auipc	a0,0x0
  80008c:	fde50513          	addi	a0,a0,-34 # 800066 <cputch>
vcprintf(const char *fmt, va_list ap) {
  800090:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  800092:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800094:	114000ef          	jal	ra,8001a8 <vprintfmt>
    return cnt;
}
  800098:	60e2                	ld	ra,24(sp)
  80009a:	4532                	lw	a0,12(sp)
  80009c:	6105                	addi	sp,sp,32
  80009e:	8082                	ret

00000000008000a0 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8000a0:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  8000a2:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  8000a6:	f42e                	sd	a1,40(sp)
  8000a8:	f832                	sd	a2,48(sp)
  8000aa:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000ac:	862a                	mv	a2,a0
  8000ae:	004c                	addi	a1,sp,4
  8000b0:	00000517          	auipc	a0,0x0
  8000b4:	fb650513          	addi	a0,a0,-74 # 800066 <cputch>
  8000b8:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  8000ba:	ec06                	sd	ra,24(sp)
  8000bc:	e0ba                	sd	a4,64(sp)
  8000be:	e4be                	sd	a5,72(sp)
  8000c0:	e8c2                	sd	a6,80(sp)
  8000c2:	ecc6                	sd	a7,88(sp)
    va_start(ap, fmt);
  8000c4:	e41a                	sd	t1,8(sp)
    int cnt = 0;
  8000c6:	c202                	sw	zero,4(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000c8:	0e0000ef          	jal	ra,8001a8 <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  8000cc:	60e2                	ld	ra,24(sp)
  8000ce:	4512                	lw	a0,4(sp)
  8000d0:	6125                	addi	sp,sp,96
  8000d2:	8082                	ret

00000000008000d4 <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int64_t num, ...) {
  8000d4:	7175                	addi	sp,sp,-144
  8000d6:	f8ba                	sd	a4,112(sp)
    va_list ap;
    va_start(ap, num);
    uint64_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint64_t);
  8000d8:	e0ba                	sd	a4,64(sp)
  8000da:	0118                	addi	a4,sp,128
syscall(int64_t num, ...) {
  8000dc:	e42a                	sd	a0,8(sp)
  8000de:	ecae                	sd	a1,88(sp)
  8000e0:	f0b2                	sd	a2,96(sp)
  8000e2:	f4b6                	sd	a3,104(sp)
  8000e4:	fcbe                	sd	a5,120(sp)
  8000e6:	e142                	sd	a6,128(sp)
  8000e8:	e546                	sd	a7,136(sp)
        a[i] = va_arg(ap, uint64_t);
  8000ea:	f42e                	sd	a1,40(sp)
  8000ec:	f832                	sd	a2,48(sp)
  8000ee:	fc36                	sd	a3,56(sp)
  8000f0:	f03a                	sd	a4,32(sp)
  8000f2:	e4be                	sd	a5,72(sp)
    }
    va_end(ap);

    asm volatile (
  8000f4:	6522                	ld	a0,8(sp)
  8000f6:	75a2                	ld	a1,40(sp)
  8000f8:	7642                	ld	a2,48(sp)
  8000fa:	76e2                	ld	a3,56(sp)
  8000fc:	6706                	ld	a4,64(sp)
  8000fe:	67a6                	ld	a5,72(sp)
  800100:	00000073          	ecall
  800104:	00a13e23          	sd	a0,28(sp)
        "sd a0, %0"
        : "=m" (ret)
        : "m"(num), "m"(a[0]), "m"(a[1]), "m"(a[2]), "m"(a[3]), "m"(a[4])
        :"memory");
    return ret;
}
  800108:	4572                	lw	a0,28(sp)
  80010a:	6149                	addi	sp,sp,144
  80010c:	8082                	ret

000000000080010e <sys_exit>:

int
sys_exit(int64_t error_code) {
    return syscall(SYS_exit, error_code);
  80010e:	85aa                	mv	a1,a0
  800110:	4505                	li	a0,1
  800112:	b7c9                	j	8000d4 <syscall>

0000000000800114 <sys_putc>:
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  800114:	85aa                	mv	a1,a0
  800116:	4579                	li	a0,30
  800118:	bf75                	j	8000d4 <syscall>

000000000080011a <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  80011a:	1141                	addi	sp,sp,-16
  80011c:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  80011e:	ff1ff0ef          	jal	ra,80010e <sys_exit>
    cprintf("BUG: exit failed.\n");
  800122:	00000517          	auipc	a0,0x0
  800126:	46e50513          	addi	a0,a0,1134 # 800590 <main+0x42>
  80012a:	f77ff0ef          	jal	ra,8000a0 <cprintf>
    while (1);
  80012e:	a001                	j	80012e <exit+0x14>

0000000000800130 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800130:	1141                	addi	sp,sp,-16
  800132:	e406                	sd	ra,8(sp)
    int ret = main();
  800134:	41a000ef          	jal	ra,80054e <main>
    exit(ret);
  800138:	fe3ff0ef          	jal	ra,80011a <exit>

000000000080013c <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80013c:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800140:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800142:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800146:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800148:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  80014c:	f022                	sd	s0,32(sp)
  80014e:	ec26                	sd	s1,24(sp)
  800150:	e84a                	sd	s2,16(sp)
  800152:	f406                	sd	ra,40(sp)
  800154:	e44e                	sd	s3,8(sp)
  800156:	84aa                	mv	s1,a0
  800158:	892e                	mv	s2,a1
  80015a:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  80015e:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800160:	03067e63          	bgeu	a2,a6,80019c <printnum+0x60>
  800164:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800166:	00805763          	blez	s0,800174 <printnum+0x38>
  80016a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80016c:	85ca                	mv	a1,s2
  80016e:	854e                	mv	a0,s3
  800170:	9482                	jalr	s1
        while (-- width > 0)
  800172:	fc65                	bnez	s0,80016a <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800174:	1a02                	slli	s4,s4,0x20
  800176:	020a5a13          	srli	s4,s4,0x20
  80017a:	00000797          	auipc	a5,0x0
  80017e:	64e78793          	addi	a5,a5,1614 # 8007c8 <error_string+0xc8>
  800182:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  800184:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  800186:	000a4503          	lbu	a0,0(s4)
}
  80018a:	70a2                	ld	ra,40(sp)
  80018c:	69a2                	ld	s3,8(sp)
  80018e:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  800190:	85ca                	mv	a1,s2
  800192:	8326                	mv	t1,s1
}
  800194:	6942                	ld	s2,16(sp)
  800196:	64e2                	ld	s1,24(sp)
  800198:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  80019a:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  80019c:	03065633          	divu	a2,a2,a6
  8001a0:	8722                	mv	a4,s0
  8001a2:	f9bff0ef          	jal	ra,80013c <printnum>
  8001a6:	b7f9                	j	800174 <printnum+0x38>

00000000008001a8 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001a8:	7119                	addi	sp,sp,-128
  8001aa:	f4a6                	sd	s1,104(sp)
  8001ac:	f0ca                	sd	s2,96(sp)
  8001ae:	e8d2                	sd	s4,80(sp)
  8001b0:	e4d6                	sd	s5,72(sp)
  8001b2:	e0da                	sd	s6,64(sp)
  8001b4:	fc5e                	sd	s7,56(sp)
  8001b6:	f862                	sd	s8,48(sp)
  8001b8:	f06a                	sd	s10,32(sp)
  8001ba:	fc86                	sd	ra,120(sp)
  8001bc:	f8a2                	sd	s0,112(sp)
  8001be:	ecce                	sd	s3,88(sp)
  8001c0:	f466                	sd	s9,40(sp)
  8001c2:	ec6e                	sd	s11,24(sp)
  8001c4:	892a                	mv	s2,a0
  8001c6:	84ae                	mv	s1,a1
  8001c8:	8d32                	mv	s10,a2
  8001ca:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001cc:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001ce:	00000a17          	auipc	s4,0x0
  8001d2:	3d6a0a13          	addi	s4,s4,982 # 8005a4 <main+0x56>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  8001d6:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001da:	00000c17          	auipc	s8,0x0
  8001de:	526c0c13          	addi	s8,s8,1318 # 800700 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001e2:	000d4503          	lbu	a0,0(s10)
  8001e6:	02500793          	li	a5,37
  8001ea:	001d0413          	addi	s0,s10,1
  8001ee:	00f50e63          	beq	a0,a5,80020a <vprintfmt+0x62>
            if (ch == '\0') {
  8001f2:	c521                	beqz	a0,80023a <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001f4:	02500993          	li	s3,37
  8001f8:	a011                	j	8001fc <vprintfmt+0x54>
            if (ch == '\0') {
  8001fa:	c121                	beqz	a0,80023a <vprintfmt+0x92>
            putch(ch, putdat);
  8001fc:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001fe:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800200:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800202:	fff44503          	lbu	a0,-1(s0)
  800206:	ff351ae3          	bne	a0,s3,8001fa <vprintfmt+0x52>
  80020a:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  80020e:	02000793          	li	a5,32
        lflag = altflag = 0;
  800212:	4981                	li	s3,0
  800214:	4801                	li	a6,0
        width = precision = -1;
  800216:	5cfd                	li	s9,-1
  800218:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  80021a:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  80021e:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  800220:	fdd6069b          	addiw	a3,a2,-35
  800224:	0ff6f693          	andi	a3,a3,255
  800228:	00140d13          	addi	s10,s0,1
  80022c:	1ed5ef63          	bltu	a1,a3,80042a <vprintfmt+0x282>
  800230:	068a                	slli	a3,a3,0x2
  800232:	96d2                	add	a3,a3,s4
  800234:	4294                	lw	a3,0(a3)
  800236:	96d2                	add	a3,a3,s4
  800238:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80023a:	70e6                	ld	ra,120(sp)
  80023c:	7446                	ld	s0,112(sp)
  80023e:	74a6                	ld	s1,104(sp)
  800240:	7906                	ld	s2,96(sp)
  800242:	69e6                	ld	s3,88(sp)
  800244:	6a46                	ld	s4,80(sp)
  800246:	6aa6                	ld	s5,72(sp)
  800248:	6b06                	ld	s6,64(sp)
  80024a:	7be2                	ld	s7,56(sp)
  80024c:	7c42                	ld	s8,48(sp)
  80024e:	7ca2                	ld	s9,40(sp)
  800250:	7d02                	ld	s10,32(sp)
  800252:	6de2                	ld	s11,24(sp)
  800254:	6109                	addi	sp,sp,128
  800256:	8082                	ret
            padc = '-';
  800258:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
  80025a:	00144603          	lbu	a2,1(s0)
  80025e:	846a                	mv	s0,s10
  800260:	b7c1                	j	800220 <vprintfmt+0x78>
            precision = va_arg(ap, int);
  800262:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  800266:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  80026a:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  80026c:	846a                	mv	s0,s10
            if (width < 0)
  80026e:	fa0dd9e3          	bgez	s11,800220 <vprintfmt+0x78>
                width = precision, precision = -1;
  800272:	8de6                	mv	s11,s9
  800274:	5cfd                	li	s9,-1
  800276:	b76d                	j	800220 <vprintfmt+0x78>
            if (width < 0)
  800278:	fffdc693          	not	a3,s11
  80027c:	96fd                	srai	a3,a3,0x3f
  80027e:	00ddfdb3          	and	s11,s11,a3
  800282:	00144603          	lbu	a2,1(s0)
  800286:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  800288:	846a                	mv	s0,s10
  80028a:	bf59                	j	800220 <vprintfmt+0x78>
    if (lflag >= 2) {
  80028c:	4705                	li	a4,1
  80028e:	008a8593          	addi	a1,s5,8
  800292:	01074463          	blt	a4,a6,80029a <vprintfmt+0xf2>
    else if (lflag) {
  800296:	22080863          	beqz	a6,8004c6 <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
  80029a:	000ab603          	ld	a2,0(s5)
  80029e:	46c1                	li	a3,16
  8002a0:	8aae                	mv	s5,a1
  8002a2:	a291                	j	8003e6 <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
  8002a4:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  8002a8:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8002ac:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8002ae:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8002b2:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8002b6:	fad56ce3          	bltu	a0,a3,80026e <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
  8002ba:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002bc:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  8002c0:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  8002c4:	0196873b          	addw	a4,a3,s9
  8002c8:	0017171b          	slliw	a4,a4,0x1
  8002cc:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  8002d0:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  8002d4:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002d8:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8002dc:	fcd57fe3          	bgeu	a0,a3,8002ba <vprintfmt+0x112>
  8002e0:	b779                	j	80026e <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
  8002e2:	000aa503          	lw	a0,0(s5)
  8002e6:	85a6                	mv	a1,s1
  8002e8:	0aa1                	addi	s5,s5,8
  8002ea:	9902                	jalr	s2
            break;
  8002ec:	bddd                	j	8001e2 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8002ee:	4705                	li	a4,1
  8002f0:	008a8993          	addi	s3,s5,8
  8002f4:	01074463          	blt	a4,a6,8002fc <vprintfmt+0x154>
    else if (lflag) {
  8002f8:	1c080463          	beqz	a6,8004c0 <vprintfmt+0x318>
        return va_arg(*ap, long);
  8002fc:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  800300:	1c044a63          	bltz	s0,8004d4 <vprintfmt+0x32c>
            num = getint(&ap, lflag);
  800304:	8622                	mv	a2,s0
  800306:	8ace                	mv	s5,s3
  800308:	46a9                	li	a3,10
  80030a:	a8f1                	j	8003e6 <vprintfmt+0x23e>
            err = va_arg(ap, int);
  80030c:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800310:	4761                	li	a4,24
            err = va_arg(ap, int);
  800312:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  800314:	41f7d69b          	sraiw	a3,a5,0x1f
  800318:	8fb5                	xor	a5,a5,a3
  80031a:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80031e:	12d74963          	blt	a4,a3,800450 <vprintfmt+0x2a8>
  800322:	00369793          	slli	a5,a3,0x3
  800326:	97e2                	add	a5,a5,s8
  800328:	639c                	ld	a5,0(a5)
  80032a:	12078363          	beqz	a5,800450 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
  80032e:	86be                	mv	a3,a5
  800330:	00000617          	auipc	a2,0x0
  800334:	58860613          	addi	a2,a2,1416 # 8008b8 <error_string+0x1b8>
  800338:	85a6                	mv	a1,s1
  80033a:	854a                	mv	a0,s2
  80033c:	1cc000ef          	jal	ra,800508 <printfmt>
  800340:	b54d                	j	8001e2 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  800342:	000ab603          	ld	a2,0(s5)
  800346:	0aa1                	addi	s5,s5,8
  800348:	1a060163          	beqz	a2,8004ea <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
  80034c:	00160413          	addi	s0,a2,1
  800350:	15b05763          	blez	s11,80049e <vprintfmt+0x2f6>
  800354:	02d00593          	li	a1,45
  800358:	10b79d63          	bne	a5,a1,800472 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80035c:	00064783          	lbu	a5,0(a2)
  800360:	0007851b          	sext.w	a0,a5
  800364:	c905                	beqz	a0,800394 <vprintfmt+0x1ec>
  800366:	000cc563          	bltz	s9,800370 <vprintfmt+0x1c8>
  80036a:	3cfd                	addiw	s9,s9,-1
  80036c:	036c8263          	beq	s9,s6,800390 <vprintfmt+0x1e8>
                    putch('?', putdat);
  800370:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800372:	14098f63          	beqz	s3,8004d0 <vprintfmt+0x328>
  800376:	3781                	addiw	a5,a5,-32
  800378:	14fbfc63          	bgeu	s7,a5,8004d0 <vprintfmt+0x328>
                    putch('?', putdat);
  80037c:	03f00513          	li	a0,63
  800380:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800382:	0405                	addi	s0,s0,1
  800384:	fff44783          	lbu	a5,-1(s0)
  800388:	3dfd                	addiw	s11,s11,-1
  80038a:	0007851b          	sext.w	a0,a5
  80038e:	fd61                	bnez	a0,800366 <vprintfmt+0x1be>
            for (; width > 0; width --) {
  800390:	e5b059e3          	blez	s11,8001e2 <vprintfmt+0x3a>
  800394:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  800396:	85a6                	mv	a1,s1
  800398:	02000513          	li	a0,32
  80039c:	9902                	jalr	s2
            for (; width > 0; width --) {
  80039e:	e40d82e3          	beqz	s11,8001e2 <vprintfmt+0x3a>
  8003a2:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003a4:	85a6                	mv	a1,s1
  8003a6:	02000513          	li	a0,32
  8003aa:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003ac:	fe0d94e3          	bnez	s11,800394 <vprintfmt+0x1ec>
  8003b0:	bd0d                	j	8001e2 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003b2:	4705                	li	a4,1
  8003b4:	008a8593          	addi	a1,s5,8
  8003b8:	01074463          	blt	a4,a6,8003c0 <vprintfmt+0x218>
    else if (lflag) {
  8003bc:	0e080863          	beqz	a6,8004ac <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
  8003c0:	000ab603          	ld	a2,0(s5)
  8003c4:	46a1                	li	a3,8
  8003c6:	8aae                	mv	s5,a1
  8003c8:	a839                	j	8003e6 <vprintfmt+0x23e>
            putch('0', putdat);
  8003ca:	03000513          	li	a0,48
  8003ce:	85a6                	mv	a1,s1
  8003d0:	e03e                	sd	a5,0(sp)
  8003d2:	9902                	jalr	s2
            putch('x', putdat);
  8003d4:	85a6                	mv	a1,s1
  8003d6:	07800513          	li	a0,120
  8003da:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8003dc:	0aa1                	addi	s5,s5,8
  8003de:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  8003e2:	6782                	ld	a5,0(sp)
  8003e4:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  8003e6:	2781                	sext.w	a5,a5
  8003e8:	876e                	mv	a4,s11
  8003ea:	85a6                	mv	a1,s1
  8003ec:	854a                	mv	a0,s2
  8003ee:	d4fff0ef          	jal	ra,80013c <printnum>
            break;
  8003f2:	bbc5                	j	8001e2 <vprintfmt+0x3a>
            lflag ++;
  8003f4:	00144603          	lbu	a2,1(s0)
  8003f8:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  8003fa:	846a                	mv	s0,s10
            goto reswitch;
  8003fc:	b515                	j	800220 <vprintfmt+0x78>
            goto reswitch;
  8003fe:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800402:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  800404:	846a                	mv	s0,s10
            goto reswitch;
  800406:	bd29                	j	800220 <vprintfmt+0x78>
            putch(ch, putdat);
  800408:	85a6                	mv	a1,s1
  80040a:	02500513          	li	a0,37
  80040e:	9902                	jalr	s2
            break;
  800410:	bbc9                	j	8001e2 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800412:	4705                	li	a4,1
  800414:	008a8593          	addi	a1,s5,8
  800418:	01074463          	blt	a4,a6,800420 <vprintfmt+0x278>
    else if (lflag) {
  80041c:	08080d63          	beqz	a6,8004b6 <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
  800420:	000ab603          	ld	a2,0(s5)
  800424:	46a9                	li	a3,10
  800426:	8aae                	mv	s5,a1
  800428:	bf7d                	j	8003e6 <vprintfmt+0x23e>
            putch('%', putdat);
  80042a:	85a6                	mv	a1,s1
  80042c:	02500513          	li	a0,37
  800430:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800432:	fff44703          	lbu	a4,-1(s0)
  800436:	02500793          	li	a5,37
  80043a:	8d22                	mv	s10,s0
  80043c:	daf703e3          	beq	a4,a5,8001e2 <vprintfmt+0x3a>
  800440:	02500713          	li	a4,37
  800444:	1d7d                	addi	s10,s10,-1
  800446:	fffd4783          	lbu	a5,-1(s10)
  80044a:	fee79de3          	bne	a5,a4,800444 <vprintfmt+0x29c>
  80044e:	bb51                	j	8001e2 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800450:	00000617          	auipc	a2,0x0
  800454:	45860613          	addi	a2,a2,1112 # 8008a8 <error_string+0x1a8>
  800458:	85a6                	mv	a1,s1
  80045a:	854a                	mv	a0,s2
  80045c:	0ac000ef          	jal	ra,800508 <printfmt>
  800460:	b349                	j	8001e2 <vprintfmt+0x3a>
                p = "(null)";
  800462:	00000617          	auipc	a2,0x0
  800466:	43e60613          	addi	a2,a2,1086 # 8008a0 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  80046a:	00000417          	auipc	s0,0x0
  80046e:	43740413          	addi	s0,s0,1079 # 8008a1 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800472:	8532                	mv	a0,a2
  800474:	85e6                	mv	a1,s9
  800476:	e032                	sd	a2,0(sp)
  800478:	e43e                	sd	a5,8(sp)
  80047a:	0ae000ef          	jal	ra,800528 <strnlen>
  80047e:	40ad8dbb          	subw	s11,s11,a0
  800482:	6602                	ld	a2,0(sp)
  800484:	01b05d63          	blez	s11,80049e <vprintfmt+0x2f6>
  800488:	67a2                	ld	a5,8(sp)
  80048a:	2781                	sext.w	a5,a5
  80048c:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  80048e:	6522                	ld	a0,8(sp)
  800490:	85a6                	mv	a1,s1
  800492:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  800494:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  800496:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  800498:	6602                	ld	a2,0(sp)
  80049a:	fe0d9ae3          	bnez	s11,80048e <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80049e:	00064783          	lbu	a5,0(a2)
  8004a2:	0007851b          	sext.w	a0,a5
  8004a6:	ec0510e3          	bnez	a0,800366 <vprintfmt+0x1be>
  8004aa:	bb25                	j	8001e2 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
  8004ac:	000ae603          	lwu	a2,0(s5)
  8004b0:	46a1                	li	a3,8
  8004b2:	8aae                	mv	s5,a1
  8004b4:	bf0d                	j	8003e6 <vprintfmt+0x23e>
  8004b6:	000ae603          	lwu	a2,0(s5)
  8004ba:	46a9                	li	a3,10
  8004bc:	8aae                	mv	s5,a1
  8004be:	b725                	j	8003e6 <vprintfmt+0x23e>
        return va_arg(*ap, int);
  8004c0:	000aa403          	lw	s0,0(s5)
  8004c4:	bd35                	j	800300 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
  8004c6:	000ae603          	lwu	a2,0(s5)
  8004ca:	46c1                	li	a3,16
  8004cc:	8aae                	mv	s5,a1
  8004ce:	bf21                	j	8003e6 <vprintfmt+0x23e>
                    putch(ch, putdat);
  8004d0:	9902                	jalr	s2
  8004d2:	bd45                	j	800382 <vprintfmt+0x1da>
                putch('-', putdat);
  8004d4:	85a6                	mv	a1,s1
  8004d6:	02d00513          	li	a0,45
  8004da:	e03e                	sd	a5,0(sp)
  8004dc:	9902                	jalr	s2
                num = -(long long)num;
  8004de:	8ace                	mv	s5,s3
  8004e0:	40800633          	neg	a2,s0
  8004e4:	46a9                	li	a3,10
  8004e6:	6782                	ld	a5,0(sp)
  8004e8:	bdfd                	j	8003e6 <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
  8004ea:	01b05663          	blez	s11,8004f6 <vprintfmt+0x34e>
  8004ee:	02d00693          	li	a3,45
  8004f2:	f6d798e3          	bne	a5,a3,800462 <vprintfmt+0x2ba>
  8004f6:	00000417          	auipc	s0,0x0
  8004fa:	3ab40413          	addi	s0,s0,939 # 8008a1 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004fe:	02800513          	li	a0,40
  800502:	02800793          	li	a5,40
  800506:	b585                	j	800366 <vprintfmt+0x1be>

0000000000800508 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800508:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80050a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80050e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800510:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800512:	ec06                	sd	ra,24(sp)
  800514:	f83a                	sd	a4,48(sp)
  800516:	fc3e                	sd	a5,56(sp)
  800518:	e0c2                	sd	a6,64(sp)
  80051a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  80051c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80051e:	c8bff0ef          	jal	ra,8001a8 <vprintfmt>
}
  800522:	60e2                	ld	ra,24(sp)
  800524:	6161                	addi	sp,sp,80
  800526:	8082                	ret

0000000000800528 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  800528:	c185                	beqz	a1,800548 <strnlen+0x20>
  80052a:	00054783          	lbu	a5,0(a0)
  80052e:	cf89                	beqz	a5,800548 <strnlen+0x20>
    size_t cnt = 0;
  800530:	4781                	li	a5,0
  800532:	a021                	j	80053a <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  800534:	00074703          	lbu	a4,0(a4)
  800538:	c711                	beqz	a4,800544 <strnlen+0x1c>
        cnt ++;
  80053a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  80053c:	00f50733          	add	a4,a0,a5
  800540:	fef59ae3          	bne	a1,a5,800534 <strnlen+0xc>
    }
    return cnt;
}
  800544:	853e                	mv	a0,a5
  800546:	8082                	ret
    size_t cnt = 0;
  800548:	4781                	li	a5,0
}
  80054a:	853e                	mv	a0,a5
  80054c:	8082                	ret

000000000080054e <main>:
#include <ulib.h>

/* try to load the kernel's TSS selector into the DS register */

int
main(void) {
  80054e:	1141                	addi	sp,sp,-16
	// There is no such thing as TSS in RISC-V
    // asm volatile("movw $0x28,%ax; movw %ax,%ds");
    panic("FAIL: T.T\n");
  800550:	00000617          	auipc	a2,0x0
  800554:	37060613          	addi	a2,a2,880 # 8008c0 <error_string+0x1c0>
  800558:	45a9                	li	a1,10
  80055a:	00000517          	auipc	a0,0x0
  80055e:	37650513          	addi	a0,a0,886 # 8008d0 <error_string+0x1d0>
main(void) {
  800562:	e406                	sd	ra,8(sp)
    panic("FAIL: T.T\n");
  800564:	ac3ff0ef          	jal	ra,800026 <__panic>
