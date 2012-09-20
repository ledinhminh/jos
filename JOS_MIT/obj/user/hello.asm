
obj/user/hello.debug:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("hello, world\n");
  80003a:	c7 04 24 c0 22 80 00 	movl   $0x8022c0,(%esp)
  800041:	e8 e7 00 00 00       	call   80012d <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800046:	a1 08 40 80 00       	mov    0x804008,%eax
  80004b:	8b 40 48             	mov    0x48(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 ce 22 80 00 	movl   $0x8022ce,(%esp)
  800059:	e8 cf 00 00 00       	call   80012d <cprintf>
}
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	83 ec 18             	sub    $0x18,%esp
  800066:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800069:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80006c:	8b 75 08             	mov    0x8(%ebp),%esi
  80006f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  800072:	e8 00 0f 00 00       	call   800f77 <sys_getenvid>
  800077:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007c:	c1 e0 07             	shl    $0x7,%eax
  80007f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800084:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800089:	85 f6                	test   %esi,%esi
  80008b:	7e 07                	jle    800094 <libmain+0x34>
		binaryname = argv[0];
  80008d:	8b 03                	mov    (%ebx),%eax
  80008f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800094:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800098:	89 34 24             	mov    %esi,(%esp)
  80009b:	e8 94 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a0:	e8 0b 00 00 00       	call   8000b0 <exit>
}
  8000a5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000a8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000ab:	89 ec                	mov    %ebp,%esp
  8000ad:	5d                   	pop    %ebp
  8000ae:	c3                   	ret    
	...

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000b6:	e8 8e 14 00 00       	call   801549 <close_all>
	sys_env_destroy(0);
  8000bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c2:	e8 eb 0e 00 00       	call   800fb2 <sys_env_destroy>
}
  8000c7:	c9                   	leave  
  8000c8:	c3                   	ret    
  8000c9:	00 00                	add    %al,(%eax)
	...

008000cc <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000dc:	00 00 00 
	b.cnt = 0;
  8000df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8000f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000f7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8000fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800101:	c7 04 24 47 01 80 00 	movl   $0x800147,(%esp)
  800108:	e8 d0 01 00 00       	call   8002dd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80010d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800113:	89 44 24 04          	mov    %eax,0x4(%esp)
  800117:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80011d:	89 04 24             	mov    %eax,(%esp)
  800120:	e8 01 0f 00 00       	call   801026 <sys_cputs>

	return b.cnt;
}
  800125:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80012b:	c9                   	leave  
  80012c:	c3                   	ret    

0080012d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80012d:	55                   	push   %ebp
  80012e:	89 e5                	mov    %esp,%ebp
  800130:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800133:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800136:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013a:	8b 45 08             	mov    0x8(%ebp),%eax
  80013d:	89 04 24             	mov    %eax,(%esp)
  800140:	e8 87 ff ff ff       	call   8000cc <vcprintf>
	va_end(ap);

	return cnt;
}
  800145:	c9                   	leave  
  800146:	c3                   	ret    

00800147 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	53                   	push   %ebx
  80014b:	83 ec 14             	sub    $0x14,%esp
  80014e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800151:	8b 03                	mov    (%ebx),%eax
  800153:	8b 55 08             	mov    0x8(%ebp),%edx
  800156:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80015a:	83 c0 01             	add    $0x1,%eax
  80015d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80015f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800164:	75 19                	jne    80017f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800166:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80016d:	00 
  80016e:	8d 43 08             	lea    0x8(%ebx),%eax
  800171:	89 04 24             	mov    %eax,(%esp)
  800174:	e8 ad 0e 00 00       	call   801026 <sys_cputs>
		b->idx = 0;
  800179:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80017f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800183:	83 c4 14             	add    $0x14,%esp
  800186:	5b                   	pop    %ebx
  800187:	5d                   	pop    %ebp
  800188:	c3                   	ret    
  800189:	00 00                	add    %al,(%eax)
  80018b:	00 00                	add    %al,(%eax)
  80018d:	00 00                	add    %al,(%eax)
	...

00800190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 4c             	sub    $0x4c,%esp
  800199:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80019c:	89 d6                	mov    %edx,%esi
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001b0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001bb:	39 d1                	cmp    %edx,%ecx
  8001bd:	72 15                	jb     8001d4 <printnum+0x44>
  8001bf:	77 07                	ja     8001c8 <printnum+0x38>
  8001c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001c4:	39 d0                	cmp    %edx,%eax
  8001c6:	76 0c                	jbe    8001d4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c8:	83 eb 01             	sub    $0x1,%ebx
  8001cb:	85 db                	test   %ebx,%ebx
  8001cd:	8d 76 00             	lea    0x0(%esi),%esi
  8001d0:	7f 61                	jg     800233 <printnum+0xa3>
  8001d2:	eb 70                	jmp    800244 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001d8:	83 eb 01             	sub    $0x1,%ebx
  8001db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8001e7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8001eb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8001ee:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8001f1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8001f4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001ff:	00 
  800200:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800203:	89 04 24             	mov    %eax,(%esp)
  800206:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800209:	89 54 24 04          	mov    %edx,0x4(%esp)
  80020d:	e8 2e 1e 00 00       	call   802040 <__udivdi3>
  800212:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800215:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800218:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80021c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800220:	89 04 24             	mov    %eax,(%esp)
  800223:	89 54 24 04          	mov    %edx,0x4(%esp)
  800227:	89 f2                	mov    %esi,%edx
  800229:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80022c:	e8 5f ff ff ff       	call   800190 <printnum>
  800231:	eb 11                	jmp    800244 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800233:	89 74 24 04          	mov    %esi,0x4(%esp)
  800237:	89 3c 24             	mov    %edi,(%esp)
  80023a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023d:	83 eb 01             	sub    $0x1,%ebx
  800240:	85 db                	test   %ebx,%ebx
  800242:	7f ef                	jg     800233 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800244:	89 74 24 04          	mov    %esi,0x4(%esp)
  800248:	8b 74 24 04          	mov    0x4(%esp),%esi
  80024c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80024f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800253:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80025a:	00 
  80025b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80025e:	89 14 24             	mov    %edx,(%esp)
  800261:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800264:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800268:	e8 03 1f 00 00       	call   802170 <__umoddi3>
  80026d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800271:	0f be 80 ef 22 80 00 	movsbl 0x8022ef(%eax),%eax
  800278:	89 04 24             	mov    %eax,(%esp)
  80027b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80027e:	83 c4 4c             	add    $0x4c,%esp
  800281:	5b                   	pop    %ebx
  800282:	5e                   	pop    %esi
  800283:	5f                   	pop    %edi
  800284:	5d                   	pop    %ebp
  800285:	c3                   	ret    

00800286 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800289:	83 fa 01             	cmp    $0x1,%edx
  80028c:	7e 0e                	jle    80029c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80028e:	8b 10                	mov    (%eax),%edx
  800290:	8d 4a 08             	lea    0x8(%edx),%ecx
  800293:	89 08                	mov    %ecx,(%eax)
  800295:	8b 02                	mov    (%edx),%eax
  800297:	8b 52 04             	mov    0x4(%edx),%edx
  80029a:	eb 22                	jmp    8002be <getuint+0x38>
	else if (lflag)
  80029c:	85 d2                	test   %edx,%edx
  80029e:	74 10                	je     8002b0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002a0:	8b 10                	mov    (%eax),%edx
  8002a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a5:	89 08                	mov    %ecx,(%eax)
  8002a7:	8b 02                	mov    (%edx),%eax
  8002a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ae:	eb 0e                	jmp    8002be <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002b0:	8b 10                	mov    (%eax),%edx
  8002b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b5:	89 08                	mov    %ecx,(%eax)
  8002b7:	8b 02                	mov    (%edx),%eax
  8002b9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002be:	5d                   	pop    %ebp
  8002bf:	c3                   	ret    

008002c0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ca:	8b 10                	mov    (%eax),%edx
  8002cc:	3b 50 04             	cmp    0x4(%eax),%edx
  8002cf:	73 0a                	jae    8002db <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d4:	88 0a                	mov    %cl,(%edx)
  8002d6:	83 c2 01             	add    $0x1,%edx
  8002d9:	89 10                	mov    %edx,(%eax)
}
  8002db:	5d                   	pop    %ebp
  8002dc:	c3                   	ret    

008002dd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002dd:	55                   	push   %ebp
  8002de:	89 e5                	mov    %esp,%ebp
  8002e0:	57                   	push   %edi
  8002e1:	56                   	push   %esi
  8002e2:	53                   	push   %ebx
  8002e3:	83 ec 5c             	sub    $0x5c,%esp
  8002e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002e9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8002ef:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002f6:	eb 11                	jmp    800309 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f8:	85 c0                	test   %eax,%eax
  8002fa:	0f 84 68 04 00 00    	je     800768 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  800300:	89 74 24 04          	mov    %esi,0x4(%esp)
  800304:	89 04 24             	mov    %eax,(%esp)
  800307:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800309:	0f b6 03             	movzbl (%ebx),%eax
  80030c:	83 c3 01             	add    $0x1,%ebx
  80030f:	83 f8 25             	cmp    $0x25,%eax
  800312:	75 e4                	jne    8002f8 <vprintfmt+0x1b>
  800314:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80031b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800322:	b9 00 00 00 00       	mov    $0x0,%ecx
  800327:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  80032b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800332:	eb 06                	jmp    80033a <vprintfmt+0x5d>
  800334:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  800338:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	0f b6 13             	movzbl (%ebx),%edx
  80033d:	0f b6 c2             	movzbl %dl,%eax
  800340:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800343:	8d 43 01             	lea    0x1(%ebx),%eax
  800346:	83 ea 23             	sub    $0x23,%edx
  800349:	80 fa 55             	cmp    $0x55,%dl
  80034c:	0f 87 f9 03 00 00    	ja     80074b <vprintfmt+0x46e>
  800352:	0f b6 d2             	movzbl %dl,%edx
  800355:	ff 24 95 c0 24 80 00 	jmp    *0x8024c0(,%edx,4)
  80035c:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800360:	eb d6                	jmp    800338 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800362:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800365:	83 ea 30             	sub    $0x30,%edx
  800368:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80036b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80036e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800371:	83 fb 09             	cmp    $0x9,%ebx
  800374:	77 54                	ja     8003ca <vprintfmt+0xed>
  800376:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800379:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80037c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80037f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800382:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800386:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800389:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80038c:	83 fb 09             	cmp    $0x9,%ebx
  80038f:	76 eb                	jbe    80037c <vprintfmt+0x9f>
  800391:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800394:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800397:	eb 31                	jmp    8003ca <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800399:	8b 55 14             	mov    0x14(%ebp),%edx
  80039c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80039f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8003a2:	8b 12                	mov    (%edx),%edx
  8003a4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8003a7:	eb 21                	jmp    8003ca <vprintfmt+0xed>

		case '.':
			if (width < 0)
  8003a9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b2:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  8003b6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003b9:	e9 7a ff ff ff       	jmp    800338 <vprintfmt+0x5b>
  8003be:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003c5:	e9 6e ff ff ff       	jmp    800338 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8003ca:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003ce:	0f 89 64 ff ff ff    	jns    800338 <vprintfmt+0x5b>
  8003d4:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8003d7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003da:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8003dd:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8003e0:	e9 53 ff ff ff       	jmp    800338 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e5:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8003e8:	e9 4b ff ff ff       	jmp    800338 <vprintfmt+0x5b>
  8003ed:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f3:	8d 50 04             	lea    0x4(%eax),%edx
  8003f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003fd:	8b 00                	mov    (%eax),%eax
  8003ff:	89 04 24             	mov    %eax,(%esp)
  800402:	ff d7                	call   *%edi
  800404:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800407:	e9 fd fe ff ff       	jmp    800309 <vprintfmt+0x2c>
  80040c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040f:	8b 45 14             	mov    0x14(%ebp),%eax
  800412:	8d 50 04             	lea    0x4(%eax),%edx
  800415:	89 55 14             	mov    %edx,0x14(%ebp)
  800418:	8b 00                	mov    (%eax),%eax
  80041a:	89 c2                	mov    %eax,%edx
  80041c:	c1 fa 1f             	sar    $0x1f,%edx
  80041f:	31 d0                	xor    %edx,%eax
  800421:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800423:	83 f8 0f             	cmp    $0xf,%eax
  800426:	7f 0b                	jg     800433 <vprintfmt+0x156>
  800428:	8b 14 85 20 26 80 00 	mov    0x802620(,%eax,4),%edx
  80042f:	85 d2                	test   %edx,%edx
  800431:	75 20                	jne    800453 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800433:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800437:	c7 44 24 08 00 23 80 	movl   $0x802300,0x8(%esp)
  80043e:	00 
  80043f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800443:	89 3c 24             	mov    %edi,(%esp)
  800446:	e8 a5 03 00 00       	call   8007f0 <printfmt>
  80044b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044e:	e9 b6 fe ff ff       	jmp    800309 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800453:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800457:	c7 44 24 08 3b 27 80 	movl   $0x80273b,0x8(%esp)
  80045e:	00 
  80045f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800463:	89 3c 24             	mov    %edi,(%esp)
  800466:	e8 85 03 00 00       	call   8007f0 <printfmt>
  80046b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80046e:	e9 96 fe ff ff       	jmp    800309 <vprintfmt+0x2c>
  800473:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800476:	89 c3                	mov    %eax,%ebx
  800478:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80047b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80047e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800481:	8b 45 14             	mov    0x14(%ebp),%eax
  800484:	8d 50 04             	lea    0x4(%eax),%edx
  800487:	89 55 14             	mov    %edx,0x14(%ebp)
  80048a:	8b 00                	mov    (%eax),%eax
  80048c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80048f:	85 c0                	test   %eax,%eax
  800491:	b8 09 23 80 00       	mov    $0x802309,%eax
  800496:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  80049a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80049d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8004a1:	7e 06                	jle    8004a9 <vprintfmt+0x1cc>
  8004a3:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8004a7:	75 13                	jne    8004bc <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004ac:	0f be 02             	movsbl (%edx),%eax
  8004af:	85 c0                	test   %eax,%eax
  8004b1:	0f 85 a2 00 00 00    	jne    800559 <vprintfmt+0x27c>
  8004b7:	e9 8f 00 00 00       	jmp    80054b <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004c0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004c3:	89 0c 24             	mov    %ecx,(%esp)
  8004c6:	e8 70 03 00 00       	call   80083b <strnlen>
  8004cb:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004ce:	29 c2                	sub    %eax,%edx
  8004d0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004d3:	85 d2                	test   %edx,%edx
  8004d5:	7e d2                	jle    8004a9 <vprintfmt+0x1cc>
					putch(padc, putdat);
  8004d7:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8004db:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004de:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  8004e1:	89 d3                	mov    %edx,%ebx
  8004e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ea:	89 04 24             	mov    %eax,(%esp)
  8004ed:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ef:	83 eb 01             	sub    $0x1,%ebx
  8004f2:	85 db                	test   %ebx,%ebx
  8004f4:	7f ed                	jg     8004e3 <vprintfmt+0x206>
  8004f6:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8004f9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800500:	eb a7                	jmp    8004a9 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800502:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800506:	74 1b                	je     800523 <vprintfmt+0x246>
  800508:	8d 50 e0             	lea    -0x20(%eax),%edx
  80050b:	83 fa 5e             	cmp    $0x5e,%edx
  80050e:	76 13                	jbe    800523 <vprintfmt+0x246>
					putch('?', putdat);
  800510:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800513:	89 54 24 04          	mov    %edx,0x4(%esp)
  800517:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80051e:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800521:	eb 0d                	jmp    800530 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800523:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800526:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80052a:	89 04 24             	mov    %eax,(%esp)
  80052d:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800530:	83 ef 01             	sub    $0x1,%edi
  800533:	0f be 03             	movsbl (%ebx),%eax
  800536:	85 c0                	test   %eax,%eax
  800538:	74 05                	je     80053f <vprintfmt+0x262>
  80053a:	83 c3 01             	add    $0x1,%ebx
  80053d:	eb 31                	jmp    800570 <vprintfmt+0x293>
  80053f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800542:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800545:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800548:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80054b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80054f:	7f 36                	jg     800587 <vprintfmt+0x2aa>
  800551:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800554:	e9 b0 fd ff ff       	jmp    800309 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800559:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80055c:	83 c2 01             	add    $0x1,%edx
  80055f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800562:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800565:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800568:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80056b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80056e:	89 d3                	mov    %edx,%ebx
  800570:	85 f6                	test   %esi,%esi
  800572:	78 8e                	js     800502 <vprintfmt+0x225>
  800574:	83 ee 01             	sub    $0x1,%esi
  800577:	79 89                	jns    800502 <vprintfmt+0x225>
  800579:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80057c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80057f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800582:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800585:	eb c4                	jmp    80054b <vprintfmt+0x26e>
  800587:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80058a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800591:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800598:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059a:	83 eb 01             	sub    $0x1,%ebx
  80059d:	85 db                	test   %ebx,%ebx
  80059f:	7f ec                	jg     80058d <vprintfmt+0x2b0>
  8005a1:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8005a4:	e9 60 fd ff ff       	jmp    800309 <vprintfmt+0x2c>
  8005a9:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ac:	83 f9 01             	cmp    $0x1,%ecx
  8005af:	7e 16                	jle    8005c7 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8d 50 08             	lea    0x8(%eax),%edx
  8005b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ba:	8b 10                	mov    (%eax),%edx
  8005bc:	8b 48 04             	mov    0x4(%eax),%ecx
  8005bf:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005c2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c5:	eb 32                	jmp    8005f9 <vprintfmt+0x31c>
	else if (lflag)
  8005c7:	85 c9                	test   %ecx,%ecx
  8005c9:	74 18                	je     8005e3 <vprintfmt+0x306>
		return va_arg(*ap, long);
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8d 50 04             	lea    0x4(%eax),%edx
  8005d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d4:	8b 00                	mov    (%eax),%eax
  8005d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d9:	89 c1                	mov    %eax,%ecx
  8005db:	c1 f9 1f             	sar    $0x1f,%ecx
  8005de:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e1:	eb 16                	jmp    8005f9 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8d 50 04             	lea    0x4(%eax),%edx
  8005e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ec:	8b 00                	mov    (%eax),%eax
  8005ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f1:	89 c2                	mov    %eax,%edx
  8005f3:	c1 fa 1f             	sar    $0x1f,%edx
  8005f6:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005ff:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  800604:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800608:	0f 89 8a 00 00 00    	jns    800698 <vprintfmt+0x3bb>
				putch('-', putdat);
  80060e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800612:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800619:	ff d7                	call   *%edi
				num = -(long long) num;
  80061b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80061e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800621:	f7 d8                	neg    %eax
  800623:	83 d2 00             	adc    $0x0,%edx
  800626:	f7 da                	neg    %edx
  800628:	eb 6e                	jmp    800698 <vprintfmt+0x3bb>
  80062a:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80062d:	89 ca                	mov    %ecx,%edx
  80062f:	8d 45 14             	lea    0x14(%ebp),%eax
  800632:	e8 4f fc ff ff       	call   800286 <getuint>
  800637:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  80063c:	eb 5a                	jmp    800698 <vprintfmt+0x3bb>
  80063e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800641:	89 ca                	mov    %ecx,%edx
  800643:	8d 45 14             	lea    0x14(%ebp),%eax
  800646:	e8 3b fc ff ff       	call   800286 <getuint>
  80064b:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  800650:	eb 46                	jmp    800698 <vprintfmt+0x3bb>
  800652:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  800655:	89 74 24 04          	mov    %esi,0x4(%esp)
  800659:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800660:	ff d7                	call   *%edi
			putch('x', putdat);
  800662:	89 74 24 04          	mov    %esi,0x4(%esp)
  800666:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80066d:	ff d7                	call   *%edi
			num = (unsigned long long)
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8d 50 04             	lea    0x4(%eax),%edx
  800675:	89 55 14             	mov    %edx,0x14(%ebp)
  800678:	8b 00                	mov    (%eax),%eax
  80067a:	ba 00 00 00 00       	mov    $0x0,%edx
  80067f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800684:	eb 12                	jmp    800698 <vprintfmt+0x3bb>
  800686:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800689:	89 ca                	mov    %ecx,%edx
  80068b:	8d 45 14             	lea    0x14(%ebp),%eax
  80068e:	e8 f3 fb ff ff       	call   800286 <getuint>
  800693:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800698:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80069c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8006a0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8006a3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8006a7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8006ab:	89 04 24             	mov    %eax,(%esp)
  8006ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006b2:	89 f2                	mov    %esi,%edx
  8006b4:	89 f8                	mov    %edi,%eax
  8006b6:	e8 d5 fa ff ff       	call   800190 <printnum>
  8006bb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8006be:	e9 46 fc ff ff       	jmp    800309 <vprintfmt+0x2c>
  8006c3:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8d 50 04             	lea    0x4(%eax),%edx
  8006cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cf:	8b 00                	mov    (%eax),%eax
  8006d1:	85 c0                	test   %eax,%eax
  8006d3:	75 24                	jne    8006f9 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  8006d5:	c7 44 24 0c 24 24 80 	movl   $0x802424,0xc(%esp)
  8006dc:	00 
  8006dd:	c7 44 24 08 3b 27 80 	movl   $0x80273b,0x8(%esp)
  8006e4:	00 
  8006e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006e9:	89 3c 24             	mov    %edi,(%esp)
  8006ec:	e8 ff 00 00 00       	call   8007f0 <printfmt>
  8006f1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8006f4:	e9 10 fc ff ff       	jmp    800309 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  8006f9:	83 3e 7f             	cmpl   $0x7f,(%esi)
  8006fc:	7e 29                	jle    800727 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  8006fe:	0f b6 16             	movzbl (%esi),%edx
  800701:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  800703:	c7 44 24 0c 5c 24 80 	movl   $0x80245c,0xc(%esp)
  80070a:	00 
  80070b:	c7 44 24 08 3b 27 80 	movl   $0x80273b,0x8(%esp)
  800712:	00 
  800713:	89 74 24 04          	mov    %esi,0x4(%esp)
  800717:	89 3c 24             	mov    %edi,(%esp)
  80071a:	e8 d1 00 00 00       	call   8007f0 <printfmt>
  80071f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800722:	e9 e2 fb ff ff       	jmp    800309 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  800727:	0f b6 16             	movzbl (%esi),%edx
  80072a:	88 10                	mov    %dl,(%eax)
  80072c:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  80072f:	e9 d5 fb ff ff       	jmp    800309 <vprintfmt+0x2c>
  800734:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800737:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80073a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80073e:	89 14 24             	mov    %edx,(%esp)
  800741:	ff d7                	call   *%edi
  800743:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800746:	e9 be fb ff ff       	jmp    800309 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80074b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80074f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800756:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800758:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80075b:	80 38 25             	cmpb   $0x25,(%eax)
  80075e:	0f 84 a5 fb ff ff    	je     800309 <vprintfmt+0x2c>
  800764:	89 c3                	mov    %eax,%ebx
  800766:	eb f0                	jmp    800758 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  800768:	83 c4 5c             	add    $0x5c,%esp
  80076b:	5b                   	pop    %ebx
  80076c:	5e                   	pop    %esi
  80076d:	5f                   	pop    %edi
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	83 ec 28             	sub    $0x28,%esp
  800776:	8b 45 08             	mov    0x8(%ebp),%eax
  800779:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80077c:	85 c0                	test   %eax,%eax
  80077e:	74 04                	je     800784 <vsnprintf+0x14>
  800780:	85 d2                	test   %edx,%edx
  800782:	7f 07                	jg     80078b <vsnprintf+0x1b>
  800784:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800789:	eb 3b                	jmp    8007c6 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80078b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80078e:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800792:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800795:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80079c:	8b 45 14             	mov    0x14(%ebp),%eax
  80079f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007aa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b1:	c7 04 24 c0 02 80 00 	movl   $0x8002c0,(%esp)
  8007b8:	e8 20 fb ff ff       	call   8002dd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007c6:	c9                   	leave  
  8007c7:	c3                   	ret    

008007c8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8007ce:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8007d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e6:	89 04 24             	mov    %eax,(%esp)
  8007e9:	e8 82 ff ff ff       	call   800770 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ee:	c9                   	leave  
  8007ef:	c3                   	ret    

008007f0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8007f6:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8007f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007fd:	8b 45 10             	mov    0x10(%ebp),%eax
  800800:	89 44 24 08          	mov    %eax,0x8(%esp)
  800804:	8b 45 0c             	mov    0xc(%ebp),%eax
  800807:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	89 04 24             	mov    %eax,(%esp)
  800811:	e8 c7 fa ff ff       	call   8002dd <vprintfmt>
	va_end(ap);
}
  800816:	c9                   	leave  
  800817:	c3                   	ret    
	...

00800820 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800826:	b8 00 00 00 00       	mov    $0x0,%eax
  80082b:	80 3a 00             	cmpb   $0x0,(%edx)
  80082e:	74 09                	je     800839 <strlen+0x19>
		n++;
  800830:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800833:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800837:	75 f7                	jne    800830 <strlen+0x10>
		n++;
	return n;
}
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	53                   	push   %ebx
  80083f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800842:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800845:	85 c9                	test   %ecx,%ecx
  800847:	74 19                	je     800862 <strnlen+0x27>
  800849:	80 3b 00             	cmpb   $0x0,(%ebx)
  80084c:	74 14                	je     800862 <strnlen+0x27>
  80084e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800853:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800856:	39 c8                	cmp    %ecx,%eax
  800858:	74 0d                	je     800867 <strnlen+0x2c>
  80085a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80085e:	75 f3                	jne    800853 <strnlen+0x18>
  800860:	eb 05                	jmp    800867 <strnlen+0x2c>
  800862:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800867:	5b                   	pop    %ebx
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	53                   	push   %ebx
  80086e:	8b 45 08             	mov    0x8(%ebp),%eax
  800871:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800874:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800879:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80087d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800880:	83 c2 01             	add    $0x1,%edx
  800883:	84 c9                	test   %cl,%cl
  800885:	75 f2                	jne    800879 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800887:	5b                   	pop    %ebx
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	53                   	push   %ebx
  80088e:	83 ec 08             	sub    $0x8,%esp
  800891:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800894:	89 1c 24             	mov    %ebx,(%esp)
  800897:	e8 84 ff ff ff       	call   800820 <strlen>
	strcpy(dst + len, src);
  80089c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089f:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008a3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8008a6:	89 04 24             	mov    %eax,(%esp)
  8008a9:	e8 bc ff ff ff       	call   80086a <strcpy>
	return dst;
}
  8008ae:	89 d8                	mov    %ebx,%eax
  8008b0:	83 c4 08             	add    $0x8,%esp
  8008b3:	5b                   	pop    %ebx
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	56                   	push   %esi
  8008ba:	53                   	push   %ebx
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c4:	85 f6                	test   %esi,%esi
  8008c6:	74 18                	je     8008e0 <strncpy+0x2a>
  8008c8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008cd:	0f b6 1a             	movzbl (%edx),%ebx
  8008d0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d3:	80 3a 01             	cmpb   $0x1,(%edx)
  8008d6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d9:	83 c1 01             	add    $0x1,%ecx
  8008dc:	39 ce                	cmp    %ecx,%esi
  8008de:	77 ed                	ja     8008cd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008e0:	5b                   	pop    %ebx
  8008e1:	5e                   	pop    %esi
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
  8008e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f2:	89 f0                	mov    %esi,%eax
  8008f4:	85 c9                	test   %ecx,%ecx
  8008f6:	74 27                	je     80091f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8008f8:	83 e9 01             	sub    $0x1,%ecx
  8008fb:	74 1d                	je     80091a <strlcpy+0x36>
  8008fd:	0f b6 1a             	movzbl (%edx),%ebx
  800900:	84 db                	test   %bl,%bl
  800902:	74 16                	je     80091a <strlcpy+0x36>
			*dst++ = *src++;
  800904:	88 18                	mov    %bl,(%eax)
  800906:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800909:	83 e9 01             	sub    $0x1,%ecx
  80090c:	74 0e                	je     80091c <strlcpy+0x38>
			*dst++ = *src++;
  80090e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800911:	0f b6 1a             	movzbl (%edx),%ebx
  800914:	84 db                	test   %bl,%bl
  800916:	75 ec                	jne    800904 <strlcpy+0x20>
  800918:	eb 02                	jmp    80091c <strlcpy+0x38>
  80091a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80091c:	c6 00 00             	movb   $0x0,(%eax)
  80091f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800921:	5b                   	pop    %ebx
  800922:	5e                   	pop    %esi
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80092e:	0f b6 01             	movzbl (%ecx),%eax
  800931:	84 c0                	test   %al,%al
  800933:	74 15                	je     80094a <strcmp+0x25>
  800935:	3a 02                	cmp    (%edx),%al
  800937:	75 11                	jne    80094a <strcmp+0x25>
		p++, q++;
  800939:	83 c1 01             	add    $0x1,%ecx
  80093c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80093f:	0f b6 01             	movzbl (%ecx),%eax
  800942:	84 c0                	test   %al,%al
  800944:	74 04                	je     80094a <strcmp+0x25>
  800946:	3a 02                	cmp    (%edx),%al
  800948:	74 ef                	je     800939 <strcmp+0x14>
  80094a:	0f b6 c0             	movzbl %al,%eax
  80094d:	0f b6 12             	movzbl (%edx),%edx
  800950:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	53                   	push   %ebx
  800958:	8b 55 08             	mov    0x8(%ebp),%edx
  80095b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80095e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800961:	85 c0                	test   %eax,%eax
  800963:	74 23                	je     800988 <strncmp+0x34>
  800965:	0f b6 1a             	movzbl (%edx),%ebx
  800968:	84 db                	test   %bl,%bl
  80096a:	74 25                	je     800991 <strncmp+0x3d>
  80096c:	3a 19                	cmp    (%ecx),%bl
  80096e:	75 21                	jne    800991 <strncmp+0x3d>
  800970:	83 e8 01             	sub    $0x1,%eax
  800973:	74 13                	je     800988 <strncmp+0x34>
		n--, p++, q++;
  800975:	83 c2 01             	add    $0x1,%edx
  800978:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80097b:	0f b6 1a             	movzbl (%edx),%ebx
  80097e:	84 db                	test   %bl,%bl
  800980:	74 0f                	je     800991 <strncmp+0x3d>
  800982:	3a 19                	cmp    (%ecx),%bl
  800984:	74 ea                	je     800970 <strncmp+0x1c>
  800986:	eb 09                	jmp    800991 <strncmp+0x3d>
  800988:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80098d:	5b                   	pop    %ebx
  80098e:	5d                   	pop    %ebp
  80098f:	90                   	nop
  800990:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800991:	0f b6 02             	movzbl (%edx),%eax
  800994:	0f b6 11             	movzbl (%ecx),%edx
  800997:	29 d0                	sub    %edx,%eax
  800999:	eb f2                	jmp    80098d <strncmp+0x39>

0080099b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a5:	0f b6 10             	movzbl (%eax),%edx
  8009a8:	84 d2                	test   %dl,%dl
  8009aa:	74 18                	je     8009c4 <strchr+0x29>
		if (*s == c)
  8009ac:	38 ca                	cmp    %cl,%dl
  8009ae:	75 0a                	jne    8009ba <strchr+0x1f>
  8009b0:	eb 17                	jmp    8009c9 <strchr+0x2e>
  8009b2:	38 ca                	cmp    %cl,%dl
  8009b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009b8:	74 0f                	je     8009c9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ba:	83 c0 01             	add    $0x1,%eax
  8009bd:	0f b6 10             	movzbl (%eax),%edx
  8009c0:	84 d2                	test   %dl,%dl
  8009c2:	75 ee                	jne    8009b2 <strchr+0x17>
  8009c4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d5:	0f b6 10             	movzbl (%eax),%edx
  8009d8:	84 d2                	test   %dl,%dl
  8009da:	74 18                	je     8009f4 <strfind+0x29>
		if (*s == c)
  8009dc:	38 ca                	cmp    %cl,%dl
  8009de:	75 0a                	jne    8009ea <strfind+0x1f>
  8009e0:	eb 12                	jmp    8009f4 <strfind+0x29>
  8009e2:	38 ca                	cmp    %cl,%dl
  8009e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009e8:	74 0a                	je     8009f4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009ea:	83 c0 01             	add    $0x1,%eax
  8009ed:	0f b6 10             	movzbl (%eax),%edx
  8009f0:	84 d2                	test   %dl,%dl
  8009f2:	75 ee                	jne    8009e2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	83 ec 0c             	sub    $0xc,%esp
  8009fc:	89 1c 24             	mov    %ebx,(%esp)
  8009ff:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a03:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a07:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a10:	85 c9                	test   %ecx,%ecx
  800a12:	74 30                	je     800a44 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a14:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1a:	75 25                	jne    800a41 <memset+0x4b>
  800a1c:	f6 c1 03             	test   $0x3,%cl
  800a1f:	75 20                	jne    800a41 <memset+0x4b>
		c &= 0xFF;
  800a21:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a24:	89 d3                	mov    %edx,%ebx
  800a26:	c1 e3 08             	shl    $0x8,%ebx
  800a29:	89 d6                	mov    %edx,%esi
  800a2b:	c1 e6 18             	shl    $0x18,%esi
  800a2e:	89 d0                	mov    %edx,%eax
  800a30:	c1 e0 10             	shl    $0x10,%eax
  800a33:	09 f0                	or     %esi,%eax
  800a35:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800a37:	09 d8                	or     %ebx,%eax
  800a39:	c1 e9 02             	shr    $0x2,%ecx
  800a3c:	fc                   	cld    
  800a3d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a3f:	eb 03                	jmp    800a44 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a41:	fc                   	cld    
  800a42:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a44:	89 f8                	mov    %edi,%eax
  800a46:	8b 1c 24             	mov    (%esp),%ebx
  800a49:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a4d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a51:	89 ec                	mov    %ebp,%esp
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	83 ec 08             	sub    $0x8,%esp
  800a5b:	89 34 24             	mov    %esi,(%esp)
  800a5e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a62:	8b 45 08             	mov    0x8(%ebp),%eax
  800a65:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800a68:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a6b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a6d:	39 c6                	cmp    %eax,%esi
  800a6f:	73 35                	jae    800aa6 <memmove+0x51>
  800a71:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a74:	39 d0                	cmp    %edx,%eax
  800a76:	73 2e                	jae    800aa6 <memmove+0x51>
		s += n;
		d += n;
  800a78:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7a:	f6 c2 03             	test   $0x3,%dl
  800a7d:	75 1b                	jne    800a9a <memmove+0x45>
  800a7f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a85:	75 13                	jne    800a9a <memmove+0x45>
  800a87:	f6 c1 03             	test   $0x3,%cl
  800a8a:	75 0e                	jne    800a9a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800a8c:	83 ef 04             	sub    $0x4,%edi
  800a8f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a92:	c1 e9 02             	shr    $0x2,%ecx
  800a95:	fd                   	std    
  800a96:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a98:	eb 09                	jmp    800aa3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a9a:	83 ef 01             	sub    $0x1,%edi
  800a9d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800aa0:	fd                   	std    
  800aa1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aa3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aa4:	eb 20                	jmp    800ac6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aac:	75 15                	jne    800ac3 <memmove+0x6e>
  800aae:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ab4:	75 0d                	jne    800ac3 <memmove+0x6e>
  800ab6:	f6 c1 03             	test   $0x3,%cl
  800ab9:	75 08                	jne    800ac3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800abb:	c1 e9 02             	shr    $0x2,%ecx
  800abe:	fc                   	cld    
  800abf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac1:	eb 03                	jmp    800ac6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ac3:	fc                   	cld    
  800ac4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ac6:	8b 34 24             	mov    (%esp),%esi
  800ac9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800acd:	89 ec                	mov    %ebp,%esp
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ad7:	8b 45 10             	mov    0x10(%ebp),%eax
  800ada:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ade:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae8:	89 04 24             	mov    %eax,(%esp)
  800aeb:	e8 65 ff ff ff       	call   800a55 <memmove>
}
  800af0:	c9                   	leave  
  800af1:	c3                   	ret    

00800af2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
  800af8:	8b 75 08             	mov    0x8(%ebp),%esi
  800afb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800afe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b01:	85 c9                	test   %ecx,%ecx
  800b03:	74 36                	je     800b3b <memcmp+0x49>
		if (*s1 != *s2)
  800b05:	0f b6 06             	movzbl (%esi),%eax
  800b08:	0f b6 1f             	movzbl (%edi),%ebx
  800b0b:	38 d8                	cmp    %bl,%al
  800b0d:	74 20                	je     800b2f <memcmp+0x3d>
  800b0f:	eb 14                	jmp    800b25 <memcmp+0x33>
  800b11:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800b16:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800b1b:	83 c2 01             	add    $0x1,%edx
  800b1e:	83 e9 01             	sub    $0x1,%ecx
  800b21:	38 d8                	cmp    %bl,%al
  800b23:	74 12                	je     800b37 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800b25:	0f b6 c0             	movzbl %al,%eax
  800b28:	0f b6 db             	movzbl %bl,%ebx
  800b2b:	29 d8                	sub    %ebx,%eax
  800b2d:	eb 11                	jmp    800b40 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b2f:	83 e9 01             	sub    $0x1,%ecx
  800b32:	ba 00 00 00 00       	mov    $0x0,%edx
  800b37:	85 c9                	test   %ecx,%ecx
  800b39:	75 d6                	jne    800b11 <memcmp+0x1f>
  800b3b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5f                   	pop    %edi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b4b:	89 c2                	mov    %eax,%edx
  800b4d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b50:	39 d0                	cmp    %edx,%eax
  800b52:	73 15                	jae    800b69 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b54:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b58:	38 08                	cmp    %cl,(%eax)
  800b5a:	75 06                	jne    800b62 <memfind+0x1d>
  800b5c:	eb 0b                	jmp    800b69 <memfind+0x24>
  800b5e:	38 08                	cmp    %cl,(%eax)
  800b60:	74 07                	je     800b69 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b62:	83 c0 01             	add    $0x1,%eax
  800b65:	39 c2                	cmp    %eax,%edx
  800b67:	77 f5                	ja     800b5e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	57                   	push   %edi
  800b6f:	56                   	push   %esi
  800b70:	53                   	push   %ebx
  800b71:	83 ec 04             	sub    $0x4,%esp
  800b74:	8b 55 08             	mov    0x8(%ebp),%edx
  800b77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b7a:	0f b6 02             	movzbl (%edx),%eax
  800b7d:	3c 20                	cmp    $0x20,%al
  800b7f:	74 04                	je     800b85 <strtol+0x1a>
  800b81:	3c 09                	cmp    $0x9,%al
  800b83:	75 0e                	jne    800b93 <strtol+0x28>
		s++;
  800b85:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b88:	0f b6 02             	movzbl (%edx),%eax
  800b8b:	3c 20                	cmp    $0x20,%al
  800b8d:	74 f6                	je     800b85 <strtol+0x1a>
  800b8f:	3c 09                	cmp    $0x9,%al
  800b91:	74 f2                	je     800b85 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b93:	3c 2b                	cmp    $0x2b,%al
  800b95:	75 0c                	jne    800ba3 <strtol+0x38>
		s++;
  800b97:	83 c2 01             	add    $0x1,%edx
  800b9a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ba1:	eb 15                	jmp    800bb8 <strtol+0x4d>
	else if (*s == '-')
  800ba3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800baa:	3c 2d                	cmp    $0x2d,%al
  800bac:	75 0a                	jne    800bb8 <strtol+0x4d>
		s++, neg = 1;
  800bae:	83 c2 01             	add    $0x1,%edx
  800bb1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bb8:	85 db                	test   %ebx,%ebx
  800bba:	0f 94 c0             	sete   %al
  800bbd:	74 05                	je     800bc4 <strtol+0x59>
  800bbf:	83 fb 10             	cmp    $0x10,%ebx
  800bc2:	75 18                	jne    800bdc <strtol+0x71>
  800bc4:	80 3a 30             	cmpb   $0x30,(%edx)
  800bc7:	75 13                	jne    800bdc <strtol+0x71>
  800bc9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bcd:	8d 76 00             	lea    0x0(%esi),%esi
  800bd0:	75 0a                	jne    800bdc <strtol+0x71>
		s += 2, base = 16;
  800bd2:	83 c2 02             	add    $0x2,%edx
  800bd5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bda:	eb 15                	jmp    800bf1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bdc:	84 c0                	test   %al,%al
  800bde:	66 90                	xchg   %ax,%ax
  800be0:	74 0f                	je     800bf1 <strtol+0x86>
  800be2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800be7:	80 3a 30             	cmpb   $0x30,(%edx)
  800bea:	75 05                	jne    800bf1 <strtol+0x86>
		s++, base = 8;
  800bec:	83 c2 01             	add    $0x1,%edx
  800bef:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bf1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bf8:	0f b6 0a             	movzbl (%edx),%ecx
  800bfb:	89 cf                	mov    %ecx,%edi
  800bfd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c00:	80 fb 09             	cmp    $0x9,%bl
  800c03:	77 08                	ja     800c0d <strtol+0xa2>
			dig = *s - '0';
  800c05:	0f be c9             	movsbl %cl,%ecx
  800c08:	83 e9 30             	sub    $0x30,%ecx
  800c0b:	eb 1e                	jmp    800c2b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800c0d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800c10:	80 fb 19             	cmp    $0x19,%bl
  800c13:	77 08                	ja     800c1d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800c15:	0f be c9             	movsbl %cl,%ecx
  800c18:	83 e9 57             	sub    $0x57,%ecx
  800c1b:	eb 0e                	jmp    800c2b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800c1d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800c20:	80 fb 19             	cmp    $0x19,%bl
  800c23:	77 15                	ja     800c3a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800c25:	0f be c9             	movsbl %cl,%ecx
  800c28:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c2b:	39 f1                	cmp    %esi,%ecx
  800c2d:	7d 0b                	jge    800c3a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800c2f:	83 c2 01             	add    $0x1,%edx
  800c32:	0f af c6             	imul   %esi,%eax
  800c35:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c38:	eb be                	jmp    800bf8 <strtol+0x8d>
  800c3a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800c3c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c40:	74 05                	je     800c47 <strtol+0xdc>
		*endptr = (char *) s;
  800c42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c45:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c47:	89 ca                	mov    %ecx,%edx
  800c49:	f7 da                	neg    %edx
  800c4b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c4f:	0f 45 c2             	cmovne %edx,%eax
}
  800c52:	83 c4 04             	add    $0x4,%esp
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    
	...

00800c5c <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	83 ec 48             	sub    $0x48,%esp
  800c62:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c65:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c68:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c6b:	89 c6                	mov    %eax,%esi
  800c6d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800c70:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c72:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c75:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c7b:	51                   	push   %ecx
  800c7c:	52                   	push   %edx
  800c7d:	53                   	push   %ebx
  800c7e:	54                   	push   %esp
  800c7f:	55                   	push   %ebp
  800c80:	56                   	push   %esi
  800c81:	57                   	push   %edi
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	8d 35 8c 0c 80 00    	lea    0x800c8c,%esi
  800c8a:	0f 34                	sysenter 

00800c8c <.after_sysenter_label>:
  800c8c:	5f                   	pop    %edi
  800c8d:	5e                   	pop    %esi
  800c8e:	5d                   	pop    %ebp
  800c8f:	5c                   	pop    %esp
  800c90:	5b                   	pop    %ebx
  800c91:	5a                   	pop    %edx
  800c92:	59                   	pop    %ecx
  800c93:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800c95:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c99:	74 28                	je     800cc3 <.after_sysenter_label+0x37>
  800c9b:	85 c0                	test   %eax,%eax
  800c9d:	7e 24                	jle    800cc3 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ca3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ca7:	c7 44 24 08 60 26 80 	movl   $0x802660,0x8(%esp)
  800cae:	00 
  800caf:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800cb6:	00 
  800cb7:	c7 04 24 7d 26 80 00 	movl   $0x80267d,(%esp)
  800cbe:	e8 91 11 00 00       	call   801e54 <_panic>

	return ret;
}
  800cc3:	89 d0                	mov    %edx,%eax
  800cc5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cc8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ccb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cce:	89 ec                	mov    %ebp,%esp
  800cd0:	5d                   	pop    %ebp
  800cd1:	c3                   	ret    

00800cd2 <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  800cd8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800cdf:	00 
  800ce0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ce7:	00 
  800ce8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800cef:	00 
  800cf0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cf3:	89 04 24             	mov    %eax,(%esp)
  800cf6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cfe:	b8 10 00 00 00       	mov    $0x10,%eax
  800d03:	e8 54 ff ff ff       	call   800c5c <syscall>
}
  800d08:	c9                   	leave  
  800d09:	c3                   	ret    

00800d0a <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  800d10:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d17:	00 
  800d18:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d1f:	00 
  800d20:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d27:	00 
  800d28:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d2f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d34:	ba 00 00 00 00       	mov    $0x0,%edx
  800d39:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d3e:	e8 19 ff ff ff       	call   800c5c <syscall>
}
  800d43:	c9                   	leave  
  800d44:	c3                   	ret    

00800d45 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d4b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d52:	00 
  800d53:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d5a:	00 
  800d5b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d62:	00 
  800d63:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d6d:	ba 01 00 00 00       	mov    $0x1,%edx
  800d72:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d77:	e8 e0 fe ff ff       	call   800c5c <syscall>
}
  800d7c:	c9                   	leave  
  800d7d:	c3                   	ret    

00800d7e <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d84:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d8b:	00 
  800d8c:	8b 45 14             	mov    0x14(%ebp),%eax
  800d8f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d93:	8b 45 10             	mov    0x10(%ebp),%eax
  800d96:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d9d:	89 04 24             	mov    %eax,(%esp)
  800da0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da3:	ba 00 00 00 00       	mov    $0x0,%edx
  800da8:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dad:	e8 aa fe ff ff       	call   800c5c <syscall>
}
  800db2:	c9                   	leave  
  800db3:	c3                   	ret    

00800db4 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800dba:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dc1:	00 
  800dc2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800dc9:	00 
  800dca:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800dd1:	00 
  800dd2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd5:	89 04 24             	mov    %eax,(%esp)
  800dd8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ddb:	ba 01 00 00 00       	mov    $0x1,%edx
  800de0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800de5:	e8 72 fe ff ff       	call   800c5c <syscall>
}
  800dea:	c9                   	leave  
  800deb:	c3                   	ret    

00800dec <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800df2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800df9:	00 
  800dfa:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e01:	00 
  800e02:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e09:	00 
  800e0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e0d:	89 04 24             	mov    %eax,(%esp)
  800e10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e13:	ba 01 00 00 00       	mov    $0x1,%edx
  800e18:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e1d:	e8 3a fe ff ff       	call   800c5c <syscall>
}
  800e22:	c9                   	leave  
  800e23:	c3                   	ret    

00800e24 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800e2a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e31:	00 
  800e32:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e39:	00 
  800e3a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e41:	00 
  800e42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e45:	89 04 24             	mov    %eax,(%esp)
  800e48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4b:	ba 01 00 00 00       	mov    $0x1,%edx
  800e50:	b8 09 00 00 00       	mov    $0x9,%eax
  800e55:	e8 02 fe ff ff       	call   800c5c <syscall>
}
  800e5a:	c9                   	leave  
  800e5b:	c3                   	ret    

00800e5c <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800e62:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e69:	00 
  800e6a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e71:	00 
  800e72:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e79:	00 
  800e7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7d:	89 04 24             	mov    %eax,(%esp)
  800e80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e83:	ba 01 00 00 00       	mov    $0x1,%edx
  800e88:	b8 07 00 00 00       	mov    $0x7,%eax
  800e8d:	e8 ca fd ff ff       	call   800c5c <syscall>
}
  800e92:	c9                   	leave  
  800e93:	c3                   	ret    

00800e94 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800e9a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ea1:	00 
  800ea2:	8b 45 18             	mov    0x18(%ebp),%eax
  800ea5:	0b 45 14             	or     0x14(%ebp),%eax
  800ea8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800eac:	8b 45 10             	mov    0x10(%ebp),%eax
  800eaf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eb3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eb6:	89 04 24             	mov    %eax,(%esp)
  800eb9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ebc:	ba 01 00 00 00       	mov    $0x1,%edx
  800ec1:	b8 06 00 00 00       	mov    $0x6,%eax
  800ec6:	e8 91 fd ff ff       	call   800c5c <syscall>
}
  800ecb:	c9                   	leave  
  800ecc:	c3                   	ret    

00800ecd <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
  800ed0:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800ed3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800eda:	00 
  800edb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ee2:	00 
  800ee3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ee6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eed:	89 04 24             	mov    %eax,(%esp)
  800ef0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef3:	ba 01 00 00 00       	mov    $0x1,%edx
  800ef8:	b8 05 00 00 00       	mov    $0x5,%eax
  800efd:	e8 5a fd ff ff       	call   800c5c <syscall>
}
  800f02:	c9                   	leave  
  800f03:	c3                   	ret    

00800f04 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f0a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f11:	00 
  800f12:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f19:	00 
  800f1a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f21:	00 
  800f22:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f29:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f33:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f38:	e8 1f fd ff ff       	call   800c5c <syscall>
}
  800f3d:	c9                   	leave  
  800f3e:	c3                   	ret    

00800f3f <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  800f45:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f4c:	00 
  800f4d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f54:	00 
  800f55:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f5c:	00 
  800f5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f60:	89 04 24             	mov    %eax,(%esp)
  800f63:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f66:	ba 00 00 00 00       	mov    $0x0,%edx
  800f6b:	b8 04 00 00 00       	mov    $0x4,%eax
  800f70:	e8 e7 fc ff ff       	call   800c5c <syscall>
}
  800f75:	c9                   	leave  
  800f76:	c3                   	ret    

00800f77 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800f7d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f84:	00 
  800f85:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f8c:	00 
  800f8d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f94:	00 
  800f95:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f9c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fa1:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa6:	b8 02 00 00 00       	mov    $0x2,%eax
  800fab:	e8 ac fc ff ff       	call   800c5c <syscall>
}
  800fb0:	c9                   	leave  
  800fb1:	c3                   	ret    

00800fb2 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800fb2:	55                   	push   %ebp
  800fb3:	89 e5                	mov    %esp,%ebp
  800fb5:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800fb8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fbf:	00 
  800fc0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fc7:	00 
  800fc8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fcf:	00 
  800fd0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fd7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fda:	ba 01 00 00 00       	mov    $0x1,%edx
  800fdf:	b8 03 00 00 00       	mov    $0x3,%eax
  800fe4:	e8 73 fc ff ff       	call   800c5c <syscall>
}
  800fe9:	c9                   	leave  
  800fea:	c3                   	ret    

00800feb <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800feb:	55                   	push   %ebp
  800fec:	89 e5                	mov    %esp,%ebp
  800fee:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800ff1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ff8:	00 
  800ff9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801000:	00 
  801001:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801008:	00 
  801009:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801010:	b9 00 00 00 00       	mov    $0x0,%ecx
  801015:	ba 00 00 00 00       	mov    $0x0,%edx
  80101a:	b8 01 00 00 00       	mov    $0x1,%eax
  80101f:	e8 38 fc ff ff       	call   800c5c <syscall>
}
  801024:	c9                   	leave  
  801025:	c3                   	ret    

00801026 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801026:	55                   	push   %ebp
  801027:	89 e5                	mov    %esp,%ebp
  801029:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80102c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801033:	00 
  801034:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80103b:	00 
  80103c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801043:	00 
  801044:	8b 45 0c             	mov    0xc(%ebp),%eax
  801047:	89 04 24             	mov    %eax,(%esp)
  80104a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80104d:	ba 00 00 00 00       	mov    $0x0,%edx
  801052:	b8 00 00 00 00       	mov    $0x0,%eax
  801057:	e8 00 fc ff ff       	call   800c5c <syscall>
}
  80105c:	c9                   	leave  
  80105d:	c3                   	ret    
	...

00801060 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	8b 45 08             	mov    0x8(%ebp),%eax
  801066:	05 00 00 00 30       	add    $0x30000000,%eax
  80106b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80106e:	5d                   	pop    %ebp
  80106f:	c3                   	ret    

00801070 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801076:	8b 45 08             	mov    0x8(%ebp),%eax
  801079:	89 04 24             	mov    %eax,(%esp)
  80107c:	e8 df ff ff ff       	call   801060 <fd2num>
  801081:	05 20 00 0d 00       	add    $0xd0020,%eax
  801086:	c1 e0 0c             	shl    $0xc,%eax
}
  801089:	c9                   	leave  
  80108a:	c3                   	ret    

0080108b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80108b:	55                   	push   %ebp
  80108c:	89 e5                	mov    %esp,%ebp
  80108e:	57                   	push   %edi
  80108f:	56                   	push   %esi
  801090:	53                   	push   %ebx
  801091:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801094:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801099:	a8 01                	test   $0x1,%al
  80109b:	74 36                	je     8010d3 <fd_alloc+0x48>
  80109d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8010a2:	a8 01                	test   $0x1,%al
  8010a4:	74 2d                	je     8010d3 <fd_alloc+0x48>
  8010a6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8010ab:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8010b0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8010b5:	89 c3                	mov    %eax,%ebx
  8010b7:	89 c2                	mov    %eax,%edx
  8010b9:	c1 ea 16             	shr    $0x16,%edx
  8010bc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8010bf:	f6 c2 01             	test   $0x1,%dl
  8010c2:	74 14                	je     8010d8 <fd_alloc+0x4d>
  8010c4:	89 c2                	mov    %eax,%edx
  8010c6:	c1 ea 0c             	shr    $0xc,%edx
  8010c9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8010cc:	f6 c2 01             	test   $0x1,%dl
  8010cf:	75 10                	jne    8010e1 <fd_alloc+0x56>
  8010d1:	eb 05                	jmp    8010d8 <fd_alloc+0x4d>
  8010d3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8010d8:	89 1f                	mov    %ebx,(%edi)
  8010da:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8010df:	eb 17                	jmp    8010f8 <fd_alloc+0x6d>
  8010e1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010e6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010eb:	75 c8                	jne    8010b5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010ed:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8010f3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8010f8:	5b                   	pop    %ebx
  8010f9:	5e                   	pop    %esi
  8010fa:	5f                   	pop    %edi
  8010fb:	5d                   	pop    %ebp
  8010fc:	c3                   	ret    

008010fd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010fd:	55                   	push   %ebp
  8010fe:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801100:	8b 45 08             	mov    0x8(%ebp),%eax
  801103:	83 f8 1f             	cmp    $0x1f,%eax
  801106:	77 36                	ja     80113e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801108:	05 00 00 0d 00       	add    $0xd0000,%eax
  80110d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801110:	89 c2                	mov    %eax,%edx
  801112:	c1 ea 16             	shr    $0x16,%edx
  801115:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80111c:	f6 c2 01             	test   $0x1,%dl
  80111f:	74 1d                	je     80113e <fd_lookup+0x41>
  801121:	89 c2                	mov    %eax,%edx
  801123:	c1 ea 0c             	shr    $0xc,%edx
  801126:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80112d:	f6 c2 01             	test   $0x1,%dl
  801130:	74 0c                	je     80113e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801132:	8b 55 0c             	mov    0xc(%ebp),%edx
  801135:	89 02                	mov    %eax,(%edx)
  801137:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80113c:	eb 05                	jmp    801143 <fd_lookup+0x46>
  80113e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801143:	5d                   	pop    %ebp
  801144:	c3                   	ret    

00801145 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801145:	55                   	push   %ebp
  801146:	89 e5                	mov    %esp,%ebp
  801148:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80114b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80114e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801152:	8b 45 08             	mov    0x8(%ebp),%eax
  801155:	89 04 24             	mov    %eax,(%esp)
  801158:	e8 a0 ff ff ff       	call   8010fd <fd_lookup>
  80115d:	85 c0                	test   %eax,%eax
  80115f:	78 0e                	js     80116f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801161:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801164:	8b 55 0c             	mov    0xc(%ebp),%edx
  801167:	89 50 04             	mov    %edx,0x4(%eax)
  80116a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80116f:	c9                   	leave  
  801170:	c3                   	ret    

00801171 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801171:	55                   	push   %ebp
  801172:	89 e5                	mov    %esp,%ebp
  801174:	56                   	push   %esi
  801175:	53                   	push   %ebx
  801176:	83 ec 10             	sub    $0x10,%esp
  801179:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80117c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80117f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801184:	b8 04 30 80 00       	mov    $0x803004,%eax
  801189:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80118f:	75 11                	jne    8011a2 <dev_lookup+0x31>
  801191:	eb 04                	jmp    801197 <dev_lookup+0x26>
  801193:	39 08                	cmp    %ecx,(%eax)
  801195:	75 10                	jne    8011a7 <dev_lookup+0x36>
			*dev = devtab[i];
  801197:	89 03                	mov    %eax,(%ebx)
  801199:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80119e:	66 90                	xchg   %ax,%ax
  8011a0:	eb 36                	jmp    8011d8 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011a2:	be 08 27 80 00       	mov    $0x802708,%esi
  8011a7:	83 c2 01             	add    $0x1,%edx
  8011aa:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8011ad:	85 c0                	test   %eax,%eax
  8011af:	75 e2                	jne    801193 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011b1:	a1 08 40 80 00       	mov    0x804008,%eax
  8011b6:	8b 40 48             	mov    0x48(%eax),%eax
  8011b9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c1:	c7 04 24 8c 26 80 00 	movl   $0x80268c,(%esp)
  8011c8:	e8 60 ef ff ff       	call   80012d <cprintf>
	*dev = 0;
  8011cd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8011d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8011d8:	83 c4 10             	add    $0x10,%esp
  8011db:	5b                   	pop    %ebx
  8011dc:	5e                   	pop    %esi
  8011dd:	5d                   	pop    %ebp
  8011de:	c3                   	ret    

008011df <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8011df:	55                   	push   %ebp
  8011e0:	89 e5                	mov    %esp,%ebp
  8011e2:	53                   	push   %ebx
  8011e3:	83 ec 24             	sub    $0x24,%esp
  8011e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011f3:	89 04 24             	mov    %eax,(%esp)
  8011f6:	e8 02 ff ff ff       	call   8010fd <fd_lookup>
  8011fb:	85 c0                	test   %eax,%eax
  8011fd:	78 53                	js     801252 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ff:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801202:	89 44 24 04          	mov    %eax,0x4(%esp)
  801206:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801209:	8b 00                	mov    (%eax),%eax
  80120b:	89 04 24             	mov    %eax,(%esp)
  80120e:	e8 5e ff ff ff       	call   801171 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801213:	85 c0                	test   %eax,%eax
  801215:	78 3b                	js     801252 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801217:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80121c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80121f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801223:	74 2d                	je     801252 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801225:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801228:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80122f:	00 00 00 
	stat->st_isdir = 0;
  801232:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801239:	00 00 00 
	stat->st_dev = dev;
  80123c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80123f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801245:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801249:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80124c:	89 14 24             	mov    %edx,(%esp)
  80124f:	ff 50 14             	call   *0x14(%eax)
}
  801252:	83 c4 24             	add    $0x24,%esp
  801255:	5b                   	pop    %ebx
  801256:	5d                   	pop    %ebp
  801257:	c3                   	ret    

00801258 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801258:	55                   	push   %ebp
  801259:	89 e5                	mov    %esp,%ebp
  80125b:	53                   	push   %ebx
  80125c:	83 ec 24             	sub    $0x24,%esp
  80125f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801262:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801265:	89 44 24 04          	mov    %eax,0x4(%esp)
  801269:	89 1c 24             	mov    %ebx,(%esp)
  80126c:	e8 8c fe ff ff       	call   8010fd <fd_lookup>
  801271:	85 c0                	test   %eax,%eax
  801273:	78 5f                	js     8012d4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801275:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801278:	89 44 24 04          	mov    %eax,0x4(%esp)
  80127c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127f:	8b 00                	mov    (%eax),%eax
  801281:	89 04 24             	mov    %eax,(%esp)
  801284:	e8 e8 fe ff ff       	call   801171 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801289:	85 c0                	test   %eax,%eax
  80128b:	78 47                	js     8012d4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80128d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801290:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801294:	75 23                	jne    8012b9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801296:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80129b:	8b 40 48             	mov    0x48(%eax),%eax
  80129e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a6:	c7 04 24 ac 26 80 00 	movl   $0x8026ac,(%esp)
  8012ad:	e8 7b ee ff ff       	call   80012d <cprintf>
  8012b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012b7:	eb 1b                	jmp    8012d4 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8012b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012bc:	8b 48 18             	mov    0x18(%eax),%ecx
  8012bf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012c4:	85 c9                	test   %ecx,%ecx
  8012c6:	74 0c                	je     8012d4 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012cb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012cf:	89 14 24             	mov    %edx,(%esp)
  8012d2:	ff d1                	call   *%ecx
}
  8012d4:	83 c4 24             	add    $0x24,%esp
  8012d7:	5b                   	pop    %ebx
  8012d8:	5d                   	pop    %ebp
  8012d9:	c3                   	ret    

008012da <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012da:	55                   	push   %ebp
  8012db:	89 e5                	mov    %esp,%ebp
  8012dd:	53                   	push   %ebx
  8012de:	83 ec 24             	sub    $0x24,%esp
  8012e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012eb:	89 1c 24             	mov    %ebx,(%esp)
  8012ee:	e8 0a fe ff ff       	call   8010fd <fd_lookup>
  8012f3:	85 c0                	test   %eax,%eax
  8012f5:	78 66                	js     80135d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012fa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012fe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801301:	8b 00                	mov    (%eax),%eax
  801303:	89 04 24             	mov    %eax,(%esp)
  801306:	e8 66 fe ff ff       	call   801171 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80130b:	85 c0                	test   %eax,%eax
  80130d:	78 4e                	js     80135d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80130f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801312:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801316:	75 23                	jne    80133b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801318:	a1 08 40 80 00       	mov    0x804008,%eax
  80131d:	8b 40 48             	mov    0x48(%eax),%eax
  801320:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801324:	89 44 24 04          	mov    %eax,0x4(%esp)
  801328:	c7 04 24 cd 26 80 00 	movl   $0x8026cd,(%esp)
  80132f:	e8 f9 ed ff ff       	call   80012d <cprintf>
  801334:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801339:	eb 22                	jmp    80135d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80133b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80133e:	8b 48 0c             	mov    0xc(%eax),%ecx
  801341:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801346:	85 c9                	test   %ecx,%ecx
  801348:	74 13                	je     80135d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80134a:	8b 45 10             	mov    0x10(%ebp),%eax
  80134d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801351:	8b 45 0c             	mov    0xc(%ebp),%eax
  801354:	89 44 24 04          	mov    %eax,0x4(%esp)
  801358:	89 14 24             	mov    %edx,(%esp)
  80135b:	ff d1                	call   *%ecx
}
  80135d:	83 c4 24             	add    $0x24,%esp
  801360:	5b                   	pop    %ebx
  801361:	5d                   	pop    %ebp
  801362:	c3                   	ret    

00801363 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801363:	55                   	push   %ebp
  801364:	89 e5                	mov    %esp,%ebp
  801366:	53                   	push   %ebx
  801367:	83 ec 24             	sub    $0x24,%esp
  80136a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80136d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801370:	89 44 24 04          	mov    %eax,0x4(%esp)
  801374:	89 1c 24             	mov    %ebx,(%esp)
  801377:	e8 81 fd ff ff       	call   8010fd <fd_lookup>
  80137c:	85 c0                	test   %eax,%eax
  80137e:	78 6b                	js     8013eb <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801380:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801383:	89 44 24 04          	mov    %eax,0x4(%esp)
  801387:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80138a:	8b 00                	mov    (%eax),%eax
  80138c:	89 04 24             	mov    %eax,(%esp)
  80138f:	e8 dd fd ff ff       	call   801171 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801394:	85 c0                	test   %eax,%eax
  801396:	78 53                	js     8013eb <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801398:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80139b:	8b 42 08             	mov    0x8(%edx),%eax
  80139e:	83 e0 03             	and    $0x3,%eax
  8013a1:	83 f8 01             	cmp    $0x1,%eax
  8013a4:	75 23                	jne    8013c9 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013a6:	a1 08 40 80 00       	mov    0x804008,%eax
  8013ab:	8b 40 48             	mov    0x48(%eax),%eax
  8013ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b6:	c7 04 24 ea 26 80 00 	movl   $0x8026ea,(%esp)
  8013bd:	e8 6b ed ff ff       	call   80012d <cprintf>
  8013c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8013c7:	eb 22                	jmp    8013eb <read+0x88>
	}
	if (!dev->dev_read)
  8013c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013cc:	8b 48 08             	mov    0x8(%eax),%ecx
  8013cf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013d4:	85 c9                	test   %ecx,%ecx
  8013d6:	74 13                	je     8013eb <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013d8:	8b 45 10             	mov    0x10(%ebp),%eax
  8013db:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013df:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013e2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e6:	89 14 24             	mov    %edx,(%esp)
  8013e9:	ff d1                	call   *%ecx
}
  8013eb:	83 c4 24             	add    $0x24,%esp
  8013ee:	5b                   	pop    %ebx
  8013ef:	5d                   	pop    %ebp
  8013f0:	c3                   	ret    

008013f1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013f1:	55                   	push   %ebp
  8013f2:	89 e5                	mov    %esp,%ebp
  8013f4:	57                   	push   %edi
  8013f5:	56                   	push   %esi
  8013f6:	53                   	push   %ebx
  8013f7:	83 ec 1c             	sub    $0x1c,%esp
  8013fa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013fd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801400:	ba 00 00 00 00       	mov    $0x0,%edx
  801405:	bb 00 00 00 00       	mov    $0x0,%ebx
  80140a:	b8 00 00 00 00       	mov    $0x0,%eax
  80140f:	85 f6                	test   %esi,%esi
  801411:	74 29                	je     80143c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801413:	89 f0                	mov    %esi,%eax
  801415:	29 d0                	sub    %edx,%eax
  801417:	89 44 24 08          	mov    %eax,0x8(%esp)
  80141b:	03 55 0c             	add    0xc(%ebp),%edx
  80141e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801422:	89 3c 24             	mov    %edi,(%esp)
  801425:	e8 39 ff ff ff       	call   801363 <read>
		if (m < 0)
  80142a:	85 c0                	test   %eax,%eax
  80142c:	78 0e                	js     80143c <readn+0x4b>
			return m;
		if (m == 0)
  80142e:	85 c0                	test   %eax,%eax
  801430:	74 08                	je     80143a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801432:	01 c3                	add    %eax,%ebx
  801434:	89 da                	mov    %ebx,%edx
  801436:	39 f3                	cmp    %esi,%ebx
  801438:	72 d9                	jb     801413 <readn+0x22>
  80143a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80143c:	83 c4 1c             	add    $0x1c,%esp
  80143f:	5b                   	pop    %ebx
  801440:	5e                   	pop    %esi
  801441:	5f                   	pop    %edi
  801442:	5d                   	pop    %ebp
  801443:	c3                   	ret    

00801444 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801444:	55                   	push   %ebp
  801445:	89 e5                	mov    %esp,%ebp
  801447:	83 ec 28             	sub    $0x28,%esp
  80144a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80144d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801450:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801453:	89 34 24             	mov    %esi,(%esp)
  801456:	e8 05 fc ff ff       	call   801060 <fd2num>
  80145b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80145e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801462:	89 04 24             	mov    %eax,(%esp)
  801465:	e8 93 fc ff ff       	call   8010fd <fd_lookup>
  80146a:	89 c3                	mov    %eax,%ebx
  80146c:	85 c0                	test   %eax,%eax
  80146e:	78 05                	js     801475 <fd_close+0x31>
  801470:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801473:	74 0e                	je     801483 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801475:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801479:	b8 00 00 00 00       	mov    $0x0,%eax
  80147e:	0f 44 d8             	cmove  %eax,%ebx
  801481:	eb 3d                	jmp    8014c0 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801483:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801486:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148a:	8b 06                	mov    (%esi),%eax
  80148c:	89 04 24             	mov    %eax,(%esp)
  80148f:	e8 dd fc ff ff       	call   801171 <dev_lookup>
  801494:	89 c3                	mov    %eax,%ebx
  801496:	85 c0                	test   %eax,%eax
  801498:	78 16                	js     8014b0 <fd_close+0x6c>
		if (dev->dev_close)
  80149a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80149d:	8b 40 10             	mov    0x10(%eax),%eax
  8014a0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014a5:	85 c0                	test   %eax,%eax
  8014a7:	74 07                	je     8014b0 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8014a9:	89 34 24             	mov    %esi,(%esp)
  8014ac:	ff d0                	call   *%eax
  8014ae:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014b0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014bb:	e8 9c f9 ff ff       	call   800e5c <sys_page_unmap>
	return r;
}
  8014c0:	89 d8                	mov    %ebx,%eax
  8014c2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014c5:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8014c8:	89 ec                	mov    %ebp,%esp
  8014ca:	5d                   	pop    %ebp
  8014cb:	c3                   	ret    

008014cc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014dc:	89 04 24             	mov    %eax,(%esp)
  8014df:	e8 19 fc ff ff       	call   8010fd <fd_lookup>
  8014e4:	85 c0                	test   %eax,%eax
  8014e6:	78 13                	js     8014fb <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8014e8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8014ef:	00 
  8014f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014f3:	89 04 24             	mov    %eax,(%esp)
  8014f6:	e8 49 ff ff ff       	call   801444 <fd_close>
}
  8014fb:	c9                   	leave  
  8014fc:	c3                   	ret    

008014fd <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8014fd:	55                   	push   %ebp
  8014fe:	89 e5                	mov    %esp,%ebp
  801500:	83 ec 18             	sub    $0x18,%esp
  801503:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801506:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801509:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801510:	00 
  801511:	8b 45 08             	mov    0x8(%ebp),%eax
  801514:	89 04 24             	mov    %eax,(%esp)
  801517:	e8 78 03 00 00       	call   801894 <open>
  80151c:	89 c3                	mov    %eax,%ebx
  80151e:	85 c0                	test   %eax,%eax
  801520:	78 1b                	js     80153d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801522:	8b 45 0c             	mov    0xc(%ebp),%eax
  801525:	89 44 24 04          	mov    %eax,0x4(%esp)
  801529:	89 1c 24             	mov    %ebx,(%esp)
  80152c:	e8 ae fc ff ff       	call   8011df <fstat>
  801531:	89 c6                	mov    %eax,%esi
	close(fd);
  801533:	89 1c 24             	mov    %ebx,(%esp)
  801536:	e8 91 ff ff ff       	call   8014cc <close>
  80153b:	89 f3                	mov    %esi,%ebx
	return r;
}
  80153d:	89 d8                	mov    %ebx,%eax
  80153f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801542:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801545:	89 ec                	mov    %ebp,%esp
  801547:	5d                   	pop    %ebp
  801548:	c3                   	ret    

00801549 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801549:	55                   	push   %ebp
  80154a:	89 e5                	mov    %esp,%ebp
  80154c:	53                   	push   %ebx
  80154d:	83 ec 14             	sub    $0x14,%esp
  801550:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801555:	89 1c 24             	mov    %ebx,(%esp)
  801558:	e8 6f ff ff ff       	call   8014cc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80155d:	83 c3 01             	add    $0x1,%ebx
  801560:	83 fb 20             	cmp    $0x20,%ebx
  801563:	75 f0                	jne    801555 <close_all+0xc>
		close(i);
}
  801565:	83 c4 14             	add    $0x14,%esp
  801568:	5b                   	pop    %ebx
  801569:	5d                   	pop    %ebp
  80156a:	c3                   	ret    

0080156b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80156b:	55                   	push   %ebp
  80156c:	89 e5                	mov    %esp,%ebp
  80156e:	83 ec 58             	sub    $0x58,%esp
  801571:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801574:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801577:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80157a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80157d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801580:	89 44 24 04          	mov    %eax,0x4(%esp)
  801584:	8b 45 08             	mov    0x8(%ebp),%eax
  801587:	89 04 24             	mov    %eax,(%esp)
  80158a:	e8 6e fb ff ff       	call   8010fd <fd_lookup>
  80158f:	89 c3                	mov    %eax,%ebx
  801591:	85 c0                	test   %eax,%eax
  801593:	0f 88 e0 00 00 00    	js     801679 <dup+0x10e>
		return r;
	close(newfdnum);
  801599:	89 3c 24             	mov    %edi,(%esp)
  80159c:	e8 2b ff ff ff       	call   8014cc <close>

	newfd = INDEX2FD(newfdnum);
  8015a1:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8015a7:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8015aa:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015ad:	89 04 24             	mov    %eax,(%esp)
  8015b0:	e8 bb fa ff ff       	call   801070 <fd2data>
  8015b5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015b7:	89 34 24             	mov    %esi,(%esp)
  8015ba:	e8 b1 fa ff ff       	call   801070 <fd2data>
  8015bf:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  8015c2:	89 da                	mov    %ebx,%edx
  8015c4:	89 d8                	mov    %ebx,%eax
  8015c6:	c1 e8 16             	shr    $0x16,%eax
  8015c9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015d0:	a8 01                	test   $0x1,%al
  8015d2:	74 43                	je     801617 <dup+0xac>
  8015d4:	c1 ea 0c             	shr    $0xc,%edx
  8015d7:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8015de:	a8 01                	test   $0x1,%al
  8015e0:	74 35                	je     801617 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015e2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8015e9:	25 07 0e 00 00       	and    $0xe07,%eax
  8015ee:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015f2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015f5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015f9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801600:	00 
  801601:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801605:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80160c:	e8 83 f8 ff ff       	call   800e94 <sys_page_map>
  801611:	89 c3                	mov    %eax,%ebx
  801613:	85 c0                	test   %eax,%eax
  801615:	78 3f                	js     801656 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801617:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80161a:	89 c2                	mov    %eax,%edx
  80161c:	c1 ea 0c             	shr    $0xc,%edx
  80161f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801626:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80162c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801630:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801634:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80163b:	00 
  80163c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801640:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801647:	e8 48 f8 ff ff       	call   800e94 <sys_page_map>
  80164c:	89 c3                	mov    %eax,%ebx
  80164e:	85 c0                	test   %eax,%eax
  801650:	78 04                	js     801656 <dup+0xeb>
  801652:	89 fb                	mov    %edi,%ebx
  801654:	eb 23                	jmp    801679 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801656:	89 74 24 04          	mov    %esi,0x4(%esp)
  80165a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801661:	e8 f6 f7 ff ff       	call   800e5c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801666:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801669:	89 44 24 04          	mov    %eax,0x4(%esp)
  80166d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801674:	e8 e3 f7 ff ff       	call   800e5c <sys_page_unmap>
	return r;
}
  801679:	89 d8                	mov    %ebx,%eax
  80167b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80167e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801681:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801684:	89 ec                	mov    %ebp,%esp
  801686:	5d                   	pop    %ebp
  801687:	c3                   	ret    

00801688 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801688:	55                   	push   %ebp
  801689:	89 e5                	mov    %esp,%ebp
  80168b:	83 ec 18             	sub    $0x18,%esp
  80168e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801691:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801694:	89 c3                	mov    %eax,%ebx
  801696:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801698:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80169f:	75 11                	jne    8016b2 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016a1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8016a8:	e8 03 08 00 00       	call   801eb0 <ipc_find_env>
  8016ad:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016b2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8016b9:	00 
  8016ba:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8016c1:	00 
  8016c2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016c6:	a1 00 40 80 00       	mov    0x804000,%eax
  8016cb:	89 04 24             	mov    %eax,(%esp)
  8016ce:	e8 26 08 00 00       	call   801ef9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016d3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016da:	00 
  8016db:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016e6:	e8 79 08 00 00       	call   801f64 <ipc_recv>
}
  8016eb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8016ee:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8016f1:	89 ec                	mov    %ebp,%esp
  8016f3:	5d                   	pop    %ebp
  8016f4:	c3                   	ret    

008016f5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016f5:	55                   	push   %ebp
  8016f6:	89 e5                	mov    %esp,%ebp
  8016f8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fe:	8b 40 0c             	mov    0xc(%eax),%eax
  801701:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801706:	8b 45 0c             	mov    0xc(%ebp),%eax
  801709:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80170e:	ba 00 00 00 00       	mov    $0x0,%edx
  801713:	b8 02 00 00 00       	mov    $0x2,%eax
  801718:	e8 6b ff ff ff       	call   801688 <fsipc>
}
  80171d:	c9                   	leave  
  80171e:	c3                   	ret    

0080171f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80171f:	55                   	push   %ebp
  801720:	89 e5                	mov    %esp,%ebp
  801722:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801725:	8b 45 08             	mov    0x8(%ebp),%eax
  801728:	8b 40 0c             	mov    0xc(%eax),%eax
  80172b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801730:	ba 00 00 00 00       	mov    $0x0,%edx
  801735:	b8 06 00 00 00       	mov    $0x6,%eax
  80173a:	e8 49 ff ff ff       	call   801688 <fsipc>
}
  80173f:	c9                   	leave  
  801740:	c3                   	ret    

00801741 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801741:	55                   	push   %ebp
  801742:	89 e5                	mov    %esp,%ebp
  801744:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801747:	ba 00 00 00 00       	mov    $0x0,%edx
  80174c:	b8 08 00 00 00       	mov    $0x8,%eax
  801751:	e8 32 ff ff ff       	call   801688 <fsipc>
}
  801756:	c9                   	leave  
  801757:	c3                   	ret    

00801758 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	53                   	push   %ebx
  80175c:	83 ec 14             	sub    $0x14,%esp
  80175f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801762:	8b 45 08             	mov    0x8(%ebp),%eax
  801765:	8b 40 0c             	mov    0xc(%eax),%eax
  801768:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80176d:	ba 00 00 00 00       	mov    $0x0,%edx
  801772:	b8 05 00 00 00       	mov    $0x5,%eax
  801777:	e8 0c ff ff ff       	call   801688 <fsipc>
  80177c:	85 c0                	test   %eax,%eax
  80177e:	78 2b                	js     8017ab <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801780:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801787:	00 
  801788:	89 1c 24             	mov    %ebx,(%esp)
  80178b:	e8 da f0 ff ff       	call   80086a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801790:	a1 80 50 80 00       	mov    0x805080,%eax
  801795:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80179b:	a1 84 50 80 00       	mov    0x805084,%eax
  8017a0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8017a6:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8017ab:	83 c4 14             	add    $0x14,%esp
  8017ae:	5b                   	pop    %ebx
  8017af:	5d                   	pop    %ebp
  8017b0:	c3                   	ret    

008017b1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017b1:	55                   	push   %ebp
  8017b2:	89 e5                	mov    %esp,%ebp
  8017b4:	83 ec 18             	sub    $0x18,%esp
  8017b7:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8017bd:	8b 52 0c             	mov    0xc(%edx),%edx
  8017c0:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  8017c6:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  8017cb:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017d0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017d5:	0f 47 c2             	cmova  %edx,%eax
  8017d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e3:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8017ea:	e8 66 f2 ff ff       	call   800a55 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  8017ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8017f4:	b8 04 00 00 00       	mov    $0x4,%eax
  8017f9:	e8 8a fe ff ff       	call   801688 <fsipc>
}
  8017fe:	c9                   	leave  
  8017ff:	c3                   	ret    

00801800 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801800:	55                   	push   %ebp
  801801:	89 e5                	mov    %esp,%ebp
  801803:	53                   	push   %ebx
  801804:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801807:	8b 45 08             	mov    0x8(%ebp),%eax
  80180a:	8b 40 0c             	mov    0xc(%eax),%eax
  80180d:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  801812:	8b 45 10             	mov    0x10(%ebp),%eax
  801815:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  80181a:	ba 00 00 00 00       	mov    $0x0,%edx
  80181f:	b8 03 00 00 00       	mov    $0x3,%eax
  801824:	e8 5f fe ff ff       	call   801688 <fsipc>
  801829:	89 c3                	mov    %eax,%ebx
  80182b:	85 c0                	test   %eax,%eax
  80182d:	78 17                	js     801846 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80182f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801833:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80183a:	00 
  80183b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80183e:	89 04 24             	mov    %eax,(%esp)
  801841:	e8 0f f2 ff ff       	call   800a55 <memmove>
  return r;	
}
  801846:	89 d8                	mov    %ebx,%eax
  801848:	83 c4 14             	add    $0x14,%esp
  80184b:	5b                   	pop    %ebx
  80184c:	5d                   	pop    %ebp
  80184d:	c3                   	ret    

0080184e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  80184e:	55                   	push   %ebp
  80184f:	89 e5                	mov    %esp,%ebp
  801851:	53                   	push   %ebx
  801852:	83 ec 14             	sub    $0x14,%esp
  801855:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801858:	89 1c 24             	mov    %ebx,(%esp)
  80185b:	e8 c0 ef ff ff       	call   800820 <strlen>
  801860:	89 c2                	mov    %eax,%edx
  801862:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801867:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  80186d:	7f 1f                	jg     80188e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  80186f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801873:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80187a:	e8 eb ef ff ff       	call   80086a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  80187f:	ba 00 00 00 00       	mov    $0x0,%edx
  801884:	b8 07 00 00 00       	mov    $0x7,%eax
  801889:	e8 fa fd ff ff       	call   801688 <fsipc>
}
  80188e:	83 c4 14             	add    $0x14,%esp
  801891:	5b                   	pop    %ebx
  801892:	5d                   	pop    %ebp
  801893:	c3                   	ret    

00801894 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801894:	55                   	push   %ebp
  801895:	89 e5                	mov    %esp,%ebp
  801897:	83 ec 28             	sub    $0x28,%esp
  80189a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80189d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8018a0:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  8018a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a6:	89 04 24             	mov    %eax,(%esp)
  8018a9:	e8 dd f7 ff ff       	call   80108b <fd_alloc>
  8018ae:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  8018b0:	85 c0                	test   %eax,%eax
  8018b2:	0f 88 89 00 00 00    	js     801941 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  8018b8:	89 34 24             	mov    %esi,(%esp)
  8018bb:	e8 60 ef ff ff       	call   800820 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  8018c0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  8018c5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018ca:	7f 75                	jg     801941 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  8018cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018d0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8018d7:	e8 8e ef ff ff       	call   80086a <strcpy>
  fsipcbuf.open.req_omode = mode;
  8018dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018df:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  8018e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018e7:	b8 01 00 00 00       	mov    $0x1,%eax
  8018ec:	e8 97 fd ff ff       	call   801688 <fsipc>
  8018f1:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  8018f3:	85 c0                	test   %eax,%eax
  8018f5:	78 0f                	js     801906 <open+0x72>
  return fd2num(fd);
  8018f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018fa:	89 04 24             	mov    %eax,(%esp)
  8018fd:	e8 5e f7 ff ff       	call   801060 <fd2num>
  801902:	89 c3                	mov    %eax,%ebx
  801904:	eb 3b                	jmp    801941 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801906:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80190d:	00 
  80190e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801911:	89 04 24             	mov    %eax,(%esp)
  801914:	e8 2b fb ff ff       	call   801444 <fd_close>
  801919:	85 c0                	test   %eax,%eax
  80191b:	74 24                	je     801941 <open+0xad>
  80191d:	c7 44 24 0c 14 27 80 	movl   $0x802714,0xc(%esp)
  801924:	00 
  801925:	c7 44 24 08 29 27 80 	movl   $0x802729,0x8(%esp)
  80192c:	00 
  80192d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801934:	00 
  801935:	c7 04 24 3e 27 80 00 	movl   $0x80273e,(%esp)
  80193c:	e8 13 05 00 00       	call   801e54 <_panic>
  return r;
}
  801941:	89 d8                	mov    %ebx,%eax
  801943:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801946:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801949:	89 ec                	mov    %ebp,%esp
  80194b:	5d                   	pop    %ebp
  80194c:	c3                   	ret    
  80194d:	00 00                	add    %al,(%eax)
	...

00801950 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801956:	c7 44 24 04 49 27 80 	movl   $0x802749,0x4(%esp)
  80195d:	00 
  80195e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801961:	89 04 24             	mov    %eax,(%esp)
  801964:	e8 01 ef ff ff       	call   80086a <strcpy>
	return 0;
}
  801969:	b8 00 00 00 00       	mov    $0x0,%eax
  80196e:	c9                   	leave  
  80196f:	c3                   	ret    

00801970 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801970:	55                   	push   %ebp
  801971:	89 e5                	mov    %esp,%ebp
  801973:	53                   	push   %ebx
  801974:	83 ec 14             	sub    $0x14,%esp
  801977:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80197a:	89 1c 24             	mov    %ebx,(%esp)
  80197d:	e8 72 06 00 00       	call   801ff4 <pageref>
  801982:	89 c2                	mov    %eax,%edx
  801984:	b8 00 00 00 00       	mov    $0x0,%eax
  801989:	83 fa 01             	cmp    $0x1,%edx
  80198c:	75 0b                	jne    801999 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80198e:	8b 43 0c             	mov    0xc(%ebx),%eax
  801991:	89 04 24             	mov    %eax,(%esp)
  801994:	e8 b9 02 00 00       	call   801c52 <nsipc_close>
	else
		return 0;
}
  801999:	83 c4 14             	add    $0x14,%esp
  80199c:	5b                   	pop    %ebx
  80199d:	5d                   	pop    %ebp
  80199e:	c3                   	ret    

0080199f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80199f:	55                   	push   %ebp
  8019a0:	89 e5                	mov    %esp,%ebp
  8019a2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019a5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8019ac:	00 
  8019ad:	8b 45 10             	mov    0x10(%ebp),%eax
  8019b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019be:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c1:	89 04 24             	mov    %eax,(%esp)
  8019c4:	e8 c5 02 00 00       	call   801c8e <nsipc_send>
}
  8019c9:	c9                   	leave  
  8019ca:	c3                   	ret    

008019cb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8019cb:	55                   	push   %ebp
  8019cc:	89 e5                	mov    %esp,%ebp
  8019ce:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019d1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8019d8:	00 
  8019d9:	8b 45 10             	mov    0x10(%ebp),%eax
  8019dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ed:	89 04 24             	mov    %eax,(%esp)
  8019f0:	e8 0c 03 00 00       	call   801d01 <nsipc_recv>
}
  8019f5:	c9                   	leave  
  8019f6:	c3                   	ret    

008019f7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  8019f7:	55                   	push   %ebp
  8019f8:	89 e5                	mov    %esp,%ebp
  8019fa:	56                   	push   %esi
  8019fb:	53                   	push   %ebx
  8019fc:	83 ec 20             	sub    $0x20,%esp
  8019ff:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a01:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a04:	89 04 24             	mov    %eax,(%esp)
  801a07:	e8 7f f6 ff ff       	call   80108b <fd_alloc>
  801a0c:	89 c3                	mov    %eax,%ebx
  801a0e:	85 c0                	test   %eax,%eax
  801a10:	78 21                	js     801a33 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a12:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a19:	00 
  801a1a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a21:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a28:	e8 a0 f4 ff ff       	call   800ecd <sys_page_alloc>
  801a2d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a2f:	85 c0                	test   %eax,%eax
  801a31:	79 0a                	jns    801a3d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  801a33:	89 34 24             	mov    %esi,(%esp)
  801a36:	e8 17 02 00 00       	call   801c52 <nsipc_close>
		return r;
  801a3b:	eb 28                	jmp    801a65 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a3d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a46:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a4b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a55:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a5b:	89 04 24             	mov    %eax,(%esp)
  801a5e:	e8 fd f5 ff ff       	call   801060 <fd2num>
  801a63:	89 c3                	mov    %eax,%ebx
}
  801a65:	89 d8                	mov    %ebx,%eax
  801a67:	83 c4 20             	add    $0x20,%esp
  801a6a:	5b                   	pop    %ebx
  801a6b:	5e                   	pop    %esi
  801a6c:	5d                   	pop    %ebp
  801a6d:	c3                   	ret    

00801a6e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a74:	8b 45 10             	mov    0x10(%ebp),%eax
  801a77:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a7e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a82:	8b 45 08             	mov    0x8(%ebp),%eax
  801a85:	89 04 24             	mov    %eax,(%esp)
  801a88:	e8 79 01 00 00       	call   801c06 <nsipc_socket>
  801a8d:	85 c0                	test   %eax,%eax
  801a8f:	78 05                	js     801a96 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801a91:	e8 61 ff ff ff       	call   8019f7 <alloc_sockfd>
}
  801a96:	c9                   	leave  
  801a97:	c3                   	ret    

00801a98 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a98:	55                   	push   %ebp
  801a99:	89 e5                	mov    %esp,%ebp
  801a9b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a9e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801aa1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801aa5:	89 04 24             	mov    %eax,(%esp)
  801aa8:	e8 50 f6 ff ff       	call   8010fd <fd_lookup>
  801aad:	85 c0                	test   %eax,%eax
  801aaf:	78 15                	js     801ac6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801ab1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ab4:	8b 0a                	mov    (%edx),%ecx
  801ab6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801abb:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  801ac1:	75 03                	jne    801ac6 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801ac3:	8b 42 0c             	mov    0xc(%edx),%eax
}
  801ac6:	c9                   	leave  
  801ac7:	c3                   	ret    

00801ac8 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  801ac8:	55                   	push   %ebp
  801ac9:	89 e5                	mov    %esp,%ebp
  801acb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ace:	8b 45 08             	mov    0x8(%ebp),%eax
  801ad1:	e8 c2 ff ff ff       	call   801a98 <fd2sockid>
  801ad6:	85 c0                	test   %eax,%eax
  801ad8:	78 0f                	js     801ae9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801ada:	8b 55 0c             	mov    0xc(%ebp),%edx
  801add:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ae1:	89 04 24             	mov    %eax,(%esp)
  801ae4:	e8 47 01 00 00       	call   801c30 <nsipc_listen>
}
  801ae9:	c9                   	leave  
  801aea:	c3                   	ret    

00801aeb <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801aeb:	55                   	push   %ebp
  801aec:	89 e5                	mov    %esp,%ebp
  801aee:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801af1:	8b 45 08             	mov    0x8(%ebp),%eax
  801af4:	e8 9f ff ff ff       	call   801a98 <fd2sockid>
  801af9:	85 c0                	test   %eax,%eax
  801afb:	78 16                	js     801b13 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801afd:	8b 55 10             	mov    0x10(%ebp),%edx
  801b00:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b04:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b07:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b0b:	89 04 24             	mov    %eax,(%esp)
  801b0e:	e8 6e 02 00 00       	call   801d81 <nsipc_connect>
}
  801b13:	c9                   	leave  
  801b14:	c3                   	ret    

00801b15 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801b15:	55                   	push   %ebp
  801b16:	89 e5                	mov    %esp,%ebp
  801b18:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b1e:	e8 75 ff ff ff       	call   801a98 <fd2sockid>
  801b23:	85 c0                	test   %eax,%eax
  801b25:	78 0f                	js     801b36 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b27:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b2a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b2e:	89 04 24             	mov    %eax,(%esp)
  801b31:	e8 36 01 00 00       	call   801c6c <nsipc_shutdown>
}
  801b36:	c9                   	leave  
  801b37:	c3                   	ret    

00801b38 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b41:	e8 52 ff ff ff       	call   801a98 <fd2sockid>
  801b46:	85 c0                	test   %eax,%eax
  801b48:	78 16                	js     801b60 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801b4a:	8b 55 10             	mov    0x10(%ebp),%edx
  801b4d:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b51:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b54:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b58:	89 04 24             	mov    %eax,(%esp)
  801b5b:	e8 60 02 00 00       	call   801dc0 <nsipc_bind>
}
  801b60:	c9                   	leave  
  801b61:	c3                   	ret    

00801b62 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
  801b65:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b68:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6b:	e8 28 ff ff ff       	call   801a98 <fd2sockid>
  801b70:	85 c0                	test   %eax,%eax
  801b72:	78 1f                	js     801b93 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b74:	8b 55 10             	mov    0x10(%ebp),%edx
  801b77:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b7b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b7e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b82:	89 04 24             	mov    %eax,(%esp)
  801b85:	e8 75 02 00 00       	call   801dff <nsipc_accept>
  801b8a:	85 c0                	test   %eax,%eax
  801b8c:	78 05                	js     801b93 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801b8e:	e8 64 fe ff ff       	call   8019f7 <alloc_sockfd>
}
  801b93:	c9                   	leave  
  801b94:	c3                   	ret    
	...

00801ba0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801ba0:	55                   	push   %ebp
  801ba1:	89 e5                	mov    %esp,%ebp
  801ba3:	53                   	push   %ebx
  801ba4:	83 ec 14             	sub    $0x14,%esp
  801ba7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ba9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801bb0:	75 11                	jne    801bc3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801bb2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  801bb9:	e8 f2 02 00 00       	call   801eb0 <ipc_find_env>
  801bbe:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bc3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801bca:	00 
  801bcb:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801bd2:	00 
  801bd3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bd7:	a1 04 40 80 00       	mov    0x804004,%eax
  801bdc:	89 04 24             	mov    %eax,(%esp)
  801bdf:	e8 15 03 00 00       	call   801ef9 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801be4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801beb:	00 
  801bec:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801bf3:	00 
  801bf4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bfb:	e8 64 03 00 00       	call   801f64 <ipc_recv>
}
  801c00:	83 c4 14             	add    $0x14,%esp
  801c03:	5b                   	pop    %ebx
  801c04:	5d                   	pop    %ebp
  801c05:	c3                   	ret    

00801c06 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801c06:	55                   	push   %ebp
  801c07:	89 e5                	mov    %esp,%ebp
  801c09:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c0f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801c14:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c17:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801c1c:	8b 45 10             	mov    0x10(%ebp),%eax
  801c1f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801c24:	b8 09 00 00 00       	mov    $0x9,%eax
  801c29:	e8 72 ff ff ff       	call   801ba0 <nsipc>
}
  801c2e:	c9                   	leave  
  801c2f:	c3                   	ret    

00801c30 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  801c30:	55                   	push   %ebp
  801c31:	89 e5                	mov    %esp,%ebp
  801c33:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c36:	8b 45 08             	mov    0x8(%ebp),%eax
  801c39:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801c3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c41:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801c46:	b8 06 00 00 00       	mov    $0x6,%eax
  801c4b:	e8 50 ff ff ff       	call   801ba0 <nsipc>
}
  801c50:	c9                   	leave  
  801c51:	c3                   	ret    

00801c52 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c58:	8b 45 08             	mov    0x8(%ebp),%eax
  801c5b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c60:	b8 04 00 00 00       	mov    $0x4,%eax
  801c65:	e8 36 ff ff ff       	call   801ba0 <nsipc>
}
  801c6a:	c9                   	leave  
  801c6b:	c3                   	ret    

00801c6c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  801c6c:	55                   	push   %ebp
  801c6d:	89 e5                	mov    %esp,%ebp
  801c6f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c72:	8b 45 08             	mov    0x8(%ebp),%eax
  801c75:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c7d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c82:	b8 03 00 00 00       	mov    $0x3,%eax
  801c87:	e8 14 ff ff ff       	call   801ba0 <nsipc>
}
  801c8c:	c9                   	leave  
  801c8d:	c3                   	ret    

00801c8e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c8e:	55                   	push   %ebp
  801c8f:	89 e5                	mov    %esp,%ebp
  801c91:	53                   	push   %ebx
  801c92:	83 ec 14             	sub    $0x14,%esp
  801c95:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c98:	8b 45 08             	mov    0x8(%ebp),%eax
  801c9b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801ca0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801ca6:	7e 24                	jle    801ccc <nsipc_send+0x3e>
  801ca8:	c7 44 24 0c 55 27 80 	movl   $0x802755,0xc(%esp)
  801caf:	00 
  801cb0:	c7 44 24 08 29 27 80 	movl   $0x802729,0x8(%esp)
  801cb7:	00 
  801cb8:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  801cbf:	00 
  801cc0:	c7 04 24 61 27 80 00 	movl   $0x802761,(%esp)
  801cc7:	e8 88 01 00 00       	call   801e54 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801ccc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cd0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cd7:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801cde:	e8 72 ed ff ff       	call   800a55 <memmove>
	nsipcbuf.send.req_size = size;
  801ce3:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801ce9:	8b 45 14             	mov    0x14(%ebp),%eax
  801cec:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801cf1:	b8 08 00 00 00       	mov    $0x8,%eax
  801cf6:	e8 a5 fe ff ff       	call   801ba0 <nsipc>
}
  801cfb:	83 c4 14             	add    $0x14,%esp
  801cfe:	5b                   	pop    %ebx
  801cff:	5d                   	pop    %ebp
  801d00:	c3                   	ret    

00801d01 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d01:	55                   	push   %ebp
  801d02:	89 e5                	mov    %esp,%ebp
  801d04:	56                   	push   %esi
  801d05:	53                   	push   %ebx
  801d06:	83 ec 10             	sub    $0x10,%esp
  801d09:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d0c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d0f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d14:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d1a:	8b 45 14             	mov    0x14(%ebp),%eax
  801d1d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d22:	b8 07 00 00 00       	mov    $0x7,%eax
  801d27:	e8 74 fe ff ff       	call   801ba0 <nsipc>
  801d2c:	89 c3                	mov    %eax,%ebx
  801d2e:	85 c0                	test   %eax,%eax
  801d30:	78 46                	js     801d78 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801d32:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d37:	7f 04                	jg     801d3d <nsipc_recv+0x3c>
  801d39:	39 c6                	cmp    %eax,%esi
  801d3b:	7d 24                	jge    801d61 <nsipc_recv+0x60>
  801d3d:	c7 44 24 0c 6d 27 80 	movl   $0x80276d,0xc(%esp)
  801d44:	00 
  801d45:	c7 44 24 08 29 27 80 	movl   $0x802729,0x8(%esp)
  801d4c:	00 
  801d4d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801d54:	00 
  801d55:	c7 04 24 61 27 80 00 	movl   $0x802761,(%esp)
  801d5c:	e8 f3 00 00 00       	call   801e54 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d61:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d65:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801d6c:	00 
  801d6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d70:	89 04 24             	mov    %eax,(%esp)
  801d73:	e8 dd ec ff ff       	call   800a55 <memmove>
	}

	return r;
}
  801d78:	89 d8                	mov    %ebx,%eax
  801d7a:	83 c4 10             	add    $0x10,%esp
  801d7d:	5b                   	pop    %ebx
  801d7e:	5e                   	pop    %esi
  801d7f:	5d                   	pop    %ebp
  801d80:	c3                   	ret    

00801d81 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d81:	55                   	push   %ebp
  801d82:	89 e5                	mov    %esp,%ebp
  801d84:	53                   	push   %ebx
  801d85:	83 ec 14             	sub    $0x14,%esp
  801d88:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d8e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d93:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d97:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d9e:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801da5:	e8 ab ec ff ff       	call   800a55 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801daa:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801db0:	b8 05 00 00 00       	mov    $0x5,%eax
  801db5:	e8 e6 fd ff ff       	call   801ba0 <nsipc>
}
  801dba:	83 c4 14             	add    $0x14,%esp
  801dbd:	5b                   	pop    %ebx
  801dbe:	5d                   	pop    %ebp
  801dbf:	c3                   	ret    

00801dc0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	53                   	push   %ebx
  801dc4:	83 ec 14             	sub    $0x14,%esp
  801dc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801dca:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcd:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801dd2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dd6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ddd:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801de4:	e8 6c ec ff ff       	call   800a55 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801de9:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801def:	b8 02 00 00 00       	mov    $0x2,%eax
  801df4:	e8 a7 fd ff ff       	call   801ba0 <nsipc>
}
  801df9:	83 c4 14             	add    $0x14,%esp
  801dfc:	5b                   	pop    %ebx
  801dfd:	5d                   	pop    %ebp
  801dfe:	c3                   	ret    

00801dff <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801dff:	55                   	push   %ebp
  801e00:	89 e5                	mov    %esp,%ebp
  801e02:	83 ec 18             	sub    $0x18,%esp
  801e05:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801e08:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  801e0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0e:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e13:	b8 01 00 00 00       	mov    $0x1,%eax
  801e18:	e8 83 fd ff ff       	call   801ba0 <nsipc>
  801e1d:	89 c3                	mov    %eax,%ebx
  801e1f:	85 c0                	test   %eax,%eax
  801e21:	78 25                	js     801e48 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801e23:	be 10 60 80 00       	mov    $0x806010,%esi
  801e28:	8b 06                	mov    (%esi),%eax
  801e2a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e2e:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e35:	00 
  801e36:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e39:	89 04 24             	mov    %eax,(%esp)
  801e3c:	e8 14 ec ff ff       	call   800a55 <memmove>
		*addrlen = ret->ret_addrlen;
  801e41:	8b 16                	mov    (%esi),%edx
  801e43:	8b 45 10             	mov    0x10(%ebp),%eax
  801e46:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  801e48:	89 d8                	mov    %ebx,%eax
  801e4a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801e4d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801e50:	89 ec                	mov    %ebp,%esp
  801e52:	5d                   	pop    %ebp
  801e53:	c3                   	ret    

00801e54 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e54:	55                   	push   %ebp
  801e55:	89 e5                	mov    %esp,%ebp
  801e57:	56                   	push   %esi
  801e58:	53                   	push   %ebx
  801e59:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801e5c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e5f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801e65:	e8 0d f1 ff ff       	call   800f77 <sys_getenvid>
  801e6a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e6d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801e71:	8b 55 08             	mov    0x8(%ebp),%edx
  801e74:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801e78:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e80:	c7 04 24 84 27 80 00 	movl   $0x802784,(%esp)
  801e87:	e8 a1 e2 ff ff       	call   80012d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e8c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e90:	8b 45 10             	mov    0x10(%ebp),%eax
  801e93:	89 04 24             	mov    %eax,(%esp)
  801e96:	e8 31 e2 ff ff       	call   8000cc <vcprintf>
	cprintf("\n");
  801e9b:	c7 04 24 cc 22 80 00 	movl   $0x8022cc,(%esp)
  801ea2:	e8 86 e2 ff ff       	call   80012d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801ea7:	cc                   	int3   
  801ea8:	eb fd                	jmp    801ea7 <_panic+0x53>
  801eaa:	00 00                	add    %al,(%eax)
  801eac:	00 00                	add    %al,(%eax)
	...

00801eb0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801eb0:	55                   	push   %ebp
  801eb1:	89 e5                	mov    %esp,%ebp
  801eb3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801eb6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801ebc:	b8 01 00 00 00       	mov    $0x1,%eax
  801ec1:	39 ca                	cmp    %ecx,%edx
  801ec3:	75 04                	jne    801ec9 <ipc_find_env+0x19>
  801ec5:	b0 00                	mov    $0x0,%al
  801ec7:	eb 11                	jmp    801eda <ipc_find_env+0x2a>
  801ec9:	89 c2                	mov    %eax,%edx
  801ecb:	c1 e2 07             	shl    $0x7,%edx
  801ece:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801ed4:	8b 12                	mov    (%edx),%edx
  801ed6:	39 ca                	cmp    %ecx,%edx
  801ed8:	75 0f                	jne    801ee9 <ipc_find_env+0x39>
			return envs[i].env_id;
  801eda:	8d 44 00 01          	lea    0x1(%eax,%eax,1),%eax
  801ede:	c1 e0 06             	shl    $0x6,%eax
  801ee1:	8b 80 08 00 c0 ee    	mov    -0x113ffff8(%eax),%eax
  801ee7:	eb 0e                	jmp    801ef7 <ipc_find_env+0x47>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ee9:	83 c0 01             	add    $0x1,%eax
  801eec:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ef1:	75 d6                	jne    801ec9 <ipc_find_env+0x19>
  801ef3:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801ef7:	5d                   	pop    %ebp
  801ef8:	c3                   	ret    

00801ef9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ef9:	55                   	push   %ebp
  801efa:	89 e5                	mov    %esp,%ebp
  801efc:	57                   	push   %edi
  801efd:	56                   	push   %esi
  801efe:	53                   	push   %ebx
  801eff:	83 ec 1c             	sub    $0x1c,%esp
  801f02:	8b 75 08             	mov    0x8(%ebp),%esi
  801f05:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f08:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801f0b:	85 db                	test   %ebx,%ebx
  801f0d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f12:	0f 44 d8             	cmove  %eax,%ebx
  801f15:	eb 25                	jmp    801f3c <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  801f17:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f1a:	74 20                	je     801f3c <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  801f1c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f20:	c7 44 24 08 a8 27 80 	movl   $0x8027a8,0x8(%esp)
  801f27:	00 
  801f28:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801f2f:	00 
  801f30:	c7 04 24 c6 27 80 00 	movl   $0x8027c6,(%esp)
  801f37:	e8 18 ff ff ff       	call   801e54 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  801f3c:	8b 45 14             	mov    0x14(%ebp),%eax
  801f3f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f43:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f47:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f4b:	89 34 24             	mov    %esi,(%esp)
  801f4e:	e8 2b ee ff ff       	call   800d7e <sys_ipc_try_send>
  801f53:	85 c0                	test   %eax,%eax
  801f55:	75 c0                	jne    801f17 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  801f57:	e8 a8 ef ff ff       	call   800f04 <sys_yield>
}
  801f5c:	83 c4 1c             	add    $0x1c,%esp
  801f5f:	5b                   	pop    %ebx
  801f60:	5e                   	pop    %esi
  801f61:	5f                   	pop    %edi
  801f62:	5d                   	pop    %ebp
  801f63:	c3                   	ret    

00801f64 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f64:	55                   	push   %ebp
  801f65:	89 e5                	mov    %esp,%ebp
  801f67:	83 ec 28             	sub    $0x28,%esp
  801f6a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801f6d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801f70:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801f73:	8b 75 08             	mov    0x8(%ebp),%esi
  801f76:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f79:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801f7c:	85 c0                	test   %eax,%eax
  801f7e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f83:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801f86:	89 04 24             	mov    %eax,(%esp)
  801f89:	e8 b7 ed ff ff       	call   800d45 <sys_ipc_recv>
  801f8e:	89 c3                	mov    %eax,%ebx
  801f90:	85 c0                	test   %eax,%eax
  801f92:	79 2a                	jns    801fbe <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  801f94:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f98:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f9c:	c7 04 24 d0 27 80 00 	movl   $0x8027d0,(%esp)
  801fa3:	e8 85 e1 ff ff       	call   80012d <cprintf>
		if(from_env_store != NULL)
  801fa8:	85 f6                	test   %esi,%esi
  801faa:	74 06                	je     801fb2 <ipc_recv+0x4e>
			*from_env_store = 0;
  801fac:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801fb2:	85 ff                	test   %edi,%edi
  801fb4:	74 2c                	je     801fe2 <ipc_recv+0x7e>
			*perm_store = 0;
  801fb6:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801fbc:	eb 24                	jmp    801fe2 <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  801fbe:	85 f6                	test   %esi,%esi
  801fc0:	74 0a                	je     801fcc <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  801fc2:	a1 08 40 80 00       	mov    0x804008,%eax
  801fc7:	8b 40 74             	mov    0x74(%eax),%eax
  801fca:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801fcc:	85 ff                	test   %edi,%edi
  801fce:	74 0a                	je     801fda <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  801fd0:	a1 08 40 80 00       	mov    0x804008,%eax
  801fd5:	8b 40 78             	mov    0x78(%eax),%eax
  801fd8:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801fda:	a1 08 40 80 00       	mov    0x804008,%eax
  801fdf:	8b 58 70             	mov    0x70(%eax),%ebx
}
  801fe2:	89 d8                	mov    %ebx,%eax
  801fe4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801fe7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801fea:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801fed:	89 ec                	mov    %ebp,%esp
  801fef:	5d                   	pop    %ebp
  801ff0:	c3                   	ret    
  801ff1:	00 00                	add    %al,(%eax)
	...

00801ff4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ff4:	55                   	push   %ebp
  801ff5:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  801ff7:	8b 45 08             	mov    0x8(%ebp),%eax
  801ffa:	89 c2                	mov    %eax,%edx
  801ffc:	c1 ea 16             	shr    $0x16,%edx
  801fff:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802006:	f6 c2 01             	test   $0x1,%dl
  802009:	74 20                	je     80202b <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  80200b:	c1 e8 0c             	shr    $0xc,%eax
  80200e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802015:	a8 01                	test   $0x1,%al
  802017:	74 12                	je     80202b <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802019:	c1 e8 0c             	shr    $0xc,%eax
  80201c:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802021:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  802026:	0f b7 c0             	movzwl %ax,%eax
  802029:	eb 05                	jmp    802030 <pageref+0x3c>
  80202b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802030:	5d                   	pop    %ebp
  802031:	c3                   	ret    
	...

00802040 <__udivdi3>:
  802040:	55                   	push   %ebp
  802041:	89 e5                	mov    %esp,%ebp
  802043:	57                   	push   %edi
  802044:	56                   	push   %esi
  802045:	83 ec 10             	sub    $0x10,%esp
  802048:	8b 45 14             	mov    0x14(%ebp),%eax
  80204b:	8b 55 08             	mov    0x8(%ebp),%edx
  80204e:	8b 75 10             	mov    0x10(%ebp),%esi
  802051:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802054:	85 c0                	test   %eax,%eax
  802056:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802059:	75 35                	jne    802090 <__udivdi3+0x50>
  80205b:	39 fe                	cmp    %edi,%esi
  80205d:	77 61                	ja     8020c0 <__udivdi3+0x80>
  80205f:	85 f6                	test   %esi,%esi
  802061:	75 0b                	jne    80206e <__udivdi3+0x2e>
  802063:	b8 01 00 00 00       	mov    $0x1,%eax
  802068:	31 d2                	xor    %edx,%edx
  80206a:	f7 f6                	div    %esi
  80206c:	89 c6                	mov    %eax,%esi
  80206e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802071:	31 d2                	xor    %edx,%edx
  802073:	89 f8                	mov    %edi,%eax
  802075:	f7 f6                	div    %esi
  802077:	89 c7                	mov    %eax,%edi
  802079:	89 c8                	mov    %ecx,%eax
  80207b:	f7 f6                	div    %esi
  80207d:	89 c1                	mov    %eax,%ecx
  80207f:	89 fa                	mov    %edi,%edx
  802081:	89 c8                	mov    %ecx,%eax
  802083:	83 c4 10             	add    $0x10,%esp
  802086:	5e                   	pop    %esi
  802087:	5f                   	pop    %edi
  802088:	5d                   	pop    %ebp
  802089:	c3                   	ret    
  80208a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802090:	39 f8                	cmp    %edi,%eax
  802092:	77 1c                	ja     8020b0 <__udivdi3+0x70>
  802094:	0f bd d0             	bsr    %eax,%edx
  802097:	83 f2 1f             	xor    $0x1f,%edx
  80209a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80209d:	75 39                	jne    8020d8 <__udivdi3+0x98>
  80209f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8020a2:	0f 86 a0 00 00 00    	jbe    802148 <__udivdi3+0x108>
  8020a8:	39 f8                	cmp    %edi,%eax
  8020aa:	0f 82 98 00 00 00    	jb     802148 <__udivdi3+0x108>
  8020b0:	31 ff                	xor    %edi,%edi
  8020b2:	31 c9                	xor    %ecx,%ecx
  8020b4:	89 c8                	mov    %ecx,%eax
  8020b6:	89 fa                	mov    %edi,%edx
  8020b8:	83 c4 10             	add    $0x10,%esp
  8020bb:	5e                   	pop    %esi
  8020bc:	5f                   	pop    %edi
  8020bd:	5d                   	pop    %ebp
  8020be:	c3                   	ret    
  8020bf:	90                   	nop
  8020c0:	89 d1                	mov    %edx,%ecx
  8020c2:	89 fa                	mov    %edi,%edx
  8020c4:	89 c8                	mov    %ecx,%eax
  8020c6:	31 ff                	xor    %edi,%edi
  8020c8:	f7 f6                	div    %esi
  8020ca:	89 c1                	mov    %eax,%ecx
  8020cc:	89 fa                	mov    %edi,%edx
  8020ce:	89 c8                	mov    %ecx,%eax
  8020d0:	83 c4 10             	add    $0x10,%esp
  8020d3:	5e                   	pop    %esi
  8020d4:	5f                   	pop    %edi
  8020d5:	5d                   	pop    %ebp
  8020d6:	c3                   	ret    
  8020d7:	90                   	nop
  8020d8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8020dc:	89 f2                	mov    %esi,%edx
  8020de:	d3 e0                	shl    %cl,%eax
  8020e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020e3:	b8 20 00 00 00       	mov    $0x20,%eax
  8020e8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8020eb:	89 c1                	mov    %eax,%ecx
  8020ed:	d3 ea                	shr    %cl,%edx
  8020ef:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8020f3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8020f6:	d3 e6                	shl    %cl,%esi
  8020f8:	89 c1                	mov    %eax,%ecx
  8020fa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8020fd:	89 fe                	mov    %edi,%esi
  8020ff:	d3 ee                	shr    %cl,%esi
  802101:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802105:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802108:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80210b:	d3 e7                	shl    %cl,%edi
  80210d:	89 c1                	mov    %eax,%ecx
  80210f:	d3 ea                	shr    %cl,%edx
  802111:	09 d7                	or     %edx,%edi
  802113:	89 f2                	mov    %esi,%edx
  802115:	89 f8                	mov    %edi,%eax
  802117:	f7 75 ec             	divl   -0x14(%ebp)
  80211a:	89 d6                	mov    %edx,%esi
  80211c:	89 c7                	mov    %eax,%edi
  80211e:	f7 65 e8             	mull   -0x18(%ebp)
  802121:	39 d6                	cmp    %edx,%esi
  802123:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802126:	72 30                	jb     802158 <__udivdi3+0x118>
  802128:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80212b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80212f:	d3 e2                	shl    %cl,%edx
  802131:	39 c2                	cmp    %eax,%edx
  802133:	73 05                	jae    80213a <__udivdi3+0xfa>
  802135:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802138:	74 1e                	je     802158 <__udivdi3+0x118>
  80213a:	89 f9                	mov    %edi,%ecx
  80213c:	31 ff                	xor    %edi,%edi
  80213e:	e9 71 ff ff ff       	jmp    8020b4 <__udivdi3+0x74>
  802143:	90                   	nop
  802144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802148:	31 ff                	xor    %edi,%edi
  80214a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80214f:	e9 60 ff ff ff       	jmp    8020b4 <__udivdi3+0x74>
  802154:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802158:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80215b:	31 ff                	xor    %edi,%edi
  80215d:	89 c8                	mov    %ecx,%eax
  80215f:	89 fa                	mov    %edi,%edx
  802161:	83 c4 10             	add    $0x10,%esp
  802164:	5e                   	pop    %esi
  802165:	5f                   	pop    %edi
  802166:	5d                   	pop    %ebp
  802167:	c3                   	ret    
	...

00802170 <__umoddi3>:
  802170:	55                   	push   %ebp
  802171:	89 e5                	mov    %esp,%ebp
  802173:	57                   	push   %edi
  802174:	56                   	push   %esi
  802175:	83 ec 20             	sub    $0x20,%esp
  802178:	8b 55 14             	mov    0x14(%ebp),%edx
  80217b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80217e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802181:	8b 75 0c             	mov    0xc(%ebp),%esi
  802184:	85 d2                	test   %edx,%edx
  802186:	89 c8                	mov    %ecx,%eax
  802188:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80218b:	75 13                	jne    8021a0 <__umoddi3+0x30>
  80218d:	39 f7                	cmp    %esi,%edi
  80218f:	76 3f                	jbe    8021d0 <__umoddi3+0x60>
  802191:	89 f2                	mov    %esi,%edx
  802193:	f7 f7                	div    %edi
  802195:	89 d0                	mov    %edx,%eax
  802197:	31 d2                	xor    %edx,%edx
  802199:	83 c4 20             	add    $0x20,%esp
  80219c:	5e                   	pop    %esi
  80219d:	5f                   	pop    %edi
  80219e:	5d                   	pop    %ebp
  80219f:	c3                   	ret    
  8021a0:	39 f2                	cmp    %esi,%edx
  8021a2:	77 4c                	ja     8021f0 <__umoddi3+0x80>
  8021a4:	0f bd ca             	bsr    %edx,%ecx
  8021a7:	83 f1 1f             	xor    $0x1f,%ecx
  8021aa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8021ad:	75 51                	jne    802200 <__umoddi3+0x90>
  8021af:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8021b2:	0f 87 e0 00 00 00    	ja     802298 <__umoddi3+0x128>
  8021b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021bb:	29 f8                	sub    %edi,%eax
  8021bd:	19 d6                	sbb    %edx,%esi
  8021bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8021c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c5:	89 f2                	mov    %esi,%edx
  8021c7:	83 c4 20             	add    $0x20,%esp
  8021ca:	5e                   	pop    %esi
  8021cb:	5f                   	pop    %edi
  8021cc:	5d                   	pop    %ebp
  8021cd:	c3                   	ret    
  8021ce:	66 90                	xchg   %ax,%ax
  8021d0:	85 ff                	test   %edi,%edi
  8021d2:	75 0b                	jne    8021df <__umoddi3+0x6f>
  8021d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8021d9:	31 d2                	xor    %edx,%edx
  8021db:	f7 f7                	div    %edi
  8021dd:	89 c7                	mov    %eax,%edi
  8021df:	89 f0                	mov    %esi,%eax
  8021e1:	31 d2                	xor    %edx,%edx
  8021e3:	f7 f7                	div    %edi
  8021e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021e8:	f7 f7                	div    %edi
  8021ea:	eb a9                	jmp    802195 <__umoddi3+0x25>
  8021ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	89 c8                	mov    %ecx,%eax
  8021f2:	89 f2                	mov    %esi,%edx
  8021f4:	83 c4 20             	add    $0x20,%esp
  8021f7:	5e                   	pop    %esi
  8021f8:	5f                   	pop    %edi
  8021f9:	5d                   	pop    %ebp
  8021fa:	c3                   	ret    
  8021fb:	90                   	nop
  8021fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802200:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802204:	d3 e2                	shl    %cl,%edx
  802206:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802209:	ba 20 00 00 00       	mov    $0x20,%edx
  80220e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802211:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802214:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802218:	89 fa                	mov    %edi,%edx
  80221a:	d3 ea                	shr    %cl,%edx
  80221c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802220:	0b 55 f4             	or     -0xc(%ebp),%edx
  802223:	d3 e7                	shl    %cl,%edi
  802225:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802229:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80222c:	89 f2                	mov    %esi,%edx
  80222e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802231:	89 c7                	mov    %eax,%edi
  802233:	d3 ea                	shr    %cl,%edx
  802235:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802239:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80223c:	89 c2                	mov    %eax,%edx
  80223e:	d3 e6                	shl    %cl,%esi
  802240:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802244:	d3 ea                	shr    %cl,%edx
  802246:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80224a:	09 d6                	or     %edx,%esi
  80224c:	89 f0                	mov    %esi,%eax
  80224e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802251:	d3 e7                	shl    %cl,%edi
  802253:	89 f2                	mov    %esi,%edx
  802255:	f7 75 f4             	divl   -0xc(%ebp)
  802258:	89 d6                	mov    %edx,%esi
  80225a:	f7 65 e8             	mull   -0x18(%ebp)
  80225d:	39 d6                	cmp    %edx,%esi
  80225f:	72 2b                	jb     80228c <__umoddi3+0x11c>
  802261:	39 c7                	cmp    %eax,%edi
  802263:	72 23                	jb     802288 <__umoddi3+0x118>
  802265:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802269:	29 c7                	sub    %eax,%edi
  80226b:	19 d6                	sbb    %edx,%esi
  80226d:	89 f0                	mov    %esi,%eax
  80226f:	89 f2                	mov    %esi,%edx
  802271:	d3 ef                	shr    %cl,%edi
  802273:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802277:	d3 e0                	shl    %cl,%eax
  802279:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80227d:	09 f8                	or     %edi,%eax
  80227f:	d3 ea                	shr    %cl,%edx
  802281:	83 c4 20             	add    $0x20,%esp
  802284:	5e                   	pop    %esi
  802285:	5f                   	pop    %edi
  802286:	5d                   	pop    %ebp
  802287:	c3                   	ret    
  802288:	39 d6                	cmp    %edx,%esi
  80228a:	75 d9                	jne    802265 <__umoddi3+0xf5>
  80228c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80228f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802292:	eb d1                	jmp    802265 <__umoddi3+0xf5>
  802294:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802298:	39 f2                	cmp    %esi,%edx
  80229a:	0f 82 18 ff ff ff    	jb     8021b8 <__umoddi3+0x48>
  8022a0:	e9 1d ff ff ff       	jmp    8021c2 <__umoddi3+0x52>
