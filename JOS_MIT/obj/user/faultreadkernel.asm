
obj/user/faultreadkernel.debug:     file format elf32-i386


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
  80002c:	e8 23 00 00 00       	call   800054 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  80003a:	a1 00 00 10 f0       	mov    0xf0100000,%eax
  80003f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800043:	c7 04 24 00 1d 80 00 	movl   $0x801d00,(%esp)
  80004a:	e8 d2 00 00 00       	call   800121 <cprintf>
}
  80004f:	c9                   	leave  
  800050:	c3                   	ret    
  800051:	00 00                	add    %al,(%eax)
	...

00800054 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800054:	55                   	push   %ebp
  800055:	89 e5                	mov    %esp,%ebp
  800057:	83 ec 18             	sub    $0x18,%esp
  80005a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80005d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800060:	8b 75 08             	mov    0x8(%ebp),%esi
  800063:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  800066:	e8 89 0e 00 00       	call   800ef4 <sys_getenvid>
  80006b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800070:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800073:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800078:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007d:	85 f6                	test   %esi,%esi
  80007f:	7e 07                	jle    800088 <libmain+0x34>
		binaryname = argv[0];
  800081:	8b 03                	mov    (%ebx),%eax
  800083:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800088:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80008c:	89 34 24             	mov    %esi,(%esp)
  80008f:	e8 a0 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800094:	e8 0b 00 00 00       	call   8000a4 <exit>
}
  800099:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80009c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80009f:	89 ec                	mov    %ebp,%esp
  8000a1:	5d                   	pop    %ebp
  8000a2:	c3                   	ret    
	...

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000aa:	e8 1a 14 00 00       	call   8014c9 <close_all>
	sys_env_destroy(0);
  8000af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b6:	e8 74 0e 00 00       	call   800f2f <sys_env_destroy>
}
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    
  8000bd:	00 00                	add    %al,(%eax)
	...

008000c0 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000c9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000d0:	00 00 00 
	b.cnt = 0;
  8000d3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000da:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000e0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8000e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000eb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8000f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f5:	c7 04 24 3b 01 80 00 	movl   $0x80013b,(%esp)
  8000fc:	e8 cc 01 00 00       	call   8002cd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800101:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800107:	89 44 24 04          	mov    %eax,0x4(%esp)
  80010b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800111:	89 04 24             	mov    %eax,(%esp)
  800114:	e8 8a 0e 00 00       	call   800fa3 <sys_cputs>

	return b.cnt;
}
  800119:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80011f:	c9                   	leave  
  800120:	c3                   	ret    

00800121 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800127:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80012a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80012e:	8b 45 08             	mov    0x8(%ebp),%eax
  800131:	89 04 24             	mov    %eax,(%esp)
  800134:	e8 87 ff ff ff       	call   8000c0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800139:	c9                   	leave  
  80013a:	c3                   	ret    

0080013b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80013b:	55                   	push   %ebp
  80013c:	89 e5                	mov    %esp,%ebp
  80013e:	53                   	push   %ebx
  80013f:	83 ec 14             	sub    $0x14,%esp
  800142:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800145:	8b 03                	mov    (%ebx),%eax
  800147:	8b 55 08             	mov    0x8(%ebp),%edx
  80014a:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80014e:	83 c0 01             	add    $0x1,%eax
  800151:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800153:	3d ff 00 00 00       	cmp    $0xff,%eax
  800158:	75 19                	jne    800173 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80015a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800161:	00 
  800162:	8d 43 08             	lea    0x8(%ebx),%eax
  800165:	89 04 24             	mov    %eax,(%esp)
  800168:	e8 36 0e 00 00       	call   800fa3 <sys_cputs>
		b->idx = 0;
  80016d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800173:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800177:	83 c4 14             	add    $0x14,%esp
  80017a:	5b                   	pop    %ebx
  80017b:	5d                   	pop    %ebp
  80017c:	c3                   	ret    
  80017d:	00 00                	add    %al,(%eax)
	...

00800180 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	57                   	push   %edi
  800184:	56                   	push   %esi
  800185:	53                   	push   %ebx
  800186:	83 ec 4c             	sub    $0x4c,%esp
  800189:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80018c:	89 d6                	mov    %edx,%esi
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800194:	8b 55 0c             	mov    0xc(%ebp),%edx
  800197:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80019a:	8b 45 10             	mov    0x10(%ebp),%eax
  80019d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001a0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001ab:	39 d1                	cmp    %edx,%ecx
  8001ad:	72 15                	jb     8001c4 <printnum+0x44>
  8001af:	77 07                	ja     8001b8 <printnum+0x38>
  8001b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001b4:	39 d0                	cmp    %edx,%eax
  8001b6:	76 0c                	jbe    8001c4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001b8:	83 eb 01             	sub    $0x1,%ebx
  8001bb:	85 db                	test   %ebx,%ebx
  8001bd:	8d 76 00             	lea    0x0(%esi),%esi
  8001c0:	7f 61                	jg     800223 <printnum+0xa3>
  8001c2:	eb 70                	jmp    800234 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001c8:	83 eb 01             	sub    $0x1,%ebx
  8001cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8001d7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8001db:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8001de:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8001e1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8001e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001ef:	00 
  8001f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8001f3:	89 04 24             	mov    %eax,(%esp)
  8001f6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8001f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001fd:	e8 7e 18 00 00       	call   801a80 <__udivdi3>
  800202:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800205:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800208:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80020c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800210:	89 04 24             	mov    %eax,(%esp)
  800213:	89 54 24 04          	mov    %edx,0x4(%esp)
  800217:	89 f2                	mov    %esi,%edx
  800219:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80021c:	e8 5f ff ff ff       	call   800180 <printnum>
  800221:	eb 11                	jmp    800234 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800223:	89 74 24 04          	mov    %esi,0x4(%esp)
  800227:	89 3c 24             	mov    %edi,(%esp)
  80022a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80022d:	83 eb 01             	sub    $0x1,%ebx
  800230:	85 db                	test   %ebx,%ebx
  800232:	7f ef                	jg     800223 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800234:	89 74 24 04          	mov    %esi,0x4(%esp)
  800238:	8b 74 24 04          	mov    0x4(%esp),%esi
  80023c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80023f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800243:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80024a:	00 
  80024b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80024e:	89 14 24             	mov    %edx,(%esp)
  800251:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800254:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800258:	e8 53 19 00 00       	call   801bb0 <__umoddi3>
  80025d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800261:	0f be 80 31 1d 80 00 	movsbl 0x801d31(%eax),%eax
  800268:	89 04 24             	mov    %eax,(%esp)
  80026b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80026e:	83 c4 4c             	add    $0x4c,%esp
  800271:	5b                   	pop    %ebx
  800272:	5e                   	pop    %esi
  800273:	5f                   	pop    %edi
  800274:	5d                   	pop    %ebp
  800275:	c3                   	ret    

00800276 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800276:	55                   	push   %ebp
  800277:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800279:	83 fa 01             	cmp    $0x1,%edx
  80027c:	7e 0e                	jle    80028c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027e:	8b 10                	mov    (%eax),%edx
  800280:	8d 4a 08             	lea    0x8(%edx),%ecx
  800283:	89 08                	mov    %ecx,(%eax)
  800285:	8b 02                	mov    (%edx),%eax
  800287:	8b 52 04             	mov    0x4(%edx),%edx
  80028a:	eb 22                	jmp    8002ae <getuint+0x38>
	else if (lflag)
  80028c:	85 d2                	test   %edx,%edx
  80028e:	74 10                	je     8002a0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800290:	8b 10                	mov    (%eax),%edx
  800292:	8d 4a 04             	lea    0x4(%edx),%ecx
  800295:	89 08                	mov    %ecx,(%eax)
  800297:	8b 02                	mov    (%edx),%eax
  800299:	ba 00 00 00 00       	mov    $0x0,%edx
  80029e:	eb 0e                	jmp    8002ae <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a0:	8b 10                	mov    (%eax),%edx
  8002a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a5:	89 08                	mov    %ecx,(%eax)
  8002a7:	8b 02                	mov    (%edx),%eax
  8002a9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ae:	5d                   	pop    %ebp
  8002af:	c3                   	ret    

008002b0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ba:	8b 10                	mov    (%eax),%edx
  8002bc:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bf:	73 0a                	jae    8002cb <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c4:	88 0a                	mov    %cl,(%edx)
  8002c6:	83 c2 01             	add    $0x1,%edx
  8002c9:	89 10                	mov    %edx,(%eax)
}
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    

008002cd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	57                   	push   %edi
  8002d1:	56                   	push   %esi
  8002d2:	53                   	push   %ebx
  8002d3:	83 ec 5c             	sub    $0x5c,%esp
  8002d6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002d9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8002df:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002e6:	eb 11                	jmp    8002f9 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e8:	85 c0                	test   %eax,%eax
  8002ea:	0f 84 68 04 00 00    	je     800758 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  8002f0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002f4:	89 04 24             	mov    %eax,(%esp)
  8002f7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f9:	0f b6 03             	movzbl (%ebx),%eax
  8002fc:	83 c3 01             	add    $0x1,%ebx
  8002ff:	83 f8 25             	cmp    $0x25,%eax
  800302:	75 e4                	jne    8002e8 <vprintfmt+0x1b>
  800304:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80030b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800312:	b9 00 00 00 00       	mov    $0x0,%ecx
  800317:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  80031b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800322:	eb 06                	jmp    80032a <vprintfmt+0x5d>
  800324:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  800328:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032a:	0f b6 13             	movzbl (%ebx),%edx
  80032d:	0f b6 c2             	movzbl %dl,%eax
  800330:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800333:	8d 43 01             	lea    0x1(%ebx),%eax
  800336:	83 ea 23             	sub    $0x23,%edx
  800339:	80 fa 55             	cmp    $0x55,%dl
  80033c:	0f 87 f9 03 00 00    	ja     80073b <vprintfmt+0x46e>
  800342:	0f b6 d2             	movzbl %dl,%edx
  800345:	ff 24 95 00 1f 80 00 	jmp    *0x801f00(,%edx,4)
  80034c:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800350:	eb d6                	jmp    800328 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800352:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800355:	83 ea 30             	sub    $0x30,%edx
  800358:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80035b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80035e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800361:	83 fb 09             	cmp    $0x9,%ebx
  800364:	77 54                	ja     8003ba <vprintfmt+0xed>
  800366:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800369:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80036c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80036f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800372:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800376:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800379:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80037c:	83 fb 09             	cmp    $0x9,%ebx
  80037f:	76 eb                	jbe    80036c <vprintfmt+0x9f>
  800381:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800384:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800387:	eb 31                	jmp    8003ba <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800389:	8b 55 14             	mov    0x14(%ebp),%edx
  80038c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80038f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800392:	8b 12                	mov    (%edx),%edx
  800394:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800397:	eb 21                	jmp    8003ba <vprintfmt+0xed>

		case '.':
			if (width < 0)
  800399:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80039d:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a2:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  8003a6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003a9:	e9 7a ff ff ff       	jmp    800328 <vprintfmt+0x5b>
  8003ae:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003b5:	e9 6e ff ff ff       	jmp    800328 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8003ba:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003be:	0f 89 64 ff ff ff    	jns    800328 <vprintfmt+0x5b>
  8003c4:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8003c7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003ca:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8003cd:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8003d0:	e9 53 ff ff ff       	jmp    800328 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d5:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8003d8:	e9 4b ff ff ff       	jmp    800328 <vprintfmt+0x5b>
  8003dd:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e3:	8d 50 04             	lea    0x4(%eax),%edx
  8003e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003ed:	8b 00                	mov    (%eax),%eax
  8003ef:	89 04 24             	mov    %eax,(%esp)
  8003f2:	ff d7                	call   *%edi
  8003f4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8003f7:	e9 fd fe ff ff       	jmp    8002f9 <vprintfmt+0x2c>
  8003fc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800402:	8d 50 04             	lea    0x4(%eax),%edx
  800405:	89 55 14             	mov    %edx,0x14(%ebp)
  800408:	8b 00                	mov    (%eax),%eax
  80040a:	89 c2                	mov    %eax,%edx
  80040c:	c1 fa 1f             	sar    $0x1f,%edx
  80040f:	31 d0                	xor    %edx,%eax
  800411:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800413:	83 f8 0f             	cmp    $0xf,%eax
  800416:	7f 0b                	jg     800423 <vprintfmt+0x156>
  800418:	8b 14 85 60 20 80 00 	mov    0x802060(,%eax,4),%edx
  80041f:	85 d2                	test   %edx,%edx
  800421:	75 20                	jne    800443 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800423:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800427:	c7 44 24 08 42 1d 80 	movl   $0x801d42,0x8(%esp)
  80042e:	00 
  80042f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800433:	89 3c 24             	mov    %edi,(%esp)
  800436:	e8 a5 03 00 00       	call   8007e0 <printfmt>
  80043b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80043e:	e9 b6 fe ff ff       	jmp    8002f9 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800443:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800447:	c7 44 24 08 77 21 80 	movl   $0x802177,0x8(%esp)
  80044e:	00 
  80044f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800453:	89 3c 24             	mov    %edi,(%esp)
  800456:	e8 85 03 00 00       	call   8007e0 <printfmt>
  80045b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80045e:	e9 96 fe ff ff       	jmp    8002f9 <vprintfmt+0x2c>
  800463:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800466:	89 c3                	mov    %eax,%ebx
  800468:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80046b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80046e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800471:	8b 45 14             	mov    0x14(%ebp),%eax
  800474:	8d 50 04             	lea    0x4(%eax),%edx
  800477:	89 55 14             	mov    %edx,0x14(%ebp)
  80047a:	8b 00                	mov    (%eax),%eax
  80047c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80047f:	85 c0                	test   %eax,%eax
  800481:	b8 4b 1d 80 00       	mov    $0x801d4b,%eax
  800486:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  80048a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80048d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800491:	7e 06                	jle    800499 <vprintfmt+0x1cc>
  800493:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800497:	75 13                	jne    8004ac <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800499:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80049c:	0f be 02             	movsbl (%edx),%eax
  80049f:	85 c0                	test   %eax,%eax
  8004a1:	0f 85 a2 00 00 00    	jne    800549 <vprintfmt+0x27c>
  8004a7:	e9 8f 00 00 00       	jmp    80053b <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ac:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004b0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004b3:	89 0c 24             	mov    %ecx,(%esp)
  8004b6:	e8 70 03 00 00       	call   80082b <strnlen>
  8004bb:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004be:	29 c2                	sub    %eax,%edx
  8004c0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004c3:	85 d2                	test   %edx,%edx
  8004c5:	7e d2                	jle    800499 <vprintfmt+0x1cc>
					putch(padc, putdat);
  8004c7:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8004cb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004ce:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  8004d1:	89 d3                	mov    %edx,%ebx
  8004d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004da:	89 04 24             	mov    %eax,(%esp)
  8004dd:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004df:	83 eb 01             	sub    $0x1,%ebx
  8004e2:	85 db                	test   %ebx,%ebx
  8004e4:	7f ed                	jg     8004d3 <vprintfmt+0x206>
  8004e6:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8004e9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8004f0:	eb a7                	jmp    800499 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004f2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004f6:	74 1b                	je     800513 <vprintfmt+0x246>
  8004f8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004fb:	83 fa 5e             	cmp    $0x5e,%edx
  8004fe:	76 13                	jbe    800513 <vprintfmt+0x246>
					putch('?', putdat);
  800500:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800503:	89 54 24 04          	mov    %edx,0x4(%esp)
  800507:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80050e:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800511:	eb 0d                	jmp    800520 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800513:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800516:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80051a:	89 04 24             	mov    %eax,(%esp)
  80051d:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800520:	83 ef 01             	sub    $0x1,%edi
  800523:	0f be 03             	movsbl (%ebx),%eax
  800526:	85 c0                	test   %eax,%eax
  800528:	74 05                	je     80052f <vprintfmt+0x262>
  80052a:	83 c3 01             	add    $0x1,%ebx
  80052d:	eb 31                	jmp    800560 <vprintfmt+0x293>
  80052f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800532:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800535:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800538:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80053b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80053f:	7f 36                	jg     800577 <vprintfmt+0x2aa>
  800541:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800544:	e9 b0 fd ff ff       	jmp    8002f9 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800549:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80054c:	83 c2 01             	add    $0x1,%edx
  80054f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800552:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800555:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800558:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80055b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80055e:	89 d3                	mov    %edx,%ebx
  800560:	85 f6                	test   %esi,%esi
  800562:	78 8e                	js     8004f2 <vprintfmt+0x225>
  800564:	83 ee 01             	sub    $0x1,%esi
  800567:	79 89                	jns    8004f2 <vprintfmt+0x225>
  800569:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80056c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800572:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800575:	eb c4                	jmp    80053b <vprintfmt+0x26e>
  800577:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80057a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80057d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800581:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800588:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058a:	83 eb 01             	sub    $0x1,%ebx
  80058d:	85 db                	test   %ebx,%ebx
  80058f:	7f ec                	jg     80057d <vprintfmt+0x2b0>
  800591:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800594:	e9 60 fd ff ff       	jmp    8002f9 <vprintfmt+0x2c>
  800599:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80059c:	83 f9 01             	cmp    $0x1,%ecx
  80059f:	7e 16                	jle    8005b7 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  8005a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a4:	8d 50 08             	lea    0x8(%eax),%edx
  8005a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005aa:	8b 10                	mov    (%eax),%edx
  8005ac:	8b 48 04             	mov    0x4(%eax),%ecx
  8005af:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005b2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005b5:	eb 32                	jmp    8005e9 <vprintfmt+0x31c>
	else if (lflag)
  8005b7:	85 c9                	test   %ecx,%ecx
  8005b9:	74 18                	je     8005d3 <vprintfmt+0x306>
		return va_arg(*ap, long);
  8005bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005be:	8d 50 04             	lea    0x4(%eax),%edx
  8005c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c4:	8b 00                	mov    (%eax),%eax
  8005c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c9:	89 c1                	mov    %eax,%ecx
  8005cb:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ce:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005d1:	eb 16                	jmp    8005e9 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  8005d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d6:	8d 50 04             	lea    0x4(%eax),%edx
  8005d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005dc:	8b 00                	mov    (%eax),%eax
  8005de:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005e1:	89 c2                	mov    %eax,%edx
  8005e3:	c1 fa 1f             	sar    $0x1f,%edx
  8005e6:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005e9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005ec:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005ef:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  8005f4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005f8:	0f 89 8a 00 00 00    	jns    800688 <vprintfmt+0x3bb>
				putch('-', putdat);
  8005fe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800602:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800609:	ff d7                	call   *%edi
				num = -(long long) num;
  80060b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80060e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800611:	f7 d8                	neg    %eax
  800613:	83 d2 00             	adc    $0x0,%edx
  800616:	f7 da                	neg    %edx
  800618:	eb 6e                	jmp    800688 <vprintfmt+0x3bb>
  80061a:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80061d:	89 ca                	mov    %ecx,%edx
  80061f:	8d 45 14             	lea    0x14(%ebp),%eax
  800622:	e8 4f fc ff ff       	call   800276 <getuint>
  800627:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  80062c:	eb 5a                	jmp    800688 <vprintfmt+0x3bb>
  80062e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800631:	89 ca                	mov    %ecx,%edx
  800633:	8d 45 14             	lea    0x14(%ebp),%eax
  800636:	e8 3b fc ff ff       	call   800276 <getuint>
  80063b:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  800640:	eb 46                	jmp    800688 <vprintfmt+0x3bb>
  800642:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  800645:	89 74 24 04          	mov    %esi,0x4(%esp)
  800649:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800650:	ff d7                	call   *%edi
			putch('x', putdat);
  800652:	89 74 24 04          	mov    %esi,0x4(%esp)
  800656:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80065d:	ff d7                	call   *%edi
			num = (unsigned long long)
  80065f:	8b 45 14             	mov    0x14(%ebp),%eax
  800662:	8d 50 04             	lea    0x4(%eax),%edx
  800665:	89 55 14             	mov    %edx,0x14(%ebp)
  800668:	8b 00                	mov    (%eax),%eax
  80066a:	ba 00 00 00 00       	mov    $0x0,%edx
  80066f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800674:	eb 12                	jmp    800688 <vprintfmt+0x3bb>
  800676:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800679:	89 ca                	mov    %ecx,%edx
  80067b:	8d 45 14             	lea    0x14(%ebp),%eax
  80067e:	e8 f3 fb ff ff       	call   800276 <getuint>
  800683:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800688:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80068c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800690:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800693:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800697:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80069b:	89 04 24             	mov    %eax,(%esp)
  80069e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006a2:	89 f2                	mov    %esi,%edx
  8006a4:	89 f8                	mov    %edi,%eax
  8006a6:	e8 d5 fa ff ff       	call   800180 <printnum>
  8006ab:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8006ae:	e9 46 fc ff ff       	jmp    8002f9 <vprintfmt+0x2c>
  8006b3:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  8006b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b9:	8d 50 04             	lea    0x4(%eax),%edx
  8006bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bf:	8b 00                	mov    (%eax),%eax
  8006c1:	85 c0                	test   %eax,%eax
  8006c3:	75 24                	jne    8006e9 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  8006c5:	c7 44 24 0c 64 1e 80 	movl   $0x801e64,0xc(%esp)
  8006cc:	00 
  8006cd:	c7 44 24 08 77 21 80 	movl   $0x802177,0x8(%esp)
  8006d4:	00 
  8006d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d9:	89 3c 24             	mov    %edi,(%esp)
  8006dc:	e8 ff 00 00 00       	call   8007e0 <printfmt>
  8006e1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8006e4:	e9 10 fc ff ff       	jmp    8002f9 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  8006e9:	83 3e 7f             	cmpl   $0x7f,(%esi)
  8006ec:	7e 29                	jle    800717 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  8006ee:	0f b6 16             	movzbl (%esi),%edx
  8006f1:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  8006f3:	c7 44 24 0c 9c 1e 80 	movl   $0x801e9c,0xc(%esp)
  8006fa:	00 
  8006fb:	c7 44 24 08 77 21 80 	movl   $0x802177,0x8(%esp)
  800702:	00 
  800703:	89 74 24 04          	mov    %esi,0x4(%esp)
  800707:	89 3c 24             	mov    %edi,(%esp)
  80070a:	e8 d1 00 00 00       	call   8007e0 <printfmt>
  80070f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800712:	e9 e2 fb ff ff       	jmp    8002f9 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  800717:	0f b6 16             	movzbl (%esi),%edx
  80071a:	88 10                	mov    %dl,(%eax)
  80071c:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  80071f:	e9 d5 fb ff ff       	jmp    8002f9 <vprintfmt+0x2c>
  800724:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800727:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80072a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80072e:	89 14 24             	mov    %edx,(%esp)
  800731:	ff d7                	call   *%edi
  800733:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800736:	e9 be fb ff ff       	jmp    8002f9 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80073b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80073f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800746:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800748:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80074b:	80 38 25             	cmpb   $0x25,(%eax)
  80074e:	0f 84 a5 fb ff ff    	je     8002f9 <vprintfmt+0x2c>
  800754:	89 c3                	mov    %eax,%ebx
  800756:	eb f0                	jmp    800748 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  800758:	83 c4 5c             	add    $0x5c,%esp
  80075b:	5b                   	pop    %ebx
  80075c:	5e                   	pop    %esi
  80075d:	5f                   	pop    %edi
  80075e:	5d                   	pop    %ebp
  80075f:	c3                   	ret    

00800760 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800760:	55                   	push   %ebp
  800761:	89 e5                	mov    %esp,%ebp
  800763:	83 ec 28             	sub    $0x28,%esp
  800766:	8b 45 08             	mov    0x8(%ebp),%eax
  800769:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80076c:	85 c0                	test   %eax,%eax
  80076e:	74 04                	je     800774 <vsnprintf+0x14>
  800770:	85 d2                	test   %edx,%edx
  800772:	7f 07                	jg     80077b <vsnprintf+0x1b>
  800774:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800779:	eb 3b                	jmp    8007b6 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80077b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80077e:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800782:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800785:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80078c:	8b 45 14             	mov    0x14(%ebp),%eax
  80078f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800793:	8b 45 10             	mov    0x10(%ebp),%eax
  800796:	89 44 24 08          	mov    %eax,0x8(%esp)
  80079a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80079d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a1:	c7 04 24 b0 02 80 00 	movl   $0x8002b0,(%esp)
  8007a8:	e8 20 fb ff ff       	call   8002cd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007b6:	c9                   	leave  
  8007b7:	c3                   	ret    

008007b8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8007be:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8007c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d6:	89 04 24             	mov    %eax,(%esp)
  8007d9:	e8 82 ff ff ff       	call   800760 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007de:	c9                   	leave  
  8007df:	c3                   	ret    

008007e0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8007e6:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8007e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fe:	89 04 24             	mov    %eax,(%esp)
  800801:	e8 c7 fa ff ff       	call   8002cd <vprintfmt>
	va_end(ap);
}
  800806:	c9                   	leave  
  800807:	c3                   	ret    
	...

00800810 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800816:	b8 00 00 00 00       	mov    $0x0,%eax
  80081b:	80 3a 00             	cmpb   $0x0,(%edx)
  80081e:	74 09                	je     800829 <strlen+0x19>
		n++;
  800820:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800823:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800827:	75 f7                	jne    800820 <strlen+0x10>
		n++;
	return n;
}
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	53                   	push   %ebx
  80082f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800832:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800835:	85 c9                	test   %ecx,%ecx
  800837:	74 19                	je     800852 <strnlen+0x27>
  800839:	80 3b 00             	cmpb   $0x0,(%ebx)
  80083c:	74 14                	je     800852 <strnlen+0x27>
  80083e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800843:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800846:	39 c8                	cmp    %ecx,%eax
  800848:	74 0d                	je     800857 <strnlen+0x2c>
  80084a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80084e:	75 f3                	jne    800843 <strnlen+0x18>
  800850:	eb 05                	jmp    800857 <strnlen+0x2c>
  800852:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800857:	5b                   	pop    %ebx
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	53                   	push   %ebx
  80085e:	8b 45 08             	mov    0x8(%ebp),%eax
  800861:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800864:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800869:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80086d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800870:	83 c2 01             	add    $0x1,%edx
  800873:	84 c9                	test   %cl,%cl
  800875:	75 f2                	jne    800869 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800877:	5b                   	pop    %ebx
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	53                   	push   %ebx
  80087e:	83 ec 08             	sub    $0x8,%esp
  800881:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800884:	89 1c 24             	mov    %ebx,(%esp)
  800887:	e8 84 ff ff ff       	call   800810 <strlen>
	strcpy(dst + len, src);
  80088c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800893:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800896:	89 04 24             	mov    %eax,(%esp)
  800899:	e8 bc ff ff ff       	call   80085a <strcpy>
	return dst;
}
  80089e:	89 d8                	mov    %ebx,%eax
  8008a0:	83 c4 08             	add    $0x8,%esp
  8008a3:	5b                   	pop    %ebx
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	56                   	push   %esi
  8008aa:	53                   	push   %ebx
  8008ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b4:	85 f6                	test   %esi,%esi
  8008b6:	74 18                	je     8008d0 <strncpy+0x2a>
  8008b8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008bd:	0f b6 1a             	movzbl (%edx),%ebx
  8008c0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008c3:	80 3a 01             	cmpb   $0x1,(%edx)
  8008c6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c9:	83 c1 01             	add    $0x1,%ecx
  8008cc:	39 ce                	cmp    %ecx,%esi
  8008ce:	77 ed                	ja     8008bd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008d0:	5b                   	pop    %ebx
  8008d1:	5e                   	pop    %esi
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	56                   	push   %esi
  8008d8:	53                   	push   %ebx
  8008d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e2:	89 f0                	mov    %esi,%eax
  8008e4:	85 c9                	test   %ecx,%ecx
  8008e6:	74 27                	je     80090f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8008e8:	83 e9 01             	sub    $0x1,%ecx
  8008eb:	74 1d                	je     80090a <strlcpy+0x36>
  8008ed:	0f b6 1a             	movzbl (%edx),%ebx
  8008f0:	84 db                	test   %bl,%bl
  8008f2:	74 16                	je     80090a <strlcpy+0x36>
			*dst++ = *src++;
  8008f4:	88 18                	mov    %bl,(%eax)
  8008f6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008f9:	83 e9 01             	sub    $0x1,%ecx
  8008fc:	74 0e                	je     80090c <strlcpy+0x38>
			*dst++ = *src++;
  8008fe:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800901:	0f b6 1a             	movzbl (%edx),%ebx
  800904:	84 db                	test   %bl,%bl
  800906:	75 ec                	jne    8008f4 <strlcpy+0x20>
  800908:	eb 02                	jmp    80090c <strlcpy+0x38>
  80090a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80090c:	c6 00 00             	movb   $0x0,(%eax)
  80090f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800911:	5b                   	pop    %ebx
  800912:	5e                   	pop    %esi
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80091e:	0f b6 01             	movzbl (%ecx),%eax
  800921:	84 c0                	test   %al,%al
  800923:	74 15                	je     80093a <strcmp+0x25>
  800925:	3a 02                	cmp    (%edx),%al
  800927:	75 11                	jne    80093a <strcmp+0x25>
		p++, q++;
  800929:	83 c1 01             	add    $0x1,%ecx
  80092c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80092f:	0f b6 01             	movzbl (%ecx),%eax
  800932:	84 c0                	test   %al,%al
  800934:	74 04                	je     80093a <strcmp+0x25>
  800936:	3a 02                	cmp    (%edx),%al
  800938:	74 ef                	je     800929 <strcmp+0x14>
  80093a:	0f b6 c0             	movzbl %al,%eax
  80093d:	0f b6 12             	movzbl (%edx),%edx
  800940:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	53                   	push   %ebx
  800948:	8b 55 08             	mov    0x8(%ebp),%edx
  80094b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80094e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800951:	85 c0                	test   %eax,%eax
  800953:	74 23                	je     800978 <strncmp+0x34>
  800955:	0f b6 1a             	movzbl (%edx),%ebx
  800958:	84 db                	test   %bl,%bl
  80095a:	74 25                	je     800981 <strncmp+0x3d>
  80095c:	3a 19                	cmp    (%ecx),%bl
  80095e:	75 21                	jne    800981 <strncmp+0x3d>
  800960:	83 e8 01             	sub    $0x1,%eax
  800963:	74 13                	je     800978 <strncmp+0x34>
		n--, p++, q++;
  800965:	83 c2 01             	add    $0x1,%edx
  800968:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80096b:	0f b6 1a             	movzbl (%edx),%ebx
  80096e:	84 db                	test   %bl,%bl
  800970:	74 0f                	je     800981 <strncmp+0x3d>
  800972:	3a 19                	cmp    (%ecx),%bl
  800974:	74 ea                	je     800960 <strncmp+0x1c>
  800976:	eb 09                	jmp    800981 <strncmp+0x3d>
  800978:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80097d:	5b                   	pop    %ebx
  80097e:	5d                   	pop    %ebp
  80097f:	90                   	nop
  800980:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800981:	0f b6 02             	movzbl (%edx),%eax
  800984:	0f b6 11             	movzbl (%ecx),%edx
  800987:	29 d0                	sub    %edx,%eax
  800989:	eb f2                	jmp    80097d <strncmp+0x39>

0080098b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800995:	0f b6 10             	movzbl (%eax),%edx
  800998:	84 d2                	test   %dl,%dl
  80099a:	74 18                	je     8009b4 <strchr+0x29>
		if (*s == c)
  80099c:	38 ca                	cmp    %cl,%dl
  80099e:	75 0a                	jne    8009aa <strchr+0x1f>
  8009a0:	eb 17                	jmp    8009b9 <strchr+0x2e>
  8009a2:	38 ca                	cmp    %cl,%dl
  8009a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009a8:	74 0f                	je     8009b9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009aa:	83 c0 01             	add    $0x1,%eax
  8009ad:	0f b6 10             	movzbl (%eax),%edx
  8009b0:	84 d2                	test   %dl,%dl
  8009b2:	75 ee                	jne    8009a2 <strchr+0x17>
  8009b4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c5:	0f b6 10             	movzbl (%eax),%edx
  8009c8:	84 d2                	test   %dl,%dl
  8009ca:	74 18                	je     8009e4 <strfind+0x29>
		if (*s == c)
  8009cc:	38 ca                	cmp    %cl,%dl
  8009ce:	75 0a                	jne    8009da <strfind+0x1f>
  8009d0:	eb 12                	jmp    8009e4 <strfind+0x29>
  8009d2:	38 ca                	cmp    %cl,%dl
  8009d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009d8:	74 0a                	je     8009e4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009da:	83 c0 01             	add    $0x1,%eax
  8009dd:	0f b6 10             	movzbl (%eax),%edx
  8009e0:	84 d2                	test   %dl,%dl
  8009e2:	75 ee                	jne    8009d2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	83 ec 0c             	sub    $0xc,%esp
  8009ec:	89 1c 24             	mov    %ebx,(%esp)
  8009ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009f3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8009f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a00:	85 c9                	test   %ecx,%ecx
  800a02:	74 30                	je     800a34 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a04:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a0a:	75 25                	jne    800a31 <memset+0x4b>
  800a0c:	f6 c1 03             	test   $0x3,%cl
  800a0f:	75 20                	jne    800a31 <memset+0x4b>
		c &= 0xFF;
  800a11:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a14:	89 d3                	mov    %edx,%ebx
  800a16:	c1 e3 08             	shl    $0x8,%ebx
  800a19:	89 d6                	mov    %edx,%esi
  800a1b:	c1 e6 18             	shl    $0x18,%esi
  800a1e:	89 d0                	mov    %edx,%eax
  800a20:	c1 e0 10             	shl    $0x10,%eax
  800a23:	09 f0                	or     %esi,%eax
  800a25:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800a27:	09 d8                	or     %ebx,%eax
  800a29:	c1 e9 02             	shr    $0x2,%ecx
  800a2c:	fc                   	cld    
  800a2d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a2f:	eb 03                	jmp    800a34 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a31:	fc                   	cld    
  800a32:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a34:	89 f8                	mov    %edi,%eax
  800a36:	8b 1c 24             	mov    (%esp),%ebx
  800a39:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a3d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a41:	89 ec                	mov    %ebp,%esp
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    

00800a45 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	83 ec 08             	sub    $0x8,%esp
  800a4b:	89 34 24             	mov    %esi,(%esp)
  800a4e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a52:	8b 45 08             	mov    0x8(%ebp),%eax
  800a55:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800a58:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a5b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a5d:	39 c6                	cmp    %eax,%esi
  800a5f:	73 35                	jae    800a96 <memmove+0x51>
  800a61:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a64:	39 d0                	cmp    %edx,%eax
  800a66:	73 2e                	jae    800a96 <memmove+0x51>
		s += n;
		d += n;
  800a68:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6a:	f6 c2 03             	test   $0x3,%dl
  800a6d:	75 1b                	jne    800a8a <memmove+0x45>
  800a6f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a75:	75 13                	jne    800a8a <memmove+0x45>
  800a77:	f6 c1 03             	test   $0x3,%cl
  800a7a:	75 0e                	jne    800a8a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800a7c:	83 ef 04             	sub    $0x4,%edi
  800a7f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a82:	c1 e9 02             	shr    $0x2,%ecx
  800a85:	fd                   	std    
  800a86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a88:	eb 09                	jmp    800a93 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a8a:	83 ef 01             	sub    $0x1,%edi
  800a8d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a90:	fd                   	std    
  800a91:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a93:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a94:	eb 20                	jmp    800ab6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a96:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a9c:	75 15                	jne    800ab3 <memmove+0x6e>
  800a9e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aa4:	75 0d                	jne    800ab3 <memmove+0x6e>
  800aa6:	f6 c1 03             	test   $0x3,%cl
  800aa9:	75 08                	jne    800ab3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800aab:	c1 e9 02             	shr    $0x2,%ecx
  800aae:	fc                   	cld    
  800aaf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab1:	eb 03                	jmp    800ab6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ab3:	fc                   	cld    
  800ab4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ab6:	8b 34 24             	mov    (%esp),%esi
  800ab9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800abd:	89 ec                	mov    %ebp,%esp
  800abf:	5d                   	pop    %ebp
  800ac0:	c3                   	ret    

00800ac1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ac7:	8b 45 10             	mov    0x10(%ebp),%eax
  800aca:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ace:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad8:	89 04 24             	mov    %eax,(%esp)
  800adb:	e8 65 ff ff ff       	call   800a45 <memmove>
}
  800ae0:	c9                   	leave  
  800ae1:	c3                   	ret    

00800ae2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	57                   	push   %edi
  800ae6:	56                   	push   %esi
  800ae7:	53                   	push   %ebx
  800ae8:	8b 75 08             	mov    0x8(%ebp),%esi
  800aeb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800aee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af1:	85 c9                	test   %ecx,%ecx
  800af3:	74 36                	je     800b2b <memcmp+0x49>
		if (*s1 != *s2)
  800af5:	0f b6 06             	movzbl (%esi),%eax
  800af8:	0f b6 1f             	movzbl (%edi),%ebx
  800afb:	38 d8                	cmp    %bl,%al
  800afd:	74 20                	je     800b1f <memcmp+0x3d>
  800aff:	eb 14                	jmp    800b15 <memcmp+0x33>
  800b01:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800b06:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800b0b:	83 c2 01             	add    $0x1,%edx
  800b0e:	83 e9 01             	sub    $0x1,%ecx
  800b11:	38 d8                	cmp    %bl,%al
  800b13:	74 12                	je     800b27 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800b15:	0f b6 c0             	movzbl %al,%eax
  800b18:	0f b6 db             	movzbl %bl,%ebx
  800b1b:	29 d8                	sub    %ebx,%eax
  800b1d:	eb 11                	jmp    800b30 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b1f:	83 e9 01             	sub    $0x1,%ecx
  800b22:	ba 00 00 00 00       	mov    $0x0,%edx
  800b27:	85 c9                	test   %ecx,%ecx
  800b29:	75 d6                	jne    800b01 <memcmp+0x1f>
  800b2b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5f                   	pop    %edi
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b3b:	89 c2                	mov    %eax,%edx
  800b3d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b40:	39 d0                	cmp    %edx,%eax
  800b42:	73 15                	jae    800b59 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b44:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b48:	38 08                	cmp    %cl,(%eax)
  800b4a:	75 06                	jne    800b52 <memfind+0x1d>
  800b4c:	eb 0b                	jmp    800b59 <memfind+0x24>
  800b4e:	38 08                	cmp    %cl,(%eax)
  800b50:	74 07                	je     800b59 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b52:	83 c0 01             	add    $0x1,%eax
  800b55:	39 c2                	cmp    %eax,%edx
  800b57:	77 f5                	ja     800b4e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	57                   	push   %edi
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
  800b61:	83 ec 04             	sub    $0x4,%esp
  800b64:	8b 55 08             	mov    0x8(%ebp),%edx
  800b67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6a:	0f b6 02             	movzbl (%edx),%eax
  800b6d:	3c 20                	cmp    $0x20,%al
  800b6f:	74 04                	je     800b75 <strtol+0x1a>
  800b71:	3c 09                	cmp    $0x9,%al
  800b73:	75 0e                	jne    800b83 <strtol+0x28>
		s++;
  800b75:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b78:	0f b6 02             	movzbl (%edx),%eax
  800b7b:	3c 20                	cmp    $0x20,%al
  800b7d:	74 f6                	je     800b75 <strtol+0x1a>
  800b7f:	3c 09                	cmp    $0x9,%al
  800b81:	74 f2                	je     800b75 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b83:	3c 2b                	cmp    $0x2b,%al
  800b85:	75 0c                	jne    800b93 <strtol+0x38>
		s++;
  800b87:	83 c2 01             	add    $0x1,%edx
  800b8a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b91:	eb 15                	jmp    800ba8 <strtol+0x4d>
	else if (*s == '-')
  800b93:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b9a:	3c 2d                	cmp    $0x2d,%al
  800b9c:	75 0a                	jne    800ba8 <strtol+0x4d>
		s++, neg = 1;
  800b9e:	83 c2 01             	add    $0x1,%edx
  800ba1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba8:	85 db                	test   %ebx,%ebx
  800baa:	0f 94 c0             	sete   %al
  800bad:	74 05                	je     800bb4 <strtol+0x59>
  800baf:	83 fb 10             	cmp    $0x10,%ebx
  800bb2:	75 18                	jne    800bcc <strtol+0x71>
  800bb4:	80 3a 30             	cmpb   $0x30,(%edx)
  800bb7:	75 13                	jne    800bcc <strtol+0x71>
  800bb9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bbd:	8d 76 00             	lea    0x0(%esi),%esi
  800bc0:	75 0a                	jne    800bcc <strtol+0x71>
		s += 2, base = 16;
  800bc2:	83 c2 02             	add    $0x2,%edx
  800bc5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bca:	eb 15                	jmp    800be1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bcc:	84 c0                	test   %al,%al
  800bce:	66 90                	xchg   %ax,%ax
  800bd0:	74 0f                	je     800be1 <strtol+0x86>
  800bd2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bd7:	80 3a 30             	cmpb   $0x30,(%edx)
  800bda:	75 05                	jne    800be1 <strtol+0x86>
		s++, base = 8;
  800bdc:	83 c2 01             	add    $0x1,%edx
  800bdf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800be1:	b8 00 00 00 00       	mov    $0x0,%eax
  800be6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800be8:	0f b6 0a             	movzbl (%edx),%ecx
  800beb:	89 cf                	mov    %ecx,%edi
  800bed:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bf0:	80 fb 09             	cmp    $0x9,%bl
  800bf3:	77 08                	ja     800bfd <strtol+0xa2>
			dig = *s - '0';
  800bf5:	0f be c9             	movsbl %cl,%ecx
  800bf8:	83 e9 30             	sub    $0x30,%ecx
  800bfb:	eb 1e                	jmp    800c1b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800bfd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800c00:	80 fb 19             	cmp    $0x19,%bl
  800c03:	77 08                	ja     800c0d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800c05:	0f be c9             	movsbl %cl,%ecx
  800c08:	83 e9 57             	sub    $0x57,%ecx
  800c0b:	eb 0e                	jmp    800c1b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800c0d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800c10:	80 fb 19             	cmp    $0x19,%bl
  800c13:	77 15                	ja     800c2a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800c15:	0f be c9             	movsbl %cl,%ecx
  800c18:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c1b:	39 f1                	cmp    %esi,%ecx
  800c1d:	7d 0b                	jge    800c2a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800c1f:	83 c2 01             	add    $0x1,%edx
  800c22:	0f af c6             	imul   %esi,%eax
  800c25:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c28:	eb be                	jmp    800be8 <strtol+0x8d>
  800c2a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800c2c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c30:	74 05                	je     800c37 <strtol+0xdc>
		*endptr = (char *) s;
  800c32:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c35:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c37:	89 ca                	mov    %ecx,%edx
  800c39:	f7 da                	neg    %edx
  800c3b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c3f:	0f 45 c2             	cmovne %edx,%eax
}
  800c42:	83 c4 04             	add    $0x4,%esp
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    
	...

00800c4c <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c4c:	55                   	push   %ebp
  800c4d:	89 e5                	mov    %esp,%ebp
  800c4f:	83 ec 48             	sub    $0x48,%esp
  800c52:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c55:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c58:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c5b:	89 c6                	mov    %eax,%esi
  800c5d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800c60:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c62:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c65:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6b:	51                   	push   %ecx
  800c6c:	52                   	push   %edx
  800c6d:	53                   	push   %ebx
  800c6e:	54                   	push   %esp
  800c6f:	55                   	push   %ebp
  800c70:	56                   	push   %esi
  800c71:	57                   	push   %edi
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	8d 35 7c 0c 80 00    	lea    0x800c7c,%esi
  800c7a:	0f 34                	sysenter 

00800c7c <.after_sysenter_label>:
  800c7c:	5f                   	pop    %edi
  800c7d:	5e                   	pop    %esi
  800c7e:	5d                   	pop    %ebp
  800c7f:	5c                   	pop    %esp
  800c80:	5b                   	pop    %ebx
  800c81:	5a                   	pop    %edx
  800c82:	59                   	pop    %ecx
  800c83:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800c85:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c89:	74 28                	je     800cb3 <.after_sysenter_label+0x37>
  800c8b:	85 c0                	test   %eax,%eax
  800c8d:	7e 24                	jle    800cb3 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c8f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c93:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800c97:	c7 44 24 08 a0 20 80 	movl   $0x8020a0,0x8(%esp)
  800c9e:	00 
  800c9f:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800ca6:	00 
  800ca7:	c7 04 24 bd 20 80 00 	movl   $0x8020bd,(%esp)
  800cae:	e8 1d 0c 00 00       	call   8018d0 <_panic>

	return ret;
}
  800cb3:	89 d0                	mov    %edx,%eax
  800cb5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cb8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cbb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cbe:	89 ec                	mov    %ebp,%esp
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800cc8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ccf:	00 
  800cd0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800cd7:	00 
  800cd8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800cdf:	00 
  800ce0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ce7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cea:	ba 01 00 00 00       	mov    $0x1,%edx
  800cef:	b8 0e 00 00 00       	mov    $0xe,%eax
  800cf4:	e8 53 ff ff ff       	call   800c4c <syscall>
}
  800cf9:	c9                   	leave  
  800cfa:	c3                   	ret    

00800cfb <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d01:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d08:	00 
  800d09:	8b 45 14             	mov    0x14(%ebp),%eax
  800d0c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d10:	8b 45 10             	mov    0x10(%ebp),%eax
  800d13:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d1a:	89 04 24             	mov    %eax,(%esp)
  800d1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d20:	ba 00 00 00 00       	mov    $0x0,%edx
  800d25:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d2a:	e8 1d ff ff ff       	call   800c4c <syscall>
}
  800d2f:	c9                   	leave  
  800d30:	c3                   	ret    

00800d31 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d31:	55                   	push   %ebp
  800d32:	89 e5                	mov    %esp,%ebp
  800d34:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800d37:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d3e:	00 
  800d3f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d46:	00 
  800d47:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d4e:	00 
  800d4f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d52:	89 04 24             	mov    %eax,(%esp)
  800d55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d58:	ba 01 00 00 00       	mov    $0x1,%edx
  800d5d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d62:	e8 e5 fe ff ff       	call   800c4c <syscall>
}
  800d67:	c9                   	leave  
  800d68:	c3                   	ret    

00800d69 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800d6f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d76:	00 
  800d77:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d7e:	00 
  800d7f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d86:	00 
  800d87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d8a:	89 04 24             	mov    %eax,(%esp)
  800d8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d90:	ba 01 00 00 00       	mov    $0x1,%edx
  800d95:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d9a:	e8 ad fe ff ff       	call   800c4c <syscall>
}
  800d9f:	c9                   	leave  
  800da0:	c3                   	ret    

00800da1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800da7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dae:	00 
  800daf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800db6:	00 
  800db7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800dbe:	00 
  800dbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc2:	89 04 24             	mov    %eax,(%esp)
  800dc5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc8:	ba 01 00 00 00       	mov    $0x1,%edx
  800dcd:	b8 09 00 00 00       	mov    $0x9,%eax
  800dd2:	e8 75 fe ff ff       	call   800c4c <syscall>
}
  800dd7:	c9                   	leave  
  800dd8:	c3                   	ret    

00800dd9 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800ddf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800de6:	00 
  800de7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800dee:	00 
  800def:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800df6:	00 
  800df7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dfa:	89 04 24             	mov    %eax,(%esp)
  800dfd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e00:	ba 01 00 00 00       	mov    $0x1,%edx
  800e05:	b8 07 00 00 00       	mov    $0x7,%eax
  800e0a:	e8 3d fe ff ff       	call   800c4c <syscall>
}
  800e0f:	c9                   	leave  
  800e10:	c3                   	ret    

00800e11 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800e17:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e1e:	00 
  800e1f:	8b 45 18             	mov    0x18(%ebp),%eax
  800e22:	0b 45 14             	or     0x14(%ebp),%eax
  800e25:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e29:	8b 45 10             	mov    0x10(%ebp),%eax
  800e2c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e33:	89 04 24             	mov    %eax,(%esp)
  800e36:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e39:	ba 01 00 00 00       	mov    $0x1,%edx
  800e3e:	b8 06 00 00 00       	mov    $0x6,%eax
  800e43:	e8 04 fe ff ff       	call   800c4c <syscall>
}
  800e48:	c9                   	leave  
  800e49:	c3                   	ret    

00800e4a <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800e50:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e57:	00 
  800e58:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e5f:	00 
  800e60:	8b 45 10             	mov    0x10(%ebp),%eax
  800e63:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6a:	89 04 24             	mov    %eax,(%esp)
  800e6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e70:	ba 01 00 00 00       	mov    $0x1,%edx
  800e75:	b8 05 00 00 00       	mov    $0x5,%eax
  800e7a:	e8 cd fd ff ff       	call   800c4c <syscall>
}
  800e7f:	c9                   	leave  
  800e80:	c3                   	ret    

00800e81 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800e87:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e8e:	00 
  800e8f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e96:	00 
  800e97:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e9e:	00 
  800e9f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ea6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eab:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eb5:	e8 92 fd ff ff       	call   800c4c <syscall>
}
  800eba:	c9                   	leave  
  800ebb:	c3                   	ret    

00800ebc <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  800ec2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ec9:	00 
  800eca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ed1:	00 
  800ed2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ed9:	00 
  800eda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800edd:	89 04 24             	mov    %eax,(%esp)
  800ee0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ee8:	b8 04 00 00 00       	mov    $0x4,%eax
  800eed:	e8 5a fd ff ff       	call   800c4c <syscall>
}
  800ef2:	c9                   	leave  
  800ef3:	c3                   	ret    

00800ef4 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800efa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f01:	00 
  800f02:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f09:	00 
  800f0a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f11:	00 
  800f12:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f19:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f23:	b8 02 00 00 00       	mov    $0x2,%eax
  800f28:	e8 1f fd ff ff       	call   800c4c <syscall>
}
  800f2d:	c9                   	leave  
  800f2e:	c3                   	ret    

00800f2f <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800f35:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f3c:	00 
  800f3d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f44:	00 
  800f45:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f4c:	00 
  800f4d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f57:	ba 01 00 00 00       	mov    $0x1,%edx
  800f5c:	b8 03 00 00 00       	mov    $0x3,%eax
  800f61:	e8 e6 fc ff ff       	call   800c4c <syscall>
}
  800f66:	c9                   	leave  
  800f67:	c3                   	ret    

00800f68 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800f68:	55                   	push   %ebp
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800f6e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f75:	00 
  800f76:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f7d:	00 
  800f7e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f85:	00 
  800f86:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f8d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f92:	ba 00 00 00 00       	mov    $0x0,%edx
  800f97:	b8 01 00 00 00       	mov    $0x1,%eax
  800f9c:	e8 ab fc ff ff       	call   800c4c <syscall>
}
  800fa1:	c9                   	leave  
  800fa2:	c3                   	ret    

00800fa3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fa3:	55                   	push   %ebp
  800fa4:	89 e5                	mov    %esp,%ebp
  800fa6:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800fa9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fb0:	00 
  800fb1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fb8:	00 
  800fb9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fc0:	00 
  800fc1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fc4:	89 04 24             	mov    %eax,(%esp)
  800fc7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fca:	ba 00 00 00 00       	mov    $0x0,%edx
  800fcf:	b8 00 00 00 00       	mov    $0x0,%eax
  800fd4:	e8 73 fc ff ff       	call   800c4c <syscall>
}
  800fd9:	c9                   	leave  
  800fda:	c3                   	ret    
  800fdb:	00 00                	add    %al,(%eax)
  800fdd:	00 00                	add    %al,(%eax)
	...

00800fe0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe6:	05 00 00 00 30       	add    $0x30000000,%eax
  800feb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  800fee:	5d                   	pop    %ebp
  800fef:	c3                   	ret    

00800ff0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  800ff6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff9:	89 04 24             	mov    %eax,(%esp)
  800ffc:	e8 df ff ff ff       	call   800fe0 <fd2num>
  801001:	05 20 00 0d 00       	add    $0xd0020,%eax
  801006:	c1 e0 0c             	shl    $0xc,%eax
}
  801009:	c9                   	leave  
  80100a:	c3                   	ret    

0080100b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80100b:	55                   	push   %ebp
  80100c:	89 e5                	mov    %esp,%ebp
  80100e:	57                   	push   %edi
  80100f:	56                   	push   %esi
  801010:	53                   	push   %ebx
  801011:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801014:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801019:	a8 01                	test   $0x1,%al
  80101b:	74 36                	je     801053 <fd_alloc+0x48>
  80101d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801022:	a8 01                	test   $0x1,%al
  801024:	74 2d                	je     801053 <fd_alloc+0x48>
  801026:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80102b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801030:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801035:	89 c3                	mov    %eax,%ebx
  801037:	89 c2                	mov    %eax,%edx
  801039:	c1 ea 16             	shr    $0x16,%edx
  80103c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80103f:	f6 c2 01             	test   $0x1,%dl
  801042:	74 14                	je     801058 <fd_alloc+0x4d>
  801044:	89 c2                	mov    %eax,%edx
  801046:	c1 ea 0c             	shr    $0xc,%edx
  801049:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80104c:	f6 c2 01             	test   $0x1,%dl
  80104f:	75 10                	jne    801061 <fd_alloc+0x56>
  801051:	eb 05                	jmp    801058 <fd_alloc+0x4d>
  801053:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801058:	89 1f                	mov    %ebx,(%edi)
  80105a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80105f:	eb 17                	jmp    801078 <fd_alloc+0x6d>
  801061:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801066:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80106b:	75 c8                	jne    801035 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80106d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801073:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801078:	5b                   	pop    %ebx
  801079:	5e                   	pop    %esi
  80107a:	5f                   	pop    %edi
  80107b:	5d                   	pop    %ebp
  80107c:	c3                   	ret    

0080107d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801080:	8b 45 08             	mov    0x8(%ebp),%eax
  801083:	83 f8 1f             	cmp    $0x1f,%eax
  801086:	77 36                	ja     8010be <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801088:	05 00 00 0d 00       	add    $0xd0000,%eax
  80108d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801090:	89 c2                	mov    %eax,%edx
  801092:	c1 ea 16             	shr    $0x16,%edx
  801095:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80109c:	f6 c2 01             	test   $0x1,%dl
  80109f:	74 1d                	je     8010be <fd_lookup+0x41>
  8010a1:	89 c2                	mov    %eax,%edx
  8010a3:	c1 ea 0c             	shr    $0xc,%edx
  8010a6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010ad:	f6 c2 01             	test   $0x1,%dl
  8010b0:	74 0c                	je     8010be <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010b5:	89 02                	mov    %eax,(%edx)
  8010b7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8010bc:	eb 05                	jmp    8010c3 <fd_lookup+0x46>
  8010be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010c3:	5d                   	pop    %ebp
  8010c4:	c3                   	ret    

008010c5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8010c5:	55                   	push   %ebp
  8010c6:	89 e5                	mov    %esp,%ebp
  8010c8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010cb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8010ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d5:	89 04 24             	mov    %eax,(%esp)
  8010d8:	e8 a0 ff ff ff       	call   80107d <fd_lookup>
  8010dd:	85 c0                	test   %eax,%eax
  8010df:	78 0e                	js     8010ef <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8010e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8010e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010e7:	89 50 04             	mov    %edx,0x4(%eax)
  8010ea:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8010ef:	c9                   	leave  
  8010f0:	c3                   	ret    

008010f1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010f1:	55                   	push   %ebp
  8010f2:	89 e5                	mov    %esp,%ebp
  8010f4:	56                   	push   %esi
  8010f5:	53                   	push   %ebx
  8010f6:	83 ec 10             	sub    $0x10,%esp
  8010f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8010ff:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801104:	b8 04 30 80 00       	mov    $0x803004,%eax
  801109:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80110f:	75 11                	jne    801122 <dev_lookup+0x31>
  801111:	eb 04                	jmp    801117 <dev_lookup+0x26>
  801113:	39 08                	cmp    %ecx,(%eax)
  801115:	75 10                	jne    801127 <dev_lookup+0x36>
			*dev = devtab[i];
  801117:	89 03                	mov    %eax,(%ebx)
  801119:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80111e:	66 90                	xchg   %ax,%ax
  801120:	eb 36                	jmp    801158 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801122:	be 48 21 80 00       	mov    $0x802148,%esi
  801127:	83 c2 01             	add    $0x1,%edx
  80112a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80112d:	85 c0                	test   %eax,%eax
  80112f:	75 e2                	jne    801113 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801131:	a1 04 40 80 00       	mov    0x804004,%eax
  801136:	8b 40 48             	mov    0x48(%eax),%eax
  801139:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80113d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801141:	c7 04 24 cc 20 80 00 	movl   $0x8020cc,(%esp)
  801148:	e8 d4 ef ff ff       	call   800121 <cprintf>
	*dev = 0;
  80114d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801153:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801158:	83 c4 10             	add    $0x10,%esp
  80115b:	5b                   	pop    %ebx
  80115c:	5e                   	pop    %esi
  80115d:	5d                   	pop    %ebp
  80115e:	c3                   	ret    

0080115f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80115f:	55                   	push   %ebp
  801160:	89 e5                	mov    %esp,%ebp
  801162:	53                   	push   %ebx
  801163:	83 ec 24             	sub    $0x24,%esp
  801166:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801169:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80116c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801170:	8b 45 08             	mov    0x8(%ebp),%eax
  801173:	89 04 24             	mov    %eax,(%esp)
  801176:	e8 02 ff ff ff       	call   80107d <fd_lookup>
  80117b:	85 c0                	test   %eax,%eax
  80117d:	78 53                	js     8011d2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80117f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801182:	89 44 24 04          	mov    %eax,0x4(%esp)
  801186:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801189:	8b 00                	mov    (%eax),%eax
  80118b:	89 04 24             	mov    %eax,(%esp)
  80118e:	e8 5e ff ff ff       	call   8010f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801193:	85 c0                	test   %eax,%eax
  801195:	78 3b                	js     8011d2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801197:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80119c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80119f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8011a3:	74 2d                	je     8011d2 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8011a5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8011a8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8011af:	00 00 00 
	stat->st_isdir = 0;
  8011b2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8011b9:	00 00 00 
	stat->st_dev = dev;
  8011bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011bf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8011c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011c9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011cc:	89 14 24             	mov    %edx,(%esp)
  8011cf:	ff 50 14             	call   *0x14(%eax)
}
  8011d2:	83 c4 24             	add    $0x24,%esp
  8011d5:	5b                   	pop    %ebx
  8011d6:	5d                   	pop    %ebp
  8011d7:	c3                   	ret    

008011d8 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8011d8:	55                   	push   %ebp
  8011d9:	89 e5                	mov    %esp,%ebp
  8011db:	53                   	push   %ebx
  8011dc:	83 ec 24             	sub    $0x24,%esp
  8011df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011e9:	89 1c 24             	mov    %ebx,(%esp)
  8011ec:	e8 8c fe ff ff       	call   80107d <fd_lookup>
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	78 5f                	js     801254 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ff:	8b 00                	mov    (%eax),%eax
  801201:	89 04 24             	mov    %eax,(%esp)
  801204:	e8 e8 fe ff ff       	call   8010f1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801209:	85 c0                	test   %eax,%eax
  80120b:	78 47                	js     801254 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80120d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801210:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801214:	75 23                	jne    801239 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801216:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80121b:	8b 40 48             	mov    0x48(%eax),%eax
  80121e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801222:	89 44 24 04          	mov    %eax,0x4(%esp)
  801226:	c7 04 24 ec 20 80 00 	movl   $0x8020ec,(%esp)
  80122d:	e8 ef ee ff ff       	call   800121 <cprintf>
  801232:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801237:	eb 1b                	jmp    801254 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801239:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80123c:	8b 48 18             	mov    0x18(%eax),%ecx
  80123f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801244:	85 c9                	test   %ecx,%ecx
  801246:	74 0c                	je     801254 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801248:	8b 45 0c             	mov    0xc(%ebp),%eax
  80124b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80124f:	89 14 24             	mov    %edx,(%esp)
  801252:	ff d1                	call   *%ecx
}
  801254:	83 c4 24             	add    $0x24,%esp
  801257:	5b                   	pop    %ebx
  801258:	5d                   	pop    %ebp
  801259:	c3                   	ret    

0080125a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80125a:	55                   	push   %ebp
  80125b:	89 e5                	mov    %esp,%ebp
  80125d:	53                   	push   %ebx
  80125e:	83 ec 24             	sub    $0x24,%esp
  801261:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801264:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801267:	89 44 24 04          	mov    %eax,0x4(%esp)
  80126b:	89 1c 24             	mov    %ebx,(%esp)
  80126e:	e8 0a fe ff ff       	call   80107d <fd_lookup>
  801273:	85 c0                	test   %eax,%eax
  801275:	78 66                	js     8012dd <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801277:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80127e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801281:	8b 00                	mov    (%eax),%eax
  801283:	89 04 24             	mov    %eax,(%esp)
  801286:	e8 66 fe ff ff       	call   8010f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80128b:	85 c0                	test   %eax,%eax
  80128d:	78 4e                	js     8012dd <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80128f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801292:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801296:	75 23                	jne    8012bb <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801298:	a1 04 40 80 00       	mov    0x804004,%eax
  80129d:	8b 40 48             	mov    0x48(%eax),%eax
  8012a0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012a8:	c7 04 24 0d 21 80 00 	movl   $0x80210d,(%esp)
  8012af:	e8 6d ee ff ff       	call   800121 <cprintf>
  8012b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8012b9:	eb 22                	jmp    8012dd <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012be:	8b 48 0c             	mov    0xc(%eax),%ecx
  8012c1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012c6:	85 c9                	test   %ecx,%ecx
  8012c8:	74 13                	je     8012dd <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8012cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d8:	89 14 24             	mov    %edx,(%esp)
  8012db:	ff d1                	call   *%ecx
}
  8012dd:	83 c4 24             	add    $0x24,%esp
  8012e0:	5b                   	pop    %ebx
  8012e1:	5d                   	pop    %ebp
  8012e2:	c3                   	ret    

008012e3 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	53                   	push   %ebx
  8012e7:	83 ec 24             	sub    $0x24,%esp
  8012ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f4:	89 1c 24             	mov    %ebx,(%esp)
  8012f7:	e8 81 fd ff ff       	call   80107d <fd_lookup>
  8012fc:	85 c0                	test   %eax,%eax
  8012fe:	78 6b                	js     80136b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801300:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801303:	89 44 24 04          	mov    %eax,0x4(%esp)
  801307:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130a:	8b 00                	mov    (%eax),%eax
  80130c:	89 04 24             	mov    %eax,(%esp)
  80130f:	e8 dd fd ff ff       	call   8010f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801314:	85 c0                	test   %eax,%eax
  801316:	78 53                	js     80136b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801318:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80131b:	8b 42 08             	mov    0x8(%edx),%eax
  80131e:	83 e0 03             	and    $0x3,%eax
  801321:	83 f8 01             	cmp    $0x1,%eax
  801324:	75 23                	jne    801349 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801326:	a1 04 40 80 00       	mov    0x804004,%eax
  80132b:	8b 40 48             	mov    0x48(%eax),%eax
  80132e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801332:	89 44 24 04          	mov    %eax,0x4(%esp)
  801336:	c7 04 24 2a 21 80 00 	movl   $0x80212a,(%esp)
  80133d:	e8 df ed ff ff       	call   800121 <cprintf>
  801342:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801347:	eb 22                	jmp    80136b <read+0x88>
	}
	if (!dev->dev_read)
  801349:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80134c:	8b 48 08             	mov    0x8(%eax),%ecx
  80134f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801354:	85 c9                	test   %ecx,%ecx
  801356:	74 13                	je     80136b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801358:	8b 45 10             	mov    0x10(%ebp),%eax
  80135b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80135f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801362:	89 44 24 04          	mov    %eax,0x4(%esp)
  801366:	89 14 24             	mov    %edx,(%esp)
  801369:	ff d1                	call   *%ecx
}
  80136b:	83 c4 24             	add    $0x24,%esp
  80136e:	5b                   	pop    %ebx
  80136f:	5d                   	pop    %ebp
  801370:	c3                   	ret    

00801371 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801371:	55                   	push   %ebp
  801372:	89 e5                	mov    %esp,%ebp
  801374:	57                   	push   %edi
  801375:	56                   	push   %esi
  801376:	53                   	push   %ebx
  801377:	83 ec 1c             	sub    $0x1c,%esp
  80137a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80137d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801380:	ba 00 00 00 00       	mov    $0x0,%edx
  801385:	bb 00 00 00 00       	mov    $0x0,%ebx
  80138a:	b8 00 00 00 00       	mov    $0x0,%eax
  80138f:	85 f6                	test   %esi,%esi
  801391:	74 29                	je     8013bc <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801393:	89 f0                	mov    %esi,%eax
  801395:	29 d0                	sub    %edx,%eax
  801397:	89 44 24 08          	mov    %eax,0x8(%esp)
  80139b:	03 55 0c             	add    0xc(%ebp),%edx
  80139e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013a2:	89 3c 24             	mov    %edi,(%esp)
  8013a5:	e8 39 ff ff ff       	call   8012e3 <read>
		if (m < 0)
  8013aa:	85 c0                	test   %eax,%eax
  8013ac:	78 0e                	js     8013bc <readn+0x4b>
			return m;
		if (m == 0)
  8013ae:	85 c0                	test   %eax,%eax
  8013b0:	74 08                	je     8013ba <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013b2:	01 c3                	add    %eax,%ebx
  8013b4:	89 da                	mov    %ebx,%edx
  8013b6:	39 f3                	cmp    %esi,%ebx
  8013b8:	72 d9                	jb     801393 <readn+0x22>
  8013ba:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013bc:	83 c4 1c             	add    $0x1c,%esp
  8013bf:	5b                   	pop    %ebx
  8013c0:	5e                   	pop    %esi
  8013c1:	5f                   	pop    %edi
  8013c2:	5d                   	pop    %ebp
  8013c3:	c3                   	ret    

008013c4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013c4:	55                   	push   %ebp
  8013c5:	89 e5                	mov    %esp,%ebp
  8013c7:	83 ec 28             	sub    $0x28,%esp
  8013ca:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013cd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8013d0:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013d3:	89 34 24             	mov    %esi,(%esp)
  8013d6:	e8 05 fc ff ff       	call   800fe0 <fd2num>
  8013db:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8013de:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013e2:	89 04 24             	mov    %eax,(%esp)
  8013e5:	e8 93 fc ff ff       	call   80107d <fd_lookup>
  8013ea:	89 c3                	mov    %eax,%ebx
  8013ec:	85 c0                	test   %eax,%eax
  8013ee:	78 05                	js     8013f5 <fd_close+0x31>
  8013f0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013f3:	74 0e                	je     801403 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8013f5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8013f9:	b8 00 00 00 00       	mov    $0x0,%eax
  8013fe:	0f 44 d8             	cmove  %eax,%ebx
  801401:	eb 3d                	jmp    801440 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801403:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801406:	89 44 24 04          	mov    %eax,0x4(%esp)
  80140a:	8b 06                	mov    (%esi),%eax
  80140c:	89 04 24             	mov    %eax,(%esp)
  80140f:	e8 dd fc ff ff       	call   8010f1 <dev_lookup>
  801414:	89 c3                	mov    %eax,%ebx
  801416:	85 c0                	test   %eax,%eax
  801418:	78 16                	js     801430 <fd_close+0x6c>
		if (dev->dev_close)
  80141a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141d:	8b 40 10             	mov    0x10(%eax),%eax
  801420:	bb 00 00 00 00       	mov    $0x0,%ebx
  801425:	85 c0                	test   %eax,%eax
  801427:	74 07                	je     801430 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801429:	89 34 24             	mov    %esi,(%esp)
  80142c:	ff d0                	call   *%eax
  80142e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801430:	89 74 24 04          	mov    %esi,0x4(%esp)
  801434:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80143b:	e8 99 f9 ff ff       	call   800dd9 <sys_page_unmap>
	return r;
}
  801440:	89 d8                	mov    %ebx,%eax
  801442:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801445:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801448:	89 ec                	mov    %ebp,%esp
  80144a:	5d                   	pop    %ebp
  80144b:	c3                   	ret    

0080144c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80144c:	55                   	push   %ebp
  80144d:	89 e5                	mov    %esp,%ebp
  80144f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801452:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801455:	89 44 24 04          	mov    %eax,0x4(%esp)
  801459:	8b 45 08             	mov    0x8(%ebp),%eax
  80145c:	89 04 24             	mov    %eax,(%esp)
  80145f:	e8 19 fc ff ff       	call   80107d <fd_lookup>
  801464:	85 c0                	test   %eax,%eax
  801466:	78 13                	js     80147b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801468:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80146f:	00 
  801470:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801473:	89 04 24             	mov    %eax,(%esp)
  801476:	e8 49 ff ff ff       	call   8013c4 <fd_close>
}
  80147b:	c9                   	leave  
  80147c:	c3                   	ret    

0080147d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80147d:	55                   	push   %ebp
  80147e:	89 e5                	mov    %esp,%ebp
  801480:	83 ec 18             	sub    $0x18,%esp
  801483:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801486:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801489:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801490:	00 
  801491:	8b 45 08             	mov    0x8(%ebp),%eax
  801494:	89 04 24             	mov    %eax,(%esp)
  801497:	e8 78 03 00 00       	call   801814 <open>
  80149c:	89 c3                	mov    %eax,%ebx
  80149e:	85 c0                	test   %eax,%eax
  8014a0:	78 1b                	js     8014bd <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8014a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a9:	89 1c 24             	mov    %ebx,(%esp)
  8014ac:	e8 ae fc ff ff       	call   80115f <fstat>
  8014b1:	89 c6                	mov    %eax,%esi
	close(fd);
  8014b3:	89 1c 24             	mov    %ebx,(%esp)
  8014b6:	e8 91 ff ff ff       	call   80144c <close>
  8014bb:	89 f3                	mov    %esi,%ebx
	return r;
}
  8014bd:	89 d8                	mov    %ebx,%eax
  8014bf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014c2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8014c5:	89 ec                	mov    %ebp,%esp
  8014c7:	5d                   	pop    %ebp
  8014c8:	c3                   	ret    

008014c9 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8014c9:	55                   	push   %ebp
  8014ca:	89 e5                	mov    %esp,%ebp
  8014cc:	53                   	push   %ebx
  8014cd:	83 ec 14             	sub    $0x14,%esp
  8014d0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8014d5:	89 1c 24             	mov    %ebx,(%esp)
  8014d8:	e8 6f ff ff ff       	call   80144c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014dd:	83 c3 01             	add    $0x1,%ebx
  8014e0:	83 fb 20             	cmp    $0x20,%ebx
  8014e3:	75 f0                	jne    8014d5 <close_all+0xc>
		close(i);
}
  8014e5:	83 c4 14             	add    $0x14,%esp
  8014e8:	5b                   	pop    %ebx
  8014e9:	5d                   	pop    %ebp
  8014ea:	c3                   	ret    

008014eb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014eb:	55                   	push   %ebp
  8014ec:	89 e5                	mov    %esp,%ebp
  8014ee:	83 ec 58             	sub    $0x58,%esp
  8014f1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8014f4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8014f7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8014fa:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014fd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801500:	89 44 24 04          	mov    %eax,0x4(%esp)
  801504:	8b 45 08             	mov    0x8(%ebp),%eax
  801507:	89 04 24             	mov    %eax,(%esp)
  80150a:	e8 6e fb ff ff       	call   80107d <fd_lookup>
  80150f:	89 c3                	mov    %eax,%ebx
  801511:	85 c0                	test   %eax,%eax
  801513:	0f 88 e0 00 00 00    	js     8015f9 <dup+0x10e>
		return r;
	close(newfdnum);
  801519:	89 3c 24             	mov    %edi,(%esp)
  80151c:	e8 2b ff ff ff       	call   80144c <close>

	newfd = INDEX2FD(newfdnum);
  801521:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801527:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80152a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80152d:	89 04 24             	mov    %eax,(%esp)
  801530:	e8 bb fa ff ff       	call   800ff0 <fd2data>
  801535:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801537:	89 34 24             	mov    %esi,(%esp)
  80153a:	e8 b1 fa ff ff       	call   800ff0 <fd2data>
  80153f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801542:	89 da                	mov    %ebx,%edx
  801544:	89 d8                	mov    %ebx,%eax
  801546:	c1 e8 16             	shr    $0x16,%eax
  801549:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801550:	a8 01                	test   $0x1,%al
  801552:	74 43                	je     801597 <dup+0xac>
  801554:	c1 ea 0c             	shr    $0xc,%edx
  801557:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80155e:	a8 01                	test   $0x1,%al
  801560:	74 35                	je     801597 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801562:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801569:	25 07 0e 00 00       	and    $0xe07,%eax
  80156e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801572:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801575:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801579:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801580:	00 
  801581:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801585:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80158c:	e8 80 f8 ff ff       	call   800e11 <sys_page_map>
  801591:	89 c3                	mov    %eax,%ebx
  801593:	85 c0                	test   %eax,%eax
  801595:	78 3f                	js     8015d6 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801597:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80159a:	89 c2                	mov    %eax,%edx
  80159c:	c1 ea 0c             	shr    $0xc,%edx
  80159f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015a6:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8015ac:	89 54 24 10          	mov    %edx,0x10(%esp)
  8015b0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8015b4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015bb:	00 
  8015bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015c7:	e8 45 f8 ff ff       	call   800e11 <sys_page_map>
  8015cc:	89 c3                	mov    %eax,%ebx
  8015ce:	85 c0                	test   %eax,%eax
  8015d0:	78 04                	js     8015d6 <dup+0xeb>
  8015d2:	89 fb                	mov    %edi,%ebx
  8015d4:	eb 23                	jmp    8015f9 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015da:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015e1:	e8 f3 f7 ff ff       	call   800dd9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015e6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015ed:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015f4:	e8 e0 f7 ff ff       	call   800dd9 <sys_page_unmap>
	return r;
}
  8015f9:	89 d8                	mov    %ebx,%eax
  8015fb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8015fe:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801601:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801604:	89 ec                	mov    %ebp,%esp
  801606:	5d                   	pop    %ebp
  801607:	c3                   	ret    

00801608 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801608:	55                   	push   %ebp
  801609:	89 e5                	mov    %esp,%ebp
  80160b:	83 ec 18             	sub    $0x18,%esp
  80160e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801611:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801614:	89 c3                	mov    %eax,%ebx
  801616:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801618:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80161f:	75 11                	jne    801632 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801621:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801628:	e8 03 03 00 00       	call   801930 <ipc_find_env>
  80162d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801632:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801639:	00 
  80163a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801641:	00 
  801642:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801646:	a1 00 40 80 00       	mov    0x804000,%eax
  80164b:	89 04 24             	mov    %eax,(%esp)
  80164e:	e8 21 03 00 00       	call   801974 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801653:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80165a:	00 
  80165b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80165f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801666:	e8 78 03 00 00       	call   8019e3 <ipc_recv>
}
  80166b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80166e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801671:	89 ec                	mov    %ebp,%esp
  801673:	5d                   	pop    %ebp
  801674:	c3                   	ret    

00801675 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80167b:	8b 45 08             	mov    0x8(%ebp),%eax
  80167e:	8b 40 0c             	mov    0xc(%eax),%eax
  801681:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801686:	8b 45 0c             	mov    0xc(%ebp),%eax
  801689:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80168e:	ba 00 00 00 00       	mov    $0x0,%edx
  801693:	b8 02 00 00 00       	mov    $0x2,%eax
  801698:	e8 6b ff ff ff       	call   801608 <fsipc>
}
  80169d:	c9                   	leave  
  80169e:	c3                   	ret    

0080169f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80169f:	55                   	push   %ebp
  8016a0:	89 e5                	mov    %esp,%ebp
  8016a2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a8:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ab:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b5:	b8 06 00 00 00       	mov    $0x6,%eax
  8016ba:	e8 49 ff ff ff       	call   801608 <fsipc>
}
  8016bf:	c9                   	leave  
  8016c0:	c3                   	ret    

008016c1 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  8016c1:	55                   	push   %ebp
  8016c2:	89 e5                	mov    %esp,%ebp
  8016c4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016cc:	b8 08 00 00 00       	mov    $0x8,%eax
  8016d1:	e8 32 ff ff ff       	call   801608 <fsipc>
}
  8016d6:	c9                   	leave  
  8016d7:	c3                   	ret    

008016d8 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016d8:	55                   	push   %ebp
  8016d9:	89 e5                	mov    %esp,%ebp
  8016db:	53                   	push   %ebx
  8016dc:	83 ec 14             	sub    $0x14,%esp
  8016df:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8016f2:	b8 05 00 00 00       	mov    $0x5,%eax
  8016f7:	e8 0c ff ff ff       	call   801608 <fsipc>
  8016fc:	85 c0                	test   %eax,%eax
  8016fe:	78 2b                	js     80172b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801700:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801707:	00 
  801708:	89 1c 24             	mov    %ebx,(%esp)
  80170b:	e8 4a f1 ff ff       	call   80085a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801710:	a1 80 50 80 00       	mov    0x805080,%eax
  801715:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80171b:	a1 84 50 80 00       	mov    0x805084,%eax
  801720:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801726:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80172b:	83 c4 14             	add    $0x14,%esp
  80172e:	5b                   	pop    %ebx
  80172f:	5d                   	pop    %ebp
  801730:	c3                   	ret    

00801731 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801731:	55                   	push   %ebp
  801732:	89 e5                	mov    %esp,%ebp
  801734:	83 ec 18             	sub    $0x18,%esp
  801737:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  80173a:	8b 55 08             	mov    0x8(%ebp),%edx
  80173d:	8b 52 0c             	mov    0xc(%edx),%edx
  801740:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  801746:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  80174b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801750:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801755:	0f 47 c2             	cmova  %edx,%eax
  801758:	89 44 24 08          	mov    %eax,0x8(%esp)
  80175c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80175f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801763:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  80176a:	e8 d6 f2 ff ff       	call   800a45 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  80176f:	ba 00 00 00 00       	mov    $0x0,%edx
  801774:	b8 04 00 00 00       	mov    $0x4,%eax
  801779:	e8 8a fe ff ff       	call   801608 <fsipc>
}
  80177e:	c9                   	leave  
  80177f:	c3                   	ret    

00801780 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	53                   	push   %ebx
  801784:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801787:	8b 45 08             	mov    0x8(%ebp),%eax
  80178a:	8b 40 0c             	mov    0xc(%eax),%eax
  80178d:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  801792:	8b 45 10             	mov    0x10(%ebp),%eax
  801795:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  80179a:	ba 00 00 00 00       	mov    $0x0,%edx
  80179f:	b8 03 00 00 00       	mov    $0x3,%eax
  8017a4:	e8 5f fe ff ff       	call   801608 <fsipc>
  8017a9:	89 c3                	mov    %eax,%ebx
  8017ab:	85 c0                	test   %eax,%eax
  8017ad:	78 17                	js     8017c6 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017b3:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8017ba:	00 
  8017bb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017be:	89 04 24             	mov    %eax,(%esp)
  8017c1:	e8 7f f2 ff ff       	call   800a45 <memmove>
  return r;	
}
  8017c6:	89 d8                	mov    %ebx,%eax
  8017c8:	83 c4 14             	add    $0x14,%esp
  8017cb:	5b                   	pop    %ebx
  8017cc:	5d                   	pop    %ebp
  8017cd:	c3                   	ret    

008017ce <remove>:
}

// Delete a file
int
remove(const char *path)
{
  8017ce:	55                   	push   %ebp
  8017cf:	89 e5                	mov    %esp,%ebp
  8017d1:	53                   	push   %ebx
  8017d2:	83 ec 14             	sub    $0x14,%esp
  8017d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8017d8:	89 1c 24             	mov    %ebx,(%esp)
  8017db:	e8 30 f0 ff ff       	call   800810 <strlen>
  8017e0:	89 c2                	mov    %eax,%edx
  8017e2:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  8017e7:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  8017ed:	7f 1f                	jg     80180e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  8017ef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017f3:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8017fa:	e8 5b f0 ff ff       	call   80085a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  8017ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801804:	b8 07 00 00 00       	mov    $0x7,%eax
  801809:	e8 fa fd ff ff       	call   801608 <fsipc>
}
  80180e:	83 c4 14             	add    $0x14,%esp
  801811:	5b                   	pop    %ebx
  801812:	5d                   	pop    %ebp
  801813:	c3                   	ret    

00801814 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801814:	55                   	push   %ebp
  801815:	89 e5                	mov    %esp,%ebp
  801817:	83 ec 28             	sub    $0x28,%esp
  80181a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80181d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801820:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801823:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801826:	89 04 24             	mov    %eax,(%esp)
  801829:	e8 dd f7 ff ff       	call   80100b <fd_alloc>
  80182e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801830:	85 c0                	test   %eax,%eax
  801832:	0f 88 89 00 00 00    	js     8018c1 <open+0xad>

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801838:	89 34 24             	mov    %esi,(%esp)
  80183b:	e8 d0 ef ff ff       	call   800810 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801840:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801845:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80184a:	7f 75                	jg     8018c1 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  80184c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801850:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801857:	e8 fe ef ff ff       	call   80085a <strcpy>
  fsipcbuf.open.req_omode = mode;
  80185c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185f:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  801864:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801867:	b8 01 00 00 00       	mov    $0x1,%eax
  80186c:	e8 97 fd ff ff       	call   801608 <fsipc>
  801871:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801873:	85 c0                	test   %eax,%eax
  801875:	78 0f                	js     801886 <open+0x72>
  return fd2num(fd);
  801877:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80187a:	89 04 24             	mov    %eax,(%esp)
  80187d:	e8 5e f7 ff ff       	call   800fe0 <fd2num>
  801882:	89 c3                	mov    %eax,%ebx
  801884:	eb 3b                	jmp    8018c1 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801886:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80188d:	00 
  80188e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801891:	89 04 24             	mov    %eax,(%esp)
  801894:	e8 2b fb ff ff       	call   8013c4 <fd_close>
  801899:	85 c0                	test   %eax,%eax
  80189b:	74 24                	je     8018c1 <open+0xad>
  80189d:	c7 44 24 0c 50 21 80 	movl   $0x802150,0xc(%esp)
  8018a4:	00 
  8018a5:	c7 44 24 08 65 21 80 	movl   $0x802165,0x8(%esp)
  8018ac:	00 
  8018ad:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  8018b4:	00 
  8018b5:	c7 04 24 7a 21 80 00 	movl   $0x80217a,(%esp)
  8018bc:	e8 0f 00 00 00       	call   8018d0 <_panic>
  return r;
}
  8018c1:	89 d8                	mov    %ebx,%eax
  8018c3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8018c6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8018c9:	89 ec                	mov    %ebp,%esp
  8018cb:	5d                   	pop    %ebp
  8018cc:	c3                   	ret    
  8018cd:	00 00                	add    %al,(%eax)
	...

008018d0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	56                   	push   %esi
  8018d4:	53                   	push   %ebx
  8018d5:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8018d8:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8018db:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8018e1:	e8 0e f6 ff ff       	call   800ef4 <sys_getenvid>
  8018e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018e9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8018ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8018f0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8018f4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8018f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018fc:	c7 04 24 88 21 80 00 	movl   $0x802188,(%esp)
  801903:	e8 19 e8 ff ff       	call   800121 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801908:	89 74 24 04          	mov    %esi,0x4(%esp)
  80190c:	8b 45 10             	mov    0x10(%ebp),%eax
  80190f:	89 04 24             	mov    %eax,(%esp)
  801912:	e8 a9 e7 ff ff       	call   8000c0 <vcprintf>
	cprintf("\n");
  801917:	c7 04 24 44 21 80 00 	movl   $0x802144,(%esp)
  80191e:	e8 fe e7 ff ff       	call   800121 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801923:	cc                   	int3   
  801924:	eb fd                	jmp    801923 <_panic+0x53>
	...

00801930 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801930:	55                   	push   %ebp
  801931:	89 e5                	mov    %esp,%ebp
  801933:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801936:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80193c:	b8 01 00 00 00       	mov    $0x1,%eax
  801941:	39 ca                	cmp    %ecx,%edx
  801943:	75 04                	jne    801949 <ipc_find_env+0x19>
  801945:	b0 00                	mov    $0x0,%al
  801947:	eb 0f                	jmp    801958 <ipc_find_env+0x28>
  801949:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80194c:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801952:	8b 12                	mov    (%edx),%edx
  801954:	39 ca                	cmp    %ecx,%edx
  801956:	75 0c                	jne    801964 <ipc_find_env+0x34>
			return envs[i].env_id;
  801958:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80195b:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  801960:	8b 00                	mov    (%eax),%eax
  801962:	eb 0e                	jmp    801972 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801964:	83 c0 01             	add    $0x1,%eax
  801967:	3d 00 04 00 00       	cmp    $0x400,%eax
  80196c:	75 db                	jne    801949 <ipc_find_env+0x19>
  80196e:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801972:	5d                   	pop    %ebp
  801973:	c3                   	ret    

00801974 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801974:	55                   	push   %ebp
  801975:	89 e5                	mov    %esp,%ebp
  801977:	57                   	push   %edi
  801978:	56                   	push   %esi
  801979:	53                   	push   %ebx
  80197a:	83 ec 1c             	sub    $0x1c,%esp
  80197d:	8b 75 08             	mov    0x8(%ebp),%esi
  801980:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801983:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801986:	85 db                	test   %ebx,%ebx
  801988:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80198d:	0f 44 d8             	cmove  %eax,%ebx
  801990:	eb 29                	jmp    8019bb <ipc_send+0x47>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
  801992:	85 c0                	test   %eax,%eax
  801994:	79 25                	jns    8019bb <ipc_send+0x47>
  801996:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801999:	74 20                	je     8019bb <ipc_send+0x47>
			panic ("ipc: sys try send failed : %e", r);
  80199b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80199f:	c7 44 24 08 ac 21 80 	movl   $0x8021ac,0x8(%esp)
  8019a6:	00 
  8019a7:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8019ae:	00 
  8019af:	c7 04 24 ca 21 80 00 	movl   $0x8021ca,(%esp)
  8019b6:	e8 15 ff ff ff       	call   8018d0 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  8019bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8019be:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019c2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019c6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8019ca:	89 34 24             	mov    %esi,(%esp)
  8019cd:	e8 29 f3 ff ff       	call   800cfb <sys_ipc_try_send>
  8019d2:	85 c0                	test   %eax,%eax
  8019d4:	75 bc                	jne    801992 <ipc_send+0x1e>
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  8019d6:	e8 a6 f4 ff ff       	call   800e81 <sys_yield>
}
  8019db:	83 c4 1c             	add    $0x1c,%esp
  8019de:	5b                   	pop    %ebx
  8019df:	5e                   	pop    %esi
  8019e0:	5f                   	pop    %edi
  8019e1:	5d                   	pop    %ebp
  8019e2:	c3                   	ret    

008019e3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019e3:	55                   	push   %ebp
  8019e4:	89 e5                	mov    %esp,%ebp
  8019e6:	83 ec 28             	sub    $0x28,%esp
  8019e9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8019ec:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8019ef:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8019f2:	8b 75 08             	mov    0x8(%ebp),%esi
  8019f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f8:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  8019fb:	85 c0                	test   %eax,%eax
  8019fd:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a02:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801a05:	89 04 24             	mov    %eax,(%esp)
  801a08:	e8 b5 f2 ff ff       	call   800cc2 <sys_ipc_recv>
  801a0d:	89 c3                	mov    %eax,%ebx
  801a0f:	85 c0                	test   %eax,%eax
  801a11:	79 2a                	jns    801a3d <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  801a13:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a17:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a1b:	c7 04 24 d4 21 80 00 	movl   $0x8021d4,(%esp)
  801a22:	e8 fa e6 ff ff       	call   800121 <cprintf>
		if(from_env_store != NULL)
  801a27:	85 f6                	test   %esi,%esi
  801a29:	74 06                	je     801a31 <ipc_recv+0x4e>
			*from_env_store = 0;
  801a2b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801a31:	85 ff                	test   %edi,%edi
  801a33:	74 2d                	je     801a62 <ipc_recv+0x7f>
			*perm_store = 0;
  801a35:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801a3b:	eb 25                	jmp    801a62 <ipc_recv+0x7f>
		return r;
	}
	if(from_env_store != NULL)
  801a3d:	85 f6                	test   %esi,%esi
  801a3f:	90                   	nop
  801a40:	74 0a                	je     801a4c <ipc_recv+0x69>
		*from_env_store = thisenv->env_ipc_from;
  801a42:	a1 04 40 80 00       	mov    0x804004,%eax
  801a47:	8b 40 74             	mov    0x74(%eax),%eax
  801a4a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801a4c:	85 ff                	test   %edi,%edi
  801a4e:	74 0a                	je     801a5a <ipc_recv+0x77>
		*perm_store = thisenv->env_ipc_perm;
  801a50:	a1 04 40 80 00       	mov    0x804004,%eax
  801a55:	8b 40 78             	mov    0x78(%eax),%eax
  801a58:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801a5a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a5f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  801a62:	89 d8                	mov    %ebx,%eax
  801a64:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801a67:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801a6a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801a6d:	89 ec                	mov    %ebp,%esp
  801a6f:	5d                   	pop    %ebp
  801a70:	c3                   	ret    
	...

00801a80 <__udivdi3>:
  801a80:	55                   	push   %ebp
  801a81:	89 e5                	mov    %esp,%ebp
  801a83:	57                   	push   %edi
  801a84:	56                   	push   %esi
  801a85:	83 ec 10             	sub    $0x10,%esp
  801a88:	8b 45 14             	mov    0x14(%ebp),%eax
  801a8b:	8b 55 08             	mov    0x8(%ebp),%edx
  801a8e:	8b 75 10             	mov    0x10(%ebp),%esi
  801a91:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a94:	85 c0                	test   %eax,%eax
  801a96:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801a99:	75 35                	jne    801ad0 <__udivdi3+0x50>
  801a9b:	39 fe                	cmp    %edi,%esi
  801a9d:	77 61                	ja     801b00 <__udivdi3+0x80>
  801a9f:	85 f6                	test   %esi,%esi
  801aa1:	75 0b                	jne    801aae <__udivdi3+0x2e>
  801aa3:	b8 01 00 00 00       	mov    $0x1,%eax
  801aa8:	31 d2                	xor    %edx,%edx
  801aaa:	f7 f6                	div    %esi
  801aac:	89 c6                	mov    %eax,%esi
  801aae:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801ab1:	31 d2                	xor    %edx,%edx
  801ab3:	89 f8                	mov    %edi,%eax
  801ab5:	f7 f6                	div    %esi
  801ab7:	89 c7                	mov    %eax,%edi
  801ab9:	89 c8                	mov    %ecx,%eax
  801abb:	f7 f6                	div    %esi
  801abd:	89 c1                	mov    %eax,%ecx
  801abf:	89 fa                	mov    %edi,%edx
  801ac1:	89 c8                	mov    %ecx,%eax
  801ac3:	83 c4 10             	add    $0x10,%esp
  801ac6:	5e                   	pop    %esi
  801ac7:	5f                   	pop    %edi
  801ac8:	5d                   	pop    %ebp
  801ac9:	c3                   	ret    
  801aca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ad0:	39 f8                	cmp    %edi,%eax
  801ad2:	77 1c                	ja     801af0 <__udivdi3+0x70>
  801ad4:	0f bd d0             	bsr    %eax,%edx
  801ad7:	83 f2 1f             	xor    $0x1f,%edx
  801ada:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801add:	75 39                	jne    801b18 <__udivdi3+0x98>
  801adf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801ae2:	0f 86 a0 00 00 00    	jbe    801b88 <__udivdi3+0x108>
  801ae8:	39 f8                	cmp    %edi,%eax
  801aea:	0f 82 98 00 00 00    	jb     801b88 <__udivdi3+0x108>
  801af0:	31 ff                	xor    %edi,%edi
  801af2:	31 c9                	xor    %ecx,%ecx
  801af4:	89 c8                	mov    %ecx,%eax
  801af6:	89 fa                	mov    %edi,%edx
  801af8:	83 c4 10             	add    $0x10,%esp
  801afb:	5e                   	pop    %esi
  801afc:	5f                   	pop    %edi
  801afd:	5d                   	pop    %ebp
  801afe:	c3                   	ret    
  801aff:	90                   	nop
  801b00:	89 d1                	mov    %edx,%ecx
  801b02:	89 fa                	mov    %edi,%edx
  801b04:	89 c8                	mov    %ecx,%eax
  801b06:	31 ff                	xor    %edi,%edi
  801b08:	f7 f6                	div    %esi
  801b0a:	89 c1                	mov    %eax,%ecx
  801b0c:	89 fa                	mov    %edi,%edx
  801b0e:	89 c8                	mov    %ecx,%eax
  801b10:	83 c4 10             	add    $0x10,%esp
  801b13:	5e                   	pop    %esi
  801b14:	5f                   	pop    %edi
  801b15:	5d                   	pop    %ebp
  801b16:	c3                   	ret    
  801b17:	90                   	nop
  801b18:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b1c:	89 f2                	mov    %esi,%edx
  801b1e:	d3 e0                	shl    %cl,%eax
  801b20:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b23:	b8 20 00 00 00       	mov    $0x20,%eax
  801b28:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801b2b:	89 c1                	mov    %eax,%ecx
  801b2d:	d3 ea                	shr    %cl,%edx
  801b2f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b33:	0b 55 ec             	or     -0x14(%ebp),%edx
  801b36:	d3 e6                	shl    %cl,%esi
  801b38:	89 c1                	mov    %eax,%ecx
  801b3a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801b3d:	89 fe                	mov    %edi,%esi
  801b3f:	d3 ee                	shr    %cl,%esi
  801b41:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b45:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801b48:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b4b:	d3 e7                	shl    %cl,%edi
  801b4d:	89 c1                	mov    %eax,%ecx
  801b4f:	d3 ea                	shr    %cl,%edx
  801b51:	09 d7                	or     %edx,%edi
  801b53:	89 f2                	mov    %esi,%edx
  801b55:	89 f8                	mov    %edi,%eax
  801b57:	f7 75 ec             	divl   -0x14(%ebp)
  801b5a:	89 d6                	mov    %edx,%esi
  801b5c:	89 c7                	mov    %eax,%edi
  801b5e:	f7 65 e8             	mull   -0x18(%ebp)
  801b61:	39 d6                	cmp    %edx,%esi
  801b63:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801b66:	72 30                	jb     801b98 <__udivdi3+0x118>
  801b68:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b6b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b6f:	d3 e2                	shl    %cl,%edx
  801b71:	39 c2                	cmp    %eax,%edx
  801b73:	73 05                	jae    801b7a <__udivdi3+0xfa>
  801b75:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801b78:	74 1e                	je     801b98 <__udivdi3+0x118>
  801b7a:	89 f9                	mov    %edi,%ecx
  801b7c:	31 ff                	xor    %edi,%edi
  801b7e:	e9 71 ff ff ff       	jmp    801af4 <__udivdi3+0x74>
  801b83:	90                   	nop
  801b84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b88:	31 ff                	xor    %edi,%edi
  801b8a:	b9 01 00 00 00       	mov    $0x1,%ecx
  801b8f:	e9 60 ff ff ff       	jmp    801af4 <__udivdi3+0x74>
  801b94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b98:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801b9b:	31 ff                	xor    %edi,%edi
  801b9d:	89 c8                	mov    %ecx,%eax
  801b9f:	89 fa                	mov    %edi,%edx
  801ba1:	83 c4 10             	add    $0x10,%esp
  801ba4:	5e                   	pop    %esi
  801ba5:	5f                   	pop    %edi
  801ba6:	5d                   	pop    %ebp
  801ba7:	c3                   	ret    
	...

00801bb0 <__umoddi3>:
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	57                   	push   %edi
  801bb4:	56                   	push   %esi
  801bb5:	83 ec 20             	sub    $0x20,%esp
  801bb8:	8b 55 14             	mov    0x14(%ebp),%edx
  801bbb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bbe:	8b 7d 10             	mov    0x10(%ebp),%edi
  801bc1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bc4:	85 d2                	test   %edx,%edx
  801bc6:	89 c8                	mov    %ecx,%eax
  801bc8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801bcb:	75 13                	jne    801be0 <__umoddi3+0x30>
  801bcd:	39 f7                	cmp    %esi,%edi
  801bcf:	76 3f                	jbe    801c10 <__umoddi3+0x60>
  801bd1:	89 f2                	mov    %esi,%edx
  801bd3:	f7 f7                	div    %edi
  801bd5:	89 d0                	mov    %edx,%eax
  801bd7:	31 d2                	xor    %edx,%edx
  801bd9:	83 c4 20             	add    $0x20,%esp
  801bdc:	5e                   	pop    %esi
  801bdd:	5f                   	pop    %edi
  801bde:	5d                   	pop    %ebp
  801bdf:	c3                   	ret    
  801be0:	39 f2                	cmp    %esi,%edx
  801be2:	77 4c                	ja     801c30 <__umoddi3+0x80>
  801be4:	0f bd ca             	bsr    %edx,%ecx
  801be7:	83 f1 1f             	xor    $0x1f,%ecx
  801bea:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801bed:	75 51                	jne    801c40 <__umoddi3+0x90>
  801bef:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801bf2:	0f 87 e0 00 00 00    	ja     801cd8 <__umoddi3+0x128>
  801bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfb:	29 f8                	sub    %edi,%eax
  801bfd:	19 d6                	sbb    %edx,%esi
  801bff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c05:	89 f2                	mov    %esi,%edx
  801c07:	83 c4 20             	add    $0x20,%esp
  801c0a:	5e                   	pop    %esi
  801c0b:	5f                   	pop    %edi
  801c0c:	5d                   	pop    %ebp
  801c0d:	c3                   	ret    
  801c0e:	66 90                	xchg   %ax,%ax
  801c10:	85 ff                	test   %edi,%edi
  801c12:	75 0b                	jne    801c1f <__umoddi3+0x6f>
  801c14:	b8 01 00 00 00       	mov    $0x1,%eax
  801c19:	31 d2                	xor    %edx,%edx
  801c1b:	f7 f7                	div    %edi
  801c1d:	89 c7                	mov    %eax,%edi
  801c1f:	89 f0                	mov    %esi,%eax
  801c21:	31 d2                	xor    %edx,%edx
  801c23:	f7 f7                	div    %edi
  801c25:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c28:	f7 f7                	div    %edi
  801c2a:	eb a9                	jmp    801bd5 <__umoddi3+0x25>
  801c2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c30:	89 c8                	mov    %ecx,%eax
  801c32:	89 f2                	mov    %esi,%edx
  801c34:	83 c4 20             	add    $0x20,%esp
  801c37:	5e                   	pop    %esi
  801c38:	5f                   	pop    %edi
  801c39:	5d                   	pop    %ebp
  801c3a:	c3                   	ret    
  801c3b:	90                   	nop
  801c3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c40:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c44:	d3 e2                	shl    %cl,%edx
  801c46:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801c49:	ba 20 00 00 00       	mov    $0x20,%edx
  801c4e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801c51:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801c54:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801c58:	89 fa                	mov    %edi,%edx
  801c5a:	d3 ea                	shr    %cl,%edx
  801c5c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c60:	0b 55 f4             	or     -0xc(%ebp),%edx
  801c63:	d3 e7                	shl    %cl,%edi
  801c65:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801c69:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801c6c:	89 f2                	mov    %esi,%edx
  801c6e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801c71:	89 c7                	mov    %eax,%edi
  801c73:	d3 ea                	shr    %cl,%edx
  801c75:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c79:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801c7c:	89 c2                	mov    %eax,%edx
  801c7e:	d3 e6                	shl    %cl,%esi
  801c80:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801c84:	d3 ea                	shr    %cl,%edx
  801c86:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c8a:	09 d6                	or     %edx,%esi
  801c8c:	89 f0                	mov    %esi,%eax
  801c8e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801c91:	d3 e7                	shl    %cl,%edi
  801c93:	89 f2                	mov    %esi,%edx
  801c95:	f7 75 f4             	divl   -0xc(%ebp)
  801c98:	89 d6                	mov    %edx,%esi
  801c9a:	f7 65 e8             	mull   -0x18(%ebp)
  801c9d:	39 d6                	cmp    %edx,%esi
  801c9f:	72 2b                	jb     801ccc <__umoddi3+0x11c>
  801ca1:	39 c7                	cmp    %eax,%edi
  801ca3:	72 23                	jb     801cc8 <__umoddi3+0x118>
  801ca5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801ca9:	29 c7                	sub    %eax,%edi
  801cab:	19 d6                	sbb    %edx,%esi
  801cad:	89 f0                	mov    %esi,%eax
  801caf:	89 f2                	mov    %esi,%edx
  801cb1:	d3 ef                	shr    %cl,%edi
  801cb3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801cb7:	d3 e0                	shl    %cl,%eax
  801cb9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801cbd:	09 f8                	or     %edi,%eax
  801cbf:	d3 ea                	shr    %cl,%edx
  801cc1:	83 c4 20             	add    $0x20,%esp
  801cc4:	5e                   	pop    %esi
  801cc5:	5f                   	pop    %edi
  801cc6:	5d                   	pop    %ebp
  801cc7:	c3                   	ret    
  801cc8:	39 d6                	cmp    %edx,%esi
  801cca:	75 d9                	jne    801ca5 <__umoddi3+0xf5>
  801ccc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801ccf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801cd2:	eb d1                	jmp    801ca5 <__umoddi3+0xf5>
  801cd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cd8:	39 f2                	cmp    %esi,%edx
  801cda:	0f 82 18 ff ff ff    	jb     801bf8 <__umoddi3+0x48>
  801ce0:	e9 1d ff ff ff       	jmp    801c02 <__umoddi3+0x52>
