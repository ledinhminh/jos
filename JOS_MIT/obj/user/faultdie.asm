
obj/user/faultdie.debug:     file format elf32-i386


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
  80002c:	e8 63 00 00 00       	call   800094 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800040 <umain>:
	sys_env_destroy(sys_getenvid());
}

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  800046:	c7 04 24 5e 00 80 00 	movl   $0x80005e,(%esp)
  80004d:	e8 3e 10 00 00       	call   801090 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800052:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800059:	00 00 00 
}
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	83 ec 18             	sub    $0x18,%esp
  800064:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  800067:	8b 50 04             	mov    0x4(%eax),%edx
  80006a:	83 e2 07             	and    $0x7,%edx
  80006d:	89 54 24 08          	mov    %edx,0x8(%esp)
  800071:	8b 00                	mov    (%eax),%eax
  800073:	89 44 24 04          	mov    %eax,0x4(%esp)
  800077:	c7 04 24 80 23 80 00 	movl   $0x802380,(%esp)
  80007e:	e8 de 00 00 00       	call   800161 <cprintf>
	sys_env_destroy(sys_getenvid());
  800083:	e8 1f 0f 00 00       	call   800fa7 <sys_getenvid>
  800088:	89 04 24             	mov    %eax,(%esp)
  80008b:	e8 52 0f 00 00       	call   800fe2 <sys_env_destroy>
}
  800090:	c9                   	leave  
  800091:	c3                   	ret    
	...

00800094 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 18             	sub    $0x18,%esp
  80009a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80009d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000a0:	8b 75 08             	mov    0x8(%ebp),%esi
  8000a3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  8000a6:	e8 fc 0e 00 00       	call   800fa7 <sys_getenvid>
  8000ab:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b0:	c1 e0 07             	shl    $0x7,%eax
  8000b3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b8:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000bd:	85 f6                	test   %esi,%esi
  8000bf:	7e 07                	jle    8000c8 <libmain+0x34>
		binaryname = argv[0];
  8000c1:	8b 03                	mov    (%ebx),%eax
  8000c3:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000c8:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000cc:	89 34 24             	mov    %esi,(%esp)
  8000cf:	e8 6c ff ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  8000d4:	e8 0b 00 00 00       	call   8000e4 <exit>
}
  8000d9:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000dc:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000df:	89 ec                	mov    %ebp,%esp
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    
	...

008000e4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000ea:	e8 2a 15 00 00       	call   801619 <close_all>
	sys_env_destroy(0);
  8000ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f6:	e8 e7 0e 00 00       	call   800fe2 <sys_env_destroy>
}
  8000fb:	c9                   	leave  
  8000fc:	c3                   	ret    
  8000fd:	00 00                	add    %al,(%eax)
	...

00800100 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800109:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800110:	00 00 00 
	b.cnt = 0;
  800113:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800120:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800124:	8b 45 08             	mov    0x8(%ebp),%eax
  800127:	89 44 24 08          	mov    %eax,0x8(%esp)
  80012b:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800131:	89 44 24 04          	mov    %eax,0x4(%esp)
  800135:	c7 04 24 7b 01 80 00 	movl   $0x80017b,(%esp)
  80013c:	e8 cc 01 00 00       	call   80030d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800141:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800147:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800151:	89 04 24             	mov    %eax,(%esp)
  800154:	e8 fd 0e 00 00       	call   801056 <sys_cputs>

	return b.cnt;
}
  800159:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80015f:	c9                   	leave  
  800160:	c3                   	ret    

00800161 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800161:	55                   	push   %ebp
  800162:	89 e5                	mov    %esp,%ebp
  800164:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800167:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80016a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016e:	8b 45 08             	mov    0x8(%ebp),%eax
  800171:	89 04 24             	mov    %eax,(%esp)
  800174:	e8 87 ff ff ff       	call   800100 <vcprintf>
	va_end(ap);

	return cnt;
}
  800179:	c9                   	leave  
  80017a:	c3                   	ret    

0080017b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80017b:	55                   	push   %ebp
  80017c:	89 e5                	mov    %esp,%ebp
  80017e:	53                   	push   %ebx
  80017f:	83 ec 14             	sub    $0x14,%esp
  800182:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800185:	8b 03                	mov    (%ebx),%eax
  800187:	8b 55 08             	mov    0x8(%ebp),%edx
  80018a:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80018e:	83 c0 01             	add    $0x1,%eax
  800191:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800193:	3d ff 00 00 00       	cmp    $0xff,%eax
  800198:	75 19                	jne    8001b3 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80019a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001a1:	00 
  8001a2:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a5:	89 04 24             	mov    %eax,(%esp)
  8001a8:	e8 a9 0e 00 00       	call   801056 <sys_cputs>
		b->idx = 0;
  8001ad:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001b3:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b7:	83 c4 14             	add    $0x14,%esp
  8001ba:	5b                   	pop    %ebx
  8001bb:	5d                   	pop    %ebp
  8001bc:	c3                   	ret    
  8001bd:	00 00                	add    %al,(%eax)
	...

008001c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	57                   	push   %edi
  8001c4:	56                   	push   %esi
  8001c5:	53                   	push   %ebx
  8001c6:	83 ec 4c             	sub    $0x4c,%esp
  8001c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001cc:	89 d6                	mov    %edx,%esi
  8001ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001da:	8b 45 10             	mov    0x10(%ebp),%eax
  8001dd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001e0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001eb:	39 d1                	cmp    %edx,%ecx
  8001ed:	72 15                	jb     800204 <printnum+0x44>
  8001ef:	77 07                	ja     8001f8 <printnum+0x38>
  8001f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001f4:	39 d0                	cmp    %edx,%eax
  8001f6:	76 0c                	jbe    800204 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001f8:	83 eb 01             	sub    $0x1,%ebx
  8001fb:	85 db                	test   %ebx,%ebx
  8001fd:	8d 76 00             	lea    0x0(%esi),%esi
  800200:	7f 61                	jg     800263 <printnum+0xa3>
  800202:	eb 70                	jmp    800274 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800204:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800208:	83 eb 01             	sub    $0x1,%ebx
  80020b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80020f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800213:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800217:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80021b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80021e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800221:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800224:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800228:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80022f:	00 
  800230:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800233:	89 04 24             	mov    %eax,(%esp)
  800236:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800239:	89 54 24 04          	mov    %edx,0x4(%esp)
  80023d:	e8 ce 1e 00 00       	call   802110 <__udivdi3>
  800242:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800245:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800248:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80024c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800250:	89 04 24             	mov    %eax,(%esp)
  800253:	89 54 24 04          	mov    %edx,0x4(%esp)
  800257:	89 f2                	mov    %esi,%edx
  800259:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80025c:	e8 5f ff ff ff       	call   8001c0 <printnum>
  800261:	eb 11                	jmp    800274 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800263:	89 74 24 04          	mov    %esi,0x4(%esp)
  800267:	89 3c 24             	mov    %edi,(%esp)
  80026a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80026d:	83 eb 01             	sub    $0x1,%ebx
  800270:	85 db                	test   %ebx,%ebx
  800272:	7f ef                	jg     800263 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800274:	89 74 24 04          	mov    %esi,0x4(%esp)
  800278:	8b 74 24 04          	mov    0x4(%esp),%esi
  80027c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80027f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800283:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80028a:	00 
  80028b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80028e:	89 14 24             	mov    %edx,(%esp)
  800291:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800294:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800298:	e8 a3 1f 00 00       	call   802240 <__umoddi3>
  80029d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002a1:	0f be 80 a6 23 80 00 	movsbl 0x8023a6(%eax),%eax
  8002a8:	89 04 24             	mov    %eax,(%esp)
  8002ab:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002ae:	83 c4 4c             	add    $0x4c,%esp
  8002b1:	5b                   	pop    %ebx
  8002b2:	5e                   	pop    %esi
  8002b3:	5f                   	pop    %edi
  8002b4:	5d                   	pop    %ebp
  8002b5:	c3                   	ret    

008002b6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b9:	83 fa 01             	cmp    $0x1,%edx
  8002bc:	7e 0e                	jle    8002cc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002be:	8b 10                	mov    (%eax),%edx
  8002c0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c3:	89 08                	mov    %ecx,(%eax)
  8002c5:	8b 02                	mov    (%edx),%eax
  8002c7:	8b 52 04             	mov    0x4(%edx),%edx
  8002ca:	eb 22                	jmp    8002ee <getuint+0x38>
	else if (lflag)
  8002cc:	85 d2                	test   %edx,%edx
  8002ce:	74 10                	je     8002e0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d0:	8b 10                	mov    (%eax),%edx
  8002d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d5:	89 08                	mov    %ecx,(%eax)
  8002d7:	8b 02                	mov    (%edx),%eax
  8002d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002de:	eb 0e                	jmp    8002ee <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 02                	mov    (%edx),%eax
  8002e9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002fa:	8b 10                	mov    (%eax),%edx
  8002fc:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ff:	73 0a                	jae    80030b <sprintputch+0x1b>
		*b->buf++ = ch;
  800301:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800304:	88 0a                	mov    %cl,(%edx)
  800306:	83 c2 01             	add    $0x1,%edx
  800309:	89 10                	mov    %edx,(%eax)
}
  80030b:	5d                   	pop    %ebp
  80030c:	c3                   	ret    

0080030d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	57                   	push   %edi
  800311:	56                   	push   %esi
  800312:	53                   	push   %ebx
  800313:	83 ec 5c             	sub    $0x5c,%esp
  800316:	8b 7d 08             	mov    0x8(%ebp),%edi
  800319:	8b 75 0c             	mov    0xc(%ebp),%esi
  80031c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80031f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800326:	eb 11                	jmp    800339 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800328:	85 c0                	test   %eax,%eax
  80032a:	0f 84 68 04 00 00    	je     800798 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  800330:	89 74 24 04          	mov    %esi,0x4(%esp)
  800334:	89 04 24             	mov    %eax,(%esp)
  800337:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800339:	0f b6 03             	movzbl (%ebx),%eax
  80033c:	83 c3 01             	add    $0x1,%ebx
  80033f:	83 f8 25             	cmp    $0x25,%eax
  800342:	75 e4                	jne    800328 <vprintfmt+0x1b>
  800344:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80034b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800352:	b9 00 00 00 00       	mov    $0x0,%ecx
  800357:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  80035b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800362:	eb 06                	jmp    80036a <vprintfmt+0x5d>
  800364:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  800368:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	0f b6 13             	movzbl (%ebx),%edx
  80036d:	0f b6 c2             	movzbl %dl,%eax
  800370:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800373:	8d 43 01             	lea    0x1(%ebx),%eax
  800376:	83 ea 23             	sub    $0x23,%edx
  800379:	80 fa 55             	cmp    $0x55,%dl
  80037c:	0f 87 f9 03 00 00    	ja     80077b <vprintfmt+0x46e>
  800382:	0f b6 d2             	movzbl %dl,%edx
  800385:	ff 24 95 80 25 80 00 	jmp    *0x802580(,%edx,4)
  80038c:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800390:	eb d6                	jmp    800368 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800392:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800395:	83 ea 30             	sub    $0x30,%edx
  800398:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80039b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80039e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003a1:	83 fb 09             	cmp    $0x9,%ebx
  8003a4:	77 54                	ja     8003fa <vprintfmt+0xed>
  8003a6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8003a9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ac:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8003af:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003b2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8003b6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003b9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003bc:	83 fb 09             	cmp    $0x9,%ebx
  8003bf:	76 eb                	jbe    8003ac <vprintfmt+0x9f>
  8003c1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8003c4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8003c7:	eb 31                	jmp    8003fa <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c9:	8b 55 14             	mov    0x14(%ebp),%edx
  8003cc:	8d 5a 04             	lea    0x4(%edx),%ebx
  8003cf:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8003d2:	8b 12                	mov    (%edx),%edx
  8003d4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8003d7:	eb 21                	jmp    8003fa <vprintfmt+0xed>

		case '.':
			if (width < 0)
  8003d9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e2:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  8003e6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003e9:	e9 7a ff ff ff       	jmp    800368 <vprintfmt+0x5b>
  8003ee:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003f5:	e9 6e ff ff ff       	jmp    800368 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8003fa:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003fe:	0f 89 64 ff ff ff    	jns    800368 <vprintfmt+0x5b>
  800404:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800407:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80040a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80040d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800410:	e9 53 ff ff ff       	jmp    800368 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800415:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800418:	e9 4b ff ff ff       	jmp    800368 <vprintfmt+0x5b>
  80041d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800420:	8b 45 14             	mov    0x14(%ebp),%eax
  800423:	8d 50 04             	lea    0x4(%eax),%edx
  800426:	89 55 14             	mov    %edx,0x14(%ebp)
  800429:	89 74 24 04          	mov    %esi,0x4(%esp)
  80042d:	8b 00                	mov    (%eax),%eax
  80042f:	89 04 24             	mov    %eax,(%esp)
  800432:	ff d7                	call   *%edi
  800434:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800437:	e9 fd fe ff ff       	jmp    800339 <vprintfmt+0x2c>
  80043c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80043f:	8b 45 14             	mov    0x14(%ebp),%eax
  800442:	8d 50 04             	lea    0x4(%eax),%edx
  800445:	89 55 14             	mov    %edx,0x14(%ebp)
  800448:	8b 00                	mov    (%eax),%eax
  80044a:	89 c2                	mov    %eax,%edx
  80044c:	c1 fa 1f             	sar    $0x1f,%edx
  80044f:	31 d0                	xor    %edx,%eax
  800451:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800453:	83 f8 0f             	cmp    $0xf,%eax
  800456:	7f 0b                	jg     800463 <vprintfmt+0x156>
  800458:	8b 14 85 e0 26 80 00 	mov    0x8026e0(,%eax,4),%edx
  80045f:	85 d2                	test   %edx,%edx
  800461:	75 20                	jne    800483 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800463:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800467:	c7 44 24 08 b7 23 80 	movl   $0x8023b7,0x8(%esp)
  80046e:	00 
  80046f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800473:	89 3c 24             	mov    %edi,(%esp)
  800476:	e8 a5 03 00 00       	call   800820 <printfmt>
  80047b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80047e:	e9 b6 fe ff ff       	jmp    800339 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800483:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800487:	c7 44 24 08 23 28 80 	movl   $0x802823,0x8(%esp)
  80048e:	00 
  80048f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800493:	89 3c 24             	mov    %edi,(%esp)
  800496:	e8 85 03 00 00       	call   800820 <printfmt>
  80049b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80049e:	e9 96 fe ff ff       	jmp    800339 <vprintfmt+0x2c>
  8004a3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004a6:	89 c3                	mov    %eax,%ebx
  8004a8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004ab:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004ae:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b4:	8d 50 04             	lea    0x4(%eax),%edx
  8004b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ba:	8b 00                	mov    (%eax),%eax
  8004bc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004bf:	85 c0                	test   %eax,%eax
  8004c1:	b8 c0 23 80 00       	mov    $0x8023c0,%eax
  8004c6:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  8004ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8004cd:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8004d1:	7e 06                	jle    8004d9 <vprintfmt+0x1cc>
  8004d3:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8004d7:	75 13                	jne    8004ec <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004dc:	0f be 02             	movsbl (%edx),%eax
  8004df:	85 c0                	test   %eax,%eax
  8004e1:	0f 85 a2 00 00 00    	jne    800589 <vprintfmt+0x27c>
  8004e7:	e9 8f 00 00 00       	jmp    80057b <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ec:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004f0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004f3:	89 0c 24             	mov    %ecx,(%esp)
  8004f6:	e8 70 03 00 00       	call   80086b <strnlen>
  8004fb:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004fe:	29 c2                	sub    %eax,%edx
  800500:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800503:	85 d2                	test   %edx,%edx
  800505:	7e d2                	jle    8004d9 <vprintfmt+0x1cc>
					putch(padc, putdat);
  800507:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80050b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80050e:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800511:	89 d3                	mov    %edx,%ebx
  800513:	89 74 24 04          	mov    %esi,0x4(%esp)
  800517:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80051a:	89 04 24             	mov    %eax,(%esp)
  80051d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051f:	83 eb 01             	sub    $0x1,%ebx
  800522:	85 db                	test   %ebx,%ebx
  800524:	7f ed                	jg     800513 <vprintfmt+0x206>
  800526:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800529:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800530:	eb a7                	jmp    8004d9 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800532:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800536:	74 1b                	je     800553 <vprintfmt+0x246>
  800538:	8d 50 e0             	lea    -0x20(%eax),%edx
  80053b:	83 fa 5e             	cmp    $0x5e,%edx
  80053e:	76 13                	jbe    800553 <vprintfmt+0x246>
					putch('?', putdat);
  800540:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800543:	89 54 24 04          	mov    %edx,0x4(%esp)
  800547:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80054e:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800551:	eb 0d                	jmp    800560 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800553:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800556:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80055a:	89 04 24             	mov    %eax,(%esp)
  80055d:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800560:	83 ef 01             	sub    $0x1,%edi
  800563:	0f be 03             	movsbl (%ebx),%eax
  800566:	85 c0                	test   %eax,%eax
  800568:	74 05                	je     80056f <vprintfmt+0x262>
  80056a:	83 c3 01             	add    $0x1,%ebx
  80056d:	eb 31                	jmp    8005a0 <vprintfmt+0x293>
  80056f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800572:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800575:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800578:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80057b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80057f:	7f 36                	jg     8005b7 <vprintfmt+0x2aa>
  800581:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800584:	e9 b0 fd ff ff       	jmp    800339 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800589:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80058c:	83 c2 01             	add    $0x1,%edx
  80058f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800592:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800595:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800598:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80059b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80059e:	89 d3                	mov    %edx,%ebx
  8005a0:	85 f6                	test   %esi,%esi
  8005a2:	78 8e                	js     800532 <vprintfmt+0x225>
  8005a4:	83 ee 01             	sub    $0x1,%esi
  8005a7:	79 89                	jns    800532 <vprintfmt+0x225>
  8005a9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005af:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005b2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8005b5:	eb c4                	jmp    80057b <vprintfmt+0x26e>
  8005b7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8005ba:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005c1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005c8:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005ca:	83 eb 01             	sub    $0x1,%ebx
  8005cd:	85 db                	test   %ebx,%ebx
  8005cf:	7f ec                	jg     8005bd <vprintfmt+0x2b0>
  8005d1:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8005d4:	e9 60 fd ff ff       	jmp    800339 <vprintfmt+0x2c>
  8005d9:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005dc:	83 f9 01             	cmp    $0x1,%ecx
  8005df:	7e 16                	jle    8005f7 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  8005e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e4:	8d 50 08             	lea    0x8(%eax),%edx
  8005e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ea:	8b 10                	mov    (%eax),%edx
  8005ec:	8b 48 04             	mov    0x4(%eax),%ecx
  8005ef:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005f2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005f5:	eb 32                	jmp    800629 <vprintfmt+0x31c>
	else if (lflag)
  8005f7:	85 c9                	test   %ecx,%ecx
  8005f9:	74 18                	je     800613 <vprintfmt+0x306>
		return va_arg(*ap, long);
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8d 50 04             	lea    0x4(%eax),%edx
  800601:	89 55 14             	mov    %edx,0x14(%ebp)
  800604:	8b 00                	mov    (%eax),%eax
  800606:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800609:	89 c1                	mov    %eax,%ecx
  80060b:	c1 f9 1f             	sar    $0x1f,%ecx
  80060e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800611:	eb 16                	jmp    800629 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  800613:	8b 45 14             	mov    0x14(%ebp),%eax
  800616:	8d 50 04             	lea    0x4(%eax),%edx
  800619:	89 55 14             	mov    %edx,0x14(%ebp)
  80061c:	8b 00                	mov    (%eax),%eax
  80061e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800621:	89 c2                	mov    %eax,%edx
  800623:	c1 fa 1f             	sar    $0x1f,%edx
  800626:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800629:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80062c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80062f:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  800634:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800638:	0f 89 8a 00 00 00    	jns    8006c8 <vprintfmt+0x3bb>
				putch('-', putdat);
  80063e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800642:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800649:	ff d7                	call   *%edi
				num = -(long long) num;
  80064b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80064e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800651:	f7 d8                	neg    %eax
  800653:	83 d2 00             	adc    $0x0,%edx
  800656:	f7 da                	neg    %edx
  800658:	eb 6e                	jmp    8006c8 <vprintfmt+0x3bb>
  80065a:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80065d:	89 ca                	mov    %ecx,%edx
  80065f:	8d 45 14             	lea    0x14(%ebp),%eax
  800662:	e8 4f fc ff ff       	call   8002b6 <getuint>
  800667:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  80066c:	eb 5a                	jmp    8006c8 <vprintfmt+0x3bb>
  80066e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800671:	89 ca                	mov    %ecx,%edx
  800673:	8d 45 14             	lea    0x14(%ebp),%eax
  800676:	e8 3b fc ff ff       	call   8002b6 <getuint>
  80067b:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  800680:	eb 46                	jmp    8006c8 <vprintfmt+0x3bb>
  800682:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  800685:	89 74 24 04          	mov    %esi,0x4(%esp)
  800689:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800690:	ff d7                	call   *%edi
			putch('x', putdat);
  800692:	89 74 24 04          	mov    %esi,0x4(%esp)
  800696:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80069d:	ff d7                	call   *%edi
			num = (unsigned long long)
  80069f:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a2:	8d 50 04             	lea    0x4(%eax),%edx
  8006a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006a8:	8b 00                	mov    (%eax),%eax
  8006aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8006af:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006b4:	eb 12                	jmp    8006c8 <vprintfmt+0x3bb>
  8006b6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006b9:	89 ca                	mov    %ecx,%edx
  8006bb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006be:	e8 f3 fb ff ff       	call   8002b6 <getuint>
  8006c3:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c8:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8006cc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8006d0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8006d3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8006d7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8006db:	89 04 24             	mov    %eax,(%esp)
  8006de:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006e2:	89 f2                	mov    %esi,%edx
  8006e4:	89 f8                	mov    %edi,%eax
  8006e6:	e8 d5 fa ff ff       	call   8001c0 <printnum>
  8006eb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8006ee:	e9 46 fc ff ff       	jmp    800339 <vprintfmt+0x2c>
  8006f3:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  8006f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f9:	8d 50 04             	lea    0x4(%eax),%edx
  8006fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ff:	8b 00                	mov    (%eax),%eax
  800701:	85 c0                	test   %eax,%eax
  800703:	75 24                	jne    800729 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  800705:	c7 44 24 0c dc 24 80 	movl   $0x8024dc,0xc(%esp)
  80070c:	00 
  80070d:	c7 44 24 08 23 28 80 	movl   $0x802823,0x8(%esp)
  800714:	00 
  800715:	89 74 24 04          	mov    %esi,0x4(%esp)
  800719:	89 3c 24             	mov    %edi,(%esp)
  80071c:	e8 ff 00 00 00       	call   800820 <printfmt>
  800721:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800724:	e9 10 fc ff ff       	jmp    800339 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  800729:	83 3e 7f             	cmpl   $0x7f,(%esi)
  80072c:	7e 29                	jle    800757 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  80072e:	0f b6 16             	movzbl (%esi),%edx
  800731:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  800733:	c7 44 24 0c 14 25 80 	movl   $0x802514,0xc(%esp)
  80073a:	00 
  80073b:	c7 44 24 08 23 28 80 	movl   $0x802823,0x8(%esp)
  800742:	00 
  800743:	89 74 24 04          	mov    %esi,0x4(%esp)
  800747:	89 3c 24             	mov    %edi,(%esp)
  80074a:	e8 d1 00 00 00       	call   800820 <printfmt>
  80074f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800752:	e9 e2 fb ff ff       	jmp    800339 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  800757:	0f b6 16             	movzbl (%esi),%edx
  80075a:	88 10                	mov    %dl,(%eax)
  80075c:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  80075f:	e9 d5 fb ff ff       	jmp    800339 <vprintfmt+0x2c>
  800764:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800767:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80076a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80076e:	89 14 24             	mov    %edx,(%esp)
  800771:	ff d7                	call   *%edi
  800773:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800776:	e9 be fb ff ff       	jmp    800339 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80077b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80077f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800786:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800788:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80078b:	80 38 25             	cmpb   $0x25,(%eax)
  80078e:	0f 84 a5 fb ff ff    	je     800339 <vprintfmt+0x2c>
  800794:	89 c3                	mov    %eax,%ebx
  800796:	eb f0                	jmp    800788 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  800798:	83 c4 5c             	add    $0x5c,%esp
  80079b:	5b                   	pop    %ebx
  80079c:	5e                   	pop    %esi
  80079d:	5f                   	pop    %edi
  80079e:	5d                   	pop    %ebp
  80079f:	c3                   	ret    

008007a0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007a0:	55                   	push   %ebp
  8007a1:	89 e5                	mov    %esp,%ebp
  8007a3:	83 ec 28             	sub    $0x28,%esp
  8007a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007a9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8007ac:	85 c0                	test   %eax,%eax
  8007ae:	74 04                	je     8007b4 <vsnprintf+0x14>
  8007b0:	85 d2                	test   %edx,%edx
  8007b2:	7f 07                	jg     8007bb <vsnprintf+0x1b>
  8007b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007b9:	eb 3b                	jmp    8007f6 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007bb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007be:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8007c2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007c5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d3:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007da:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e1:	c7 04 24 f0 02 80 00 	movl   $0x8002f0,(%esp)
  8007e8:	e8 20 fb ff ff       	call   80030d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007f0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007f6:	c9                   	leave  
  8007f7:	c3                   	ret    

008007f8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007f8:	55                   	push   %ebp
  8007f9:	89 e5                	mov    %esp,%ebp
  8007fb:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8007fe:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800801:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800805:	8b 45 10             	mov    0x10(%ebp),%eax
  800808:	89 44 24 08          	mov    %eax,0x8(%esp)
  80080c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80080f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	89 04 24             	mov    %eax,(%esp)
  800819:	e8 82 ff ff ff       	call   8007a0 <vsnprintf>
	va_end(ap);

	return rc;
}
  80081e:	c9                   	leave  
  80081f:	c3                   	ret    

00800820 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800826:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800829:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80082d:	8b 45 10             	mov    0x10(%ebp),%eax
  800830:	89 44 24 08          	mov    %eax,0x8(%esp)
  800834:	8b 45 0c             	mov    0xc(%ebp),%eax
  800837:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083b:	8b 45 08             	mov    0x8(%ebp),%eax
  80083e:	89 04 24             	mov    %eax,(%esp)
  800841:	e8 c7 fa ff ff       	call   80030d <vprintfmt>
	va_end(ap);
}
  800846:	c9                   	leave  
  800847:	c3                   	ret    
	...

00800850 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800850:	55                   	push   %ebp
  800851:	89 e5                	mov    %esp,%ebp
  800853:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800856:	b8 00 00 00 00       	mov    $0x0,%eax
  80085b:	80 3a 00             	cmpb   $0x0,(%edx)
  80085e:	74 09                	je     800869 <strlen+0x19>
		n++;
  800860:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800863:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800867:	75 f7                	jne    800860 <strlen+0x10>
		n++;
	return n;
}
  800869:	5d                   	pop    %ebp
  80086a:	c3                   	ret    

0080086b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80086b:	55                   	push   %ebp
  80086c:	89 e5                	mov    %esp,%ebp
  80086e:	53                   	push   %ebx
  80086f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800872:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800875:	85 c9                	test   %ecx,%ecx
  800877:	74 19                	je     800892 <strnlen+0x27>
  800879:	80 3b 00             	cmpb   $0x0,(%ebx)
  80087c:	74 14                	je     800892 <strnlen+0x27>
  80087e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800883:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800886:	39 c8                	cmp    %ecx,%eax
  800888:	74 0d                	je     800897 <strnlen+0x2c>
  80088a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80088e:	75 f3                	jne    800883 <strnlen+0x18>
  800890:	eb 05                	jmp    800897 <strnlen+0x2c>
  800892:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800897:	5b                   	pop    %ebx
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	53                   	push   %ebx
  80089e:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008a4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008a9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008ad:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008b0:	83 c2 01             	add    $0x1,%edx
  8008b3:	84 c9                	test   %cl,%cl
  8008b5:	75 f2                	jne    8008a9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008b7:	5b                   	pop    %ebx
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	53                   	push   %ebx
  8008be:	83 ec 08             	sub    $0x8,%esp
  8008c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008c4:	89 1c 24             	mov    %ebx,(%esp)
  8008c7:	e8 84 ff ff ff       	call   800850 <strlen>
	strcpy(dst + len, src);
  8008cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cf:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008d3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8008d6:	89 04 24             	mov    %eax,(%esp)
  8008d9:	e8 bc ff ff ff       	call   80089a <strcpy>
	return dst;
}
  8008de:	89 d8                	mov    %ebx,%eax
  8008e0:	83 c4 08             	add    $0x8,%esp
  8008e3:	5b                   	pop    %ebx
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008e6:	55                   	push   %ebp
  8008e7:	89 e5                	mov    %esp,%ebp
  8008e9:	56                   	push   %esi
  8008ea:	53                   	push   %ebx
  8008eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008f1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008f4:	85 f6                	test   %esi,%esi
  8008f6:	74 18                	je     800910 <strncpy+0x2a>
  8008f8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008fd:	0f b6 1a             	movzbl (%edx),%ebx
  800900:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800903:	80 3a 01             	cmpb   $0x1,(%edx)
  800906:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800909:	83 c1 01             	add    $0x1,%ecx
  80090c:	39 ce                	cmp    %ecx,%esi
  80090e:	77 ed                	ja     8008fd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800910:	5b                   	pop    %ebx
  800911:	5e                   	pop    %esi
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    

00800914 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	56                   	push   %esi
  800918:	53                   	push   %ebx
  800919:	8b 75 08             	mov    0x8(%ebp),%esi
  80091c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800922:	89 f0                	mov    %esi,%eax
  800924:	85 c9                	test   %ecx,%ecx
  800926:	74 27                	je     80094f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800928:	83 e9 01             	sub    $0x1,%ecx
  80092b:	74 1d                	je     80094a <strlcpy+0x36>
  80092d:	0f b6 1a             	movzbl (%edx),%ebx
  800930:	84 db                	test   %bl,%bl
  800932:	74 16                	je     80094a <strlcpy+0x36>
			*dst++ = *src++;
  800934:	88 18                	mov    %bl,(%eax)
  800936:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800939:	83 e9 01             	sub    $0x1,%ecx
  80093c:	74 0e                	je     80094c <strlcpy+0x38>
			*dst++ = *src++;
  80093e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800941:	0f b6 1a             	movzbl (%edx),%ebx
  800944:	84 db                	test   %bl,%bl
  800946:	75 ec                	jne    800934 <strlcpy+0x20>
  800948:	eb 02                	jmp    80094c <strlcpy+0x38>
  80094a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80094c:	c6 00 00             	movb   $0x0,(%eax)
  80094f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800951:	5b                   	pop    %ebx
  800952:	5e                   	pop    %esi
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80095b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80095e:	0f b6 01             	movzbl (%ecx),%eax
  800961:	84 c0                	test   %al,%al
  800963:	74 15                	je     80097a <strcmp+0x25>
  800965:	3a 02                	cmp    (%edx),%al
  800967:	75 11                	jne    80097a <strcmp+0x25>
		p++, q++;
  800969:	83 c1 01             	add    $0x1,%ecx
  80096c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80096f:	0f b6 01             	movzbl (%ecx),%eax
  800972:	84 c0                	test   %al,%al
  800974:	74 04                	je     80097a <strcmp+0x25>
  800976:	3a 02                	cmp    (%edx),%al
  800978:	74 ef                	je     800969 <strcmp+0x14>
  80097a:	0f b6 c0             	movzbl %al,%eax
  80097d:	0f b6 12             	movzbl (%edx),%edx
  800980:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	53                   	push   %ebx
  800988:	8b 55 08             	mov    0x8(%ebp),%edx
  80098b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80098e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800991:	85 c0                	test   %eax,%eax
  800993:	74 23                	je     8009b8 <strncmp+0x34>
  800995:	0f b6 1a             	movzbl (%edx),%ebx
  800998:	84 db                	test   %bl,%bl
  80099a:	74 25                	je     8009c1 <strncmp+0x3d>
  80099c:	3a 19                	cmp    (%ecx),%bl
  80099e:	75 21                	jne    8009c1 <strncmp+0x3d>
  8009a0:	83 e8 01             	sub    $0x1,%eax
  8009a3:	74 13                	je     8009b8 <strncmp+0x34>
		n--, p++, q++;
  8009a5:	83 c2 01             	add    $0x1,%edx
  8009a8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009ab:	0f b6 1a             	movzbl (%edx),%ebx
  8009ae:	84 db                	test   %bl,%bl
  8009b0:	74 0f                	je     8009c1 <strncmp+0x3d>
  8009b2:	3a 19                	cmp    (%ecx),%bl
  8009b4:	74 ea                	je     8009a0 <strncmp+0x1c>
  8009b6:	eb 09                	jmp    8009c1 <strncmp+0x3d>
  8009b8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009bd:	5b                   	pop    %ebx
  8009be:	5d                   	pop    %ebp
  8009bf:	90                   	nop
  8009c0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009c1:	0f b6 02             	movzbl (%edx),%eax
  8009c4:	0f b6 11             	movzbl (%ecx),%edx
  8009c7:	29 d0                	sub    %edx,%eax
  8009c9:	eb f2                	jmp    8009bd <strncmp+0x39>

008009cb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d5:	0f b6 10             	movzbl (%eax),%edx
  8009d8:	84 d2                	test   %dl,%dl
  8009da:	74 18                	je     8009f4 <strchr+0x29>
		if (*s == c)
  8009dc:	38 ca                	cmp    %cl,%dl
  8009de:	75 0a                	jne    8009ea <strchr+0x1f>
  8009e0:	eb 17                	jmp    8009f9 <strchr+0x2e>
  8009e2:	38 ca                	cmp    %cl,%dl
  8009e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009e8:	74 0f                	je     8009f9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ea:	83 c0 01             	add    $0x1,%eax
  8009ed:	0f b6 10             	movzbl (%eax),%edx
  8009f0:	84 d2                	test   %dl,%dl
  8009f2:	75 ee                	jne    8009e2 <strchr+0x17>
  8009f4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800a01:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a05:	0f b6 10             	movzbl (%eax),%edx
  800a08:	84 d2                	test   %dl,%dl
  800a0a:	74 18                	je     800a24 <strfind+0x29>
		if (*s == c)
  800a0c:	38 ca                	cmp    %cl,%dl
  800a0e:	75 0a                	jne    800a1a <strfind+0x1f>
  800a10:	eb 12                	jmp    800a24 <strfind+0x29>
  800a12:	38 ca                	cmp    %cl,%dl
  800a14:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a18:	74 0a                	je     800a24 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a1a:	83 c0 01             	add    $0x1,%eax
  800a1d:	0f b6 10             	movzbl (%eax),%edx
  800a20:	84 d2                	test   %dl,%dl
  800a22:	75 ee                	jne    800a12 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a24:	5d                   	pop    %ebp
  800a25:	c3                   	ret    

00800a26 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a26:	55                   	push   %ebp
  800a27:	89 e5                	mov    %esp,%ebp
  800a29:	83 ec 0c             	sub    $0xc,%esp
  800a2c:	89 1c 24             	mov    %ebx,(%esp)
  800a2f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a33:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a37:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a40:	85 c9                	test   %ecx,%ecx
  800a42:	74 30                	je     800a74 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a44:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a4a:	75 25                	jne    800a71 <memset+0x4b>
  800a4c:	f6 c1 03             	test   $0x3,%cl
  800a4f:	75 20                	jne    800a71 <memset+0x4b>
		c &= 0xFF;
  800a51:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a54:	89 d3                	mov    %edx,%ebx
  800a56:	c1 e3 08             	shl    $0x8,%ebx
  800a59:	89 d6                	mov    %edx,%esi
  800a5b:	c1 e6 18             	shl    $0x18,%esi
  800a5e:	89 d0                	mov    %edx,%eax
  800a60:	c1 e0 10             	shl    $0x10,%eax
  800a63:	09 f0                	or     %esi,%eax
  800a65:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800a67:	09 d8                	or     %ebx,%eax
  800a69:	c1 e9 02             	shr    $0x2,%ecx
  800a6c:	fc                   	cld    
  800a6d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a6f:	eb 03                	jmp    800a74 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a71:	fc                   	cld    
  800a72:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a74:	89 f8                	mov    %edi,%eax
  800a76:	8b 1c 24             	mov    (%esp),%ebx
  800a79:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a7d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a81:	89 ec                	mov    %ebp,%esp
  800a83:	5d                   	pop    %ebp
  800a84:	c3                   	ret    

00800a85 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a85:	55                   	push   %ebp
  800a86:	89 e5                	mov    %esp,%ebp
  800a88:	83 ec 08             	sub    $0x8,%esp
  800a8b:	89 34 24             	mov    %esi,(%esp)
  800a8e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a92:	8b 45 08             	mov    0x8(%ebp),%eax
  800a95:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800a98:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a9b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a9d:	39 c6                	cmp    %eax,%esi
  800a9f:	73 35                	jae    800ad6 <memmove+0x51>
  800aa1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800aa4:	39 d0                	cmp    %edx,%eax
  800aa6:	73 2e                	jae    800ad6 <memmove+0x51>
		s += n;
		d += n;
  800aa8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aaa:	f6 c2 03             	test   $0x3,%dl
  800aad:	75 1b                	jne    800aca <memmove+0x45>
  800aaf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ab5:	75 13                	jne    800aca <memmove+0x45>
  800ab7:	f6 c1 03             	test   $0x3,%cl
  800aba:	75 0e                	jne    800aca <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800abc:	83 ef 04             	sub    $0x4,%edi
  800abf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ac2:	c1 e9 02             	shr    $0x2,%ecx
  800ac5:	fd                   	std    
  800ac6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac8:	eb 09                	jmp    800ad3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aca:	83 ef 01             	sub    $0x1,%edi
  800acd:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ad0:	fd                   	std    
  800ad1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ad3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ad4:	eb 20                	jmp    800af6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800adc:	75 15                	jne    800af3 <memmove+0x6e>
  800ade:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ae4:	75 0d                	jne    800af3 <memmove+0x6e>
  800ae6:	f6 c1 03             	test   $0x3,%cl
  800ae9:	75 08                	jne    800af3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800aeb:	c1 e9 02             	shr    $0x2,%ecx
  800aee:	fc                   	cld    
  800aef:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af1:	eb 03                	jmp    800af6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800af3:	fc                   	cld    
  800af4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800af6:	8b 34 24             	mov    (%esp),%esi
  800af9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800afd:	89 ec                	mov    %ebp,%esp
  800aff:	5d                   	pop    %ebp
  800b00:	c3                   	ret    

00800b01 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b07:	8b 45 10             	mov    0x10(%ebp),%eax
  800b0a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b11:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b15:	8b 45 08             	mov    0x8(%ebp),%eax
  800b18:	89 04 24             	mov    %eax,(%esp)
  800b1b:	e8 65 ff ff ff       	call   800a85 <memmove>
}
  800b20:	c9                   	leave  
  800b21:	c3                   	ret    

00800b22 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	57                   	push   %edi
  800b26:	56                   	push   %esi
  800b27:	53                   	push   %ebx
  800b28:	8b 75 08             	mov    0x8(%ebp),%esi
  800b2b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b2e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b31:	85 c9                	test   %ecx,%ecx
  800b33:	74 36                	je     800b6b <memcmp+0x49>
		if (*s1 != *s2)
  800b35:	0f b6 06             	movzbl (%esi),%eax
  800b38:	0f b6 1f             	movzbl (%edi),%ebx
  800b3b:	38 d8                	cmp    %bl,%al
  800b3d:	74 20                	je     800b5f <memcmp+0x3d>
  800b3f:	eb 14                	jmp    800b55 <memcmp+0x33>
  800b41:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800b46:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800b4b:	83 c2 01             	add    $0x1,%edx
  800b4e:	83 e9 01             	sub    $0x1,%ecx
  800b51:	38 d8                	cmp    %bl,%al
  800b53:	74 12                	je     800b67 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800b55:	0f b6 c0             	movzbl %al,%eax
  800b58:	0f b6 db             	movzbl %bl,%ebx
  800b5b:	29 d8                	sub    %ebx,%eax
  800b5d:	eb 11                	jmp    800b70 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b5f:	83 e9 01             	sub    $0x1,%ecx
  800b62:	ba 00 00 00 00       	mov    $0x0,%edx
  800b67:	85 c9                	test   %ecx,%ecx
  800b69:	75 d6                	jne    800b41 <memcmp+0x1f>
  800b6b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b70:	5b                   	pop    %ebx
  800b71:	5e                   	pop    %esi
  800b72:	5f                   	pop    %edi
  800b73:	5d                   	pop    %ebp
  800b74:	c3                   	ret    

00800b75 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b7b:	89 c2                	mov    %eax,%edx
  800b7d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b80:	39 d0                	cmp    %edx,%eax
  800b82:	73 15                	jae    800b99 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b84:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b88:	38 08                	cmp    %cl,(%eax)
  800b8a:	75 06                	jne    800b92 <memfind+0x1d>
  800b8c:	eb 0b                	jmp    800b99 <memfind+0x24>
  800b8e:	38 08                	cmp    %cl,(%eax)
  800b90:	74 07                	je     800b99 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b92:	83 c0 01             	add    $0x1,%eax
  800b95:	39 c2                	cmp    %eax,%edx
  800b97:	77 f5                	ja     800b8e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	57                   	push   %edi
  800b9f:	56                   	push   %esi
  800ba0:	53                   	push   %ebx
  800ba1:	83 ec 04             	sub    $0x4,%esp
  800ba4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800baa:	0f b6 02             	movzbl (%edx),%eax
  800bad:	3c 20                	cmp    $0x20,%al
  800baf:	74 04                	je     800bb5 <strtol+0x1a>
  800bb1:	3c 09                	cmp    $0x9,%al
  800bb3:	75 0e                	jne    800bc3 <strtol+0x28>
		s++;
  800bb5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bb8:	0f b6 02             	movzbl (%edx),%eax
  800bbb:	3c 20                	cmp    $0x20,%al
  800bbd:	74 f6                	je     800bb5 <strtol+0x1a>
  800bbf:	3c 09                	cmp    $0x9,%al
  800bc1:	74 f2                	je     800bb5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bc3:	3c 2b                	cmp    $0x2b,%al
  800bc5:	75 0c                	jne    800bd3 <strtol+0x38>
		s++;
  800bc7:	83 c2 01             	add    $0x1,%edx
  800bca:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bd1:	eb 15                	jmp    800be8 <strtol+0x4d>
	else if (*s == '-')
  800bd3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bda:	3c 2d                	cmp    $0x2d,%al
  800bdc:	75 0a                	jne    800be8 <strtol+0x4d>
		s++, neg = 1;
  800bde:	83 c2 01             	add    $0x1,%edx
  800be1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800be8:	85 db                	test   %ebx,%ebx
  800bea:	0f 94 c0             	sete   %al
  800bed:	74 05                	je     800bf4 <strtol+0x59>
  800bef:	83 fb 10             	cmp    $0x10,%ebx
  800bf2:	75 18                	jne    800c0c <strtol+0x71>
  800bf4:	80 3a 30             	cmpb   $0x30,(%edx)
  800bf7:	75 13                	jne    800c0c <strtol+0x71>
  800bf9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bfd:	8d 76 00             	lea    0x0(%esi),%esi
  800c00:	75 0a                	jne    800c0c <strtol+0x71>
		s += 2, base = 16;
  800c02:	83 c2 02             	add    $0x2,%edx
  800c05:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c0a:	eb 15                	jmp    800c21 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c0c:	84 c0                	test   %al,%al
  800c0e:	66 90                	xchg   %ax,%ax
  800c10:	74 0f                	je     800c21 <strtol+0x86>
  800c12:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c17:	80 3a 30             	cmpb   $0x30,(%edx)
  800c1a:	75 05                	jne    800c21 <strtol+0x86>
		s++, base = 8;
  800c1c:	83 c2 01             	add    $0x1,%edx
  800c1f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c21:	b8 00 00 00 00       	mov    $0x0,%eax
  800c26:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c28:	0f b6 0a             	movzbl (%edx),%ecx
  800c2b:	89 cf                	mov    %ecx,%edi
  800c2d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c30:	80 fb 09             	cmp    $0x9,%bl
  800c33:	77 08                	ja     800c3d <strtol+0xa2>
			dig = *s - '0';
  800c35:	0f be c9             	movsbl %cl,%ecx
  800c38:	83 e9 30             	sub    $0x30,%ecx
  800c3b:	eb 1e                	jmp    800c5b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800c3d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800c40:	80 fb 19             	cmp    $0x19,%bl
  800c43:	77 08                	ja     800c4d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800c45:	0f be c9             	movsbl %cl,%ecx
  800c48:	83 e9 57             	sub    $0x57,%ecx
  800c4b:	eb 0e                	jmp    800c5b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800c4d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800c50:	80 fb 19             	cmp    $0x19,%bl
  800c53:	77 15                	ja     800c6a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800c55:	0f be c9             	movsbl %cl,%ecx
  800c58:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c5b:	39 f1                	cmp    %esi,%ecx
  800c5d:	7d 0b                	jge    800c6a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800c5f:	83 c2 01             	add    $0x1,%edx
  800c62:	0f af c6             	imul   %esi,%eax
  800c65:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c68:	eb be                	jmp    800c28 <strtol+0x8d>
  800c6a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800c6c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c70:	74 05                	je     800c77 <strtol+0xdc>
		*endptr = (char *) s;
  800c72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c75:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c77:	89 ca                	mov    %ecx,%edx
  800c79:	f7 da                	neg    %edx
  800c7b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c7f:	0f 45 c2             	cmovne %edx,%eax
}
  800c82:	83 c4 04             	add    $0x4,%esp
  800c85:	5b                   	pop    %ebx
  800c86:	5e                   	pop    %esi
  800c87:	5f                   	pop    %edi
  800c88:	5d                   	pop    %ebp
  800c89:	c3                   	ret    
	...

00800c8c <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c8c:	55                   	push   %ebp
  800c8d:	89 e5                	mov    %esp,%ebp
  800c8f:	83 ec 48             	sub    $0x48,%esp
  800c92:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c95:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c98:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c9b:	89 c6                	mov    %eax,%esi
  800c9d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800ca0:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800ca2:	8b 7d 10             	mov    0x10(%ebp),%edi
  800ca5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ca8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cab:	51                   	push   %ecx
  800cac:	52                   	push   %edx
  800cad:	53                   	push   %ebx
  800cae:	54                   	push   %esp
  800caf:	55                   	push   %ebp
  800cb0:	56                   	push   %esi
  800cb1:	57                   	push   %edi
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	8d 35 bc 0c 80 00    	lea    0x800cbc,%esi
  800cba:	0f 34                	sysenter 

00800cbc <.after_sysenter_label>:
  800cbc:	5f                   	pop    %edi
  800cbd:	5e                   	pop    %esi
  800cbe:	5d                   	pop    %ebp
  800cbf:	5c                   	pop    %esp
  800cc0:	5b                   	pop    %ebx
  800cc1:	5a                   	pop    %edx
  800cc2:	59                   	pop    %ecx
  800cc3:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800cc5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800cc9:	74 28                	je     800cf3 <.after_sysenter_label+0x37>
  800ccb:	85 c0                	test   %eax,%eax
  800ccd:	7e 24                	jle    800cf3 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ccf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cd3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800cd7:	c7 44 24 08 20 27 80 	movl   $0x802720,0x8(%esp)
  800cde:	00 
  800cdf:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800ce6:	00 
  800ce7:	c7 04 24 3d 27 80 00 	movl   $0x80273d,(%esp)
  800cee:	e8 31 12 00 00       	call   801f24 <_panic>

	return ret;
}
  800cf3:	89 d0                	mov    %edx,%eax
  800cf5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cf8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cfb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cfe:	89 ec                	mov    %ebp,%esp
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    

00800d02 <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  800d08:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d0f:	00 
  800d10:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d17:	00 
  800d18:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d1f:	00 
  800d20:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d23:	89 04 24             	mov    %eax,(%esp)
  800d26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d29:	ba 00 00 00 00       	mov    $0x0,%edx
  800d2e:	b8 10 00 00 00       	mov    $0x10,%eax
  800d33:	e8 54 ff ff ff       	call   800c8c <syscall>
}
  800d38:	c9                   	leave  
  800d39:	c3                   	ret    

00800d3a <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800d3a:	55                   	push   %ebp
  800d3b:	89 e5                	mov    %esp,%ebp
  800d3d:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  800d40:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d47:	00 
  800d48:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d4f:	00 
  800d50:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d57:	00 
  800d58:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d5f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d64:	ba 00 00 00 00       	mov    $0x0,%edx
  800d69:	b8 0f 00 00 00       	mov    $0xf,%eax
  800d6e:	e8 19 ff ff ff       	call   800c8c <syscall>
}
  800d73:	c9                   	leave  
  800d74:	c3                   	ret    

00800d75 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800d75:	55                   	push   %ebp
  800d76:	89 e5                	mov    %esp,%ebp
  800d78:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d7b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d82:	00 
  800d83:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d8a:	00 
  800d8b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d92:	00 
  800d93:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d9a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d9d:	ba 01 00 00 00       	mov    $0x1,%edx
  800da2:	b8 0e 00 00 00       	mov    $0xe,%eax
  800da7:	e8 e0 fe ff ff       	call   800c8c <syscall>
}
  800dac:	c9                   	leave  
  800dad:	c3                   	ret    

00800dae <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dae:	55                   	push   %ebp
  800daf:	89 e5                	mov    %esp,%ebp
  800db1:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800db4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dbb:	00 
  800dbc:	8b 45 14             	mov    0x14(%ebp),%eax
  800dbf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800dc3:	8b 45 10             	mov    0x10(%ebp),%eax
  800dc6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800dca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dcd:	89 04 24             	mov    %eax,(%esp)
  800dd0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd3:	ba 00 00 00 00       	mov    $0x0,%edx
  800dd8:	b8 0d 00 00 00       	mov    $0xd,%eax
  800ddd:	e8 aa fe ff ff       	call   800c8c <syscall>
}
  800de2:	c9                   	leave  
  800de3:	c3                   	ret    

00800de4 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800de4:	55                   	push   %ebp
  800de5:	89 e5                	mov    %esp,%ebp
  800de7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800dea:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800df1:	00 
  800df2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800df9:	00 
  800dfa:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e01:	00 
  800e02:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e05:	89 04 24             	mov    %eax,(%esp)
  800e08:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0b:	ba 01 00 00 00       	mov    $0x1,%edx
  800e10:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e15:	e8 72 fe ff ff       	call   800c8c <syscall>
}
  800e1a:	c9                   	leave  
  800e1b:	c3                   	ret    

00800e1c <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e1c:	55                   	push   %ebp
  800e1d:	89 e5                	mov    %esp,%ebp
  800e1f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800e22:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e29:	00 
  800e2a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e31:	00 
  800e32:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e39:	00 
  800e3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e3d:	89 04 24             	mov    %eax,(%esp)
  800e40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e43:	ba 01 00 00 00       	mov    $0x1,%edx
  800e48:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e4d:	e8 3a fe ff ff       	call   800c8c <syscall>
}
  800e52:	c9                   	leave  
  800e53:	c3                   	ret    

00800e54 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800e5a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e61:	00 
  800e62:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e69:	00 
  800e6a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e71:	00 
  800e72:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e75:	89 04 24             	mov    %eax,(%esp)
  800e78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7b:	ba 01 00 00 00       	mov    $0x1,%edx
  800e80:	b8 09 00 00 00       	mov    $0x9,%eax
  800e85:	e8 02 fe ff ff       	call   800c8c <syscall>
}
  800e8a:	c9                   	leave  
  800e8b:	c3                   	ret    

00800e8c <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800e8c:	55                   	push   %ebp
  800e8d:	89 e5                	mov    %esp,%ebp
  800e8f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800e92:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e99:	00 
  800e9a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ea1:	00 
  800ea2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ea9:	00 
  800eaa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ead:	89 04 24             	mov    %eax,(%esp)
  800eb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb3:	ba 01 00 00 00       	mov    $0x1,%edx
  800eb8:	b8 07 00 00 00       	mov    $0x7,%eax
  800ebd:	e8 ca fd ff ff       	call   800c8c <syscall>
}
  800ec2:	c9                   	leave  
  800ec3:	c3                   	ret    

00800ec4 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ec4:	55                   	push   %ebp
  800ec5:	89 e5                	mov    %esp,%ebp
  800ec7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800eca:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ed1:	00 
  800ed2:	8b 45 18             	mov    0x18(%ebp),%eax
  800ed5:	0b 45 14             	or     0x14(%ebp),%eax
  800ed8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800edc:	8b 45 10             	mov    0x10(%ebp),%eax
  800edf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ee3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ee6:	89 04 24             	mov    %eax,(%esp)
  800ee9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eec:	ba 01 00 00 00       	mov    $0x1,%edx
  800ef1:	b8 06 00 00 00       	mov    $0x6,%eax
  800ef6:	e8 91 fd ff ff       	call   800c8c <syscall>
}
  800efb:	c9                   	leave  
  800efc:	c3                   	ret    

00800efd <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800efd:	55                   	push   %ebp
  800efe:	89 e5                	mov    %esp,%ebp
  800f00:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f03:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f0a:	00 
  800f0b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f12:	00 
  800f13:	8b 45 10             	mov    0x10(%ebp),%eax
  800f16:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1d:	89 04 24             	mov    %eax,(%esp)
  800f20:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f23:	ba 01 00 00 00       	mov    $0x1,%edx
  800f28:	b8 05 00 00 00       	mov    $0x5,%eax
  800f2d:	e8 5a fd ff ff       	call   800c8c <syscall>
}
  800f32:	c9                   	leave  
  800f33:	c3                   	ret    

00800f34 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800f3a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f41:	00 
  800f42:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f49:	00 
  800f4a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f51:	00 
  800f52:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f59:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f63:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f68:	e8 1f fd ff ff       	call   800c8c <syscall>
}
  800f6d:	c9                   	leave  
  800f6e:	c3                   	ret    

00800f6f <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800f6f:	55                   	push   %ebp
  800f70:	89 e5                	mov    %esp,%ebp
  800f72:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  800f75:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f7c:	00 
  800f7d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f84:	00 
  800f85:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f8c:	00 
  800f8d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f90:	89 04 24             	mov    %eax,(%esp)
  800f93:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f96:	ba 00 00 00 00       	mov    $0x0,%edx
  800f9b:	b8 04 00 00 00       	mov    $0x4,%eax
  800fa0:	e8 e7 fc ff ff       	call   800c8c <syscall>
}
  800fa5:	c9                   	leave  
  800fa6:	c3                   	ret    

00800fa7 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800fa7:	55                   	push   %ebp
  800fa8:	89 e5                	mov    %esp,%ebp
  800faa:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800fad:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fb4:	00 
  800fb5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fbc:	00 
  800fbd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fc4:	00 
  800fc5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fcc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fd1:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd6:	b8 02 00 00 00       	mov    $0x2,%eax
  800fdb:	e8 ac fc ff ff       	call   800c8c <syscall>
}
  800fe0:	c9                   	leave  
  800fe1:	c3                   	ret    

00800fe2 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800fe2:	55                   	push   %ebp
  800fe3:	89 e5                	mov    %esp,%ebp
  800fe5:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800fe8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fef:	00 
  800ff0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ff7:	00 
  800ff8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fff:	00 
  801000:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801007:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80100a:	ba 01 00 00 00       	mov    $0x1,%edx
  80100f:	b8 03 00 00 00       	mov    $0x3,%eax
  801014:	e8 73 fc ff ff       	call   800c8c <syscall>
}
  801019:	c9                   	leave  
  80101a:	c3                   	ret    

0080101b <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  801021:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801028:	00 
  801029:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801030:	00 
  801031:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801038:	00 
  801039:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801040:	b9 00 00 00 00       	mov    $0x0,%ecx
  801045:	ba 00 00 00 00       	mov    $0x0,%edx
  80104a:	b8 01 00 00 00       	mov    $0x1,%eax
  80104f:	e8 38 fc ff ff       	call   800c8c <syscall>
}
  801054:	c9                   	leave  
  801055:	c3                   	ret    

00801056 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801056:	55                   	push   %ebp
  801057:	89 e5                	mov    %esp,%ebp
  801059:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80105c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801063:	00 
  801064:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80106b:	00 
  80106c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801073:	00 
  801074:	8b 45 0c             	mov    0xc(%ebp),%eax
  801077:	89 04 24             	mov    %eax,(%esp)
  80107a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80107d:	ba 00 00 00 00       	mov    $0x0,%edx
  801082:	b8 00 00 00 00       	mov    $0x0,%eax
  801087:	e8 00 fc ff ff       	call   800c8c <syscall>
}
  80108c:	c9                   	leave  
  80108d:	c3                   	ret    
	...

00801090 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801090:	55                   	push   %ebp
  801091:	89 e5                	mov    %esp,%ebp
  801093:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801096:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  80109d:	75 54                	jne    8010f3 <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  80109f:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8010a6:	00 
  8010a7:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8010ae:	ee 
  8010af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010b6:	e8 42 fe ff ff       	call   800efd <sys_page_alloc>
  8010bb:	85 c0                	test   %eax,%eax
  8010bd:	79 20                	jns    8010df <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  8010bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8010c3:	c7 44 24 08 4b 27 80 	movl   $0x80274b,0x8(%esp)
  8010ca:	00 
  8010cb:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8010d2:	00 
  8010d3:	c7 04 24 63 27 80 00 	movl   $0x802763,(%esp)
  8010da:	e8 45 0e 00 00       	call   801f24 <_panic>
		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  8010df:	c7 44 24 04 00 11 80 	movl   $0x801100,0x4(%esp)
  8010e6:	00 
  8010e7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010ee:	e8 f1 fc ff ff       	call   800de4 <sys_env_set_pgfault_upcall>

			//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8010f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f6:	a3 0c 40 80 00       	mov    %eax,0x80400c
}
  8010fb:	c9                   	leave  
  8010fc:	c3                   	ret    
  8010fd:	00 00                	add    %al,(%eax)
	...

00801100 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801100:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801101:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  801106:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801108:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 0x30(%esp), %eax
  80110b:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80110f:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  801112:	89 44 24 30          	mov    %eax,0x30(%esp)
	# put old eip in the pre-reserved 4 bytes space
	movl 0x28(%esp), %ebx
  801116:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  80111a:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	addl $0x8, %esp
  80111c:	83 c4 08             	add    $0x8,%esp
	popal
  80111f:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $0x4, %esp
  801120:	83 c4 04             	add    $0x4,%esp
	popfl
  801123:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  801124:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  801125:	c3                   	ret    
	...

00801130 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801130:	55                   	push   %ebp
  801131:	89 e5                	mov    %esp,%ebp
  801133:	8b 45 08             	mov    0x8(%ebp),%eax
  801136:	05 00 00 00 30       	add    $0x30000000,%eax
  80113b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80113e:	5d                   	pop    %ebp
  80113f:	c3                   	ret    

00801140 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801146:	8b 45 08             	mov    0x8(%ebp),%eax
  801149:	89 04 24             	mov    %eax,(%esp)
  80114c:	e8 df ff ff ff       	call   801130 <fd2num>
  801151:	05 20 00 0d 00       	add    $0xd0020,%eax
  801156:	c1 e0 0c             	shl    $0xc,%eax
}
  801159:	c9                   	leave  
  80115a:	c3                   	ret    

0080115b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80115b:	55                   	push   %ebp
  80115c:	89 e5                	mov    %esp,%ebp
  80115e:	57                   	push   %edi
  80115f:	56                   	push   %esi
  801160:	53                   	push   %ebx
  801161:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801164:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801169:	a8 01                	test   $0x1,%al
  80116b:	74 36                	je     8011a3 <fd_alloc+0x48>
  80116d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801172:	a8 01                	test   $0x1,%al
  801174:	74 2d                	je     8011a3 <fd_alloc+0x48>
  801176:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80117b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801180:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801185:	89 c3                	mov    %eax,%ebx
  801187:	89 c2                	mov    %eax,%edx
  801189:	c1 ea 16             	shr    $0x16,%edx
  80118c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80118f:	f6 c2 01             	test   $0x1,%dl
  801192:	74 14                	je     8011a8 <fd_alloc+0x4d>
  801194:	89 c2                	mov    %eax,%edx
  801196:	c1 ea 0c             	shr    $0xc,%edx
  801199:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80119c:	f6 c2 01             	test   $0x1,%dl
  80119f:	75 10                	jne    8011b1 <fd_alloc+0x56>
  8011a1:	eb 05                	jmp    8011a8 <fd_alloc+0x4d>
  8011a3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8011a8:	89 1f                	mov    %ebx,(%edi)
  8011aa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8011af:	eb 17                	jmp    8011c8 <fd_alloc+0x6d>
  8011b1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011b6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011bb:	75 c8                	jne    801185 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011bd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8011c3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8011c8:	5b                   	pop    %ebx
  8011c9:	5e                   	pop    %esi
  8011ca:	5f                   	pop    %edi
  8011cb:	5d                   	pop    %ebp
  8011cc:	c3                   	ret    

008011cd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011cd:	55                   	push   %ebp
  8011ce:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011d3:	83 f8 1f             	cmp    $0x1f,%eax
  8011d6:	77 36                	ja     80120e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011d8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8011dd:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8011e0:	89 c2                	mov    %eax,%edx
  8011e2:	c1 ea 16             	shr    $0x16,%edx
  8011e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011ec:	f6 c2 01             	test   $0x1,%dl
  8011ef:	74 1d                	je     80120e <fd_lookup+0x41>
  8011f1:	89 c2                	mov    %eax,%edx
  8011f3:	c1 ea 0c             	shr    $0xc,%edx
  8011f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011fd:	f6 c2 01             	test   $0x1,%dl
  801200:	74 0c                	je     80120e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801202:	8b 55 0c             	mov    0xc(%ebp),%edx
  801205:	89 02                	mov    %eax,(%edx)
  801207:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80120c:	eb 05                	jmp    801213 <fd_lookup+0x46>
  80120e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801213:	5d                   	pop    %ebp
  801214:	c3                   	ret    

00801215 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801215:	55                   	push   %ebp
  801216:	89 e5                	mov    %esp,%ebp
  801218:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80121b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80121e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801222:	8b 45 08             	mov    0x8(%ebp),%eax
  801225:	89 04 24             	mov    %eax,(%esp)
  801228:	e8 a0 ff ff ff       	call   8011cd <fd_lookup>
  80122d:	85 c0                	test   %eax,%eax
  80122f:	78 0e                	js     80123f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801231:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801234:	8b 55 0c             	mov    0xc(%ebp),%edx
  801237:	89 50 04             	mov    %edx,0x4(%eax)
  80123a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80123f:	c9                   	leave  
  801240:	c3                   	ret    

00801241 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801241:	55                   	push   %ebp
  801242:	89 e5                	mov    %esp,%ebp
  801244:	56                   	push   %esi
  801245:	53                   	push   %ebx
  801246:	83 ec 10             	sub    $0x10,%esp
  801249:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80124c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80124f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801254:	b8 04 30 80 00       	mov    $0x803004,%eax
  801259:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80125f:	75 11                	jne    801272 <dev_lookup+0x31>
  801261:	eb 04                	jmp    801267 <dev_lookup+0x26>
  801263:	39 08                	cmp    %ecx,(%eax)
  801265:	75 10                	jne    801277 <dev_lookup+0x36>
			*dev = devtab[i];
  801267:	89 03                	mov    %eax,(%ebx)
  801269:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80126e:	66 90                	xchg   %ax,%ax
  801270:	eb 36                	jmp    8012a8 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801272:	be f0 27 80 00       	mov    $0x8027f0,%esi
  801277:	83 c2 01             	add    $0x1,%edx
  80127a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80127d:	85 c0                	test   %eax,%eax
  80127f:	75 e2                	jne    801263 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801281:	a1 08 40 80 00       	mov    0x804008,%eax
  801286:	8b 40 48             	mov    0x48(%eax),%eax
  801289:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80128d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801291:	c7 04 24 74 27 80 00 	movl   $0x802774,(%esp)
  801298:	e8 c4 ee ff ff       	call   800161 <cprintf>
	*dev = 0;
  80129d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8012a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8012a8:	83 c4 10             	add    $0x10,%esp
  8012ab:	5b                   	pop    %ebx
  8012ac:	5e                   	pop    %esi
  8012ad:	5d                   	pop    %ebp
  8012ae:	c3                   	ret    

008012af <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8012af:	55                   	push   %ebp
  8012b0:	89 e5                	mov    %esp,%ebp
  8012b2:	53                   	push   %ebx
  8012b3:	83 ec 24             	sub    $0x24,%esp
  8012b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8012c3:	89 04 24             	mov    %eax,(%esp)
  8012c6:	e8 02 ff ff ff       	call   8011cd <fd_lookup>
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	78 53                	js     801322 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d9:	8b 00                	mov    (%eax),%eax
  8012db:	89 04 24             	mov    %eax,(%esp)
  8012de:	e8 5e ff ff ff       	call   801241 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012e3:	85 c0                	test   %eax,%eax
  8012e5:	78 3b                	js     801322 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8012e7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012ef:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8012f3:	74 2d                	je     801322 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012f5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012f8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012ff:	00 00 00 
	stat->st_isdir = 0;
  801302:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801309:	00 00 00 
	stat->st_dev = dev;
  80130c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80130f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801315:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801319:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80131c:	89 14 24             	mov    %edx,(%esp)
  80131f:	ff 50 14             	call   *0x14(%eax)
}
  801322:	83 c4 24             	add    $0x24,%esp
  801325:	5b                   	pop    %ebx
  801326:	5d                   	pop    %ebp
  801327:	c3                   	ret    

00801328 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801328:	55                   	push   %ebp
  801329:	89 e5                	mov    %esp,%ebp
  80132b:	53                   	push   %ebx
  80132c:	83 ec 24             	sub    $0x24,%esp
  80132f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801332:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801335:	89 44 24 04          	mov    %eax,0x4(%esp)
  801339:	89 1c 24             	mov    %ebx,(%esp)
  80133c:	e8 8c fe ff ff       	call   8011cd <fd_lookup>
  801341:	85 c0                	test   %eax,%eax
  801343:	78 5f                	js     8013a4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801345:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801348:	89 44 24 04          	mov    %eax,0x4(%esp)
  80134c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134f:	8b 00                	mov    (%eax),%eax
  801351:	89 04 24             	mov    %eax,(%esp)
  801354:	e8 e8 fe ff ff       	call   801241 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801359:	85 c0                	test   %eax,%eax
  80135b:	78 47                	js     8013a4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80135d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801360:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801364:	75 23                	jne    801389 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801366:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80136b:	8b 40 48             	mov    0x48(%eax),%eax
  80136e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801372:	89 44 24 04          	mov    %eax,0x4(%esp)
  801376:	c7 04 24 94 27 80 00 	movl   $0x802794,(%esp)
  80137d:	e8 df ed ff ff       	call   800161 <cprintf>
  801382:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801387:	eb 1b                	jmp    8013a4 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801389:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80138c:	8b 48 18             	mov    0x18(%eax),%ecx
  80138f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801394:	85 c9                	test   %ecx,%ecx
  801396:	74 0c                	je     8013a4 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801398:	8b 45 0c             	mov    0xc(%ebp),%eax
  80139b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80139f:	89 14 24             	mov    %edx,(%esp)
  8013a2:	ff d1                	call   *%ecx
}
  8013a4:	83 c4 24             	add    $0x24,%esp
  8013a7:	5b                   	pop    %ebx
  8013a8:	5d                   	pop    %ebp
  8013a9:	c3                   	ret    

008013aa <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013aa:	55                   	push   %ebp
  8013ab:	89 e5                	mov    %esp,%ebp
  8013ad:	53                   	push   %ebx
  8013ae:	83 ec 24             	sub    $0x24,%esp
  8013b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013bb:	89 1c 24             	mov    %ebx,(%esp)
  8013be:	e8 0a fe ff ff       	call   8011cd <fd_lookup>
  8013c3:	85 c0                	test   %eax,%eax
  8013c5:	78 66                	js     80142d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013d1:	8b 00                	mov    (%eax),%eax
  8013d3:	89 04 24             	mov    %eax,(%esp)
  8013d6:	e8 66 fe ff ff       	call   801241 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013db:	85 c0                	test   %eax,%eax
  8013dd:	78 4e                	js     80142d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8013df:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013e2:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8013e6:	75 23                	jne    80140b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8013e8:	a1 08 40 80 00       	mov    0x804008,%eax
  8013ed:	8b 40 48             	mov    0x48(%eax),%eax
  8013f0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8013f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013f8:	c7 04 24 b5 27 80 00 	movl   $0x8027b5,(%esp)
  8013ff:	e8 5d ed ff ff       	call   800161 <cprintf>
  801404:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801409:	eb 22                	jmp    80142d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80140b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80140e:	8b 48 0c             	mov    0xc(%eax),%ecx
  801411:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801416:	85 c9                	test   %ecx,%ecx
  801418:	74 13                	je     80142d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80141a:	8b 45 10             	mov    0x10(%ebp),%eax
  80141d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801421:	8b 45 0c             	mov    0xc(%ebp),%eax
  801424:	89 44 24 04          	mov    %eax,0x4(%esp)
  801428:	89 14 24             	mov    %edx,(%esp)
  80142b:	ff d1                	call   *%ecx
}
  80142d:	83 c4 24             	add    $0x24,%esp
  801430:	5b                   	pop    %ebx
  801431:	5d                   	pop    %ebp
  801432:	c3                   	ret    

00801433 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801433:	55                   	push   %ebp
  801434:	89 e5                	mov    %esp,%ebp
  801436:	53                   	push   %ebx
  801437:	83 ec 24             	sub    $0x24,%esp
  80143a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80143d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801440:	89 44 24 04          	mov    %eax,0x4(%esp)
  801444:	89 1c 24             	mov    %ebx,(%esp)
  801447:	e8 81 fd ff ff       	call   8011cd <fd_lookup>
  80144c:	85 c0                	test   %eax,%eax
  80144e:	78 6b                	js     8014bb <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801450:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801453:	89 44 24 04          	mov    %eax,0x4(%esp)
  801457:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80145a:	8b 00                	mov    (%eax),%eax
  80145c:	89 04 24             	mov    %eax,(%esp)
  80145f:	e8 dd fd ff ff       	call   801241 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801464:	85 c0                	test   %eax,%eax
  801466:	78 53                	js     8014bb <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801468:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80146b:	8b 42 08             	mov    0x8(%edx),%eax
  80146e:	83 e0 03             	and    $0x3,%eax
  801471:	83 f8 01             	cmp    $0x1,%eax
  801474:	75 23                	jne    801499 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801476:	a1 08 40 80 00       	mov    0x804008,%eax
  80147b:	8b 40 48             	mov    0x48(%eax),%eax
  80147e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801482:	89 44 24 04          	mov    %eax,0x4(%esp)
  801486:	c7 04 24 d2 27 80 00 	movl   $0x8027d2,(%esp)
  80148d:	e8 cf ec ff ff       	call   800161 <cprintf>
  801492:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801497:	eb 22                	jmp    8014bb <read+0x88>
	}
	if (!dev->dev_read)
  801499:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80149c:	8b 48 08             	mov    0x8(%eax),%ecx
  80149f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014a4:	85 c9                	test   %ecx,%ecx
  8014a6:	74 13                	je     8014bb <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8014ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b6:	89 14 24             	mov    %edx,(%esp)
  8014b9:	ff d1                	call   *%ecx
}
  8014bb:	83 c4 24             	add    $0x24,%esp
  8014be:	5b                   	pop    %ebx
  8014bf:	5d                   	pop    %ebp
  8014c0:	c3                   	ret    

008014c1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014c1:	55                   	push   %ebp
  8014c2:	89 e5                	mov    %esp,%ebp
  8014c4:	57                   	push   %edi
  8014c5:	56                   	push   %esi
  8014c6:	53                   	push   %ebx
  8014c7:	83 ec 1c             	sub    $0x1c,%esp
  8014ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014cd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014da:	b8 00 00 00 00       	mov    $0x0,%eax
  8014df:	85 f6                	test   %esi,%esi
  8014e1:	74 29                	je     80150c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8014e3:	89 f0                	mov    %esi,%eax
  8014e5:	29 d0                	sub    %edx,%eax
  8014e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8014eb:	03 55 0c             	add    0xc(%ebp),%edx
  8014ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014f2:	89 3c 24             	mov    %edi,(%esp)
  8014f5:	e8 39 ff ff ff       	call   801433 <read>
		if (m < 0)
  8014fa:	85 c0                	test   %eax,%eax
  8014fc:	78 0e                	js     80150c <readn+0x4b>
			return m;
		if (m == 0)
  8014fe:	85 c0                	test   %eax,%eax
  801500:	74 08                	je     80150a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801502:	01 c3                	add    %eax,%ebx
  801504:	89 da                	mov    %ebx,%edx
  801506:	39 f3                	cmp    %esi,%ebx
  801508:	72 d9                	jb     8014e3 <readn+0x22>
  80150a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80150c:	83 c4 1c             	add    $0x1c,%esp
  80150f:	5b                   	pop    %ebx
  801510:	5e                   	pop    %esi
  801511:	5f                   	pop    %edi
  801512:	5d                   	pop    %ebp
  801513:	c3                   	ret    

00801514 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801514:	55                   	push   %ebp
  801515:	89 e5                	mov    %esp,%ebp
  801517:	83 ec 28             	sub    $0x28,%esp
  80151a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80151d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801520:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801523:	89 34 24             	mov    %esi,(%esp)
  801526:	e8 05 fc ff ff       	call   801130 <fd2num>
  80152b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80152e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801532:	89 04 24             	mov    %eax,(%esp)
  801535:	e8 93 fc ff ff       	call   8011cd <fd_lookup>
  80153a:	89 c3                	mov    %eax,%ebx
  80153c:	85 c0                	test   %eax,%eax
  80153e:	78 05                	js     801545 <fd_close+0x31>
  801540:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801543:	74 0e                	je     801553 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801545:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801549:	b8 00 00 00 00       	mov    $0x0,%eax
  80154e:	0f 44 d8             	cmove  %eax,%ebx
  801551:	eb 3d                	jmp    801590 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801553:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801556:	89 44 24 04          	mov    %eax,0x4(%esp)
  80155a:	8b 06                	mov    (%esi),%eax
  80155c:	89 04 24             	mov    %eax,(%esp)
  80155f:	e8 dd fc ff ff       	call   801241 <dev_lookup>
  801564:	89 c3                	mov    %eax,%ebx
  801566:	85 c0                	test   %eax,%eax
  801568:	78 16                	js     801580 <fd_close+0x6c>
		if (dev->dev_close)
  80156a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156d:	8b 40 10             	mov    0x10(%eax),%eax
  801570:	bb 00 00 00 00       	mov    $0x0,%ebx
  801575:	85 c0                	test   %eax,%eax
  801577:	74 07                	je     801580 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801579:	89 34 24             	mov    %esi,(%esp)
  80157c:	ff d0                	call   *%eax
  80157e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801580:	89 74 24 04          	mov    %esi,0x4(%esp)
  801584:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80158b:	e8 fc f8 ff ff       	call   800e8c <sys_page_unmap>
	return r;
}
  801590:	89 d8                	mov    %ebx,%eax
  801592:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801595:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801598:	89 ec                	mov    %ebp,%esp
  80159a:	5d                   	pop    %ebp
  80159b:	c3                   	ret    

0080159c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80159c:	55                   	push   %ebp
  80159d:	89 e5                	mov    %esp,%ebp
  80159f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015ac:	89 04 24             	mov    %eax,(%esp)
  8015af:	e8 19 fc ff ff       	call   8011cd <fd_lookup>
  8015b4:	85 c0                	test   %eax,%eax
  8015b6:	78 13                	js     8015cb <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8015b8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8015bf:	00 
  8015c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c3:	89 04 24             	mov    %eax,(%esp)
  8015c6:	e8 49 ff ff ff       	call   801514 <fd_close>
}
  8015cb:	c9                   	leave  
  8015cc:	c3                   	ret    

008015cd <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8015cd:	55                   	push   %ebp
  8015ce:	89 e5                	mov    %esp,%ebp
  8015d0:	83 ec 18             	sub    $0x18,%esp
  8015d3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8015d6:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015d9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8015e0:	00 
  8015e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e4:	89 04 24             	mov    %eax,(%esp)
  8015e7:	e8 78 03 00 00       	call   801964 <open>
  8015ec:	89 c3                	mov    %eax,%ebx
  8015ee:	85 c0                	test   %eax,%eax
  8015f0:	78 1b                	js     80160d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8015f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015f9:	89 1c 24             	mov    %ebx,(%esp)
  8015fc:	e8 ae fc ff ff       	call   8012af <fstat>
  801601:	89 c6                	mov    %eax,%esi
	close(fd);
  801603:	89 1c 24             	mov    %ebx,(%esp)
  801606:	e8 91 ff ff ff       	call   80159c <close>
  80160b:	89 f3                	mov    %esi,%ebx
	return r;
}
  80160d:	89 d8                	mov    %ebx,%eax
  80160f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801612:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801615:	89 ec                	mov    %ebp,%esp
  801617:	5d                   	pop    %ebp
  801618:	c3                   	ret    

00801619 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801619:	55                   	push   %ebp
  80161a:	89 e5                	mov    %esp,%ebp
  80161c:	53                   	push   %ebx
  80161d:	83 ec 14             	sub    $0x14,%esp
  801620:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801625:	89 1c 24             	mov    %ebx,(%esp)
  801628:	e8 6f ff ff ff       	call   80159c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80162d:	83 c3 01             	add    $0x1,%ebx
  801630:	83 fb 20             	cmp    $0x20,%ebx
  801633:	75 f0                	jne    801625 <close_all+0xc>
		close(i);
}
  801635:	83 c4 14             	add    $0x14,%esp
  801638:	5b                   	pop    %ebx
  801639:	5d                   	pop    %ebp
  80163a:	c3                   	ret    

0080163b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80163b:	55                   	push   %ebp
  80163c:	89 e5                	mov    %esp,%ebp
  80163e:	83 ec 58             	sub    $0x58,%esp
  801641:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801644:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801647:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80164a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80164d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801650:	89 44 24 04          	mov    %eax,0x4(%esp)
  801654:	8b 45 08             	mov    0x8(%ebp),%eax
  801657:	89 04 24             	mov    %eax,(%esp)
  80165a:	e8 6e fb ff ff       	call   8011cd <fd_lookup>
  80165f:	89 c3                	mov    %eax,%ebx
  801661:	85 c0                	test   %eax,%eax
  801663:	0f 88 e0 00 00 00    	js     801749 <dup+0x10e>
		return r;
	close(newfdnum);
  801669:	89 3c 24             	mov    %edi,(%esp)
  80166c:	e8 2b ff ff ff       	call   80159c <close>

	newfd = INDEX2FD(newfdnum);
  801671:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801677:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80167a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80167d:	89 04 24             	mov    %eax,(%esp)
  801680:	e8 bb fa ff ff       	call   801140 <fd2data>
  801685:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801687:	89 34 24             	mov    %esi,(%esp)
  80168a:	e8 b1 fa ff ff       	call   801140 <fd2data>
  80168f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801692:	89 da                	mov    %ebx,%edx
  801694:	89 d8                	mov    %ebx,%eax
  801696:	c1 e8 16             	shr    $0x16,%eax
  801699:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016a0:	a8 01                	test   $0x1,%al
  8016a2:	74 43                	je     8016e7 <dup+0xac>
  8016a4:	c1 ea 0c             	shr    $0xc,%edx
  8016a7:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8016ae:	a8 01                	test   $0x1,%al
  8016b0:	74 35                	je     8016e7 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016b2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8016b9:	25 07 0e 00 00       	and    $0xe07,%eax
  8016be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8016c2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8016c9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016d0:	00 
  8016d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8016d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016dc:	e8 e3 f7 ff ff       	call   800ec4 <sys_page_map>
  8016e1:	89 c3                	mov    %eax,%ebx
  8016e3:	85 c0                	test   %eax,%eax
  8016e5:	78 3f                	js     801726 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016ea:	89 c2                	mov    %eax,%edx
  8016ec:	c1 ea 0c             	shr    $0xc,%edx
  8016ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016f6:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8016fc:	89 54 24 10          	mov    %edx,0x10(%esp)
  801700:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801704:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80170b:	00 
  80170c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801710:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801717:	e8 a8 f7 ff ff       	call   800ec4 <sys_page_map>
  80171c:	89 c3                	mov    %eax,%ebx
  80171e:	85 c0                	test   %eax,%eax
  801720:	78 04                	js     801726 <dup+0xeb>
  801722:	89 fb                	mov    %edi,%ebx
  801724:	eb 23                	jmp    801749 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801726:	89 74 24 04          	mov    %esi,0x4(%esp)
  80172a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801731:	e8 56 f7 ff ff       	call   800e8c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801736:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801739:	89 44 24 04          	mov    %eax,0x4(%esp)
  80173d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801744:	e8 43 f7 ff ff       	call   800e8c <sys_page_unmap>
	return r;
}
  801749:	89 d8                	mov    %ebx,%eax
  80174b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80174e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801751:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801754:	89 ec                	mov    %ebp,%esp
  801756:	5d                   	pop    %ebp
  801757:	c3                   	ret    

00801758 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801758:	55                   	push   %ebp
  801759:	89 e5                	mov    %esp,%ebp
  80175b:	83 ec 18             	sub    $0x18,%esp
  80175e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801761:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801764:	89 c3                	mov    %eax,%ebx
  801766:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801768:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80176f:	75 11                	jne    801782 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801771:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801778:	e8 03 08 00 00       	call   801f80 <ipc_find_env>
  80177d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801782:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801789:	00 
  80178a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801791:	00 
  801792:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801796:	a1 00 40 80 00       	mov    0x804000,%eax
  80179b:	89 04 24             	mov    %eax,(%esp)
  80179e:	e8 26 08 00 00       	call   801fc9 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8017a3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8017aa:	00 
  8017ab:	89 74 24 04          	mov    %esi,0x4(%esp)
  8017af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8017b6:	e8 79 08 00 00       	call   802034 <ipc_recv>
}
  8017bb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8017be:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8017c1:	89 ec                	mov    %ebp,%esp
  8017c3:	5d                   	pop    %ebp
  8017c4:	c3                   	ret    

008017c5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8017c5:	55                   	push   %ebp
  8017c6:	89 e5                	mov    %esp,%ebp
  8017c8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8017cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8017d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017d9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8017de:	ba 00 00 00 00       	mov    $0x0,%edx
  8017e3:	b8 02 00 00 00       	mov    $0x2,%eax
  8017e8:	e8 6b ff ff ff       	call   801758 <fsipc>
}
  8017ed:	c9                   	leave  
  8017ee:	c3                   	ret    

008017ef <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017ef:	55                   	push   %ebp
  8017f0:	89 e5                	mov    %esp,%ebp
  8017f2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f8:	8b 40 0c             	mov    0xc(%eax),%eax
  8017fb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801800:	ba 00 00 00 00       	mov    $0x0,%edx
  801805:	b8 06 00 00 00       	mov    $0x6,%eax
  80180a:	e8 49 ff ff ff       	call   801758 <fsipc>
}
  80180f:	c9                   	leave  
  801810:	c3                   	ret    

00801811 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801811:	55                   	push   %ebp
  801812:	89 e5                	mov    %esp,%ebp
  801814:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801817:	ba 00 00 00 00       	mov    $0x0,%edx
  80181c:	b8 08 00 00 00       	mov    $0x8,%eax
  801821:	e8 32 ff ff ff       	call   801758 <fsipc>
}
  801826:	c9                   	leave  
  801827:	c3                   	ret    

00801828 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801828:	55                   	push   %ebp
  801829:	89 e5                	mov    %esp,%ebp
  80182b:	53                   	push   %ebx
  80182c:	83 ec 14             	sub    $0x14,%esp
  80182f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801832:	8b 45 08             	mov    0x8(%ebp),%eax
  801835:	8b 40 0c             	mov    0xc(%eax),%eax
  801838:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80183d:	ba 00 00 00 00       	mov    $0x0,%edx
  801842:	b8 05 00 00 00       	mov    $0x5,%eax
  801847:	e8 0c ff ff ff       	call   801758 <fsipc>
  80184c:	85 c0                	test   %eax,%eax
  80184e:	78 2b                	js     80187b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801850:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801857:	00 
  801858:	89 1c 24             	mov    %ebx,(%esp)
  80185b:	e8 3a f0 ff ff       	call   80089a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801860:	a1 80 50 80 00       	mov    0x805080,%eax
  801865:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80186b:	a1 84 50 80 00       	mov    0x805084,%eax
  801870:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801876:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80187b:	83 c4 14             	add    $0x14,%esp
  80187e:	5b                   	pop    %ebx
  80187f:	5d                   	pop    %ebp
  801880:	c3                   	ret    

00801881 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801881:	55                   	push   %ebp
  801882:	89 e5                	mov    %esp,%ebp
  801884:	83 ec 18             	sub    $0x18,%esp
  801887:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  80188a:	8b 55 08             	mov    0x8(%ebp),%edx
  80188d:	8b 52 0c             	mov    0xc(%edx),%edx
  801890:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  801896:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  80189b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8018a0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8018a5:	0f 47 c2             	cmova  %edx,%eax
  8018a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8018ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018b3:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8018ba:	e8 c6 f1 ff ff       	call   800a85 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  8018bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8018c4:	b8 04 00 00 00       	mov    $0x4,%eax
  8018c9:	e8 8a fe ff ff       	call   801758 <fsipc>
}
  8018ce:	c9                   	leave  
  8018cf:	c3                   	ret    

008018d0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	53                   	push   %ebx
  8018d4:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  8018d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8018da:	8b 40 0c             	mov    0xc(%eax),%eax
  8018dd:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  8018e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8018e5:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  8018ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ef:	b8 03 00 00 00       	mov    $0x3,%eax
  8018f4:	e8 5f fe ff ff       	call   801758 <fsipc>
  8018f9:	89 c3                	mov    %eax,%ebx
  8018fb:	85 c0                	test   %eax,%eax
  8018fd:	78 17                	js     801916 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  801903:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80190a:	00 
  80190b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80190e:	89 04 24             	mov    %eax,(%esp)
  801911:	e8 6f f1 ff ff       	call   800a85 <memmove>
  return r;	
}
  801916:	89 d8                	mov    %ebx,%eax
  801918:	83 c4 14             	add    $0x14,%esp
  80191b:	5b                   	pop    %ebx
  80191c:	5d                   	pop    %ebp
  80191d:	c3                   	ret    

0080191e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  80191e:	55                   	push   %ebp
  80191f:	89 e5                	mov    %esp,%ebp
  801921:	53                   	push   %ebx
  801922:	83 ec 14             	sub    $0x14,%esp
  801925:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801928:	89 1c 24             	mov    %ebx,(%esp)
  80192b:	e8 20 ef ff ff       	call   800850 <strlen>
  801930:	89 c2                	mov    %eax,%edx
  801932:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801937:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  80193d:	7f 1f                	jg     80195e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  80193f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801943:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80194a:	e8 4b ef ff ff       	call   80089a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  80194f:	ba 00 00 00 00       	mov    $0x0,%edx
  801954:	b8 07 00 00 00       	mov    $0x7,%eax
  801959:	e8 fa fd ff ff       	call   801758 <fsipc>
}
  80195e:	83 c4 14             	add    $0x14,%esp
  801961:	5b                   	pop    %ebx
  801962:	5d                   	pop    %ebp
  801963:	c3                   	ret    

00801964 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801964:	55                   	push   %ebp
  801965:	89 e5                	mov    %esp,%ebp
  801967:	83 ec 28             	sub    $0x28,%esp
  80196a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80196d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801970:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801973:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801976:	89 04 24             	mov    %eax,(%esp)
  801979:	e8 dd f7 ff ff       	call   80115b <fd_alloc>
  80197e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801980:	85 c0                	test   %eax,%eax
  801982:	0f 88 89 00 00 00    	js     801a11 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801988:	89 34 24             	mov    %esi,(%esp)
  80198b:	e8 c0 ee ff ff       	call   800850 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801990:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801995:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80199a:	7f 75                	jg     801a11 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  80199c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019a0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8019a7:	e8 ee ee ff ff       	call   80089a <strcpy>
  fsipcbuf.open.req_omode = mode;
  8019ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019af:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  8019b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019b7:	b8 01 00 00 00       	mov    $0x1,%eax
  8019bc:	e8 97 fd ff ff       	call   801758 <fsipc>
  8019c1:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  8019c3:	85 c0                	test   %eax,%eax
  8019c5:	78 0f                	js     8019d6 <open+0x72>
  return fd2num(fd);
  8019c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ca:	89 04 24             	mov    %eax,(%esp)
  8019cd:	e8 5e f7 ff ff       	call   801130 <fd2num>
  8019d2:	89 c3                	mov    %eax,%ebx
  8019d4:	eb 3b                	jmp    801a11 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  8019d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8019dd:	00 
  8019de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e1:	89 04 24             	mov    %eax,(%esp)
  8019e4:	e8 2b fb ff ff       	call   801514 <fd_close>
  8019e9:	85 c0                	test   %eax,%eax
  8019eb:	74 24                	je     801a11 <open+0xad>
  8019ed:	c7 44 24 0c fc 27 80 	movl   $0x8027fc,0xc(%esp)
  8019f4:	00 
  8019f5:	c7 44 24 08 11 28 80 	movl   $0x802811,0x8(%esp)
  8019fc:	00 
  8019fd:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801a04:	00 
  801a05:	c7 04 24 26 28 80 00 	movl   $0x802826,(%esp)
  801a0c:	e8 13 05 00 00       	call   801f24 <_panic>
  return r;
}
  801a11:	89 d8                	mov    %ebx,%eax
  801a13:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801a16:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801a19:	89 ec                	mov    %ebp,%esp
  801a1b:	5d                   	pop    %ebp
  801a1c:	c3                   	ret    
  801a1d:	00 00                	add    %al,(%eax)
	...

00801a20 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801a26:	c7 44 24 04 31 28 80 	movl   $0x802831,0x4(%esp)
  801a2d:	00 
  801a2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a31:	89 04 24             	mov    %eax,(%esp)
  801a34:	e8 61 ee ff ff       	call   80089a <strcpy>
	return 0;
}
  801a39:	b8 00 00 00 00       	mov    $0x0,%eax
  801a3e:	c9                   	leave  
  801a3f:	c3                   	ret    

00801a40 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801a40:	55                   	push   %ebp
  801a41:	89 e5                	mov    %esp,%ebp
  801a43:	53                   	push   %ebx
  801a44:	83 ec 14             	sub    $0x14,%esp
  801a47:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801a4a:	89 1c 24             	mov    %ebx,(%esp)
  801a4d:	e8 72 06 00 00       	call   8020c4 <pageref>
  801a52:	89 c2                	mov    %eax,%edx
  801a54:	b8 00 00 00 00       	mov    $0x0,%eax
  801a59:	83 fa 01             	cmp    $0x1,%edx
  801a5c:	75 0b                	jne    801a69 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  801a5e:	8b 43 0c             	mov    0xc(%ebx),%eax
  801a61:	89 04 24             	mov    %eax,(%esp)
  801a64:	e8 b9 02 00 00       	call   801d22 <nsipc_close>
	else
		return 0;
}
  801a69:	83 c4 14             	add    $0x14,%esp
  801a6c:	5b                   	pop    %ebx
  801a6d:	5d                   	pop    %ebp
  801a6e:	c3                   	ret    

00801a6f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801a6f:	55                   	push   %ebp
  801a70:	89 e5                	mov    %esp,%ebp
  801a72:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801a75:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801a7c:	00 
  801a7d:	8b 45 10             	mov    0x10(%ebp),%eax
  801a80:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a84:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a87:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a8b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a8e:	8b 40 0c             	mov    0xc(%eax),%eax
  801a91:	89 04 24             	mov    %eax,(%esp)
  801a94:	e8 c5 02 00 00       	call   801d5e <nsipc_send>
}
  801a99:	c9                   	leave  
  801a9a:	c3                   	ret    

00801a9b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801a9b:	55                   	push   %ebp
  801a9c:	89 e5                	mov    %esp,%ebp
  801a9e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801aa1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801aa8:	00 
  801aa9:	8b 45 10             	mov    0x10(%ebp),%eax
  801aac:	89 44 24 08          	mov    %eax,0x8(%esp)
  801ab0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ab3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ab7:	8b 45 08             	mov    0x8(%ebp),%eax
  801aba:	8b 40 0c             	mov    0xc(%eax),%eax
  801abd:	89 04 24             	mov    %eax,(%esp)
  801ac0:	e8 0c 03 00 00       	call   801dd1 <nsipc_recv>
}
  801ac5:	c9                   	leave  
  801ac6:	c3                   	ret    

00801ac7 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  801ac7:	55                   	push   %ebp
  801ac8:	89 e5                	mov    %esp,%ebp
  801aca:	56                   	push   %esi
  801acb:	53                   	push   %ebx
  801acc:	83 ec 20             	sub    $0x20,%esp
  801acf:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801ad1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ad4:	89 04 24             	mov    %eax,(%esp)
  801ad7:	e8 7f f6 ff ff       	call   80115b <fd_alloc>
  801adc:	89 c3                	mov    %eax,%ebx
  801ade:	85 c0                	test   %eax,%eax
  801ae0:	78 21                	js     801b03 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801ae2:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  801ae9:	00 
  801aea:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aed:	89 44 24 04          	mov    %eax,0x4(%esp)
  801af1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801af8:	e8 00 f4 ff ff       	call   800efd <sys_page_alloc>
  801afd:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801aff:	85 c0                	test   %eax,%eax
  801b01:	79 0a                	jns    801b0d <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  801b03:	89 34 24             	mov    %esi,(%esp)
  801b06:	e8 17 02 00 00       	call   801d22 <nsipc_close>
		return r;
  801b0b:	eb 28                	jmp    801b35 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801b0d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b13:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b16:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b1b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801b22:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b25:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801b28:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b2b:	89 04 24             	mov    %eax,(%esp)
  801b2e:	e8 fd f5 ff ff       	call   801130 <fd2num>
  801b33:	89 c3                	mov    %eax,%ebx
}
  801b35:	89 d8                	mov    %ebx,%eax
  801b37:	83 c4 20             	add    $0x20,%esp
  801b3a:	5b                   	pop    %ebx
  801b3b:	5e                   	pop    %esi
  801b3c:	5d                   	pop    %ebp
  801b3d:	c3                   	ret    

00801b3e <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b3e:	55                   	push   %ebp
  801b3f:	89 e5                	mov    %esp,%ebp
  801b41:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b44:	8b 45 10             	mov    0x10(%ebp),%eax
  801b47:	89 44 24 08          	mov    %eax,0x8(%esp)
  801b4b:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b4e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b52:	8b 45 08             	mov    0x8(%ebp),%eax
  801b55:	89 04 24             	mov    %eax,(%esp)
  801b58:	e8 79 01 00 00       	call   801cd6 <nsipc_socket>
  801b5d:	85 c0                	test   %eax,%eax
  801b5f:	78 05                	js     801b66 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  801b61:	e8 61 ff ff ff       	call   801ac7 <alloc_sockfd>
}
  801b66:	c9                   	leave  
  801b67:	c3                   	ret    

00801b68 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801b68:	55                   	push   %ebp
  801b69:	89 e5                	mov    %esp,%ebp
  801b6b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801b6e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801b71:	89 54 24 04          	mov    %edx,0x4(%esp)
  801b75:	89 04 24             	mov    %eax,(%esp)
  801b78:	e8 50 f6 ff ff       	call   8011cd <fd_lookup>
  801b7d:	85 c0                	test   %eax,%eax
  801b7f:	78 15                	js     801b96 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801b81:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b84:	8b 0a                	mov    (%edx),%ecx
  801b86:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b8b:	3b 0d 20 30 80 00    	cmp    0x803020,%ecx
  801b91:	75 03                	jne    801b96 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801b93:	8b 42 0c             	mov    0xc(%edx),%eax
}
  801b96:	c9                   	leave  
  801b97:	c3                   	ret    

00801b98 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  801b98:	55                   	push   %ebp
  801b99:	89 e5                	mov    %esp,%ebp
  801b9b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b9e:	8b 45 08             	mov    0x8(%ebp),%eax
  801ba1:	e8 c2 ff ff ff       	call   801b68 <fd2sockid>
  801ba6:	85 c0                	test   %eax,%eax
  801ba8:	78 0f                	js     801bb9 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801baa:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bad:	89 54 24 04          	mov    %edx,0x4(%esp)
  801bb1:	89 04 24             	mov    %eax,(%esp)
  801bb4:	e8 47 01 00 00       	call   801d00 <nsipc_listen>
}
  801bb9:	c9                   	leave  
  801bba:	c3                   	ret    

00801bbb <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801bbb:	55                   	push   %ebp
  801bbc:	89 e5                	mov    %esp,%ebp
  801bbe:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801bc1:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc4:	e8 9f ff ff ff       	call   801b68 <fd2sockid>
  801bc9:	85 c0                	test   %eax,%eax
  801bcb:	78 16                	js     801be3 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  801bcd:	8b 55 10             	mov    0x10(%ebp),%edx
  801bd0:	89 54 24 08          	mov    %edx,0x8(%esp)
  801bd4:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bd7:	89 54 24 04          	mov    %edx,0x4(%esp)
  801bdb:	89 04 24             	mov    %eax,(%esp)
  801bde:	e8 6e 02 00 00       	call   801e51 <nsipc_connect>
}
  801be3:	c9                   	leave  
  801be4:	c3                   	ret    

00801be5 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  801be5:	55                   	push   %ebp
  801be6:	89 e5                	mov    %esp,%ebp
  801be8:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801beb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bee:	e8 75 ff ff ff       	call   801b68 <fd2sockid>
  801bf3:	85 c0                	test   %eax,%eax
  801bf5:	78 0f                	js     801c06 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801bf7:	8b 55 0c             	mov    0xc(%ebp),%edx
  801bfa:	89 54 24 04          	mov    %edx,0x4(%esp)
  801bfe:	89 04 24             	mov    %eax,(%esp)
  801c01:	e8 36 01 00 00       	call   801d3c <nsipc_shutdown>
}
  801c06:	c9                   	leave  
  801c07:	c3                   	ret    

00801c08 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c08:	55                   	push   %ebp
  801c09:	89 e5                	mov    %esp,%ebp
  801c0b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c0e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c11:	e8 52 ff ff ff       	call   801b68 <fd2sockid>
  801c16:	85 c0                	test   %eax,%eax
  801c18:	78 16                	js     801c30 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  801c1a:	8b 55 10             	mov    0x10(%ebp),%edx
  801c1d:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c21:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c24:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c28:	89 04 24             	mov    %eax,(%esp)
  801c2b:	e8 60 02 00 00       	call   801e90 <nsipc_bind>
}
  801c30:	c9                   	leave  
  801c31:	c3                   	ret    

00801c32 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801c32:	55                   	push   %ebp
  801c33:	89 e5                	mov    %esp,%ebp
  801c35:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801c38:	8b 45 08             	mov    0x8(%ebp),%eax
  801c3b:	e8 28 ff ff ff       	call   801b68 <fd2sockid>
  801c40:	85 c0                	test   %eax,%eax
  801c42:	78 1f                	js     801c63 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801c44:	8b 55 10             	mov    0x10(%ebp),%edx
  801c47:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c4e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801c52:	89 04 24             	mov    %eax,(%esp)
  801c55:	e8 75 02 00 00       	call   801ecf <nsipc_accept>
  801c5a:	85 c0                	test   %eax,%eax
  801c5c:	78 05                	js     801c63 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  801c5e:	e8 64 fe ff ff       	call   801ac7 <alloc_sockfd>
}
  801c63:	c9                   	leave  
  801c64:	c3                   	ret    
	...

00801c70 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801c70:	55                   	push   %ebp
  801c71:	89 e5                	mov    %esp,%ebp
  801c73:	53                   	push   %ebx
  801c74:	83 ec 14             	sub    $0x14,%esp
  801c77:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801c79:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801c80:	75 11                	jne    801c93 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801c82:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  801c89:	e8 f2 02 00 00       	call   801f80 <ipc_find_env>
  801c8e:	a3 04 40 80 00       	mov    %eax,0x804004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801c93:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801c9a:	00 
  801c9b:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801ca2:	00 
  801ca3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ca7:	a1 04 40 80 00       	mov    0x804004,%eax
  801cac:	89 04 24             	mov    %eax,(%esp)
  801caf:	e8 15 03 00 00       	call   801fc9 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801cb4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cbb:	00 
  801cbc:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801cc3:	00 
  801cc4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ccb:	e8 64 03 00 00       	call   802034 <ipc_recv>
}
  801cd0:	83 c4 14             	add    $0x14,%esp
  801cd3:	5b                   	pop    %ebx
  801cd4:	5d                   	pop    %ebp
  801cd5:	c3                   	ret    

00801cd6 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  801cd6:	55                   	push   %ebp
  801cd7:	89 e5                	mov    %esp,%ebp
  801cd9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801cdc:	8b 45 08             	mov    0x8(%ebp),%eax
  801cdf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801ce4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ce7:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801cec:	8b 45 10             	mov    0x10(%ebp),%eax
  801cef:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801cf4:	b8 09 00 00 00       	mov    $0x9,%eax
  801cf9:	e8 72 ff ff ff       	call   801c70 <nsipc>
}
  801cfe:	c9                   	leave  
  801cff:	c3                   	ret    

00801d00 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  801d00:	55                   	push   %ebp
  801d01:	89 e5                	mov    %esp,%ebp
  801d03:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801d06:	8b 45 08             	mov    0x8(%ebp),%eax
  801d09:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801d0e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d11:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801d16:	b8 06 00 00 00       	mov    $0x6,%eax
  801d1b:	e8 50 ff ff ff       	call   801c70 <nsipc>
}
  801d20:	c9                   	leave  
  801d21:	c3                   	ret    

00801d22 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  801d22:	55                   	push   %ebp
  801d23:	89 e5                	mov    %esp,%ebp
  801d25:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801d28:	8b 45 08             	mov    0x8(%ebp),%eax
  801d2b:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801d30:	b8 04 00 00 00       	mov    $0x4,%eax
  801d35:	e8 36 ff ff ff       	call   801c70 <nsipc>
}
  801d3a:	c9                   	leave  
  801d3b:	c3                   	ret    

00801d3c <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  801d3c:	55                   	push   %ebp
  801d3d:	89 e5                	mov    %esp,%ebp
  801d3f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801d42:	8b 45 08             	mov    0x8(%ebp),%eax
  801d45:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801d4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d4d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801d52:	b8 03 00 00 00       	mov    $0x3,%eax
  801d57:	e8 14 ff ff ff       	call   801c70 <nsipc>
}
  801d5c:	c9                   	leave  
  801d5d:	c3                   	ret    

00801d5e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d5e:	55                   	push   %ebp
  801d5f:	89 e5                	mov    %esp,%ebp
  801d61:	53                   	push   %ebx
  801d62:	83 ec 14             	sub    $0x14,%esp
  801d65:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d68:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6b:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d70:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d76:	7e 24                	jle    801d9c <nsipc_send+0x3e>
  801d78:	c7 44 24 0c 3d 28 80 	movl   $0x80283d,0xc(%esp)
  801d7f:	00 
  801d80:	c7 44 24 08 11 28 80 	movl   $0x802811,0x8(%esp)
  801d87:	00 
  801d88:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  801d8f:	00 
  801d90:	c7 04 24 49 28 80 00 	movl   $0x802849,(%esp)
  801d97:	e8 88 01 00 00       	call   801f24 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d9c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801da0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801da3:	89 44 24 04          	mov    %eax,0x4(%esp)
  801da7:	c7 04 24 0c 60 80 00 	movl   $0x80600c,(%esp)
  801dae:	e8 d2 ec ff ff       	call   800a85 <memmove>
	nsipcbuf.send.req_size = size;
  801db3:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801db9:	8b 45 14             	mov    0x14(%ebp),%eax
  801dbc:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801dc1:	b8 08 00 00 00       	mov    $0x8,%eax
  801dc6:	e8 a5 fe ff ff       	call   801c70 <nsipc>
}
  801dcb:	83 c4 14             	add    $0x14,%esp
  801dce:	5b                   	pop    %ebx
  801dcf:	5d                   	pop    %ebp
  801dd0:	c3                   	ret    

00801dd1 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801dd1:	55                   	push   %ebp
  801dd2:	89 e5                	mov    %esp,%ebp
  801dd4:	56                   	push   %esi
  801dd5:	53                   	push   %ebx
  801dd6:	83 ec 10             	sub    $0x10,%esp
  801dd9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801ddc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ddf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801de4:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801dea:	8b 45 14             	mov    0x14(%ebp),%eax
  801ded:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801df2:	b8 07 00 00 00       	mov    $0x7,%eax
  801df7:	e8 74 fe ff ff       	call   801c70 <nsipc>
  801dfc:	89 c3                	mov    %eax,%ebx
  801dfe:	85 c0                	test   %eax,%eax
  801e00:	78 46                	js     801e48 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  801e02:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801e07:	7f 04                	jg     801e0d <nsipc_recv+0x3c>
  801e09:	39 c6                	cmp    %eax,%esi
  801e0b:	7d 24                	jge    801e31 <nsipc_recv+0x60>
  801e0d:	c7 44 24 0c 55 28 80 	movl   $0x802855,0xc(%esp)
  801e14:	00 
  801e15:	c7 44 24 08 11 28 80 	movl   $0x802811,0x8(%esp)
  801e1c:	00 
  801e1d:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  801e24:	00 
  801e25:	c7 04 24 49 28 80 00 	movl   $0x802849,(%esp)
  801e2c:	e8 f3 00 00 00       	call   801f24 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801e31:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e35:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e3c:	00 
  801e3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e40:	89 04 24             	mov    %eax,(%esp)
  801e43:	e8 3d ec ff ff       	call   800a85 <memmove>
	}

	return r;
}
  801e48:	89 d8                	mov    %ebx,%eax
  801e4a:	83 c4 10             	add    $0x10,%esp
  801e4d:	5b                   	pop    %ebx
  801e4e:	5e                   	pop    %esi
  801e4f:	5d                   	pop    %ebp
  801e50:	c3                   	ret    

00801e51 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e51:	55                   	push   %ebp
  801e52:	89 e5                	mov    %esp,%ebp
  801e54:	53                   	push   %ebx
  801e55:	83 ec 14             	sub    $0x14,%esp
  801e58:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801e5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e5e:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801e63:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e67:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e6a:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e6e:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801e75:	e8 0b ec ff ff       	call   800a85 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801e7a:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801e80:	b8 05 00 00 00       	mov    $0x5,%eax
  801e85:	e8 e6 fd ff ff       	call   801c70 <nsipc>
}
  801e8a:	83 c4 14             	add    $0x14,%esp
  801e8d:	5b                   	pop    %ebx
  801e8e:	5d                   	pop    %ebp
  801e8f:	c3                   	ret    

00801e90 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e90:	55                   	push   %ebp
  801e91:	89 e5                	mov    %esp,%ebp
  801e93:	53                   	push   %ebx
  801e94:	83 ec 14             	sub    $0x14,%esp
  801e97:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e9a:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801ea2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801ea6:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ea9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ead:	c7 04 24 04 60 80 00 	movl   $0x806004,(%esp)
  801eb4:	e8 cc eb ff ff       	call   800a85 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801eb9:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801ebf:	b8 02 00 00 00       	mov    $0x2,%eax
  801ec4:	e8 a7 fd ff ff       	call   801c70 <nsipc>
}
  801ec9:	83 c4 14             	add    $0x14,%esp
  801ecc:	5b                   	pop    %ebx
  801ecd:	5d                   	pop    %ebp
  801ece:	c3                   	ret    

00801ecf <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ecf:	55                   	push   %ebp
  801ed0:	89 e5                	mov    %esp,%ebp
  801ed2:	83 ec 18             	sub    $0x18,%esp
  801ed5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801ed8:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  801edb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ede:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801ee3:	b8 01 00 00 00       	mov    $0x1,%eax
  801ee8:	e8 83 fd ff ff       	call   801c70 <nsipc>
  801eed:	89 c3                	mov    %eax,%ebx
  801eef:	85 c0                	test   %eax,%eax
  801ef1:	78 25                	js     801f18 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801ef3:	be 10 60 80 00       	mov    $0x806010,%esi
  801ef8:	8b 06                	mov    (%esi),%eax
  801efa:	89 44 24 08          	mov    %eax,0x8(%esp)
  801efe:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801f05:	00 
  801f06:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f09:	89 04 24             	mov    %eax,(%esp)
  801f0c:	e8 74 eb ff ff       	call   800a85 <memmove>
		*addrlen = ret->ret_addrlen;
  801f11:	8b 16                	mov    (%esi),%edx
  801f13:	8b 45 10             	mov    0x10(%ebp),%eax
  801f16:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  801f18:	89 d8                	mov    %ebx,%eax
  801f1a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801f1d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801f20:	89 ec                	mov    %ebp,%esp
  801f22:	5d                   	pop    %ebp
  801f23:	c3                   	ret    

00801f24 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f24:	55                   	push   %ebp
  801f25:	89 e5                	mov    %esp,%ebp
  801f27:	56                   	push   %esi
  801f28:	53                   	push   %ebx
  801f29:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801f2c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f2f:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801f35:	e8 6d f0 ff ff       	call   800fa7 <sys_getenvid>
  801f3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f3d:	89 54 24 10          	mov    %edx,0x10(%esp)
  801f41:	8b 55 08             	mov    0x8(%ebp),%edx
  801f44:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801f48:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f4c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801f50:	c7 04 24 6c 28 80 00 	movl   $0x80286c,(%esp)
  801f57:	e8 05 e2 ff ff       	call   800161 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f5c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f60:	8b 45 10             	mov    0x10(%ebp),%eax
  801f63:	89 04 24             	mov    %eax,(%esp)
  801f66:	e8 95 e1 ff ff       	call   800100 <vcprintf>
	cprintf("\n");
  801f6b:	c7 04 24 ec 27 80 00 	movl   $0x8027ec,(%esp)
  801f72:	e8 ea e1 ff ff       	call   800161 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f77:	cc                   	int3   
  801f78:	eb fd                	jmp    801f77 <_panic+0x53>
  801f7a:	00 00                	add    %al,(%eax)
  801f7c:	00 00                	add    %al,(%eax)
	...

00801f80 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801f80:	55                   	push   %ebp
  801f81:	89 e5                	mov    %esp,%ebp
  801f83:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801f86:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801f8c:	b8 01 00 00 00       	mov    $0x1,%eax
  801f91:	39 ca                	cmp    %ecx,%edx
  801f93:	75 04                	jne    801f99 <ipc_find_env+0x19>
  801f95:	b0 00                	mov    $0x0,%al
  801f97:	eb 11                	jmp    801faa <ipc_find_env+0x2a>
  801f99:	89 c2                	mov    %eax,%edx
  801f9b:	c1 e2 07             	shl    $0x7,%edx
  801f9e:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801fa4:	8b 12                	mov    (%edx),%edx
  801fa6:	39 ca                	cmp    %ecx,%edx
  801fa8:	75 0f                	jne    801fb9 <ipc_find_env+0x39>
			return envs[i].env_id;
  801faa:	8d 44 00 01          	lea    0x1(%eax,%eax,1),%eax
  801fae:	c1 e0 06             	shl    $0x6,%eax
  801fb1:	8b 80 08 00 c0 ee    	mov    -0x113ffff8(%eax),%eax
  801fb7:	eb 0e                	jmp    801fc7 <ipc_find_env+0x47>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fb9:	83 c0 01             	add    $0x1,%eax
  801fbc:	3d 00 04 00 00       	cmp    $0x400,%eax
  801fc1:	75 d6                	jne    801f99 <ipc_find_env+0x19>
  801fc3:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801fc7:	5d                   	pop    %ebp
  801fc8:	c3                   	ret    

00801fc9 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801fc9:	55                   	push   %ebp
  801fca:	89 e5                	mov    %esp,%ebp
  801fcc:	57                   	push   %edi
  801fcd:	56                   	push   %esi
  801fce:	53                   	push   %ebx
  801fcf:	83 ec 1c             	sub    $0x1c,%esp
  801fd2:	8b 75 08             	mov    0x8(%ebp),%esi
  801fd5:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801fd8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801fdb:	85 db                	test   %ebx,%ebx
  801fdd:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801fe2:	0f 44 d8             	cmove  %eax,%ebx
  801fe5:	eb 25                	jmp    80200c <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  801fe7:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fea:	74 20                	je     80200c <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  801fec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ff0:	c7 44 24 08 90 28 80 	movl   $0x802890,0x8(%esp)
  801ff7:	00 
  801ff8:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801fff:	00 
  802000:	c7 04 24 ae 28 80 00 	movl   $0x8028ae,(%esp)
  802007:	e8 18 ff ff ff       	call   801f24 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  80200c:	8b 45 14             	mov    0x14(%ebp),%eax
  80200f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  802013:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802017:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80201b:	89 34 24             	mov    %esi,(%esp)
  80201e:	e8 8b ed ff ff       	call   800dae <sys_ipc_try_send>
  802023:	85 c0                	test   %eax,%eax
  802025:	75 c0                	jne    801fe7 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  802027:	e8 08 ef ff ff       	call   800f34 <sys_yield>
}
  80202c:	83 c4 1c             	add    $0x1c,%esp
  80202f:	5b                   	pop    %ebx
  802030:	5e                   	pop    %esi
  802031:	5f                   	pop    %edi
  802032:	5d                   	pop    %ebp
  802033:	c3                   	ret    

00802034 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802034:	55                   	push   %ebp
  802035:	89 e5                	mov    %esp,%ebp
  802037:	83 ec 28             	sub    $0x28,%esp
  80203a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80203d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  802040:	89 7d fc             	mov    %edi,-0x4(%ebp)
  802043:	8b 75 08             	mov    0x8(%ebp),%esi
  802046:	8b 45 0c             	mov    0xc(%ebp),%eax
  802049:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  80204c:	85 c0                	test   %eax,%eax
  80204e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802053:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  802056:	89 04 24             	mov    %eax,(%esp)
  802059:	e8 17 ed ff ff       	call   800d75 <sys_ipc_recv>
  80205e:	89 c3                	mov    %eax,%ebx
  802060:	85 c0                	test   %eax,%eax
  802062:	79 2a                	jns    80208e <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  802064:	89 44 24 08          	mov    %eax,0x8(%esp)
  802068:	89 44 24 04          	mov    %eax,0x4(%esp)
  80206c:	c7 04 24 b8 28 80 00 	movl   $0x8028b8,(%esp)
  802073:	e8 e9 e0 ff ff       	call   800161 <cprintf>
		if(from_env_store != NULL)
  802078:	85 f6                	test   %esi,%esi
  80207a:	74 06                	je     802082 <ipc_recv+0x4e>
			*from_env_store = 0;
  80207c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  802082:	85 ff                	test   %edi,%edi
  802084:	74 2c                	je     8020b2 <ipc_recv+0x7e>
			*perm_store = 0;
  802086:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  80208c:	eb 24                	jmp    8020b2 <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  80208e:	85 f6                	test   %esi,%esi
  802090:	74 0a                	je     80209c <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  802092:	a1 08 40 80 00       	mov    0x804008,%eax
  802097:	8b 40 74             	mov    0x74(%eax),%eax
  80209a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  80209c:	85 ff                	test   %edi,%edi
  80209e:	74 0a                	je     8020aa <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  8020a0:	a1 08 40 80 00       	mov    0x804008,%eax
  8020a5:	8b 40 78             	mov    0x78(%eax),%eax
  8020a8:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8020aa:	a1 08 40 80 00       	mov    0x804008,%eax
  8020af:	8b 58 70             	mov    0x70(%eax),%ebx
}
  8020b2:	89 d8                	mov    %ebx,%eax
  8020b4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8020b7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8020ba:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8020bd:	89 ec                	mov    %ebp,%esp
  8020bf:	5d                   	pop    %ebp
  8020c0:	c3                   	ret    
  8020c1:	00 00                	add    %al,(%eax)
	...

008020c4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020c4:	55                   	push   %ebp
  8020c5:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  8020c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8020ca:	89 c2                	mov    %eax,%edx
  8020cc:	c1 ea 16             	shr    $0x16,%edx
  8020cf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8020d6:	f6 c2 01             	test   $0x1,%dl
  8020d9:	74 20                	je     8020fb <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  8020db:	c1 e8 0c             	shr    $0xc,%eax
  8020de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8020e5:	a8 01                	test   $0x1,%al
  8020e7:	74 12                	je     8020fb <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020e9:	c1 e8 0c             	shr    $0xc,%eax
  8020ec:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  8020f1:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  8020f6:	0f b7 c0             	movzwl %ax,%eax
  8020f9:	eb 05                	jmp    802100 <pageref+0x3c>
  8020fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802100:	5d                   	pop    %ebp
  802101:	c3                   	ret    
	...

00802110 <__udivdi3>:
  802110:	55                   	push   %ebp
  802111:	89 e5                	mov    %esp,%ebp
  802113:	57                   	push   %edi
  802114:	56                   	push   %esi
  802115:	83 ec 10             	sub    $0x10,%esp
  802118:	8b 45 14             	mov    0x14(%ebp),%eax
  80211b:	8b 55 08             	mov    0x8(%ebp),%edx
  80211e:	8b 75 10             	mov    0x10(%ebp),%esi
  802121:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802124:	85 c0                	test   %eax,%eax
  802126:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802129:	75 35                	jne    802160 <__udivdi3+0x50>
  80212b:	39 fe                	cmp    %edi,%esi
  80212d:	77 61                	ja     802190 <__udivdi3+0x80>
  80212f:	85 f6                	test   %esi,%esi
  802131:	75 0b                	jne    80213e <__udivdi3+0x2e>
  802133:	b8 01 00 00 00       	mov    $0x1,%eax
  802138:	31 d2                	xor    %edx,%edx
  80213a:	f7 f6                	div    %esi
  80213c:	89 c6                	mov    %eax,%esi
  80213e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802141:	31 d2                	xor    %edx,%edx
  802143:	89 f8                	mov    %edi,%eax
  802145:	f7 f6                	div    %esi
  802147:	89 c7                	mov    %eax,%edi
  802149:	89 c8                	mov    %ecx,%eax
  80214b:	f7 f6                	div    %esi
  80214d:	89 c1                	mov    %eax,%ecx
  80214f:	89 fa                	mov    %edi,%edx
  802151:	89 c8                	mov    %ecx,%eax
  802153:	83 c4 10             	add    $0x10,%esp
  802156:	5e                   	pop    %esi
  802157:	5f                   	pop    %edi
  802158:	5d                   	pop    %ebp
  802159:	c3                   	ret    
  80215a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802160:	39 f8                	cmp    %edi,%eax
  802162:	77 1c                	ja     802180 <__udivdi3+0x70>
  802164:	0f bd d0             	bsr    %eax,%edx
  802167:	83 f2 1f             	xor    $0x1f,%edx
  80216a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80216d:	75 39                	jne    8021a8 <__udivdi3+0x98>
  80216f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802172:	0f 86 a0 00 00 00    	jbe    802218 <__udivdi3+0x108>
  802178:	39 f8                	cmp    %edi,%eax
  80217a:	0f 82 98 00 00 00    	jb     802218 <__udivdi3+0x108>
  802180:	31 ff                	xor    %edi,%edi
  802182:	31 c9                	xor    %ecx,%ecx
  802184:	89 c8                	mov    %ecx,%eax
  802186:	89 fa                	mov    %edi,%edx
  802188:	83 c4 10             	add    $0x10,%esp
  80218b:	5e                   	pop    %esi
  80218c:	5f                   	pop    %edi
  80218d:	5d                   	pop    %ebp
  80218e:	c3                   	ret    
  80218f:	90                   	nop
  802190:	89 d1                	mov    %edx,%ecx
  802192:	89 fa                	mov    %edi,%edx
  802194:	89 c8                	mov    %ecx,%eax
  802196:	31 ff                	xor    %edi,%edi
  802198:	f7 f6                	div    %esi
  80219a:	89 c1                	mov    %eax,%ecx
  80219c:	89 fa                	mov    %edi,%edx
  80219e:	89 c8                	mov    %ecx,%eax
  8021a0:	83 c4 10             	add    $0x10,%esp
  8021a3:	5e                   	pop    %esi
  8021a4:	5f                   	pop    %edi
  8021a5:	5d                   	pop    %ebp
  8021a6:	c3                   	ret    
  8021a7:	90                   	nop
  8021a8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8021ac:	89 f2                	mov    %esi,%edx
  8021ae:	d3 e0                	shl    %cl,%eax
  8021b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8021b3:	b8 20 00 00 00       	mov    $0x20,%eax
  8021b8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8021bb:	89 c1                	mov    %eax,%ecx
  8021bd:	d3 ea                	shr    %cl,%edx
  8021bf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8021c3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8021c6:	d3 e6                	shl    %cl,%esi
  8021c8:	89 c1                	mov    %eax,%ecx
  8021ca:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8021cd:	89 fe                	mov    %edi,%esi
  8021cf:	d3 ee                	shr    %cl,%esi
  8021d1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8021d5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8021d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021db:	d3 e7                	shl    %cl,%edi
  8021dd:	89 c1                	mov    %eax,%ecx
  8021df:	d3 ea                	shr    %cl,%edx
  8021e1:	09 d7                	or     %edx,%edi
  8021e3:	89 f2                	mov    %esi,%edx
  8021e5:	89 f8                	mov    %edi,%eax
  8021e7:	f7 75 ec             	divl   -0x14(%ebp)
  8021ea:	89 d6                	mov    %edx,%esi
  8021ec:	89 c7                	mov    %eax,%edi
  8021ee:	f7 65 e8             	mull   -0x18(%ebp)
  8021f1:	39 d6                	cmp    %edx,%esi
  8021f3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8021f6:	72 30                	jb     802228 <__udivdi3+0x118>
  8021f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8021fb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8021ff:	d3 e2                	shl    %cl,%edx
  802201:	39 c2                	cmp    %eax,%edx
  802203:	73 05                	jae    80220a <__udivdi3+0xfa>
  802205:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802208:	74 1e                	je     802228 <__udivdi3+0x118>
  80220a:	89 f9                	mov    %edi,%ecx
  80220c:	31 ff                	xor    %edi,%edi
  80220e:	e9 71 ff ff ff       	jmp    802184 <__udivdi3+0x74>
  802213:	90                   	nop
  802214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802218:	31 ff                	xor    %edi,%edi
  80221a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80221f:	e9 60 ff ff ff       	jmp    802184 <__udivdi3+0x74>
  802224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802228:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80222b:	31 ff                	xor    %edi,%edi
  80222d:	89 c8                	mov    %ecx,%eax
  80222f:	89 fa                	mov    %edi,%edx
  802231:	83 c4 10             	add    $0x10,%esp
  802234:	5e                   	pop    %esi
  802235:	5f                   	pop    %edi
  802236:	5d                   	pop    %ebp
  802237:	c3                   	ret    
	...

00802240 <__umoddi3>:
  802240:	55                   	push   %ebp
  802241:	89 e5                	mov    %esp,%ebp
  802243:	57                   	push   %edi
  802244:	56                   	push   %esi
  802245:	83 ec 20             	sub    $0x20,%esp
  802248:	8b 55 14             	mov    0x14(%ebp),%edx
  80224b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80224e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802251:	8b 75 0c             	mov    0xc(%ebp),%esi
  802254:	85 d2                	test   %edx,%edx
  802256:	89 c8                	mov    %ecx,%eax
  802258:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80225b:	75 13                	jne    802270 <__umoddi3+0x30>
  80225d:	39 f7                	cmp    %esi,%edi
  80225f:	76 3f                	jbe    8022a0 <__umoddi3+0x60>
  802261:	89 f2                	mov    %esi,%edx
  802263:	f7 f7                	div    %edi
  802265:	89 d0                	mov    %edx,%eax
  802267:	31 d2                	xor    %edx,%edx
  802269:	83 c4 20             	add    $0x20,%esp
  80226c:	5e                   	pop    %esi
  80226d:	5f                   	pop    %edi
  80226e:	5d                   	pop    %ebp
  80226f:	c3                   	ret    
  802270:	39 f2                	cmp    %esi,%edx
  802272:	77 4c                	ja     8022c0 <__umoddi3+0x80>
  802274:	0f bd ca             	bsr    %edx,%ecx
  802277:	83 f1 1f             	xor    $0x1f,%ecx
  80227a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80227d:	75 51                	jne    8022d0 <__umoddi3+0x90>
  80227f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802282:	0f 87 e0 00 00 00    	ja     802368 <__umoddi3+0x128>
  802288:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80228b:	29 f8                	sub    %edi,%eax
  80228d:	19 d6                	sbb    %edx,%esi
  80228f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802292:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802295:	89 f2                	mov    %esi,%edx
  802297:	83 c4 20             	add    $0x20,%esp
  80229a:	5e                   	pop    %esi
  80229b:	5f                   	pop    %edi
  80229c:	5d                   	pop    %ebp
  80229d:	c3                   	ret    
  80229e:	66 90                	xchg   %ax,%ax
  8022a0:	85 ff                	test   %edi,%edi
  8022a2:	75 0b                	jne    8022af <__umoddi3+0x6f>
  8022a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8022a9:	31 d2                	xor    %edx,%edx
  8022ab:	f7 f7                	div    %edi
  8022ad:	89 c7                	mov    %eax,%edi
  8022af:	89 f0                	mov    %esi,%eax
  8022b1:	31 d2                	xor    %edx,%edx
  8022b3:	f7 f7                	div    %edi
  8022b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b8:	f7 f7                	div    %edi
  8022ba:	eb a9                	jmp    802265 <__umoddi3+0x25>
  8022bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022c0:	89 c8                	mov    %ecx,%eax
  8022c2:	89 f2                	mov    %esi,%edx
  8022c4:	83 c4 20             	add    $0x20,%esp
  8022c7:	5e                   	pop    %esi
  8022c8:	5f                   	pop    %edi
  8022c9:	5d                   	pop    %ebp
  8022ca:	c3                   	ret    
  8022cb:	90                   	nop
  8022cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8022d4:	d3 e2                	shl    %cl,%edx
  8022d6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8022d9:	ba 20 00 00 00       	mov    $0x20,%edx
  8022de:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8022e1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8022e4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8022e8:	89 fa                	mov    %edi,%edx
  8022ea:	d3 ea                	shr    %cl,%edx
  8022ec:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8022f0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8022f3:	d3 e7                	shl    %cl,%edi
  8022f5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8022f9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8022fc:	89 f2                	mov    %esi,%edx
  8022fe:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802301:	89 c7                	mov    %eax,%edi
  802303:	d3 ea                	shr    %cl,%edx
  802305:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802309:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80230c:	89 c2                	mov    %eax,%edx
  80230e:	d3 e6                	shl    %cl,%esi
  802310:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802314:	d3 ea                	shr    %cl,%edx
  802316:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80231a:	09 d6                	or     %edx,%esi
  80231c:	89 f0                	mov    %esi,%eax
  80231e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802321:	d3 e7                	shl    %cl,%edi
  802323:	89 f2                	mov    %esi,%edx
  802325:	f7 75 f4             	divl   -0xc(%ebp)
  802328:	89 d6                	mov    %edx,%esi
  80232a:	f7 65 e8             	mull   -0x18(%ebp)
  80232d:	39 d6                	cmp    %edx,%esi
  80232f:	72 2b                	jb     80235c <__umoddi3+0x11c>
  802331:	39 c7                	cmp    %eax,%edi
  802333:	72 23                	jb     802358 <__umoddi3+0x118>
  802335:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802339:	29 c7                	sub    %eax,%edi
  80233b:	19 d6                	sbb    %edx,%esi
  80233d:	89 f0                	mov    %esi,%eax
  80233f:	89 f2                	mov    %esi,%edx
  802341:	d3 ef                	shr    %cl,%edi
  802343:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802347:	d3 e0                	shl    %cl,%eax
  802349:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80234d:	09 f8                	or     %edi,%eax
  80234f:	d3 ea                	shr    %cl,%edx
  802351:	83 c4 20             	add    $0x20,%esp
  802354:	5e                   	pop    %esi
  802355:	5f                   	pop    %edi
  802356:	5d                   	pop    %ebp
  802357:	c3                   	ret    
  802358:	39 d6                	cmp    %edx,%esi
  80235a:	75 d9                	jne    802335 <__umoddi3+0xf5>
  80235c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80235f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802362:	eb d1                	jmp    802335 <__umoddi3+0xf5>
  802364:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802368:	39 f2                	cmp    %esi,%edx
  80236a:	0f 82 18 ff ff ff    	jb     802288 <__umoddi3+0x48>
  802370:	e9 1d ff ff ff       	jmp    802292 <__umoddi3+0x52>
