
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
  80003a:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800041:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800044:	ba 01 00 00 00       	mov    $0x1,%edx
  800049:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004e:	89 d0                	mov    %edx,%eax
  800050:	c1 fa 1f             	sar    $0x1f,%edx
  800053:	f7 f9                	idiv   %ecx
  800055:	89 44 24 04          	mov    %eax,0x4(%esp)
  800059:	c7 04 24 20 1d 80 00 	movl   $0x801d20,(%esp)
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
  80007a:	e8 95 0e 00 00       	call   800f14 <sys_getenvid>
  80007f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800084:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800087:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008c:	a3 08 40 80 00       	mov    %eax,0x804008

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
  8000be:	e8 26 14 00 00       	call   8014e9 <close_all>
	sys_env_destroy(0);
  8000c3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ca:	e8 80 0e 00 00       	call   800f4f <sys_env_destroy>
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
  800128:	e8 96 0e 00 00       	call   800fc3 <sys_cputs>

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
  80017c:	e8 42 0e 00 00       	call   800fc3 <sys_cputs>
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
  80021d:	e8 7e 18 00 00       	call   801aa0 <__udivdi3>
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
  800278:	e8 53 19 00 00       	call   801bd0 <__umoddi3>
  80027d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800281:	0f be 80 38 1d 80 00 	movsbl 0x801d38(%eax),%eax
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
  800365:	ff 24 95 20 1f 80 00 	jmp    *0x801f20(,%edx,4)
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
  800438:	8b 14 85 80 20 80 00 	mov    0x802080(,%eax,4),%edx
  80043f:	85 d2                	test   %edx,%edx
  800441:	75 20                	jne    800463 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800443:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800447:	c7 44 24 08 49 1d 80 	movl   $0x801d49,0x8(%esp)
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
  800467:	c7 44 24 08 97 21 80 	movl   $0x802197,0x8(%esp)
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
  8004a1:	b8 52 1d 80 00       	mov    $0x801d52,%eax
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
  8006e5:	c7 44 24 0c 6c 1e 80 	movl   $0x801e6c,0xc(%esp)
  8006ec:	00 
  8006ed:	c7 44 24 08 97 21 80 	movl   $0x802197,0x8(%esp)
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
  800713:	c7 44 24 0c a4 1e 80 	movl   $0x801ea4,0xc(%esp)
  80071a:	00 
  80071b:	c7 44 24 08 97 21 80 	movl   $0x802197,0x8(%esp)
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
  800cb7:	c7 44 24 08 c0 20 80 	movl   $0x8020c0,0x8(%esp)
  800cbe:	00 
  800cbf:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800cc6:	00 
  800cc7:	c7 04 24 dd 20 80 00 	movl   $0x8020dd,(%esp)
  800cce:	e8 1d 0c 00 00       	call   8018f0 <_panic>

	return ret;
}
  800cd3:	89 d0                	mov    %edx,%eax
  800cd5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cd8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cdb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cde:	89 ec                	mov    %ebp,%esp
  800ce0:	5d                   	pop    %ebp
  800ce1:	c3                   	ret    

00800ce2 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800ce8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800cef:	00 
  800cf0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800cf7:	00 
  800cf8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800cff:	00 
  800d00:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d0a:	ba 01 00 00 00       	mov    $0x1,%edx
  800d0f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d14:	e8 53 ff ff ff       	call   800c6c <syscall>
}
  800d19:	c9                   	leave  
  800d1a:	c3                   	ret    

00800d1b <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d21:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d28:	00 
  800d29:	8b 45 14             	mov    0x14(%ebp),%eax
  800d2c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d30:	8b 45 10             	mov    0x10(%ebp),%eax
  800d33:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d3a:	89 04 24             	mov    %eax,(%esp)
  800d3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d40:	ba 00 00 00 00       	mov    $0x0,%edx
  800d45:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d4a:	e8 1d ff ff ff       	call   800c6c <syscall>
}
  800d4f:	c9                   	leave  
  800d50:	c3                   	ret    

00800d51 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d51:	55                   	push   %ebp
  800d52:	89 e5                	mov    %esp,%ebp
  800d54:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800d57:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d5e:	00 
  800d5f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d66:	00 
  800d67:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d6e:	00 
  800d6f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d72:	89 04 24             	mov    %eax,(%esp)
  800d75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d78:	ba 01 00 00 00       	mov    $0x1,%edx
  800d7d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d82:	e8 e5 fe ff ff       	call   800c6c <syscall>
}
  800d87:	c9                   	leave  
  800d88:	c3                   	ret    

00800d89 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d89:	55                   	push   %ebp
  800d8a:	89 e5                	mov    %esp,%ebp
  800d8c:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800d8f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d96:	00 
  800d97:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d9e:	00 
  800d9f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800da6:	00 
  800da7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800daa:	89 04 24             	mov    %eax,(%esp)
  800dad:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db0:	ba 01 00 00 00       	mov    $0x1,%edx
  800db5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dba:	e8 ad fe ff ff       	call   800c6c <syscall>
}
  800dbf:	c9                   	leave  
  800dc0:	c3                   	ret    

00800dc1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800dc7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dce:	00 
  800dcf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800dd6:	00 
  800dd7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800dde:	00 
  800ddf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de2:	89 04 24             	mov    %eax,(%esp)
  800de5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de8:	ba 01 00 00 00       	mov    $0x1,%edx
  800ded:	b8 09 00 00 00       	mov    $0x9,%eax
  800df2:	e8 75 fe ff ff       	call   800c6c <syscall>
}
  800df7:	c9                   	leave  
  800df8:	c3                   	ret    

00800df9 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800dff:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e06:	00 
  800e07:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e0e:	00 
  800e0f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e16:	00 
  800e17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e1a:	89 04 24             	mov    %eax,(%esp)
  800e1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e20:	ba 01 00 00 00       	mov    $0x1,%edx
  800e25:	b8 07 00 00 00       	mov    $0x7,%eax
  800e2a:	e8 3d fe ff ff       	call   800c6c <syscall>
}
  800e2f:	c9                   	leave  
  800e30:	c3                   	ret    

00800e31 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
  800e34:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800e37:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e3e:	00 
  800e3f:	8b 45 18             	mov    0x18(%ebp),%eax
  800e42:	0b 45 14             	or     0x14(%ebp),%eax
  800e45:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e49:	8b 45 10             	mov    0x10(%ebp),%eax
  800e4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e50:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e53:	89 04 24             	mov    %eax,(%esp)
  800e56:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e59:	ba 01 00 00 00       	mov    $0x1,%edx
  800e5e:	b8 06 00 00 00       	mov    $0x6,%eax
  800e63:	e8 04 fe ff ff       	call   800c6c <syscall>
}
  800e68:	c9                   	leave  
  800e69:	c3                   	ret    

00800e6a <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800e70:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e77:	00 
  800e78:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e7f:	00 
  800e80:	8b 45 10             	mov    0x10(%ebp),%eax
  800e83:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8a:	89 04 24             	mov    %eax,(%esp)
  800e8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e90:	ba 01 00 00 00       	mov    $0x1,%edx
  800e95:	b8 05 00 00 00       	mov    $0x5,%eax
  800e9a:	e8 cd fd ff ff       	call   800c6c <syscall>
}
  800e9f:	c9                   	leave  
  800ea0:	c3                   	ret    

00800ea1 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800ea1:	55                   	push   %ebp
  800ea2:	89 e5                	mov    %esp,%ebp
  800ea4:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800ea7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800eae:	00 
  800eaf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800eb6:	00 
  800eb7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ebe:	00 
  800ebf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ec6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ecb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ed5:	e8 92 fd ff ff       	call   800c6c <syscall>
}
  800eda:	c9                   	leave  
  800edb:	c3                   	ret    

00800edc <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  800ee2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ee9:	00 
  800eea:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ef1:	00 
  800ef2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ef9:	00 
  800efa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800efd:	89 04 24             	mov    %eax,(%esp)
  800f00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f03:	ba 00 00 00 00       	mov    $0x0,%edx
  800f08:	b8 04 00 00 00       	mov    $0x4,%eax
  800f0d:	e8 5a fd ff ff       	call   800c6c <syscall>
}
  800f12:	c9                   	leave  
  800f13:	c3                   	ret    

00800f14 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800f1a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f21:	00 
  800f22:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f29:	00 
  800f2a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f31:	00 
  800f32:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f39:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f43:	b8 02 00 00 00       	mov    $0x2,%eax
  800f48:	e8 1f fd ff ff       	call   800c6c <syscall>
}
  800f4d:	c9                   	leave  
  800f4e:	c3                   	ret    

00800f4f <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800f4f:	55                   	push   %ebp
  800f50:	89 e5                	mov    %esp,%ebp
  800f52:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800f55:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f5c:	00 
  800f5d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f64:	00 
  800f65:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f6c:	00 
  800f6d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f77:	ba 01 00 00 00       	mov    $0x1,%edx
  800f7c:	b8 03 00 00 00       	mov    $0x3,%eax
  800f81:	e8 e6 fc ff ff       	call   800c6c <syscall>
}
  800f86:	c9                   	leave  
  800f87:	c3                   	ret    

00800f88 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800f8e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f95:	00 
  800f96:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f9d:	00 
  800f9e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fa5:	00 
  800fa6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fad:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fb2:	ba 00 00 00 00       	mov    $0x0,%edx
  800fb7:	b8 01 00 00 00       	mov    $0x1,%eax
  800fbc:	e8 ab fc ff ff       	call   800c6c <syscall>
}
  800fc1:	c9                   	leave  
  800fc2:	c3                   	ret    

00800fc3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fc3:	55                   	push   %ebp
  800fc4:	89 e5                	mov    %esp,%ebp
  800fc6:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800fc9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fd0:	00 
  800fd1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fd8:	00 
  800fd9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fe0:	00 
  800fe1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe4:	89 04 24             	mov    %eax,(%esp)
  800fe7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fea:	ba 00 00 00 00       	mov    $0x0,%edx
  800fef:	b8 00 00 00 00       	mov    $0x0,%eax
  800ff4:	e8 73 fc ff ff       	call   800c6c <syscall>
}
  800ff9:	c9                   	leave  
  800ffa:	c3                   	ret    
  800ffb:	00 00                	add    %al,(%eax)
  800ffd:	00 00                	add    %al,(%eax)
	...

00801000 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	8b 45 08             	mov    0x8(%ebp),%eax
  801006:	05 00 00 00 30       	add    $0x30000000,%eax
  80100b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80100e:	5d                   	pop    %ebp
  80100f:	c3                   	ret    

00801010 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801016:	8b 45 08             	mov    0x8(%ebp),%eax
  801019:	89 04 24             	mov    %eax,(%esp)
  80101c:	e8 df ff ff ff       	call   801000 <fd2num>
  801021:	05 20 00 0d 00       	add    $0xd0020,%eax
  801026:	c1 e0 0c             	shl    $0xc,%eax
}
  801029:	c9                   	leave  
  80102a:	c3                   	ret    

0080102b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	57                   	push   %edi
  80102f:	56                   	push   %esi
  801030:	53                   	push   %ebx
  801031:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801034:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801039:	a8 01                	test   $0x1,%al
  80103b:	74 36                	je     801073 <fd_alloc+0x48>
  80103d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801042:	a8 01                	test   $0x1,%al
  801044:	74 2d                	je     801073 <fd_alloc+0x48>
  801046:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80104b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801050:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801055:	89 c3                	mov    %eax,%ebx
  801057:	89 c2                	mov    %eax,%edx
  801059:	c1 ea 16             	shr    $0x16,%edx
  80105c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80105f:	f6 c2 01             	test   $0x1,%dl
  801062:	74 14                	je     801078 <fd_alloc+0x4d>
  801064:	89 c2                	mov    %eax,%edx
  801066:	c1 ea 0c             	shr    $0xc,%edx
  801069:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80106c:	f6 c2 01             	test   $0x1,%dl
  80106f:	75 10                	jne    801081 <fd_alloc+0x56>
  801071:	eb 05                	jmp    801078 <fd_alloc+0x4d>
  801073:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801078:	89 1f                	mov    %ebx,(%edi)
  80107a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80107f:	eb 17                	jmp    801098 <fd_alloc+0x6d>
  801081:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801086:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80108b:	75 c8                	jne    801055 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80108d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801093:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801098:	5b                   	pop    %ebx
  801099:	5e                   	pop    %esi
  80109a:	5f                   	pop    %edi
  80109b:	5d                   	pop    %ebp
  80109c:	c3                   	ret    

0080109d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80109d:	55                   	push   %ebp
  80109e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a3:	83 f8 1f             	cmp    $0x1f,%eax
  8010a6:	77 36                	ja     8010de <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010a8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8010ad:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8010b0:	89 c2                	mov    %eax,%edx
  8010b2:	c1 ea 16             	shr    $0x16,%edx
  8010b5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010bc:	f6 c2 01             	test   $0x1,%dl
  8010bf:	74 1d                	je     8010de <fd_lookup+0x41>
  8010c1:	89 c2                	mov    %eax,%edx
  8010c3:	c1 ea 0c             	shr    $0xc,%edx
  8010c6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010cd:	f6 c2 01             	test   $0x1,%dl
  8010d0:	74 0c                	je     8010de <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010d2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010d5:	89 02                	mov    %eax,(%edx)
  8010d7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8010dc:	eb 05                	jmp    8010e3 <fd_lookup+0x46>
  8010de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010e3:	5d                   	pop    %ebp
  8010e4:	c3                   	ret    

008010e5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
  8010e8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010eb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8010ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f5:	89 04 24             	mov    %eax,(%esp)
  8010f8:	e8 a0 ff ff ff       	call   80109d <fd_lookup>
  8010fd:	85 c0                	test   %eax,%eax
  8010ff:	78 0e                	js     80110f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801101:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801104:	8b 55 0c             	mov    0xc(%ebp),%edx
  801107:	89 50 04             	mov    %edx,0x4(%eax)
  80110a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80110f:	c9                   	leave  
  801110:	c3                   	ret    

00801111 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801111:	55                   	push   %ebp
  801112:	89 e5                	mov    %esp,%ebp
  801114:	56                   	push   %esi
  801115:	53                   	push   %ebx
  801116:	83 ec 10             	sub    $0x10,%esp
  801119:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80111c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80111f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801124:	b8 04 30 80 00       	mov    $0x803004,%eax
  801129:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80112f:	75 11                	jne    801142 <dev_lookup+0x31>
  801131:	eb 04                	jmp    801137 <dev_lookup+0x26>
  801133:	39 08                	cmp    %ecx,(%eax)
  801135:	75 10                	jne    801147 <dev_lookup+0x36>
			*dev = devtab[i];
  801137:	89 03                	mov    %eax,(%ebx)
  801139:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80113e:	66 90                	xchg   %ax,%ax
  801140:	eb 36                	jmp    801178 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801142:	be 68 21 80 00       	mov    $0x802168,%esi
  801147:	83 c2 01             	add    $0x1,%edx
  80114a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80114d:	85 c0                	test   %eax,%eax
  80114f:	75 e2                	jne    801133 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801151:	a1 08 40 80 00       	mov    0x804008,%eax
  801156:	8b 40 48             	mov    0x48(%eax),%eax
  801159:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80115d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801161:	c7 04 24 ec 20 80 00 	movl   $0x8020ec,(%esp)
  801168:	e8 c8 ef ff ff       	call   800135 <cprintf>
	*dev = 0;
  80116d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801173:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801178:	83 c4 10             	add    $0x10,%esp
  80117b:	5b                   	pop    %ebx
  80117c:	5e                   	pop    %esi
  80117d:	5d                   	pop    %ebp
  80117e:	c3                   	ret    

0080117f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	53                   	push   %ebx
  801183:	83 ec 24             	sub    $0x24,%esp
  801186:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801189:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80118c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801190:	8b 45 08             	mov    0x8(%ebp),%eax
  801193:	89 04 24             	mov    %eax,(%esp)
  801196:	e8 02 ff ff ff       	call   80109d <fd_lookup>
  80119b:	85 c0                	test   %eax,%eax
  80119d:	78 53                	js     8011f2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80119f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011a9:	8b 00                	mov    (%eax),%eax
  8011ab:	89 04 24             	mov    %eax,(%esp)
  8011ae:	e8 5e ff ff ff       	call   801111 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011b3:	85 c0                	test   %eax,%eax
  8011b5:	78 3b                	js     8011f2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8011b7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011bf:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8011c3:	74 2d                	je     8011f2 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8011c5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8011c8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8011cf:	00 00 00 
	stat->st_isdir = 0;
  8011d2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8011d9:	00 00 00 
	stat->st_dev = dev;
  8011dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011df:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8011e5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011e9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011ec:	89 14 24             	mov    %edx,(%esp)
  8011ef:	ff 50 14             	call   *0x14(%eax)
}
  8011f2:	83 c4 24             	add    $0x24,%esp
  8011f5:	5b                   	pop    %ebx
  8011f6:	5d                   	pop    %ebp
  8011f7:	c3                   	ret    

008011f8 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8011f8:	55                   	push   %ebp
  8011f9:	89 e5                	mov    %esp,%ebp
  8011fb:	53                   	push   %ebx
  8011fc:	83 ec 24             	sub    $0x24,%esp
  8011ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801202:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801205:	89 44 24 04          	mov    %eax,0x4(%esp)
  801209:	89 1c 24             	mov    %ebx,(%esp)
  80120c:	e8 8c fe ff ff       	call   80109d <fd_lookup>
  801211:	85 c0                	test   %eax,%eax
  801213:	78 5f                	js     801274 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801215:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801218:	89 44 24 04          	mov    %eax,0x4(%esp)
  80121c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121f:	8b 00                	mov    (%eax),%eax
  801221:	89 04 24             	mov    %eax,(%esp)
  801224:	e8 e8 fe ff ff       	call   801111 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801229:	85 c0                	test   %eax,%eax
  80122b:	78 47                	js     801274 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80122d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801230:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801234:	75 23                	jne    801259 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801236:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80123b:	8b 40 48             	mov    0x48(%eax),%eax
  80123e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801242:	89 44 24 04          	mov    %eax,0x4(%esp)
  801246:	c7 04 24 0c 21 80 00 	movl   $0x80210c,(%esp)
  80124d:	e8 e3 ee ff ff       	call   800135 <cprintf>
  801252:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801257:	eb 1b                	jmp    801274 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801259:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80125c:	8b 48 18             	mov    0x18(%eax),%ecx
  80125f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801264:	85 c9                	test   %ecx,%ecx
  801266:	74 0c                	je     801274 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801268:	8b 45 0c             	mov    0xc(%ebp),%eax
  80126b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80126f:	89 14 24             	mov    %edx,(%esp)
  801272:	ff d1                	call   *%ecx
}
  801274:	83 c4 24             	add    $0x24,%esp
  801277:	5b                   	pop    %ebx
  801278:	5d                   	pop    %ebp
  801279:	c3                   	ret    

0080127a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80127a:	55                   	push   %ebp
  80127b:	89 e5                	mov    %esp,%ebp
  80127d:	53                   	push   %ebx
  80127e:	83 ec 24             	sub    $0x24,%esp
  801281:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801284:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801287:	89 44 24 04          	mov    %eax,0x4(%esp)
  80128b:	89 1c 24             	mov    %ebx,(%esp)
  80128e:	e8 0a fe ff ff       	call   80109d <fd_lookup>
  801293:	85 c0                	test   %eax,%eax
  801295:	78 66                	js     8012fd <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801297:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80129a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80129e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a1:	8b 00                	mov    (%eax),%eax
  8012a3:	89 04 24             	mov    %eax,(%esp)
  8012a6:	e8 66 fe ff ff       	call   801111 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	78 4e                	js     8012fd <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012af:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012b2:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8012b6:	75 23                	jne    8012db <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012b8:	a1 08 40 80 00       	mov    0x804008,%eax
  8012bd:	8b 40 48             	mov    0x48(%eax),%eax
  8012c0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c8:	c7 04 24 2d 21 80 00 	movl   $0x80212d,(%esp)
  8012cf:	e8 61 ee ff ff       	call   800135 <cprintf>
  8012d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8012d9:	eb 22                	jmp    8012fd <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012db:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012de:	8b 48 0c             	mov    0xc(%eax),%ecx
  8012e1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012e6:	85 c9                	test   %ecx,%ecx
  8012e8:	74 13                	je     8012fd <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8012ed:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f8:	89 14 24             	mov    %edx,(%esp)
  8012fb:	ff d1                	call   *%ecx
}
  8012fd:	83 c4 24             	add    $0x24,%esp
  801300:	5b                   	pop    %ebx
  801301:	5d                   	pop    %ebp
  801302:	c3                   	ret    

00801303 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801303:	55                   	push   %ebp
  801304:	89 e5                	mov    %esp,%ebp
  801306:	53                   	push   %ebx
  801307:	83 ec 24             	sub    $0x24,%esp
  80130a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80130d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801310:	89 44 24 04          	mov    %eax,0x4(%esp)
  801314:	89 1c 24             	mov    %ebx,(%esp)
  801317:	e8 81 fd ff ff       	call   80109d <fd_lookup>
  80131c:	85 c0                	test   %eax,%eax
  80131e:	78 6b                	js     80138b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801320:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801323:	89 44 24 04          	mov    %eax,0x4(%esp)
  801327:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80132a:	8b 00                	mov    (%eax),%eax
  80132c:	89 04 24             	mov    %eax,(%esp)
  80132f:	e8 dd fd ff ff       	call   801111 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801334:	85 c0                	test   %eax,%eax
  801336:	78 53                	js     80138b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801338:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80133b:	8b 42 08             	mov    0x8(%edx),%eax
  80133e:	83 e0 03             	and    $0x3,%eax
  801341:	83 f8 01             	cmp    $0x1,%eax
  801344:	75 23                	jne    801369 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801346:	a1 08 40 80 00       	mov    0x804008,%eax
  80134b:	8b 40 48             	mov    0x48(%eax),%eax
  80134e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801352:	89 44 24 04          	mov    %eax,0x4(%esp)
  801356:	c7 04 24 4a 21 80 00 	movl   $0x80214a,(%esp)
  80135d:	e8 d3 ed ff ff       	call   800135 <cprintf>
  801362:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801367:	eb 22                	jmp    80138b <read+0x88>
	}
	if (!dev->dev_read)
  801369:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136c:	8b 48 08             	mov    0x8(%eax),%ecx
  80136f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801374:	85 c9                	test   %ecx,%ecx
  801376:	74 13                	je     80138b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801378:	8b 45 10             	mov    0x10(%ebp),%eax
  80137b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80137f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801382:	89 44 24 04          	mov    %eax,0x4(%esp)
  801386:	89 14 24             	mov    %edx,(%esp)
  801389:	ff d1                	call   *%ecx
}
  80138b:	83 c4 24             	add    $0x24,%esp
  80138e:	5b                   	pop    %ebx
  80138f:	5d                   	pop    %ebp
  801390:	c3                   	ret    

00801391 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801391:	55                   	push   %ebp
  801392:	89 e5                	mov    %esp,%ebp
  801394:	57                   	push   %edi
  801395:	56                   	push   %esi
  801396:	53                   	push   %ebx
  801397:	83 ec 1c             	sub    $0x1c,%esp
  80139a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80139d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8013af:	85 f6                	test   %esi,%esi
  8013b1:	74 29                	je     8013dc <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013b3:	89 f0                	mov    %esi,%eax
  8013b5:	29 d0                	sub    %edx,%eax
  8013b7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013bb:	03 55 0c             	add    0xc(%ebp),%edx
  8013be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013c2:	89 3c 24             	mov    %edi,(%esp)
  8013c5:	e8 39 ff ff ff       	call   801303 <read>
		if (m < 0)
  8013ca:	85 c0                	test   %eax,%eax
  8013cc:	78 0e                	js     8013dc <readn+0x4b>
			return m;
		if (m == 0)
  8013ce:	85 c0                	test   %eax,%eax
  8013d0:	74 08                	je     8013da <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013d2:	01 c3                	add    %eax,%ebx
  8013d4:	89 da                	mov    %ebx,%edx
  8013d6:	39 f3                	cmp    %esi,%ebx
  8013d8:	72 d9                	jb     8013b3 <readn+0x22>
  8013da:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013dc:	83 c4 1c             	add    $0x1c,%esp
  8013df:	5b                   	pop    %ebx
  8013e0:	5e                   	pop    %esi
  8013e1:	5f                   	pop    %edi
  8013e2:	5d                   	pop    %ebp
  8013e3:	c3                   	ret    

008013e4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013e4:	55                   	push   %ebp
  8013e5:	89 e5                	mov    %esp,%ebp
  8013e7:	83 ec 28             	sub    $0x28,%esp
  8013ea:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013ed:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8013f0:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013f3:	89 34 24             	mov    %esi,(%esp)
  8013f6:	e8 05 fc ff ff       	call   801000 <fd2num>
  8013fb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8013fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  801402:	89 04 24             	mov    %eax,(%esp)
  801405:	e8 93 fc ff ff       	call   80109d <fd_lookup>
  80140a:	89 c3                	mov    %eax,%ebx
  80140c:	85 c0                	test   %eax,%eax
  80140e:	78 05                	js     801415 <fd_close+0x31>
  801410:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801413:	74 0e                	je     801423 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801415:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801419:	b8 00 00 00 00       	mov    $0x0,%eax
  80141e:	0f 44 d8             	cmove  %eax,%ebx
  801421:	eb 3d                	jmp    801460 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801423:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801426:	89 44 24 04          	mov    %eax,0x4(%esp)
  80142a:	8b 06                	mov    (%esi),%eax
  80142c:	89 04 24             	mov    %eax,(%esp)
  80142f:	e8 dd fc ff ff       	call   801111 <dev_lookup>
  801434:	89 c3                	mov    %eax,%ebx
  801436:	85 c0                	test   %eax,%eax
  801438:	78 16                	js     801450 <fd_close+0x6c>
		if (dev->dev_close)
  80143a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143d:	8b 40 10             	mov    0x10(%eax),%eax
  801440:	bb 00 00 00 00       	mov    $0x0,%ebx
  801445:	85 c0                	test   %eax,%eax
  801447:	74 07                	je     801450 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801449:	89 34 24             	mov    %esi,(%esp)
  80144c:	ff d0                	call   *%eax
  80144e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801450:	89 74 24 04          	mov    %esi,0x4(%esp)
  801454:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80145b:	e8 99 f9 ff ff       	call   800df9 <sys_page_unmap>
	return r;
}
  801460:	89 d8                	mov    %ebx,%eax
  801462:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801465:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801468:	89 ec                	mov    %ebp,%esp
  80146a:	5d                   	pop    %ebp
  80146b:	c3                   	ret    

0080146c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80146c:	55                   	push   %ebp
  80146d:	89 e5                	mov    %esp,%ebp
  80146f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801472:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801475:	89 44 24 04          	mov    %eax,0x4(%esp)
  801479:	8b 45 08             	mov    0x8(%ebp),%eax
  80147c:	89 04 24             	mov    %eax,(%esp)
  80147f:	e8 19 fc ff ff       	call   80109d <fd_lookup>
  801484:	85 c0                	test   %eax,%eax
  801486:	78 13                	js     80149b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801488:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80148f:	00 
  801490:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801493:	89 04 24             	mov    %eax,(%esp)
  801496:	e8 49 ff ff ff       	call   8013e4 <fd_close>
}
  80149b:	c9                   	leave  
  80149c:	c3                   	ret    

0080149d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80149d:	55                   	push   %ebp
  80149e:	89 e5                	mov    %esp,%ebp
  8014a0:	83 ec 18             	sub    $0x18,%esp
  8014a3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8014a6:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014a9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014b0:	00 
  8014b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014b4:	89 04 24             	mov    %eax,(%esp)
  8014b7:	e8 78 03 00 00       	call   801834 <open>
  8014bc:	89 c3                	mov    %eax,%ebx
  8014be:	85 c0                	test   %eax,%eax
  8014c0:	78 1b                	js     8014dd <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8014c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c9:	89 1c 24             	mov    %ebx,(%esp)
  8014cc:	e8 ae fc ff ff       	call   80117f <fstat>
  8014d1:	89 c6                	mov    %eax,%esi
	close(fd);
  8014d3:	89 1c 24             	mov    %ebx,(%esp)
  8014d6:	e8 91 ff ff ff       	call   80146c <close>
  8014db:	89 f3                	mov    %esi,%ebx
	return r;
}
  8014dd:	89 d8                	mov    %ebx,%eax
  8014df:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014e2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8014e5:	89 ec                	mov    %ebp,%esp
  8014e7:	5d                   	pop    %ebp
  8014e8:	c3                   	ret    

008014e9 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8014e9:	55                   	push   %ebp
  8014ea:	89 e5                	mov    %esp,%ebp
  8014ec:	53                   	push   %ebx
  8014ed:	83 ec 14             	sub    $0x14,%esp
  8014f0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8014f5:	89 1c 24             	mov    %ebx,(%esp)
  8014f8:	e8 6f ff ff ff       	call   80146c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014fd:	83 c3 01             	add    $0x1,%ebx
  801500:	83 fb 20             	cmp    $0x20,%ebx
  801503:	75 f0                	jne    8014f5 <close_all+0xc>
		close(i);
}
  801505:	83 c4 14             	add    $0x14,%esp
  801508:	5b                   	pop    %ebx
  801509:	5d                   	pop    %ebp
  80150a:	c3                   	ret    

0080150b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80150b:	55                   	push   %ebp
  80150c:	89 e5                	mov    %esp,%ebp
  80150e:	83 ec 58             	sub    $0x58,%esp
  801511:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801514:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801517:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80151a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80151d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801520:	89 44 24 04          	mov    %eax,0x4(%esp)
  801524:	8b 45 08             	mov    0x8(%ebp),%eax
  801527:	89 04 24             	mov    %eax,(%esp)
  80152a:	e8 6e fb ff ff       	call   80109d <fd_lookup>
  80152f:	89 c3                	mov    %eax,%ebx
  801531:	85 c0                	test   %eax,%eax
  801533:	0f 88 e0 00 00 00    	js     801619 <dup+0x10e>
		return r;
	close(newfdnum);
  801539:	89 3c 24             	mov    %edi,(%esp)
  80153c:	e8 2b ff ff ff       	call   80146c <close>

	newfd = INDEX2FD(newfdnum);
  801541:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801547:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80154a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80154d:	89 04 24             	mov    %eax,(%esp)
  801550:	e8 bb fa ff ff       	call   801010 <fd2data>
  801555:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801557:	89 34 24             	mov    %esi,(%esp)
  80155a:	e8 b1 fa ff ff       	call   801010 <fd2data>
  80155f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801562:	89 da                	mov    %ebx,%edx
  801564:	89 d8                	mov    %ebx,%eax
  801566:	c1 e8 16             	shr    $0x16,%eax
  801569:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801570:	a8 01                	test   $0x1,%al
  801572:	74 43                	je     8015b7 <dup+0xac>
  801574:	c1 ea 0c             	shr    $0xc,%edx
  801577:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80157e:	a8 01                	test   $0x1,%al
  801580:	74 35                	je     8015b7 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801582:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801589:	25 07 0e 00 00       	and    $0xe07,%eax
  80158e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801592:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801595:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801599:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015a0:	00 
  8015a1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015a5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015ac:	e8 80 f8 ff ff       	call   800e31 <sys_page_map>
  8015b1:	89 c3                	mov    %eax,%ebx
  8015b3:	85 c0                	test   %eax,%eax
  8015b5:	78 3f                	js     8015f6 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015ba:	89 c2                	mov    %eax,%edx
  8015bc:	c1 ea 0c             	shr    $0xc,%edx
  8015bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015c6:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8015cc:	89 54 24 10          	mov    %edx,0x10(%esp)
  8015d0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8015d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015db:	00 
  8015dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015e7:	e8 45 f8 ff ff       	call   800e31 <sys_page_map>
  8015ec:	89 c3                	mov    %eax,%ebx
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	78 04                	js     8015f6 <dup+0xeb>
  8015f2:	89 fb                	mov    %edi,%ebx
  8015f4:	eb 23                	jmp    801619 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015f6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015fa:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801601:	e8 f3 f7 ff ff       	call   800df9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801606:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801609:	89 44 24 04          	mov    %eax,0x4(%esp)
  80160d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801614:	e8 e0 f7 ff ff       	call   800df9 <sys_page_unmap>
	return r;
}
  801619:	89 d8                	mov    %ebx,%eax
  80161b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80161e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801621:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801624:	89 ec                	mov    %ebp,%esp
  801626:	5d                   	pop    %ebp
  801627:	c3                   	ret    

00801628 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801628:	55                   	push   %ebp
  801629:	89 e5                	mov    %esp,%ebp
  80162b:	83 ec 18             	sub    $0x18,%esp
  80162e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801631:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801634:	89 c3                	mov    %eax,%ebx
  801636:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801638:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80163f:	75 11                	jne    801652 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801641:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801648:	e8 03 03 00 00       	call   801950 <ipc_find_env>
  80164d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801652:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801659:	00 
  80165a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801661:	00 
  801662:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801666:	a1 00 40 80 00       	mov    0x804000,%eax
  80166b:	89 04 24             	mov    %eax,(%esp)
  80166e:	e8 21 03 00 00       	call   801994 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801673:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80167a:	00 
  80167b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80167f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801686:	e8 78 03 00 00       	call   801a03 <ipc_recv>
}
  80168b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80168e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801691:	89 ec                	mov    %ebp,%esp
  801693:	5d                   	pop    %ebp
  801694:	c3                   	ret    

00801695 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801695:	55                   	push   %ebp
  801696:	89 e5                	mov    %esp,%ebp
  801698:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80169b:	8b 45 08             	mov    0x8(%ebp),%eax
  80169e:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016a6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016a9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b3:	b8 02 00 00 00       	mov    $0x2,%eax
  8016b8:	e8 6b ff ff ff       	call   801628 <fsipc>
}
  8016bd:	c9                   	leave  
  8016be:	c3                   	ret    

008016bf <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016bf:	55                   	push   %ebp
  8016c0:	89 e5                	mov    %esp,%ebp
  8016c2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c8:	8b 40 0c             	mov    0xc(%eax),%eax
  8016cb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d5:	b8 06 00 00 00       	mov    $0x6,%eax
  8016da:	e8 49 ff ff ff       	call   801628 <fsipc>
}
  8016df:	c9                   	leave  
  8016e0:	c3                   	ret    

008016e1 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016e7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ec:	b8 08 00 00 00       	mov    $0x8,%eax
  8016f1:	e8 32 ff ff ff       	call   801628 <fsipc>
}
  8016f6:	c9                   	leave  
  8016f7:	c3                   	ret    

008016f8 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	53                   	push   %ebx
  8016fc:	83 ec 14             	sub    $0x14,%esp
  8016ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801702:	8b 45 08             	mov    0x8(%ebp),%eax
  801705:	8b 40 0c             	mov    0xc(%eax),%eax
  801708:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80170d:	ba 00 00 00 00       	mov    $0x0,%edx
  801712:	b8 05 00 00 00       	mov    $0x5,%eax
  801717:	e8 0c ff ff ff       	call   801628 <fsipc>
  80171c:	85 c0                	test   %eax,%eax
  80171e:	78 2b                	js     80174b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801720:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801727:	00 
  801728:	89 1c 24             	mov    %ebx,(%esp)
  80172b:	e8 4a f1 ff ff       	call   80087a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801730:	a1 80 50 80 00       	mov    0x805080,%eax
  801735:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80173b:	a1 84 50 80 00       	mov    0x805084,%eax
  801740:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801746:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80174b:	83 c4 14             	add    $0x14,%esp
  80174e:	5b                   	pop    %ebx
  80174f:	5d                   	pop    %ebp
  801750:	c3                   	ret    

00801751 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801751:	55                   	push   %ebp
  801752:	89 e5                	mov    %esp,%ebp
  801754:	83 ec 18             	sub    $0x18,%esp
  801757:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  80175a:	8b 55 08             	mov    0x8(%ebp),%edx
  80175d:	8b 52 0c             	mov    0xc(%edx),%edx
  801760:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  801766:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  80176b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801770:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801775:	0f 47 c2             	cmova  %edx,%eax
  801778:	89 44 24 08          	mov    %eax,0x8(%esp)
  80177c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80177f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801783:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  80178a:	e8 d6 f2 ff ff       	call   800a65 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  80178f:	ba 00 00 00 00       	mov    $0x0,%edx
  801794:	b8 04 00 00 00       	mov    $0x4,%eax
  801799:	e8 8a fe ff ff       	call   801628 <fsipc>
}
  80179e:	c9                   	leave  
  80179f:	c3                   	ret    

008017a0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017a0:	55                   	push   %ebp
  8017a1:	89 e5                	mov    %esp,%ebp
  8017a3:	53                   	push   %ebx
  8017a4:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ad:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  8017b2:	8b 45 10             	mov    0x10(%ebp),%eax
  8017b5:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8017bf:	b8 03 00 00 00       	mov    $0x3,%eax
  8017c4:	e8 5f fe ff ff       	call   801628 <fsipc>
  8017c9:	89 c3                	mov    %eax,%ebx
  8017cb:	85 c0                	test   %eax,%eax
  8017cd:	78 17                	js     8017e6 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017d3:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8017da:	00 
  8017db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017de:	89 04 24             	mov    %eax,(%esp)
  8017e1:	e8 7f f2 ff ff       	call   800a65 <memmove>
  return r;	
}
  8017e6:	89 d8                	mov    %ebx,%eax
  8017e8:	83 c4 14             	add    $0x14,%esp
  8017eb:	5b                   	pop    %ebx
  8017ec:	5d                   	pop    %ebp
  8017ed:	c3                   	ret    

008017ee <remove>:
}

// Delete a file
int
remove(const char *path)
{
  8017ee:	55                   	push   %ebp
  8017ef:	89 e5                	mov    %esp,%ebp
  8017f1:	53                   	push   %ebx
  8017f2:	83 ec 14             	sub    $0x14,%esp
  8017f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8017f8:	89 1c 24             	mov    %ebx,(%esp)
  8017fb:	e8 30 f0 ff ff       	call   800830 <strlen>
  801800:	89 c2                	mov    %eax,%edx
  801802:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801807:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  80180d:	7f 1f                	jg     80182e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  80180f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801813:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80181a:	e8 5b f0 ff ff       	call   80087a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  80181f:	ba 00 00 00 00       	mov    $0x0,%edx
  801824:	b8 07 00 00 00       	mov    $0x7,%eax
  801829:	e8 fa fd ff ff       	call   801628 <fsipc>
}
  80182e:	83 c4 14             	add    $0x14,%esp
  801831:	5b                   	pop    %ebx
  801832:	5d                   	pop    %ebp
  801833:	c3                   	ret    

00801834 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801834:	55                   	push   %ebp
  801835:	89 e5                	mov    %esp,%ebp
  801837:	83 ec 28             	sub    $0x28,%esp
  80183a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80183d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801840:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801843:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801846:	89 04 24             	mov    %eax,(%esp)
  801849:	e8 dd f7 ff ff       	call   80102b <fd_alloc>
  80184e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801850:	85 c0                	test   %eax,%eax
  801852:	0f 88 89 00 00 00    	js     8018e1 <open+0xad>

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801858:	89 34 24             	mov    %esi,(%esp)
  80185b:	e8 d0 ef ff ff       	call   800830 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801860:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801865:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80186a:	7f 75                	jg     8018e1 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  80186c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801870:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801877:	e8 fe ef ff ff       	call   80087a <strcpy>
  fsipcbuf.open.req_omode = mode;
  80187c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80187f:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  801884:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801887:	b8 01 00 00 00       	mov    $0x1,%eax
  80188c:	e8 97 fd ff ff       	call   801628 <fsipc>
  801891:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801893:	85 c0                	test   %eax,%eax
  801895:	78 0f                	js     8018a6 <open+0x72>
  return fd2num(fd);
  801897:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80189a:	89 04 24             	mov    %eax,(%esp)
  80189d:	e8 5e f7 ff ff       	call   801000 <fd2num>
  8018a2:	89 c3                	mov    %eax,%ebx
  8018a4:	eb 3b                	jmp    8018e1 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  8018a6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8018ad:	00 
  8018ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b1:	89 04 24             	mov    %eax,(%esp)
  8018b4:	e8 2b fb ff ff       	call   8013e4 <fd_close>
  8018b9:	85 c0                	test   %eax,%eax
  8018bb:	74 24                	je     8018e1 <open+0xad>
  8018bd:	c7 44 24 0c 70 21 80 	movl   $0x802170,0xc(%esp)
  8018c4:	00 
  8018c5:	c7 44 24 08 85 21 80 	movl   $0x802185,0x8(%esp)
  8018cc:	00 
  8018cd:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  8018d4:	00 
  8018d5:	c7 04 24 9a 21 80 00 	movl   $0x80219a,(%esp)
  8018dc:	e8 0f 00 00 00       	call   8018f0 <_panic>
  return r;
}
  8018e1:	89 d8                	mov    %ebx,%eax
  8018e3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8018e6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8018e9:	89 ec                	mov    %ebp,%esp
  8018eb:	5d                   	pop    %ebp
  8018ec:	c3                   	ret    
  8018ed:	00 00                	add    %al,(%eax)
	...

008018f0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8018f0:	55                   	push   %ebp
  8018f1:	89 e5                	mov    %esp,%ebp
  8018f3:	56                   	push   %esi
  8018f4:	53                   	push   %ebx
  8018f5:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8018f8:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8018fb:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801901:	e8 0e f6 ff ff       	call   800f14 <sys_getenvid>
  801906:	8b 55 0c             	mov    0xc(%ebp),%edx
  801909:	89 54 24 10          	mov    %edx,0x10(%esp)
  80190d:	8b 55 08             	mov    0x8(%ebp),%edx
  801910:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801914:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801918:	89 44 24 04          	mov    %eax,0x4(%esp)
  80191c:	c7 04 24 a8 21 80 00 	movl   $0x8021a8,(%esp)
  801923:	e8 0d e8 ff ff       	call   800135 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801928:	89 74 24 04          	mov    %esi,0x4(%esp)
  80192c:	8b 45 10             	mov    0x10(%ebp),%eax
  80192f:	89 04 24             	mov    %eax,(%esp)
  801932:	e8 9d e7 ff ff       	call   8000d4 <vcprintf>
	cprintf("\n");
  801937:	c7 04 24 2c 1d 80 00 	movl   $0x801d2c,(%esp)
  80193e:	e8 f2 e7 ff ff       	call   800135 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801943:	cc                   	int3   
  801944:	eb fd                	jmp    801943 <_panic+0x53>
	...

00801950 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801956:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80195c:	b8 01 00 00 00       	mov    $0x1,%eax
  801961:	39 ca                	cmp    %ecx,%edx
  801963:	75 04                	jne    801969 <ipc_find_env+0x19>
  801965:	b0 00                	mov    $0x0,%al
  801967:	eb 0f                	jmp    801978 <ipc_find_env+0x28>
  801969:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80196c:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801972:	8b 12                	mov    (%edx),%edx
  801974:	39 ca                	cmp    %ecx,%edx
  801976:	75 0c                	jne    801984 <ipc_find_env+0x34>
			return envs[i].env_id;
  801978:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80197b:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  801980:	8b 00                	mov    (%eax),%eax
  801982:	eb 0e                	jmp    801992 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801984:	83 c0 01             	add    $0x1,%eax
  801987:	3d 00 04 00 00       	cmp    $0x400,%eax
  80198c:	75 db                	jne    801969 <ipc_find_env+0x19>
  80198e:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801992:	5d                   	pop    %ebp
  801993:	c3                   	ret    

00801994 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801994:	55                   	push   %ebp
  801995:	89 e5                	mov    %esp,%ebp
  801997:	57                   	push   %edi
  801998:	56                   	push   %esi
  801999:	53                   	push   %ebx
  80199a:	83 ec 1c             	sub    $0x1c,%esp
  80199d:	8b 75 08             	mov    0x8(%ebp),%esi
  8019a0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8019a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  8019a6:	85 db                	test   %ebx,%ebx
  8019a8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8019ad:	0f 44 d8             	cmove  %eax,%ebx
  8019b0:	eb 29                	jmp    8019db <ipc_send+0x47>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
  8019b2:	85 c0                	test   %eax,%eax
  8019b4:	79 25                	jns    8019db <ipc_send+0x47>
  8019b6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8019b9:	74 20                	je     8019db <ipc_send+0x47>
			panic ("ipc: sys try send failed : %e", r);
  8019bb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019bf:	c7 44 24 08 cc 21 80 	movl   $0x8021cc,0x8(%esp)
  8019c6:	00 
  8019c7:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8019ce:	00 
  8019cf:	c7 04 24 ea 21 80 00 	movl   $0x8021ea,(%esp)
  8019d6:	e8 15 ff ff ff       	call   8018f0 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  8019db:	8b 45 14             	mov    0x14(%ebp),%eax
  8019de:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019e2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019e6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8019ea:	89 34 24             	mov    %esi,(%esp)
  8019ed:	e8 29 f3 ff ff       	call   800d1b <sys_ipc_try_send>
  8019f2:	85 c0                	test   %eax,%eax
  8019f4:	75 bc                	jne    8019b2 <ipc_send+0x1e>
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  8019f6:	e8 a6 f4 ff ff       	call   800ea1 <sys_yield>
}
  8019fb:	83 c4 1c             	add    $0x1c,%esp
  8019fe:	5b                   	pop    %ebx
  8019ff:	5e                   	pop    %esi
  801a00:	5f                   	pop    %edi
  801a01:	5d                   	pop    %ebp
  801a02:	c3                   	ret    

00801a03 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a03:	55                   	push   %ebp
  801a04:	89 e5                	mov    %esp,%ebp
  801a06:	83 ec 28             	sub    $0x28,%esp
  801a09:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801a0c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801a0f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801a12:	8b 75 08             	mov    0x8(%ebp),%esi
  801a15:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a18:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801a1b:	85 c0                	test   %eax,%eax
  801a1d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a22:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801a25:	89 04 24             	mov    %eax,(%esp)
  801a28:	e8 b5 f2 ff ff       	call   800ce2 <sys_ipc_recv>
  801a2d:	89 c3                	mov    %eax,%ebx
  801a2f:	85 c0                	test   %eax,%eax
  801a31:	79 2a                	jns    801a5d <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  801a33:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a37:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a3b:	c7 04 24 f4 21 80 00 	movl   $0x8021f4,(%esp)
  801a42:	e8 ee e6 ff ff       	call   800135 <cprintf>
		if(from_env_store != NULL)
  801a47:	85 f6                	test   %esi,%esi
  801a49:	74 06                	je     801a51 <ipc_recv+0x4e>
			*from_env_store = 0;
  801a4b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801a51:	85 ff                	test   %edi,%edi
  801a53:	74 2d                	je     801a82 <ipc_recv+0x7f>
			*perm_store = 0;
  801a55:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801a5b:	eb 25                	jmp    801a82 <ipc_recv+0x7f>
		return r;
	}
	if(from_env_store != NULL)
  801a5d:	85 f6                	test   %esi,%esi
  801a5f:	90                   	nop
  801a60:	74 0a                	je     801a6c <ipc_recv+0x69>
		*from_env_store = thisenv->env_ipc_from;
  801a62:	a1 08 40 80 00       	mov    0x804008,%eax
  801a67:	8b 40 74             	mov    0x74(%eax),%eax
  801a6a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801a6c:	85 ff                	test   %edi,%edi
  801a6e:	74 0a                	je     801a7a <ipc_recv+0x77>
		*perm_store = thisenv->env_ipc_perm;
  801a70:	a1 08 40 80 00       	mov    0x804008,%eax
  801a75:	8b 40 78             	mov    0x78(%eax),%eax
  801a78:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801a7a:	a1 08 40 80 00       	mov    0x804008,%eax
  801a7f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  801a82:	89 d8                	mov    %ebx,%eax
  801a84:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801a87:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801a8a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801a8d:	89 ec                	mov    %ebp,%esp
  801a8f:	5d                   	pop    %ebp
  801a90:	c3                   	ret    
	...

00801aa0 <__udivdi3>:
  801aa0:	55                   	push   %ebp
  801aa1:	89 e5                	mov    %esp,%ebp
  801aa3:	57                   	push   %edi
  801aa4:	56                   	push   %esi
  801aa5:	83 ec 10             	sub    $0x10,%esp
  801aa8:	8b 45 14             	mov    0x14(%ebp),%eax
  801aab:	8b 55 08             	mov    0x8(%ebp),%edx
  801aae:	8b 75 10             	mov    0x10(%ebp),%esi
  801ab1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ab4:	85 c0                	test   %eax,%eax
  801ab6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801ab9:	75 35                	jne    801af0 <__udivdi3+0x50>
  801abb:	39 fe                	cmp    %edi,%esi
  801abd:	77 61                	ja     801b20 <__udivdi3+0x80>
  801abf:	85 f6                	test   %esi,%esi
  801ac1:	75 0b                	jne    801ace <__udivdi3+0x2e>
  801ac3:	b8 01 00 00 00       	mov    $0x1,%eax
  801ac8:	31 d2                	xor    %edx,%edx
  801aca:	f7 f6                	div    %esi
  801acc:	89 c6                	mov    %eax,%esi
  801ace:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801ad1:	31 d2                	xor    %edx,%edx
  801ad3:	89 f8                	mov    %edi,%eax
  801ad5:	f7 f6                	div    %esi
  801ad7:	89 c7                	mov    %eax,%edi
  801ad9:	89 c8                	mov    %ecx,%eax
  801adb:	f7 f6                	div    %esi
  801add:	89 c1                	mov    %eax,%ecx
  801adf:	89 fa                	mov    %edi,%edx
  801ae1:	89 c8                	mov    %ecx,%eax
  801ae3:	83 c4 10             	add    $0x10,%esp
  801ae6:	5e                   	pop    %esi
  801ae7:	5f                   	pop    %edi
  801ae8:	5d                   	pop    %ebp
  801ae9:	c3                   	ret    
  801aea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801af0:	39 f8                	cmp    %edi,%eax
  801af2:	77 1c                	ja     801b10 <__udivdi3+0x70>
  801af4:	0f bd d0             	bsr    %eax,%edx
  801af7:	83 f2 1f             	xor    $0x1f,%edx
  801afa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801afd:	75 39                	jne    801b38 <__udivdi3+0x98>
  801aff:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801b02:	0f 86 a0 00 00 00    	jbe    801ba8 <__udivdi3+0x108>
  801b08:	39 f8                	cmp    %edi,%eax
  801b0a:	0f 82 98 00 00 00    	jb     801ba8 <__udivdi3+0x108>
  801b10:	31 ff                	xor    %edi,%edi
  801b12:	31 c9                	xor    %ecx,%ecx
  801b14:	89 c8                	mov    %ecx,%eax
  801b16:	89 fa                	mov    %edi,%edx
  801b18:	83 c4 10             	add    $0x10,%esp
  801b1b:	5e                   	pop    %esi
  801b1c:	5f                   	pop    %edi
  801b1d:	5d                   	pop    %ebp
  801b1e:	c3                   	ret    
  801b1f:	90                   	nop
  801b20:	89 d1                	mov    %edx,%ecx
  801b22:	89 fa                	mov    %edi,%edx
  801b24:	89 c8                	mov    %ecx,%eax
  801b26:	31 ff                	xor    %edi,%edi
  801b28:	f7 f6                	div    %esi
  801b2a:	89 c1                	mov    %eax,%ecx
  801b2c:	89 fa                	mov    %edi,%edx
  801b2e:	89 c8                	mov    %ecx,%eax
  801b30:	83 c4 10             	add    $0x10,%esp
  801b33:	5e                   	pop    %esi
  801b34:	5f                   	pop    %edi
  801b35:	5d                   	pop    %ebp
  801b36:	c3                   	ret    
  801b37:	90                   	nop
  801b38:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b3c:	89 f2                	mov    %esi,%edx
  801b3e:	d3 e0                	shl    %cl,%eax
  801b40:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b43:	b8 20 00 00 00       	mov    $0x20,%eax
  801b48:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801b4b:	89 c1                	mov    %eax,%ecx
  801b4d:	d3 ea                	shr    %cl,%edx
  801b4f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b53:	0b 55 ec             	or     -0x14(%ebp),%edx
  801b56:	d3 e6                	shl    %cl,%esi
  801b58:	89 c1                	mov    %eax,%ecx
  801b5a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801b5d:	89 fe                	mov    %edi,%esi
  801b5f:	d3 ee                	shr    %cl,%esi
  801b61:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b65:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801b68:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b6b:	d3 e7                	shl    %cl,%edi
  801b6d:	89 c1                	mov    %eax,%ecx
  801b6f:	d3 ea                	shr    %cl,%edx
  801b71:	09 d7                	or     %edx,%edi
  801b73:	89 f2                	mov    %esi,%edx
  801b75:	89 f8                	mov    %edi,%eax
  801b77:	f7 75 ec             	divl   -0x14(%ebp)
  801b7a:	89 d6                	mov    %edx,%esi
  801b7c:	89 c7                	mov    %eax,%edi
  801b7e:	f7 65 e8             	mull   -0x18(%ebp)
  801b81:	39 d6                	cmp    %edx,%esi
  801b83:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801b86:	72 30                	jb     801bb8 <__udivdi3+0x118>
  801b88:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b8b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b8f:	d3 e2                	shl    %cl,%edx
  801b91:	39 c2                	cmp    %eax,%edx
  801b93:	73 05                	jae    801b9a <__udivdi3+0xfa>
  801b95:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801b98:	74 1e                	je     801bb8 <__udivdi3+0x118>
  801b9a:	89 f9                	mov    %edi,%ecx
  801b9c:	31 ff                	xor    %edi,%edi
  801b9e:	e9 71 ff ff ff       	jmp    801b14 <__udivdi3+0x74>
  801ba3:	90                   	nop
  801ba4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ba8:	31 ff                	xor    %edi,%edi
  801baa:	b9 01 00 00 00       	mov    $0x1,%ecx
  801baf:	e9 60 ff ff ff       	jmp    801b14 <__udivdi3+0x74>
  801bb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bb8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801bbb:	31 ff                	xor    %edi,%edi
  801bbd:	89 c8                	mov    %ecx,%eax
  801bbf:	89 fa                	mov    %edi,%edx
  801bc1:	83 c4 10             	add    $0x10,%esp
  801bc4:	5e                   	pop    %esi
  801bc5:	5f                   	pop    %edi
  801bc6:	5d                   	pop    %ebp
  801bc7:	c3                   	ret    
	...

00801bd0 <__umoddi3>:
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
  801bd3:	57                   	push   %edi
  801bd4:	56                   	push   %esi
  801bd5:	83 ec 20             	sub    $0x20,%esp
  801bd8:	8b 55 14             	mov    0x14(%ebp),%edx
  801bdb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bde:	8b 7d 10             	mov    0x10(%ebp),%edi
  801be1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801be4:	85 d2                	test   %edx,%edx
  801be6:	89 c8                	mov    %ecx,%eax
  801be8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801beb:	75 13                	jne    801c00 <__umoddi3+0x30>
  801bed:	39 f7                	cmp    %esi,%edi
  801bef:	76 3f                	jbe    801c30 <__umoddi3+0x60>
  801bf1:	89 f2                	mov    %esi,%edx
  801bf3:	f7 f7                	div    %edi
  801bf5:	89 d0                	mov    %edx,%eax
  801bf7:	31 d2                	xor    %edx,%edx
  801bf9:	83 c4 20             	add    $0x20,%esp
  801bfc:	5e                   	pop    %esi
  801bfd:	5f                   	pop    %edi
  801bfe:	5d                   	pop    %ebp
  801bff:	c3                   	ret    
  801c00:	39 f2                	cmp    %esi,%edx
  801c02:	77 4c                	ja     801c50 <__umoddi3+0x80>
  801c04:	0f bd ca             	bsr    %edx,%ecx
  801c07:	83 f1 1f             	xor    $0x1f,%ecx
  801c0a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801c0d:	75 51                	jne    801c60 <__umoddi3+0x90>
  801c0f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801c12:	0f 87 e0 00 00 00    	ja     801cf8 <__umoddi3+0x128>
  801c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1b:	29 f8                	sub    %edi,%eax
  801c1d:	19 d6                	sbb    %edx,%esi
  801c1f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c25:	89 f2                	mov    %esi,%edx
  801c27:	83 c4 20             	add    $0x20,%esp
  801c2a:	5e                   	pop    %esi
  801c2b:	5f                   	pop    %edi
  801c2c:	5d                   	pop    %ebp
  801c2d:	c3                   	ret    
  801c2e:	66 90                	xchg   %ax,%ax
  801c30:	85 ff                	test   %edi,%edi
  801c32:	75 0b                	jne    801c3f <__umoddi3+0x6f>
  801c34:	b8 01 00 00 00       	mov    $0x1,%eax
  801c39:	31 d2                	xor    %edx,%edx
  801c3b:	f7 f7                	div    %edi
  801c3d:	89 c7                	mov    %eax,%edi
  801c3f:	89 f0                	mov    %esi,%eax
  801c41:	31 d2                	xor    %edx,%edx
  801c43:	f7 f7                	div    %edi
  801c45:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c48:	f7 f7                	div    %edi
  801c4a:	eb a9                	jmp    801bf5 <__umoddi3+0x25>
  801c4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c50:	89 c8                	mov    %ecx,%eax
  801c52:	89 f2                	mov    %esi,%edx
  801c54:	83 c4 20             	add    $0x20,%esp
  801c57:	5e                   	pop    %esi
  801c58:	5f                   	pop    %edi
  801c59:	5d                   	pop    %ebp
  801c5a:	c3                   	ret    
  801c5b:	90                   	nop
  801c5c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c60:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c64:	d3 e2                	shl    %cl,%edx
  801c66:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801c69:	ba 20 00 00 00       	mov    $0x20,%edx
  801c6e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801c71:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801c74:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801c78:	89 fa                	mov    %edi,%edx
  801c7a:	d3 ea                	shr    %cl,%edx
  801c7c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c80:	0b 55 f4             	or     -0xc(%ebp),%edx
  801c83:	d3 e7                	shl    %cl,%edi
  801c85:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801c89:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801c8c:	89 f2                	mov    %esi,%edx
  801c8e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801c91:	89 c7                	mov    %eax,%edi
  801c93:	d3 ea                	shr    %cl,%edx
  801c95:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c99:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801c9c:	89 c2                	mov    %eax,%edx
  801c9e:	d3 e6                	shl    %cl,%esi
  801ca0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801ca4:	d3 ea                	shr    %cl,%edx
  801ca6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801caa:	09 d6                	or     %edx,%esi
  801cac:	89 f0                	mov    %esi,%eax
  801cae:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801cb1:	d3 e7                	shl    %cl,%edi
  801cb3:	89 f2                	mov    %esi,%edx
  801cb5:	f7 75 f4             	divl   -0xc(%ebp)
  801cb8:	89 d6                	mov    %edx,%esi
  801cba:	f7 65 e8             	mull   -0x18(%ebp)
  801cbd:	39 d6                	cmp    %edx,%esi
  801cbf:	72 2b                	jb     801cec <__umoddi3+0x11c>
  801cc1:	39 c7                	cmp    %eax,%edi
  801cc3:	72 23                	jb     801ce8 <__umoddi3+0x118>
  801cc5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801cc9:	29 c7                	sub    %eax,%edi
  801ccb:	19 d6                	sbb    %edx,%esi
  801ccd:	89 f0                	mov    %esi,%eax
  801ccf:	89 f2                	mov    %esi,%edx
  801cd1:	d3 ef                	shr    %cl,%edi
  801cd3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801cd7:	d3 e0                	shl    %cl,%eax
  801cd9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801cdd:	09 f8                	or     %edi,%eax
  801cdf:	d3 ea                	shr    %cl,%edx
  801ce1:	83 c4 20             	add    $0x20,%esp
  801ce4:	5e                   	pop    %esi
  801ce5:	5f                   	pop    %edi
  801ce6:	5d                   	pop    %ebp
  801ce7:	c3                   	ret    
  801ce8:	39 d6                	cmp    %edx,%esi
  801cea:	75 d9                	jne    801cc5 <__umoddi3+0xf5>
  801cec:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801cef:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801cf2:	eb d1                	jmp    801cc5 <__umoddi3+0xf5>
  801cf4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cf8:	39 f2                	cmp    %esi,%edx
  801cfa:	0f 82 18 ff ff ff    	jb     801c18 <__umoddi3+0x48>
  801d00:	e9 1d ff ff ff       	jmp    801c22 <__umoddi3+0x52>
