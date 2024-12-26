
obj/__user_exit.out：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
.text
.globl _start
_start:
    # call user-program function
    call umain
  800020:	12c000ef          	jal	ra,80014c <umain>
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
  800038:	64c50513          	addi	a0,a0,1612 # 800680 <main+0x116>
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
  800058:	9dc50513          	addi	a0,a0,-1572 # 800a30 <error_string+0x220>
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
  800094:	130000ef          	jal	ra,8001c4 <vprintfmt>
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
  8000c8:	0fc000ef          	jal	ra,8001c4 <vprintfmt>
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
  800136:	56e50513          	addi	a0,a0,1390 # 8006a0 <main+0x136>
  80013a:	f67ff0ef          	jal	ra,8000a0 <cprintf>
    while (1);
  80013e:	a001                	j	80013e <exit+0x14>

0000000000800140 <fork>:
}

int
fork(void) {
    return sys_fork();
  800140:	bfd1                	j	800114 <sys_fork>

0000000000800142 <wait>:
}

int
wait(void) {
    return sys_wait(0, NULL);
  800142:	4581                	li	a1,0
  800144:	4501                	li	a0,0
  800146:	bfc9                	j	800118 <sys_wait>

0000000000800148 <waitpid>:
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

000000000080014c <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  80014c:	1141                	addi	sp,sp,-16
  80014e:	e406                	sd	ra,8(sp)
    int ret = main();
  800150:	41a000ef          	jal	ra,80056a <main>
    exit(ret);
  800154:	fd7ff0ef          	jal	ra,80012a <exit>

0000000000800158 <printnum>:
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800158:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80015c:	7179                	addi	sp,sp,-48
    unsigned mod = do_div(result, base);
  80015e:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800162:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800164:	03067a33          	remu	s4,a2,a6
        unsigned long long num, unsigned base, int width, int padc) {
  800168:	f022                	sd	s0,32(sp)
  80016a:	ec26                	sd	s1,24(sp)
  80016c:	e84a                	sd	s2,16(sp)
  80016e:	f406                	sd	ra,40(sp)
  800170:	e44e                	sd	s3,8(sp)
  800172:	84aa                	mv	s1,a0
  800174:	892e                	mv	s2,a1
  800176:	fff7041b          	addiw	s0,a4,-1
    unsigned mod = do_div(result, base);
  80017a:	2a01                	sext.w	s4,s4

    // first recursively print all preceding (more significant) digits
    if (num >= base) {
  80017c:	03067e63          	bgeu	a2,a6,8001b8 <printnum+0x60>
  800180:	89be                	mv	s3,a5
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  800182:	00805763          	blez	s0,800190 <printnum+0x38>
  800186:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  800188:	85ca                	mv	a1,s2
  80018a:	854e                	mv	a0,s3
  80018c:	9482                	jalr	s1
        while (-- width > 0)
  80018e:	fc65                	bnez	s0,800186 <printnum+0x2e>
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800190:	1a02                	slli	s4,s4,0x20
  800192:	020a5a13          	srli	s4,s4,0x20
  800196:	00000797          	auipc	a5,0x0
  80019a:	74278793          	addi	a5,a5,1858 # 8008d8 <error_string+0xc8>
  80019e:	9a3e                	add	s4,s4,a5
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  8001a0:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001a2:	000a4503          	lbu	a0,0(s4)
}
  8001a6:	70a2                	ld	ra,40(sp)
  8001a8:	69a2                	ld	s3,8(sp)
  8001aa:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001ac:	85ca                	mv	a1,s2
  8001ae:	8326                	mv	t1,s1
}
  8001b0:	6942                	ld	s2,16(sp)
  8001b2:	64e2                	ld	s1,24(sp)
  8001b4:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001b6:	8302                	jr	t1
        printnum(putch, putdat, result, base, width - 1, padc);
  8001b8:	03065633          	divu	a2,a2,a6
  8001bc:	8722                	mv	a4,s0
  8001be:	f9bff0ef          	jal	ra,800158 <printnum>
  8001c2:	b7f9                	j	800190 <printnum+0x38>

00000000008001c4 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001c4:	7119                	addi	sp,sp,-128
  8001c6:	f4a6                	sd	s1,104(sp)
  8001c8:	f0ca                	sd	s2,96(sp)
  8001ca:	e8d2                	sd	s4,80(sp)
  8001cc:	e4d6                	sd	s5,72(sp)
  8001ce:	e0da                	sd	s6,64(sp)
  8001d0:	fc5e                	sd	s7,56(sp)
  8001d2:	f862                	sd	s8,48(sp)
  8001d4:	f06a                	sd	s10,32(sp)
  8001d6:	fc86                	sd	ra,120(sp)
  8001d8:	f8a2                	sd	s0,112(sp)
  8001da:	ecce                	sd	s3,88(sp)
  8001dc:	f466                	sd	s9,40(sp)
  8001de:	ec6e                	sd	s11,24(sp)
  8001e0:	892a                	mv	s2,a0
  8001e2:	84ae                	mv	s1,a1
  8001e4:	8d32                	mv	s10,a2
  8001e6:	8ab6                	mv	s5,a3
            putch(ch, putdat);
        }

        // Process a %-escape sequence
        char padc = ' ';
        width = precision = -1;
  8001e8:	5b7d                	li	s6,-1
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001ea:	00000a17          	auipc	s4,0x0
  8001ee:	4caa0a13          	addi	s4,s4,1226 # 8006b4 <main+0x14a>
                for (width -= strnlen(p, precision); width > 0; width --) {
                    putch(padc, putdat);
                }
            }
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
                if (altflag && (ch < ' ' || ch > '~')) {
  8001f2:	05e00b93          	li	s7,94
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8001f6:	00000c17          	auipc	s8,0x0
  8001fa:	61ac0c13          	addi	s8,s8,1562 # 800810 <error_string>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001fe:	000d4503          	lbu	a0,0(s10)
  800202:	02500793          	li	a5,37
  800206:	001d0413          	addi	s0,s10,1
  80020a:	00f50e63          	beq	a0,a5,800226 <vprintfmt+0x62>
            if (ch == '\0') {
  80020e:	c521                	beqz	a0,800256 <vprintfmt+0x92>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800210:	02500993          	li	s3,37
  800214:	a011                	j	800218 <vprintfmt+0x54>
            if (ch == '\0') {
  800216:	c121                	beqz	a0,800256 <vprintfmt+0x92>
            putch(ch, putdat);
  800218:	85a6                	mv	a1,s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80021a:	0405                	addi	s0,s0,1
            putch(ch, putdat);
  80021c:	9902                	jalr	s2
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  80021e:	fff44503          	lbu	a0,-1(s0)
  800222:	ff351ae3          	bne	a0,s3,800216 <vprintfmt+0x52>
  800226:	00044603          	lbu	a2,0(s0)
        char padc = ' ';
  80022a:	02000793          	li	a5,32
        lflag = altflag = 0;
  80022e:	4981                	li	s3,0
  800230:	4801                	li	a6,0
        width = precision = -1;
  800232:	5cfd                	li	s9,-1
  800234:	5dfd                	li	s11,-1
        switch (ch = *(unsigned char *)fmt ++) {
  800236:	05500593          	li	a1,85
                if (ch < '0' || ch > '9') {
  80023a:	4525                	li	a0,9
        switch (ch = *(unsigned char *)fmt ++) {
  80023c:	fdd6069b          	addiw	a3,a2,-35
  800240:	0ff6f693          	andi	a3,a3,255
  800244:	00140d13          	addi	s10,s0,1
  800248:	1ed5ef63          	bltu	a1,a3,800446 <vprintfmt+0x282>
  80024c:	068a                	slli	a3,a3,0x2
  80024e:	96d2                	add	a3,a3,s4
  800250:	4294                	lw	a3,0(a3)
  800252:	96d2                	add	a3,a3,s4
  800254:	8682                	jr	a3
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800256:	70e6                	ld	ra,120(sp)
  800258:	7446                	ld	s0,112(sp)
  80025a:	74a6                	ld	s1,104(sp)
  80025c:	7906                	ld	s2,96(sp)
  80025e:	69e6                	ld	s3,88(sp)
  800260:	6a46                	ld	s4,80(sp)
  800262:	6aa6                	ld	s5,72(sp)
  800264:	6b06                	ld	s6,64(sp)
  800266:	7be2                	ld	s7,56(sp)
  800268:	7c42                	ld	s8,48(sp)
  80026a:	7ca2                	ld	s9,40(sp)
  80026c:	7d02                	ld	s10,32(sp)
  80026e:	6de2                	ld	s11,24(sp)
  800270:	6109                	addi	sp,sp,128
  800272:	8082                	ret
            padc = '-';
  800274:	87b2                	mv	a5,a2
        switch (ch = *(unsigned char *)fmt ++) {
  800276:	00144603          	lbu	a2,1(s0)
  80027a:	846a                	mv	s0,s10
  80027c:	b7c1                	j	80023c <vprintfmt+0x78>
            precision = va_arg(ap, int);
  80027e:	000aac83          	lw	s9,0(s5)
            goto process_precision;
  800282:	00144603          	lbu	a2,1(s0)
            precision = va_arg(ap, int);
  800286:	0aa1                	addi	s5,s5,8
        switch (ch = *(unsigned char *)fmt ++) {
  800288:	846a                	mv	s0,s10
            if (width < 0)
  80028a:	fa0dd9e3          	bgez	s11,80023c <vprintfmt+0x78>
                width = precision, precision = -1;
  80028e:	8de6                	mv	s11,s9
  800290:	5cfd                	li	s9,-1
  800292:	b76d                	j	80023c <vprintfmt+0x78>
            if (width < 0)
  800294:	fffdc693          	not	a3,s11
  800298:	96fd                	srai	a3,a3,0x3f
  80029a:	00ddfdb3          	and	s11,s11,a3
  80029e:	00144603          	lbu	a2,1(s0)
  8002a2:	2d81                	sext.w	s11,s11
        switch (ch = *(unsigned char *)fmt ++) {
  8002a4:	846a                	mv	s0,s10
  8002a6:	bf59                	j	80023c <vprintfmt+0x78>
    if (lflag >= 2) {
  8002a8:	4705                	li	a4,1
  8002aa:	008a8593          	addi	a1,s5,8
  8002ae:	01074463          	blt	a4,a6,8002b6 <vprintfmt+0xf2>
    else if (lflag) {
  8002b2:	22080863          	beqz	a6,8004e2 <vprintfmt+0x31e>
        return va_arg(*ap, unsigned long);
  8002b6:	000ab603          	ld	a2,0(s5)
  8002ba:	46c1                	li	a3,16
  8002bc:	8aae                	mv	s5,a1
  8002be:	a291                	j	800402 <vprintfmt+0x23e>
                precision = precision * 10 + ch - '0';
  8002c0:	fd060c9b          	addiw	s9,a2,-48
                ch = *fmt;
  8002c4:	00144603          	lbu	a2,1(s0)
        switch (ch = *(unsigned char *)fmt ++) {
  8002c8:	846a                	mv	s0,s10
                if (ch < '0' || ch > '9') {
  8002ca:	fd06069b          	addiw	a3,a2,-48
                ch = *fmt;
  8002ce:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8002d2:	fad56ce3          	bltu	a0,a3,80028a <vprintfmt+0xc6>
            for (precision = 0; ; ++ fmt) {
  8002d6:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002d8:	002c969b          	slliw	a3,s9,0x2
                ch = *fmt;
  8002dc:	00044603          	lbu	a2,0(s0)
                precision = precision * 10 + ch - '0';
  8002e0:	0196873b          	addw	a4,a3,s9
  8002e4:	0017171b          	slliw	a4,a4,0x1
  8002e8:	0117073b          	addw	a4,a4,a7
                if (ch < '0' || ch > '9') {
  8002ec:	fd06069b          	addiw	a3,a2,-48
                precision = precision * 10 + ch - '0';
  8002f0:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002f4:	0006089b          	sext.w	a7,a2
                if (ch < '0' || ch > '9') {
  8002f8:	fcd57fe3          	bgeu	a0,a3,8002d6 <vprintfmt+0x112>
  8002fc:	b779                	j	80028a <vprintfmt+0xc6>
            putch(va_arg(ap, int), putdat);
  8002fe:	000aa503          	lw	a0,0(s5)
  800302:	85a6                	mv	a1,s1
  800304:	0aa1                	addi	s5,s5,8
  800306:	9902                	jalr	s2
            break;
  800308:	bddd                	j	8001fe <vprintfmt+0x3a>
    if (lflag >= 2) {
  80030a:	4705                	li	a4,1
  80030c:	008a8993          	addi	s3,s5,8
  800310:	01074463          	blt	a4,a6,800318 <vprintfmt+0x154>
    else if (lflag) {
  800314:	1c080463          	beqz	a6,8004dc <vprintfmt+0x318>
        return va_arg(*ap, long);
  800318:	000ab403          	ld	s0,0(s5)
            if ((long long)num < 0) {
  80031c:	1c044a63          	bltz	s0,8004f0 <vprintfmt+0x32c>
            num = getint(&ap, lflag);
  800320:	8622                	mv	a2,s0
  800322:	8ace                	mv	s5,s3
  800324:	46a9                	li	a3,10
  800326:	a8f1                	j	800402 <vprintfmt+0x23e>
            err = va_arg(ap, int);
  800328:	000aa783          	lw	a5,0(s5)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80032c:	4761                	li	a4,24
            err = va_arg(ap, int);
  80032e:	0aa1                	addi	s5,s5,8
            if (err < 0) {
  800330:	41f7d69b          	sraiw	a3,a5,0x1f
  800334:	8fb5                	xor	a5,a5,a3
  800336:	40d786bb          	subw	a3,a5,a3
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  80033a:	12d74963          	blt	a4,a3,80046c <vprintfmt+0x2a8>
  80033e:	00369793          	slli	a5,a3,0x3
  800342:	97e2                	add	a5,a5,s8
  800344:	639c                	ld	a5,0(a5)
  800346:	12078363          	beqz	a5,80046c <vprintfmt+0x2a8>
                printfmt(putch, putdat, "%s", p);
  80034a:	86be                	mv	a3,a5
  80034c:	00000617          	auipc	a2,0x0
  800350:	67c60613          	addi	a2,a2,1660 # 8009c8 <error_string+0x1b8>
  800354:	85a6                	mv	a1,s1
  800356:	854a                	mv	a0,s2
  800358:	1cc000ef          	jal	ra,800524 <printfmt>
  80035c:	b54d                	j	8001fe <vprintfmt+0x3a>
            if ((p = va_arg(ap, char *)) == NULL) {
  80035e:	000ab603          	ld	a2,0(s5)
  800362:	0aa1                	addi	s5,s5,8
  800364:	1a060163          	beqz	a2,800506 <vprintfmt+0x342>
            if (width > 0 && padc != '-') {
  800368:	00160413          	addi	s0,a2,1
  80036c:	15b05763          	blez	s11,8004ba <vprintfmt+0x2f6>
  800370:	02d00593          	li	a1,45
  800374:	10b79d63          	bne	a5,a1,80048e <vprintfmt+0x2ca>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  800378:	00064783          	lbu	a5,0(a2)
  80037c:	0007851b          	sext.w	a0,a5
  800380:	c905                	beqz	a0,8003b0 <vprintfmt+0x1ec>
  800382:	000cc563          	bltz	s9,80038c <vprintfmt+0x1c8>
  800386:	3cfd                	addiw	s9,s9,-1
  800388:	036c8263          	beq	s9,s6,8003ac <vprintfmt+0x1e8>
                    putch('?', putdat);
  80038c:	85a6                	mv	a1,s1
                if (altflag && (ch < ' ' || ch > '~')) {
  80038e:	14098f63          	beqz	s3,8004ec <vprintfmt+0x328>
  800392:	3781                	addiw	a5,a5,-32
  800394:	14fbfc63          	bgeu	s7,a5,8004ec <vprintfmt+0x328>
                    putch('?', putdat);
  800398:	03f00513          	li	a0,63
  80039c:	9902                	jalr	s2
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80039e:	0405                	addi	s0,s0,1
  8003a0:	fff44783          	lbu	a5,-1(s0)
  8003a4:	3dfd                	addiw	s11,s11,-1
  8003a6:	0007851b          	sext.w	a0,a5
  8003aa:	fd61                	bnez	a0,800382 <vprintfmt+0x1be>
            for (; width > 0; width --) {
  8003ac:	e5b059e3          	blez	s11,8001fe <vprintfmt+0x3a>
  8003b0:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003b2:	85a6                	mv	a1,s1
  8003b4:	02000513          	li	a0,32
  8003b8:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003ba:	e40d82e3          	beqz	s11,8001fe <vprintfmt+0x3a>
  8003be:	3dfd                	addiw	s11,s11,-1
                putch(' ', putdat);
  8003c0:	85a6                	mv	a1,s1
  8003c2:	02000513          	li	a0,32
  8003c6:	9902                	jalr	s2
            for (; width > 0; width --) {
  8003c8:	fe0d94e3          	bnez	s11,8003b0 <vprintfmt+0x1ec>
  8003cc:	bd0d                	j	8001fe <vprintfmt+0x3a>
    if (lflag >= 2) {
  8003ce:	4705                	li	a4,1
  8003d0:	008a8593          	addi	a1,s5,8
  8003d4:	01074463          	blt	a4,a6,8003dc <vprintfmt+0x218>
    else if (lflag) {
  8003d8:	0e080863          	beqz	a6,8004c8 <vprintfmt+0x304>
        return va_arg(*ap, unsigned long);
  8003dc:	000ab603          	ld	a2,0(s5)
  8003e0:	46a1                	li	a3,8
  8003e2:	8aae                	mv	s5,a1
  8003e4:	a839                	j	800402 <vprintfmt+0x23e>
            putch('0', putdat);
  8003e6:	03000513          	li	a0,48
  8003ea:	85a6                	mv	a1,s1
  8003ec:	e03e                	sd	a5,0(sp)
  8003ee:	9902                	jalr	s2
            putch('x', putdat);
  8003f0:	85a6                	mv	a1,s1
  8003f2:	07800513          	li	a0,120
  8003f6:	9902                	jalr	s2
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  8003f8:	0aa1                	addi	s5,s5,8
  8003fa:	ff8ab603          	ld	a2,-8(s5)
            goto number;
  8003fe:	6782                	ld	a5,0(sp)
  800400:	46c1                	li	a3,16
            printnum(putch, putdat, num, base, width, padc);
  800402:	2781                	sext.w	a5,a5
  800404:	876e                	mv	a4,s11
  800406:	85a6                	mv	a1,s1
  800408:	854a                	mv	a0,s2
  80040a:	d4fff0ef          	jal	ra,800158 <printnum>
            break;
  80040e:	bbc5                	j	8001fe <vprintfmt+0x3a>
            lflag ++;
  800410:	00144603          	lbu	a2,1(s0)
  800414:	2805                	addiw	a6,a6,1
        switch (ch = *(unsigned char *)fmt ++) {
  800416:	846a                	mv	s0,s10
            goto reswitch;
  800418:	b515                	j	80023c <vprintfmt+0x78>
            goto reswitch;
  80041a:	00144603          	lbu	a2,1(s0)
            altflag = 1;
  80041e:	4985                	li	s3,1
        switch (ch = *(unsigned char *)fmt ++) {
  800420:	846a                	mv	s0,s10
            goto reswitch;
  800422:	bd29                	j	80023c <vprintfmt+0x78>
            putch(ch, putdat);
  800424:	85a6                	mv	a1,s1
  800426:	02500513          	li	a0,37
  80042a:	9902                	jalr	s2
            break;
  80042c:	bbc9                	j	8001fe <vprintfmt+0x3a>
    if (lflag >= 2) {
  80042e:	4705                	li	a4,1
  800430:	008a8593          	addi	a1,s5,8
  800434:	01074463          	blt	a4,a6,80043c <vprintfmt+0x278>
    else if (lflag) {
  800438:	08080d63          	beqz	a6,8004d2 <vprintfmt+0x30e>
        return va_arg(*ap, unsigned long);
  80043c:	000ab603          	ld	a2,0(s5)
  800440:	46a9                	li	a3,10
  800442:	8aae                	mv	s5,a1
  800444:	bf7d                	j	800402 <vprintfmt+0x23e>
            putch('%', putdat);
  800446:	85a6                	mv	a1,s1
  800448:	02500513          	li	a0,37
  80044c:	9902                	jalr	s2
            for (fmt --; fmt[-1] != '%'; fmt --)
  80044e:	fff44703          	lbu	a4,-1(s0)
  800452:	02500793          	li	a5,37
  800456:	8d22                	mv	s10,s0
  800458:	daf703e3          	beq	a4,a5,8001fe <vprintfmt+0x3a>
  80045c:	02500713          	li	a4,37
  800460:	1d7d                	addi	s10,s10,-1
  800462:	fffd4783          	lbu	a5,-1(s10)
  800466:	fee79de3          	bne	a5,a4,800460 <vprintfmt+0x29c>
  80046a:	bb51                	j	8001fe <vprintfmt+0x3a>
                printfmt(putch, putdat, "error %d", err);
  80046c:	00000617          	auipc	a2,0x0
  800470:	54c60613          	addi	a2,a2,1356 # 8009b8 <error_string+0x1a8>
  800474:	85a6                	mv	a1,s1
  800476:	854a                	mv	a0,s2
  800478:	0ac000ef          	jal	ra,800524 <printfmt>
  80047c:	b349                	j	8001fe <vprintfmt+0x3a>
                p = "(null)";
  80047e:	00000617          	auipc	a2,0x0
  800482:	53260613          	addi	a2,a2,1330 # 8009b0 <error_string+0x1a0>
            if (width > 0 && padc != '-') {
  800486:	00000417          	auipc	s0,0x0
  80048a:	52b40413          	addi	s0,s0,1323 # 8009b1 <error_string+0x1a1>
                for (width -= strnlen(p, precision); width > 0; width --) {
  80048e:	8532                	mv	a0,a2
  800490:	85e6                	mv	a1,s9
  800492:	e032                	sd	a2,0(sp)
  800494:	e43e                	sd	a5,8(sp)
  800496:	0ae000ef          	jal	ra,800544 <strnlen>
  80049a:	40ad8dbb          	subw	s11,s11,a0
  80049e:	6602                	ld	a2,0(sp)
  8004a0:	01b05d63          	blez	s11,8004ba <vprintfmt+0x2f6>
  8004a4:	67a2                	ld	a5,8(sp)
  8004a6:	2781                	sext.w	a5,a5
  8004a8:	e43e                	sd	a5,8(sp)
                    putch(padc, putdat);
  8004aa:	6522                	ld	a0,8(sp)
  8004ac:	85a6                	mv	a1,s1
  8004ae:	e032                	sd	a2,0(sp)
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004b0:	3dfd                	addiw	s11,s11,-1
                    putch(padc, putdat);
  8004b2:	9902                	jalr	s2
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004b4:	6602                	ld	a2,0(sp)
  8004b6:	fe0d9ae3          	bnez	s11,8004aa <vprintfmt+0x2e6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004ba:	00064783          	lbu	a5,0(a2)
  8004be:	0007851b          	sext.w	a0,a5
  8004c2:	ec0510e3          	bnez	a0,800382 <vprintfmt+0x1be>
  8004c6:	bb25                	j	8001fe <vprintfmt+0x3a>
        return va_arg(*ap, unsigned int);
  8004c8:	000ae603          	lwu	a2,0(s5)
  8004cc:	46a1                	li	a3,8
  8004ce:	8aae                	mv	s5,a1
  8004d0:	bf0d                	j	800402 <vprintfmt+0x23e>
  8004d2:	000ae603          	lwu	a2,0(s5)
  8004d6:	46a9                	li	a3,10
  8004d8:	8aae                	mv	s5,a1
  8004da:	b725                	j	800402 <vprintfmt+0x23e>
        return va_arg(*ap, int);
  8004dc:	000aa403          	lw	s0,0(s5)
  8004e0:	bd35                	j	80031c <vprintfmt+0x158>
        return va_arg(*ap, unsigned int);
  8004e2:	000ae603          	lwu	a2,0(s5)
  8004e6:	46c1                	li	a3,16
  8004e8:	8aae                	mv	s5,a1
  8004ea:	bf21                	j	800402 <vprintfmt+0x23e>
                    putch(ch, putdat);
  8004ec:	9902                	jalr	s2
  8004ee:	bd45                	j	80039e <vprintfmt+0x1da>
                putch('-', putdat);
  8004f0:	85a6                	mv	a1,s1
  8004f2:	02d00513          	li	a0,45
  8004f6:	e03e                	sd	a5,0(sp)
  8004f8:	9902                	jalr	s2
                num = -(long long)num;
  8004fa:	8ace                	mv	s5,s3
  8004fc:	40800633          	neg	a2,s0
  800500:	46a9                	li	a3,10
  800502:	6782                	ld	a5,0(sp)
  800504:	bdfd                	j	800402 <vprintfmt+0x23e>
            if (width > 0 && padc != '-') {
  800506:	01b05663          	blez	s11,800512 <vprintfmt+0x34e>
  80050a:	02d00693          	li	a3,45
  80050e:	f6d798e3          	bne	a5,a3,80047e <vprintfmt+0x2ba>
  800512:	00000417          	auipc	s0,0x0
  800516:	49f40413          	addi	s0,s0,1183 # 8009b1 <error_string+0x1a1>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80051a:	02800513          	li	a0,40
  80051e:	02800793          	li	a5,40
  800522:	b585                	j	800382 <vprintfmt+0x1be>

0000000000800524 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800524:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800526:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80052a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80052c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80052e:	ec06                	sd	ra,24(sp)
  800530:	f83a                	sd	a4,48(sp)
  800532:	fc3e                	sd	a5,56(sp)
  800534:	e0c2                	sd	a6,64(sp)
  800536:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800538:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80053a:	c8bff0ef          	jal	ra,8001c4 <vprintfmt>
}
  80053e:	60e2                	ld	ra,24(sp)
  800540:	6161                	addi	sp,sp,80
  800542:	8082                	ret

0000000000800544 <strnlen>:
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
    while (cnt < len && *s ++ != '\0') {
  800544:	c185                	beqz	a1,800564 <strnlen+0x20>
  800546:	00054783          	lbu	a5,0(a0)
  80054a:	cf89                	beqz	a5,800564 <strnlen+0x20>
    size_t cnt = 0;
  80054c:	4781                	li	a5,0
  80054e:	a021                	j	800556 <strnlen+0x12>
    while (cnt < len && *s ++ != '\0') {
  800550:	00074703          	lbu	a4,0(a4)
  800554:	c711                	beqz	a4,800560 <strnlen+0x1c>
        cnt ++;
  800556:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  800558:	00f50733          	add	a4,a0,a5
  80055c:	fef59ae3          	bne	a1,a5,800550 <strnlen+0xc>
    }
    return cnt;
}
  800560:	853e                	mv	a0,a5
  800562:	8082                	ret
    size_t cnt = 0;
  800564:	4781                	li	a5,0
}
  800566:	853e                	mv	a0,a5
  800568:	8082                	ret

000000000080056a <main>:
#include <ulib.h>

int magic = -0x10384;

int
main(void) {
  80056a:	1101                	addi	sp,sp,-32
    int pid, code;
    cprintf("I am the parent. Forking the child...\n");
  80056c:	00000517          	auipc	a0,0x0
  800570:	46450513          	addi	a0,a0,1124 # 8009d0 <error_string+0x1c0>
main(void) {
  800574:	ec06                	sd	ra,24(sp)
  800576:	e822                	sd	s0,16(sp)
    cprintf("I am the parent. Forking the child...\n");
  800578:	b29ff0ef          	jal	ra,8000a0 <cprintf>
    if ((pid = fork()) == 0) {
  80057c:	bc5ff0ef          	jal	ra,800140 <fork>
  800580:	c569                	beqz	a0,80064a <main+0xe0>
  800582:	842a                	mv	s0,a0
        yield();
        yield();
        exit(magic);
    }
    else {
        cprintf("I am parent, fork a child pid %d\n",pid);
  800584:	85aa                	mv	a1,a0
  800586:	00000517          	auipc	a0,0x0
  80058a:	48a50513          	addi	a0,a0,1162 # 800a10 <error_string+0x200>
  80058e:	b13ff0ef          	jal	ra,8000a0 <cprintf>
    }
    assert(pid > 0);
  800592:	08805d63          	blez	s0,80062c <main+0xc2>
    cprintf("I am the parent, waiting now..\n");
  800596:	00000517          	auipc	a0,0x0
  80059a:	4d250513          	addi	a0,a0,1234 # 800a68 <error_string+0x258>
  80059e:	b03ff0ef          	jal	ra,8000a0 <cprintf>

    assert(waitpid(pid, &code) == 0 && code == magic);
  8005a2:	006c                	addi	a1,sp,12
  8005a4:	8522                	mv	a0,s0
  8005a6:	ba3ff0ef          	jal	ra,800148 <waitpid>
  8005aa:	e139                	bnez	a0,8005f0 <main+0x86>
  8005ac:	00001797          	auipc	a5,0x1
  8005b0:	a5478793          	addi	a5,a5,-1452 # 801000 <magic>
  8005b4:	4732                	lw	a4,12(sp)
  8005b6:	439c                	lw	a5,0(a5)
  8005b8:	02f71c63          	bne	a4,a5,8005f0 <main+0x86>
    assert(waitpid(pid, &code) != 0 && wait() != 0);
  8005bc:	006c                	addi	a1,sp,12
  8005be:	8522                	mv	a0,s0
  8005c0:	b89ff0ef          	jal	ra,800148 <waitpid>
  8005c4:	c529                	beqz	a0,80060e <main+0xa4>
  8005c6:	b7dff0ef          	jal	ra,800142 <wait>
  8005ca:	c131                	beqz	a0,80060e <main+0xa4>
    cprintf("waitpid %d ok.\n", pid);
  8005cc:	85a2                	mv	a1,s0
  8005ce:	00000517          	auipc	a0,0x0
  8005d2:	51250513          	addi	a0,a0,1298 # 800ae0 <error_string+0x2d0>
  8005d6:	acbff0ef          	jal	ra,8000a0 <cprintf>

    cprintf("exit pass.\n");
  8005da:	00000517          	auipc	a0,0x0
  8005de:	51650513          	addi	a0,a0,1302 # 800af0 <error_string+0x2e0>
  8005e2:	abfff0ef          	jal	ra,8000a0 <cprintf>
    return 0;
}
  8005e6:	60e2                	ld	ra,24(sp)
  8005e8:	6442                	ld	s0,16(sp)
  8005ea:	4501                	li	a0,0
  8005ec:	6105                	addi	sp,sp,32
  8005ee:	8082                	ret
    assert(waitpid(pid, &code) == 0 && code == magic);
  8005f0:	00000697          	auipc	a3,0x0
  8005f4:	49868693          	addi	a3,a3,1176 # 800a88 <error_string+0x278>
  8005f8:	00000617          	auipc	a2,0x0
  8005fc:	44860613          	addi	a2,a2,1096 # 800a40 <error_string+0x230>
  800600:	45ed                	li	a1,27
  800602:	00000517          	auipc	a0,0x0
  800606:	45650513          	addi	a0,a0,1110 # 800a58 <error_string+0x248>
  80060a:	a1dff0ef          	jal	ra,800026 <__panic>
    assert(waitpid(pid, &code) != 0 && wait() != 0);
  80060e:	00000697          	auipc	a3,0x0
  800612:	4aa68693          	addi	a3,a3,1194 # 800ab8 <error_string+0x2a8>
  800616:	00000617          	auipc	a2,0x0
  80061a:	42a60613          	addi	a2,a2,1066 # 800a40 <error_string+0x230>
  80061e:	45f1                	li	a1,28
  800620:	00000517          	auipc	a0,0x0
  800624:	43850513          	addi	a0,a0,1080 # 800a58 <error_string+0x248>
  800628:	9ffff0ef          	jal	ra,800026 <__panic>
    assert(pid > 0);
  80062c:	00000697          	auipc	a3,0x0
  800630:	40c68693          	addi	a3,a3,1036 # 800a38 <error_string+0x228>
  800634:	00000617          	auipc	a2,0x0
  800638:	40c60613          	addi	a2,a2,1036 # 800a40 <error_string+0x230>
  80063c:	45e1                	li	a1,24
  80063e:	00000517          	auipc	a0,0x0
  800642:	41a50513          	addi	a0,a0,1050 # 800a58 <error_string+0x248>
  800646:	9e1ff0ef          	jal	ra,800026 <__panic>
        cprintf("I am the child.\n");
  80064a:	00000517          	auipc	a0,0x0
  80064e:	3ae50513          	addi	a0,a0,942 # 8009f8 <error_string+0x1e8>
  800652:	a4fff0ef          	jal	ra,8000a0 <cprintf>
        yield();
  800656:	af5ff0ef          	jal	ra,80014a <yield>
        yield();
  80065a:	af1ff0ef          	jal	ra,80014a <yield>
        yield();
  80065e:	aedff0ef          	jal	ra,80014a <yield>
        yield();
  800662:	ae9ff0ef          	jal	ra,80014a <yield>
        yield();
  800666:	ae5ff0ef          	jal	ra,80014a <yield>
        yield();
  80066a:	ae1ff0ef          	jal	ra,80014a <yield>
        yield();
  80066e:	addff0ef          	jal	ra,80014a <yield>
        exit(magic);
  800672:	00001797          	auipc	a5,0x1
  800676:	98e78793          	addi	a5,a5,-1650 # 801000 <magic>
  80067a:	4388                	lw	a0,0(a5)
  80067c:	aafff0ef          	jal	ra,80012a <exit>
