
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
  800043:	c7 04 24 a0 22 80 00 	movl   $0x8022a0,(%esp)
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
  800066:	e8 fc 0e 00 00       	call   800f67 <sys_getenvid>
  80006b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800070:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800073:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800078:	a3 08 40 80 00       	mov    %eax,0x804008

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
  8000aa:	e8 8a 14 00 00       	call   801539 <close_all>
	sys_env_destroy(0);
  8000af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b6:	e8 e7 0e 00 00       	call   800fa2 <sys_env_destroy>
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
  800114:	e8 fd 0e 00 00       	call   801016 <sys_cputs>

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
  800168:	e8 a9 0e 00 00       	call   801016 <sys_cputs>
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
  8001fd:	e8 1e 1e 00 00       	call   802020 <__udivdi3>
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
  800258:	e8 f3 1e 00 00       	call   802150 <__umoddi3>
  80025d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800261:	0f be 80 d1 22 80 00 	movsbl 0x8022d1(%eax),%eax
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
  800345:	ff 24 95 a0 24 80 00 	jmp    *0x8024a0(,%edx,4)
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
  800418:	8b 14 85 00 26 80 00 	mov    0x802600(,%eax,4),%edx
  80041f:	85 d2                	test   %edx,%edx
  800421:	75 20                	jne    800443 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800423:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800427:	c7 44 24 08 e2 22 80 	movl   $0x8022e2,0x8(%esp)
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
  800447:	c7 44 24 08 1b 27 80 	movl   $0x80271b,0x8(%esp)
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
  800481:	b8 eb 22 80 00       	mov    $0x8022eb,%eax
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
  8006c5:	c7 44 24 0c 04 24 80 	movl   $0x802404,0xc(%esp)
  8006cc:	00 
  8006cd:	c7 44 24 08 1b 27 80 	movl   $0x80271b,0x8(%esp)
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
  8006f3:	c7 44 24 0c 3c 24 80 	movl   $0x80243c,0xc(%esp)
  8006fa:	00 
  8006fb:	c7 44 24 08 1b 27 80 	movl   $0x80271b,0x8(%esp)
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
  800c97:	c7 44 24 08 40 26 80 	movl   $0x802640,0x8(%esp)
  800c9e:	00 
  800c9f:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800ca6:	00 
  800ca7:	c7 04 24 5d 26 80 00 	movl   $0x80265d,(%esp)
  800cae:	e8 91 11 00 00       	call   801e44 <_panic>

	return ret;
}
  800cb3:	89 d0                	mov    %edx,%eax
  800cb5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cb8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cbb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cbe:	89 ec                	mov    %ebp,%esp
  800cc0:	5d                   	pop    %ebp
  800cc1:	c3                   	ret    

00800cc2 <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  800cc2:	55                   	push   %ebp
  800cc3:	89 e5                	mov    %esp,%ebp
  800cc5:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  800cc8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ccf:	00 
  800cd0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800cd7:	00 
  800cd8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800cdf:	00 
  800ce0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ce3:	89 04 24             	mov    %eax,(%esp)
  800ce6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cee:	b8 10 00 00 00       	mov    $0x10,%eax
  800cf3:	e8 54 ff ff ff       	call   800c4c <syscall>
}
  800cf8:	c9                   	leave  
  800cf9:	c3                   	ret    

00800cfa <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  800d00:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d07:	00 
  800d08:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d0f:	00 
  800d10:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d17:	00 
  800d18:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d1f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d24:	ba 00 00 00 00       	mov    $0x0,%edx
  800d29:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d2e:	e8 19 ff ff ff       	call   800c4c <syscall>
}
  800d33:	c9                   	leave  
  800d34:	c3                   	ret    

00800d35 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d3b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d42:	00 
  800d43:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d4a:	00 
  800d4b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d52:	00 
  800d53:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d5d:	ba 01 00 00 00       	mov    $0x1,%edx
  800d62:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d67:	e8 e0 fe ff ff       	call   800c4c <syscall>
}
  800d6c:	c9                   	leave  
  800d6d:	c3                   	ret    

00800d6e <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d74:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d7b:	00 
  800d7c:	8b 45 14             	mov    0x14(%ebp),%eax
  800d7f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d83:	8b 45 10             	mov    0x10(%ebp),%eax
  800d86:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d8d:	89 04 24             	mov    %eax,(%esp)
  800d90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d93:	ba 00 00 00 00       	mov    $0x0,%edx
  800d98:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d9d:	e8 aa fe ff ff       	call   800c4c <syscall>
}
  800da2:	c9                   	leave  
  800da3:	c3                   	ret    

00800da4 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800daa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800db1:	00 
  800db2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800db9:	00 
  800dba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800dc1:	00 
  800dc2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc5:	89 04 24             	mov    %eax,(%esp)
  800dc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dcb:	ba 01 00 00 00       	mov    $0x1,%edx
  800dd0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dd5:	e8 72 fe ff ff       	call   800c4c <syscall>
}
  800dda:	c9                   	leave  
  800ddb:	c3                   	ret    

00800ddc <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800de2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800de9:	00 
  800dea:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800df1:	00 
  800df2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800df9:	00 
  800dfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dfd:	89 04 24             	mov    %eax,(%esp)
  800e00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e03:	ba 01 00 00 00       	mov    $0x1,%edx
  800e08:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e0d:	e8 3a fe ff ff       	call   800c4c <syscall>
}
  800e12:	c9                   	leave  
  800e13:	c3                   	ret    

00800e14 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800e1a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e21:	00 
  800e22:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e29:	00 
  800e2a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e31:	00 
  800e32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e35:	89 04 24             	mov    %eax,(%esp)
  800e38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3b:	ba 01 00 00 00       	mov    $0x1,%edx
  800e40:	b8 09 00 00 00       	mov    $0x9,%eax
  800e45:	e8 02 fe ff ff       	call   800c4c <syscall>
}
  800e4a:	c9                   	leave  
  800e4b:	c3                   	ret    

00800e4c <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800e52:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e59:	00 
  800e5a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e61:	00 
  800e62:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e69:	00 
  800e6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6d:	89 04 24             	mov    %eax,(%esp)
  800e70:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e73:	ba 01 00 00 00       	mov    $0x1,%edx
  800e78:	b8 07 00 00 00       	mov    $0x7,%eax
  800e7d:	e8 ca fd ff ff       	call   800c4c <syscall>
}
  800e82:	c9                   	leave  
  800e83:	c3                   	ret    

00800e84 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800e8a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e91:	00 
  800e92:	8b 45 18             	mov    0x18(%ebp),%eax
  800e95:	0b 45 14             	or     0x14(%ebp),%eax
  800e98:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e9c:	8b 45 10             	mov    0x10(%ebp),%eax
  800e9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ea3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea6:	89 04 24             	mov    %eax,(%esp)
  800ea9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eac:	ba 01 00 00 00       	mov    $0x1,%edx
  800eb1:	b8 06 00 00 00       	mov    $0x6,%eax
  800eb6:	e8 91 fd ff ff       	call   800c4c <syscall>
}
  800ebb:	c9                   	leave  
  800ebc:	c3                   	ret    

00800ebd <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ebd:	55                   	push   %ebp
  800ebe:	89 e5                	mov    %esp,%ebp
  800ec0:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800ec3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800eca:	00 
  800ecb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ed2:	00 
  800ed3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ed6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800edd:	89 04 24             	mov    %eax,(%esp)
  800ee0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee3:	ba 01 00 00 00       	mov    $0x1,%edx
  800ee8:	b8 05 00 00 00       	mov    $0x5,%eax
  800eed:	e8 5a fd ff ff       	call   800c4c <syscall>
}
  800ef2:	c9                   	leave  
  800ef3:	c3                   	ret    

00800ef4 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800efa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f01:	00 
  800f02:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f09:	00 
  800f0a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f11:	00 
  800f12:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f19:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f23:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f28:	e8 1f fd ff ff       	call   800c4c <syscall>
}
  800f2d:	c9                   	leave  
  800f2e:	c3                   	ret    

00800f2f <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800f2f:	55                   	push   %ebp
  800f30:	89 e5                	mov    %esp,%ebp
  800f32:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  800f35:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f3c:	00 
  800f3d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f44:	00 
  800f45:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f4c:	00 
  800f4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f50:	89 04 24             	mov    %eax,(%esp)
  800f53:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f56:	ba 00 00 00 00       	mov    $0x0,%edx
  800f5b:	b8 04 00 00 00       	mov    $0x4,%eax
  800f60:	e8 e7 fc ff ff       	call   800c4c <syscall>
}
  800f65:	c9                   	leave  
  800f66:	c3                   	ret    

00800f67 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800f67:	55                   	push   %ebp
  800f68:	89 e5                	mov    %esp,%ebp
  800f6a:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800f6d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f74:	00 
  800f75:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f7c:	00 
  800f7d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f84:	00 
  800f85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f8c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f91:	ba 00 00 00 00       	mov    $0x0,%edx
  800f96:	b8 02 00 00 00       	mov    $0x2,%eax
  800f9b:	e8 ac fc ff ff       	call   800c4c <syscall>
}
  800fa0:	c9                   	leave  
  800fa1:	c3                   	ret    

00800fa2 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800fa8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800faf:	00 
  800fb0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fb7:	00 
  800fb8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fbf:	00 
  800fc0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fc7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fca:	ba 01 00 00 00       	mov    $0x1,%edx
  800fcf:	b8 03 00 00 00       	mov    $0x3,%eax
  800fd4:	e8 73 fc ff ff       	call   800c4c <syscall>
}
  800fd9:	c9                   	leave  
  800fda:	c3                   	ret    

00800fdb <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800fdb:	55                   	push   %ebp
  800fdc:	89 e5                	mov    %esp,%ebp
  800fde:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800fe1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fe8:	00 
  800fe9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ff0:	00 
  800ff1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ff8:	00 
  800ff9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801000:	b9 00 00 00 00       	mov    $0x0,%ecx
  801005:	ba 00 00 00 00       	mov    $0x0,%edx
  80100a:	b8 01 00 00 00       	mov    $0x1,%eax
  80100f:	e8 38 fc ff ff       	call   800c4c <syscall>
}
  801014:	c9                   	leave  
  801015:	c3                   	ret    

00801016 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801016:	55                   	push   %ebp
  801017:	89 e5                	mov    %esp,%ebp
  801019:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80101c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801023:	00 
  801024:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80102b:	00 
  80102c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801033:	00 
  801034:	8b 45 0c             	mov    0xc(%ebp),%eax
  801037:	89 04 24             	mov    %eax,(%esp)
  80103a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80103d:	ba 00 00 00 00       	mov    $0x0,%edx
  801042:	b8 00 00 00 00       	mov    $0x0,%eax
  801047:	e8 00 fc ff ff       	call   800c4c <syscall>
}
  80104c:	c9                   	leave  
  80104d:	c3                   	ret    
	...

00801050 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801050:	55                   	push   %ebp
  801051:	89 e5                	mov    %esp,%ebp
  801053:	8b 45 08             	mov    0x8(%ebp),%eax
  801056:	05 00 00 00 30       	add    $0x30000000,%eax
  80105b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80105e:	5d                   	pop    %ebp
  80105f:	c3                   	ret    

00801060 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801066:	8b 45 08             	mov    0x8(%ebp),%eax
  801069:	89 04 24             	mov    %eax,(%esp)
  80106c:	e8 df ff ff ff       	call   801050 <fd2num>
  801071:	05 20 00 0d 00       	add    $0xd0020,%eax
  801076:	c1 e0 0c             	shl    $0xc,%eax
}
  801079:	c9                   	leave  
  80107a:	c3                   	ret    

0080107b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80107b:	55                   	push   %ebp
  80107c:	89 e5                	mov    %esp,%ebp
  80107e:	57                   	push   %edi
  80107f:	56                   	push   %esi
  801080:	53                   	push   %ebx
  801081:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801084:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801089:	a8 01                	test   $0x1,%al
  80108b:	74 36                	je     8010c3 <fd_alloc+0x48>
  80108d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801092:	a8 01                	test   $0x1,%al
  801094:	74 2d                	je     8010c3 <fd_alloc+0x48>
  801096:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80109b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  8010a0:	be 00 00 40 ef       	mov    $0xef400000,%esi
  8010a5:	89 c3                	mov    %eax,%ebx
  8010a7:	89 c2                	mov    %eax,%edx
  8010a9:	c1 ea 16             	shr    $0x16,%edx
  8010ac:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  8010af:	f6 c2 01             	test   $0x1,%dl
  8010b2:	74 14                	je     8010c8 <fd_alloc+0x4d>
  8010b4:	89 c2                	mov    %eax,%edx
  8010b6:	c1 ea 0c             	shr    $0xc,%edx
  8010b9:	8b 14 96             	mov    (%esi,%edx,4),%edx
  8010bc:	f6 c2 01             	test   $0x1,%dl
  8010bf:	75 10                	jne    8010d1 <fd_alloc+0x56>
  8010c1:	eb 05                	jmp    8010c8 <fd_alloc+0x4d>
  8010c3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8010c8:	89 1f                	mov    %ebx,(%edi)
  8010ca:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8010cf:	eb 17                	jmp    8010e8 <fd_alloc+0x6d>
  8010d1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010d6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010db:	75 c8                	jne    8010a5 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010dd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8010e3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8010e8:	5b                   	pop    %ebx
  8010e9:	5e                   	pop    %esi
  8010ea:	5f                   	pop    %edi
  8010eb:	5d                   	pop    %ebp
  8010ec:	c3                   	ret    

008010ed <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010ed:	55                   	push   %ebp
  8010ee:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f3:	83 f8 1f             	cmp    $0x1f,%eax
  8010f6:	77 36                	ja     80112e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010f8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8010fd:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801100:	89 c2                	mov    %eax,%edx
  801102:	c1 ea 16             	shr    $0x16,%edx
  801105:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80110c:	f6 c2 01             	test   $0x1,%dl
  80110f:	74 1d                	je     80112e <fd_lookup+0x41>
  801111:	89 c2                	mov    %eax,%edx
  801113:	c1 ea 0c             	shr    $0xc,%edx
  801116:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80111d:	f6 c2 01             	test   $0x1,%dl
  801120:	74 0c                	je     80112e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801122:	8b 55 0c             	mov    0xc(%ebp),%edx
  801125:	89 02                	mov    %eax,(%edx)
  801127:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80112c:	eb 05                	jmp    801133 <fd_lookup+0x46>
  80112e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801133:	5d                   	pop    %ebp
  801134:	c3                   	ret    

00801135 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801135:	55                   	push   %ebp
  801136:	89 e5                	mov    %esp,%ebp
  801138:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80113b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80113e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801142:	8b 45 08             	mov    0x8(%ebp),%eax
  801145:	89 04 24             	mov    %eax,(%esp)
  801148:	e8 a0 ff ff ff       	call   8010ed <fd_lookup>
  80114d:	85 c0                	test   %eax,%eax
  80114f:	78 0e                	js     80115f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801151:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801154:	8b 55 0c             	mov    0xc(%ebp),%edx
  801157:	89 50 04             	mov    %edx,0x4(%eax)
  80115a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80115f:	c9                   	leave  
  801160:	c3                   	ret    

00801161 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801161:	55                   	push   %ebp
  801162:	89 e5                	mov    %esp,%ebp
  801164:	56                   	push   %esi
  801165:	53                   	push   %ebx
  801166:	83 ec 10             	sub    $0x10,%esp
  801169:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80116c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80116f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801174:	b8 04 30 80 00       	mov    $0x803004,%eax
  801179:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80117f:	75 11                	jne    801192 <dev_lookup+0x31>
  801181:	eb 04                	jmp    801187 <dev_lookup+0x26>
  801183:	39 08                	cmp    %ecx,(%eax)
  801185:	75 10                	jne    801197 <dev_lookup+0x36>
			*dev = devtab[i];
  801187:	89 03                	mov    %eax,(%ebx)
  801189:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80118e:	66 90                	xchg   %ax,%ax
  801190:	eb 36                	jmp    8011c8 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801192:	be e8 26 80 00       	mov    $0x8026e8,%esi
  801197:	83 c2 01             	add    $0x1,%edx
  80119a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80119d:	85 c0                	test   %eax,%eax
  80119f:	75 e2                	jne    801183 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8011a1:	a1 08 40 80 00       	mov    0x804008,%eax
  8011a6:	8b 40 48             	mov    0x48(%eax),%eax
  8011a9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8011ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b1:	c7 04 24 6c 26 80 00 	movl   $0x80266c,(%esp)
  8011b8:	e8 64 ef ff ff       	call   800121 <cprintf>
	*dev = 0;
  8011bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8011c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8011c8:	83 c4 10             	add    $0x10,%esp
  8011cb:	5b                   	pop    %ebx
  8011cc:	5e                   	pop    %esi
  8011cd:	5d                   	pop    %ebp
  8011ce:	c3                   	ret    

008011cf <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8011cf:	55                   	push   %ebp
  8011d0:	89 e5                	mov    %esp,%ebp
  8011d2:	53                   	push   %ebx
  8011d3:	83 ec 24             	sub    $0x24,%esp
  8011d6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011e3:	89 04 24             	mov    %eax,(%esp)
  8011e6:	e8 02 ff ff ff       	call   8010ed <fd_lookup>
  8011eb:	85 c0                	test   %eax,%eax
  8011ed:	78 53                	js     801242 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f9:	8b 00                	mov    (%eax),%eax
  8011fb:	89 04 24             	mov    %eax,(%esp)
  8011fe:	e8 5e ff ff ff       	call   801161 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801203:	85 c0                	test   %eax,%eax
  801205:	78 3b                	js     801242 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801207:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80120c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80120f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801213:	74 2d                	je     801242 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801215:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801218:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80121f:	00 00 00 
	stat->st_isdir = 0;
  801222:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801229:	00 00 00 
	stat->st_dev = dev;
  80122c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80122f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801235:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801239:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80123c:	89 14 24             	mov    %edx,(%esp)
  80123f:	ff 50 14             	call   *0x14(%eax)
}
  801242:	83 c4 24             	add    $0x24,%esp
  801245:	5b                   	pop    %ebx
  801246:	5d                   	pop    %ebp
  801247:	c3                   	ret    

00801248 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801248:	55                   	push   %ebp
  801249:	89 e5                	mov    %esp,%ebp
  80124b:	53                   	push   %ebx
  80124c:	83 ec 24             	sub    $0x24,%esp
  80124f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801252:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801255:	89 44 24 04          	mov    %eax,0x4(%esp)
  801259:	89 1c 24             	mov    %ebx,(%esp)
  80125c:	e8 8c fe ff ff       	call   8010ed <fd_lookup>
  801261:	85 c0                	test   %eax,%eax
  801263:	78 5f                	js     8012c4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801265:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801268:	89 44 24 04          	mov    %eax,0x4(%esp)
  80126c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80126f:	8b 00                	mov    (%eax),%eax
  801271:	89 04 24             	mov    %eax,(%esp)
  801274:	e8 e8 fe ff ff       	call   801161 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801279:	85 c0                	test   %eax,%eax
  80127b:	78 47                	js     8012c4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80127d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801280:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801284:	75 23                	jne    8012a9 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801286:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80128b:	8b 40 48             	mov    0x48(%eax),%eax
  80128e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801292:	89 44 24 04          	mov    %eax,0x4(%esp)
  801296:	c7 04 24 8c 26 80 00 	movl   $0x80268c,(%esp)
  80129d:	e8 7f ee ff ff       	call   800121 <cprintf>
  8012a2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012a7:	eb 1b                	jmp    8012c4 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  8012a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ac:	8b 48 18             	mov    0x18(%eax),%ecx
  8012af:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012b4:	85 c9                	test   %ecx,%ecx
  8012b6:	74 0c                	je     8012c4 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012b8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012bf:	89 14 24             	mov    %edx,(%esp)
  8012c2:	ff d1                	call   *%ecx
}
  8012c4:	83 c4 24             	add    $0x24,%esp
  8012c7:	5b                   	pop    %ebx
  8012c8:	5d                   	pop    %ebp
  8012c9:	c3                   	ret    

008012ca <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012ca:	55                   	push   %ebp
  8012cb:	89 e5                	mov    %esp,%ebp
  8012cd:	53                   	push   %ebx
  8012ce:	83 ec 24             	sub    $0x24,%esp
  8012d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012db:	89 1c 24             	mov    %ebx,(%esp)
  8012de:	e8 0a fe ff ff       	call   8010ed <fd_lookup>
  8012e3:	85 c0                	test   %eax,%eax
  8012e5:	78 66                	js     80134d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012f1:	8b 00                	mov    (%eax),%eax
  8012f3:	89 04 24             	mov    %eax,(%esp)
  8012f6:	e8 66 fe ff ff       	call   801161 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012fb:	85 c0                	test   %eax,%eax
  8012fd:	78 4e                	js     80134d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012ff:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801302:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801306:	75 23                	jne    80132b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801308:	a1 08 40 80 00       	mov    0x804008,%eax
  80130d:	8b 40 48             	mov    0x48(%eax),%eax
  801310:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801314:	89 44 24 04          	mov    %eax,0x4(%esp)
  801318:	c7 04 24 ad 26 80 00 	movl   $0x8026ad,(%esp)
  80131f:	e8 fd ed ff ff       	call   800121 <cprintf>
  801324:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801329:	eb 22                	jmp    80134d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80132b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80132e:	8b 48 0c             	mov    0xc(%eax),%ecx
  801331:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801336:	85 c9                	test   %ecx,%ecx
  801338:	74 13                	je     80134d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80133a:	8b 45 10             	mov    0x10(%ebp),%eax
  80133d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801341:	8b 45 0c             	mov    0xc(%ebp),%eax
  801344:	89 44 24 04          	mov    %eax,0x4(%esp)
  801348:	89 14 24             	mov    %edx,(%esp)
  80134b:	ff d1                	call   *%ecx
}
  80134d:	83 c4 24             	add    $0x24,%esp
  801350:	5b                   	pop    %ebx
  801351:	5d                   	pop    %ebp
  801352:	c3                   	ret    

00801353 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801353:	55                   	push   %ebp
  801354:	89 e5                	mov    %esp,%ebp
  801356:	53                   	push   %ebx
  801357:	83 ec 24             	sub    $0x24,%esp
  80135a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80135d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801360:	89 44 24 04          	mov    %eax,0x4(%esp)
  801364:	89 1c 24             	mov    %ebx,(%esp)
  801367:	e8 81 fd ff ff       	call   8010ed <fd_lookup>
  80136c:	85 c0                	test   %eax,%eax
  80136e:	78 6b                	js     8013db <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801370:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801373:	89 44 24 04          	mov    %eax,0x4(%esp)
  801377:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80137a:	8b 00                	mov    (%eax),%eax
  80137c:	89 04 24             	mov    %eax,(%esp)
  80137f:	e8 dd fd ff ff       	call   801161 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801384:	85 c0                	test   %eax,%eax
  801386:	78 53                	js     8013db <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801388:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80138b:	8b 42 08             	mov    0x8(%edx),%eax
  80138e:	83 e0 03             	and    $0x3,%eax
  801391:	83 f8 01             	cmp    $0x1,%eax
  801394:	75 23                	jne    8013b9 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801396:	a1 08 40 80 00       	mov    0x804008,%eax
  80139b:	8b 40 48             	mov    0x48(%eax),%eax
  80139e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a6:	c7 04 24 ca 26 80 00 	movl   $0x8026ca,(%esp)
  8013ad:	e8 6f ed ff ff       	call   800121 <cprintf>
  8013b2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8013b7:	eb 22                	jmp    8013db <read+0x88>
	}
	if (!dev->dev_read)
  8013b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013bc:	8b 48 08             	mov    0x8(%eax),%ecx
  8013bf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013c4:	85 c9                	test   %ecx,%ecx
  8013c6:	74 13                	je     8013db <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013c8:	8b 45 10             	mov    0x10(%ebp),%eax
  8013cb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d6:	89 14 24             	mov    %edx,(%esp)
  8013d9:	ff d1                	call   *%ecx
}
  8013db:	83 c4 24             	add    $0x24,%esp
  8013de:	5b                   	pop    %ebx
  8013df:	5d                   	pop    %ebp
  8013e0:	c3                   	ret    

008013e1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013e1:	55                   	push   %ebp
  8013e2:	89 e5                	mov    %esp,%ebp
  8013e4:	57                   	push   %edi
  8013e5:	56                   	push   %esi
  8013e6:	53                   	push   %ebx
  8013e7:	83 ec 1c             	sub    $0x1c,%esp
  8013ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013ed:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8013ff:	85 f6                	test   %esi,%esi
  801401:	74 29                	je     80142c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801403:	89 f0                	mov    %esi,%eax
  801405:	29 d0                	sub    %edx,%eax
  801407:	89 44 24 08          	mov    %eax,0x8(%esp)
  80140b:	03 55 0c             	add    0xc(%ebp),%edx
  80140e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801412:	89 3c 24             	mov    %edi,(%esp)
  801415:	e8 39 ff ff ff       	call   801353 <read>
		if (m < 0)
  80141a:	85 c0                	test   %eax,%eax
  80141c:	78 0e                	js     80142c <readn+0x4b>
			return m;
		if (m == 0)
  80141e:	85 c0                	test   %eax,%eax
  801420:	74 08                	je     80142a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801422:	01 c3                	add    %eax,%ebx
  801424:	89 da                	mov    %ebx,%edx
  801426:	39 f3                	cmp    %esi,%ebx
  801428:	72 d9                	jb     801403 <readn+0x22>
  80142a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80142c:	83 c4 1c             	add    $0x1c,%esp
  80142f:	5b                   	pop    %ebx
  801430:	5e                   	pop    %esi
  801431:	5f                   	pop    %edi
  801432:	5d                   	pop    %ebp
  801433:	c3                   	ret    

00801434 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	83 ec 28             	sub    $0x28,%esp
  80143a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80143d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801440:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801443:	89 34 24             	mov    %esi,(%esp)
  801446:	e8 05 fc ff ff       	call   801050 <fd2num>
  80144b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80144e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801452:	89 04 24             	mov    %eax,(%esp)
  801455:	e8 93 fc ff ff       	call   8010ed <fd_lookup>
  80145a:	89 c3                	mov    %eax,%ebx
  80145c:	85 c0                	test   %eax,%eax
  80145e:	78 05                	js     801465 <fd_close+0x31>
  801460:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801463:	74 0e                	je     801473 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801465:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801469:	b8 00 00 00 00       	mov    $0x0,%eax
  80146e:	0f 44 d8             	cmove  %eax,%ebx
  801471:	eb 3d                	jmp    8014b0 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801473:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801476:	89 44 24 04          	mov    %eax,0x4(%esp)
  80147a:	8b 06                	mov    (%esi),%eax
  80147c:	89 04 24             	mov    %eax,(%esp)
  80147f:	e8 dd fc ff ff       	call   801161 <dev_lookup>
  801484:	89 c3                	mov    %eax,%ebx
  801486:	85 c0                	test   %eax,%eax
  801488:	78 16                	js     8014a0 <fd_close+0x6c>
		if (dev->dev_close)
  80148a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80148d:	8b 40 10             	mov    0x10(%eax),%eax
  801490:	bb 00 00 00 00       	mov    $0x0,%ebx
  801495:	85 c0                	test   %eax,%eax
  801497:	74 07                	je     8014a0 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801499:	89 34 24             	mov    %esi,(%esp)
  80149c:	ff d0                	call   *%eax
  80149e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8014a0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014ab:	e8 9c f9 ff ff       	call   800e4c <sys_page_unmap>
	return r;
}
  8014b0:	89 d8                	mov    %ebx,%eax
  8014b2:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014b5:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8014b8:	89 ec                	mov    %ebp,%esp
  8014ba:	5d                   	pop    %ebp
  8014bb:	c3                   	ret    

008014bc <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8014bc:	55                   	push   %ebp
  8014bd:	89 e5                	mov    %esp,%ebp
  8014bf:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014cc:	89 04 24             	mov    %eax,(%esp)
  8014cf:	e8 19 fc ff ff       	call   8010ed <fd_lookup>
  8014d4:	85 c0                	test   %eax,%eax
  8014d6:	78 13                	js     8014eb <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8014d8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8014df:	00 
  8014e0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014e3:	89 04 24             	mov    %eax,(%esp)
  8014e6:	e8 49 ff ff ff       	call   801434 <fd_close>
}
  8014eb:	c9                   	leave  
  8014ec:	c3                   	ret    

008014ed <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8014ed:	55                   	push   %ebp
  8014ee:	89 e5                	mov    %esp,%ebp
  8014f0:	83 ec 18             	sub    $0x18,%esp
  8014f3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8014f6:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014f9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801500:	00 
  801501:	8b 45 08             	mov    0x8(%ebp),%eax
  801504:	89 04 24             	mov    %eax,(%esp)
  801507:	e8 78 03 00 00       	call   801884 <open>
  80150c:	89 c3                	mov    %eax,%ebx
  80150e:	85 c0                	test   %eax,%eax
  801510:	78 1b                	js     80152d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801512:	8b 45 0c             	mov    0xc(%ebp),%eax
  801515:	89 44 24 04          	mov    %eax,0x4(%esp)
  801519:	89 1c 24             	mov    %ebx,(%esp)
  80151c:	e8 ae fc ff ff       	call   8011cf <fstat>
  801521:	89 c6                	mov    %eax,%esi
	close(fd);
  801523:	89 1c 24             	mov    %ebx,(%esp)
  801526:	e8 91 ff ff ff       	call   8014bc <close>
  80152b:	89 f3                	mov    %esi,%ebx
	return r;
}
  80152d:	89 d8                	mov    %ebx,%eax
  80152f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801532:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801535:	89 ec                	mov    %ebp,%esp
  801537:	5d                   	pop    %ebp
  801538:	c3                   	ret    

00801539 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801539:	55                   	push   %ebp
  80153a:	89 e5                	mov    %esp,%ebp
  80153c:	53                   	push   %ebx
  80153d:	83 ec 14             	sub    $0x14,%esp
  801540:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801545:	89 1c 24             	mov    %ebx,(%esp)
  801548:	e8 6f ff ff ff       	call   8014bc <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80154d:	83 c3 01             	add    $0x1,%ebx
  801550:	83 fb 20             	cmp    $0x20,%ebx
  801553:	75 f0                	jne    801545 <close_all+0xc>
		close(i);
}
  801555:	83 c4 14             	add    $0x14,%esp
  801558:	5b                   	pop    %ebx
  801559:	5d                   	pop    %ebp
  80155a:	c3                   	ret    

0080155b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80155b:	55                   	push   %ebp
  80155c:	89 e5                	mov    %esp,%ebp
  80155e:	83 ec 58             	sub    $0x58,%esp
  801561:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801564:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801567:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80156a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80156d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801570:	89 44 24 04          	mov    %eax,0x4(%esp)
  801574:	8b 45 08             	mov    0x8(%ebp),%eax
  801577:	89 04 24             	mov    %eax,(%esp)
  80157a:	e8 6e fb ff ff       	call   8010ed <fd_lookup>
  80157f:	89 c3                	mov    %eax,%ebx
  801581:	85 c0                	test   %eax,%eax
  801583:	0f 88 e0 00 00 00    	js     801669 <dup+0x10e>
		return r;
	close(newfdnum);
  801589:	89 3c 24             	mov    %edi,(%esp)
  80158c:	e8 2b ff ff ff       	call   8014bc <close>

	newfd = INDEX2FD(newfdnum);
  801591:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801597:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80159a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80159d:	89 04 24             	mov    %eax,(%esp)
  8015a0:	e8 bb fa ff ff       	call   801060 <fd2data>
  8015a5:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015a7:	89 34 24             	mov    %esi,(%esp)
  8015aa:	e8 b1 fa ff ff       	call   801060 <fd2data>
  8015af:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  8015b2:	89 da                	mov    %ebx,%edx
  8015b4:	89 d8                	mov    %ebx,%eax
  8015b6:	c1 e8 16             	shr    $0x16,%eax
  8015b9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015c0:	a8 01                	test   $0x1,%al
  8015c2:	74 43                	je     801607 <dup+0xac>
  8015c4:	c1 ea 0c             	shr    $0xc,%edx
  8015c7:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8015ce:	a8 01                	test   $0x1,%al
  8015d0:	74 35                	je     801607 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015d2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8015d9:	25 07 0e 00 00       	and    $0xe07,%eax
  8015de:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015e2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015e5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015e9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015f0:	00 
  8015f1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015f5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015fc:	e8 83 f8 ff ff       	call   800e84 <sys_page_map>
  801601:	89 c3                	mov    %eax,%ebx
  801603:	85 c0                	test   %eax,%eax
  801605:	78 3f                	js     801646 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801607:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80160a:	89 c2                	mov    %eax,%edx
  80160c:	c1 ea 0c             	shr    $0xc,%edx
  80160f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801616:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80161c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801620:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801624:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80162b:	00 
  80162c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801630:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801637:	e8 48 f8 ff ff       	call   800e84 <sys_page_map>
  80163c:	89 c3                	mov    %eax,%ebx
  80163e:	85 c0                	test   %eax,%eax
  801640:	78 04                	js     801646 <dup+0xeb>
  801642:	89 fb                	mov    %edi,%ebx
  801644:	eb 23                	jmp    801669 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801646:	89 74 24 04          	mov    %esi,0x4(%esp)
  80164a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801651:	e8 f6 f7 ff ff       	call   800e4c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801656:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801659:	89 44 24 04          	mov    %eax,0x4(%esp)
  80165d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801664:	e8 e3 f7 ff ff       	call   800e4c <sys_page_unmap>
	return r;
}
  801669:	89 d8                	mov    %ebx,%eax
  80166b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80166e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801671:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801674:	89 ec                	mov    %ebp,%esp
  801676:	5d                   	pop    %ebp
  801677:	c3                   	ret    

00801678 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801678:	55                   	push   %ebp
  801679:	89 e5                	mov    %esp,%ebp
  80167b:	83 ec 18             	sub    $0x18,%esp
  80167e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801681:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801684:	89 c3                	mov    %eax,%ebx
  801686:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801688:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80168f:	75 11                	jne    8016a2 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801691:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801698:	e8 03 08 00 00       	call   801ea0 <ipc_find_env>
  80169d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8016a2:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  8016a9:	00 
  8016aa:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  8016b1:	00 
  8016b2:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016b6:	a1 00 40 80 00       	mov    0x804000,%eax
  8016bb:	89 04 24             	mov    %eax,(%esp)
  8016be:	e8 21 08 00 00       	call   801ee4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016c3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016ca:	00 
  8016cb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016cf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016d6:	e8 74 08 00 00       	call   801f4f <ipc_recv>
}
  8016db:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8016de:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8016e1:	89 ec                	mov    %ebp,%esp
  8016e3:	5d                   	pop    %ebp
  8016e4:	c3                   	ret    

008016e5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016e5:	55                   	push   %ebp
  8016e6:	89 e5                	mov    %esp,%ebp
  8016e8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ee:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016f9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801703:	b8 02 00 00 00       	mov    $0x2,%eax
  801708:	e8 6b ff ff ff       	call   801678 <fsipc>
}
  80170d:	c9                   	leave  
  80170e:	c3                   	ret    

0080170f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80170f:	55                   	push   %ebp
  801710:	89 e5                	mov    %esp,%ebp
  801712:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801715:	8b 45 08             	mov    0x8(%ebp),%eax
  801718:	8b 40 0c             	mov    0xc(%eax),%eax
  80171b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801720:	ba 00 00 00 00       	mov    $0x0,%edx
  801725:	b8 06 00 00 00       	mov    $0x6,%eax
  80172a:	e8 49 ff ff ff       	call   801678 <fsipc>
}
  80172f:	c9                   	leave  
  801730:	c3                   	ret    

00801731 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801731:	55                   	push   %ebp
  801732:	89 e5                	mov    %esp,%ebp
  801734:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801737:	ba 00 00 00 00       	mov    $0x0,%edx
  80173c:	b8 08 00 00 00       	mov    $0x8,%eax
  801741:	e8 32 ff ff ff       	call   801678 <fsipc>
}
  801746:	c9                   	leave  
  801747:	c3                   	ret    

00801748 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801748:	55                   	push   %ebp
  801749:	89 e5                	mov    %esp,%ebp
  80174b:	53                   	push   %ebx
  80174c:	83 ec 14             	sub    $0x14,%esp
  80174f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801752:	8b 45 08             	mov    0x8(%ebp),%eax
  801755:	8b 40 0c             	mov    0xc(%eax),%eax
  801758:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80175d:	ba 00 00 00 00       	mov    $0x0,%edx
  801762:	b8 05 00 00 00       	mov    $0x5,%eax
  801767:	e8 0c ff ff ff       	call   801678 <fsipc>
  80176c:	85 c0                	test   %eax,%eax
  80176e:	78 2b                	js     80179b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801770:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801777:	00 
  801778:	89 1c 24             	mov    %ebx,(%esp)
  80177b:	e8 da f0 ff ff       	call   80085a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801780:	a1 80 50 80 00       	mov    0x805080,%eax
  801785:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80178b:	a1 84 50 80 00       	mov    0x805084,%eax
  801790:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801796:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80179b:	83 c4 14             	add    $0x14,%esp
  80179e:	5b                   	pop    %ebx
  80179f:	5d                   	pop    %ebp
  8017a0:	c3                   	ret    

008017a1 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8017a1:	55                   	push   %ebp
  8017a2:	89 e5                	mov    %esp,%ebp
  8017a4:	83 ec 18             	sub    $0x18,%esp
  8017a7:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  8017aa:	8b 55 08             	mov    0x8(%ebp),%edx
  8017ad:	8b 52 0c             	mov    0xc(%edx),%edx
  8017b0:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  8017b6:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  8017bb:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017c0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017c5:	0f 47 c2             	cmova  %edx,%eax
  8017c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d3:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8017da:	e8 66 f2 ff ff       	call   800a45 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  8017df:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e4:	b8 04 00 00 00       	mov    $0x4,%eax
  8017e9:	e8 8a fe ff ff       	call   801678 <fsipc>
}
  8017ee:	c9                   	leave  
  8017ef:	c3                   	ret    

008017f0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	53                   	push   %ebx
  8017f4:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fa:	8b 40 0c             	mov    0xc(%eax),%eax
  8017fd:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  801802:	8b 45 10             	mov    0x10(%ebp),%eax
  801805:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  80180a:	ba 00 00 00 00       	mov    $0x0,%edx
  80180f:	b8 03 00 00 00       	mov    $0x3,%eax
  801814:	e8 5f fe ff ff       	call   801678 <fsipc>
  801819:	89 c3                	mov    %eax,%ebx
  80181b:	85 c0                	test   %eax,%eax
  80181d:	78 17                	js     801836 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80181f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801823:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80182a:	00 
  80182b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80182e:	89 04 24             	mov    %eax,(%esp)
  801831:	e8 0f f2 ff ff       	call   800a45 <memmove>
  return r;	
}
  801836:	89 d8                	mov    %ebx,%eax
  801838:	83 c4 14             	add    $0x14,%esp
  80183b:	5b                   	pop    %ebx
  80183c:	5d                   	pop    %ebp
  80183d:	c3                   	ret    

0080183e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	53                   	push   %ebx
  801842:	83 ec 14             	sub    $0x14,%esp
  801845:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801848:	89 1c 24             	mov    %ebx,(%esp)
  80184b:	e8 c0 ef ff ff       	call   800810 <strlen>
  801850:	89 c2                	mov    %eax,%edx
  801852:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801857:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  80185d:	7f 1f                	jg     80187e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  80185f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801863:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80186a:	e8 eb ef ff ff       	call   80085a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  80186f:	ba 00 00 00 00       	mov    $0x0,%edx
  801874:	b8 07 00 00 00       	mov    $0x7,%eax
  801879:	e8 fa fd ff ff       	call   801678 <fsipc>
}
  80187e:	83 c4 14             	add    $0x14,%esp
  801881:	5b                   	pop    %ebx
  801882:	5d                   	pop    %ebp
  801883:	c3                   	ret    

00801884 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801884:	55                   	push   %ebp
  801885:	89 e5                	mov    %esp,%ebp
  801887:	83 ec 28             	sub    $0x28,%esp
  80188a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80188d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801890:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801893:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801896:	89 04 24             	mov    %eax,(%esp)
  801899:	e8 dd f7 ff ff       	call   80107b <fd_alloc>
  80189e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  8018a0:	85 c0                	test   %eax,%eax
  8018a2:	0f 88 89 00 00 00    	js     801931 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  8018a8:	89 34 24             	mov    %esi,(%esp)
  8018ab:	e8 60 ef ff ff       	call   800810 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  8018b0:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  8018b5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018ba:	7f 75                	jg     801931 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  8018bc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018c0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8018c7:	e8 8e ef ff ff       	call   80085a <strcpy>
  fsipcbuf.open.req_omode = mode;
  8018cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018cf:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  8018d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8018dc:	e8 97 fd ff ff       	call   801678 <fsipc>
  8018e1:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  8018e3:	85 c0                	test   %eax,%eax
  8018e5:	78 0f                	js     8018f6 <open+0x72>
  return fd2num(fd);
  8018e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ea:	89 04 24             	mov    %eax,(%esp)
  8018ed:	e8 5e f7 ff ff       	call   801050 <fd2num>
  8018f2:	89 c3                	mov    %eax,%ebx
  8018f4:	eb 3b                	jmp    801931 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  8018f6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8018fd:	00 
  8018fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801901:	89 04 24             	mov    %eax,(%esp)
  801904:	e8 2b fb ff ff       	call   801434 <fd_close>
  801909:	85 c0                	test   %eax,%eax
  80190b:	74 24                	je     801931 <open+0xad>
  80190d:	c7 44 24 0c f4 26 80 	movl   $0x8026f4,0xc(%esp)
  801914:	00 
  801915:	c7 44 24 08 09 27 80 	movl   $0x802709,0x8(%esp)
  80191c:	00 
  80191d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801924:	00 
  801925:	c7 04 24 1e 27 80 00 	movl   $0x80271e,(%esp)
  80192c:	e8 13 05 00 00       	call   801e44 <_panic>
  return r;
}
  801931:	89 d8                	mov    %ebx,%eax
  801933:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801936:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801939:	89 ec                	mov    %ebp,%esp
  80193b:	5d                   	pop    %ebp
  80193c:	c3                   	ret    
  80193d:	00 00                	add    %al,(%eax)
	...

00801940 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801946:	c7 44 24 04 29 27 80 	movl   $0x802729,0x4(%esp)
  80194d:	00 
  80194e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801951:	89 04 24             	mov    %eax,(%esp)
  801954:	e8 01 ef ff ff       	call   80085a <strcpy>
	return 0;
}
  801959:	b8 00 00 00 00       	mov    $0x0,%eax
  80195e:	c9                   	leave  
  80195f:	c3                   	ret    

00801960 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801960:	55                   	push   %ebp
  801961:	89 e5                	mov    %esp,%ebp
  801963:	53                   	push   %ebx
  801964:	83 ec 14             	sub    $0x14,%esp
  801967:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  80196a:	89 1c 24             	mov    %ebx,(%esp)
  80196d:	e8 6a 06 00 00       	call   801fdc <pageref>
  801972:	89 c2                	mov    %eax,%edx
  801974:	b8 00 00 00 00       	mov    $0x0,%eax
  801979:	83 fa 01             	cmp    $0x1,%edx
  80197c:	75 0b                	jne    801989 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80197e:	8b 43 0c             	mov    0xc(%ebx),%eax
  801981:	89 04 24             	mov    %eax,(%esp)
  801984:	e8 b9 02 00 00       	call   801c42 <nsipc_close>
	else
		return 0;
}
  801989:	83 c4 14             	add    $0x14,%esp
  80198c:	5b                   	pop    %ebx
  80198d:	5d                   	pop    %ebp
  80198e:	c3                   	ret    

0080198f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80198f:	55                   	push   %ebp
  801990:	89 e5                	mov    %esp,%ebp
  801992:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801995:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80199c:	00 
  80199d:	8b 45 10             	mov    0x10(%ebp),%eax
  8019a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8019b1:	89 04 24             	mov    %eax,(%esp)
  8019b4:	e8 c5 02 00 00       	call   801c7e <nsipc_send>
}
  8019b9:	c9                   	leave  
  8019ba:	c3                   	ret    

008019bb <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8019bb:	55                   	push   %ebp
  8019bc:	89 e5                	mov    %esp,%ebp
  8019be:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019c1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8019c8:	00 
  8019c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8019cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019da:	8b 40 0c             	mov    0xc(%eax),%eax
  8019dd:	89 04 24             	mov    %eax,(%esp)
  8019e0:	e8 0c 03 00 00       	call   801cf1 <nsipc_recv>
}
  8019e5:	c9                   	leave  
  8019e6:	c3                   	ret    

008019e7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  8019e7:	55                   	push   %ebp
  8019e8:	89 e5                	mov    %esp,%ebp
  8019ea:	56                   	push   %esi
  8019eb:	53                   	push   %ebx
  8019ec:	83 ec 20             	sub    $0x20,%esp
  8019ef:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8019f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f4:	89 04 24             	mov    %eax,(%esp)
  8019f7:	e8 7f f6 ff ff       	call   80107b <fd_alloc>
  8019fc:	89 c3                	mov    %eax,%ebx
  8019fe:	85 c0                	test   %eax,%eax
  801a00:	78 21                	js     801a23 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a02:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801a09:	00 
  801a0a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a0d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a11:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a18:	e8 a0 f4 ff ff       	call   800ebd <sys_page_alloc>
  801a1d:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a1f:	85 c0                	test   %eax,%eax
  801a21:	79 0a                	jns    801a2d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  801a23:	89 34 24             	mov    %esi,(%esp)
  801a26:	e8 17 02 00 00       	call   801c42 <nsipc_close>
		return r;
  801a2b:	eb 28                	jmp    801a55 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a2d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a36:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a38:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a3b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a45:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a4b:	89 04 24             	mov    %eax,(%esp)
  801a4e:	e8 fd f5 ff ff       	call   801050 <fd2num>
  801a53:	89 c3                	mov    %eax,%ebx
}
  801a55:	89 d8                	mov    %ebx,%eax
  801a57:	83 c4 20             	add    $0x20,%esp
  801a5a:	5b                   	pop    %ebx
  801a5b:	5e                   	pop    %esi
  801a5c:	5d                   	pop    %ebp
  801a5d:	c3                   	ret    

00801a5e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801a5e:	55                   	push   %ebp
  801a5f:	89 e5                	mov    %esp,%ebp
  801a61:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a64:	8b 45 10             	mov    0x10(%ebp),%eax
  801a67:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a6e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a72:	8b 45 08             	mov    0x8(%ebp),%eax
  801a75:	89 04 24             	mov    %eax,(%esp)
  801a78:	e8 79 01 00 00       	call   801bf6 <nsipc_socket>
  801a7d:	85 c0                	test   %eax,%eax
  801a7f:	78 05                	js     801a86 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801a81:	e8 61 ff ff ff       	call   8019e7 <alloc_sockfd>
}
  801a86:	c9                   	leave  
  801a87:	c3                   	ret    

00801a88 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a88:	55                   	push   %ebp
  801a89:	89 e5                	mov    %esp,%ebp
  801a8b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a8e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a91:	89 54 24 04          	mov    %edx,0x4(%esp)
  801a95:	89 04 24             	mov    %eax,(%esp)
  801a98:	e8 50 f6 ff ff       	call   8010ed <fd_lookup>
  801a9d:	85 c0                	test   %eax,%eax
  801a9f:	78 15                	js     801ab6 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801aa1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801aa4:	8b 0a                	mov    (%edx),%ecx
  801aa6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801aab:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  801ab1:	75 03                	jne    801ab6 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801ab3:	8b 42 0c             	mov    0xc(%edx),%eax
}
  801ab6:	c9                   	leave  
  801ab7:	c3                   	ret    

00801ab8 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  801ab8:	55                   	push   %ebp
  801ab9:	89 e5                	mov    %esp,%ebp
  801abb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801abe:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac1:	e8 c2 ff ff ff       	call   801a88 <fd2sockid>
  801ac6:	85 c0                	test   %eax,%eax
  801ac8:	78 0f                	js     801ad9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801aca:	8b 55 0c             	mov    0xc(%ebp),%edx
  801acd:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ad1:	89 04 24             	mov    %eax,(%esp)
  801ad4:	e8 47 01 00 00       	call   801c20 <nsipc_listen>
}
  801ad9:	c9                   	leave  
  801ada:	c3                   	ret    

00801adb <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ae1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae4:	e8 9f ff ff ff       	call   801a88 <fd2sockid>
  801ae9:	85 c0                	test   %eax,%eax
  801aeb:	78 16                	js     801b03 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801aed:	8b 55 10             	mov    0x10(%ebp),%edx
  801af0:	89 54 24 08          	mov    %edx,0x8(%esp)
  801af4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801af7:	89 54 24 04          	mov    %edx,0x4(%esp)
  801afb:	89 04 24             	mov    %eax,(%esp)
  801afe:	e8 6e 02 00 00       	call   801d71 <nsipc_connect>
}
  801b03:	c9                   	leave  
  801b04:	c3                   	ret    

00801b05 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801b05:	55                   	push   %ebp
  801b06:	89 e5                	mov    %esp,%ebp
  801b08:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b0b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b0e:	e8 75 ff ff ff       	call   801a88 <fd2sockid>
  801b13:	85 c0                	test   %eax,%eax
  801b15:	78 0f                	js     801b26 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b17:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b1a:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b1e:	89 04 24             	mov    %eax,(%esp)
  801b21:	e8 36 01 00 00       	call   801c5c <nsipc_shutdown>
}
  801b26:	c9                   	leave  
  801b27:	c3                   	ret    

00801b28 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b28:	55                   	push   %ebp
  801b29:	89 e5                	mov    %esp,%ebp
  801b2b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b2e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b31:	e8 52 ff ff ff       	call   801a88 <fd2sockid>
  801b36:	85 c0                	test   %eax,%eax
  801b38:	78 16                	js     801b50 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801b3a:	8b 55 10             	mov    0x10(%ebp),%edx
  801b3d:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b41:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b44:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b48:	89 04 24             	mov    %eax,(%esp)
  801b4b:	e8 60 02 00 00       	call   801db0 <nsipc_bind>
}
  801b50:	c9                   	leave  
  801b51:	c3                   	ret    

00801b52 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801b52:	55                   	push   %ebp
  801b53:	89 e5                	mov    %esp,%ebp
  801b55:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b58:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5b:	e8 28 ff ff ff       	call   801a88 <fd2sockid>
  801b60:	85 c0                	test   %eax,%eax
  801b62:	78 1f                	js     801b83 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801b64:	8b 55 10             	mov    0x10(%ebp),%edx
  801b67:	89 54 24 08          	mov    %edx,0x8(%esp)
  801b6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b6e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b72:	89 04 24             	mov    %eax,(%esp)
  801b75:	e8 75 02 00 00       	call   801def <nsipc_accept>
  801b7a:	85 c0                	test   %eax,%eax
  801b7c:	78 05                	js     801b83 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801b7e:	e8 64 fe ff ff       	call   8019e7 <alloc_sockfd>
}
  801b83:	c9                   	leave  
  801b84:	c3                   	ret    
	...

00801b90 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b90:	55                   	push   %ebp
  801b91:	89 e5                	mov    %esp,%ebp
  801b93:	53                   	push   %ebx
  801b94:	83 ec 14             	sub    $0x14,%esp
  801b97:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801b99:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801ba0:	75 11                	jne    801bb3 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801ba2:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  801ba9:	e8 f2 02 00 00       	call   801ea0 <ipc_find_env>
  801bae:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bb3:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801bba:	00 
  801bbb:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801bc2:	00 
  801bc3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801bc7:	a1 04 40 80 00       	mov    0x804004,%eax
  801bcc:	89 04 24             	mov    %eax,(%esp)
  801bcf:	e8 10 03 00 00       	call   801ee4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801bd4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801bdb:	00 
  801bdc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801be3:	00 
  801be4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801beb:	e8 5f 03 00 00       	call   801f4f <ipc_recv>
}
  801bf0:	83 c4 14             	add    $0x14,%esp
  801bf3:	5b                   	pop    %ebx
  801bf4:	5d                   	pop    %ebp
  801bf5:	c3                   	ret    

00801bf6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801bf6:	55                   	push   %ebp
  801bf7:	89 e5                	mov    %esp,%ebp
  801bf9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801bfc:	8b 45 08             	mov    0x8(%ebp),%eax
  801bff:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801c04:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c07:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801c0c:	8b 45 10             	mov    0x10(%ebp),%eax
  801c0f:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801c14:	b8 09 00 00 00       	mov    $0x9,%eax
  801c19:	e8 72 ff ff ff       	call   801b90 <nsipc>
}
  801c1e:	c9                   	leave  
  801c1f:	c3                   	ret    

00801c20 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  801c20:	55                   	push   %ebp
  801c21:	89 e5                	mov    %esp,%ebp
  801c23:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801c26:	8b 45 08             	mov    0x8(%ebp),%eax
  801c29:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801c2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c31:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801c36:	b8 06 00 00 00       	mov    $0x6,%eax
  801c3b:	e8 50 ff ff ff       	call   801b90 <nsipc>
}
  801c40:	c9                   	leave  
  801c41:	c3                   	ret    

00801c42 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  801c42:	55                   	push   %ebp
  801c43:	89 e5                	mov    %esp,%ebp
  801c45:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c48:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c50:	b8 04 00 00 00       	mov    $0x4,%eax
  801c55:	e8 36 ff ff ff       	call   801b90 <nsipc>
}
  801c5a:	c9                   	leave  
  801c5b:	c3                   	ret    

00801c5c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c62:	8b 45 08             	mov    0x8(%ebp),%eax
  801c65:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c6d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c72:	b8 03 00 00 00       	mov    $0x3,%eax
  801c77:	e8 14 ff ff ff       	call   801b90 <nsipc>
}
  801c7c:	c9                   	leave  
  801c7d:	c3                   	ret    

00801c7e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c7e:	55                   	push   %ebp
  801c7f:	89 e5                	mov    %esp,%ebp
  801c81:	53                   	push   %ebx
  801c82:	83 ec 14             	sub    $0x14,%esp
  801c85:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c88:	8b 45 08             	mov    0x8(%ebp),%eax
  801c8b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801c90:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c96:	7e 24                	jle    801cbc <nsipc_send+0x3e>
  801c98:	c7 44 24 0c 35 27 80 	movl   $0x802735,0xc(%esp)
  801c9f:	00 
  801ca0:	c7 44 24 08 09 27 80 	movl   $0x802709,0x8(%esp)
  801ca7:	00 
  801ca8:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  801caf:	00 
  801cb0:	c7 04 24 41 27 80 00 	movl   $0x802741,(%esp)
  801cb7:	e8 88 01 00 00       	call   801e44 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801cbc:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801cc0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cc3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc7:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801cce:	e8 72 ed ff ff       	call   800a45 <memmove>
	nsipcbuf.send.req_size = size;
  801cd3:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801cd9:	8b 45 14             	mov    0x14(%ebp),%eax
  801cdc:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801ce1:	b8 08 00 00 00       	mov    $0x8,%eax
  801ce6:	e8 a5 fe ff ff       	call   801b90 <nsipc>
}
  801ceb:	83 c4 14             	add    $0x14,%esp
  801cee:	5b                   	pop    %ebx
  801cef:	5d                   	pop    %ebp
  801cf0:	c3                   	ret    

00801cf1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801cf1:	55                   	push   %ebp
  801cf2:	89 e5                	mov    %esp,%ebp
  801cf4:	56                   	push   %esi
  801cf5:	53                   	push   %ebx
  801cf6:	83 ec 10             	sub    $0x10,%esp
  801cf9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801cfc:	8b 45 08             	mov    0x8(%ebp),%eax
  801cff:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d04:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d0a:	8b 45 14             	mov    0x14(%ebp),%eax
  801d0d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d12:	b8 07 00 00 00       	mov    $0x7,%eax
  801d17:	e8 74 fe ff ff       	call   801b90 <nsipc>
  801d1c:	89 c3                	mov    %eax,%ebx
  801d1e:	85 c0                	test   %eax,%eax
  801d20:	78 46                	js     801d68 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801d22:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d27:	7f 04                	jg     801d2d <nsipc_recv+0x3c>
  801d29:	39 c6                	cmp    %eax,%esi
  801d2b:	7d 24                	jge    801d51 <nsipc_recv+0x60>
  801d2d:	c7 44 24 0c 4d 27 80 	movl   $0x80274d,0xc(%esp)
  801d34:	00 
  801d35:	c7 44 24 08 09 27 80 	movl   $0x802709,0x8(%esp)
  801d3c:	00 
  801d3d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801d44:	00 
  801d45:	c7 04 24 41 27 80 00 	movl   $0x802741,(%esp)
  801d4c:	e8 f3 00 00 00       	call   801e44 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d51:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d55:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801d5c:	00 
  801d5d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d60:	89 04 24             	mov    %eax,(%esp)
  801d63:	e8 dd ec ff ff       	call   800a45 <memmove>
	}

	return r;
}
  801d68:	89 d8                	mov    %ebx,%eax
  801d6a:	83 c4 10             	add    $0x10,%esp
  801d6d:	5b                   	pop    %ebx
  801d6e:	5e                   	pop    %esi
  801d6f:	5d                   	pop    %ebp
  801d70:	c3                   	ret    

00801d71 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d71:	55                   	push   %ebp
  801d72:	89 e5                	mov    %esp,%ebp
  801d74:	53                   	push   %ebx
  801d75:	83 ec 14             	sub    $0x14,%esp
  801d78:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801d7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801d83:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d87:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d8a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801d8e:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801d95:	e8 ab ec ff ff       	call   800a45 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801d9a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801da0:	b8 05 00 00 00       	mov    $0x5,%eax
  801da5:	e8 e6 fd ff ff       	call   801b90 <nsipc>
}
  801daa:	83 c4 14             	add    $0x14,%esp
  801dad:	5b                   	pop    %ebx
  801dae:	5d                   	pop    %ebp
  801daf:	c3                   	ret    

00801db0 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801db0:	55                   	push   %ebp
  801db1:	89 e5                	mov    %esp,%ebp
  801db3:	53                   	push   %ebx
  801db4:	83 ec 14             	sub    $0x14,%esp
  801db7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801dba:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbd:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801dc2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dc6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801dcd:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801dd4:	e8 6c ec ff ff       	call   800a45 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801dd9:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801ddf:	b8 02 00 00 00       	mov    $0x2,%eax
  801de4:	e8 a7 fd ff ff       	call   801b90 <nsipc>
}
  801de9:	83 c4 14             	add    $0x14,%esp
  801dec:	5b                   	pop    %ebx
  801ded:	5d                   	pop    %ebp
  801dee:	c3                   	ret    

00801def <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801def:	55                   	push   %ebp
  801df0:	89 e5                	mov    %esp,%ebp
  801df2:	83 ec 18             	sub    $0x18,%esp
  801df5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801df8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  801dfb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dfe:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e03:	b8 01 00 00 00       	mov    $0x1,%eax
  801e08:	e8 83 fd ff ff       	call   801b90 <nsipc>
  801e0d:	89 c3                	mov    %eax,%ebx
  801e0f:	85 c0                	test   %eax,%eax
  801e11:	78 25                	js     801e38 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801e13:	be 10 60 80 00       	mov    $0x806010,%esi
  801e18:	8b 06                	mov    (%esi),%eax
  801e1a:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e1e:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e25:	00 
  801e26:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e29:	89 04 24             	mov    %eax,(%esp)
  801e2c:	e8 14 ec ff ff       	call   800a45 <memmove>
		*addrlen = ret->ret_addrlen;
  801e31:	8b 16                	mov    (%esi),%edx
  801e33:	8b 45 10             	mov    0x10(%ebp),%eax
  801e36:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  801e38:	89 d8                	mov    %ebx,%eax
  801e3a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801e3d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801e40:	89 ec                	mov    %ebp,%esp
  801e42:	5d                   	pop    %ebp
  801e43:	c3                   	ret    

00801e44 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801e44:	55                   	push   %ebp
  801e45:	89 e5                	mov    %esp,%ebp
  801e47:	56                   	push   %esi
  801e48:	53                   	push   %ebx
  801e49:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801e4c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801e4f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801e55:	e8 0d f1 ff ff       	call   800f67 <sys_getenvid>
  801e5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e5d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801e61:	8b 55 08             	mov    0x8(%ebp),%edx
  801e64:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801e68:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e70:	c7 04 24 64 27 80 00 	movl   $0x802764,(%esp)
  801e77:	e8 a5 e2 ff ff       	call   800121 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801e7c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e80:	8b 45 10             	mov    0x10(%ebp),%eax
  801e83:	89 04 24             	mov    %eax,(%esp)
  801e86:	e8 35 e2 ff ff       	call   8000c0 <vcprintf>
	cprintf("\n");
  801e8b:	c7 04 24 e4 26 80 00 	movl   $0x8026e4,(%esp)
  801e92:	e8 8a e2 ff ff       	call   800121 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e97:	cc                   	int3   
  801e98:	eb fd                	jmp    801e97 <_panic+0x53>
  801e9a:	00 00                	add    %al,(%eax)
  801e9c:	00 00                	add    %al,(%eax)
	...

00801ea0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ea0:	55                   	push   %ebp
  801ea1:	89 e5                	mov    %esp,%ebp
  801ea3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801ea6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801eac:	b8 01 00 00 00       	mov    $0x1,%eax
  801eb1:	39 ca                	cmp    %ecx,%edx
  801eb3:	75 04                	jne    801eb9 <ipc_find_env+0x19>
  801eb5:	b0 00                	mov    $0x0,%al
  801eb7:	eb 0f                	jmp    801ec8 <ipc_find_env+0x28>
  801eb9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ebc:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801ec2:	8b 12                	mov    (%edx),%edx
  801ec4:	39 ca                	cmp    %ecx,%edx
  801ec6:	75 0c                	jne    801ed4 <ipc_find_env+0x34>
			return envs[i].env_id;
  801ec8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ecb:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  801ed0:	8b 00                	mov    (%eax),%eax
  801ed2:	eb 0e                	jmp    801ee2 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ed4:	83 c0 01             	add    $0x1,%eax
  801ed7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801edc:	75 db                	jne    801eb9 <ipc_find_env+0x19>
  801ede:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801ee2:	5d                   	pop    %ebp
  801ee3:	c3                   	ret    

00801ee4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ee4:	55                   	push   %ebp
  801ee5:	89 e5                	mov    %esp,%ebp
  801ee7:	57                   	push   %edi
  801ee8:	56                   	push   %esi
  801ee9:	53                   	push   %ebx
  801eea:	83 ec 1c             	sub    $0x1c,%esp
  801eed:	8b 75 08             	mov    0x8(%ebp),%esi
  801ef0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ef3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801ef6:	85 db                	test   %ebx,%ebx
  801ef8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801efd:	0f 44 d8             	cmove  %eax,%ebx
  801f00:	eb 25                	jmp    801f27 <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  801f02:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f05:	74 20                	je     801f27 <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  801f07:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f0b:	c7 44 24 08 88 27 80 	movl   $0x802788,0x8(%esp)
  801f12:	00 
  801f13:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801f1a:	00 
  801f1b:	c7 04 24 a6 27 80 00 	movl   $0x8027a6,(%esp)
  801f22:	e8 1d ff ff ff       	call   801e44 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  801f27:	8b 45 14             	mov    0x14(%ebp),%eax
  801f2a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f2e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f32:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f36:	89 34 24             	mov    %esi,(%esp)
  801f39:	e8 30 ee ff ff       	call   800d6e <sys_ipc_try_send>
  801f3e:	85 c0                	test   %eax,%eax
  801f40:	75 c0                	jne    801f02 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  801f42:	e8 ad ef ff ff       	call   800ef4 <sys_yield>
}
  801f47:	83 c4 1c             	add    $0x1c,%esp
  801f4a:	5b                   	pop    %ebx
  801f4b:	5e                   	pop    %esi
  801f4c:	5f                   	pop    %edi
  801f4d:	5d                   	pop    %ebp
  801f4e:	c3                   	ret    

00801f4f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f4f:	55                   	push   %ebp
  801f50:	89 e5                	mov    %esp,%ebp
  801f52:	83 ec 28             	sub    $0x28,%esp
  801f55:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801f58:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801f5b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801f5e:	8b 75 08             	mov    0x8(%ebp),%esi
  801f61:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f64:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801f67:	85 c0                	test   %eax,%eax
  801f69:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f6e:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801f71:	89 04 24             	mov    %eax,(%esp)
  801f74:	e8 bc ed ff ff       	call   800d35 <sys_ipc_recv>
  801f79:	89 c3                	mov    %eax,%ebx
  801f7b:	85 c0                	test   %eax,%eax
  801f7d:	79 2a                	jns    801fa9 <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  801f7f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f83:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f87:	c7 04 24 b0 27 80 00 	movl   $0x8027b0,(%esp)
  801f8e:	e8 8e e1 ff ff       	call   800121 <cprintf>
		if(from_env_store != NULL)
  801f93:	85 f6                	test   %esi,%esi
  801f95:	74 06                	je     801f9d <ipc_recv+0x4e>
			*from_env_store = 0;
  801f97:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801f9d:	85 ff                	test   %edi,%edi
  801f9f:	74 2c                	je     801fcd <ipc_recv+0x7e>
			*perm_store = 0;
  801fa1:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801fa7:	eb 24                	jmp    801fcd <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  801fa9:	85 f6                	test   %esi,%esi
  801fab:	74 0a                	je     801fb7 <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  801fad:	a1 08 40 80 00       	mov    0x804008,%eax
  801fb2:	8b 40 74             	mov    0x74(%eax),%eax
  801fb5:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801fb7:	85 ff                	test   %edi,%edi
  801fb9:	74 0a                	je     801fc5 <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  801fbb:	a1 08 40 80 00       	mov    0x804008,%eax
  801fc0:	8b 40 78             	mov    0x78(%eax),%eax
  801fc3:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801fc5:	a1 08 40 80 00       	mov    0x804008,%eax
  801fca:	8b 58 70             	mov    0x70(%eax),%ebx
}
  801fcd:	89 d8                	mov    %ebx,%eax
  801fcf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801fd2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801fd5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801fd8:	89 ec                	mov    %ebp,%esp
  801fda:	5d                   	pop    %ebp
  801fdb:	c3                   	ret    

00801fdc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801fdc:	55                   	push   %ebp
  801fdd:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  801fdf:	8b 45 08             	mov    0x8(%ebp),%eax
  801fe2:	89 c2                	mov    %eax,%edx
  801fe4:	c1 ea 16             	shr    $0x16,%edx
  801fe7:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801fee:	f6 c2 01             	test   $0x1,%dl
  801ff1:	74 20                	je     802013 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  801ff3:	c1 e8 0c             	shr    $0xc,%eax
  801ff6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801ffd:	a8 01                	test   $0x1,%al
  801fff:	74 12                	je     802013 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802001:	c1 e8 0c             	shr    $0xc,%eax
  802004:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802009:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  80200e:	0f b7 c0             	movzwl %ax,%eax
  802011:	eb 05                	jmp    802018 <pageref+0x3c>
  802013:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802018:	5d                   	pop    %ebp
  802019:	c3                   	ret    
  80201a:	00 00                	add    %al,(%eax)
  80201c:	00 00                	add    %al,(%eax)
	...

00802020 <__udivdi3>:
  802020:	55                   	push   %ebp
  802021:	89 e5                	mov    %esp,%ebp
  802023:	57                   	push   %edi
  802024:	56                   	push   %esi
  802025:	83 ec 10             	sub    $0x10,%esp
  802028:	8b 45 14             	mov    0x14(%ebp),%eax
  80202b:	8b 55 08             	mov    0x8(%ebp),%edx
  80202e:	8b 75 10             	mov    0x10(%ebp),%esi
  802031:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802034:	85 c0                	test   %eax,%eax
  802036:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802039:	75 35                	jne    802070 <__udivdi3+0x50>
  80203b:	39 fe                	cmp    %edi,%esi
  80203d:	77 61                	ja     8020a0 <__udivdi3+0x80>
  80203f:	85 f6                	test   %esi,%esi
  802041:	75 0b                	jne    80204e <__udivdi3+0x2e>
  802043:	b8 01 00 00 00       	mov    $0x1,%eax
  802048:	31 d2                	xor    %edx,%edx
  80204a:	f7 f6                	div    %esi
  80204c:	89 c6                	mov    %eax,%esi
  80204e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802051:	31 d2                	xor    %edx,%edx
  802053:	89 f8                	mov    %edi,%eax
  802055:	f7 f6                	div    %esi
  802057:	89 c7                	mov    %eax,%edi
  802059:	89 c8                	mov    %ecx,%eax
  80205b:	f7 f6                	div    %esi
  80205d:	89 c1                	mov    %eax,%ecx
  80205f:	89 fa                	mov    %edi,%edx
  802061:	89 c8                	mov    %ecx,%eax
  802063:	83 c4 10             	add    $0x10,%esp
  802066:	5e                   	pop    %esi
  802067:	5f                   	pop    %edi
  802068:	5d                   	pop    %ebp
  802069:	c3                   	ret    
  80206a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802070:	39 f8                	cmp    %edi,%eax
  802072:	77 1c                	ja     802090 <__udivdi3+0x70>
  802074:	0f bd d0             	bsr    %eax,%edx
  802077:	83 f2 1f             	xor    $0x1f,%edx
  80207a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80207d:	75 39                	jne    8020b8 <__udivdi3+0x98>
  80207f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802082:	0f 86 a0 00 00 00    	jbe    802128 <__udivdi3+0x108>
  802088:	39 f8                	cmp    %edi,%eax
  80208a:	0f 82 98 00 00 00    	jb     802128 <__udivdi3+0x108>
  802090:	31 ff                	xor    %edi,%edi
  802092:	31 c9                	xor    %ecx,%ecx
  802094:	89 c8                	mov    %ecx,%eax
  802096:	89 fa                	mov    %edi,%edx
  802098:	83 c4 10             	add    $0x10,%esp
  80209b:	5e                   	pop    %esi
  80209c:	5f                   	pop    %edi
  80209d:	5d                   	pop    %ebp
  80209e:	c3                   	ret    
  80209f:	90                   	nop
  8020a0:	89 d1                	mov    %edx,%ecx
  8020a2:	89 fa                	mov    %edi,%edx
  8020a4:	89 c8                	mov    %ecx,%eax
  8020a6:	31 ff                	xor    %edi,%edi
  8020a8:	f7 f6                	div    %esi
  8020aa:	89 c1                	mov    %eax,%ecx
  8020ac:	89 fa                	mov    %edi,%edx
  8020ae:	89 c8                	mov    %ecx,%eax
  8020b0:	83 c4 10             	add    $0x10,%esp
  8020b3:	5e                   	pop    %esi
  8020b4:	5f                   	pop    %edi
  8020b5:	5d                   	pop    %ebp
  8020b6:	c3                   	ret    
  8020b7:	90                   	nop
  8020b8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8020bc:	89 f2                	mov    %esi,%edx
  8020be:	d3 e0                	shl    %cl,%eax
  8020c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8020c3:	b8 20 00 00 00       	mov    $0x20,%eax
  8020c8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8020cb:	89 c1                	mov    %eax,%ecx
  8020cd:	d3 ea                	shr    %cl,%edx
  8020cf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8020d3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8020d6:	d3 e6                	shl    %cl,%esi
  8020d8:	89 c1                	mov    %eax,%ecx
  8020da:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8020dd:	89 fe                	mov    %edi,%esi
  8020df:	d3 ee                	shr    %cl,%esi
  8020e1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8020e5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8020e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020eb:	d3 e7                	shl    %cl,%edi
  8020ed:	89 c1                	mov    %eax,%ecx
  8020ef:	d3 ea                	shr    %cl,%edx
  8020f1:	09 d7                	or     %edx,%edi
  8020f3:	89 f2                	mov    %esi,%edx
  8020f5:	89 f8                	mov    %edi,%eax
  8020f7:	f7 75 ec             	divl   -0x14(%ebp)
  8020fa:	89 d6                	mov    %edx,%esi
  8020fc:	89 c7                	mov    %eax,%edi
  8020fe:	f7 65 e8             	mull   -0x18(%ebp)
  802101:	39 d6                	cmp    %edx,%esi
  802103:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802106:	72 30                	jb     802138 <__udivdi3+0x118>
  802108:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80210b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80210f:	d3 e2                	shl    %cl,%edx
  802111:	39 c2                	cmp    %eax,%edx
  802113:	73 05                	jae    80211a <__udivdi3+0xfa>
  802115:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802118:	74 1e                	je     802138 <__udivdi3+0x118>
  80211a:	89 f9                	mov    %edi,%ecx
  80211c:	31 ff                	xor    %edi,%edi
  80211e:	e9 71 ff ff ff       	jmp    802094 <__udivdi3+0x74>
  802123:	90                   	nop
  802124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802128:	31 ff                	xor    %edi,%edi
  80212a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80212f:	e9 60 ff ff ff       	jmp    802094 <__udivdi3+0x74>
  802134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802138:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80213b:	31 ff                	xor    %edi,%edi
  80213d:	89 c8                	mov    %ecx,%eax
  80213f:	89 fa                	mov    %edi,%edx
  802141:	83 c4 10             	add    $0x10,%esp
  802144:	5e                   	pop    %esi
  802145:	5f                   	pop    %edi
  802146:	5d                   	pop    %ebp
  802147:	c3                   	ret    
	...

00802150 <__umoddi3>:
  802150:	55                   	push   %ebp
  802151:	89 e5                	mov    %esp,%ebp
  802153:	57                   	push   %edi
  802154:	56                   	push   %esi
  802155:	83 ec 20             	sub    $0x20,%esp
  802158:	8b 55 14             	mov    0x14(%ebp),%edx
  80215b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80215e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802161:	8b 75 0c             	mov    0xc(%ebp),%esi
  802164:	85 d2                	test   %edx,%edx
  802166:	89 c8                	mov    %ecx,%eax
  802168:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80216b:	75 13                	jne    802180 <__umoddi3+0x30>
  80216d:	39 f7                	cmp    %esi,%edi
  80216f:	76 3f                	jbe    8021b0 <__umoddi3+0x60>
  802171:	89 f2                	mov    %esi,%edx
  802173:	f7 f7                	div    %edi
  802175:	89 d0                	mov    %edx,%eax
  802177:	31 d2                	xor    %edx,%edx
  802179:	83 c4 20             	add    $0x20,%esp
  80217c:	5e                   	pop    %esi
  80217d:	5f                   	pop    %edi
  80217e:	5d                   	pop    %ebp
  80217f:	c3                   	ret    
  802180:	39 f2                	cmp    %esi,%edx
  802182:	77 4c                	ja     8021d0 <__umoddi3+0x80>
  802184:	0f bd ca             	bsr    %edx,%ecx
  802187:	83 f1 1f             	xor    $0x1f,%ecx
  80218a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80218d:	75 51                	jne    8021e0 <__umoddi3+0x90>
  80218f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802192:	0f 87 e0 00 00 00    	ja     802278 <__umoddi3+0x128>
  802198:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80219b:	29 f8                	sub    %edi,%eax
  80219d:	19 d6                	sbb    %edx,%esi
  80219f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8021a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021a5:	89 f2                	mov    %esi,%edx
  8021a7:	83 c4 20             	add    $0x20,%esp
  8021aa:	5e                   	pop    %esi
  8021ab:	5f                   	pop    %edi
  8021ac:	5d                   	pop    %ebp
  8021ad:	c3                   	ret    
  8021ae:	66 90                	xchg   %ax,%ax
  8021b0:	85 ff                	test   %edi,%edi
  8021b2:	75 0b                	jne    8021bf <__umoddi3+0x6f>
  8021b4:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b9:	31 d2                	xor    %edx,%edx
  8021bb:	f7 f7                	div    %edi
  8021bd:	89 c7                	mov    %eax,%edi
  8021bf:	89 f0                	mov    %esi,%eax
  8021c1:	31 d2                	xor    %edx,%edx
  8021c3:	f7 f7                	div    %edi
  8021c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021c8:	f7 f7                	div    %edi
  8021ca:	eb a9                	jmp    802175 <__umoddi3+0x25>
  8021cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021d0:	89 c8                	mov    %ecx,%eax
  8021d2:	89 f2                	mov    %esi,%edx
  8021d4:	83 c4 20             	add    $0x20,%esp
  8021d7:	5e                   	pop    %esi
  8021d8:	5f                   	pop    %edi
  8021d9:	5d                   	pop    %ebp
  8021da:	c3                   	ret    
  8021db:	90                   	nop
  8021dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8021e4:	d3 e2                	shl    %cl,%edx
  8021e6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8021e9:	ba 20 00 00 00       	mov    $0x20,%edx
  8021ee:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8021f1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8021f4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8021f8:	89 fa                	mov    %edi,%edx
  8021fa:	d3 ea                	shr    %cl,%edx
  8021fc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802200:	0b 55 f4             	or     -0xc(%ebp),%edx
  802203:	d3 e7                	shl    %cl,%edi
  802205:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802209:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80220c:	89 f2                	mov    %esi,%edx
  80220e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802211:	89 c7                	mov    %eax,%edi
  802213:	d3 ea                	shr    %cl,%edx
  802215:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802219:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80221c:	89 c2                	mov    %eax,%edx
  80221e:	d3 e6                	shl    %cl,%esi
  802220:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802224:	d3 ea                	shr    %cl,%edx
  802226:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80222a:	09 d6                	or     %edx,%esi
  80222c:	89 f0                	mov    %esi,%eax
  80222e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802231:	d3 e7                	shl    %cl,%edi
  802233:	89 f2                	mov    %esi,%edx
  802235:	f7 75 f4             	divl   -0xc(%ebp)
  802238:	89 d6                	mov    %edx,%esi
  80223a:	f7 65 e8             	mull   -0x18(%ebp)
  80223d:	39 d6                	cmp    %edx,%esi
  80223f:	72 2b                	jb     80226c <__umoddi3+0x11c>
  802241:	39 c7                	cmp    %eax,%edi
  802243:	72 23                	jb     802268 <__umoddi3+0x118>
  802245:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802249:	29 c7                	sub    %eax,%edi
  80224b:	19 d6                	sbb    %edx,%esi
  80224d:	89 f0                	mov    %esi,%eax
  80224f:	89 f2                	mov    %esi,%edx
  802251:	d3 ef                	shr    %cl,%edi
  802253:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802257:	d3 e0                	shl    %cl,%eax
  802259:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80225d:	09 f8                	or     %edi,%eax
  80225f:	d3 ea                	shr    %cl,%edx
  802261:	83 c4 20             	add    $0x20,%esp
  802264:	5e                   	pop    %esi
  802265:	5f                   	pop    %edi
  802266:	5d                   	pop    %ebp
  802267:	c3                   	ret    
  802268:	39 d6                	cmp    %edx,%esi
  80226a:	75 d9                	jne    802245 <__umoddi3+0xf5>
  80226c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80226f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802272:	eb d1                	jmp    802245 <__umoddi3+0xf5>
  802274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802278:	39 f2                	cmp    %esi,%edx
  80227a:	0f 82 18 ff ff ff    	jb     802198 <__umoddi3+0x48>
  802280:	e9 1d ff ff ff       	jmp    8021a2 <__umoddi3+0x52>
