
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
  800047:	c7 04 24 60 22 80 00 	movl   $0x802260,(%esp)
  80004e:	e8 3a 01 00 00       	call   80018d <cprintf>
	if ((env = fork()) == 0) {
  800053:	e8 16 10 00 00       	call   80106e <fork>
  800058:	89 c3                	mov    %eax,%ebx
  80005a:	85 c0                	test   %eax,%eax
  80005c:	75 0e                	jne    80006c <umain+0x2c>
		cprintf("I am the child.  Spinning...\n");
  80005e:	c7 04 24 d8 22 80 00 	movl   $0x8022d8,(%esp)
  800065:	e8 23 01 00 00       	call   80018d <cprintf>
  80006a:	eb fe                	jmp    80006a <umain+0x2a>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  80006c:	c7 04 24 88 22 80 00 	movl   $0x802288,(%esp)
  800073:	e8 15 01 00 00       	call   80018d <cprintf>
	sys_yield();
  800078:	e8 74 0e 00 00       	call   800ef1 <sys_yield>
	sys_yield();
  80007d:	e8 6f 0e 00 00       	call   800ef1 <sys_yield>
	sys_yield();
  800082:	e8 6a 0e 00 00       	call   800ef1 <sys_yield>
	sys_yield();
  800087:	e8 65 0e 00 00       	call   800ef1 <sys_yield>
	sys_yield();
  80008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800090:	e8 5c 0e 00 00       	call   800ef1 <sys_yield>
	sys_yield();
  800095:	e8 57 0e 00 00       	call   800ef1 <sys_yield>
	sys_yield();
  80009a:	e8 52 0e 00 00       	call   800ef1 <sys_yield>
	sys_yield();
  80009f:	90                   	nop
  8000a0:	e8 4c 0e 00 00       	call   800ef1 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  8000a5:	c7 04 24 b0 22 80 00 	movl   $0x8022b0,(%esp)
  8000ac:	e8 dc 00 00 00       	call   80018d <cprintf>
	sys_env_destroy(env);
  8000b1:	89 1c 24             	mov    %ebx,(%esp)
  8000b4:	e8 e6 0e 00 00       	call   800f9f <sys_env_destroy>
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
  8000d2:	e8 8d 0e 00 00       	call   800f64 <sys_getenvid>
  8000d7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000dc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000df:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e4:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e9:	85 f6                	test   %esi,%esi
  8000eb:	7e 07                	jle    8000f4 <libmain+0x34>
		binaryname = argv[0];
  8000ed:	8b 03                	mov    (%ebx),%eax
  8000ef:	a3 00 30 80 00       	mov    %eax,0x803000

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
  800116:	e8 8e 18 00 00       	call   8019a9 <close_all>
	sys_env_destroy(0);
  80011b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800122:	e8 78 0e 00 00       	call   800f9f <sys_env_destroy>
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
  800180:	e8 8e 0e 00 00       	call   801013 <sys_cputs>

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
  8001d4:	e8 3a 0e 00 00       	call   801013 <sys_cputs>
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
  80026d:	e8 7e 1d 00 00       	call   801ff0 <__udivdi3>
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
  8002c8:	e8 53 1e 00 00       	call   802120 <__umoddi3>
  8002cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002d1:	0f be 80 00 23 80 00 	movsbl 0x802300(%eax),%eax
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
  8003b5:	ff 24 95 e0 24 80 00 	jmp    *0x8024e0(,%edx,4)
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
  800488:	8b 14 85 40 26 80 00 	mov    0x802640(,%eax,4),%edx
  80048f:	85 d2                	test   %edx,%edx
  800491:	75 20                	jne    8004b3 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800493:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800497:	c7 44 24 08 11 23 80 	movl   $0x802311,0x8(%esp)
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
  8004b7:	c7 44 24 08 c7 29 80 	movl   $0x8029c7,0x8(%esp)
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
  8004f1:	b8 1a 23 80 00       	mov    $0x80231a,%eax
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
  800735:	c7 44 24 0c 34 24 80 	movl   $0x802434,0xc(%esp)
  80073c:	00 
  80073d:	c7 44 24 08 c7 29 80 	movl   $0x8029c7,0x8(%esp)
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
  800763:	c7 44 24 0c 6c 24 80 	movl   $0x80246c,0xc(%esp)
  80076a:	00 
  80076b:	c7 44 24 08 c7 29 80 	movl   $0x8029c7,0x8(%esp)
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
  800d07:	c7 44 24 08 80 26 80 	movl   $0x802680,0x8(%esp)
  800d0e:	00 
  800d0f:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800d16:	00 
  800d17:	c7 04 24 9d 26 80 00 	movl   $0x80269d,(%esp)
  800d1e:	e8 8d 10 00 00       	call   801db0 <_panic>

	return ret;
}
  800d23:	89 d0                	mov    %edx,%eax
  800d25:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d28:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d2b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d2e:	89 ec                	mov    %ebp,%esp
  800d30:	5d                   	pop    %ebp
  800d31:	c3                   	ret    

00800d32 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d38:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d3f:	00 
  800d40:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d47:	00 
  800d48:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d4f:	00 
  800d50:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d5a:	ba 01 00 00 00       	mov    $0x1,%edx
  800d5f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d64:	e8 53 ff ff ff       	call   800cbc <syscall>
}
  800d69:	c9                   	leave  
  800d6a:	c3                   	ret    

00800d6b <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d71:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d78:	00 
  800d79:	8b 45 14             	mov    0x14(%ebp),%eax
  800d7c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d80:	8b 45 10             	mov    0x10(%ebp),%eax
  800d83:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d8a:	89 04 24             	mov    %eax,(%esp)
  800d8d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d90:	ba 00 00 00 00       	mov    $0x0,%edx
  800d95:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d9a:	e8 1d ff ff ff       	call   800cbc <syscall>
}
  800d9f:	c9                   	leave  
  800da0:	c3                   	ret    

00800da1 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
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
  800dcd:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dd2:	e8 e5 fe ff ff       	call   800cbc <syscall>
}
  800dd7:	c9                   	leave  
  800dd8:	c3                   	ret    

00800dd9 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800dd9:	55                   	push   %ebp
  800dda:	89 e5                	mov    %esp,%ebp
  800ddc:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
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
  800e05:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e0a:	e8 ad fe ff ff       	call   800cbc <syscall>
}
  800e0f:	c9                   	leave  
  800e10:	c3                   	ret    

00800e11 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e11:	55                   	push   %ebp
  800e12:	89 e5                	mov    %esp,%ebp
  800e14:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800e17:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e1e:	00 
  800e1f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e26:	00 
  800e27:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e2e:	00 
  800e2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e32:	89 04 24             	mov    %eax,(%esp)
  800e35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e38:	ba 01 00 00 00       	mov    $0x1,%edx
  800e3d:	b8 09 00 00 00       	mov    $0x9,%eax
  800e42:	e8 75 fe ff ff       	call   800cbc <syscall>
}
  800e47:	c9                   	leave  
  800e48:	c3                   	ret    

00800e49 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800e4f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e56:	00 
  800e57:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e5e:	00 
  800e5f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e66:	00 
  800e67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6a:	89 04 24             	mov    %eax,(%esp)
  800e6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e70:	ba 01 00 00 00       	mov    $0x1,%edx
  800e75:	b8 07 00 00 00       	mov    $0x7,%eax
  800e7a:	e8 3d fe ff ff       	call   800cbc <syscall>
}
  800e7f:	c9                   	leave  
  800e80:	c3                   	ret    

00800e81 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800e87:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e8e:	00 
  800e8f:	8b 45 18             	mov    0x18(%ebp),%eax
  800e92:	0b 45 14             	or     0x14(%ebp),%eax
  800e95:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e99:	8b 45 10             	mov    0x10(%ebp),%eax
  800e9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ea0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea3:	89 04 24             	mov    %eax,(%esp)
  800ea6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea9:	ba 01 00 00 00       	mov    $0x1,%edx
  800eae:	b8 06 00 00 00       	mov    $0x6,%eax
  800eb3:	e8 04 fe ff ff       	call   800cbc <syscall>
}
  800eb8:	c9                   	leave  
  800eb9:	c3                   	ret    

00800eba <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800ec0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ec7:	00 
  800ec8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ecf:	00 
  800ed0:	8b 45 10             	mov    0x10(%ebp),%eax
  800ed3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ed7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eda:	89 04 24             	mov    %eax,(%esp)
  800edd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ee0:	ba 01 00 00 00       	mov    $0x1,%edx
  800ee5:	b8 05 00 00 00       	mov    $0x5,%eax
  800eea:	e8 cd fd ff ff       	call   800cbc <syscall>
}
  800eef:	c9                   	leave  
  800ef0:	c3                   	ret    

00800ef1 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800ef1:	55                   	push   %ebp
  800ef2:	89 e5                	mov    %esp,%ebp
  800ef4:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800ef7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800efe:	00 
  800eff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f06:	00 
  800f07:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f0e:	00 
  800f0f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f16:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800f20:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f25:	e8 92 fd ff ff       	call   800cbc <syscall>
}
  800f2a:	c9                   	leave  
  800f2b:	c3                   	ret    

00800f2c <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  800f32:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f39:	00 
  800f3a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f41:	00 
  800f42:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f49:	00 
  800f4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f4d:	89 04 24             	mov    %eax,(%esp)
  800f50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f53:	ba 00 00 00 00       	mov    $0x0,%edx
  800f58:	b8 04 00 00 00       	mov    $0x4,%eax
  800f5d:	e8 5a fd ff ff       	call   800cbc <syscall>
}
  800f62:	c9                   	leave  
  800f63:	c3                   	ret    

00800f64 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800f64:	55                   	push   %ebp
  800f65:	89 e5                	mov    %esp,%ebp
  800f67:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800f6a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f71:	00 
  800f72:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f79:	00 
  800f7a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f81:	00 
  800f82:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f89:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f93:	b8 02 00 00 00       	mov    $0x2,%eax
  800f98:	e8 1f fd ff ff       	call   800cbc <syscall>
}
  800f9d:	c9                   	leave  
  800f9e:	c3                   	ret    

00800f9f <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800f9f:	55                   	push   %ebp
  800fa0:	89 e5                	mov    %esp,%ebp
  800fa2:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800fa5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fac:	00 
  800fad:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fb4:	00 
  800fb5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fbc:	00 
  800fbd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fc4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fc7:	ba 01 00 00 00       	mov    $0x1,%edx
  800fcc:	b8 03 00 00 00       	mov    $0x3,%eax
  800fd1:	e8 e6 fc ff ff       	call   800cbc <syscall>
}
  800fd6:	c9                   	leave  
  800fd7:	c3                   	ret    

00800fd8 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800fde:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fe5:	00 
  800fe6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fed:	00 
  800fee:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ff5:	00 
  800ff6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ffd:	b9 00 00 00 00       	mov    $0x0,%ecx
  801002:	ba 00 00 00 00       	mov    $0x0,%edx
  801007:	b8 01 00 00 00       	mov    $0x1,%eax
  80100c:	e8 ab fc ff ff       	call   800cbc <syscall>
}
  801011:	c9                   	leave  
  801012:	c3                   	ret    

00801013 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801013:	55                   	push   %ebp
  801014:	89 e5                	mov    %esp,%ebp
  801016:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  801019:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801020:	00 
  801021:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801028:	00 
  801029:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801030:	00 
  801031:	8b 45 0c             	mov    0xc(%ebp),%eax
  801034:	89 04 24             	mov    %eax,(%esp)
  801037:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80103a:	ba 00 00 00 00       	mov    $0x0,%edx
  80103f:	b8 00 00 00 00       	mov    $0x0,%eax
  801044:	e8 73 fc ff ff       	call   800cbc <syscall>
}
  801049:	c9                   	leave  
  80104a:	c3                   	ret    
	...

0080104c <sfork>:
}

// Challenge!
int
sfork(void)
{
  80104c:	55                   	push   %ebp
  80104d:	89 e5                	mov    %esp,%ebp
  80104f:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801052:	c7 44 24 08 ab 26 80 	movl   $0x8026ab,0x8(%esp)
  801059:	00 
  80105a:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
  801061:	00 
  801062:	c7 04 24 c1 26 80 00 	movl   $0x8026c1,(%esp)
  801069:	e8 42 0d 00 00       	call   801db0 <_panic>

0080106e <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  80106e:	55                   	push   %ebp
  80106f:	89 e5                	mov    %esp,%ebp
  801071:	57                   	push   %edi
  801072:	56                   	push   %esi
  801073:	53                   	push   %ebx
  801074:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envidnum;
	uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	
	set_pgfault_handler(pgfault);
  801077:	c7 04 24 32 13 80 00 	movl   $0x801332,(%esp)
  80107e:	e8 85 0d 00 00       	call   801e08 <set_pgfault_handler>
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	//if I push esp it will be a pagefault.I come across a bug here.
	__asm __volatile(  
  801083:	ba 08 00 00 00       	mov    $0x8,%edx
  801088:	89 d0                	mov    %edx,%eax
  80108a:	51                   	push   %ecx
  80108b:	52                   	push   %edx
  80108c:	53                   	push   %ebx
  80108d:	55                   	push   %ebp
  80108e:	56                   	push   %esi
  80108f:	57                   	push   %edi
  801090:	89 e5                	mov    %esp,%ebp
  801092:	8d 35 9a 10 80 00    	lea    0x80109a,%esi
  801098:	0f 34                	sysenter 

0080109a <.after_sysenter_label>:
  80109a:	5f                   	pop    %edi
  80109b:	5e                   	pop    %esi
  80109c:	5d                   	pop    %ebp
  80109d:	5b                   	pop    %ebx
  80109e:	5a                   	pop    %edx
  80109f:	59                   	pop    %ecx
  8010a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	envidnum = sys_exofork();
	cprintf("%s:fork[%d]: sys_exofork() return %x\n",__FILE__, __LINE__, envidnum);
  8010a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010a7:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
  8010ae:	00 
  8010af:	c7 44 24 04 c1 26 80 	movl   $0x8026c1,0x4(%esp)
  8010b6:	00 
  8010b7:	c7 04 24 1c 27 80 00 	movl   $0x80271c,(%esp)
  8010be:	e8 ca f0 ff ff       	call   80018d <cprintf>
	if (envidnum < 0)
  8010c3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8010c7:	79 23                	jns    8010ec <.after_sysenter_label+0x52>
		panic("sys_exofork: %e", envidnum);
  8010c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010cc:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010d0:	c7 44 24 08 cc 26 80 	movl   $0x8026cc,0x8(%esp)
  8010d7:	00 
  8010d8:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  8010df:	00 
  8010e0:	c7 04 24 c1 26 80 00 	movl   $0x8026c1,(%esp)
  8010e7:	e8 c4 0c 00 00       	call   801db0 <_panic>
	// We’re the child
	if (envidnum == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  8010ec:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
  8010f1:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  8010f6:	bf 00 00 40 ef       	mov    $0xef400000,%edi
	envidnum = sys_exofork();
	cprintf("%s:fork[%d]: sys_exofork() return %x\n",__FILE__, __LINE__, envidnum);
	if (envidnum < 0)
		panic("sys_exofork: %e", envidnum);
	// We’re the child
	if (envidnum == 0) {
  8010fb:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8010ff:	75 1c                	jne    80111d <.after_sysenter_label+0x83>
		thisenv = &envs[ENVX(sys_getenvid())];
  801101:	e8 5e fe ff ff       	call   800f64 <sys_getenvid>
  801106:	25 ff 03 00 00       	and    $0x3ff,%eax
  80110b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80110e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801113:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801118:	e9 0a 02 00 00       	jmp    801327 <.after_sysenter_label+0x28d>
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
  80111d:	89 d8                	mov    %ebx,%eax
  80111f:	c1 e8 16             	shr    $0x16,%eax
  801122:	8b 04 86             	mov    (%esi,%eax,4),%eax
  801125:	a8 01                	test   $0x1,%al
  801127:	0f 84 43 01 00 00    	je     801270 <.after_sysenter_label+0x1d6>
  80112d:	89 d8                	mov    %ebx,%eax
  80112f:	c1 e8 0c             	shr    $0xc,%eax
  801132:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801135:	f6 c2 01             	test   $0x1,%dl
  801138:	0f 84 32 01 00 00    	je     801270 <.after_sysenter_label+0x1d6>
  80113e:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801141:	f6 c2 04             	test   $0x4,%dl
  801144:	0f 84 26 01 00 00    	je     801270 <.after_sysenter_label+0x1d6>
{
	int r;

	// LAB 4: Your code here.
	int perm;
	void * addr = (void *) ((uint32_t) pn * PGSIZE);
  80114a:	c1 e0 0c             	shl    $0xc,%eax
  80114d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	pte_t pte = vpt[PGNUM(addr)];
  801150:	c1 e8 0c             	shr    $0xc,%eax
  801153:	8b 04 87             	mov    (%edi,%eax,4),%eax
	perm = pte & PTE_SYSCALL;
  801156:	89 c2                	mov    %eax,%edx
  801158:	81 e2 07 0e 00 00    	and    $0xe07,%edx
	
	if (perm & (PTE_W|PTE_COW)) 
  80115e:	a9 02 08 00 00       	test   $0x802,%eax
  801163:	0f 84 a0 00 00 00    	je     801209 <.after_sysenter_label+0x16f>
	{
		 perm &= ~PTE_W;
  801169:	83 e2 fd             	and    $0xfffffffd,%edx
		 perm |= PTE_COW;
  80116c:	80 ce 08             	or     $0x8,%dh
  80116f:	89 55 dc             	mov    %edx,-0x24(%ebp)
		//map in child
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  801172:	89 54 24 10          	mov    %edx,0x10(%esp)
  801176:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801179:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80117d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801180:	89 44 24 08          	mov    %eax,0x8(%esp)
  801184:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801187:	89 44 24 04          	mov    %eax,0x4(%esp)
  80118b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801192:	e8 ea fc ff ff       	call   800e81 <sys_page_map>
  801197:	85 c0                	test   %eax,%eax
  801199:	79 20                	jns    8011bb <.after_sysenter_label+0x121>
			panic ("duppage: page re-mapping failed at 1 : %e", r);
  80119b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80119f:	c7 44 24 08 44 27 80 	movl   $0x802744,0x8(%esp)
  8011a6:	00 
  8011a7:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
  8011ae:	00 
  8011af:	c7 04 24 c1 26 80 00 	movl   $0x8026c1,(%esp)
  8011b6:	e8 f5 0b 00 00       	call   801db0 <_panic>
		//remap in the parent		
		if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0)
  8011bb:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8011be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011c9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8011d0:	00 
  8011d1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011dc:	e8 a0 fc ff ff       	call   800e81 <sys_page_map>
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	0f 89 87 00 00 00    	jns    801270 <.after_sysenter_label+0x1d6>
			panic ("duppage: page re-mapping failed at 2 : %e", r);
  8011e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011ed:	c7 44 24 08 70 27 80 	movl   $0x802770,0x8(%esp)
  8011f4:	00 
  8011f5:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  8011fc:	00 
  8011fd:	c7 04 24 c1 26 80 00 	movl   $0x8026c1,(%esp)
  801204:	e8 a7 0b 00 00       	call   801db0 <_panic>
	}
	else //include PTE_SHARE
	{
		cprintf("map two %x----%x\n",envid,addr);
  801209:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80120c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801210:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801213:	89 44 24 04          	mov    %eax,0x4(%esp)
  801217:	c7 04 24 dc 26 80 00 	movl   $0x8026dc,(%esp)
  80121e:	e8 6a ef ff ff       	call   80018d <cprintf>
		if ((r = sys_page_map (0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  801223:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80122a:	00 
  80122b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80122e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801232:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801235:	89 44 24 08          	mov    %eax,0x8(%esp)
  801239:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80123c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801240:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801247:	e8 35 fc ff ff       	call   800e81 <sys_page_map>
  80124c:	85 c0                	test   %eax,%eax
  80124e:	79 20                	jns    801270 <.after_sysenter_label+0x1d6>
			panic ("duppage: page re-mapping failed at 3 : %e", r);
  801250:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801254:	c7 44 24 08 9c 27 80 	movl   $0x80279c,0x8(%esp)
  80125b:	00 
  80125c:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  801263:	00 
  801264:	c7 04 24 c1 26 80 00 	movl   $0x8026c1,(%esp)
  80126b:	e8 40 0b 00 00       	call   801db0 <_panic>
	if (envidnum == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
  801270:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801276:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  80127c:	0f 85 9b fe ff ff    	jne    80111d <.after_sysenter_label+0x83>
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
			duppage(envidnum,PGNUM(addr));
	}
	if ((r = sys_page_alloc (envidnum, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P)) < 0)
  801282:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801289:	00 
  80128a:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801291:	ee 
  801292:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801295:	89 04 24             	mov    %eax,(%esp)
  801298:	e8 1d fc ff ff       	call   800eba <sys_page_alloc>
  80129d:	85 c0                	test   %eax,%eax
  80129f:	79 20                	jns    8012c1 <.after_sysenter_label+0x227>
		panic ("fork: page allocation failed : %e", r);
  8012a1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012a5:	c7 44 24 08 c8 27 80 	movl   $0x8027c8,0x8(%esp)
  8012ac:	00 
  8012ad:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  8012b4:	00 
  8012b5:	c7 04 24 c1 26 80 00 	movl   $0x8026c1,(%esp)
  8012bc:	e8 ef 0a 00 00       	call   801db0 <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	sys_env_set_pgfault_upcall (envidnum, _pgfault_upcall);
  8012c1:	c7 44 24 04 78 1e 80 	movl   $0x801e78,0x4(%esp)
  8012c8:	00 
  8012c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012cc:	89 04 24             	mov    %eax,(%esp)
  8012cf:	e8 cd fa ff ff       	call   800da1 <sys_env_set_pgfault_upcall>
	//cprintf("%x-----%x\n",&envid,envid);
	// Start the child environment running
	if((r = sys_env_set_status(envidnum, ENV_RUNNABLE)) < 0)
  8012d4:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8012db:	00 
  8012dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012df:	89 04 24             	mov    %eax,(%esp)
  8012e2:	e8 2a fb ff ff       	call   800e11 <sys_env_set_status>
  8012e7:	85 c0                	test   %eax,%eax
  8012e9:	79 20                	jns    80130b <.after_sysenter_label+0x271>
		panic("fork: set child env status failed : %e", r);
  8012eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012ef:	c7 44 24 08 ec 27 80 	movl   $0x8027ec,0x8(%esp)
  8012f6:	00 
  8012f7:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
  8012fe:	00 
  8012ff:	c7 04 24 c1 26 80 00 	movl   $0x8026c1,(%esp)
  801306:	e8 a5 0a 00 00       	call   801db0 <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("%x-----%x\n",&envidnum,envidnum);
	cprintf("%s:fork[%d]: fork return\n", __FILE__, __LINE__);
  80130b:	c7 44 24 08 9a 00 00 	movl   $0x9a,0x8(%esp)
  801312:	00 
  801313:	c7 44 24 04 c1 26 80 	movl   $0x8026c1,0x4(%esp)
  80131a:	00 
  80131b:	c7 04 24 ee 26 80 00 	movl   $0x8026ee,(%esp)
  801322:	e8 66 ee ff ff       	call   80018d <cprintf>
	return envidnum;

	//panic("fork not implemented");
}
  801327:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80132a:	83 c4 3c             	add    $0x3c,%esp
  80132d:	5b                   	pop    %ebx
  80132e:	5e                   	pop    %esi
  80132f:	5f                   	pop    %edi
  801330:	5d                   	pop    %ebp
  801331:	c3                   	ret    

00801332 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801332:	55                   	push   %ebp
  801333:	89 e5                	mov    %esp,%ebp
  801335:	57                   	push   %edi
  801336:	56                   	push   %esi
  801337:	53                   	push   %ebx
  801338:	83 ec 2c             	sub    $0x2c,%esp
  80133b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	void *addr = (void *) utf->utf_fault_va;
  80133e:	8b 33                	mov    (%ebx),%esi
	uint32_t err = utf->utf_err;
  801340:	8b 7b 04             	mov    0x4(%ebx),%edi
	// Check that the faulting access was (1) a write, and (2) to a
	// copy-on-write page.  If not, panic.
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).
	cprintf("pgfault: do page fault here %x\n",utf->utf_eflags);
  801343:	8b 43 2c             	mov    0x2c(%ebx),%eax
  801346:	89 44 24 04          	mov    %eax,0x4(%esp)
  80134a:	c7 04 24 14 28 80 00 	movl   $0x802814,(%esp)
  801351:	e8 37 ee ff ff       	call   80018d <cprintf>
	// LAB 4: Your code here.
	if((err & FEC_WR) == 0)
  801356:	f7 c7 02 00 00 00    	test   $0x2,%edi
  80135c:	75 2b                	jne    801389 <pgfault+0x57>
		panic("pgfault: fault is not a write (err: %08x va: %08x ip: %08x)",err, addr, utf->utf_eip);
  80135e:	8b 43 28             	mov    0x28(%ebx),%eax
  801361:	89 44 24 14          	mov    %eax,0x14(%esp)
  801365:	89 74 24 10          	mov    %esi,0x10(%esp)
  801369:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80136d:	c7 44 24 08 34 28 80 	movl   $0x802834,0x8(%esp)
  801374:	00 
  801375:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  80137c:	00 
  80137d:	c7 04 24 c1 26 80 00 	movl   $0x8026c1,(%esp)
  801384:	e8 27 0a 00 00       	call   801db0 <_panic>
	if ((vpd[PDX(addr)] & PTE_P) == 0 || (vpt[PGNUM(addr)] & PTE_COW) == 0)
  801389:	89 f0                	mov    %esi,%eax
  80138b:	c1 e8 16             	shr    $0x16,%eax
  80138e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801395:	a8 01                	test   $0x1,%al
  801397:	74 11                	je     8013aa <pgfault+0x78>
  801399:	89 f0                	mov    %esi,%eax
  80139b:	c1 e8 0c             	shr    $0xc,%eax
  80139e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013a5:	f6 c4 08             	test   $0x8,%ah
  8013a8:	75 1c                	jne    8013c6 <pgfault+0x94>
		panic ("pgfault: not a write or attempting to access a non-COW page");
  8013aa:	c7 44 24 08 70 28 80 	movl   $0x802870,0x8(%esp)
  8013b1:	00 
  8013b2:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8013b9:	00 
  8013ba:	c7 04 24 c1 26 80 00 	movl   $0x8026c1,(%esp)
  8013c1:	e8 ea 09 00 00       	call   801db0 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc (0, (void *)PFTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  8013c6:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8013cd:	00 
  8013ce:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8013d5:	00 
  8013d6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8013dd:	e8 d8 fa ff ff       	call   800eba <sys_page_alloc>
  8013e2:	85 c0                	test   %eax,%eax
  8013e4:	79 20                	jns    801406 <pgfault+0xd4>
		panic ("pgfault: page allocation failed : %e", r);
  8013e6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013ea:	c7 44 24 08 ac 28 80 	movl   $0x8028ac,0x8(%esp)
  8013f1:	00 
  8013f2:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8013f9:	00 
  8013fa:	c7 04 24 c1 26 80 00 	movl   $0x8026c1,(%esp)
  801401:	e8 aa 09 00 00       	call   801db0 <_panic>
	addr = ROUNDDOWN (addr, PGSIZE);
  801406:	89 f3                	mov    %esi,%ebx
  801408:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove (PFTEMP, addr, PGSIZE);
  80140e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  801415:	00 
  801416:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80141a:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  801421:	e8 8f f6 ff ff       	call   800ab5 <memmove>
	if((r = sys_page_map (0, PFTEMP, 0, addr, PTE_U|PTE_P|PTE_W)) < 0)
  801426:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  80142d:	00 
  80142e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801432:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801439:	00 
  80143a:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801441:	00 
  801442:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801449:	e8 33 fa ff ff       	call   800e81 <sys_page_map>
  80144e:	85 c0                	test   %eax,%eax
  801450:	79 20                	jns    801472 <pgfault+0x140>
		panic ("pgfault: page mapping failed : %e", r);
  801452:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801456:	c7 44 24 08 d4 28 80 	movl   $0x8028d4,0x8(%esp)
  80145d:	00 
  80145e:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  801465:	00 
  801466:	c7 04 24 c1 26 80 00 	movl   $0x8026c1,(%esp)
  80146d:	e8 3e 09 00 00       	call   801db0 <_panic>
	if((r = sys_page_unmap(0,PFTEMP)) < 0)
  801472:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801479:	00 
  80147a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801481:	e8 c3 f9 ff ff       	call   800e49 <sys_page_unmap>
  801486:	85 c0                	test   %eax,%eax
  801488:	79 20                	jns    8014aa <pgfault+0x178>
		panic("pgfault: page unmapping failed : %e", r);
  80148a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80148e:	c7 44 24 08 f8 28 80 	movl   $0x8028f8,0x8(%esp)
  801495:	00 
  801496:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  80149d:	00 
  80149e:	c7 04 24 c1 26 80 00 	movl   $0x8026c1,(%esp)
  8014a5:	e8 06 09 00 00       	call   801db0 <_panic>
	cprintf("pgfault: finish\n");
  8014aa:	c7 04 24 08 27 80 00 	movl   $0x802708,(%esp)
  8014b1:	e8 d7 ec ff ff       	call   80018d <cprintf>
	/* __asm__ volatile("movl %%esp, %0\n\t" */
	/* 		 :"=r"(gaga) */
	/* 		 ::); */
	/* cprintf("gaga----------%x\n", gaga); */
	//panic("pgfault not implemented");
}
  8014b6:	83 c4 2c             	add    $0x2c,%esp
  8014b9:	5b                   	pop    %ebx
  8014ba:	5e                   	pop    %esi
  8014bb:	5f                   	pop    %edi
  8014bc:	5d                   	pop    %ebp
  8014bd:	c3                   	ret    
	...

008014c0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8014c6:	05 00 00 00 30       	add    $0x30000000,%eax
  8014cb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8014ce:	5d                   	pop    %ebp
  8014cf:	c3                   	ret    

008014d0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8014d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8014d9:	89 04 24             	mov    %eax,(%esp)
  8014dc:	e8 df ff ff ff       	call   8014c0 <fd2num>
  8014e1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8014e6:	c1 e0 0c             	shl    $0xc,%eax
}
  8014e9:	c9                   	leave  
  8014ea:	c3                   	ret    

008014eb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014eb:	55                   	push   %ebp
  8014ec:	89 e5                	mov    %esp,%ebp
  8014ee:	57                   	push   %edi
  8014ef:	56                   	push   %esi
  8014f0:	53                   	push   %ebx
  8014f1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8014f4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8014f9:	a8 01                	test   $0x1,%al
  8014fb:	74 36                	je     801533 <fd_alloc+0x48>
  8014fd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801502:	a8 01                	test   $0x1,%al
  801504:	74 2d                	je     801533 <fd_alloc+0x48>
  801506:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80150b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801510:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801515:	89 c3                	mov    %eax,%ebx
  801517:	89 c2                	mov    %eax,%edx
  801519:	c1 ea 16             	shr    $0x16,%edx
  80151c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80151f:	f6 c2 01             	test   $0x1,%dl
  801522:	74 14                	je     801538 <fd_alloc+0x4d>
  801524:	89 c2                	mov    %eax,%edx
  801526:	c1 ea 0c             	shr    $0xc,%edx
  801529:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80152c:	f6 c2 01             	test   $0x1,%dl
  80152f:	75 10                	jne    801541 <fd_alloc+0x56>
  801531:	eb 05                	jmp    801538 <fd_alloc+0x4d>
  801533:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801538:	89 1f                	mov    %ebx,(%edi)
  80153a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80153f:	eb 17                	jmp    801558 <fd_alloc+0x6d>
  801541:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801546:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80154b:	75 c8                	jne    801515 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80154d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801553:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801558:	5b                   	pop    %ebx
  801559:	5e                   	pop    %esi
  80155a:	5f                   	pop    %edi
  80155b:	5d                   	pop    %ebp
  80155c:	c3                   	ret    

0080155d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80155d:	55                   	push   %ebp
  80155e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801560:	8b 45 08             	mov    0x8(%ebp),%eax
  801563:	83 f8 1f             	cmp    $0x1f,%eax
  801566:	77 36                	ja     80159e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801568:	05 00 00 0d 00       	add    $0xd0000,%eax
  80156d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801570:	89 c2                	mov    %eax,%edx
  801572:	c1 ea 16             	shr    $0x16,%edx
  801575:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80157c:	f6 c2 01             	test   $0x1,%dl
  80157f:	74 1d                	je     80159e <fd_lookup+0x41>
  801581:	89 c2                	mov    %eax,%edx
  801583:	c1 ea 0c             	shr    $0xc,%edx
  801586:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80158d:	f6 c2 01             	test   $0x1,%dl
  801590:	74 0c                	je     80159e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801592:	8b 55 0c             	mov    0xc(%ebp),%edx
  801595:	89 02                	mov    %eax,(%edx)
  801597:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80159c:	eb 05                	jmp    8015a3 <fd_lookup+0x46>
  80159e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015a3:	5d                   	pop    %ebp
  8015a4:	c3                   	ret    

008015a5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8015a5:	55                   	push   %ebp
  8015a6:	89 e5                	mov    %esp,%ebp
  8015a8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015ab:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8015b5:	89 04 24             	mov    %eax,(%esp)
  8015b8:	e8 a0 ff ff ff       	call   80155d <fd_lookup>
  8015bd:	85 c0                	test   %eax,%eax
  8015bf:	78 0e                	js     8015cf <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8015c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015c7:	89 50 04             	mov    %edx,0x4(%eax)
  8015ca:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8015cf:	c9                   	leave  
  8015d0:	c3                   	ret    

008015d1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8015d1:	55                   	push   %ebp
  8015d2:	89 e5                	mov    %esp,%ebp
  8015d4:	56                   	push   %esi
  8015d5:	53                   	push   %ebx
  8015d6:	83 ec 10             	sub    $0x10,%esp
  8015d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8015df:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8015e4:	b8 04 30 80 00       	mov    $0x803004,%eax
  8015e9:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8015ef:	75 11                	jne    801602 <dev_lookup+0x31>
  8015f1:	eb 04                	jmp    8015f7 <dev_lookup+0x26>
  8015f3:	39 08                	cmp    %ecx,(%eax)
  8015f5:	75 10                	jne    801607 <dev_lookup+0x36>
			*dev = devtab[i];
  8015f7:	89 03                	mov    %eax,(%ebx)
  8015f9:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8015fe:	66 90                	xchg   %ax,%ax
  801600:	eb 36                	jmp    801638 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801602:	be 98 29 80 00       	mov    $0x802998,%esi
  801607:	83 c2 01             	add    $0x1,%edx
  80160a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80160d:	85 c0                	test   %eax,%eax
  80160f:	75 e2                	jne    8015f3 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801611:	a1 04 40 80 00       	mov    0x804004,%eax
  801616:	8b 40 48             	mov    0x48(%eax),%eax
  801619:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80161d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801621:	c7 04 24 1c 29 80 00 	movl   $0x80291c,(%esp)
  801628:	e8 60 eb ff ff       	call   80018d <cprintf>
	*dev = 0;
  80162d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801633:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801638:	83 c4 10             	add    $0x10,%esp
  80163b:	5b                   	pop    %ebx
  80163c:	5e                   	pop    %esi
  80163d:	5d                   	pop    %ebp
  80163e:	c3                   	ret    

0080163f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80163f:	55                   	push   %ebp
  801640:	89 e5                	mov    %esp,%ebp
  801642:	53                   	push   %ebx
  801643:	83 ec 24             	sub    $0x24,%esp
  801646:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801649:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80164c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801650:	8b 45 08             	mov    0x8(%ebp),%eax
  801653:	89 04 24             	mov    %eax,(%esp)
  801656:	e8 02 ff ff ff       	call   80155d <fd_lookup>
  80165b:	85 c0                	test   %eax,%eax
  80165d:	78 53                	js     8016b2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80165f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801662:	89 44 24 04          	mov    %eax,0x4(%esp)
  801666:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801669:	8b 00                	mov    (%eax),%eax
  80166b:	89 04 24             	mov    %eax,(%esp)
  80166e:	e8 5e ff ff ff       	call   8015d1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801673:	85 c0                	test   %eax,%eax
  801675:	78 3b                	js     8016b2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801677:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80167c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80167f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801683:	74 2d                	je     8016b2 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801685:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801688:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80168f:	00 00 00 
	stat->st_isdir = 0;
  801692:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801699:	00 00 00 
	stat->st_dev = dev;
  80169c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016ac:	89 14 24             	mov    %edx,(%esp)
  8016af:	ff 50 14             	call   *0x14(%eax)
}
  8016b2:	83 c4 24             	add    $0x24,%esp
  8016b5:	5b                   	pop    %ebx
  8016b6:	5d                   	pop    %ebp
  8016b7:	c3                   	ret    

008016b8 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8016b8:	55                   	push   %ebp
  8016b9:	89 e5                	mov    %esp,%ebp
  8016bb:	53                   	push   %ebx
  8016bc:	83 ec 24             	sub    $0x24,%esp
  8016bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016c9:	89 1c 24             	mov    %ebx,(%esp)
  8016cc:	e8 8c fe ff ff       	call   80155d <fd_lookup>
  8016d1:	85 c0                	test   %eax,%eax
  8016d3:	78 5f                	js     801734 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016df:	8b 00                	mov    (%eax),%eax
  8016e1:	89 04 24             	mov    %eax,(%esp)
  8016e4:	e8 e8 fe ff ff       	call   8015d1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016e9:	85 c0                	test   %eax,%eax
  8016eb:	78 47                	js     801734 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016ed:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016f0:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8016f4:	75 23                	jne    801719 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8016f6:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8016fb:	8b 40 48             	mov    0x48(%eax),%eax
  8016fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801702:	89 44 24 04          	mov    %eax,0x4(%esp)
  801706:	c7 04 24 3c 29 80 00 	movl   $0x80293c,(%esp)
  80170d:	e8 7b ea ff ff       	call   80018d <cprintf>
  801712:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801717:	eb 1b                	jmp    801734 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801719:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80171c:	8b 48 18             	mov    0x18(%eax),%ecx
  80171f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801724:	85 c9                	test   %ecx,%ecx
  801726:	74 0c                	je     801734 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801728:	8b 45 0c             	mov    0xc(%ebp),%eax
  80172b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80172f:	89 14 24             	mov    %edx,(%esp)
  801732:	ff d1                	call   *%ecx
}
  801734:	83 c4 24             	add    $0x24,%esp
  801737:	5b                   	pop    %ebx
  801738:	5d                   	pop    %ebp
  801739:	c3                   	ret    

0080173a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80173a:	55                   	push   %ebp
  80173b:	89 e5                	mov    %esp,%ebp
  80173d:	53                   	push   %ebx
  80173e:	83 ec 24             	sub    $0x24,%esp
  801741:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801744:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801747:	89 44 24 04          	mov    %eax,0x4(%esp)
  80174b:	89 1c 24             	mov    %ebx,(%esp)
  80174e:	e8 0a fe ff ff       	call   80155d <fd_lookup>
  801753:	85 c0                	test   %eax,%eax
  801755:	78 66                	js     8017bd <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801757:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80175a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80175e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801761:	8b 00                	mov    (%eax),%eax
  801763:	89 04 24             	mov    %eax,(%esp)
  801766:	e8 66 fe ff ff       	call   8015d1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80176b:	85 c0                	test   %eax,%eax
  80176d:	78 4e                	js     8017bd <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80176f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801772:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801776:	75 23                	jne    80179b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801778:	a1 04 40 80 00       	mov    0x804004,%eax
  80177d:	8b 40 48             	mov    0x48(%eax),%eax
  801780:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801784:	89 44 24 04          	mov    %eax,0x4(%esp)
  801788:	c7 04 24 5d 29 80 00 	movl   $0x80295d,(%esp)
  80178f:	e8 f9 e9 ff ff       	call   80018d <cprintf>
  801794:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801799:	eb 22                	jmp    8017bd <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80179b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80179e:	8b 48 0c             	mov    0xc(%eax),%ecx
  8017a1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017a6:	85 c9                	test   %ecx,%ecx
  8017a8:	74 13                	je     8017bd <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8017ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b8:	89 14 24             	mov    %edx,(%esp)
  8017bb:	ff d1                	call   *%ecx
}
  8017bd:	83 c4 24             	add    $0x24,%esp
  8017c0:	5b                   	pop    %ebx
  8017c1:	5d                   	pop    %ebp
  8017c2:	c3                   	ret    

008017c3 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017c3:	55                   	push   %ebp
  8017c4:	89 e5                	mov    %esp,%ebp
  8017c6:	53                   	push   %ebx
  8017c7:	83 ec 24             	sub    $0x24,%esp
  8017ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d4:	89 1c 24             	mov    %ebx,(%esp)
  8017d7:	e8 81 fd ff ff       	call   80155d <fd_lookup>
  8017dc:	85 c0                	test   %eax,%eax
  8017de:	78 6b                	js     80184b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ea:	8b 00                	mov    (%eax),%eax
  8017ec:	89 04 24             	mov    %eax,(%esp)
  8017ef:	e8 dd fd ff ff       	call   8015d1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017f4:	85 c0                	test   %eax,%eax
  8017f6:	78 53                	js     80184b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017fb:	8b 42 08             	mov    0x8(%edx),%eax
  8017fe:	83 e0 03             	and    $0x3,%eax
  801801:	83 f8 01             	cmp    $0x1,%eax
  801804:	75 23                	jne    801829 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801806:	a1 04 40 80 00       	mov    0x804004,%eax
  80180b:	8b 40 48             	mov    0x48(%eax),%eax
  80180e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801812:	89 44 24 04          	mov    %eax,0x4(%esp)
  801816:	c7 04 24 7a 29 80 00 	movl   $0x80297a,(%esp)
  80181d:	e8 6b e9 ff ff       	call   80018d <cprintf>
  801822:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801827:	eb 22                	jmp    80184b <read+0x88>
	}
	if (!dev->dev_read)
  801829:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80182c:	8b 48 08             	mov    0x8(%eax),%ecx
  80182f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801834:	85 c9                	test   %ecx,%ecx
  801836:	74 13                	je     80184b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801838:	8b 45 10             	mov    0x10(%ebp),%eax
  80183b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80183f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801842:	89 44 24 04          	mov    %eax,0x4(%esp)
  801846:	89 14 24             	mov    %edx,(%esp)
  801849:	ff d1                	call   *%ecx
}
  80184b:	83 c4 24             	add    $0x24,%esp
  80184e:	5b                   	pop    %ebx
  80184f:	5d                   	pop    %ebp
  801850:	c3                   	ret    

00801851 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801851:	55                   	push   %ebp
  801852:	89 e5                	mov    %esp,%ebp
  801854:	57                   	push   %edi
  801855:	56                   	push   %esi
  801856:	53                   	push   %ebx
  801857:	83 ec 1c             	sub    $0x1c,%esp
  80185a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80185d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801860:	ba 00 00 00 00       	mov    $0x0,%edx
  801865:	bb 00 00 00 00       	mov    $0x0,%ebx
  80186a:	b8 00 00 00 00       	mov    $0x0,%eax
  80186f:	85 f6                	test   %esi,%esi
  801871:	74 29                	je     80189c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801873:	89 f0                	mov    %esi,%eax
  801875:	29 d0                	sub    %edx,%eax
  801877:	89 44 24 08          	mov    %eax,0x8(%esp)
  80187b:	03 55 0c             	add    0xc(%ebp),%edx
  80187e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801882:	89 3c 24             	mov    %edi,(%esp)
  801885:	e8 39 ff ff ff       	call   8017c3 <read>
		if (m < 0)
  80188a:	85 c0                	test   %eax,%eax
  80188c:	78 0e                	js     80189c <readn+0x4b>
			return m;
		if (m == 0)
  80188e:	85 c0                	test   %eax,%eax
  801890:	74 08                	je     80189a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801892:	01 c3                	add    %eax,%ebx
  801894:	89 da                	mov    %ebx,%edx
  801896:	39 f3                	cmp    %esi,%ebx
  801898:	72 d9                	jb     801873 <readn+0x22>
  80189a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80189c:	83 c4 1c             	add    $0x1c,%esp
  80189f:	5b                   	pop    %ebx
  8018a0:	5e                   	pop    %esi
  8018a1:	5f                   	pop    %edi
  8018a2:	5d                   	pop    %ebp
  8018a3:	c3                   	ret    

008018a4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8018a4:	55                   	push   %ebp
  8018a5:	89 e5                	mov    %esp,%ebp
  8018a7:	83 ec 28             	sub    $0x28,%esp
  8018aa:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8018ad:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8018b0:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8018b3:	89 34 24             	mov    %esi,(%esp)
  8018b6:	e8 05 fc ff ff       	call   8014c0 <fd2num>
  8018bb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8018be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8018c2:	89 04 24             	mov    %eax,(%esp)
  8018c5:	e8 93 fc ff ff       	call   80155d <fd_lookup>
  8018ca:	89 c3                	mov    %eax,%ebx
  8018cc:	85 c0                	test   %eax,%eax
  8018ce:	78 05                	js     8018d5 <fd_close+0x31>
  8018d0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8018d3:	74 0e                	je     8018e3 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8018d5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8018d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8018de:	0f 44 d8             	cmove  %eax,%ebx
  8018e1:	eb 3d                	jmp    801920 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8018e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018ea:	8b 06                	mov    (%esi),%eax
  8018ec:	89 04 24             	mov    %eax,(%esp)
  8018ef:	e8 dd fc ff ff       	call   8015d1 <dev_lookup>
  8018f4:	89 c3                	mov    %eax,%ebx
  8018f6:	85 c0                	test   %eax,%eax
  8018f8:	78 16                	js     801910 <fd_close+0x6c>
		if (dev->dev_close)
  8018fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018fd:	8b 40 10             	mov    0x10(%eax),%eax
  801900:	bb 00 00 00 00       	mov    $0x0,%ebx
  801905:	85 c0                	test   %eax,%eax
  801907:	74 07                	je     801910 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801909:	89 34 24             	mov    %esi,(%esp)
  80190c:	ff d0                	call   *%eax
  80190e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801910:	89 74 24 04          	mov    %esi,0x4(%esp)
  801914:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80191b:	e8 29 f5 ff ff       	call   800e49 <sys_page_unmap>
	return r;
}
  801920:	89 d8                	mov    %ebx,%eax
  801922:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801925:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801928:	89 ec                	mov    %ebp,%esp
  80192a:	5d                   	pop    %ebp
  80192b:	c3                   	ret    

0080192c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80192c:	55                   	push   %ebp
  80192d:	89 e5                	mov    %esp,%ebp
  80192f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801932:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801935:	89 44 24 04          	mov    %eax,0x4(%esp)
  801939:	8b 45 08             	mov    0x8(%ebp),%eax
  80193c:	89 04 24             	mov    %eax,(%esp)
  80193f:	e8 19 fc ff ff       	call   80155d <fd_lookup>
  801944:	85 c0                	test   %eax,%eax
  801946:	78 13                	js     80195b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801948:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80194f:	00 
  801950:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801953:	89 04 24             	mov    %eax,(%esp)
  801956:	e8 49 ff ff ff       	call   8018a4 <fd_close>
}
  80195b:	c9                   	leave  
  80195c:	c3                   	ret    

0080195d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80195d:	55                   	push   %ebp
  80195e:	89 e5                	mov    %esp,%ebp
  801960:	83 ec 18             	sub    $0x18,%esp
  801963:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801966:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801969:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801970:	00 
  801971:	8b 45 08             	mov    0x8(%ebp),%eax
  801974:	89 04 24             	mov    %eax,(%esp)
  801977:	e8 78 03 00 00       	call   801cf4 <open>
  80197c:	89 c3                	mov    %eax,%ebx
  80197e:	85 c0                	test   %eax,%eax
  801980:	78 1b                	js     80199d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801982:	8b 45 0c             	mov    0xc(%ebp),%eax
  801985:	89 44 24 04          	mov    %eax,0x4(%esp)
  801989:	89 1c 24             	mov    %ebx,(%esp)
  80198c:	e8 ae fc ff ff       	call   80163f <fstat>
  801991:	89 c6                	mov    %eax,%esi
	close(fd);
  801993:	89 1c 24             	mov    %ebx,(%esp)
  801996:	e8 91 ff ff ff       	call   80192c <close>
  80199b:	89 f3                	mov    %esi,%ebx
	return r;
}
  80199d:	89 d8                	mov    %ebx,%eax
  80199f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8019a2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8019a5:	89 ec                	mov    %ebp,%esp
  8019a7:	5d                   	pop    %ebp
  8019a8:	c3                   	ret    

008019a9 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8019a9:	55                   	push   %ebp
  8019aa:	89 e5                	mov    %esp,%ebp
  8019ac:	53                   	push   %ebx
  8019ad:	83 ec 14             	sub    $0x14,%esp
  8019b0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8019b5:	89 1c 24             	mov    %ebx,(%esp)
  8019b8:	e8 6f ff ff ff       	call   80192c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8019bd:	83 c3 01             	add    $0x1,%ebx
  8019c0:	83 fb 20             	cmp    $0x20,%ebx
  8019c3:	75 f0                	jne    8019b5 <close_all+0xc>
		close(i);
}
  8019c5:	83 c4 14             	add    $0x14,%esp
  8019c8:	5b                   	pop    %ebx
  8019c9:	5d                   	pop    %ebp
  8019ca:	c3                   	ret    

008019cb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8019cb:	55                   	push   %ebp
  8019cc:	89 e5                	mov    %esp,%ebp
  8019ce:	83 ec 58             	sub    $0x58,%esp
  8019d1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8019d4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8019d7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8019da:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8019dd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8019e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e7:	89 04 24             	mov    %eax,(%esp)
  8019ea:	e8 6e fb ff ff       	call   80155d <fd_lookup>
  8019ef:	89 c3                	mov    %eax,%ebx
  8019f1:	85 c0                	test   %eax,%eax
  8019f3:	0f 88 e0 00 00 00    	js     801ad9 <dup+0x10e>
		return r;
	close(newfdnum);
  8019f9:	89 3c 24             	mov    %edi,(%esp)
  8019fc:	e8 2b ff ff ff       	call   80192c <close>

	newfd = INDEX2FD(newfdnum);
  801a01:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801a07:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801a0a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a0d:	89 04 24             	mov    %eax,(%esp)
  801a10:	e8 bb fa ff ff       	call   8014d0 <fd2data>
  801a15:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801a17:	89 34 24             	mov    %esi,(%esp)
  801a1a:	e8 b1 fa ff ff       	call   8014d0 <fd2data>
  801a1f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801a22:	89 da                	mov    %ebx,%edx
  801a24:	89 d8                	mov    %ebx,%eax
  801a26:	c1 e8 16             	shr    $0x16,%eax
  801a29:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a30:	a8 01                	test   $0x1,%al
  801a32:	74 43                	je     801a77 <dup+0xac>
  801a34:	c1 ea 0c             	shr    $0xc,%edx
  801a37:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801a3e:	a8 01                	test   $0x1,%al
  801a40:	74 35                	je     801a77 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801a42:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801a49:	25 07 0e 00 00       	and    $0xe07,%eax
  801a4e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801a52:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801a55:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a59:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a60:	00 
  801a61:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801a6c:	e8 10 f4 ff ff       	call   800e81 <sys_page_map>
  801a71:	89 c3                	mov    %eax,%ebx
  801a73:	85 c0                	test   %eax,%eax
  801a75:	78 3f                	js     801ab6 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801a77:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801a7a:	89 c2                	mov    %eax,%edx
  801a7c:	c1 ea 0c             	shr    $0xc,%edx
  801a7f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801a86:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801a8c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801a90:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801a94:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801a9b:	00 
  801a9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801aa0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801aa7:	e8 d5 f3 ff ff       	call   800e81 <sys_page_map>
  801aac:	89 c3                	mov    %eax,%ebx
  801aae:	85 c0                	test   %eax,%eax
  801ab0:	78 04                	js     801ab6 <dup+0xeb>
  801ab2:	89 fb                	mov    %edi,%ebx
  801ab4:	eb 23                	jmp    801ad9 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801ab6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801aba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ac1:	e8 83 f3 ff ff       	call   800e49 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801ac6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801ac9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801acd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ad4:	e8 70 f3 ff ff       	call   800e49 <sys_page_unmap>
	return r;
}
  801ad9:	89 d8                	mov    %ebx,%eax
  801adb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801ade:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801ae1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801ae4:	89 ec                	mov    %ebp,%esp
  801ae6:	5d                   	pop    %ebp
  801ae7:	c3                   	ret    

00801ae8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801ae8:	55                   	push   %ebp
  801ae9:	89 e5                	mov    %esp,%ebp
  801aeb:	83 ec 18             	sub    $0x18,%esp
  801aee:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801af1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801af4:	89 c3                	mov    %eax,%ebx
  801af6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801af8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801aff:	75 11                	jne    801b12 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801b01:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801b08:	e8 93 03 00 00       	call   801ea0 <ipc_find_env>
  801b0d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801b12:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801b19:	00 
  801b1a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801b21:	00 
  801b22:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801b26:	a1 00 40 80 00       	mov    0x804000,%eax
  801b2b:	89 04 24             	mov    %eax,(%esp)
  801b2e:	e8 b1 03 00 00       	call   801ee4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801b33:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801b3a:	00 
  801b3b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b3f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b46:	e8 08 04 00 00       	call   801f53 <ipc_recv>
}
  801b4b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b4e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b51:	89 ec                	mov    %ebp,%esp
  801b53:	5d                   	pop    %ebp
  801b54:	c3                   	ret    

00801b55 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5e:	8b 40 0c             	mov    0xc(%eax),%eax
  801b61:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801b66:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b69:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801b6e:	ba 00 00 00 00       	mov    $0x0,%edx
  801b73:	b8 02 00 00 00       	mov    $0x2,%eax
  801b78:	e8 6b ff ff ff       	call   801ae8 <fsipc>
}
  801b7d:	c9                   	leave  
  801b7e:	c3                   	ret    

00801b7f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801b7f:	55                   	push   %ebp
  801b80:	89 e5                	mov    %esp,%ebp
  801b82:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801b85:	8b 45 08             	mov    0x8(%ebp),%eax
  801b88:	8b 40 0c             	mov    0xc(%eax),%eax
  801b8b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801b90:	ba 00 00 00 00       	mov    $0x0,%edx
  801b95:	b8 06 00 00 00       	mov    $0x6,%eax
  801b9a:	e8 49 ff ff ff       	call   801ae8 <fsipc>
}
  801b9f:	c9                   	leave  
  801ba0:	c3                   	ret    

00801ba1 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801ba1:	55                   	push   %ebp
  801ba2:	89 e5                	mov    %esp,%ebp
  801ba4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ba7:	ba 00 00 00 00       	mov    $0x0,%edx
  801bac:	b8 08 00 00 00       	mov    $0x8,%eax
  801bb1:	e8 32 ff ff ff       	call   801ae8 <fsipc>
}
  801bb6:	c9                   	leave  
  801bb7:	c3                   	ret    

00801bb8 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801bb8:	55                   	push   %ebp
  801bb9:	89 e5                	mov    %esp,%ebp
  801bbb:	53                   	push   %ebx
  801bbc:	83 ec 14             	sub    $0x14,%esp
  801bbf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801bc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc5:	8b 40 0c             	mov    0xc(%eax),%eax
  801bc8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801bcd:	ba 00 00 00 00       	mov    $0x0,%edx
  801bd2:	b8 05 00 00 00       	mov    $0x5,%eax
  801bd7:	e8 0c ff ff ff       	call   801ae8 <fsipc>
  801bdc:	85 c0                	test   %eax,%eax
  801bde:	78 2b                	js     801c0b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801be0:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801be7:	00 
  801be8:	89 1c 24             	mov    %ebx,(%esp)
  801beb:	e8 da ec ff ff       	call   8008ca <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801bf0:	a1 80 50 80 00       	mov    0x805080,%eax
  801bf5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801bfb:	a1 84 50 80 00       	mov    0x805084,%eax
  801c00:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801c06:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801c0b:	83 c4 14             	add    $0x14,%esp
  801c0e:	5b                   	pop    %ebx
  801c0f:	5d                   	pop    %ebp
  801c10:	c3                   	ret    

00801c11 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801c11:	55                   	push   %ebp
  801c12:	89 e5                	mov    %esp,%ebp
  801c14:	83 ec 18             	sub    $0x18,%esp
  801c17:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  801c1a:	8b 55 08             	mov    0x8(%ebp),%edx
  801c1d:	8b 52 0c             	mov    0xc(%edx),%edx
  801c20:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  801c26:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  801c2b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801c30:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801c35:	0f 47 c2             	cmova  %edx,%eax
  801c38:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c43:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  801c4a:	e8 66 ee ff ff       	call   800ab5 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  801c4f:	ba 00 00 00 00       	mov    $0x0,%edx
  801c54:	b8 04 00 00 00       	mov    $0x4,%eax
  801c59:	e8 8a fe ff ff       	call   801ae8 <fsipc>
}
  801c5e:	c9                   	leave  
  801c5f:	c3                   	ret    

00801c60 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801c60:	55                   	push   %ebp
  801c61:	89 e5                	mov    %esp,%ebp
  801c63:	53                   	push   %ebx
  801c64:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801c67:	8b 45 08             	mov    0x8(%ebp),%eax
  801c6a:	8b 40 0c             	mov    0xc(%eax),%eax
  801c6d:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  801c72:	8b 45 10             	mov    0x10(%ebp),%eax
  801c75:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  801c7a:	ba 00 00 00 00       	mov    $0x0,%edx
  801c7f:	b8 03 00 00 00       	mov    $0x3,%eax
  801c84:	e8 5f fe ff ff       	call   801ae8 <fsipc>
  801c89:	89 c3                	mov    %eax,%ebx
  801c8b:	85 c0                	test   %eax,%eax
  801c8d:	78 17                	js     801ca6 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801c8f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c93:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801c9a:	00 
  801c9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c9e:	89 04 24             	mov    %eax,(%esp)
  801ca1:	e8 0f ee ff ff       	call   800ab5 <memmove>
  return r;	
}
  801ca6:	89 d8                	mov    %ebx,%eax
  801ca8:	83 c4 14             	add    $0x14,%esp
  801cab:	5b                   	pop    %ebx
  801cac:	5d                   	pop    %ebp
  801cad:	c3                   	ret    

00801cae <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801cae:	55                   	push   %ebp
  801caf:	89 e5                	mov    %esp,%ebp
  801cb1:	53                   	push   %ebx
  801cb2:	83 ec 14             	sub    $0x14,%esp
  801cb5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801cb8:	89 1c 24             	mov    %ebx,(%esp)
  801cbb:	e8 c0 eb ff ff       	call   800880 <strlen>
  801cc0:	89 c2                	mov    %eax,%edx
  801cc2:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801cc7:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801ccd:	7f 1f                	jg     801cee <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801ccf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801cd3:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801cda:	e8 eb eb ff ff       	call   8008ca <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801cdf:	ba 00 00 00 00       	mov    $0x0,%edx
  801ce4:	b8 07 00 00 00       	mov    $0x7,%eax
  801ce9:	e8 fa fd ff ff       	call   801ae8 <fsipc>
}
  801cee:	83 c4 14             	add    $0x14,%esp
  801cf1:	5b                   	pop    %ebx
  801cf2:	5d                   	pop    %ebp
  801cf3:	c3                   	ret    

00801cf4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801cf4:	55                   	push   %ebp
  801cf5:	89 e5                	mov    %esp,%ebp
  801cf7:	83 ec 28             	sub    $0x28,%esp
  801cfa:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801cfd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801d00:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801d03:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d06:	89 04 24             	mov    %eax,(%esp)
  801d09:	e8 dd f7 ff ff       	call   8014eb <fd_alloc>
  801d0e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801d10:	85 c0                	test   %eax,%eax
  801d12:	0f 88 89 00 00 00    	js     801da1 <open+0xad>

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801d18:	89 34 24             	mov    %esi,(%esp)
  801d1b:	e8 60 eb ff ff       	call   800880 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801d20:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801d25:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801d2a:	7f 75                	jg     801da1 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  801d2c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d30:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801d37:	e8 8e eb ff ff       	call   8008ca <strcpy>
  fsipcbuf.open.req_omode = mode;
  801d3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d3f:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  801d44:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801d47:	b8 01 00 00 00       	mov    $0x1,%eax
  801d4c:	e8 97 fd ff ff       	call   801ae8 <fsipc>
  801d51:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801d53:	85 c0                	test   %eax,%eax
  801d55:	78 0f                	js     801d66 <open+0x72>
  return fd2num(fd);
  801d57:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d5a:	89 04 24             	mov    %eax,(%esp)
  801d5d:	e8 5e f7 ff ff       	call   8014c0 <fd2num>
  801d62:	89 c3                	mov    %eax,%ebx
  801d64:	eb 3b                	jmp    801da1 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801d66:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801d6d:	00 
  801d6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d71:	89 04 24             	mov    %eax,(%esp)
  801d74:	e8 2b fb ff ff       	call   8018a4 <fd_close>
  801d79:	85 c0                	test   %eax,%eax
  801d7b:	74 24                	je     801da1 <open+0xad>
  801d7d:	c7 44 24 0c a0 29 80 	movl   $0x8029a0,0xc(%esp)
  801d84:	00 
  801d85:	c7 44 24 08 b5 29 80 	movl   $0x8029b5,0x8(%esp)
  801d8c:	00 
  801d8d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801d94:	00 
  801d95:	c7 04 24 ca 29 80 00 	movl   $0x8029ca,(%esp)
  801d9c:	e8 0f 00 00 00       	call   801db0 <_panic>
  return r;
}
  801da1:	89 d8                	mov    %ebx,%eax
  801da3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801da6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801da9:	89 ec                	mov    %ebp,%esp
  801dab:	5d                   	pop    %ebp
  801dac:	c3                   	ret    
  801dad:	00 00                	add    %al,(%eax)
	...

00801db0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801db0:	55                   	push   %ebp
  801db1:	89 e5                	mov    %esp,%ebp
  801db3:	56                   	push   %esi
  801db4:	53                   	push   %ebx
  801db5:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801db8:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801dbb:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801dc1:	e8 9e f1 ff ff       	call   800f64 <sys_getenvid>
  801dc6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dc9:	89 54 24 10          	mov    %edx,0x10(%esp)
  801dcd:	8b 55 08             	mov    0x8(%ebp),%edx
  801dd0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801dd4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801dd8:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ddc:	c7 04 24 d8 29 80 00 	movl   $0x8029d8,(%esp)
  801de3:	e8 a5 e3 ff ff       	call   80018d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801de8:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dec:	8b 45 10             	mov    0x10(%ebp),%eax
  801def:	89 04 24             	mov    %eax,(%esp)
  801df2:	e8 35 e3 ff ff       	call   80012c <vcprintf>
	cprintf("\n");
  801df7:	c7 04 24 f4 22 80 00 	movl   $0x8022f4,(%esp)
  801dfe:	e8 8a e3 ff ff       	call   80018d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801e03:	cc                   	int3   
  801e04:	eb fd                	jmp    801e03 <_panic+0x53>
	...

00801e08 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801e08:	55                   	push   %ebp
  801e09:	89 e5                	mov    %esp,%ebp
  801e0b:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801e0e:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801e15:	75 54                	jne    801e6b <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  801e17:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801e1e:	00 
  801e1f:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801e26:	ee 
  801e27:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e2e:	e8 87 f0 ff ff       	call   800eba <sys_page_alloc>
  801e33:	85 c0                	test   %eax,%eax
  801e35:	79 20                	jns    801e57 <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  801e37:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801e3b:	c7 44 24 08 fc 29 80 	movl   $0x8029fc,0x8(%esp)
  801e42:	00 
  801e43:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  801e4a:	00 
  801e4b:	c7 04 24 14 2a 80 00 	movl   $0x802a14,(%esp)
  801e52:	e8 59 ff ff ff       	call   801db0 <_panic>
		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  801e57:	c7 44 24 04 78 1e 80 	movl   $0x801e78,0x4(%esp)
  801e5e:	00 
  801e5f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801e66:	e8 36 ef ff ff       	call   800da1 <sys_env_set_pgfault_upcall>

			//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6e:	a3 00 60 80 00       	mov    %eax,0x806000
}
  801e73:	c9                   	leave  
  801e74:	c3                   	ret    
  801e75:	00 00                	add    %al,(%eax)
	...

00801e78 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801e78:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801e79:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801e7e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801e80:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 0x30(%esp), %eax
  801e83:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  801e87:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801e8a:	89 44 24 30          	mov    %eax,0x30(%esp)
	# put old eip in the pre-reserved 4 bytes space
	movl 0x28(%esp), %ebx
  801e8e:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  801e92:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	addl $0x8, %esp
  801e94:	83 c4 08             	add    $0x8,%esp
	popal
  801e97:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $0x4, %esp
  801e98:	83 c4 04             	add    $0x4,%esp
	popfl
  801e9b:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  801e9c:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801e9d:	c3                   	ret    
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
  801f00:	eb 29                	jmp    801f2b <ipc_send+0x47>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
  801f02:	85 c0                	test   %eax,%eax
  801f04:	79 25                	jns    801f2b <ipc_send+0x47>
  801f06:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f09:	74 20                	je     801f2b <ipc_send+0x47>
			panic ("ipc: sys try send failed : %e", r);
  801f0b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f0f:	c7 44 24 08 22 2a 80 	movl   $0x802a22,0x8(%esp)
  801f16:	00 
  801f17:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801f1e:	00 
  801f1f:	c7 04 24 40 2a 80 00 	movl   $0x802a40,(%esp)
  801f26:	e8 85 fe ff ff       	call   801db0 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  801f2b:	8b 45 14             	mov    0x14(%ebp),%eax
  801f2e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801f32:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f36:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801f3a:	89 34 24             	mov    %esi,(%esp)
  801f3d:	e8 29 ee ff ff       	call   800d6b <sys_ipc_try_send>
  801f42:	85 c0                	test   %eax,%eax
  801f44:	75 bc                	jne    801f02 <ipc_send+0x1e>
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  801f46:	e8 a6 ef ff ff       	call   800ef1 <sys_yield>
}
  801f4b:	83 c4 1c             	add    $0x1c,%esp
  801f4e:	5b                   	pop    %ebx
  801f4f:	5e                   	pop    %esi
  801f50:	5f                   	pop    %edi
  801f51:	5d                   	pop    %ebp
  801f52:	c3                   	ret    

00801f53 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f53:	55                   	push   %ebp
  801f54:	89 e5                	mov    %esp,%ebp
  801f56:	83 ec 28             	sub    $0x28,%esp
  801f59:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801f5c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801f5f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801f62:	8b 75 08             	mov    0x8(%ebp),%esi
  801f65:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f68:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801f6b:	85 c0                	test   %eax,%eax
  801f6d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f72:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801f75:	89 04 24             	mov    %eax,(%esp)
  801f78:	e8 b5 ed ff ff       	call   800d32 <sys_ipc_recv>
  801f7d:	89 c3                	mov    %eax,%ebx
  801f7f:	85 c0                	test   %eax,%eax
  801f81:	79 2a                	jns    801fad <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  801f83:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f87:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f8b:	c7 04 24 4a 2a 80 00 	movl   $0x802a4a,(%esp)
  801f92:	e8 f6 e1 ff ff       	call   80018d <cprintf>
		if(from_env_store != NULL)
  801f97:	85 f6                	test   %esi,%esi
  801f99:	74 06                	je     801fa1 <ipc_recv+0x4e>
			*from_env_store = 0;
  801f9b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801fa1:	85 ff                	test   %edi,%edi
  801fa3:	74 2d                	je     801fd2 <ipc_recv+0x7f>
			*perm_store = 0;
  801fa5:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801fab:	eb 25                	jmp    801fd2 <ipc_recv+0x7f>
		return r;
	}
	if(from_env_store != NULL)
  801fad:	85 f6                	test   %esi,%esi
  801faf:	90                   	nop
  801fb0:	74 0a                	je     801fbc <ipc_recv+0x69>
		*from_env_store = thisenv->env_ipc_from;
  801fb2:	a1 04 40 80 00       	mov    0x804004,%eax
  801fb7:	8b 40 74             	mov    0x74(%eax),%eax
  801fba:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801fbc:	85 ff                	test   %edi,%edi
  801fbe:	74 0a                	je     801fca <ipc_recv+0x77>
		*perm_store = thisenv->env_ipc_perm;
  801fc0:	a1 04 40 80 00       	mov    0x804004,%eax
  801fc5:	8b 40 78             	mov    0x78(%eax),%eax
  801fc8:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801fca:	a1 04 40 80 00       	mov    0x804004,%eax
  801fcf:	8b 58 70             	mov    0x70(%eax),%ebx
}
  801fd2:	89 d8                	mov    %ebx,%eax
  801fd4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801fd7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801fda:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801fdd:	89 ec                	mov    %ebp,%esp
  801fdf:	5d                   	pop    %ebp
  801fe0:	c3                   	ret    
	...

00801ff0 <__udivdi3>:
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	57                   	push   %edi
  801ff4:	56                   	push   %esi
  801ff5:	83 ec 10             	sub    $0x10,%esp
  801ff8:	8b 45 14             	mov    0x14(%ebp),%eax
  801ffb:	8b 55 08             	mov    0x8(%ebp),%edx
  801ffe:	8b 75 10             	mov    0x10(%ebp),%esi
  802001:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802004:	85 c0                	test   %eax,%eax
  802006:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802009:	75 35                	jne    802040 <__udivdi3+0x50>
  80200b:	39 fe                	cmp    %edi,%esi
  80200d:	77 61                	ja     802070 <__udivdi3+0x80>
  80200f:	85 f6                	test   %esi,%esi
  802011:	75 0b                	jne    80201e <__udivdi3+0x2e>
  802013:	b8 01 00 00 00       	mov    $0x1,%eax
  802018:	31 d2                	xor    %edx,%edx
  80201a:	f7 f6                	div    %esi
  80201c:	89 c6                	mov    %eax,%esi
  80201e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802021:	31 d2                	xor    %edx,%edx
  802023:	89 f8                	mov    %edi,%eax
  802025:	f7 f6                	div    %esi
  802027:	89 c7                	mov    %eax,%edi
  802029:	89 c8                	mov    %ecx,%eax
  80202b:	f7 f6                	div    %esi
  80202d:	89 c1                	mov    %eax,%ecx
  80202f:	89 fa                	mov    %edi,%edx
  802031:	89 c8                	mov    %ecx,%eax
  802033:	83 c4 10             	add    $0x10,%esp
  802036:	5e                   	pop    %esi
  802037:	5f                   	pop    %edi
  802038:	5d                   	pop    %ebp
  802039:	c3                   	ret    
  80203a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802040:	39 f8                	cmp    %edi,%eax
  802042:	77 1c                	ja     802060 <__udivdi3+0x70>
  802044:	0f bd d0             	bsr    %eax,%edx
  802047:	83 f2 1f             	xor    $0x1f,%edx
  80204a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80204d:	75 39                	jne    802088 <__udivdi3+0x98>
  80204f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802052:	0f 86 a0 00 00 00    	jbe    8020f8 <__udivdi3+0x108>
  802058:	39 f8                	cmp    %edi,%eax
  80205a:	0f 82 98 00 00 00    	jb     8020f8 <__udivdi3+0x108>
  802060:	31 ff                	xor    %edi,%edi
  802062:	31 c9                	xor    %ecx,%ecx
  802064:	89 c8                	mov    %ecx,%eax
  802066:	89 fa                	mov    %edi,%edx
  802068:	83 c4 10             	add    $0x10,%esp
  80206b:	5e                   	pop    %esi
  80206c:	5f                   	pop    %edi
  80206d:	5d                   	pop    %ebp
  80206e:	c3                   	ret    
  80206f:	90                   	nop
  802070:	89 d1                	mov    %edx,%ecx
  802072:	89 fa                	mov    %edi,%edx
  802074:	89 c8                	mov    %ecx,%eax
  802076:	31 ff                	xor    %edi,%edi
  802078:	f7 f6                	div    %esi
  80207a:	89 c1                	mov    %eax,%ecx
  80207c:	89 fa                	mov    %edi,%edx
  80207e:	89 c8                	mov    %ecx,%eax
  802080:	83 c4 10             	add    $0x10,%esp
  802083:	5e                   	pop    %esi
  802084:	5f                   	pop    %edi
  802085:	5d                   	pop    %ebp
  802086:	c3                   	ret    
  802087:	90                   	nop
  802088:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80208c:	89 f2                	mov    %esi,%edx
  80208e:	d3 e0                	shl    %cl,%eax
  802090:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802093:	b8 20 00 00 00       	mov    $0x20,%eax
  802098:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80209b:	89 c1                	mov    %eax,%ecx
  80209d:	d3 ea                	shr    %cl,%edx
  80209f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8020a3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8020a6:	d3 e6                	shl    %cl,%esi
  8020a8:	89 c1                	mov    %eax,%ecx
  8020aa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8020ad:	89 fe                	mov    %edi,%esi
  8020af:	d3 ee                	shr    %cl,%esi
  8020b1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8020b5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8020b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020bb:	d3 e7                	shl    %cl,%edi
  8020bd:	89 c1                	mov    %eax,%ecx
  8020bf:	d3 ea                	shr    %cl,%edx
  8020c1:	09 d7                	or     %edx,%edi
  8020c3:	89 f2                	mov    %esi,%edx
  8020c5:	89 f8                	mov    %edi,%eax
  8020c7:	f7 75 ec             	divl   -0x14(%ebp)
  8020ca:	89 d6                	mov    %edx,%esi
  8020cc:	89 c7                	mov    %eax,%edi
  8020ce:	f7 65 e8             	mull   -0x18(%ebp)
  8020d1:	39 d6                	cmp    %edx,%esi
  8020d3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8020d6:	72 30                	jb     802108 <__udivdi3+0x118>
  8020d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8020db:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8020df:	d3 e2                	shl    %cl,%edx
  8020e1:	39 c2                	cmp    %eax,%edx
  8020e3:	73 05                	jae    8020ea <__udivdi3+0xfa>
  8020e5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8020e8:	74 1e                	je     802108 <__udivdi3+0x118>
  8020ea:	89 f9                	mov    %edi,%ecx
  8020ec:	31 ff                	xor    %edi,%edi
  8020ee:	e9 71 ff ff ff       	jmp    802064 <__udivdi3+0x74>
  8020f3:	90                   	nop
  8020f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8020f8:	31 ff                	xor    %edi,%edi
  8020fa:	b9 01 00 00 00       	mov    $0x1,%ecx
  8020ff:	e9 60 ff ff ff       	jmp    802064 <__udivdi3+0x74>
  802104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802108:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80210b:	31 ff                	xor    %edi,%edi
  80210d:	89 c8                	mov    %ecx,%eax
  80210f:	89 fa                	mov    %edi,%edx
  802111:	83 c4 10             	add    $0x10,%esp
  802114:	5e                   	pop    %esi
  802115:	5f                   	pop    %edi
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    
	...

00802120 <__umoddi3>:
  802120:	55                   	push   %ebp
  802121:	89 e5                	mov    %esp,%ebp
  802123:	57                   	push   %edi
  802124:	56                   	push   %esi
  802125:	83 ec 20             	sub    $0x20,%esp
  802128:	8b 55 14             	mov    0x14(%ebp),%edx
  80212b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80212e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802131:	8b 75 0c             	mov    0xc(%ebp),%esi
  802134:	85 d2                	test   %edx,%edx
  802136:	89 c8                	mov    %ecx,%eax
  802138:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80213b:	75 13                	jne    802150 <__umoddi3+0x30>
  80213d:	39 f7                	cmp    %esi,%edi
  80213f:	76 3f                	jbe    802180 <__umoddi3+0x60>
  802141:	89 f2                	mov    %esi,%edx
  802143:	f7 f7                	div    %edi
  802145:	89 d0                	mov    %edx,%eax
  802147:	31 d2                	xor    %edx,%edx
  802149:	83 c4 20             	add    $0x20,%esp
  80214c:	5e                   	pop    %esi
  80214d:	5f                   	pop    %edi
  80214e:	5d                   	pop    %ebp
  80214f:	c3                   	ret    
  802150:	39 f2                	cmp    %esi,%edx
  802152:	77 4c                	ja     8021a0 <__umoddi3+0x80>
  802154:	0f bd ca             	bsr    %edx,%ecx
  802157:	83 f1 1f             	xor    $0x1f,%ecx
  80215a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80215d:	75 51                	jne    8021b0 <__umoddi3+0x90>
  80215f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802162:	0f 87 e0 00 00 00    	ja     802248 <__umoddi3+0x128>
  802168:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80216b:	29 f8                	sub    %edi,%eax
  80216d:	19 d6                	sbb    %edx,%esi
  80216f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802172:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802175:	89 f2                	mov    %esi,%edx
  802177:	83 c4 20             	add    $0x20,%esp
  80217a:	5e                   	pop    %esi
  80217b:	5f                   	pop    %edi
  80217c:	5d                   	pop    %ebp
  80217d:	c3                   	ret    
  80217e:	66 90                	xchg   %ax,%ax
  802180:	85 ff                	test   %edi,%edi
  802182:	75 0b                	jne    80218f <__umoddi3+0x6f>
  802184:	b8 01 00 00 00       	mov    $0x1,%eax
  802189:	31 d2                	xor    %edx,%edx
  80218b:	f7 f7                	div    %edi
  80218d:	89 c7                	mov    %eax,%edi
  80218f:	89 f0                	mov    %esi,%eax
  802191:	31 d2                	xor    %edx,%edx
  802193:	f7 f7                	div    %edi
  802195:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802198:	f7 f7                	div    %edi
  80219a:	eb a9                	jmp    802145 <__umoddi3+0x25>
  80219c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a0:	89 c8                	mov    %ecx,%eax
  8021a2:	89 f2                	mov    %esi,%edx
  8021a4:	83 c4 20             	add    $0x20,%esp
  8021a7:	5e                   	pop    %esi
  8021a8:	5f                   	pop    %edi
  8021a9:	5d                   	pop    %ebp
  8021aa:	c3                   	ret    
  8021ab:	90                   	nop
  8021ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8021b4:	d3 e2                	shl    %cl,%edx
  8021b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8021b9:	ba 20 00 00 00       	mov    $0x20,%edx
  8021be:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8021c1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8021c4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8021c8:	89 fa                	mov    %edi,%edx
  8021ca:	d3 ea                	shr    %cl,%edx
  8021cc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8021d0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8021d3:	d3 e7                	shl    %cl,%edi
  8021d5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8021d9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8021dc:	89 f2                	mov    %esi,%edx
  8021de:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8021e1:	89 c7                	mov    %eax,%edi
  8021e3:	d3 ea                	shr    %cl,%edx
  8021e5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8021e9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8021ec:	89 c2                	mov    %eax,%edx
  8021ee:	d3 e6                	shl    %cl,%esi
  8021f0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8021f4:	d3 ea                	shr    %cl,%edx
  8021f6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8021fa:	09 d6                	or     %edx,%esi
  8021fc:	89 f0                	mov    %esi,%eax
  8021fe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802201:	d3 e7                	shl    %cl,%edi
  802203:	89 f2                	mov    %esi,%edx
  802205:	f7 75 f4             	divl   -0xc(%ebp)
  802208:	89 d6                	mov    %edx,%esi
  80220a:	f7 65 e8             	mull   -0x18(%ebp)
  80220d:	39 d6                	cmp    %edx,%esi
  80220f:	72 2b                	jb     80223c <__umoddi3+0x11c>
  802211:	39 c7                	cmp    %eax,%edi
  802213:	72 23                	jb     802238 <__umoddi3+0x118>
  802215:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802219:	29 c7                	sub    %eax,%edi
  80221b:	19 d6                	sbb    %edx,%esi
  80221d:	89 f0                	mov    %esi,%eax
  80221f:	89 f2                	mov    %esi,%edx
  802221:	d3 ef                	shr    %cl,%edi
  802223:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802227:	d3 e0                	shl    %cl,%eax
  802229:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80222d:	09 f8                	or     %edi,%eax
  80222f:	d3 ea                	shr    %cl,%edx
  802231:	83 c4 20             	add    $0x20,%esp
  802234:	5e                   	pop    %esi
  802235:	5f                   	pop    %edi
  802236:	5d                   	pop    %ebp
  802237:	c3                   	ret    
  802238:	39 d6                	cmp    %edx,%esi
  80223a:	75 d9                	jne    802215 <__umoddi3+0xf5>
  80223c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80223f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802242:	eb d1                	jmp    802215 <__umoddi3+0xf5>
  802244:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802248:	39 f2                	cmp    %esi,%edx
  80224a:	0f 82 18 ff ff ff    	jb     802168 <__umoddi3+0x48>
  802250:	e9 1d ff ff ff       	jmp    802172 <__umoddi3+0x52>
