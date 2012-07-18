
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
  80004d:	e8 ca 0f 00 00       	call   80101c <set_pgfault_handler>
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
  800077:	c7 04 24 e0 1d 80 00 	movl   $0x801de0,(%esp)
  80007e:	e8 de 00 00 00       	call   800161 <cprintf>
	sys_env_destroy(sys_getenvid());
  800083:	e8 ac 0e 00 00       	call   800f34 <sys_getenvid>
  800088:	89 04 24             	mov    %eax,(%esp)
  80008b:	e8 df 0e 00 00       	call   800f6f <sys_env_destroy>
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
  8000a6:	e8 89 0e 00 00       	call   800f34 <sys_getenvid>
  8000ab:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000b3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000b8:	a3 04 40 80 00       	mov    %eax,0x804004

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
  8000ea:	e8 ba 14 00 00       	call   8015a9 <close_all>
	sys_env_destroy(0);
  8000ef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f6:	e8 74 0e 00 00       	call   800f6f <sys_env_destroy>
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
  800154:	e8 8a 0e 00 00       	call   800fe3 <sys_cputs>

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
  8001a8:	e8 36 0e 00 00       	call   800fe3 <sys_cputs>
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
  80023d:	e8 1e 19 00 00       	call   801b60 <__udivdi3>
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
  800298:	e8 f3 19 00 00       	call   801c90 <__umoddi3>
  80029d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002a1:	0f be 80 06 1e 80 00 	movsbl 0x801e06(%eax),%eax
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
  800385:	ff 24 95 e0 1f 80 00 	jmp    *0x801fe0(,%edx,4)
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
  800458:	8b 14 85 40 21 80 00 	mov    0x802140(,%eax,4),%edx
  80045f:	85 d2                	test   %edx,%edx
  800461:	75 20                	jne    800483 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800463:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800467:	c7 44 24 08 17 1e 80 	movl   $0x801e17,0x8(%esp)
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
  800487:	c7 44 24 08 7f 22 80 	movl   $0x80227f,0x8(%esp)
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
  8004c1:	b8 20 1e 80 00       	mov    $0x801e20,%eax
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
  800705:	c7 44 24 0c 3c 1f 80 	movl   $0x801f3c,0xc(%esp)
  80070c:	00 
  80070d:	c7 44 24 08 7f 22 80 	movl   $0x80227f,0x8(%esp)
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
  800733:	c7 44 24 0c 74 1f 80 	movl   $0x801f74,0xc(%esp)
  80073a:	00 
  80073b:	c7 44 24 08 7f 22 80 	movl   $0x80227f,0x8(%esp)
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
  800cd7:	c7 44 24 08 80 21 80 	movl   $0x802180,0x8(%esp)
  800cde:	00 
  800cdf:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800ce6:	00 
  800ce7:	c7 04 24 9d 21 80 00 	movl   $0x80219d,(%esp)
  800cee:	e8 bd 0c 00 00       	call   8019b0 <_panic>

	return ret;
}
  800cf3:	89 d0                	mov    %edx,%eax
  800cf5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cf8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cfb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cfe:	89 ec                	mov    %ebp,%esp
  800d00:	5d                   	pop    %ebp
  800d01:	c3                   	ret    

00800d02 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800d02:	55                   	push   %ebp
  800d03:	89 e5                	mov    %esp,%ebp
  800d05:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d08:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d0f:	00 
  800d10:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d17:	00 
  800d18:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d1f:	00 
  800d20:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d2a:	ba 01 00 00 00       	mov    $0x1,%edx
  800d2f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d34:	e8 53 ff ff ff       	call   800c8c <syscall>
}
  800d39:	c9                   	leave  
  800d3a:	c3                   	ret    

00800d3b <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d41:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d48:	00 
  800d49:	8b 45 14             	mov    0x14(%ebp),%eax
  800d4c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d50:	8b 45 10             	mov    0x10(%ebp),%eax
  800d53:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d5a:	89 04 24             	mov    %eax,(%esp)
  800d5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d60:	ba 00 00 00 00       	mov    $0x0,%edx
  800d65:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d6a:	e8 1d ff ff ff       	call   800c8c <syscall>
}
  800d6f:	c9                   	leave  
  800d70:	c3                   	ret    

00800d71 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d71:	55                   	push   %ebp
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800d77:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d7e:	00 
  800d7f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d86:	00 
  800d87:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d8e:	00 
  800d8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d92:	89 04 24             	mov    %eax,(%esp)
  800d95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d98:	ba 01 00 00 00       	mov    $0x1,%edx
  800d9d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800da2:	e8 e5 fe ff ff       	call   800c8c <syscall>
}
  800da7:	c9                   	leave  
  800da8:	c3                   	ret    

00800da9 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800daf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800db6:	00 
  800db7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800dbe:	00 
  800dbf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800dc6:	00 
  800dc7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dca:	89 04 24             	mov    %eax,(%esp)
  800dcd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd0:	ba 01 00 00 00       	mov    $0x1,%edx
  800dd5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dda:	e8 ad fe ff ff       	call   800c8c <syscall>
}
  800ddf:	c9                   	leave  
  800de0:	c3                   	ret    

00800de1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800de1:	55                   	push   %ebp
  800de2:	89 e5                	mov    %esp,%ebp
  800de4:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800de7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dee:	00 
  800def:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800df6:	00 
  800df7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800dfe:	00 
  800dff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e02:	89 04 24             	mov    %eax,(%esp)
  800e05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e08:	ba 01 00 00 00       	mov    $0x1,%edx
  800e0d:	b8 09 00 00 00       	mov    $0x9,%eax
  800e12:	e8 75 fe ff ff       	call   800c8c <syscall>
}
  800e17:	c9                   	leave  
  800e18:	c3                   	ret    

00800e19 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800e1f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e26:	00 
  800e27:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e2e:	00 
  800e2f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e36:	00 
  800e37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e3a:	89 04 24             	mov    %eax,(%esp)
  800e3d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e40:	ba 01 00 00 00       	mov    $0x1,%edx
  800e45:	b8 07 00 00 00       	mov    $0x7,%eax
  800e4a:	e8 3d fe ff ff       	call   800c8c <syscall>
}
  800e4f:	c9                   	leave  
  800e50:	c3                   	ret    

00800e51 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800e57:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e5e:	00 
  800e5f:	8b 45 18             	mov    0x18(%ebp),%eax
  800e62:	0b 45 14             	or     0x14(%ebp),%eax
  800e65:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e69:	8b 45 10             	mov    0x10(%ebp),%eax
  800e6c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e70:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e73:	89 04 24             	mov    %eax,(%esp)
  800e76:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e79:	ba 01 00 00 00       	mov    $0x1,%edx
  800e7e:	b8 06 00 00 00       	mov    $0x6,%eax
  800e83:	e8 04 fe ff ff       	call   800c8c <syscall>
}
  800e88:	c9                   	leave  
  800e89:	c3                   	ret    

00800e8a <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e8a:	55                   	push   %ebp
  800e8b:	89 e5                	mov    %esp,%ebp
  800e8d:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800e90:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e97:	00 
  800e98:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e9f:	00 
  800ea0:	8b 45 10             	mov    0x10(%ebp),%eax
  800ea3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ea7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eaa:	89 04 24             	mov    %eax,(%esp)
  800ead:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eb0:	ba 01 00 00 00       	mov    $0x1,%edx
  800eb5:	b8 05 00 00 00       	mov    $0x5,%eax
  800eba:	e8 cd fd ff ff       	call   800c8c <syscall>
}
  800ebf:	c9                   	leave  
  800ec0:	c3                   	ret    

00800ec1 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800ec7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ece:	00 
  800ecf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ed6:	00 
  800ed7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ede:	00 
  800edf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ee6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800eeb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ef5:	e8 92 fd ff ff       	call   800c8c <syscall>
}
  800efa:	c9                   	leave  
  800efb:	c3                   	ret    

00800efc <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800efc:	55                   	push   %ebp
  800efd:	89 e5                	mov    %esp,%ebp
  800eff:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  800f02:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f09:	00 
  800f0a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f11:	00 
  800f12:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f19:	00 
  800f1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f1d:	89 04 24             	mov    %eax,(%esp)
  800f20:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f23:	ba 00 00 00 00       	mov    $0x0,%edx
  800f28:	b8 04 00 00 00       	mov    $0x4,%eax
  800f2d:	e8 5a fd ff ff       	call   800c8c <syscall>
}
  800f32:	c9                   	leave  
  800f33:	c3                   	ret    

00800f34 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800f3a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f41:	00 
  800f42:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f49:	00 
  800f4a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f51:	00 
  800f52:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f59:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f63:	b8 02 00 00 00       	mov    $0x2,%eax
  800f68:	e8 1f fd ff ff       	call   800c8c <syscall>
}
  800f6d:	c9                   	leave  
  800f6e:	c3                   	ret    

00800f6f <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800f6f:	55                   	push   %ebp
  800f70:	89 e5                	mov    %esp,%ebp
  800f72:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800f75:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f7c:	00 
  800f7d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f84:	00 
  800f85:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f8c:	00 
  800f8d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f97:	ba 01 00 00 00       	mov    $0x1,%edx
  800f9c:	b8 03 00 00 00       	mov    $0x3,%eax
  800fa1:	e8 e6 fc ff ff       	call   800c8c <syscall>
}
  800fa6:	c9                   	leave  
  800fa7:	c3                   	ret    

00800fa8 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800fae:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fb5:	00 
  800fb6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fbd:	00 
  800fbe:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fc5:	00 
  800fc6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fcd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800fd7:	b8 01 00 00 00       	mov    $0x1,%eax
  800fdc:	e8 ab fc ff ff       	call   800c8c <syscall>
}
  800fe1:	c9                   	leave  
  800fe2:	c3                   	ret    

00800fe3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800fe9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ff0:	00 
  800ff1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ff8:	00 
  800ff9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801000:	00 
  801001:	8b 45 0c             	mov    0xc(%ebp),%eax
  801004:	89 04 24             	mov    %eax,(%esp)
  801007:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80100a:	ba 00 00 00 00       	mov    $0x0,%edx
  80100f:	b8 00 00 00 00       	mov    $0x0,%eax
  801014:	e8 73 fc ff ff       	call   800c8c <syscall>
}
  801019:	c9                   	leave  
  80101a:	c3                   	ret    
	...

0080101c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80101c:	55                   	push   %ebp
  80101d:	89 e5                	mov    %esp,%ebp
  80101f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801022:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  801029:	75 54                	jne    80107f <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  80102b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  801032:	00 
  801033:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80103a:	ee 
  80103b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801042:	e8 43 fe ff ff       	call   800e8a <sys_page_alloc>
  801047:	85 c0                	test   %eax,%eax
  801049:	79 20                	jns    80106b <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  80104b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80104f:	c7 44 24 08 ab 21 80 	movl   $0x8021ab,0x8(%esp)
  801056:	00 
  801057:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80105e:	00 
  80105f:	c7 04 24 c3 21 80 00 	movl   $0x8021c3,(%esp)
  801066:	e8 45 09 00 00       	call   8019b0 <_panic>
		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  80106b:	c7 44 24 04 8c 10 80 	movl   $0x80108c,0x4(%esp)
  801072:	00 
  801073:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80107a:	e8 f2 fc ff ff       	call   800d71 <sys_env_set_pgfault_upcall>

			//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80107f:	8b 45 08             	mov    0x8(%ebp),%eax
  801082:	a3 08 40 80 00       	mov    %eax,0x804008
}
  801087:	c9                   	leave  
  801088:	c3                   	ret    
  801089:	00 00                	add    %al,(%eax)
	...

0080108c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80108c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80108d:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  801092:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801094:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 0x30(%esp), %eax
  801097:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  80109b:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  80109e:	89 44 24 30          	mov    %eax,0x30(%esp)
	# put old eip in the pre-reserved 4 bytes space
	movl 0x28(%esp), %ebx
  8010a2:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8010a6:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	addl $0x8, %esp
  8010a8:	83 c4 08             	add    $0x8,%esp
	popal
  8010ab:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $0x4, %esp
  8010ac:	83 c4 04             	add    $0x4,%esp
	popfl
  8010af:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  8010b0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8010b1:	c3                   	ret    
	...

008010c0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8010c0:	55                   	push   %ebp
  8010c1:	89 e5                	mov    %esp,%ebp
  8010c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c6:	05 00 00 00 30       	add    $0x30000000,%eax
  8010cb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8010ce:	5d                   	pop    %ebp
  8010cf:	c3                   	ret    

008010d0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8010d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d9:	89 04 24             	mov    %eax,(%esp)
  8010dc:	e8 df ff ff ff       	call   8010c0 <fd2num>
  8010e1:	05 20 00 0d 00       	add    $0xd0020,%eax
  8010e6:	c1 e0 0c             	shl    $0xc,%eax
}
  8010e9:	c9                   	leave  
  8010ea:	c3                   	ret    

008010eb <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010eb:	55                   	push   %ebp
  8010ec:	89 e5                	mov    %esp,%ebp
  8010ee:	57                   	push   %edi
  8010ef:	56                   	push   %esi
  8010f0:	53                   	push   %ebx
  8010f1:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  8010f4:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  8010f9:	a8 01                	test   $0x1,%al
  8010fb:	74 36                	je     801133 <fd_alloc+0x48>
  8010fd:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801102:	a8 01                	test   $0x1,%al
  801104:	74 2d                	je     801133 <fd_alloc+0x48>
  801106:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80110b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801110:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801115:	89 c3                	mov    %eax,%ebx
  801117:	89 c2                	mov    %eax,%edx
  801119:	c1 ea 16             	shr    $0x16,%edx
  80111c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80111f:	f6 c2 01             	test   $0x1,%dl
  801122:	74 14                	je     801138 <fd_alloc+0x4d>
  801124:	89 c2                	mov    %eax,%edx
  801126:	c1 ea 0c             	shr    $0xc,%edx
  801129:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80112c:	f6 c2 01             	test   $0x1,%dl
  80112f:	75 10                	jne    801141 <fd_alloc+0x56>
  801131:	eb 05                	jmp    801138 <fd_alloc+0x4d>
  801133:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801138:	89 1f                	mov    %ebx,(%edi)
  80113a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80113f:	eb 17                	jmp    801158 <fd_alloc+0x6d>
  801141:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801146:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80114b:	75 c8                	jne    801115 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80114d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801153:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801158:	5b                   	pop    %ebx
  801159:	5e                   	pop    %esi
  80115a:	5f                   	pop    %edi
  80115b:	5d                   	pop    %ebp
  80115c:	c3                   	ret    

0080115d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80115d:	55                   	push   %ebp
  80115e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801160:	8b 45 08             	mov    0x8(%ebp),%eax
  801163:	83 f8 1f             	cmp    $0x1f,%eax
  801166:	77 36                	ja     80119e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801168:	05 00 00 0d 00       	add    $0xd0000,%eax
  80116d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801170:	89 c2                	mov    %eax,%edx
  801172:	c1 ea 16             	shr    $0x16,%edx
  801175:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80117c:	f6 c2 01             	test   $0x1,%dl
  80117f:	74 1d                	je     80119e <fd_lookup+0x41>
  801181:	89 c2                	mov    %eax,%edx
  801183:	c1 ea 0c             	shr    $0xc,%edx
  801186:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80118d:	f6 c2 01             	test   $0x1,%dl
  801190:	74 0c                	je     80119e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801192:	8b 55 0c             	mov    0xc(%ebp),%edx
  801195:	89 02                	mov    %eax,(%edx)
  801197:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80119c:	eb 05                	jmp    8011a3 <fd_lookup+0x46>
  80119e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8011a3:	5d                   	pop    %ebp
  8011a4:	c3                   	ret    

008011a5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011ab:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8011b5:	89 04 24             	mov    %eax,(%esp)
  8011b8:	e8 a0 ff ff ff       	call   80115d <fd_lookup>
  8011bd:	85 c0                	test   %eax,%eax
  8011bf:	78 0e                	js     8011cf <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8011c1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011c7:	89 50 04             	mov    %edx,0x4(%eax)
  8011ca:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8011cf:	c9                   	leave  
  8011d0:	c3                   	ret    

008011d1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8011d1:	55                   	push   %ebp
  8011d2:	89 e5                	mov    %esp,%ebp
  8011d4:	56                   	push   %esi
  8011d5:	53                   	push   %ebx
  8011d6:	83 ec 10             	sub    $0x10,%esp
  8011d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011dc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8011df:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  8011e4:	b8 04 30 80 00       	mov    $0x803004,%eax
  8011e9:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  8011ef:	75 11                	jne    801202 <dev_lookup+0x31>
  8011f1:	eb 04                	jmp    8011f7 <dev_lookup+0x26>
  8011f3:	39 08                	cmp    %ecx,(%eax)
  8011f5:	75 10                	jne    801207 <dev_lookup+0x36>
			*dev = devtab[i];
  8011f7:	89 03                	mov    %eax,(%ebx)
  8011f9:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8011fe:	66 90                	xchg   %ax,%ax
  801200:	eb 36                	jmp    801238 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801202:	be 50 22 80 00       	mov    $0x802250,%esi
  801207:	83 c2 01             	add    $0x1,%edx
  80120a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80120d:	85 c0                	test   %eax,%eax
  80120f:	75 e2                	jne    8011f3 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801211:	a1 04 40 80 00       	mov    0x804004,%eax
  801216:	8b 40 48             	mov    0x48(%eax),%eax
  801219:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80121d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801221:	c7 04 24 d4 21 80 00 	movl   $0x8021d4,(%esp)
  801228:	e8 34 ef ff ff       	call   800161 <cprintf>
	*dev = 0;
  80122d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801233:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801238:	83 c4 10             	add    $0x10,%esp
  80123b:	5b                   	pop    %ebx
  80123c:	5e                   	pop    %esi
  80123d:	5d                   	pop    %ebp
  80123e:	c3                   	ret    

0080123f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80123f:	55                   	push   %ebp
  801240:	89 e5                	mov    %esp,%ebp
  801242:	53                   	push   %ebx
  801243:	83 ec 24             	sub    $0x24,%esp
  801246:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801249:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801250:	8b 45 08             	mov    0x8(%ebp),%eax
  801253:	89 04 24             	mov    %eax,(%esp)
  801256:	e8 02 ff ff ff       	call   80115d <fd_lookup>
  80125b:	85 c0                	test   %eax,%eax
  80125d:	78 53                	js     8012b2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801262:	89 44 24 04          	mov    %eax,0x4(%esp)
  801266:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801269:	8b 00                	mov    (%eax),%eax
  80126b:	89 04 24             	mov    %eax,(%esp)
  80126e:	e8 5e ff ff ff       	call   8011d1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801273:	85 c0                	test   %eax,%eax
  801275:	78 3b                	js     8012b2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801277:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80127c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80127f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  801283:	74 2d                	je     8012b2 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801285:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801288:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80128f:	00 00 00 
	stat->st_isdir = 0;
  801292:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801299:	00 00 00 
	stat->st_dev = dev;
  80129c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80129f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012a5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8012a9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012ac:	89 14 24             	mov    %edx,(%esp)
  8012af:	ff 50 14             	call   *0x14(%eax)
}
  8012b2:	83 c4 24             	add    $0x24,%esp
  8012b5:	5b                   	pop    %ebx
  8012b6:	5d                   	pop    %ebp
  8012b7:	c3                   	ret    

008012b8 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8012b8:	55                   	push   %ebp
  8012b9:	89 e5                	mov    %esp,%ebp
  8012bb:	53                   	push   %ebx
  8012bc:	83 ec 24             	sub    $0x24,%esp
  8012bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012c2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c9:	89 1c 24             	mov    %ebx,(%esp)
  8012cc:	e8 8c fe ff ff       	call   80115d <fd_lookup>
  8012d1:	85 c0                	test   %eax,%eax
  8012d3:	78 5f                	js     801334 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012df:	8b 00                	mov    (%eax),%eax
  8012e1:	89 04 24             	mov    %eax,(%esp)
  8012e4:	e8 e8 fe ff ff       	call   8011d1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012e9:	85 c0                	test   %eax,%eax
  8012eb:	78 47                	js     801334 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012ed:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012f0:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8012f4:	75 23                	jne    801319 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012f6:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012fb:	8b 40 48             	mov    0x48(%eax),%eax
  8012fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801302:	89 44 24 04          	mov    %eax,0x4(%esp)
  801306:	c7 04 24 f4 21 80 00 	movl   $0x8021f4,(%esp)
  80130d:	e8 4f ee ff ff       	call   800161 <cprintf>
  801312:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801317:	eb 1b                	jmp    801334 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801319:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80131c:	8b 48 18             	mov    0x18(%eax),%ecx
  80131f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801324:	85 c9                	test   %ecx,%ecx
  801326:	74 0c                	je     801334 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801328:	8b 45 0c             	mov    0xc(%ebp),%eax
  80132b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80132f:	89 14 24             	mov    %edx,(%esp)
  801332:	ff d1                	call   *%ecx
}
  801334:	83 c4 24             	add    $0x24,%esp
  801337:	5b                   	pop    %ebx
  801338:	5d                   	pop    %ebp
  801339:	c3                   	ret    

0080133a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80133a:	55                   	push   %ebp
  80133b:	89 e5                	mov    %esp,%ebp
  80133d:	53                   	push   %ebx
  80133e:	83 ec 24             	sub    $0x24,%esp
  801341:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801344:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801347:	89 44 24 04          	mov    %eax,0x4(%esp)
  80134b:	89 1c 24             	mov    %ebx,(%esp)
  80134e:	e8 0a fe ff ff       	call   80115d <fd_lookup>
  801353:	85 c0                	test   %eax,%eax
  801355:	78 66                	js     8013bd <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801357:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80135a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80135e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801361:	8b 00                	mov    (%eax),%eax
  801363:	89 04 24             	mov    %eax,(%esp)
  801366:	e8 66 fe ff ff       	call   8011d1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80136b:	85 c0                	test   %eax,%eax
  80136d:	78 4e                	js     8013bd <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80136f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801372:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801376:	75 23                	jne    80139b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801378:	a1 04 40 80 00       	mov    0x804004,%eax
  80137d:	8b 40 48             	mov    0x48(%eax),%eax
  801380:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801384:	89 44 24 04          	mov    %eax,0x4(%esp)
  801388:	c7 04 24 15 22 80 00 	movl   $0x802215,(%esp)
  80138f:	e8 cd ed ff ff       	call   800161 <cprintf>
  801394:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801399:	eb 22                	jmp    8013bd <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80139b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80139e:	8b 48 0c             	mov    0xc(%eax),%ecx
  8013a1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013a6:	85 c9                	test   %ecx,%ecx
  8013a8:	74 13                	je     8013bd <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8013aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8013ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013b1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b8:	89 14 24             	mov    %edx,(%esp)
  8013bb:	ff d1                	call   *%ecx
}
  8013bd:	83 c4 24             	add    $0x24,%esp
  8013c0:	5b                   	pop    %ebx
  8013c1:	5d                   	pop    %ebp
  8013c2:	c3                   	ret    

008013c3 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8013c3:	55                   	push   %ebp
  8013c4:	89 e5                	mov    %esp,%ebp
  8013c6:	53                   	push   %ebx
  8013c7:	83 ec 24             	sub    $0x24,%esp
  8013ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013d0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013d4:	89 1c 24             	mov    %ebx,(%esp)
  8013d7:	e8 81 fd ff ff       	call   80115d <fd_lookup>
  8013dc:	85 c0                	test   %eax,%eax
  8013de:	78 6b                	js     80144b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013e0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013e3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ea:	8b 00                	mov    (%eax),%eax
  8013ec:	89 04 24             	mov    %eax,(%esp)
  8013ef:	e8 dd fd ff ff       	call   8011d1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013f4:	85 c0                	test   %eax,%eax
  8013f6:	78 53                	js     80144b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8013f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8013fb:	8b 42 08             	mov    0x8(%edx),%eax
  8013fe:	83 e0 03             	and    $0x3,%eax
  801401:	83 f8 01             	cmp    $0x1,%eax
  801404:	75 23                	jne    801429 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801406:	a1 04 40 80 00       	mov    0x804004,%eax
  80140b:	8b 40 48             	mov    0x48(%eax),%eax
  80140e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801412:	89 44 24 04          	mov    %eax,0x4(%esp)
  801416:	c7 04 24 32 22 80 00 	movl   $0x802232,(%esp)
  80141d:	e8 3f ed ff ff       	call   800161 <cprintf>
  801422:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801427:	eb 22                	jmp    80144b <read+0x88>
	}
	if (!dev->dev_read)
  801429:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80142c:	8b 48 08             	mov    0x8(%eax),%ecx
  80142f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801434:	85 c9                	test   %ecx,%ecx
  801436:	74 13                	je     80144b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801438:	8b 45 10             	mov    0x10(%ebp),%eax
  80143b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80143f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801442:	89 44 24 04          	mov    %eax,0x4(%esp)
  801446:	89 14 24             	mov    %edx,(%esp)
  801449:	ff d1                	call   *%ecx
}
  80144b:	83 c4 24             	add    $0x24,%esp
  80144e:	5b                   	pop    %ebx
  80144f:	5d                   	pop    %ebp
  801450:	c3                   	ret    

00801451 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801451:	55                   	push   %ebp
  801452:	89 e5                	mov    %esp,%ebp
  801454:	57                   	push   %edi
  801455:	56                   	push   %esi
  801456:	53                   	push   %ebx
  801457:	83 ec 1c             	sub    $0x1c,%esp
  80145a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80145d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801460:	ba 00 00 00 00       	mov    $0x0,%edx
  801465:	bb 00 00 00 00       	mov    $0x0,%ebx
  80146a:	b8 00 00 00 00       	mov    $0x0,%eax
  80146f:	85 f6                	test   %esi,%esi
  801471:	74 29                	je     80149c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801473:	89 f0                	mov    %esi,%eax
  801475:	29 d0                	sub    %edx,%eax
  801477:	89 44 24 08          	mov    %eax,0x8(%esp)
  80147b:	03 55 0c             	add    0xc(%ebp),%edx
  80147e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801482:	89 3c 24             	mov    %edi,(%esp)
  801485:	e8 39 ff ff ff       	call   8013c3 <read>
		if (m < 0)
  80148a:	85 c0                	test   %eax,%eax
  80148c:	78 0e                	js     80149c <readn+0x4b>
			return m;
		if (m == 0)
  80148e:	85 c0                	test   %eax,%eax
  801490:	74 08                	je     80149a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801492:	01 c3                	add    %eax,%ebx
  801494:	89 da                	mov    %ebx,%edx
  801496:	39 f3                	cmp    %esi,%ebx
  801498:	72 d9                	jb     801473 <readn+0x22>
  80149a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80149c:	83 c4 1c             	add    $0x1c,%esp
  80149f:	5b                   	pop    %ebx
  8014a0:	5e                   	pop    %esi
  8014a1:	5f                   	pop    %edi
  8014a2:	5d                   	pop    %ebp
  8014a3:	c3                   	ret    

008014a4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014a4:	55                   	push   %ebp
  8014a5:	89 e5                	mov    %esp,%ebp
  8014a7:	83 ec 28             	sub    $0x28,%esp
  8014aa:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8014ad:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8014b0:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014b3:	89 34 24             	mov    %esi,(%esp)
  8014b6:	e8 05 fc ff ff       	call   8010c0 <fd2num>
  8014bb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8014be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8014c2:	89 04 24             	mov    %eax,(%esp)
  8014c5:	e8 93 fc ff ff       	call   80115d <fd_lookup>
  8014ca:	89 c3                	mov    %eax,%ebx
  8014cc:	85 c0                	test   %eax,%eax
  8014ce:	78 05                	js     8014d5 <fd_close+0x31>
  8014d0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014d3:	74 0e                	je     8014e3 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  8014d5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8014d9:	b8 00 00 00 00       	mov    $0x0,%eax
  8014de:	0f 44 d8             	cmove  %eax,%ebx
  8014e1:	eb 3d                	jmp    801520 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014ea:	8b 06                	mov    (%esi),%eax
  8014ec:	89 04 24             	mov    %eax,(%esp)
  8014ef:	e8 dd fc ff ff       	call   8011d1 <dev_lookup>
  8014f4:	89 c3                	mov    %eax,%ebx
  8014f6:	85 c0                	test   %eax,%eax
  8014f8:	78 16                	js     801510 <fd_close+0x6c>
		if (dev->dev_close)
  8014fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014fd:	8b 40 10             	mov    0x10(%eax),%eax
  801500:	bb 00 00 00 00       	mov    $0x0,%ebx
  801505:	85 c0                	test   %eax,%eax
  801507:	74 07                	je     801510 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801509:	89 34 24             	mov    %esi,(%esp)
  80150c:	ff d0                	call   *%eax
  80150e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801510:	89 74 24 04          	mov    %esi,0x4(%esp)
  801514:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80151b:	e8 f9 f8 ff ff       	call   800e19 <sys_page_unmap>
	return r;
}
  801520:	89 d8                	mov    %ebx,%eax
  801522:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801525:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801528:	89 ec                	mov    %ebp,%esp
  80152a:	5d                   	pop    %ebp
  80152b:	c3                   	ret    

0080152c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80152c:	55                   	push   %ebp
  80152d:	89 e5                	mov    %esp,%ebp
  80152f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801532:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801535:	89 44 24 04          	mov    %eax,0x4(%esp)
  801539:	8b 45 08             	mov    0x8(%ebp),%eax
  80153c:	89 04 24             	mov    %eax,(%esp)
  80153f:	e8 19 fc ff ff       	call   80115d <fd_lookup>
  801544:	85 c0                	test   %eax,%eax
  801546:	78 13                	js     80155b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801548:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80154f:	00 
  801550:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801553:	89 04 24             	mov    %eax,(%esp)
  801556:	e8 49 ff ff ff       	call   8014a4 <fd_close>
}
  80155b:	c9                   	leave  
  80155c:	c3                   	ret    

0080155d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80155d:	55                   	push   %ebp
  80155e:	89 e5                	mov    %esp,%ebp
  801560:	83 ec 18             	sub    $0x18,%esp
  801563:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801566:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801569:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801570:	00 
  801571:	8b 45 08             	mov    0x8(%ebp),%eax
  801574:	89 04 24             	mov    %eax,(%esp)
  801577:	e8 78 03 00 00       	call   8018f4 <open>
  80157c:	89 c3                	mov    %eax,%ebx
  80157e:	85 c0                	test   %eax,%eax
  801580:	78 1b                	js     80159d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801582:	8b 45 0c             	mov    0xc(%ebp),%eax
  801585:	89 44 24 04          	mov    %eax,0x4(%esp)
  801589:	89 1c 24             	mov    %ebx,(%esp)
  80158c:	e8 ae fc ff ff       	call   80123f <fstat>
  801591:	89 c6                	mov    %eax,%esi
	close(fd);
  801593:	89 1c 24             	mov    %ebx,(%esp)
  801596:	e8 91 ff ff ff       	call   80152c <close>
  80159b:	89 f3                	mov    %esi,%ebx
	return r;
}
  80159d:	89 d8                	mov    %ebx,%eax
  80159f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8015a2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8015a5:	89 ec                	mov    %ebp,%esp
  8015a7:	5d                   	pop    %ebp
  8015a8:	c3                   	ret    

008015a9 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8015a9:	55                   	push   %ebp
  8015aa:	89 e5                	mov    %esp,%ebp
  8015ac:	53                   	push   %ebx
  8015ad:	83 ec 14             	sub    $0x14,%esp
  8015b0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8015b5:	89 1c 24             	mov    %ebx,(%esp)
  8015b8:	e8 6f ff ff ff       	call   80152c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8015bd:	83 c3 01             	add    $0x1,%ebx
  8015c0:	83 fb 20             	cmp    $0x20,%ebx
  8015c3:	75 f0                	jne    8015b5 <close_all+0xc>
		close(i);
}
  8015c5:	83 c4 14             	add    $0x14,%esp
  8015c8:	5b                   	pop    %ebx
  8015c9:	5d                   	pop    %ebp
  8015ca:	c3                   	ret    

008015cb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015cb:	55                   	push   %ebp
  8015cc:	89 e5                	mov    %esp,%ebp
  8015ce:	83 ec 58             	sub    $0x58,%esp
  8015d1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8015d4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8015d7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  8015da:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015dd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015e0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e7:	89 04 24             	mov    %eax,(%esp)
  8015ea:	e8 6e fb ff ff       	call   80115d <fd_lookup>
  8015ef:	89 c3                	mov    %eax,%ebx
  8015f1:	85 c0                	test   %eax,%eax
  8015f3:	0f 88 e0 00 00 00    	js     8016d9 <dup+0x10e>
		return r;
	close(newfdnum);
  8015f9:	89 3c 24             	mov    %edi,(%esp)
  8015fc:	e8 2b ff ff ff       	call   80152c <close>

	newfd = INDEX2FD(newfdnum);
  801601:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801607:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80160a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80160d:	89 04 24             	mov    %eax,(%esp)
  801610:	e8 bb fa ff ff       	call   8010d0 <fd2data>
  801615:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801617:	89 34 24             	mov    %esi,(%esp)
  80161a:	e8 b1 fa ff ff       	call   8010d0 <fd2data>
  80161f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801622:	89 da                	mov    %ebx,%edx
  801624:	89 d8                	mov    %ebx,%eax
  801626:	c1 e8 16             	shr    $0x16,%eax
  801629:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801630:	a8 01                	test   $0x1,%al
  801632:	74 43                	je     801677 <dup+0xac>
  801634:	c1 ea 0c             	shr    $0xc,%edx
  801637:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80163e:	a8 01                	test   $0x1,%al
  801640:	74 35                	je     801677 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801642:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801649:	25 07 0e 00 00       	and    $0xe07,%eax
  80164e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801652:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801655:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801659:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801660:	00 
  801661:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801665:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80166c:	e8 e0 f7 ff ff       	call   800e51 <sys_page_map>
  801671:	89 c3                	mov    %eax,%ebx
  801673:	85 c0                	test   %eax,%eax
  801675:	78 3f                	js     8016b6 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801677:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80167a:	89 c2                	mov    %eax,%edx
  80167c:	c1 ea 0c             	shr    $0xc,%edx
  80167f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801686:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  80168c:	89 54 24 10          	mov    %edx,0x10(%esp)
  801690:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801694:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80169b:	00 
  80169c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016a0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016a7:	e8 a5 f7 ff ff       	call   800e51 <sys_page_map>
  8016ac:	89 c3                	mov    %eax,%ebx
  8016ae:	85 c0                	test   %eax,%eax
  8016b0:	78 04                	js     8016b6 <dup+0xeb>
  8016b2:	89 fb                	mov    %edi,%ebx
  8016b4:	eb 23                	jmp    8016d9 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8016b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016ba:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016c1:	e8 53 f7 ff ff       	call   800e19 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016c6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8016c9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8016cd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016d4:	e8 40 f7 ff ff       	call   800e19 <sys_page_unmap>
	return r;
}
  8016d9:	89 d8                	mov    %ebx,%eax
  8016db:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8016de:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8016e1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8016e4:	89 ec                	mov    %ebp,%esp
  8016e6:	5d                   	pop    %ebp
  8016e7:	c3                   	ret    

008016e8 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	83 ec 18             	sub    $0x18,%esp
  8016ee:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8016f1:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8016f4:	89 c3                	mov    %eax,%ebx
  8016f6:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  8016f8:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8016ff:	75 11                	jne    801712 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801701:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801708:	e8 03 03 00 00       	call   801a10 <ipc_find_env>
  80170d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801712:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801719:	00 
  80171a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801721:	00 
  801722:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801726:	a1 00 40 80 00       	mov    0x804000,%eax
  80172b:	89 04 24             	mov    %eax,(%esp)
  80172e:	e8 21 03 00 00       	call   801a54 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801733:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80173a:	00 
  80173b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80173f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801746:	e8 78 03 00 00       	call   801ac3 <ipc_recv>
}
  80174b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80174e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801751:	89 ec                	mov    %ebp,%esp
  801753:	5d                   	pop    %ebp
  801754:	c3                   	ret    

00801755 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80175b:	8b 45 08             	mov    0x8(%ebp),%eax
  80175e:	8b 40 0c             	mov    0xc(%eax),%eax
  801761:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801766:	8b 45 0c             	mov    0xc(%ebp),%eax
  801769:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80176e:	ba 00 00 00 00       	mov    $0x0,%edx
  801773:	b8 02 00 00 00       	mov    $0x2,%eax
  801778:	e8 6b ff ff ff       	call   8016e8 <fsipc>
}
  80177d:	c9                   	leave  
  80177e:	c3                   	ret    

0080177f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80177f:	55                   	push   %ebp
  801780:	89 e5                	mov    %esp,%ebp
  801782:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801785:	8b 45 08             	mov    0x8(%ebp),%eax
  801788:	8b 40 0c             	mov    0xc(%eax),%eax
  80178b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801790:	ba 00 00 00 00       	mov    $0x0,%edx
  801795:	b8 06 00 00 00       	mov    $0x6,%eax
  80179a:	e8 49 ff ff ff       	call   8016e8 <fsipc>
}
  80179f:	c9                   	leave  
  8017a0:	c3                   	ret    

008017a1 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  8017a1:	55                   	push   %ebp
  8017a2:	89 e5                	mov    %esp,%ebp
  8017a4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8017a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ac:	b8 08 00 00 00       	mov    $0x8,%eax
  8017b1:	e8 32 ff ff ff       	call   8016e8 <fsipc>
}
  8017b6:	c9                   	leave  
  8017b7:	c3                   	ret    

008017b8 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017b8:	55                   	push   %ebp
  8017b9:	89 e5                	mov    %esp,%ebp
  8017bb:	53                   	push   %ebx
  8017bc:	83 ec 14             	sub    $0x14,%esp
  8017bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8017c8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8017d2:	b8 05 00 00 00       	mov    $0x5,%eax
  8017d7:	e8 0c ff ff ff       	call   8016e8 <fsipc>
  8017dc:	85 c0                	test   %eax,%eax
  8017de:	78 2b                	js     80180b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017e0:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8017e7:	00 
  8017e8:	89 1c 24             	mov    %ebx,(%esp)
  8017eb:	e8 aa f0 ff ff       	call   80089a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017f0:	a1 80 50 80 00       	mov    0x805080,%eax
  8017f5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8017fb:	a1 84 50 80 00       	mov    0x805084,%eax
  801800:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801806:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80180b:	83 c4 14             	add    $0x14,%esp
  80180e:	5b                   	pop    %ebx
  80180f:	5d                   	pop    %ebp
  801810:	c3                   	ret    

00801811 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801811:	55                   	push   %ebp
  801812:	89 e5                	mov    %esp,%ebp
  801814:	83 ec 18             	sub    $0x18,%esp
  801817:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  80181a:	8b 55 08             	mov    0x8(%ebp),%edx
  80181d:	8b 52 0c             	mov    0xc(%edx),%edx
  801820:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  801826:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  80182b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801830:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801835:	0f 47 c2             	cmova  %edx,%eax
  801838:	89 44 24 08          	mov    %eax,0x8(%esp)
  80183c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80183f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801843:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  80184a:	e8 36 f2 ff ff       	call   800a85 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  80184f:	ba 00 00 00 00       	mov    $0x0,%edx
  801854:	b8 04 00 00 00       	mov    $0x4,%eax
  801859:	e8 8a fe ff ff       	call   8016e8 <fsipc>
}
  80185e:	c9                   	leave  
  80185f:	c3                   	ret    

00801860 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801860:	55                   	push   %ebp
  801861:	89 e5                	mov    %esp,%ebp
  801863:	53                   	push   %ebx
  801864:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801867:	8b 45 08             	mov    0x8(%ebp),%eax
  80186a:	8b 40 0c             	mov    0xc(%eax),%eax
  80186d:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  801872:	8b 45 10             	mov    0x10(%ebp),%eax
  801875:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  80187a:	ba 00 00 00 00       	mov    $0x0,%edx
  80187f:	b8 03 00 00 00       	mov    $0x3,%eax
  801884:	e8 5f fe ff ff       	call   8016e8 <fsipc>
  801889:	89 c3                	mov    %eax,%ebx
  80188b:	85 c0                	test   %eax,%eax
  80188d:	78 17                	js     8018a6 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80188f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801893:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80189a:	00 
  80189b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80189e:	89 04 24             	mov    %eax,(%esp)
  8018a1:	e8 df f1 ff ff       	call   800a85 <memmove>
  return r;	
}
  8018a6:	89 d8                	mov    %ebx,%eax
  8018a8:	83 c4 14             	add    $0x14,%esp
  8018ab:	5b                   	pop    %ebx
  8018ac:	5d                   	pop    %ebp
  8018ad:	c3                   	ret    

008018ae <remove>:
}

// Delete a file
int
remove(const char *path)
{
  8018ae:	55                   	push   %ebp
  8018af:	89 e5                	mov    %esp,%ebp
  8018b1:	53                   	push   %ebx
  8018b2:	83 ec 14             	sub    $0x14,%esp
  8018b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8018b8:	89 1c 24             	mov    %ebx,(%esp)
  8018bb:	e8 90 ef ff ff       	call   800850 <strlen>
  8018c0:	89 c2                	mov    %eax,%edx
  8018c2:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  8018c7:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  8018cd:	7f 1f                	jg     8018ee <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  8018cf:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018d3:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8018da:	e8 bb ef ff ff       	call   80089a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  8018df:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e4:	b8 07 00 00 00       	mov    $0x7,%eax
  8018e9:	e8 fa fd ff ff       	call   8016e8 <fsipc>
}
  8018ee:	83 c4 14             	add    $0x14,%esp
  8018f1:	5b                   	pop    %ebx
  8018f2:	5d                   	pop    %ebp
  8018f3:	c3                   	ret    

008018f4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018f4:	55                   	push   %ebp
  8018f5:	89 e5                	mov    %esp,%ebp
  8018f7:	83 ec 28             	sub    $0x28,%esp
  8018fa:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8018fd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801900:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801903:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801906:	89 04 24             	mov    %eax,(%esp)
  801909:	e8 dd f7 ff ff       	call   8010eb <fd_alloc>
  80190e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801910:	85 c0                	test   %eax,%eax
  801912:	0f 88 89 00 00 00    	js     8019a1 <open+0xad>

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801918:	89 34 24             	mov    %esi,(%esp)
  80191b:	e8 30 ef ff ff       	call   800850 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801920:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801925:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80192a:	7f 75                	jg     8019a1 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  80192c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801930:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801937:	e8 5e ef ff ff       	call   80089a <strcpy>
  fsipcbuf.open.req_omode = mode;
  80193c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80193f:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  801944:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801947:	b8 01 00 00 00       	mov    $0x1,%eax
  80194c:	e8 97 fd ff ff       	call   8016e8 <fsipc>
  801951:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801953:	85 c0                	test   %eax,%eax
  801955:	78 0f                	js     801966 <open+0x72>
  return fd2num(fd);
  801957:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80195a:	89 04 24             	mov    %eax,(%esp)
  80195d:	e8 5e f7 ff ff       	call   8010c0 <fd2num>
  801962:	89 c3                	mov    %eax,%ebx
  801964:	eb 3b                	jmp    8019a1 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801966:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80196d:	00 
  80196e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801971:	89 04 24             	mov    %eax,(%esp)
  801974:	e8 2b fb ff ff       	call   8014a4 <fd_close>
  801979:	85 c0                	test   %eax,%eax
  80197b:	74 24                	je     8019a1 <open+0xad>
  80197d:	c7 44 24 0c 58 22 80 	movl   $0x802258,0xc(%esp)
  801984:	00 
  801985:	c7 44 24 08 6d 22 80 	movl   $0x80226d,0x8(%esp)
  80198c:	00 
  80198d:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801994:	00 
  801995:	c7 04 24 82 22 80 00 	movl   $0x802282,(%esp)
  80199c:	e8 0f 00 00 00       	call   8019b0 <_panic>
  return r;
}
  8019a1:	89 d8                	mov    %ebx,%eax
  8019a3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8019a6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8019a9:	89 ec                	mov    %ebp,%esp
  8019ab:	5d                   	pop    %ebp
  8019ac:	c3                   	ret    
  8019ad:	00 00                	add    %al,(%eax)
	...

008019b0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8019b0:	55                   	push   %ebp
  8019b1:	89 e5                	mov    %esp,%ebp
  8019b3:	56                   	push   %esi
  8019b4:	53                   	push   %ebx
  8019b5:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8019b8:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8019bb:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8019c1:	e8 6e f5 ff ff       	call   800f34 <sys_getenvid>
  8019c6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019c9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8019cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8019d0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8019d4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019dc:	c7 04 24 90 22 80 00 	movl   $0x802290,(%esp)
  8019e3:	e8 79 e7 ff ff       	call   800161 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8019e8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8019ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8019ef:	89 04 24             	mov    %eax,(%esp)
  8019f2:	e8 09 e7 ff ff       	call   800100 <vcprintf>
	cprintf("\n");
  8019f7:	c7 04 24 4c 22 80 00 	movl   $0x80224c,(%esp)
  8019fe:	e8 5e e7 ff ff       	call   800161 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a03:	cc                   	int3   
  801a04:	eb fd                	jmp    801a03 <_panic+0x53>
	...

00801a10 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801a10:	55                   	push   %ebp
  801a11:	89 e5                	mov    %esp,%ebp
  801a13:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801a16:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801a1c:	b8 01 00 00 00       	mov    $0x1,%eax
  801a21:	39 ca                	cmp    %ecx,%edx
  801a23:	75 04                	jne    801a29 <ipc_find_env+0x19>
  801a25:	b0 00                	mov    $0x0,%al
  801a27:	eb 0f                	jmp    801a38 <ipc_find_env+0x28>
  801a29:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801a2c:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801a32:	8b 12                	mov    (%edx),%edx
  801a34:	39 ca                	cmp    %ecx,%edx
  801a36:	75 0c                	jne    801a44 <ipc_find_env+0x34>
			return envs[i].env_id;
  801a38:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a3b:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  801a40:	8b 00                	mov    (%eax),%eax
  801a42:	eb 0e                	jmp    801a52 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801a44:	83 c0 01             	add    $0x1,%eax
  801a47:	3d 00 04 00 00       	cmp    $0x400,%eax
  801a4c:	75 db                	jne    801a29 <ipc_find_env+0x19>
  801a4e:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801a52:	5d                   	pop    %ebp
  801a53:	c3                   	ret    

00801a54 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
  801a57:	57                   	push   %edi
  801a58:	56                   	push   %esi
  801a59:	53                   	push   %ebx
  801a5a:	83 ec 1c             	sub    $0x1c,%esp
  801a5d:	8b 75 08             	mov    0x8(%ebp),%esi
  801a60:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801a63:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801a66:	85 db                	test   %ebx,%ebx
  801a68:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  801a6d:	0f 44 d8             	cmove  %eax,%ebx
  801a70:	eb 29                	jmp    801a9b <ipc_send+0x47>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
  801a72:	85 c0                	test   %eax,%eax
  801a74:	79 25                	jns    801a9b <ipc_send+0x47>
  801a76:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801a79:	74 20                	je     801a9b <ipc_send+0x47>
			panic ("ipc: sys try send failed : %e", r);
  801a7b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a7f:	c7 44 24 08 b4 22 80 	movl   $0x8022b4,0x8(%esp)
  801a86:	00 
  801a87:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  801a8e:	00 
  801a8f:	c7 04 24 d2 22 80 00 	movl   $0x8022d2,(%esp)
  801a96:	e8 15 ff ff ff       	call   8019b0 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  801a9b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a9e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801aa2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801aa6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801aaa:	89 34 24             	mov    %esi,(%esp)
  801aad:	e8 89 f2 ff ff       	call   800d3b <sys_ipc_try_send>
  801ab2:	85 c0                	test   %eax,%eax
  801ab4:	75 bc                	jne    801a72 <ipc_send+0x1e>
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  801ab6:	e8 06 f4 ff ff       	call   800ec1 <sys_yield>
}
  801abb:	83 c4 1c             	add    $0x1c,%esp
  801abe:	5b                   	pop    %ebx
  801abf:	5e                   	pop    %esi
  801ac0:	5f                   	pop    %edi
  801ac1:	5d                   	pop    %ebp
  801ac2:	c3                   	ret    

00801ac3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ac3:	55                   	push   %ebp
  801ac4:	89 e5                	mov    %esp,%ebp
  801ac6:	83 ec 28             	sub    $0x28,%esp
  801ac9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801acc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801acf:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801ad2:	8b 75 08             	mov    0x8(%ebp),%esi
  801ad5:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ad8:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801adb:	85 c0                	test   %eax,%eax
  801add:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ae2:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801ae5:	89 04 24             	mov    %eax,(%esp)
  801ae8:	e8 15 f2 ff ff       	call   800d02 <sys_ipc_recv>
  801aed:	89 c3                	mov    %eax,%ebx
  801aef:	85 c0                	test   %eax,%eax
  801af1:	79 2a                	jns    801b1d <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  801af3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801af7:	89 44 24 04          	mov    %eax,0x4(%esp)
  801afb:	c7 04 24 dc 22 80 00 	movl   $0x8022dc,(%esp)
  801b02:	e8 5a e6 ff ff       	call   800161 <cprintf>
		if(from_env_store != NULL)
  801b07:	85 f6                	test   %esi,%esi
  801b09:	74 06                	je     801b11 <ipc_recv+0x4e>
			*from_env_store = 0;
  801b0b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801b11:	85 ff                	test   %edi,%edi
  801b13:	74 2d                	je     801b42 <ipc_recv+0x7f>
			*perm_store = 0;
  801b15:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801b1b:	eb 25                	jmp    801b42 <ipc_recv+0x7f>
		return r;
	}
	if(from_env_store != NULL)
  801b1d:	85 f6                	test   %esi,%esi
  801b1f:	90                   	nop
  801b20:	74 0a                	je     801b2c <ipc_recv+0x69>
		*from_env_store = thisenv->env_ipc_from;
  801b22:	a1 04 40 80 00       	mov    0x804004,%eax
  801b27:	8b 40 74             	mov    0x74(%eax),%eax
  801b2a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801b2c:	85 ff                	test   %edi,%edi
  801b2e:	74 0a                	je     801b3a <ipc_recv+0x77>
		*perm_store = thisenv->env_ipc_perm;
  801b30:	a1 04 40 80 00       	mov    0x804004,%eax
  801b35:	8b 40 78             	mov    0x78(%eax),%eax
  801b38:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801b3a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b3f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  801b42:	89 d8                	mov    %ebx,%eax
  801b44:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801b47:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801b4a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801b4d:	89 ec                	mov    %ebp,%esp
  801b4f:	5d                   	pop    %ebp
  801b50:	c3                   	ret    
	...

00801b60 <__udivdi3>:
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	57                   	push   %edi
  801b64:	56                   	push   %esi
  801b65:	83 ec 10             	sub    $0x10,%esp
  801b68:	8b 45 14             	mov    0x14(%ebp),%eax
  801b6b:	8b 55 08             	mov    0x8(%ebp),%edx
  801b6e:	8b 75 10             	mov    0x10(%ebp),%esi
  801b71:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801b74:	85 c0                	test   %eax,%eax
  801b76:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801b79:	75 35                	jne    801bb0 <__udivdi3+0x50>
  801b7b:	39 fe                	cmp    %edi,%esi
  801b7d:	77 61                	ja     801be0 <__udivdi3+0x80>
  801b7f:	85 f6                	test   %esi,%esi
  801b81:	75 0b                	jne    801b8e <__udivdi3+0x2e>
  801b83:	b8 01 00 00 00       	mov    $0x1,%eax
  801b88:	31 d2                	xor    %edx,%edx
  801b8a:	f7 f6                	div    %esi
  801b8c:	89 c6                	mov    %eax,%esi
  801b8e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801b91:	31 d2                	xor    %edx,%edx
  801b93:	89 f8                	mov    %edi,%eax
  801b95:	f7 f6                	div    %esi
  801b97:	89 c7                	mov    %eax,%edi
  801b99:	89 c8                	mov    %ecx,%eax
  801b9b:	f7 f6                	div    %esi
  801b9d:	89 c1                	mov    %eax,%ecx
  801b9f:	89 fa                	mov    %edi,%edx
  801ba1:	89 c8                	mov    %ecx,%eax
  801ba3:	83 c4 10             	add    $0x10,%esp
  801ba6:	5e                   	pop    %esi
  801ba7:	5f                   	pop    %edi
  801ba8:	5d                   	pop    %ebp
  801ba9:	c3                   	ret    
  801baa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801bb0:	39 f8                	cmp    %edi,%eax
  801bb2:	77 1c                	ja     801bd0 <__udivdi3+0x70>
  801bb4:	0f bd d0             	bsr    %eax,%edx
  801bb7:	83 f2 1f             	xor    $0x1f,%edx
  801bba:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801bbd:	75 39                	jne    801bf8 <__udivdi3+0x98>
  801bbf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801bc2:	0f 86 a0 00 00 00    	jbe    801c68 <__udivdi3+0x108>
  801bc8:	39 f8                	cmp    %edi,%eax
  801bca:	0f 82 98 00 00 00    	jb     801c68 <__udivdi3+0x108>
  801bd0:	31 ff                	xor    %edi,%edi
  801bd2:	31 c9                	xor    %ecx,%ecx
  801bd4:	89 c8                	mov    %ecx,%eax
  801bd6:	89 fa                	mov    %edi,%edx
  801bd8:	83 c4 10             	add    $0x10,%esp
  801bdb:	5e                   	pop    %esi
  801bdc:	5f                   	pop    %edi
  801bdd:	5d                   	pop    %ebp
  801bde:	c3                   	ret    
  801bdf:	90                   	nop
  801be0:	89 d1                	mov    %edx,%ecx
  801be2:	89 fa                	mov    %edi,%edx
  801be4:	89 c8                	mov    %ecx,%eax
  801be6:	31 ff                	xor    %edi,%edi
  801be8:	f7 f6                	div    %esi
  801bea:	89 c1                	mov    %eax,%ecx
  801bec:	89 fa                	mov    %edi,%edx
  801bee:	89 c8                	mov    %ecx,%eax
  801bf0:	83 c4 10             	add    $0x10,%esp
  801bf3:	5e                   	pop    %esi
  801bf4:	5f                   	pop    %edi
  801bf5:	5d                   	pop    %ebp
  801bf6:	c3                   	ret    
  801bf7:	90                   	nop
  801bf8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801bfc:	89 f2                	mov    %esi,%edx
  801bfe:	d3 e0                	shl    %cl,%eax
  801c00:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801c03:	b8 20 00 00 00       	mov    $0x20,%eax
  801c08:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801c0b:	89 c1                	mov    %eax,%ecx
  801c0d:	d3 ea                	shr    %cl,%edx
  801c0f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801c13:	0b 55 ec             	or     -0x14(%ebp),%edx
  801c16:	d3 e6                	shl    %cl,%esi
  801c18:	89 c1                	mov    %eax,%ecx
  801c1a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801c1d:	89 fe                	mov    %edi,%esi
  801c1f:	d3 ee                	shr    %cl,%esi
  801c21:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801c25:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801c28:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c2b:	d3 e7                	shl    %cl,%edi
  801c2d:	89 c1                	mov    %eax,%ecx
  801c2f:	d3 ea                	shr    %cl,%edx
  801c31:	09 d7                	or     %edx,%edi
  801c33:	89 f2                	mov    %esi,%edx
  801c35:	89 f8                	mov    %edi,%eax
  801c37:	f7 75 ec             	divl   -0x14(%ebp)
  801c3a:	89 d6                	mov    %edx,%esi
  801c3c:	89 c7                	mov    %eax,%edi
  801c3e:	f7 65 e8             	mull   -0x18(%ebp)
  801c41:	39 d6                	cmp    %edx,%esi
  801c43:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801c46:	72 30                	jb     801c78 <__udivdi3+0x118>
  801c48:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c4b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801c4f:	d3 e2                	shl    %cl,%edx
  801c51:	39 c2                	cmp    %eax,%edx
  801c53:	73 05                	jae    801c5a <__udivdi3+0xfa>
  801c55:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801c58:	74 1e                	je     801c78 <__udivdi3+0x118>
  801c5a:	89 f9                	mov    %edi,%ecx
  801c5c:	31 ff                	xor    %edi,%edi
  801c5e:	e9 71 ff ff ff       	jmp    801bd4 <__udivdi3+0x74>
  801c63:	90                   	nop
  801c64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c68:	31 ff                	xor    %edi,%edi
  801c6a:	b9 01 00 00 00       	mov    $0x1,%ecx
  801c6f:	e9 60 ff ff ff       	jmp    801bd4 <__udivdi3+0x74>
  801c74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c78:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801c7b:	31 ff                	xor    %edi,%edi
  801c7d:	89 c8                	mov    %ecx,%eax
  801c7f:	89 fa                	mov    %edi,%edx
  801c81:	83 c4 10             	add    $0x10,%esp
  801c84:	5e                   	pop    %esi
  801c85:	5f                   	pop    %edi
  801c86:	5d                   	pop    %ebp
  801c87:	c3                   	ret    
	...

00801c90 <__umoddi3>:
  801c90:	55                   	push   %ebp
  801c91:	89 e5                	mov    %esp,%ebp
  801c93:	57                   	push   %edi
  801c94:	56                   	push   %esi
  801c95:	83 ec 20             	sub    $0x20,%esp
  801c98:	8b 55 14             	mov    0x14(%ebp),%edx
  801c9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c9e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801ca1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ca4:	85 d2                	test   %edx,%edx
  801ca6:	89 c8                	mov    %ecx,%eax
  801ca8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801cab:	75 13                	jne    801cc0 <__umoddi3+0x30>
  801cad:	39 f7                	cmp    %esi,%edi
  801caf:	76 3f                	jbe    801cf0 <__umoddi3+0x60>
  801cb1:	89 f2                	mov    %esi,%edx
  801cb3:	f7 f7                	div    %edi
  801cb5:	89 d0                	mov    %edx,%eax
  801cb7:	31 d2                	xor    %edx,%edx
  801cb9:	83 c4 20             	add    $0x20,%esp
  801cbc:	5e                   	pop    %esi
  801cbd:	5f                   	pop    %edi
  801cbe:	5d                   	pop    %ebp
  801cbf:	c3                   	ret    
  801cc0:	39 f2                	cmp    %esi,%edx
  801cc2:	77 4c                	ja     801d10 <__umoddi3+0x80>
  801cc4:	0f bd ca             	bsr    %edx,%ecx
  801cc7:	83 f1 1f             	xor    $0x1f,%ecx
  801cca:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801ccd:	75 51                	jne    801d20 <__umoddi3+0x90>
  801ccf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801cd2:	0f 87 e0 00 00 00    	ja     801db8 <__umoddi3+0x128>
  801cd8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cdb:	29 f8                	sub    %edi,%eax
  801cdd:	19 d6                	sbb    %edx,%esi
  801cdf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801ce2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ce5:	89 f2                	mov    %esi,%edx
  801ce7:	83 c4 20             	add    $0x20,%esp
  801cea:	5e                   	pop    %esi
  801ceb:	5f                   	pop    %edi
  801cec:	5d                   	pop    %ebp
  801ced:	c3                   	ret    
  801cee:	66 90                	xchg   %ax,%ax
  801cf0:	85 ff                	test   %edi,%edi
  801cf2:	75 0b                	jne    801cff <__umoddi3+0x6f>
  801cf4:	b8 01 00 00 00       	mov    $0x1,%eax
  801cf9:	31 d2                	xor    %edx,%edx
  801cfb:	f7 f7                	div    %edi
  801cfd:	89 c7                	mov    %eax,%edi
  801cff:	89 f0                	mov    %esi,%eax
  801d01:	31 d2                	xor    %edx,%edx
  801d03:	f7 f7                	div    %edi
  801d05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d08:	f7 f7                	div    %edi
  801d0a:	eb a9                	jmp    801cb5 <__umoddi3+0x25>
  801d0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d10:	89 c8                	mov    %ecx,%eax
  801d12:	89 f2                	mov    %esi,%edx
  801d14:	83 c4 20             	add    $0x20,%esp
  801d17:	5e                   	pop    %esi
  801d18:	5f                   	pop    %edi
  801d19:	5d                   	pop    %ebp
  801d1a:	c3                   	ret    
  801d1b:	90                   	nop
  801d1c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d20:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d24:	d3 e2                	shl    %cl,%edx
  801d26:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801d29:	ba 20 00 00 00       	mov    $0x20,%edx
  801d2e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801d31:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801d34:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801d38:	89 fa                	mov    %edi,%edx
  801d3a:	d3 ea                	shr    %cl,%edx
  801d3c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d40:	0b 55 f4             	or     -0xc(%ebp),%edx
  801d43:	d3 e7                	shl    %cl,%edi
  801d45:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801d49:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801d4c:	89 f2                	mov    %esi,%edx
  801d4e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801d51:	89 c7                	mov    %eax,%edi
  801d53:	d3 ea                	shr    %cl,%edx
  801d55:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d59:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801d5c:	89 c2                	mov    %eax,%edx
  801d5e:	d3 e6                	shl    %cl,%esi
  801d60:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801d64:	d3 ea                	shr    %cl,%edx
  801d66:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d6a:	09 d6                	or     %edx,%esi
  801d6c:	89 f0                	mov    %esi,%eax
  801d6e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801d71:	d3 e7                	shl    %cl,%edi
  801d73:	89 f2                	mov    %esi,%edx
  801d75:	f7 75 f4             	divl   -0xc(%ebp)
  801d78:	89 d6                	mov    %edx,%esi
  801d7a:	f7 65 e8             	mull   -0x18(%ebp)
  801d7d:	39 d6                	cmp    %edx,%esi
  801d7f:	72 2b                	jb     801dac <__umoddi3+0x11c>
  801d81:	39 c7                	cmp    %eax,%edi
  801d83:	72 23                	jb     801da8 <__umoddi3+0x118>
  801d85:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d89:	29 c7                	sub    %eax,%edi
  801d8b:	19 d6                	sbb    %edx,%esi
  801d8d:	89 f0                	mov    %esi,%eax
  801d8f:	89 f2                	mov    %esi,%edx
  801d91:	d3 ef                	shr    %cl,%edi
  801d93:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801d97:	d3 e0                	shl    %cl,%eax
  801d99:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d9d:	09 f8                	or     %edi,%eax
  801d9f:	d3 ea                	shr    %cl,%edx
  801da1:	83 c4 20             	add    $0x20,%esp
  801da4:	5e                   	pop    %esi
  801da5:	5f                   	pop    %edi
  801da6:	5d                   	pop    %ebp
  801da7:	c3                   	ret    
  801da8:	39 d6                	cmp    %edx,%esi
  801daa:	75 d9                	jne    801d85 <__umoddi3+0xf5>
  801dac:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801daf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801db2:	eb d1                	jmp    801d85 <__umoddi3+0xf5>
  801db4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801db8:	39 f2                	cmp    %esi,%edx
  801dba:	0f 82 18 ff ff ff    	jb     801cd8 <__umoddi3+0x48>
  801dc0:	e9 1d ff ff ff       	jmp    801ce2 <__umoddi3+0x52>
