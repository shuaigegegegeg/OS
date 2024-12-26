
obj/__user_badarg.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	126000ef          	jal	ra,800146 <umain>
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
  800038:	61c50513          	addi	a0,a0,1564 # 800650 <main+0xec>
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
  800054:	00001517          	auipc	a0,0x1
  800058:	95450513          	addi	a0,a0,-1708 # 8009a8 <error_string+0x1c8>
  80005c:	044000ef          	jal	ra,8000a0 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800060:	5559                	li	a0,-10
  800062:	0c8000ef          	jal	ra,80012a <exit>

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
  80006e:	0b6000ef          	jal	ra,800124 <sys_putc>
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
  800094:	12a000ef          	jal	ra,8001be <vprintfmt>
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
  8000c8:	0f6000ef          	jal	ra,8001be <vprintfmt>
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

0000000000800124 <sys_putc>:
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  800124:	85aa                	mv	a1,a0
  800126:	4579                	li	a0,30
  800128:	b775                	j	8000d4 <syscall>

000000000080012a <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  80012a:	1141                	addi	sp,sp,-16
  80012c:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  80012e:	fe1ff0ef          	jal	ra,80010e <sys_exit>
    cprintf("BUG: exit failed.\n");
  800132:	00000517          	auipc	a0,0x0
  800136:	53e50513          	addi	a0,a0,1342 # 800670 <main+0x10c>
  80013a:	f67ff0ef          	jal	ra,8000a0 <cprintf>
    while (1);
  80013e:	a001                	j	80013e <exit+0x14>

0000000000800140 <fork>:
}

int
fork(void) {
    return sys_fork();
  800140:	bfd1                	j	800114 <sys_fork>

0000000000800142 <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  800142:	bfd9                	j	800118 <sys_wait>

0000000000800144 <yield>:
}

void
yield(void) {
    sys_yield();
  800144:	bff1                	j	800120 <sys_yield>

0000000000800146 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800146:	1141                	addi	sp,sp,-16
  800148:	e406                	sd	ra,8(sp)
    int ret = main();
  80014a:	41a000ef          	jal	ra,800564 <main>
    exit(ret);
  80014e:	fddff0ef          	jal	ra,80012a <exit>

0000000000800152 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800152:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800156:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800158:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80015c:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80015e:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800162:	f022                	sd	s0,32(sp)
  800164:	ec26                	sd	s1,24(sp)
  800166:	e84a                	sd	s2,16(sp)
  800168:	f406                	sd	ra,40(sp)
  80016a:	e44e                	sd	s3,8(sp)
  80016c:	84aa                	mv	s1,a0
  80016e:	892e                	mv	s2,a1
  800170:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800174:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800176:	03067e63          	bgeu	a2,a6,8001b2 <printnum+0x60>
  80017a:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80017c:	00805763          	blez	s0,80018a <printnum+0x38>
  800180:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800182:	85ca                	mv	a1,s2
  800184:	854e                	mv	a0,s3
  800186:	9482                	jalr	s1
        while (-- width > 0)
  800188:	fc65                	bnez	s0,800180 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  80018a:	1a02                	slli	s4,s4,0x20
  80018c:	020a5a13          	srli	s4,s4,0x20
  800190:	00000797          	auipc	a5,0x0
  800194:	71878793          	addi	a5,a5,1816 # 8008a8 <error_string+0xc8>
  800198:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  80019a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80019c:	000a4503          	lbu	a0,0(s4)
}
  8001a0:	70a2                	ld	ra,40(sp)
  8001a2:	69a2                	ld	s3,8(sp)
  8001a4:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001a6:	85ca                	mv	a1,s2
  8001a8:	8326                	mv	t1,s1
}
  8001aa:	6942                	ld	s2,16(sp)
  8001ac:	64e2                	ld	s1,24(sp)
  8001ae:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001b0:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001b2:	03065633          	divu	a2,a2,a6
  8001b6:	8722                	mv	a4,s0
  8001b8:	f9bff0ef          	jal	ra,800152 <printnum>
  8001bc:	b7f9                	j	80018a <printnum+0x38>

00000000008001be <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001be:	7119                	addi	sp,sp,-128
  8001c0:	f4a6                	sd	s1,104(sp)
  8001c2:	f0ca                	sd	s2,96(sp)
  8001c4:	e8d2                	sd	s4,80(sp)
  8001c6:	e4d6                	sd	s5,72(sp)
  8001c8:	e0da                	sd	s6,64(sp)
  8001ca:	fc5e                	sd	s7,56(sp)
  8001cc:	f862                	sd	s8,48(sp)
  8001ce:	f06a                	sd	s10,32(sp)
  8001d0:	fc86                	sd	ra,120(sp)
  8001d2:	f8a2                	sd	s0,112(sp)
  8001d4:	ecce                	sd	s3,88(sp)
  8001d6:	f466                	sd	s9,40(sp)
  8001d8:	ec6e                	sd	s11,24(sp)
  8001da:	892a                	mv	s2,a0
  8001dc:	84ae                	mv	s1,a1
  8001de:	8d32                	mv	s10,a2
  8001e0:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001e2:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001e4:	00000a17          	auipc	s4,0x0
  8001e8:	4a0a0a13          	addi	s4,s4,1184 # 800684 <main+0x120>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  8001ec:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001f0:	00000c17          	auipc	s8,0x0
  8001f4:	5f0c0c13          	addi	s8,s8,1520 # 8007e0 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001f8:	000d4503          	lbu	a0,0(s10)
  8001fc:	02500793          	li	a5,37
  800200:	001d0413          	addi	s0,s10,1
  800204:	00f50e63          	beq	a0,a5,800220 <vprintfmt+0x62>
            if (ch == '\0') {
  800208:	c521                	beqz	a0,800250 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80020a:	02500993          	li	s3,37
  80020e:	a011                	j	800212 <vprintfmt+0x54>
            if (ch == '\0') {
  800210:	c121                	beqz	a0,800250 <vprintfmt+0x92>
            putch(ch, putdat);
  800212:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800214:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800216:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800218:	fff44503          	lbu	a0,-1(s0)
  80021c:	ff351ae3          	bne	a0,s3,800210 <vprintfmt+0x52>
  800220:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800224:	02000793          	li	a5,32
        lflag = altflag = 0;
  800228:	4981                	li	s3,0
  80022a:	4801                	li	a6,0
        width = precision = -1;
  80022c:	5cfd                	li	s9,-1
  80022e:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  800230:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  800234:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  800236:	fdd6069b          	addiw	a3,a2,-35
  80023a:	0ff6f693          	andi	a3,a3,255
  80023e:	00140d13          	addi	s10,s0,1
  800242:	1ed5ef63          	bltu	a1,a3,800440 <vprintfmt+0x282>
  800246:	068a                	slli	a3,a3,0x2
  800248:	96d2                	add	a3,a3,s4
  80024a:	4294                	lw	a3,0(a3)
  80024c:	96d2                	add	a3,a3,s4
  80024e:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800250:	70e6                	ld	ra,120(sp)
  800252:	7446                	ld	s0,112(sp)
  800254:	74a6                	ld	s1,104(sp)
  800256:	7906                	ld	s2,96(sp)
  800258:	69e6                	ld	s3,88(sp)
  80025a:	6a46                	ld	s4,80(sp)
  80025c:	6aa6                	ld	s5,72(sp)
  80025e:	6b06                	ld	s6,64(sp)
  800260:	7be2                	ld	s7,56(sp)
  800262:	7c42                	ld	s8,48(sp)
  800264:	7ca2                	ld	s9,40(sp)
  800266:	7d02                	ld	s10,32(sp)
  800268:	6de2                	ld	s11,24(sp)
  80026a:	6109                	addi	sp,sp,128
  80026c:	8082                	ret
            padc = '-';
  80026e:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
  800270:	00144603          	lbu	a2,1(s0)
  800274:	846a                	mv	s0,s10
  800276:	b7c1                	j	800236 <vprintfmt+0x78>
            precision = va_arg(ap, int);
  800278:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  80027c:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800280:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  800282:	846a                	mv	s0,s10
            if (width < 0)
  800284:	fa0dd9e3          	bgez	s11,800236 <vprintfmt+0x78>
                width = precision, precision = -1;
  800288:	8de6                	mv	s11,s9
  80028a:	5cfd                	li	s9,-1
  80028c:	b76d                	j	800236 <vprintfmt+0x78>
            if (width < 0)
  80028e:	fffdc693          	not	a3,s11
  800292:	96fd                	srai	a3,a3,0x3f
  800294:	00ddfdb3          	and	s11,s11,a3
  800298:	00144603          	lbu	a2,1(s0)
  80029c:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  80029e:	846a                	mv	s0,s10
  8002a0:	bf59                	j	800236 <vprintfmt+0x78>
    if (lflag >= 2) {
  8002a2:	4705                	li	a4,1
  8002a4:	008a8593          	addi	a1,s5,8
  8002a8:	01074463          	blt	a4,a6,8002b0 <vprintfmt+0xf2>
    else if (lflag) {
  8002ac:	22080863          	beqz	a6,8004dc <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
  8002b0:	000ab603          	ld	a2,0(s5)
  8002b4:	46c1                	li	a3,16
  8002b6:	8aae                	mv	s5,a1
  8002b8:	a291                	j	8003fc <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
  8002ba:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  8002be:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8002c2:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8002c4:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8002c8:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8002cc:	fad56ce3          	bltu	a0,a3,800284 <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
  8002d0:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002d2:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  8002d6:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  8002da:	0196873b          	addw	a4,a3,s9
  8002de:	0017171b          	slliw	a4,a4,0x1
  8002e2:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  8002e6:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  8002ea:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002ee:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8002f2:	fcd57fe3          	bgeu	a0,a3,8002d0 <vprintfmt+0x112>
  8002f6:	b779                	j	800284 <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
  8002f8:	000aa503          	lw	a0,0(s5)
  8002fc:	85a6                	mv	a1,s1
  8002fe:	0aa1                	addi	s5,s5,8
  800300:	9902                	jalr	s2
            break;
  800302:	bddd                	j	8001f8 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800304:	4705                	li	a4,1
  800306:	008a8993          	addi	s3,s5,8
  80030a:	01074463          	blt	a4,a6,800312 <vprintfmt+0x154>
    else if (lflag) {
  80030e:	1c080463          	beqz	a6,8004d6 <vprintfmt+0x318>
        return va_arg(*ap, long);
  800312:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  800316:	1c044a63          	bltz	s0,8004ea <vprintfmt+0x32c>
            num = getint(&ap, lflag);
  80031a:	8622                	mv	a2,s0
  80031c:	8ace                	mv	s5,s3
  80031e:	46a9                	li	a3,10
  800320:	a8f1                	j	8003fc <vprintfmt+0x23e>
            err = va_arg(ap, int);
  800322:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800326:	4761                	li	a4,24
            err = va_arg(ap, int);
  800328:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  80032a:	41f7d69b          	sraiw	a3,a5,0x1f
  80032e:	8fb5                	xor	a5,a5,a3
  800330:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800334:	12d74963          	blt	a4,a3,800466 <vprintfmt+0x2a8>
  800338:	00369793          	slli	a5,a3,0x3
  80033c:	97e2                	add	a5,a5,s8
  80033e:	639c                	ld	a5,0(a5)
  800340:	12078363          	beqz	a5,800466 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
  800344:	86be                	mv	a3,a5
  800346:	00000617          	auipc	a2,0x0
  80034a:	65260613          	addi	a2,a2,1618 # 800998 <error_string+0x1b8>
  80034e:	85a6                	mv	a1,s1
  800350:	854a                	mv	a0,s2
  800352:	1cc000ef          	jal	ra,80051e <printfmt>
  800356:	b54d                	j	8001f8 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  800358:	000ab603          	ld	a2,0(s5)
  80035c:	0aa1                	addi	s5,s5,8
  80035e:	1a060163          	beqz	a2,800500 <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
  800362:	00160413          	addi	s0,a2,1
  800366:	15b05763          	blez	s11,8004b4 <vprintfmt+0x2f6>
  80036a:	02d00593          	li	a1,45
  80036e:	10b79d63          	bne	a5,a1,800488 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800372:	00064783          	lbu	a5,0(a2)
  800376:	0007851b          	sext.w	a0,a5
  80037a:	c905                	beqz	a0,8003aa <vprintfmt+0x1ec>
  80037c:	000cc563          	bltz	s9,800386 <vprintfmt+0x1c8>
  800380:	3cfd                	addiw	s9,s9,-1
  800382:	036c8263          	beq	s9,s6,8003a6 <vprintfmt+0x1e8>
                    putch('?', putdat);
  800386:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800388:	14098f63          	beqz	s3,8004e6 <vprintfmt+0x328>
  80038c:	3781                	addiw	a5,a5,-32
  80038e:	14fbfc63          	bgeu	s7,a5,8004e6 <vprintfmt+0x328>
                    putch('?', putdat);
  800392:	03f00513          	li	a0,63
  800396:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800398:	0405                	addi	s0,s0,1
  80039a:	fff44783          	lbu	a5,-1(s0)
  80039e:	3dfd                	addiw	s11,s11,-1
  8003a0:	0007851b          	sext.w	a0,a5
  8003a4:	fd61                	bnez	a0,80037c <vprintfmt+0x1be>
            for (; width > 0; width --) {
  8003a6:	e5b059e3          	blez	s11,8001f8 <vprintfmt+0x3a>
  8003aa:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003ac:	85a6                	mv	a1,s1
  8003ae:	02000513          	li	a0,32
  8003b2:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003b4:	e40d82e3          	beqz	s11,8001f8 <vprintfmt+0x3a>
  8003b8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003ba:	85a6                	mv	a1,s1
  8003bc:	02000513          	li	a0,32
  8003c0:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003c2:	fe0d94e3          	bnez	s11,8003aa <vprintfmt+0x1ec>
  8003c6:	bd0d                	j	8001f8 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003c8:	4705                	li	a4,1
  8003ca:	008a8593          	addi	a1,s5,8
  8003ce:	01074463          	blt	a4,a6,8003d6 <vprintfmt+0x218>
    else if (lflag) {
  8003d2:	0e080863          	beqz	a6,8004c2 <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
  8003d6:	000ab603          	ld	a2,0(s5)
  8003da:	46a1                	li	a3,8
  8003dc:	8aae                	mv	s5,a1
  8003de:	a839                	j	8003fc <vprintfmt+0x23e>
            putch('0', putdat);
  8003e0:	03000513          	li	a0,48
  8003e4:	85a6                	mv	a1,s1
  8003e6:	e03e                	sd	a5,0(sp)
  8003e8:	9902                	jalr	s2
            putch('x', putdat);
  8003ea:	85a6                	mv	a1,s1
  8003ec:	07800513          	li	a0,120
  8003f0:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8003f2:	0aa1                	addi	s5,s5,8
  8003f4:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  8003f8:	6782                	ld	a5,0(sp)
  8003fa:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  8003fc:	2781                	sext.w	a5,a5
  8003fe:	876e                	mv	a4,s11
  800400:	85a6                	mv	a1,s1
  800402:	854a                	mv	a0,s2
  800404:	d4fff0ef          	jal	ra,800152 <printnum>
            break;
  800408:	bbc5                	j	8001f8 <vprintfmt+0x3a>
            lflag ++;
  80040a:	00144603          	lbu	a2,1(s0)
  80040e:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  800410:	846a                	mv	s0,s10
            goto reswitch;
  800412:	b515                	j	800236 <vprintfmt+0x78>
            goto reswitch;
  800414:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800418:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  80041a:	846a                	mv	s0,s10
            goto reswitch;
  80041c:	bd29                	j	800236 <vprintfmt+0x78>
            putch(ch, putdat);
  80041e:	85a6                	mv	a1,s1
  800420:	02500513          	li	a0,37
  800424:	9902                	jalr	s2
            break;
  800426:	bbc9                	j	8001f8 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800428:	4705                	li	a4,1
  80042a:	008a8593          	addi	a1,s5,8
  80042e:	01074463          	blt	a4,a6,800436 <vprintfmt+0x278>
    else if (lflag) {
  800432:	08080d63          	beqz	a6,8004cc <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
  800436:	000ab603          	ld	a2,0(s5)
  80043a:	46a9                	li	a3,10
  80043c:	8aae                	mv	s5,a1
  80043e:	bf7d                	j	8003fc <vprintfmt+0x23e>
            putch('%', putdat);
  800440:	85a6                	mv	a1,s1
  800442:	02500513          	li	a0,37
  800446:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800448:	fff44703          	lbu	a4,-1(s0)
  80044c:	02500793          	li	a5,37
  800450:	8d22                	mv	s10,s0
  800452:	daf703e3          	beq	a4,a5,8001f8 <vprintfmt+0x3a>
  800456:	02500713          	li	a4,37
  80045a:	1d7d                	addi	s10,s10,-1
  80045c:	fffd4783          	lbu	a5,-1(s10)
  800460:	fee79de3          	bne	a5,a4,80045a <vprintfmt+0x29c>
  800464:	bb51                	j	8001f8 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800466:	00000617          	auipc	a2,0x0
  80046a:	52260613          	addi	a2,a2,1314 # 800988 <error_string+0x1a8>
  80046e:	85a6                	mv	a1,s1
  800470:	854a                	mv	a0,s2
  800472:	0ac000ef          	jal	ra,80051e <printfmt>
  800476:	b349                	j	8001f8 <vprintfmt+0x3a>
                p = "(null)";
  800478:	00000617          	auipc	a2,0x0
  80047c:	50860613          	addi	a2,a2,1288 # 800980 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  800480:	00000417          	auipc	s0,0x0
  800484:	50140413          	addi	s0,s0,1281 # 800981 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800488:	8532                	mv	a0,a2
  80048a:	85e6                	mv	a1,s9
  80048c:	e032                	sd	a2,0(sp)
  80048e:	e43e                	sd	a5,8(sp)
  800490:	0ae000ef          	jal	ra,80053e <strnlen>
  800494:	40ad8dbb          	subw	s11,s11,a0
  800498:	6602                	ld	a2,0(sp)
  80049a:	01b05d63          	blez	s11,8004b4 <vprintfmt+0x2f6>
  80049e:	67a2                	ld	a5,8(sp)
  8004a0:	2781                	sext.w	a5,a5
  8004a2:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004a4:	6522                	ld	a0,8(sp)
  8004a6:	85a6                	mv	a1,s1
  8004a8:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004aa:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004ac:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ae:	6602                	ld	a2,0(sp)
  8004b0:	fe0d9ae3          	bnez	s11,8004a4 <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004b4:	00064783          	lbu	a5,0(a2)
  8004b8:	0007851b          	sext.w	a0,a5
  8004bc:	ec0510e3          	bnez	a0,80037c <vprintfmt+0x1be>
  8004c0:	bb25                	j	8001f8 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
  8004c2:	000ae603          	lwu	a2,0(s5)
  8004c6:	46a1                	li	a3,8
  8004c8:	8aae                	mv	s5,a1
  8004ca:	bf0d                	j	8003fc <vprintfmt+0x23e>
  8004cc:	000ae603          	lwu	a2,0(s5)
  8004d0:	46a9                	li	a3,10
  8004d2:	8aae                	mv	s5,a1
  8004d4:	b725                	j	8003fc <vprintfmt+0x23e>
        return va_arg(*ap, int);
  8004d6:	000aa403          	lw	s0,0(s5)
  8004da:	bd35                	j	800316 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
  8004dc:	000ae603          	lwu	a2,0(s5)
  8004e0:	46c1                	li	a3,16
  8004e2:	8aae                	mv	s5,a1
  8004e4:	bf21                	j	8003fc <vprintfmt+0x23e>
                    putch(ch, putdat);
  8004e6:	9902                	jalr	s2
  8004e8:	bd45                	j	800398 <vprintfmt+0x1da>
                putch('-', putdat);
  8004ea:	85a6                	mv	a1,s1
  8004ec:	02d00513          	li	a0,45
  8004f0:	e03e                	sd	a5,0(sp)
  8004f2:	9902                	jalr	s2
                num = -(long long)num;
  8004f4:	8ace                	mv	s5,s3
  8004f6:	40800633          	neg	a2,s0
  8004fa:	46a9                	li	a3,10
  8004fc:	6782                	ld	a5,0(sp)
  8004fe:	bdfd                	j	8003fc <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
  800500:	01b05663          	blez	s11,80050c <vprintfmt+0x34e>
  800504:	02d00693          	li	a3,45
  800508:	f6d798e3          	bne	a5,a3,800478 <vprintfmt+0x2ba>
  80050c:	00000417          	auipc	s0,0x0
  800510:	47540413          	addi	s0,s0,1141 # 800981 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800514:	02800513          	li	a0,40
  800518:	02800793          	li	a5,40
  80051c:	b585                	j	80037c <vprintfmt+0x1be>

000000000080051e <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80051e:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800520:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800524:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800526:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800528:	ec06                	sd	ra,24(sp)
  80052a:	f83a                	sd	a4,48(sp)
  80052c:	fc3e                	sd	a5,56(sp)
  80052e:	e0c2                	sd	a6,64(sp)
  800530:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800532:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800534:	c8bff0ef          	jal	ra,8001be <vprintfmt>
}
  800538:	60e2                	ld	ra,24(sp)
  80053a:	6161                	addi	sp,sp,80
  80053c:	8082                	ret

000000000080053e <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  80053e:	c185                	beqz	a1,80055e <strnlen+0x20>
  800540:	00054783          	lbu	a5,0(a0)
  800544:	cf89                	beqz	a5,80055e <strnlen+0x20>
    size_t cnt = 0;
  800546:	4781                	li	a5,0
  800548:	a021                	j	800550 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  80054a:	00074703          	lbu	a4,0(a4)
  80054e:	c711                	beqz	a4,80055a <strnlen+0x1c>
        cnt ++;
  800550:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800552:	00f50733          	add	a4,a0,a5
  800556:	fef59ae3          	bne	a1,a5,80054a <strnlen+0xc>
    }
    return cnt;
}
  80055a:	853e                	mv	a0,a5
  80055c:	8082                	ret
    size_t cnt = 0;
  80055e:	4781                	li	a5,0
}
  800560:	853e                	mv	a0,a5
  800562:	8082                	ret

0000000000800564 <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  800564:	1101                	addi	sp,sp,-32
  800566:	ec06                	sd	ra,24(sp)
  800568:	e822                	sd	s0,16(sp)
    int pid, exit_code;
    if ((pid = fork()) == 0) {
  80056a:	bd7ff0ef          	jal	ra,800140 <fork>
  80056e:	c169                	beqz	a0,800630 <main+0xcc>
  800570:	842a                	mv	s0,a0
        for (i = 0; i < 10; i ++) {
            yield();
        }
        exit(0xbeaf);
    }
    assert(pid > 0);
  800572:	0aa05063          	blez	a0,800612 <main+0xae>
    assert(waitpid(-1, NULL) != 0);
  800576:	4581                	li	a1,0
  800578:	557d                	li	a0,-1
  80057a:	bc9ff0ef          	jal	ra,800142 <waitpid>
  80057e:	c93d                	beqz	a0,8005f4 <main+0x90>
    assert(waitpid(pid, (void *)0xC0000000) != 0);
  800580:	458d                	li	a1,3
  800582:	05fa                	slli	a1,a1,0x1e
  800584:	8522                	mv	a0,s0
  800586:	bbdff0ef          	jal	ra,800142 <waitpid>
  80058a:	c531                	beqz	a0,8005d6 <main+0x72>
    assert(waitpid(pid, &exit_code) == 0 && exit_code == 0xbeaf);
  80058c:	006c                	addi	a1,sp,12
  80058e:	8522                	mv	a0,s0
  800590:	bb3ff0ef          	jal	ra,800142 <waitpid>
  800594:	e115                	bnez	a0,8005b8 <main+0x54>
  800596:	4732                	lw	a4,12(sp)
  800598:	67b1                	lui	a5,0xc
  80059a:	eaf78793          	addi	a5,a5,-337 # beaf <_start-0x7f4171>
  80059e:	00f71d63          	bne	a4,a5,8005b8 <main+0x54>
    cprintf("badarg pass.\n");
  8005a2:	00000517          	auipc	a0,0x0
  8005a6:	4b650513          	addi	a0,a0,1206 # 800a58 <error_string+0x278>
  8005aa:	af7ff0ef          	jal	ra,8000a0 <cprintf>
    return 0;
}
  8005ae:	60e2                	ld	ra,24(sp)
  8005b0:	6442                	ld	s0,16(sp)
  8005b2:	4501                	li	a0,0
  8005b4:	6105                	addi	sp,sp,32
  8005b6:	8082                	ret
    assert(waitpid(pid, &exit_code) == 0 && exit_code == 0xbeaf);
  8005b8:	00000697          	auipc	a3,0x0
  8005bc:	46868693          	addi	a3,a3,1128 # 800a20 <error_string+0x240>
  8005c0:	00000617          	auipc	a2,0x0
  8005c4:	3f860613          	addi	a2,a2,1016 # 8009b8 <error_string+0x1d8>
  8005c8:	45c9                	li	a1,18
  8005ca:	00000517          	auipc	a0,0x0
  8005ce:	40650513          	addi	a0,a0,1030 # 8009d0 <error_string+0x1f0>
  8005d2:	a55ff0ef          	jal	ra,800026 <__panic>
    assert(waitpid(pid, (void *)0xC0000000) != 0);
  8005d6:	00000697          	auipc	a3,0x0
  8005da:	42268693          	addi	a3,a3,1058 # 8009f8 <error_string+0x218>
  8005de:	00000617          	auipc	a2,0x0
  8005e2:	3da60613          	addi	a2,a2,986 # 8009b8 <error_string+0x1d8>
  8005e6:	45c5                	li	a1,17
  8005e8:	00000517          	auipc	a0,0x0
  8005ec:	3e850513          	addi	a0,a0,1000 # 8009d0 <error_string+0x1f0>
  8005f0:	a37ff0ef          	jal	ra,800026 <__panic>
    assert(waitpid(-1, NULL) != 0);
  8005f4:	00000697          	auipc	a3,0x0
  8005f8:	3ec68693          	addi	a3,a3,1004 # 8009e0 <error_string+0x200>
  8005fc:	00000617          	auipc	a2,0x0
  800600:	3bc60613          	addi	a2,a2,956 # 8009b8 <error_string+0x1d8>
  800604:	45c1                	li	a1,16
  800606:	00000517          	auipc	a0,0x0
  80060a:	3ca50513          	addi	a0,a0,970 # 8009d0 <error_string+0x1f0>
  80060e:	a19ff0ef          	jal	ra,800026 <__panic>
    assert(pid > 0);
  800612:	00000697          	auipc	a3,0x0
  800616:	39e68693          	addi	a3,a3,926 # 8009b0 <error_string+0x1d0>
  80061a:	00000617          	auipc	a2,0x0
  80061e:	39e60613          	addi	a2,a2,926 # 8009b8 <error_string+0x1d8>
  800622:	45bd                	li	a1,15
  800624:	00000517          	auipc	a0,0x0
  800628:	3ac50513          	addi	a0,a0,940 # 8009d0 <error_string+0x1f0>
  80062c:	9fbff0ef          	jal	ra,800026 <__panic>
        cprintf("fork ok.\n");
  800630:	00000517          	auipc	a0,0x0
  800634:	37050513          	addi	a0,a0,880 # 8009a0 <error_string+0x1c0>
  800638:	a69ff0ef          	jal	ra,8000a0 <cprintf>
  80063c:	4429                	li	s0,10
            yield();
  80063e:	347d                	addiw	s0,s0,-1
  800640:	b05ff0ef          	jal	ra,800144 <yield>
        for (i = 0; i < 10; i ++) {
  800644:	fc6d                	bnez	s0,80063e <main+0xda>
        exit(0xbeaf);
  800646:	6531                	lui	a0,0xc
  800648:	eaf50513          	addi	a0,a0,-337 # beaf <_start-0x7f4171>
  80064c:	adfff0ef          	jal	ra,80012a <exit>
