
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
  800043:	81 3d 08 40 80 00 7c 	cmpl   $0xeec0007c,0x804008
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
  800065:	e8 15 11 00 00       	call   80117f <ipc_recv>
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
  800083:	a1 c4 00 c0 ee       	mov    0xeec000c4,%eax
  800088:	89 44 24 08          	mov    %eax,0x8(%esp)
  80008c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800090:	c7 04 24 31 23 80 00 	movl   $0x802331,(%esp)
  800097:	e8 f9 00 00 00       	call   800195 <cprintf>
		while (1)
			ipc_send(envs[1].env_id, 0, 0, 0);
  80009c:	bb c4 00 c0 ee       	mov    $0xeec000c4,%ebx
  8000a1:	8b 03                	mov    (%ebx),%eax
  8000a3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000aa:	00 
  8000ab:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000b2:	00 
  8000b3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000ba:	00 
  8000bb:	89 04 24             	mov    %eax,(%esp)
  8000be:	e8 51 10 00 00       	call   801114 <ipc_send>
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
  8000e4:	6b c0 7c             	imul   $0x7c,%eax,%eax
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
  80011e:	e8 d6 15 00 00       	call   8016f9 <close_all>
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
  80027d:	e8 1e 1e 00 00       	call   8020a0 <__udivdi3>
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
  8002d8:	e8 f3 1e 00 00       	call   8021d0 <__umoddi3>
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
  800d2e:	e8 d1 12 00 00       	call   802004 <_panic>

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
  8010e7:	eb 0f                	jmp    8010f8 <ipc_find_env+0x28>
  8010e9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8010ec:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  8010f2:	8b 12                	mov    (%edx),%edx
  8010f4:	39 ca                	cmp    %ecx,%edx
  8010f6:	75 0c                	jne    801104 <ipc_find_env+0x34>
			return envs[i].env_id;
  8010f8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010fb:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  801100:	8b 00                	mov    (%eax),%eax
  801102:	eb 0e                	jmp    801112 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801104:	83 c0 01             	add    $0x1,%eax
  801107:	3d 00 04 00 00       	cmp    $0x400,%eax
  80110c:	75 db                	jne    8010e9 <ipc_find_env+0x19>
  80110e:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801112:	5d                   	pop    %ebp
  801113:	c3                   	ret    

00801114 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	57                   	push   %edi
  801118:	56                   	push   %esi
  801119:	53                   	push   %ebx
  80111a:	83 ec 1c             	sub    $0x1c,%esp
  80111d:	8b 75 08             	mov    0x8(%ebp),%esi
  801120:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801123:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801126:	85 db                	test   %ebx,%ebx
  801128:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80112d:	0f 44 d8             	cmove  %eax,%ebx
  801130:	eb 25                	jmp    801157 <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  801132:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801135:	74 20                	je     801157 <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  801137:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80113b:	c7 44 24 08 0b 27 80 	movl   $0x80270b,0x8(%esp)
  801142:	00 
  801143:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  80114a:	00 
  80114b:	c7 04 24 29 27 80 00 	movl   $0x802729,(%esp)
  801152:	e8 ad 0e 00 00       	call   802004 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  801157:	8b 45 14             	mov    0x14(%ebp),%eax
  80115a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80115e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801162:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801166:	89 34 24             	mov    %esi,(%esp)
  801169:	e8 80 fc ff ff       	call   800dee <sys_ipc_try_send>
  80116e:	85 c0                	test   %eax,%eax
  801170:	75 c0                	jne    801132 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  801172:	e8 fd fd ff ff       	call   800f74 <sys_yield>
}
  801177:	83 c4 1c             	add    $0x1c,%esp
  80117a:	5b                   	pop    %ebx
  80117b:	5e                   	pop    %esi
  80117c:	5f                   	pop    %edi
  80117d:	5d                   	pop    %ebp
  80117e:	c3                   	ret    

0080117f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	83 ec 28             	sub    $0x28,%esp
  801185:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801188:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80118b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80118e:	8b 75 08             	mov    0x8(%ebp),%esi
  801191:	8b 45 0c             	mov    0xc(%ebp),%eax
  801194:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801197:	85 c0                	test   %eax,%eax
  801199:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80119e:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  8011a1:	89 04 24             	mov    %eax,(%esp)
  8011a4:	e8 0c fc ff ff       	call   800db5 <sys_ipc_recv>
  8011a9:	89 c3                	mov    %eax,%ebx
  8011ab:	85 c0                	test   %eax,%eax
  8011ad:	79 2a                	jns    8011d9 <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  8011af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8011b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b7:	c7 04 24 33 27 80 00 	movl   $0x802733,(%esp)
  8011be:	e8 d2 ef ff ff       	call   800195 <cprintf>
		if(from_env_store != NULL)
  8011c3:	85 f6                	test   %esi,%esi
  8011c5:	74 06                	je     8011cd <ipc_recv+0x4e>
			*from_env_store = 0;
  8011c7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  8011cd:	85 ff                	test   %edi,%edi
  8011cf:	74 2c                	je     8011fd <ipc_recv+0x7e>
			*perm_store = 0;
  8011d1:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8011d7:	eb 24                	jmp    8011fd <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  8011d9:	85 f6                	test   %esi,%esi
  8011db:	74 0a                	je     8011e7 <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  8011dd:	a1 08 40 80 00       	mov    0x804008,%eax
  8011e2:	8b 40 74             	mov    0x74(%eax),%eax
  8011e5:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  8011e7:	85 ff                	test   %edi,%edi
  8011e9:	74 0a                	je     8011f5 <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  8011eb:	a1 08 40 80 00       	mov    0x804008,%eax
  8011f0:	8b 40 78             	mov    0x78(%eax),%eax
  8011f3:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8011f5:	a1 08 40 80 00       	mov    0x804008,%eax
  8011fa:	8b 58 70             	mov    0x70(%eax),%ebx
}
  8011fd:	89 d8                	mov    %ebx,%eax
  8011ff:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801202:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801205:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801208:	89 ec                	mov    %ebp,%esp
  80120a:	5d                   	pop    %ebp
  80120b:	c3                   	ret    
  80120c:	00 00                	add    %al,(%eax)
	...

00801210 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801210:	55                   	push   %ebp
  801211:	89 e5                	mov    %esp,%ebp
  801213:	8b 45 08             	mov    0x8(%ebp),%eax
  801216:	05 00 00 00 30       	add    $0x30000000,%eax
  80121b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80121e:	5d                   	pop    %ebp
  80121f:	c3                   	ret    

00801220 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801220:	55                   	push   %ebp
  801221:	89 e5                	mov    %esp,%ebp
  801223:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801226:	8b 45 08             	mov    0x8(%ebp),%eax
  801229:	89 04 24             	mov    %eax,(%esp)
  80122c:	e8 df ff ff ff       	call   801210 <fd2num>
  801231:	05 20 00 0d 00       	add    $0xd0020,%eax
  801236:	c1 e0 0c             	shl    $0xc,%eax
}
  801239:	c9                   	leave  
  80123a:	c3                   	ret    

0080123b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80123b:	55                   	push   %ebp
  80123c:	89 e5                	mov    %esp,%ebp
  80123e:	57                   	push   %edi
  80123f:	56                   	push   %esi
  801240:	53                   	push   %ebx
  801241:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801244:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801249:	a8 01                	test   $0x1,%al
  80124b:	74 36                	je     801283 <fd_alloc+0x48>
  80124d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801252:	a8 01                	test   $0x1,%al
  801254:	74 2d                	je     801283 <fd_alloc+0x48>
  801256:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80125b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801260:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801265:	89 c3                	mov    %eax,%ebx
  801267:	89 c2                	mov    %eax,%edx
  801269:	c1 ea 16             	shr    $0x16,%edx
  80126c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80126f:	f6 c2 01             	test   $0x1,%dl
  801272:	74 14                	je     801288 <fd_alloc+0x4d>
  801274:	89 c2                	mov    %eax,%edx
  801276:	c1 ea 0c             	shr    $0xc,%edx
  801279:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80127c:	f6 c2 01             	test   $0x1,%dl
  80127f:	75 10                	jne    801291 <fd_alloc+0x56>
  801281:	eb 05                	jmp    801288 <fd_alloc+0x4d>
  801283:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801288:	89 1f                	mov    %ebx,(%edi)
  80128a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80128f:	eb 17                	jmp    8012a8 <fd_alloc+0x6d>
  801291:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801296:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80129b:	75 c8                	jne    801265 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80129d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8012a3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8012a8:	5b                   	pop    %ebx
  8012a9:	5e                   	pop    %esi
  8012aa:	5f                   	pop    %edi
  8012ab:	5d                   	pop    %ebp
  8012ac:	c3                   	ret    

008012ad <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012ad:	55                   	push   %ebp
  8012ae:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b3:	83 f8 1f             	cmp    $0x1f,%eax
  8012b6:	77 36                	ja     8012ee <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8012b8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8012bd:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8012c0:	89 c2                	mov    %eax,%edx
  8012c2:	c1 ea 16             	shr    $0x16,%edx
  8012c5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012cc:	f6 c2 01             	test   $0x1,%dl
  8012cf:	74 1d                	je     8012ee <fd_lookup+0x41>
  8012d1:	89 c2                	mov    %eax,%edx
  8012d3:	c1 ea 0c             	shr    $0xc,%edx
  8012d6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012dd:	f6 c2 01             	test   $0x1,%dl
  8012e0:	74 0c                	je     8012ee <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8012e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012e5:	89 02                	mov    %eax,(%edx)
  8012e7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8012ec:	eb 05                	jmp    8012f3 <fd_lookup+0x46>
  8012ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8012f3:	5d                   	pop    %ebp
  8012f4:	c3                   	ret    

008012f5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8012f5:	55                   	push   %ebp
  8012f6:	89 e5                	mov    %esp,%ebp
  8012f8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8012fb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8012fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  801302:	8b 45 08             	mov    0x8(%ebp),%eax
  801305:	89 04 24             	mov    %eax,(%esp)
  801308:	e8 a0 ff ff ff       	call   8012ad <fd_lookup>
  80130d:	85 c0                	test   %eax,%eax
  80130f:	78 0e                	js     80131f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801311:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801314:	8b 55 0c             	mov    0xc(%ebp),%edx
  801317:	89 50 04             	mov    %edx,0x4(%eax)
  80131a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80131f:	c9                   	leave  
  801320:	c3                   	ret    

00801321 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801321:	55                   	push   %ebp
  801322:	89 e5                	mov    %esp,%ebp
  801324:	56                   	push   %esi
  801325:	53                   	push   %ebx
  801326:	83 ec 10             	sub    $0x10,%esp
  801329:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80132c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80132f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801334:	b8 04 30 80 00       	mov    $0x803004,%eax
  801339:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80133f:	75 11                	jne    801352 <dev_lookup+0x31>
  801341:	eb 04                	jmp    801347 <dev_lookup+0x26>
  801343:	39 08                	cmp    %ecx,(%eax)
  801345:	75 10                	jne    801357 <dev_lookup+0x36>
			*dev = devtab[i];
  801347:	89 03                	mov    %eax,(%ebx)
  801349:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80134e:	66 90                	xchg   %ax,%ax
  801350:	eb 36                	jmp    801388 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801352:	be c4 27 80 00       	mov    $0x8027c4,%esi
  801357:	83 c2 01             	add    $0x1,%edx
  80135a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80135d:	85 c0                	test   %eax,%eax
  80135f:	75 e2                	jne    801343 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801361:	a1 08 40 80 00       	mov    0x804008,%eax
  801366:	8b 40 48             	mov    0x48(%eax),%eax
  801369:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80136d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801371:	c7 04 24 48 27 80 00 	movl   $0x802748,(%esp)
  801378:	e8 18 ee ff ff       	call   800195 <cprintf>
	*dev = 0;
  80137d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801383:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801388:	83 c4 10             	add    $0x10,%esp
  80138b:	5b                   	pop    %ebx
  80138c:	5e                   	pop    %esi
  80138d:	5d                   	pop    %ebp
  80138e:	c3                   	ret    

0080138f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	53                   	push   %ebx
  801393:	83 ec 24             	sub    $0x24,%esp
  801396:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801399:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80139c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013a0:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a3:	89 04 24             	mov    %eax,(%esp)
  8013a6:	e8 02 ff ff ff       	call   8012ad <fd_lookup>
  8013ab:	85 c0                	test   %eax,%eax
  8013ad:	78 53                	js     801402 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013b9:	8b 00                	mov    (%eax),%eax
  8013bb:	89 04 24             	mov    %eax,(%esp)
  8013be:	e8 5e ff ff ff       	call   801321 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013c3:	85 c0                	test   %eax,%eax
  8013c5:	78 3b                	js     801402 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8013c7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8013cf:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8013d3:	74 2d                	je     801402 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8013d5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8013d8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8013df:	00 00 00 
	stat->st_isdir = 0;
  8013e2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8013e9:	00 00 00 
	stat->st_dev = dev;
  8013ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013ef:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8013f5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8013f9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013fc:	89 14 24             	mov    %edx,(%esp)
  8013ff:	ff 50 14             	call   *0x14(%eax)
}
  801402:	83 c4 24             	add    $0x24,%esp
  801405:	5b                   	pop    %ebx
  801406:	5d                   	pop    %ebp
  801407:	c3                   	ret    

00801408 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801408:	55                   	push   %ebp
  801409:	89 e5                	mov    %esp,%ebp
  80140b:	53                   	push   %ebx
  80140c:	83 ec 24             	sub    $0x24,%esp
  80140f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801412:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801415:	89 44 24 04          	mov    %eax,0x4(%esp)
  801419:	89 1c 24             	mov    %ebx,(%esp)
  80141c:	e8 8c fe ff ff       	call   8012ad <fd_lookup>
  801421:	85 c0                	test   %eax,%eax
  801423:	78 5f                	js     801484 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801425:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801428:	89 44 24 04          	mov    %eax,0x4(%esp)
  80142c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142f:	8b 00                	mov    (%eax),%eax
  801431:	89 04 24             	mov    %eax,(%esp)
  801434:	e8 e8 fe ff ff       	call   801321 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801439:	85 c0                	test   %eax,%eax
  80143b:	78 47                	js     801484 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80143d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801440:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801444:	75 23                	jne    801469 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801446:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80144b:	8b 40 48             	mov    0x48(%eax),%eax
  80144e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801452:	89 44 24 04          	mov    %eax,0x4(%esp)
  801456:	c7 04 24 68 27 80 00 	movl   $0x802768,(%esp)
  80145d:	e8 33 ed ff ff       	call   800195 <cprintf>
  801462:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801467:	eb 1b                	jmp    801484 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801469:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80146c:	8b 48 18             	mov    0x18(%eax),%ecx
  80146f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801474:	85 c9                	test   %ecx,%ecx
  801476:	74 0c                	je     801484 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801478:	8b 45 0c             	mov    0xc(%ebp),%eax
  80147b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80147f:	89 14 24             	mov    %edx,(%esp)
  801482:	ff d1                	call   *%ecx
}
  801484:	83 c4 24             	add    $0x24,%esp
  801487:	5b                   	pop    %ebx
  801488:	5d                   	pop    %ebp
  801489:	c3                   	ret    

0080148a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80148a:	55                   	push   %ebp
  80148b:	89 e5                	mov    %esp,%ebp
  80148d:	53                   	push   %ebx
  80148e:	83 ec 24             	sub    $0x24,%esp
  801491:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801494:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801497:	89 44 24 04          	mov    %eax,0x4(%esp)
  80149b:	89 1c 24             	mov    %ebx,(%esp)
  80149e:	e8 0a fe ff ff       	call   8012ad <fd_lookup>
  8014a3:	85 c0                	test   %eax,%eax
  8014a5:	78 66                	js     80150d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014aa:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b1:	8b 00                	mov    (%eax),%eax
  8014b3:	89 04 24             	mov    %eax,(%esp)
  8014b6:	e8 66 fe ff ff       	call   801321 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014bb:	85 c0                	test   %eax,%eax
  8014bd:	78 4e                	js     80150d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014bf:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8014c2:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8014c6:	75 23                	jne    8014eb <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8014c8:	a1 08 40 80 00       	mov    0x804008,%eax
  8014cd:	8b 40 48             	mov    0x48(%eax),%eax
  8014d0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8014d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014d8:	c7 04 24 89 27 80 00 	movl   $0x802789,(%esp)
  8014df:	e8 b1 ec ff ff       	call   800195 <cprintf>
  8014e4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8014e9:	eb 22                	jmp    80150d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8014eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014ee:	8b 48 0c             	mov    0xc(%eax),%ecx
  8014f1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014f6:	85 c9                	test   %ecx,%ecx
  8014f8:	74 13                	je     80150d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8014fa:	8b 45 10             	mov    0x10(%ebp),%eax
  8014fd:	89 44 24 08          	mov    %eax,0x8(%esp)
  801501:	8b 45 0c             	mov    0xc(%ebp),%eax
  801504:	89 44 24 04          	mov    %eax,0x4(%esp)
  801508:	89 14 24             	mov    %edx,(%esp)
  80150b:	ff d1                	call   *%ecx
}
  80150d:	83 c4 24             	add    $0x24,%esp
  801510:	5b                   	pop    %ebx
  801511:	5d                   	pop    %ebp
  801512:	c3                   	ret    

00801513 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801513:	55                   	push   %ebp
  801514:	89 e5                	mov    %esp,%ebp
  801516:	53                   	push   %ebx
  801517:	83 ec 24             	sub    $0x24,%esp
  80151a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80151d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801520:	89 44 24 04          	mov    %eax,0x4(%esp)
  801524:	89 1c 24             	mov    %ebx,(%esp)
  801527:	e8 81 fd ff ff       	call   8012ad <fd_lookup>
  80152c:	85 c0                	test   %eax,%eax
  80152e:	78 6b                	js     80159b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801530:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801533:	89 44 24 04          	mov    %eax,0x4(%esp)
  801537:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80153a:	8b 00                	mov    (%eax),%eax
  80153c:	89 04 24             	mov    %eax,(%esp)
  80153f:	e8 dd fd ff ff       	call   801321 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801544:	85 c0                	test   %eax,%eax
  801546:	78 53                	js     80159b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801548:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80154b:	8b 42 08             	mov    0x8(%edx),%eax
  80154e:	83 e0 03             	and    $0x3,%eax
  801551:	83 f8 01             	cmp    $0x1,%eax
  801554:	75 23                	jne    801579 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801556:	a1 08 40 80 00       	mov    0x804008,%eax
  80155b:	8b 40 48             	mov    0x48(%eax),%eax
  80155e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801562:	89 44 24 04          	mov    %eax,0x4(%esp)
  801566:	c7 04 24 a6 27 80 00 	movl   $0x8027a6,(%esp)
  80156d:	e8 23 ec ff ff       	call   800195 <cprintf>
  801572:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801577:	eb 22                	jmp    80159b <read+0x88>
	}
	if (!dev->dev_read)
  801579:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80157c:	8b 48 08             	mov    0x8(%eax),%ecx
  80157f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801584:	85 c9                	test   %ecx,%ecx
  801586:	74 13                	je     80159b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801588:	8b 45 10             	mov    0x10(%ebp),%eax
  80158b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80158f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801592:	89 44 24 04          	mov    %eax,0x4(%esp)
  801596:	89 14 24             	mov    %edx,(%esp)
  801599:	ff d1                	call   *%ecx
}
  80159b:	83 c4 24             	add    $0x24,%esp
  80159e:	5b                   	pop    %ebx
  80159f:	5d                   	pop    %ebp
  8015a0:	c3                   	ret    

008015a1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015a1:	55                   	push   %ebp
  8015a2:	89 e5                	mov    %esp,%ebp
  8015a4:	57                   	push   %edi
  8015a5:	56                   	push   %esi
  8015a6:	53                   	push   %ebx
  8015a7:	83 ec 1c             	sub    $0x1c,%esp
  8015aa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015ad:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015ba:	b8 00 00 00 00       	mov    $0x0,%eax
  8015bf:	85 f6                	test   %esi,%esi
  8015c1:	74 29                	je     8015ec <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8015c3:	89 f0                	mov    %esi,%eax
  8015c5:	29 d0                	sub    %edx,%eax
  8015c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8015cb:	03 55 0c             	add    0xc(%ebp),%edx
  8015ce:	89 54 24 04          	mov    %edx,0x4(%esp)
  8015d2:	89 3c 24             	mov    %edi,(%esp)
  8015d5:	e8 39 ff ff ff       	call   801513 <read>
		if (m < 0)
  8015da:	85 c0                	test   %eax,%eax
  8015dc:	78 0e                	js     8015ec <readn+0x4b>
			return m;
		if (m == 0)
  8015de:	85 c0                	test   %eax,%eax
  8015e0:	74 08                	je     8015ea <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015e2:	01 c3                	add    %eax,%ebx
  8015e4:	89 da                	mov    %ebx,%edx
  8015e6:	39 f3                	cmp    %esi,%ebx
  8015e8:	72 d9                	jb     8015c3 <readn+0x22>
  8015ea:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8015ec:	83 c4 1c             	add    $0x1c,%esp
  8015ef:	5b                   	pop    %ebx
  8015f0:	5e                   	pop    %esi
  8015f1:	5f                   	pop    %edi
  8015f2:	5d                   	pop    %ebp
  8015f3:	c3                   	ret    

008015f4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015f4:	55                   	push   %ebp
  8015f5:	89 e5                	mov    %esp,%ebp
  8015f7:	83 ec 28             	sub    $0x28,%esp
  8015fa:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8015fd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801600:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801603:	89 34 24             	mov    %esi,(%esp)
  801606:	e8 05 fc ff ff       	call   801210 <fd2num>
  80160b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80160e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801612:	89 04 24             	mov    %eax,(%esp)
  801615:	e8 93 fc ff ff       	call   8012ad <fd_lookup>
  80161a:	89 c3                	mov    %eax,%ebx
  80161c:	85 c0                	test   %eax,%eax
  80161e:	78 05                	js     801625 <fd_close+0x31>
  801620:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801623:	74 0e                	je     801633 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801625:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801629:	b8 00 00 00 00       	mov    $0x0,%eax
  80162e:	0f 44 d8             	cmove  %eax,%ebx
  801631:	eb 3d                	jmp    801670 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801633:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801636:	89 44 24 04          	mov    %eax,0x4(%esp)
  80163a:	8b 06                	mov    (%esi),%eax
  80163c:	89 04 24             	mov    %eax,(%esp)
  80163f:	e8 dd fc ff ff       	call   801321 <dev_lookup>
  801644:	89 c3                	mov    %eax,%ebx
  801646:	85 c0                	test   %eax,%eax
  801648:	78 16                	js     801660 <fd_close+0x6c>
		if (dev->dev_close)
  80164a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80164d:	8b 40 10             	mov    0x10(%eax),%eax
  801650:	bb 00 00 00 00       	mov    $0x0,%ebx
  801655:	85 c0                	test   %eax,%eax
  801657:	74 07                	je     801660 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801659:	89 34 24             	mov    %esi,(%esp)
  80165c:	ff d0                	call   *%eax
  80165e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801660:	89 74 24 04          	mov    %esi,0x4(%esp)
  801664:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80166b:	e8 5c f8 ff ff       	call   800ecc <sys_page_unmap>
	return r;
}
  801670:	89 d8                	mov    %ebx,%eax
  801672:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801675:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801678:	89 ec                	mov    %ebp,%esp
  80167a:	5d                   	pop    %ebp
  80167b:	c3                   	ret    

0080167c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801682:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801685:	89 44 24 04          	mov    %eax,0x4(%esp)
  801689:	8b 45 08             	mov    0x8(%ebp),%eax
  80168c:	89 04 24             	mov    %eax,(%esp)
  80168f:	e8 19 fc ff ff       	call   8012ad <fd_lookup>
  801694:	85 c0                	test   %eax,%eax
  801696:	78 13                	js     8016ab <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801698:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80169f:	00 
  8016a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a3:	89 04 24             	mov    %eax,(%esp)
  8016a6:	e8 49 ff ff ff       	call   8015f4 <fd_close>
}
  8016ab:	c9                   	leave  
  8016ac:	c3                   	ret    

008016ad <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	83 ec 18             	sub    $0x18,%esp
  8016b3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8016b6:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016b9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8016c0:	00 
  8016c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c4:	89 04 24             	mov    %eax,(%esp)
  8016c7:	e8 78 03 00 00       	call   801a44 <open>
  8016cc:	89 c3                	mov    %eax,%ebx
  8016ce:	85 c0                	test   %eax,%eax
  8016d0:	78 1b                	js     8016ed <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8016d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016d9:	89 1c 24             	mov    %ebx,(%esp)
  8016dc:	e8 ae fc ff ff       	call   80138f <fstat>
  8016e1:	89 c6                	mov    %eax,%esi
	close(fd);
  8016e3:	89 1c 24             	mov    %ebx,(%esp)
  8016e6:	e8 91 ff ff ff       	call   80167c <close>
  8016eb:	89 f3                	mov    %esi,%ebx
	return r;
}
  8016ed:	89 d8                	mov    %ebx,%eax
  8016ef:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8016f2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8016f5:	89 ec                	mov    %ebp,%esp
  8016f7:	5d                   	pop    %ebp
  8016f8:	c3                   	ret    

008016f9 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8016f9:	55                   	push   %ebp
  8016fa:	89 e5                	mov    %esp,%ebp
  8016fc:	53                   	push   %ebx
  8016fd:	83 ec 14             	sub    $0x14,%esp
  801700:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801705:	89 1c 24             	mov    %ebx,(%esp)
  801708:	e8 6f ff ff ff       	call   80167c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80170d:	83 c3 01             	add    $0x1,%ebx
  801710:	83 fb 20             	cmp    $0x20,%ebx
  801713:	75 f0                	jne    801705 <close_all+0xc>
		close(i);
}
  801715:	83 c4 14             	add    $0x14,%esp
  801718:	5b                   	pop    %ebx
  801719:	5d                   	pop    %ebp
  80171a:	c3                   	ret    

0080171b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80171b:	55                   	push   %ebp
  80171c:	89 e5                	mov    %esp,%ebp
  80171e:	83 ec 58             	sub    $0x58,%esp
  801721:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801724:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801727:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80172a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80172d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801730:	89 44 24 04          	mov    %eax,0x4(%esp)
  801734:	8b 45 08             	mov    0x8(%ebp),%eax
  801737:	89 04 24             	mov    %eax,(%esp)
  80173a:	e8 6e fb ff ff       	call   8012ad <fd_lookup>
  80173f:	89 c3                	mov    %eax,%ebx
  801741:	85 c0                	test   %eax,%eax
  801743:	0f 88 e0 00 00 00    	js     801829 <dup+0x10e>
		return r;
	close(newfdnum);
  801749:	89 3c 24             	mov    %edi,(%esp)
  80174c:	e8 2b ff ff ff       	call   80167c <close>

	newfd = INDEX2FD(newfdnum);
  801751:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801757:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80175a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80175d:	89 04 24             	mov    %eax,(%esp)
  801760:	e8 bb fa ff ff       	call   801220 <fd2data>
  801765:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801767:	89 34 24             	mov    %esi,(%esp)
  80176a:	e8 b1 fa ff ff       	call   801220 <fd2data>
  80176f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801772:	89 da                	mov    %ebx,%edx
  801774:	89 d8                	mov    %ebx,%eax
  801776:	c1 e8 16             	shr    $0x16,%eax
  801779:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801780:	a8 01                	test   $0x1,%al
  801782:	74 43                	je     8017c7 <dup+0xac>
  801784:	c1 ea 0c             	shr    $0xc,%edx
  801787:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80178e:	a8 01                	test   $0x1,%al
  801790:	74 35                	je     8017c7 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801792:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801799:	25 07 0e 00 00       	and    $0xe07,%eax
  80179e:	89 44 24 10          	mov    %eax,0x10(%esp)
  8017a2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8017a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8017a9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017b0:	00 
  8017b1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8017b5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017bc:	e8 43 f7 ff ff       	call   800f04 <sys_page_map>
  8017c1:	89 c3                	mov    %eax,%ebx
  8017c3:	85 c0                	test   %eax,%eax
  8017c5:	78 3f                	js     801806 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8017c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8017ca:	89 c2                	mov    %eax,%edx
  8017cc:	c1 ea 0c             	shr    $0xc,%edx
  8017cf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017d6:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8017dc:	89 54 24 10          	mov    %edx,0x10(%esp)
  8017e0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8017e4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017eb:	00 
  8017ec:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017f7:	e8 08 f7 ff ff       	call   800f04 <sys_page_map>
  8017fc:	89 c3                	mov    %eax,%ebx
  8017fe:	85 c0                	test   %eax,%eax
  801800:	78 04                	js     801806 <dup+0xeb>
  801802:	89 fb                	mov    %edi,%ebx
  801804:	eb 23                	jmp    801829 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801806:	89 74 24 04          	mov    %esi,0x4(%esp)
  80180a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801811:	e8 b6 f6 ff ff       	call   800ecc <sys_page_unmap>
	sys_page_unmap(0, nva);
  801816:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801819:	89 44 24 04          	mov    %eax,0x4(%esp)
  80181d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801824:	e8 a3 f6 ff ff       	call   800ecc <sys_page_unmap>
	return r;
}
  801829:	89 d8                	mov    %ebx,%eax
  80182b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80182e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801831:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801834:	89 ec                	mov    %ebp,%esp
  801836:	5d                   	pop    %ebp
  801837:	c3                   	ret    

00801838 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801838:	55                   	push   %ebp
  801839:	89 e5                	mov    %esp,%ebp
  80183b:	83 ec 18             	sub    $0x18,%esp
  80183e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801841:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801844:	89 c3                	mov    %eax,%ebx
  801846:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801848:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80184f:	75 11                	jne    801862 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801851:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801858:	e8 73 f8 ff ff       	call   8010d0 <ipc_find_env>
  80185d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801862:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801869:	00 
  80186a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801871:	00 
  801872:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801876:	a1 00 40 80 00       	mov    0x804000,%eax
  80187b:	89 04 24             	mov    %eax,(%esp)
  80187e:	e8 91 f8 ff ff       	call   801114 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801883:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80188a:	00 
  80188b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80188f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801896:	e8 e4 f8 ff ff       	call   80117f <ipc_recv>
}
  80189b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80189e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8018a1:	89 ec                	mov    %ebp,%esp
  8018a3:	5d                   	pop    %ebp
  8018a4:	c3                   	ret    

008018a5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018a5:	55                   	push   %ebp
  8018a6:	89 e5                	mov    %esp,%ebp
  8018a8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018b9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018be:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c3:	b8 02 00 00 00       	mov    $0x2,%eax
  8018c8:	e8 6b ff ff ff       	call   801838 <fsipc>
}
  8018cd:	c9                   	leave  
  8018ce:	c3                   	ret    

008018cf <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018cf:	55                   	push   %ebp
  8018d0:	89 e5                	mov    %esp,%ebp
  8018d2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d8:	8b 40 0c             	mov    0xc(%eax),%eax
  8018db:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018e0:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e5:	b8 06 00 00 00       	mov    $0x6,%eax
  8018ea:	e8 49 ff ff ff       	call   801838 <fsipc>
}
  8018ef:	c9                   	leave  
  8018f0:	c3                   	ret    

008018f1 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  8018f1:	55                   	push   %ebp
  8018f2:	89 e5                	mov    %esp,%ebp
  8018f4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8018f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018fc:	b8 08 00 00 00       	mov    $0x8,%eax
  801901:	e8 32 ff ff ff       	call   801838 <fsipc>
}
  801906:	c9                   	leave  
  801907:	c3                   	ret    

00801908 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801908:	55                   	push   %ebp
  801909:	89 e5                	mov    %esp,%ebp
  80190b:	53                   	push   %ebx
  80190c:	83 ec 14             	sub    $0x14,%esp
  80190f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801912:	8b 45 08             	mov    0x8(%ebp),%eax
  801915:	8b 40 0c             	mov    0xc(%eax),%eax
  801918:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80191d:	ba 00 00 00 00       	mov    $0x0,%edx
  801922:	b8 05 00 00 00       	mov    $0x5,%eax
  801927:	e8 0c ff ff ff       	call   801838 <fsipc>
  80192c:	85 c0                	test   %eax,%eax
  80192e:	78 2b                	js     80195b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801930:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801937:	00 
  801938:	89 1c 24             	mov    %ebx,(%esp)
  80193b:	e8 9a ef ff ff       	call   8008da <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801940:	a1 80 50 80 00       	mov    0x805080,%eax
  801945:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80194b:	a1 84 50 80 00       	mov    0x805084,%eax
  801950:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801956:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80195b:	83 c4 14             	add    $0x14,%esp
  80195e:	5b                   	pop    %ebx
  80195f:	5d                   	pop    %ebp
  801960:	c3                   	ret    

00801961 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801961:	55                   	push   %ebp
  801962:	89 e5                	mov    %esp,%ebp
  801964:	83 ec 18             	sub    $0x18,%esp
  801967:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  80196a:	8b 55 08             	mov    0x8(%ebp),%edx
  80196d:	8b 52 0c             	mov    0xc(%edx),%edx
  801970:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  801976:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  80197b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801980:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801985:	0f 47 c2             	cmova  %edx,%eax
  801988:	89 44 24 08          	mov    %eax,0x8(%esp)
  80198c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80198f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801993:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  80199a:	e8 26 f1 ff ff       	call   800ac5 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  80199f:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a4:	b8 04 00 00 00       	mov    $0x4,%eax
  8019a9:	e8 8a fe ff ff       	call   801838 <fsipc>
}
  8019ae:	c9                   	leave  
  8019af:	c3                   	ret    

008019b0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	53                   	push   %ebx
  8019b4:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ba:	8b 40 0c             	mov    0xc(%eax),%eax
  8019bd:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  8019c2:	8b 45 10             	mov    0x10(%ebp),%eax
  8019c5:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8019cf:	b8 03 00 00 00       	mov    $0x3,%eax
  8019d4:	e8 5f fe ff ff       	call   801838 <fsipc>
  8019d9:	89 c3                	mov    %eax,%ebx
  8019db:	85 c0                	test   %eax,%eax
  8019dd:	78 17                	js     8019f6 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019e3:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8019ea:	00 
  8019eb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ee:	89 04 24             	mov    %eax,(%esp)
  8019f1:	e8 cf f0 ff ff       	call   800ac5 <memmove>
  return r;	
}
  8019f6:	89 d8                	mov    %ebx,%eax
  8019f8:	83 c4 14             	add    $0x14,%esp
  8019fb:	5b                   	pop    %ebx
  8019fc:	5d                   	pop    %ebp
  8019fd:	c3                   	ret    

008019fe <remove>:
}

// Delete a file
int
remove(const char *path)
{
  8019fe:	55                   	push   %ebp
  8019ff:	89 e5                	mov    %esp,%ebp
  801a01:	53                   	push   %ebx
  801a02:	83 ec 14             	sub    $0x14,%esp
  801a05:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801a08:	89 1c 24             	mov    %ebx,(%esp)
  801a0b:	e8 80 ee ff ff       	call   800890 <strlen>
  801a10:	89 c2                	mov    %eax,%edx
  801a12:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801a17:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801a1d:	7f 1f                	jg     801a3e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801a1f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801a23:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a2a:	e8 ab ee ff ff       	call   8008da <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801a2f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a34:	b8 07 00 00 00       	mov    $0x7,%eax
  801a39:	e8 fa fd ff ff       	call   801838 <fsipc>
}
  801a3e:	83 c4 14             	add    $0x14,%esp
  801a41:	5b                   	pop    %ebx
  801a42:	5d                   	pop    %ebp
  801a43:	c3                   	ret    

00801a44 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801a44:	55                   	push   %ebp
  801a45:	89 e5                	mov    %esp,%ebp
  801a47:	83 ec 28             	sub    $0x28,%esp
  801a4a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801a4d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801a50:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801a53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a56:	89 04 24             	mov    %eax,(%esp)
  801a59:	e8 dd f7 ff ff       	call   80123b <fd_alloc>
  801a5e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801a60:	85 c0                	test   %eax,%eax
  801a62:	0f 88 89 00 00 00    	js     801af1 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801a68:	89 34 24             	mov    %esi,(%esp)
  801a6b:	e8 20 ee ff ff       	call   800890 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801a70:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801a75:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a7a:	7f 75                	jg     801af1 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  801a7c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801a80:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801a87:	e8 4e ee ff ff       	call   8008da <strcpy>
  fsipcbuf.open.req_omode = mode;
  801a8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a8f:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  801a94:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a97:	b8 01 00 00 00       	mov    $0x1,%eax
  801a9c:	e8 97 fd ff ff       	call   801838 <fsipc>
  801aa1:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801aa3:	85 c0                	test   %eax,%eax
  801aa5:	78 0f                	js     801ab6 <open+0x72>
  return fd2num(fd);
  801aa7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aaa:	89 04 24             	mov    %eax,(%esp)
  801aad:	e8 5e f7 ff ff       	call   801210 <fd2num>
  801ab2:	89 c3                	mov    %eax,%ebx
  801ab4:	eb 3b                	jmp    801af1 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801ab6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801abd:	00 
  801abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac1:	89 04 24             	mov    %eax,(%esp)
  801ac4:	e8 2b fb ff ff       	call   8015f4 <fd_close>
  801ac9:	85 c0                	test   %eax,%eax
  801acb:	74 24                	je     801af1 <open+0xad>
  801acd:	c7 44 24 0c d0 27 80 	movl   $0x8027d0,0xc(%esp)
  801ad4:	00 
  801ad5:	c7 44 24 08 e5 27 80 	movl   $0x8027e5,0x8(%esp)
  801adc:	00 
  801add:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801ae4:	00 
  801ae5:	c7 04 24 fa 27 80 00 	movl   $0x8027fa,(%esp)
  801aec:	e8 13 05 00 00       	call   802004 <_panic>
  return r;
}
  801af1:	89 d8                	mov    %ebx,%eax
  801af3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801af6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801af9:	89 ec                	mov    %ebp,%esp
  801afb:	5d                   	pop    %ebp
  801afc:	c3                   	ret    
  801afd:	00 00                	add    %al,(%eax)
	...

00801b00 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b00:	55                   	push   %ebp
  801b01:	89 e5                	mov    %esp,%ebp
  801b03:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801b06:	c7 44 24 04 05 28 80 	movl   $0x802805,0x4(%esp)
  801b0d:	00 
  801b0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b11:	89 04 24             	mov    %eax,(%esp)
  801b14:	e8 c1 ed ff ff       	call   8008da <strcpy>
	return 0;
}
  801b19:	b8 00 00 00 00       	mov    $0x0,%eax
  801b1e:	c9                   	leave  
  801b1f:	c3                   	ret    

00801b20 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	53                   	push   %ebx
  801b24:	83 ec 14             	sub    $0x14,%esp
  801b27:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801b2a:	89 1c 24             	mov    %ebx,(%esp)
  801b2d:	e8 2a 05 00 00       	call   80205c <pageref>
  801b32:	89 c2                	mov    %eax,%edx
  801b34:	b8 00 00 00 00       	mov    $0x0,%eax
  801b39:	83 fa 01             	cmp    $0x1,%edx
  801b3c:	75 0b                	jne    801b49 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801b3e:	8b 43 0c             	mov    0xc(%ebx),%eax
  801b41:	89 04 24             	mov    %eax,(%esp)
  801b44:	e8 b9 02 00 00       	call   801e02 <nsipc_close>
	else
		return 0;
}
  801b49:	83 c4 14             	add    $0x14,%esp
  801b4c:	5b                   	pop    %ebx
  801b4d:	5d                   	pop    %ebp
  801b4e:	c3                   	ret    

00801b4f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801b4f:	55                   	push   %ebp
  801b50:	89 e5                	mov    %esp,%ebp
  801b52:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801b55:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801b5c:	00 
  801b5d:	8b 45 10             	mov    0x10(%ebp),%eax
  801b60:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b64:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b67:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b6e:	8b 40 0c             	mov    0xc(%eax),%eax
  801b71:	89 04 24             	mov    %eax,(%esp)
  801b74:	e8 c5 02 00 00       	call   801e3e <nsipc_send>
}
  801b79:	c9                   	leave  
  801b7a:	c3                   	ret    

00801b7b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801b7b:	55                   	push   %ebp
  801b7c:	89 e5                	mov    %esp,%ebp
  801b7e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801b81:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801b88:	00 
  801b89:	8b 45 10             	mov    0x10(%ebp),%eax
  801b8c:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b90:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b93:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b97:	8b 45 08             	mov    0x8(%ebp),%eax
  801b9a:	8b 40 0c             	mov    0xc(%eax),%eax
  801b9d:	89 04 24             	mov    %eax,(%esp)
  801ba0:	e8 0c 03 00 00       	call   801eb1 <nsipc_recv>
}
  801ba5:	c9                   	leave  
  801ba6:	c3                   	ret    

00801ba7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801ba7:	55                   	push   %ebp
  801ba8:	89 e5                	mov    %esp,%ebp
  801baa:	56                   	push   %esi
  801bab:	53                   	push   %ebx
  801bac:	83 ec 20             	sub    $0x20,%esp
  801baf:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801bb1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb4:	89 04 24             	mov    %eax,(%esp)
  801bb7:	e8 7f f6 ff ff       	call   80123b <fd_alloc>
  801bbc:	89 c3                	mov    %eax,%ebx
  801bbe:	85 c0                	test   %eax,%eax
  801bc0:	78 21                	js     801be3 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801bc2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801bc9:	00 
  801bca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bcd:	89 44 24 04          	mov    %eax,0x4(%esp)
  801bd1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801bd8:	e8 60 f3 ff ff       	call   800f3d <sys_page_alloc>
  801bdd:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801bdf:	85 c0                	test   %eax,%eax
  801be1:	79 0a                	jns    801bed <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  801be3:	89 34 24             	mov    %esi,(%esp)
  801be6:	e8 17 02 00 00       	call   801e02 <nsipc_close>
		return r;
  801beb:	eb 28                	jmp    801c15 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801bed:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801bf3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bf6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801bf8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bfb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801c02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c05:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c0b:	89 04 24             	mov    %eax,(%esp)
  801c0e:	e8 fd f5 ff ff       	call   801210 <fd2num>
  801c13:	89 c3                	mov    %eax,%ebx
}
  801c15:	89 d8                	mov    %ebx,%eax
  801c17:	83 c4 20             	add    $0x20,%esp
  801c1a:	5b                   	pop    %ebx
  801c1b:	5e                   	pop    %esi
  801c1c:	5d                   	pop    %ebp
  801c1d:	c3                   	ret    

00801c1e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801c1e:	55                   	push   %ebp
  801c1f:	89 e5                	mov    %esp,%ebp
  801c21:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801c24:	8b 45 10             	mov    0x10(%ebp),%eax
  801c27:	89 44 24 08          	mov    %eax,0x8(%esp)
  801c2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c2e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c32:	8b 45 08             	mov    0x8(%ebp),%eax
  801c35:	89 04 24             	mov    %eax,(%esp)
  801c38:	e8 79 01 00 00       	call   801db6 <nsipc_socket>
  801c3d:	85 c0                	test   %eax,%eax
  801c3f:	78 05                	js     801c46 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801c41:	e8 61 ff ff ff       	call   801ba7 <alloc_sockfd>
}
  801c46:	c9                   	leave  
  801c47:	c3                   	ret    

00801c48 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801c48:	55                   	push   %ebp
  801c49:	89 e5                	mov    %esp,%ebp
  801c4b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c4e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c51:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c55:	89 04 24             	mov    %eax,(%esp)
  801c58:	e8 50 f6 ff ff       	call   8012ad <fd_lookup>
  801c5d:	85 c0                	test   %eax,%eax
  801c5f:	78 15                	js     801c76 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801c61:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c64:	8b 0a                	mov    (%edx),%ecx
  801c66:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c6b:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  801c71:	75 03                	jne    801c76 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801c73:	8b 42 0c             	mov    0xc(%edx),%eax
}
  801c76:	c9                   	leave  
  801c77:	c3                   	ret    

00801c78 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  801c78:	55                   	push   %ebp
  801c79:	89 e5                	mov    %esp,%ebp
  801c7b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c7e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c81:	e8 c2 ff ff ff       	call   801c48 <fd2sockid>
  801c86:	85 c0                	test   %eax,%eax
  801c88:	78 0f                	js     801c99 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801c8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c8d:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c91:	89 04 24             	mov    %eax,(%esp)
  801c94:	e8 47 01 00 00       	call   801de0 <nsipc_listen>
}
  801c99:	c9                   	leave  
  801c9a:	c3                   	ret    

00801c9b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801c9b:	55                   	push   %ebp
  801c9c:	89 e5                	mov    %esp,%ebp
  801c9e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ca1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca4:	e8 9f ff ff ff       	call   801c48 <fd2sockid>
  801ca9:	85 c0                	test   %eax,%eax
  801cab:	78 16                	js     801cc3 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801cad:	8b 55 10             	mov    0x10(%ebp),%edx
  801cb0:	89 54 24 08          	mov    %edx,0x8(%esp)
  801cb4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cb7:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cbb:	89 04 24             	mov    %eax,(%esp)
  801cbe:	e8 6e 02 00 00       	call   801f31 <nsipc_connect>
}
  801cc3:	c9                   	leave  
  801cc4:	c3                   	ret    

00801cc5 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801cc5:	55                   	push   %ebp
  801cc6:	89 e5                	mov    %esp,%ebp
  801cc8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cce:	e8 75 ff ff ff       	call   801c48 <fd2sockid>
  801cd3:	85 c0                	test   %eax,%eax
  801cd5:	78 0f                	js     801ce6 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801cd7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801cda:	89 54 24 04          	mov    %edx,0x4(%esp)
  801cde:	89 04 24             	mov    %eax,(%esp)
  801ce1:	e8 36 01 00 00       	call   801e1c <nsipc_shutdown>
}
  801ce6:	c9                   	leave  
  801ce7:	c3                   	ret    

00801ce8 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ce8:	55                   	push   %ebp
  801ce9:	89 e5                	mov    %esp,%ebp
  801ceb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cee:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf1:	e8 52 ff ff ff       	call   801c48 <fd2sockid>
  801cf6:	85 c0                	test   %eax,%eax
  801cf8:	78 16                	js     801d10 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801cfa:	8b 55 10             	mov    0x10(%ebp),%edx
  801cfd:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d01:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d04:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d08:	89 04 24             	mov    %eax,(%esp)
  801d0b:	e8 60 02 00 00       	call   801f70 <nsipc_bind>
}
  801d10:	c9                   	leave  
  801d11:	c3                   	ret    

00801d12 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801d12:	55                   	push   %ebp
  801d13:	89 e5                	mov    %esp,%ebp
  801d15:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d18:	8b 45 08             	mov    0x8(%ebp),%eax
  801d1b:	e8 28 ff ff ff       	call   801c48 <fd2sockid>
  801d20:	85 c0                	test   %eax,%eax
  801d22:	78 1f                	js     801d43 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d24:	8b 55 10             	mov    0x10(%ebp),%edx
  801d27:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d2b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801d2e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d32:	89 04 24             	mov    %eax,(%esp)
  801d35:	e8 75 02 00 00       	call   801faf <nsipc_accept>
  801d3a:	85 c0                	test   %eax,%eax
  801d3c:	78 05                	js     801d43 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801d3e:	e8 64 fe ff ff       	call   801ba7 <alloc_sockfd>
}
  801d43:	c9                   	leave  
  801d44:	c3                   	ret    
	...

00801d50 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
  801d53:	53                   	push   %ebx
  801d54:	83 ec 14             	sub    $0x14,%esp
  801d57:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801d59:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801d60:	75 11                	jne    801d73 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801d62:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  801d69:	e8 62 f3 ff ff       	call   8010d0 <ipc_find_env>
  801d6e:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801d73:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d7a:	00 
  801d7b:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801d82:	00 
  801d83:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d87:	a1 04 40 80 00       	mov    0x804004,%eax
  801d8c:	89 04 24             	mov    %eax,(%esp)
  801d8f:	e8 80 f3 ff ff       	call   801114 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801d94:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d9b:	00 
  801d9c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801da3:	00 
  801da4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801dab:	e8 cf f3 ff ff       	call   80117f <ipc_recv>
}
  801db0:	83 c4 14             	add    $0x14,%esp
  801db3:	5b                   	pop    %ebx
  801db4:	5d                   	pop    %ebp
  801db5:	c3                   	ret    

00801db6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801db6:	55                   	push   %ebp
  801db7:	89 e5                	mov    %esp,%ebp
  801db9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801dbc:	8b 45 08             	mov    0x8(%ebp),%eax
  801dbf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801dc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dc7:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801dcc:	8b 45 10             	mov    0x10(%ebp),%eax
  801dcf:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801dd4:	b8 09 00 00 00       	mov    $0x9,%eax
  801dd9:	e8 72 ff ff ff       	call   801d50 <nsipc>
}
  801dde:	c9                   	leave  
  801ddf:	c3                   	ret    

00801de0 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801de6:	8b 45 08             	mov    0x8(%ebp),%eax
  801de9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801dee:	8b 45 0c             	mov    0xc(%ebp),%eax
  801df1:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801df6:	b8 06 00 00 00       	mov    $0x6,%eax
  801dfb:	e8 50 ff ff ff       	call   801d50 <nsipc>
}
  801e00:	c9                   	leave  
  801e01:	c3                   	ret    

00801e02 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  801e02:	55                   	push   %ebp
  801e03:	89 e5                	mov    %esp,%ebp
  801e05:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801e08:	8b 45 08             	mov    0x8(%ebp),%eax
  801e0b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801e10:	b8 04 00 00 00       	mov    $0x4,%eax
  801e15:	e8 36 ff ff ff       	call   801d50 <nsipc>
}
  801e1a:	c9                   	leave  
  801e1b:	c3                   	ret    

00801e1c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  801e1c:	55                   	push   %ebp
  801e1d:	89 e5                	mov    %esp,%ebp
  801e1f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e22:	8b 45 08             	mov    0x8(%ebp),%eax
  801e25:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801e2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e2d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e32:	b8 03 00 00 00       	mov    $0x3,%eax
  801e37:	e8 14 ff ff ff       	call   801d50 <nsipc>
}
  801e3c:	c9                   	leave  
  801e3d:	c3                   	ret    

00801e3e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801e3e:	55                   	push   %ebp
  801e3f:	89 e5                	mov    %esp,%ebp
  801e41:	53                   	push   %ebx
  801e42:	83 ec 14             	sub    $0x14,%esp
  801e45:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801e48:	8b 45 08             	mov    0x8(%ebp),%eax
  801e4b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801e50:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801e56:	7e 24                	jle    801e7c <nsipc_send+0x3e>
  801e58:	c7 44 24 0c 11 28 80 	movl   $0x802811,0xc(%esp)
  801e5f:	00 
  801e60:	c7 44 24 08 e5 27 80 	movl   $0x8027e5,0x8(%esp)
  801e67:	00 
  801e68:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  801e6f:	00 
  801e70:	c7 04 24 1d 28 80 00 	movl   $0x80281d,(%esp)
  801e77:	e8 88 01 00 00       	call   802004 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801e7c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e80:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e83:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e87:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801e8e:	e8 32 ec ff ff       	call   800ac5 <memmove>
	nsipcbuf.send.req_size = size;
  801e93:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801e99:	8b 45 14             	mov    0x14(%ebp),%eax
  801e9c:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801ea1:	b8 08 00 00 00       	mov    $0x8,%eax
  801ea6:	e8 a5 fe ff ff       	call   801d50 <nsipc>
}
  801eab:	83 c4 14             	add    $0x14,%esp
  801eae:	5b                   	pop    %ebx
  801eaf:	5d                   	pop    %ebp
  801eb0:	c3                   	ret    

00801eb1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	56                   	push   %esi
  801eb5:	53                   	push   %ebx
  801eb6:	83 ec 10             	sub    $0x10,%esp
  801eb9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801ebc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801ec4:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801eca:	8b 45 14             	mov    0x14(%ebp),%eax
  801ecd:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801ed2:	b8 07 00 00 00       	mov    $0x7,%eax
  801ed7:	e8 74 fe ff ff       	call   801d50 <nsipc>
  801edc:	89 c3                	mov    %eax,%ebx
  801ede:	85 c0                	test   %eax,%eax
  801ee0:	78 46                	js     801f28 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801ee2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801ee7:	7f 04                	jg     801eed <nsipc_recv+0x3c>
  801ee9:	39 c6                	cmp    %eax,%esi
  801eeb:	7d 24                	jge    801f11 <nsipc_recv+0x60>
  801eed:	c7 44 24 0c 29 28 80 	movl   $0x802829,0xc(%esp)
  801ef4:	00 
  801ef5:	c7 44 24 08 e5 27 80 	movl   $0x8027e5,0x8(%esp)
  801efc:	00 
  801efd:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801f04:	00 
  801f05:	c7 04 24 1d 28 80 00 	movl   $0x80281d,(%esp)
  801f0c:	e8 f3 00 00 00       	call   802004 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f11:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f15:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801f1c:	00 
  801f1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f20:	89 04 24             	mov    %eax,(%esp)
  801f23:	e8 9d eb ff ff       	call   800ac5 <memmove>
	}

	return r;
}
  801f28:	89 d8                	mov    %ebx,%eax
  801f2a:	83 c4 10             	add    $0x10,%esp
  801f2d:	5b                   	pop    %ebx
  801f2e:	5e                   	pop    %esi
  801f2f:	5d                   	pop    %ebp
  801f30:	c3                   	ret    

00801f31 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801f31:	55                   	push   %ebp
  801f32:	89 e5                	mov    %esp,%ebp
  801f34:	53                   	push   %ebx
  801f35:	83 ec 14             	sub    $0x14,%esp
  801f38:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801f3b:	8b 45 08             	mov    0x8(%ebp),%eax
  801f3e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801f43:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f47:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f4a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f4e:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801f55:	e8 6b eb ff ff       	call   800ac5 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801f5a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801f60:	b8 05 00 00 00       	mov    $0x5,%eax
  801f65:	e8 e6 fd ff ff       	call   801d50 <nsipc>
}
  801f6a:	83 c4 14             	add    $0x14,%esp
  801f6d:	5b                   	pop    %ebx
  801f6e:	5d                   	pop    %ebp
  801f6f:	c3                   	ret    

00801f70 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f70:	55                   	push   %ebp
  801f71:	89 e5                	mov    %esp,%ebp
  801f73:	53                   	push   %ebx
  801f74:	83 ec 14             	sub    $0x14,%esp
  801f77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f7a:	8b 45 08             	mov    0x8(%ebp),%eax
  801f7d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f82:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f86:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f89:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f8d:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801f94:	e8 2c eb ff ff       	call   800ac5 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f99:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801f9f:	b8 02 00 00 00       	mov    $0x2,%eax
  801fa4:	e8 a7 fd ff ff       	call   801d50 <nsipc>
}
  801fa9:	83 c4 14             	add    $0x14,%esp
  801fac:	5b                   	pop    %ebx
  801fad:	5d                   	pop    %ebp
  801fae:	c3                   	ret    

00801faf <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801faf:	55                   	push   %ebp
  801fb0:	89 e5                	mov    %esp,%ebp
  801fb2:	83 ec 18             	sub    $0x18,%esp
  801fb5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801fb8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  801fbb:	8b 45 08             	mov    0x8(%ebp),%eax
  801fbe:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801fc3:	b8 01 00 00 00       	mov    $0x1,%eax
  801fc8:	e8 83 fd ff ff       	call   801d50 <nsipc>
  801fcd:	89 c3                	mov    %eax,%ebx
  801fcf:	85 c0                	test   %eax,%eax
  801fd1:	78 25                	js     801ff8 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801fd3:	be 10 60 80 00       	mov    $0x806010,%esi
  801fd8:	8b 06                	mov    (%esi),%eax
  801fda:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fde:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801fe5:	00 
  801fe6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fe9:	89 04 24             	mov    %eax,(%esp)
  801fec:	e8 d4 ea ff ff       	call   800ac5 <memmove>
		*addrlen = ret->ret_addrlen;
  801ff1:	8b 16                	mov    (%esi),%edx
  801ff3:	8b 45 10             	mov    0x10(%ebp),%eax
  801ff6:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  801ff8:	89 d8                	mov    %ebx,%eax
  801ffa:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801ffd:	8b 75 fc             	mov    -0x4(%ebp),%esi
  802000:	89 ec                	mov    %ebp,%esp
  802002:	5d                   	pop    %ebp
  802003:	c3                   	ret    

00802004 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802004:	55                   	push   %ebp
  802005:	89 e5                	mov    %esp,%ebp
  802007:	56                   	push   %esi
  802008:	53                   	push   %ebx
  802009:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80200c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80200f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  802015:	e8 cd ef ff ff       	call   800fe7 <sys_getenvid>
  80201a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80201d:	89 54 24 10          	mov    %edx,0x10(%esp)
  802021:	8b 55 08             	mov    0x8(%ebp),%edx
  802024:	89 54 24 0c          	mov    %edx,0xc(%esp)
  802028:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80202c:	89 44 24 04          	mov    %eax,0x4(%esp)
  802030:	c7 04 24 40 28 80 00 	movl   $0x802840,(%esp)
  802037:	e8 59 e1 ff ff       	call   800195 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80203c:	89 74 24 04          	mov    %esi,0x4(%esp)
  802040:	8b 45 10             	mov    0x10(%ebp),%eax
  802043:	89 04 24             	mov    %eax,(%esp)
  802046:	e8 e9 e0 ff ff       	call   800134 <vcprintf>
	cprintf("\n");
  80204b:	c7 04 24 c0 27 80 00 	movl   $0x8027c0,(%esp)
  802052:	e8 3e e1 ff ff       	call   800195 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802057:	cc                   	int3   
  802058:	eb fd                	jmp    802057 <_panic+0x53>
	...

0080205c <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80205c:	55                   	push   %ebp
  80205d:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  80205f:	8b 45 08             	mov    0x8(%ebp),%eax
  802062:	89 c2                	mov    %eax,%edx
  802064:	c1 ea 16             	shr    $0x16,%edx
  802067:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80206e:	f6 c2 01             	test   $0x1,%dl
  802071:	74 20                	je     802093 <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  802073:	c1 e8 0c             	shr    $0xc,%eax
  802076:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80207d:	a8 01                	test   $0x1,%al
  80207f:	74 12                	je     802093 <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802081:	c1 e8 0c             	shr    $0xc,%eax
  802084:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  802089:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  80208e:	0f b7 c0             	movzwl %ax,%eax
  802091:	eb 05                	jmp    802098 <pageref+0x3c>
  802093:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802098:	5d                   	pop    %ebp
  802099:	c3                   	ret    
  80209a:	00 00                	add    %al,(%eax)
  80209c:	00 00                	add    %al,(%eax)
	...

008020a0 <__udivdi3>:
  8020a0:	55                   	push   %ebp
  8020a1:	89 e5                	mov    %esp,%ebp
  8020a3:	57                   	push   %edi
  8020a4:	56                   	push   %esi
  8020a5:	83 ec 10             	sub    $0x10,%esp
  8020a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8020ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8020ae:	8b 75 10             	mov    0x10(%ebp),%esi
  8020b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8020b4:	85 c0                	test   %eax,%eax
  8020b6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8020b9:	75 35                	jne    8020f0 <__udivdi3+0x50>
  8020bb:	39 fe                	cmp    %edi,%esi
  8020bd:	77 61                	ja     802120 <__udivdi3+0x80>
  8020bf:	85 f6                	test   %esi,%esi
  8020c1:	75 0b                	jne    8020ce <__udivdi3+0x2e>
  8020c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8020c8:	31 d2                	xor    %edx,%edx
  8020ca:	f7 f6                	div    %esi
  8020cc:	89 c6                	mov    %eax,%esi
  8020ce:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8020d1:	31 d2                	xor    %edx,%edx
  8020d3:	89 f8                	mov    %edi,%eax
  8020d5:	f7 f6                	div    %esi
  8020d7:	89 c7                	mov    %eax,%edi
  8020d9:	89 c8                	mov    %ecx,%eax
  8020db:	f7 f6                	div    %esi
  8020dd:	89 c1                	mov    %eax,%ecx
  8020df:	89 fa                	mov    %edi,%edx
  8020e1:	89 c8                	mov    %ecx,%eax
  8020e3:	83 c4 10             	add    $0x10,%esp
  8020e6:	5e                   	pop    %esi
  8020e7:	5f                   	pop    %edi
  8020e8:	5d                   	pop    %ebp
  8020e9:	c3                   	ret    
  8020ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020f0:	39 f8                	cmp    %edi,%eax
  8020f2:	77 1c                	ja     802110 <__udivdi3+0x70>
  8020f4:	0f bd d0             	bsr    %eax,%edx
  8020f7:	83 f2 1f             	xor    $0x1f,%edx
  8020fa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8020fd:	75 39                	jne    802138 <__udivdi3+0x98>
  8020ff:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802102:	0f 86 a0 00 00 00    	jbe    8021a8 <__udivdi3+0x108>
  802108:	39 f8                	cmp    %edi,%eax
  80210a:	0f 82 98 00 00 00    	jb     8021a8 <__udivdi3+0x108>
  802110:	31 ff                	xor    %edi,%edi
  802112:	31 c9                	xor    %ecx,%ecx
  802114:	89 c8                	mov    %ecx,%eax
  802116:	89 fa                	mov    %edi,%edx
  802118:	83 c4 10             	add    $0x10,%esp
  80211b:	5e                   	pop    %esi
  80211c:	5f                   	pop    %edi
  80211d:	5d                   	pop    %ebp
  80211e:	c3                   	ret    
  80211f:	90                   	nop
  802120:	89 d1                	mov    %edx,%ecx
  802122:	89 fa                	mov    %edi,%edx
  802124:	89 c8                	mov    %ecx,%eax
  802126:	31 ff                	xor    %edi,%edi
  802128:	f7 f6                	div    %esi
  80212a:	89 c1                	mov    %eax,%ecx
  80212c:	89 fa                	mov    %edi,%edx
  80212e:	89 c8                	mov    %ecx,%eax
  802130:	83 c4 10             	add    $0x10,%esp
  802133:	5e                   	pop    %esi
  802134:	5f                   	pop    %edi
  802135:	5d                   	pop    %ebp
  802136:	c3                   	ret    
  802137:	90                   	nop
  802138:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80213c:	89 f2                	mov    %esi,%edx
  80213e:	d3 e0                	shl    %cl,%eax
  802140:	89 45 ec             	mov    %eax,-0x14(%ebp)
  802143:	b8 20 00 00 00       	mov    $0x20,%eax
  802148:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80214b:	89 c1                	mov    %eax,%ecx
  80214d:	d3 ea                	shr    %cl,%edx
  80214f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802153:	0b 55 ec             	or     -0x14(%ebp),%edx
  802156:	d3 e6                	shl    %cl,%esi
  802158:	89 c1                	mov    %eax,%ecx
  80215a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80215d:	89 fe                	mov    %edi,%esi
  80215f:	d3 ee                	shr    %cl,%esi
  802161:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  802165:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802168:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80216b:	d3 e7                	shl    %cl,%edi
  80216d:	89 c1                	mov    %eax,%ecx
  80216f:	d3 ea                	shr    %cl,%edx
  802171:	09 d7                	or     %edx,%edi
  802173:	89 f2                	mov    %esi,%edx
  802175:	89 f8                	mov    %edi,%eax
  802177:	f7 75 ec             	divl   -0x14(%ebp)
  80217a:	89 d6                	mov    %edx,%esi
  80217c:	89 c7                	mov    %eax,%edi
  80217e:	f7 65 e8             	mull   -0x18(%ebp)
  802181:	39 d6                	cmp    %edx,%esi
  802183:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802186:	72 30                	jb     8021b8 <__udivdi3+0x118>
  802188:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80218b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80218f:	d3 e2                	shl    %cl,%edx
  802191:	39 c2                	cmp    %eax,%edx
  802193:	73 05                	jae    80219a <__udivdi3+0xfa>
  802195:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802198:	74 1e                	je     8021b8 <__udivdi3+0x118>
  80219a:	89 f9                	mov    %edi,%ecx
  80219c:	31 ff                	xor    %edi,%edi
  80219e:	e9 71 ff ff ff       	jmp    802114 <__udivdi3+0x74>
  8021a3:	90                   	nop
  8021a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021a8:	31 ff                	xor    %edi,%edi
  8021aa:	b9 01 00 00 00       	mov    $0x1,%ecx
  8021af:	e9 60 ff ff ff       	jmp    802114 <__udivdi3+0x74>
  8021b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8021b8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8021bb:	31 ff                	xor    %edi,%edi
  8021bd:	89 c8                	mov    %ecx,%eax
  8021bf:	89 fa                	mov    %edi,%edx
  8021c1:	83 c4 10             	add    $0x10,%esp
  8021c4:	5e                   	pop    %esi
  8021c5:	5f                   	pop    %edi
  8021c6:	5d                   	pop    %ebp
  8021c7:	c3                   	ret    
	...

008021d0 <__umoddi3>:
  8021d0:	55                   	push   %ebp
  8021d1:	89 e5                	mov    %esp,%ebp
  8021d3:	57                   	push   %edi
  8021d4:	56                   	push   %esi
  8021d5:	83 ec 20             	sub    $0x20,%esp
  8021d8:	8b 55 14             	mov    0x14(%ebp),%edx
  8021db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8021de:	8b 7d 10             	mov    0x10(%ebp),%edi
  8021e1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8021e4:	85 d2                	test   %edx,%edx
  8021e6:	89 c8                	mov    %ecx,%eax
  8021e8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8021eb:	75 13                	jne    802200 <__umoddi3+0x30>
  8021ed:	39 f7                	cmp    %esi,%edi
  8021ef:	76 3f                	jbe    802230 <__umoddi3+0x60>
  8021f1:	89 f2                	mov    %esi,%edx
  8021f3:	f7 f7                	div    %edi
  8021f5:	89 d0                	mov    %edx,%eax
  8021f7:	31 d2                	xor    %edx,%edx
  8021f9:	83 c4 20             	add    $0x20,%esp
  8021fc:	5e                   	pop    %esi
  8021fd:	5f                   	pop    %edi
  8021fe:	5d                   	pop    %ebp
  8021ff:	c3                   	ret    
  802200:	39 f2                	cmp    %esi,%edx
  802202:	77 4c                	ja     802250 <__umoddi3+0x80>
  802204:	0f bd ca             	bsr    %edx,%ecx
  802207:	83 f1 1f             	xor    $0x1f,%ecx
  80220a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80220d:	75 51                	jne    802260 <__umoddi3+0x90>
  80220f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802212:	0f 87 e0 00 00 00    	ja     8022f8 <__umoddi3+0x128>
  802218:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80221b:	29 f8                	sub    %edi,%eax
  80221d:	19 d6                	sbb    %edx,%esi
  80221f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802222:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802225:	89 f2                	mov    %esi,%edx
  802227:	83 c4 20             	add    $0x20,%esp
  80222a:	5e                   	pop    %esi
  80222b:	5f                   	pop    %edi
  80222c:	5d                   	pop    %ebp
  80222d:	c3                   	ret    
  80222e:	66 90                	xchg   %ax,%ax
  802230:	85 ff                	test   %edi,%edi
  802232:	75 0b                	jne    80223f <__umoddi3+0x6f>
  802234:	b8 01 00 00 00       	mov    $0x1,%eax
  802239:	31 d2                	xor    %edx,%edx
  80223b:	f7 f7                	div    %edi
  80223d:	89 c7                	mov    %eax,%edi
  80223f:	89 f0                	mov    %esi,%eax
  802241:	31 d2                	xor    %edx,%edx
  802243:	f7 f7                	div    %edi
  802245:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802248:	f7 f7                	div    %edi
  80224a:	eb a9                	jmp    8021f5 <__umoddi3+0x25>
  80224c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802250:	89 c8                	mov    %ecx,%eax
  802252:	89 f2                	mov    %esi,%edx
  802254:	83 c4 20             	add    $0x20,%esp
  802257:	5e                   	pop    %esi
  802258:	5f                   	pop    %edi
  802259:	5d                   	pop    %ebp
  80225a:	c3                   	ret    
  80225b:	90                   	nop
  80225c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802260:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802264:	d3 e2                	shl    %cl,%edx
  802266:	89 55 f4             	mov    %edx,-0xc(%ebp)
  802269:	ba 20 00 00 00       	mov    $0x20,%edx
  80226e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  802271:	89 55 ec             	mov    %edx,-0x14(%ebp)
  802274:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802278:	89 fa                	mov    %edi,%edx
  80227a:	d3 ea                	shr    %cl,%edx
  80227c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802280:	0b 55 f4             	or     -0xc(%ebp),%edx
  802283:	d3 e7                	shl    %cl,%edi
  802285:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802289:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80228c:	89 f2                	mov    %esi,%edx
  80228e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802291:	89 c7                	mov    %eax,%edi
  802293:	d3 ea                	shr    %cl,%edx
  802295:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802299:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80229c:	89 c2                	mov    %eax,%edx
  80229e:	d3 e6                	shl    %cl,%esi
  8022a0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8022a4:	d3 ea                	shr    %cl,%edx
  8022a6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8022aa:	09 d6                	or     %edx,%esi
  8022ac:	89 f0                	mov    %esi,%eax
  8022ae:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8022b1:	d3 e7                	shl    %cl,%edi
  8022b3:	89 f2                	mov    %esi,%edx
  8022b5:	f7 75 f4             	divl   -0xc(%ebp)
  8022b8:	89 d6                	mov    %edx,%esi
  8022ba:	f7 65 e8             	mull   -0x18(%ebp)
  8022bd:	39 d6                	cmp    %edx,%esi
  8022bf:	72 2b                	jb     8022ec <__umoddi3+0x11c>
  8022c1:	39 c7                	cmp    %eax,%edi
  8022c3:	72 23                	jb     8022e8 <__umoddi3+0x118>
  8022c5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8022c9:	29 c7                	sub    %eax,%edi
  8022cb:	19 d6                	sbb    %edx,%esi
  8022cd:	89 f0                	mov    %esi,%eax
  8022cf:	89 f2                	mov    %esi,%edx
  8022d1:	d3 ef                	shr    %cl,%edi
  8022d3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8022d7:	d3 e0                	shl    %cl,%eax
  8022d9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8022dd:	09 f8                	or     %edi,%eax
  8022df:	d3 ea                	shr    %cl,%edx
  8022e1:	83 c4 20             	add    $0x20,%esp
  8022e4:	5e                   	pop    %esi
  8022e5:	5f                   	pop    %edi
  8022e6:	5d                   	pop    %ebp
  8022e7:	c3                   	ret    
  8022e8:	39 d6                	cmp    %edx,%esi
  8022ea:	75 d9                	jne    8022c5 <__umoddi3+0xf5>
  8022ec:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8022ef:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8022f2:	eb d1                	jmp    8022c5 <__umoddi3+0xf5>
  8022f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022f8:	39 f2                	cmp    %esi,%edx
  8022fa:	0f 82 18 ff ff ff    	jb     802218 <__umoddi3+0x48>
  802300:	e9 1d ff ff ff       	jmp    802222 <__umoddi3+0x52>
