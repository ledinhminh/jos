
obj/user/hello.debug:     file format elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	83 ec 18             	sub    $0x18,%esp
	cprintf("hello, world\n");
  80003a:	c7 04 24 00 1d 80 00 	movl   $0x801d00,(%esp)
  800041:	e8 e7 00 00 00       	call   80012d <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800046:	a1 04 40 80 00       	mov    0x804004,%eax
  80004b:	8b 40 48             	mov    0x48(%eax),%eax
  80004e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800052:	c7 04 24 0e 1d 80 00 	movl   $0x801d0e,(%esp)
  800059:	e8 cf 00 00 00       	call   80012d <cprintf>
}
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	83 ec 18             	sub    $0x18,%esp
  800066:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800069:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80006c:	8b 75 08             	mov    0x8(%ebp),%esi
  80006f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  800072:	e8 8d 0e 00 00       	call   800f04 <sys_getenvid>
  800077:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800084:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800089:	85 f6                	test   %esi,%esi
  80008b:	7e 07                	jle    800094 <libmain+0x34>
		binaryname = argv[0];
  80008d:	8b 03                	mov    (%ebx),%eax
  80008f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800094:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800098:	89 34 24             	mov    %esi,(%esp)
  80009b:	e8 94 ff ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  8000a0:	e8 0b 00 00 00       	call   8000b0 <exit>
}
  8000a5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000a8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000ab:	89 ec                	mov    %ebp,%esp
  8000ad:	5d                   	pop    %ebp
  8000ae:	c3                   	ret    
	...

008000b0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b0:	55                   	push   %ebp
  8000b1:	89 e5                	mov    %esp,%ebp
  8000b3:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8000b6:	e8 1e 14 00 00       	call   8014d9 <close_all>
	sys_env_destroy(0);
  8000bb:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000c2:	e8 78 0e 00 00       	call   800f3f <sys_env_destroy>
}
  8000c7:	c9                   	leave  
  8000c8:	c3                   	ret    
  8000c9:	00 00                	add    %al,(%eax)
	...

008000cc <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000d5:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000dc:	00 00 00 
	b.cnt = 0;
  8000df:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000e6:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000ec:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8000f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000f7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8000fd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800101:	c7 04 24 47 01 80 00 	movl   $0x800147,(%esp)
  800108:	e8 d0 01 00 00       	call   8002dd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80010d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800113:	89 44 24 04          	mov    %eax,0x4(%esp)
  800117:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80011d:	89 04 24             	mov    %eax,(%esp)
  800120:	e8 8e 0e 00 00       	call   800fb3 <sys_cputs>

	return b.cnt;
}
  800125:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80012b:	c9                   	leave  
  80012c:	c3                   	ret    

0080012d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80012d:	55                   	push   %ebp
  80012e:	89 e5                	mov    %esp,%ebp
  800130:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800133:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800136:	89 44 24 04          	mov    %eax,0x4(%esp)
  80013a:	8b 45 08             	mov    0x8(%ebp),%eax
  80013d:	89 04 24             	mov    %eax,(%esp)
  800140:	e8 87 ff ff ff       	call   8000cc <vcprintf>
	va_end(ap);

	return cnt;
}
  800145:	c9                   	leave  
  800146:	c3                   	ret    

00800147 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800147:	55                   	push   %ebp
  800148:	89 e5                	mov    %esp,%ebp
  80014a:	53                   	push   %ebx
  80014b:	83 ec 14             	sub    $0x14,%esp
  80014e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800151:	8b 03                	mov    (%ebx),%eax
  800153:	8b 55 08             	mov    0x8(%ebp),%edx
  800156:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80015a:	83 c0 01             	add    $0x1,%eax
  80015d:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80015f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800164:	75 19                	jne    80017f <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800166:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80016d:	00 
  80016e:	8d 43 08             	lea    0x8(%ebx),%eax
  800171:	89 04 24             	mov    %eax,(%esp)
  800174:	e8 3a 0e 00 00       	call   800fb3 <sys_cputs>
		b->idx = 0;
  800179:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80017f:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800183:	83 c4 14             	add    $0x14,%esp
  800186:	5b                   	pop    %ebx
  800187:	5d                   	pop    %ebp
  800188:	c3                   	ret    
  800189:	00 00                	add    %al,(%eax)
  80018b:	00 00                	add    %al,(%eax)
  80018d:	00 00                	add    %al,(%eax)
	...

00800190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 4c             	sub    $0x4c,%esp
  800199:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80019c:	89 d6                	mov    %edx,%esi
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001b0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001bb:	39 d1                	cmp    %edx,%ecx
  8001bd:	72 15                	jb     8001d4 <printnum+0x44>
  8001bf:	77 07                	ja     8001c8 <printnum+0x38>
  8001c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001c4:	39 d0                	cmp    %edx,%eax
  8001c6:	76 0c                	jbe    8001d4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c8:	83 eb 01             	sub    $0x1,%ebx
  8001cb:	85 db                	test   %ebx,%ebx
  8001cd:	8d 76 00             	lea    0x0(%esi),%esi
  8001d0:	7f 61                	jg     800233 <printnum+0xa3>
  8001d2:	eb 70                	jmp    800244 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001d8:	83 eb 01             	sub    $0x1,%ebx
  8001db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8001e7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8001eb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8001ee:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8001f1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8001f4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001ff:	00 
  800200:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800203:	89 04 24             	mov    %eax,(%esp)
  800206:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800209:	89 54 24 04          	mov    %edx,0x4(%esp)
  80020d:	e8 7e 18 00 00       	call   801a90 <__udivdi3>
  800212:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800215:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800218:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80021c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800220:	89 04 24             	mov    %eax,(%esp)
  800223:	89 54 24 04          	mov    %edx,0x4(%esp)
  800227:	89 f2                	mov    %esi,%edx
  800229:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80022c:	e8 5f ff ff ff       	call   800190 <printnum>
  800231:	eb 11                	jmp    800244 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800233:	89 74 24 04          	mov    %esi,0x4(%esp)
  800237:	89 3c 24             	mov    %edi,(%esp)
  80023a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023d:	83 eb 01             	sub    $0x1,%ebx
  800240:	85 db                	test   %ebx,%ebx
  800242:	7f ef                	jg     800233 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800244:	89 74 24 04          	mov    %esi,0x4(%esp)
  800248:	8b 74 24 04          	mov    0x4(%esp),%esi
  80024c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80024f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800253:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80025a:	00 
  80025b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80025e:	89 14 24             	mov    %edx,(%esp)
  800261:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800264:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800268:	e8 53 19 00 00       	call   801bc0 <__umoddi3>
  80026d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800271:	0f be 80 2f 1d 80 00 	movsbl 0x801d2f(%eax),%eax
  800278:	89 04 24             	mov    %eax,(%esp)
  80027b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80027e:	83 c4 4c             	add    $0x4c,%esp
  800281:	5b                   	pop    %ebx
  800282:	5e                   	pop    %esi
  800283:	5f                   	pop    %edi
  800284:	5d                   	pop    %ebp
  800285:	c3                   	ret    

00800286 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800289:	83 fa 01             	cmp    $0x1,%edx
  80028c:	7e 0e                	jle    80029c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80028e:	8b 10                	mov    (%eax),%edx
  800290:	8d 4a 08             	lea    0x8(%edx),%ecx
  800293:	89 08                	mov    %ecx,(%eax)
  800295:	8b 02                	mov    (%edx),%eax
  800297:	8b 52 04             	mov    0x4(%edx),%edx
  80029a:	eb 22                	jmp    8002be <getuint+0x38>
	else if (lflag)
  80029c:	85 d2                	test   %edx,%edx
  80029e:	74 10                	je     8002b0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002a0:	8b 10                	mov    (%eax),%edx
  8002a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a5:	89 08                	mov    %ecx,(%eax)
  8002a7:	8b 02                	mov    (%edx),%eax
  8002a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ae:	eb 0e                	jmp    8002be <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002b0:	8b 10                	mov    (%eax),%edx
  8002b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b5:	89 08                	mov    %ecx,(%eax)
  8002b7:	8b 02                	mov    (%edx),%eax
  8002b9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002be:	5d                   	pop    %ebp
  8002bf:	c3                   	ret    

008002c0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ca:	8b 10                	mov    (%eax),%edx
  8002cc:	3b 50 04             	cmp    0x4(%eax),%edx
  8002cf:	73 0a                	jae    8002db <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d4:	88 0a                	mov    %cl,(%edx)
  8002d6:	83 c2 01             	add    $0x1,%edx
  8002d9:	89 10                	mov    %edx,(%eax)
}
  8002db:	5d                   	pop    %ebp
  8002dc:	c3                   	ret    

008002dd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002dd:	55                   	push   %ebp
  8002de:	89 e5                	mov    %esp,%ebp
  8002e0:	57                   	push   %edi
  8002e1:	56                   	push   %esi
  8002e2:	53                   	push   %ebx
  8002e3:	83 ec 5c             	sub    $0x5c,%esp
  8002e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002e9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8002ef:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002f6:	eb 11                	jmp    800309 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f8:	85 c0                	test   %eax,%eax
  8002fa:	0f 84 68 04 00 00    	je     800768 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  800300:	89 74 24 04          	mov    %esi,0x4(%esp)
  800304:	89 04 24             	mov    %eax,(%esp)
  800307:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800309:	0f b6 03             	movzbl (%ebx),%eax
  80030c:	83 c3 01             	add    $0x1,%ebx
  80030f:	83 f8 25             	cmp    $0x25,%eax
  800312:	75 e4                	jne    8002f8 <vprintfmt+0x1b>
  800314:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80031b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800322:	b9 00 00 00 00       	mov    $0x0,%ecx
  800327:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  80032b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800332:	eb 06                	jmp    80033a <vprintfmt+0x5d>
  800334:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  800338:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	0f b6 13             	movzbl (%ebx),%edx
  80033d:	0f b6 c2             	movzbl %dl,%eax
  800340:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800343:	8d 43 01             	lea    0x1(%ebx),%eax
  800346:	83 ea 23             	sub    $0x23,%edx
  800349:	80 fa 55             	cmp    $0x55,%dl
  80034c:	0f 87 f9 03 00 00    	ja     80074b <vprintfmt+0x46e>
  800352:	0f b6 d2             	movzbl %dl,%edx
  800355:	ff 24 95 00 1f 80 00 	jmp    *0x801f00(,%edx,4)
  80035c:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800360:	eb d6                	jmp    800338 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800362:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800365:	83 ea 30             	sub    $0x30,%edx
  800368:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80036b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80036e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800371:	83 fb 09             	cmp    $0x9,%ebx
  800374:	77 54                	ja     8003ca <vprintfmt+0xed>
  800376:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800379:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80037c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80037f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800382:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800386:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800389:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80038c:	83 fb 09             	cmp    $0x9,%ebx
  80038f:	76 eb                	jbe    80037c <vprintfmt+0x9f>
  800391:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800394:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800397:	eb 31                	jmp    8003ca <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800399:	8b 55 14             	mov    0x14(%ebp),%edx
  80039c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80039f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8003a2:	8b 12                	mov    (%edx),%edx
  8003a4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8003a7:	eb 21                	jmp    8003ca <vprintfmt+0xed>

		case '.':
			if (width < 0)
  8003a9:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b2:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  8003b6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003b9:	e9 7a ff ff ff       	jmp    800338 <vprintfmt+0x5b>
  8003be:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003c5:	e9 6e ff ff ff       	jmp    800338 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8003ca:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8003ce:	0f 89 64 ff ff ff    	jns    800338 <vprintfmt+0x5b>
  8003d4:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8003d7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8003da:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8003dd:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8003e0:	e9 53 ff ff ff       	jmp    800338 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e5:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8003e8:	e9 4b ff ff ff       	jmp    800338 <vprintfmt+0x5b>
  8003ed:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f3:	8d 50 04             	lea    0x4(%eax),%edx
  8003f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003fd:	8b 00                	mov    (%eax),%eax
  8003ff:	89 04 24             	mov    %eax,(%esp)
  800402:	ff d7                	call   *%edi
  800404:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800407:	e9 fd fe ff ff       	jmp    800309 <vprintfmt+0x2c>
  80040c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040f:	8b 45 14             	mov    0x14(%ebp),%eax
  800412:	8d 50 04             	lea    0x4(%eax),%edx
  800415:	89 55 14             	mov    %edx,0x14(%ebp)
  800418:	8b 00                	mov    (%eax),%eax
  80041a:	89 c2                	mov    %eax,%edx
  80041c:	c1 fa 1f             	sar    $0x1f,%edx
  80041f:	31 d0                	xor    %edx,%eax
  800421:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800423:	83 f8 0f             	cmp    $0xf,%eax
  800426:	7f 0b                	jg     800433 <vprintfmt+0x156>
  800428:	8b 14 85 60 20 80 00 	mov    0x802060(,%eax,4),%edx
  80042f:	85 d2                	test   %edx,%edx
  800431:	75 20                	jne    800453 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800433:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800437:	c7 44 24 08 40 1d 80 	movl   $0x801d40,0x8(%esp)
  80043e:	00 
  80043f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800443:	89 3c 24             	mov    %edi,(%esp)
  800446:	e8 a5 03 00 00       	call   8007f0 <printfmt>
  80044b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044e:	e9 b6 fe ff ff       	jmp    800309 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800453:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800457:	c7 44 24 08 77 21 80 	movl   $0x802177,0x8(%esp)
  80045e:	00 
  80045f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800463:	89 3c 24             	mov    %edi,(%esp)
  800466:	e8 85 03 00 00       	call   8007f0 <printfmt>
  80046b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80046e:	e9 96 fe ff ff       	jmp    800309 <vprintfmt+0x2c>
  800473:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800476:	89 c3                	mov    %eax,%ebx
  800478:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80047b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80047e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800481:	8b 45 14             	mov    0x14(%ebp),%eax
  800484:	8d 50 04             	lea    0x4(%eax),%edx
  800487:	89 55 14             	mov    %edx,0x14(%ebp)
  80048a:	8b 00                	mov    (%eax),%eax
  80048c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80048f:	85 c0                	test   %eax,%eax
  800491:	b8 49 1d 80 00       	mov    $0x801d49,%eax
  800496:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  80049a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80049d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  8004a1:	7e 06                	jle    8004a9 <vprintfmt+0x1cc>
  8004a3:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  8004a7:	75 13                	jne    8004bc <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8004ac:	0f be 02             	movsbl (%edx),%eax
  8004af:	85 c0                	test   %eax,%eax
  8004b1:	0f 85 a2 00 00 00    	jne    800559 <vprintfmt+0x27c>
  8004b7:	e9 8f 00 00 00       	jmp    80054b <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004c0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004c3:	89 0c 24             	mov    %ecx,(%esp)
  8004c6:	e8 70 03 00 00       	call   80083b <strnlen>
  8004cb:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004ce:	29 c2                	sub    %eax,%edx
  8004d0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004d3:	85 d2                	test   %edx,%edx
  8004d5:	7e d2                	jle    8004a9 <vprintfmt+0x1cc>
					putch(padc, putdat);
  8004d7:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8004db:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004de:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  8004e1:	89 d3                	mov    %edx,%ebx
  8004e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004ea:	89 04 24             	mov    %eax,(%esp)
  8004ed:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ef:	83 eb 01             	sub    $0x1,%ebx
  8004f2:	85 db                	test   %ebx,%ebx
  8004f4:	7f ed                	jg     8004e3 <vprintfmt+0x206>
  8004f6:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8004f9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  800500:	eb a7                	jmp    8004a9 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800502:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800506:	74 1b                	je     800523 <vprintfmt+0x246>
  800508:	8d 50 e0             	lea    -0x20(%eax),%edx
  80050b:	83 fa 5e             	cmp    $0x5e,%edx
  80050e:	76 13                	jbe    800523 <vprintfmt+0x246>
					putch('?', putdat);
  800510:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800513:	89 54 24 04          	mov    %edx,0x4(%esp)
  800517:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80051e:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800521:	eb 0d                	jmp    800530 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800523:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800526:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80052a:	89 04 24             	mov    %eax,(%esp)
  80052d:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800530:	83 ef 01             	sub    $0x1,%edi
  800533:	0f be 03             	movsbl (%ebx),%eax
  800536:	85 c0                	test   %eax,%eax
  800538:	74 05                	je     80053f <vprintfmt+0x262>
  80053a:	83 c3 01             	add    $0x1,%ebx
  80053d:	eb 31                	jmp    800570 <vprintfmt+0x293>
  80053f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800542:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800545:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800548:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80054b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80054f:	7f 36                	jg     800587 <vprintfmt+0x2aa>
  800551:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800554:	e9 b0 fd ff ff       	jmp    800309 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800559:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80055c:	83 c2 01             	add    $0x1,%edx
  80055f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800562:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800565:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800568:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80056b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80056e:	89 d3                	mov    %edx,%ebx
  800570:	85 f6                	test   %esi,%esi
  800572:	78 8e                	js     800502 <vprintfmt+0x225>
  800574:	83 ee 01             	sub    $0x1,%esi
  800577:	79 89                	jns    800502 <vprintfmt+0x225>
  800579:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80057c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80057f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800582:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800585:	eb c4                	jmp    80054b <vprintfmt+0x26e>
  800587:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80058a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80058d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800591:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800598:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80059a:	83 eb 01             	sub    $0x1,%ebx
  80059d:	85 db                	test   %ebx,%ebx
  80059f:	7f ec                	jg     80058d <vprintfmt+0x2b0>
  8005a1:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  8005a4:	e9 60 fd ff ff       	jmp    800309 <vprintfmt+0x2c>
  8005a9:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005ac:	83 f9 01             	cmp    $0x1,%ecx
  8005af:	7e 16                	jle    8005c7 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	8d 50 08             	lea    0x8(%eax),%edx
  8005b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ba:	8b 10                	mov    (%eax),%edx
  8005bc:	8b 48 04             	mov    0x4(%eax),%ecx
  8005bf:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8005c2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005c5:	eb 32                	jmp    8005f9 <vprintfmt+0x31c>
	else if (lflag)
  8005c7:	85 c9                	test   %ecx,%ecx
  8005c9:	74 18                	je     8005e3 <vprintfmt+0x306>
		return va_arg(*ap, long);
  8005cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ce:	8d 50 04             	lea    0x4(%eax),%edx
  8005d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8005d4:	8b 00                	mov    (%eax),%eax
  8005d6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005d9:	89 c1                	mov    %eax,%ecx
  8005db:	c1 f9 1f             	sar    $0x1f,%ecx
  8005de:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005e1:	eb 16                	jmp    8005f9 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  8005e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e6:	8d 50 04             	lea    0x4(%eax),%edx
  8005e9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ec:	8b 00                	mov    (%eax),%eax
  8005ee:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005f1:	89 c2                	mov    %eax,%edx
  8005f3:	c1 fa 1f             	sar    $0x1f,%edx
  8005f6:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005f9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005fc:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8005ff:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  800604:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800608:	0f 89 8a 00 00 00    	jns    800698 <vprintfmt+0x3bb>
				putch('-', putdat);
  80060e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800612:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800619:	ff d7                	call   *%edi
				num = -(long long) num;
  80061b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80061e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800621:	f7 d8                	neg    %eax
  800623:	83 d2 00             	adc    $0x0,%edx
  800626:	f7 da                	neg    %edx
  800628:	eb 6e                	jmp    800698 <vprintfmt+0x3bb>
  80062a:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80062d:	89 ca                	mov    %ecx,%edx
  80062f:	8d 45 14             	lea    0x14(%ebp),%eax
  800632:	e8 4f fc ff ff       	call   800286 <getuint>
  800637:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  80063c:	eb 5a                	jmp    800698 <vprintfmt+0x3bb>
  80063e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800641:	89 ca                	mov    %ecx,%edx
  800643:	8d 45 14             	lea    0x14(%ebp),%eax
  800646:	e8 3b fc ff ff       	call   800286 <getuint>
  80064b:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  800650:	eb 46                	jmp    800698 <vprintfmt+0x3bb>
  800652:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  800655:	89 74 24 04          	mov    %esi,0x4(%esp)
  800659:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800660:	ff d7                	call   *%edi
			putch('x', putdat);
  800662:	89 74 24 04          	mov    %esi,0x4(%esp)
  800666:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80066d:	ff d7                	call   *%edi
			num = (unsigned long long)
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8d 50 04             	lea    0x4(%eax),%edx
  800675:	89 55 14             	mov    %edx,0x14(%ebp)
  800678:	8b 00                	mov    (%eax),%eax
  80067a:	ba 00 00 00 00       	mov    $0x0,%edx
  80067f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800684:	eb 12                	jmp    800698 <vprintfmt+0x3bb>
  800686:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800689:	89 ca                	mov    %ecx,%edx
  80068b:	8d 45 14             	lea    0x14(%ebp),%eax
  80068e:	e8 f3 fb ff ff       	call   800286 <getuint>
  800693:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800698:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80069c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8006a0:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  8006a3:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8006a7:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8006ab:	89 04 24             	mov    %eax,(%esp)
  8006ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8006b2:	89 f2                	mov    %esi,%edx
  8006b4:	89 f8                	mov    %edi,%eax
  8006b6:	e8 d5 fa ff ff       	call   800190 <printnum>
  8006bb:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8006be:	e9 46 fc ff ff       	jmp    800309 <vprintfmt+0x2c>
  8006c3:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  8006c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c9:	8d 50 04             	lea    0x4(%eax),%edx
  8006cc:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cf:	8b 00                	mov    (%eax),%eax
  8006d1:	85 c0                	test   %eax,%eax
  8006d3:	75 24                	jne    8006f9 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  8006d5:	c7 44 24 0c 64 1e 80 	movl   $0x801e64,0xc(%esp)
  8006dc:	00 
  8006dd:	c7 44 24 08 77 21 80 	movl   $0x802177,0x8(%esp)
  8006e4:	00 
  8006e5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006e9:	89 3c 24             	mov    %edi,(%esp)
  8006ec:	e8 ff 00 00 00       	call   8007f0 <printfmt>
  8006f1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8006f4:	e9 10 fc ff ff       	jmp    800309 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  8006f9:	83 3e 7f             	cmpl   $0x7f,(%esi)
  8006fc:	7e 29                	jle    800727 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  8006fe:	0f b6 16             	movzbl (%esi),%edx
  800701:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  800703:	c7 44 24 0c 9c 1e 80 	movl   $0x801e9c,0xc(%esp)
  80070a:	00 
  80070b:	c7 44 24 08 77 21 80 	movl   $0x802177,0x8(%esp)
  800712:	00 
  800713:	89 74 24 04          	mov    %esi,0x4(%esp)
  800717:	89 3c 24             	mov    %edi,(%esp)
  80071a:	e8 d1 00 00 00       	call   8007f0 <printfmt>
  80071f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800722:	e9 e2 fb ff ff       	jmp    800309 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  800727:	0f b6 16             	movzbl (%esi),%edx
  80072a:	88 10                	mov    %dl,(%eax)
  80072c:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  80072f:	e9 d5 fb ff ff       	jmp    800309 <vprintfmt+0x2c>
  800734:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800737:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80073a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80073e:	89 14 24             	mov    %edx,(%esp)
  800741:	ff d7                	call   *%edi
  800743:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800746:	e9 be fb ff ff       	jmp    800309 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80074b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80074f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800756:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800758:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80075b:	80 38 25             	cmpb   $0x25,(%eax)
  80075e:	0f 84 a5 fb ff ff    	je     800309 <vprintfmt+0x2c>
  800764:	89 c3                	mov    %eax,%ebx
  800766:	eb f0                	jmp    800758 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  800768:	83 c4 5c             	add    $0x5c,%esp
  80076b:	5b                   	pop    %ebx
  80076c:	5e                   	pop    %esi
  80076d:	5f                   	pop    %edi
  80076e:	5d                   	pop    %ebp
  80076f:	c3                   	ret    

00800770 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800770:	55                   	push   %ebp
  800771:	89 e5                	mov    %esp,%ebp
  800773:	83 ec 28             	sub    $0x28,%esp
  800776:	8b 45 08             	mov    0x8(%ebp),%eax
  800779:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80077c:	85 c0                	test   %eax,%eax
  80077e:	74 04                	je     800784 <vsnprintf+0x14>
  800780:	85 d2                	test   %edx,%edx
  800782:	7f 07                	jg     80078b <vsnprintf+0x1b>
  800784:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800789:	eb 3b                	jmp    8007c6 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80078b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80078e:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800792:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800795:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80079c:	8b 45 14             	mov    0x14(%ebp),%eax
  80079f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8007a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007aa:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b1:	c7 04 24 c0 02 80 00 	movl   $0x8002c0,(%esp)
  8007b8:	e8 20 fb ff ff       	call   8002dd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007bd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007c0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007c6:	c9                   	leave  
  8007c7:	c3                   	ret    

008007c8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c8:	55                   	push   %ebp
  8007c9:	89 e5                	mov    %esp,%ebp
  8007cb:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8007ce:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8007d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007d5:	8b 45 10             	mov    0x10(%ebp),%eax
  8007d8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8007e6:	89 04 24             	mov    %eax,(%esp)
  8007e9:	e8 82 ff ff ff       	call   800770 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ee:	c9                   	leave  
  8007ef:	c3                   	ret    

008007f0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007f0:	55                   	push   %ebp
  8007f1:	89 e5                	mov    %esp,%ebp
  8007f3:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8007f6:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8007f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007fd:	8b 45 10             	mov    0x10(%ebp),%eax
  800800:	89 44 24 08          	mov    %eax,0x8(%esp)
  800804:	8b 45 0c             	mov    0xc(%ebp),%eax
  800807:	89 44 24 04          	mov    %eax,0x4(%esp)
  80080b:	8b 45 08             	mov    0x8(%ebp),%eax
  80080e:	89 04 24             	mov    %eax,(%esp)
  800811:	e8 c7 fa ff ff       	call   8002dd <vprintfmt>
	va_end(ap);
}
  800816:	c9                   	leave  
  800817:	c3                   	ret    
	...

00800820 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800820:	55                   	push   %ebp
  800821:	89 e5                	mov    %esp,%ebp
  800823:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800826:	b8 00 00 00 00       	mov    $0x0,%eax
  80082b:	80 3a 00             	cmpb   $0x0,(%edx)
  80082e:	74 09                	je     800839 <strlen+0x19>
		n++;
  800830:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800833:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800837:	75 f7                	jne    800830 <strlen+0x10>
		n++;
	return n;
}
  800839:	5d                   	pop    %ebp
  80083a:	c3                   	ret    

0080083b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80083b:	55                   	push   %ebp
  80083c:	89 e5                	mov    %esp,%ebp
  80083e:	53                   	push   %ebx
  80083f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800842:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800845:	85 c9                	test   %ecx,%ecx
  800847:	74 19                	je     800862 <strnlen+0x27>
  800849:	80 3b 00             	cmpb   $0x0,(%ebx)
  80084c:	74 14                	je     800862 <strnlen+0x27>
  80084e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800853:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800856:	39 c8                	cmp    %ecx,%eax
  800858:	74 0d                	je     800867 <strnlen+0x2c>
  80085a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80085e:	75 f3                	jne    800853 <strnlen+0x18>
  800860:	eb 05                	jmp    800867 <strnlen+0x2c>
  800862:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800867:	5b                   	pop    %ebx
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	53                   	push   %ebx
  80086e:	8b 45 08             	mov    0x8(%ebp),%eax
  800871:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800874:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800879:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80087d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800880:	83 c2 01             	add    $0x1,%edx
  800883:	84 c9                	test   %cl,%cl
  800885:	75 f2                	jne    800879 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800887:	5b                   	pop    %ebx
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	53                   	push   %ebx
  80088e:	83 ec 08             	sub    $0x8,%esp
  800891:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800894:	89 1c 24             	mov    %ebx,(%esp)
  800897:	e8 84 ff ff ff       	call   800820 <strlen>
	strcpy(dst + len, src);
  80089c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089f:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008a3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8008a6:	89 04 24             	mov    %eax,(%esp)
  8008a9:	e8 bc ff ff ff       	call   80086a <strcpy>
	return dst;
}
  8008ae:	89 d8                	mov    %ebx,%eax
  8008b0:	83 c4 08             	add    $0x8,%esp
  8008b3:	5b                   	pop    %ebx
  8008b4:	5d                   	pop    %ebp
  8008b5:	c3                   	ret    

008008b6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	56                   	push   %esi
  8008ba:	53                   	push   %ebx
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008c1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c4:	85 f6                	test   %esi,%esi
  8008c6:	74 18                	je     8008e0 <strncpy+0x2a>
  8008c8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008cd:	0f b6 1a             	movzbl (%edx),%ebx
  8008d0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008d3:	80 3a 01             	cmpb   $0x1,(%edx)
  8008d6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d9:	83 c1 01             	add    $0x1,%ecx
  8008dc:	39 ce                	cmp    %ecx,%esi
  8008de:	77 ed                	ja     8008cd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008e0:	5b                   	pop    %ebx
  8008e1:	5e                   	pop    %esi
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
  8008e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ef:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008f2:	89 f0                	mov    %esi,%eax
  8008f4:	85 c9                	test   %ecx,%ecx
  8008f6:	74 27                	je     80091f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8008f8:	83 e9 01             	sub    $0x1,%ecx
  8008fb:	74 1d                	je     80091a <strlcpy+0x36>
  8008fd:	0f b6 1a             	movzbl (%edx),%ebx
  800900:	84 db                	test   %bl,%bl
  800902:	74 16                	je     80091a <strlcpy+0x36>
			*dst++ = *src++;
  800904:	88 18                	mov    %bl,(%eax)
  800906:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800909:	83 e9 01             	sub    $0x1,%ecx
  80090c:	74 0e                	je     80091c <strlcpy+0x38>
			*dst++ = *src++;
  80090e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800911:	0f b6 1a             	movzbl (%edx),%ebx
  800914:	84 db                	test   %bl,%bl
  800916:	75 ec                	jne    800904 <strlcpy+0x20>
  800918:	eb 02                	jmp    80091c <strlcpy+0x38>
  80091a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80091c:	c6 00 00             	movb   $0x0,(%eax)
  80091f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800921:	5b                   	pop    %ebx
  800922:	5e                   	pop    %esi
  800923:	5d                   	pop    %ebp
  800924:	c3                   	ret    

00800925 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800925:	55                   	push   %ebp
  800926:	89 e5                	mov    %esp,%ebp
  800928:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80092b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80092e:	0f b6 01             	movzbl (%ecx),%eax
  800931:	84 c0                	test   %al,%al
  800933:	74 15                	je     80094a <strcmp+0x25>
  800935:	3a 02                	cmp    (%edx),%al
  800937:	75 11                	jne    80094a <strcmp+0x25>
		p++, q++;
  800939:	83 c1 01             	add    $0x1,%ecx
  80093c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80093f:	0f b6 01             	movzbl (%ecx),%eax
  800942:	84 c0                	test   %al,%al
  800944:	74 04                	je     80094a <strcmp+0x25>
  800946:	3a 02                	cmp    (%edx),%al
  800948:	74 ef                	je     800939 <strcmp+0x14>
  80094a:	0f b6 c0             	movzbl %al,%eax
  80094d:	0f b6 12             	movzbl (%edx),%edx
  800950:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800952:	5d                   	pop    %ebp
  800953:	c3                   	ret    

00800954 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	53                   	push   %ebx
  800958:	8b 55 08             	mov    0x8(%ebp),%edx
  80095b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80095e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800961:	85 c0                	test   %eax,%eax
  800963:	74 23                	je     800988 <strncmp+0x34>
  800965:	0f b6 1a             	movzbl (%edx),%ebx
  800968:	84 db                	test   %bl,%bl
  80096a:	74 25                	je     800991 <strncmp+0x3d>
  80096c:	3a 19                	cmp    (%ecx),%bl
  80096e:	75 21                	jne    800991 <strncmp+0x3d>
  800970:	83 e8 01             	sub    $0x1,%eax
  800973:	74 13                	je     800988 <strncmp+0x34>
		n--, p++, q++;
  800975:	83 c2 01             	add    $0x1,%edx
  800978:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80097b:	0f b6 1a             	movzbl (%edx),%ebx
  80097e:	84 db                	test   %bl,%bl
  800980:	74 0f                	je     800991 <strncmp+0x3d>
  800982:	3a 19                	cmp    (%ecx),%bl
  800984:	74 ea                	je     800970 <strncmp+0x1c>
  800986:	eb 09                	jmp    800991 <strncmp+0x3d>
  800988:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80098d:	5b                   	pop    %ebx
  80098e:	5d                   	pop    %ebp
  80098f:	90                   	nop
  800990:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800991:	0f b6 02             	movzbl (%edx),%eax
  800994:	0f b6 11             	movzbl (%ecx),%edx
  800997:	29 d0                	sub    %edx,%eax
  800999:	eb f2                	jmp    80098d <strncmp+0x39>

0080099b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009a5:	0f b6 10             	movzbl (%eax),%edx
  8009a8:	84 d2                	test   %dl,%dl
  8009aa:	74 18                	je     8009c4 <strchr+0x29>
		if (*s == c)
  8009ac:	38 ca                	cmp    %cl,%dl
  8009ae:	75 0a                	jne    8009ba <strchr+0x1f>
  8009b0:	eb 17                	jmp    8009c9 <strchr+0x2e>
  8009b2:	38 ca                	cmp    %cl,%dl
  8009b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009b8:	74 0f                	je     8009c9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ba:	83 c0 01             	add    $0x1,%eax
  8009bd:	0f b6 10             	movzbl (%eax),%edx
  8009c0:	84 d2                	test   %dl,%dl
  8009c2:	75 ee                	jne    8009b2 <strchr+0x17>
  8009c4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8009c9:	5d                   	pop    %ebp
  8009ca:	c3                   	ret    

008009cb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009d5:	0f b6 10             	movzbl (%eax),%edx
  8009d8:	84 d2                	test   %dl,%dl
  8009da:	74 18                	je     8009f4 <strfind+0x29>
		if (*s == c)
  8009dc:	38 ca                	cmp    %cl,%dl
  8009de:	75 0a                	jne    8009ea <strfind+0x1f>
  8009e0:	eb 12                	jmp    8009f4 <strfind+0x29>
  8009e2:	38 ca                	cmp    %cl,%dl
  8009e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009e8:	74 0a                	je     8009f4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009ea:	83 c0 01             	add    $0x1,%eax
  8009ed:	0f b6 10             	movzbl (%eax),%edx
  8009f0:	84 d2                	test   %dl,%dl
  8009f2:	75 ee                	jne    8009e2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8009f4:	5d                   	pop    %ebp
  8009f5:	c3                   	ret    

008009f6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009f6:	55                   	push   %ebp
  8009f7:	89 e5                	mov    %esp,%ebp
  8009f9:	83 ec 0c             	sub    $0xc,%esp
  8009fc:	89 1c 24             	mov    %ebx,(%esp)
  8009ff:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a03:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a07:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a10:	85 c9                	test   %ecx,%ecx
  800a12:	74 30                	je     800a44 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a14:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a1a:	75 25                	jne    800a41 <memset+0x4b>
  800a1c:	f6 c1 03             	test   $0x3,%cl
  800a1f:	75 20                	jne    800a41 <memset+0x4b>
		c &= 0xFF;
  800a21:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a24:	89 d3                	mov    %edx,%ebx
  800a26:	c1 e3 08             	shl    $0x8,%ebx
  800a29:	89 d6                	mov    %edx,%esi
  800a2b:	c1 e6 18             	shl    $0x18,%esi
  800a2e:	89 d0                	mov    %edx,%eax
  800a30:	c1 e0 10             	shl    $0x10,%eax
  800a33:	09 f0                	or     %esi,%eax
  800a35:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800a37:	09 d8                	or     %ebx,%eax
  800a39:	c1 e9 02             	shr    $0x2,%ecx
  800a3c:	fc                   	cld    
  800a3d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a3f:	eb 03                	jmp    800a44 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a41:	fc                   	cld    
  800a42:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a44:	89 f8                	mov    %edi,%eax
  800a46:	8b 1c 24             	mov    (%esp),%ebx
  800a49:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a4d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a51:	89 ec                	mov    %ebp,%esp
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a55:	55                   	push   %ebp
  800a56:	89 e5                	mov    %esp,%ebp
  800a58:	83 ec 08             	sub    $0x8,%esp
  800a5b:	89 34 24             	mov    %esi,(%esp)
  800a5e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a62:	8b 45 08             	mov    0x8(%ebp),%eax
  800a65:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800a68:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a6b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a6d:	39 c6                	cmp    %eax,%esi
  800a6f:	73 35                	jae    800aa6 <memmove+0x51>
  800a71:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a74:	39 d0                	cmp    %edx,%eax
  800a76:	73 2e                	jae    800aa6 <memmove+0x51>
		s += n;
		d += n;
  800a78:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a7a:	f6 c2 03             	test   $0x3,%dl
  800a7d:	75 1b                	jne    800a9a <memmove+0x45>
  800a7f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a85:	75 13                	jne    800a9a <memmove+0x45>
  800a87:	f6 c1 03             	test   $0x3,%cl
  800a8a:	75 0e                	jne    800a9a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800a8c:	83 ef 04             	sub    $0x4,%edi
  800a8f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a92:	c1 e9 02             	shr    $0x2,%ecx
  800a95:	fd                   	std    
  800a96:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a98:	eb 09                	jmp    800aa3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a9a:	83 ef 01             	sub    $0x1,%edi
  800a9d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800aa0:	fd                   	std    
  800aa1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800aa3:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800aa4:	eb 20                	jmp    800ac6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800aac:	75 15                	jne    800ac3 <memmove+0x6e>
  800aae:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ab4:	75 0d                	jne    800ac3 <memmove+0x6e>
  800ab6:	f6 c1 03             	test   $0x3,%cl
  800ab9:	75 08                	jne    800ac3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800abb:	c1 e9 02             	shr    $0x2,%ecx
  800abe:	fc                   	cld    
  800abf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ac1:	eb 03                	jmp    800ac6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ac3:	fc                   	cld    
  800ac4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ac6:	8b 34 24             	mov    (%esp),%esi
  800ac9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800acd:	89 ec                	mov    %ebp,%esp
  800acf:	5d                   	pop    %ebp
  800ad0:	c3                   	ret    

00800ad1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ad7:	8b 45 10             	mov    0x10(%ebp),%eax
  800ada:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ade:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae8:	89 04 24             	mov    %eax,(%esp)
  800aeb:	e8 65 ff ff ff       	call   800a55 <memmove>
}
  800af0:	c9                   	leave  
  800af1:	c3                   	ret    

00800af2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	57                   	push   %edi
  800af6:	56                   	push   %esi
  800af7:	53                   	push   %ebx
  800af8:	8b 75 08             	mov    0x8(%ebp),%esi
  800afb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800afe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b01:	85 c9                	test   %ecx,%ecx
  800b03:	74 36                	je     800b3b <memcmp+0x49>
		if (*s1 != *s2)
  800b05:	0f b6 06             	movzbl (%esi),%eax
  800b08:	0f b6 1f             	movzbl (%edi),%ebx
  800b0b:	38 d8                	cmp    %bl,%al
  800b0d:	74 20                	je     800b2f <memcmp+0x3d>
  800b0f:	eb 14                	jmp    800b25 <memcmp+0x33>
  800b11:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800b16:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800b1b:	83 c2 01             	add    $0x1,%edx
  800b1e:	83 e9 01             	sub    $0x1,%ecx
  800b21:	38 d8                	cmp    %bl,%al
  800b23:	74 12                	je     800b37 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800b25:	0f b6 c0             	movzbl %al,%eax
  800b28:	0f b6 db             	movzbl %bl,%ebx
  800b2b:	29 d8                	sub    %ebx,%eax
  800b2d:	eb 11                	jmp    800b40 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b2f:	83 e9 01             	sub    $0x1,%ecx
  800b32:	ba 00 00 00 00       	mov    $0x0,%edx
  800b37:	85 c9                	test   %ecx,%ecx
  800b39:	75 d6                	jne    800b11 <memcmp+0x1f>
  800b3b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b40:	5b                   	pop    %ebx
  800b41:	5e                   	pop    %esi
  800b42:	5f                   	pop    %edi
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b4b:	89 c2                	mov    %eax,%edx
  800b4d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b50:	39 d0                	cmp    %edx,%eax
  800b52:	73 15                	jae    800b69 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b54:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b58:	38 08                	cmp    %cl,(%eax)
  800b5a:	75 06                	jne    800b62 <memfind+0x1d>
  800b5c:	eb 0b                	jmp    800b69 <memfind+0x24>
  800b5e:	38 08                	cmp    %cl,(%eax)
  800b60:	74 07                	je     800b69 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b62:	83 c0 01             	add    $0x1,%eax
  800b65:	39 c2                	cmp    %eax,%edx
  800b67:	77 f5                	ja     800b5e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	57                   	push   %edi
  800b6f:	56                   	push   %esi
  800b70:	53                   	push   %ebx
  800b71:	83 ec 04             	sub    $0x4,%esp
  800b74:	8b 55 08             	mov    0x8(%ebp),%edx
  800b77:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b7a:	0f b6 02             	movzbl (%edx),%eax
  800b7d:	3c 20                	cmp    $0x20,%al
  800b7f:	74 04                	je     800b85 <strtol+0x1a>
  800b81:	3c 09                	cmp    $0x9,%al
  800b83:	75 0e                	jne    800b93 <strtol+0x28>
		s++;
  800b85:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b88:	0f b6 02             	movzbl (%edx),%eax
  800b8b:	3c 20                	cmp    $0x20,%al
  800b8d:	74 f6                	je     800b85 <strtol+0x1a>
  800b8f:	3c 09                	cmp    $0x9,%al
  800b91:	74 f2                	je     800b85 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b93:	3c 2b                	cmp    $0x2b,%al
  800b95:	75 0c                	jne    800ba3 <strtol+0x38>
		s++;
  800b97:	83 c2 01             	add    $0x1,%edx
  800b9a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800ba1:	eb 15                	jmp    800bb8 <strtol+0x4d>
	else if (*s == '-')
  800ba3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800baa:	3c 2d                	cmp    $0x2d,%al
  800bac:	75 0a                	jne    800bb8 <strtol+0x4d>
		s++, neg = 1;
  800bae:	83 c2 01             	add    $0x1,%edx
  800bb1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bb8:	85 db                	test   %ebx,%ebx
  800bba:	0f 94 c0             	sete   %al
  800bbd:	74 05                	je     800bc4 <strtol+0x59>
  800bbf:	83 fb 10             	cmp    $0x10,%ebx
  800bc2:	75 18                	jne    800bdc <strtol+0x71>
  800bc4:	80 3a 30             	cmpb   $0x30,(%edx)
  800bc7:	75 13                	jne    800bdc <strtol+0x71>
  800bc9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bcd:	8d 76 00             	lea    0x0(%esi),%esi
  800bd0:	75 0a                	jne    800bdc <strtol+0x71>
		s += 2, base = 16;
  800bd2:	83 c2 02             	add    $0x2,%edx
  800bd5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bda:	eb 15                	jmp    800bf1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bdc:	84 c0                	test   %al,%al
  800bde:	66 90                	xchg   %ax,%ax
  800be0:	74 0f                	je     800bf1 <strtol+0x86>
  800be2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800be7:	80 3a 30             	cmpb   $0x30,(%edx)
  800bea:	75 05                	jne    800bf1 <strtol+0x86>
		s++, base = 8;
  800bec:	83 c2 01             	add    $0x1,%edx
  800bef:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bf1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bf6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bf8:	0f b6 0a             	movzbl (%edx),%ecx
  800bfb:	89 cf                	mov    %ecx,%edi
  800bfd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c00:	80 fb 09             	cmp    $0x9,%bl
  800c03:	77 08                	ja     800c0d <strtol+0xa2>
			dig = *s - '0';
  800c05:	0f be c9             	movsbl %cl,%ecx
  800c08:	83 e9 30             	sub    $0x30,%ecx
  800c0b:	eb 1e                	jmp    800c2b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800c0d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800c10:	80 fb 19             	cmp    $0x19,%bl
  800c13:	77 08                	ja     800c1d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800c15:	0f be c9             	movsbl %cl,%ecx
  800c18:	83 e9 57             	sub    $0x57,%ecx
  800c1b:	eb 0e                	jmp    800c2b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800c1d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800c20:	80 fb 19             	cmp    $0x19,%bl
  800c23:	77 15                	ja     800c3a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800c25:	0f be c9             	movsbl %cl,%ecx
  800c28:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c2b:	39 f1                	cmp    %esi,%ecx
  800c2d:	7d 0b                	jge    800c3a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800c2f:	83 c2 01             	add    $0x1,%edx
  800c32:	0f af c6             	imul   %esi,%eax
  800c35:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c38:	eb be                	jmp    800bf8 <strtol+0x8d>
  800c3a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800c3c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c40:	74 05                	je     800c47 <strtol+0xdc>
		*endptr = (char *) s;
  800c42:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c45:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c47:	89 ca                	mov    %ecx,%edx
  800c49:	f7 da                	neg    %edx
  800c4b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c4f:	0f 45 c2             	cmovne %edx,%eax
}
  800c52:	83 c4 04             	add    $0x4,%esp
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    
	...

00800c5c <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c5c:	55                   	push   %ebp
  800c5d:	89 e5                	mov    %esp,%ebp
  800c5f:	83 ec 48             	sub    $0x48,%esp
  800c62:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c65:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c68:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800c6b:	89 c6                	mov    %eax,%esi
  800c6d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800c70:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800c72:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c75:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c7b:	51                   	push   %ecx
  800c7c:	52                   	push   %edx
  800c7d:	53                   	push   %ebx
  800c7e:	54                   	push   %esp
  800c7f:	55                   	push   %ebp
  800c80:	56                   	push   %esi
  800c81:	57                   	push   %edi
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	8d 35 8c 0c 80 00    	lea    0x800c8c,%esi
  800c8a:	0f 34                	sysenter 

00800c8c <.after_sysenter_label>:
  800c8c:	5f                   	pop    %edi
  800c8d:	5e                   	pop    %esi
  800c8e:	5d                   	pop    %ebp
  800c8f:	5c                   	pop    %esp
  800c90:	5b                   	pop    %ebx
  800c91:	5a                   	pop    %edx
  800c92:	59                   	pop    %ecx
  800c93:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800c95:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c99:	74 28                	je     800cc3 <.after_sysenter_label+0x37>
  800c9b:	85 c0                	test   %eax,%eax
  800c9d:	7e 24                	jle    800cc3 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ca3:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800ca7:	c7 44 24 08 a0 20 80 	movl   $0x8020a0,0x8(%esp)
  800cae:	00 
  800caf:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800cb6:	00 
  800cb7:	c7 04 24 bd 20 80 00 	movl   $0x8020bd,(%esp)
  800cbe:	e8 1d 0c 00 00       	call   8018e0 <_panic>

	return ret;
}
  800cc3:	89 d0                	mov    %edx,%eax
  800cc5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cc8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ccb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cce:	89 ec                	mov    %ebp,%esp
  800cd0:	5d                   	pop    %ebp
  800cd1:	c3                   	ret    

00800cd2 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800cd2:	55                   	push   %ebp
  800cd3:	89 e5                	mov    %esp,%ebp
  800cd5:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800cd8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800cdf:	00 
  800ce0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ce7:	00 
  800ce8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800cef:	00 
  800cf0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800cf7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cfa:	ba 01 00 00 00       	mov    $0x1,%edx
  800cff:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d04:	e8 53 ff ff ff       	call   800c5c <syscall>
}
  800d09:	c9                   	leave  
  800d0a:	c3                   	ret    

00800d0b <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d0b:	55                   	push   %ebp
  800d0c:	89 e5                	mov    %esp,%ebp
  800d0e:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d11:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d18:	00 
  800d19:	8b 45 14             	mov    0x14(%ebp),%eax
  800d1c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d20:	8b 45 10             	mov    0x10(%ebp),%eax
  800d23:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d2a:	89 04 24             	mov    %eax,(%esp)
  800d2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d30:	ba 00 00 00 00       	mov    $0x0,%edx
  800d35:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d3a:	e8 1d ff ff ff       	call   800c5c <syscall>
}
  800d3f:	c9                   	leave  
  800d40:	c3                   	ret    

00800d41 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800d47:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d4e:	00 
  800d4f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d56:	00 
  800d57:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d5e:	00 
  800d5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d62:	89 04 24             	mov    %eax,(%esp)
  800d65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d68:	ba 01 00 00 00       	mov    $0x1,%edx
  800d6d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d72:	e8 e5 fe ff ff       	call   800c5c <syscall>
}
  800d77:	c9                   	leave  
  800d78:	c3                   	ret    

00800d79 <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d79:	55                   	push   %ebp
  800d7a:	89 e5                	mov    %esp,%ebp
  800d7c:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800d7f:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800d86:	00 
  800d87:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800d8e:	00 
  800d8f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800d96:	00 
  800d97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d9a:	89 04 24             	mov    %eax,(%esp)
  800d9d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da0:	ba 01 00 00 00       	mov    $0x1,%edx
  800da5:	b8 0a 00 00 00       	mov    $0xa,%eax
  800daa:	e8 ad fe ff ff       	call   800c5c <syscall>
}
  800daf:	c9                   	leave  
  800db0:	c3                   	ret    

00800db1 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800db7:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dbe:	00 
  800dbf:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800dc6:	00 
  800dc7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800dce:	00 
  800dcf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd2:	89 04 24             	mov    %eax,(%esp)
  800dd5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dd8:	ba 01 00 00 00       	mov    $0x1,%edx
  800ddd:	b8 09 00 00 00       	mov    $0x9,%eax
  800de2:	e8 75 fe ff ff       	call   800c5c <syscall>
}
  800de7:	c9                   	leave  
  800de8:	c3                   	ret    

00800de9 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800de9:	55                   	push   %ebp
  800dea:	89 e5                	mov    %esp,%ebp
  800dec:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800def:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800df6:	00 
  800df7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800dfe:	00 
  800dff:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e06:	00 
  800e07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e0a:	89 04 24             	mov    %eax,(%esp)
  800e0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e10:	ba 01 00 00 00       	mov    $0x1,%edx
  800e15:	b8 07 00 00 00       	mov    $0x7,%eax
  800e1a:	e8 3d fe ff ff       	call   800c5c <syscall>
}
  800e1f:	c9                   	leave  
  800e20:	c3                   	ret    

00800e21 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e21:	55                   	push   %ebp
  800e22:	89 e5                	mov    %esp,%ebp
  800e24:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800e27:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e2e:	00 
  800e2f:	8b 45 18             	mov    0x18(%ebp),%eax
  800e32:	0b 45 14             	or     0x14(%ebp),%eax
  800e35:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e39:	8b 45 10             	mov    0x10(%ebp),%eax
  800e3c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e43:	89 04 24             	mov    %eax,(%esp)
  800e46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e49:	ba 01 00 00 00       	mov    $0x1,%edx
  800e4e:	b8 06 00 00 00       	mov    $0x6,%eax
  800e53:	e8 04 fe ff ff       	call   800c5c <syscall>
}
  800e58:	c9                   	leave  
  800e59:	c3                   	ret    

00800e5a <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e5a:	55                   	push   %ebp
  800e5b:	89 e5                	mov    %esp,%ebp
  800e5d:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800e60:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e67:	00 
  800e68:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e6f:	00 
  800e70:	8b 45 10             	mov    0x10(%ebp),%eax
  800e73:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7a:	89 04 24             	mov    %eax,(%esp)
  800e7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e80:	ba 01 00 00 00       	mov    $0x1,%edx
  800e85:	b8 05 00 00 00       	mov    $0x5,%eax
  800e8a:	e8 cd fd ff ff       	call   800c5c <syscall>
}
  800e8f:	c9                   	leave  
  800e90:	c3                   	ret    

00800e91 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800e91:	55                   	push   %ebp
  800e92:	89 e5                	mov    %esp,%ebp
  800e94:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800e97:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e9e:	00 
  800e9f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ea6:	00 
  800ea7:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800eae:	00 
  800eaf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800eb6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ebb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ec5:	e8 92 fd ff ff       	call   800c5c <syscall>
}
  800eca:	c9                   	leave  
  800ecb:	c3                   	ret    

00800ecc <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  800ecc:	55                   	push   %ebp
  800ecd:	89 e5                	mov    %esp,%ebp
  800ecf:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  800ed2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ed9:	00 
  800eda:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ee1:	00 
  800ee2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ee9:	00 
  800eea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eed:	89 04 24             	mov    %eax,(%esp)
  800ef0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef8:	b8 04 00 00 00       	mov    $0x4,%eax
  800efd:	e8 5a fd ff ff       	call   800c5c <syscall>
}
  800f02:	c9                   	leave  
  800f03:	c3                   	ret    

00800f04 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800f04:	55                   	push   %ebp
  800f05:	89 e5                	mov    %esp,%ebp
  800f07:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800f0a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f11:	00 
  800f12:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f19:	00 
  800f1a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f21:	00 
  800f22:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f29:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f33:	b8 02 00 00 00       	mov    $0x2,%eax
  800f38:	e8 1f fd ff ff       	call   800c5c <syscall>
}
  800f3d:	c9                   	leave  
  800f3e:	c3                   	ret    

00800f3f <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800f3f:	55                   	push   %ebp
  800f40:	89 e5                	mov    %esp,%ebp
  800f42:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800f45:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f4c:	00 
  800f4d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f54:	00 
  800f55:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f5c:	00 
  800f5d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f64:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f67:	ba 01 00 00 00       	mov    $0x1,%edx
  800f6c:	b8 03 00 00 00       	mov    $0x3,%eax
  800f71:	e8 e6 fc ff ff       	call   800c5c <syscall>
}
  800f76:	c9                   	leave  
  800f77:	c3                   	ret    

00800f78 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800f7e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f85:	00 
  800f86:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f8d:	00 
  800f8e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f95:	00 
  800f96:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800f9d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fa2:	ba 00 00 00 00       	mov    $0x0,%edx
  800fa7:	b8 01 00 00 00       	mov    $0x1,%eax
  800fac:	e8 ab fc ff ff       	call   800c5c <syscall>
}
  800fb1:	c9                   	leave  
  800fb2:	c3                   	ret    

00800fb3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800fb9:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fc0:	00 
  800fc1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fc8:	00 
  800fc9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800fd0:	00 
  800fd1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fd4:	89 04 24             	mov    %eax,(%esp)
  800fd7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fda:	ba 00 00 00 00       	mov    $0x0,%edx
  800fdf:	b8 00 00 00 00       	mov    $0x0,%eax
  800fe4:	e8 73 fc ff ff       	call   800c5c <syscall>
}
  800fe9:	c9                   	leave  
  800fea:	c3                   	ret    
  800feb:	00 00                	add    %al,(%eax)
  800fed:	00 00                	add    %al,(%eax)
	...

00800ff0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ff6:	05 00 00 00 30       	add    $0x30000000,%eax
  800ffb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  800ffe:	5d                   	pop    %ebp
  800fff:	c3                   	ret    

00801000 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  801006:	8b 45 08             	mov    0x8(%ebp),%eax
  801009:	89 04 24             	mov    %eax,(%esp)
  80100c:	e8 df ff ff ff       	call   800ff0 <fd2num>
  801011:	05 20 00 0d 00       	add    $0xd0020,%eax
  801016:	c1 e0 0c             	shl    $0xc,%eax
}
  801019:	c9                   	leave  
  80101a:	c3                   	ret    

0080101b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	57                   	push   %edi
  80101f:	56                   	push   %esi
  801020:	53                   	push   %ebx
  801021:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801024:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801029:	a8 01                	test   $0x1,%al
  80102b:	74 36                	je     801063 <fd_alloc+0x48>
  80102d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801032:	a8 01                	test   $0x1,%al
  801034:	74 2d                	je     801063 <fd_alloc+0x48>
  801036:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80103b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801040:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801045:	89 c3                	mov    %eax,%ebx
  801047:	89 c2                	mov    %eax,%edx
  801049:	c1 ea 16             	shr    $0x16,%edx
  80104c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80104f:	f6 c2 01             	test   $0x1,%dl
  801052:	74 14                	je     801068 <fd_alloc+0x4d>
  801054:	89 c2                	mov    %eax,%edx
  801056:	c1 ea 0c             	shr    $0xc,%edx
  801059:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80105c:	f6 c2 01             	test   $0x1,%dl
  80105f:	75 10                	jne    801071 <fd_alloc+0x56>
  801061:	eb 05                	jmp    801068 <fd_alloc+0x4d>
  801063:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801068:	89 1f                	mov    %ebx,(%edi)
  80106a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80106f:	eb 17                	jmp    801088 <fd_alloc+0x6d>
  801071:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801076:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80107b:	75 c8                	jne    801045 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80107d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801083:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801088:	5b                   	pop    %ebx
  801089:	5e                   	pop    %esi
  80108a:	5f                   	pop    %edi
  80108b:	5d                   	pop    %ebp
  80108c:	c3                   	ret    

0080108d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80108d:	55                   	push   %ebp
  80108e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801090:	8b 45 08             	mov    0x8(%ebp),%eax
  801093:	83 f8 1f             	cmp    $0x1f,%eax
  801096:	77 36                	ja     8010ce <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801098:	05 00 00 0d 00       	add    $0xd0000,%eax
  80109d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  8010a0:	89 c2                	mov    %eax,%edx
  8010a2:	c1 ea 16             	shr    $0x16,%edx
  8010a5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010ac:	f6 c2 01             	test   $0x1,%dl
  8010af:	74 1d                	je     8010ce <fd_lookup+0x41>
  8010b1:	89 c2                	mov    %eax,%edx
  8010b3:	c1 ea 0c             	shr    $0xc,%edx
  8010b6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010bd:	f6 c2 01             	test   $0x1,%dl
  8010c0:	74 0c                	je     8010ce <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010c2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010c5:	89 02                	mov    %eax,(%edx)
  8010c7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8010cc:	eb 05                	jmp    8010d3 <fd_lookup+0x46>
  8010ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8010d3:	5d                   	pop    %ebp
  8010d4:	c3                   	ret    

008010d5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8010d5:	55                   	push   %ebp
  8010d6:	89 e5                	mov    %esp,%ebp
  8010d8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8010db:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8010de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8010e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e5:	89 04 24             	mov    %eax,(%esp)
  8010e8:	e8 a0 ff ff ff       	call   80108d <fd_lookup>
  8010ed:	85 c0                	test   %eax,%eax
  8010ef:	78 0e                	js     8010ff <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8010f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8010f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010f7:	89 50 04             	mov    %edx,0x4(%eax)
  8010fa:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8010ff:	c9                   	leave  
  801100:	c3                   	ret    

00801101 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	56                   	push   %esi
  801105:	53                   	push   %ebx
  801106:	83 ec 10             	sub    $0x10,%esp
  801109:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80110c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  80110f:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801114:	b8 04 30 80 00       	mov    $0x803004,%eax
  801119:	39 0d 04 30 80 00    	cmp    %ecx,0x803004
  80111f:	75 11                	jne    801132 <dev_lookup+0x31>
  801121:	eb 04                	jmp    801127 <dev_lookup+0x26>
  801123:	39 08                	cmp    %ecx,(%eax)
  801125:	75 10                	jne    801137 <dev_lookup+0x36>
			*dev = devtab[i];
  801127:	89 03                	mov    %eax,(%ebx)
  801129:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80112e:	66 90                	xchg   %ax,%ax
  801130:	eb 36                	jmp    801168 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801132:	be 48 21 80 00       	mov    $0x802148,%esi
  801137:	83 c2 01             	add    $0x1,%edx
  80113a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80113d:	85 c0                	test   %eax,%eax
  80113f:	75 e2                	jne    801123 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801141:	a1 04 40 80 00       	mov    0x804004,%eax
  801146:	8b 40 48             	mov    0x48(%eax),%eax
  801149:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80114d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801151:	c7 04 24 cc 20 80 00 	movl   $0x8020cc,(%esp)
  801158:	e8 d0 ef ff ff       	call   80012d <cprintf>
	*dev = 0;
  80115d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801163:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801168:	83 c4 10             	add    $0x10,%esp
  80116b:	5b                   	pop    %ebx
  80116c:	5e                   	pop    %esi
  80116d:	5d                   	pop    %ebp
  80116e:	c3                   	ret    

0080116f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80116f:	55                   	push   %ebp
  801170:	89 e5                	mov    %esp,%ebp
  801172:	53                   	push   %ebx
  801173:	83 ec 24             	sub    $0x24,%esp
  801176:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801179:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80117c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801180:	8b 45 08             	mov    0x8(%ebp),%eax
  801183:	89 04 24             	mov    %eax,(%esp)
  801186:	e8 02 ff ff ff       	call   80108d <fd_lookup>
  80118b:	85 c0                	test   %eax,%eax
  80118d:	78 53                	js     8011e2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801192:	89 44 24 04          	mov    %eax,0x4(%esp)
  801196:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801199:	8b 00                	mov    (%eax),%eax
  80119b:	89 04 24             	mov    %eax,(%esp)
  80119e:	e8 5e ff ff ff       	call   801101 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011a3:	85 c0                	test   %eax,%eax
  8011a5:	78 3b                	js     8011e2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  8011a7:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011af:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8011b3:	74 2d                	je     8011e2 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8011b5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8011b8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8011bf:	00 00 00 
	stat->st_isdir = 0;
  8011c2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8011c9:	00 00 00 
	stat->st_dev = dev;
  8011cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011cf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8011d5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8011d9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011dc:	89 14 24             	mov    %edx,(%esp)
  8011df:	ff 50 14             	call   *0x14(%eax)
}
  8011e2:	83 c4 24             	add    $0x24,%esp
  8011e5:	5b                   	pop    %ebx
  8011e6:	5d                   	pop    %ebp
  8011e7:	c3                   	ret    

008011e8 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8011e8:	55                   	push   %ebp
  8011e9:	89 e5                	mov    %esp,%ebp
  8011eb:	53                   	push   %ebx
  8011ec:	83 ec 24             	sub    $0x24,%esp
  8011ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8011f9:	89 1c 24             	mov    %ebx,(%esp)
  8011fc:	e8 8c fe ff ff       	call   80108d <fd_lookup>
  801201:	85 c0                	test   %eax,%eax
  801203:	78 5f                	js     801264 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801205:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801208:	89 44 24 04          	mov    %eax,0x4(%esp)
  80120c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120f:	8b 00                	mov    (%eax),%eax
  801211:	89 04 24             	mov    %eax,(%esp)
  801214:	e8 e8 fe ff ff       	call   801101 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801219:	85 c0                	test   %eax,%eax
  80121b:	78 47                	js     801264 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80121d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801220:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801224:	75 23                	jne    801249 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801226:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80122b:	8b 40 48             	mov    0x48(%eax),%eax
  80122e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801232:	89 44 24 04          	mov    %eax,0x4(%esp)
  801236:	c7 04 24 ec 20 80 00 	movl   $0x8020ec,(%esp)
  80123d:	e8 eb ee ff ff       	call   80012d <cprintf>
  801242:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801247:	eb 1b                	jmp    801264 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801249:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80124c:	8b 48 18             	mov    0x18(%eax),%ecx
  80124f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801254:	85 c9                	test   %ecx,%ecx
  801256:	74 0c                	je     801264 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801258:	8b 45 0c             	mov    0xc(%ebp),%eax
  80125b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80125f:	89 14 24             	mov    %edx,(%esp)
  801262:	ff d1                	call   *%ecx
}
  801264:	83 c4 24             	add    $0x24,%esp
  801267:	5b                   	pop    %ebx
  801268:	5d                   	pop    %ebp
  801269:	c3                   	ret    

0080126a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80126a:	55                   	push   %ebp
  80126b:	89 e5                	mov    %esp,%ebp
  80126d:	53                   	push   %ebx
  80126e:	83 ec 24             	sub    $0x24,%esp
  801271:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801274:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801277:	89 44 24 04          	mov    %eax,0x4(%esp)
  80127b:	89 1c 24             	mov    %ebx,(%esp)
  80127e:	e8 0a fe ff ff       	call   80108d <fd_lookup>
  801283:	85 c0                	test   %eax,%eax
  801285:	78 66                	js     8012ed <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801287:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80128a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80128e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801291:	8b 00                	mov    (%eax),%eax
  801293:	89 04 24             	mov    %eax,(%esp)
  801296:	e8 66 fe ff ff       	call   801101 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80129b:	85 c0                	test   %eax,%eax
  80129d:	78 4e                	js     8012ed <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80129f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012a2:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  8012a6:	75 23                	jne    8012cb <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8012a8:	a1 04 40 80 00       	mov    0x804004,%eax
  8012ad:	8b 40 48             	mov    0x48(%eax),%eax
  8012b0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8012b4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012b8:	c7 04 24 0d 21 80 00 	movl   $0x80210d,(%esp)
  8012bf:	e8 69 ee ff ff       	call   80012d <cprintf>
  8012c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8012c9:	eb 22                	jmp    8012ed <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8012cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ce:	8b 48 0c             	mov    0xc(%eax),%ecx
  8012d1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012d6:	85 c9                	test   %ecx,%ecx
  8012d8:	74 13                	je     8012ed <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8012da:	8b 45 10             	mov    0x10(%ebp),%eax
  8012dd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8012e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e8:	89 14 24             	mov    %edx,(%esp)
  8012eb:	ff d1                	call   *%ecx
}
  8012ed:	83 c4 24             	add    $0x24,%esp
  8012f0:	5b                   	pop    %ebx
  8012f1:	5d                   	pop    %ebp
  8012f2:	c3                   	ret    

008012f3 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8012f3:	55                   	push   %ebp
  8012f4:	89 e5                	mov    %esp,%ebp
  8012f6:	53                   	push   %ebx
  8012f7:	83 ec 24             	sub    $0x24,%esp
  8012fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801300:	89 44 24 04          	mov    %eax,0x4(%esp)
  801304:	89 1c 24             	mov    %ebx,(%esp)
  801307:	e8 81 fd ff ff       	call   80108d <fd_lookup>
  80130c:	85 c0                	test   %eax,%eax
  80130e:	78 6b                	js     80137b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801310:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801313:	89 44 24 04          	mov    %eax,0x4(%esp)
  801317:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131a:	8b 00                	mov    (%eax),%eax
  80131c:	89 04 24             	mov    %eax,(%esp)
  80131f:	e8 dd fd ff ff       	call   801101 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801324:	85 c0                	test   %eax,%eax
  801326:	78 53                	js     80137b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801328:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80132b:	8b 42 08             	mov    0x8(%edx),%eax
  80132e:	83 e0 03             	and    $0x3,%eax
  801331:	83 f8 01             	cmp    $0x1,%eax
  801334:	75 23                	jne    801359 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801336:	a1 04 40 80 00       	mov    0x804004,%eax
  80133b:	8b 40 48             	mov    0x48(%eax),%eax
  80133e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801342:	89 44 24 04          	mov    %eax,0x4(%esp)
  801346:	c7 04 24 2a 21 80 00 	movl   $0x80212a,(%esp)
  80134d:	e8 db ed ff ff       	call   80012d <cprintf>
  801352:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801357:	eb 22                	jmp    80137b <read+0x88>
	}
	if (!dev->dev_read)
  801359:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135c:	8b 48 08             	mov    0x8(%eax),%ecx
  80135f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801364:	85 c9                	test   %ecx,%ecx
  801366:	74 13                	je     80137b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801368:	8b 45 10             	mov    0x10(%ebp),%eax
  80136b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80136f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801372:	89 44 24 04          	mov    %eax,0x4(%esp)
  801376:	89 14 24             	mov    %edx,(%esp)
  801379:	ff d1                	call   *%ecx
}
  80137b:	83 c4 24             	add    $0x24,%esp
  80137e:	5b                   	pop    %ebx
  80137f:	5d                   	pop    %ebp
  801380:	c3                   	ret    

00801381 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801381:	55                   	push   %ebp
  801382:	89 e5                	mov    %esp,%ebp
  801384:	57                   	push   %edi
  801385:	56                   	push   %esi
  801386:	53                   	push   %ebx
  801387:	83 ec 1c             	sub    $0x1c,%esp
  80138a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80138d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801390:	ba 00 00 00 00       	mov    $0x0,%edx
  801395:	bb 00 00 00 00       	mov    $0x0,%ebx
  80139a:	b8 00 00 00 00       	mov    $0x0,%eax
  80139f:	85 f6                	test   %esi,%esi
  8013a1:	74 29                	je     8013cc <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013a3:	89 f0                	mov    %esi,%eax
  8013a5:	29 d0                	sub    %edx,%eax
  8013a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013ab:	03 55 0c             	add    0xc(%ebp),%edx
  8013ae:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013b2:	89 3c 24             	mov    %edi,(%esp)
  8013b5:	e8 39 ff ff ff       	call   8012f3 <read>
		if (m < 0)
  8013ba:	85 c0                	test   %eax,%eax
  8013bc:	78 0e                	js     8013cc <readn+0x4b>
			return m;
		if (m == 0)
  8013be:	85 c0                	test   %eax,%eax
  8013c0:	74 08                	je     8013ca <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013c2:	01 c3                	add    %eax,%ebx
  8013c4:	89 da                	mov    %ebx,%edx
  8013c6:	39 f3                	cmp    %esi,%ebx
  8013c8:	72 d9                	jb     8013a3 <readn+0x22>
  8013ca:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013cc:	83 c4 1c             	add    $0x1c,%esp
  8013cf:	5b                   	pop    %ebx
  8013d0:	5e                   	pop    %esi
  8013d1:	5f                   	pop    %edi
  8013d2:	5d                   	pop    %ebp
  8013d3:	c3                   	ret    

008013d4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013d4:	55                   	push   %ebp
  8013d5:	89 e5                	mov    %esp,%ebp
  8013d7:	83 ec 28             	sub    $0x28,%esp
  8013da:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8013dd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8013e0:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013e3:	89 34 24             	mov    %esi,(%esp)
  8013e6:	e8 05 fc ff ff       	call   800ff0 <fd2num>
  8013eb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8013ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8013f2:	89 04 24             	mov    %eax,(%esp)
  8013f5:	e8 93 fc ff ff       	call   80108d <fd_lookup>
  8013fa:	89 c3                	mov    %eax,%ebx
  8013fc:	85 c0                	test   %eax,%eax
  8013fe:	78 05                	js     801405 <fd_close+0x31>
  801400:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801403:	74 0e                	je     801413 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801405:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801409:	b8 00 00 00 00       	mov    $0x0,%eax
  80140e:	0f 44 d8             	cmove  %eax,%ebx
  801411:	eb 3d                	jmp    801450 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801413:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801416:	89 44 24 04          	mov    %eax,0x4(%esp)
  80141a:	8b 06                	mov    (%esi),%eax
  80141c:	89 04 24             	mov    %eax,(%esp)
  80141f:	e8 dd fc ff ff       	call   801101 <dev_lookup>
  801424:	89 c3                	mov    %eax,%ebx
  801426:	85 c0                	test   %eax,%eax
  801428:	78 16                	js     801440 <fd_close+0x6c>
		if (dev->dev_close)
  80142a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142d:	8b 40 10             	mov    0x10(%eax),%eax
  801430:	bb 00 00 00 00       	mov    $0x0,%ebx
  801435:	85 c0                	test   %eax,%eax
  801437:	74 07                	je     801440 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801439:	89 34 24             	mov    %esi,(%esp)
  80143c:	ff d0                	call   *%eax
  80143e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801440:	89 74 24 04          	mov    %esi,0x4(%esp)
  801444:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80144b:	e8 99 f9 ff ff       	call   800de9 <sys_page_unmap>
	return r;
}
  801450:	89 d8                	mov    %ebx,%eax
  801452:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801455:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801458:	89 ec                	mov    %ebp,%esp
  80145a:	5d                   	pop    %ebp
  80145b:	c3                   	ret    

0080145c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80145c:	55                   	push   %ebp
  80145d:	89 e5                	mov    %esp,%ebp
  80145f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801462:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801465:	89 44 24 04          	mov    %eax,0x4(%esp)
  801469:	8b 45 08             	mov    0x8(%ebp),%eax
  80146c:	89 04 24             	mov    %eax,(%esp)
  80146f:	e8 19 fc ff ff       	call   80108d <fd_lookup>
  801474:	85 c0                	test   %eax,%eax
  801476:	78 13                	js     80148b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801478:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80147f:	00 
  801480:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801483:	89 04 24             	mov    %eax,(%esp)
  801486:	e8 49 ff ff ff       	call   8013d4 <fd_close>
}
  80148b:	c9                   	leave  
  80148c:	c3                   	ret    

0080148d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  80148d:	55                   	push   %ebp
  80148e:	89 e5                	mov    %esp,%ebp
  801490:	83 ec 18             	sub    $0x18,%esp
  801493:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801496:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801499:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8014a0:	00 
  8014a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a4:	89 04 24             	mov    %eax,(%esp)
  8014a7:	e8 78 03 00 00       	call   801824 <open>
  8014ac:	89 c3                	mov    %eax,%ebx
  8014ae:	85 c0                	test   %eax,%eax
  8014b0:	78 1b                	js     8014cd <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  8014b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8014b9:	89 1c 24             	mov    %ebx,(%esp)
  8014bc:	e8 ae fc ff ff       	call   80116f <fstat>
  8014c1:	89 c6                	mov    %eax,%esi
	close(fd);
  8014c3:	89 1c 24             	mov    %ebx,(%esp)
  8014c6:	e8 91 ff ff ff       	call   80145c <close>
  8014cb:	89 f3                	mov    %esi,%ebx
	return r;
}
  8014cd:	89 d8                	mov    %ebx,%eax
  8014cf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8014d2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8014d5:	89 ec                	mov    %ebp,%esp
  8014d7:	5d                   	pop    %ebp
  8014d8:	c3                   	ret    

008014d9 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  8014d9:	55                   	push   %ebp
  8014da:	89 e5                	mov    %esp,%ebp
  8014dc:	53                   	push   %ebx
  8014dd:	83 ec 14             	sub    $0x14,%esp
  8014e0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  8014e5:	89 1c 24             	mov    %ebx,(%esp)
  8014e8:	e8 6f ff ff ff       	call   80145c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  8014ed:	83 c3 01             	add    $0x1,%ebx
  8014f0:	83 fb 20             	cmp    $0x20,%ebx
  8014f3:	75 f0                	jne    8014e5 <close_all+0xc>
		close(i);
}
  8014f5:	83 c4 14             	add    $0x14,%esp
  8014f8:	5b                   	pop    %ebx
  8014f9:	5d                   	pop    %ebp
  8014fa:	c3                   	ret    

008014fb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014fb:	55                   	push   %ebp
  8014fc:	89 e5                	mov    %esp,%ebp
  8014fe:	83 ec 58             	sub    $0x58,%esp
  801501:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801504:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801507:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80150a:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80150d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801510:	89 44 24 04          	mov    %eax,0x4(%esp)
  801514:	8b 45 08             	mov    0x8(%ebp),%eax
  801517:	89 04 24             	mov    %eax,(%esp)
  80151a:	e8 6e fb ff ff       	call   80108d <fd_lookup>
  80151f:	89 c3                	mov    %eax,%ebx
  801521:	85 c0                	test   %eax,%eax
  801523:	0f 88 e0 00 00 00    	js     801609 <dup+0x10e>
		return r;
	close(newfdnum);
  801529:	89 3c 24             	mov    %edi,(%esp)
  80152c:	e8 2b ff ff ff       	call   80145c <close>

	newfd = INDEX2FD(newfdnum);
  801531:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801537:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  80153a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80153d:	89 04 24             	mov    %eax,(%esp)
  801540:	e8 bb fa ff ff       	call   801000 <fd2data>
  801545:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801547:	89 34 24             	mov    %esi,(%esp)
  80154a:	e8 b1 fa ff ff       	call   801000 <fd2data>
  80154f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801552:	89 da                	mov    %ebx,%edx
  801554:	89 d8                	mov    %ebx,%eax
  801556:	c1 e8 16             	shr    $0x16,%eax
  801559:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801560:	a8 01                	test   $0x1,%al
  801562:	74 43                	je     8015a7 <dup+0xac>
  801564:	c1 ea 0c             	shr    $0xc,%edx
  801567:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80156e:	a8 01                	test   $0x1,%al
  801570:	74 35                	je     8015a7 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801572:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801579:	25 07 0e 00 00       	and    $0xe07,%eax
  80157e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801582:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801585:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801589:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801590:	00 
  801591:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801595:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80159c:	e8 80 f8 ff ff       	call   800e21 <sys_page_map>
  8015a1:	89 c3                	mov    %eax,%ebx
  8015a3:	85 c0                	test   %eax,%eax
  8015a5:	78 3f                	js     8015e6 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8015aa:	89 c2                	mov    %eax,%edx
  8015ac:	c1 ea 0c             	shr    $0xc,%edx
  8015af:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8015b6:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8015bc:	89 54 24 10          	mov    %edx,0x10(%esp)
  8015c0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8015c4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8015cb:	00 
  8015cc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015d0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015d7:	e8 45 f8 ff ff       	call   800e21 <sys_page_map>
  8015dc:	89 c3                	mov    %eax,%ebx
  8015de:	85 c0                	test   %eax,%eax
  8015e0:	78 04                	js     8015e6 <dup+0xeb>
  8015e2:	89 fb                	mov    %edi,%ebx
  8015e4:	eb 23                	jmp    801609 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8015e6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8015ea:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8015f1:	e8 f3 f7 ff ff       	call   800de9 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015f6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  8015f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8015fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801604:	e8 e0 f7 ff ff       	call   800de9 <sys_page_unmap>
	return r;
}
  801609:	89 d8                	mov    %ebx,%eax
  80160b:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80160e:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801611:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801614:	89 ec                	mov    %ebp,%esp
  801616:	5d                   	pop    %ebp
  801617:	c3                   	ret    

00801618 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801618:	55                   	push   %ebp
  801619:	89 e5                	mov    %esp,%ebp
  80161b:	83 ec 18             	sub    $0x18,%esp
  80161e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801621:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801624:	89 c3                	mov    %eax,%ebx
  801626:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801628:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80162f:	75 11                	jne    801642 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801631:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801638:	e8 03 03 00 00       	call   801940 <ipc_find_env>
  80163d:	a3 00 40 80 00       	mov    %eax,0x804000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801642:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801649:	00 
  80164a:	c7 44 24 08 00 50 80 	movl   $0x805000,0x8(%esp)
  801651:	00 
  801652:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801656:	a1 00 40 80 00       	mov    0x804000,%eax
  80165b:	89 04 24             	mov    %eax,(%esp)
  80165e:	e8 21 03 00 00       	call   801984 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801663:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80166a:	00 
  80166b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80166f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801676:	e8 78 03 00 00       	call   8019f3 <ipc_recv>
}
  80167b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80167e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801681:	89 ec                	mov    %ebp,%esp
  801683:	5d                   	pop    %ebp
  801684:	c3                   	ret    

00801685 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
  801688:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80168b:	8b 45 08             	mov    0x8(%ebp),%eax
  80168e:	8b 40 0c             	mov    0xc(%eax),%eax
  801691:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801696:	8b 45 0c             	mov    0xc(%ebp),%eax
  801699:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80169e:	ba 00 00 00 00       	mov    $0x0,%edx
  8016a3:	b8 02 00 00 00       	mov    $0x2,%eax
  8016a8:	e8 6b ff ff ff       	call   801618 <fsipc>
}
  8016ad:	c9                   	leave  
  8016ae:	c3                   	ret    

008016af <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016af:	55                   	push   %ebp
  8016b0:	89 e5                	mov    %esp,%ebp
  8016b2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b8:	8b 40 0c             	mov    0xc(%eax),%eax
  8016bb:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c5:	b8 06 00 00 00       	mov    $0x6,%eax
  8016ca:	e8 49 ff ff ff       	call   801618 <fsipc>
}
  8016cf:	c9                   	leave  
  8016d0:	c3                   	ret    

008016d1 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  8016d1:	55                   	push   %ebp
  8016d2:	89 e5                	mov    %esp,%ebp
  8016d4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8016d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016dc:	b8 08 00 00 00       	mov    $0x8,%eax
  8016e1:	e8 32 ff ff ff       	call   801618 <fsipc>
}
  8016e6:	c9                   	leave  
  8016e7:	c3                   	ret    

008016e8 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016e8:	55                   	push   %ebp
  8016e9:	89 e5                	mov    %esp,%ebp
  8016eb:	53                   	push   %ebx
  8016ec:	83 ec 14             	sub    $0x14,%esp
  8016ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8016f8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801702:	b8 05 00 00 00       	mov    $0x5,%eax
  801707:	e8 0c ff ff ff       	call   801618 <fsipc>
  80170c:	85 c0                	test   %eax,%eax
  80170e:	78 2b                	js     80173b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801710:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  801717:	00 
  801718:	89 1c 24             	mov    %ebx,(%esp)
  80171b:	e8 4a f1 ff ff       	call   80086a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801720:	a1 80 50 80 00       	mov    0x805080,%eax
  801725:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80172b:	a1 84 50 80 00       	mov    0x805084,%eax
  801730:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801736:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  80173b:	83 c4 14             	add    $0x14,%esp
  80173e:	5b                   	pop    %ebx
  80173f:	5d                   	pop    %ebp
  801740:	c3                   	ret    

00801741 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801741:	55                   	push   %ebp
  801742:	89 e5                	mov    %esp,%ebp
  801744:	83 ec 18             	sub    $0x18,%esp
  801747:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  80174a:	8b 55 08             	mov    0x8(%ebp),%edx
  80174d:	8b 52 0c             	mov    0xc(%edx),%edx
  801750:	89 15 00 50 80 00    	mov    %edx,0x805000
  fsipcbuf.write.req_n = n;
  801756:	a3 04 50 80 00       	mov    %eax,0x805004
  memmove(fsipcbuf.write.req_buf, buf,
  80175b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801760:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801765:	0f 47 c2             	cmova  %edx,%eax
  801768:	89 44 24 08          	mov    %eax,0x8(%esp)
  80176c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80176f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801773:	c7 04 24 08 50 80 00 	movl   $0x805008,(%esp)
  80177a:	e8 d6 f2 ff ff       	call   800a55 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  80177f:	ba 00 00 00 00       	mov    $0x0,%edx
  801784:	b8 04 00 00 00       	mov    $0x4,%eax
  801789:	e8 8a fe ff ff       	call   801618 <fsipc>
}
  80178e:	c9                   	leave  
  80178f:	c3                   	ret    

00801790 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	53                   	push   %ebx
  801794:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801797:	8b 45 08             	mov    0x8(%ebp),%eax
  80179a:	8b 40 0c             	mov    0xc(%eax),%eax
  80179d:	a3 00 50 80 00       	mov    %eax,0x805000
  fsipcbuf.read.req_n = n;
  8017a2:	8b 45 10             	mov    0x10(%ebp),%eax
  8017a5:	a3 04 50 80 00       	mov    %eax,0x805004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  8017aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8017af:	b8 03 00 00 00       	mov    $0x3,%eax
  8017b4:	e8 5f fe ff ff       	call   801618 <fsipc>
  8017b9:	89 c3                	mov    %eax,%ebx
  8017bb:	85 c0                	test   %eax,%eax
  8017bd:	78 17                	js     8017d6 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8017c3:	c7 44 24 04 00 50 80 	movl   $0x805000,0x4(%esp)
  8017ca:	00 
  8017cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017ce:	89 04 24             	mov    %eax,(%esp)
  8017d1:	e8 7f f2 ff ff       	call   800a55 <memmove>
  return r;	
}
  8017d6:	89 d8                	mov    %ebx,%eax
  8017d8:	83 c4 14             	add    $0x14,%esp
  8017db:	5b                   	pop    %ebx
  8017dc:	5d                   	pop    %ebp
  8017dd:	c3                   	ret    

008017de <remove>:
}

// Delete a file
int
remove(const char *path)
{
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	53                   	push   %ebx
  8017e2:	83 ec 14             	sub    $0x14,%esp
  8017e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  8017e8:	89 1c 24             	mov    %ebx,(%esp)
  8017eb:	e8 30 f0 ff ff       	call   800820 <strlen>
  8017f0:	89 c2                	mov    %eax,%edx
  8017f2:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  8017f7:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  8017fd:	7f 1f                	jg     80181e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  8017ff:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801803:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  80180a:	e8 5b f0 ff ff       	call   80086a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  80180f:	ba 00 00 00 00       	mov    $0x0,%edx
  801814:	b8 07 00 00 00       	mov    $0x7,%eax
  801819:	e8 fa fd ff ff       	call   801618 <fsipc>
}
  80181e:	83 c4 14             	add    $0x14,%esp
  801821:	5b                   	pop    %ebx
  801822:	5d                   	pop    %ebp
  801823:	c3                   	ret    

00801824 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	83 ec 28             	sub    $0x28,%esp
  80182a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80182d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801830:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801833:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801836:	89 04 24             	mov    %eax,(%esp)
  801839:	e8 dd f7 ff ff       	call   80101b <fd_alloc>
  80183e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801840:	85 c0                	test   %eax,%eax
  801842:	0f 88 89 00 00 00    	js     8018d1 <open+0xad>

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801848:	89 34 24             	mov    %esi,(%esp)
  80184b:	e8 d0 ef ff ff       	call   800820 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801850:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
   //     r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
   //     if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801855:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80185a:	7f 75                	jg     8018d1 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  80185c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801860:	c7 04 24 00 50 80 00 	movl   $0x805000,(%esp)
  801867:	e8 fe ef ff ff       	call   80086a <strcpy>
  fsipcbuf.open.req_omode = mode;
  80186c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186f:	a3 00 54 80 00       	mov    %eax,0x805400
  r = fsipc(FSREQ_OPEN, fd);
  801874:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801877:	b8 01 00 00 00       	mov    $0x1,%eax
  80187c:	e8 97 fd ff ff       	call   801618 <fsipc>
  801881:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801883:	85 c0                	test   %eax,%eax
  801885:	78 0f                	js     801896 <open+0x72>
  return fd2num(fd);
  801887:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80188a:	89 04 24             	mov    %eax,(%esp)
  80188d:	e8 5e f7 ff ff       	call   800ff0 <fd2num>
  801892:	89 c3                	mov    %eax,%ebx
  801894:	eb 3b                	jmp    8018d1 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801896:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80189d:	00 
  80189e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a1:	89 04 24             	mov    %eax,(%esp)
  8018a4:	e8 2b fb ff ff       	call   8013d4 <fd_close>
  8018a9:	85 c0                	test   %eax,%eax
  8018ab:	74 24                	je     8018d1 <open+0xad>
  8018ad:	c7 44 24 0c 50 21 80 	movl   $0x802150,0xc(%esp)
  8018b4:	00 
  8018b5:	c7 44 24 08 65 21 80 	movl   $0x802165,0x8(%esp)
  8018bc:	00 
  8018bd:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  8018c4:	00 
  8018c5:	c7 04 24 7a 21 80 00 	movl   $0x80217a,(%esp)
  8018cc:	e8 0f 00 00 00       	call   8018e0 <_panic>
  return r;
}
  8018d1:	89 d8                	mov    %ebx,%eax
  8018d3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8018d6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8018d9:	89 ec                	mov    %ebp,%esp
  8018db:	5d                   	pop    %ebp
  8018dc:	c3                   	ret    
  8018dd:	00 00                	add    %al,(%eax)
	...

008018e0 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
  8018e3:	56                   	push   %esi
  8018e4:	53                   	push   %ebx
  8018e5:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8018e8:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8018eb:	8b 1d 00 30 80 00    	mov    0x803000,%ebx
  8018f1:	e8 0e f6 ff ff       	call   800f04 <sys_getenvid>
  8018f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f9:	89 54 24 10          	mov    %edx,0x10(%esp)
  8018fd:	8b 55 08             	mov    0x8(%ebp),%edx
  801900:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801904:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801908:	89 44 24 04          	mov    %eax,0x4(%esp)
  80190c:	c7 04 24 88 21 80 00 	movl   $0x802188,(%esp)
  801913:	e8 15 e8 ff ff       	call   80012d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801918:	89 74 24 04          	mov    %esi,0x4(%esp)
  80191c:	8b 45 10             	mov    0x10(%ebp),%eax
  80191f:	89 04 24             	mov    %eax,(%esp)
  801922:	e8 a5 e7 ff ff       	call   8000cc <vcprintf>
	cprintf("\n");
  801927:	c7 04 24 0c 1d 80 00 	movl   $0x801d0c,(%esp)
  80192e:	e8 fa e7 ff ff       	call   80012d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801933:	cc                   	int3   
  801934:	eb fd                	jmp    801933 <_panic+0x53>
	...

00801940 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801940:	55                   	push   %ebp
  801941:	89 e5                	mov    %esp,%ebp
  801943:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  801946:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  80194c:	b8 01 00 00 00       	mov    $0x1,%eax
  801951:	39 ca                	cmp    %ecx,%edx
  801953:	75 04                	jne    801959 <ipc_find_env+0x19>
  801955:	b0 00                	mov    $0x0,%al
  801957:	eb 0f                	jmp    801968 <ipc_find_env+0x28>
  801959:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80195c:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801962:	8b 12                	mov    (%edx),%edx
  801964:	39 ca                	cmp    %ecx,%edx
  801966:	75 0c                	jne    801974 <ipc_find_env+0x34>
			return envs[i].env_id;
  801968:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80196b:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  801970:	8b 00                	mov    (%eax),%eax
  801972:	eb 0e                	jmp    801982 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801974:	83 c0 01             	add    $0x1,%eax
  801977:	3d 00 04 00 00       	cmp    $0x400,%eax
  80197c:	75 db                	jne    801959 <ipc_find_env+0x19>
  80197e:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801982:	5d                   	pop    %ebp
  801983:	c3                   	ret    

00801984 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801984:	55                   	push   %ebp
  801985:	89 e5                	mov    %esp,%ebp
  801987:	57                   	push   %edi
  801988:	56                   	push   %esi
  801989:	53                   	push   %ebx
  80198a:	83 ec 1c             	sub    $0x1c,%esp
  80198d:	8b 75 08             	mov    0x8(%ebp),%esi
  801990:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801993:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801996:	85 db                	test   %ebx,%ebx
  801998:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  80199d:	0f 44 d8             	cmove  %eax,%ebx
  8019a0:	eb 29                	jmp    8019cb <ipc_send+0x47>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
  8019a2:	85 c0                	test   %eax,%eax
  8019a4:	79 25                	jns    8019cb <ipc_send+0x47>
  8019a6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8019a9:	74 20                	je     8019cb <ipc_send+0x47>
			panic ("ipc: sys try send failed : %e", r);
  8019ab:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019af:	c7 44 24 08 ac 21 80 	movl   $0x8021ac,0x8(%esp)
  8019b6:	00 
  8019b7:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  8019be:	00 
  8019bf:	c7 04 24 ca 21 80 00 	movl   $0x8021ca,(%esp)
  8019c6:	e8 15 ff ff ff       	call   8018e0 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  8019cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ce:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8019d2:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019d6:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8019da:	89 34 24             	mov    %esi,(%esp)
  8019dd:	e8 29 f3 ff ff       	call   800d0b <sys_ipc_try_send>
  8019e2:	85 c0                	test   %eax,%eax
  8019e4:	75 bc                	jne    8019a2 <ipc_send+0x1e>
	{
		if( r < 0 && r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  8019e6:	e8 a6 f4 ff ff       	call   800e91 <sys_yield>
}
  8019eb:	83 c4 1c             	add    $0x1c,%esp
  8019ee:	5b                   	pop    %ebx
  8019ef:	5e                   	pop    %esi
  8019f0:	5f                   	pop    %edi
  8019f1:	5d                   	pop    %ebp
  8019f2:	c3                   	ret    

008019f3 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8019f3:	55                   	push   %ebp
  8019f4:	89 e5                	mov    %esp,%ebp
  8019f6:	83 ec 28             	sub    $0x28,%esp
  8019f9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8019fc:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8019ff:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801a02:	8b 75 08             	mov    0x8(%ebp),%esi
  801a05:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a08:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801a0b:	85 c0                	test   %eax,%eax
  801a0d:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a12:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801a15:	89 04 24             	mov    %eax,(%esp)
  801a18:	e8 b5 f2 ff ff       	call   800cd2 <sys_ipc_recv>
  801a1d:	89 c3                	mov    %eax,%ebx
  801a1f:	85 c0                	test   %eax,%eax
  801a21:	79 2a                	jns    801a4d <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  801a23:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a27:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a2b:	c7 04 24 d4 21 80 00 	movl   $0x8021d4,(%esp)
  801a32:	e8 f6 e6 ff ff       	call   80012d <cprintf>
		if(from_env_store != NULL)
  801a37:	85 f6                	test   %esi,%esi
  801a39:	74 06                	je     801a41 <ipc_recv+0x4e>
			*from_env_store = 0;
  801a3b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  801a41:	85 ff                	test   %edi,%edi
  801a43:	74 2d                	je     801a72 <ipc_recv+0x7f>
			*perm_store = 0;
  801a45:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801a4b:	eb 25                	jmp    801a72 <ipc_recv+0x7f>
		return r;
	}
	if(from_env_store != NULL)
  801a4d:	85 f6                	test   %esi,%esi
  801a4f:	90                   	nop
  801a50:	74 0a                	je     801a5c <ipc_recv+0x69>
		*from_env_store = thisenv->env_ipc_from;
  801a52:	a1 04 40 80 00       	mov    0x804004,%eax
  801a57:	8b 40 74             	mov    0x74(%eax),%eax
  801a5a:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  801a5c:	85 ff                	test   %edi,%edi
  801a5e:	74 0a                	je     801a6a <ipc_recv+0x77>
		*perm_store = thisenv->env_ipc_perm;
  801a60:	a1 04 40 80 00       	mov    0x804004,%eax
  801a65:	8b 40 78             	mov    0x78(%eax),%eax
  801a68:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801a6a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a6f:	8b 58 70             	mov    0x70(%eax),%ebx
}
  801a72:	89 d8                	mov    %ebx,%eax
  801a74:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801a77:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801a7a:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801a7d:	89 ec                	mov    %ebp,%esp
  801a7f:	5d                   	pop    %ebp
  801a80:	c3                   	ret    
	...

00801a90 <__udivdi3>:
  801a90:	55                   	push   %ebp
  801a91:	89 e5                	mov    %esp,%ebp
  801a93:	57                   	push   %edi
  801a94:	56                   	push   %esi
  801a95:	83 ec 10             	sub    $0x10,%esp
  801a98:	8b 45 14             	mov    0x14(%ebp),%eax
  801a9b:	8b 55 08             	mov    0x8(%ebp),%edx
  801a9e:	8b 75 10             	mov    0x10(%ebp),%esi
  801aa1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801aa4:	85 c0                	test   %eax,%eax
  801aa6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801aa9:	75 35                	jne    801ae0 <__udivdi3+0x50>
  801aab:	39 fe                	cmp    %edi,%esi
  801aad:	77 61                	ja     801b10 <__udivdi3+0x80>
  801aaf:	85 f6                	test   %esi,%esi
  801ab1:	75 0b                	jne    801abe <__udivdi3+0x2e>
  801ab3:	b8 01 00 00 00       	mov    $0x1,%eax
  801ab8:	31 d2                	xor    %edx,%edx
  801aba:	f7 f6                	div    %esi
  801abc:	89 c6                	mov    %eax,%esi
  801abe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801ac1:	31 d2                	xor    %edx,%edx
  801ac3:	89 f8                	mov    %edi,%eax
  801ac5:	f7 f6                	div    %esi
  801ac7:	89 c7                	mov    %eax,%edi
  801ac9:	89 c8                	mov    %ecx,%eax
  801acb:	f7 f6                	div    %esi
  801acd:	89 c1                	mov    %eax,%ecx
  801acf:	89 fa                	mov    %edi,%edx
  801ad1:	89 c8                	mov    %ecx,%eax
  801ad3:	83 c4 10             	add    $0x10,%esp
  801ad6:	5e                   	pop    %esi
  801ad7:	5f                   	pop    %edi
  801ad8:	5d                   	pop    %ebp
  801ad9:	c3                   	ret    
  801ada:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ae0:	39 f8                	cmp    %edi,%eax
  801ae2:	77 1c                	ja     801b00 <__udivdi3+0x70>
  801ae4:	0f bd d0             	bsr    %eax,%edx
  801ae7:	83 f2 1f             	xor    $0x1f,%edx
  801aea:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801aed:	75 39                	jne    801b28 <__udivdi3+0x98>
  801aef:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801af2:	0f 86 a0 00 00 00    	jbe    801b98 <__udivdi3+0x108>
  801af8:	39 f8                	cmp    %edi,%eax
  801afa:	0f 82 98 00 00 00    	jb     801b98 <__udivdi3+0x108>
  801b00:	31 ff                	xor    %edi,%edi
  801b02:	31 c9                	xor    %ecx,%ecx
  801b04:	89 c8                	mov    %ecx,%eax
  801b06:	89 fa                	mov    %edi,%edx
  801b08:	83 c4 10             	add    $0x10,%esp
  801b0b:	5e                   	pop    %esi
  801b0c:	5f                   	pop    %edi
  801b0d:	5d                   	pop    %ebp
  801b0e:	c3                   	ret    
  801b0f:	90                   	nop
  801b10:	89 d1                	mov    %edx,%ecx
  801b12:	89 fa                	mov    %edi,%edx
  801b14:	89 c8                	mov    %ecx,%eax
  801b16:	31 ff                	xor    %edi,%edi
  801b18:	f7 f6                	div    %esi
  801b1a:	89 c1                	mov    %eax,%ecx
  801b1c:	89 fa                	mov    %edi,%edx
  801b1e:	89 c8                	mov    %ecx,%eax
  801b20:	83 c4 10             	add    $0x10,%esp
  801b23:	5e                   	pop    %esi
  801b24:	5f                   	pop    %edi
  801b25:	5d                   	pop    %ebp
  801b26:	c3                   	ret    
  801b27:	90                   	nop
  801b28:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b2c:	89 f2                	mov    %esi,%edx
  801b2e:	d3 e0                	shl    %cl,%eax
  801b30:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b33:	b8 20 00 00 00       	mov    $0x20,%eax
  801b38:	2b 45 f4             	sub    -0xc(%ebp),%eax
  801b3b:	89 c1                	mov    %eax,%ecx
  801b3d:	d3 ea                	shr    %cl,%edx
  801b3f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b43:	0b 55 ec             	or     -0x14(%ebp),%edx
  801b46:	d3 e6                	shl    %cl,%esi
  801b48:	89 c1                	mov    %eax,%ecx
  801b4a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  801b4d:	89 fe                	mov    %edi,%esi
  801b4f:	d3 ee                	shr    %cl,%esi
  801b51:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b55:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801b58:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b5b:	d3 e7                	shl    %cl,%edi
  801b5d:	89 c1                	mov    %eax,%ecx
  801b5f:	d3 ea                	shr    %cl,%edx
  801b61:	09 d7                	or     %edx,%edi
  801b63:	89 f2                	mov    %esi,%edx
  801b65:	89 f8                	mov    %edi,%eax
  801b67:	f7 75 ec             	divl   -0x14(%ebp)
  801b6a:	89 d6                	mov    %edx,%esi
  801b6c:	89 c7                	mov    %eax,%edi
  801b6e:	f7 65 e8             	mull   -0x18(%ebp)
  801b71:	39 d6                	cmp    %edx,%esi
  801b73:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801b76:	72 30                	jb     801ba8 <__udivdi3+0x118>
  801b78:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801b7b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801b7f:	d3 e2                	shl    %cl,%edx
  801b81:	39 c2                	cmp    %eax,%edx
  801b83:	73 05                	jae    801b8a <__udivdi3+0xfa>
  801b85:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801b88:	74 1e                	je     801ba8 <__udivdi3+0x118>
  801b8a:	89 f9                	mov    %edi,%ecx
  801b8c:	31 ff                	xor    %edi,%edi
  801b8e:	e9 71 ff ff ff       	jmp    801b04 <__udivdi3+0x74>
  801b93:	90                   	nop
  801b94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801b98:	31 ff                	xor    %edi,%edi
  801b9a:	b9 01 00 00 00       	mov    $0x1,%ecx
  801b9f:	e9 60 ff ff ff       	jmp    801b04 <__udivdi3+0x74>
  801ba4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ba8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  801bab:	31 ff                	xor    %edi,%edi
  801bad:	89 c8                	mov    %ecx,%eax
  801baf:	89 fa                	mov    %edi,%edx
  801bb1:	83 c4 10             	add    $0x10,%esp
  801bb4:	5e                   	pop    %esi
  801bb5:	5f                   	pop    %edi
  801bb6:	5d                   	pop    %ebp
  801bb7:	c3                   	ret    
	...

00801bc0 <__umoddi3>:
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	57                   	push   %edi
  801bc4:	56                   	push   %esi
  801bc5:	83 ec 20             	sub    $0x20,%esp
  801bc8:	8b 55 14             	mov    0x14(%ebp),%edx
  801bcb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801bce:	8b 7d 10             	mov    0x10(%ebp),%edi
  801bd1:	8b 75 0c             	mov    0xc(%ebp),%esi
  801bd4:	85 d2                	test   %edx,%edx
  801bd6:	89 c8                	mov    %ecx,%eax
  801bd8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  801bdb:	75 13                	jne    801bf0 <__umoddi3+0x30>
  801bdd:	39 f7                	cmp    %esi,%edi
  801bdf:	76 3f                	jbe    801c20 <__umoddi3+0x60>
  801be1:	89 f2                	mov    %esi,%edx
  801be3:	f7 f7                	div    %edi
  801be5:	89 d0                	mov    %edx,%eax
  801be7:	31 d2                	xor    %edx,%edx
  801be9:	83 c4 20             	add    $0x20,%esp
  801bec:	5e                   	pop    %esi
  801bed:	5f                   	pop    %edi
  801bee:	5d                   	pop    %ebp
  801bef:	c3                   	ret    
  801bf0:	39 f2                	cmp    %esi,%edx
  801bf2:	77 4c                	ja     801c40 <__umoddi3+0x80>
  801bf4:	0f bd ca             	bsr    %edx,%ecx
  801bf7:	83 f1 1f             	xor    $0x1f,%ecx
  801bfa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801bfd:	75 51                	jne    801c50 <__umoddi3+0x90>
  801bff:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801c02:	0f 87 e0 00 00 00    	ja     801ce8 <__umoddi3+0x128>
  801c08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c0b:	29 f8                	sub    %edi,%eax
  801c0d:	19 d6                	sbb    %edx,%esi
  801c0f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801c12:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c15:	89 f2                	mov    %esi,%edx
  801c17:	83 c4 20             	add    $0x20,%esp
  801c1a:	5e                   	pop    %esi
  801c1b:	5f                   	pop    %edi
  801c1c:	5d                   	pop    %ebp
  801c1d:	c3                   	ret    
  801c1e:	66 90                	xchg   %ax,%ax
  801c20:	85 ff                	test   %edi,%edi
  801c22:	75 0b                	jne    801c2f <__umoddi3+0x6f>
  801c24:	b8 01 00 00 00       	mov    $0x1,%eax
  801c29:	31 d2                	xor    %edx,%edx
  801c2b:	f7 f7                	div    %edi
  801c2d:	89 c7                	mov    %eax,%edi
  801c2f:	89 f0                	mov    %esi,%eax
  801c31:	31 d2                	xor    %edx,%edx
  801c33:	f7 f7                	div    %edi
  801c35:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c38:	f7 f7                	div    %edi
  801c3a:	eb a9                	jmp    801be5 <__umoddi3+0x25>
  801c3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c40:	89 c8                	mov    %ecx,%eax
  801c42:	89 f2                	mov    %esi,%edx
  801c44:	83 c4 20             	add    $0x20,%esp
  801c47:	5e                   	pop    %esi
  801c48:	5f                   	pop    %edi
  801c49:	5d                   	pop    %ebp
  801c4a:	c3                   	ret    
  801c4b:	90                   	nop
  801c4c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c50:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c54:	d3 e2                	shl    %cl,%edx
  801c56:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801c59:	ba 20 00 00 00       	mov    $0x20,%edx
  801c5e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801c61:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801c64:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801c68:	89 fa                	mov    %edi,%edx
  801c6a:	d3 ea                	shr    %cl,%edx
  801c6c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c70:	0b 55 f4             	or     -0xc(%ebp),%edx
  801c73:	d3 e7                	shl    %cl,%edi
  801c75:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801c79:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801c7c:	89 f2                	mov    %esi,%edx
  801c7e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801c81:	89 c7                	mov    %eax,%edi
  801c83:	d3 ea                	shr    %cl,%edx
  801c85:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c89:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  801c8c:	89 c2                	mov    %eax,%edx
  801c8e:	d3 e6                	shl    %cl,%esi
  801c90:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801c94:	d3 ea                	shr    %cl,%edx
  801c96:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801c9a:	09 d6                	or     %edx,%esi
  801c9c:	89 f0                	mov    %esi,%eax
  801c9e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801ca1:	d3 e7                	shl    %cl,%edi
  801ca3:	89 f2                	mov    %esi,%edx
  801ca5:	f7 75 f4             	divl   -0xc(%ebp)
  801ca8:	89 d6                	mov    %edx,%esi
  801caa:	f7 65 e8             	mull   -0x18(%ebp)
  801cad:	39 d6                	cmp    %edx,%esi
  801caf:	72 2b                	jb     801cdc <__umoddi3+0x11c>
  801cb1:	39 c7                	cmp    %eax,%edi
  801cb3:	72 23                	jb     801cd8 <__umoddi3+0x118>
  801cb5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801cb9:	29 c7                	sub    %eax,%edi
  801cbb:	19 d6                	sbb    %edx,%esi
  801cbd:	89 f0                	mov    %esi,%eax
  801cbf:	89 f2                	mov    %esi,%edx
  801cc1:	d3 ef                	shr    %cl,%edi
  801cc3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801cc7:	d3 e0                	shl    %cl,%eax
  801cc9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801ccd:	09 f8                	or     %edi,%eax
  801ccf:	d3 ea                	shr    %cl,%edx
  801cd1:	83 c4 20             	add    $0x20,%esp
  801cd4:	5e                   	pop    %esi
  801cd5:	5f                   	pop    %edi
  801cd6:	5d                   	pop    %ebp
  801cd7:	c3                   	ret    
  801cd8:	39 d6                	cmp    %edx,%esi
  801cda:	75 d9                	jne    801cb5 <__umoddi3+0xf5>
  801cdc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  801cdf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801ce2:	eb d1                	jmp    801cb5 <__umoddi3+0xf5>
  801ce4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801ce8:	39 f2                	cmp    %esi,%edx
  801cea:	0f 82 18 ff ff ff    	jb     801c08 <__umoddi3+0x48>
  801cf0:	e9 1d ff ff ff       	jmp    801c12 <__umoddi3+0x52>
