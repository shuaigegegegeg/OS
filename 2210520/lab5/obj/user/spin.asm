
obj/__user_spin.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	12e000ef          	jal	ra,80014e <umain>
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
  800038:	60450513          	addi	a0,a0,1540 # 800638 <main+0xcc>
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
  800058:	60450513          	addi	a0,a0,1540 # 800658 <main+0xec>
  80005c:	044000ef          	jal	ra,8000a0 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800060:	5559                	li	a0,-10
  800062:	0ce000ef          	jal	ra,800130 <exit>

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
  80006e:	0bc000ef          	jal	ra,80012a <sys_putc>
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
  800094:	132000ef          	jal	ra,8001c6 <vprintfmt>
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
  8000c8:	0fe000ef          	jal	ra,8001c6 <vprintfmt>
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

0000000000800114 <sys_fork>:
}

int
sys_fork(void) {
    return syscall(SYS_fork);
  800114:	4509                	li	a0,2
  800116:	bf7d                	j	8000d4 <syscall>

0000000000800118 <sys_wait>:
}

int
sys_wait(int64_t pid, int *store) {
    return syscall(SYS_wait, pid, store);
  800118:	862e                	mv	a2,a1
  80011a:	85aa                	mv	a1,a0
  80011c:	450d                	li	a0,3
  80011e:	bf5d                	j	8000d4 <syscall>

0000000000800120 <sys_yield>:
}

int
sys_yield(void) {
    return syscall(SYS_yield);
  800120:	4529                	li	a0,10
  800122:	bf4d                	j	8000d4 <syscall>

0000000000800124 <sys_kill>:
}

int
sys_kill(int64_t pid) {
    return syscall(SYS_kill, pid);
  800124:	85aa                	mv	a1,a0
  800126:	4531                	li	a0,12
  800128:	b775                	j	8000d4 <syscall>

000000000080012a <sys_putc>:
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  80012a:	85aa                	mv	a1,a0
  80012c:	4579                	li	a0,30
  80012e:	b75d                	j	8000d4 <syscall>

0000000000800130 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800130:	1141                	addi	sp,sp,-16
  800132:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800134:	fdbff0ef          	jal	ra,80010e <sys_exit>
    cprintf("BUG: exit failed.\n");
  800138:	00000517          	auipc	a0,0x0
  80013c:	52850513          	addi	a0,a0,1320 # 800660 <main+0xf4>
  800140:	f61ff0ef          	jal	ra,8000a0 <cprintf>
    while (1);
  800144:	a001                	j	800144 <exit+0x14>

0000000000800146 <fork>:
}

int
fork(void) {
    return sys_fork();
  800146:	b7f9                	j	800114 <sys_fork>

0000000000800148 <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  800148:	bfc1                	j	800118 <sys_wait>

000000000080014a <yield>:
}

void
yield(void) {
    sys_yield();
  80014a:	bfd9                	j	800120 <sys_yield>

000000000080014c <kill>:
}

int
kill(int pid) {
    return sys_kill(pid);
  80014c:	bfe1                	j	800124 <sys_kill>

000000000080014e <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  80014e:	1141                	addi	sp,sp,-16
  800150:	e406                	sd	ra,8(sp)
    int ret = main();
  800152:	41a000ef          	jal	ra,80056c <main>
    exit(ret);
  800156:	fdbff0ef          	jal	ra,800130 <exit>

000000000080015a <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  80015a:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80015e:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800160:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800164:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800166:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  80016a:	f022                	sd	s0,32(sp)
  80016c:	ec26                	sd	s1,24(sp)
  80016e:	e84a                	sd	s2,16(sp)
  800170:	f406                	sd	ra,40(sp)
  800172:	e44e                	sd	s3,8(sp)
  800174:	84aa                	mv	s1,a0
  800176:	892e                	mv	s2,a1
  800178:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  80017c:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  80017e:	03067e63          	bgeu	a2,a6,8001ba <printnum+0x60>
  800182:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800184:	00805763          	blez	s0,800192 <printnum+0x38>
  800188:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80018a:	85ca                	mv	a1,s2
  80018c:	854e                	mv	a0,s3
  80018e:	9482                	jalr	s1
        while (-- width > 0)
  800190:	fc65                	bnez	s0,800188 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800192:	1a02                	slli	s4,s4,0x20
  800194:	020a5a13          	srli	s4,s4,0x20
  800198:	00000797          	auipc	a5,0x0
  80019c:	70078793          	addi	a5,a5,1792 # 800898 <error_string+0xc8>
  8001a0:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001a2:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001a4:	000a4503          	lbu	a0,0(s4)
}
  8001a8:	70a2                	ld	ra,40(sp)
  8001aa:	69a2                	ld	s3,8(sp)
  8001ac:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001ae:	85ca                	mv	a1,s2
  8001b0:	8326                	mv	t1,s1
}
  8001b2:	6942                	ld	s2,16(sp)
  8001b4:	64e2                	ld	s1,24(sp)
  8001b6:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001b8:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001ba:	03065633          	divu	a2,a2,a6
  8001be:	8722                	mv	a4,s0
  8001c0:	f9bff0ef          	jal	ra,80015a <printnum>
  8001c4:	b7f9                	j	800192 <printnum+0x38>

00000000008001c6 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001c6:	7119                	addi	sp,sp,-128
  8001c8:	f4a6                	sd	s1,104(sp)
  8001ca:	f0ca                	sd	s2,96(sp)
  8001cc:	e8d2                	sd	s4,80(sp)
  8001ce:	e4d6                	sd	s5,72(sp)
  8001d0:	e0da                	sd	s6,64(sp)
  8001d2:	fc5e                	sd	s7,56(sp)
  8001d4:	f862                	sd	s8,48(sp)
  8001d6:	f06a                	sd	s10,32(sp)
  8001d8:	fc86                	sd	ra,120(sp)
  8001da:	f8a2                	sd	s0,112(sp)
  8001dc:	ecce                	sd	s3,88(sp)
  8001de:	f466                	sd	s9,40(sp)
  8001e0:	ec6e                	sd	s11,24(sp)
  8001e2:	892a                	mv	s2,a0
  8001e4:	84ae                	mv	s1,a1
  8001e6:	8d32                	mv	s10,a2
  8001e8:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001ea:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001ec:	00000a17          	auipc	s4,0x0
  8001f0:	488a0a13          	addi	s4,s4,1160 # 800674 <main+0x108>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  8001f4:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001f8:	00000c17          	auipc	s8,0x0
  8001fc:	5d8c0c13          	addi	s8,s8,1496 # 8007d0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800200:	000d4503          	lbu	a0,0(s10)
  800204:	02500793          	li	a5,37
  800208:	001d0413          	addi	s0,s10,1
  80020c:	00f50e63          	beq	a0,a5,800228 <vprintfmt+0x62>
            if (ch == '\0') {
  800210:	c521                	beqz	a0,800258 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800212:	02500993          	li	s3,37
  800216:	a011                	j	80021a <vprintfmt+0x54>
            if (ch == '\0') {
  800218:	c121                	beqz	a0,800258 <vprintfmt+0x92>
            putch(ch, putdat);
  80021a:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80021c:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  80021e:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800220:	fff44503          	lbu	a0,-1(s0)
  800224:	ff351ae3          	bne	a0,s3,800218 <vprintfmt+0x52>
  800228:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  80022c:	02000793          	li	a5,32
        lflag = altflag = 0;
  800230:	4981                	li	s3,0
  800232:	4801                	li	a6,0
        width = precision = -1;
  800234:	5cfd                	li	s9,-1
  800236:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  800238:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  80023c:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  80023e:	fdd6069b          	addiw	a3,a2,-35
  800242:	0ff6f693          	andi	a3,a3,255
  800246:	00140d13          	addi	s10,s0,1
  80024a:	1ed5ef63          	bltu	a1,a3,800448 <vprintfmt+0x282>
  80024e:	068a                	slli	a3,a3,0x2
  800250:	96d2                	add	a3,a3,s4
  800252:	4294                	lw	a3,0(a3)
  800254:	96d2                	add	a3,a3,s4
  800256:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800258:	70e6                	ld	ra,120(sp)
  80025a:	7446                	ld	s0,112(sp)
  80025c:	74a6                	ld	s1,104(sp)
  80025e:	7906                	ld	s2,96(sp)
  800260:	69e6                	ld	s3,88(sp)
  800262:	6a46                	ld	s4,80(sp)
  800264:	6aa6                	ld	s5,72(sp)
  800266:	6b06                	ld	s6,64(sp)
  800268:	7be2                	ld	s7,56(sp)
  80026a:	7c42                	ld	s8,48(sp)
  80026c:	7ca2                	ld	s9,40(sp)
  80026e:	7d02                	ld	s10,32(sp)
  800270:	6de2                	ld	s11,24(sp)
  800272:	6109                	addi	sp,sp,128
  800274:	8082                	ret
            padc = '-';
  800276:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
  800278:	00144603          	lbu	a2,1(s0)
  80027c:	846a                	mv	s0,s10
  80027e:	b7c1                	j	80023e <vprintfmt+0x78>
            precision = va_arg(ap, int);
  800280:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  800284:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800288:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  80028a:	846a                	mv	s0,s10
            if (width < 0)
  80028c:	fa0dd9e3          	bgez	s11,80023e <vprintfmt+0x78>
                width = precision, precision = -1;
  800290:	8de6                	mv	s11,s9
  800292:	5cfd                	li	s9,-1
  800294:	b76d                	j	80023e <vprintfmt+0x78>
            if (width < 0)
  800296:	fffdc693          	not	a3,s11
  80029a:	96fd                	srai	a3,a3,0x3f
  80029c:	00ddfdb3          	and	s11,s11,a3
  8002a0:	00144603          	lbu	a2,1(s0)
  8002a4:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  8002a6:	846a                	mv	s0,s10
  8002a8:	bf59                	j	80023e <vprintfmt+0x78>
    if (lflag >= 2) {
  8002aa:	4705                	li	a4,1
  8002ac:	008a8593          	addi	a1,s5,8
  8002b0:	01074463          	blt	a4,a6,8002b8 <vprintfmt+0xf2>
    else if (lflag) {
  8002b4:	22080863          	beqz	a6,8004e4 <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
  8002b8:	000ab603          	ld	a2,0(s5)
  8002bc:	46c1                	li	a3,16
  8002be:	8aae                	mv	s5,a1
  8002c0:	a291                	j	800404 <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
  8002c2:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  8002c6:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8002ca:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8002cc:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8002d0:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8002d4:	fad56ce3          	bltu	a0,a3,80028c <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
  8002d8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002da:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  8002de:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  8002e2:	0196873b          	addw	a4,a3,s9
  8002e6:	0017171b          	slliw	a4,a4,0x1
  8002ea:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  8002ee:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  8002f2:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002f6:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8002fa:	fcd57fe3          	bgeu	a0,a3,8002d8 <vprintfmt+0x112>
  8002fe:	b779                	j	80028c <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
  800300:	000aa503          	lw	a0,0(s5)
  800304:	85a6                	mv	a1,s1
  800306:	0aa1                	addi	s5,s5,8
  800308:	9902                	jalr	s2
            break;
  80030a:	bddd                	j	800200 <vprintfmt+0x3a>
    if (lflag >= 2) {
  80030c:	4705                	li	a4,1
  80030e:	008a8993          	addi	s3,s5,8
  800312:	01074463          	blt	a4,a6,80031a <vprintfmt+0x154>
    else if (lflag) {
  800316:	1c080463          	beqz	a6,8004de <vprintfmt+0x318>
        return va_arg(*ap, long);
  80031a:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  80031e:	1c044a63          	bltz	s0,8004f2 <vprintfmt+0x32c>
            num = getint(&ap, lflag);
  800322:	8622                	mv	a2,s0
  800324:	8ace                	mv	s5,s3
  800326:	46a9                	li	a3,10
  800328:	a8f1                	j	800404 <vprintfmt+0x23e>
            err = va_arg(ap, int);
  80032a:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80032e:	4761                	li	a4,24
            err = va_arg(ap, int);
  800330:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  800332:	41f7d69b          	sraiw	a3,a5,0x1f
  800336:	8fb5                	xor	a5,a5,a3
  800338:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80033c:	12d74963          	blt	a4,a3,80046e <vprintfmt+0x2a8>
  800340:	00369793          	slli	a5,a3,0x3
  800344:	97e2                	add	a5,a5,s8
  800346:	639c                	ld	a5,0(a5)
  800348:	12078363          	beqz	a5,80046e <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
  80034c:	86be                	mv	a3,a5
  80034e:	00000617          	auipc	a2,0x0
  800352:	63a60613          	addi	a2,a2,1594 # 800988 <error_string+0x1b8>
  800356:	85a6                	mv	a1,s1
  800358:	854a                	mv	a0,s2
  80035a:	1cc000ef          	jal	ra,800526 <printfmt>
  80035e:	b54d                	j	800200 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  800360:	000ab603          	ld	a2,0(s5)
  800364:	0aa1                	addi	s5,s5,8
  800366:	1a060163          	beqz	a2,800508 <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
  80036a:	00160413          	addi	s0,a2,1
  80036e:	15b05763          	blez	s11,8004bc <vprintfmt+0x2f6>
  800372:	02d00593          	li	a1,45
  800376:	10b79d63          	bne	a5,a1,800490 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80037a:	00064783          	lbu	a5,0(a2)
  80037e:	0007851b          	sext.w	a0,a5
  800382:	c905                	beqz	a0,8003b2 <vprintfmt+0x1ec>
  800384:	000cc563          	bltz	s9,80038e <vprintfmt+0x1c8>
  800388:	3cfd                	addiw	s9,s9,-1
  80038a:	036c8263          	beq	s9,s6,8003ae <vprintfmt+0x1e8>
                    putch('?', putdat);
  80038e:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800390:	14098f63          	beqz	s3,8004ee <vprintfmt+0x328>
  800394:	3781                	addiw	a5,a5,-32
  800396:	14fbfc63          	bgeu	s7,a5,8004ee <vprintfmt+0x328>
                    putch('?', putdat);
  80039a:	03f00513          	li	a0,63
  80039e:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003a0:	0405                	addi	s0,s0,1
  8003a2:	fff44783          	lbu	a5,-1(s0)
  8003a6:	3dfd                	addiw	s11,s11,-1
  8003a8:	0007851b          	sext.w	a0,a5
  8003ac:	fd61                	bnez	a0,800384 <vprintfmt+0x1be>
            for (; width > 0; width --) {
  8003ae:	e5b059e3          	blez	s11,800200 <vprintfmt+0x3a>
  8003b2:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003b4:	85a6                	mv	a1,s1
  8003b6:	02000513          	li	a0,32
  8003ba:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003bc:	e40d82e3          	beqz	s11,800200 <vprintfmt+0x3a>
  8003c0:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003c2:	85a6                	mv	a1,s1
  8003c4:	02000513          	li	a0,32
  8003c8:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003ca:	fe0d94e3          	bnez	s11,8003b2 <vprintfmt+0x1ec>
  8003ce:	bd0d                	j	800200 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003d0:	4705                	li	a4,1
  8003d2:	008a8593          	addi	a1,s5,8
  8003d6:	01074463          	blt	a4,a6,8003de <vprintfmt+0x218>
    else if (lflag) {
  8003da:	0e080863          	beqz	a6,8004ca <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
  8003de:	000ab603          	ld	a2,0(s5)
  8003e2:	46a1                	li	a3,8
  8003e4:	8aae                	mv	s5,a1
  8003e6:	a839                	j	800404 <vprintfmt+0x23e>
            putch('0', putdat);
  8003e8:	03000513          	li	a0,48
  8003ec:	85a6                	mv	a1,s1
  8003ee:	e03e                	sd	a5,0(sp)
  8003f0:	9902                	jalr	s2
            putch('x', putdat);
  8003f2:	85a6                	mv	a1,s1
  8003f4:	07800513          	li	a0,120
  8003f8:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8003fa:	0aa1                	addi	s5,s5,8
  8003fc:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  800400:	6782                	ld	a5,0(sp)
  800402:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  800404:	2781                	sext.w	a5,a5
  800406:	876e                	mv	a4,s11
  800408:	85a6                	mv	a1,s1
  80040a:	854a                	mv	a0,s2
  80040c:	d4fff0ef          	jal	ra,80015a <printnum>
            break;
  800410:	bbc5                	j	800200 <vprintfmt+0x3a>
            lflag ++;
  800412:	00144603          	lbu	a2,1(s0)
  800416:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  800418:	846a                	mv	s0,s10
            goto reswitch;
  80041a:	b515                	j	80023e <vprintfmt+0x78>
            goto reswitch;
  80041c:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800420:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  800422:	846a                	mv	s0,s10
            goto reswitch;
  800424:	bd29                	j	80023e <vprintfmt+0x78>
            putch(ch, putdat);
  800426:	85a6                	mv	a1,s1
  800428:	02500513          	li	a0,37
  80042c:	9902                	jalr	s2
            break;
  80042e:	bbc9                	j	800200 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800430:	4705                	li	a4,1
  800432:	008a8593          	addi	a1,s5,8
  800436:	01074463          	blt	a4,a6,80043e <vprintfmt+0x278>
    else if (lflag) {
  80043a:	08080d63          	beqz	a6,8004d4 <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
  80043e:	000ab603          	ld	a2,0(s5)
  800442:	46a9                	li	a3,10
  800444:	8aae                	mv	s5,a1
  800446:	bf7d                	j	800404 <vprintfmt+0x23e>
            putch('%', putdat);
  800448:	85a6                	mv	a1,s1
  80044a:	02500513          	li	a0,37
  80044e:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800450:	fff44703          	lbu	a4,-1(s0)
  800454:	02500793          	li	a5,37
  800458:	8d22                	mv	s10,s0
  80045a:	daf703e3          	beq	a4,a5,800200 <vprintfmt+0x3a>
  80045e:	02500713          	li	a4,37
  800462:	1d7d                	addi	s10,s10,-1
  800464:	fffd4783          	lbu	a5,-1(s10)
  800468:	fee79de3          	bne	a5,a4,800462 <vprintfmt+0x29c>
  80046c:	bb51                	j	800200 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  80046e:	00000617          	auipc	a2,0x0
  800472:	50a60613          	addi	a2,a2,1290 # 800978 <error_string+0x1a8>
  800476:	85a6                	mv	a1,s1
  800478:	854a                	mv	a0,s2
  80047a:	0ac000ef          	jal	ra,800526 <printfmt>
  80047e:	b349                	j	800200 <vprintfmt+0x3a>
                p = "(null)";
  800480:	00000617          	auipc	a2,0x0
  800484:	4f060613          	addi	a2,a2,1264 # 800970 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  800488:	00000417          	auipc	s0,0x0
  80048c:	4e940413          	addi	s0,s0,1257 # 800971 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800490:	8532                	mv	a0,a2
  800492:	85e6                	mv	a1,s9
  800494:	e032                	sd	a2,0(sp)
  800496:	e43e                	sd	a5,8(sp)
  800498:	0ae000ef          	jal	ra,800546 <strnlen>
  80049c:	40ad8dbb          	subw	s11,s11,a0
  8004a0:	6602                	ld	a2,0(sp)
  8004a2:	01b05d63          	blez	s11,8004bc <vprintfmt+0x2f6>
  8004a6:	67a2                	ld	a5,8(sp)
  8004a8:	2781                	sext.w	a5,a5
  8004aa:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004ac:	6522                	ld	a0,8(sp)
  8004ae:	85a6                	mv	a1,s1
  8004b0:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004b2:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004b4:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004b6:	6602                	ld	a2,0(sp)
  8004b8:	fe0d9ae3          	bnez	s11,8004ac <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004bc:	00064783          	lbu	a5,0(a2)
  8004c0:	0007851b          	sext.w	a0,a5
  8004c4:	ec0510e3          	bnez	a0,800384 <vprintfmt+0x1be>
  8004c8:	bb25                	j	800200 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
  8004ca:	000ae603          	lwu	a2,0(s5)
  8004ce:	46a1                	li	a3,8
  8004d0:	8aae                	mv	s5,a1
  8004d2:	bf0d                	j	800404 <vprintfmt+0x23e>
  8004d4:	000ae603          	lwu	a2,0(s5)
  8004d8:	46a9                	li	a3,10
  8004da:	8aae                	mv	s5,a1
  8004dc:	b725                	j	800404 <vprintfmt+0x23e>
        return va_arg(*ap, int);
  8004de:	000aa403          	lw	s0,0(s5)
  8004e2:	bd35                	j	80031e <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
  8004e4:	000ae603          	lwu	a2,0(s5)
  8004e8:	46c1                	li	a3,16
  8004ea:	8aae                	mv	s5,a1
  8004ec:	bf21                	j	800404 <vprintfmt+0x23e>
                    putch(ch, putdat);
  8004ee:	9902                	jalr	s2
  8004f0:	bd45                	j	8003a0 <vprintfmt+0x1da>
                putch('-', putdat);
  8004f2:	85a6                	mv	a1,s1
  8004f4:	02d00513          	li	a0,45
  8004f8:	e03e                	sd	a5,0(sp)
  8004fa:	9902                	jalr	s2
                num = -(long long)num;
  8004fc:	8ace                	mv	s5,s3
  8004fe:	40800633          	neg	a2,s0
  800502:	46a9                	li	a3,10
  800504:	6782                	ld	a5,0(sp)
  800506:	bdfd                	j	800404 <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
  800508:	01b05663          	blez	s11,800514 <vprintfmt+0x34e>
  80050c:	02d00693          	li	a3,45
  800510:	f6d798e3          	bne	a5,a3,800480 <vprintfmt+0x2ba>
  800514:	00000417          	auipc	s0,0x0
  800518:	45d40413          	addi	s0,s0,1117 # 800971 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80051c:	02800513          	li	a0,40
  800520:	02800793          	li	a5,40
  800524:	b585                	j	800384 <vprintfmt+0x1be>

0000000000800526 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800526:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800528:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80052c:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80052e:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800530:	ec06                	sd	ra,24(sp)
  800532:	f83a                	sd	a4,48(sp)
  800534:	fc3e                	sd	a5,56(sp)
  800536:	e0c2                	sd	a6,64(sp)
  800538:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  80053a:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80053c:	c8bff0ef          	jal	ra,8001c6 <vprintfmt>
}
  800540:	60e2                	ld	ra,24(sp)
  800542:	6161                	addi	sp,sp,80
  800544:	8082                	ret

0000000000800546 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  800546:	c185                	beqz	a1,800566 <strnlen+0x20>
  800548:	00054783          	lbu	a5,0(a0)
  80054c:	cf89                	beqz	a5,800566 <strnlen+0x20>
    size_t cnt = 0;
  80054e:	4781                	li	a5,0
  800550:	a021                	j	800558 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  800552:	00074703          	lbu	a4,0(a4)
  800556:	c711                	beqz	a4,800562 <strnlen+0x1c>
        cnt ++;
  800558:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  80055a:	00f50733          	add	a4,a0,a5
  80055e:	fef59ae3          	bne	a1,a5,800552 <strnlen+0xc>
    }
    return cnt;
}
  800562:	853e                	mv	a0,a5
  800564:	8082                	ret
    size_t cnt = 0;
  800566:	4781                	li	a5,0
}
  800568:	853e                	mv	a0,a5
  80056a:	8082                	ret

000000000080056c <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  80056c:	1141                	addi	sp,sp,-16
    int pid, ret;
    cprintf("I am the parent. Forking the child...\n");
  80056e:	00000517          	auipc	a0,0x0
  800572:	42250513          	addi	a0,a0,1058 # 800990 <error_string+0x1c0>
main(void) {
  800576:	e406                	sd	ra,8(sp)
  800578:	e022                	sd	s0,0(sp)
    cprintf("I am the parent. Forking the child...\n");
  80057a:	b27ff0ef          	jal	ra,8000a0 <cprintf>
    if ((pid = fork()) == 0) {
  80057e:	bc9ff0ef          	jal	ra,800146 <fork>
  800582:	e901                	bnez	a0,800592 <main+0x26>
        cprintf("I am the child. spinning ...\n");
  800584:	00000517          	auipc	a0,0x0
  800588:	43450513          	addi	a0,a0,1076 # 8009b8 <error_string+0x1e8>
  80058c:	b15ff0ef          	jal	ra,8000a0 <cprintf>
        while (1);
  800590:	a001                	j	800590 <main+0x24>
    }
    cprintf("I am the parent. Running the child...\n");
  800592:	842a                	mv	s0,a0
  800594:	00000517          	auipc	a0,0x0
  800598:	44450513          	addi	a0,a0,1092 # 8009d8 <error_string+0x208>
  80059c:	b05ff0ef          	jal	ra,8000a0 <cprintf>

    yield();
  8005a0:	babff0ef          	jal	ra,80014a <yield>
    yield();
  8005a4:	ba7ff0ef          	jal	ra,80014a <yield>
    yield();
  8005a8:	ba3ff0ef          	jal	ra,80014a <yield>

    cprintf("I am the parent.  Killing the child...\n");
  8005ac:	00000517          	auipc	a0,0x0
  8005b0:	45450513          	addi	a0,a0,1108 # 800a00 <error_string+0x230>
  8005b4:	aedff0ef          	jal	ra,8000a0 <cprintf>

    assert((ret = kill(pid)) == 0);
  8005b8:	8522                	mv	a0,s0
  8005ba:	b93ff0ef          	jal	ra,80014c <kill>
  8005be:	ed31                	bnez	a0,80061a <main+0xae>
    cprintf("kill returns %d\n", ret);
  8005c0:	4581                	li	a1,0
  8005c2:	00000517          	auipc	a0,0x0
  8005c6:	4a650513          	addi	a0,a0,1190 # 800a68 <error_string+0x298>
  8005ca:	ad7ff0ef          	jal	ra,8000a0 <cprintf>

    assert((ret = waitpid(pid, NULL)) == 0);
  8005ce:	4581                	li	a1,0
  8005d0:	8522                	mv	a0,s0
  8005d2:	b77ff0ef          	jal	ra,800148 <waitpid>
  8005d6:	e11d                	bnez	a0,8005fc <main+0x90>
    cprintf("wait returns %d\n", ret);
  8005d8:	4581                	li	a1,0
  8005da:	00000517          	auipc	a0,0x0
  8005de:	4c650513          	addi	a0,a0,1222 # 800aa0 <error_string+0x2d0>
  8005e2:	abfff0ef          	jal	ra,8000a0 <cprintf>

    cprintf("spin may pass.\n");
  8005e6:	00000517          	auipc	a0,0x0
  8005ea:	4d250513          	addi	a0,a0,1234 # 800ab8 <error_string+0x2e8>
  8005ee:	ab3ff0ef          	jal	ra,8000a0 <cprintf>
    return 0;
}
  8005f2:	60a2                	ld	ra,8(sp)
  8005f4:	6402                	ld	s0,0(sp)
  8005f6:	4501                	li	a0,0
  8005f8:	0141                	addi	sp,sp,16
  8005fa:	8082                	ret
    assert((ret = waitpid(pid, NULL)) == 0);
  8005fc:	00000697          	auipc	a3,0x0
  800600:	48468693          	addi	a3,a3,1156 # 800a80 <error_string+0x2b0>
  800604:	00000617          	auipc	a2,0x0
  800608:	43c60613          	addi	a2,a2,1084 # 800a40 <error_string+0x270>
  80060c:	45dd                	li	a1,23
  80060e:	00000517          	auipc	a0,0x0
  800612:	44a50513          	addi	a0,a0,1098 # 800a58 <error_string+0x288>
  800616:	a11ff0ef          	jal	ra,800026 <__panic>
    assert((ret = kill(pid)) == 0);
  80061a:	00000697          	auipc	a3,0x0
  80061e:	40e68693          	addi	a3,a3,1038 # 800a28 <error_string+0x258>
  800622:	00000617          	auipc	a2,0x0
  800626:	41e60613          	addi	a2,a2,1054 # 800a40 <error_string+0x270>
  80062a:	45d1                	li	a1,20
  80062c:	00000517          	auipc	a0,0x0
  800630:	42c50513          	addi	a0,a0,1068 # 800a58 <error_string+0x288>
  800634:	9f3ff0ef          	jal	ra,800026 <__panic>
