
obj/user/fairness.debug:     file format elf32-i386


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
  80002c:	e8 97 00 00 00       	call   8000c8 <libmain>
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
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 20             	sub    $0x20,%esp
	envid_t who, id;

	id = sys_getenvid();
  80003c:	e8 a6 0f 00 00       	call   800fe7 <sys_getenvid>
  800041:	89 c3                	mov    %eax,%ebx

	if (thisenv == &envs[1]) {
  800043:	81 3d 08 40 80 00 80 	cmpl   $0xeec00080,0x804008
  80004a:	00 c0 ee 
  80004d:	75 34                	jne    800083 <umain+0x4f>
		while (1) {
			ipc_recv(&who, 0, 0);
  80004f:	8d 75 f4             	lea    -0xc(%ebp),%esi
  800052:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800059:	00 
  80005a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800061:	00 
  800062:	89 34 24             	mov    %esi,(%esp)
  800065:	e8 1a 11 00 00       	call   801184 <ipc_recv>
			cprintf("%x recv from %x\n", id, who);
  80006a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80006d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800071:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800075:	c7 04 24 20 23 80 00 	movl   $0x802320,(%esp)
  80007c:	e8 14 01 00 00       	call   800195 <cprintf>
  800081:	eb cf                	jmp    800052 <umain+0x1e>
		}
	} else {
		cprintf("%x loop sending to %x\n", id, envs[1].env_id);
  800083:	a1 c8 00 c0 ee       	mov    0xeec000c8,%eax
  800088:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800090:	c7 04 24 31 23 80 00 	movl   $0x802331,(%esp)
  800097:	e8 f9 00 00 00       	call   800195 <cprintf>
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80009c:	bb c8 00 c0 ee       	mov    $0xeec000c8,%ebx
  8000a1:	8b 03                	mov    (%ebx),%eax
  8000a3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000aa:	00 
  8000ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000b2:	00 
  8000b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000ba:	00 
  8000bb:	89 04 24             	mov    %eax,(%esp)
  8000be:	e8 56 10 00 00       	call   801119 <ipc_send>
  8000c3:	eb dc                	jmp    8000a1 <umain+0x6d>
  8000c5:	00 00                	add    %al,(%eax)
	...

008000c8 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	83 ec 18             	sub    $0x18,%esp
  8000ce:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000d1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8000d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  8000da:	e8 08 0f 00 00       	call   800fe7 <sys_getenvid>
  8000df:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e4:	c1 e0 07             	shl    $0x7,%eax
  8000e7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ec:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f1:	85 f6                	test   %esi,%esi
  8000f3:	7e 07                	jle    8000fc <libmain+0x34>
		binaryname = argv[0];
  8000f5:	8b 03                	mov    (%ebx),%eax
  8000f7:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000fc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800100:	89 34 24             	mov    %esi,(%esp)
  800103:	e8 2c ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  800108:	e8 0b 00 00 00       	call   800118 <exit>
}
  80010d:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800110:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800113:	89 ec                	mov    %ebp,%esp
  800115:	5d                   	pop    %ebp
  800116:	c3                   	ret    
	...

00800118 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	83 ec 18             	sub    $0x18,%esp
	close_all();
  80011e:	e8 e6 15 00 00       	call   801709 <close_all>
	sys_env_destroy(0);
  800123:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80012a:	e8 f3 0e 00 00       	call   801022 <sys_env_destroy>
}
  80012f:	c9                   	leave  
  800130:	c3                   	ret    
  800131:	00 00                	add    %al,(%eax)
	...

00800134 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80013d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800144:	00 00 00 
	b.cnt = 0;
  800147:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80014e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800151:	8b 45 0c             	mov    0xc(%ebp),%eax
  800154:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800158:	8b 45 08             	mov    0x8(%ebp),%eax
  80015b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80015f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800165:	89 44 24 04          	mov    %eax,0x4(%esp)
  800169:	c7 04 24 af 01 80 00 	movl   $0x8001af,(%esp)
  800170:	e8 d8 01 00 00       	call   80034d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800175:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80017b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800185:	89 04 24             	mov    %eax,(%esp)
  800188:	e8 09 0f 00 00       	call   801096 <sys_cputs>

	return b.cnt;
}
  80018d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800193:	c9                   	leave  
  800194:	c3                   	ret    

00800195 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80019b:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80019e:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a5:	89 04 24             	mov    %eax,(%esp)
  8001a8:	e8 87 ff ff ff       	call   800134 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ad:	c9                   	leave  
  8001ae:	c3                   	ret    

008001af <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	53                   	push   %ebx
  8001b3:	83 ec 14             	sub    $0x14,%esp
  8001b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b9:	8b 03                	mov    (%ebx),%eax
  8001bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001be:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001c2:	83 c0 01             	add    $0x1,%eax
  8001c5:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001c7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001cc:	75 19                	jne    8001e7 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001ce:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001d5:	00 
  8001d6:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d9:	89 04 24             	mov    %eax,(%esp)
  8001dc:	e8 b5 0e 00 00       	call   801096 <sys_cputs>
		b->idx = 0;
  8001e1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001e7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001eb:	83 c4 14             	add    $0x14,%esp
  8001ee:	5b                   	pop    %ebx
  8001ef:	5d                   	pop    %ebp
  8001f0:	c3                   	ret    
	...

00800200 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800200:	55                   	push   %ebp
  800201:	89 e5                	mov    %esp,%ebp
  800203:	57                   	push   %edi
  800204:	56                   	push   %esi
  800205:	53                   	push   %ebx
  800206:	83 ec 4c             	sub    $0x4c,%esp
  800209:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80020c:	89 d6                	mov    %edx,%esi
  80020e:	8b 45 08             	mov    0x8(%ebp),%eax
  800211:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800214:	8b 55 0c             	mov    0xc(%ebp),%edx
  800217:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80021a:	8b 45 10             	mov    0x10(%ebp),%eax
  80021d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800220:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800223:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800226:	b9 00 00 00 00       	mov    $0x0,%ecx
  80022b:	39 d1                	cmp    %edx,%ecx
  80022d:	72 15                	jb     800244 <printnum+0x44>
  80022f:	77 07                	ja     800238 <printnum+0x38>
  800231:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800234:	39 d0                	cmp    %edx,%eax
  800236:	76 0c                	jbe    800244 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800238:	83 eb 01             	sub    $0x1,%ebx
  80023b:	85 db                	test   %ebx,%ebx
  80023d:	8d 76 00             	lea    0x0(%esi),%esi
  800240:	7f 61                	jg     8002a3 <printnum+0xa3>
  800242:	eb 70                	jmp    8002b4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800244:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800248:	83 eb 01             	sub    $0x1,%ebx
  80024b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80024f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800253:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800257:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80025b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80025e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800261:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800264:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800268:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80026f:	00 
  800270:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800273:	89 04 24             	mov    %eax,(%esp)
  800276:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800279:	89 54 24 04          	mov    %edx,0x4(%esp)
  80027d:	e8 2e 1e 00 00       	call   8020b0 <__udivdi3>
  800282:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800285:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800288:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80028c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800290:	89 04 24             	mov    %eax,(%esp)
  800293:	89 54 24 04          	mov    %edx,0x4(%esp)
  800297:	89 f2                	mov    %esi,%edx
  800299:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80029c:	e8 5f ff ff ff       	call   800200 <printnum>
  8002a1:	eb 11                	jmp    8002b4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002a7:	89 3c 24             	mov    %edi,(%esp)
  8002aa:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002ad:	83 eb 01             	sub    $0x1,%ebx
  8002b0:	85 db                	test   %ebx,%ebx
  8002b2:	7f ef                	jg     8002a3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002b8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002bc:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ca:	00 
  8002cb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002ce:	89 14 24             	mov    %edx,(%esp)
  8002d1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002d4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8002d8:	e8 03 1f 00 00       	call   8021e0 <__umoddi3>
  8002dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002e1:	0f be 80 52 23 80 00 	movsbl 0x802352(%eax),%eax
  8002e8:	89 04 24             	mov    %eax,(%esp)
  8002eb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002ee:	83 c4 4c             	add    $0x4c,%esp
  8002f1:	5b                   	pop    %ebx
  8002f2:	5e                   	pop    %esi
  8002f3:	5f                   	pop    %edi
  8002f4:	5d                   	pop    %ebp
  8002f5:	c3                   	ret    

008002f6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002f6:	55                   	push   %ebp
  8002f7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002f9:	83 fa 01             	cmp    $0x1,%edx
  8002fc:	7e 0e                	jle    80030c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002fe:	8b 10                	mov    (%eax),%edx
  800300:	8d 4a 08             	lea    0x8(%edx),%ecx
  800303:	89 08                	mov    %ecx,(%eax)
  800305:	8b 02                	mov    (%edx),%eax
  800307:	8b 52 04             	mov    0x4(%edx),%edx
  80030a:	eb 22                	jmp    80032e <getuint+0x38>
	else if (lflag)
  80030c:	85 d2                	test   %edx,%edx
  80030e:	74 10                	je     800320 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800310:	8b 10                	mov    (%eax),%edx
  800312:	8d 4a 04             	lea    0x4(%edx),%ecx
  800315:	89 08                	mov    %ecx,(%eax)
  800317:	8b 02                	mov    (%edx),%eax
  800319:	ba 00 00 00 00       	mov    $0x0,%edx
  80031e:	eb 0e                	jmp    80032e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800320:	8b 10                	mov    (%eax),%edx
  800322:	8d 4a 04             	lea    0x4(%edx),%ecx
  800325:	89 08                	mov    %ecx,(%eax)
  800327:	8b 02                	mov    (%edx),%eax
  800329:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032e:	5d                   	pop    %ebp
  80032f:	c3                   	ret    

00800330 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800336:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80033a:	8b 10                	mov    (%eax),%edx
  80033c:	3b 50 04             	cmp    0x4(%eax),%edx
  80033f:	73 0a                	jae    80034b <sprintputch+0x1b>
		*b->buf++ = ch;
  800341:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800344:	88 0a                	mov    %cl,(%edx)
  800346:	83 c2 01             	add    $0x1,%edx
  800349:	89 10                	mov    %edx,(%eax)
}
  80034b:	5d                   	pop    %ebp
  80034c:	c3                   	ret    

0080034d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80034d:	55                   	push   %ebp
  80034e:	89 e5                	mov    %esp,%ebp
  800350:	57                   	push   %edi
  800351:	56                   	push   %esi
  800352:	53                   	push   %ebx
  800353:	83 ec 5c             	sub    $0x5c,%esp
  800356:	8b 7d 08             	mov    0x8(%ebp),%edi
  800359:	8b 75 0c             	mov    0xc(%ebp),%esi
  80035c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80035f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800366:	eb 11                	jmp    800379 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800368:	85 c0                	test   %eax,%eax
  80036a:	0f 84 68 04 00 00    	je     8007d8 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  800370:	89 74 24 04          	mov    %esi,0x4(%esp)
  800374:	89 04 24             	mov    %eax,(%esp)
  800377:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800379:	0f b6 03             	movzbl (%ebx),%eax
  80037c:	83 c3 01             	add    $0x1,%ebx
  80037f:	83 f8 25             	cmp    $0x25,%eax
  800382:	75 e4                	jne    800368 <vprintfmt+0x1b>
  800384:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80038b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800392:	b9 00 00 00 00       	mov    $0x0,%ecx
  800397:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  80039b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8003a2:	eb 06                	jmp    8003aa <vprintfmt+0x5d>
  8003a4:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  8003a8:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003aa:	0f b6 13             	movzbl (%ebx),%edx
  8003ad:	0f b6 c2             	movzbl %dl,%eax
  8003b0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003b3:	8d 43 01             	lea    0x1(%ebx),%eax
  8003b6:	83 ea 23             	sub    $0x23,%edx
  8003b9:	80 fa 55             	cmp    $0x55,%dl
  8003bc:	0f 87 f9 03 00 00    	ja     8007bb <vprintfmt+0x46e>
  8003c2:	0f b6 d2             	movzbl %dl,%edx
  8003c5:	ff 24 95 40 25 80 00 	jmp    *0x802540(,%edx,4)
  8003cc:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  8003d0:	eb d6                	jmp    8003a8 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003d2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003d5:	83 ea 30             	sub    $0x30,%edx
  8003d8:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  8003db:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003de:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003e1:	83 fb 09             	cmp    $0x9,%ebx
  8003e4:	77 54                	ja     80043a <vprintfmt+0xed>
  8003e6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8003e9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ec:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8003ef:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003f2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8003f6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003f9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003fc:	83 fb 09             	cmp    $0x9,%ebx
  8003ff:	76 eb                	jbe    8003ec <vprintfmt+0x9f>
  800401:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800404:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800407:	eb 31                	jmp    80043a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800409:	8b 55 14             	mov    0x14(%ebp),%edx
  80040c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80040f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800412:	8b 12                	mov    (%edx),%edx
  800414:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800417:	eb 21                	jmp    80043a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  800419:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80041d:	ba 00 00 00 00       	mov    $0x0,%edx
  800422:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  800426:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800429:	e9 7a ff ff ff       	jmp    8003a8 <vprintfmt+0x5b>
  80042e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800435:	e9 6e ff ff ff       	jmp    8003a8 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80043a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80043e:	0f 89 64 ff ff ff    	jns    8003a8 <vprintfmt+0x5b>
  800444:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800447:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80044a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80044d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800450:	e9 53 ff ff ff       	jmp    8003a8 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800455:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800458:	e9 4b ff ff ff       	jmp    8003a8 <vprintfmt+0x5b>
  80045d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800460:	8b 45 14             	mov    0x14(%ebp),%eax
  800463:	8d 50 04             	lea    0x4(%eax),%edx
  800466:	89 55 14             	mov    %edx,0x14(%ebp)
  800469:	89 74 24 04          	mov    %esi,0x4(%esp)
  80046d:	8b 00                	mov    (%eax),%eax
  80046f:	89 04 24             	mov    %eax,(%esp)
  800472:	ff d7                	call   *%edi
  800474:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800477:	e9 fd fe ff ff       	jmp    800379 <vprintfmt+0x2c>
  80047c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80047f:	8b 45 14             	mov    0x14(%ebp),%eax
  800482:	8d 50 04             	lea    0x4(%eax),%edx
  800485:	89 55 14             	mov    %edx,0x14(%ebp)
  800488:	8b 00                	mov    (%eax),%eax
  80048a:	89 c2                	mov    %eax,%edx
  80048c:	c1 fa 1f             	sar    $0x1f,%edx
  80048f:	31 d0                	xor    %edx,%eax
  800491:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800493:	83 f8 0f             	cmp    $0xf,%eax
  800496:	7f 0b                	jg     8004a3 <vprintfmt+0x156>
  800498:	8b 14 85 a0 26 80 00 	mov    0x8026a0(,%eax,4),%edx
  80049f:	85 d2                	test   %edx,%edx
  8004a1:	75 20                	jne    8004c3 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  8004a3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004a7:	c7 44 24 08 63 23 80 	movl   $0x802363,0x8(%esp)
  8004ae:	00 
  8004af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004b3:	89 3c 24             	mov    %edi,(%esp)
  8004b6:	e8 a5 03 00 00       	call   800860 <printfmt>
  8004bb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004be:	e9 b6 fe ff ff       	jmp    800379 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004c3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004c7:	c7 44 24 08 f7 27 80 	movl   $0x8027f7,0x8(%esp)
  8004ce:	00 
  8004cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004d3:	89 3c 24             	mov    %edi,(%esp)
  8004d6:	e8 85 03 00 00       	call   800860 <printfmt>
  8004db:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004de:	e9 96 fe ff ff       	jmp    800379 <vprintfmt+0x2c>
  8004e3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004e6:	89 c3                	mov    %eax,%ebx
  8004e8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004eb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004ee:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f4:	8d 50 04             	lea    0x4(%eax),%edx
  8004f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fa:	8b 00                	mov    (%eax),%eax
  8004fc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004ff:	85 c0                	test   %eax,%eax
  800501:	b8 6c 23 80 00       	mov    $0x80236c,%eax
  800506:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  80050a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80050d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800511:	7e 06                	jle    800519 <vprintfmt+0x1cc>
  800513:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800517:	75 13                	jne    80052c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800519:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80051c:	0f be 02             	movsbl (%edx),%eax
  80051f:	85 c0                	test   %eax,%eax
  800521:	0f 85 a2 00 00 00    	jne    8005c9 <vprintfmt+0x27c>
  800527:	e9 8f 00 00 00       	jmp    8005bb <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800530:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800533:	89 0c 24             	mov    %ecx,(%esp)
  800536:	e8 70 03 00 00       	call   8008ab <strnlen>
  80053b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80053e:	29 c2                	sub    %eax,%edx
  800540:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800543:	85 d2                	test   %edx,%edx
  800545:	7e d2                	jle    800519 <vprintfmt+0x1cc>
					putch(padc, putdat);
  800547:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80054b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80054e:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800551:	89 d3                	mov    %edx,%ebx
  800553:	89 74 24 04          	mov    %esi,0x4(%esp)
  800557:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80055a:	89 04 24             	mov    %eax,(%esp)
  80055d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80055f:	83 eb 01             	sub    $0x1,%ebx
  800562:	85 db                	test   %ebx,%ebx
  800564:	7f ed                	jg     800553 <vprintfmt+0x206>
  800566:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800569:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800570:	eb a7                	jmp    800519 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800572:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800576:	74 1b                	je     800593 <vprintfmt+0x246>
  800578:	8d 50 e0             	lea    -0x20(%eax),%edx
  80057b:	83 fa 5e             	cmp    $0x5e,%edx
  80057e:	76 13                	jbe    800593 <vprintfmt+0x246>
					putch('?', putdat);
  800580:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800583:	89 54 24 04          	mov    %edx,0x4(%esp)
  800587:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80058e:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800591:	eb 0d                	jmp    8005a0 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800593:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800596:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80059a:	89 04 24             	mov    %eax,(%esp)
  80059d:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005a0:	83 ef 01             	sub    $0x1,%edi
  8005a3:	0f be 03             	movsbl (%ebx),%eax
  8005a6:	85 c0                	test   %eax,%eax
  8005a8:	74 05                	je     8005af <vprintfmt+0x262>
  8005aa:	83 c3 01             	add    $0x1,%ebx
  8005ad:	eb 31                	jmp    8005e0 <vprintfmt+0x293>
  8005af:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b5:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005b8:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005bb:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005bf:	7f 36                	jg     8005f7 <vprintfmt+0x2aa>
  8005c1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005c4:	e9 b0 fd ff ff       	jmp    800379 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005cc:	83 c2 01             	add    $0x1,%edx
  8005cf:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005d2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005d5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005d8:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005db:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8005de:	89 d3                	mov    %edx,%ebx
  8005e0:	85 f6                	test   %esi,%esi
  8005e2:	78 8e                	js     800572 <vprintfmt+0x225>
  8005e4:	83 ee 01             	sub    $0x1,%esi
  8005e7:	79 89                	jns    800572 <vprintfmt+0x225>
  8005e9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ef:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005f2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8005f5:	eb c4                	jmp    8005bb <vprintfmt+0x26e>
  8005f7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8005fa:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005fd:	89 74 24 04          	mov    %esi,0x4(%esp)
  800601:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800608:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80060a:	83 eb 01             	sub    $0x1,%ebx
  80060d:	85 db                	test   %ebx,%ebx
  80060f:	7f ec                	jg     8005fd <vprintfmt+0x2b0>
  800611:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800614:	e9 60 fd ff ff       	jmp    800379 <vprintfmt+0x2c>
  800619:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80061c:	83 f9 01             	cmp    $0x1,%ecx
  80061f:	7e 16                	jle    800637 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  800621:	8b 45 14             	mov    0x14(%ebp),%eax
  800624:	8d 50 08             	lea    0x8(%eax),%edx
  800627:	89 55 14             	mov    %edx,0x14(%ebp)
  80062a:	8b 10                	mov    (%eax),%edx
  80062c:	8b 48 04             	mov    0x4(%eax),%ecx
  80062f:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800632:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800635:	eb 32                	jmp    800669 <vprintfmt+0x31c>
	else if (lflag)
  800637:	85 c9                	test   %ecx,%ecx
  800639:	74 18                	je     800653 <vprintfmt+0x306>
		return va_arg(*ap, long);
  80063b:	8b 45 14             	mov    0x14(%ebp),%eax
  80063e:	8d 50 04             	lea    0x4(%eax),%edx
  800641:	89 55 14             	mov    %edx,0x14(%ebp)
  800644:	8b 00                	mov    (%eax),%eax
  800646:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800649:	89 c1                	mov    %eax,%ecx
  80064b:	c1 f9 1f             	sar    $0x1f,%ecx
  80064e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800651:	eb 16                	jmp    800669 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  800653:	8b 45 14             	mov    0x14(%ebp),%eax
  800656:	8d 50 04             	lea    0x4(%eax),%edx
  800659:	89 55 14             	mov    %edx,0x14(%ebp)
  80065c:	8b 00                	mov    (%eax),%eax
  80065e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800661:	89 c2                	mov    %eax,%edx
  800663:	c1 fa 1f             	sar    $0x1f,%edx
  800666:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800669:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80066c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80066f:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  800674:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800678:	0f 89 8a 00 00 00    	jns    800708 <vprintfmt+0x3bb>
				putch('-', putdat);
  80067e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800682:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800689:	ff d7                	call   *%edi
				num = -(long long) num;
  80068b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80068e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800691:	f7 d8                	neg    %eax
  800693:	83 d2 00             	adc    $0x0,%edx
  800696:	f7 da                	neg    %edx
  800698:	eb 6e                	jmp    800708 <vprintfmt+0x3bb>
  80069a:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80069d:	89 ca                	mov    %ecx,%edx
  80069f:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a2:	e8 4f fc ff ff       	call   8002f6 <getuint>
  8006a7:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  8006ac:	eb 5a                	jmp    800708 <vprintfmt+0x3bb>
  8006ae:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  8006b1:	89 ca                	mov    %ecx,%edx
  8006b3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b6:	e8 3b fc ff ff       	call   8002f6 <getuint>
  8006bb:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  8006c0:	eb 46                	jmp    800708 <vprintfmt+0x3bb>
  8006c2:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  8006c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006c9:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006d0:	ff d7                	call   *%edi
			putch('x', putdat);
  8006d2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d6:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006dd:	ff d7                	call   *%edi
			num = (unsigned long long)
  8006df:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e2:	8d 50 04             	lea    0x4(%eax),%edx
  8006e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e8:	8b 00                	mov    (%eax),%eax
  8006ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8006ef:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006f4:	eb 12                	jmp    800708 <vprintfmt+0x3bb>
  8006f6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006f9:	89 ca                	mov    %ecx,%edx
  8006fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fe:	e8 f3 fb ff ff       	call   8002f6 <getuint>
  800703:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800708:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80070c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800710:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800713:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800717:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80071b:	89 04 24             	mov    %eax,(%esp)
  80071e:	89 54 24 04          	mov    %edx,0x4(%esp)
  800722:	89 f2                	mov    %esi,%edx
  800724:	89 f8                	mov    %edi,%eax
  800726:	e8 d5 fa ff ff       	call   800200 <printnum>
  80072b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  80072e:	e9 46 fc ff ff       	jmp    800379 <vprintfmt+0x2c>
  800733:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  800736:	8b 45 14             	mov    0x14(%ebp),%eax
  800739:	8d 50 04             	lea    0x4(%eax),%edx
  80073c:	89 55 14             	mov    %edx,0x14(%ebp)
  80073f:	8b 00                	mov    (%eax),%eax
  800741:	85 c0                	test   %eax,%eax
  800743:	75 24                	jne    800769 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  800745:	c7 44 24 0c 88 24 80 	movl   $0x802488,0xc(%esp)
  80074c:	00 
  80074d:	c7 44 24 08 f7 27 80 	movl   $0x8027f7,0x8(%esp)
  800754:	00 
  800755:	89 74 24 04          	mov    %esi,0x4(%esp)
  800759:	89 3c 24             	mov    %edi,(%esp)
  80075c:	e8 ff 00 00 00       	call   800860 <printfmt>
  800761:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800764:	e9 10 fc ff ff       	jmp    800379 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  800769:	83 3e 7f             	cmpl   $0x7f,(%esi)
  80076c:	7e 29                	jle    800797 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  80076e:	0f b6 16             	movzbl (%esi),%edx
  800771:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  800773:	c7 44 24 0c c0 24 80 	movl   $0x8024c0,0xc(%esp)
  80077a:	00 
  80077b:	c7 44 24 08 f7 27 80 	movl   $0x8027f7,0x8(%esp)
  800782:	00 
  800783:	89 74 24 04          	mov    %esi,0x4(%esp)
  800787:	89 3c 24             	mov    %edi,(%esp)
  80078a:	e8 d1 00 00 00       	call   800860 <printfmt>
  80078f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800792:	e9 e2 fb ff ff       	jmp    800379 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  800797:	0f b6 16             	movzbl (%esi),%edx
  80079a:	88 10                	mov    %dl,(%eax)
  80079c:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  80079f:	e9 d5 fb ff ff       	jmp    800379 <vprintfmt+0x2c>
  8007a4:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8007a7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007aa:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007ae:	89 14 24             	mov    %edx,(%esp)
  8007b1:	ff d7                	call   *%edi
  8007b3:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8007b6:	e9 be fb ff ff       	jmp    800379 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007bb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007bf:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007c6:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007c8:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8007cb:	80 38 25             	cmpb   $0x25,(%eax)
  8007ce:	0f 84 a5 fb ff ff    	je     800379 <vprintfmt+0x2c>
  8007d4:	89 c3                	mov    %eax,%ebx
  8007d6:	eb f0                	jmp    8007c8 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  8007d8:	83 c4 5c             	add    $0x5c,%esp
  8007db:	5b                   	pop    %ebx
  8007dc:	5e                   	pop    %esi
  8007dd:	5f                   	pop    %edi
  8007de:	5d                   	pop    %ebp
  8007df:	c3                   	ret    

008007e0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	83 ec 28             	sub    $0x28,%esp
  8007e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8007ec:	85 c0                	test   %eax,%eax
  8007ee:	74 04                	je     8007f4 <vsnprintf+0x14>
  8007f0:	85 d2                	test   %edx,%edx
  8007f2:	7f 07                	jg     8007fb <vsnprintf+0x1b>
  8007f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007f9:	eb 3b                	jmp    800836 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007fb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007fe:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800802:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800805:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80080c:	8b 45 14             	mov    0x14(%ebp),%eax
  80080f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800813:	8b 45 10             	mov    0x10(%ebp),%eax
  800816:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80081d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800821:	c7 04 24 30 03 80 00 	movl   $0x800330,(%esp)
  800828:	e8 20 fb ff ff       	call   80034d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80082d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800830:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800833:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800836:	c9                   	leave  
  800837:	c3                   	ret    

00800838 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800838:	55                   	push   %ebp
  800839:	89 e5                	mov    %esp,%ebp
  80083b:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80083e:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800841:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800845:	8b 45 10             	mov    0x10(%ebp),%eax
  800848:	89 44 24 08          	mov    %eax,0x8(%esp)
  80084c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800853:	8b 45 08             	mov    0x8(%ebp),%eax
  800856:	89 04 24             	mov    %eax,(%esp)
  800859:	e8 82 ff ff ff       	call   8007e0 <vsnprintf>
	va_end(ap);

	return rc;
}
  80085e:	c9                   	leave  
  80085f:	c3                   	ret    

00800860 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800866:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800869:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80086d:	8b 45 10             	mov    0x10(%ebp),%eax
  800870:	89 44 24 08          	mov    %eax,0x8(%esp)
  800874:	8b 45 0c             	mov    0xc(%ebp),%eax
  800877:	89 44 24 04          	mov    %eax,0x4(%esp)
  80087b:	8b 45 08             	mov    0x8(%ebp),%eax
  80087e:	89 04 24             	mov    %eax,(%esp)
  800881:	e8 c7 fa ff ff       	call   80034d <vprintfmt>
	va_end(ap);
}
  800886:	c9                   	leave  
  800887:	c3                   	ret    
	...

00800890 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800896:	b8 00 00 00 00       	mov    $0x0,%eax
  80089b:	80 3a 00             	cmpb   $0x0,(%edx)
  80089e:	74 09                	je     8008a9 <strlen+0x19>
		n++;
  8008a0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008a7:	75 f7                	jne    8008a0 <strlen+0x10>
		n++;
	return n;
}
  8008a9:	5d                   	pop    %ebp
  8008aa:	c3                   	ret    

008008ab <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	53                   	push   %ebx
  8008af:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008b5:	85 c9                	test   %ecx,%ecx
  8008b7:	74 19                	je     8008d2 <strnlen+0x27>
  8008b9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008bc:	74 14                	je     8008d2 <strnlen+0x27>
  8008be:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008c3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c6:	39 c8                	cmp    %ecx,%eax
  8008c8:	74 0d                	je     8008d7 <strnlen+0x2c>
  8008ca:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8008ce:	75 f3                	jne    8008c3 <strnlen+0x18>
  8008d0:	eb 05                	jmp    8008d7 <strnlen+0x2c>
  8008d2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008d7:	5b                   	pop    %ebx
  8008d8:	5d                   	pop    %ebp
  8008d9:	c3                   	ret    

008008da <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	53                   	push   %ebx
  8008de:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008e4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008e9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008ed:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008f0:	83 c2 01             	add    $0x1,%edx
  8008f3:	84 c9                	test   %cl,%cl
  8008f5:	75 f2                	jne    8008e9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008f7:	5b                   	pop    %ebx
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	53                   	push   %ebx
  8008fe:	83 ec 08             	sub    $0x8,%esp
  800901:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800904:	89 1c 24             	mov    %ebx,(%esp)
  800907:	e8 84 ff ff ff       	call   800890 <strlen>
	strcpy(dst + len, src);
  80090c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80090f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800913:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800916:	89 04 24             	mov    %eax,(%esp)
  800919:	e8 bc ff ff ff       	call   8008da <strcpy>
	return dst;
}
  80091e:	89 d8                	mov    %ebx,%eax
  800920:	83 c4 08             	add    $0x8,%esp
  800923:	5b                   	pop    %ebx
  800924:	5d                   	pop    %ebp
  800925:	c3                   	ret    

00800926 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800926:	55                   	push   %ebp
  800927:	89 e5                	mov    %esp,%ebp
  800929:	56                   	push   %esi
  80092a:	53                   	push   %ebx
  80092b:	8b 45 08             	mov    0x8(%ebp),%eax
  80092e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800931:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800934:	85 f6                	test   %esi,%esi
  800936:	74 18                	je     800950 <strncpy+0x2a>
  800938:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80093d:	0f b6 1a             	movzbl (%edx),%ebx
  800940:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800943:	80 3a 01             	cmpb   $0x1,(%edx)
  800946:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800949:	83 c1 01             	add    $0x1,%ecx
  80094c:	39 ce                	cmp    %ecx,%esi
  80094e:	77 ed                	ja     80093d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800950:	5b                   	pop    %ebx
  800951:	5e                   	pop    %esi
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	56                   	push   %esi
  800958:	53                   	push   %ebx
  800959:	8b 75 08             	mov    0x8(%ebp),%esi
  80095c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800962:	89 f0                	mov    %esi,%eax
  800964:	85 c9                	test   %ecx,%ecx
  800966:	74 27                	je     80098f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800968:	83 e9 01             	sub    $0x1,%ecx
  80096b:	74 1d                	je     80098a <strlcpy+0x36>
  80096d:	0f b6 1a             	movzbl (%edx),%ebx
  800970:	84 db                	test   %bl,%bl
  800972:	74 16                	je     80098a <strlcpy+0x36>
			*dst++ = *src++;
  800974:	88 18                	mov    %bl,(%eax)
  800976:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800979:	83 e9 01             	sub    $0x1,%ecx
  80097c:	74 0e                	je     80098c <strlcpy+0x38>
			*dst++ = *src++;
  80097e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800981:	0f b6 1a             	movzbl (%edx),%ebx
  800984:	84 db                	test   %bl,%bl
  800986:	75 ec                	jne    800974 <strlcpy+0x20>
  800988:	eb 02                	jmp    80098c <strlcpy+0x38>
  80098a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80098c:	c6 00 00             	movb   $0x0,(%eax)
  80098f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800991:	5b                   	pop    %ebx
  800992:	5e                   	pop    %esi
  800993:	5d                   	pop    %ebp
  800994:	c3                   	ret    

00800995 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80099e:	0f b6 01             	movzbl (%ecx),%eax
  8009a1:	84 c0                	test   %al,%al
  8009a3:	74 15                	je     8009ba <strcmp+0x25>
  8009a5:	3a 02                	cmp    (%edx),%al
  8009a7:	75 11                	jne    8009ba <strcmp+0x25>
		p++, q++;
  8009a9:	83 c1 01             	add    $0x1,%ecx
  8009ac:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009af:	0f b6 01             	movzbl (%ecx),%eax
  8009b2:	84 c0                	test   %al,%al
  8009b4:	74 04                	je     8009ba <strcmp+0x25>
  8009b6:	3a 02                	cmp    (%edx),%al
  8009b8:	74 ef                	je     8009a9 <strcmp+0x14>
  8009ba:	0f b6 c0             	movzbl %al,%eax
  8009bd:	0f b6 12             	movzbl (%edx),%edx
  8009c0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009c2:	5d                   	pop    %ebp
  8009c3:	c3                   	ret    

008009c4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009c4:	55                   	push   %ebp
  8009c5:	89 e5                	mov    %esp,%ebp
  8009c7:	53                   	push   %ebx
  8009c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8009cb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ce:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8009d1:	85 c0                	test   %eax,%eax
  8009d3:	74 23                	je     8009f8 <strncmp+0x34>
  8009d5:	0f b6 1a             	movzbl (%edx),%ebx
  8009d8:	84 db                	test   %bl,%bl
  8009da:	74 25                	je     800a01 <strncmp+0x3d>
  8009dc:	3a 19                	cmp    (%ecx),%bl
  8009de:	75 21                	jne    800a01 <strncmp+0x3d>
  8009e0:	83 e8 01             	sub    $0x1,%eax
  8009e3:	74 13                	je     8009f8 <strncmp+0x34>
		n--, p++, q++;
  8009e5:	83 c2 01             	add    $0x1,%edx
  8009e8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009eb:	0f b6 1a             	movzbl (%edx),%ebx
  8009ee:	84 db                	test   %bl,%bl
  8009f0:	74 0f                	je     800a01 <strncmp+0x3d>
  8009f2:	3a 19                	cmp    (%ecx),%bl
  8009f4:	74 ea                	je     8009e0 <strncmp+0x1c>
  8009f6:	eb 09                	jmp    800a01 <strncmp+0x3d>
  8009f8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009fd:	5b                   	pop    %ebx
  8009fe:	5d                   	pop    %ebp
  8009ff:	90                   	nop
  800a00:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a01:	0f b6 02             	movzbl (%edx),%eax
  800a04:	0f b6 11             	movzbl (%ecx),%edx
  800a07:	29 d0                	sub    %edx,%eax
  800a09:	eb f2                	jmp    8009fd <strncmp+0x39>

00800a0b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a15:	0f b6 10             	movzbl (%eax),%edx
  800a18:	84 d2                	test   %dl,%dl
  800a1a:	74 18                	je     800a34 <strchr+0x29>
		if (*s == c)
  800a1c:	38 ca                	cmp    %cl,%dl
  800a1e:	75 0a                	jne    800a2a <strchr+0x1f>
  800a20:	eb 17                	jmp    800a39 <strchr+0x2e>
  800a22:	38 ca                	cmp    %cl,%dl
  800a24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a28:	74 0f                	je     800a39 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a2a:	83 c0 01             	add    $0x1,%eax
  800a2d:	0f b6 10             	movzbl (%eax),%edx
  800a30:	84 d2                	test   %dl,%dl
  800a32:	75 ee                	jne    800a22 <strchr+0x17>
  800a34:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a39:	5d                   	pop    %ebp
  800a3a:	c3                   	ret    

00800a3b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a45:	0f b6 10             	movzbl (%eax),%edx
  800a48:	84 d2                	test   %dl,%dl
  800a4a:	74 18                	je     800a64 <strfind+0x29>
		if (*s == c)
  800a4c:	38 ca                	cmp    %cl,%dl
  800a4e:	75 0a                	jne    800a5a <strfind+0x1f>
  800a50:	eb 12                	jmp    800a64 <strfind+0x29>
  800a52:	38 ca                	cmp    %cl,%dl
  800a54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a58:	74 0a                	je     800a64 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a5a:	83 c0 01             	add    $0x1,%eax
  800a5d:	0f b6 10             	movzbl (%eax),%edx
  800a60:	84 d2                	test   %dl,%dl
  800a62:	75 ee                	jne    800a52 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a64:	5d                   	pop    %ebp
  800a65:	c3                   	ret    

00800a66 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a66:	55                   	push   %ebp
  800a67:	89 e5                	mov    %esp,%ebp
  800a69:	83 ec 0c             	sub    $0xc,%esp
  800a6c:	89 1c 24             	mov    %ebx,(%esp)
  800a6f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a73:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a77:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a7d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a80:	85 c9                	test   %ecx,%ecx
  800a82:	74 30                	je     800ab4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a84:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a8a:	75 25                	jne    800ab1 <memset+0x4b>
  800a8c:	f6 c1 03             	test   $0x3,%cl
  800a8f:	75 20                	jne    800ab1 <memset+0x4b>
		c &= 0xFF;
  800a91:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a94:	89 d3                	mov    %edx,%ebx
  800a96:	c1 e3 08             	shl    $0x8,%ebx
  800a99:	89 d6                	mov    %edx,%esi
  800a9b:	c1 e6 18             	shl    $0x18,%esi
  800a9e:	89 d0                	mov    %edx,%eax
  800aa0:	c1 e0 10             	shl    $0x10,%eax
  800aa3:	09 f0                	or     %esi,%eax
  800aa5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800aa7:	09 d8                	or     %ebx,%eax
  800aa9:	c1 e9 02             	shr    $0x2,%ecx
  800aac:	fc                   	cld    
  800aad:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aaf:	eb 03                	jmp    800ab4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ab1:	fc                   	cld    
  800ab2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ab4:	89 f8                	mov    %edi,%eax
  800ab6:	8b 1c 24             	mov    (%esp),%ebx
  800ab9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800abd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ac1:	89 ec                	mov    %ebp,%esp
  800ac3:	5d                   	pop    %ebp
  800ac4:	c3                   	ret    

00800ac5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ac5:	55                   	push   %ebp
  800ac6:	89 e5                	mov    %esp,%ebp
  800ac8:	83 ec 08             	sub    $0x8,%esp
  800acb:	89 34 24             	mov    %esi,(%esp)
  800ace:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ad2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800ad8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800adb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800add:	39 c6                	cmp    %eax,%esi
  800adf:	73 35                	jae    800b16 <memmove+0x51>
  800ae1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ae4:	39 d0                	cmp    %edx,%eax
  800ae6:	73 2e                	jae    800b16 <memmove+0x51>
		s += n;
		d += n;
  800ae8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aea:	f6 c2 03             	test   $0x3,%dl
  800aed:	75 1b                	jne    800b0a <memmove+0x45>
  800aef:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800af5:	75 13                	jne    800b0a <memmove+0x45>
  800af7:	f6 c1 03             	test   $0x3,%cl
  800afa:	75 0e                	jne    800b0a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800afc:	83 ef 04             	sub    $0x4,%edi
  800aff:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b02:	c1 e9 02             	shr    $0x2,%ecx
  800b05:	fd                   	std    
  800b06:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b08:	eb 09                	jmp    800b13 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b0a:	83 ef 01             	sub    $0x1,%edi
  800b0d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b10:	fd                   	std    
  800b11:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b13:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b14:	eb 20                	jmp    800b36 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b16:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b1c:	75 15                	jne    800b33 <memmove+0x6e>
  800b1e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b24:	75 0d                	jne    800b33 <memmove+0x6e>
  800b26:	f6 c1 03             	test   $0x3,%cl
  800b29:	75 08                	jne    800b33 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800b2b:	c1 e9 02             	shr    $0x2,%ecx
  800b2e:	fc                   	cld    
  800b2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b31:	eb 03                	jmp    800b36 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b33:	fc                   	cld    
  800b34:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b36:	8b 34 24             	mov    (%esp),%esi
  800b39:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b3d:	89 ec                	mov    %ebp,%esp
  800b3f:	5d                   	pop    %ebp
  800b40:	c3                   	ret    

00800b41 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b47:	8b 45 10             	mov    0x10(%ebp),%eax
  800b4a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b4e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b51:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b55:	8b 45 08             	mov    0x8(%ebp),%eax
  800b58:	89 04 24             	mov    %eax,(%esp)
  800b5b:	e8 65 ff ff ff       	call   800ac5 <memmove>
}
  800b60:	c9                   	leave  
  800b61:	c3                   	ret    

00800b62 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b62:	55                   	push   %ebp
  800b63:	89 e5                	mov    %esp,%ebp
  800b65:	57                   	push   %edi
  800b66:	56                   	push   %esi
  800b67:	53                   	push   %ebx
  800b68:	8b 75 08             	mov    0x8(%ebp),%esi
  800b6b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b71:	85 c9                	test   %ecx,%ecx
  800b73:	74 36                	je     800bab <memcmp+0x49>
		if (*s1 != *s2)
  800b75:	0f b6 06             	movzbl (%esi),%eax
  800b78:	0f b6 1f             	movzbl (%edi),%ebx
  800b7b:	38 d8                	cmp    %bl,%al
  800b7d:	74 20                	je     800b9f <memcmp+0x3d>
  800b7f:	eb 14                	jmp    800b95 <memcmp+0x33>
  800b81:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800b86:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800b8b:	83 c2 01             	add    $0x1,%edx
  800b8e:	83 e9 01             	sub    $0x1,%ecx
  800b91:	38 d8                	cmp    %bl,%al
  800b93:	74 12                	je     800ba7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800b95:	0f b6 c0             	movzbl %al,%eax
  800b98:	0f b6 db             	movzbl %bl,%ebx
  800b9b:	29 d8                	sub    %ebx,%eax
  800b9d:	eb 11                	jmp    800bb0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b9f:	83 e9 01             	sub    $0x1,%ecx
  800ba2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba7:	85 c9                	test   %ecx,%ecx
  800ba9:	75 d6                	jne    800b81 <memcmp+0x1f>
  800bab:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800bb0:	5b                   	pop    %ebx
  800bb1:	5e                   	pop    %esi
  800bb2:	5f                   	pop    %edi
  800bb3:	5d                   	pop    %ebp
  800bb4:	c3                   	ret    

00800bb5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bbb:	89 c2                	mov    %eax,%edx
  800bbd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bc0:	39 d0                	cmp    %edx,%eax
  800bc2:	73 15                	jae    800bd9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bc4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800bc8:	38 08                	cmp    %cl,(%eax)
  800bca:	75 06                	jne    800bd2 <memfind+0x1d>
  800bcc:	eb 0b                	jmp    800bd9 <memfind+0x24>
  800bce:	38 08                	cmp    %cl,(%eax)
  800bd0:	74 07                	je     800bd9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bd2:	83 c0 01             	add    $0x1,%eax
  800bd5:	39 c2                	cmp    %eax,%edx
  800bd7:	77 f5                	ja     800bce <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	57                   	push   %edi
  800bdf:	56                   	push   %esi
  800be0:	53                   	push   %ebx
  800be1:	83 ec 04             	sub    $0x4,%esp
  800be4:	8b 55 08             	mov    0x8(%ebp),%edx
  800be7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bea:	0f b6 02             	movzbl (%edx),%eax
  800bed:	3c 20                	cmp    $0x20,%al
  800bef:	74 04                	je     800bf5 <strtol+0x1a>
  800bf1:	3c 09                	cmp    $0x9,%al
  800bf3:	75 0e                	jne    800c03 <strtol+0x28>
		s++;
  800bf5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bf8:	0f b6 02             	movzbl (%edx),%eax
  800bfb:	3c 20                	cmp    $0x20,%al
  800bfd:	74 f6                	je     800bf5 <strtol+0x1a>
  800bff:	3c 09                	cmp    $0x9,%al
  800c01:	74 f2                	je     800bf5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c03:	3c 2b                	cmp    $0x2b,%al
  800c05:	75 0c                	jne    800c13 <strtol+0x38>
		s++;
  800c07:	83 c2 01             	add    $0x1,%edx
  800c0a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c11:	eb 15                	jmp    800c28 <strtol+0x4d>
	else if (*s == '-')
  800c13:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c1a:	3c 2d                	cmp    $0x2d,%al
  800c1c:	75 0a                	jne    800c28 <strtol+0x4d>
		s++, neg = 1;
  800c1e:	83 c2 01             	add    $0x1,%edx
  800c21:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c28:	85 db                	test   %ebx,%ebx
  800c2a:	0f 94 c0             	sete   %al
  800c2d:	74 05                	je     800c34 <strtol+0x59>
  800c2f:	83 fb 10             	cmp    $0x10,%ebx
  800c32:	75 18                	jne    800c4c <strtol+0x71>
  800c34:	80 3a 30             	cmpb   $0x30,(%edx)
  800c37:	75 13                	jne    800c4c <strtol+0x71>
  800c39:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c3d:	8d 76 00             	lea    0x0(%esi),%esi
  800c40:	75 0a                	jne    800c4c <strtol+0x71>
		s += 2, base = 16;
  800c42:	83 c2 02             	add    $0x2,%edx
  800c45:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c4a:	eb 15                	jmp    800c61 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c4c:	84 c0                	test   %al,%al
  800c4e:	66 90                	xchg   %ax,%ax
  800c50:	74 0f                	je     800c61 <strtol+0x86>
  800c52:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c57:	80 3a 30             	cmpb   $0x30,(%edx)
  800c5a:	75 05                	jne    800c61 <strtol+0x86>
		s++, base = 8;
  800c5c:	83 c2 01             	add    $0x1,%edx
  800c5f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c61:	b8 00 00 00 00       	mov    $0x0,%eax
  800c66:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c68:	0f b6 0a             	movzbl (%edx),%ecx
  800c6b:	89 cf                	mov    %ecx,%edi
  800c6d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c70:	80 fb 09             	cmp    $0x9,%bl
  800c73:	77 08                	ja     800c7d <strtol+0xa2>
			dig = *s - '0';
  800c75:	0f be c9             	movsbl %cl,%ecx
  800c78:	83 e9 30             	sub    $0x30,%ecx
  800c7b:	eb 1e                	jmp    800c9b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800c7d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800c80:	80 fb 19             	cmp    $0x19,%bl
  800c83:	77 08                	ja     800c8d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800c85:	0f be c9             	movsbl %cl,%ecx
  800c88:	83 e9 57             	sub    $0x57,%ecx
  800c8b:	eb 0e                	jmp    800c9b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800c8d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800c90:	80 fb 19             	cmp    $0x19,%bl
  800c93:	77 15                	ja     800caa <strtol+0xcf>
			dig = *s - 'A' + 10;
  800c95:	0f be c9             	movsbl %cl,%ecx
  800c98:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c9b:	39 f1                	cmp    %esi,%ecx
  800c9d:	7d 0b                	jge    800caa <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800c9f:	83 c2 01             	add    $0x1,%edx
  800ca2:	0f af c6             	imul   %esi,%eax
  800ca5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800ca8:	eb be                	jmp    800c68 <strtol+0x8d>
  800caa:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800cac:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cb0:	74 05                	je     800cb7 <strtol+0xdc>
		*endptr = (char *) s;
  800cb2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cb5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800cb7:	89 ca                	mov    %ecx,%edx
  800cb9:	f7 da                	neg    %edx
  800cbb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800cbf:	0f 45 c2             	cmovne %edx,%eax
}
  800cc2:	83 c4 04             	add    $0x4,%esp
  800cc5:	5b                   	pop    %ebx
  800cc6:	5e                   	pop    %esi
  800cc7:	5f                   	pop    %edi
  800cc8:	5d                   	pop    %ebp
  800cc9:	c3                   	ret    
	...

00800ccc <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	83 ec 48             	sub    $0x48,%esp
  800cd2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cd5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cd8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800cdb:	89 c6                	mov    %eax,%esi
  800cdd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800ce0:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ce2:	8b 7d 10             	mov    0x10(%ebp),%edi
  800ce5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ce8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ceb:	51                   	push   %ecx
  800cec:	52                   	push   %edx
  800ced:	53                   	push   %ebx
  800cee:	54                   	push   %esp
  800cef:	55                   	push   %ebp
  800cf0:	56                   	push   %esi
  800cf1:	57                   	push   %edi
  800cf2:	89 e5                	mov    %esp,%ebp
  800cf4:	8d 35 fc 0c 80 00    	lea    0x800cfc,%esi
  800cfa:	0f 34                	sysenter 

00800cfc <.after_sysenter_label>:
  800cfc:	5f                   	pop    %edi
  800cfd:	5e                   	pop    %esi
  800cfe:	5d                   	pop    %ebp
  800cff:	5c                   	pop    %esp
  800d00:	5b                   	pop    %ebx
  800d01:	5a                   	pop    %edx
  800d02:	59                   	pop    %ecx
  800d03:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800d05:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d09:	74 28                	je     800d33 <.after_sysenter_label+0x37>
  800d0b:	85 c0                	test   %eax,%eax
  800d0d:	7e 24                	jle    800d33 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d0f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d13:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800d17:	c7 44 24 08 e0 26 80 	movl   $0x8026e0,0x8(%esp)
  800d1e:	00 
  800d1f:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800d26:	00 
  800d27:	c7 04 24 fd 26 80 00 	movl   $0x8026fd,(%esp)
  800d2e:	e8 e1 12 00 00       	call   802014 <_panic>

	return ret;
}
  800d33:	89 d0                	mov    %edx,%eax
  800d35:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d38:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d3b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d3e:	89 ec                	mov    %ebp,%esp
  800d40:	5d                   	pop    %ebp
  800d41:	c3                   	ret    

00800d42 <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  800d48:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d4f:	00 
  800d50:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d57:	00 
  800d58:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d5f:	00 
  800d60:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d63:	89 04 24             	mov    %eax,(%esp)
  800d66:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d69:	ba 00 00 00 00       	mov    $0x0,%edx
  800d6e:	b8 10 00 00 00       	mov    $0x10,%eax
  800d73:	e8 54 ff ff ff       	call   800ccc <syscall>
}
  800d78:	c9                   	leave  
  800d79:	c3                   	ret    

00800d7a <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  800d80:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d87:	00 
  800d88:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d8f:	00 
  800d90:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d97:	00 
  800d98:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d9f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da4:	ba 00 00 00 00       	mov    $0x0,%edx
  800da9:	b8 0f 00 00 00       	mov    $0xf,%eax
  800dae:	e8 19 ff ff ff       	call   800ccc <syscall>
}
  800db3:	c9                   	leave  
  800db4:	c3                   	ret    

00800db5 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800db5:	55                   	push   %ebp
  800db6:	89 e5                	mov    %esp,%ebp
  800db8:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800dbb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dc2:	00 
  800dc3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800dca:	00 
  800dcb:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800dd2:	00 
  800dd3:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800dda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ddd:	ba 01 00 00 00       	mov    $0x1,%edx
  800de2:	b8 0e 00 00 00       	mov    $0xe,%eax
  800de7:	e8 e0 fe ff ff       	call   800ccc <syscall>
}
  800dec:	c9                   	leave  
  800ded:	c3                   	ret    

00800dee <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800df4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dfb:	00 
  800dfc:	8b 45 14             	mov    0x14(%ebp),%eax
  800dff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e03:	8b 45 10             	mov    0x10(%ebp),%eax
  800e06:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e0d:	89 04 24             	mov    %eax,(%esp)
  800e10:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e13:	ba 00 00 00 00       	mov    $0x0,%edx
  800e18:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e1d:	e8 aa fe ff ff       	call   800ccc <syscall>
}
  800e22:	c9                   	leave  
  800e23:	c3                   	ret    

00800e24 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
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
  800e50:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e55:	e8 72 fe ff ff       	call   800ccc <syscall>
}
  800e5a:	c9                   	leave  
  800e5b:	c3                   	ret    

00800e5c <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e5c:	55                   	push   %ebp
  800e5d:	89 e5                	mov    %esp,%ebp
  800e5f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
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
  800e88:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e8d:	e8 3a fe ff ff       	call   800ccc <syscall>
}
  800e92:	c9                   	leave  
  800e93:	c3                   	ret    

00800e94 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800e9a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ea1:	00 
  800ea2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ea9:	00 
  800eaa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800eb1:	00 
  800eb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eb5:	89 04 24             	mov    %eax,(%esp)
  800eb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ebb:	ba 01 00 00 00       	mov    $0x1,%edx
  800ec0:	b8 09 00 00 00       	mov    $0x9,%eax
  800ec5:	e8 02 fe ff ff       	call   800ccc <syscall>
}
  800eca:	c9                   	leave  
  800ecb:	c3                   	ret    

00800ecc <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800ed2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ed9:	00 
  800eda:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ee1:	00 
  800ee2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ee9:	00 
  800eea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eed:	89 04 24             	mov    %eax,(%esp)
  800ef0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef3:	ba 01 00 00 00       	mov    $0x1,%edx
  800ef8:	b8 07 00 00 00       	mov    $0x7,%eax
  800efd:	e8 ca fd ff ff       	call   800ccc <syscall>
}
  800f02:	c9                   	leave  
  800f03:	c3                   	ret    

00800f04 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800f0a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f11:	00 
  800f12:	8b 45 18             	mov    0x18(%ebp),%eax
  800f15:	0b 45 14             	or     0x14(%ebp),%eax
  800f18:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f1c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f23:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f26:	89 04 24             	mov    %eax,(%esp)
  800f29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f2c:	ba 01 00 00 00       	mov    $0x1,%edx
  800f31:	b8 06 00 00 00       	mov    $0x6,%eax
  800f36:	e8 91 fd ff ff       	call   800ccc <syscall>
}
  800f3b:	c9                   	leave  
  800f3c:	c3                   	ret    

00800f3d <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f43:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f4a:	00 
  800f4b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f52:	00 
  800f53:	8b 45 10             	mov    0x10(%ebp),%eax
  800f56:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f5d:	89 04 24             	mov    %eax,(%esp)
  800f60:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f63:	ba 01 00 00 00       	mov    $0x1,%edx
  800f68:	b8 05 00 00 00       	mov    $0x5,%eax
  800f6d:	e8 5a fd ff ff       	call   800ccc <syscall>
}
  800f72:	c9                   	leave  
  800f73:	c3                   	ret    

00800f74 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800f74:	55                   	push   %ebp
  800f75:	89 e5                	mov    %esp,%ebp
  800f77:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f7a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f81:	00 
  800f82:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f89:	00 
  800f8a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f91:	00 
  800f92:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f99:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f9e:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa3:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fa8:	e8 1f fd ff ff       	call   800ccc <syscall>
}
  800fad:	c9                   	leave  
  800fae:	c3                   	ret    

00800faf <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800faf:	55                   	push   %ebp
  800fb0:	89 e5                	mov    %esp,%ebp
  800fb2:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  800fb5:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fbc:	00 
  800fbd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fc4:	00 
  800fc5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fcc:	00 
  800fcd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fd0:	89 04 24             	mov    %eax,(%esp)
  800fd3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fd6:	ba 00 00 00 00       	mov    $0x0,%edx
  800fdb:	b8 04 00 00 00       	mov    $0x4,%eax
  800fe0:	e8 e7 fc ff ff       	call   800ccc <syscall>
}
  800fe5:	c9                   	leave  
  800fe6:	c3                   	ret    

00800fe7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800fe7:	55                   	push   %ebp
  800fe8:	89 e5                	mov    %esp,%ebp
  800fea:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800fed:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ff4:	00 
  800ff5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ffc:	00 
  800ffd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801004:	00 
  801005:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80100c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801011:	ba 00 00 00 00       	mov    $0x0,%edx
  801016:	b8 02 00 00 00       	mov    $0x2,%eax
  80101b:	e8 ac fc ff ff       	call   800ccc <syscall>
}
  801020:	c9                   	leave  
  801021:	c3                   	ret    

00801022 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801022:	55                   	push   %ebp
  801023:	89 e5                	mov    %esp,%ebp
  801025:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  801028:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80102f:	00 
  801030:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801037:	00 
  801038:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80103f:	00 
  801040:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801047:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80104a:	ba 01 00 00 00       	mov    $0x1,%edx
  80104f:	b8 03 00 00 00       	mov    $0x3,%eax
  801054:	e8 73 fc ff ff       	call   800ccc <syscall>
}
  801059:	c9                   	leave  
  80105a:	c3                   	ret    

0080105b <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  801061:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801068:	00 
  801069:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801070:	00 
  801071:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801078:	00 
  801079:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801080:	b9 00 00 00 00       	mov    $0x0,%ecx
  801085:	ba 00 00 00 00       	mov    $0x0,%edx
  80108a:	b8 01 00 00 00       	mov    $0x1,%eax
  80108f:	e8 38 fc ff ff       	call   800ccc <syscall>
}
  801094:	c9                   	leave  
  801095:	c3                   	ret    

00801096 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801096:	55                   	push   %ebp
  801097:	89 e5                	mov    %esp,%ebp
  801099:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80109c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010a3:	00 
  8010a4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010ab:	00 
  8010ac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010b3:	00 
  8010b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8010b7:	89 04 24             	mov    %eax,(%esp)
  8010ba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8010c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8010c7:	e8 00 fc ff ff       	call   800ccc <syscall>
}
  8010cc:	c9                   	leave  
  8010cd:	c3                   	ret    
	...

008010d0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8010d6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  8010dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8010e1:	39 ca                	cmp    %ecx,%edx
  8010e3:	75 04                	jne    8010e9 <ipc_find_env+0x19>
  8010e5:	b0 00                	mov    $0x0,%al
  8010e7:	eb 11                	jmp    8010fa <ipc_find_env+0x2a>
  8010e9:	89 c2                	mov    %eax,%edx
  8010eb:	c1 e2 07             	shl    $0x7,%edx
  8010ee:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  8010f4:	8b 12                	mov    (%edx),%edx
  8010f6:	39 ca                	cmp    %ecx,%edx
  8010f8:	75 0f                	jne    801109 <ipc_find_env+0x39>
			return envs[i].env_id;
  8010fa:	8d 44 00 01          	lea    0x1(%eax,%eax,1),%eax
  8010fe:	c1 e0 06             	shl    $0x6,%eax
  801101:	8b 80 08 00 c0 ee    	mov    -0x113ffff8(%eax),%eax
  801107:	eb 0e                	jmp    801117 <ipc_find_env+0x47>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801109:	83 c0 01             	add    $0x1,%eax
  80110c:	3d 00 04 00 00       	cmp    $0x400,%eax
  801111:	75 d6                	jne    8010e9 <ipc_find_env+0x19>
  801113:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801117:	5d                   	pop    %ebp
  801118:	c3                   	ret    

00801119 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801119:	55                   	push   %ebp
  80111a:	89 e5                	mov    %esp,%ebp
  80111c:	57                   	push   %edi
  80111d:	56                   	push   %esi
  80111e:	53                   	push   %ebx
  80111f:	83 ec 1c             	sub    $0x1c,%esp
  801122:	8b 75 08             	mov    0x8(%ebp),%esi
  801125:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801128:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  80112b:	85 db                	test   %ebx,%ebx
  80112d:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801132:	0f 44 d8             	cmove  %eax,%ebx
  801135:	eb 25                	jmp    80115c <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  801137:	83 f8 f9             	cmp    $0xfffffff9,%eax
  80113a:	74 20                	je     80115c <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  80113c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801140:	c7 44 24 08 0b 27 80 	movl   $0x80270b,0x8(%esp)
  801147:	00 
  801148:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  80114f:	00 
  801150:	c7 04 24 29 27 80 00 	movl   $0x802729,(%esp)
  801157:	e8 b8 0e 00 00       	call   802014 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  80115c:	8b 45 14             	mov    0x14(%ebp),%eax
  80115f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801163:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801167:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80116b:	89 34 24             	mov    %esi,(%esp)
  80116e:	e8 7b fc ff ff       	call   800dee <sys_ipc_try_send>
  801173:	85 c0                	test   %eax,%eax
  801175:	75 c0                	jne    801137 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  801177:	e8 f8 fd ff ff       	call   800f74 <sys_yield>
}
  80117c:	83 c4 1c             	add    $0x1c,%esp
  80117f:	5b                   	pop    %ebx
  801180:	5e                   	pop    %esi
  801181:	5f                   	pop    %edi
  801182:	5d                   	pop    %ebp
  801183:	c3                   	ret    

00801184 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801184:	55                   	push   %ebp
  801185:	89 e5                	mov    %esp,%ebp
  801187:	83 ec 28             	sub    $0x28,%esp
  80118a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80118d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801190:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801193:	8b 75 08             	mov    0x8(%ebp),%esi
  801196:	8b 45 0c             	mov    0xc(%ebp),%eax
  801199:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  80119c:	85 c0                	test   %eax,%eax
  80119e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8011a3:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  8011a6:	89 04 24             	mov    %eax,(%esp)
  8011a9:	e8 07 fc ff ff       	call   800db5 <sys_ipc_recv>
  8011ae:	89 c3                	mov    %eax,%ebx
  8011b0:	85 c0                	test   %eax,%eax
  8011b2:	79 2a                	jns    8011de <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  8011b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011bc:	c7 04 24 33 27 80 00 	movl   $0x802733,(%esp)
  8011c3:	e8 cd ef ff ff       	call   800195 <cprintf>
		if(from_env_store != NULL)
  8011c8:	85 f6                	test   %esi,%esi
  8011ca:	74 06                	je     8011d2 <ipc_recv+0x4e>
			*from_env_store = 0;
  8011cc:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  8011d2:	85 ff                	test   %edi,%edi
  8011d4:	74 2c                	je     801202 <ipc_recv+0x7e>
			*perm_store = 0;
  8011d6:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8011dc:	eb 24                	jmp    801202 <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  8011de:	85 f6                	test   %esi,%esi
  8011e0:	74 0a                	je     8011ec <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  8011e2:	a1 08 40 80 00       	mov    0x804008,%eax
  8011e7:	8b 40 74             	mov    0x74(%eax),%eax
  8011ea:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  8011ec:	85 ff                	test   %edi,%edi
  8011ee:	74 0a                	je     8011fa <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  8011f0:	a1 08 40 80 00       	mov    0x804008,%eax
  8011f5:	8b 40 78             	mov    0x78(%eax),%eax
  8011f8:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8011fa:	a1 08 40 80 00       	mov    0x804008,%eax
  8011ff:	8b 58 70             	mov    0x70(%eax),%ebx
}
  801202:	89 d8                	mov    %ebx,%eax
  801204:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801207:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80120a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80120d:	89 ec                	mov    %ebp,%esp
  80120f:	5d                   	pop    %ebp
  801210:	c3                   	ret    
	...

00801220 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	8b 45 08             	mov    0x8(%ebp),%eax
  801226:	05 00 00 00 30       	add    $0x30000000,%eax
  80122b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80122e:	5d                   	pop    %ebp
  80122f:	c3                   	ret    

00801230 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801230:	55                   	push   %ebp
  801231:	89 e5                	mov    %esp,%ebp
  801233:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801236:	8b 45 08             	mov    0x8(%ebp),%eax
  801239:	89 04 24             	mov    %eax,(%esp)
  80123c:	e8 df ff ff ff       	call   801220 <fd2num>
  801241:	05 20 00 0d 00       	add    $0xd0020,%eax
  801246:	c1 e0 0c             	shl    $0xc,%eax
}
  801249:	c9                   	leave  
  80124a:	c3                   	ret    

0080124b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	57                   	push   %edi
  80124f:	56                   	push   %esi
  801250:	53                   	push   %ebx
  801251:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801254:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801259:	a8 01                	test   $0x1,%al
  80125b:	74 36                	je     801293 <fd_alloc+0x48>
  80125d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801262:	a8 01                	test   $0x1,%al
  801264:	74 2d                	je     801293 <fd_alloc+0x48>
  801266:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80126b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801270:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801275:	89 c3                	mov    %eax,%ebx
  801277:	89 c2                	mov    %eax,%edx
  801279:	c1 ea 16             	shr    $0x16,%edx
  80127c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80127f:	f6 c2 01             	test   $0x1,%dl
  801282:	74 14                	je     801298 <fd_alloc+0x4d>
  801284:	89 c2                	mov    %eax,%edx
  801286:	c1 ea 0c             	shr    $0xc,%edx
  801289:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80128c:	f6 c2 01             	test   $0x1,%dl
  80128f:	75 10                	jne    8012a1 <fd_alloc+0x56>
  801291:	eb 05                	jmp    801298 <fd_alloc+0x4d>
  801293:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801298:	89 1f                	mov    %ebx,(%edi)
  80129a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80129f:	eb 17                	jmp    8012b8 <fd_alloc+0x6d>
  8012a1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012a6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012ab:	75 c8                	jne    801275 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012ad:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8012b3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8012b8:	5b                   	pop    %ebx
  8012b9:	5e                   	pop    %esi
  8012ba:	5f                   	pop    %edi
  8012bb:	5d                   	pop    %ebp
  8012bc:	c3                   	ret    

008012bd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c3:	83 f8 1f             	cmp    $0x1f,%eax
  8012c6:	77 36                	ja     8012fe <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012c8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8012cd:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8012d0:	89 c2                	mov    %eax,%edx
  8012d2:	c1 ea 16             	shr    $0x16,%edx
  8012d5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012dc:	f6 c2 01             	test   $0x1,%dl
  8012df:	74 1d                	je     8012fe <fd_lookup+0x41>
  8012e1:	89 c2                	mov    %eax,%edx
  8012e3:	c1 ea 0c             	shr    $0xc,%edx
  8012e6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012ed:	f6 c2 01             	test   $0x1,%dl
  8012f0:	74 0c                	je     8012fe <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012f5:	89 02                	mov    %eax,(%edx)
  8012f7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8012fc:	eb 05                	jmp    801303 <fd_lookup+0x46>
  8012fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801303:	5d                   	pop    %ebp
  801304:	c3                   	ret    

00801305 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801305:	55                   	push   %ebp
  801306:	89 e5                	mov    %esp,%ebp
  801308:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80130b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80130e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801312:	8b 45 08             	mov    0x8(%ebp),%eax
  801315:	89 04 24             	mov    %eax,(%esp)
  801318:	e8 a0 ff ff ff       	call   8012bd <fd_lookup>
  80131d:	85 c0                	test   %eax,%eax
  80131f:	78 0e                	js     80132f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801321:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801324:	8b 55 0c             	mov    0xc(%ebp),%edx
  801327:	89 50 04             	mov    %edx,0x4(%eax)
  80132a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80132f:	c9                   	leave  
  801330:	c3                   	ret    

00801331 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801331:	55                   	push   %ebp
  801332:	89 e5                	mov    %esp,%ebp
  801334:	56                   	push   %esi
  801335:	53                   	push   %ebx
  801336:	83 ec 10             	sub    $0x10,%esp
  801339:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80133c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80133f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801344:	b8 04 30 80 00       	mov    $0x803004,%eax
  801349:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80134f:	75 11                	jne    801362 <dev_lookup+0x31>
  801351:	eb 04                	jmp    801357 <dev_lookup+0x26>
  801353:	39 08                	cmp    %ecx,(%eax)
  801355:	75 10                	jne    801367 <dev_lookup+0x36>
			*dev = devtab[i];
  801357:	89 03                	mov    %eax,(%ebx)
  801359:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80135e:	66 90                	xchg   %ax,%ax
  801360:	eb 36                	jmp    801398 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801362:	be c4 27 80 00       	mov    $0x8027c4,%esi
  801367:	83 c2 01             	add    $0x1,%edx
  80136a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80136d:	85 c0                	test   %eax,%eax
  80136f:	75 e2                	jne    801353 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801371:	a1 08 40 80 00       	mov    0x804008,%eax
  801376:	8b 40 48             	mov    0x48(%eax),%eax
  801379:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80137d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801381:	c7 04 24 48 27 80 00 	movl   $0x802748,(%esp)
  801388:	e8 08 ee ff ff       	call   800195 <cprintf>
	*dev = 0;
  80138d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801393:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801398:	83 c4 10             	add    $0x10,%esp
  80139b:	5b                   	pop    %ebx
  80139c:	5e                   	pop    %esi
  80139d:	5d                   	pop    %ebp
  80139e:	c3                   	ret    

0080139f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80139f:	55                   	push   %ebp
  8013a0:	89 e5                	mov    %esp,%ebp
  8013a2:	53                   	push   %ebx
  8013a3:	83 ec 24             	sub    $0x24,%esp
  8013a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013a9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b3:	89 04 24             	mov    %eax,(%esp)
  8013b6:	e8 02 ff ff ff       	call   8012bd <fd_lookup>
  8013bb:	85 c0                	test   %eax,%eax
  8013bd:	78 53                	js     801412 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013c6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013c9:	8b 00                	mov    (%eax),%eax
  8013cb:	89 04 24             	mov    %eax,(%esp)
  8013ce:	e8 5e ff ff ff       	call   801331 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013d3:	85 c0                	test   %eax,%eax
  8013d5:	78 3b                	js     801412 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8013d7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013df:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8013e3:	74 2d                	je     801412 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013e5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013e8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013ef:	00 00 00 
	stat->st_isdir = 0;
  8013f2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013f9:	00 00 00 
	stat->st_dev = dev;
  8013fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ff:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801405:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801409:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80140c:	89 14 24             	mov    %edx,(%esp)
  80140f:	ff 50 14             	call   *0x14(%eax)
}
  801412:	83 c4 24             	add    $0x24,%esp
  801415:	5b                   	pop    %ebx
  801416:	5d                   	pop    %ebp
  801417:	c3                   	ret    

00801418 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801418:	55                   	push   %ebp
  801419:	89 e5                	mov    %esp,%ebp
  80141b:	53                   	push   %ebx
  80141c:	83 ec 24             	sub    $0x24,%esp
  80141f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801422:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801425:	89 44 24 04          	mov    %eax,0x4(%esp)
  801429:	89 1c 24             	mov    %ebx,(%esp)
  80142c:	e8 8c fe ff ff       	call   8012bd <fd_lookup>
  801431:	85 c0                	test   %eax,%eax
  801433:	78 5f                	js     801494 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801435:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801438:	89 44 24 04          	mov    %eax,0x4(%esp)
  80143c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80143f:	8b 00                	mov    (%eax),%eax
  801441:	89 04 24             	mov    %eax,(%esp)
  801444:	e8 e8 fe ff ff       	call   801331 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801449:	85 c0                	test   %eax,%eax
  80144b:	78 47                	js     801494 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80144d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801450:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801454:	75 23                	jne    801479 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801456:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80145b:	8b 40 48             	mov    0x48(%eax),%eax
  80145e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801462:	89 44 24 04          	mov    %eax,0x4(%esp)
  801466:	c7 04 24 68 27 80 00 	movl   $0x802768,(%esp)
  80146d:	e8 23 ed ff ff       	call   800195 <cprintf>
  801472:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801477:	eb 1b                	jmp    801494 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801479:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147c:	8b 48 18             	mov    0x18(%eax),%ecx
  80147f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801484:	85 c9                	test   %ecx,%ecx
  801486:	74 0c                	je     801494 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801488:	8b 45 0c             	mov    0xc(%ebp),%eax
  80148b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80148f:	89 14 24             	mov    %edx,(%esp)
  801492:	ff d1                	call   *%ecx
}
  801494:	83 c4 24             	add    $0x24,%esp
  801497:	5b                   	pop    %ebx
  801498:	5d                   	pop    %ebp
  801499:	c3                   	ret    

0080149a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80149a:	55                   	push   %ebp
  80149b:	89 e5                	mov    %esp,%ebp
  80149d:	53                   	push   %ebx
  80149e:	83 ec 24             	sub    $0x24,%esp
  8014a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014a4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ab:	89 1c 24             	mov    %ebx,(%esp)
  8014ae:	e8 0a fe ff ff       	call   8012bd <fd_lookup>
  8014b3:	85 c0                	test   %eax,%eax
  8014b5:	78 66                	js     80151d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ba:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c1:	8b 00                	mov    (%eax),%eax
  8014c3:	89 04 24             	mov    %eax,(%esp)
  8014c6:	e8 66 fe ff ff       	call   801331 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014cb:	85 c0                	test   %eax,%eax
  8014cd:	78 4e                	js     80151d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014cf:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014d2:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8014d6:	75 23                	jne    8014fb <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014d8:	a1 08 40 80 00       	mov    0x804008,%eax
  8014dd:	8b 40 48             	mov    0x48(%eax),%eax
  8014e0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014e8:	c7 04 24 89 27 80 00 	movl   $0x802789,(%esp)
  8014ef:	e8 a1 ec ff ff       	call   800195 <cprintf>
  8014f4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8014f9:	eb 22                	jmp    80151d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014fe:	8b 48 0c             	mov    0xc(%eax),%ecx
  801501:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801506:	85 c9                	test   %ecx,%ecx
  801508:	74 13                	je     80151d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80150a:	8b 45 10             	mov    0x10(%ebp),%eax
  80150d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801511:	8b 45 0c             	mov    0xc(%ebp),%eax
  801514:	89 44 24 04          	mov    %eax,0x4(%esp)
  801518:	89 14 24             	mov    %edx,(%esp)
  80151b:	ff d1                	call   *%ecx
}
  80151d:	83 c4 24             	add    $0x24,%esp
  801520:	5b                   	pop    %ebx
  801521:	5d                   	pop    %ebp
  801522:	c3                   	ret    

00801523 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801523:	55                   	push   %ebp
  801524:	89 e5                	mov    %esp,%ebp
  801526:	53                   	push   %ebx
  801527:	83 ec 24             	sub    $0x24,%esp
  80152a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80152d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801530:	89 44 24 04          	mov    %eax,0x4(%esp)
  801534:	89 1c 24             	mov    %ebx,(%esp)
  801537:	e8 81 fd ff ff       	call   8012bd <fd_lookup>
  80153c:	85 c0                	test   %eax,%eax
  80153e:	78 6b                	js     8015ab <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801540:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801543:	89 44 24 04          	mov    %eax,0x4(%esp)
  801547:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80154a:	8b 00                	mov    (%eax),%eax
  80154c:	89 04 24             	mov    %eax,(%esp)
  80154f:	e8 dd fd ff ff       	call   801331 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801554:	85 c0                	test   %eax,%eax
  801556:	78 53                	js     8015ab <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801558:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80155b:	8b 42 08             	mov    0x8(%edx),%eax
  80155e:	83 e0 03             	and    $0x3,%eax
  801561:	83 f8 01             	cmp    $0x1,%eax
  801564:	75 23                	jne    801589 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801566:	a1 08 40 80 00       	mov    0x804008,%eax
  80156b:	8b 40 48             	mov    0x48(%eax),%eax
  80156e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801572:	89 44 24 04          	mov    %eax,0x4(%esp)
  801576:	c7 04 24 a6 27 80 00 	movl   $0x8027a6,(%esp)
  80157d:	e8 13 ec ff ff       	call   800195 <cprintf>
  801582:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801587:	eb 22                	jmp    8015ab <read+0x88>
	}
	if (!dev->dev_read)
  801589:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80158c:	8b 48 08             	mov    0x8(%eax),%ecx
  80158f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801594:	85 c9                	test   %ecx,%ecx
  801596:	74 13                	je     8015ab <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801598:	8b 45 10             	mov    0x10(%ebp),%eax
  80159b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80159f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a6:	89 14 24             	mov    %edx,(%esp)
  8015a9:	ff d1                	call   *%ecx
}
  8015ab:	83 c4 24             	add    $0x24,%esp
  8015ae:	5b                   	pop    %ebx
  8015af:	5d                   	pop    %ebp
  8015b0:	c3                   	ret    

008015b1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015b1:	55                   	push   %ebp
  8015b2:	89 e5                	mov    %esp,%ebp
  8015b4:	57                   	push   %edi
  8015b5:	56                   	push   %esi
  8015b6:	53                   	push   %ebx
  8015b7:	83 ec 1c             	sub    $0x1c,%esp
  8015ba:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015bd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8015cf:	85 f6                	test   %esi,%esi
  8015d1:	74 29                	je     8015fc <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015d3:	89 f0                	mov    %esi,%eax
  8015d5:	29 d0                	sub    %edx,%eax
  8015d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015db:	03 55 0c             	add    0xc(%ebp),%edx
  8015de:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015e2:	89 3c 24             	mov    %edi,(%esp)
  8015e5:	e8 39 ff ff ff       	call   801523 <read>
		if (m < 0)
  8015ea:	85 c0                	test   %eax,%eax
  8015ec:	78 0e                	js     8015fc <readn+0x4b>
			return m;
		if (m == 0)
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	74 08                	je     8015fa <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015f2:	01 c3                	add    %eax,%ebx
  8015f4:	89 da                	mov    %ebx,%edx
  8015f6:	39 f3                	cmp    %esi,%ebx
  8015f8:	72 d9                	jb     8015d3 <readn+0x22>
  8015fa:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015fc:	83 c4 1c             	add    $0x1c,%esp
  8015ff:	5b                   	pop    %ebx
  801600:	5e                   	pop    %esi
  801601:	5f                   	pop    %edi
  801602:	5d                   	pop    %ebp
  801603:	c3                   	ret    

00801604 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801604:	55                   	push   %ebp
  801605:	89 e5                	mov    %esp,%ebp
  801607:	83 ec 28             	sub    $0x28,%esp
  80160a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80160d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801610:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801613:	89 34 24             	mov    %esi,(%esp)
  801616:	e8 05 fc ff ff       	call   801220 <fd2num>
  80161b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80161e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801622:	89 04 24             	mov    %eax,(%esp)
  801625:	e8 93 fc ff ff       	call   8012bd <fd_lookup>
  80162a:	89 c3                	mov    %eax,%ebx
  80162c:	85 c0                	test   %eax,%eax
  80162e:	78 05                	js     801635 <fd_close+0x31>
  801630:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801633:	74 0e                	je     801643 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801635:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801639:	b8 00 00 00 00       	mov    $0x0,%eax
  80163e:	0f 44 d8             	cmove  %eax,%ebx
  801641:	eb 3d                	jmp    801680 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801643:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801646:	89 44 24 04          	mov    %eax,0x4(%esp)
  80164a:	8b 06                	mov    (%esi),%eax
  80164c:	89 04 24             	mov    %eax,(%esp)
  80164f:	e8 dd fc ff ff       	call   801331 <dev_lookup>
  801654:	89 c3                	mov    %eax,%ebx
  801656:	85 c0                	test   %eax,%eax
  801658:	78 16                	js     801670 <fd_close+0x6c>
		if (dev->dev_close)
  80165a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165d:	8b 40 10             	mov    0x10(%eax),%eax
  801660:	bb 00 00 00 00       	mov    $0x0,%ebx
  801665:	85 c0                	test   %eax,%eax
  801667:	74 07                	je     801670 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801669:	89 34 24             	mov    %esi,(%esp)
  80166c:	ff d0                	call   *%eax
  80166e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801670:	89 74 24 04          	mov    %esi,0x4(%esp)
  801674:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80167b:	e8 4c f8 ff ff       	call   800ecc <sys_page_unmap>
	return r;
}
  801680:	89 d8                	mov    %ebx,%eax
  801682:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801685:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801688:	89 ec                	mov    %ebp,%esp
  80168a:	5d                   	pop    %ebp
  80168b:	c3                   	ret    

0080168c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801692:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801695:	89 44 24 04          	mov    %eax,0x4(%esp)
  801699:	8b 45 08             	mov    0x8(%ebp),%eax
  80169c:	89 04 24             	mov    %eax,(%esp)
  80169f:	e8 19 fc ff ff       	call   8012bd <fd_lookup>
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	78 13                	js     8016bb <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8016a8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8016af:	00 
  8016b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016b3:	89 04 24             	mov    %eax,(%esp)
  8016b6:	e8 49 ff ff ff       	call   801604 <fd_close>
}
  8016bb:	c9                   	leave  
  8016bc:	c3                   	ret    

008016bd <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8016bd:	55                   	push   %ebp
  8016be:	89 e5                	mov    %esp,%ebp
  8016c0:	83 ec 18             	sub    $0x18,%esp
  8016c3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8016c6:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016d0:	00 
  8016d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d4:	89 04 24             	mov    %eax,(%esp)
  8016d7:	e8 78 03 00 00       	call   801a54 <open>
  8016dc:	89 c3                	mov    %eax,%ebx
  8016de:	85 c0                	test   %eax,%eax
  8016e0:	78 1b                	js     8016fd <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8016e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016e9:	89 1c 24             	mov    %ebx,(%esp)
  8016ec:	e8 ae fc ff ff       	call   80139f <fstat>
  8016f1:	89 c6                	mov    %eax,%esi
	close(fd);
  8016f3:	89 1c 24             	mov    %ebx,(%esp)
  8016f6:	e8 91 ff ff ff       	call   80168c <close>
  8016fb:	89 f3                	mov    %esi,%ebx
	return r;
}
  8016fd:	89 d8                	mov    %ebx,%eax
  8016ff:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801702:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801705:	89 ec                	mov    %ebp,%esp
  801707:	5d                   	pop    %ebp
  801708:	c3                   	ret    

00801709 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801709:	55                   	push   %ebp
  80170a:	89 e5                	mov    %esp,%ebp
  80170c:	53                   	push   %ebx
  80170d:	83 ec 14             	sub    $0x14,%esp
  801710:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801715:	89 1c 24             	mov    %ebx,(%esp)
  801718:	e8 6f ff ff ff       	call   80168c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80171d:	83 c3 01             	add    $0x1,%ebx
  801720:	83 fb 20             	cmp    $0x20,%ebx
  801723:	75 f0                	jne    801715 <close_all+0xc>
		close(i);
}
  801725:	83 c4 14             	add    $0x14,%esp
  801728:	5b                   	pop    %ebx
  801729:	5d                   	pop    %ebp
  80172a:	c3                   	ret    

0080172b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	83 ec 58             	sub    $0x58,%esp
  801731:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801734:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801737:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80173a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80173d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801740:	89 44 24 04          	mov    %eax,0x4(%esp)
  801744:	8b 45 08             	mov    0x8(%ebp),%eax
  801747:	89 04 24             	mov    %eax,(%esp)
  80174a:	e8 6e fb ff ff       	call   8012bd <fd_lookup>
  80174f:	89 c3                	mov    %eax,%ebx
  801751:	85 c0                	test   %eax,%eax
  801753:	0f 88 e0 00 00 00    	js     801839 <dup+0x10e>
		return r;
	close(newfdnum);
  801759:	89 3c 24             	mov    %edi,(%esp)
  80175c:	e8 2b ff ff ff       	call   80168c <close>

	newfd = INDEX2FD(newfdnum);
  801761:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801767:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80176a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80176d:	89 04 24             	mov    %eax,(%esp)
  801770:	e8 bb fa ff ff       	call   801230 <fd2data>
  801775:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801777:	89 34 24             	mov    %esi,(%esp)
  80177a:	e8 b1 fa ff ff       	call   801230 <fd2data>
  80177f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801782:	89 da                	mov    %ebx,%edx
  801784:	89 d8                	mov    %ebx,%eax
  801786:	c1 e8 16             	shr    $0x16,%eax
  801789:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801790:	a8 01                	test   $0x1,%al
  801792:	74 43                	je     8017d7 <dup+0xac>
  801794:	c1 ea 0c             	shr    $0xc,%edx
  801797:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80179e:	a8 01                	test   $0x1,%al
  8017a0:	74 35                	je     8017d7 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8017a2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8017a9:	25 07 0e 00 00       	and    $0xe07,%eax
  8017ae:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017b2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8017b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017b9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017c0:	00 
  8017c1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017cc:	e8 33 f7 ff ff       	call   800f04 <sys_page_map>
  8017d1:	89 c3                	mov    %eax,%ebx
  8017d3:	85 c0                	test   %eax,%eax
  8017d5:	78 3f                	js     801816 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017d7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017da:	89 c2                	mov    %eax,%edx
  8017dc:	c1 ea 0c             	shr    $0xc,%edx
  8017df:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017e6:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8017ec:	89 54 24 10          	mov    %edx,0x10(%esp)
  8017f0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8017f4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017fb:	00 
  8017fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801800:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801807:	e8 f8 f6 ff ff       	call   800f04 <sys_page_map>
  80180c:	89 c3                	mov    %eax,%ebx
  80180e:	85 c0                	test   %eax,%eax
  801810:	78 04                	js     801816 <dup+0xeb>
  801812:	89 fb                	mov    %edi,%ebx
  801814:	eb 23                	jmp    801839 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801816:	89 74 24 04          	mov    %esi,0x4(%esp)
  80181a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801821:	e8 a6 f6 ff ff       	call   800ecc <sys_page_unmap>
	sys_page_unmap(0, nva);
  801826:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801829:	89 44 24 04          	mov    %eax,0x4(%esp)
  80182d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801834:	e8 93 f6 ff ff       	call   800ecc <sys_page_unmap>
	return r;
}
  801839:	89 d8                	mov    %ebx,%eax
  80183b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80183e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801841:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801844:	89 ec                	mov    %ebp,%esp
  801846:	5d                   	pop    %ebp
  801847:	c3                   	ret    

00801848 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801848:	55                   	push   %ebp
  801849:	89 e5                	mov    %esp,%ebp
  80184b:	83 ec 18             	sub    $0x18,%esp
  80184e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801851:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801854:	89 c3                	mov    %eax,%ebx
  801856:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801858:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80185f:	75 11                	jne    801872 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801861:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801868:	e8 63 f8 ff ff       	call   8010d0 <ipc_find_env>
  80186d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801872:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801879:	00 
  80187a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801881:	00 
  801882:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801886:	a1 00 40 80 00       	mov    0x804000,%eax
  80188b:	89 04 24             	mov    %eax,(%esp)
  80188e:	e8 86 f8 ff ff       	call   801119 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801893:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80189a:	00 
  80189b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80189f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8018a6:	e8 d9 f8 ff ff       	call   801184 <ipc_recv>
}
  8018ab:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8018ae:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8018b1:	89 ec                	mov    %ebp,%esp
  8018b3:	5d                   	pop    %ebp
  8018b4:	c3                   	ret    

008018b5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018b5:	55                   	push   %ebp
  8018b6:	89 e5                	mov    %esp,%ebp
  8018b8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018be:	8b 40 0c             	mov    0xc(%eax),%eax
  8018c1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018c9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8018d3:	b8 02 00 00 00       	mov    $0x2,%eax
  8018d8:	e8 6b ff ff ff       	call   801848 <fsipc>
}
  8018dd:	c9                   	leave  
  8018de:	c3                   	ret    

008018df <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018df:	55                   	push   %ebp
  8018e0:	89 e5                	mov    %esp,%ebp
  8018e2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018eb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018f5:	b8 06 00 00 00       	mov    $0x6,%eax
  8018fa:	e8 49 ff ff ff       	call   801848 <fsipc>
}
  8018ff:	c9                   	leave  
  801900:	c3                   	ret    

00801901 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801901:	55                   	push   %ebp
  801902:	89 e5                	mov    %esp,%ebp
  801904:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801907:	ba 00 00 00 00       	mov    $0x0,%edx
  80190c:	b8 08 00 00 00       	mov    $0x8,%eax
  801911:	e8 32 ff ff ff       	call   801848 <fsipc>
}
  801916:	c9                   	leave  
  801917:	c3                   	ret    

00801918 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801918:	55                   	push   %ebp
  801919:	89 e5                	mov    %esp,%ebp
  80191b:	53                   	push   %ebx
  80191c:	83 ec 14             	sub    $0x14,%esp
  80191f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801922:	8b 45 08             	mov    0x8(%ebp),%eax
  801925:	8b 40 0c             	mov    0xc(%eax),%eax
  801928:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80192d:	ba 00 00 00 00       	mov    $0x0,%edx
  801932:	b8 05 00 00 00       	mov    $0x5,%eax
  801937:	e8 0c ff ff ff       	call   801848 <fsipc>
  80193c:	85 c0                	test   %eax,%eax
  80193e:	78 2b                	js     80196b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801940:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801947:	00 
  801948:	89 1c 24             	mov    %ebx,(%esp)
  80194b:	e8 8a ef ff ff       	call   8008da <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801950:	a1 80 50 80 00       	mov    0x805080,%eax
  801955:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80195b:	a1 84 50 80 00       	mov    0x805084,%eax
  801960:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801966:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80196b:	83 c4 14             	add    $0x14,%esp
  80196e:	5b                   	pop    %ebx
  80196f:	5d                   	pop    %ebp
  801970:	c3                   	ret    

00801971 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801971:	55                   	push   %ebp
  801972:	89 e5                	mov    %esp,%ebp
  801974:	83 ec 18             	sub    $0x18,%esp
  801977:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  80197a:	8b 55 08             	mov    0x8(%ebp),%edx
  80197d:	8b 52 0c             	mov    0xc(%edx),%edx
  801980:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  801986:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  80198b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801990:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801995:	0f 47 c2             	cmova  %edx,%eax
  801998:	89 44 24 08          	mov    %eax,0x8(%esp)
  80199c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80199f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a3:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8019aa:	e8 16 f1 ff ff       	call   800ac5 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  8019af:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b4:	b8 04 00 00 00       	mov    $0x4,%eax
  8019b9:	e8 8a fe ff ff       	call   801848 <fsipc>
}
  8019be:	c9                   	leave  
  8019bf:	c3                   	ret    

008019c0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	53                   	push   %ebx
  8019c4:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ca:	8b 40 0c             	mov    0xc(%eax),%eax
  8019cd:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  8019d2:	8b 45 10             	mov    0x10(%ebp),%eax
  8019d5:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019da:	ba 00 00 00 00       	mov    $0x0,%edx
  8019df:	b8 03 00 00 00       	mov    $0x3,%eax
  8019e4:	e8 5f fe ff ff       	call   801848 <fsipc>
  8019e9:	89 c3                	mov    %eax,%ebx
  8019eb:	85 c0                	test   %eax,%eax
  8019ed:	78 17                	js     801a06 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019f3:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8019fa:	00 
  8019fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019fe:	89 04 24             	mov    %eax,(%esp)
  801a01:	e8 bf f0 ff ff       	call   800ac5 <memmove>
  return r;	
}
  801a06:	89 d8                	mov    %ebx,%eax
  801a08:	83 c4 14             	add    $0x14,%esp
  801a0b:	5b                   	pop    %ebx
  801a0c:	5d                   	pop    %ebp
  801a0d:	c3                   	ret    

00801a0e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801a0e:	55                   	push   %ebp
  801a0f:	89 e5                	mov    %esp,%ebp
  801a11:	53                   	push   %ebx
  801a12:	83 ec 14             	sub    $0x14,%esp
  801a15:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801a18:	89 1c 24             	mov    %ebx,(%esp)
  801a1b:	e8 70 ee ff ff       	call   800890 <strlen>
  801a20:	89 c2                	mov    %eax,%edx
  801a22:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801a27:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801a2d:	7f 1f                	jg     801a4e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801a2f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a33:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a3a:	e8 9b ee ff ff       	call   8008da <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801a3f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a44:	b8 07 00 00 00       	mov    $0x7,%eax
  801a49:	e8 fa fd ff ff       	call   801848 <fsipc>
}
  801a4e:	83 c4 14             	add    $0x14,%esp
  801a51:	5b                   	pop    %ebx
  801a52:	5d                   	pop    %ebp
  801a53:	c3                   	ret    

00801a54 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
  801a57:	83 ec 28             	sub    $0x28,%esp
  801a5a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a5d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801a60:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801a63:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a66:	89 04 24             	mov    %eax,(%esp)
  801a69:	e8 dd f7 ff ff       	call   80124b <fd_alloc>
  801a6e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801a70:	85 c0                	test   %eax,%eax
  801a72:	0f 88 89 00 00 00    	js     801b01 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801a78:	89 34 24             	mov    %esi,(%esp)
  801a7b:	e8 10 ee ff ff       	call   800890 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801a80:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801a85:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a8a:	7f 75                	jg     801b01 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  801a8c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a90:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a97:	e8 3e ee ff ff       	call   8008da <strcpy>
  fsipcbuf.open.req_omode = mode;
  801a9c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9f:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  801aa4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801aa7:	b8 01 00 00 00       	mov    $0x1,%eax
  801aac:	e8 97 fd ff ff       	call   801848 <fsipc>
  801ab1:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801ab3:	85 c0                	test   %eax,%eax
  801ab5:	78 0f                	js     801ac6 <open+0x72>
  return fd2num(fd);
  801ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aba:	89 04 24             	mov    %eax,(%esp)
  801abd:	e8 5e f7 ff ff       	call   801220 <fd2num>
  801ac2:	89 c3                	mov    %eax,%ebx
  801ac4:	eb 3b                	jmp    801b01 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801ac6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801acd:	00 
  801ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ad1:	89 04 24             	mov    %eax,(%esp)
  801ad4:	e8 2b fb ff ff       	call   801604 <fd_close>
  801ad9:	85 c0                	test   %eax,%eax
  801adb:	74 24                	je     801b01 <open+0xad>
  801add:	c7 44 24 0c d0 27 80 	movl   $0x8027d0,0xc(%esp)
  801ae4:	00 
  801ae5:	c7 44 24 08 e5 27 80 	movl   $0x8027e5,0x8(%esp)
  801aec:	00 
  801aed:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801af4:	00 
  801af5:	c7 04 24 fa 27 80 00 	movl   $0x8027fa,(%esp)
  801afc:	e8 13 05 00 00       	call   802014 <_panic>
  return r;
}
  801b01:	89 d8                	mov    %ebx,%eax
  801b03:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b06:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b09:	89 ec                	mov    %ebp,%esp
  801b0b:	5d                   	pop    %ebp
  801b0c:	c3                   	ret    
  801b0d:	00 00                	add    %al,(%eax)
	...

00801b10 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b10:	55                   	push   %ebp
  801b11:	89 e5                	mov    %esp,%ebp
  801b13:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801b16:	c7 44 24 04 05 28 80 	movl   $0x802805,0x4(%esp)
  801b1d:	00 
  801b1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b21:	89 04 24             	mov    %eax,(%esp)
  801b24:	e8 b1 ed ff ff       	call   8008da <strcpy>
	return 0;
}
  801b29:	b8 00 00 00 00       	mov    $0x0,%eax
  801b2e:	c9                   	leave  
  801b2f:	c3                   	ret    

00801b30 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801b30:	55                   	push   %ebp
  801b31:	89 e5                	mov    %esp,%ebp
  801b33:	53                   	push   %ebx
  801b34:	83 ec 14             	sub    $0x14,%esp
  801b37:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b3a:	89 1c 24             	mov    %ebx,(%esp)
  801b3d:	e8 2a 05 00 00       	call   80206c <pageref>
  801b42:	89 c2                	mov    %eax,%edx
  801b44:	b8 00 00 00 00       	mov    $0x0,%eax
  801b49:	83 fa 01             	cmp    $0x1,%edx
  801b4c:	75 0b                	jne    801b59 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801b4e:	8b 43 0c             	mov    0xc(%ebx),%eax
  801b51:	89 04 24             	mov    %eax,(%esp)
  801b54:	e8 b9 02 00 00       	call   801e12 <nsipc_close>
	else
		return 0;
}
  801b59:	83 c4 14             	add    $0x14,%esp
  801b5c:	5b                   	pop    %ebx
  801b5d:	5d                   	pop    %ebp
  801b5e:	c3                   	ret    

00801b5f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b5f:	55                   	push   %ebp
  801b60:	89 e5                	mov    %esp,%ebp
  801b62:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b65:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801b6c:	00 
  801b6d:	8b 45 10             	mov    0x10(%ebp),%eax
  801b70:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b74:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b77:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7e:	8b 40 0c             	mov    0xc(%eax),%eax
  801b81:	89 04 24             	mov    %eax,(%esp)
  801b84:	e8 c5 02 00 00       	call   801e4e <nsipc_send>
}
  801b89:	c9                   	leave  
  801b8a:	c3                   	ret    

00801b8b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b91:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801b98:	00 
  801b99:	8b 45 10             	mov    0x10(%ebp),%eax
  801b9c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ba0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba7:	8b 45 08             	mov    0x8(%ebp),%eax
  801baa:	8b 40 0c             	mov    0xc(%eax),%eax
  801bad:	89 04 24             	mov    %eax,(%esp)
  801bb0:	e8 0c 03 00 00       	call   801ec1 <nsipc_recv>
}
  801bb5:	c9                   	leave  
  801bb6:	c3                   	ret    

00801bb7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801bb7:	55                   	push   %ebp
  801bb8:	89 e5                	mov    %esp,%ebp
  801bba:	56                   	push   %esi
  801bbb:	53                   	push   %ebx
  801bbc:	83 ec 20             	sub    $0x20,%esp
  801bbf:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801bc1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bc4:	89 04 24             	mov    %eax,(%esp)
  801bc7:	e8 7f f6 ff ff       	call   80124b <fd_alloc>
  801bcc:	89 c3                	mov    %eax,%ebx
  801bce:	85 c0                	test   %eax,%eax
  801bd0:	78 21                	js     801bf3 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801bd2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801bd9:	00 
  801bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bdd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801be1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801be8:	e8 50 f3 ff ff       	call   800f3d <sys_page_alloc>
  801bed:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801bef:	85 c0                	test   %eax,%eax
  801bf1:	79 0a                	jns    801bfd <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  801bf3:	89 34 24             	mov    %esi,(%esp)
  801bf6:	e8 17 02 00 00       	call   801e12 <nsipc_close>
		return r;
  801bfb:	eb 28                	jmp    801c25 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801bfd:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c06:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c0b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c15:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801c18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c1b:	89 04 24             	mov    %eax,(%esp)
  801c1e:	e8 fd f5 ff ff       	call   801220 <fd2num>
  801c23:	89 c3                	mov    %eax,%ebx
}
  801c25:	89 d8                	mov    %ebx,%eax
  801c27:	83 c4 20             	add    $0x20,%esp
  801c2a:	5b                   	pop    %ebx
  801c2b:	5e                   	pop    %esi
  801c2c:	5d                   	pop    %ebp
  801c2d:	c3                   	ret    

00801c2e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c2e:	55                   	push   %ebp
  801c2f:	89 e5                	mov    %esp,%ebp
  801c31:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c34:	8b 45 10             	mov    0x10(%ebp),%eax
  801c37:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c3e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c42:	8b 45 08             	mov    0x8(%ebp),%eax
  801c45:	89 04 24             	mov    %eax,(%esp)
  801c48:	e8 79 01 00 00       	call   801dc6 <nsipc_socket>
  801c4d:	85 c0                	test   %eax,%eax
  801c4f:	78 05                	js     801c56 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801c51:	e8 61 ff ff ff       	call   801bb7 <alloc_sockfd>
}
  801c56:	c9                   	leave  
  801c57:	c3                   	ret    

00801c58 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801c58:	55                   	push   %ebp
  801c59:	89 e5                	mov    %esp,%ebp
  801c5b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c5e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c61:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c65:	89 04 24             	mov    %eax,(%esp)
  801c68:	e8 50 f6 ff ff       	call   8012bd <fd_lookup>
  801c6d:	85 c0                	test   %eax,%eax
  801c6f:	78 15                	js     801c86 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801c71:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c74:	8b 0a                	mov    (%edx),%ecx
  801c76:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c7b:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  801c81:	75 03                	jne    801c86 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801c83:	8b 42 0c             	mov    0xc(%edx),%eax
}
  801c86:	c9                   	leave  
  801c87:	c3                   	ret    

00801c88 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  801c88:	55                   	push   %ebp
  801c89:	89 e5                	mov    %esp,%ebp
  801c8b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c91:	e8 c2 ff ff ff       	call   801c58 <fd2sockid>
  801c96:	85 c0                	test   %eax,%eax
  801c98:	78 0f                	js     801ca9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c9a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c9d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ca1:	89 04 24             	mov    %eax,(%esp)
  801ca4:	e8 47 01 00 00       	call   801df0 <nsipc_listen>
}
  801ca9:	c9                   	leave  
  801caa:	c3                   	ret    

00801cab <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801cab:	55                   	push   %ebp
  801cac:	89 e5                	mov    %esp,%ebp
  801cae:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cb1:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb4:	e8 9f ff ff ff       	call   801c58 <fd2sockid>
  801cb9:	85 c0                	test   %eax,%eax
  801cbb:	78 16                	js     801cd3 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801cbd:	8b 55 10             	mov    0x10(%ebp),%edx
  801cc0:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cc4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cc7:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ccb:	89 04 24             	mov    %eax,(%esp)
  801cce:	e8 6e 02 00 00       	call   801f41 <nsipc_connect>
}
  801cd3:	c9                   	leave  
  801cd4:	c3                   	ret    

00801cd5 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801cd5:	55                   	push   %ebp
  801cd6:	89 e5                	mov    %esp,%ebp
  801cd8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cdb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cde:	e8 75 ff ff ff       	call   801c58 <fd2sockid>
  801ce3:	85 c0                	test   %eax,%eax
  801ce5:	78 0f                	js     801cf6 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801ce7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cea:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cee:	89 04 24             	mov    %eax,(%esp)
  801cf1:	e8 36 01 00 00       	call   801e2c <nsipc_shutdown>
}
  801cf6:	c9                   	leave  
  801cf7:	c3                   	ret    

00801cf8 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cf8:	55                   	push   %ebp
  801cf9:	89 e5                	mov    %esp,%ebp
  801cfb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cfe:	8b 45 08             	mov    0x8(%ebp),%eax
  801d01:	e8 52 ff ff ff       	call   801c58 <fd2sockid>
  801d06:	85 c0                	test   %eax,%eax
  801d08:	78 16                	js     801d20 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801d0a:	8b 55 10             	mov    0x10(%ebp),%edx
  801d0d:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d11:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d14:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d18:	89 04 24             	mov    %eax,(%esp)
  801d1b:	e8 60 02 00 00       	call   801f80 <nsipc_bind>
}
  801d20:	c9                   	leave  
  801d21:	c3                   	ret    

00801d22 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d22:	55                   	push   %ebp
  801d23:	89 e5                	mov    %esp,%ebp
  801d25:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d28:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2b:	e8 28 ff ff ff       	call   801c58 <fd2sockid>
  801d30:	85 c0                	test   %eax,%eax
  801d32:	78 1f                	js     801d53 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d34:	8b 55 10             	mov    0x10(%ebp),%edx
  801d37:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d3b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d3e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d42:	89 04 24             	mov    %eax,(%esp)
  801d45:	e8 75 02 00 00       	call   801fbf <nsipc_accept>
  801d4a:	85 c0                	test   %eax,%eax
  801d4c:	78 05                	js     801d53 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801d4e:	e8 64 fe ff ff       	call   801bb7 <alloc_sockfd>
}
  801d53:	c9                   	leave  
  801d54:	c3                   	ret    
	...

00801d60 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d60:	55                   	push   %ebp
  801d61:	89 e5                	mov    %esp,%ebp
  801d63:	53                   	push   %ebx
  801d64:	83 ec 14             	sub    $0x14,%esp
  801d67:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d69:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801d70:	75 11                	jne    801d83 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d72:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  801d79:	e8 52 f3 ff ff       	call   8010d0 <ipc_find_env>
  801d7e:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d83:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d8a:	00 
  801d8b:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801d92:	00 
  801d93:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d97:	a1 04 40 80 00       	mov    0x804004,%eax
  801d9c:	89 04 24             	mov    %eax,(%esp)
  801d9f:	e8 75 f3 ff ff       	call   801119 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801da4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801dab:	00 
  801dac:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801db3:	00 
  801db4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dbb:	e8 c4 f3 ff ff       	call   801184 <ipc_recv>
}
  801dc0:	83 c4 14             	add    $0x14,%esp
  801dc3:	5b                   	pop    %ebx
  801dc4:	5d                   	pop    %ebp
  801dc5:	c3                   	ret    

00801dc6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801dc6:	55                   	push   %ebp
  801dc7:	89 e5                	mov    %esp,%ebp
  801dc9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801dcc:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801dd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd7:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801ddc:	8b 45 10             	mov    0x10(%ebp),%eax
  801ddf:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801de4:	b8 09 00 00 00       	mov    $0x9,%eax
  801de9:	e8 72 ff ff ff       	call   801d60 <nsipc>
}
  801dee:	c9                   	leave  
  801def:	c3                   	ret    

00801df0 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  801df0:	55                   	push   %ebp
  801df1:	89 e5                	mov    %esp,%ebp
  801df3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801df6:	8b 45 08             	mov    0x8(%ebp),%eax
  801df9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801dfe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e01:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801e06:	b8 06 00 00 00       	mov    $0x6,%eax
  801e0b:	e8 50 ff ff ff       	call   801d60 <nsipc>
}
  801e10:	c9                   	leave  
  801e11:	c3                   	ret    

00801e12 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  801e12:	55                   	push   %ebp
  801e13:	89 e5                	mov    %esp,%ebp
  801e15:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801e18:	8b 45 08             	mov    0x8(%ebp),%eax
  801e1b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801e20:	b8 04 00 00 00       	mov    $0x4,%eax
  801e25:	e8 36 ff ff ff       	call   801d60 <nsipc>
}
  801e2a:	c9                   	leave  
  801e2b:	c3                   	ret    

00801e2c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  801e2c:	55                   	push   %ebp
  801e2d:	89 e5                	mov    %esp,%ebp
  801e2f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e32:	8b 45 08             	mov    0x8(%ebp),%eax
  801e35:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801e3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e3d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e42:	b8 03 00 00 00       	mov    $0x3,%eax
  801e47:	e8 14 ff ff ff       	call   801d60 <nsipc>
}
  801e4c:	c9                   	leave  
  801e4d:	c3                   	ret    

00801e4e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e4e:	55                   	push   %ebp
  801e4f:	89 e5                	mov    %esp,%ebp
  801e51:	53                   	push   %ebx
  801e52:	83 ec 14             	sub    $0x14,%esp
  801e55:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e58:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e60:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e66:	7e 24                	jle    801e8c <nsipc_send+0x3e>
  801e68:	c7 44 24 0c 11 28 80 	movl   $0x802811,0xc(%esp)
  801e6f:	00 
  801e70:	c7 44 24 08 e5 27 80 	movl   $0x8027e5,0x8(%esp)
  801e77:	00 
  801e78:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  801e7f:	00 
  801e80:	c7 04 24 1d 28 80 00 	movl   $0x80281d,(%esp)
  801e87:	e8 88 01 00 00       	call   802014 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e8c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e90:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e93:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e97:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801e9e:	e8 22 ec ff ff       	call   800ac5 <memmove>
	nsipcbuf.send.req_size = size;
  801ea3:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801ea9:	8b 45 14             	mov    0x14(%ebp),%eax
  801eac:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801eb1:	b8 08 00 00 00       	mov    $0x8,%eax
  801eb6:	e8 a5 fe ff ff       	call   801d60 <nsipc>
}
  801ebb:	83 c4 14             	add    $0x14,%esp
  801ebe:	5b                   	pop    %ebx
  801ebf:	5d                   	pop    %ebp
  801ec0:	c3                   	ret    

00801ec1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801ec1:	55                   	push   %ebp
  801ec2:	89 e5                	mov    %esp,%ebp
  801ec4:	56                   	push   %esi
  801ec5:	53                   	push   %ebx
  801ec6:	83 ec 10             	sub    $0x10,%esp
  801ec9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801ecc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ecf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801ed4:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801eda:	8b 45 14             	mov    0x14(%ebp),%eax
  801edd:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ee2:	b8 07 00 00 00       	mov    $0x7,%eax
  801ee7:	e8 74 fe ff ff       	call   801d60 <nsipc>
  801eec:	89 c3                	mov    %eax,%ebx
  801eee:	85 c0                	test   %eax,%eax
  801ef0:	78 46                	js     801f38 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801ef2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801ef7:	7f 04                	jg     801efd <nsipc_recv+0x3c>
  801ef9:	39 c6                	cmp    %eax,%esi
  801efb:	7d 24                	jge    801f21 <nsipc_recv+0x60>
  801efd:	c7 44 24 0c 29 28 80 	movl   $0x802829,0xc(%esp)
  801f04:	00 
  801f05:	c7 44 24 08 e5 27 80 	movl   $0x8027e5,0x8(%esp)
  801f0c:	00 
  801f0d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801f14:	00 
  801f15:	c7 04 24 1d 28 80 00 	movl   $0x80281d,(%esp)
  801f1c:	e8 f3 00 00 00       	call   802014 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f21:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f25:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801f2c:	00 
  801f2d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f30:	89 04 24             	mov    %eax,(%esp)
  801f33:	e8 8d eb ff ff       	call   800ac5 <memmove>
	}

	return r;
}
  801f38:	89 d8                	mov    %ebx,%eax
  801f3a:	83 c4 10             	add    $0x10,%esp
  801f3d:	5b                   	pop    %ebx
  801f3e:	5e                   	pop    %esi
  801f3f:	5d                   	pop    %ebp
  801f40:	c3                   	ret    

00801f41 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f41:	55                   	push   %ebp
  801f42:	89 e5                	mov    %esp,%ebp
  801f44:	53                   	push   %ebx
  801f45:	83 ec 14             	sub    $0x14,%esp
  801f48:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801f4b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801f53:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f57:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f5a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f5e:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801f65:	e8 5b eb ff ff       	call   800ac5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801f6a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801f70:	b8 05 00 00 00       	mov    $0x5,%eax
  801f75:	e8 e6 fd ff ff       	call   801d60 <nsipc>
}
  801f7a:	83 c4 14             	add    $0x14,%esp
  801f7d:	5b                   	pop    %ebx
  801f7e:	5d                   	pop    %ebp
  801f7f:	c3                   	ret    

00801f80 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f80:	55                   	push   %ebp
  801f81:	89 e5                	mov    %esp,%ebp
  801f83:	53                   	push   %ebx
  801f84:	83 ec 14             	sub    $0x14,%esp
  801f87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f8a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f8d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f92:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f96:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f99:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f9d:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801fa4:	e8 1c eb ff ff       	call   800ac5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801fa9:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801faf:	b8 02 00 00 00       	mov    $0x2,%eax
  801fb4:	e8 a7 fd ff ff       	call   801d60 <nsipc>
}
  801fb9:	83 c4 14             	add    $0x14,%esp
  801fbc:	5b                   	pop    %ebx
  801fbd:	5d                   	pop    %ebp
  801fbe:	c3                   	ret    

00801fbf <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801fbf:	55                   	push   %ebp
  801fc0:	89 e5                	mov    %esp,%ebp
  801fc2:	83 ec 18             	sub    $0x18,%esp
  801fc5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801fc8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  801fcb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fce:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801fd3:	b8 01 00 00 00       	mov    $0x1,%eax
  801fd8:	e8 83 fd ff ff       	call   801d60 <nsipc>
  801fdd:	89 c3                	mov    %eax,%ebx
  801fdf:	85 c0                	test   %eax,%eax
  801fe1:	78 25                	js     802008 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801fe3:	be 10 60 80 00       	mov    $0x806010,%esi
  801fe8:	8b 06                	mov    (%esi),%eax
  801fea:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fee:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801ff5:	00 
  801ff6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ff9:	89 04 24             	mov    %eax,(%esp)
  801ffc:	e8 c4 ea ff ff       	call   800ac5 <memmove>
		*addrlen = ret->ret_addrlen;
  802001:	8b 16                	mov    (%esi),%edx
  802003:	8b 45 10             	mov    0x10(%ebp),%eax
  802006:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  802008:	89 d8                	mov    %ebx,%eax
  80200a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80200d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802010:	89 ec                	mov    %ebp,%esp
  802012:	5d                   	pop    %ebp
  802013:	c3                   	ret    

00802014 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802014:	55                   	push   %ebp
  802015:	89 e5                	mov    %esp,%ebp
  802017:	56                   	push   %esi
  802018:	53                   	push   %ebx
  802019:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80201c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80201f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802025:	e8 bd ef ff ff       	call   800fe7 <sys_getenvid>
  80202a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80202d:	89 54 24 10          	mov    %edx,0x10(%esp)
  802031:	8b 55 08             	mov    0x8(%ebp),%edx
  802034:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802038:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80203c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802040:	c7 04 24 40 28 80 00 	movl   $0x802840,(%esp)
  802047:	e8 49 e1 ff ff       	call   800195 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80204c:	89 74 24 04          	mov    %esi,0x4(%esp)
  802050:	8b 45 10             	mov    0x10(%ebp),%eax
  802053:	89 04 24             	mov    %eax,(%esp)
  802056:	e8 d9 e0 ff ff       	call   800134 <vcprintf>
	cprintf("\n");
  80205b:	c7 04 24 c0 27 80 00 	movl   $0x8027c0,(%esp)
  802062:	e8 2e e1 ff ff       	call   800195 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802067:	cc                   	int3   
  802068:	eb fd                	jmp    802067 <_panic+0x53>
	...

0080206c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80206c:	55                   	push   %ebp
  80206d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  80206f:	8b 45 08             	mov    0x8(%ebp),%eax
  802072:	89 c2                	mov    %eax,%edx
  802074:	c1 ea 16             	shr    $0x16,%edx
  802077:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80207e:	f6 c2 01             	test   $0x1,%dl
  802081:	74 20                	je     8020a3 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  802083:	c1 e8 0c             	shr    $0xc,%eax
  802086:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80208d:	a8 01                	test   $0x1,%al
  80208f:	74 12                	je     8020a3 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802091:	c1 e8 0c             	shr    $0xc,%eax
  802094:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802099:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  80209e:	0f b7 c0             	movzwl %ax,%eax
  8020a1:	eb 05                	jmp    8020a8 <pageref+0x3c>
  8020a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020a8:	5d                   	pop    %ebp
  8020a9:	c3                   	ret    
  8020aa:	00 00                	add    %al,(%eax)
  8020ac:	00 00                	add    %al,(%eax)
	...

008020b0 <__udivdi3>:
  8020b0:	55                   	push   %ebp
  8020b1:	89 e5                	mov    %esp,%ebp
  8020b3:	57                   	push   %edi
  8020b4:	56                   	push   %esi
  8020b5:	83 ec 10             	sub    $0x10,%esp
  8020b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8020bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8020be:	8b 75 10             	mov    0x10(%ebp),%esi
  8020c1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8020c4:	85 c0                	test   %eax,%eax
  8020c6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8020c9:	75 35                	jne    802100 <__udivdi3+0x50>
  8020cb:	39 fe                	cmp    %edi,%esi
  8020cd:	77 61                	ja     802130 <__udivdi3+0x80>
  8020cf:	85 f6                	test   %esi,%esi
  8020d1:	75 0b                	jne    8020de <__udivdi3+0x2e>
  8020d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8020d8:	31 d2                	xor    %edx,%edx
  8020da:	f7 f6                	div    %esi
  8020dc:	89 c6                	mov    %eax,%esi
  8020de:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8020e1:	31 d2                	xor    %edx,%edx
  8020e3:	89 f8                	mov    %edi,%eax
  8020e5:	f7 f6                	div    %esi
  8020e7:	89 c7                	mov    %eax,%edi
  8020e9:	89 c8                	mov    %ecx,%eax
  8020eb:	f7 f6                	div    %esi
  8020ed:	89 c1                	mov    %eax,%ecx
  8020ef:	89 fa                	mov    %edi,%edx
  8020f1:	89 c8                	mov    %ecx,%eax
  8020f3:	83 c4 10             	add    $0x10,%esp
  8020f6:	5e                   	pop    %esi
  8020f7:	5f                   	pop    %edi
  8020f8:	5d                   	pop    %ebp
  8020f9:	c3                   	ret    
  8020fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802100:	39 f8                	cmp    %edi,%eax
  802102:	77 1c                	ja     802120 <__udivdi3+0x70>
  802104:	0f bd d0             	bsr    %eax,%edx
  802107:	83 f2 1f             	xor    $0x1f,%edx
  80210a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80210d:	75 39                	jne    802148 <__udivdi3+0x98>
  80210f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802112:	0f 86 a0 00 00 00    	jbe    8021b8 <__udivdi3+0x108>
  802118:	39 f8                	cmp    %edi,%eax
  80211a:	0f 82 98 00 00 00    	jb     8021b8 <__udivdi3+0x108>
  802120:	31 ff                	xor    %edi,%edi
  802122:	31 c9                	xor    %ecx,%ecx
  802124:	89 c8                	mov    %ecx,%eax
  802126:	89 fa                	mov    %edi,%edx
  802128:	83 c4 10             	add    $0x10,%esp
  80212b:	5e                   	pop    %esi
  80212c:	5f                   	pop    %edi
  80212d:	5d                   	pop    %ebp
  80212e:	c3                   	ret    
  80212f:	90                   	nop
  802130:	89 d1                	mov    %edx,%ecx
  802132:	89 fa                	mov    %edi,%edx
  802134:	89 c8                	mov    %ecx,%eax
  802136:	31 ff                	xor    %edi,%edi
  802138:	f7 f6                	div    %esi
  80213a:	89 c1                	mov    %eax,%ecx
  80213c:	89 fa                	mov    %edi,%edx
  80213e:	89 c8                	mov    %ecx,%eax
  802140:	83 c4 10             	add    $0x10,%esp
  802143:	5e                   	pop    %esi
  802144:	5f                   	pop    %edi
  802145:	5d                   	pop    %ebp
  802146:	c3                   	ret    
  802147:	90                   	nop
  802148:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80214c:	89 f2                	mov    %esi,%edx
  80214e:	d3 e0                	shl    %cl,%eax
  802150:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802153:	b8 20 00 00 00       	mov    $0x20,%eax
  802158:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80215b:	89 c1                	mov    %eax,%ecx
  80215d:	d3 ea                	shr    %cl,%edx
  80215f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802163:	0b 55 ec             	or     -0x14(%ebp),%edx
  802166:	d3 e6                	shl    %cl,%esi
  802168:	89 c1                	mov    %eax,%ecx
  80216a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80216d:	89 fe                	mov    %edi,%esi
  80216f:	d3 ee                	shr    %cl,%esi
  802171:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802175:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802178:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80217b:	d3 e7                	shl    %cl,%edi
  80217d:	89 c1                	mov    %eax,%ecx
  80217f:	d3 ea                	shr    %cl,%edx
  802181:	09 d7                	or     %edx,%edi
  802183:	89 f2                	mov    %esi,%edx
  802185:	89 f8                	mov    %edi,%eax
  802187:	f7 75 ec             	divl   -0x14(%ebp)
  80218a:	89 d6                	mov    %edx,%esi
  80218c:	89 c7                	mov    %eax,%edi
  80218e:	f7 65 e8             	mull   -0x18(%ebp)
  802191:	39 d6                	cmp    %edx,%esi
  802193:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802196:	72 30                	jb     8021c8 <__udivdi3+0x118>
  802198:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80219b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80219f:	d3 e2                	shl    %cl,%edx
  8021a1:	39 c2                	cmp    %eax,%edx
  8021a3:	73 05                	jae    8021aa <__udivdi3+0xfa>
  8021a5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8021a8:	74 1e                	je     8021c8 <__udivdi3+0x118>
  8021aa:	89 f9                	mov    %edi,%ecx
  8021ac:	31 ff                	xor    %edi,%edi
  8021ae:	e9 71 ff ff ff       	jmp    802124 <__udivdi3+0x74>
  8021b3:	90                   	nop
  8021b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b8:	31 ff                	xor    %edi,%edi
  8021ba:	b9 01 00 00 00       	mov    $0x1,%ecx
  8021bf:	e9 60 ff ff ff       	jmp    802124 <__udivdi3+0x74>
  8021c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021c8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8021cb:	31 ff                	xor    %edi,%edi
  8021cd:	89 c8                	mov    %ecx,%eax
  8021cf:	89 fa                	mov    %edi,%edx
  8021d1:	83 c4 10             	add    $0x10,%esp
  8021d4:	5e                   	pop    %esi
  8021d5:	5f                   	pop    %edi
  8021d6:	5d                   	pop    %ebp
  8021d7:	c3                   	ret    
	...

008021e0 <__umoddi3>:
  8021e0:	55                   	push   %ebp
  8021e1:	89 e5                	mov    %esp,%ebp
  8021e3:	57                   	push   %edi
  8021e4:	56                   	push   %esi
  8021e5:	83 ec 20             	sub    $0x20,%esp
  8021e8:	8b 55 14             	mov    0x14(%ebp),%edx
  8021eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021ee:	8b 7d 10             	mov    0x10(%ebp),%edi
  8021f1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021f4:	85 d2                	test   %edx,%edx
  8021f6:	89 c8                	mov    %ecx,%eax
  8021f8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8021fb:	75 13                	jne    802210 <__umoddi3+0x30>
  8021fd:	39 f7                	cmp    %esi,%edi
  8021ff:	76 3f                	jbe    802240 <__umoddi3+0x60>
  802201:	89 f2                	mov    %esi,%edx
  802203:	f7 f7                	div    %edi
  802205:	89 d0                	mov    %edx,%eax
  802207:	31 d2                	xor    %edx,%edx
  802209:	83 c4 20             	add    $0x20,%esp
  80220c:	5e                   	pop    %esi
  80220d:	5f                   	pop    %edi
  80220e:	5d                   	pop    %ebp
  80220f:	c3                   	ret    
  802210:	39 f2                	cmp    %esi,%edx
  802212:	77 4c                	ja     802260 <__umoddi3+0x80>
  802214:	0f bd ca             	bsr    %edx,%ecx
  802217:	83 f1 1f             	xor    $0x1f,%ecx
  80221a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80221d:	75 51                	jne    802270 <__umoddi3+0x90>
  80221f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802222:	0f 87 e0 00 00 00    	ja     802308 <__umoddi3+0x128>
  802228:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80222b:	29 f8                	sub    %edi,%eax
  80222d:	19 d6                	sbb    %edx,%esi
  80222f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802232:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802235:	89 f2                	mov    %esi,%edx
  802237:	83 c4 20             	add    $0x20,%esp
  80223a:	5e                   	pop    %esi
  80223b:	5f                   	pop    %edi
  80223c:	5d                   	pop    %ebp
  80223d:	c3                   	ret    
  80223e:	66 90                	xchg   %ax,%ax
  802240:	85 ff                	test   %edi,%edi
  802242:	75 0b                	jne    80224f <__umoddi3+0x6f>
  802244:	b8 01 00 00 00       	mov    $0x1,%eax
  802249:	31 d2                	xor    %edx,%edx
  80224b:	f7 f7                	div    %edi
  80224d:	89 c7                	mov    %eax,%edi
  80224f:	89 f0                	mov    %esi,%eax
  802251:	31 d2                	xor    %edx,%edx
  802253:	f7 f7                	div    %edi
  802255:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802258:	f7 f7                	div    %edi
  80225a:	eb a9                	jmp    802205 <__umoddi3+0x25>
  80225c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802260:	89 c8                	mov    %ecx,%eax
  802262:	89 f2                	mov    %esi,%edx
  802264:	83 c4 20             	add    $0x20,%esp
  802267:	5e                   	pop    %esi
  802268:	5f                   	pop    %edi
  802269:	5d                   	pop    %ebp
  80226a:	c3                   	ret    
  80226b:	90                   	nop
  80226c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802270:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802274:	d3 e2                	shl    %cl,%edx
  802276:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802279:	ba 20 00 00 00       	mov    $0x20,%edx
  80227e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802281:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802284:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802288:	89 fa                	mov    %edi,%edx
  80228a:	d3 ea                	shr    %cl,%edx
  80228c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802290:	0b 55 f4             	or     -0xc(%ebp),%edx
  802293:	d3 e7                	shl    %cl,%edi
  802295:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802299:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80229c:	89 f2                	mov    %esi,%edx
  80229e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8022a1:	89 c7                	mov    %eax,%edi
  8022a3:	d3 ea                	shr    %cl,%edx
  8022a5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8022a9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8022ac:	89 c2                	mov    %eax,%edx
  8022ae:	d3 e6                	shl    %cl,%esi
  8022b0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8022b4:	d3 ea                	shr    %cl,%edx
  8022b6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8022ba:	09 d6                	or     %edx,%esi
  8022bc:	89 f0                	mov    %esi,%eax
  8022be:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8022c1:	d3 e7                	shl    %cl,%edi
  8022c3:	89 f2                	mov    %esi,%edx
  8022c5:	f7 75 f4             	divl   -0xc(%ebp)
  8022c8:	89 d6                	mov    %edx,%esi
  8022ca:	f7 65 e8             	mull   -0x18(%ebp)
  8022cd:	39 d6                	cmp    %edx,%esi
  8022cf:	72 2b                	jb     8022fc <__umoddi3+0x11c>
  8022d1:	39 c7                	cmp    %eax,%edi
  8022d3:	72 23                	jb     8022f8 <__umoddi3+0x118>
  8022d5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8022d9:	29 c7                	sub    %eax,%edi
  8022db:	19 d6                	sbb    %edx,%esi
  8022dd:	89 f0                	mov    %esi,%eax
  8022df:	89 f2                	mov    %esi,%edx
  8022e1:	d3 ef                	shr    %cl,%edi
  8022e3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8022e7:	d3 e0                	shl    %cl,%eax
  8022e9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8022ed:	09 f8                	or     %edi,%eax
  8022ef:	d3 ea                	shr    %cl,%edx
  8022f1:	83 c4 20             	add    $0x20,%esp
  8022f4:	5e                   	pop    %esi
  8022f5:	5f                   	pop    %edi
  8022f6:	5d                   	pop    %ebp
  8022f7:	c3                   	ret    
  8022f8:	39 d6                	cmp    %edx,%esi
  8022fa:	75 d9                	jne    8022d5 <__umoddi3+0xf5>
  8022fc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8022ff:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802302:	eb d1                	jmp    8022d5 <__umoddi3+0xf5>
  802304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802308:	39 f2                	cmp    %esi,%edx
  80230a:	0f 82 18 ff ff ff    	jb     802228 <__umoddi3+0x48>
  802310:	e9 1d ff ff ff       	jmp    802232 <__umoddi3+0x52>
