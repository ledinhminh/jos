
obj/user/spin.debug:     file format elf32-i386


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
  80002c:	e8 8f 00 00 00       	call   8000c0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	53                   	push   %ebx
  800044:	83 ec 14             	sub    $0x14,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  800047:	c7 04 24 00 28 80 00 	movl   $0x802800,(%esp)
  80004e:	e8 3a 01 00 00       	call   80018d <cprintf>
	if ((env = fork()) == 0) {
  800053:	e8 8a 10 00 00       	call   8010e2 <fork>
  800058:	89 c3                	mov    %eax,%ebx
  80005a:	85 c0                	test   %eax,%eax
  80005c:	75 0e                	jne    80006c <umain+0x2c>
		cprintf("I am the child.  Spinning...\n");
  80005e:	c7 04 24 78 28 80 00 	movl   $0x802878,(%esp)
  800065:	e8 23 01 00 00       	call   80018d <cprintf>
  80006a:	eb fe                	jmp    80006a <umain+0x2a>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  80006c:	c7 04 24 28 28 80 00 	movl   $0x802828,(%esp)
  800073:	e8 15 01 00 00       	call   80018d <cprintf>
	sys_yield();
  800078:	e8 e7 0e 00 00       	call   800f64 <sys_yield>
	sys_yield();
  80007d:	e8 e2 0e 00 00       	call   800f64 <sys_yield>
	sys_yield();
  800082:	e8 dd 0e 00 00       	call   800f64 <sys_yield>
	sys_yield();
  800087:	e8 d8 0e 00 00       	call   800f64 <sys_yield>
	sys_yield();
  80008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800090:	e8 cf 0e 00 00       	call   800f64 <sys_yield>
	sys_yield();
  800095:	e8 ca 0e 00 00       	call   800f64 <sys_yield>
	sys_yield();
  80009a:	e8 c5 0e 00 00       	call   800f64 <sys_yield>
	sys_yield();
  80009f:	90                   	nop
  8000a0:	e8 bf 0e 00 00       	call   800f64 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  8000a5:	c7 04 24 50 28 80 00 	movl   $0x802850,(%esp)
  8000ac:	e8 dc 00 00 00       	call   80018d <cprintf>
	sys_env_destroy(env);
  8000b1:	89 1c 24             	mov    %ebx,(%esp)
  8000b4:	e8 59 0f 00 00       	call   801012 <sys_env_destroy>
}
  8000b9:	83 c4 14             	add    $0x14,%esp
  8000bc:	5b                   	pop    %ebx
  8000bd:	5d                   	pop    %ebp
  8000be:	c3                   	ret    
	...

008000c0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	83 ec 18             	sub    $0x18,%esp
  8000c6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000c9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8000cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  8000d2:	e8 00 0f 00 00       	call   800fd7 <sys_getenvid>
  8000d7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000dc:	c1 e0 07             	shl    $0x7,%eax
  8000df:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e4:	a3 08 50 80 00       	mov    %eax,0x805008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e9:	85 f6                	test   %esi,%esi
  8000eb:	7e 07                	jle    8000f4 <libmain+0x34>
		binaryname = argv[0];
  8000ed:	8b 03                	mov    (%ebx),%eax
  8000ef:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  8000f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000f8:	89 34 24             	mov    %esi,(%esp)
  8000fb:	e8 40 ff ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  800100:	e8 0b 00 00 00       	call   800110 <exit>
}
  800105:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800108:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80010b:	89 ec                	mov    %ebp,%esp
  80010d:	5d                   	pop    %ebp
  80010e:	c3                   	ret    
	...

00800110 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800110:	55                   	push   %ebp
  800111:	89 e5                	mov    %esp,%ebp
  800113:	83 ec 18             	sub    $0x18,%esp
	close_all();
  800116:	e8 de 18 00 00       	call   8019f9 <close_all>
	sys_env_destroy(0);
  80011b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800122:	e8 eb 0e 00 00       	call   801012 <sys_env_destroy>
}
  800127:	c9                   	leave  
  800128:	c3                   	ret    
  800129:	00 00                	add    %al,(%eax)
	...

0080012c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800135:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80013c:	00 00 00 
	b.cnt = 0;
  80013f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800146:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800149:	8b 45 0c             	mov    0xc(%ebp),%eax
  80014c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800150:	8b 45 08             	mov    0x8(%ebp),%eax
  800153:	89 44 24 08          	mov    %eax,0x8(%esp)
  800157:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80015d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800161:	c7 04 24 a7 01 80 00 	movl   $0x8001a7,(%esp)
  800168:	e8 d0 01 00 00       	call   80033d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80016d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800173:	89 44 24 04          	mov    %eax,0x4(%esp)
  800177:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017d:	89 04 24             	mov    %eax,(%esp)
  800180:	e8 01 0f 00 00       	call   801086 <sys_cputs>

	return b.cnt;
}
  800185:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    

0080018d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800193:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800196:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019a:	8b 45 08             	mov    0x8(%ebp),%eax
  80019d:	89 04 24             	mov    %eax,(%esp)
  8001a0:	e8 87 ff ff ff       	call   80012c <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	53                   	push   %ebx
  8001ab:	83 ec 14             	sub    $0x14,%esp
  8001ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b1:	8b 03                	mov    (%ebx),%eax
  8001b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b6:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001ba:	83 c0 01             	add    $0x1,%eax
  8001bd:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001bf:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c4:	75 19                	jne    8001df <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001c6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001cd:	00 
  8001ce:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d1:	89 04 24             	mov    %eax,(%esp)
  8001d4:	e8 ad 0e 00 00       	call   801086 <sys_cputs>
		b->idx = 0;
  8001d9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001df:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e3:	83 c4 14             	add    $0x14,%esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5d                   	pop    %ebp
  8001e8:	c3                   	ret    
  8001e9:	00 00                	add    %al,(%eax)
  8001eb:	00 00                	add    %al,(%eax)
  8001ed:	00 00                	add    %al,(%eax)
	...

008001f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	57                   	push   %edi
  8001f4:	56                   	push   %esi
  8001f5:	53                   	push   %ebx
  8001f6:	83 ec 4c             	sub    $0x4c,%esp
  8001f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001fc:	89 d6                	mov    %edx,%esi
  8001fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800201:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800204:	8b 55 0c             	mov    0xc(%ebp),%edx
  800207:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80020a:	8b 45 10             	mov    0x10(%ebp),%eax
  80020d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800210:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800213:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800216:	b9 00 00 00 00       	mov    $0x0,%ecx
  80021b:	39 d1                	cmp    %edx,%ecx
  80021d:	72 15                	jb     800234 <printnum+0x44>
  80021f:	77 07                	ja     800228 <printnum+0x38>
  800221:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800224:	39 d0                	cmp    %edx,%eax
  800226:	76 0c                	jbe    800234 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800228:	83 eb 01             	sub    $0x1,%ebx
  80022b:	85 db                	test   %ebx,%ebx
  80022d:	8d 76 00             	lea    0x0(%esi),%esi
  800230:	7f 61                	jg     800293 <printnum+0xa3>
  800232:	eb 70                	jmp    8002a4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800234:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800238:	83 eb 01             	sub    $0x1,%ebx
  80023b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80023f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800243:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800247:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80024b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80024e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800251:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800254:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800258:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80025f:	00 
  800260:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800263:	89 04 24             	mov    %eax,(%esp)
  800266:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800269:	89 54 24 04          	mov    %edx,0x4(%esp)
  80026d:	e8 1e 23 00 00       	call   802590 <__udivdi3>
  800272:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800275:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800278:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80027c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800280:	89 04 24             	mov    %eax,(%esp)
  800283:	89 54 24 04          	mov    %edx,0x4(%esp)
  800287:	89 f2                	mov    %esi,%edx
  800289:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80028c:	e8 5f ff ff ff       	call   8001f0 <printnum>
  800291:	eb 11                	jmp    8002a4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800293:	89 74 24 04          	mov    %esi,0x4(%esp)
  800297:	89 3c 24             	mov    %edi,(%esp)
  80029a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029d:	83 eb 01             	sub    $0x1,%ebx
  8002a0:	85 db                	test   %ebx,%ebx
  8002a2:	7f ef                	jg     800293 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002a8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ba:	00 
  8002bb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002be:	89 14 24             	mov    %edx,(%esp)
  8002c1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002c4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8002c8:	e8 f3 23 00 00       	call   8026c0 <__umoddi3>
  8002cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002d1:	0f be 80 a0 28 80 00 	movsbl 0x8028a0(%eax),%eax
  8002d8:	89 04 24             	mov    %eax,(%esp)
  8002db:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002de:	83 c4 4c             	add    $0x4c,%esp
  8002e1:	5b                   	pop    %ebx
  8002e2:	5e                   	pop    %esi
  8002e3:	5f                   	pop    %edi
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e9:	83 fa 01             	cmp    $0x1,%edx
  8002ec:	7e 0e                	jle    8002fc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ee:	8b 10                	mov    (%eax),%edx
  8002f0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f3:	89 08                	mov    %ecx,(%eax)
  8002f5:	8b 02                	mov    (%edx),%eax
  8002f7:	8b 52 04             	mov    0x4(%edx),%edx
  8002fa:	eb 22                	jmp    80031e <getuint+0x38>
	else if (lflag)
  8002fc:	85 d2                	test   %edx,%edx
  8002fe:	74 10                	je     800310 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800300:	8b 10                	mov    (%eax),%edx
  800302:	8d 4a 04             	lea    0x4(%edx),%ecx
  800305:	89 08                	mov    %ecx,(%eax)
  800307:	8b 02                	mov    (%edx),%eax
  800309:	ba 00 00 00 00       	mov    $0x0,%edx
  80030e:	eb 0e                	jmp    80031e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800310:	8b 10                	mov    (%eax),%edx
  800312:	8d 4a 04             	lea    0x4(%edx),%ecx
  800315:	89 08                	mov    %ecx,(%eax)
  800317:	8b 02                	mov    (%edx),%eax
  800319:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800326:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80032a:	8b 10                	mov    (%eax),%edx
  80032c:	3b 50 04             	cmp    0x4(%eax),%edx
  80032f:	73 0a                	jae    80033b <sprintputch+0x1b>
		*b->buf++ = ch;
  800331:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800334:	88 0a                	mov    %cl,(%edx)
  800336:	83 c2 01             	add    $0x1,%edx
  800339:	89 10                	mov    %edx,(%eax)
}
  80033b:	5d                   	pop    %ebp
  80033c:	c3                   	ret    

0080033d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	57                   	push   %edi
  800341:	56                   	push   %esi
  800342:	53                   	push   %ebx
  800343:	83 ec 5c             	sub    $0x5c,%esp
  800346:	8b 7d 08             	mov    0x8(%ebp),%edi
  800349:	8b 75 0c             	mov    0xc(%ebp),%esi
  80034c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80034f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800356:	eb 11                	jmp    800369 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800358:	85 c0                	test   %eax,%eax
  80035a:	0f 84 68 04 00 00    	je     8007c8 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  800360:	89 74 24 04          	mov    %esi,0x4(%esp)
  800364:	89 04 24             	mov    %eax,(%esp)
  800367:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800369:	0f b6 03             	movzbl (%ebx),%eax
  80036c:	83 c3 01             	add    $0x1,%ebx
  80036f:	83 f8 25             	cmp    $0x25,%eax
  800372:	75 e4                	jne    800358 <vprintfmt+0x1b>
  800374:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80037b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800382:	b9 00 00 00 00       	mov    $0x0,%ecx
  800387:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  80038b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800392:	eb 06                	jmp    80039a <vprintfmt+0x5d>
  800394:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  800398:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	0f b6 13             	movzbl (%ebx),%edx
  80039d:	0f b6 c2             	movzbl %dl,%eax
  8003a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003a3:	8d 43 01             	lea    0x1(%ebx),%eax
  8003a6:	83 ea 23             	sub    $0x23,%edx
  8003a9:	80 fa 55             	cmp    $0x55,%dl
  8003ac:	0f 87 f9 03 00 00    	ja     8007ab <vprintfmt+0x46e>
  8003b2:	0f b6 d2             	movzbl %dl,%edx
  8003b5:	ff 24 95 80 2a 80 00 	jmp    *0x802a80(,%edx,4)
  8003bc:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  8003c0:	eb d6                	jmp    800398 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003c5:	83 ea 30             	sub    $0x30,%edx
  8003c8:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  8003cb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003ce:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003d1:	83 fb 09             	cmp    $0x9,%ebx
  8003d4:	77 54                	ja     80042a <vprintfmt+0xed>
  8003d6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8003d9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003dc:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8003df:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003e2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8003e6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003e9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003ec:	83 fb 09             	cmp    $0x9,%ebx
  8003ef:	76 eb                	jbe    8003dc <vprintfmt+0x9f>
  8003f1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8003f4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8003f7:	eb 31                	jmp    80042a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f9:	8b 55 14             	mov    0x14(%ebp),%edx
  8003fc:	8d 5a 04             	lea    0x4(%edx),%ebx
  8003ff:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800402:	8b 12                	mov    (%edx),%edx
  800404:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800407:	eb 21                	jmp    80042a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  800409:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80040d:	ba 00 00 00 00       	mov    $0x0,%edx
  800412:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  800416:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800419:	e9 7a ff ff ff       	jmp    800398 <vprintfmt+0x5b>
  80041e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800425:	e9 6e ff ff ff       	jmp    800398 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80042a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80042e:	0f 89 64 ff ff ff    	jns    800398 <vprintfmt+0x5b>
  800434:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800437:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80043a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80043d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800440:	e9 53 ff ff ff       	jmp    800398 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800445:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800448:	e9 4b ff ff ff       	jmp    800398 <vprintfmt+0x5b>
  80044d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800450:	8b 45 14             	mov    0x14(%ebp),%eax
  800453:	8d 50 04             	lea    0x4(%eax),%edx
  800456:	89 55 14             	mov    %edx,0x14(%ebp)
  800459:	89 74 24 04          	mov    %esi,0x4(%esp)
  80045d:	8b 00                	mov    (%eax),%eax
  80045f:	89 04 24             	mov    %eax,(%esp)
  800462:	ff d7                	call   *%edi
  800464:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800467:	e9 fd fe ff ff       	jmp    800369 <vprintfmt+0x2c>
  80046c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046f:	8b 45 14             	mov    0x14(%ebp),%eax
  800472:	8d 50 04             	lea    0x4(%eax),%edx
  800475:	89 55 14             	mov    %edx,0x14(%ebp)
  800478:	8b 00                	mov    (%eax),%eax
  80047a:	89 c2                	mov    %eax,%edx
  80047c:	c1 fa 1f             	sar    $0x1f,%edx
  80047f:	31 d0                	xor    %edx,%eax
  800481:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800483:	83 f8 0f             	cmp    $0xf,%eax
  800486:	7f 0b                	jg     800493 <vprintfmt+0x156>
  800488:	8b 14 85 e0 2b 80 00 	mov    0x802be0(,%eax,4),%edx
  80048f:	85 d2                	test   %edx,%edx
  800491:	75 20                	jne    8004b3 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800493:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800497:	c7 44 24 08 b1 28 80 	movl   $0x8028b1,0x8(%esp)
  80049e:	00 
  80049f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004a3:	89 3c 24             	mov    %edi,(%esp)
  8004a6:	e8 a5 03 00 00       	call   800850 <printfmt>
  8004ab:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ae:	e9 b6 fe ff ff       	jmp    800369 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004b3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004b7:	c7 44 24 08 37 2f 80 	movl   $0x802f37,0x8(%esp)
  8004be:	00 
  8004bf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004c3:	89 3c 24             	mov    %edi,(%esp)
  8004c6:	e8 85 03 00 00       	call   800850 <printfmt>
  8004cb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004ce:	e9 96 fe ff ff       	jmp    800369 <vprintfmt+0x2c>
  8004d3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004d6:	89 c3                	mov    %eax,%ebx
  8004d8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004db:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004de:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e4:	8d 50 04             	lea    0x4(%eax),%edx
  8004e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ea:	8b 00                	mov    (%eax),%eax
  8004ec:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ef:	85 c0                	test   %eax,%eax
  8004f1:	b8 ba 28 80 00       	mov    $0x8028ba,%eax
  8004f6:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  8004fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8004fd:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800501:	7e 06                	jle    800509 <vprintfmt+0x1cc>
  800503:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800507:	75 13                	jne    80051c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800509:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80050c:	0f be 02             	movsbl (%edx),%eax
  80050f:	85 c0                	test   %eax,%eax
  800511:	0f 85 a2 00 00 00    	jne    8005b9 <vprintfmt+0x27c>
  800517:	e9 8f 00 00 00       	jmp    8005ab <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800520:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800523:	89 0c 24             	mov    %ecx,(%esp)
  800526:	e8 70 03 00 00       	call   80089b <strnlen>
  80052b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80052e:	29 c2                	sub    %eax,%edx
  800530:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800533:	85 d2                	test   %edx,%edx
  800535:	7e d2                	jle    800509 <vprintfmt+0x1cc>
					putch(padc, putdat);
  800537:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80053b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80053e:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800541:	89 d3                	mov    %edx,%ebx
  800543:	89 74 24 04          	mov    %esi,0x4(%esp)
  800547:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80054a:	89 04 24             	mov    %eax,(%esp)
  80054d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80054f:	83 eb 01             	sub    $0x1,%ebx
  800552:	85 db                	test   %ebx,%ebx
  800554:	7f ed                	jg     800543 <vprintfmt+0x206>
  800556:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800559:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800560:	eb a7                	jmp    800509 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800562:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800566:	74 1b                	je     800583 <vprintfmt+0x246>
  800568:	8d 50 e0             	lea    -0x20(%eax),%edx
  80056b:	83 fa 5e             	cmp    $0x5e,%edx
  80056e:	76 13                	jbe    800583 <vprintfmt+0x246>
					putch('?', putdat);
  800570:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800573:	89 54 24 04          	mov    %edx,0x4(%esp)
  800577:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80057e:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800581:	eb 0d                	jmp    800590 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800583:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800586:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80058a:	89 04 24             	mov    %eax,(%esp)
  80058d:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800590:	83 ef 01             	sub    $0x1,%edi
  800593:	0f be 03             	movsbl (%ebx),%eax
  800596:	85 c0                	test   %eax,%eax
  800598:	74 05                	je     80059f <vprintfmt+0x262>
  80059a:	83 c3 01             	add    $0x1,%ebx
  80059d:	eb 31                	jmp    8005d0 <vprintfmt+0x293>
  80059f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005a8:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ab:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005af:	7f 36                	jg     8005e7 <vprintfmt+0x2aa>
  8005b1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005b4:	e9 b0 fd ff ff       	jmp    800369 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005bc:	83 c2 01             	add    $0x1,%edx
  8005bf:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005c2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005c5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005c8:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005cb:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8005ce:	89 d3                	mov    %edx,%ebx
  8005d0:	85 f6                	test   %esi,%esi
  8005d2:	78 8e                	js     800562 <vprintfmt+0x225>
  8005d4:	83 ee 01             	sub    $0x1,%esi
  8005d7:	79 89                	jns    800562 <vprintfmt+0x225>
  8005d9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005df:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005e2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8005e5:	eb c4                	jmp    8005ab <vprintfmt+0x26e>
  8005e7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8005ea:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ed:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005f8:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005fa:	83 eb 01             	sub    $0x1,%ebx
  8005fd:	85 db                	test   %ebx,%ebx
  8005ff:	7f ec                	jg     8005ed <vprintfmt+0x2b0>
  800601:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800604:	e9 60 fd ff ff       	jmp    800369 <vprintfmt+0x2c>
  800609:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80060c:	83 f9 01             	cmp    $0x1,%ecx
  80060f:	7e 16                	jle    800627 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  800611:	8b 45 14             	mov    0x14(%ebp),%eax
  800614:	8d 50 08             	lea    0x8(%eax),%edx
  800617:	89 55 14             	mov    %edx,0x14(%ebp)
  80061a:	8b 10                	mov    (%eax),%edx
  80061c:	8b 48 04             	mov    0x4(%eax),%ecx
  80061f:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800622:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800625:	eb 32                	jmp    800659 <vprintfmt+0x31c>
	else if (lflag)
  800627:	85 c9                	test   %ecx,%ecx
  800629:	74 18                	je     800643 <vprintfmt+0x306>
		return va_arg(*ap, long);
  80062b:	8b 45 14             	mov    0x14(%ebp),%eax
  80062e:	8d 50 04             	lea    0x4(%eax),%edx
  800631:	89 55 14             	mov    %edx,0x14(%ebp)
  800634:	8b 00                	mov    (%eax),%eax
  800636:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800639:	89 c1                	mov    %eax,%ecx
  80063b:	c1 f9 1f             	sar    $0x1f,%ecx
  80063e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800641:	eb 16                	jmp    800659 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8d 50 04             	lea    0x4(%eax),%edx
  800649:	89 55 14             	mov    %edx,0x14(%ebp)
  80064c:	8b 00                	mov    (%eax),%eax
  80064e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800651:	89 c2                	mov    %eax,%edx
  800653:	c1 fa 1f             	sar    $0x1f,%edx
  800656:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800659:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80065c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80065f:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  800664:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800668:	0f 89 8a 00 00 00    	jns    8006f8 <vprintfmt+0x3bb>
				putch('-', putdat);
  80066e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800672:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800679:	ff d7                	call   *%edi
				num = -(long long) num;
  80067b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80067e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800681:	f7 d8                	neg    %eax
  800683:	83 d2 00             	adc    $0x0,%edx
  800686:	f7 da                	neg    %edx
  800688:	eb 6e                	jmp    8006f8 <vprintfmt+0x3bb>
  80068a:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80068d:	89 ca                	mov    %ecx,%edx
  80068f:	8d 45 14             	lea    0x14(%ebp),%eax
  800692:	e8 4f fc ff ff       	call   8002e6 <getuint>
  800697:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  80069c:	eb 5a                	jmp    8006f8 <vprintfmt+0x3bb>
  80069e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8006a1:	89 ca                	mov    %ecx,%edx
  8006a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a6:	e8 3b fc ff ff       	call   8002e6 <getuint>
  8006ab:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  8006b0:	eb 46                	jmp    8006f8 <vprintfmt+0x3bb>
  8006b2:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  8006b5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006b9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006c0:	ff d7                	call   *%edi
			putch('x', putdat);
  8006c2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006c6:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006cd:	ff d7                	call   *%edi
			num = (unsigned long long)
  8006cf:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d2:	8d 50 04             	lea    0x4(%eax),%edx
  8006d5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d8:	8b 00                	mov    (%eax),%eax
  8006da:	ba 00 00 00 00       	mov    $0x0,%edx
  8006df:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006e4:	eb 12                	jmp    8006f8 <vprintfmt+0x3bb>
  8006e6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e9:	89 ca                	mov    %ecx,%edx
  8006eb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ee:	e8 f3 fb ff ff       	call   8002e6 <getuint>
  8006f3:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f8:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8006fc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800700:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800703:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800707:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80070b:	89 04 24             	mov    %eax,(%esp)
  80070e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800712:	89 f2                	mov    %esi,%edx
  800714:	89 f8                	mov    %edi,%eax
  800716:	e8 d5 fa ff ff       	call   8001f0 <printnum>
  80071b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80071e:	e9 46 fc ff ff       	jmp    800369 <vprintfmt+0x2c>
  800723:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  800726:	8b 45 14             	mov    0x14(%ebp),%eax
  800729:	8d 50 04             	lea    0x4(%eax),%edx
  80072c:	89 55 14             	mov    %edx,0x14(%ebp)
  80072f:	8b 00                	mov    (%eax),%eax
  800731:	85 c0                	test   %eax,%eax
  800733:	75 24                	jne    800759 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  800735:	c7 44 24 0c d4 29 80 	movl   $0x8029d4,0xc(%esp)
  80073c:	00 
  80073d:	c7 44 24 08 37 2f 80 	movl   $0x802f37,0x8(%esp)
  800744:	00 
  800745:	89 74 24 04          	mov    %esi,0x4(%esp)
  800749:	89 3c 24             	mov    %edi,(%esp)
  80074c:	e8 ff 00 00 00       	call   800850 <printfmt>
  800751:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800754:	e9 10 fc ff ff       	jmp    800369 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  800759:	83 3e 7f             	cmpl   $0x7f,(%esi)
  80075c:	7e 29                	jle    800787 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  80075e:	0f b6 16             	movzbl (%esi),%edx
  800761:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  800763:	c7 44 24 0c 0c 2a 80 	movl   $0x802a0c,0xc(%esp)
  80076a:	00 
  80076b:	c7 44 24 08 37 2f 80 	movl   $0x802f37,0x8(%esp)
  800772:	00 
  800773:	89 74 24 04          	mov    %esi,0x4(%esp)
  800777:	89 3c 24             	mov    %edi,(%esp)
  80077a:	e8 d1 00 00 00       	call   800850 <printfmt>
  80077f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800782:	e9 e2 fb ff ff       	jmp    800369 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  800787:	0f b6 16             	movzbl (%esi),%edx
  80078a:	88 10                	mov    %dl,(%eax)
  80078c:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  80078f:	e9 d5 fb ff ff       	jmp    800369 <vprintfmt+0x2c>
  800794:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800797:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80079a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80079e:	89 14 24             	mov    %edx,(%esp)
  8007a1:	ff d7                	call   *%edi
  8007a3:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8007a6:	e9 be fb ff ff       	jmp    800369 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007ab:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007af:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007b6:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007b8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8007bb:	80 38 25             	cmpb   $0x25,(%eax)
  8007be:	0f 84 a5 fb ff ff    	je     800369 <vprintfmt+0x2c>
  8007c4:	89 c3                	mov    %eax,%ebx
  8007c6:	eb f0                	jmp    8007b8 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  8007c8:	83 c4 5c             	add    $0x5c,%esp
  8007cb:	5b                   	pop    %ebx
  8007cc:	5e                   	pop    %esi
  8007cd:	5f                   	pop    %edi
  8007ce:	5d                   	pop    %ebp
  8007cf:	c3                   	ret    

008007d0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	83 ec 28             	sub    $0x28,%esp
  8007d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8007dc:	85 c0                	test   %eax,%eax
  8007de:	74 04                	je     8007e4 <vsnprintf+0x14>
  8007e0:	85 d2                	test   %edx,%edx
  8007e2:	7f 07                	jg     8007eb <vsnprintf+0x1b>
  8007e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007e9:	eb 3b                	jmp    800826 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ee:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8007f2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007f5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800803:	8b 45 10             	mov    0x10(%ebp),%eax
  800806:	89 44 24 08          	mov    %eax,0x8(%esp)
  80080a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80080d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800811:	c7 04 24 20 03 80 00 	movl   $0x800320,(%esp)
  800818:	e8 20 fb ff ff       	call   80033d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80081d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800820:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800823:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800826:	c9                   	leave  
  800827:	c3                   	ret    

00800828 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80082e:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800831:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800835:	8b 45 10             	mov    0x10(%ebp),%eax
  800838:	89 44 24 08          	mov    %eax,0x8(%esp)
  80083c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800843:	8b 45 08             	mov    0x8(%ebp),%eax
  800846:	89 04 24             	mov    %eax,(%esp)
  800849:	e8 82 ff ff ff       	call   8007d0 <vsnprintf>
	va_end(ap);

	return rc;
}
  80084e:	c9                   	leave  
  80084f:	c3                   	ret    

00800850 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800856:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800859:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80085d:	8b 45 10             	mov    0x10(%ebp),%eax
  800860:	89 44 24 08          	mov    %eax,0x8(%esp)
  800864:	8b 45 0c             	mov    0xc(%ebp),%eax
  800867:	89 44 24 04          	mov    %eax,0x4(%esp)
  80086b:	8b 45 08             	mov    0x8(%ebp),%eax
  80086e:	89 04 24             	mov    %eax,(%esp)
  800871:	e8 c7 fa ff ff       	call   80033d <vprintfmt>
	va_end(ap);
}
  800876:	c9                   	leave  
  800877:	c3                   	ret    
	...

00800880 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800886:	b8 00 00 00 00       	mov    $0x0,%eax
  80088b:	80 3a 00             	cmpb   $0x0,(%edx)
  80088e:	74 09                	je     800899 <strlen+0x19>
		n++;
  800890:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800893:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800897:	75 f7                	jne    800890 <strlen+0x10>
		n++;
	return n;
}
  800899:	5d                   	pop    %ebp
  80089a:	c3                   	ret    

0080089b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80089b:	55                   	push   %ebp
  80089c:	89 e5                	mov    %esp,%ebp
  80089e:	53                   	push   %ebx
  80089f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a5:	85 c9                	test   %ecx,%ecx
  8008a7:	74 19                	je     8008c2 <strnlen+0x27>
  8008a9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008ac:	74 14                	je     8008c2 <strnlen+0x27>
  8008ae:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008b3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b6:	39 c8                	cmp    %ecx,%eax
  8008b8:	74 0d                	je     8008c7 <strnlen+0x2c>
  8008ba:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8008be:	75 f3                	jne    8008b3 <strnlen+0x18>
  8008c0:	eb 05                	jmp    8008c7 <strnlen+0x2c>
  8008c2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008c7:	5b                   	pop    %ebx
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	53                   	push   %ebx
  8008ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008d4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008d9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008dd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008e0:	83 c2 01             	add    $0x1,%edx
  8008e3:	84 c9                	test   %cl,%cl
  8008e5:	75 f2                	jne    8008d9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008e7:	5b                   	pop    %ebx
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    

008008ea <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	53                   	push   %ebx
  8008ee:	83 ec 08             	sub    $0x8,%esp
  8008f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008f4:	89 1c 24             	mov    %ebx,(%esp)
  8008f7:	e8 84 ff ff ff       	call   800880 <strlen>
	strcpy(dst + len, src);
  8008fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ff:	89 54 24 04          	mov    %edx,0x4(%esp)
  800903:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800906:	89 04 24             	mov    %eax,(%esp)
  800909:	e8 bc ff ff ff       	call   8008ca <strcpy>
	return dst;
}
  80090e:	89 d8                	mov    %ebx,%eax
  800910:	83 c4 08             	add    $0x8,%esp
  800913:	5b                   	pop    %ebx
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800916:	55                   	push   %ebp
  800917:	89 e5                	mov    %esp,%ebp
  800919:	56                   	push   %esi
  80091a:	53                   	push   %ebx
  80091b:	8b 45 08             	mov    0x8(%ebp),%eax
  80091e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800921:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800924:	85 f6                	test   %esi,%esi
  800926:	74 18                	je     800940 <strncpy+0x2a>
  800928:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80092d:	0f b6 1a             	movzbl (%edx),%ebx
  800930:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800933:	80 3a 01             	cmpb   $0x1,(%edx)
  800936:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800939:	83 c1 01             	add    $0x1,%ecx
  80093c:	39 ce                	cmp    %ecx,%esi
  80093e:	77 ed                	ja     80092d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800940:	5b                   	pop    %ebx
  800941:	5e                   	pop    %esi
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	56                   	push   %esi
  800948:	53                   	push   %ebx
  800949:	8b 75 08             	mov    0x8(%ebp),%esi
  80094c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80094f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800952:	89 f0                	mov    %esi,%eax
  800954:	85 c9                	test   %ecx,%ecx
  800956:	74 27                	je     80097f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800958:	83 e9 01             	sub    $0x1,%ecx
  80095b:	74 1d                	je     80097a <strlcpy+0x36>
  80095d:	0f b6 1a             	movzbl (%edx),%ebx
  800960:	84 db                	test   %bl,%bl
  800962:	74 16                	je     80097a <strlcpy+0x36>
			*dst++ = *src++;
  800964:	88 18                	mov    %bl,(%eax)
  800966:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800969:	83 e9 01             	sub    $0x1,%ecx
  80096c:	74 0e                	je     80097c <strlcpy+0x38>
			*dst++ = *src++;
  80096e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800971:	0f b6 1a             	movzbl (%edx),%ebx
  800974:	84 db                	test   %bl,%bl
  800976:	75 ec                	jne    800964 <strlcpy+0x20>
  800978:	eb 02                	jmp    80097c <strlcpy+0x38>
  80097a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80097c:	c6 00 00             	movb   $0x0,(%eax)
  80097f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800981:	5b                   	pop    %ebx
  800982:	5e                   	pop    %esi
  800983:	5d                   	pop    %ebp
  800984:	c3                   	ret    

00800985 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800985:	55                   	push   %ebp
  800986:	89 e5                	mov    %esp,%ebp
  800988:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80098e:	0f b6 01             	movzbl (%ecx),%eax
  800991:	84 c0                	test   %al,%al
  800993:	74 15                	je     8009aa <strcmp+0x25>
  800995:	3a 02                	cmp    (%edx),%al
  800997:	75 11                	jne    8009aa <strcmp+0x25>
		p++, q++;
  800999:	83 c1 01             	add    $0x1,%ecx
  80099c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80099f:	0f b6 01             	movzbl (%ecx),%eax
  8009a2:	84 c0                	test   %al,%al
  8009a4:	74 04                	je     8009aa <strcmp+0x25>
  8009a6:	3a 02                	cmp    (%edx),%al
  8009a8:	74 ef                	je     800999 <strcmp+0x14>
  8009aa:	0f b6 c0             	movzbl %al,%eax
  8009ad:	0f b6 12             	movzbl (%edx),%edx
  8009b0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	53                   	push   %ebx
  8009b8:	8b 55 08             	mov    0x8(%ebp),%edx
  8009bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009be:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8009c1:	85 c0                	test   %eax,%eax
  8009c3:	74 23                	je     8009e8 <strncmp+0x34>
  8009c5:	0f b6 1a             	movzbl (%edx),%ebx
  8009c8:	84 db                	test   %bl,%bl
  8009ca:	74 25                	je     8009f1 <strncmp+0x3d>
  8009cc:	3a 19                	cmp    (%ecx),%bl
  8009ce:	75 21                	jne    8009f1 <strncmp+0x3d>
  8009d0:	83 e8 01             	sub    $0x1,%eax
  8009d3:	74 13                	je     8009e8 <strncmp+0x34>
		n--, p++, q++;
  8009d5:	83 c2 01             	add    $0x1,%edx
  8009d8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009db:	0f b6 1a             	movzbl (%edx),%ebx
  8009de:	84 db                	test   %bl,%bl
  8009e0:	74 0f                	je     8009f1 <strncmp+0x3d>
  8009e2:	3a 19                	cmp    (%ecx),%bl
  8009e4:	74 ea                	je     8009d0 <strncmp+0x1c>
  8009e6:	eb 09                	jmp    8009f1 <strncmp+0x3d>
  8009e8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009ed:	5b                   	pop    %ebx
  8009ee:	5d                   	pop    %ebp
  8009ef:	90                   	nop
  8009f0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009f1:	0f b6 02             	movzbl (%edx),%eax
  8009f4:	0f b6 11             	movzbl (%ecx),%edx
  8009f7:	29 d0                	sub    %edx,%eax
  8009f9:	eb f2                	jmp    8009ed <strncmp+0x39>

008009fb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a05:	0f b6 10             	movzbl (%eax),%edx
  800a08:	84 d2                	test   %dl,%dl
  800a0a:	74 18                	je     800a24 <strchr+0x29>
		if (*s == c)
  800a0c:	38 ca                	cmp    %cl,%dl
  800a0e:	75 0a                	jne    800a1a <strchr+0x1f>
  800a10:	eb 17                	jmp    800a29 <strchr+0x2e>
  800a12:	38 ca                	cmp    %cl,%dl
  800a14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a18:	74 0f                	je     800a29 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a1a:	83 c0 01             	add    $0x1,%eax
  800a1d:	0f b6 10             	movzbl (%eax),%edx
  800a20:	84 d2                	test   %dl,%dl
  800a22:	75 ee                	jne    800a12 <strchr+0x17>
  800a24:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a31:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a35:	0f b6 10             	movzbl (%eax),%edx
  800a38:	84 d2                	test   %dl,%dl
  800a3a:	74 18                	je     800a54 <strfind+0x29>
		if (*s == c)
  800a3c:	38 ca                	cmp    %cl,%dl
  800a3e:	75 0a                	jne    800a4a <strfind+0x1f>
  800a40:	eb 12                	jmp    800a54 <strfind+0x29>
  800a42:	38 ca                	cmp    %cl,%dl
  800a44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a48:	74 0a                	je     800a54 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a4a:	83 c0 01             	add    $0x1,%eax
  800a4d:	0f b6 10             	movzbl (%eax),%edx
  800a50:	84 d2                	test   %dl,%dl
  800a52:	75 ee                	jne    800a42 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	83 ec 0c             	sub    $0xc,%esp
  800a5c:	89 1c 24             	mov    %ebx,(%esp)
  800a5f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a63:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a67:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a6d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a70:	85 c9                	test   %ecx,%ecx
  800a72:	74 30                	je     800aa4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a74:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a7a:	75 25                	jne    800aa1 <memset+0x4b>
  800a7c:	f6 c1 03             	test   $0x3,%cl
  800a7f:	75 20                	jne    800aa1 <memset+0x4b>
		c &= 0xFF;
  800a81:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a84:	89 d3                	mov    %edx,%ebx
  800a86:	c1 e3 08             	shl    $0x8,%ebx
  800a89:	89 d6                	mov    %edx,%esi
  800a8b:	c1 e6 18             	shl    $0x18,%esi
  800a8e:	89 d0                	mov    %edx,%eax
  800a90:	c1 e0 10             	shl    $0x10,%eax
  800a93:	09 f0                	or     %esi,%eax
  800a95:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800a97:	09 d8                	or     %ebx,%eax
  800a99:	c1 e9 02             	shr    $0x2,%ecx
  800a9c:	fc                   	cld    
  800a9d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a9f:	eb 03                	jmp    800aa4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800aa1:	fc                   	cld    
  800aa2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800aa4:	89 f8                	mov    %edi,%eax
  800aa6:	8b 1c 24             	mov    (%esp),%ebx
  800aa9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800aad:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ab1:	89 ec                	mov    %ebp,%esp
  800ab3:	5d                   	pop    %ebp
  800ab4:	c3                   	ret    

00800ab5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ab5:	55                   	push   %ebp
  800ab6:	89 e5                	mov    %esp,%ebp
  800ab8:	83 ec 08             	sub    $0x8,%esp
  800abb:	89 34 24             	mov    %esi,(%esp)
  800abe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ac2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800ac8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800acb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800acd:	39 c6                	cmp    %eax,%esi
  800acf:	73 35                	jae    800b06 <memmove+0x51>
  800ad1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ad4:	39 d0                	cmp    %edx,%eax
  800ad6:	73 2e                	jae    800b06 <memmove+0x51>
		s += n;
		d += n;
  800ad8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ada:	f6 c2 03             	test   $0x3,%dl
  800add:	75 1b                	jne    800afa <memmove+0x45>
  800adf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ae5:	75 13                	jne    800afa <memmove+0x45>
  800ae7:	f6 c1 03             	test   $0x3,%cl
  800aea:	75 0e                	jne    800afa <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800aec:	83 ef 04             	sub    $0x4,%edi
  800aef:	8d 72 fc             	lea    -0x4(%edx),%esi
  800af2:	c1 e9 02             	shr    $0x2,%ecx
  800af5:	fd                   	std    
  800af6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af8:	eb 09                	jmp    800b03 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800afa:	83 ef 01             	sub    $0x1,%edi
  800afd:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b00:	fd                   	std    
  800b01:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b03:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b04:	eb 20                	jmp    800b26 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b06:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b0c:	75 15                	jne    800b23 <memmove+0x6e>
  800b0e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b14:	75 0d                	jne    800b23 <memmove+0x6e>
  800b16:	f6 c1 03             	test   $0x3,%cl
  800b19:	75 08                	jne    800b23 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800b1b:	c1 e9 02             	shr    $0x2,%ecx
  800b1e:	fc                   	cld    
  800b1f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b21:	eb 03                	jmp    800b26 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b23:	fc                   	cld    
  800b24:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b26:	8b 34 24             	mov    (%esp),%esi
  800b29:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b2d:	89 ec                	mov    %ebp,%esp
  800b2f:	5d                   	pop    %ebp
  800b30:	c3                   	ret    

00800b31 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b37:	8b 45 10             	mov    0x10(%ebp),%eax
  800b3a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b41:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b45:	8b 45 08             	mov    0x8(%ebp),%eax
  800b48:	89 04 24             	mov    %eax,(%esp)
  800b4b:	e8 65 ff ff ff       	call   800ab5 <memmove>
}
  800b50:	c9                   	leave  
  800b51:	c3                   	ret    

00800b52 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b52:	55                   	push   %ebp
  800b53:	89 e5                	mov    %esp,%ebp
  800b55:	57                   	push   %edi
  800b56:	56                   	push   %esi
  800b57:	53                   	push   %ebx
  800b58:	8b 75 08             	mov    0x8(%ebp),%esi
  800b5b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b5e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b61:	85 c9                	test   %ecx,%ecx
  800b63:	74 36                	je     800b9b <memcmp+0x49>
		if (*s1 != *s2)
  800b65:	0f b6 06             	movzbl (%esi),%eax
  800b68:	0f b6 1f             	movzbl (%edi),%ebx
  800b6b:	38 d8                	cmp    %bl,%al
  800b6d:	74 20                	je     800b8f <memcmp+0x3d>
  800b6f:	eb 14                	jmp    800b85 <memcmp+0x33>
  800b71:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800b76:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800b7b:	83 c2 01             	add    $0x1,%edx
  800b7e:	83 e9 01             	sub    $0x1,%ecx
  800b81:	38 d8                	cmp    %bl,%al
  800b83:	74 12                	je     800b97 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800b85:	0f b6 c0             	movzbl %al,%eax
  800b88:	0f b6 db             	movzbl %bl,%ebx
  800b8b:	29 d8                	sub    %ebx,%eax
  800b8d:	eb 11                	jmp    800ba0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b8f:	83 e9 01             	sub    $0x1,%ecx
  800b92:	ba 00 00 00 00       	mov    $0x0,%edx
  800b97:	85 c9                	test   %ecx,%ecx
  800b99:	75 d6                	jne    800b71 <memcmp+0x1f>
  800b9b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800ba0:	5b                   	pop    %ebx
  800ba1:	5e                   	pop    %esi
  800ba2:	5f                   	pop    %edi
  800ba3:	5d                   	pop    %ebp
  800ba4:	c3                   	ret    

00800ba5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ba5:	55                   	push   %ebp
  800ba6:	89 e5                	mov    %esp,%ebp
  800ba8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bab:	89 c2                	mov    %eax,%edx
  800bad:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bb0:	39 d0                	cmp    %edx,%eax
  800bb2:	73 15                	jae    800bc9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bb4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800bb8:	38 08                	cmp    %cl,(%eax)
  800bba:	75 06                	jne    800bc2 <memfind+0x1d>
  800bbc:	eb 0b                	jmp    800bc9 <memfind+0x24>
  800bbe:	38 08                	cmp    %cl,(%eax)
  800bc0:	74 07                	je     800bc9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bc2:	83 c0 01             	add    $0x1,%eax
  800bc5:	39 c2                	cmp    %eax,%edx
  800bc7:	77 f5                	ja     800bbe <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	57                   	push   %edi
  800bcf:	56                   	push   %esi
  800bd0:	53                   	push   %ebx
  800bd1:	83 ec 04             	sub    $0x4,%esp
  800bd4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bda:	0f b6 02             	movzbl (%edx),%eax
  800bdd:	3c 20                	cmp    $0x20,%al
  800bdf:	74 04                	je     800be5 <strtol+0x1a>
  800be1:	3c 09                	cmp    $0x9,%al
  800be3:	75 0e                	jne    800bf3 <strtol+0x28>
		s++;
  800be5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800be8:	0f b6 02             	movzbl (%edx),%eax
  800beb:	3c 20                	cmp    $0x20,%al
  800bed:	74 f6                	je     800be5 <strtol+0x1a>
  800bef:	3c 09                	cmp    $0x9,%al
  800bf1:	74 f2                	je     800be5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bf3:	3c 2b                	cmp    $0x2b,%al
  800bf5:	75 0c                	jne    800c03 <strtol+0x38>
		s++;
  800bf7:	83 c2 01             	add    $0x1,%edx
  800bfa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c01:	eb 15                	jmp    800c18 <strtol+0x4d>
	else if (*s == '-')
  800c03:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c0a:	3c 2d                	cmp    $0x2d,%al
  800c0c:	75 0a                	jne    800c18 <strtol+0x4d>
		s++, neg = 1;
  800c0e:	83 c2 01             	add    $0x1,%edx
  800c11:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c18:	85 db                	test   %ebx,%ebx
  800c1a:	0f 94 c0             	sete   %al
  800c1d:	74 05                	je     800c24 <strtol+0x59>
  800c1f:	83 fb 10             	cmp    $0x10,%ebx
  800c22:	75 18                	jne    800c3c <strtol+0x71>
  800c24:	80 3a 30             	cmpb   $0x30,(%edx)
  800c27:	75 13                	jne    800c3c <strtol+0x71>
  800c29:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c2d:	8d 76 00             	lea    0x0(%esi),%esi
  800c30:	75 0a                	jne    800c3c <strtol+0x71>
		s += 2, base = 16;
  800c32:	83 c2 02             	add    $0x2,%edx
  800c35:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c3a:	eb 15                	jmp    800c51 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c3c:	84 c0                	test   %al,%al
  800c3e:	66 90                	xchg   %ax,%ax
  800c40:	74 0f                	je     800c51 <strtol+0x86>
  800c42:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c47:	80 3a 30             	cmpb   $0x30,(%edx)
  800c4a:	75 05                	jne    800c51 <strtol+0x86>
		s++, base = 8;
  800c4c:	83 c2 01             	add    $0x1,%edx
  800c4f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c51:	b8 00 00 00 00       	mov    $0x0,%eax
  800c56:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c58:	0f b6 0a             	movzbl (%edx),%ecx
  800c5b:	89 cf                	mov    %ecx,%edi
  800c5d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c60:	80 fb 09             	cmp    $0x9,%bl
  800c63:	77 08                	ja     800c6d <strtol+0xa2>
			dig = *s - '0';
  800c65:	0f be c9             	movsbl %cl,%ecx
  800c68:	83 e9 30             	sub    $0x30,%ecx
  800c6b:	eb 1e                	jmp    800c8b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800c6d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800c70:	80 fb 19             	cmp    $0x19,%bl
  800c73:	77 08                	ja     800c7d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800c75:	0f be c9             	movsbl %cl,%ecx
  800c78:	83 e9 57             	sub    $0x57,%ecx
  800c7b:	eb 0e                	jmp    800c8b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800c7d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800c80:	80 fb 19             	cmp    $0x19,%bl
  800c83:	77 15                	ja     800c9a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800c85:	0f be c9             	movsbl %cl,%ecx
  800c88:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c8b:	39 f1                	cmp    %esi,%ecx
  800c8d:	7d 0b                	jge    800c9a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800c8f:	83 c2 01             	add    $0x1,%edx
  800c92:	0f af c6             	imul   %esi,%eax
  800c95:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c98:	eb be                	jmp    800c58 <strtol+0x8d>
  800c9a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800c9c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ca0:	74 05                	je     800ca7 <strtol+0xdc>
		*endptr = (char *) s;
  800ca2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ca5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ca7:	89 ca                	mov    %ecx,%edx
  800ca9:	f7 da                	neg    %edx
  800cab:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800caf:	0f 45 c2             	cmovne %edx,%eax
}
  800cb2:	83 c4 04             	add    $0x4,%esp
  800cb5:	5b                   	pop    %ebx
  800cb6:	5e                   	pop    %esi
  800cb7:	5f                   	pop    %edi
  800cb8:	5d                   	pop    %ebp
  800cb9:	c3                   	ret    
	...

00800cbc <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	83 ec 48             	sub    $0x48,%esp
  800cc2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cc5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cc8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800ccb:	89 c6                	mov    %eax,%esi
  800ccd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800cd0:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800cd2:	8b 7d 10             	mov    0x10(%ebp),%edi
  800cd5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cd8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cdb:	51                   	push   %ecx
  800cdc:	52                   	push   %edx
  800cdd:	53                   	push   %ebx
  800cde:	54                   	push   %esp
  800cdf:	55                   	push   %ebp
  800ce0:	56                   	push   %esi
  800ce1:	57                   	push   %edi
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	8d 35 ec 0c 80 00    	lea    0x800cec,%esi
  800cea:	0f 34                	sysenter 

00800cec <.after_sysenter_label>:
  800cec:	5f                   	pop    %edi
  800ced:	5e                   	pop    %esi
  800cee:	5d                   	pop    %ebp
  800cef:	5c                   	pop    %esp
  800cf0:	5b                   	pop    %ebx
  800cf1:	5a                   	pop    %edx
  800cf2:	59                   	pop    %ecx
  800cf3:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800cf5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800cf9:	74 28                	je     800d23 <.after_sysenter_label+0x37>
  800cfb:	85 c0                	test   %eax,%eax
  800cfd:	7e 24                	jle    800d23 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cff:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d03:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800d07:	c7 44 24 08 20 2c 80 	movl   $0x802c20,0x8(%esp)
  800d0e:	00 
  800d0f:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800d16:	00 
  800d17:	c7 04 24 3d 2c 80 00 	movl   $0x802c3d,(%esp)
  800d1e:	e8 e1 15 00 00       	call   802304 <_panic>

	return ret;
}
  800d23:	89 d0                	mov    %edx,%eax
  800d25:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d28:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d2b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d2e:	89 ec                	mov    %ebp,%esp
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    

00800d32 <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  800d38:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d3f:	00 
  800d40:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d47:	00 
  800d48:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d4f:	00 
  800d50:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d53:	89 04 24             	mov    %eax,(%esp)
  800d56:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d59:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5e:	b8 10 00 00 00       	mov    $0x10,%eax
  800d63:	e8 54 ff ff ff       	call   800cbc <syscall>
}
  800d68:	c9                   	leave  
  800d69:	c3                   	ret    

00800d6a <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  800d70:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d77:	00 
  800d78:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d7f:	00 
  800d80:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d87:	00 
  800d88:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d8f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d94:	ba 00 00 00 00       	mov    $0x0,%edx
  800d99:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d9e:	e8 19 ff ff ff       	call   800cbc <syscall>
}
  800da3:	c9                   	leave  
  800da4:	c3                   	ret    

00800da5 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800da5:	55                   	push   %ebp
  800da6:	89 e5                	mov    %esp,%ebp
  800da8:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800dab:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800db2:	00 
  800db3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800dba:	00 
  800dbb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800dc2:	00 
  800dc3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800dca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dcd:	ba 01 00 00 00       	mov    $0x1,%edx
  800dd2:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dd7:	e8 e0 fe ff ff       	call   800cbc <syscall>
}
  800ddc:	c9                   	leave  
  800ddd:	c3                   	ret    

00800dde <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dde:	55                   	push   %ebp
  800ddf:	89 e5                	mov    %esp,%ebp
  800de1:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800de4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800deb:	00 
  800dec:	8b 45 14             	mov    0x14(%ebp),%eax
  800def:	89 44 24 08          	mov    %eax,0x8(%esp)
  800df3:	8b 45 10             	mov    0x10(%ebp),%eax
  800df6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dfd:	89 04 24             	mov    %eax,(%esp)
  800e00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e03:	ba 00 00 00 00       	mov    $0x0,%edx
  800e08:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e0d:	e8 aa fe ff ff       	call   800cbc <syscall>
}
  800e12:	c9                   	leave  
  800e13:	c3                   	ret    

00800e14 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e14:	55                   	push   %ebp
  800e15:	89 e5                	mov    %esp,%ebp
  800e17:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
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
  800e40:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e45:	e8 72 fe ff ff       	call   800cbc <syscall>
}
  800e4a:	c9                   	leave  
  800e4b:	c3                   	ret    

00800e4c <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e4c:	55                   	push   %ebp
  800e4d:	89 e5                	mov    %esp,%ebp
  800e4f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
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
  800e78:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e7d:	e8 3a fe ff ff       	call   800cbc <syscall>
}
  800e82:	c9                   	leave  
  800e83:	c3                   	ret    

00800e84 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800e8a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e91:	00 
  800e92:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e99:	00 
  800e9a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ea1:	00 
  800ea2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea5:	89 04 24             	mov    %eax,(%esp)
  800ea8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eab:	ba 01 00 00 00       	mov    $0x1,%edx
  800eb0:	b8 09 00 00 00       	mov    $0x9,%eax
  800eb5:	e8 02 fe ff ff       	call   800cbc <syscall>
}
  800eba:	c9                   	leave  
  800ebb:	c3                   	ret    

00800ebc <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800ebc:	55                   	push   %ebp
  800ebd:	89 e5                	mov    %esp,%ebp
  800ebf:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800ec2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ec9:	00 
  800eca:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ed1:	00 
  800ed2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ed9:	00 
  800eda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800edd:	89 04 24             	mov    %eax,(%esp)
  800ee0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee3:	ba 01 00 00 00       	mov    $0x1,%edx
  800ee8:	b8 07 00 00 00       	mov    $0x7,%eax
  800eed:	e8 ca fd ff ff       	call   800cbc <syscall>
}
  800ef2:	c9                   	leave  
  800ef3:	c3                   	ret    

00800ef4 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ef4:	55                   	push   %ebp
  800ef5:	89 e5                	mov    %esp,%ebp
  800ef7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800efa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f01:	00 
  800f02:	8b 45 18             	mov    0x18(%ebp),%eax
  800f05:	0b 45 14             	or     0x14(%ebp),%eax
  800f08:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f0c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f0f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f16:	89 04 24             	mov    %eax,(%esp)
  800f19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f1c:	ba 01 00 00 00       	mov    $0x1,%edx
  800f21:	b8 06 00 00 00       	mov    $0x6,%eax
  800f26:	e8 91 fd ff ff       	call   800cbc <syscall>
}
  800f2b:	c9                   	leave  
  800f2c:	c3                   	ret    

00800f2d <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f2d:	55                   	push   %ebp
  800f2e:	89 e5                	mov    %esp,%ebp
  800f30:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f33:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f3a:	00 
  800f3b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f42:	00 
  800f43:	8b 45 10             	mov    0x10(%ebp),%eax
  800f46:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f4d:	89 04 24             	mov    %eax,(%esp)
  800f50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f53:	ba 01 00 00 00       	mov    $0x1,%edx
  800f58:	b8 05 00 00 00       	mov    $0x5,%eax
  800f5d:	e8 5a fd ff ff       	call   800cbc <syscall>
}
  800f62:	c9                   	leave  
  800f63:	c3                   	ret    

00800f64 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f6a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f71:	00 
  800f72:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f79:	00 
  800f7a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f81:	00 
  800f82:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f89:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f93:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f98:	e8 1f fd ff ff       	call   800cbc <syscall>
}
  800f9d:	c9                   	leave  
  800f9e:	c3                   	ret    

00800f9f <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
  800fa2:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  800fa5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fac:	00 
  800fad:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fb4:	00 
  800fb5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fbc:	00 
  800fbd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fc0:	89 04 24             	mov    %eax,(%esp)
  800fc3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fc6:	ba 00 00 00 00       	mov    $0x0,%edx
  800fcb:	b8 04 00 00 00       	mov    $0x4,%eax
  800fd0:	e8 e7 fc ff ff       	call   800cbc <syscall>
}
  800fd5:	c9                   	leave  
  800fd6:	c3                   	ret    

00800fd7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800fdd:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fe4:	00 
  800fe5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fec:	00 
  800fed:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ff4:	00 
  800ff5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ffc:	b9 00 00 00 00       	mov    $0x0,%ecx
  801001:	ba 00 00 00 00       	mov    $0x0,%edx
  801006:	b8 02 00 00 00       	mov    $0x2,%eax
  80100b:	e8 ac fc ff ff       	call   800cbc <syscall>
}
  801010:	c9                   	leave  
  801011:	c3                   	ret    

00801012 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801012:	55                   	push   %ebp
  801013:	89 e5                	mov    %esp,%ebp
  801015:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801018:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80101f:	00 
  801020:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801027:	00 
  801028:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80102f:	00 
  801030:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801037:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80103a:	ba 01 00 00 00       	mov    $0x1,%edx
  80103f:	b8 03 00 00 00       	mov    $0x3,%eax
  801044:	e8 73 fc ff ff       	call   800cbc <syscall>
}
  801049:	c9                   	leave  
  80104a:	c3                   	ret    

0080104b <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  80104b:	55                   	push   %ebp
  80104c:	89 e5                	mov    %esp,%ebp
  80104e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  801051:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801058:	00 
  801059:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801060:	00 
  801061:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801068:	00 
  801069:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801070:	b9 00 00 00 00       	mov    $0x0,%ecx
  801075:	ba 00 00 00 00       	mov    $0x0,%edx
  80107a:	b8 01 00 00 00       	mov    $0x1,%eax
  80107f:	e8 38 fc ff ff       	call   800cbc <syscall>
}
  801084:	c9                   	leave  
  801085:	c3                   	ret    

00801086 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
  801089:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80108c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801093:	00 
  801094:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80109b:	00 
  80109c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010a3:	00 
  8010a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010a7:	89 04 24             	mov    %eax,(%esp)
  8010aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8010b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8010b7:	e8 00 fc ff ff       	call   800cbc <syscall>
}
  8010bc:	c9                   	leave  
  8010bd:	c3                   	ret    
	...

008010c0 <sfork>:
}

// Challenge!
int
sfork(void)
{
  8010c0:	55                   	push   %ebp
  8010c1:	89 e5                	mov    %esp,%ebp
  8010c3:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8010c6:	c7 44 24 08 4b 2c 80 	movl   $0x802c4b,0x8(%esp)
  8010cd:	00 
  8010ce:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
  8010d5:	00 
  8010d6:	c7 04 24 61 2c 80 00 	movl   $0x802c61,(%esp)
  8010dd:	e8 22 12 00 00       	call   802304 <_panic>

008010e2 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	57                   	push   %edi
  8010e6:	56                   	push   %esi
  8010e7:	53                   	push   %ebx
  8010e8:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envidnum;
	uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	
	set_pgfault_handler(pgfault);
  8010eb:	c7 04 24 a6 13 80 00 	movl   $0x8013a6,(%esp)
  8010f2:	e8 65 12 00 00       	call   80235c <set_pgfault_handler>
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	//if I push esp it will be a pagefault.I come across a bug here.
	__asm __volatile(  
  8010f7:	ba 08 00 00 00       	mov    $0x8,%edx
  8010fc:	89 d0                	mov    %edx,%eax
  8010fe:	51                   	push   %ecx
  8010ff:	52                   	push   %edx
  801100:	53                   	push   %ebx
  801101:	55                   	push   %ebp
  801102:	56                   	push   %esi
  801103:	57                   	push   %edi
  801104:	89 e5                	mov    %esp,%ebp
  801106:	8d 35 0e 11 80 00    	lea    0x80110e,%esi
  80110c:	0f 34                	sysenter 

0080110e <.after_sysenter_label>:
  80110e:	5f                   	pop    %edi
  80110f:	5e                   	pop    %esi
  801110:	5d                   	pop    %ebp
  801111:	5b                   	pop    %ebx
  801112:	5a                   	pop    %edx
  801113:	59                   	pop    %ecx
  801114:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	envidnum = sys_exofork();
	cprintf("%s:fork[%d]: sys_exofork() return %x\n",__FILE__, __LINE__, envidnum);
  801117:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80111b:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
  801122:	00 
  801123:	c7 44 24 04 61 2c 80 	movl   $0x802c61,0x4(%esp)
  80112a:	00 
  80112b:	c7 04 24 a8 2c 80 00 	movl   $0x802ca8,(%esp)
  801132:	e8 56 f0 ff ff       	call   80018d <cprintf>
	if (envidnum < 0)
  801137:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80113b:	79 23                	jns    801160 <.after_sysenter_label+0x52>
		panic("sys_exofork: %e", envidnum);
  80113d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801140:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801144:	c7 44 24 08 6c 2c 80 	movl   $0x802c6c,0x8(%esp)
  80114b:	00 
  80114c:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  801153:	00 
  801154:	c7 04 24 61 2c 80 00 	movl   $0x802c61,(%esp)
  80115b:	e8 a4 11 00 00       	call   802304 <_panic>
	// We’re the child
	if (envidnum == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  801160:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
  801165:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  80116a:	bf 00 00 40 ef       	mov    $0xef400000,%edi
	envidnum = sys_exofork();
	cprintf("%s:fork[%d]: sys_exofork() return %x\n",__FILE__, __LINE__, envidnum);
	if (envidnum < 0)
		panic("sys_exofork: %e", envidnum);
	// We’re the child
	if (envidnum == 0) {
  80116f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801173:	75 1c                	jne    801191 <.after_sysenter_label+0x83>
		thisenv = &envs[ENVX(sys_getenvid())];
  801175:	e8 5d fe ff ff       	call   800fd7 <sys_getenvid>
  80117a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80117f:	c1 e0 07             	shl    $0x7,%eax
  801182:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801187:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  80118c:	e9 0a 02 00 00       	jmp    80139b <.after_sysenter_label+0x28d>
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
  801191:	89 d8                	mov    %ebx,%eax
  801193:	c1 e8 16             	shr    $0x16,%eax
  801196:	8b 04 86             	mov    (%esi,%eax,4),%eax
  801199:	a8 01                	test   $0x1,%al
  80119b:	0f 84 43 01 00 00    	je     8012e4 <.after_sysenter_label+0x1d6>
  8011a1:	89 d8                	mov    %ebx,%eax
  8011a3:	c1 e8 0c             	shr    $0xc,%eax
  8011a6:	8b 14 87             	mov    (%edi,%eax,4),%edx
  8011a9:	f6 c2 01             	test   $0x1,%dl
  8011ac:	0f 84 32 01 00 00    	je     8012e4 <.after_sysenter_label+0x1d6>
  8011b2:	8b 14 87             	mov    (%edi,%eax,4),%edx
  8011b5:	f6 c2 04             	test   $0x4,%dl
  8011b8:	0f 84 26 01 00 00    	je     8012e4 <.after_sysenter_label+0x1d6>
{
	int r;

	// LAB 4: Your code here.
	int perm;
	void * addr = (void *) ((uint32_t) pn * PGSIZE);
  8011be:	c1 e0 0c             	shl    $0xc,%eax
  8011c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	pte_t pte = vpt[PGNUM(addr)];
  8011c4:	c1 e8 0c             	shr    $0xc,%eax
  8011c7:	8b 04 87             	mov    (%edi,%eax,4),%eax
	perm = pte & PTE_SYSCALL;
  8011ca:	89 c2                	mov    %eax,%edx
  8011cc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
	
	if (perm & (PTE_W|PTE_COW)) 
  8011d2:	a9 02 08 00 00       	test   $0x802,%eax
  8011d7:	0f 84 a0 00 00 00    	je     80127d <.after_sysenter_label+0x16f>
	{
		 perm &= ~PTE_W;
  8011dd:	83 e2 fd             	and    $0xfffffffd,%edx
		 perm |= PTE_COW;
  8011e0:	80 ce 08             	or     $0x8,%dh
  8011e3:	89 55 dc             	mov    %edx,-0x24(%ebp)
		//map in child
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  8011e6:	89 54 24 10          	mov    %edx,0x10(%esp)
  8011ea:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011f8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011ff:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801206:	e8 e9 fc ff ff       	call   800ef4 <sys_page_map>
  80120b:	85 c0                	test   %eax,%eax
  80120d:	79 20                	jns    80122f <.after_sysenter_label+0x121>
			panic ("duppage: page re-mapping failed at 1 : %e", r);
  80120f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801213:	c7 44 24 08 d0 2c 80 	movl   $0x802cd0,0x8(%esp)
  80121a:	00 
  80121b:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
  801222:	00 
  801223:	c7 04 24 61 2c 80 00 	movl   $0x802c61,(%esp)
  80122a:	e8 d5 10 00 00       	call   802304 <_panic>
		//remap in the parent		
		if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0)
  80122f:	8b 45 dc             	mov    -0x24(%ebp),%eax
  801232:	89 44 24 10          	mov    %eax,0x10(%esp)
  801236:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801239:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80123d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801244:	00 
  801245:	89 44 24 04          	mov    %eax,0x4(%esp)
  801249:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801250:	e8 9f fc ff ff       	call   800ef4 <sys_page_map>
  801255:	85 c0                	test   %eax,%eax
  801257:	0f 89 87 00 00 00    	jns    8012e4 <.after_sysenter_label+0x1d6>
			panic ("duppage: page re-mapping failed at 2 : %e", r);
  80125d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801261:	c7 44 24 08 fc 2c 80 	movl   $0x802cfc,0x8(%esp)
  801268:	00 
  801269:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  801270:	00 
  801271:	c7 04 24 61 2c 80 00 	movl   $0x802c61,(%esp)
  801278:	e8 87 10 00 00       	call   802304 <_panic>
	}
	else //include PTE_SHARE
	{
		cprintf("map two %x----%x\n",envid,addr);
  80127d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801280:	89 44 24 08          	mov    %eax,0x8(%esp)
  801284:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801287:	89 44 24 04          	mov    %eax,0x4(%esp)
  80128b:	c7 04 24 7c 2c 80 00 	movl   $0x802c7c,(%esp)
  801292:	e8 f6 ee ff ff       	call   80018d <cprintf>
		if ((r = sys_page_map (0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  801297:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80129e:	00 
  80129f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012a2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012a9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012ad:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012bb:	e8 34 fc ff ff       	call   800ef4 <sys_page_map>
  8012c0:	85 c0                	test   %eax,%eax
  8012c2:	79 20                	jns    8012e4 <.after_sysenter_label+0x1d6>
			panic ("duppage: page re-mapping failed at 3 : %e", r);
  8012c4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012c8:	c7 44 24 08 28 2d 80 	movl   $0x802d28,0x8(%esp)
  8012cf:	00 
  8012d0:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  8012d7:	00 
  8012d8:	c7 04 24 61 2c 80 00 	movl   $0x802c61,(%esp)
  8012df:	e8 20 10 00 00       	call   802304 <_panic>
	if (envidnum == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
  8012e4:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8012ea:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8012f0:	0f 85 9b fe ff ff    	jne    801191 <.after_sysenter_label+0x83>
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
			duppage(envidnum,PGNUM(addr));
	}
	if ((r = sys_page_alloc (envidnum, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P)) < 0)
  8012f6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8012fd:	00 
  8012fe:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801305:	ee 
  801306:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801309:	89 04 24             	mov    %eax,(%esp)
  80130c:	e8 1c fc ff ff       	call   800f2d <sys_page_alloc>
  801311:	85 c0                	test   %eax,%eax
  801313:	79 20                	jns    801335 <.after_sysenter_label+0x227>
		panic ("fork: page allocation failed : %e", r);
  801315:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801319:	c7 44 24 08 54 2d 80 	movl   $0x802d54,0x8(%esp)
  801320:	00 
  801321:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  801328:	00 
  801329:	c7 04 24 61 2c 80 00 	movl   $0x802c61,(%esp)
  801330:	e8 cf 0f 00 00       	call   802304 <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	sys_env_set_pgfault_upcall (envidnum, _pgfault_upcall);
  801335:	c7 44 24 04 cc 23 80 	movl   $0x8023cc,0x4(%esp)
  80133c:	00 
  80133d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801340:	89 04 24             	mov    %eax,(%esp)
  801343:	e8 cc fa ff ff       	call   800e14 <sys_env_set_pgfault_upcall>
	//cprintf("%x-----%x\n",&envid,envid);
	// Start the child environment running
	if((r = sys_env_set_status(envidnum, ENV_RUNNABLE)) < 0)
  801348:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  80134f:	00 
  801350:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801353:	89 04 24             	mov    %eax,(%esp)
  801356:	e8 29 fb ff ff       	call   800e84 <sys_env_set_status>
  80135b:	85 c0                	test   %eax,%eax
  80135d:	79 20                	jns    80137f <.after_sysenter_label+0x271>
		panic("fork: set child env status failed : %e", r);
  80135f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801363:	c7 44 24 08 78 2d 80 	movl   $0x802d78,0x8(%esp)
  80136a:	00 
  80136b:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
  801372:	00 
  801373:	c7 04 24 61 2c 80 00 	movl   $0x802c61,(%esp)
  80137a:	e8 85 0f 00 00       	call   802304 <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("%x-----%x\n",&envidnum,envidnum);
	cprintf("%s:fork[%d]: fork return\n", __FILE__, __LINE__);
  80137f:	c7 44 24 08 9a 00 00 	movl   $0x9a,0x8(%esp)
  801386:	00 
  801387:	c7 44 24 04 61 2c 80 	movl   $0x802c61,0x4(%esp)
  80138e:	00 
  80138f:	c7 04 24 8e 2c 80 00 	movl   $0x802c8e,(%esp)
  801396:	e8 f2 ed ff ff       	call   80018d <cprintf>
	return envidnum;

	//panic("fork not implemented");
}
  80139b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80139e:	83 c4 3c             	add    $0x3c,%esp
  8013a1:	5b                   	pop    %ebx
  8013a2:	5e                   	pop    %esi
  8013a3:	5f                   	pop    %edi
  8013a4:	5d                   	pop    %ebp
  8013a5:	c3                   	ret    

008013a6 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  8013a6:	55                   	push   %ebp
  8013a7:	89 e5                	mov    %esp,%ebp
  8013a9:	53                   	push   %ebx
  8013aa:	83 ec 24             	sub    $0x24,%esp
  8013ad:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  8013b0:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  8013b2:	8b 50 04             	mov    0x4(%eax),%edx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).
	//cprintf("pgfault: do page fault here %x\n",utf->utf_eflags);
	// LAB 4: Your code here.
	if((err & FEC_WR) == 0)
  8013b5:	f6 c2 02             	test   $0x2,%dl
  8013b8:	75 2b                	jne    8013e5 <pgfault+0x3f>
		panic("pgfault: fault is not a write (err: %08x va: %08x ip: %08x)",err, addr, utf->utf_eip);
  8013ba:	8b 40 28             	mov    0x28(%eax),%eax
  8013bd:	89 44 24 14          	mov    %eax,0x14(%esp)
  8013c1:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8013c5:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8013c9:	c7 44 24 08 a0 2d 80 	movl   $0x802da0,0x8(%esp)
  8013d0:	00 
  8013d1:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  8013d8:	00 
  8013d9:	c7 04 24 61 2c 80 00 	movl   $0x802c61,(%esp)
  8013e0:	e8 1f 0f 00 00       	call   802304 <_panic>
	if ((vpd[PDX(addr)] & PTE_P) == 0 || (vpt[PGNUM(addr)] & PTE_COW) == 0)
  8013e5:	89 d8                	mov    %ebx,%eax
  8013e7:	c1 e8 16             	shr    $0x16,%eax
  8013ea:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013f1:	a8 01                	test   $0x1,%al
  8013f3:	74 11                	je     801406 <pgfault+0x60>
  8013f5:	89 d8                	mov    %ebx,%eax
  8013f7:	c1 e8 0c             	shr    $0xc,%eax
  8013fa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801401:	f6 c4 08             	test   $0x8,%ah
  801404:	75 1c                	jne    801422 <pgfault+0x7c>
		panic ("pgfault: not a write or attempting to access a non-COW page");
  801406:	c7 44 24 08 dc 2d 80 	movl   $0x802ddc,0x8(%esp)
  80140d:	00 
  80140e:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  801415:	00 
  801416:	c7 04 24 61 2c 80 00 	movl   $0x802c61,(%esp)
  80141d:	e8 e2 0e 00 00       	call   802304 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc (0, (void *)PFTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  801422:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801429:	00 
  80142a:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801431:	00 
  801432:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801439:	e8 ef fa ff ff       	call   800f2d <sys_page_alloc>
  80143e:	85 c0                	test   %eax,%eax
  801440:	79 20                	jns    801462 <pgfault+0xbc>
		panic ("pgfault: page allocation failed : %e", r);
  801442:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801446:	c7 44 24 08 18 2e 80 	movl   $0x802e18,0x8(%esp)
  80144d:	00 
  80144e:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  801455:	00 
  801456:	c7 04 24 61 2c 80 00 	movl   $0x802c61,(%esp)
  80145d:	e8 a2 0e 00 00       	call   802304 <_panic>
	addr = ROUNDDOWN (addr, PGSIZE);
  801462:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove (PFTEMP, addr, PGSIZE);
  801468:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  80146f:	00 
  801470:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801474:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80147b:	e8 35 f6 ff ff       	call   800ab5 <memmove>
	if((r = sys_page_map (0, PFTEMP, 0, addr, PTE_U|PTE_P|PTE_W)) < 0)
  801480:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801487:	00 
  801488:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80148c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801493:	00 
  801494:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80149b:	00 
  80149c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014a3:	e8 4c fa ff ff       	call   800ef4 <sys_page_map>
  8014a8:	85 c0                	test   %eax,%eax
  8014aa:	79 20                	jns    8014cc <pgfault+0x126>
		panic ("pgfault: page mapping failed : %e", r);
  8014ac:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014b0:	c7 44 24 08 40 2e 80 	movl   $0x802e40,0x8(%esp)
  8014b7:	00 
  8014b8:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  8014bf:	00 
  8014c0:	c7 04 24 61 2c 80 00 	movl   $0x802c61,(%esp)
  8014c7:	e8 38 0e 00 00       	call   802304 <_panic>
	if((r = sys_page_unmap(0,PFTEMP)) < 0)
  8014cc:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8014d3:	00 
  8014d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014db:	e8 dc f9 ff ff       	call   800ebc <sys_page_unmap>
  8014e0:	85 c0                	test   %eax,%eax
  8014e2:	79 20                	jns    801504 <pgfault+0x15e>
		panic("pgfault: page unmapping failed : %e", r);
  8014e4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014e8:	c7 44 24 08 64 2e 80 	movl   $0x802e64,0x8(%esp)
  8014ef:	00 
  8014f0:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  8014f7:	00 
  8014f8:	c7 04 24 61 2c 80 00 	movl   $0x802c61,(%esp)
  8014ff:	e8 00 0e 00 00       	call   802304 <_panic>
	/* __asm__ volatile("movl %%esp, %0\n\t" */
	/* 		 :"=r"(gaga) */
	/* 		 ::); */
	/* cprintf("gaga----------%x\n", gaga); */
	//panic("pgfault not implemented");
}
  801504:	83 c4 24             	add    $0x24,%esp
  801507:	5b                   	pop    %ebx
  801508:	5d                   	pop    %ebp
  801509:	c3                   	ret    
  80150a:	00 00                	add    %al,(%eax)
  80150c:	00 00                	add    %al,(%eax)
	...

00801510 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801510:	55                   	push   %ebp
  801511:	89 e5                	mov    %esp,%ebp
  801513:	8b 45 08             	mov    0x8(%ebp),%eax
  801516:	05 00 00 00 30       	add    $0x30000000,%eax
  80151b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80151e:	5d                   	pop    %ebp
  80151f:	c3                   	ret    

00801520 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801520:	55                   	push   %ebp
  801521:	89 e5                	mov    %esp,%ebp
  801523:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801526:	8b 45 08             	mov    0x8(%ebp),%eax
  801529:	89 04 24             	mov    %eax,(%esp)
  80152c:	e8 df ff ff ff       	call   801510 <fd2num>
  801531:	05 20 00 0d 00       	add    $0xd0020,%eax
  801536:	c1 e0 0c             	shl    $0xc,%eax
}
  801539:	c9                   	leave  
  80153a:	c3                   	ret    

0080153b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80153b:	55                   	push   %ebp
  80153c:	89 e5                	mov    %esp,%ebp
  80153e:	57                   	push   %edi
  80153f:	56                   	push   %esi
  801540:	53                   	push   %ebx
  801541:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801544:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801549:	a8 01                	test   $0x1,%al
  80154b:	74 36                	je     801583 <fd_alloc+0x48>
  80154d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801552:	a8 01                	test   $0x1,%al
  801554:	74 2d                	je     801583 <fd_alloc+0x48>
  801556:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80155b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801560:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801565:	89 c3                	mov    %eax,%ebx
  801567:	89 c2                	mov    %eax,%edx
  801569:	c1 ea 16             	shr    $0x16,%edx
  80156c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80156f:	f6 c2 01             	test   $0x1,%dl
  801572:	74 14                	je     801588 <fd_alloc+0x4d>
  801574:	89 c2                	mov    %eax,%edx
  801576:	c1 ea 0c             	shr    $0xc,%edx
  801579:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80157c:	f6 c2 01             	test   $0x1,%dl
  80157f:	75 10                	jne    801591 <fd_alloc+0x56>
  801581:	eb 05                	jmp    801588 <fd_alloc+0x4d>
  801583:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801588:	89 1f                	mov    %ebx,(%edi)
  80158a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80158f:	eb 17                	jmp    8015a8 <fd_alloc+0x6d>
  801591:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801596:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80159b:	75 c8                	jne    801565 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80159d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8015a3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8015a8:	5b                   	pop    %ebx
  8015a9:	5e                   	pop    %esi
  8015aa:	5f                   	pop    %edi
  8015ab:	5d                   	pop    %ebp
  8015ac:	c3                   	ret    

008015ad <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8015ad:	55                   	push   %ebp
  8015ae:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8015b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b3:	83 f8 1f             	cmp    $0x1f,%eax
  8015b6:	77 36                	ja     8015ee <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8015b8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8015bd:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8015c0:	89 c2                	mov    %eax,%edx
  8015c2:	c1 ea 16             	shr    $0x16,%edx
  8015c5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8015cc:	f6 c2 01             	test   $0x1,%dl
  8015cf:	74 1d                	je     8015ee <fd_lookup+0x41>
  8015d1:	89 c2                	mov    %eax,%edx
  8015d3:	c1 ea 0c             	shr    $0xc,%edx
  8015d6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015dd:	f6 c2 01             	test   $0x1,%dl
  8015e0:	74 0c                	je     8015ee <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8015e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015e5:	89 02                	mov    %eax,(%edx)
  8015e7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8015ec:	eb 05                	jmp    8015f3 <fd_lookup+0x46>
  8015ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015f3:	5d                   	pop    %ebp
  8015f4:	c3                   	ret    

008015f5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8015f5:	55                   	push   %ebp
  8015f6:	89 e5                	mov    %esp,%ebp
  8015f8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015fb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801602:	8b 45 08             	mov    0x8(%ebp),%eax
  801605:	89 04 24             	mov    %eax,(%esp)
  801608:	e8 a0 ff ff ff       	call   8015ad <fd_lookup>
  80160d:	85 c0                	test   %eax,%eax
  80160f:	78 0e                	js     80161f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801611:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801614:	8b 55 0c             	mov    0xc(%ebp),%edx
  801617:	89 50 04             	mov    %edx,0x4(%eax)
  80161a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80161f:	c9                   	leave  
  801620:	c3                   	ret    

00801621 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801621:	55                   	push   %ebp
  801622:	89 e5                	mov    %esp,%ebp
  801624:	56                   	push   %esi
  801625:	53                   	push   %ebx
  801626:	83 ec 10             	sub    $0x10,%esp
  801629:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80162c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80162f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801634:	b8 04 40 80 00       	mov    $0x804004,%eax
  801639:	39 0d 04 40 80 00    	cmp    %ecx,0x804004
  80163f:	75 11                	jne    801652 <dev_lookup+0x31>
  801641:	eb 04                	jmp    801647 <dev_lookup+0x26>
  801643:	39 08                	cmp    %ecx,(%eax)
  801645:	75 10                	jne    801657 <dev_lookup+0x36>
			*dev = devtab[i];
  801647:	89 03                	mov    %eax,(%ebx)
  801649:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80164e:	66 90                	xchg   %ax,%ax
  801650:	eb 36                	jmp    801688 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801652:	be 04 2f 80 00       	mov    $0x802f04,%esi
  801657:	83 c2 01             	add    $0x1,%edx
  80165a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80165d:	85 c0                	test   %eax,%eax
  80165f:	75 e2                	jne    801643 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801661:	a1 08 50 80 00       	mov    0x805008,%eax
  801666:	8b 40 48             	mov    0x48(%eax),%eax
  801669:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80166d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801671:	c7 04 24 88 2e 80 00 	movl   $0x802e88,(%esp)
  801678:	e8 10 eb ff ff       	call   80018d <cprintf>
	*dev = 0;
  80167d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801683:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801688:	83 c4 10             	add    $0x10,%esp
  80168b:	5b                   	pop    %ebx
  80168c:	5e                   	pop    %esi
  80168d:	5d                   	pop    %ebp
  80168e:	c3                   	ret    

0080168f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80168f:	55                   	push   %ebp
  801690:	89 e5                	mov    %esp,%ebp
  801692:	53                   	push   %ebx
  801693:	83 ec 24             	sub    $0x24,%esp
  801696:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801699:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80169c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8016a3:	89 04 24             	mov    %eax,(%esp)
  8016a6:	e8 02 ff ff ff       	call   8015ad <fd_lookup>
  8016ab:	85 c0                	test   %eax,%eax
  8016ad:	78 53                	js     801702 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b9:	8b 00                	mov    (%eax),%eax
  8016bb:	89 04 24             	mov    %eax,(%esp)
  8016be:	e8 5e ff ff ff       	call   801621 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c3:	85 c0                	test   %eax,%eax
  8016c5:	78 3b                	js     801702 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8016c7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016cf:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8016d3:	74 2d                	je     801702 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016d5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016d8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016df:	00 00 00 
	stat->st_isdir = 0;
  8016e2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016e9:	00 00 00 
	stat->st_dev = dev;
  8016ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ef:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016f9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016fc:	89 14 24             	mov    %edx,(%esp)
  8016ff:	ff 50 14             	call   *0x14(%eax)
}
  801702:	83 c4 24             	add    $0x24,%esp
  801705:	5b                   	pop    %ebx
  801706:	5d                   	pop    %ebp
  801707:	c3                   	ret    

00801708 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801708:	55                   	push   %ebp
  801709:	89 e5                	mov    %esp,%ebp
  80170b:	53                   	push   %ebx
  80170c:	83 ec 24             	sub    $0x24,%esp
  80170f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801712:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801715:	89 44 24 04          	mov    %eax,0x4(%esp)
  801719:	89 1c 24             	mov    %ebx,(%esp)
  80171c:	e8 8c fe ff ff       	call   8015ad <fd_lookup>
  801721:	85 c0                	test   %eax,%eax
  801723:	78 5f                	js     801784 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801725:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801728:	89 44 24 04          	mov    %eax,0x4(%esp)
  80172c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80172f:	8b 00                	mov    (%eax),%eax
  801731:	89 04 24             	mov    %eax,(%esp)
  801734:	e8 e8 fe ff ff       	call   801621 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801739:	85 c0                	test   %eax,%eax
  80173b:	78 47                	js     801784 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80173d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801740:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801744:	75 23                	jne    801769 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801746:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80174b:	8b 40 48             	mov    0x48(%eax),%eax
  80174e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801752:	89 44 24 04          	mov    %eax,0x4(%esp)
  801756:	c7 04 24 a8 2e 80 00 	movl   $0x802ea8,(%esp)
  80175d:	e8 2b ea ff ff       	call   80018d <cprintf>
  801762:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801767:	eb 1b                	jmp    801784 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801769:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80176c:	8b 48 18             	mov    0x18(%eax),%ecx
  80176f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801774:	85 c9                	test   %ecx,%ecx
  801776:	74 0c                	je     801784 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801778:	8b 45 0c             	mov    0xc(%ebp),%eax
  80177b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80177f:	89 14 24             	mov    %edx,(%esp)
  801782:	ff d1                	call   *%ecx
}
  801784:	83 c4 24             	add    $0x24,%esp
  801787:	5b                   	pop    %ebx
  801788:	5d                   	pop    %ebp
  801789:	c3                   	ret    

0080178a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80178a:	55                   	push   %ebp
  80178b:	89 e5                	mov    %esp,%ebp
  80178d:	53                   	push   %ebx
  80178e:	83 ec 24             	sub    $0x24,%esp
  801791:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801794:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801797:	89 44 24 04          	mov    %eax,0x4(%esp)
  80179b:	89 1c 24             	mov    %ebx,(%esp)
  80179e:	e8 0a fe ff ff       	call   8015ad <fd_lookup>
  8017a3:	85 c0                	test   %eax,%eax
  8017a5:	78 66                	js     80180d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017b1:	8b 00                	mov    (%eax),%eax
  8017b3:	89 04 24             	mov    %eax,(%esp)
  8017b6:	e8 66 fe ff ff       	call   801621 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017bb:	85 c0                	test   %eax,%eax
  8017bd:	78 4e                	js     80180d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017bf:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017c2:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8017c6:	75 23                	jne    8017eb <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017c8:	a1 08 50 80 00       	mov    0x805008,%eax
  8017cd:	8b 40 48             	mov    0x48(%eax),%eax
  8017d0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8017d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d8:	c7 04 24 c9 2e 80 00 	movl   $0x802ec9,(%esp)
  8017df:	e8 a9 e9 ff ff       	call   80018d <cprintf>
  8017e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8017e9:	eb 22                	jmp    80180d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ee:	8b 48 0c             	mov    0xc(%eax),%ecx
  8017f1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017f6:	85 c9                	test   %ecx,%ecx
  8017f8:	74 13                	je     80180d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8017fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  801801:	8b 45 0c             	mov    0xc(%ebp),%eax
  801804:	89 44 24 04          	mov    %eax,0x4(%esp)
  801808:	89 14 24             	mov    %edx,(%esp)
  80180b:	ff d1                	call   *%ecx
}
  80180d:	83 c4 24             	add    $0x24,%esp
  801810:	5b                   	pop    %ebx
  801811:	5d                   	pop    %ebp
  801812:	c3                   	ret    

00801813 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801813:	55                   	push   %ebp
  801814:	89 e5                	mov    %esp,%ebp
  801816:	53                   	push   %ebx
  801817:	83 ec 24             	sub    $0x24,%esp
  80181a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80181d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801820:	89 44 24 04          	mov    %eax,0x4(%esp)
  801824:	89 1c 24             	mov    %ebx,(%esp)
  801827:	e8 81 fd ff ff       	call   8015ad <fd_lookup>
  80182c:	85 c0                	test   %eax,%eax
  80182e:	78 6b                	js     80189b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801830:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801833:	89 44 24 04          	mov    %eax,0x4(%esp)
  801837:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80183a:	8b 00                	mov    (%eax),%eax
  80183c:	89 04 24             	mov    %eax,(%esp)
  80183f:	e8 dd fd ff ff       	call   801621 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801844:	85 c0                	test   %eax,%eax
  801846:	78 53                	js     80189b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801848:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80184b:	8b 42 08             	mov    0x8(%edx),%eax
  80184e:	83 e0 03             	and    $0x3,%eax
  801851:	83 f8 01             	cmp    $0x1,%eax
  801854:	75 23                	jne    801879 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801856:	a1 08 50 80 00       	mov    0x805008,%eax
  80185b:	8b 40 48             	mov    0x48(%eax),%eax
  80185e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801862:	89 44 24 04          	mov    %eax,0x4(%esp)
  801866:	c7 04 24 e6 2e 80 00 	movl   $0x802ee6,(%esp)
  80186d:	e8 1b e9 ff ff       	call   80018d <cprintf>
  801872:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801877:	eb 22                	jmp    80189b <read+0x88>
	}
	if (!dev->dev_read)
  801879:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80187c:	8b 48 08             	mov    0x8(%eax),%ecx
  80187f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801884:	85 c9                	test   %ecx,%ecx
  801886:	74 13                	je     80189b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801888:	8b 45 10             	mov    0x10(%ebp),%eax
  80188b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80188f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801892:	89 44 24 04          	mov    %eax,0x4(%esp)
  801896:	89 14 24             	mov    %edx,(%esp)
  801899:	ff d1                	call   *%ecx
}
  80189b:	83 c4 24             	add    $0x24,%esp
  80189e:	5b                   	pop    %ebx
  80189f:	5d                   	pop    %ebp
  8018a0:	c3                   	ret    

008018a1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8018a1:	55                   	push   %ebp
  8018a2:	89 e5                	mov    %esp,%ebp
  8018a4:	57                   	push   %edi
  8018a5:	56                   	push   %esi
  8018a6:	53                   	push   %ebx
  8018a7:	83 ec 1c             	sub    $0x1c,%esp
  8018aa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8018ad:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8018bf:	85 f6                	test   %esi,%esi
  8018c1:	74 29                	je     8018ec <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8018c3:	89 f0                	mov    %esi,%eax
  8018c5:	29 d0                	sub    %edx,%eax
  8018c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018cb:	03 55 0c             	add    0xc(%ebp),%edx
  8018ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018d2:	89 3c 24             	mov    %edi,(%esp)
  8018d5:	e8 39 ff ff ff       	call   801813 <read>
		if (m < 0)
  8018da:	85 c0                	test   %eax,%eax
  8018dc:	78 0e                	js     8018ec <readn+0x4b>
			return m;
		if (m == 0)
  8018de:	85 c0                	test   %eax,%eax
  8018e0:	74 08                	je     8018ea <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8018e2:	01 c3                	add    %eax,%ebx
  8018e4:	89 da                	mov    %ebx,%edx
  8018e6:	39 f3                	cmp    %esi,%ebx
  8018e8:	72 d9                	jb     8018c3 <readn+0x22>
  8018ea:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8018ec:	83 c4 1c             	add    $0x1c,%esp
  8018ef:	5b                   	pop    %ebx
  8018f0:	5e                   	pop    %esi
  8018f1:	5f                   	pop    %edi
  8018f2:	5d                   	pop    %ebp
  8018f3:	c3                   	ret    

008018f4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	83 ec 28             	sub    $0x28,%esp
  8018fa:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8018fd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801900:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801903:	89 34 24             	mov    %esi,(%esp)
  801906:	e8 05 fc ff ff       	call   801510 <fd2num>
  80190b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80190e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801912:	89 04 24             	mov    %eax,(%esp)
  801915:	e8 93 fc ff ff       	call   8015ad <fd_lookup>
  80191a:	89 c3                	mov    %eax,%ebx
  80191c:	85 c0                	test   %eax,%eax
  80191e:	78 05                	js     801925 <fd_close+0x31>
  801920:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801923:	74 0e                	je     801933 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801925:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801929:	b8 00 00 00 00       	mov    $0x0,%eax
  80192e:	0f 44 d8             	cmove  %eax,%ebx
  801931:	eb 3d                	jmp    801970 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801933:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801936:	89 44 24 04          	mov    %eax,0x4(%esp)
  80193a:	8b 06                	mov    (%esi),%eax
  80193c:	89 04 24             	mov    %eax,(%esp)
  80193f:	e8 dd fc ff ff       	call   801621 <dev_lookup>
  801944:	89 c3                	mov    %eax,%ebx
  801946:	85 c0                	test   %eax,%eax
  801948:	78 16                	js     801960 <fd_close+0x6c>
		if (dev->dev_close)
  80194a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80194d:	8b 40 10             	mov    0x10(%eax),%eax
  801950:	bb 00 00 00 00       	mov    $0x0,%ebx
  801955:	85 c0                	test   %eax,%eax
  801957:	74 07                	je     801960 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801959:	89 34 24             	mov    %esi,(%esp)
  80195c:	ff d0                	call   *%eax
  80195e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801960:	89 74 24 04          	mov    %esi,0x4(%esp)
  801964:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80196b:	e8 4c f5 ff ff       	call   800ebc <sys_page_unmap>
	return r;
}
  801970:	89 d8                	mov    %ebx,%eax
  801972:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801975:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801978:	89 ec                	mov    %ebp,%esp
  80197a:	5d                   	pop    %ebp
  80197b:	c3                   	ret    

0080197c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80197c:	55                   	push   %ebp
  80197d:	89 e5                	mov    %esp,%ebp
  80197f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801982:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801985:	89 44 24 04          	mov    %eax,0x4(%esp)
  801989:	8b 45 08             	mov    0x8(%ebp),%eax
  80198c:	89 04 24             	mov    %eax,(%esp)
  80198f:	e8 19 fc ff ff       	call   8015ad <fd_lookup>
  801994:	85 c0                	test   %eax,%eax
  801996:	78 13                	js     8019ab <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801998:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80199f:	00 
  8019a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a3:	89 04 24             	mov    %eax,(%esp)
  8019a6:	e8 49 ff ff ff       	call   8018f4 <fd_close>
}
  8019ab:	c9                   	leave  
  8019ac:	c3                   	ret    

008019ad <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8019ad:	55                   	push   %ebp
  8019ae:	89 e5                	mov    %esp,%ebp
  8019b0:	83 ec 18             	sub    $0x18,%esp
  8019b3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8019b6:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019c0:	00 
  8019c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c4:	89 04 24             	mov    %eax,(%esp)
  8019c7:	e8 78 03 00 00       	call   801d44 <open>
  8019cc:	89 c3                	mov    %eax,%ebx
  8019ce:	85 c0                	test   %eax,%eax
  8019d0:	78 1b                	js     8019ed <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8019d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d9:	89 1c 24             	mov    %ebx,(%esp)
  8019dc:	e8 ae fc ff ff       	call   80168f <fstat>
  8019e1:	89 c6                	mov    %eax,%esi
	close(fd);
  8019e3:	89 1c 24             	mov    %ebx,(%esp)
  8019e6:	e8 91 ff ff ff       	call   80197c <close>
  8019eb:	89 f3                	mov    %esi,%ebx
	return r;
}
  8019ed:	89 d8                	mov    %ebx,%eax
  8019ef:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8019f2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8019f5:	89 ec                	mov    %ebp,%esp
  8019f7:	5d                   	pop    %ebp
  8019f8:	c3                   	ret    

008019f9 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8019f9:	55                   	push   %ebp
  8019fa:	89 e5                	mov    %esp,%ebp
  8019fc:	53                   	push   %ebx
  8019fd:	83 ec 14             	sub    $0x14,%esp
  801a00:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801a05:	89 1c 24             	mov    %ebx,(%esp)
  801a08:	e8 6f ff ff ff       	call   80197c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801a0d:	83 c3 01             	add    $0x1,%ebx
  801a10:	83 fb 20             	cmp    $0x20,%ebx
  801a13:	75 f0                	jne    801a05 <close_all+0xc>
		close(i);
}
  801a15:	83 c4 14             	add    $0x14,%esp
  801a18:	5b                   	pop    %ebx
  801a19:	5d                   	pop    %ebp
  801a1a:	c3                   	ret    

00801a1b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801a1b:	55                   	push   %ebp
  801a1c:	89 e5                	mov    %esp,%ebp
  801a1e:	83 ec 58             	sub    $0x58,%esp
  801a21:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801a24:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801a27:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801a2a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801a2d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801a30:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a34:	8b 45 08             	mov    0x8(%ebp),%eax
  801a37:	89 04 24             	mov    %eax,(%esp)
  801a3a:	e8 6e fb ff ff       	call   8015ad <fd_lookup>
  801a3f:	89 c3                	mov    %eax,%ebx
  801a41:	85 c0                	test   %eax,%eax
  801a43:	0f 88 e0 00 00 00    	js     801b29 <dup+0x10e>
		return r;
	close(newfdnum);
  801a49:	89 3c 24             	mov    %edi,(%esp)
  801a4c:	e8 2b ff ff ff       	call   80197c <close>

	newfd = INDEX2FD(newfdnum);
  801a51:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801a57:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801a5a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a5d:	89 04 24             	mov    %eax,(%esp)
  801a60:	e8 bb fa ff ff       	call   801520 <fd2data>
  801a65:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801a67:	89 34 24             	mov    %esi,(%esp)
  801a6a:	e8 b1 fa ff ff       	call   801520 <fd2data>
  801a6f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801a72:	89 da                	mov    %ebx,%edx
  801a74:	89 d8                	mov    %ebx,%eax
  801a76:	c1 e8 16             	shr    $0x16,%eax
  801a79:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a80:	a8 01                	test   $0x1,%al
  801a82:	74 43                	je     801ac7 <dup+0xac>
  801a84:	c1 ea 0c             	shr    $0xc,%edx
  801a87:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801a8e:	a8 01                	test   $0x1,%al
  801a90:	74 35                	je     801ac7 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801a92:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801a99:	25 07 0e 00 00       	and    $0xe07,%eax
  801a9e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801aa2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801aa5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801aa9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801ab0:	00 
  801ab1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ab5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801abc:	e8 33 f4 ff ff       	call   800ef4 <sys_page_map>
  801ac1:	89 c3                	mov    %eax,%ebx
  801ac3:	85 c0                	test   %eax,%eax
  801ac5:	78 3f                	js     801b06 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801ac7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801aca:	89 c2                	mov    %eax,%edx
  801acc:	c1 ea 0c             	shr    $0xc,%edx
  801acf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801ad6:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801adc:	89 54 24 10          	mov    %edx,0x10(%esp)
  801ae0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801ae4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801aeb:	00 
  801aec:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801af7:	e8 f8 f3 ff ff       	call   800ef4 <sys_page_map>
  801afc:	89 c3                	mov    %eax,%ebx
  801afe:	85 c0                	test   %eax,%eax
  801b00:	78 04                	js     801b06 <dup+0xeb>
  801b02:	89 fb                	mov    %edi,%ebx
  801b04:	eb 23                	jmp    801b29 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801b06:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b0a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b11:	e8 a6 f3 ff ff       	call   800ebc <sys_page_unmap>
	sys_page_unmap(0, nva);
  801b16:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801b19:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b1d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b24:	e8 93 f3 ff ff       	call   800ebc <sys_page_unmap>
	return r;
}
  801b29:	89 d8                	mov    %ebx,%eax
  801b2b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801b2e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801b31:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b34:	89 ec                	mov    %ebp,%esp
  801b36:	5d                   	pop    %ebp
  801b37:	c3                   	ret    

00801b38 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	83 ec 18             	sub    $0x18,%esp
  801b3e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b41:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801b44:	89 c3                	mov    %eax,%ebx
  801b46:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801b48:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801b4f:	75 11                	jne    801b62 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801b51:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801b58:	e8 a3 08 00 00       	call   802400 <ipc_find_env>
  801b5d:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801b62:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b69:	00 
  801b6a:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801b71:	00 
  801b72:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b76:	a1 00 50 80 00       	mov    0x805000,%eax
  801b7b:	89 04 24             	mov    %eax,(%esp)
  801b7e:	e8 c6 08 00 00       	call   802449 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801b83:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b8a:	00 
  801b8b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b8f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b96:	e8 19 09 00 00       	call   8024b4 <ipc_recv>
}
  801b9b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b9e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801ba1:	89 ec                	mov    %ebp,%esp
  801ba3:	5d                   	pop    %ebp
  801ba4:	c3                   	ret    

00801ba5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801ba5:	55                   	push   %ebp
  801ba6:	89 e5                	mov    %esp,%ebp
  801ba8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801bab:	8b 45 08             	mov    0x8(%ebp),%eax
  801bae:	8b 40 0c             	mov    0xc(%eax),%eax
  801bb1:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801bb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801bb9:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801bbe:	ba 00 00 00 00       	mov    $0x0,%edx
  801bc3:	b8 02 00 00 00       	mov    $0x2,%eax
  801bc8:	e8 6b ff ff ff       	call   801b38 <fsipc>
}
  801bcd:	c9                   	leave  
  801bce:	c3                   	ret    

00801bcf <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801bcf:	55                   	push   %ebp
  801bd0:	89 e5                	mov    %esp,%ebp
  801bd2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801bd5:	8b 45 08             	mov    0x8(%ebp),%eax
  801bd8:	8b 40 0c             	mov    0xc(%eax),%eax
  801bdb:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801be0:	ba 00 00 00 00       	mov    $0x0,%edx
  801be5:	b8 06 00 00 00       	mov    $0x6,%eax
  801bea:	e8 49 ff ff ff       	call   801b38 <fsipc>
}
  801bef:	c9                   	leave  
  801bf0:	c3                   	ret    

00801bf1 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801bf1:	55                   	push   %ebp
  801bf2:	89 e5                	mov    %esp,%ebp
  801bf4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bf7:	ba 00 00 00 00       	mov    $0x0,%edx
  801bfc:	b8 08 00 00 00       	mov    $0x8,%eax
  801c01:	e8 32 ff ff ff       	call   801b38 <fsipc>
}
  801c06:	c9                   	leave  
  801c07:	c3                   	ret    

00801c08 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801c08:	55                   	push   %ebp
  801c09:	89 e5                	mov    %esp,%ebp
  801c0b:	53                   	push   %ebx
  801c0c:	83 ec 14             	sub    $0x14,%esp
  801c0f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801c12:	8b 45 08             	mov    0x8(%ebp),%eax
  801c15:	8b 40 0c             	mov    0xc(%eax),%eax
  801c18:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801c1d:	ba 00 00 00 00       	mov    $0x0,%edx
  801c22:	b8 05 00 00 00       	mov    $0x5,%eax
  801c27:	e8 0c ff ff ff       	call   801b38 <fsipc>
  801c2c:	85 c0                	test   %eax,%eax
  801c2e:	78 2b                	js     801c5b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801c30:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801c37:	00 
  801c38:	89 1c 24             	mov    %ebx,(%esp)
  801c3b:	e8 8a ec ff ff       	call   8008ca <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801c40:	a1 80 60 80 00       	mov    0x806080,%eax
  801c45:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801c4b:	a1 84 60 80 00       	mov    0x806084,%eax
  801c50:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801c56:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801c5b:	83 c4 14             	add    $0x14,%esp
  801c5e:	5b                   	pop    %ebx
  801c5f:	5d                   	pop    %ebp
  801c60:	c3                   	ret    

00801c61 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801c61:	55                   	push   %ebp
  801c62:	89 e5                	mov    %esp,%ebp
  801c64:	83 ec 18             	sub    $0x18,%esp
  801c67:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  801c6a:	8b 55 08             	mov    0x8(%ebp),%edx
  801c6d:	8b 52 0c             	mov    0xc(%edx),%edx
  801c70:	89 15 00 60 80 00    	mov    %edx,0x806000
  fsipcbuf.write.req_n = n;
  801c76:	a3 04 60 80 00       	mov    %eax,0x806004
  memmove(fsipcbuf.write.req_buf, buf,
  801c7b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801c80:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801c85:	0f 47 c2             	cmova  %edx,%eax
  801c88:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c8f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c93:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801c9a:	e8 16 ee ff ff       	call   800ab5 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  801c9f:	ba 00 00 00 00       	mov    $0x0,%edx
  801ca4:	b8 04 00 00 00       	mov    $0x4,%eax
  801ca9:	e8 8a fe ff ff       	call   801b38 <fsipc>
}
  801cae:	c9                   	leave  
  801caf:	c3                   	ret    

00801cb0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801cb0:	55                   	push   %ebp
  801cb1:	89 e5                	mov    %esp,%ebp
  801cb3:	53                   	push   %ebx
  801cb4:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801cb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801cba:	8b 40 0c             	mov    0xc(%eax),%eax
  801cbd:	a3 00 60 80 00       	mov    %eax,0x806000
  fsipcbuf.read.req_n = n;
  801cc2:	8b 45 10             	mov    0x10(%ebp),%eax
  801cc5:	a3 04 60 80 00       	mov    %eax,0x806004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  801cca:	ba 00 00 00 00       	mov    $0x0,%edx
  801ccf:	b8 03 00 00 00       	mov    $0x3,%eax
  801cd4:	e8 5f fe ff ff       	call   801b38 <fsipc>
  801cd9:	89 c3                	mov    %eax,%ebx
  801cdb:	85 c0                	test   %eax,%eax
  801cdd:	78 17                	js     801cf6 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801cdf:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ce3:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801cea:	00 
  801ceb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cee:	89 04 24             	mov    %eax,(%esp)
  801cf1:	e8 bf ed ff ff       	call   800ab5 <memmove>
  return r;	
}
  801cf6:	89 d8                	mov    %ebx,%eax
  801cf8:	83 c4 14             	add    $0x14,%esp
  801cfb:	5b                   	pop    %ebx
  801cfc:	5d                   	pop    %ebp
  801cfd:	c3                   	ret    

00801cfe <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801cfe:	55                   	push   %ebp
  801cff:	89 e5                	mov    %esp,%ebp
  801d01:	53                   	push   %ebx
  801d02:	83 ec 14             	sub    $0x14,%esp
  801d05:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801d08:	89 1c 24             	mov    %ebx,(%esp)
  801d0b:	e8 70 eb ff ff       	call   800880 <strlen>
  801d10:	89 c2                	mov    %eax,%edx
  801d12:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801d17:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801d1d:	7f 1f                	jg     801d3e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801d1f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d23:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801d2a:	e8 9b eb ff ff       	call   8008ca <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801d2f:	ba 00 00 00 00       	mov    $0x0,%edx
  801d34:	b8 07 00 00 00       	mov    $0x7,%eax
  801d39:	e8 fa fd ff ff       	call   801b38 <fsipc>
}
  801d3e:	83 c4 14             	add    $0x14,%esp
  801d41:	5b                   	pop    %ebx
  801d42:	5d                   	pop    %ebp
  801d43:	c3                   	ret    

00801d44 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801d44:	55                   	push   %ebp
  801d45:	89 e5                	mov    %esp,%ebp
  801d47:	83 ec 28             	sub    $0x28,%esp
  801d4a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d4d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801d50:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801d53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d56:	89 04 24             	mov    %eax,(%esp)
  801d59:	e8 dd f7 ff ff       	call   80153b <fd_alloc>
  801d5e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801d60:	85 c0                	test   %eax,%eax
  801d62:	0f 88 89 00 00 00    	js     801df1 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801d68:	89 34 24             	mov    %esi,(%esp)
  801d6b:	e8 10 eb ff ff       	call   800880 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801d70:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801d75:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801d7a:	7f 75                	jg     801df1 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  801d7c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d80:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801d87:	e8 3e eb ff ff       	call   8008ca <strcpy>
  fsipcbuf.open.req_omode = mode;
  801d8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d8f:	a3 00 64 80 00       	mov    %eax,0x806400
  r = fsipc(FSREQ_OPEN, fd);
  801d94:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d97:	b8 01 00 00 00       	mov    $0x1,%eax
  801d9c:	e8 97 fd ff ff       	call   801b38 <fsipc>
  801da1:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801da3:	85 c0                	test   %eax,%eax
  801da5:	78 0f                	js     801db6 <open+0x72>
  return fd2num(fd);
  801da7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801daa:	89 04 24             	mov    %eax,(%esp)
  801dad:	e8 5e f7 ff ff       	call   801510 <fd2num>
  801db2:	89 c3                	mov    %eax,%ebx
  801db4:	eb 3b                	jmp    801df1 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801db6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801dbd:	00 
  801dbe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801dc1:	89 04 24             	mov    %eax,(%esp)
  801dc4:	e8 2b fb ff ff       	call   8018f4 <fd_close>
  801dc9:	85 c0                	test   %eax,%eax
  801dcb:	74 24                	je     801df1 <open+0xad>
  801dcd:	c7 44 24 0c 10 2f 80 	movl   $0x802f10,0xc(%esp)
  801dd4:	00 
  801dd5:	c7 44 24 08 25 2f 80 	movl   $0x802f25,0x8(%esp)
  801ddc:	00 
  801ddd:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801de4:	00 
  801de5:	c7 04 24 3a 2f 80 00 	movl   $0x802f3a,(%esp)
  801dec:	e8 13 05 00 00       	call   802304 <_panic>
  return r;
}
  801df1:	89 d8                	mov    %ebx,%eax
  801df3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801df6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801df9:	89 ec                	mov    %ebp,%esp
  801dfb:	5d                   	pop    %ebp
  801dfc:	c3                   	ret    
  801dfd:	00 00                	add    %al,(%eax)
	...

00801e00 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801e00:	55                   	push   %ebp
  801e01:	89 e5                	mov    %esp,%ebp
  801e03:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801e06:	c7 44 24 04 45 2f 80 	movl   $0x802f45,0x4(%esp)
  801e0d:	00 
  801e0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e11:	89 04 24             	mov    %eax,(%esp)
  801e14:	e8 b1 ea ff ff       	call   8008ca <strcpy>
	return 0;
}
  801e19:	b8 00 00 00 00       	mov    $0x0,%eax
  801e1e:	c9                   	leave  
  801e1f:	c3                   	ret    

00801e20 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801e20:	55                   	push   %ebp
  801e21:	89 e5                	mov    %esp,%ebp
  801e23:	53                   	push   %ebx
  801e24:	83 ec 14             	sub    $0x14,%esp
  801e27:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801e2a:	89 1c 24             	mov    %ebx,(%esp)
  801e2d:	e8 12 07 00 00       	call   802544 <pageref>
  801e32:	89 c2                	mov    %eax,%edx
  801e34:	b8 00 00 00 00       	mov    $0x0,%eax
  801e39:	83 fa 01             	cmp    $0x1,%edx
  801e3c:	75 0b                	jne    801e49 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801e3e:	8b 43 0c             	mov    0xc(%ebx),%eax
  801e41:	89 04 24             	mov    %eax,(%esp)
  801e44:	e8 b9 02 00 00       	call   802102 <nsipc_close>
	else
		return 0;
}
  801e49:	83 c4 14             	add    $0x14,%esp
  801e4c:	5b                   	pop    %ebx
  801e4d:	5d                   	pop    %ebp
  801e4e:	c3                   	ret    

00801e4f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801e4f:	55                   	push   %ebp
  801e50:	89 e5                	mov    %esp,%ebp
  801e52:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801e55:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801e5c:	00 
  801e5d:	8b 45 10             	mov    0x10(%ebp),%eax
  801e60:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e64:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e67:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6e:	8b 40 0c             	mov    0xc(%eax),%eax
  801e71:	89 04 24             	mov    %eax,(%esp)
  801e74:	e8 c5 02 00 00       	call   80213e <nsipc_send>
}
  801e79:	c9                   	leave  
  801e7a:	c3                   	ret    

00801e7b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801e7b:	55                   	push   %ebp
  801e7c:	89 e5                	mov    %esp,%ebp
  801e7e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801e81:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801e88:	00 
  801e89:	8b 45 10             	mov    0x10(%ebp),%eax
  801e8c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e90:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e93:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e97:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9a:	8b 40 0c             	mov    0xc(%eax),%eax
  801e9d:	89 04 24             	mov    %eax,(%esp)
  801ea0:	e8 0c 03 00 00       	call   8021b1 <nsipc_recv>
}
  801ea5:	c9                   	leave  
  801ea6:	c3                   	ret    

00801ea7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801ea7:	55                   	push   %ebp
  801ea8:	89 e5                	mov    %esp,%ebp
  801eaa:	56                   	push   %esi
  801eab:	53                   	push   %ebx
  801eac:	83 ec 20             	sub    $0x20,%esp
  801eaf:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801eb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801eb4:	89 04 24             	mov    %eax,(%esp)
  801eb7:	e8 7f f6 ff ff       	call   80153b <fd_alloc>
  801ebc:	89 c3                	mov    %eax,%ebx
  801ebe:	85 c0                	test   %eax,%eax
  801ec0:	78 21                	js     801ee3 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801ec2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ec9:	00 
  801eca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ecd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ed1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ed8:	e8 50 f0 ff ff       	call   800f2d <sys_page_alloc>
  801edd:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801edf:	85 c0                	test   %eax,%eax
  801ee1:	79 0a                	jns    801eed <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  801ee3:	89 34 24             	mov    %esi,(%esp)
  801ee6:	e8 17 02 00 00       	call   802102 <nsipc_close>
		return r;
  801eeb:	eb 28                	jmp    801f15 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801eed:	8b 15 20 40 80 00    	mov    0x804020,%edx
  801ef3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801ef8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801efb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801f02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f05:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801f08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f0b:	89 04 24             	mov    %eax,(%esp)
  801f0e:	e8 fd f5 ff ff       	call   801510 <fd2num>
  801f13:	89 c3                	mov    %eax,%ebx
}
  801f15:	89 d8                	mov    %ebx,%eax
  801f17:	83 c4 20             	add    $0x20,%esp
  801f1a:	5b                   	pop    %ebx
  801f1b:	5e                   	pop    %esi
  801f1c:	5d                   	pop    %ebp
  801f1d:	c3                   	ret    

00801f1e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801f1e:	55                   	push   %ebp
  801f1f:	89 e5                	mov    %esp,%ebp
  801f21:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801f24:	8b 45 10             	mov    0x10(%ebp),%eax
  801f27:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f32:	8b 45 08             	mov    0x8(%ebp),%eax
  801f35:	89 04 24             	mov    %eax,(%esp)
  801f38:	e8 79 01 00 00       	call   8020b6 <nsipc_socket>
  801f3d:	85 c0                	test   %eax,%eax
  801f3f:	78 05                	js     801f46 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801f41:	e8 61 ff ff ff       	call   801ea7 <alloc_sockfd>
}
  801f46:	c9                   	leave  
  801f47:	c3                   	ret    

00801f48 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801f48:	55                   	push   %ebp
  801f49:	89 e5                	mov    %esp,%ebp
  801f4b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801f4e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801f51:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f55:	89 04 24             	mov    %eax,(%esp)
  801f58:	e8 50 f6 ff ff       	call   8015ad <fd_lookup>
  801f5d:	85 c0                	test   %eax,%eax
  801f5f:	78 15                	js     801f76 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801f61:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f64:	8b 0a                	mov    (%edx),%ecx
  801f66:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801f6b:	3b 0d 20 40 80 00    	cmp    0x804020,%ecx
  801f71:	75 03                	jne    801f76 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801f73:	8b 42 0c             	mov    0xc(%edx),%eax
}
  801f76:	c9                   	leave  
  801f77:	c3                   	ret    

00801f78 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  801f78:	55                   	push   %ebp
  801f79:	89 e5                	mov    %esp,%ebp
  801f7b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801f7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f81:	e8 c2 ff ff ff       	call   801f48 <fd2sockid>
  801f86:	85 c0                	test   %eax,%eax
  801f88:	78 0f                	js     801f99 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801f8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f8d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f91:	89 04 24             	mov    %eax,(%esp)
  801f94:	e8 47 01 00 00       	call   8020e0 <nsipc_listen>
}
  801f99:	c9                   	leave  
  801f9a:	c3                   	ret    

00801f9b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f9b:	55                   	push   %ebp
  801f9c:	89 e5                	mov    %esp,%ebp
  801f9e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fa1:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa4:	e8 9f ff ff ff       	call   801f48 <fd2sockid>
  801fa9:	85 c0                	test   %eax,%eax
  801fab:	78 16                	js     801fc3 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801fad:	8b 55 10             	mov    0x10(%ebp),%edx
  801fb0:	89 54 24 08          	mov    %edx,0x8(%esp)
  801fb4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fb7:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fbb:	89 04 24             	mov    %eax,(%esp)
  801fbe:	e8 6e 02 00 00       	call   802231 <nsipc_connect>
}
  801fc3:	c9                   	leave  
  801fc4:	c3                   	ret    

00801fc5 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801fc5:	55                   	push   %ebp
  801fc6:	89 e5                	mov    %esp,%ebp
  801fc8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fcb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fce:	e8 75 ff ff ff       	call   801f48 <fd2sockid>
  801fd3:	85 c0                	test   %eax,%eax
  801fd5:	78 0f                	js     801fe6 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801fd7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fda:	89 54 24 04          	mov    %edx,0x4(%esp)
  801fde:	89 04 24             	mov    %eax,(%esp)
  801fe1:	e8 36 01 00 00       	call   80211c <nsipc_shutdown>
}
  801fe6:	c9                   	leave  
  801fe7:	c3                   	ret    

00801fe8 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801fe8:	55                   	push   %ebp
  801fe9:	89 e5                	mov    %esp,%ebp
  801feb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801fee:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff1:	e8 52 ff ff ff       	call   801f48 <fd2sockid>
  801ff6:	85 c0                	test   %eax,%eax
  801ff8:	78 16                	js     802010 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801ffa:	8b 55 10             	mov    0x10(%ebp),%edx
  801ffd:	89 54 24 08          	mov    %edx,0x8(%esp)
  802001:	8b 55 0c             	mov    0xc(%ebp),%edx
  802004:	89 54 24 04          	mov    %edx,0x4(%esp)
  802008:	89 04 24             	mov    %eax,(%esp)
  80200b:	e8 60 02 00 00       	call   802270 <nsipc_bind>
}
  802010:	c9                   	leave  
  802011:	c3                   	ret    

00802012 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  802012:	55                   	push   %ebp
  802013:	89 e5                	mov    %esp,%ebp
  802015:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802018:	8b 45 08             	mov    0x8(%ebp),%eax
  80201b:	e8 28 ff ff ff       	call   801f48 <fd2sockid>
  802020:	85 c0                	test   %eax,%eax
  802022:	78 1f                	js     802043 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  802024:	8b 55 10             	mov    0x10(%ebp),%edx
  802027:	89 54 24 08          	mov    %edx,0x8(%esp)
  80202b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80202e:	89 54 24 04          	mov    %edx,0x4(%esp)
  802032:	89 04 24             	mov    %eax,(%esp)
  802035:	e8 75 02 00 00       	call   8022af <nsipc_accept>
  80203a:	85 c0                	test   %eax,%eax
  80203c:	78 05                	js     802043 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80203e:	e8 64 fe ff ff       	call   801ea7 <alloc_sockfd>
}
  802043:	c9                   	leave  
  802044:	c3                   	ret    
	...

00802050 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802050:	55                   	push   %ebp
  802051:	89 e5                	mov    %esp,%ebp
  802053:	53                   	push   %ebx
  802054:	83 ec 14             	sub    $0x14,%esp
  802057:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802059:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802060:	75 11                	jne    802073 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802062:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  802069:	e8 92 03 00 00       	call   802400 <ipc_find_env>
  80206e:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802073:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80207a:	00 
  80207b:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802082:	00 
  802083:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802087:	a1 04 50 80 00       	mov    0x805004,%eax
  80208c:	89 04 24             	mov    %eax,(%esp)
  80208f:	e8 b5 03 00 00       	call   802449 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802094:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80209b:	00 
  80209c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8020a3:	00 
  8020a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020ab:	e8 04 04 00 00       	call   8024b4 <ipc_recv>
}
  8020b0:	83 c4 14             	add    $0x14,%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5d                   	pop    %ebp
  8020b5:	c3                   	ret    

008020b6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  8020b6:	55                   	push   %ebp
  8020b7:	89 e5                	mov    %esp,%ebp
  8020b9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8020bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8020bf:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8020c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020c7:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8020cc:	8b 45 10             	mov    0x10(%ebp),%eax
  8020cf:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8020d4:	b8 09 00 00 00       	mov    $0x9,%eax
  8020d9:	e8 72 ff ff ff       	call   802050 <nsipc>
}
  8020de:	c9                   	leave  
  8020df:	c3                   	ret    

008020e0 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  8020e0:	55                   	push   %ebp
  8020e1:	89 e5                	mov    %esp,%ebp
  8020e3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8020e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8020e9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8020ee:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020f1:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8020f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8020fb:	e8 50 ff ff ff       	call   802050 <nsipc>
}
  802100:	c9                   	leave  
  802101:	c3                   	ret    

00802102 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  802102:	55                   	push   %ebp
  802103:	89 e5                	mov    %esp,%ebp
  802105:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  802108:	8b 45 08             	mov    0x8(%ebp),%eax
  80210b:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  802110:	b8 04 00 00 00       	mov    $0x4,%eax
  802115:	e8 36 ff ff ff       	call   802050 <nsipc>
}
  80211a:	c9                   	leave  
  80211b:	c3                   	ret    

0080211c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  80211c:	55                   	push   %ebp
  80211d:	89 e5                	mov    %esp,%ebp
  80211f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  802122:	8b 45 08             	mov    0x8(%ebp),%eax
  802125:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  80212a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80212d:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802132:	b8 03 00 00 00       	mov    $0x3,%eax
  802137:	e8 14 ff ff ff       	call   802050 <nsipc>
}
  80213c:	c9                   	leave  
  80213d:	c3                   	ret    

0080213e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80213e:	55                   	push   %ebp
  80213f:	89 e5                	mov    %esp,%ebp
  802141:	53                   	push   %ebx
  802142:	83 ec 14             	sub    $0x14,%esp
  802145:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802148:	8b 45 08             	mov    0x8(%ebp),%eax
  80214b:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802150:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802156:	7e 24                	jle    80217c <nsipc_send+0x3e>
  802158:	c7 44 24 0c 51 2f 80 	movl   $0x802f51,0xc(%esp)
  80215f:	00 
  802160:	c7 44 24 08 25 2f 80 	movl   $0x802f25,0x8(%esp)
  802167:	00 
  802168:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80216f:	00 
  802170:	c7 04 24 5d 2f 80 00 	movl   $0x802f5d,(%esp)
  802177:	e8 88 01 00 00       	call   802304 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80217c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802180:	8b 45 0c             	mov    0xc(%ebp),%eax
  802183:	89 44 24 04          	mov    %eax,0x4(%esp)
  802187:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  80218e:	e8 22 e9 ff ff       	call   800ab5 <memmove>
	nsipcbuf.send.req_size = size;
  802193:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802199:	8b 45 14             	mov    0x14(%ebp),%eax
  80219c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8021a1:	b8 08 00 00 00       	mov    $0x8,%eax
  8021a6:	e8 a5 fe ff ff       	call   802050 <nsipc>
}
  8021ab:	83 c4 14             	add    $0x14,%esp
  8021ae:	5b                   	pop    %ebx
  8021af:	5d                   	pop    %ebp
  8021b0:	c3                   	ret    

008021b1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8021b1:	55                   	push   %ebp
  8021b2:	89 e5                	mov    %esp,%ebp
  8021b4:	56                   	push   %esi
  8021b5:	53                   	push   %ebx
  8021b6:	83 ec 10             	sub    $0x10,%esp
  8021b9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8021bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8021bf:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  8021c4:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  8021ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8021cd:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8021d2:	b8 07 00 00 00       	mov    $0x7,%eax
  8021d7:	e8 74 fe ff ff       	call   802050 <nsipc>
  8021dc:	89 c3                	mov    %eax,%ebx
  8021de:	85 c0                	test   %eax,%eax
  8021e0:	78 46                	js     802228 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8021e2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8021e7:	7f 04                	jg     8021ed <nsipc_recv+0x3c>
  8021e9:	39 c6                	cmp    %eax,%esi
  8021eb:	7d 24                	jge    802211 <nsipc_recv+0x60>
  8021ed:	c7 44 24 0c 69 2f 80 	movl   $0x802f69,0xc(%esp)
  8021f4:	00 
  8021f5:	c7 44 24 08 25 2f 80 	movl   $0x802f25,0x8(%esp)
  8021fc:	00 
  8021fd:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  802204:	00 
  802205:	c7 04 24 5d 2f 80 00 	movl   $0x802f5d,(%esp)
  80220c:	e8 f3 00 00 00       	call   802304 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  802211:	89 44 24 08          	mov    %eax,0x8(%esp)
  802215:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  80221c:	00 
  80221d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802220:	89 04 24             	mov    %eax,(%esp)
  802223:	e8 8d e8 ff ff       	call   800ab5 <memmove>
	}

	return r;
}
  802228:	89 d8                	mov    %ebx,%eax
  80222a:	83 c4 10             	add    $0x10,%esp
  80222d:	5b                   	pop    %ebx
  80222e:	5e                   	pop    %esi
  80222f:	5d                   	pop    %ebp
  802230:	c3                   	ret    

00802231 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802231:	55                   	push   %ebp
  802232:	89 e5                	mov    %esp,%ebp
  802234:	53                   	push   %ebx
  802235:	83 ec 14             	sub    $0x14,%esp
  802238:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80223b:	8b 45 08             	mov    0x8(%ebp),%eax
  80223e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802243:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802247:	8b 45 0c             	mov    0xc(%ebp),%eax
  80224a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80224e:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802255:	e8 5b e8 ff ff       	call   800ab5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80225a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802260:	b8 05 00 00 00       	mov    $0x5,%eax
  802265:	e8 e6 fd ff ff       	call   802050 <nsipc>
}
  80226a:	83 c4 14             	add    $0x14,%esp
  80226d:	5b                   	pop    %ebx
  80226e:	5d                   	pop    %ebp
  80226f:	c3                   	ret    

00802270 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802270:	55                   	push   %ebp
  802271:	89 e5                	mov    %esp,%ebp
  802273:	53                   	push   %ebx
  802274:	83 ec 14             	sub    $0x14,%esp
  802277:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80227a:	8b 45 08             	mov    0x8(%ebp),%eax
  80227d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802282:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802286:	8b 45 0c             	mov    0xc(%ebp),%eax
  802289:	89 44 24 04          	mov    %eax,0x4(%esp)
  80228d:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802294:	e8 1c e8 ff ff       	call   800ab5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802299:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80229f:	b8 02 00 00 00       	mov    $0x2,%eax
  8022a4:	e8 a7 fd ff ff       	call   802050 <nsipc>
}
  8022a9:	83 c4 14             	add    $0x14,%esp
  8022ac:	5b                   	pop    %ebx
  8022ad:	5d                   	pop    %ebp
  8022ae:	c3                   	ret    

008022af <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8022af:	55                   	push   %ebp
  8022b0:	89 e5                	mov    %esp,%ebp
  8022b2:	83 ec 18             	sub    $0x18,%esp
  8022b5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8022b8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  8022bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8022be:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8022c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8022c8:	e8 83 fd ff ff       	call   802050 <nsipc>
  8022cd:	89 c3                	mov    %eax,%ebx
  8022cf:	85 c0                	test   %eax,%eax
  8022d1:	78 25                	js     8022f8 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8022d3:	be 10 70 80 00       	mov    $0x807010,%esi
  8022d8:	8b 06                	mov    (%esi),%eax
  8022da:	89 44 24 08          	mov    %eax,0x8(%esp)
  8022de:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8022e5:	00 
  8022e6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022e9:	89 04 24             	mov    %eax,(%esp)
  8022ec:	e8 c4 e7 ff ff       	call   800ab5 <memmove>
		*addrlen = ret->ret_addrlen;
  8022f1:	8b 16                	mov    (%esi),%edx
  8022f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8022f6:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  8022f8:	89 d8                	mov    %ebx,%eax
  8022fa:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8022fd:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802300:	89 ec                	mov    %ebp,%esp
  802302:	5d                   	pop    %ebp
  802303:	c3                   	ret    

00802304 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802304:	55                   	push   %ebp
  802305:	89 e5                	mov    %esp,%ebp
  802307:	56                   	push   %esi
  802308:	53                   	push   %ebx
  802309:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80230c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80230f:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  802315:	e8 bd ec ff ff       	call   800fd7 <sys_getenvid>
  80231a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80231d:	89 54 24 10          	mov    %edx,0x10(%esp)
  802321:	8b 55 08             	mov    0x8(%ebp),%edx
  802324:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802328:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80232c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802330:	c7 04 24 80 2f 80 00 	movl   $0x802f80,(%esp)
  802337:	e8 51 de ff ff       	call   80018d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80233c:	89 74 24 04          	mov    %esi,0x4(%esp)
  802340:	8b 45 10             	mov    0x10(%ebp),%eax
  802343:	89 04 24             	mov    %eax,(%esp)
  802346:	e8 e1 dd ff ff       	call   80012c <vcprintf>
	cprintf("\n");
  80234b:	c7 04 24 94 28 80 00 	movl   $0x802894,(%esp)
  802352:	e8 36 de ff ff       	call   80018d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802357:	cc                   	int3   
  802358:	eb fd                	jmp    802357 <_panic+0x53>
	...

0080235c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80235c:	55                   	push   %ebp
  80235d:	89 e5                	mov    %esp,%ebp
  80235f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802362:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802369:	75 54                	jne    8023bf <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  80236b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802372:	00 
  802373:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80237a:	ee 
  80237b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802382:	e8 a6 eb ff ff       	call   800f2d <sys_page_alloc>
  802387:	85 c0                	test   %eax,%eax
  802389:	79 20                	jns    8023ab <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  80238b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80238f:	c7 44 24 08 a4 2f 80 	movl   $0x802fa4,0x8(%esp)
  802396:	00 
  802397:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80239e:	00 
  80239f:	c7 04 24 bc 2f 80 00 	movl   $0x802fbc,(%esp)
  8023a6:	e8 59 ff ff ff       	call   802304 <_panic>
		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  8023ab:	c7 44 24 04 cc 23 80 	movl   $0x8023cc,0x4(%esp)
  8023b2:	00 
  8023b3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8023ba:	e8 55 ea ff ff       	call   800e14 <sys_env_set_pgfault_upcall>

			//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8023bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8023c2:	a3 00 80 80 00       	mov    %eax,0x808000
}
  8023c7:	c9                   	leave  
  8023c8:	c3                   	ret    
  8023c9:	00 00                	add    %al,(%eax)
	...

008023cc <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8023cc:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8023cd:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  8023d2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8023d4:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 0x30(%esp), %eax
  8023d7:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  8023db:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8023de:	89 44 24 30          	mov    %eax,0x30(%esp)
	# put old eip in the pre-reserved 4 bytes space
	movl 0x28(%esp), %ebx
  8023e2:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8023e6:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	addl $0x8, %esp
  8023e8:	83 c4 08             	add    $0x8,%esp
	popal
  8023eb:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $0x4, %esp
  8023ec:	83 c4 04             	add    $0x4,%esp
	popfl
  8023ef:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  8023f0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8023f1:	c3                   	ret    
	...

00802400 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802400:	55                   	push   %ebp
  802401:	89 e5                	mov    %esp,%ebp
  802403:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  802406:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80240c:	b8 01 00 00 00       	mov    $0x1,%eax
  802411:	39 ca                	cmp    %ecx,%edx
  802413:	75 04                	jne    802419 <ipc_find_env+0x19>
  802415:	b0 00                	mov    $0x0,%al
  802417:	eb 11                	jmp    80242a <ipc_find_env+0x2a>
  802419:	89 c2                	mov    %eax,%edx
  80241b:	c1 e2 07             	shl    $0x7,%edx
  80241e:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  802424:	8b 12                	mov    (%edx),%edx
  802426:	39 ca                	cmp    %ecx,%edx
  802428:	75 0f                	jne    802439 <ipc_find_env+0x39>
			return envs[i].env_id;
  80242a:	8d 44 00 01          	lea    0x1(%eax,%eax,1),%eax
  80242e:	c1 e0 06             	shl    $0x6,%eax
  802431:	8b 80 08 00 c0 ee    	mov    -0x113ffff8(%eax),%eax
  802437:	eb 0e                	jmp    802447 <ipc_find_env+0x47>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802439:	83 c0 01             	add    $0x1,%eax
  80243c:	3d 00 04 00 00       	cmp    $0x400,%eax
  802441:	75 d6                	jne    802419 <ipc_find_env+0x19>
  802443:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  802447:	5d                   	pop    %ebp
  802448:	c3                   	ret    

00802449 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802449:	55                   	push   %ebp
  80244a:	89 e5                	mov    %esp,%ebp
  80244c:	57                   	push   %edi
  80244d:	56                   	push   %esi
  80244e:	53                   	push   %ebx
  80244f:	83 ec 1c             	sub    $0x1c,%esp
  802452:	8b 75 08             	mov    0x8(%ebp),%esi
  802455:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802458:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  80245b:	85 db                	test   %ebx,%ebx
  80245d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  802462:	0f 44 d8             	cmove  %eax,%ebx
  802465:	eb 25                	jmp    80248c <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  802467:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80246a:	74 20                	je     80248c <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  80246c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802470:	c7 44 24 08 ca 2f 80 	movl   $0x802fca,0x8(%esp)
  802477:	00 
  802478:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  80247f:	00 
  802480:	c7 04 24 e8 2f 80 00 	movl   $0x802fe8,(%esp)
  802487:	e8 78 fe ff ff       	call   802304 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  80248c:	8b 45 14             	mov    0x14(%ebp),%eax
  80248f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802493:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802497:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80249b:	89 34 24             	mov    %esi,(%esp)
  80249e:	e8 3b e9 ff ff       	call   800dde <sys_ipc_try_send>
  8024a3:	85 c0                	test   %eax,%eax
  8024a5:	75 c0                	jne    802467 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  8024a7:	e8 b8 ea ff ff       	call   800f64 <sys_yield>
}
  8024ac:	83 c4 1c             	add    $0x1c,%esp
  8024af:	5b                   	pop    %ebx
  8024b0:	5e                   	pop    %esi
  8024b1:	5f                   	pop    %edi
  8024b2:	5d                   	pop    %ebp
  8024b3:	c3                   	ret    

008024b4 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8024b4:	55                   	push   %ebp
  8024b5:	89 e5                	mov    %esp,%ebp
  8024b7:	83 ec 28             	sub    $0x28,%esp
  8024ba:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8024bd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8024c0:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8024c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8024c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024c9:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  8024cc:	85 c0                	test   %eax,%eax
  8024ce:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8024d3:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  8024d6:	89 04 24             	mov    %eax,(%esp)
  8024d9:	e8 c7 e8 ff ff       	call   800da5 <sys_ipc_recv>
  8024de:	89 c3                	mov    %eax,%ebx
  8024e0:	85 c0                	test   %eax,%eax
  8024e2:	79 2a                	jns    80250e <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  8024e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8024ec:	c7 04 24 f2 2f 80 00 	movl   $0x802ff2,(%esp)
  8024f3:	e8 95 dc ff ff       	call   80018d <cprintf>
		if(from_env_store != NULL)
  8024f8:	85 f6                	test   %esi,%esi
  8024fa:	74 06                	je     802502 <ipc_recv+0x4e>
			*from_env_store = 0;
  8024fc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  802502:	85 ff                	test   %edi,%edi
  802504:	74 2c                	je     802532 <ipc_recv+0x7e>
			*perm_store = 0;
  802506:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  80250c:	eb 24                	jmp    802532 <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  80250e:	85 f6                	test   %esi,%esi
  802510:	74 0a                	je     80251c <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  802512:	a1 08 50 80 00       	mov    0x805008,%eax
  802517:	8b 40 74             	mov    0x74(%eax),%eax
  80251a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  80251c:	85 ff                	test   %edi,%edi
  80251e:	74 0a                	je     80252a <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  802520:	a1 08 50 80 00       	mov    0x805008,%eax
  802525:	8b 40 78             	mov    0x78(%eax),%eax
  802528:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  80252a:	a1 08 50 80 00       	mov    0x805008,%eax
  80252f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  802532:	89 d8                	mov    %ebx,%eax
  802534:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  802537:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80253a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80253d:	89 ec                	mov    %ebp,%esp
  80253f:	5d                   	pop    %ebp
  802540:	c3                   	ret    
  802541:	00 00                	add    %al,(%eax)
	...

00802544 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802544:	55                   	push   %ebp
  802545:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  802547:	8b 45 08             	mov    0x8(%ebp),%eax
  80254a:	89 c2                	mov    %eax,%edx
  80254c:	c1 ea 16             	shr    $0x16,%edx
  80254f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  802556:	f6 c2 01             	test   $0x1,%dl
  802559:	74 20                	je     80257b <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  80255b:	c1 e8 0c             	shr    $0xc,%eax
  80255e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802565:	a8 01                	test   $0x1,%al
  802567:	74 12                	je     80257b <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802569:	c1 e8 0c             	shr    $0xc,%eax
  80256c:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802571:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  802576:	0f b7 c0             	movzwl %ax,%eax
  802579:	eb 05                	jmp    802580 <pageref+0x3c>
  80257b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802580:	5d                   	pop    %ebp
  802581:	c3                   	ret    
	...

00802590 <__udivdi3>:
  802590:	55                   	push   %ebp
  802591:	89 e5                	mov    %esp,%ebp
  802593:	57                   	push   %edi
  802594:	56                   	push   %esi
  802595:	83 ec 10             	sub    $0x10,%esp
  802598:	8b 45 14             	mov    0x14(%ebp),%eax
  80259b:	8b 55 08             	mov    0x8(%ebp),%edx
  80259e:	8b 75 10             	mov    0x10(%ebp),%esi
  8025a1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8025a4:	85 c0                	test   %eax,%eax
  8025a6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8025a9:	75 35                	jne    8025e0 <__udivdi3+0x50>
  8025ab:	39 fe                	cmp    %edi,%esi
  8025ad:	77 61                	ja     802610 <__udivdi3+0x80>
  8025af:	85 f6                	test   %esi,%esi
  8025b1:	75 0b                	jne    8025be <__udivdi3+0x2e>
  8025b3:	b8 01 00 00 00       	mov    $0x1,%eax
  8025b8:	31 d2                	xor    %edx,%edx
  8025ba:	f7 f6                	div    %esi
  8025bc:	89 c6                	mov    %eax,%esi
  8025be:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8025c1:	31 d2                	xor    %edx,%edx
  8025c3:	89 f8                	mov    %edi,%eax
  8025c5:	f7 f6                	div    %esi
  8025c7:	89 c7                	mov    %eax,%edi
  8025c9:	89 c8                	mov    %ecx,%eax
  8025cb:	f7 f6                	div    %esi
  8025cd:	89 c1                	mov    %eax,%ecx
  8025cf:	89 fa                	mov    %edi,%edx
  8025d1:	89 c8                	mov    %ecx,%eax
  8025d3:	83 c4 10             	add    $0x10,%esp
  8025d6:	5e                   	pop    %esi
  8025d7:	5f                   	pop    %edi
  8025d8:	5d                   	pop    %ebp
  8025d9:	c3                   	ret    
  8025da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8025e0:	39 f8                	cmp    %edi,%eax
  8025e2:	77 1c                	ja     802600 <__udivdi3+0x70>
  8025e4:	0f bd d0             	bsr    %eax,%edx
  8025e7:	83 f2 1f             	xor    $0x1f,%edx
  8025ea:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8025ed:	75 39                	jne    802628 <__udivdi3+0x98>
  8025ef:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8025f2:	0f 86 a0 00 00 00    	jbe    802698 <__udivdi3+0x108>
  8025f8:	39 f8                	cmp    %edi,%eax
  8025fa:	0f 82 98 00 00 00    	jb     802698 <__udivdi3+0x108>
  802600:	31 ff                	xor    %edi,%edi
  802602:	31 c9                	xor    %ecx,%ecx
  802604:	89 c8                	mov    %ecx,%eax
  802606:	89 fa                	mov    %edi,%edx
  802608:	83 c4 10             	add    $0x10,%esp
  80260b:	5e                   	pop    %esi
  80260c:	5f                   	pop    %edi
  80260d:	5d                   	pop    %ebp
  80260e:	c3                   	ret    
  80260f:	90                   	nop
  802610:	89 d1                	mov    %edx,%ecx
  802612:	89 fa                	mov    %edi,%edx
  802614:	89 c8                	mov    %ecx,%eax
  802616:	31 ff                	xor    %edi,%edi
  802618:	f7 f6                	div    %esi
  80261a:	89 c1                	mov    %eax,%ecx
  80261c:	89 fa                	mov    %edi,%edx
  80261e:	89 c8                	mov    %ecx,%eax
  802620:	83 c4 10             	add    $0x10,%esp
  802623:	5e                   	pop    %esi
  802624:	5f                   	pop    %edi
  802625:	5d                   	pop    %ebp
  802626:	c3                   	ret    
  802627:	90                   	nop
  802628:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80262c:	89 f2                	mov    %esi,%edx
  80262e:	d3 e0                	shl    %cl,%eax
  802630:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802633:	b8 20 00 00 00       	mov    $0x20,%eax
  802638:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80263b:	89 c1                	mov    %eax,%ecx
  80263d:	d3 ea                	shr    %cl,%edx
  80263f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802643:	0b 55 ec             	or     -0x14(%ebp),%edx
  802646:	d3 e6                	shl    %cl,%esi
  802648:	89 c1                	mov    %eax,%ecx
  80264a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80264d:	89 fe                	mov    %edi,%esi
  80264f:	d3 ee                	shr    %cl,%esi
  802651:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802655:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802658:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80265b:	d3 e7                	shl    %cl,%edi
  80265d:	89 c1                	mov    %eax,%ecx
  80265f:	d3 ea                	shr    %cl,%edx
  802661:	09 d7                	or     %edx,%edi
  802663:	89 f2                	mov    %esi,%edx
  802665:	89 f8                	mov    %edi,%eax
  802667:	f7 75 ec             	divl   -0x14(%ebp)
  80266a:	89 d6                	mov    %edx,%esi
  80266c:	89 c7                	mov    %eax,%edi
  80266e:	f7 65 e8             	mull   -0x18(%ebp)
  802671:	39 d6                	cmp    %edx,%esi
  802673:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802676:	72 30                	jb     8026a8 <__udivdi3+0x118>
  802678:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80267b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80267f:	d3 e2                	shl    %cl,%edx
  802681:	39 c2                	cmp    %eax,%edx
  802683:	73 05                	jae    80268a <__udivdi3+0xfa>
  802685:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802688:	74 1e                	je     8026a8 <__udivdi3+0x118>
  80268a:	89 f9                	mov    %edi,%ecx
  80268c:	31 ff                	xor    %edi,%edi
  80268e:	e9 71 ff ff ff       	jmp    802604 <__udivdi3+0x74>
  802693:	90                   	nop
  802694:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802698:	31 ff                	xor    %edi,%edi
  80269a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80269f:	e9 60 ff ff ff       	jmp    802604 <__udivdi3+0x74>
  8026a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8026a8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8026ab:	31 ff                	xor    %edi,%edi
  8026ad:	89 c8                	mov    %ecx,%eax
  8026af:	89 fa                	mov    %edi,%edx
  8026b1:	83 c4 10             	add    $0x10,%esp
  8026b4:	5e                   	pop    %esi
  8026b5:	5f                   	pop    %edi
  8026b6:	5d                   	pop    %ebp
  8026b7:	c3                   	ret    
	...

008026c0 <__umoddi3>:
  8026c0:	55                   	push   %ebp
  8026c1:	89 e5                	mov    %esp,%ebp
  8026c3:	57                   	push   %edi
  8026c4:	56                   	push   %esi
  8026c5:	83 ec 20             	sub    $0x20,%esp
  8026c8:	8b 55 14             	mov    0x14(%ebp),%edx
  8026cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8026ce:	8b 7d 10             	mov    0x10(%ebp),%edi
  8026d1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8026d4:	85 d2                	test   %edx,%edx
  8026d6:	89 c8                	mov    %ecx,%eax
  8026d8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8026db:	75 13                	jne    8026f0 <__umoddi3+0x30>
  8026dd:	39 f7                	cmp    %esi,%edi
  8026df:	76 3f                	jbe    802720 <__umoddi3+0x60>
  8026e1:	89 f2                	mov    %esi,%edx
  8026e3:	f7 f7                	div    %edi
  8026e5:	89 d0                	mov    %edx,%eax
  8026e7:	31 d2                	xor    %edx,%edx
  8026e9:	83 c4 20             	add    $0x20,%esp
  8026ec:	5e                   	pop    %esi
  8026ed:	5f                   	pop    %edi
  8026ee:	5d                   	pop    %ebp
  8026ef:	c3                   	ret    
  8026f0:	39 f2                	cmp    %esi,%edx
  8026f2:	77 4c                	ja     802740 <__umoddi3+0x80>
  8026f4:	0f bd ca             	bsr    %edx,%ecx
  8026f7:	83 f1 1f             	xor    $0x1f,%ecx
  8026fa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8026fd:	75 51                	jne    802750 <__umoddi3+0x90>
  8026ff:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802702:	0f 87 e0 00 00 00    	ja     8027e8 <__umoddi3+0x128>
  802708:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80270b:	29 f8                	sub    %edi,%eax
  80270d:	19 d6                	sbb    %edx,%esi
  80270f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802712:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802715:	89 f2                	mov    %esi,%edx
  802717:	83 c4 20             	add    $0x20,%esp
  80271a:	5e                   	pop    %esi
  80271b:	5f                   	pop    %edi
  80271c:	5d                   	pop    %ebp
  80271d:	c3                   	ret    
  80271e:	66 90                	xchg   %ax,%ax
  802720:	85 ff                	test   %edi,%edi
  802722:	75 0b                	jne    80272f <__umoddi3+0x6f>
  802724:	b8 01 00 00 00       	mov    $0x1,%eax
  802729:	31 d2                	xor    %edx,%edx
  80272b:	f7 f7                	div    %edi
  80272d:	89 c7                	mov    %eax,%edi
  80272f:	89 f0                	mov    %esi,%eax
  802731:	31 d2                	xor    %edx,%edx
  802733:	f7 f7                	div    %edi
  802735:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802738:	f7 f7                	div    %edi
  80273a:	eb a9                	jmp    8026e5 <__umoddi3+0x25>
  80273c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802740:	89 c8                	mov    %ecx,%eax
  802742:	89 f2                	mov    %esi,%edx
  802744:	83 c4 20             	add    $0x20,%esp
  802747:	5e                   	pop    %esi
  802748:	5f                   	pop    %edi
  802749:	5d                   	pop    %ebp
  80274a:	c3                   	ret    
  80274b:	90                   	nop
  80274c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802750:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802754:	d3 e2                	shl    %cl,%edx
  802756:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802759:	ba 20 00 00 00       	mov    $0x20,%edx
  80275e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802761:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802764:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802768:	89 fa                	mov    %edi,%edx
  80276a:	d3 ea                	shr    %cl,%edx
  80276c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802770:	0b 55 f4             	or     -0xc(%ebp),%edx
  802773:	d3 e7                	shl    %cl,%edi
  802775:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802779:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80277c:	89 f2                	mov    %esi,%edx
  80277e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802781:	89 c7                	mov    %eax,%edi
  802783:	d3 ea                	shr    %cl,%edx
  802785:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802789:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80278c:	89 c2                	mov    %eax,%edx
  80278e:	d3 e6                	shl    %cl,%esi
  802790:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802794:	d3 ea                	shr    %cl,%edx
  802796:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80279a:	09 d6                	or     %edx,%esi
  80279c:	89 f0                	mov    %esi,%eax
  80279e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8027a1:	d3 e7                	shl    %cl,%edi
  8027a3:	89 f2                	mov    %esi,%edx
  8027a5:	f7 75 f4             	divl   -0xc(%ebp)
  8027a8:	89 d6                	mov    %edx,%esi
  8027aa:	f7 65 e8             	mull   -0x18(%ebp)
  8027ad:	39 d6                	cmp    %edx,%esi
  8027af:	72 2b                	jb     8027dc <__umoddi3+0x11c>
  8027b1:	39 c7                	cmp    %eax,%edi
  8027b3:	72 23                	jb     8027d8 <__umoddi3+0x118>
  8027b5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027b9:	29 c7                	sub    %eax,%edi
  8027bb:	19 d6                	sbb    %edx,%esi
  8027bd:	89 f0                	mov    %esi,%eax
  8027bf:	89 f2                	mov    %esi,%edx
  8027c1:	d3 ef                	shr    %cl,%edi
  8027c3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8027c7:	d3 e0                	shl    %cl,%eax
  8027c9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027cd:	09 f8                	or     %edi,%eax
  8027cf:	d3 ea                	shr    %cl,%edx
  8027d1:	83 c4 20             	add    $0x20,%esp
  8027d4:	5e                   	pop    %esi
  8027d5:	5f                   	pop    %edi
  8027d6:	5d                   	pop    %ebp
  8027d7:	c3                   	ret    
  8027d8:	39 d6                	cmp    %edx,%esi
  8027da:	75 d9                	jne    8027b5 <__umoddi3+0xf5>
  8027dc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8027df:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8027e2:	eb d1                	jmp    8027b5 <__umoddi3+0xf5>
  8027e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027e8:	39 f2                	cmp    %esi,%edx
  8027ea:	0f 82 18 ff ff ff    	jb     802708 <__umoddi3+0x48>
  8027f0:	e9 1d ff ff ff       	jmp    802712 <__umoddi3+0x52>
