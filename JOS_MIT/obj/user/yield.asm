
obj/user/yield.debug:     file format elf32-i386


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
  80002c:	e8 6f 00 00 00       	call   8000a0 <libmain>
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
  800037:	53                   	push   %ebx
  800038:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003b:	a1 04 40 80 00       	mov    0x804004,%eax
  800040:	8b 40 48             	mov    0x48(%eax),%eax
  800043:	89 44 24 04          	mov    %eax,0x4(%esp)
  800047:	c7 04 24 40 1d 80 00 	movl   $0x801d40,(%esp)
  80004e:	e8 1a 01 00 00       	call   80016d <cprintf>
  800053:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < 5; i++) {
		sys_yield();
  800058:	e8 74 0e 00 00       	call   800ed1 <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005d:	a1 04 40 80 00       	mov    0x804004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800062:	8b 40 48             	mov    0x48(%eax),%eax
  800065:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800069:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006d:	c7 04 24 60 1d 80 00 	movl   $0x801d60,(%esp)
  800074:	e8 f4 00 00 00       	call   80016d <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800079:	83 c3 01             	add    $0x1,%ebx
  80007c:	83 fb 05             	cmp    $0x5,%ebx
  80007f:	75 d7                	jne    800058 <umain+0x24>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  800081:	a1 04 40 80 00       	mov    0x804004,%eax
  800086:	8b 40 48             	mov    0x48(%eax),%eax
  800089:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008d:	c7 04 24 8c 1d 80 00 	movl   $0x801d8c,(%esp)
  800094:	e8 d4 00 00 00       	call   80016d <cprintf>
}
  800099:	83 c4 14             	add    $0x14,%esp
  80009c:	5b                   	pop    %ebx
  80009d:	5d                   	pop    %ebp
  80009e:	c3                   	ret    
	...

008000a0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	83 ec 18             	sub    $0x18,%esp
  8000a6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000a9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000ac:	8b 75 08             	mov    0x8(%ebp),%esi
  8000af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  8000b2:	e8 8d 0e 00 00       	call   800f44 <sys_getenvid>
  8000b7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000bc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000bf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c4:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c9:	85 f6                	test   %esi,%esi
  8000cb:	7e 07                	jle    8000d4 <libmain+0x34>
		binaryname = argv[0];
  8000cd:	8b 03                	mov    (%ebx),%eax
  8000cf:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000d4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d8:	89 34 24             	mov    %esi,(%esp)
  8000db:	e8 54 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000e0:	e8 0b 00 00 00       	call   8000f0 <exit>
}
  8000e5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000e8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000eb:	89 ec                	mov    %ebp,%esp
  8000ed:	5d                   	pop    %ebp
  8000ee:	c3                   	ret    
	...

008000f0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000f6:	e8 1e 14 00 00       	call   801519 <close_all>
	sys_env_destroy(0);
  8000fb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800102:	e8 78 0e 00 00       	call   800f7f <sys_env_destroy>
}
  800107:	c9                   	leave  
  800108:	c3                   	ret    
  800109:	00 00                	add    %al,(%eax)
	...

0080010c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80010c:	55                   	push   %ebp
  80010d:	89 e5                	mov    %esp,%ebp
  80010f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800115:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011c:	00 00 00 
	b.cnt = 0;
  80011f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800126:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800129:	8b 45 0c             	mov    0xc(%ebp),%eax
  80012c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800130:	8b 45 08             	mov    0x8(%ebp),%eax
  800133:	89 44 24 08          	mov    %eax,0x8(%esp)
  800137:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80013d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800141:	c7 04 24 87 01 80 00 	movl   $0x800187,(%esp)
  800148:	e8 d0 01 00 00       	call   80031d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800153:	89 44 24 04          	mov    %eax,0x4(%esp)
  800157:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80015d:	89 04 24             	mov    %eax,(%esp)
  800160:	e8 8e 0e 00 00       	call   800ff3 <sys_cputs>

	return b.cnt;
}
  800165:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80016b:	c9                   	leave  
  80016c:	c3                   	ret    

0080016d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80016d:	55                   	push   %ebp
  80016e:	89 e5                	mov    %esp,%ebp
  800170:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800173:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800176:	89 44 24 04          	mov    %eax,0x4(%esp)
  80017a:	8b 45 08             	mov    0x8(%ebp),%eax
  80017d:	89 04 24             	mov    %eax,(%esp)
  800180:	e8 87 ff ff ff       	call   80010c <vcprintf>
	va_end(ap);

	return cnt;
}
  800185:	c9                   	leave  
  800186:	c3                   	ret    

00800187 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	53                   	push   %ebx
  80018b:	83 ec 14             	sub    $0x14,%esp
  80018e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800191:	8b 03                	mov    (%ebx),%eax
  800193:	8b 55 08             	mov    0x8(%ebp),%edx
  800196:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80019a:	83 c0 01             	add    $0x1,%eax
  80019d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80019f:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a4:	75 19                	jne    8001bf <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001a6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001ad:	00 
  8001ae:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b1:	89 04 24             	mov    %eax,(%esp)
  8001b4:	e8 3a 0e 00 00       	call   800ff3 <sys_cputs>
		b->idx = 0;
  8001b9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001bf:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c3:	83 c4 14             	add    $0x14,%esp
  8001c6:	5b                   	pop    %ebx
  8001c7:	5d                   	pop    %ebp
  8001c8:	c3                   	ret    
  8001c9:	00 00                	add    %al,(%eax)
  8001cb:	00 00                	add    %al,(%eax)
  8001cd:	00 00                	add    %al,(%eax)
	...

008001d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	57                   	push   %edi
  8001d4:	56                   	push   %esi
  8001d5:	53                   	push   %ebx
  8001d6:	83 ec 4c             	sub    $0x4c,%esp
  8001d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001dc:	89 d6                	mov    %edx,%esi
  8001de:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001f0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001fb:	39 d1                	cmp    %edx,%ecx
  8001fd:	72 15                	jb     800214 <printnum+0x44>
  8001ff:	77 07                	ja     800208 <printnum+0x38>
  800201:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800204:	39 d0                	cmp    %edx,%eax
  800206:	76 0c                	jbe    800214 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800208:	83 eb 01             	sub    $0x1,%ebx
  80020b:	85 db                	test   %ebx,%ebx
  80020d:	8d 76 00             	lea    0x0(%esi),%esi
  800210:	7f 61                	jg     800273 <printnum+0xa3>
  800212:	eb 70                	jmp    800284 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800214:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800218:	83 eb 01             	sub    $0x1,%ebx
  80021b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80021f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800223:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800227:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80022b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80022e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800231:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800234:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800238:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80023f:	00 
  800240:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800243:	89 04 24             	mov    %eax,(%esp)
  800246:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800249:	89 54 24 04          	mov    %edx,0x4(%esp)
  80024d:	e8 7e 18 00 00       	call   801ad0 <__udivdi3>
  800252:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800255:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800258:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80025c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800260:	89 04 24             	mov    %eax,(%esp)
  800263:	89 54 24 04          	mov    %edx,0x4(%esp)
  800267:	89 f2                	mov    %esi,%edx
  800269:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80026c:	e8 5f ff ff ff       	call   8001d0 <printnum>
  800271:	eb 11                	jmp    800284 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800273:	89 74 24 04          	mov    %esi,0x4(%esp)
  800277:	89 3c 24             	mov    %edi,(%esp)
  80027a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027d:	83 eb 01             	sub    $0x1,%ebx
  800280:	85 db                	test   %ebx,%ebx
  800282:	7f ef                	jg     800273 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800284:	89 74 24 04          	mov    %esi,0x4(%esp)
  800288:	8b 74 24 04          	mov    0x4(%esp),%esi
  80028c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80028f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800293:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80029a:	00 
  80029b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80029e:	89 14 24             	mov    %edx,(%esp)
  8002a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002a4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8002a8:	e8 53 19 00 00       	call   801c00 <__umoddi3>
  8002ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002b1:	0f be 80 b5 1d 80 00 	movsbl 0x801db5(%eax),%eax
  8002b8:	89 04 24             	mov    %eax,(%esp)
  8002bb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002be:	83 c4 4c             	add    $0x4c,%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c9:	83 fa 01             	cmp    $0x1,%edx
  8002cc:	7e 0e                	jle    8002dc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ce:	8b 10                	mov    (%eax),%edx
  8002d0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d3:	89 08                	mov    %ecx,(%eax)
  8002d5:	8b 02                	mov    (%edx),%eax
  8002d7:	8b 52 04             	mov    0x4(%edx),%edx
  8002da:	eb 22                	jmp    8002fe <getuint+0x38>
	else if (lflag)
  8002dc:	85 d2                	test   %edx,%edx
  8002de:	74 10                	je     8002f0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 02                	mov    (%edx),%eax
  8002e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ee:	eb 0e                	jmp    8002fe <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f5:	89 08                	mov    %ecx,(%eax)
  8002f7:	8b 02                	mov    (%edx),%eax
  8002f9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    

00800300 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800306:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80030a:	8b 10                	mov    (%eax),%edx
  80030c:	3b 50 04             	cmp    0x4(%eax),%edx
  80030f:	73 0a                	jae    80031b <sprintputch+0x1b>
		*b->buf++ = ch;
  800311:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800314:	88 0a                	mov    %cl,(%edx)
  800316:	83 c2 01             	add    $0x1,%edx
  800319:	89 10                	mov    %edx,(%eax)
}
  80031b:	5d                   	pop    %ebp
  80031c:	c3                   	ret    

0080031d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	57                   	push   %edi
  800321:	56                   	push   %esi
  800322:	53                   	push   %ebx
  800323:	83 ec 5c             	sub    $0x5c,%esp
  800326:	8b 7d 08             	mov    0x8(%ebp),%edi
  800329:	8b 75 0c             	mov    0xc(%ebp),%esi
  80032c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80032f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800336:	eb 11                	jmp    800349 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800338:	85 c0                	test   %eax,%eax
  80033a:	0f 84 68 04 00 00    	je     8007a8 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  800340:	89 74 24 04          	mov    %esi,0x4(%esp)
  800344:	89 04 24             	mov    %eax,(%esp)
  800347:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800349:	0f b6 03             	movzbl (%ebx),%eax
  80034c:	83 c3 01             	add    $0x1,%ebx
  80034f:	83 f8 25             	cmp    $0x25,%eax
  800352:	75 e4                	jne    800338 <vprintfmt+0x1b>
  800354:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80035b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800362:	b9 00 00 00 00       	mov    $0x0,%ecx
  800367:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  80036b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800372:	eb 06                	jmp    80037a <vprintfmt+0x5d>
  800374:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  800378:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	0f b6 13             	movzbl (%ebx),%edx
  80037d:	0f b6 c2             	movzbl %dl,%eax
  800380:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800383:	8d 43 01             	lea    0x1(%ebx),%eax
  800386:	83 ea 23             	sub    $0x23,%edx
  800389:	80 fa 55             	cmp    $0x55,%dl
  80038c:	0f 87 f9 03 00 00    	ja     80078b <vprintfmt+0x46e>
  800392:	0f b6 d2             	movzbl %dl,%edx
  800395:	ff 24 95 a0 1f 80 00 	jmp    *0x801fa0(,%edx,4)
  80039c:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  8003a0:	eb d6                	jmp    800378 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8003a5:	83 ea 30             	sub    $0x30,%edx
  8003a8:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  8003ab:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003ae:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003b1:	83 fb 09             	cmp    $0x9,%ebx
  8003b4:	77 54                	ja     80040a <vprintfmt+0xed>
  8003b6:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8003b9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003bc:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8003bf:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003c2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8003c6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003c9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003cc:	83 fb 09             	cmp    $0x9,%ebx
  8003cf:	76 eb                	jbe    8003bc <vprintfmt+0x9f>
  8003d1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8003d4:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8003d7:	eb 31                	jmp    80040a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d9:	8b 55 14             	mov    0x14(%ebp),%edx
  8003dc:	8d 5a 04             	lea    0x4(%edx),%ebx
  8003df:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8003e2:	8b 12                	mov    (%edx),%edx
  8003e4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8003e7:	eb 21                	jmp    80040a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  8003e9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f2:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  8003f6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003f9:	e9 7a ff ff ff       	jmp    800378 <vprintfmt+0x5b>
  8003fe:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800405:	e9 6e ff ff ff       	jmp    800378 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80040a:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80040e:	0f 89 64 ff ff ff    	jns    800378 <vprintfmt+0x5b>
  800414:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800417:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  80041a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80041d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800420:	e9 53 ff ff ff       	jmp    800378 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800425:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800428:	e9 4b ff ff ff       	jmp    800378 <vprintfmt+0x5b>
  80042d:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800430:	8b 45 14             	mov    0x14(%ebp),%eax
  800433:	8d 50 04             	lea    0x4(%eax),%edx
  800436:	89 55 14             	mov    %edx,0x14(%ebp)
  800439:	89 74 24 04          	mov    %esi,0x4(%esp)
  80043d:	8b 00                	mov    (%eax),%eax
  80043f:	89 04 24             	mov    %eax,(%esp)
  800442:	ff d7                	call   *%edi
  800444:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800447:	e9 fd fe ff ff       	jmp    800349 <vprintfmt+0x2c>
  80044c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80044f:	8b 45 14             	mov    0x14(%ebp),%eax
  800452:	8d 50 04             	lea    0x4(%eax),%edx
  800455:	89 55 14             	mov    %edx,0x14(%ebp)
  800458:	8b 00                	mov    (%eax),%eax
  80045a:	89 c2                	mov    %eax,%edx
  80045c:	c1 fa 1f             	sar    $0x1f,%edx
  80045f:	31 d0                	xor    %edx,%eax
  800461:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800463:	83 f8 0f             	cmp    $0xf,%eax
  800466:	7f 0b                	jg     800473 <vprintfmt+0x156>
  800468:	8b 14 85 00 21 80 00 	mov    0x802100(,%eax,4),%edx
  80046f:	85 d2                	test   %edx,%edx
  800471:	75 20                	jne    800493 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800473:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800477:	c7 44 24 08 c6 1d 80 	movl   $0x801dc6,0x8(%esp)
  80047e:	00 
  80047f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800483:	89 3c 24             	mov    %edi,(%esp)
  800486:	e8 a5 03 00 00       	call   800830 <printfmt>
  80048b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80048e:	e9 b6 fe ff ff       	jmp    800349 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800493:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800497:	c7 44 24 08 17 22 80 	movl   $0x802217,0x8(%esp)
  80049e:	00 
  80049f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004a3:	89 3c 24             	mov    %edi,(%esp)
  8004a6:	e8 85 03 00 00       	call   800830 <printfmt>
  8004ab:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8004ae:	e9 96 fe ff ff       	jmp    800349 <vprintfmt+0x2c>
  8004b3:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8004b6:	89 c3                	mov    %eax,%ebx
  8004b8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004bb:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8004be:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c4:	8d 50 04             	lea    0x4(%eax),%edx
  8004c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ca:	8b 00                	mov    (%eax),%eax
  8004cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8004cf:	85 c0                	test   %eax,%eax
  8004d1:	b8 cf 1d 80 00       	mov    $0x801dcf,%eax
  8004d6:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  8004da:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8004dd:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8004e1:	7e 06                	jle    8004e9 <vprintfmt+0x1cc>
  8004e3:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8004e7:	75 13                	jne    8004fc <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004ec:	0f be 02             	movsbl (%edx),%eax
  8004ef:	85 c0                	test   %eax,%eax
  8004f1:	0f 85 a2 00 00 00    	jne    800599 <vprintfmt+0x27c>
  8004f7:	e9 8f 00 00 00       	jmp    80058b <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800500:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800503:	89 0c 24             	mov    %ecx,(%esp)
  800506:	e8 70 03 00 00       	call   80087b <strnlen>
  80050b:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80050e:	29 c2                	sub    %eax,%edx
  800510:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  800513:	85 d2                	test   %edx,%edx
  800515:	7e d2                	jle    8004e9 <vprintfmt+0x1cc>
					putch(padc, putdat);
  800517:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80051b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80051e:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  800521:	89 d3                	mov    %edx,%ebx
  800523:	89 74 24 04          	mov    %esi,0x4(%esp)
  800527:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80052a:	89 04 24             	mov    %eax,(%esp)
  80052d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052f:	83 eb 01             	sub    $0x1,%ebx
  800532:	85 db                	test   %ebx,%ebx
  800534:	7f ed                	jg     800523 <vprintfmt+0x206>
  800536:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  800539:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800540:	eb a7                	jmp    8004e9 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800542:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800546:	74 1b                	je     800563 <vprintfmt+0x246>
  800548:	8d 50 e0             	lea    -0x20(%eax),%edx
  80054b:	83 fa 5e             	cmp    $0x5e,%edx
  80054e:	76 13                	jbe    800563 <vprintfmt+0x246>
					putch('?', putdat);
  800550:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800553:	89 54 24 04          	mov    %edx,0x4(%esp)
  800557:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80055e:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800561:	eb 0d                	jmp    800570 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800563:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800566:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80056a:	89 04 24             	mov    %eax,(%esp)
  80056d:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800570:	83 ef 01             	sub    $0x1,%edi
  800573:	0f be 03             	movsbl (%ebx),%eax
  800576:	85 c0                	test   %eax,%eax
  800578:	74 05                	je     80057f <vprintfmt+0x262>
  80057a:	83 c3 01             	add    $0x1,%ebx
  80057d:	eb 31                	jmp    8005b0 <vprintfmt+0x293>
  80057f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800582:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800585:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800588:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80058f:	7f 36                	jg     8005c7 <vprintfmt+0x2aa>
  800591:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800594:	e9 b0 fd ff ff       	jmp    800349 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800599:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80059c:	83 c2 01             	add    $0x1,%edx
  80059f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  8005a2:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8005a5:	89 75 e0             	mov    %esi,-0x20(%ebp)
  8005a8:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005ab:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8005ae:	89 d3                	mov    %edx,%ebx
  8005b0:	85 f6                	test   %esi,%esi
  8005b2:	78 8e                	js     800542 <vprintfmt+0x225>
  8005b4:	83 ee 01             	sub    $0x1,%esi
  8005b7:	79 89                	jns    800542 <vprintfmt+0x225>
  8005b9:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8005bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005bf:	8b 75 e0             	mov    -0x20(%ebp),%esi
  8005c2:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8005c5:	eb c4                	jmp    80058b <vprintfmt+0x26e>
  8005c7:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  8005ca:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d1:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005d8:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005da:	83 eb 01             	sub    $0x1,%ebx
  8005dd:	85 db                	test   %ebx,%ebx
  8005df:	7f ec                	jg     8005cd <vprintfmt+0x2b0>
  8005e1:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8005e4:	e9 60 fd ff ff       	jmp    800349 <vprintfmt+0x2c>
  8005e9:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ec:	83 f9 01             	cmp    $0x1,%ecx
  8005ef:	7e 16                	jle    800607 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  8005f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f4:	8d 50 08             	lea    0x8(%eax),%edx
  8005f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005fa:	8b 10                	mov    (%eax),%edx
  8005fc:	8b 48 04             	mov    0x4(%eax),%ecx
  8005ff:	89 55 d8             	mov    %edx,-0x28(%ebp)
  800602:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800605:	eb 32                	jmp    800639 <vprintfmt+0x31c>
	else if (lflag)
  800607:	85 c9                	test   %ecx,%ecx
  800609:	74 18                	je     800623 <vprintfmt+0x306>
		return va_arg(*ap, long);
  80060b:	8b 45 14             	mov    0x14(%ebp),%eax
  80060e:	8d 50 04             	lea    0x4(%eax),%edx
  800611:	89 55 14             	mov    %edx,0x14(%ebp)
  800614:	8b 00                	mov    (%eax),%eax
  800616:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800619:	89 c1                	mov    %eax,%ecx
  80061b:	c1 f9 1f             	sar    $0x1f,%ecx
  80061e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800621:	eb 16                	jmp    800639 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8d 50 04             	lea    0x4(%eax),%edx
  800629:	89 55 14             	mov    %edx,0x14(%ebp)
  80062c:	8b 00                	mov    (%eax),%eax
  80062e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800631:	89 c2                	mov    %eax,%edx
  800633:	c1 fa 1f             	sar    $0x1f,%edx
  800636:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800639:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80063c:	8b 55 dc             	mov    -0x24(%ebp),%edx
  80063f:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  800644:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800648:	0f 89 8a 00 00 00    	jns    8006d8 <vprintfmt+0x3bb>
				putch('-', putdat);
  80064e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800652:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800659:	ff d7                	call   *%edi
				num = -(long long) num;
  80065b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80065e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800661:	f7 d8                	neg    %eax
  800663:	83 d2 00             	adc    $0x0,%edx
  800666:	f7 da                	neg    %edx
  800668:	eb 6e                	jmp    8006d8 <vprintfmt+0x3bb>
  80066a:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80066d:	89 ca                	mov    %ecx,%edx
  80066f:	8d 45 14             	lea    0x14(%ebp),%eax
  800672:	e8 4f fc ff ff       	call   8002c6 <getuint>
  800677:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  80067c:	eb 5a                	jmp    8006d8 <vprintfmt+0x3bb>
  80067e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800681:	89 ca                	mov    %ecx,%edx
  800683:	8d 45 14             	lea    0x14(%ebp),%eax
  800686:	e8 3b fc ff ff       	call   8002c6 <getuint>
  80068b:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  800690:	eb 46                	jmp    8006d8 <vprintfmt+0x3bb>
  800692:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  800695:	89 74 24 04          	mov    %esi,0x4(%esp)
  800699:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006a0:	ff d7                	call   *%edi
			putch('x', putdat);
  8006a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006a6:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006ad:	ff d7                	call   *%edi
			num = (unsigned long long)
  8006af:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b2:	8d 50 04             	lea    0x4(%eax),%edx
  8006b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b8:	8b 00                	mov    (%eax),%eax
  8006ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8006bf:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006c4:	eb 12                	jmp    8006d8 <vprintfmt+0x3bb>
  8006c6:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006c9:	89 ca                	mov    %ecx,%edx
  8006cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ce:	e8 f3 fb ff ff       	call   8002c6 <getuint>
  8006d3:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006d8:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8006dc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8006e0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8006e3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8006e7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8006eb:	89 04 24             	mov    %eax,(%esp)
  8006ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006f2:	89 f2                	mov    %esi,%edx
  8006f4:	89 f8                	mov    %edi,%eax
  8006f6:	e8 d5 fa ff ff       	call   8001d0 <printnum>
  8006fb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8006fe:	e9 46 fc ff ff       	jmp    800349 <vprintfmt+0x2c>
  800703:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  800706:	8b 45 14             	mov    0x14(%ebp),%eax
  800709:	8d 50 04             	lea    0x4(%eax),%edx
  80070c:	89 55 14             	mov    %edx,0x14(%ebp)
  80070f:	8b 00                	mov    (%eax),%eax
  800711:	85 c0                	test   %eax,%eax
  800713:	75 24                	jne    800739 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  800715:	c7 44 24 0c e8 1e 80 	movl   $0x801ee8,0xc(%esp)
  80071c:	00 
  80071d:	c7 44 24 08 17 22 80 	movl   $0x802217,0x8(%esp)
  800724:	00 
  800725:	89 74 24 04          	mov    %esi,0x4(%esp)
  800729:	89 3c 24             	mov    %edi,(%esp)
  80072c:	e8 ff 00 00 00       	call   800830 <printfmt>
  800731:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800734:	e9 10 fc ff ff       	jmp    800349 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  800739:	83 3e 7f             	cmpl   $0x7f,(%esi)
  80073c:	7e 29                	jle    800767 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  80073e:	0f b6 16             	movzbl (%esi),%edx
  800741:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  800743:	c7 44 24 0c 20 1f 80 	movl   $0x801f20,0xc(%esp)
  80074a:	00 
  80074b:	c7 44 24 08 17 22 80 	movl   $0x802217,0x8(%esp)
  800752:	00 
  800753:	89 74 24 04          	mov    %esi,0x4(%esp)
  800757:	89 3c 24             	mov    %edi,(%esp)
  80075a:	e8 d1 00 00 00       	call   800830 <printfmt>
  80075f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800762:	e9 e2 fb ff ff       	jmp    800349 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  800767:	0f b6 16             	movzbl (%esi),%edx
  80076a:	88 10                	mov    %dl,(%eax)
  80076c:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  80076f:	e9 d5 fb ff ff       	jmp    800349 <vprintfmt+0x2c>
  800774:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800777:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80077a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80077e:	89 14 24             	mov    %edx,(%esp)
  800781:	ff d7                	call   *%edi
  800783:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800786:	e9 be fb ff ff       	jmp    800349 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80078b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80078f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800796:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800798:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80079b:	80 38 25             	cmpb   $0x25,(%eax)
  80079e:	0f 84 a5 fb ff ff    	je     800349 <vprintfmt+0x2c>
  8007a4:	89 c3                	mov    %eax,%ebx
  8007a6:	eb f0                	jmp    800798 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  8007a8:	83 c4 5c             	add    $0x5c,%esp
  8007ab:	5b                   	pop    %ebx
  8007ac:	5e                   	pop    %esi
  8007ad:	5f                   	pop    %edi
  8007ae:	5d                   	pop    %ebp
  8007af:	c3                   	ret    

008007b0 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	83 ec 28             	sub    $0x28,%esp
  8007b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8007bc:	85 c0                	test   %eax,%eax
  8007be:	74 04                	je     8007c4 <vsnprintf+0x14>
  8007c0:	85 d2                	test   %edx,%edx
  8007c2:	7f 07                	jg     8007cb <vsnprintf+0x1b>
  8007c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007c9:	eb 3b                	jmp    800806 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007cb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007ce:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8007d2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007d5:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ea:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f1:	c7 04 24 00 03 80 00 	movl   $0x800300,(%esp)
  8007f8:	e8 20 fb ff ff       	call   80031d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007fd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800800:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800803:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800806:	c9                   	leave  
  800807:	c3                   	ret    

00800808 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800808:	55                   	push   %ebp
  800809:	89 e5                	mov    %esp,%ebp
  80080b:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80080e:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800811:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800815:	8b 45 10             	mov    0x10(%ebp),%eax
  800818:	89 44 24 08          	mov    %eax,0x8(%esp)
  80081c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80081f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800823:	8b 45 08             	mov    0x8(%ebp),%eax
  800826:	89 04 24             	mov    %eax,(%esp)
  800829:	e8 82 ff ff ff       	call   8007b0 <vsnprintf>
	va_end(ap);

	return rc;
}
  80082e:	c9                   	leave  
  80082f:	c3                   	ret    

00800830 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800836:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800839:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80083d:	8b 45 10             	mov    0x10(%ebp),%eax
  800840:	89 44 24 08          	mov    %eax,0x8(%esp)
  800844:	8b 45 0c             	mov    0xc(%ebp),%eax
  800847:	89 44 24 04          	mov    %eax,0x4(%esp)
  80084b:	8b 45 08             	mov    0x8(%ebp),%eax
  80084e:	89 04 24             	mov    %eax,(%esp)
  800851:	e8 c7 fa ff ff       	call   80031d <vprintfmt>
	va_end(ap);
}
  800856:	c9                   	leave  
  800857:	c3                   	ret    
	...

00800860 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800866:	b8 00 00 00 00       	mov    $0x0,%eax
  80086b:	80 3a 00             	cmpb   $0x0,(%edx)
  80086e:	74 09                	je     800879 <strlen+0x19>
		n++;
  800870:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800873:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800877:	75 f7                	jne    800870 <strlen+0x10>
		n++;
	return n;
}
  800879:	5d                   	pop    %ebp
  80087a:	c3                   	ret    

0080087b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80087b:	55                   	push   %ebp
  80087c:	89 e5                	mov    %esp,%ebp
  80087e:	53                   	push   %ebx
  80087f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800882:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800885:	85 c9                	test   %ecx,%ecx
  800887:	74 19                	je     8008a2 <strnlen+0x27>
  800889:	80 3b 00             	cmpb   $0x0,(%ebx)
  80088c:	74 14                	je     8008a2 <strnlen+0x27>
  80088e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800893:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800896:	39 c8                	cmp    %ecx,%eax
  800898:	74 0d                	je     8008a7 <strnlen+0x2c>
  80089a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80089e:	75 f3                	jne    800893 <strnlen+0x18>
  8008a0:	eb 05                	jmp    8008a7 <strnlen+0x2c>
  8008a2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008a7:	5b                   	pop    %ebx
  8008a8:	5d                   	pop    %ebp
  8008a9:	c3                   	ret    

008008aa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008aa:	55                   	push   %ebp
  8008ab:	89 e5                	mov    %esp,%ebp
  8008ad:	53                   	push   %ebx
  8008ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008b4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008b9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008bd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008c0:	83 c2 01             	add    $0x1,%edx
  8008c3:	84 c9                	test   %cl,%cl
  8008c5:	75 f2                	jne    8008b9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008c7:	5b                   	pop    %ebx
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	53                   	push   %ebx
  8008ce:	83 ec 08             	sub    $0x8,%esp
  8008d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008d4:	89 1c 24             	mov    %ebx,(%esp)
  8008d7:	e8 84 ff ff ff       	call   800860 <strlen>
	strcpy(dst + len, src);
  8008dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008df:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008e3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8008e6:	89 04 24             	mov    %eax,(%esp)
  8008e9:	e8 bc ff ff ff       	call   8008aa <strcpy>
	return dst;
}
  8008ee:	89 d8                	mov    %ebx,%eax
  8008f0:	83 c4 08             	add    $0x8,%esp
  8008f3:	5b                   	pop    %ebx
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	56                   	push   %esi
  8008fa:	53                   	push   %ebx
  8008fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800901:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800904:	85 f6                	test   %esi,%esi
  800906:	74 18                	je     800920 <strncpy+0x2a>
  800908:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80090d:	0f b6 1a             	movzbl (%edx),%ebx
  800910:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800913:	80 3a 01             	cmpb   $0x1,(%edx)
  800916:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800919:	83 c1 01             	add    $0x1,%ecx
  80091c:	39 ce                	cmp    %ecx,%esi
  80091e:	77 ed                	ja     80090d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800920:	5b                   	pop    %ebx
  800921:	5e                   	pop    %esi
  800922:	5d                   	pop    %ebp
  800923:	c3                   	ret    

00800924 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800924:	55                   	push   %ebp
  800925:	89 e5                	mov    %esp,%ebp
  800927:	56                   	push   %esi
  800928:	53                   	push   %ebx
  800929:	8b 75 08             	mov    0x8(%ebp),%esi
  80092c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80092f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800932:	89 f0                	mov    %esi,%eax
  800934:	85 c9                	test   %ecx,%ecx
  800936:	74 27                	je     80095f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800938:	83 e9 01             	sub    $0x1,%ecx
  80093b:	74 1d                	je     80095a <strlcpy+0x36>
  80093d:	0f b6 1a             	movzbl (%edx),%ebx
  800940:	84 db                	test   %bl,%bl
  800942:	74 16                	je     80095a <strlcpy+0x36>
			*dst++ = *src++;
  800944:	88 18                	mov    %bl,(%eax)
  800946:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800949:	83 e9 01             	sub    $0x1,%ecx
  80094c:	74 0e                	je     80095c <strlcpy+0x38>
			*dst++ = *src++;
  80094e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800951:	0f b6 1a             	movzbl (%edx),%ebx
  800954:	84 db                	test   %bl,%bl
  800956:	75 ec                	jne    800944 <strlcpy+0x20>
  800958:	eb 02                	jmp    80095c <strlcpy+0x38>
  80095a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80095c:	c6 00 00             	movb   $0x0,(%eax)
  80095f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800961:	5b                   	pop    %ebx
  800962:	5e                   	pop    %esi
  800963:	5d                   	pop    %ebp
  800964:	c3                   	ret    

00800965 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800965:	55                   	push   %ebp
  800966:	89 e5                	mov    %esp,%ebp
  800968:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80096b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80096e:	0f b6 01             	movzbl (%ecx),%eax
  800971:	84 c0                	test   %al,%al
  800973:	74 15                	je     80098a <strcmp+0x25>
  800975:	3a 02                	cmp    (%edx),%al
  800977:	75 11                	jne    80098a <strcmp+0x25>
		p++, q++;
  800979:	83 c1 01             	add    $0x1,%ecx
  80097c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80097f:	0f b6 01             	movzbl (%ecx),%eax
  800982:	84 c0                	test   %al,%al
  800984:	74 04                	je     80098a <strcmp+0x25>
  800986:	3a 02                	cmp    (%edx),%al
  800988:	74 ef                	je     800979 <strcmp+0x14>
  80098a:	0f b6 c0             	movzbl %al,%eax
  80098d:	0f b6 12             	movzbl (%edx),%edx
  800990:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800992:	5d                   	pop    %ebp
  800993:	c3                   	ret    

00800994 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800994:	55                   	push   %ebp
  800995:	89 e5                	mov    %esp,%ebp
  800997:	53                   	push   %ebx
  800998:	8b 55 08             	mov    0x8(%ebp),%edx
  80099b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80099e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8009a1:	85 c0                	test   %eax,%eax
  8009a3:	74 23                	je     8009c8 <strncmp+0x34>
  8009a5:	0f b6 1a             	movzbl (%edx),%ebx
  8009a8:	84 db                	test   %bl,%bl
  8009aa:	74 25                	je     8009d1 <strncmp+0x3d>
  8009ac:	3a 19                	cmp    (%ecx),%bl
  8009ae:	75 21                	jne    8009d1 <strncmp+0x3d>
  8009b0:	83 e8 01             	sub    $0x1,%eax
  8009b3:	74 13                	je     8009c8 <strncmp+0x34>
		n--, p++, q++;
  8009b5:	83 c2 01             	add    $0x1,%edx
  8009b8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009bb:	0f b6 1a             	movzbl (%edx),%ebx
  8009be:	84 db                	test   %bl,%bl
  8009c0:	74 0f                	je     8009d1 <strncmp+0x3d>
  8009c2:	3a 19                	cmp    (%ecx),%bl
  8009c4:	74 ea                	je     8009b0 <strncmp+0x1c>
  8009c6:	eb 09                	jmp    8009d1 <strncmp+0x3d>
  8009c8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009cd:	5b                   	pop    %ebx
  8009ce:	5d                   	pop    %ebp
  8009cf:	90                   	nop
  8009d0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d1:	0f b6 02             	movzbl (%edx),%eax
  8009d4:	0f b6 11             	movzbl (%ecx),%edx
  8009d7:	29 d0                	sub    %edx,%eax
  8009d9:	eb f2                	jmp    8009cd <strncmp+0x39>

008009db <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e5:	0f b6 10             	movzbl (%eax),%edx
  8009e8:	84 d2                	test   %dl,%dl
  8009ea:	74 18                	je     800a04 <strchr+0x29>
		if (*s == c)
  8009ec:	38 ca                	cmp    %cl,%dl
  8009ee:	75 0a                	jne    8009fa <strchr+0x1f>
  8009f0:	eb 17                	jmp    800a09 <strchr+0x2e>
  8009f2:	38 ca                	cmp    %cl,%dl
  8009f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009f8:	74 0f                	je     800a09 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009fa:	83 c0 01             	add    $0x1,%eax
  8009fd:	0f b6 10             	movzbl (%eax),%edx
  800a00:	84 d2                	test   %dl,%dl
  800a02:	75 ee                	jne    8009f2 <strchr+0x17>
  800a04:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a09:	5d                   	pop    %ebp
  800a0a:	c3                   	ret    

00800a0b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a0b:	55                   	push   %ebp
  800a0c:	89 e5                	mov    %esp,%ebp
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a15:	0f b6 10             	movzbl (%eax),%edx
  800a18:	84 d2                	test   %dl,%dl
  800a1a:	74 18                	je     800a34 <strfind+0x29>
		if (*s == c)
  800a1c:	38 ca                	cmp    %cl,%dl
  800a1e:	75 0a                	jne    800a2a <strfind+0x1f>
  800a20:	eb 12                	jmp    800a34 <strfind+0x29>
  800a22:	38 ca                	cmp    %cl,%dl
  800a24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a28:	74 0a                	je     800a34 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a2a:	83 c0 01             	add    $0x1,%eax
  800a2d:	0f b6 10             	movzbl (%eax),%edx
  800a30:	84 d2                	test   %dl,%dl
  800a32:	75 ee                	jne    800a22 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a34:	5d                   	pop    %ebp
  800a35:	c3                   	ret    

00800a36 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a36:	55                   	push   %ebp
  800a37:	89 e5                	mov    %esp,%ebp
  800a39:	83 ec 0c             	sub    $0xc,%esp
  800a3c:	89 1c 24             	mov    %ebx,(%esp)
  800a3f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a43:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a47:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a4d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a50:	85 c9                	test   %ecx,%ecx
  800a52:	74 30                	je     800a84 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a54:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a5a:	75 25                	jne    800a81 <memset+0x4b>
  800a5c:	f6 c1 03             	test   $0x3,%cl
  800a5f:	75 20                	jne    800a81 <memset+0x4b>
		c &= 0xFF;
  800a61:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a64:	89 d3                	mov    %edx,%ebx
  800a66:	c1 e3 08             	shl    $0x8,%ebx
  800a69:	89 d6                	mov    %edx,%esi
  800a6b:	c1 e6 18             	shl    $0x18,%esi
  800a6e:	89 d0                	mov    %edx,%eax
  800a70:	c1 e0 10             	shl    $0x10,%eax
  800a73:	09 f0                	or     %esi,%eax
  800a75:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800a77:	09 d8                	or     %ebx,%eax
  800a79:	c1 e9 02             	shr    $0x2,%ecx
  800a7c:	fc                   	cld    
  800a7d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a7f:	eb 03                	jmp    800a84 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a81:	fc                   	cld    
  800a82:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a84:	89 f8                	mov    %edi,%eax
  800a86:	8b 1c 24             	mov    (%esp),%ebx
  800a89:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a8d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a91:	89 ec                	mov    %ebp,%esp
  800a93:	5d                   	pop    %ebp
  800a94:	c3                   	ret    

00800a95 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a95:	55                   	push   %ebp
  800a96:	89 e5                	mov    %esp,%ebp
  800a98:	83 ec 08             	sub    $0x8,%esp
  800a9b:	89 34 24             	mov    %esi,(%esp)
  800a9e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800aa2:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800aa8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800aab:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800aad:	39 c6                	cmp    %eax,%esi
  800aaf:	73 35                	jae    800ae6 <memmove+0x51>
  800ab1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ab4:	39 d0                	cmp    %edx,%eax
  800ab6:	73 2e                	jae    800ae6 <memmove+0x51>
		s += n;
		d += n;
  800ab8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aba:	f6 c2 03             	test   $0x3,%dl
  800abd:	75 1b                	jne    800ada <memmove+0x45>
  800abf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ac5:	75 13                	jne    800ada <memmove+0x45>
  800ac7:	f6 c1 03             	test   $0x3,%cl
  800aca:	75 0e                	jne    800ada <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800acc:	83 ef 04             	sub    $0x4,%edi
  800acf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ad2:	c1 e9 02             	shr    $0x2,%ecx
  800ad5:	fd                   	std    
  800ad6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad8:	eb 09                	jmp    800ae3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ada:	83 ef 01             	sub    $0x1,%edi
  800add:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ae0:	fd                   	std    
  800ae1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ae3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ae4:	eb 20                	jmp    800b06 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aec:	75 15                	jne    800b03 <memmove+0x6e>
  800aee:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800af4:	75 0d                	jne    800b03 <memmove+0x6e>
  800af6:	f6 c1 03             	test   $0x3,%cl
  800af9:	75 08                	jne    800b03 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800afb:	c1 e9 02             	shr    $0x2,%ecx
  800afe:	fc                   	cld    
  800aff:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b01:	eb 03                	jmp    800b06 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b03:	fc                   	cld    
  800b04:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b06:	8b 34 24             	mov    (%esp),%esi
  800b09:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b0d:	89 ec                	mov    %ebp,%esp
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b17:	8b 45 10             	mov    0x10(%ebp),%eax
  800b1a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b21:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b25:	8b 45 08             	mov    0x8(%ebp),%eax
  800b28:	89 04 24             	mov    %eax,(%esp)
  800b2b:	e8 65 ff ff ff       	call   800a95 <memmove>
}
  800b30:	c9                   	leave  
  800b31:	c3                   	ret    

00800b32 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	57                   	push   %edi
  800b36:	56                   	push   %esi
  800b37:	53                   	push   %ebx
  800b38:	8b 75 08             	mov    0x8(%ebp),%esi
  800b3b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b41:	85 c9                	test   %ecx,%ecx
  800b43:	74 36                	je     800b7b <memcmp+0x49>
		if (*s1 != *s2)
  800b45:	0f b6 06             	movzbl (%esi),%eax
  800b48:	0f b6 1f             	movzbl (%edi),%ebx
  800b4b:	38 d8                	cmp    %bl,%al
  800b4d:	74 20                	je     800b6f <memcmp+0x3d>
  800b4f:	eb 14                	jmp    800b65 <memcmp+0x33>
  800b51:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800b56:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800b5b:	83 c2 01             	add    $0x1,%edx
  800b5e:	83 e9 01             	sub    $0x1,%ecx
  800b61:	38 d8                	cmp    %bl,%al
  800b63:	74 12                	je     800b77 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800b65:	0f b6 c0             	movzbl %al,%eax
  800b68:	0f b6 db             	movzbl %bl,%ebx
  800b6b:	29 d8                	sub    %ebx,%eax
  800b6d:	eb 11                	jmp    800b80 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b6f:	83 e9 01             	sub    $0x1,%ecx
  800b72:	ba 00 00 00 00       	mov    $0x0,%edx
  800b77:	85 c9                	test   %ecx,%ecx
  800b79:	75 d6                	jne    800b51 <memcmp+0x1f>
  800b7b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b80:	5b                   	pop    %ebx
  800b81:	5e                   	pop    %esi
  800b82:	5f                   	pop    %edi
  800b83:	5d                   	pop    %ebp
  800b84:	c3                   	ret    

00800b85 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b85:	55                   	push   %ebp
  800b86:	89 e5                	mov    %esp,%ebp
  800b88:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b8b:	89 c2                	mov    %eax,%edx
  800b8d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b90:	39 d0                	cmp    %edx,%eax
  800b92:	73 15                	jae    800ba9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b94:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b98:	38 08                	cmp    %cl,(%eax)
  800b9a:	75 06                	jne    800ba2 <memfind+0x1d>
  800b9c:	eb 0b                	jmp    800ba9 <memfind+0x24>
  800b9e:	38 08                	cmp    %cl,(%eax)
  800ba0:	74 07                	je     800ba9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ba2:	83 c0 01             	add    $0x1,%eax
  800ba5:	39 c2                	cmp    %eax,%edx
  800ba7:	77 f5                	ja     800b9e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ba9:	5d                   	pop    %ebp
  800baa:	c3                   	ret    

00800bab <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bab:	55                   	push   %ebp
  800bac:	89 e5                	mov    %esp,%ebp
  800bae:	57                   	push   %edi
  800baf:	56                   	push   %esi
  800bb0:	53                   	push   %ebx
  800bb1:	83 ec 04             	sub    $0x4,%esp
  800bb4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bba:	0f b6 02             	movzbl (%edx),%eax
  800bbd:	3c 20                	cmp    $0x20,%al
  800bbf:	74 04                	je     800bc5 <strtol+0x1a>
  800bc1:	3c 09                	cmp    $0x9,%al
  800bc3:	75 0e                	jne    800bd3 <strtol+0x28>
		s++;
  800bc5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bc8:	0f b6 02             	movzbl (%edx),%eax
  800bcb:	3c 20                	cmp    $0x20,%al
  800bcd:	74 f6                	je     800bc5 <strtol+0x1a>
  800bcf:	3c 09                	cmp    $0x9,%al
  800bd1:	74 f2                	je     800bc5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800bd3:	3c 2b                	cmp    $0x2b,%al
  800bd5:	75 0c                	jne    800be3 <strtol+0x38>
		s++;
  800bd7:	83 c2 01             	add    $0x1,%edx
  800bda:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800be1:	eb 15                	jmp    800bf8 <strtol+0x4d>
	else if (*s == '-')
  800be3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bea:	3c 2d                	cmp    $0x2d,%al
  800bec:	75 0a                	jne    800bf8 <strtol+0x4d>
		s++, neg = 1;
  800bee:	83 c2 01             	add    $0x1,%edx
  800bf1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bf8:	85 db                	test   %ebx,%ebx
  800bfa:	0f 94 c0             	sete   %al
  800bfd:	74 05                	je     800c04 <strtol+0x59>
  800bff:	83 fb 10             	cmp    $0x10,%ebx
  800c02:	75 18                	jne    800c1c <strtol+0x71>
  800c04:	80 3a 30             	cmpb   $0x30,(%edx)
  800c07:	75 13                	jne    800c1c <strtol+0x71>
  800c09:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c0d:	8d 76 00             	lea    0x0(%esi),%esi
  800c10:	75 0a                	jne    800c1c <strtol+0x71>
		s += 2, base = 16;
  800c12:	83 c2 02             	add    $0x2,%edx
  800c15:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c1a:	eb 15                	jmp    800c31 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c1c:	84 c0                	test   %al,%al
  800c1e:	66 90                	xchg   %ax,%ax
  800c20:	74 0f                	je     800c31 <strtol+0x86>
  800c22:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c27:	80 3a 30             	cmpb   $0x30,(%edx)
  800c2a:	75 05                	jne    800c31 <strtol+0x86>
		s++, base = 8;
  800c2c:	83 c2 01             	add    $0x1,%edx
  800c2f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c31:	b8 00 00 00 00       	mov    $0x0,%eax
  800c36:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c38:	0f b6 0a             	movzbl (%edx),%ecx
  800c3b:	89 cf                	mov    %ecx,%edi
  800c3d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c40:	80 fb 09             	cmp    $0x9,%bl
  800c43:	77 08                	ja     800c4d <strtol+0xa2>
			dig = *s - '0';
  800c45:	0f be c9             	movsbl %cl,%ecx
  800c48:	83 e9 30             	sub    $0x30,%ecx
  800c4b:	eb 1e                	jmp    800c6b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800c4d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800c50:	80 fb 19             	cmp    $0x19,%bl
  800c53:	77 08                	ja     800c5d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800c55:	0f be c9             	movsbl %cl,%ecx
  800c58:	83 e9 57             	sub    $0x57,%ecx
  800c5b:	eb 0e                	jmp    800c6b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800c5d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800c60:	80 fb 19             	cmp    $0x19,%bl
  800c63:	77 15                	ja     800c7a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800c65:	0f be c9             	movsbl %cl,%ecx
  800c68:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c6b:	39 f1                	cmp    %esi,%ecx
  800c6d:	7d 0b                	jge    800c7a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800c6f:	83 c2 01             	add    $0x1,%edx
  800c72:	0f af c6             	imul   %esi,%eax
  800c75:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c78:	eb be                	jmp    800c38 <strtol+0x8d>
  800c7a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800c7c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c80:	74 05                	je     800c87 <strtol+0xdc>
		*endptr = (char *) s;
  800c82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c85:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c87:	89 ca                	mov    %ecx,%edx
  800c89:	f7 da                	neg    %edx
  800c8b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c8f:	0f 45 c2             	cmovne %edx,%eax
}
  800c92:	83 c4 04             	add    $0x4,%esp
  800c95:	5b                   	pop    %ebx
  800c96:	5e                   	pop    %esi
  800c97:	5f                   	pop    %edi
  800c98:	5d                   	pop    %ebp
  800c99:	c3                   	ret    
	...

00800c9c <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c9c:	55                   	push   %ebp
  800c9d:	89 e5                	mov    %esp,%ebp
  800c9f:	83 ec 48             	sub    $0x48,%esp
  800ca2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ca5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ca8:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800cab:	89 c6                	mov    %eax,%esi
  800cad:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800cb0:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800cb2:	8b 7d 10             	mov    0x10(%ebp),%edi
  800cb5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cbb:	51                   	push   %ecx
  800cbc:	52                   	push   %edx
  800cbd:	53                   	push   %ebx
  800cbe:	54                   	push   %esp
  800cbf:	55                   	push   %ebp
  800cc0:	56                   	push   %esi
  800cc1:	57                   	push   %edi
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	8d 35 cc 0c 80 00    	lea    0x800ccc,%esi
  800cca:	0f 34                	sysenter 

00800ccc <.after_sysenter_label>:
  800ccc:	5f                   	pop    %edi
  800ccd:	5e                   	pop    %esi
  800cce:	5d                   	pop    %ebp
  800ccf:	5c                   	pop    %esp
  800cd0:	5b                   	pop    %ebx
  800cd1:	5a                   	pop    %edx
  800cd2:	59                   	pop    %ecx
  800cd3:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800cd5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800cd9:	74 28                	je     800d03 <.after_sysenter_label+0x37>
  800cdb:	85 c0                	test   %eax,%eax
  800cdd:	7e 24                	jle    800d03 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ce3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ce7:	c7 44 24 08 40 21 80 	movl   $0x802140,0x8(%esp)
  800cee:	00 
  800cef:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800cf6:	00 
  800cf7:	c7 04 24 5d 21 80 00 	movl   $0x80215d,(%esp)
  800cfe:	e8 1d 0c 00 00       	call   801920 <_panic>

	return ret;
}
  800d03:	89 d0                	mov    %edx,%eax
  800d05:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d08:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d0b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d0e:	89 ec                	mov    %ebp,%esp
  800d10:	5d                   	pop    %ebp
  800d11:	c3                   	ret    

00800d12 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d18:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d1f:	00 
  800d20:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d27:	00 
  800d28:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d2f:	00 
  800d30:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800d37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d3a:	ba 01 00 00 00       	mov    $0x1,%edx
  800d3f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d44:	e8 53 ff ff ff       	call   800c9c <syscall>
}
  800d49:	c9                   	leave  
  800d4a:	c3                   	ret    

00800d4b <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d51:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d58:	00 
  800d59:	8b 45 14             	mov    0x14(%ebp),%eax
  800d5c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d60:	8b 45 10             	mov    0x10(%ebp),%eax
  800d63:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d67:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d6a:	89 04 24             	mov    %eax,(%esp)
  800d6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d70:	ba 00 00 00 00       	mov    $0x0,%edx
  800d75:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d7a:	e8 1d ff ff ff       	call   800c9c <syscall>
}
  800d7f:	c9                   	leave  
  800d80:	c3                   	ret    

00800d81 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800d87:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d8e:	00 
  800d8f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d96:	00 
  800d97:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d9e:	00 
  800d9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da2:	89 04 24             	mov    %eax,(%esp)
  800da5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da8:	ba 01 00 00 00       	mov    $0x1,%edx
  800dad:	b8 0b 00 00 00       	mov    $0xb,%eax
  800db2:	e8 e5 fe ff ff       	call   800c9c <syscall>
}
  800db7:	c9                   	leave  
  800db8:	c3                   	ret    

00800db9 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800db9:	55                   	push   %ebp
  800dba:	89 e5                	mov    %esp,%ebp
  800dbc:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800dbf:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dc6:	00 
  800dc7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800dce:	00 
  800dcf:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800dd6:	00 
  800dd7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dda:	89 04 24             	mov    %eax,(%esp)
  800ddd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de0:	ba 01 00 00 00       	mov    $0x1,%edx
  800de5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800dea:	e8 ad fe ff ff       	call   800c9c <syscall>
}
  800def:	c9                   	leave  
  800df0:	c3                   	ret    

00800df1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
  800df4:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800df7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dfe:	00 
  800dff:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e06:	00 
  800e07:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e0e:	00 
  800e0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e12:	89 04 24             	mov    %eax,(%esp)
  800e15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e18:	ba 01 00 00 00       	mov    $0x1,%edx
  800e1d:	b8 09 00 00 00       	mov    $0x9,%eax
  800e22:	e8 75 fe ff ff       	call   800c9c <syscall>
}
  800e27:	c9                   	leave  
  800e28:	c3                   	ret    

00800e29 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800e29:	55                   	push   %ebp
  800e2a:	89 e5                	mov    %esp,%ebp
  800e2c:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800e2f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e36:	00 
  800e37:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e3e:	00 
  800e3f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e46:	00 
  800e47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e4a:	89 04 24             	mov    %eax,(%esp)
  800e4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e50:	ba 01 00 00 00       	mov    $0x1,%edx
  800e55:	b8 07 00 00 00       	mov    $0x7,%eax
  800e5a:	e8 3d fe ff ff       	call   800c9c <syscall>
}
  800e5f:	c9                   	leave  
  800e60:	c3                   	ret    

00800e61 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800e67:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e6e:	00 
  800e6f:	8b 45 18             	mov    0x18(%ebp),%eax
  800e72:	0b 45 14             	or     0x14(%ebp),%eax
  800e75:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e79:	8b 45 10             	mov    0x10(%ebp),%eax
  800e7c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e80:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e83:	89 04 24             	mov    %eax,(%esp)
  800e86:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e89:	ba 01 00 00 00       	mov    $0x1,%edx
  800e8e:	b8 06 00 00 00       	mov    $0x6,%eax
  800e93:	e8 04 fe ff ff       	call   800c9c <syscall>
}
  800e98:	c9                   	leave  
  800e99:	c3                   	ret    

00800e9a <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e9a:	55                   	push   %ebp
  800e9b:	89 e5                	mov    %esp,%ebp
  800e9d:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800ea0:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ea7:	00 
  800ea8:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800eaf:	00 
  800eb0:	8b 45 10             	mov    0x10(%ebp),%eax
  800eb3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800eb7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eba:	89 04 24             	mov    %eax,(%esp)
  800ebd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec0:	ba 01 00 00 00       	mov    $0x1,%edx
  800ec5:	b8 05 00 00 00       	mov    $0x5,%eax
  800eca:	e8 cd fd ff ff       	call   800c9c <syscall>
}
  800ecf:	c9                   	leave  
  800ed0:	c3                   	ret    

00800ed1 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800ed7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ede:	00 
  800edf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ee6:	00 
  800ee7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800eee:	00 
  800eef:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800ef6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800efb:	ba 00 00 00 00       	mov    $0x0,%edx
  800f00:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f05:	e8 92 fd ff ff       	call   800c9c <syscall>
}
  800f0a:	c9                   	leave  
  800f0b:	c3                   	ret    

00800f0c <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800f0c:	55                   	push   %ebp
  800f0d:	89 e5                	mov    %esp,%ebp
  800f0f:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  800f12:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f19:	00 
  800f1a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f21:	00 
  800f22:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f29:	00 
  800f2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f2d:	89 04 24             	mov    %eax,(%esp)
  800f30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f33:	ba 00 00 00 00       	mov    $0x0,%edx
  800f38:	b8 04 00 00 00       	mov    $0x4,%eax
  800f3d:	e8 5a fd ff ff       	call   800c9c <syscall>
}
  800f42:	c9                   	leave  
  800f43:	c3                   	ret    

00800f44 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800f44:	55                   	push   %ebp
  800f45:	89 e5                	mov    %esp,%ebp
  800f47:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800f4a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f51:	00 
  800f52:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f59:	00 
  800f5a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f61:	00 
  800f62:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f69:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f6e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f73:	b8 02 00 00 00       	mov    $0x2,%eax
  800f78:	e8 1f fd ff ff       	call   800c9c <syscall>
}
  800f7d:	c9                   	leave  
  800f7e:	c3                   	ret    

00800f7f <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800f85:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f8c:	00 
  800f8d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f94:	00 
  800f95:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f9c:	00 
  800f9d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fa4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fa7:	ba 01 00 00 00       	mov    $0x1,%edx
  800fac:	b8 03 00 00 00       	mov    $0x3,%eax
  800fb1:	e8 e6 fc ff ff       	call   800c9c <syscall>
}
  800fb6:	c9                   	leave  
  800fb7:	c3                   	ret    

00800fb8 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800fbe:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fc5:	00 
  800fc6:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fcd:	00 
  800fce:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fd5:	00 
  800fd6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800fdd:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe2:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe7:	b8 01 00 00 00       	mov    $0x1,%eax
  800fec:	e8 ab fc ff ff       	call   800c9c <syscall>
}
  800ff1:	c9                   	leave  
  800ff2:	c3                   	ret    

00800ff3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800ff3:	55                   	push   %ebp
  800ff4:	89 e5                	mov    %esp,%ebp
  800ff6:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800ff9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801000:	00 
  801001:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801008:	00 
  801009:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801010:	00 
  801011:	8b 45 0c             	mov    0xc(%ebp),%eax
  801014:	89 04 24             	mov    %eax,(%esp)
  801017:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80101a:	ba 00 00 00 00       	mov    $0x0,%edx
  80101f:	b8 00 00 00 00       	mov    $0x0,%eax
  801024:	e8 73 fc ff ff       	call   800c9c <syscall>
}
  801029:	c9                   	leave  
  80102a:	c3                   	ret    
  80102b:	00 00                	add    %al,(%eax)
  80102d:	00 00                	add    %al,(%eax)
	...

00801030 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	8b 45 08             	mov    0x8(%ebp),%eax
  801036:	05 00 00 00 30       	add    $0x30000000,%eax
  80103b:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  80103e:	5d                   	pop    %ebp
  80103f:	c3                   	ret    

00801040 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801046:	8b 45 08             	mov    0x8(%ebp),%eax
  801049:	89 04 24             	mov    %eax,(%esp)
  80104c:	e8 df ff ff ff       	call   801030 <fd2num>
  801051:	05 20 00 0d 00       	add    $0xd0020,%eax
  801056:	c1 e0 0c             	shl    $0xc,%eax
}
  801059:	c9                   	leave  
  80105a:	c3                   	ret    

0080105b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80105b:	55                   	push   %ebp
  80105c:	89 e5                	mov    %esp,%ebp
  80105e:	57                   	push   %edi
  80105f:	56                   	push   %esi
  801060:	53                   	push   %ebx
  801061:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801064:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801069:	a8 01                	test   $0x1,%al
  80106b:	74 36                	je     8010a3 <fd_alloc+0x48>
  80106d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801072:	a8 01                	test   $0x1,%al
  801074:	74 2d                	je     8010a3 <fd_alloc+0x48>
  801076:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80107b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801080:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801085:	89 c3                	mov    %eax,%ebx
  801087:	89 c2                	mov    %eax,%edx
  801089:	c1 ea 16             	shr    $0x16,%edx
  80108c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80108f:	f6 c2 01             	test   $0x1,%dl
  801092:	74 14                	je     8010a8 <fd_alloc+0x4d>
  801094:	89 c2                	mov    %eax,%edx
  801096:	c1 ea 0c             	shr    $0xc,%edx
  801099:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80109c:	f6 c2 01             	test   $0x1,%dl
  80109f:	75 10                	jne    8010b1 <fd_alloc+0x56>
  8010a1:	eb 05                	jmp    8010a8 <fd_alloc+0x4d>
  8010a3:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  8010a8:	89 1f                	mov    %ebx,(%edi)
  8010aa:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  8010af:	eb 17                	jmp    8010c8 <fd_alloc+0x6d>
  8010b1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010b6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010bb:	75 c8                	jne    801085 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010bd:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8010c3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  8010c8:	5b                   	pop    %ebx
  8010c9:	5e                   	pop    %esi
  8010ca:	5f                   	pop    %edi
  8010cb:	5d                   	pop    %ebp
  8010cc:	c3                   	ret    

008010cd <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010cd:	55                   	push   %ebp
  8010ce:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d3:	83 f8 1f             	cmp    $0x1f,%eax
  8010d6:	77 36                	ja     80110e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010d8:	05 00 00 0d 00       	add    $0xd0000,%eax
  8010dd:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8010e0:	89 c2                	mov    %eax,%edx
  8010e2:	c1 ea 16             	shr    $0x16,%edx
  8010e5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010ec:	f6 c2 01             	test   $0x1,%dl
  8010ef:	74 1d                	je     80110e <fd_lookup+0x41>
  8010f1:	89 c2                	mov    %eax,%edx
  8010f3:	c1 ea 0c             	shr    $0xc,%edx
  8010f6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010fd:	f6 c2 01             	test   $0x1,%dl
  801100:	74 0c                	je     80110e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  801102:	8b 55 0c             	mov    0xc(%ebp),%edx
  801105:	89 02                	mov    %eax,(%edx)
  801107:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  80110c:	eb 05                	jmp    801113 <fd_lookup+0x46>
  80110e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801113:	5d                   	pop    %ebp
  801114:	c3                   	ret    

00801115 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  801115:	55                   	push   %ebp
  801116:	89 e5                	mov    %esp,%ebp
  801118:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80111b:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80111e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801122:	8b 45 08             	mov    0x8(%ebp),%eax
  801125:	89 04 24             	mov    %eax,(%esp)
  801128:	e8 a0 ff ff ff       	call   8010cd <fd_lookup>
  80112d:	85 c0                	test   %eax,%eax
  80112f:	78 0e                	js     80113f <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  801131:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801134:	8b 55 0c             	mov    0xc(%ebp),%edx
  801137:	89 50 04             	mov    %edx,0x4(%eax)
  80113a:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80113f:	c9                   	leave  
  801140:	c3                   	ret    

00801141 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801141:	55                   	push   %ebp
  801142:	89 e5                	mov    %esp,%ebp
  801144:	56                   	push   %esi
  801145:	53                   	push   %ebx
  801146:	83 ec 10             	sub    $0x10,%esp
  801149:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80114c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80114f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801154:	b8 04 30 80 00       	mov    $0x803004,%eax
  801159:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80115f:	75 11                	jne    801172 <dev_lookup+0x31>
  801161:	eb 04                	jmp    801167 <dev_lookup+0x26>
  801163:	39 08                	cmp    %ecx,(%eax)
  801165:	75 10                	jne    801177 <dev_lookup+0x36>
			*dev = devtab[i];
  801167:	89 03                	mov    %eax,(%ebx)
  801169:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80116e:	66 90                	xchg   %ax,%ax
  801170:	eb 36                	jmp    8011a8 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801172:	be e8 21 80 00       	mov    $0x8021e8,%esi
  801177:	83 c2 01             	add    $0x1,%edx
  80117a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80117d:	85 c0                	test   %eax,%eax
  80117f:	75 e2                	jne    801163 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801181:	a1 04 40 80 00       	mov    0x804004,%eax
  801186:	8b 40 48             	mov    0x48(%eax),%eax
  801189:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80118d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801191:	c7 04 24 6c 21 80 00 	movl   $0x80216c,(%esp)
  801198:	e8 d0 ef ff ff       	call   80016d <cprintf>
	*dev = 0;
  80119d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8011a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  8011a8:	83 c4 10             	add    $0x10,%esp
  8011ab:	5b                   	pop    %ebx
  8011ac:	5e                   	pop    %esi
  8011ad:	5d                   	pop    %ebp
  8011ae:	c3                   	ret    

008011af <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  8011af:	55                   	push   %ebp
  8011b0:	89 e5                	mov    %esp,%ebp
  8011b2:	53                   	push   %ebx
  8011b3:	83 ec 24             	sub    $0x24,%esp
  8011b6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011b9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8011c3:	89 04 24             	mov    %eax,(%esp)
  8011c6:	e8 02 ff ff ff       	call   8010cd <fd_lookup>
  8011cb:	85 c0                	test   %eax,%eax
  8011cd:	78 53                	js     801222 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d9:	8b 00                	mov    (%eax),%eax
  8011db:	89 04 24             	mov    %eax,(%esp)
  8011de:	e8 5e ff ff ff       	call   801141 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e3:	85 c0                	test   %eax,%eax
  8011e5:	78 3b                	js     801222 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8011e7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011ec:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011ef:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8011f3:	74 2d                	je     801222 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8011f5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8011f8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8011ff:	00 00 00 
	stat->st_isdir = 0;
  801202:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801209:	00 00 00 
	stat->st_dev = dev;
  80120c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80120f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801215:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801219:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80121c:	89 14 24             	mov    %edx,(%esp)
  80121f:	ff 50 14             	call   *0x14(%eax)
}
  801222:	83 c4 24             	add    $0x24,%esp
  801225:	5b                   	pop    %ebx
  801226:	5d                   	pop    %ebp
  801227:	c3                   	ret    

00801228 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  801228:	55                   	push   %ebp
  801229:	89 e5                	mov    %esp,%ebp
  80122b:	53                   	push   %ebx
  80122c:	83 ec 24             	sub    $0x24,%esp
  80122f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801232:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801235:	89 44 24 04          	mov    %eax,0x4(%esp)
  801239:	89 1c 24             	mov    %ebx,(%esp)
  80123c:	e8 8c fe ff ff       	call   8010cd <fd_lookup>
  801241:	85 c0                	test   %eax,%eax
  801243:	78 5f                	js     8012a4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801245:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801248:	89 44 24 04          	mov    %eax,0x4(%esp)
  80124c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80124f:	8b 00                	mov    (%eax),%eax
  801251:	89 04 24             	mov    %eax,(%esp)
  801254:	e8 e8 fe ff ff       	call   801141 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801259:	85 c0                	test   %eax,%eax
  80125b:	78 47                	js     8012a4 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80125d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801260:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801264:	75 23                	jne    801289 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801266:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80126b:	8b 40 48             	mov    0x48(%eax),%eax
  80126e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801272:	89 44 24 04          	mov    %eax,0x4(%esp)
  801276:	c7 04 24 8c 21 80 00 	movl   $0x80218c,(%esp)
  80127d:	e8 eb ee ff ff       	call   80016d <cprintf>
  801282:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801287:	eb 1b                	jmp    8012a4 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801289:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80128c:	8b 48 18             	mov    0x18(%eax),%ecx
  80128f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801294:	85 c9                	test   %ecx,%ecx
  801296:	74 0c                	je     8012a4 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801298:	8b 45 0c             	mov    0xc(%ebp),%eax
  80129b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80129f:	89 14 24             	mov    %edx,(%esp)
  8012a2:	ff d1                	call   *%ecx
}
  8012a4:	83 c4 24             	add    $0x24,%esp
  8012a7:	5b                   	pop    %ebx
  8012a8:	5d                   	pop    %ebp
  8012a9:	c3                   	ret    

008012aa <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8012aa:	55                   	push   %ebp
  8012ab:	89 e5                	mov    %esp,%ebp
  8012ad:	53                   	push   %ebx
  8012ae:	83 ec 24             	sub    $0x24,%esp
  8012b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012b7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012bb:	89 1c 24             	mov    %ebx,(%esp)
  8012be:	e8 0a fe ff ff       	call   8010cd <fd_lookup>
  8012c3:	85 c0                	test   %eax,%eax
  8012c5:	78 66                	js     80132d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012c7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ca:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d1:	8b 00                	mov    (%eax),%eax
  8012d3:	89 04 24             	mov    %eax,(%esp)
  8012d6:	e8 66 fe ff ff       	call   801141 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012db:	85 c0                	test   %eax,%eax
  8012dd:	78 4e                	js     80132d <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012df:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012e2:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8012e6:	75 23                	jne    80130b <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012e8:	a1 04 40 80 00       	mov    0x804004,%eax
  8012ed:	8b 40 48             	mov    0x48(%eax),%eax
  8012f0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012f8:	c7 04 24 ad 21 80 00 	movl   $0x8021ad,(%esp)
  8012ff:	e8 69 ee ff ff       	call   80016d <cprintf>
  801304:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801309:	eb 22                	jmp    80132d <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80130b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80130e:	8b 48 0c             	mov    0xc(%eax),%ecx
  801311:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801316:	85 c9                	test   %ecx,%ecx
  801318:	74 13                	je     80132d <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80131a:	8b 45 10             	mov    0x10(%ebp),%eax
  80131d:	89 44 24 08          	mov    %eax,0x8(%esp)
  801321:	8b 45 0c             	mov    0xc(%ebp),%eax
  801324:	89 44 24 04          	mov    %eax,0x4(%esp)
  801328:	89 14 24             	mov    %edx,(%esp)
  80132b:	ff d1                	call   *%ecx
}
  80132d:	83 c4 24             	add    $0x24,%esp
  801330:	5b                   	pop    %ebx
  801331:	5d                   	pop    %ebp
  801332:	c3                   	ret    

00801333 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801333:	55                   	push   %ebp
  801334:	89 e5                	mov    %esp,%ebp
  801336:	53                   	push   %ebx
  801337:	83 ec 24             	sub    $0x24,%esp
  80133a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80133d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801340:	89 44 24 04          	mov    %eax,0x4(%esp)
  801344:	89 1c 24             	mov    %ebx,(%esp)
  801347:	e8 81 fd ff ff       	call   8010cd <fd_lookup>
  80134c:	85 c0                	test   %eax,%eax
  80134e:	78 6b                	js     8013bb <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801350:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801353:	89 44 24 04          	mov    %eax,0x4(%esp)
  801357:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80135a:	8b 00                	mov    (%eax),%eax
  80135c:	89 04 24             	mov    %eax,(%esp)
  80135f:	e8 dd fd ff ff       	call   801141 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801364:	85 c0                	test   %eax,%eax
  801366:	78 53                	js     8013bb <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801368:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80136b:	8b 42 08             	mov    0x8(%edx),%eax
  80136e:	83 e0 03             	and    $0x3,%eax
  801371:	83 f8 01             	cmp    $0x1,%eax
  801374:	75 23                	jne    801399 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801376:	a1 04 40 80 00       	mov    0x804004,%eax
  80137b:	8b 40 48             	mov    0x48(%eax),%eax
  80137e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801382:	89 44 24 04          	mov    %eax,0x4(%esp)
  801386:	c7 04 24 ca 21 80 00 	movl   $0x8021ca,(%esp)
  80138d:	e8 db ed ff ff       	call   80016d <cprintf>
  801392:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801397:	eb 22                	jmp    8013bb <read+0x88>
	}
	if (!dev->dev_read)
  801399:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80139c:	8b 48 08             	mov    0x8(%eax),%ecx
  80139f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013a4:	85 c9                	test   %ecx,%ecx
  8013a6:	74 13                	je     8013bb <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8013ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013af:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013b2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8013b6:	89 14 24             	mov    %edx,(%esp)
  8013b9:	ff d1                	call   *%ecx
}
  8013bb:	83 c4 24             	add    $0x24,%esp
  8013be:	5b                   	pop    %ebx
  8013bf:	5d                   	pop    %ebp
  8013c0:	c3                   	ret    

008013c1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013c1:	55                   	push   %ebp
  8013c2:	89 e5                	mov    %esp,%ebp
  8013c4:	57                   	push   %edi
  8013c5:	56                   	push   %esi
  8013c6:	53                   	push   %ebx
  8013c7:	83 ec 1c             	sub    $0x1c,%esp
  8013ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013cd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013da:	b8 00 00 00 00       	mov    $0x0,%eax
  8013df:	85 f6                	test   %esi,%esi
  8013e1:	74 29                	je     80140c <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013e3:	89 f0                	mov    %esi,%eax
  8013e5:	29 d0                	sub    %edx,%eax
  8013e7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013eb:	03 55 0c             	add    0xc(%ebp),%edx
  8013ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013f2:	89 3c 24             	mov    %edi,(%esp)
  8013f5:	e8 39 ff ff ff       	call   801333 <read>
		if (m < 0)
  8013fa:	85 c0                	test   %eax,%eax
  8013fc:	78 0e                	js     80140c <readn+0x4b>
			return m;
		if (m == 0)
  8013fe:	85 c0                	test   %eax,%eax
  801400:	74 08                	je     80140a <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801402:	01 c3                	add    %eax,%ebx
  801404:	89 da                	mov    %ebx,%edx
  801406:	39 f3                	cmp    %esi,%ebx
  801408:	72 d9                	jb     8013e3 <readn+0x22>
  80140a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80140c:	83 c4 1c             	add    $0x1c,%esp
  80140f:	5b                   	pop    %ebx
  801410:	5e                   	pop    %esi
  801411:	5f                   	pop    %edi
  801412:	5d                   	pop    %ebp
  801413:	c3                   	ret    

00801414 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
  801417:	83 ec 28             	sub    $0x28,%esp
  80141a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80141d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801420:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801423:	89 34 24             	mov    %esi,(%esp)
  801426:	e8 05 fc ff ff       	call   801030 <fd2num>
  80142b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80142e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801432:	89 04 24             	mov    %eax,(%esp)
  801435:	e8 93 fc ff ff       	call   8010cd <fd_lookup>
  80143a:	89 c3                	mov    %eax,%ebx
  80143c:	85 c0                	test   %eax,%eax
  80143e:	78 05                	js     801445 <fd_close+0x31>
  801440:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801443:	74 0e                	je     801453 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801445:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801449:	b8 00 00 00 00       	mov    $0x0,%eax
  80144e:	0f 44 d8             	cmove  %eax,%ebx
  801451:	eb 3d                	jmp    801490 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801453:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801456:	89 44 24 04          	mov    %eax,0x4(%esp)
  80145a:	8b 06                	mov    (%esi),%eax
  80145c:	89 04 24             	mov    %eax,(%esp)
  80145f:	e8 dd fc ff ff       	call   801141 <dev_lookup>
  801464:	89 c3                	mov    %eax,%ebx
  801466:	85 c0                	test   %eax,%eax
  801468:	78 16                	js     801480 <fd_close+0x6c>
		if (dev->dev_close)
  80146a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146d:	8b 40 10             	mov    0x10(%eax),%eax
  801470:	bb 00 00 00 00       	mov    $0x0,%ebx
  801475:	85 c0                	test   %eax,%eax
  801477:	74 07                	je     801480 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801479:	89 34 24             	mov    %esi,(%esp)
  80147c:	ff d0                	call   *%eax
  80147e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801480:	89 74 24 04          	mov    %esi,0x4(%esp)
  801484:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80148b:	e8 99 f9 ff ff       	call   800e29 <sys_page_unmap>
	return r;
}
  801490:	89 d8                	mov    %ebx,%eax
  801492:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801495:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801498:	89 ec                	mov    %ebp,%esp
  80149a:	5d                   	pop    %ebp
  80149b:	c3                   	ret    

0080149c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80149c:	55                   	push   %ebp
  80149d:	89 e5                	mov    %esp,%ebp
  80149f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ac:	89 04 24             	mov    %eax,(%esp)
  8014af:	e8 19 fc ff ff       	call   8010cd <fd_lookup>
  8014b4:	85 c0                	test   %eax,%eax
  8014b6:	78 13                	js     8014cb <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  8014b8:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8014bf:	00 
  8014c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c3:	89 04 24             	mov    %eax,(%esp)
  8014c6:	e8 49 ff ff ff       	call   801414 <fd_close>
}
  8014cb:	c9                   	leave  
  8014cc:	c3                   	ret    

008014cd <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  8014cd:	55                   	push   %ebp
  8014ce:	89 e5                	mov    %esp,%ebp
  8014d0:	83 ec 18             	sub    $0x18,%esp
  8014d3:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8014d6:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8014d9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014e0:	00 
  8014e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e4:	89 04 24             	mov    %eax,(%esp)
  8014e7:	e8 78 03 00 00       	call   801864 <open>
  8014ec:	89 c3                	mov    %eax,%ebx
  8014ee:	85 c0                	test   %eax,%eax
  8014f0:	78 1b                	js     80150d <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8014f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014f9:	89 1c 24             	mov    %ebx,(%esp)
  8014fc:	e8 ae fc ff ff       	call   8011af <fstat>
  801501:	89 c6                	mov    %eax,%esi
	close(fd);
  801503:	89 1c 24             	mov    %ebx,(%esp)
  801506:	e8 91 ff ff ff       	call   80149c <close>
  80150b:	89 f3                	mov    %esi,%ebx
	return r;
}
  80150d:	89 d8                	mov    %ebx,%eax
  80150f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801512:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801515:	89 ec                	mov    %ebp,%esp
  801517:	5d                   	pop    %ebp
  801518:	c3                   	ret    

00801519 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801519:	55                   	push   %ebp
  80151a:	89 e5                	mov    %esp,%ebp
  80151c:	53                   	push   %ebx
  80151d:	83 ec 14             	sub    $0x14,%esp
  801520:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801525:	89 1c 24             	mov    %ebx,(%esp)
  801528:	e8 6f ff ff ff       	call   80149c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80152d:	83 c3 01             	add    $0x1,%ebx
  801530:	83 fb 20             	cmp    $0x20,%ebx
  801533:	75 f0                	jne    801525 <close_all+0xc>
		close(i);
}
  801535:	83 c4 14             	add    $0x14,%esp
  801538:	5b                   	pop    %ebx
  801539:	5d                   	pop    %ebp
  80153a:	c3                   	ret    

0080153b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80153b:	55                   	push   %ebp
  80153c:	89 e5                	mov    %esp,%ebp
  80153e:	83 ec 58             	sub    $0x58,%esp
  801541:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801544:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801547:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80154a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80154d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801550:	89 44 24 04          	mov    %eax,0x4(%esp)
  801554:	8b 45 08             	mov    0x8(%ebp),%eax
  801557:	89 04 24             	mov    %eax,(%esp)
  80155a:	e8 6e fb ff ff       	call   8010cd <fd_lookup>
  80155f:	89 c3                	mov    %eax,%ebx
  801561:	85 c0                	test   %eax,%eax
  801563:	0f 88 e0 00 00 00    	js     801649 <dup+0x10e>
		return r;
	close(newfdnum);
  801569:	89 3c 24             	mov    %edi,(%esp)
  80156c:	e8 2b ff ff ff       	call   80149c <close>

	newfd = INDEX2FD(newfdnum);
  801571:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801577:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80157a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80157d:	89 04 24             	mov    %eax,(%esp)
  801580:	e8 bb fa ff ff       	call   801040 <fd2data>
  801585:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801587:	89 34 24             	mov    %esi,(%esp)
  80158a:	e8 b1 fa ff ff       	call   801040 <fd2data>
  80158f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801592:	89 da                	mov    %ebx,%edx
  801594:	89 d8                	mov    %ebx,%eax
  801596:	c1 e8 16             	shr    $0x16,%eax
  801599:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015a0:	a8 01                	test   $0x1,%al
  8015a2:	74 43                	je     8015e7 <dup+0xac>
  8015a4:	c1 ea 0c             	shr    $0xc,%edx
  8015a7:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8015ae:	a8 01                	test   $0x1,%al
  8015b0:	74 35                	je     8015e7 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015b2:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8015b9:	25 07 0e 00 00       	and    $0xe07,%eax
  8015be:	89 44 24 10          	mov    %eax,0x10(%esp)
  8015c2:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015c5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8015c9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015d0:	00 
  8015d1:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8015d5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015dc:	e8 80 f8 ff ff       	call   800e61 <sys_page_map>
  8015e1:	89 c3                	mov    %eax,%ebx
  8015e3:	85 c0                	test   %eax,%eax
  8015e5:	78 3f                	js     801626 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015e7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015ea:	89 c2                	mov    %eax,%edx
  8015ec:	c1 ea 0c             	shr    $0xc,%edx
  8015ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015f6:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8015fc:	89 54 24 10          	mov    %edx,0x10(%esp)
  801600:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801604:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80160b:	00 
  80160c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801610:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801617:	e8 45 f8 ff ff       	call   800e61 <sys_page_map>
  80161c:	89 c3                	mov    %eax,%ebx
  80161e:	85 c0                	test   %eax,%eax
  801620:	78 04                	js     801626 <dup+0xeb>
  801622:	89 fb                	mov    %edi,%ebx
  801624:	eb 23                	jmp    801649 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801626:	89 74 24 04          	mov    %esi,0x4(%esp)
  80162a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801631:	e8 f3 f7 ff ff       	call   800e29 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801636:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801639:	89 44 24 04          	mov    %eax,0x4(%esp)
  80163d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801644:	e8 e0 f7 ff ff       	call   800e29 <sys_page_unmap>
	return r;
}
  801649:	89 d8                	mov    %ebx,%eax
  80164b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80164e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801651:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801654:	89 ec                	mov    %ebp,%esp
  801656:	5d                   	pop    %ebp
  801657:	c3                   	ret    

00801658 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801658:	55                   	push   %ebp
  801659:	89 e5                	mov    %esp,%ebp
  80165b:	83 ec 18             	sub    $0x18,%esp
  80165e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801661:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801664:	89 c3                	mov    %eax,%ebx
  801666:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801668:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80166f:	75 11                	jne    801682 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801671:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801678:	e8 03 03 00 00       	call   801980 <ipc_find_env>
  80167d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801682:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801689:	00 
  80168a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801691:	00 
  801692:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801696:	a1 00 40 80 00       	mov    0x804000,%eax
  80169b:	89 04 24             	mov    %eax,(%esp)
  80169e:	e8 21 03 00 00       	call   8019c4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8016a3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8016aa:	00 
  8016ab:	89 74 24 04          	mov    %esi,0x4(%esp)
  8016af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8016b6:	e8 78 03 00 00       	call   801a33 <ipc_recv>
}
  8016bb:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8016be:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8016c1:	89 ec                	mov    %ebp,%esp
  8016c3:	5d                   	pop    %ebp
  8016c4:	c3                   	ret    

008016c5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8016cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ce:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8016d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8016d9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8016de:	ba 00 00 00 00       	mov    $0x0,%edx
  8016e3:	b8 02 00 00 00       	mov    $0x2,%eax
  8016e8:	e8 6b ff ff ff       	call   801658 <fsipc>
}
  8016ed:	c9                   	leave  
  8016ee:	c3                   	ret    

008016ef <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f8:	8b 40 0c             	mov    0xc(%eax),%eax
  8016fb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801700:	ba 00 00 00 00       	mov    $0x0,%edx
  801705:	b8 06 00 00 00       	mov    $0x6,%eax
  80170a:	e8 49 ff ff ff       	call   801658 <fsipc>
}
  80170f:	c9                   	leave  
  801710:	c3                   	ret    

00801711 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801711:	55                   	push   %ebp
  801712:	89 e5                	mov    %esp,%ebp
  801714:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801717:	ba 00 00 00 00       	mov    $0x0,%edx
  80171c:	b8 08 00 00 00       	mov    $0x8,%eax
  801721:	e8 32 ff ff ff       	call   801658 <fsipc>
}
  801726:	c9                   	leave  
  801727:	c3                   	ret    

00801728 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	53                   	push   %ebx
  80172c:	83 ec 14             	sub    $0x14,%esp
  80172f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801732:	8b 45 08             	mov    0x8(%ebp),%eax
  801735:	8b 40 0c             	mov    0xc(%eax),%eax
  801738:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80173d:	ba 00 00 00 00       	mov    $0x0,%edx
  801742:	b8 05 00 00 00       	mov    $0x5,%eax
  801747:	e8 0c ff ff ff       	call   801658 <fsipc>
  80174c:	85 c0                	test   %eax,%eax
  80174e:	78 2b                	js     80177b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801750:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801757:	00 
  801758:	89 1c 24             	mov    %ebx,(%esp)
  80175b:	e8 4a f1 ff ff       	call   8008aa <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801760:	a1 80 50 80 00       	mov    0x805080,%eax
  801765:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80176b:	a1 84 50 80 00       	mov    0x805084,%eax
  801770:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801776:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80177b:	83 c4 14             	add    $0x14,%esp
  80177e:	5b                   	pop    %ebx
  80177f:	5d                   	pop    %ebp
  801780:	c3                   	ret    

00801781 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801781:	55                   	push   %ebp
  801782:	89 e5                	mov    %esp,%ebp
  801784:	83 ec 18             	sub    $0x18,%esp
  801787:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  80178a:	8b 55 08             	mov    0x8(%ebp),%edx
  80178d:	8b 52 0c             	mov    0xc(%edx),%edx
  801790:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  801796:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  80179b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8017a0:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8017a5:	0f 47 c2             	cmova  %edx,%eax
  8017a8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017af:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017b3:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  8017ba:	e8 d6 f2 ff ff       	call   800a95 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  8017bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8017c4:	b8 04 00 00 00       	mov    $0x4,%eax
  8017c9:	e8 8a fe ff ff       	call   801658 <fsipc>
}
  8017ce:	c9                   	leave  
  8017cf:	c3                   	ret    

008017d0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8017d0:	55                   	push   %ebp
  8017d1:	89 e5                	mov    %esp,%ebp
  8017d3:	53                   	push   %ebx
  8017d4:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  8017d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017da:	8b 40 0c             	mov    0xc(%eax),%eax
  8017dd:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  8017e2:	8b 45 10             	mov    0x10(%ebp),%eax
  8017e5:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8017ef:	b8 03 00 00 00       	mov    $0x3,%eax
  8017f4:	e8 5f fe ff ff       	call   801658 <fsipc>
  8017f9:	89 c3                	mov    %eax,%ebx
  8017fb:	85 c0                	test   %eax,%eax
  8017fd:	78 17                	js     801816 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  801803:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  80180a:	00 
  80180b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80180e:	89 04 24             	mov    %eax,(%esp)
  801811:	e8 7f f2 ff ff       	call   800a95 <memmove>
  return r;	
}
  801816:	89 d8                	mov    %ebx,%eax
  801818:	83 c4 14             	add    $0x14,%esp
  80181b:	5b                   	pop    %ebx
  80181c:	5d                   	pop    %ebp
  80181d:	c3                   	ret    

0080181e <remove>:
}

// Delete a file
int
remove(const char *path)
{
  80181e:	55                   	push   %ebp
  80181f:	89 e5                	mov    %esp,%ebp
  801821:	53                   	push   %ebx
  801822:	83 ec 14             	sub    $0x14,%esp
  801825:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801828:	89 1c 24             	mov    %ebx,(%esp)
  80182b:	e8 30 f0 ff ff       	call   800860 <strlen>
  801830:	89 c2                	mov    %eax,%edx
  801832:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801837:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  80183d:	7f 1f                	jg     80185e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  80183f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801843:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80184a:	e8 5b f0 ff ff       	call   8008aa <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  80184f:	ba 00 00 00 00       	mov    $0x0,%edx
  801854:	b8 07 00 00 00       	mov    $0x7,%eax
  801859:	e8 fa fd ff ff       	call   801658 <fsipc>
}
  80185e:	83 c4 14             	add    $0x14,%esp
  801861:	5b                   	pop    %ebx
  801862:	5d                   	pop    %ebp
  801863:	c3                   	ret    

00801864 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801864:	55                   	push   %ebp
  801865:	89 e5                	mov    %esp,%ebp
  801867:	83 ec 28             	sub    $0x28,%esp
  80186a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80186d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801870:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801873:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801876:	89 04 24             	mov    %eax,(%esp)
  801879:	e8 dd f7 ff ff       	call   80105b <fd_alloc>
  80187e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801880:	85 c0                	test   %eax,%eax
  801882:	0f 88 89 00 00 00    	js     801911 <open+0xad>

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801888:	89 34 24             	mov    %esi,(%esp)
  80188b:	e8 d0 ef ff ff       	call   800860 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801890:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801895:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80189a:	7f 75                	jg     801911 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  80189c:	89 74 24 04          	mov    %esi,0x4(%esp)
  8018a0:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  8018a7:	e8 fe ef ff ff       	call   8008aa <strcpy>
  fsipcbuf.open.req_omode = mode;
  8018ac:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018af:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  8018b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018b7:	b8 01 00 00 00       	mov    $0x1,%eax
  8018bc:	e8 97 fd ff ff       	call   801658 <fsipc>
  8018c1:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  8018c3:	85 c0                	test   %eax,%eax
  8018c5:	78 0f                	js     8018d6 <open+0x72>
  return fd2num(fd);
  8018c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ca:	89 04 24             	mov    %eax,(%esp)
  8018cd:	e8 5e f7 ff ff       	call   801030 <fd2num>
  8018d2:	89 c3                	mov    %eax,%ebx
  8018d4:	eb 3b                	jmp    801911 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  8018d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8018dd:	00 
  8018de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e1:	89 04 24             	mov    %eax,(%esp)
  8018e4:	e8 2b fb ff ff       	call   801414 <fd_close>
  8018e9:	85 c0                	test   %eax,%eax
  8018eb:	74 24                	je     801911 <open+0xad>
  8018ed:	c7 44 24 0c f0 21 80 	movl   $0x8021f0,0xc(%esp)
  8018f4:	00 
  8018f5:	c7 44 24 08 05 22 80 	movl   $0x802205,0x8(%esp)
  8018fc:	00 
  8018fd:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801904:	00 
  801905:	c7 04 24 1a 22 80 00 	movl   $0x80221a,(%esp)
  80190c:	e8 0f 00 00 00       	call   801920 <_panic>
  return r;
}
  801911:	89 d8                	mov    %ebx,%eax
  801913:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801916:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801919:	89 ec                	mov    %ebp,%esp
  80191b:	5d                   	pop    %ebp
  80191c:	c3                   	ret    
  80191d:	00 00                	add    %al,(%eax)
	...

00801920 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	56                   	push   %esi
  801924:	53                   	push   %ebx
  801925:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801928:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80192b:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  801931:	e8 0e f6 ff ff       	call   800f44 <sys_getenvid>
  801936:	8b 55 0c             	mov    0xc(%ebp),%edx
  801939:	89 54 24 10          	mov    %edx,0x10(%esp)
  80193d:	8b 55 08             	mov    0x8(%ebp),%edx
  801940:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801944:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801948:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194c:	c7 04 24 28 22 80 00 	movl   $0x802228,(%esp)
  801953:	e8 15 e8 ff ff       	call   80016d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801958:	89 74 24 04          	mov    %esi,0x4(%esp)
  80195c:	8b 45 10             	mov    0x10(%ebp),%eax
  80195f:	89 04 24             	mov    %eax,(%esp)
  801962:	e8 a5 e7 ff ff       	call   80010c <vcprintf>
	cprintf("\n");
  801967:	c7 04 24 e4 21 80 00 	movl   $0x8021e4,(%esp)
  80196e:	e8 fa e7 ff ff       	call   80016d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801973:	cc                   	int3   
  801974:	eb fd                	jmp    801973 <_panic+0x53>
	...

00801980 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801980:	55                   	push   %ebp
  801981:	89 e5                	mov    %esp,%ebp
  801983:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801986:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80198c:	b8 01 00 00 00       	mov    $0x1,%eax
  801991:	39 ca                	cmp    %ecx,%edx
  801993:	75 04                	jne    801999 <ipc_find_env+0x19>
  801995:	b0 00                	mov    $0x0,%al
  801997:	eb 0f                	jmp    8019a8 <ipc_find_env+0x28>
  801999:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80199c:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  8019a2:	8b 12                	mov    (%edx),%edx
  8019a4:	39 ca                	cmp    %ecx,%edx
  8019a6:	75 0c                	jne    8019b4 <ipc_find_env+0x34>
			return envs[i].env_id;
  8019a8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8019ab:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  8019b0:	8b 00                	mov    (%eax),%eax
  8019b2:	eb 0e                	jmp    8019c2 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8019b4:	83 c0 01             	add    $0x1,%eax
  8019b7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8019bc:	75 db                	jne    801999 <ipc_find_env+0x19>
  8019be:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8019c2:	5d                   	pop    %ebp
  8019c3:	c3                   	ret    

008019c4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8019c4:	55                   	push   %ebp
  8019c5:	89 e5                	mov    %esp,%ebp
  8019c7:	57                   	push   %edi
  8019c8:	56                   	push   %esi
  8019c9:	53                   	push   %ebx
  8019ca:	83 ec 1c             	sub    $0x1c,%esp
  8019cd:	8b 75 08             	mov    0x8(%ebp),%esi
  8019d0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8019d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  8019d6:	85 db                	test   %ebx,%ebx
  8019d8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8019dd:	0f 44 d8             	cmove  %eax,%ebx
  8019e0:	eb 29                	jmp    801a0b <ipc_send+0x47>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
  8019e2:	85 c0                	test   %eax,%eax
  8019e4:	79 25                	jns    801a0b <ipc_send+0x47>
  8019e6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8019e9:	74 20                	je     801a0b <ipc_send+0x47>
			panic ("ipc: sys try send failed : %e", r);
  8019eb:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019ef:	c7 44 24 08 4c 22 80 	movl   $0x80224c,0x8(%esp)
  8019f6:	00 
  8019f7:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8019fe:	00 
  8019ff:	c7 04 24 6a 22 80 00 	movl   $0x80226a,(%esp)
  801a06:	e8 15 ff ff ff       	call   801920 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  801a0b:	8b 45 14             	mov    0x14(%ebp),%eax
  801a0e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801a12:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a16:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801a1a:	89 34 24             	mov    %esi,(%esp)
  801a1d:	e8 29 f3 ff ff       	call   800d4b <sys_ipc_try_send>
  801a22:	85 c0                	test   %eax,%eax
  801a24:	75 bc                	jne    8019e2 <ipc_send+0x1e>
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  801a26:	e8 a6 f4 ff ff       	call   800ed1 <sys_yield>
}
  801a2b:	83 c4 1c             	add    $0x1c,%esp
  801a2e:	5b                   	pop    %ebx
  801a2f:	5e                   	pop    %esi
  801a30:	5f                   	pop    %edi
  801a31:	5d                   	pop    %ebp
  801a32:	c3                   	ret    

00801a33 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a33:	55                   	push   %ebp
  801a34:	89 e5                	mov    %esp,%ebp
  801a36:	83 ec 28             	sub    $0x28,%esp
  801a39:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801a3c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801a3f:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801a42:	8b 75 08             	mov    0x8(%ebp),%esi
  801a45:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a48:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801a4b:	85 c0                	test   %eax,%eax
  801a4d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a52:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801a55:	89 04 24             	mov    %eax,(%esp)
  801a58:	e8 b5 f2 ff ff       	call   800d12 <sys_ipc_recv>
  801a5d:	89 c3                	mov    %eax,%ebx
  801a5f:	85 c0                	test   %eax,%eax
  801a61:	79 2a                	jns    801a8d <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  801a63:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a67:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a6b:	c7 04 24 74 22 80 00 	movl   $0x802274,(%esp)
  801a72:	e8 f6 e6 ff ff       	call   80016d <cprintf>
		if(from_env_store != NULL)
  801a77:	85 f6                	test   %esi,%esi
  801a79:	74 06                	je     801a81 <ipc_recv+0x4e>
			*from_env_store = 0;
  801a7b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801a81:	85 ff                	test   %edi,%edi
  801a83:	74 2d                	je     801ab2 <ipc_recv+0x7f>
			*perm_store = 0;
  801a85:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801a8b:	eb 25                	jmp    801ab2 <ipc_recv+0x7f>
		return r;
	}
	if(from_env_store != NULL)
  801a8d:	85 f6                	test   %esi,%esi
  801a8f:	90                   	nop
  801a90:	74 0a                	je     801a9c <ipc_recv+0x69>
		*from_env_store = thisenv->env_ipc_from;
  801a92:	a1 04 40 80 00       	mov    0x804004,%eax
  801a97:	8b 40 74             	mov    0x74(%eax),%eax
  801a9a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801a9c:	85 ff                	test   %edi,%edi
  801a9e:	74 0a                	je     801aaa <ipc_recv+0x77>
		*perm_store = thisenv->env_ipc_perm;
  801aa0:	a1 04 40 80 00       	mov    0x804004,%eax
  801aa5:	8b 40 78             	mov    0x78(%eax),%eax
  801aa8:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801aaa:	a1 04 40 80 00       	mov    0x804004,%eax
  801aaf:	8b 58 70             	mov    0x70(%eax),%ebx
}
  801ab2:	89 d8                	mov    %ebx,%eax
  801ab4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801ab7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801aba:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801abd:	89 ec                	mov    %ebp,%esp
  801abf:	5d                   	pop    %ebp
  801ac0:	c3                   	ret    
	...

00801ad0 <__udivdi3>:
  801ad0:	55                   	push   %ebp
  801ad1:	89 e5                	mov    %esp,%ebp
  801ad3:	57                   	push   %edi
  801ad4:	56                   	push   %esi
  801ad5:	83 ec 10             	sub    $0x10,%esp
  801ad8:	8b 45 14             	mov    0x14(%ebp),%eax
  801adb:	8b 55 08             	mov    0x8(%ebp),%edx
  801ade:	8b 75 10             	mov    0x10(%ebp),%esi
  801ae1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801ae4:	85 c0                	test   %eax,%eax
  801ae6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801ae9:	75 35                	jne    801b20 <__udivdi3+0x50>
  801aeb:	39 fe                	cmp    %edi,%esi
  801aed:	77 61                	ja     801b50 <__udivdi3+0x80>
  801aef:	85 f6                	test   %esi,%esi
  801af1:	75 0b                	jne    801afe <__udivdi3+0x2e>
  801af3:	b8 01 00 00 00       	mov    $0x1,%eax
  801af8:	31 d2                	xor    %edx,%edx
  801afa:	f7 f6                	div    %esi
  801afc:	89 c6                	mov    %eax,%esi
  801afe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801b01:	31 d2                	xor    %edx,%edx
  801b03:	89 f8                	mov    %edi,%eax
  801b05:	f7 f6                	div    %esi
  801b07:	89 c7                	mov    %eax,%edi
  801b09:	89 c8                	mov    %ecx,%eax
  801b0b:	f7 f6                	div    %esi
  801b0d:	89 c1                	mov    %eax,%ecx
  801b0f:	89 fa                	mov    %edi,%edx
  801b11:	89 c8                	mov    %ecx,%eax
  801b13:	83 c4 10             	add    $0x10,%esp
  801b16:	5e                   	pop    %esi
  801b17:	5f                   	pop    %edi
  801b18:	5d                   	pop    %ebp
  801b19:	c3                   	ret    
  801b1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801b20:	39 f8                	cmp    %edi,%eax
  801b22:	77 1c                	ja     801b40 <__udivdi3+0x70>
  801b24:	0f bd d0             	bsr    %eax,%edx
  801b27:	83 f2 1f             	xor    $0x1f,%edx
  801b2a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801b2d:	75 39                	jne    801b68 <__udivdi3+0x98>
  801b2f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801b32:	0f 86 a0 00 00 00    	jbe    801bd8 <__udivdi3+0x108>
  801b38:	39 f8                	cmp    %edi,%eax
  801b3a:	0f 82 98 00 00 00    	jb     801bd8 <__udivdi3+0x108>
  801b40:	31 ff                	xor    %edi,%edi
  801b42:	31 c9                	xor    %ecx,%ecx
  801b44:	89 c8                	mov    %ecx,%eax
  801b46:	89 fa                	mov    %edi,%edx
  801b48:	83 c4 10             	add    $0x10,%esp
  801b4b:	5e                   	pop    %esi
  801b4c:	5f                   	pop    %edi
  801b4d:	5d                   	pop    %ebp
  801b4e:	c3                   	ret    
  801b4f:	90                   	nop
  801b50:	89 d1                	mov    %edx,%ecx
  801b52:	89 fa                	mov    %edi,%edx
  801b54:	89 c8                	mov    %ecx,%eax
  801b56:	31 ff                	xor    %edi,%edi
  801b58:	f7 f6                	div    %esi
  801b5a:	89 c1                	mov    %eax,%ecx
  801b5c:	89 fa                	mov    %edi,%edx
  801b5e:	89 c8                	mov    %ecx,%eax
  801b60:	83 c4 10             	add    $0x10,%esp
  801b63:	5e                   	pop    %esi
  801b64:	5f                   	pop    %edi
  801b65:	5d                   	pop    %ebp
  801b66:	c3                   	ret    
  801b67:	90                   	nop
  801b68:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b6c:	89 f2                	mov    %esi,%edx
  801b6e:	d3 e0                	shl    %cl,%eax
  801b70:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b73:	b8 20 00 00 00       	mov    $0x20,%eax
  801b78:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801b7b:	89 c1                	mov    %eax,%ecx
  801b7d:	d3 ea                	shr    %cl,%edx
  801b7f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b83:	0b 55 ec             	or     -0x14(%ebp),%edx
  801b86:	d3 e6                	shl    %cl,%esi
  801b88:	89 c1                	mov    %eax,%ecx
  801b8a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801b8d:	89 fe                	mov    %edi,%esi
  801b8f:	d3 ee                	shr    %cl,%esi
  801b91:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b95:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801b98:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b9b:	d3 e7                	shl    %cl,%edi
  801b9d:	89 c1                	mov    %eax,%ecx
  801b9f:	d3 ea                	shr    %cl,%edx
  801ba1:	09 d7                	or     %edx,%edi
  801ba3:	89 f2                	mov    %esi,%edx
  801ba5:	89 f8                	mov    %edi,%eax
  801ba7:	f7 75 ec             	divl   -0x14(%ebp)
  801baa:	89 d6                	mov    %edx,%esi
  801bac:	89 c7                	mov    %eax,%edi
  801bae:	f7 65 e8             	mull   -0x18(%ebp)
  801bb1:	39 d6                	cmp    %edx,%esi
  801bb3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801bb6:	72 30                	jb     801be8 <__udivdi3+0x118>
  801bb8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801bbb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801bbf:	d3 e2                	shl    %cl,%edx
  801bc1:	39 c2                	cmp    %eax,%edx
  801bc3:	73 05                	jae    801bca <__udivdi3+0xfa>
  801bc5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801bc8:	74 1e                	je     801be8 <__udivdi3+0x118>
  801bca:	89 f9                	mov    %edi,%ecx
  801bcc:	31 ff                	xor    %edi,%edi
  801bce:	e9 71 ff ff ff       	jmp    801b44 <__udivdi3+0x74>
  801bd3:	90                   	nop
  801bd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801bd8:	31 ff                	xor    %edi,%edi
  801bda:	b9 01 00 00 00       	mov    $0x1,%ecx
  801bdf:	e9 60 ff ff ff       	jmp    801b44 <__udivdi3+0x74>
  801be4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801be8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801beb:	31 ff                	xor    %edi,%edi
  801bed:	89 c8                	mov    %ecx,%eax
  801bef:	89 fa                	mov    %edi,%edx
  801bf1:	83 c4 10             	add    $0x10,%esp
  801bf4:	5e                   	pop    %esi
  801bf5:	5f                   	pop    %edi
  801bf6:	5d                   	pop    %ebp
  801bf7:	c3                   	ret    
	...

00801c00 <__umoddi3>:
  801c00:	55                   	push   %ebp
  801c01:	89 e5                	mov    %esp,%ebp
  801c03:	57                   	push   %edi
  801c04:	56                   	push   %esi
  801c05:	83 ec 20             	sub    $0x20,%esp
  801c08:	8b 55 14             	mov    0x14(%ebp),%edx
  801c0b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c0e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801c11:	8b 75 0c             	mov    0xc(%ebp),%esi
  801c14:	85 d2                	test   %edx,%edx
  801c16:	89 c8                	mov    %ecx,%eax
  801c18:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801c1b:	75 13                	jne    801c30 <__umoddi3+0x30>
  801c1d:	39 f7                	cmp    %esi,%edi
  801c1f:	76 3f                	jbe    801c60 <__umoddi3+0x60>
  801c21:	89 f2                	mov    %esi,%edx
  801c23:	f7 f7                	div    %edi
  801c25:	89 d0                	mov    %edx,%eax
  801c27:	31 d2                	xor    %edx,%edx
  801c29:	83 c4 20             	add    $0x20,%esp
  801c2c:	5e                   	pop    %esi
  801c2d:	5f                   	pop    %edi
  801c2e:	5d                   	pop    %ebp
  801c2f:	c3                   	ret    
  801c30:	39 f2                	cmp    %esi,%edx
  801c32:	77 4c                	ja     801c80 <__umoddi3+0x80>
  801c34:	0f bd ca             	bsr    %edx,%ecx
  801c37:	83 f1 1f             	xor    $0x1f,%ecx
  801c3a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801c3d:	75 51                	jne    801c90 <__umoddi3+0x90>
  801c3f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801c42:	0f 87 e0 00 00 00    	ja     801d28 <__umoddi3+0x128>
  801c48:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c4b:	29 f8                	sub    %edi,%eax
  801c4d:	19 d6                	sbb    %edx,%esi
  801c4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801c52:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c55:	89 f2                	mov    %esi,%edx
  801c57:	83 c4 20             	add    $0x20,%esp
  801c5a:	5e                   	pop    %esi
  801c5b:	5f                   	pop    %edi
  801c5c:	5d                   	pop    %ebp
  801c5d:	c3                   	ret    
  801c5e:	66 90                	xchg   %ax,%ax
  801c60:	85 ff                	test   %edi,%edi
  801c62:	75 0b                	jne    801c6f <__umoddi3+0x6f>
  801c64:	b8 01 00 00 00       	mov    $0x1,%eax
  801c69:	31 d2                	xor    %edx,%edx
  801c6b:	f7 f7                	div    %edi
  801c6d:	89 c7                	mov    %eax,%edi
  801c6f:	89 f0                	mov    %esi,%eax
  801c71:	31 d2                	xor    %edx,%edx
  801c73:	f7 f7                	div    %edi
  801c75:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c78:	f7 f7                	div    %edi
  801c7a:	eb a9                	jmp    801c25 <__umoddi3+0x25>
  801c7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c80:	89 c8                	mov    %ecx,%eax
  801c82:	89 f2                	mov    %esi,%edx
  801c84:	83 c4 20             	add    $0x20,%esp
  801c87:	5e                   	pop    %esi
  801c88:	5f                   	pop    %edi
  801c89:	5d                   	pop    %ebp
  801c8a:	c3                   	ret    
  801c8b:	90                   	nop
  801c8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c90:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c94:	d3 e2                	shl    %cl,%edx
  801c96:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801c99:	ba 20 00 00 00       	mov    $0x20,%edx
  801c9e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801ca1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801ca4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801ca8:	89 fa                	mov    %edi,%edx
  801caa:	d3 ea                	shr    %cl,%edx
  801cac:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801cb0:	0b 55 f4             	or     -0xc(%ebp),%edx
  801cb3:	d3 e7                	shl    %cl,%edi
  801cb5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801cb9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801cbc:	89 f2                	mov    %esi,%edx
  801cbe:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801cc1:	89 c7                	mov    %eax,%edi
  801cc3:	d3 ea                	shr    %cl,%edx
  801cc5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801cc9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801ccc:	89 c2                	mov    %eax,%edx
  801cce:	d3 e6                	shl    %cl,%esi
  801cd0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801cd4:	d3 ea                	shr    %cl,%edx
  801cd6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801cda:	09 d6                	or     %edx,%esi
  801cdc:	89 f0                	mov    %esi,%eax
  801cde:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801ce1:	d3 e7                	shl    %cl,%edi
  801ce3:	89 f2                	mov    %esi,%edx
  801ce5:	f7 75 f4             	divl   -0xc(%ebp)
  801ce8:	89 d6                	mov    %edx,%esi
  801cea:	f7 65 e8             	mull   -0x18(%ebp)
  801ced:	39 d6                	cmp    %edx,%esi
  801cef:	72 2b                	jb     801d1c <__umoddi3+0x11c>
  801cf1:	39 c7                	cmp    %eax,%edi
  801cf3:	72 23                	jb     801d18 <__umoddi3+0x118>
  801cf5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801cf9:	29 c7                	sub    %eax,%edi
  801cfb:	19 d6                	sbb    %edx,%esi
  801cfd:	89 f0                	mov    %esi,%eax
  801cff:	89 f2                	mov    %esi,%edx
  801d01:	d3 ef                	shr    %cl,%edi
  801d03:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801d07:	d3 e0                	shl    %cl,%eax
  801d09:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801d0d:	09 f8                	or     %edi,%eax
  801d0f:	d3 ea                	shr    %cl,%edx
  801d11:	83 c4 20             	add    $0x20,%esp
  801d14:	5e                   	pop    %esi
  801d15:	5f                   	pop    %edi
  801d16:	5d                   	pop    %ebp
  801d17:	c3                   	ret    
  801d18:	39 d6                	cmp    %edx,%esi
  801d1a:	75 d9                	jne    801cf5 <__umoddi3+0xf5>
  801d1c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801d1f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801d22:	eb d1                	jmp    801cf5 <__umoddi3+0xf5>
  801d24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d28:	39 f2                	cmp    %esi,%edx
  801d2a:	0f 82 18 ff ff ff    	jb     801c48 <__umoddi3+0x48>
  801d30:	e9 1d ff ff ff       	jmp    801c52 <__umoddi3+0x52>
