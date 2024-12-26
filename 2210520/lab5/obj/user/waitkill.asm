
obj/__user_waitkill.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	134000ef          	jal	ra,800154 <umain>
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
  800038:	67c50513          	addi	a0,a0,1660 # 8006b0 <main+0xb2>
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
  800058:	9b450513          	addi	a0,a0,-1612 # 800a08 <error_string+0x1c8>
  80005c:	044000ef          	jal	ra,8000a0 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800060:	5559                	li	a0,-10
  800062:	0d2000ef          	jal	ra,800134 <exit>

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
  80006e:	0c0000ef          	jal	ra,80012e <sys_putc>
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
  800094:	138000ef          	jal	ra,8001cc <vprintfmt>
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
  8000c8:	104000ef          	jal	ra,8001cc <vprintfmt>
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

000000000080012a <sys_getpid>:
}

int
sys_getpid(void) {
    return syscall(SYS_getpid);
  80012a:	4549                	li	a0,18
  80012c:	b765                	j	8000d4 <syscall>

000000000080012e <sys_putc>:
}

int
sys_putc(int64_t c) {
    return syscall(SYS_putc, c);
  80012e:	85aa                	mv	a1,a0
  800130:	4579                	li	a0,30
  800132:	b74d                	j	8000d4 <syscall>

0000000000800134 <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  800134:	1141                	addi	sp,sp,-16
  800136:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  800138:	fd7ff0ef          	jal	ra,80010e <sys_exit>
    cprintf("BUG: exit failed.\n");
  80013c:	00000517          	auipc	a0,0x0
  800140:	59450513          	addi	a0,a0,1428 # 8006d0 <main+0xd2>
  800144:	f5dff0ef          	jal	ra,8000a0 <cprintf>
    while (1);
  800148:	a001                	j	800148 <exit+0x14>

000000000080014a <fork>:
}

int
fork(void) {
    return sys_fork();
  80014a:	b7e9                	j	800114 <sys_fork>

000000000080014c <waitpid>:
    return sys_wait(0, NULL);
}

int
waitpid(int pid, int *store) {
    return sys_wait(pid, store);
  80014c:	b7f1                	j	800118 <sys_wait>

000000000080014e <yield>:
}

void
yield(void) {
    sys_yield();
  80014e:	bfc9                	j	800120 <sys_yield>

0000000000800150 <kill>:
}

int
kill(int pid) {
    return sys_kill(pid);
  800150:	bfd1                	j	800124 <sys_kill>

0000000000800152 <getpid>:
}

int
getpid(void) {
    return sys_getpid();
  800152:	bfe1                	j	80012a <sys_getpid>

0000000000800154 <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  800154:	1141                	addi	sp,sp,-16
  800156:	e406                	sd	ra,8(sp)
    int ret = main();
  800158:	4a6000ef          	jal	ra,8005fe <main>
    exit(ret);
  80015c:	fd9ff0ef          	jal	ra,800134 <exit>

0000000000800160 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800160:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800164:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  800166:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80016a:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  80016c:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800170:	f022                	sd	s0,32(sp)
  800172:	ec26                	sd	s1,24(sp)
  800174:	e84a                	sd	s2,16(sp)
  800176:	f406                	sd	ra,40(sp)
  800178:	e44e                	sd	s3,8(sp)
  80017a:	84aa                	mv	s1,a0
  80017c:	892e                	mv	s2,a1
  80017e:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  800182:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  800184:	03067e63          	bgeu	a2,a6,8001c0 <printnum+0x60>
  800188:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80018a:	00805763          	blez	s0,800198 <printnum+0x38>
  80018e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800190:	85ca                	mv	a1,s2
  800192:	854e                	mv	a0,s3
  800194:	9482                	jalr	s1
        while (-- width > 0)
  800196:	fc65                	bnez	s0,80018e <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800198:	1a02                	slli	s4,s4,0x20
  80019a:	020a5a13          	srli	s4,s4,0x20
  80019e:	00000797          	auipc	a5,0x0
  8001a2:	76a78793          	addi	a5,a5,1898 # 800908 <error_string+0xc8>
  8001a6:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001a8:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001aa:	000a4503          	lbu	a0,0(s4)
}
  8001ae:	70a2                	ld	ra,40(sp)
  8001b0:	69a2                	ld	s3,8(sp)
  8001b2:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001b4:	85ca                	mv	a1,s2
  8001b6:	8326                	mv	t1,s1
}
  8001b8:	6942                	ld	s2,16(sp)
  8001ba:	64e2                	ld	s1,24(sp)
  8001bc:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001be:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001c0:	03065633          	divu	a2,a2,a6
  8001c4:	8722                	mv	a4,s0
  8001c6:	f9bff0ef          	jal	ra,800160 <printnum>
  8001ca:	b7f9                	j	800198 <printnum+0x38>

00000000008001cc <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001cc:	7119                	addi	sp,sp,-128
  8001ce:	f4a6                	sd	s1,104(sp)
  8001d0:	f0ca                	sd	s2,96(sp)
  8001d2:	e8d2                	sd	s4,80(sp)
  8001d4:	e4d6                	sd	s5,72(sp)
  8001d6:	e0da                	sd	s6,64(sp)
  8001d8:	fc5e                	sd	s7,56(sp)
  8001da:	f862                	sd	s8,48(sp)
  8001dc:	f06a                	sd	s10,32(sp)
  8001de:	fc86                	sd	ra,120(sp)
  8001e0:	f8a2                	sd	s0,112(sp)
  8001e2:	ecce                	sd	s3,88(sp)
  8001e4:	f466                	sd	s9,40(sp)
  8001e6:	ec6e                	sd	s11,24(sp)
  8001e8:	892a                	mv	s2,a0
  8001ea:	84ae                	mv	s1,a1
  8001ec:	8d32                	mv	s10,a2
  8001ee:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001f0:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001f2:	00000a17          	auipc	s4,0x0
  8001f6:	4f2a0a13          	addi	s4,s4,1266 # 8006e4 <main+0xe6>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  8001fa:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001fe:	00000c17          	auipc	s8,0x0
  800202:	642c0c13          	addi	s8,s8,1602 # 800840 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800206:	000d4503          	lbu	a0,0(s10)
  80020a:	02500793          	li	a5,37
  80020e:	001d0413          	addi	s0,s10,1
  800212:	00f50e63          	beq	a0,a5,80022e <vprintfmt+0x62>
            if (ch == '\0') {
  800216:	c521                	beqz	a0,80025e <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800218:	02500993          	li	s3,37
  80021c:	a011                	j	800220 <vprintfmt+0x54>
            if (ch == '\0') {
  80021e:	c121                	beqz	a0,80025e <vprintfmt+0x92>
            putch(ch, putdat);
  800220:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800222:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  800224:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800226:	fff44503          	lbu	a0,-1(s0)
  80022a:	ff351ae3          	bne	a0,s3,80021e <vprintfmt+0x52>
  80022e:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  800232:	02000793          	li	a5,32
        lflag = altflag = 0;
  800236:	4981                	li	s3,0
  800238:	4801                	li	a6,0
        width = precision = -1;
  80023a:	5cfd                	li	s9,-1
  80023c:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  80023e:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  800242:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  800244:	fdd6069b          	addiw	a3,a2,-35
  800248:	0ff6f693          	andi	a3,a3,255
  80024c:	00140d13          	addi	s10,s0,1
  800250:	1ed5ef63          	bltu	a1,a3,80044e <vprintfmt+0x282>
  800254:	068a                	slli	a3,a3,0x2
  800256:	96d2                	add	a3,a3,s4
  800258:	4294                	lw	a3,0(a3)
  80025a:	96d2                	add	a3,a3,s4
  80025c:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  80025e:	70e6                	ld	ra,120(sp)
  800260:	7446                	ld	s0,112(sp)
  800262:	74a6                	ld	s1,104(sp)
  800264:	7906                	ld	s2,96(sp)
  800266:	69e6                	ld	s3,88(sp)
  800268:	6a46                	ld	s4,80(sp)
  80026a:	6aa6                	ld	s5,72(sp)
  80026c:	6b06                	ld	s6,64(sp)
  80026e:	7be2                	ld	s7,56(sp)
  800270:	7c42                	ld	s8,48(sp)
  800272:	7ca2                	ld	s9,40(sp)
  800274:	7d02                	ld	s10,32(sp)
  800276:	6de2                	ld	s11,24(sp)
  800278:	6109                	addi	sp,sp,128
  80027a:	8082                	ret
            padc = '-';
  80027c:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
  80027e:	00144603          	lbu	a2,1(s0)
  800282:	846a                	mv	s0,s10
  800284:	b7c1                	j	800244 <vprintfmt+0x78>
            precision = va_arg(ap, int);
  800286:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  80028a:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  80028e:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  800290:	846a                	mv	s0,s10
            if (width < 0)
  800292:	fa0dd9e3          	bgez	s11,800244 <vprintfmt+0x78>
                width = precision, precision = -1;
  800296:	8de6                	mv	s11,s9
  800298:	5cfd                	li	s9,-1
  80029a:	b76d                	j	800244 <vprintfmt+0x78>
            if (width < 0)
  80029c:	fffdc693          	not	a3,s11
  8002a0:	96fd                	srai	a3,a3,0x3f
  8002a2:	00ddfdb3          	and	s11,s11,a3
  8002a6:	00144603          	lbu	a2,1(s0)
  8002aa:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  8002ac:	846a                	mv	s0,s10
  8002ae:	bf59                	j	800244 <vprintfmt+0x78>
    if (lflag >= 2) {
  8002b0:	4705                	li	a4,1
  8002b2:	008a8593          	addi	a1,s5,8
  8002b6:	01074463          	blt	a4,a6,8002be <vprintfmt+0xf2>
    else if (lflag) {
  8002ba:	22080863          	beqz	a6,8004ea <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
  8002be:	000ab603          	ld	a2,0(s5)
  8002c2:	46c1                	li	a3,16
  8002c4:	8aae                	mv	s5,a1
  8002c6:	a291                	j	80040a <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
  8002c8:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  8002cc:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8002d0:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8002d2:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8002d6:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8002da:	fad56ce3          	bltu	a0,a3,800292 <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
  8002de:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002e0:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  8002e4:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  8002e8:	0196873b          	addw	a4,a3,s9
  8002ec:	0017171b          	slliw	a4,a4,0x1
  8002f0:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  8002f4:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  8002f8:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002fc:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  800300:	fcd57fe3          	bgeu	a0,a3,8002de <vprintfmt+0x112>
  800304:	b779                	j	800292 <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
  800306:	000aa503          	lw	a0,0(s5)
  80030a:	85a6                	mv	a1,s1
  80030c:	0aa1                	addi	s5,s5,8
  80030e:	9902                	jalr	s2
            break;
  800310:	bddd                	j	800206 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800312:	4705                	li	a4,1
  800314:	008a8993          	addi	s3,s5,8
  800318:	01074463          	blt	a4,a6,800320 <vprintfmt+0x154>
    else if (lflag) {
  80031c:	1c080463          	beqz	a6,8004e4 <vprintfmt+0x318>
        return va_arg(*ap, long);
  800320:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  800324:	1c044a63          	bltz	s0,8004f8 <vprintfmt+0x32c>
            num = getint(&ap, lflag);
  800328:	8622                	mv	a2,s0
  80032a:	8ace                	mv	s5,s3
  80032c:	46a9                	li	a3,10
  80032e:	a8f1                	j	80040a <vprintfmt+0x23e>
            err = va_arg(ap, int);
  800330:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800334:	4761                	li	a4,24
            err = va_arg(ap, int);
  800336:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  800338:	41f7d69b          	sraiw	a3,a5,0x1f
  80033c:	8fb5                	xor	a5,a5,a3
  80033e:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800342:	12d74963          	blt	a4,a3,800474 <vprintfmt+0x2a8>
  800346:	00369793          	slli	a5,a3,0x3
  80034a:	97e2                	add	a5,a5,s8
  80034c:	639c                	ld	a5,0(a5)
  80034e:	12078363          	beqz	a5,800474 <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
  800352:	86be                	mv	a3,a5
  800354:	00000617          	auipc	a2,0x0
  800358:	6a460613          	addi	a2,a2,1700 # 8009f8 <error_string+0x1b8>
  80035c:	85a6                	mv	a1,s1
  80035e:	854a                	mv	a0,s2
  800360:	1cc000ef          	jal	ra,80052c <printfmt>
  800364:	b54d                	j	800206 <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  800366:	000ab603          	ld	a2,0(s5)
  80036a:	0aa1                	addi	s5,s5,8
  80036c:	1a060163          	beqz	a2,80050e <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
  800370:	00160413          	addi	s0,a2,1
  800374:	15b05763          	blez	s11,8004c2 <vprintfmt+0x2f6>
  800378:	02d00593          	li	a1,45
  80037c:	10b79d63          	bne	a5,a1,800496 <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800380:	00064783          	lbu	a5,0(a2)
  800384:	0007851b          	sext.w	a0,a5
  800388:	c905                	beqz	a0,8003b8 <vprintfmt+0x1ec>
  80038a:	000cc563          	bltz	s9,800394 <vprintfmt+0x1c8>
  80038e:	3cfd                	addiw	s9,s9,-1
  800390:	036c8263          	beq	s9,s6,8003b4 <vprintfmt+0x1e8>
                    putch('?', putdat);
  800394:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  800396:	14098f63          	beqz	s3,8004f4 <vprintfmt+0x328>
  80039a:	3781                	addiw	a5,a5,-32
  80039c:	14fbfc63          	bgeu	s7,a5,8004f4 <vprintfmt+0x328>
                    putch('?', putdat);
  8003a0:	03f00513          	li	a0,63
  8003a4:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003a6:	0405                	addi	s0,s0,1
  8003a8:	fff44783          	lbu	a5,-1(s0)
  8003ac:	3dfd                	addiw	s11,s11,-1
  8003ae:	0007851b          	sext.w	a0,a5
  8003b2:	fd61                	bnez	a0,80038a <vprintfmt+0x1be>
            for (; width > 0; width --) {
  8003b4:	e5b059e3          	blez	s11,800206 <vprintfmt+0x3a>
  8003b8:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003ba:	85a6                	mv	a1,s1
  8003bc:	02000513          	li	a0,32
  8003c0:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003c2:	e40d82e3          	beqz	s11,800206 <vprintfmt+0x3a>
  8003c6:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003c8:	85a6                	mv	a1,s1
  8003ca:	02000513          	li	a0,32
  8003ce:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003d0:	fe0d94e3          	bnez	s11,8003b8 <vprintfmt+0x1ec>
  8003d4:	bd0d                	j	800206 <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003d6:	4705                	li	a4,1
  8003d8:	008a8593          	addi	a1,s5,8
  8003dc:	01074463          	blt	a4,a6,8003e4 <vprintfmt+0x218>
    else if (lflag) {
  8003e0:	0e080863          	beqz	a6,8004d0 <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
  8003e4:	000ab603          	ld	a2,0(s5)
  8003e8:	46a1                	li	a3,8
  8003ea:	8aae                	mv	s5,a1
  8003ec:	a839                	j	80040a <vprintfmt+0x23e>
            putch('0', putdat);
  8003ee:	03000513          	li	a0,48
  8003f2:	85a6                	mv	a1,s1
  8003f4:	e03e                	sd	a5,0(sp)
  8003f6:	9902                	jalr	s2
            putch('x', putdat);
  8003f8:	85a6                	mv	a1,s1
  8003fa:	07800513          	li	a0,120
  8003fe:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800400:	0aa1                	addi	s5,s5,8
  800402:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  800406:	6782                	ld	a5,0(sp)
  800408:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  80040a:	2781                	sext.w	a5,a5
  80040c:	876e                	mv	a4,s11
  80040e:	85a6                	mv	a1,s1
  800410:	854a                	mv	a0,s2
  800412:	d4fff0ef          	jal	ra,800160 <printnum>
            break;
  800416:	bbc5                	j	800206 <vprintfmt+0x3a>
            lflag ++;
  800418:	00144603          	lbu	a2,1(s0)
  80041c:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  80041e:	846a                	mv	s0,s10
            goto reswitch;
  800420:	b515                	j	800244 <vprintfmt+0x78>
            goto reswitch;
  800422:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  800426:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  800428:	846a                	mv	s0,s10
            goto reswitch;
  80042a:	bd29                	j	800244 <vprintfmt+0x78>
            putch(ch, putdat);
  80042c:	85a6                	mv	a1,s1
  80042e:	02500513          	li	a0,37
  800432:	9902                	jalr	s2
            break;
  800434:	bbc9                	j	800206 <vprintfmt+0x3a>
    if (lflag >= 2) {
  800436:	4705                	li	a4,1
  800438:	008a8593          	addi	a1,s5,8
  80043c:	01074463          	blt	a4,a6,800444 <vprintfmt+0x278>
    else if (lflag) {
  800440:	08080d63          	beqz	a6,8004da <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
  800444:	000ab603          	ld	a2,0(s5)
  800448:	46a9                	li	a3,10
  80044a:	8aae                	mv	s5,a1
  80044c:	bf7d                	j	80040a <vprintfmt+0x23e>
            putch('%', putdat);
  80044e:	85a6                	mv	a1,s1
  800450:	02500513          	li	a0,37
  800454:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  800456:	fff44703          	lbu	a4,-1(s0)
  80045a:	02500793          	li	a5,37
  80045e:	8d22                	mv	s10,s0
  800460:	daf703e3          	beq	a4,a5,800206 <vprintfmt+0x3a>
  800464:	02500713          	li	a4,37
  800468:	1d7d                	addi	s10,s10,-1
  80046a:	fffd4783          	lbu	a5,-1(s10)
  80046e:	fee79de3          	bne	a5,a4,800468 <vprintfmt+0x29c>
  800472:	bb51                	j	800206 <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  800474:	00000617          	auipc	a2,0x0
  800478:	57460613          	addi	a2,a2,1396 # 8009e8 <error_string+0x1a8>
  80047c:	85a6                	mv	a1,s1
  80047e:	854a                	mv	a0,s2
  800480:	0ac000ef          	jal	ra,80052c <printfmt>
  800484:	b349                	j	800206 <vprintfmt+0x3a>
                p = "(null)";
  800486:	00000617          	auipc	a2,0x0
  80048a:	55a60613          	addi	a2,a2,1370 # 8009e0 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  80048e:	00000417          	auipc	s0,0x0
  800492:	55340413          	addi	s0,s0,1363 # 8009e1 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  800496:	8532                	mv	a0,a2
  800498:	85e6                	mv	a1,s9
  80049a:	e032                	sd	a2,0(sp)
  80049c:	e43e                	sd	a5,8(sp)
  80049e:	0ae000ef          	jal	ra,80054c <strnlen>
  8004a2:	40ad8dbb          	subw	s11,s11,a0
  8004a6:	6602                	ld	a2,0(sp)
  8004a8:	01b05d63          	blez	s11,8004c2 <vprintfmt+0x2f6>
  8004ac:	67a2                	ld	a5,8(sp)
  8004ae:	2781                	sext.w	a5,a5
  8004b0:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004b2:	6522                	ld	a0,8(sp)
  8004b4:	85a6                	mv	a1,s1
  8004b6:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004b8:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004ba:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004bc:	6602                	ld	a2,0(sp)
  8004be:	fe0d9ae3          	bnez	s11,8004b2 <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004c2:	00064783          	lbu	a5,0(a2)
  8004c6:	0007851b          	sext.w	a0,a5
  8004ca:	ec0510e3          	bnez	a0,80038a <vprintfmt+0x1be>
  8004ce:	bb25                	j	800206 <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
  8004d0:	000ae603          	lwu	a2,0(s5)
  8004d4:	46a1                	li	a3,8
  8004d6:	8aae                	mv	s5,a1
  8004d8:	bf0d                	j	80040a <vprintfmt+0x23e>
  8004da:	000ae603          	lwu	a2,0(s5)
  8004de:	46a9                	li	a3,10
  8004e0:	8aae                	mv	s5,a1
  8004e2:	b725                	j	80040a <vprintfmt+0x23e>
        return va_arg(*ap, int);
  8004e4:	000aa403          	lw	s0,0(s5)
  8004e8:	bd35                	j	800324 <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
  8004ea:	000ae603          	lwu	a2,0(s5)
  8004ee:	46c1                	li	a3,16
  8004f0:	8aae                	mv	s5,a1
  8004f2:	bf21                	j	80040a <vprintfmt+0x23e>
                    putch(ch, putdat);
  8004f4:	9902                	jalr	s2
  8004f6:	bd45                	j	8003a6 <vprintfmt+0x1da>
                putch('-', putdat);
  8004f8:	85a6                	mv	a1,s1
  8004fa:	02d00513          	li	a0,45
  8004fe:	e03e                	sd	a5,0(sp)
  800500:	9902                	jalr	s2
                num = -(long long)num;
  800502:	8ace                	mv	s5,s3
  800504:	40800633          	neg	a2,s0
  800508:	46a9                	li	a3,10
  80050a:	6782                	ld	a5,0(sp)
  80050c:	bdfd                	j	80040a <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
  80050e:	01b05663          	blez	s11,80051a <vprintfmt+0x34e>
  800512:	02d00693          	li	a3,45
  800516:	f6d798e3          	bne	a5,a3,800486 <vprintfmt+0x2ba>
  80051a:	00000417          	auipc	s0,0x0
  80051e:	4c740413          	addi	s0,s0,1223 # 8009e1 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800522:	02800513          	li	a0,40
  800526:	02800793          	li	a5,40
  80052a:	b585                	j	80038a <vprintfmt+0x1be>

000000000080052c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80052c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  80052e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800532:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800534:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800536:	ec06                	sd	ra,24(sp)
  800538:	f83a                	sd	a4,48(sp)
  80053a:	fc3e                	sd	a5,56(sp)
  80053c:	e0c2                	sd	a6,64(sp)
  80053e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800540:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800542:	c8bff0ef          	jal	ra,8001cc <vprintfmt>
}
  800546:	60e2                	ld	ra,24(sp)
  800548:	6161                	addi	sp,sp,80
  80054a:	8082                	ret

000000000080054c <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  80054c:	c185                	beqz	a1,80056c <strnlen+0x20>
  80054e:	00054783          	lbu	a5,0(a0)
  800552:	cf89                	beqz	a5,80056c <strnlen+0x20>
    size_t cnt = 0;
  800554:	4781                	li	a5,0
  800556:	a021                	j	80055e <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  800558:	00074703          	lbu	a4,0(a4)
  80055c:	c711                	beqz	a4,800568 <strnlen+0x1c>
        cnt ++;
  80055e:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800560:	00f50733          	add	a4,a0,a5
  800564:	fef59ae3          	bne	a1,a5,800558 <strnlen+0xc>
    }
    return cnt;
}
  800568:	853e                	mv	a0,a5
  80056a:	8082                	ret
    size_t cnt = 0;
  80056c:	4781                	li	a5,0
}
  80056e:	853e                	mv	a0,a5
  800570:	8082                	ret

0000000000800572 <do_yield>:
#include <ulib.h>
#include <stdio.h>

void
do_yield(void) {
  800572:	1141                	addi	sp,sp,-16
  800574:	e406                	sd	ra,8(sp)
    yield();
  800576:	bd9ff0ef          	jal	ra,80014e <yield>
    yield();
  80057a:	bd5ff0ef          	jal	ra,80014e <yield>
    yield();
  80057e:	bd1ff0ef          	jal	ra,80014e <yield>
    yield();
  800582:	bcdff0ef          	jal	ra,80014e <yield>
    yield();
  800586:	bc9ff0ef          	jal	ra,80014e <yield>
    yield();
}
  80058a:	60a2                	ld	ra,8(sp)
  80058c:	0141                	addi	sp,sp,16
    yield();
  80058e:	b6c1                	j	80014e <yield>

0000000000800590 <loop>:

int parent, pid1, pid2;

void
loop(void) {
  800590:	1141                	addi	sp,sp,-16
    cprintf("child 1.\n");
  800592:	00000517          	auipc	a0,0x0
  800596:	46e50513          	addi	a0,a0,1134 # 800a00 <error_string+0x1c0>
loop(void) {
  80059a:	e406                	sd	ra,8(sp)
    cprintf("child 1.\n");
  80059c:	b05ff0ef          	jal	ra,8000a0 <cprintf>
    while (1);
  8005a0:	a001                	j	8005a0 <loop+0x10>

00000000008005a2 <work>:
}

void
work(void) {
  8005a2:	1141                	addi	sp,sp,-16
    cprintf("child 2.\n");
  8005a4:	00000517          	auipc	a0,0x0
  8005a8:	4dc50513          	addi	a0,a0,1244 # 800a80 <error_string+0x240>
work(void) {
  8005ac:	e406                	sd	ra,8(sp)
    cprintf("child 2.\n");
  8005ae:	af3ff0ef          	jal	ra,8000a0 <cprintf>
    do_yield();
  8005b2:	fc1ff0ef          	jal	ra,800572 <do_yield>
    if (kill(parent) == 0) {
  8005b6:	00001797          	auipc	a5,0x1
  8005ba:	a4a78793          	addi	a5,a5,-1462 # 801000 <parent>
  8005be:	4388                	lw	a0,0(a5)
  8005c0:	b91ff0ef          	jal	ra,800150 <kill>
  8005c4:	e10d                	bnez	a0,8005e6 <work+0x44>
        cprintf("kill parent ok.\n");
  8005c6:	00000517          	auipc	a0,0x0
  8005ca:	4ca50513          	addi	a0,a0,1226 # 800a90 <error_string+0x250>
  8005ce:	ad3ff0ef          	jal	ra,8000a0 <cprintf>
        do_yield();
  8005d2:	fa1ff0ef          	jal	ra,800572 <do_yield>
        if (kill(pid1) == 0) {
  8005d6:	00001797          	auipc	a5,0x1
  8005da:	a3278793          	addi	a5,a5,-1486 # 801008 <pid1>
  8005de:	4388                	lw	a0,0(a5)
  8005e0:	b71ff0ef          	jal	ra,800150 <kill>
  8005e4:	c501                	beqz	a0,8005ec <work+0x4a>
            cprintf("kill child1 ok.\n");
            exit(0);
        }
    }
    exit(-1);
  8005e6:	557d                	li	a0,-1
  8005e8:	b4dff0ef          	jal	ra,800134 <exit>
            cprintf("kill child1 ok.\n");
  8005ec:	00000517          	auipc	a0,0x0
  8005f0:	4bc50513          	addi	a0,a0,1212 # 800aa8 <error_string+0x268>
  8005f4:	aadff0ef          	jal	ra,8000a0 <cprintf>
            exit(0);
  8005f8:	4501                	li	a0,0
  8005fa:	b3bff0ef          	jal	ra,800134 <exit>

00000000008005fe <main>:
}

int
main(void) {
  8005fe:	1141                	addi	sp,sp,-16
  800600:	e406                	sd	ra,8(sp)
  800602:	e022                	sd	s0,0(sp)
    parent = getpid();
  800604:	b4fff0ef          	jal	ra,800152 <getpid>
  800608:	00001797          	auipc	a5,0x1
  80060c:	9ea7ac23          	sw	a0,-1544(a5) # 801000 <parent>
    if ((pid1 = fork()) == 0) {
  800610:	b3bff0ef          	jal	ra,80014a <fork>
  800614:	00001797          	auipc	a5,0x1
  800618:	9ea7aa23          	sw	a0,-1548(a5) # 801008 <pid1>
  80061c:	c53d                	beqz	a0,80068a <main+0x8c>
        loop();
    }

    assert(pid1 > 0);
  80061e:	04a05663          	blez	a0,80066a <main+0x6c>

    if ((pid2 = fork()) == 0) {
  800622:	b29ff0ef          	jal	ra,80014a <fork>
  800626:	00001797          	auipc	a5,0x1
  80062a:	9ca7af23          	sw	a0,-1570(a5) # 801004 <pid2>
  80062e:	cd3d                	beqz	a0,8006ac <main+0xae>
  800630:	00001417          	auipc	s0,0x1
  800634:	9d840413          	addi	s0,s0,-1576 # 801008 <pid1>
        work();
    }
    if (pid2 > 0) {
  800638:	04a05b63          	blez	a0,80068e <main+0x90>
        cprintf("wait child 1.\n");
  80063c:	00000517          	auipc	a0,0x0
  800640:	40c50513          	addi	a0,a0,1036 # 800a48 <error_string+0x208>
  800644:	a5dff0ef          	jal	ra,8000a0 <cprintf>
        waitpid(pid1, NULL);
  800648:	4008                	lw	a0,0(s0)
  80064a:	4581                	li	a1,0
  80064c:	b01ff0ef          	jal	ra,80014c <waitpid>
        panic("waitpid %d returns\n", pid1);
  800650:	4014                	lw	a3,0(s0)
  800652:	00000617          	auipc	a2,0x0
  800656:	40660613          	addi	a2,a2,1030 # 800a58 <error_string+0x218>
  80065a:	03400593          	li	a1,52
  80065e:	00000517          	auipc	a0,0x0
  800662:	3da50513          	addi	a0,a0,986 # 800a38 <error_string+0x1f8>
  800666:	9c1ff0ef          	jal	ra,800026 <__panic>
    assert(pid1 > 0);
  80066a:	00000697          	auipc	a3,0x0
  80066e:	3a668693          	addi	a3,a3,934 # 800a10 <error_string+0x1d0>
  800672:	00000617          	auipc	a2,0x0
  800676:	3ae60613          	addi	a2,a2,942 # 800a20 <error_string+0x1e0>
  80067a:	02c00593          	li	a1,44
  80067e:	00000517          	auipc	a0,0x0
  800682:	3ba50513          	addi	a0,a0,954 # 800a38 <error_string+0x1f8>
  800686:	9a1ff0ef          	jal	ra,800026 <__panic>
        loop();
  80068a:	f07ff0ef          	jal	ra,800590 <loop>
    }
    else {
        kill(pid1);
  80068e:	4008                	lw	a0,0(s0)
  800690:	ac1ff0ef          	jal	ra,800150 <kill>
    }
    panic("FAIL: T.T\n");
  800694:	00000617          	auipc	a2,0x0
  800698:	3dc60613          	addi	a2,a2,988 # 800a70 <error_string+0x230>
  80069c:	03900593          	li	a1,57
  8006a0:	00000517          	auipc	a0,0x0
  8006a4:	39850513          	addi	a0,a0,920 # 800a38 <error_string+0x1f8>
  8006a8:	97fff0ef          	jal	ra,800026 <__panic>
        work();
  8006ac:	ef7ff0ef          	jal	ra,8005a2 <work>
