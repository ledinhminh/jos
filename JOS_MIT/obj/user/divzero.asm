
obj/user/divzero.debug:     file format elf32-i386


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
  80002c:	e8 37 00 00 00       	call   800068 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	zero = 0;
  80003a:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	ba 01 00 00 00       	mov    $0x1,%edx
  800049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004e:	89 d0                	mov    %edx,%eax
  800050:	c1 fa 1f             	sar    $0x1f,%edx
  800053:	f7 f9                	idiv   %ecx
  800055:	89 44 24 04          	mov    %eax,0x4(%esp)
  800059:	c7 04 24 c0 22 80 00 	movl   $0x8022c0,(%esp)
  800060:	e8 d0 00 00 00       	call   800135 <cprintf>
}
  800065:	c9                   	leave  
  800066:	c3                   	ret    
	...

00800068 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	83 ec 18             	sub    $0x18,%esp
  80006e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800071:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800074:	8b 75 08             	mov    0x8(%ebp),%esi
  800077:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  80007a:	e8 08 0f 00 00       	call   800f87 <sys_getenvid>
  80007f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800084:	c1 e0 07             	shl    $0x7,%eax
  800087:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008c:	a3 0c 40 80 00       	mov    %eax,0x80400c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800091:	85 f6                	test   %esi,%esi
  800093:	7e 07                	jle    80009c <libmain+0x34>
		binaryname = argv[0];
  800095:	8b 03                	mov    (%ebx),%eax
  800097:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80009c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a0:	89 34 24             	mov    %esi,(%esp)
  8000a3:	e8 8c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a8:	e8 0b 00 00 00       	call   8000b8 <exit>
}
  8000ad:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000b0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000b3:	89 ec                	mov    %ebp,%esp
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    
	...

008000b8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b8:	55                   	push   %ebp
  8000b9:	89 e5                	mov    %esp,%ebp
  8000bb:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000be:	e8 96 14 00 00       	call   801559 <close_all>
	sys_env_destroy(0);
  8000c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ca:	e8 f3 0e 00 00       	call   800fc2 <sys_env_destroy>
}
  8000cf:	c9                   	leave  
  8000d0:	c3                   	ret    
  8000d1:	00 00                	add    %al,(%eax)
	...

008000d4 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000d4:	55                   	push   %ebp
  8000d5:	89 e5                	mov    %esp,%ebp
  8000d7:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000dd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000e4:	00 00 00 
	b.cnt = 0;
  8000e7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000ee:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8000fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000ff:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800105:	89 44 24 04          	mov    %eax,0x4(%esp)
  800109:	c7 04 24 4f 01 80 00 	movl   $0x80014f,(%esp)
  800110:	e8 d8 01 00 00       	call   8002ed <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800115:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80011b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80011f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800125:	89 04 24             	mov    %eax,(%esp)
  800128:	e8 09 0f 00 00       	call   801036 <sys_cputs>

	return b.cnt;
}
  80012d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800133:	c9                   	leave  
  800134:	c3                   	ret    

00800135 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800135:	55                   	push   %ebp
  800136:	89 e5                	mov    %esp,%ebp
  800138:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80013b:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80013e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800142:	8b 45 08             	mov    0x8(%ebp),%eax
  800145:	89 04 24             	mov    %eax,(%esp)
  800148:	e8 87 ff ff ff       	call   8000d4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	53                   	push   %ebx
  800153:	83 ec 14             	sub    $0x14,%esp
  800156:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800159:	8b 03                	mov    (%ebx),%eax
  80015b:	8b 55 08             	mov    0x8(%ebp),%edx
  80015e:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800162:	83 c0 01             	add    $0x1,%eax
  800165:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800167:	3d ff 00 00 00       	cmp    $0xff,%eax
  80016c:	75 19                	jne    800187 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80016e:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800175:	00 
  800176:	8d 43 08             	lea    0x8(%ebx),%eax
  800179:	89 04 24             	mov    %eax,(%esp)
  80017c:	e8 b5 0e 00 00       	call   801036 <sys_cputs>
		b->idx = 0;
  800181:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800187:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80018b:	83 c4 14             	add    $0x14,%esp
  80018e:	5b                   	pop    %ebx
  80018f:	5d                   	pop    %ebp
  800190:	c3                   	ret    
	...

008001a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a0:	55                   	push   %ebp
  8001a1:	89 e5                	mov    %esp,%ebp
  8001a3:	57                   	push   %edi
  8001a4:	56                   	push   %esi
  8001a5:	53                   	push   %ebx
  8001a6:	83 ec 4c             	sub    $0x4c,%esp
  8001a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001ac:	89 d6                	mov    %edx,%esi
  8001ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8001bd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001c0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001cb:	39 d1                	cmp    %edx,%ecx
  8001cd:	72 15                	jb     8001e4 <printnum+0x44>
  8001cf:	77 07                	ja     8001d8 <printnum+0x38>
  8001d1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001d4:	39 d0                	cmp    %edx,%eax
  8001d6:	76 0c                	jbe    8001e4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001d8:	83 eb 01             	sub    $0x1,%ebx
  8001db:	85 db                	test   %ebx,%ebx
  8001dd:	8d 76 00             	lea    0x0(%esi),%esi
  8001e0:	7f 61                	jg     800243 <printnum+0xa3>
  8001e2:	eb 70                	jmp    800254 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001e4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001e8:	83 eb 01             	sub    $0x1,%ebx
  8001eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001f3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8001f7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8001fb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8001fe:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800201:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800204:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800208:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80020f:	00 
  800210:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800213:	89 04 24             	mov    %eax,(%esp)
  800216:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800219:	89 54 24 04          	mov    %edx,0x4(%esp)
  80021d:	e8 2e 1e 00 00       	call   802050 <__udivdi3>
  800222:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800225:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800228:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80022c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800230:	89 04 24             	mov    %eax,(%esp)
  800233:	89 54 24 04          	mov    %edx,0x4(%esp)
  800237:	89 f2                	mov    %esi,%edx
  800239:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80023c:	e8 5f ff ff ff       	call   8001a0 <printnum>
  800241:	eb 11                	jmp    800254 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800243:	89 74 24 04          	mov    %esi,0x4(%esp)
  800247:	89 3c 24             	mov    %edi,(%esp)
  80024a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80024d:	83 eb 01             	sub    $0x1,%ebx
  800250:	85 db                	test   %ebx,%ebx
  800252:	7f ef                	jg     800243 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800254:	89 74 24 04          	mov    %esi,0x4(%esp)
  800258:	8b 74 24 04          	mov    0x4(%esp),%esi
  80025c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80025f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800263:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80026a:	00 
  80026b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80026e:	89 14 24             	mov    %edx,(%esp)
  800271:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800274:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800278:	e8 03 1f 00 00       	call   802180 <__umoddi3>
  80027d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800281:	0f be 80 d8 22 80 00 	movsbl 0x8022d8(%eax),%eax
  800288:	89 04 24             	mov    %eax,(%esp)
  80028b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80028e:	83 c4 4c             	add    $0x4c,%esp
  800291:	5b                   	pop    %ebx
  800292:	5e                   	pop    %esi
  800293:	5f                   	pop    %edi
  800294:	5d                   	pop    %ebp
  800295:	c3                   	ret    

00800296 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800299:	83 fa 01             	cmp    $0x1,%edx
  80029c:	7e 0e                	jle    8002ac <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80029e:	8b 10                	mov    (%eax),%edx
  8002a0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002a3:	89 08                	mov    %ecx,(%eax)
  8002a5:	8b 02                	mov    (%edx),%eax
  8002a7:	8b 52 04             	mov    0x4(%edx),%edx
  8002aa:	eb 22                	jmp    8002ce <getuint+0x38>
	else if (lflag)
  8002ac:	85 d2                	test   %edx,%edx
  8002ae:	74 10                	je     8002c0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002b0:	8b 10                	mov    (%eax),%edx
  8002b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b5:	89 08                	mov    %ecx,(%eax)
  8002b7:	8b 02                	mov    (%edx),%eax
  8002b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002be:	eb 0e                	jmp    8002ce <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002c0:	8b 10                	mov    (%eax),%edx
  8002c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002c5:	89 08                	mov    %ecx,(%eax)
  8002c7:	8b 02                	mov    (%edx),%eax
  8002c9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    

008002d0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002d6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002da:	8b 10                	mov    (%eax),%edx
  8002dc:	3b 50 04             	cmp    0x4(%eax),%edx
  8002df:	73 0a                	jae    8002eb <sprintputch+0x1b>
		*b->buf++ = ch;
  8002e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e4:	88 0a                	mov    %cl,(%edx)
  8002e6:	83 c2 01             	add    $0x1,%edx
  8002e9:	89 10                	mov    %edx,(%eax)
}
  8002eb:	5d                   	pop    %ebp
  8002ec:	c3                   	ret    

008002ed <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ed:	55                   	push   %ebp
  8002ee:	89 e5                	mov    %esp,%ebp
  8002f0:	57                   	push   %edi
  8002f1:	56                   	push   %esi
  8002f2:	53                   	push   %ebx
  8002f3:	83 ec 5c             	sub    $0x5c,%esp
  8002f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002f9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8002ff:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800306:	eb 11                	jmp    800319 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800308:	85 c0                	test   %eax,%eax
  80030a:	0f 84 68 04 00 00    	je     800778 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  800310:	89 74 24 04          	mov    %esi,0x4(%esp)
  800314:	89 04 24             	mov    %eax,(%esp)
  800317:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800319:	0f b6 03             	movzbl (%ebx),%eax
  80031c:	83 c3 01             	add    $0x1,%ebx
  80031f:	83 f8 25             	cmp    $0x25,%eax
  800322:	75 e4                	jne    800308 <vprintfmt+0x1b>
  800324:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80032b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800332:	b9 00 00 00 00       	mov    $0x0,%ecx
  800337:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  80033b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800342:	eb 06                	jmp    80034a <vprintfmt+0x5d>
  800344:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  800348:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80034a:	0f b6 13             	movzbl (%ebx),%edx
  80034d:	0f b6 c2             	movzbl %dl,%eax
  800350:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800353:	8d 43 01             	lea    0x1(%ebx),%eax
  800356:	83 ea 23             	sub    $0x23,%edx
  800359:	80 fa 55             	cmp    $0x55,%dl
  80035c:	0f 87 f9 03 00 00    	ja     80075b <vprintfmt+0x46e>
  800362:	0f b6 d2             	movzbl %dl,%edx
  800365:	ff 24 95 c0 24 80 00 	jmp    *0x8024c0(,%edx,4)
  80036c:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800370:	eb d6                	jmp    800348 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800372:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800375:	83 ea 30             	sub    $0x30,%edx
  800378:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80037b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80037e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800381:	83 fb 09             	cmp    $0x9,%ebx
  800384:	77 54                	ja     8003da <vprintfmt+0xed>
  800386:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800389:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80038c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80038f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800392:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800396:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800399:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80039c:	83 fb 09             	cmp    $0x9,%ebx
  80039f:	76 eb                	jbe    80038c <vprintfmt+0x9f>
  8003a1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8003a4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8003a7:	eb 31                	jmp    8003da <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003a9:	8b 55 14             	mov    0x14(%ebp),%edx
  8003ac:	8d 5a 04             	lea    0x4(%edx),%ebx
  8003af:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8003b2:	8b 12                	mov    (%edx),%edx
  8003b4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8003b7:	eb 21                	jmp    8003da <vprintfmt+0xed>

		case '.':
			if (width < 0)
  8003b9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c2:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  8003c6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003c9:	e9 7a ff ff ff       	jmp    800348 <vprintfmt+0x5b>
  8003ce:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003d5:	e9 6e ff ff ff       	jmp    800348 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8003da:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003de:	0f 89 64 ff ff ff    	jns    800348 <vprintfmt+0x5b>
  8003e4:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8003e7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003ea:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8003ed:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8003f0:	e9 53 ff ff ff       	jmp    800348 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003f5:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8003f8:	e9 4b ff ff ff       	jmp    800348 <vprintfmt+0x5b>
  8003fd:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800400:	8b 45 14             	mov    0x14(%ebp),%eax
  800403:	8d 50 04             	lea    0x4(%eax),%edx
  800406:	89 55 14             	mov    %edx,0x14(%ebp)
  800409:	89 74 24 04          	mov    %esi,0x4(%esp)
  80040d:	8b 00                	mov    (%eax),%eax
  80040f:	89 04 24             	mov    %eax,(%esp)
  800412:	ff d7                	call   *%edi
  800414:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800417:	e9 fd fe ff ff       	jmp    800319 <vprintfmt+0x2c>
  80041c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80041f:	8b 45 14             	mov    0x14(%ebp),%eax
  800422:	8d 50 04             	lea    0x4(%eax),%edx
  800425:	89 55 14             	mov    %edx,0x14(%ebp)
  800428:	8b 00                	mov    (%eax),%eax
  80042a:	89 c2                	mov    %eax,%edx
  80042c:	c1 fa 1f             	sar    $0x1f,%edx
  80042f:	31 d0                	xor    %edx,%eax
  800431:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800433:	83 f8 0f             	cmp    $0xf,%eax
  800436:	7f 0b                	jg     800443 <vprintfmt+0x156>
  800438:	8b 14 85 20 26 80 00 	mov    0x802620(,%eax,4),%edx
  80043f:	85 d2                	test   %edx,%edx
  800441:	75 20                	jne    800463 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800443:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800447:	c7 44 24 08 e9 22 80 	movl   $0x8022e9,0x8(%esp)
  80044e:	00 
  80044f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800453:	89 3c 24             	mov    %edi,(%esp)
  800456:	e8 a5 03 00 00       	call   800800 <printfmt>
  80045b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80045e:	e9 b6 fe ff ff       	jmp    800319 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800463:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800467:	c7 44 24 08 3b 27 80 	movl   $0x80273b,0x8(%esp)
  80046e:	00 
  80046f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800473:	89 3c 24             	mov    %edi,(%esp)
  800476:	e8 85 03 00 00       	call   800800 <printfmt>
  80047b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80047e:	e9 96 fe ff ff       	jmp    800319 <vprintfmt+0x2c>
  800483:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800486:	89 c3                	mov    %eax,%ebx
  800488:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80048b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80048e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800491:	8b 45 14             	mov    0x14(%ebp),%eax
  800494:	8d 50 04             	lea    0x4(%eax),%edx
  800497:	89 55 14             	mov    %edx,0x14(%ebp)
  80049a:	8b 00                	mov    (%eax),%eax
  80049c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80049f:	85 c0                	test   %eax,%eax
  8004a1:	b8 f2 22 80 00       	mov    $0x8022f2,%eax
  8004a6:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  8004aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8004ad:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8004b1:	7e 06                	jle    8004b9 <vprintfmt+0x1cc>
  8004b3:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8004b7:	75 13                	jne    8004cc <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004bc:	0f be 02             	movsbl (%edx),%eax
  8004bf:	85 c0                	test   %eax,%eax
  8004c1:	0f 85 a2 00 00 00    	jne    800569 <vprintfmt+0x27c>
  8004c7:	e9 8f 00 00 00       	jmp    80055b <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004cc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004d0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004d3:	89 0c 24             	mov    %ecx,(%esp)
  8004d6:	e8 70 03 00 00       	call   80084b <strnlen>
  8004db:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004de:	29 c2                	sub    %eax,%edx
  8004e0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004e3:	85 d2                	test   %edx,%edx
  8004e5:	7e d2                	jle    8004b9 <vprintfmt+0x1cc>
					putch(padc, putdat);
  8004e7:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8004eb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004ee:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  8004f1:	89 d3                	mov    %edx,%ebx
  8004f3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004f7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004fa:	89 04 24             	mov    %eax,(%esp)
  8004fd:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ff:	83 eb 01             	sub    $0x1,%ebx
  800502:	85 db                	test   %ebx,%ebx
  800504:	7f ed                	jg     8004f3 <vprintfmt+0x206>
  800506:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800509:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800510:	eb a7                	jmp    8004b9 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800512:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800516:	74 1b                	je     800533 <vprintfmt+0x246>
  800518:	8d 50 e0             	lea    -0x20(%eax),%edx
  80051b:	83 fa 5e             	cmp    $0x5e,%edx
  80051e:	76 13                	jbe    800533 <vprintfmt+0x246>
					putch('?', putdat);
  800520:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800523:	89 54 24 04          	mov    %edx,0x4(%esp)
  800527:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80052e:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800531:	eb 0d                	jmp    800540 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800533:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800536:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80053a:	89 04 24             	mov    %eax,(%esp)
  80053d:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800540:	83 ef 01             	sub    $0x1,%edi
  800543:	0f be 03             	movsbl (%ebx),%eax
  800546:	85 c0                	test   %eax,%eax
  800548:	74 05                	je     80054f <vprintfmt+0x262>
  80054a:	83 c3 01             	add    $0x1,%ebx
  80054d:	eb 31                	jmp    800580 <vprintfmt+0x293>
  80054f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800552:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800555:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800558:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80055b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80055f:	7f 36                	jg     800597 <vprintfmt+0x2aa>
  800561:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800564:	e9 b0 fd ff ff       	jmp    800319 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800569:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80056c:	83 c2 01             	add    $0x1,%edx
  80056f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800572:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800575:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800578:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80057b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80057e:	89 d3                	mov    %edx,%ebx
  800580:	85 f6                	test   %esi,%esi
  800582:	78 8e                	js     800512 <vprintfmt+0x225>
  800584:	83 ee 01             	sub    $0x1,%esi
  800587:	79 89                	jns    800512 <vprintfmt+0x225>
  800589:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80058c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80058f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800592:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800595:	eb c4                	jmp    80055b <vprintfmt+0x26e>
  800597:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80059a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80059d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005a1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005a8:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005aa:	83 eb 01             	sub    $0x1,%ebx
  8005ad:	85 db                	test   %ebx,%ebx
  8005af:	7f ec                	jg     80059d <vprintfmt+0x2b0>
  8005b1:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8005b4:	e9 60 fd ff ff       	jmp    800319 <vprintfmt+0x2c>
  8005b9:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005bc:	83 f9 01             	cmp    $0x1,%ecx
  8005bf:	7e 16                	jle    8005d7 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  8005c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c4:	8d 50 08             	lea    0x8(%eax),%edx
  8005c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ca:	8b 10                	mov    (%eax),%edx
  8005cc:	8b 48 04             	mov    0x4(%eax),%ecx
  8005cf:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005d2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d5:	eb 32                	jmp    800609 <vprintfmt+0x31c>
	else if (lflag)
  8005d7:	85 c9                	test   %ecx,%ecx
  8005d9:	74 18                	je     8005f3 <vprintfmt+0x306>
		return va_arg(*ap, long);
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8d 50 04             	lea    0x4(%eax),%edx
  8005e1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e4:	8b 00                	mov    (%eax),%eax
  8005e6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e9:	89 c1                	mov    %eax,%ecx
  8005eb:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ee:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f1:	eb 16                	jmp    800609 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  8005f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f6:	8d 50 04             	lea    0x4(%eax),%edx
  8005f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fc:	8b 00                	mov    (%eax),%eax
  8005fe:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800601:	89 c2                	mov    %eax,%edx
  800603:	c1 fa 1f             	sar    $0x1f,%edx
  800606:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800609:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80060c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80060f:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  800614:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800618:	0f 89 8a 00 00 00    	jns    8006a8 <vprintfmt+0x3bb>
				putch('-', putdat);
  80061e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800622:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800629:	ff d7                	call   *%edi
				num = -(long long) num;
  80062b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80062e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800631:	f7 d8                	neg    %eax
  800633:	83 d2 00             	adc    $0x0,%edx
  800636:	f7 da                	neg    %edx
  800638:	eb 6e                	jmp    8006a8 <vprintfmt+0x3bb>
  80063a:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80063d:	89 ca                	mov    %ecx,%edx
  80063f:	8d 45 14             	lea    0x14(%ebp),%eax
  800642:	e8 4f fc ff ff       	call   800296 <getuint>
  800647:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  80064c:	eb 5a                	jmp    8006a8 <vprintfmt+0x3bb>
  80064e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800651:	89 ca                	mov    %ecx,%edx
  800653:	8d 45 14             	lea    0x14(%ebp),%eax
  800656:	e8 3b fc ff ff       	call   800296 <getuint>
  80065b:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  800660:	eb 46                	jmp    8006a8 <vprintfmt+0x3bb>
  800662:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  800665:	89 74 24 04          	mov    %esi,0x4(%esp)
  800669:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800670:	ff d7                	call   *%edi
			putch('x', putdat);
  800672:	89 74 24 04          	mov    %esi,0x4(%esp)
  800676:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80067d:	ff d7                	call   *%edi
			num = (unsigned long long)
  80067f:	8b 45 14             	mov    0x14(%ebp),%eax
  800682:	8d 50 04             	lea    0x4(%eax),%edx
  800685:	89 55 14             	mov    %edx,0x14(%ebp)
  800688:	8b 00                	mov    (%eax),%eax
  80068a:	ba 00 00 00 00       	mov    $0x0,%edx
  80068f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800694:	eb 12                	jmp    8006a8 <vprintfmt+0x3bb>
  800696:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800699:	89 ca                	mov    %ecx,%edx
  80069b:	8d 45 14             	lea    0x14(%ebp),%eax
  80069e:	e8 f3 fb ff ff       	call   800296 <getuint>
  8006a3:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a8:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8006ac:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8006b0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8006b3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8006b7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8006bb:	89 04 24             	mov    %eax,(%esp)
  8006be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006c2:	89 f2                	mov    %esi,%edx
  8006c4:	89 f8                	mov    %edi,%eax
  8006c6:	e8 d5 fa ff ff       	call   8001a0 <printnum>
  8006cb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8006ce:	e9 46 fc ff ff       	jmp    800319 <vprintfmt+0x2c>
  8006d3:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  8006d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d9:	8d 50 04             	lea    0x4(%eax),%edx
  8006dc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006df:	8b 00                	mov    (%eax),%eax
  8006e1:	85 c0                	test   %eax,%eax
  8006e3:	75 24                	jne    800709 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  8006e5:	c7 44 24 0c 0c 24 80 	movl   $0x80240c,0xc(%esp)
  8006ec:	00 
  8006ed:	c7 44 24 08 3b 27 80 	movl   $0x80273b,0x8(%esp)
  8006f4:	00 
  8006f5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006f9:	89 3c 24             	mov    %edi,(%esp)
  8006fc:	e8 ff 00 00 00       	call   800800 <printfmt>
  800701:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800704:	e9 10 fc ff ff       	jmp    800319 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  800709:	83 3e 7f             	cmpl   $0x7f,(%esi)
  80070c:	7e 29                	jle    800737 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  80070e:	0f b6 16             	movzbl (%esi),%edx
  800711:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  800713:	c7 44 24 0c 44 24 80 	movl   $0x802444,0xc(%esp)
  80071a:	00 
  80071b:	c7 44 24 08 3b 27 80 	movl   $0x80273b,0x8(%esp)
  800722:	00 
  800723:	89 74 24 04          	mov    %esi,0x4(%esp)
  800727:	89 3c 24             	mov    %edi,(%esp)
  80072a:	e8 d1 00 00 00       	call   800800 <printfmt>
  80072f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800732:	e9 e2 fb ff ff       	jmp    800319 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  800737:	0f b6 16             	movzbl (%esi),%edx
  80073a:	88 10                	mov    %dl,(%eax)
  80073c:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  80073f:	e9 d5 fb ff ff       	jmp    800319 <vprintfmt+0x2c>
  800744:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800747:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80074a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80074e:	89 14 24             	mov    %edx,(%esp)
  800751:	ff d7                	call   *%edi
  800753:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800756:	e9 be fb ff ff       	jmp    800319 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80075b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80075f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800766:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800768:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80076b:	80 38 25             	cmpb   $0x25,(%eax)
  80076e:	0f 84 a5 fb ff ff    	je     800319 <vprintfmt+0x2c>
  800774:	89 c3                	mov    %eax,%ebx
  800776:	eb f0                	jmp    800768 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  800778:	83 c4 5c             	add    $0x5c,%esp
  80077b:	5b                   	pop    %ebx
  80077c:	5e                   	pop    %esi
  80077d:	5f                   	pop    %edi
  80077e:	5d                   	pop    %ebp
  80077f:	c3                   	ret    

00800780 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800780:	55                   	push   %ebp
  800781:	89 e5                	mov    %esp,%ebp
  800783:	83 ec 28             	sub    $0x28,%esp
  800786:	8b 45 08             	mov    0x8(%ebp),%eax
  800789:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80078c:	85 c0                	test   %eax,%eax
  80078e:	74 04                	je     800794 <vsnprintf+0x14>
  800790:	85 d2                	test   %edx,%edx
  800792:	7f 07                	jg     80079b <vsnprintf+0x1b>
  800794:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800799:	eb 3b                	jmp    8007d6 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80079b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80079e:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8007a2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007a5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8007af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ba:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c1:	c7 04 24 d0 02 80 00 	movl   $0x8002d0,(%esp)
  8007c8:	e8 20 fb ff ff       	call   8002ed <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007d0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007d6:	c9                   	leave  
  8007d7:	c3                   	ret    

008007d8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8007de:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8007e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e5:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f6:	89 04 24             	mov    %eax,(%esp)
  8007f9:	e8 82 ff ff ff       	call   800780 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007fe:	c9                   	leave  
  8007ff:	c3                   	ret    

00800800 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800806:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800809:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80080d:	8b 45 10             	mov    0x10(%ebp),%eax
  800810:	89 44 24 08          	mov    %eax,0x8(%esp)
  800814:	8b 45 0c             	mov    0xc(%ebp),%eax
  800817:	89 44 24 04          	mov    %eax,0x4(%esp)
  80081b:	8b 45 08             	mov    0x8(%ebp),%eax
  80081e:	89 04 24             	mov    %eax,(%esp)
  800821:	e8 c7 fa ff ff       	call   8002ed <vprintfmt>
	va_end(ap);
}
  800826:	c9                   	leave  
  800827:	c3                   	ret    
	...

00800830 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800836:	b8 00 00 00 00       	mov    $0x0,%eax
  80083b:	80 3a 00             	cmpb   $0x0,(%edx)
  80083e:	74 09                	je     800849 <strlen+0x19>
		n++;
  800840:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800843:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800847:	75 f7                	jne    800840 <strlen+0x10>
		n++;
	return n;
}
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	53                   	push   %ebx
  80084f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800852:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800855:	85 c9                	test   %ecx,%ecx
  800857:	74 19                	je     800872 <strnlen+0x27>
  800859:	80 3b 00             	cmpb   $0x0,(%ebx)
  80085c:	74 14                	je     800872 <strnlen+0x27>
  80085e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800863:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800866:	39 c8                	cmp    %ecx,%eax
  800868:	74 0d                	je     800877 <strnlen+0x2c>
  80086a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80086e:	75 f3                	jne    800863 <strnlen+0x18>
  800870:	eb 05                	jmp    800877 <strnlen+0x2c>
  800872:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800877:	5b                   	pop    %ebx
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	53                   	push   %ebx
  80087e:	8b 45 08             	mov    0x8(%ebp),%eax
  800881:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800884:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800889:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80088d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800890:	83 c2 01             	add    $0x1,%edx
  800893:	84 c9                	test   %cl,%cl
  800895:	75 f2                	jne    800889 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800897:	5b                   	pop    %ebx
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	53                   	push   %ebx
  80089e:	83 ec 08             	sub    $0x8,%esp
  8008a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008a4:	89 1c 24             	mov    %ebx,(%esp)
  8008a7:	e8 84 ff ff ff       	call   800830 <strlen>
	strcpy(dst + len, src);
  8008ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008af:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008b3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8008b6:	89 04 24             	mov    %eax,(%esp)
  8008b9:	e8 bc ff ff ff       	call   80087a <strcpy>
	return dst;
}
  8008be:	89 d8                	mov    %ebx,%eax
  8008c0:	83 c4 08             	add    $0x8,%esp
  8008c3:	5b                   	pop    %ebx
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	56                   	push   %esi
  8008ca:	53                   	push   %ebx
  8008cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d4:	85 f6                	test   %esi,%esi
  8008d6:	74 18                	je     8008f0 <strncpy+0x2a>
  8008d8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008dd:	0f b6 1a             	movzbl (%edx),%ebx
  8008e0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008e3:	80 3a 01             	cmpb   $0x1,(%edx)
  8008e6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e9:	83 c1 01             	add    $0x1,%ecx
  8008ec:	39 ce                	cmp    %ecx,%esi
  8008ee:	77 ed                	ja     8008dd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008f0:	5b                   	pop    %ebx
  8008f1:	5e                   	pop    %esi
  8008f2:	5d                   	pop    %ebp
  8008f3:	c3                   	ret    

008008f4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	56                   	push   %esi
  8008f8:	53                   	push   %ebx
  8008f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800902:	89 f0                	mov    %esi,%eax
  800904:	85 c9                	test   %ecx,%ecx
  800906:	74 27                	je     80092f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800908:	83 e9 01             	sub    $0x1,%ecx
  80090b:	74 1d                	je     80092a <strlcpy+0x36>
  80090d:	0f b6 1a             	movzbl (%edx),%ebx
  800910:	84 db                	test   %bl,%bl
  800912:	74 16                	je     80092a <strlcpy+0x36>
			*dst++ = *src++;
  800914:	88 18                	mov    %bl,(%eax)
  800916:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800919:	83 e9 01             	sub    $0x1,%ecx
  80091c:	74 0e                	je     80092c <strlcpy+0x38>
			*dst++ = *src++;
  80091e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800921:	0f b6 1a             	movzbl (%edx),%ebx
  800924:	84 db                	test   %bl,%bl
  800926:	75 ec                	jne    800914 <strlcpy+0x20>
  800928:	eb 02                	jmp    80092c <strlcpy+0x38>
  80092a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80092c:	c6 00 00             	movb   $0x0,(%eax)
  80092f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800931:	5b                   	pop    %ebx
  800932:	5e                   	pop    %esi
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80093e:	0f b6 01             	movzbl (%ecx),%eax
  800941:	84 c0                	test   %al,%al
  800943:	74 15                	je     80095a <strcmp+0x25>
  800945:	3a 02                	cmp    (%edx),%al
  800947:	75 11                	jne    80095a <strcmp+0x25>
		p++, q++;
  800949:	83 c1 01             	add    $0x1,%ecx
  80094c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80094f:	0f b6 01             	movzbl (%ecx),%eax
  800952:	84 c0                	test   %al,%al
  800954:	74 04                	je     80095a <strcmp+0x25>
  800956:	3a 02                	cmp    (%edx),%al
  800958:	74 ef                	je     800949 <strcmp+0x14>
  80095a:	0f b6 c0             	movzbl %al,%eax
  80095d:	0f b6 12             	movzbl (%edx),%edx
  800960:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	53                   	push   %ebx
  800968:	8b 55 08             	mov    0x8(%ebp),%edx
  80096b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80096e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800971:	85 c0                	test   %eax,%eax
  800973:	74 23                	je     800998 <strncmp+0x34>
  800975:	0f b6 1a             	movzbl (%edx),%ebx
  800978:	84 db                	test   %bl,%bl
  80097a:	74 25                	je     8009a1 <strncmp+0x3d>
  80097c:	3a 19                	cmp    (%ecx),%bl
  80097e:	75 21                	jne    8009a1 <strncmp+0x3d>
  800980:	83 e8 01             	sub    $0x1,%eax
  800983:	74 13                	je     800998 <strncmp+0x34>
		n--, p++, q++;
  800985:	83 c2 01             	add    $0x1,%edx
  800988:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80098b:	0f b6 1a             	movzbl (%edx),%ebx
  80098e:	84 db                	test   %bl,%bl
  800990:	74 0f                	je     8009a1 <strncmp+0x3d>
  800992:	3a 19                	cmp    (%ecx),%bl
  800994:	74 ea                	je     800980 <strncmp+0x1c>
  800996:	eb 09                	jmp    8009a1 <strncmp+0x3d>
  800998:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80099d:	5b                   	pop    %ebx
  80099e:	5d                   	pop    %ebp
  80099f:	90                   	nop
  8009a0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a1:	0f b6 02             	movzbl (%edx),%eax
  8009a4:	0f b6 11             	movzbl (%ecx),%edx
  8009a7:	29 d0                	sub    %edx,%eax
  8009a9:	eb f2                	jmp    80099d <strncmp+0x39>

008009ab <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b5:	0f b6 10             	movzbl (%eax),%edx
  8009b8:	84 d2                	test   %dl,%dl
  8009ba:	74 18                	je     8009d4 <strchr+0x29>
		if (*s == c)
  8009bc:	38 ca                	cmp    %cl,%dl
  8009be:	75 0a                	jne    8009ca <strchr+0x1f>
  8009c0:	eb 17                	jmp    8009d9 <strchr+0x2e>
  8009c2:	38 ca                	cmp    %cl,%dl
  8009c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009c8:	74 0f                	je     8009d9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ca:	83 c0 01             	add    $0x1,%eax
  8009cd:	0f b6 10             	movzbl (%eax),%edx
  8009d0:	84 d2                	test   %dl,%dl
  8009d2:	75 ee                	jne    8009c2 <strchr+0x17>
  8009d4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e5:	0f b6 10             	movzbl (%eax),%edx
  8009e8:	84 d2                	test   %dl,%dl
  8009ea:	74 18                	je     800a04 <strfind+0x29>
		if (*s == c)
  8009ec:	38 ca                	cmp    %cl,%dl
  8009ee:	75 0a                	jne    8009fa <strfind+0x1f>
  8009f0:	eb 12                	jmp    800a04 <strfind+0x29>
  8009f2:	38 ca                	cmp    %cl,%dl
  8009f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009f8:	74 0a                	je     800a04 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009fa:	83 c0 01             	add    $0x1,%eax
  8009fd:	0f b6 10             	movzbl (%eax),%edx
  800a00:	84 d2                	test   %dl,%dl
  800a02:	75 ee                	jne    8009f2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	83 ec 0c             	sub    $0xc,%esp
  800a0c:	89 1c 24             	mov    %ebx,(%esp)
  800a0f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a13:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a17:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a20:	85 c9                	test   %ecx,%ecx
  800a22:	74 30                	je     800a54 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a24:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a2a:	75 25                	jne    800a51 <memset+0x4b>
  800a2c:	f6 c1 03             	test   $0x3,%cl
  800a2f:	75 20                	jne    800a51 <memset+0x4b>
		c &= 0xFF;
  800a31:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a34:	89 d3                	mov    %edx,%ebx
  800a36:	c1 e3 08             	shl    $0x8,%ebx
  800a39:	89 d6                	mov    %edx,%esi
  800a3b:	c1 e6 18             	shl    $0x18,%esi
  800a3e:	89 d0                	mov    %edx,%eax
  800a40:	c1 e0 10             	shl    $0x10,%eax
  800a43:	09 f0                	or     %esi,%eax
  800a45:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800a47:	09 d8                	or     %ebx,%eax
  800a49:	c1 e9 02             	shr    $0x2,%ecx
  800a4c:	fc                   	cld    
  800a4d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a4f:	eb 03                	jmp    800a54 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a51:	fc                   	cld    
  800a52:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a54:	89 f8                	mov    %edi,%eax
  800a56:	8b 1c 24             	mov    (%esp),%ebx
  800a59:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a5d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a61:	89 ec                	mov    %ebp,%esp
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	83 ec 08             	sub    $0x8,%esp
  800a6b:	89 34 24             	mov    %esi,(%esp)
  800a6e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a72:	8b 45 08             	mov    0x8(%ebp),%eax
  800a75:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800a78:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a7b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a7d:	39 c6                	cmp    %eax,%esi
  800a7f:	73 35                	jae    800ab6 <memmove+0x51>
  800a81:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a84:	39 d0                	cmp    %edx,%eax
  800a86:	73 2e                	jae    800ab6 <memmove+0x51>
		s += n;
		d += n;
  800a88:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8a:	f6 c2 03             	test   $0x3,%dl
  800a8d:	75 1b                	jne    800aaa <memmove+0x45>
  800a8f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a95:	75 13                	jne    800aaa <memmove+0x45>
  800a97:	f6 c1 03             	test   $0x3,%cl
  800a9a:	75 0e                	jne    800aaa <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800a9c:	83 ef 04             	sub    $0x4,%edi
  800a9f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aa2:	c1 e9 02             	shr    $0x2,%ecx
  800aa5:	fd                   	std    
  800aa6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa8:	eb 09                	jmp    800ab3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aaa:	83 ef 01             	sub    $0x1,%edi
  800aad:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ab0:	fd                   	std    
  800ab1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ab3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ab4:	eb 20                	jmp    800ad6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800abc:	75 15                	jne    800ad3 <memmove+0x6e>
  800abe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ac4:	75 0d                	jne    800ad3 <memmove+0x6e>
  800ac6:	f6 c1 03             	test   $0x3,%cl
  800ac9:	75 08                	jne    800ad3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800acb:	c1 e9 02             	shr    $0x2,%ecx
  800ace:	fc                   	cld    
  800acf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad1:	eb 03                	jmp    800ad6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ad3:	fc                   	cld    
  800ad4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ad6:	8b 34 24             	mov    (%esp),%esi
  800ad9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800add:	89 ec                	mov    %ebp,%esp
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ae7:	8b 45 10             	mov    0x10(%ebp),%eax
  800aea:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aee:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af5:	8b 45 08             	mov    0x8(%ebp),%eax
  800af8:	89 04 24             	mov    %eax,(%esp)
  800afb:	e8 65 ff ff ff       	call   800a65 <memmove>
}
  800b00:	c9                   	leave  
  800b01:	c3                   	ret    

00800b02 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
  800b08:	8b 75 08             	mov    0x8(%ebp),%esi
  800b0b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b11:	85 c9                	test   %ecx,%ecx
  800b13:	74 36                	je     800b4b <memcmp+0x49>
		if (*s1 != *s2)
  800b15:	0f b6 06             	movzbl (%esi),%eax
  800b18:	0f b6 1f             	movzbl (%edi),%ebx
  800b1b:	38 d8                	cmp    %bl,%al
  800b1d:	74 20                	je     800b3f <memcmp+0x3d>
  800b1f:	eb 14                	jmp    800b35 <memcmp+0x33>
  800b21:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800b26:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800b2b:	83 c2 01             	add    $0x1,%edx
  800b2e:	83 e9 01             	sub    $0x1,%ecx
  800b31:	38 d8                	cmp    %bl,%al
  800b33:	74 12                	je     800b47 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800b35:	0f b6 c0             	movzbl %al,%eax
  800b38:	0f b6 db             	movzbl %bl,%ebx
  800b3b:	29 d8                	sub    %ebx,%eax
  800b3d:	eb 11                	jmp    800b50 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3f:	83 e9 01             	sub    $0x1,%ecx
  800b42:	ba 00 00 00 00       	mov    $0x0,%edx
  800b47:	85 c9                	test   %ecx,%ecx
  800b49:	75 d6                	jne    800b21 <memcmp+0x1f>
  800b4b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5f                   	pop    %edi
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b5b:	89 c2                	mov    %eax,%edx
  800b5d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b60:	39 d0                	cmp    %edx,%eax
  800b62:	73 15                	jae    800b79 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b64:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b68:	38 08                	cmp    %cl,(%eax)
  800b6a:	75 06                	jne    800b72 <memfind+0x1d>
  800b6c:	eb 0b                	jmp    800b79 <memfind+0x24>
  800b6e:	38 08                	cmp    %cl,(%eax)
  800b70:	74 07                	je     800b79 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b72:	83 c0 01             	add    $0x1,%eax
  800b75:	39 c2                	cmp    %eax,%edx
  800b77:	77 f5                	ja     800b6e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
  800b81:	83 ec 04             	sub    $0x4,%esp
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b8a:	0f b6 02             	movzbl (%edx),%eax
  800b8d:	3c 20                	cmp    $0x20,%al
  800b8f:	74 04                	je     800b95 <strtol+0x1a>
  800b91:	3c 09                	cmp    $0x9,%al
  800b93:	75 0e                	jne    800ba3 <strtol+0x28>
		s++;
  800b95:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b98:	0f b6 02             	movzbl (%edx),%eax
  800b9b:	3c 20                	cmp    $0x20,%al
  800b9d:	74 f6                	je     800b95 <strtol+0x1a>
  800b9f:	3c 09                	cmp    $0x9,%al
  800ba1:	74 f2                	je     800b95 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ba3:	3c 2b                	cmp    $0x2b,%al
  800ba5:	75 0c                	jne    800bb3 <strtol+0x38>
		s++;
  800ba7:	83 c2 01             	add    $0x1,%edx
  800baa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bb1:	eb 15                	jmp    800bc8 <strtol+0x4d>
	else if (*s == '-')
  800bb3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bba:	3c 2d                	cmp    $0x2d,%al
  800bbc:	75 0a                	jne    800bc8 <strtol+0x4d>
		s++, neg = 1;
  800bbe:	83 c2 01             	add    $0x1,%edx
  800bc1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc8:	85 db                	test   %ebx,%ebx
  800bca:	0f 94 c0             	sete   %al
  800bcd:	74 05                	je     800bd4 <strtol+0x59>
  800bcf:	83 fb 10             	cmp    $0x10,%ebx
  800bd2:	75 18                	jne    800bec <strtol+0x71>
  800bd4:	80 3a 30             	cmpb   $0x30,(%edx)
  800bd7:	75 13                	jne    800bec <strtol+0x71>
  800bd9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bdd:	8d 76 00             	lea    0x0(%esi),%esi
  800be0:	75 0a                	jne    800bec <strtol+0x71>
		s += 2, base = 16;
  800be2:	83 c2 02             	add    $0x2,%edx
  800be5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bea:	eb 15                	jmp    800c01 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bec:	84 c0                	test   %al,%al
  800bee:	66 90                	xchg   %ax,%ax
  800bf0:	74 0f                	je     800c01 <strtol+0x86>
  800bf2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bf7:	80 3a 30             	cmpb   $0x30,(%edx)
  800bfa:	75 05                	jne    800c01 <strtol+0x86>
		s++, base = 8;
  800bfc:	83 c2 01             	add    $0x1,%edx
  800bff:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c01:	b8 00 00 00 00       	mov    $0x0,%eax
  800c06:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c08:	0f b6 0a             	movzbl (%edx),%ecx
  800c0b:	89 cf                	mov    %ecx,%edi
  800c0d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c10:	80 fb 09             	cmp    $0x9,%bl
  800c13:	77 08                	ja     800c1d <strtol+0xa2>
			dig = *s - '0';
  800c15:	0f be c9             	movsbl %cl,%ecx
  800c18:	83 e9 30             	sub    $0x30,%ecx
  800c1b:	eb 1e                	jmp    800c3b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800c1d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800c20:	80 fb 19             	cmp    $0x19,%bl
  800c23:	77 08                	ja     800c2d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800c25:	0f be c9             	movsbl %cl,%ecx
  800c28:	83 e9 57             	sub    $0x57,%ecx
  800c2b:	eb 0e                	jmp    800c3b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800c2d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800c30:	80 fb 19             	cmp    $0x19,%bl
  800c33:	77 15                	ja     800c4a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800c35:	0f be c9             	movsbl %cl,%ecx
  800c38:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c3b:	39 f1                	cmp    %esi,%ecx
  800c3d:	7d 0b                	jge    800c4a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800c3f:	83 c2 01             	add    $0x1,%edx
  800c42:	0f af c6             	imul   %esi,%eax
  800c45:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c48:	eb be                	jmp    800c08 <strtol+0x8d>
  800c4a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800c4c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c50:	74 05                	je     800c57 <strtol+0xdc>
		*endptr = (char *) s;
  800c52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c55:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c57:	89 ca                	mov    %ecx,%edx
  800c59:	f7 da                	neg    %edx
  800c5b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c5f:	0f 45 c2             	cmovne %edx,%eax
}
  800c62:	83 c4 04             	add    $0x4,%esp
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    
	...

00800c6c <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c6c:	55                   	push   %ebp
  800c6d:	89 e5                	mov    %esp,%ebp
  800c6f:	83 ec 48             	sub    $0x48,%esp
  800c72:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c75:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c78:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c7b:	89 c6                	mov    %eax,%esi
  800c7d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800c80:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c82:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c85:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c88:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c8b:	51                   	push   %ecx
  800c8c:	52                   	push   %edx
  800c8d:	53                   	push   %ebx
  800c8e:	54                   	push   %esp
  800c8f:	55                   	push   %ebp
  800c90:	56                   	push   %esi
  800c91:	57                   	push   %edi
  800c92:	89 e5                	mov    %esp,%ebp
  800c94:	8d 35 9c 0c 80 00    	lea    0x800c9c,%esi
  800c9a:	0f 34                	sysenter 

00800c9c <.after_sysenter_label>:
  800c9c:	5f                   	pop    %edi
  800c9d:	5e                   	pop    %esi
  800c9e:	5d                   	pop    %ebp
  800c9f:	5c                   	pop    %esp
  800ca0:	5b                   	pop    %ebx
  800ca1:	5a                   	pop    %edx
  800ca2:	59                   	pop    %ecx
  800ca3:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800ca5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ca9:	74 28                	je     800cd3 <.after_sysenter_label+0x37>
  800cab:	85 c0                	test   %eax,%eax
  800cad:	7e 24                	jle    800cd3 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  800caf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cb3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800cb7:	c7 44 24 08 60 26 80 	movl   $0x802660,0x8(%esp)
  800cbe:	00 
  800cbf:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800cc6:	00 
  800cc7:	c7 04 24 7d 26 80 00 	movl   $0x80267d,(%esp)
  800cce:	e8 91 11 00 00       	call   801e64 <_panic>

	return ret;
}
  800cd3:	89 d0                	mov    %edx,%eax
  800cd5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cd8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cdb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cde:	89 ec                	mov    %ebp,%esp
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    

00800ce2 <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  800ce8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800cef:	00 
  800cf0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800cf7:	00 
  800cf8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800cff:	00 
  800d00:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d03:	89 04 24             	mov    %eax,(%esp)
  800d06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d09:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0e:	b8 10 00 00 00       	mov    $0x10,%eax
  800d13:	e8 54 ff ff ff       	call   800c6c <syscall>
}
  800d18:	c9                   	leave  
  800d19:	c3                   	ret    

00800d1a <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  800d20:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d27:	00 
  800d28:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d2f:	00 
  800d30:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d37:	00 
  800d38:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d3f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d44:	ba 00 00 00 00       	mov    $0x0,%edx
  800d49:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d4e:	e8 19 ff ff ff       	call   800c6c <syscall>
}
  800d53:	c9                   	leave  
  800d54:	c3                   	ret    

00800d55 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800d55:	55                   	push   %ebp
  800d56:	89 e5                	mov    %esp,%ebp
  800d58:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d5b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d62:	00 
  800d63:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d6a:	00 
  800d6b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d72:	00 
  800d73:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d7d:	ba 01 00 00 00       	mov    $0x1,%edx
  800d82:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d87:	e8 e0 fe ff ff       	call   800c6c <syscall>
}
  800d8c:	c9                   	leave  
  800d8d:	c3                   	ret    

00800d8e <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d8e:	55                   	push   %ebp
  800d8f:	89 e5                	mov    %esp,%ebp
  800d91:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d94:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d9b:	00 
  800d9c:	8b 45 14             	mov    0x14(%ebp),%eax
  800d9f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800da3:	8b 45 10             	mov    0x10(%ebp),%eax
  800da6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800daa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dad:	89 04 24             	mov    %eax,(%esp)
  800db0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db3:	ba 00 00 00 00       	mov    $0x0,%edx
  800db8:	b8 0d 00 00 00       	mov    $0xd,%eax
  800dbd:	e8 aa fe ff ff       	call   800c6c <syscall>
}
  800dc2:	c9                   	leave  
  800dc3:	c3                   	ret    

00800dc4 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800dca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dd1:	00 
  800dd2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800dd9:	00 
  800dda:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800de1:	00 
  800de2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de5:	89 04 24             	mov    %eax,(%esp)
  800de8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800deb:	ba 01 00 00 00       	mov    $0x1,%edx
  800df0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800df5:	e8 72 fe ff ff       	call   800c6c <syscall>
}
  800dfa:	c9                   	leave  
  800dfb:	c3                   	ret    

00800dfc <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800e02:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e09:	00 
  800e0a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e11:	00 
  800e12:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e19:	00 
  800e1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e1d:	89 04 24             	mov    %eax,(%esp)
  800e20:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e23:	ba 01 00 00 00       	mov    $0x1,%edx
  800e28:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e2d:	e8 3a fe ff ff       	call   800c6c <syscall>
}
  800e32:	c9                   	leave  
  800e33:	c3                   	ret    

00800e34 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800e3a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e41:	00 
  800e42:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e49:	00 
  800e4a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e51:	00 
  800e52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e55:	89 04 24             	mov    %eax,(%esp)
  800e58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5b:	ba 01 00 00 00       	mov    $0x1,%edx
  800e60:	b8 09 00 00 00       	mov    $0x9,%eax
  800e65:	e8 02 fe ff ff       	call   800c6c <syscall>
}
  800e6a:	c9                   	leave  
  800e6b:	c3                   	ret    

00800e6c <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800e6c:	55                   	push   %ebp
  800e6d:	89 e5                	mov    %esp,%ebp
  800e6f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800e72:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e79:	00 
  800e7a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e81:	00 
  800e82:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e89:	00 
  800e8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8d:	89 04 24             	mov    %eax,(%esp)
  800e90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e93:	ba 01 00 00 00       	mov    $0x1,%edx
  800e98:	b8 07 00 00 00       	mov    $0x7,%eax
  800e9d:	e8 ca fd ff ff       	call   800c6c <syscall>
}
  800ea2:	c9                   	leave  
  800ea3:	c3                   	ret    

00800ea4 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800eaa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800eb1:	00 
  800eb2:	8b 45 18             	mov    0x18(%ebp),%eax
  800eb5:	0b 45 14             	or     0x14(%ebp),%eax
  800eb8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ebc:	8b 45 10             	mov    0x10(%ebp),%eax
  800ebf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ec3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec6:	89 04 24             	mov    %eax,(%esp)
  800ec9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ecc:	ba 01 00 00 00       	mov    $0x1,%edx
  800ed1:	b8 06 00 00 00       	mov    $0x6,%eax
  800ed6:	e8 91 fd ff ff       	call   800c6c <syscall>
}
  800edb:	c9                   	leave  
  800edc:	c3                   	ret    

00800edd <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
  800ee0:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800ee3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800eea:	00 
  800eeb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ef2:	00 
  800ef3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ef6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800efa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800efd:	89 04 24             	mov    %eax,(%esp)
  800f00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f03:	ba 01 00 00 00       	mov    $0x1,%edx
  800f08:	b8 05 00 00 00       	mov    $0x5,%eax
  800f0d:	e8 5a fd ff ff       	call   800c6c <syscall>
}
  800f12:	c9                   	leave  
  800f13:	c3                   	ret    

00800f14 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f1a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f21:	00 
  800f22:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f29:	00 
  800f2a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f31:	00 
  800f32:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f39:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f43:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f48:	e8 1f fd ff ff       	call   800c6c <syscall>
}
  800f4d:	c9                   	leave  
  800f4e:	c3                   	ret    

00800f4f <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  800f55:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f5c:	00 
  800f5d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f64:	00 
  800f65:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f6c:	00 
  800f6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f70:	89 04 24             	mov    %eax,(%esp)
  800f73:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f76:	ba 00 00 00 00       	mov    $0x0,%edx
  800f7b:	b8 04 00 00 00       	mov    $0x4,%eax
  800f80:	e8 e7 fc ff ff       	call   800c6c <syscall>
}
  800f85:	c9                   	leave  
  800f86:	c3                   	ret    

00800f87 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800f8d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f94:	00 
  800f95:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f9c:	00 
  800f9d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fa4:	00 
  800fa5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fac:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fb1:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb6:	b8 02 00 00 00       	mov    $0x2,%eax
  800fbb:	e8 ac fc ff ff       	call   800c6c <syscall>
}
  800fc0:	c9                   	leave  
  800fc1:	c3                   	ret    

00800fc2 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800fc2:	55                   	push   %ebp
  800fc3:	89 e5                	mov    %esp,%ebp
  800fc5:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800fc8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fcf:	00 
  800fd0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fd7:	00 
  800fd8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fdf:	00 
  800fe0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fe7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fea:	ba 01 00 00 00       	mov    $0x1,%edx
  800fef:	b8 03 00 00 00       	mov    $0x3,%eax
  800ff4:	e8 73 fc ff ff       	call   800c6c <syscall>
}
  800ff9:	c9                   	leave  
  800ffa:	c3                   	ret    

00800ffb <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  801001:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801008:	00 
  801009:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801010:	00 
  801011:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801018:	00 
  801019:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801020:	b9 00 00 00 00       	mov    $0x0,%ecx
  801025:	ba 00 00 00 00       	mov    $0x0,%edx
  80102a:	b8 01 00 00 00       	mov    $0x1,%eax
  80102f:	e8 38 fc ff ff       	call   800c6c <syscall>
}
  801034:	c9                   	leave  
  801035:	c3                   	ret    

00801036 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801036:	55                   	push   %ebp
  801037:	89 e5                	mov    %esp,%ebp
  801039:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80103c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801043:	00 
  801044:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80104b:	00 
  80104c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801053:	00 
  801054:	8b 45 0c             	mov    0xc(%ebp),%eax
  801057:	89 04 24             	mov    %eax,(%esp)
  80105a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80105d:	ba 00 00 00 00       	mov    $0x0,%edx
  801062:	b8 00 00 00 00       	mov    $0x0,%eax
  801067:	e8 00 fc ff ff       	call   800c6c <syscall>
}
  80106c:	c9                   	leave  
  80106d:	c3                   	ret    
	...

00801070 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801070:	55                   	push   %ebp
  801071:	89 e5                	mov    %esp,%ebp
  801073:	8b 45 08             	mov    0x8(%ebp),%eax
  801076:	05 00 00 00 30       	add    $0x30000000,%eax
  80107b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80107e:	5d                   	pop    %ebp
  80107f:	c3                   	ret    

00801080 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801080:	55                   	push   %ebp
  801081:	89 e5                	mov    %esp,%ebp
  801083:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801086:	8b 45 08             	mov    0x8(%ebp),%eax
  801089:	89 04 24             	mov    %eax,(%esp)
  80108c:	e8 df ff ff ff       	call   801070 <fd2num>
  801091:	05 20 00 0d 00       	add    $0xd0020,%eax
  801096:	c1 e0 0c             	shl    $0xc,%eax
}
  801099:	c9                   	leave  
  80109a:	c3                   	ret    

0080109b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80109b:	55                   	push   %ebp
  80109c:	89 e5                	mov    %esp,%ebp
  80109e:	57                   	push   %edi
  80109f:	56                   	push   %esi
  8010a0:	53                   	push   %ebx
  8010a1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8010a4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8010a9:	a8 01                	test   $0x1,%al
  8010ab:	74 36                	je     8010e3 <fd_alloc+0x48>
  8010ad:	a1 00 00 74 ef       	mov    0xef740000,%eax
  8010b2:	a8 01                	test   $0x1,%al
  8010b4:	74 2d                	je     8010e3 <fd_alloc+0x48>
  8010b6:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  8010bb:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8010c0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8010c5:	89 c3                	mov    %eax,%ebx
  8010c7:	89 c2                	mov    %eax,%edx
  8010c9:	c1 ea 16             	shr    $0x16,%edx
  8010cc:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8010cf:	f6 c2 01             	test   $0x1,%dl
  8010d2:	74 14                	je     8010e8 <fd_alloc+0x4d>
  8010d4:	89 c2                	mov    %eax,%edx
  8010d6:	c1 ea 0c             	shr    $0xc,%edx
  8010d9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8010dc:	f6 c2 01             	test   $0x1,%dl
  8010df:	75 10                	jne    8010f1 <fd_alloc+0x56>
  8010e1:	eb 05                	jmp    8010e8 <fd_alloc+0x4d>
  8010e3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8010e8:	89 1f                	mov    %ebx,(%edi)
  8010ea:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8010ef:	eb 17                	jmp    801108 <fd_alloc+0x6d>
  8010f1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010f6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010fb:	75 c8                	jne    8010c5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010fd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801103:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801108:	5b                   	pop    %ebx
  801109:	5e                   	pop    %esi
  80110a:	5f                   	pop    %edi
  80110b:	5d                   	pop    %ebp
  80110c:	c3                   	ret    

0080110d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80110d:	55                   	push   %ebp
  80110e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801110:	8b 45 08             	mov    0x8(%ebp),%eax
  801113:	83 f8 1f             	cmp    $0x1f,%eax
  801116:	77 36                	ja     80114e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801118:	05 00 00 0d 00       	add    $0xd0000,%eax
  80111d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801120:	89 c2                	mov    %eax,%edx
  801122:	c1 ea 16             	shr    $0x16,%edx
  801125:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80112c:	f6 c2 01             	test   $0x1,%dl
  80112f:	74 1d                	je     80114e <fd_lookup+0x41>
  801131:	89 c2                	mov    %eax,%edx
  801133:	c1 ea 0c             	shr    $0xc,%edx
  801136:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80113d:	f6 c2 01             	test   $0x1,%dl
  801140:	74 0c                	je     80114e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801142:	8b 55 0c             	mov    0xc(%ebp),%edx
  801145:	89 02                	mov    %eax,(%edx)
  801147:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80114c:	eb 05                	jmp    801153 <fd_lookup+0x46>
  80114e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801153:	5d                   	pop    %ebp
  801154:	c3                   	ret    

00801155 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80115b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80115e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801162:	8b 45 08             	mov    0x8(%ebp),%eax
  801165:	89 04 24             	mov    %eax,(%esp)
  801168:	e8 a0 ff ff ff       	call   80110d <fd_lookup>
  80116d:	85 c0                	test   %eax,%eax
  80116f:	78 0e                	js     80117f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801171:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801174:	8b 55 0c             	mov    0xc(%ebp),%edx
  801177:	89 50 04             	mov    %edx,0x4(%eax)
  80117a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80117f:	c9                   	leave  
  801180:	c3                   	ret    

00801181 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801181:	55                   	push   %ebp
  801182:	89 e5                	mov    %esp,%ebp
  801184:	56                   	push   %esi
  801185:	53                   	push   %ebx
  801186:	83 ec 10             	sub    $0x10,%esp
  801189:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80118c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80118f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801194:	b8 04 30 80 00       	mov    $0x803004,%eax
  801199:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80119f:	75 11                	jne    8011b2 <dev_lookup+0x31>
  8011a1:	eb 04                	jmp    8011a7 <dev_lookup+0x26>
  8011a3:	39 08                	cmp    %ecx,(%eax)
  8011a5:	75 10                	jne    8011b7 <dev_lookup+0x36>
			*dev = devtab[i];
  8011a7:	89 03                	mov    %eax,(%ebx)
  8011a9:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8011ae:	66 90                	xchg   %ax,%ax
  8011b0:	eb 36                	jmp    8011e8 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  8011b2:	be 08 27 80 00       	mov    $0x802708,%esi
  8011b7:	83 c2 01             	add    $0x1,%edx
  8011ba:	8b 04 96             	mov    (%esi,%edx,4),%eax
  8011bd:	85 c0                	test   %eax,%eax
  8011bf:	75 e2                	jne    8011a3 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011c1:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8011c6:	8b 40 48             	mov    0x48(%eax),%eax
  8011c9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d1:	c7 04 24 8c 26 80 00 	movl   $0x80268c,(%esp)
  8011d8:	e8 58 ef ff ff       	call   800135 <cprintf>
	*dev = 0;
  8011dd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8011e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8011e8:	83 c4 10             	add    $0x10,%esp
  8011eb:	5b                   	pop    %ebx
  8011ec:	5e                   	pop    %esi
  8011ed:	5d                   	pop    %ebp
  8011ee:	c3                   	ret    

008011ef <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8011ef:	55                   	push   %ebp
  8011f0:	89 e5                	mov    %esp,%ebp
  8011f2:	53                   	push   %ebx
  8011f3:	83 ec 24             	sub    $0x24,%esp
  8011f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801200:	8b 45 08             	mov    0x8(%ebp),%eax
  801203:	89 04 24             	mov    %eax,(%esp)
  801206:	e8 02 ff ff ff       	call   80110d <fd_lookup>
  80120b:	85 c0                	test   %eax,%eax
  80120d:	78 53                	js     801262 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80120f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801212:	89 44 24 04          	mov    %eax,0x4(%esp)
  801216:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801219:	8b 00                	mov    (%eax),%eax
  80121b:	89 04 24             	mov    %eax,(%esp)
  80121e:	e8 5e ff ff ff       	call   801181 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801223:	85 c0                	test   %eax,%eax
  801225:	78 3b                	js     801262 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801227:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80122c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80122f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801233:	74 2d                	je     801262 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801235:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801238:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80123f:	00 00 00 
	stat->st_isdir = 0;
  801242:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801249:	00 00 00 
	stat->st_dev = dev;
  80124c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80124f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801255:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801259:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80125c:	89 14 24             	mov    %edx,(%esp)
  80125f:	ff 50 14             	call   *0x14(%eax)
}
  801262:	83 c4 24             	add    $0x24,%esp
  801265:	5b                   	pop    %ebx
  801266:	5d                   	pop    %ebp
  801267:	c3                   	ret    

00801268 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	53                   	push   %ebx
  80126c:	83 ec 24             	sub    $0x24,%esp
  80126f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801272:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801275:	89 44 24 04          	mov    %eax,0x4(%esp)
  801279:	89 1c 24             	mov    %ebx,(%esp)
  80127c:	e8 8c fe ff ff       	call   80110d <fd_lookup>
  801281:	85 c0                	test   %eax,%eax
  801283:	78 5f                	js     8012e4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801285:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801288:	89 44 24 04          	mov    %eax,0x4(%esp)
  80128c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128f:	8b 00                	mov    (%eax),%eax
  801291:	89 04 24             	mov    %eax,(%esp)
  801294:	e8 e8 fe ff ff       	call   801181 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801299:	85 c0                	test   %eax,%eax
  80129b:	78 47                	js     8012e4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80129d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012a0:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8012a4:	75 23                	jne    8012c9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012a6:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012ab:	8b 40 48             	mov    0x48(%eax),%eax
  8012ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b6:	c7 04 24 ac 26 80 00 	movl   $0x8026ac,(%esp)
  8012bd:	e8 73 ee ff ff       	call   800135 <cprintf>
  8012c2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012c7:	eb 1b                	jmp    8012e4 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8012c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012cc:	8b 48 18             	mov    0x18(%eax),%ecx
  8012cf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012d4:	85 c9                	test   %ecx,%ecx
  8012d6:	74 0c                	je     8012e4 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012d8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012df:	89 14 24             	mov    %edx,(%esp)
  8012e2:	ff d1                	call   *%ecx
}
  8012e4:	83 c4 24             	add    $0x24,%esp
  8012e7:	5b                   	pop    %ebx
  8012e8:	5d                   	pop    %ebp
  8012e9:	c3                   	ret    

008012ea <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012ea:	55                   	push   %ebp
  8012eb:	89 e5                	mov    %esp,%ebp
  8012ed:	53                   	push   %ebx
  8012ee:	83 ec 24             	sub    $0x24,%esp
  8012f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012fb:	89 1c 24             	mov    %ebx,(%esp)
  8012fe:	e8 0a fe ff ff       	call   80110d <fd_lookup>
  801303:	85 c0                	test   %eax,%eax
  801305:	78 66                	js     80136d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801307:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80130e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801311:	8b 00                	mov    (%eax),%eax
  801313:	89 04 24             	mov    %eax,(%esp)
  801316:	e8 66 fe ff ff       	call   801181 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80131b:	85 c0                	test   %eax,%eax
  80131d:	78 4e                	js     80136d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80131f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801322:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801326:	75 23                	jne    80134b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801328:	a1 0c 40 80 00       	mov    0x80400c,%eax
  80132d:	8b 40 48             	mov    0x48(%eax),%eax
  801330:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801334:	89 44 24 04          	mov    %eax,0x4(%esp)
  801338:	c7 04 24 cd 26 80 00 	movl   $0x8026cd,(%esp)
  80133f:	e8 f1 ed ff ff       	call   800135 <cprintf>
  801344:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801349:	eb 22                	jmp    80136d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80134b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80134e:	8b 48 0c             	mov    0xc(%eax),%ecx
  801351:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801356:	85 c9                	test   %ecx,%ecx
  801358:	74 13                	je     80136d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80135a:	8b 45 10             	mov    0x10(%ebp),%eax
  80135d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801361:	8b 45 0c             	mov    0xc(%ebp),%eax
  801364:	89 44 24 04          	mov    %eax,0x4(%esp)
  801368:	89 14 24             	mov    %edx,(%esp)
  80136b:	ff d1                	call   *%ecx
}
  80136d:	83 c4 24             	add    $0x24,%esp
  801370:	5b                   	pop    %ebx
  801371:	5d                   	pop    %ebp
  801372:	c3                   	ret    

00801373 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801373:	55                   	push   %ebp
  801374:	89 e5                	mov    %esp,%ebp
  801376:	53                   	push   %ebx
  801377:	83 ec 24             	sub    $0x24,%esp
  80137a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80137d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801380:	89 44 24 04          	mov    %eax,0x4(%esp)
  801384:	89 1c 24             	mov    %ebx,(%esp)
  801387:	e8 81 fd ff ff       	call   80110d <fd_lookup>
  80138c:	85 c0                	test   %eax,%eax
  80138e:	78 6b                	js     8013fb <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801390:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801393:	89 44 24 04          	mov    %eax,0x4(%esp)
  801397:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80139a:	8b 00                	mov    (%eax),%eax
  80139c:	89 04 24             	mov    %eax,(%esp)
  80139f:	e8 dd fd ff ff       	call   801181 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a4:	85 c0                	test   %eax,%eax
  8013a6:	78 53                	js     8013fb <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013ab:	8b 42 08             	mov    0x8(%edx),%eax
  8013ae:	83 e0 03             	and    $0x3,%eax
  8013b1:	83 f8 01             	cmp    $0x1,%eax
  8013b4:	75 23                	jne    8013d9 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013b6:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8013bb:	8b 40 48             	mov    0x48(%eax),%eax
  8013be:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c6:	c7 04 24 ea 26 80 00 	movl   $0x8026ea,(%esp)
  8013cd:	e8 63 ed ff ff       	call   800135 <cprintf>
  8013d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8013d7:	eb 22                	jmp    8013fb <read+0x88>
	}
	if (!dev->dev_read)
  8013d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013dc:	8b 48 08             	mov    0x8(%eax),%ecx
  8013df:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013e4:	85 c9                	test   %ecx,%ecx
  8013e6:	74 13                	je     8013fb <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8013eb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f6:	89 14 24             	mov    %edx,(%esp)
  8013f9:	ff d1                	call   *%ecx
}
  8013fb:	83 c4 24             	add    $0x24,%esp
  8013fe:	5b                   	pop    %ebx
  8013ff:	5d                   	pop    %ebp
  801400:	c3                   	ret    

00801401 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801401:	55                   	push   %ebp
  801402:	89 e5                	mov    %esp,%ebp
  801404:	57                   	push   %edi
  801405:	56                   	push   %esi
  801406:	53                   	push   %ebx
  801407:	83 ec 1c             	sub    $0x1c,%esp
  80140a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80140d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801410:	ba 00 00 00 00       	mov    $0x0,%edx
  801415:	bb 00 00 00 00       	mov    $0x0,%ebx
  80141a:	b8 00 00 00 00       	mov    $0x0,%eax
  80141f:	85 f6                	test   %esi,%esi
  801421:	74 29                	je     80144c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801423:	89 f0                	mov    %esi,%eax
  801425:	29 d0                	sub    %edx,%eax
  801427:	89 44 24 08          	mov    %eax,0x8(%esp)
  80142b:	03 55 0c             	add    0xc(%ebp),%edx
  80142e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801432:	89 3c 24             	mov    %edi,(%esp)
  801435:	e8 39 ff ff ff       	call   801373 <read>
		if (m < 0)
  80143a:	85 c0                	test   %eax,%eax
  80143c:	78 0e                	js     80144c <readn+0x4b>
			return m;
		if (m == 0)
  80143e:	85 c0                	test   %eax,%eax
  801440:	74 08                	je     80144a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801442:	01 c3                	add    %eax,%ebx
  801444:	89 da                	mov    %ebx,%edx
  801446:	39 f3                	cmp    %esi,%ebx
  801448:	72 d9                	jb     801423 <readn+0x22>
  80144a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80144c:	83 c4 1c             	add    $0x1c,%esp
  80144f:	5b                   	pop    %ebx
  801450:	5e                   	pop    %esi
  801451:	5f                   	pop    %edi
  801452:	5d                   	pop    %ebp
  801453:	c3                   	ret    

00801454 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801454:	55                   	push   %ebp
  801455:	89 e5                	mov    %esp,%ebp
  801457:	83 ec 28             	sub    $0x28,%esp
  80145a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80145d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801460:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801463:	89 34 24             	mov    %esi,(%esp)
  801466:	e8 05 fc ff ff       	call   801070 <fd2num>
  80146b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80146e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801472:	89 04 24             	mov    %eax,(%esp)
  801475:	e8 93 fc ff ff       	call   80110d <fd_lookup>
  80147a:	89 c3                	mov    %eax,%ebx
  80147c:	85 c0                	test   %eax,%eax
  80147e:	78 05                	js     801485 <fd_close+0x31>
  801480:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801483:	74 0e                	je     801493 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801485:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801489:	b8 00 00 00 00       	mov    $0x0,%eax
  80148e:	0f 44 d8             	cmove  %eax,%ebx
  801491:	eb 3d                	jmp    8014d0 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801493:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801496:	89 44 24 04          	mov    %eax,0x4(%esp)
  80149a:	8b 06                	mov    (%esi),%eax
  80149c:	89 04 24             	mov    %eax,(%esp)
  80149f:	e8 dd fc ff ff       	call   801181 <dev_lookup>
  8014a4:	89 c3                	mov    %eax,%ebx
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	78 16                	js     8014c0 <fd_close+0x6c>
		if (dev->dev_close)
  8014aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014ad:	8b 40 10             	mov    0x10(%eax),%eax
  8014b0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014b5:	85 c0                	test   %eax,%eax
  8014b7:	74 07                	je     8014c0 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  8014b9:	89 34 24             	mov    %esi,(%esp)
  8014bc:	ff d0                	call   *%eax
  8014be:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014c4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014cb:	e8 9c f9 ff ff       	call   800e6c <sys_page_unmap>
	return r;
}
  8014d0:	89 d8                	mov    %ebx,%eax
  8014d2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014d5:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8014d8:	89 ec                	mov    %ebp,%esp
  8014da:	5d                   	pop    %ebp
  8014db:	c3                   	ret    

008014dc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ec:	89 04 24             	mov    %eax,(%esp)
  8014ef:	e8 19 fc ff ff       	call   80110d <fd_lookup>
  8014f4:	85 c0                	test   %eax,%eax
  8014f6:	78 13                	js     80150b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8014f8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8014ff:	00 
  801500:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801503:	89 04 24             	mov    %eax,(%esp)
  801506:	e8 49 ff ff ff       	call   801454 <fd_close>
}
  80150b:	c9                   	leave  
  80150c:	c3                   	ret    

0080150d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80150d:	55                   	push   %ebp
  80150e:	89 e5                	mov    %esp,%ebp
  801510:	83 ec 18             	sub    $0x18,%esp
  801513:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801516:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801519:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801520:	00 
  801521:	8b 45 08             	mov    0x8(%ebp),%eax
  801524:	89 04 24             	mov    %eax,(%esp)
  801527:	e8 78 03 00 00       	call   8018a4 <open>
  80152c:	89 c3                	mov    %eax,%ebx
  80152e:	85 c0                	test   %eax,%eax
  801530:	78 1b                	js     80154d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801532:	8b 45 0c             	mov    0xc(%ebp),%eax
  801535:	89 44 24 04          	mov    %eax,0x4(%esp)
  801539:	89 1c 24             	mov    %ebx,(%esp)
  80153c:	e8 ae fc ff ff       	call   8011ef <fstat>
  801541:	89 c6                	mov    %eax,%esi
	close(fd);
  801543:	89 1c 24             	mov    %ebx,(%esp)
  801546:	e8 91 ff ff ff       	call   8014dc <close>
  80154b:	89 f3                	mov    %esi,%ebx
	return r;
}
  80154d:	89 d8                	mov    %ebx,%eax
  80154f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801552:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801555:	89 ec                	mov    %ebp,%esp
  801557:	5d                   	pop    %ebp
  801558:	c3                   	ret    

00801559 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801559:	55                   	push   %ebp
  80155a:	89 e5                	mov    %esp,%ebp
  80155c:	53                   	push   %ebx
  80155d:	83 ec 14             	sub    $0x14,%esp
  801560:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801565:	89 1c 24             	mov    %ebx,(%esp)
  801568:	e8 6f ff ff ff       	call   8014dc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80156d:	83 c3 01             	add    $0x1,%ebx
  801570:	83 fb 20             	cmp    $0x20,%ebx
  801573:	75 f0                	jne    801565 <close_all+0xc>
		close(i);
}
  801575:	83 c4 14             	add    $0x14,%esp
  801578:	5b                   	pop    %ebx
  801579:	5d                   	pop    %ebp
  80157a:	c3                   	ret    

0080157b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80157b:	55                   	push   %ebp
  80157c:	89 e5                	mov    %esp,%ebp
  80157e:	83 ec 58             	sub    $0x58,%esp
  801581:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801584:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801587:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80158a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80158d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801590:	89 44 24 04          	mov    %eax,0x4(%esp)
  801594:	8b 45 08             	mov    0x8(%ebp),%eax
  801597:	89 04 24             	mov    %eax,(%esp)
  80159a:	e8 6e fb ff ff       	call   80110d <fd_lookup>
  80159f:	89 c3                	mov    %eax,%ebx
  8015a1:	85 c0                	test   %eax,%eax
  8015a3:	0f 88 e0 00 00 00    	js     801689 <dup+0x10e>
		return r;
	close(newfdnum);
  8015a9:	89 3c 24             	mov    %edi,(%esp)
  8015ac:	e8 2b ff ff ff       	call   8014dc <close>

	newfd = INDEX2FD(newfdnum);
  8015b1:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  8015b7:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  8015ba:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015bd:	89 04 24             	mov    %eax,(%esp)
  8015c0:	e8 bb fa ff ff       	call   801080 <fd2data>
  8015c5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015c7:	89 34 24             	mov    %esi,(%esp)
  8015ca:	e8 b1 fa ff ff       	call   801080 <fd2data>
  8015cf:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  8015d2:	89 da                	mov    %ebx,%edx
  8015d4:	89 d8                	mov    %ebx,%eax
  8015d6:	c1 e8 16             	shr    $0x16,%eax
  8015d9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015e0:	a8 01                	test   $0x1,%al
  8015e2:	74 43                	je     801627 <dup+0xac>
  8015e4:	c1 ea 0c             	shr    $0xc,%edx
  8015e7:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8015ee:	a8 01                	test   $0x1,%al
  8015f0:	74 35                	je     801627 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015f2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8015f9:	25 07 0e 00 00       	and    $0xe07,%eax
  8015fe:	89 44 24 10          	mov    %eax,0x10(%esp)
  801602:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801605:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801609:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801610:	00 
  801611:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801615:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80161c:	e8 83 f8 ff ff       	call   800ea4 <sys_page_map>
  801621:	89 c3                	mov    %eax,%ebx
  801623:	85 c0                	test   %eax,%eax
  801625:	78 3f                	js     801666 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801627:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80162a:	89 c2                	mov    %eax,%edx
  80162c:	c1 ea 0c             	shr    $0xc,%edx
  80162f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801636:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80163c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801640:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801644:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80164b:	00 
  80164c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801650:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801657:	e8 48 f8 ff ff       	call   800ea4 <sys_page_map>
  80165c:	89 c3                	mov    %eax,%ebx
  80165e:	85 c0                	test   %eax,%eax
  801660:	78 04                	js     801666 <dup+0xeb>
  801662:	89 fb                	mov    %edi,%ebx
  801664:	eb 23                	jmp    801689 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801666:	89 74 24 04          	mov    %esi,0x4(%esp)
  80166a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801671:	e8 f6 f7 ff ff       	call   800e6c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801676:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801679:	89 44 24 04          	mov    %eax,0x4(%esp)
  80167d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801684:	e8 e3 f7 ff ff       	call   800e6c <sys_page_unmap>
	return r;
}
  801689:	89 d8                	mov    %ebx,%eax
  80168b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80168e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801691:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801694:	89 ec                	mov    %ebp,%esp
  801696:	5d                   	pop    %ebp
  801697:	c3                   	ret    

00801698 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801698:	55                   	push   %ebp
  801699:	89 e5                	mov    %esp,%ebp
  80169b:	83 ec 18             	sub    $0x18,%esp
  80169e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8016a1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8016a4:	89 c3                	mov    %eax,%ebx
  8016a6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8016a8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016af:	75 11                	jne    8016c2 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8016b1:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  8016b8:	e8 03 08 00 00       	call   801ec0 <ipc_find_env>
  8016bd:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016c2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8016c9:	00 
  8016ca:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8016d1:	00 
  8016d2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016d6:	a1 00 40 80 00       	mov    0x804000,%eax
  8016db:	89 04 24             	mov    %eax,(%esp)
  8016de:	e8 26 08 00 00       	call   801f09 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016e3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016ea:	00 
  8016eb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016f6:	e8 79 08 00 00       	call   801f74 <ipc_recv>
}
  8016fb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8016fe:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801701:	89 ec                	mov    %ebp,%esp
  801703:	5d                   	pop    %ebp
  801704:	c3                   	ret    

00801705 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801705:	55                   	push   %ebp
  801706:	89 e5                	mov    %esp,%ebp
  801708:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80170b:	8b 45 08             	mov    0x8(%ebp),%eax
  80170e:	8b 40 0c             	mov    0xc(%eax),%eax
  801711:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801716:	8b 45 0c             	mov    0xc(%ebp),%eax
  801719:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80171e:	ba 00 00 00 00       	mov    $0x0,%edx
  801723:	b8 02 00 00 00       	mov    $0x2,%eax
  801728:	e8 6b ff ff ff       	call   801698 <fsipc>
}
  80172d:	c9                   	leave  
  80172e:	c3                   	ret    

0080172f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80172f:	55                   	push   %ebp
  801730:	89 e5                	mov    %esp,%ebp
  801732:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801735:	8b 45 08             	mov    0x8(%ebp),%eax
  801738:	8b 40 0c             	mov    0xc(%eax),%eax
  80173b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801740:	ba 00 00 00 00       	mov    $0x0,%edx
  801745:	b8 06 00 00 00       	mov    $0x6,%eax
  80174a:	e8 49 ff ff ff       	call   801698 <fsipc>
}
  80174f:	c9                   	leave  
  801750:	c3                   	ret    

00801751 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801751:	55                   	push   %ebp
  801752:	89 e5                	mov    %esp,%ebp
  801754:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801757:	ba 00 00 00 00       	mov    $0x0,%edx
  80175c:	b8 08 00 00 00       	mov    $0x8,%eax
  801761:	e8 32 ff ff ff       	call   801698 <fsipc>
}
  801766:	c9                   	leave  
  801767:	c3                   	ret    

00801768 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801768:	55                   	push   %ebp
  801769:	89 e5                	mov    %esp,%ebp
  80176b:	53                   	push   %ebx
  80176c:	83 ec 14             	sub    $0x14,%esp
  80176f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801772:	8b 45 08             	mov    0x8(%ebp),%eax
  801775:	8b 40 0c             	mov    0xc(%eax),%eax
  801778:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80177d:	ba 00 00 00 00       	mov    $0x0,%edx
  801782:	b8 05 00 00 00       	mov    $0x5,%eax
  801787:	e8 0c ff ff ff       	call   801698 <fsipc>
  80178c:	85 c0                	test   %eax,%eax
  80178e:	78 2b                	js     8017bb <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801790:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801797:	00 
  801798:	89 1c 24             	mov    %ebx,(%esp)
  80179b:	e8 da f0 ff ff       	call   80087a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017a0:	a1 80 50 80 00       	mov    0x805080,%eax
  8017a5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017ab:	a1 84 50 80 00       	mov    0x805084,%eax
  8017b0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  8017b6:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8017bb:	83 c4 14             	add    $0x14,%esp
  8017be:	5b                   	pop    %ebx
  8017bf:	5d                   	pop    %ebp
  8017c0:	c3                   	ret    

008017c1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017c1:	55                   	push   %ebp
  8017c2:	89 e5                	mov    %esp,%ebp
  8017c4:	83 ec 18             	sub    $0x18,%esp
  8017c7:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8017cd:	8b 52 0c             	mov    0xc(%edx),%edx
  8017d0:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  8017d6:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  8017db:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017e0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017e5:	0f 47 c2             	cmova  %edx,%eax
  8017e8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f3:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8017fa:	e8 66 f2 ff ff       	call   800a65 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  8017ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801804:	b8 04 00 00 00       	mov    $0x4,%eax
  801809:	e8 8a fe ff ff       	call   801698 <fsipc>
}
  80180e:	c9                   	leave  
  80180f:	c3                   	ret    

00801810 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	53                   	push   %ebx
  801814:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801817:	8b 45 08             	mov    0x8(%ebp),%eax
  80181a:	8b 40 0c             	mov    0xc(%eax),%eax
  80181d:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  801822:	8b 45 10             	mov    0x10(%ebp),%eax
  801825:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  80182a:	ba 00 00 00 00       	mov    $0x0,%edx
  80182f:	b8 03 00 00 00       	mov    $0x3,%eax
  801834:	e8 5f fe ff ff       	call   801698 <fsipc>
  801839:	89 c3                	mov    %eax,%ebx
  80183b:	85 c0                	test   %eax,%eax
  80183d:	78 17                	js     801856 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80183f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801843:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80184a:	00 
  80184b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80184e:	89 04 24             	mov    %eax,(%esp)
  801851:	e8 0f f2 ff ff       	call   800a65 <memmove>
  return r;	
}
  801856:	89 d8                	mov    %ebx,%eax
  801858:	83 c4 14             	add    $0x14,%esp
  80185b:	5b                   	pop    %ebx
  80185c:	5d                   	pop    %ebp
  80185d:	c3                   	ret    

0080185e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	53                   	push   %ebx
  801862:	83 ec 14             	sub    $0x14,%esp
  801865:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801868:	89 1c 24             	mov    %ebx,(%esp)
  80186b:	e8 c0 ef ff ff       	call   800830 <strlen>
  801870:	89 c2                	mov    %eax,%edx
  801872:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801877:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  80187d:	7f 1f                	jg     80189e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  80187f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801883:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80188a:	e8 eb ef ff ff       	call   80087a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  80188f:	ba 00 00 00 00       	mov    $0x0,%edx
  801894:	b8 07 00 00 00       	mov    $0x7,%eax
  801899:	e8 fa fd ff ff       	call   801698 <fsipc>
}
  80189e:	83 c4 14             	add    $0x14,%esp
  8018a1:	5b                   	pop    %ebx
  8018a2:	5d                   	pop    %ebp
  8018a3:	c3                   	ret    

008018a4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018a4:	55                   	push   %ebp
  8018a5:	89 e5                	mov    %esp,%ebp
  8018a7:	83 ec 28             	sub    $0x28,%esp
  8018aa:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8018ad:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8018b0:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  8018b3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b6:	89 04 24             	mov    %eax,(%esp)
  8018b9:	e8 dd f7 ff ff       	call   80109b <fd_alloc>
  8018be:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  8018c0:	85 c0                	test   %eax,%eax
  8018c2:	0f 88 89 00 00 00    	js     801951 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  8018c8:	89 34 24             	mov    %esi,(%esp)
  8018cb:	e8 60 ef ff ff       	call   800830 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  8018d0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  8018d5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018da:	7f 75                	jg     801951 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  8018dc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018e0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8018e7:	e8 8e ef ff ff       	call   80087a <strcpy>
  fsipcbuf.open.req_omode = mode;
  8018ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018ef:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  8018f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018f7:	b8 01 00 00 00       	mov    $0x1,%eax
  8018fc:	e8 97 fd ff ff       	call   801698 <fsipc>
  801901:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801903:	85 c0                	test   %eax,%eax
  801905:	78 0f                	js     801916 <open+0x72>
  return fd2num(fd);
  801907:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80190a:	89 04 24             	mov    %eax,(%esp)
  80190d:	e8 5e f7 ff ff       	call   801070 <fd2num>
  801912:	89 c3                	mov    %eax,%ebx
  801914:	eb 3b                	jmp    801951 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801916:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80191d:	00 
  80191e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801921:	89 04 24             	mov    %eax,(%esp)
  801924:	e8 2b fb ff ff       	call   801454 <fd_close>
  801929:	85 c0                	test   %eax,%eax
  80192b:	74 24                	je     801951 <open+0xad>
  80192d:	c7 44 24 0c 14 27 80 	movl   $0x802714,0xc(%esp)
  801934:	00 
  801935:	c7 44 24 08 29 27 80 	movl   $0x802729,0x8(%esp)
  80193c:	00 
  80193d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801944:	00 
  801945:	c7 04 24 3e 27 80 00 	movl   $0x80273e,(%esp)
  80194c:	e8 13 05 00 00       	call   801e64 <_panic>
  return r;
}
  801951:	89 d8                	mov    %ebx,%eax
  801953:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801956:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801959:	89 ec                	mov    %ebp,%esp
  80195b:	5d                   	pop    %ebp
  80195c:	c3                   	ret    
  80195d:	00 00                	add    %al,(%eax)
	...

00801960 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801960:	55                   	push   %ebp
  801961:	89 e5                	mov    %esp,%ebp
  801963:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801966:	c7 44 24 04 49 27 80 	movl   $0x802749,0x4(%esp)
  80196d:	00 
  80196e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801971:	89 04 24             	mov    %eax,(%esp)
  801974:	e8 01 ef ff ff       	call   80087a <strcpy>
	return 0;
}
  801979:	b8 00 00 00 00       	mov    $0x0,%eax
  80197e:	c9                   	leave  
  80197f:	c3                   	ret    

00801980 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	53                   	push   %ebx
  801984:	83 ec 14             	sub    $0x14,%esp
  801987:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80198a:	89 1c 24             	mov    %ebx,(%esp)
  80198d:	e8 72 06 00 00       	call   802004 <pageref>
  801992:	89 c2                	mov    %eax,%edx
  801994:	b8 00 00 00 00       	mov    $0x0,%eax
  801999:	83 fa 01             	cmp    $0x1,%edx
  80199c:	75 0b                	jne    8019a9 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80199e:	8b 43 0c             	mov    0xc(%ebx),%eax
  8019a1:	89 04 24             	mov    %eax,(%esp)
  8019a4:	e8 b9 02 00 00       	call   801c62 <nsipc_close>
	else
		return 0;
}
  8019a9:	83 c4 14             	add    $0x14,%esp
  8019ac:	5b                   	pop    %ebx
  8019ad:	5d                   	pop    %ebp
  8019ae:	c3                   	ret    

008019af <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8019af:	55                   	push   %ebp
  8019b0:	89 e5                	mov    %esp,%ebp
  8019b2:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019b5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8019bc:	00 
  8019bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8019c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8019d1:	89 04 24             	mov    %eax,(%esp)
  8019d4:	e8 c5 02 00 00       	call   801c9e <nsipc_send>
}
  8019d9:	c9                   	leave  
  8019da:	c3                   	ret    

008019db <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019e1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8019e8:	00 
  8019e9:	8b 45 10             	mov    0x10(%ebp),%eax
  8019ec:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8019fd:	89 04 24             	mov    %eax,(%esp)
  801a00:	e8 0c 03 00 00       	call   801d11 <nsipc_recv>
}
  801a05:	c9                   	leave  
  801a06:	c3                   	ret    

00801a07 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801a07:	55                   	push   %ebp
  801a08:	89 e5                	mov    %esp,%ebp
  801a0a:	56                   	push   %esi
  801a0b:	53                   	push   %ebx
  801a0c:	83 ec 20             	sub    $0x20,%esp
  801a0f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a11:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a14:	89 04 24             	mov    %eax,(%esp)
  801a17:	e8 7f f6 ff ff       	call   80109b <fd_alloc>
  801a1c:	89 c3                	mov    %eax,%ebx
  801a1e:	85 c0                	test   %eax,%eax
  801a20:	78 21                	js     801a43 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a22:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a29:	00 
  801a2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a31:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a38:	e8 a0 f4 ff ff       	call   800edd <sys_page_alloc>
  801a3d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a3f:	85 c0                	test   %eax,%eax
  801a41:	79 0a                	jns    801a4d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  801a43:	89 34 24             	mov    %esi,(%esp)
  801a46:	e8 17 02 00 00       	call   801c62 <nsipc_close>
		return r;
  801a4b:	eb 28                	jmp    801a75 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a4d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a56:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a5b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a62:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a65:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a68:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a6b:	89 04 24             	mov    %eax,(%esp)
  801a6e:	e8 fd f5 ff ff       	call   801070 <fd2num>
  801a73:	89 c3                	mov    %eax,%ebx
}
  801a75:	89 d8                	mov    %ebx,%eax
  801a77:	83 c4 20             	add    $0x20,%esp
  801a7a:	5b                   	pop    %ebx
  801a7b:	5e                   	pop    %esi
  801a7c:	5d                   	pop    %ebp
  801a7d:	c3                   	ret    

00801a7e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a84:	8b 45 10             	mov    0x10(%ebp),%eax
  801a87:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a8e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a92:	8b 45 08             	mov    0x8(%ebp),%eax
  801a95:	89 04 24             	mov    %eax,(%esp)
  801a98:	e8 79 01 00 00       	call   801c16 <nsipc_socket>
  801a9d:	85 c0                	test   %eax,%eax
  801a9f:	78 05                	js     801aa6 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801aa1:	e8 61 ff ff ff       	call   801a07 <alloc_sockfd>
}
  801aa6:	c9                   	leave  
  801aa7:	c3                   	ret    

00801aa8 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801aa8:	55                   	push   %ebp
  801aa9:	89 e5                	mov    %esp,%ebp
  801aab:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801aae:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ab1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ab5:	89 04 24             	mov    %eax,(%esp)
  801ab8:	e8 50 f6 ff ff       	call   80110d <fd_lookup>
  801abd:	85 c0                	test   %eax,%eax
  801abf:	78 15                	js     801ad6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801ac1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ac4:	8b 0a                	mov    (%edx),%ecx
  801ac6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801acb:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  801ad1:	75 03                	jne    801ad6 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801ad3:	8b 42 0c             	mov    0xc(%edx),%eax
}
  801ad6:	c9                   	leave  
  801ad7:	c3                   	ret    

00801ad8 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  801ad8:	55                   	push   %ebp
  801ad9:	89 e5                	mov    %esp,%ebp
  801adb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ade:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae1:	e8 c2 ff ff ff       	call   801aa8 <fd2sockid>
  801ae6:	85 c0                	test   %eax,%eax
  801ae8:	78 0f                	js     801af9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801aea:	8b 55 0c             	mov    0xc(%ebp),%edx
  801aed:	89 54 24 04          	mov    %edx,0x4(%esp)
  801af1:	89 04 24             	mov    %eax,(%esp)
  801af4:	e8 47 01 00 00       	call   801c40 <nsipc_listen>
}
  801af9:	c9                   	leave  
  801afa:	c3                   	ret    

00801afb <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801afb:	55                   	push   %ebp
  801afc:	89 e5                	mov    %esp,%ebp
  801afe:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b01:	8b 45 08             	mov    0x8(%ebp),%eax
  801b04:	e8 9f ff ff ff       	call   801aa8 <fd2sockid>
  801b09:	85 c0                	test   %eax,%eax
  801b0b:	78 16                	js     801b23 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801b0d:	8b 55 10             	mov    0x10(%ebp),%edx
  801b10:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b14:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b17:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b1b:	89 04 24             	mov    %eax,(%esp)
  801b1e:	e8 6e 02 00 00       	call   801d91 <nsipc_connect>
}
  801b23:	c9                   	leave  
  801b24:	c3                   	ret    

00801b25 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801b25:	55                   	push   %ebp
  801b26:	89 e5                	mov    %esp,%ebp
  801b28:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b2b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b2e:	e8 75 ff ff ff       	call   801aa8 <fd2sockid>
  801b33:	85 c0                	test   %eax,%eax
  801b35:	78 0f                	js     801b46 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b37:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b3a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b3e:	89 04 24             	mov    %eax,(%esp)
  801b41:	e8 36 01 00 00       	call   801c7c <nsipc_shutdown>
}
  801b46:	c9                   	leave  
  801b47:	c3                   	ret    

00801b48 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b48:	55                   	push   %ebp
  801b49:	89 e5                	mov    %esp,%ebp
  801b4b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b51:	e8 52 ff ff ff       	call   801aa8 <fd2sockid>
  801b56:	85 c0                	test   %eax,%eax
  801b58:	78 16                	js     801b70 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801b5a:	8b 55 10             	mov    0x10(%ebp),%edx
  801b5d:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b61:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b64:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b68:	89 04 24             	mov    %eax,(%esp)
  801b6b:	e8 60 02 00 00       	call   801dd0 <nsipc_bind>
}
  801b70:	c9                   	leave  
  801b71:	c3                   	ret    

00801b72 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b72:	55                   	push   %ebp
  801b73:	89 e5                	mov    %esp,%ebp
  801b75:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b78:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7b:	e8 28 ff ff ff       	call   801aa8 <fd2sockid>
  801b80:	85 c0                	test   %eax,%eax
  801b82:	78 1f                	js     801ba3 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b84:	8b 55 10             	mov    0x10(%ebp),%edx
  801b87:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b8b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b8e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b92:	89 04 24             	mov    %eax,(%esp)
  801b95:	e8 75 02 00 00       	call   801e0f <nsipc_accept>
  801b9a:	85 c0                	test   %eax,%eax
  801b9c:	78 05                	js     801ba3 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801b9e:	e8 64 fe ff ff       	call   801a07 <alloc_sockfd>
}
  801ba3:	c9                   	leave  
  801ba4:	c3                   	ret    
	...

00801bb0 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	53                   	push   %ebx
  801bb4:	83 ec 14             	sub    $0x14,%esp
  801bb7:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801bb9:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801bc0:	75 11                	jne    801bd3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801bc2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  801bc9:	e8 f2 02 00 00       	call   801ec0 <ipc_find_env>
  801bce:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bd3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801bda:	00 
  801bdb:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801be2:	00 
  801be3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801be7:	a1 04 40 80 00       	mov    0x804004,%eax
  801bec:	89 04 24             	mov    %eax,(%esp)
  801bef:	e8 15 03 00 00       	call   801f09 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801bf4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bfb:	00 
  801bfc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801c03:	00 
  801c04:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c0b:	e8 64 03 00 00       	call   801f74 <ipc_recv>
}
  801c10:	83 c4 14             	add    $0x14,%esp
  801c13:	5b                   	pop    %ebx
  801c14:	5d                   	pop    %ebp
  801c15:	c3                   	ret    

00801c16 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801c16:	55                   	push   %ebp
  801c17:	89 e5                	mov    %esp,%ebp
  801c19:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801c1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801c1f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801c24:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c27:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801c2c:	8b 45 10             	mov    0x10(%ebp),%eax
  801c2f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801c34:	b8 09 00 00 00       	mov    $0x9,%eax
  801c39:	e8 72 ff ff ff       	call   801bb0 <nsipc>
}
  801c3e:	c9                   	leave  
  801c3f:	c3                   	ret    

00801c40 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c46:	8b 45 08             	mov    0x8(%ebp),%eax
  801c49:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801c4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c51:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801c56:	b8 06 00 00 00       	mov    $0x6,%eax
  801c5b:	e8 50 ff ff ff       	call   801bb0 <nsipc>
}
  801c60:	c9                   	leave  
  801c61:	c3                   	ret    

00801c62 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  801c62:	55                   	push   %ebp
  801c63:	89 e5                	mov    %esp,%ebp
  801c65:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c68:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c70:	b8 04 00 00 00       	mov    $0x4,%eax
  801c75:	e8 36 ff ff ff       	call   801bb0 <nsipc>
}
  801c7a:	c9                   	leave  
  801c7b:	c3                   	ret    

00801c7c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  801c7c:	55                   	push   %ebp
  801c7d:	89 e5                	mov    %esp,%ebp
  801c7f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c82:	8b 45 08             	mov    0x8(%ebp),%eax
  801c85:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c8d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c92:	b8 03 00 00 00       	mov    $0x3,%eax
  801c97:	e8 14 ff ff ff       	call   801bb0 <nsipc>
}
  801c9c:	c9                   	leave  
  801c9d:	c3                   	ret    

00801c9e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c9e:	55                   	push   %ebp
  801c9f:	89 e5                	mov    %esp,%ebp
  801ca1:	53                   	push   %ebx
  801ca2:	83 ec 14             	sub    $0x14,%esp
  801ca5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801ca8:	8b 45 08             	mov    0x8(%ebp),%eax
  801cab:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801cb0:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801cb6:	7e 24                	jle    801cdc <nsipc_send+0x3e>
  801cb8:	c7 44 24 0c 55 27 80 	movl   $0x802755,0xc(%esp)
  801cbf:	00 
  801cc0:	c7 44 24 08 29 27 80 	movl   $0x802729,0x8(%esp)
  801cc7:	00 
  801cc8:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  801ccf:	00 
  801cd0:	c7 04 24 61 27 80 00 	movl   $0x802761,(%esp)
  801cd7:	e8 88 01 00 00       	call   801e64 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801cdc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ce0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ce3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ce7:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801cee:	e8 72 ed ff ff       	call   800a65 <memmove>
	nsipcbuf.send.req_size = size;
  801cf3:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801cf9:	8b 45 14             	mov    0x14(%ebp),%eax
  801cfc:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801d01:	b8 08 00 00 00       	mov    $0x8,%eax
  801d06:	e8 a5 fe ff ff       	call   801bb0 <nsipc>
}
  801d0b:	83 c4 14             	add    $0x14,%esp
  801d0e:	5b                   	pop    %ebx
  801d0f:	5d                   	pop    %ebp
  801d10:	c3                   	ret    

00801d11 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801d11:	55                   	push   %ebp
  801d12:	89 e5                	mov    %esp,%ebp
  801d14:	56                   	push   %esi
  801d15:	53                   	push   %ebx
  801d16:	83 ec 10             	sub    $0x10,%esp
  801d19:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d1c:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d24:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d2a:	8b 45 14             	mov    0x14(%ebp),%eax
  801d2d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d32:	b8 07 00 00 00       	mov    $0x7,%eax
  801d37:	e8 74 fe ff ff       	call   801bb0 <nsipc>
  801d3c:	89 c3                	mov    %eax,%ebx
  801d3e:	85 c0                	test   %eax,%eax
  801d40:	78 46                	js     801d88 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801d42:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d47:	7f 04                	jg     801d4d <nsipc_recv+0x3c>
  801d49:	39 c6                	cmp    %eax,%esi
  801d4b:	7d 24                	jge    801d71 <nsipc_recv+0x60>
  801d4d:	c7 44 24 0c 6d 27 80 	movl   $0x80276d,0xc(%esp)
  801d54:	00 
  801d55:	c7 44 24 08 29 27 80 	movl   $0x802729,0x8(%esp)
  801d5c:	00 
  801d5d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801d64:	00 
  801d65:	c7 04 24 61 27 80 00 	movl   $0x802761,(%esp)
  801d6c:	e8 f3 00 00 00       	call   801e64 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d71:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d75:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801d7c:	00 
  801d7d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d80:	89 04 24             	mov    %eax,(%esp)
  801d83:	e8 dd ec ff ff       	call   800a65 <memmove>
	}

	return r;
}
  801d88:	89 d8                	mov    %ebx,%eax
  801d8a:	83 c4 10             	add    $0x10,%esp
  801d8d:	5b                   	pop    %ebx
  801d8e:	5e                   	pop    %esi
  801d8f:	5d                   	pop    %ebp
  801d90:	c3                   	ret    

00801d91 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d91:	55                   	push   %ebp
  801d92:	89 e5                	mov    %esp,%ebp
  801d94:	53                   	push   %ebx
  801d95:	83 ec 14             	sub    $0x14,%esp
  801d98:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d9e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801da3:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801da7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801daa:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dae:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801db5:	e8 ab ec ff ff       	call   800a65 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801dba:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801dc0:	b8 05 00 00 00       	mov    $0x5,%eax
  801dc5:	e8 e6 fd ff ff       	call   801bb0 <nsipc>
}
  801dca:	83 c4 14             	add    $0x14,%esp
  801dcd:	5b                   	pop    %ebx
  801dce:	5d                   	pop    %ebp
  801dcf:	c3                   	ret    

00801dd0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801dd0:	55                   	push   %ebp
  801dd1:	89 e5                	mov    %esp,%ebp
  801dd3:	53                   	push   %ebx
  801dd4:	83 ec 14             	sub    $0x14,%esp
  801dd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801dda:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddd:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801de2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801de6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801de9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ded:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801df4:	e8 6c ec ff ff       	call   800a65 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801df9:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801dff:	b8 02 00 00 00       	mov    $0x2,%eax
  801e04:	e8 a7 fd ff ff       	call   801bb0 <nsipc>
}
  801e09:	83 c4 14             	add    $0x14,%esp
  801e0c:	5b                   	pop    %ebx
  801e0d:	5d                   	pop    %ebp
  801e0e:	c3                   	ret    

00801e0f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e0f:	55                   	push   %ebp
  801e10:	89 e5                	mov    %esp,%ebp
  801e12:	83 ec 18             	sub    $0x18,%esp
  801e15:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801e18:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  801e1b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1e:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e23:	b8 01 00 00 00       	mov    $0x1,%eax
  801e28:	e8 83 fd ff ff       	call   801bb0 <nsipc>
  801e2d:	89 c3                	mov    %eax,%ebx
  801e2f:	85 c0                	test   %eax,%eax
  801e31:	78 25                	js     801e58 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801e33:	be 10 60 80 00       	mov    $0x806010,%esi
  801e38:	8b 06                	mov    (%esi),%eax
  801e3a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e3e:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e45:	00 
  801e46:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e49:	89 04 24             	mov    %eax,(%esp)
  801e4c:	e8 14 ec ff ff       	call   800a65 <memmove>
		*addrlen = ret->ret_addrlen;
  801e51:	8b 16                	mov    (%esi),%edx
  801e53:	8b 45 10             	mov    0x10(%ebp),%eax
  801e56:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  801e58:	89 d8                	mov    %ebx,%eax
  801e5a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801e5d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801e60:	89 ec                	mov    %ebp,%esp
  801e62:	5d                   	pop    %ebp
  801e63:	c3                   	ret    

00801e64 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e64:	55                   	push   %ebp
  801e65:	89 e5                	mov    %esp,%ebp
  801e67:	56                   	push   %esi
  801e68:	53                   	push   %ebx
  801e69:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801e6c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e6f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801e75:	e8 0d f1 ff ff       	call   800f87 <sys_getenvid>
  801e7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e7d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801e81:	8b 55 08             	mov    0x8(%ebp),%edx
  801e84:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801e88:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e90:	c7 04 24 84 27 80 00 	movl   $0x802784,(%esp)
  801e97:	e8 99 e2 ff ff       	call   800135 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e9c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ea0:	8b 45 10             	mov    0x10(%ebp),%eax
  801ea3:	89 04 24             	mov    %eax,(%esp)
  801ea6:	e8 29 e2 ff ff       	call   8000d4 <vcprintf>
	cprintf("\n");
  801eab:	c7 04 24 cc 22 80 00 	movl   $0x8022cc,(%esp)
  801eb2:	e8 7e e2 ff ff       	call   800135 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801eb7:	cc                   	int3   
  801eb8:	eb fd                	jmp    801eb7 <_panic+0x53>
  801eba:	00 00                	add    %al,(%eax)
  801ebc:	00 00                	add    %al,(%eax)
	...

00801ec0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ec0:	55                   	push   %ebp
  801ec1:	89 e5                	mov    %esp,%ebp
  801ec3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801ec6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801ecc:	b8 01 00 00 00       	mov    $0x1,%eax
  801ed1:	39 ca                	cmp    %ecx,%edx
  801ed3:	75 04                	jne    801ed9 <ipc_find_env+0x19>
  801ed5:	b0 00                	mov    $0x0,%al
  801ed7:	eb 11                	jmp    801eea <ipc_find_env+0x2a>
  801ed9:	89 c2                	mov    %eax,%edx
  801edb:	c1 e2 07             	shl    $0x7,%edx
  801ede:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801ee4:	8b 12                	mov    (%edx),%edx
  801ee6:	39 ca                	cmp    %ecx,%edx
  801ee8:	75 0f                	jne    801ef9 <ipc_find_env+0x39>
			return envs[i].env_id;
  801eea:	8d 44 00 01          	lea    0x1(%eax,%eax,1),%eax
  801eee:	c1 e0 06             	shl    $0x6,%eax
  801ef1:	8b 80 08 00 c0 ee    	mov    -0x113ffff8(%eax),%eax
  801ef7:	eb 0e                	jmp    801f07 <ipc_find_env+0x47>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ef9:	83 c0 01             	add    $0x1,%eax
  801efc:	3d 00 04 00 00       	cmp    $0x400,%eax
  801f01:	75 d6                	jne    801ed9 <ipc_find_env+0x19>
  801f03:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801f07:	5d                   	pop    %ebp
  801f08:	c3                   	ret    

00801f09 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f09:	55                   	push   %ebp
  801f0a:	89 e5                	mov    %esp,%ebp
  801f0c:	57                   	push   %edi
  801f0d:	56                   	push   %esi
  801f0e:	53                   	push   %ebx
  801f0f:	83 ec 1c             	sub    $0x1c,%esp
  801f12:	8b 75 08             	mov    0x8(%ebp),%esi
  801f15:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801f18:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801f1b:	85 db                	test   %ebx,%ebx
  801f1d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801f22:	0f 44 d8             	cmove  %eax,%ebx
  801f25:	eb 25                	jmp    801f4c <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  801f27:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f2a:	74 20                	je     801f4c <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  801f2c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f30:	c7 44 24 08 a8 27 80 	movl   $0x8027a8,0x8(%esp)
  801f37:	00 
  801f38:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801f3f:	00 
  801f40:	c7 04 24 c6 27 80 00 	movl   $0x8027c6,(%esp)
  801f47:	e8 18 ff ff ff       	call   801e64 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  801f4c:	8b 45 14             	mov    0x14(%ebp),%eax
  801f4f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f53:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f57:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f5b:	89 34 24             	mov    %esi,(%esp)
  801f5e:	e8 2b ee ff ff       	call   800d8e <sys_ipc_try_send>
  801f63:	85 c0                	test   %eax,%eax
  801f65:	75 c0                	jne    801f27 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  801f67:	e8 a8 ef ff ff       	call   800f14 <sys_yield>
}
  801f6c:	83 c4 1c             	add    $0x1c,%esp
  801f6f:	5b                   	pop    %ebx
  801f70:	5e                   	pop    %esi
  801f71:	5f                   	pop    %edi
  801f72:	5d                   	pop    %ebp
  801f73:	c3                   	ret    

00801f74 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f74:	55                   	push   %ebp
  801f75:	89 e5                	mov    %esp,%ebp
  801f77:	83 ec 28             	sub    $0x28,%esp
  801f7a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801f7d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801f80:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801f83:	8b 75 08             	mov    0x8(%ebp),%esi
  801f86:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f89:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801f8c:	85 c0                	test   %eax,%eax
  801f8e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f93:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801f96:	89 04 24             	mov    %eax,(%esp)
  801f99:	e8 b7 ed ff ff       	call   800d55 <sys_ipc_recv>
  801f9e:	89 c3                	mov    %eax,%ebx
  801fa0:	85 c0                	test   %eax,%eax
  801fa2:	79 2a                	jns    801fce <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  801fa4:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fa8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801fac:	c7 04 24 d0 27 80 00 	movl   $0x8027d0,(%esp)
  801fb3:	e8 7d e1 ff ff       	call   800135 <cprintf>
		if(from_env_store != NULL)
  801fb8:	85 f6                	test   %esi,%esi
  801fba:	74 06                	je     801fc2 <ipc_recv+0x4e>
			*from_env_store = 0;
  801fbc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801fc2:	85 ff                	test   %edi,%edi
  801fc4:	74 2c                	je     801ff2 <ipc_recv+0x7e>
			*perm_store = 0;
  801fc6:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801fcc:	eb 24                	jmp    801ff2 <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  801fce:	85 f6                	test   %esi,%esi
  801fd0:	74 0a                	je     801fdc <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  801fd2:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801fd7:	8b 40 74             	mov    0x74(%eax),%eax
  801fda:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801fdc:	85 ff                	test   %edi,%edi
  801fde:	74 0a                	je     801fea <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  801fe0:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801fe5:	8b 40 78             	mov    0x78(%eax),%eax
  801fe8:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801fea:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801fef:	8b 58 70             	mov    0x70(%eax),%ebx
}
  801ff2:	89 d8                	mov    %ebx,%eax
  801ff4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801ff7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801ffa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801ffd:	89 ec                	mov    %ebp,%esp
  801fff:	5d                   	pop    %ebp
  802000:	c3                   	ret    
  802001:	00 00                	add    %al,(%eax)
	...

00802004 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802004:	55                   	push   %ebp
  802005:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  802007:	8b 45 08             	mov    0x8(%ebp),%eax
  80200a:	89 c2                	mov    %eax,%edx
  80200c:	c1 ea 16             	shr    $0x16,%edx
  80200f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802016:	f6 c2 01             	test   $0x1,%dl
  802019:	74 20                	je     80203b <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  80201b:	c1 e8 0c             	shr    $0xc,%eax
  80201e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802025:	a8 01                	test   $0x1,%al
  802027:	74 12                	je     80203b <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802029:	c1 e8 0c             	shr    $0xc,%eax
  80202c:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802031:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  802036:	0f b7 c0             	movzwl %ax,%eax
  802039:	eb 05                	jmp    802040 <pageref+0x3c>
  80203b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802040:	5d                   	pop    %ebp
  802041:	c3                   	ret    
	...

00802050 <__udivdi3>:
  802050:	55                   	push   %ebp
  802051:	89 e5                	mov    %esp,%ebp
  802053:	57                   	push   %edi
  802054:	56                   	push   %esi
  802055:	83 ec 10             	sub    $0x10,%esp
  802058:	8b 45 14             	mov    0x14(%ebp),%eax
  80205b:	8b 55 08             	mov    0x8(%ebp),%edx
  80205e:	8b 75 10             	mov    0x10(%ebp),%esi
  802061:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802064:	85 c0                	test   %eax,%eax
  802066:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802069:	75 35                	jne    8020a0 <__udivdi3+0x50>
  80206b:	39 fe                	cmp    %edi,%esi
  80206d:	77 61                	ja     8020d0 <__udivdi3+0x80>
  80206f:	85 f6                	test   %esi,%esi
  802071:	75 0b                	jne    80207e <__udivdi3+0x2e>
  802073:	b8 01 00 00 00       	mov    $0x1,%eax
  802078:	31 d2                	xor    %edx,%edx
  80207a:	f7 f6                	div    %esi
  80207c:	89 c6                	mov    %eax,%esi
  80207e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802081:	31 d2                	xor    %edx,%edx
  802083:	89 f8                	mov    %edi,%eax
  802085:	f7 f6                	div    %esi
  802087:	89 c7                	mov    %eax,%edi
  802089:	89 c8                	mov    %ecx,%eax
  80208b:	f7 f6                	div    %esi
  80208d:	89 c1                	mov    %eax,%ecx
  80208f:	89 fa                	mov    %edi,%edx
  802091:	89 c8                	mov    %ecx,%eax
  802093:	83 c4 10             	add    $0x10,%esp
  802096:	5e                   	pop    %esi
  802097:	5f                   	pop    %edi
  802098:	5d                   	pop    %ebp
  802099:	c3                   	ret    
  80209a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020a0:	39 f8                	cmp    %edi,%eax
  8020a2:	77 1c                	ja     8020c0 <__udivdi3+0x70>
  8020a4:	0f bd d0             	bsr    %eax,%edx
  8020a7:	83 f2 1f             	xor    $0x1f,%edx
  8020aa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8020ad:	75 39                	jne    8020e8 <__udivdi3+0x98>
  8020af:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8020b2:	0f 86 a0 00 00 00    	jbe    802158 <__udivdi3+0x108>
  8020b8:	39 f8                	cmp    %edi,%eax
  8020ba:	0f 82 98 00 00 00    	jb     802158 <__udivdi3+0x108>
  8020c0:	31 ff                	xor    %edi,%edi
  8020c2:	31 c9                	xor    %ecx,%ecx
  8020c4:	89 c8                	mov    %ecx,%eax
  8020c6:	89 fa                	mov    %edi,%edx
  8020c8:	83 c4 10             	add    $0x10,%esp
  8020cb:	5e                   	pop    %esi
  8020cc:	5f                   	pop    %edi
  8020cd:	5d                   	pop    %ebp
  8020ce:	c3                   	ret    
  8020cf:	90                   	nop
  8020d0:	89 d1                	mov    %edx,%ecx
  8020d2:	89 fa                	mov    %edi,%edx
  8020d4:	89 c8                	mov    %ecx,%eax
  8020d6:	31 ff                	xor    %edi,%edi
  8020d8:	f7 f6                	div    %esi
  8020da:	89 c1                	mov    %eax,%ecx
  8020dc:	89 fa                	mov    %edi,%edx
  8020de:	89 c8                	mov    %ecx,%eax
  8020e0:	83 c4 10             	add    $0x10,%esp
  8020e3:	5e                   	pop    %esi
  8020e4:	5f                   	pop    %edi
  8020e5:	5d                   	pop    %ebp
  8020e6:	c3                   	ret    
  8020e7:	90                   	nop
  8020e8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8020ec:	89 f2                	mov    %esi,%edx
  8020ee:	d3 e0                	shl    %cl,%eax
  8020f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020f3:	b8 20 00 00 00       	mov    $0x20,%eax
  8020f8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8020fb:	89 c1                	mov    %eax,%ecx
  8020fd:	d3 ea                	shr    %cl,%edx
  8020ff:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802103:	0b 55 ec             	or     -0x14(%ebp),%edx
  802106:	d3 e6                	shl    %cl,%esi
  802108:	89 c1                	mov    %eax,%ecx
  80210a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80210d:	89 fe                	mov    %edi,%esi
  80210f:	d3 ee                	shr    %cl,%esi
  802111:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802115:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802118:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80211b:	d3 e7                	shl    %cl,%edi
  80211d:	89 c1                	mov    %eax,%ecx
  80211f:	d3 ea                	shr    %cl,%edx
  802121:	09 d7                	or     %edx,%edi
  802123:	89 f2                	mov    %esi,%edx
  802125:	89 f8                	mov    %edi,%eax
  802127:	f7 75 ec             	divl   -0x14(%ebp)
  80212a:	89 d6                	mov    %edx,%esi
  80212c:	89 c7                	mov    %eax,%edi
  80212e:	f7 65 e8             	mull   -0x18(%ebp)
  802131:	39 d6                	cmp    %edx,%esi
  802133:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802136:	72 30                	jb     802168 <__udivdi3+0x118>
  802138:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80213b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80213f:	d3 e2                	shl    %cl,%edx
  802141:	39 c2                	cmp    %eax,%edx
  802143:	73 05                	jae    80214a <__udivdi3+0xfa>
  802145:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802148:	74 1e                	je     802168 <__udivdi3+0x118>
  80214a:	89 f9                	mov    %edi,%ecx
  80214c:	31 ff                	xor    %edi,%edi
  80214e:	e9 71 ff ff ff       	jmp    8020c4 <__udivdi3+0x74>
  802153:	90                   	nop
  802154:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802158:	31 ff                	xor    %edi,%edi
  80215a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80215f:	e9 60 ff ff ff       	jmp    8020c4 <__udivdi3+0x74>
  802164:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802168:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80216b:	31 ff                	xor    %edi,%edi
  80216d:	89 c8                	mov    %ecx,%eax
  80216f:	89 fa                	mov    %edi,%edx
  802171:	83 c4 10             	add    $0x10,%esp
  802174:	5e                   	pop    %esi
  802175:	5f                   	pop    %edi
  802176:	5d                   	pop    %ebp
  802177:	c3                   	ret    
	...

00802180 <__umoddi3>:
  802180:	55                   	push   %ebp
  802181:	89 e5                	mov    %esp,%ebp
  802183:	57                   	push   %edi
  802184:	56                   	push   %esi
  802185:	83 ec 20             	sub    $0x20,%esp
  802188:	8b 55 14             	mov    0x14(%ebp),%edx
  80218b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80218e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802191:	8b 75 0c             	mov    0xc(%ebp),%esi
  802194:	85 d2                	test   %edx,%edx
  802196:	89 c8                	mov    %ecx,%eax
  802198:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80219b:	75 13                	jne    8021b0 <__umoddi3+0x30>
  80219d:	39 f7                	cmp    %esi,%edi
  80219f:	76 3f                	jbe    8021e0 <__umoddi3+0x60>
  8021a1:	89 f2                	mov    %esi,%edx
  8021a3:	f7 f7                	div    %edi
  8021a5:	89 d0                	mov    %edx,%eax
  8021a7:	31 d2                	xor    %edx,%edx
  8021a9:	83 c4 20             	add    $0x20,%esp
  8021ac:	5e                   	pop    %esi
  8021ad:	5f                   	pop    %edi
  8021ae:	5d                   	pop    %ebp
  8021af:	c3                   	ret    
  8021b0:	39 f2                	cmp    %esi,%edx
  8021b2:	77 4c                	ja     802200 <__umoddi3+0x80>
  8021b4:	0f bd ca             	bsr    %edx,%ecx
  8021b7:	83 f1 1f             	xor    $0x1f,%ecx
  8021ba:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8021bd:	75 51                	jne    802210 <__umoddi3+0x90>
  8021bf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8021c2:	0f 87 e0 00 00 00    	ja     8022a8 <__umoddi3+0x128>
  8021c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021cb:	29 f8                	sub    %edi,%eax
  8021cd:	19 d6                	sbb    %edx,%esi
  8021cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8021d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021d5:	89 f2                	mov    %esi,%edx
  8021d7:	83 c4 20             	add    $0x20,%esp
  8021da:	5e                   	pop    %esi
  8021db:	5f                   	pop    %edi
  8021dc:	5d                   	pop    %ebp
  8021dd:	c3                   	ret    
  8021de:	66 90                	xchg   %ax,%ax
  8021e0:	85 ff                	test   %edi,%edi
  8021e2:	75 0b                	jne    8021ef <__umoddi3+0x6f>
  8021e4:	b8 01 00 00 00       	mov    $0x1,%eax
  8021e9:	31 d2                	xor    %edx,%edx
  8021eb:	f7 f7                	div    %edi
  8021ed:	89 c7                	mov    %eax,%edi
  8021ef:	89 f0                	mov    %esi,%eax
  8021f1:	31 d2                	xor    %edx,%edx
  8021f3:	f7 f7                	div    %edi
  8021f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021f8:	f7 f7                	div    %edi
  8021fa:	eb a9                	jmp    8021a5 <__umoddi3+0x25>
  8021fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802200:	89 c8                	mov    %ecx,%eax
  802202:	89 f2                	mov    %esi,%edx
  802204:	83 c4 20             	add    $0x20,%esp
  802207:	5e                   	pop    %esi
  802208:	5f                   	pop    %edi
  802209:	5d                   	pop    %ebp
  80220a:	c3                   	ret    
  80220b:	90                   	nop
  80220c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802210:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802214:	d3 e2                	shl    %cl,%edx
  802216:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802219:	ba 20 00 00 00       	mov    $0x20,%edx
  80221e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802221:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802224:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802228:	89 fa                	mov    %edi,%edx
  80222a:	d3 ea                	shr    %cl,%edx
  80222c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802230:	0b 55 f4             	or     -0xc(%ebp),%edx
  802233:	d3 e7                	shl    %cl,%edi
  802235:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802239:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80223c:	89 f2                	mov    %esi,%edx
  80223e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802241:	89 c7                	mov    %eax,%edi
  802243:	d3 ea                	shr    %cl,%edx
  802245:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802249:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80224c:	89 c2                	mov    %eax,%edx
  80224e:	d3 e6                	shl    %cl,%esi
  802250:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802254:	d3 ea                	shr    %cl,%edx
  802256:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80225a:	09 d6                	or     %edx,%esi
  80225c:	89 f0                	mov    %esi,%eax
  80225e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802261:	d3 e7                	shl    %cl,%edi
  802263:	89 f2                	mov    %esi,%edx
  802265:	f7 75 f4             	divl   -0xc(%ebp)
  802268:	89 d6                	mov    %edx,%esi
  80226a:	f7 65 e8             	mull   -0x18(%ebp)
  80226d:	39 d6                	cmp    %edx,%esi
  80226f:	72 2b                	jb     80229c <__umoddi3+0x11c>
  802271:	39 c7                	cmp    %eax,%edi
  802273:	72 23                	jb     802298 <__umoddi3+0x118>
  802275:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802279:	29 c7                	sub    %eax,%edi
  80227b:	19 d6                	sbb    %edx,%esi
  80227d:	89 f0                	mov    %esi,%eax
  80227f:	89 f2                	mov    %esi,%edx
  802281:	d3 ef                	shr    %cl,%edi
  802283:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802287:	d3 e0                	shl    %cl,%eax
  802289:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80228d:	09 f8                	or     %edi,%eax
  80228f:	d3 ea                	shr    %cl,%edx
  802291:	83 c4 20             	add    $0x20,%esp
  802294:	5e                   	pop    %esi
  802295:	5f                   	pop    %edi
  802296:	5d                   	pop    %ebp
  802297:	c3                   	ret    
  802298:	39 d6                	cmp    %edx,%esi
  80229a:	75 d9                	jne    802275 <__umoddi3+0xf5>
  80229c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80229f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8022a2:	eb d1                	jmp    802275 <__umoddi3+0xf5>
  8022a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022a8:	39 f2                	cmp    %esi,%edx
  8022aa:	0f 82 18 ff ff ff    	jb     8021c8 <__umoddi3+0x48>
  8022b0:	e9 1d ff ff ff       	jmp    8021d2 <__umoddi3+0x52>
