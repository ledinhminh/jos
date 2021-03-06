
obj/user/pingpongs.debug:     file format elf32-i386


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
  80002c:	e8 1b 01 00 00       	call   80014c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
	...

00800034 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800034:	55                   	push   %ebp
  800035:	89 e5                	mov    %esp,%ebp
  800037:	57                   	push   %edi
  800038:	56                   	push   %esi
  800039:	53                   	push   %ebx
  80003a:	83 ec 4c             	sub    $0x4c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  80003d:	e8 0e 11 00 00       	call   801150 <sfork>
  800042:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	74 5e                	je     8000a7 <umain+0x73>
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  800049:	8b 1d 0c 50 80 00    	mov    0x80500c,%ebx
  80004f:	e8 13 10 00 00       	call   801067 <sys_getenvid>
  800054:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800058:	89 44 24 04          	mov    %eax,0x4(%esp)
  80005c:	c7 04 24 80 28 80 00 	movl   $0x802880,(%esp)
  800063:	e8 b1 01 00 00       	call   800219 <cprintf>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  800068:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  80006b:	e8 f7 0f 00 00       	call   801067 <sys_getenvid>
  800070:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800074:	89 44 24 04          	mov    %eax,0x4(%esp)
  800078:	c7 04 24 9a 28 80 00 	movl   $0x80289a,(%esp)
  80007f:	e8 95 01 00 00       	call   800219 <cprintf>
		ipc_send(who, 0, 0, 0);
  800084:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80008b:	00 
  80008c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800093:	00 
  800094:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80009b:	00 
  80009c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80009f:	89 04 24             	mov    %eax,(%esp)
  8000a2:	e8 3d 15 00 00       	call   8015e4 <ipc_send>
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  8000a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b6:	00 
  8000b7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8000ba:	89 04 24             	mov    %eax,(%esp)
  8000bd:	e8 8d 15 00 00       	call   80164f <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  8000c2:	8b 1d 0c 50 80 00    	mov    0x80500c,%ebx
  8000c8:	8b 73 48             	mov    0x48(%ebx),%esi
  8000cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8000ce:	8b 15 08 50 80 00    	mov    0x805008,%edx
  8000d4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8000d7:	e8 8b 0f 00 00       	call   801067 <sys_getenvid>
  8000dc:	89 74 24 14          	mov    %esi,0x14(%esp)
  8000e0:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  8000e4:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8000e8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
  8000eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8000ef:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f3:	c7 04 24 b0 28 80 00 	movl   $0x8028b0,(%esp)
  8000fa:	e8 1a 01 00 00       	call   800219 <cprintf>
		if (val == 10)
  8000ff:	a1 08 50 80 00       	mov    0x805008,%eax
  800104:	83 f8 0a             	cmp    $0xa,%eax
  800107:	74 38                	je     800141 <umain+0x10d>
			return;
		++val;
  800109:	83 c0 01             	add    $0x1,%eax
  80010c:	a3 08 50 80 00       	mov    %eax,0x805008
		ipc_send(who, 0, 0, 0);
  800111:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800118:	00 
  800119:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800120:	00 
  800121:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800128:	00 
  800129:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80012c:	89 04 24             	mov    %eax,(%esp)
  80012f:	e8 b0 14 00 00       	call   8015e4 <ipc_send>
		if (val == 10)
  800134:	83 3d 08 50 80 00 0a 	cmpl   $0xa,0x805008
  80013b:	0f 85 66 ff ff ff    	jne    8000a7 <umain+0x73>
			return;
	}

}
  800141:	83 c4 4c             	add    $0x4c,%esp
  800144:	5b                   	pop    %ebx
  800145:	5e                   	pop    %esi
  800146:	5f                   	pop    %edi
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    
  800149:	00 00                	add    %al,(%eax)
	...

0080014c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
  800152:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800155:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800158:	8b 75 08             	mov    0x8(%ebp),%esi
  80015b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = envs + ENVX(sys_getenvid ());
  80015e:	e8 04 0f 00 00       	call   801067 <sys_getenvid>
  800163:	25 ff 03 00 00       	and    $0x3ff,%eax
  800168:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80016b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800170:	a3 0c 50 80 00       	mov    %eax,0x80500c

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800175:	85 f6                	test   %esi,%esi
  800177:	7e 07                	jle    800180 <libmain+0x34>
		binaryname = argv[0];
  800179:	8b 03                	mov    (%ebx),%eax
  80017b:	a3 00 40 80 00       	mov    %eax,0x804000

	// call user main routine
	umain(argc, argv);
  800180:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800184:	89 34 24             	mov    %esi,(%esp)
  800187:	e8 a8 fe ff ff       	call   800034 <umain>

	// exit gracefully
	exit();
  80018c:	e8 0b 00 00 00       	call   80019c <exit>
}
  800191:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800194:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800197:	89 ec                	mov    %ebp,%esp
  800199:	5d                   	pop    %ebp
  80019a:	c3                   	ret    
	...

0080019c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80019c:	55                   	push   %ebp
  80019d:	89 e5                	mov    %esp,%ebp
  80019f:	83 ec 18             	sub    $0x18,%esp
	close_all();
  8001a2:	e8 22 1a 00 00       	call   801bc9 <close_all>
	sys_env_destroy(0);
  8001a7:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001ae:	e8 ef 0e 00 00       	call   8010a2 <sys_env_destroy>
}
  8001b3:	c9                   	leave  
  8001b4:	c3                   	ret    
  8001b5:	00 00                	add    %al,(%eax)
	...

008001b8 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001c1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c8:	00 00 00 
	b.cnt = 0;
  8001cb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8001df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ed:	c7 04 24 33 02 80 00 	movl   $0x800233,(%esp)
  8001f4:	e8 d4 01 00 00       	call   8003cd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f9:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800203:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800209:	89 04 24             	mov    %eax,(%esp)
  80020c:	e8 05 0f 00 00       	call   801116 <sys_cputs>

	return b.cnt;
}
  800211:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800217:	c9                   	leave  
  800218:	c3                   	ret    

00800219 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80021f:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800222:	89 44 24 04          	mov    %eax,0x4(%esp)
  800226:	8b 45 08             	mov    0x8(%ebp),%eax
  800229:	89 04 24             	mov    %eax,(%esp)
  80022c:	e8 87 ff ff ff       	call   8001b8 <vcprintf>
	va_end(ap);

	return cnt;
}
  800231:	c9                   	leave  
  800232:	c3                   	ret    

00800233 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	53                   	push   %ebx
  800237:	83 ec 14             	sub    $0x14,%esp
  80023a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80023d:	8b 03                	mov    (%ebx),%eax
  80023f:	8b 55 08             	mov    0x8(%ebp),%edx
  800242:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800246:	83 c0 01             	add    $0x1,%eax
  800249:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80024b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800250:	75 19                	jne    80026b <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800252:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800259:	00 
  80025a:	8d 43 08             	lea    0x8(%ebx),%eax
  80025d:	89 04 24             	mov    %eax,(%esp)
  800260:	e8 b1 0e 00 00       	call   801116 <sys_cputs>
		b->idx = 0;
  800265:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80026b:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80026f:	83 c4 14             	add    $0x14,%esp
  800272:	5b                   	pop    %ebx
  800273:	5d                   	pop    %ebp
  800274:	c3                   	ret    
	...

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 4c             	sub    $0x4c,%esp
  800289:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80028c:	89 d6                	mov    %edx,%esi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800294:	8b 55 0c             	mov    0xc(%ebp),%edx
  800297:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80029a:	8b 45 10             	mov    0x10(%ebp),%eax
  80029d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002a0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ab:	39 d1                	cmp    %edx,%ecx
  8002ad:	72 15                	jb     8002c4 <printnum+0x44>
  8002af:	77 07                	ja     8002b8 <printnum+0x38>
  8002b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002b4:	39 d0                	cmp    %edx,%eax
  8002b6:	76 0c                	jbe    8002c4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b8:	83 eb 01             	sub    $0x1,%ebx
  8002bb:	85 db                	test   %ebx,%ebx
  8002bd:	8d 76 00             	lea    0x0(%esi),%esi
  8002c0:	7f 61                	jg     800323 <printnum+0xa3>
  8002c2:	eb 70                	jmp    800334 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002c4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002c8:	83 eb 01             	sub    $0x1,%ebx
  8002cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8002d7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8002db:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8002de:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8002e1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ef:	00 
  8002f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002f3:	89 04 24             	mov    %eax,(%esp)
  8002f6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8002f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002fd:	e8 0e 23 00 00       	call   802610 <__udivdi3>
  800302:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800305:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800308:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80030c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800310:	89 04 24             	mov    %eax,(%esp)
  800313:	89 54 24 04          	mov    %edx,0x4(%esp)
  800317:	89 f2                	mov    %esi,%edx
  800319:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80031c:	e8 5f ff ff ff       	call   800280 <printnum>
  800321:	eb 11                	jmp    800334 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800323:	89 74 24 04          	mov    %esi,0x4(%esp)
  800327:	89 3c 24             	mov    %edi,(%esp)
  80032a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80032d:	83 eb 01             	sub    $0x1,%ebx
  800330:	85 db                	test   %ebx,%ebx
  800332:	7f ef                	jg     800323 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800334:	89 74 24 04          	mov    %esi,0x4(%esp)
  800338:	8b 74 24 04          	mov    0x4(%esp),%esi
  80033c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80033f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800343:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80034a:	00 
  80034b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80034e:	89 14 24             	mov    %edx,(%esp)
  800351:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800354:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800358:	e8 e3 23 00 00       	call   802740 <__umoddi3>
  80035d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800361:	0f be 80 e0 28 80 00 	movsbl 0x8028e0(%eax),%eax
  800368:	89 04 24             	mov    %eax,(%esp)
  80036b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80036e:	83 c4 4c             	add    $0x4c,%esp
  800371:	5b                   	pop    %ebx
  800372:	5e                   	pop    %esi
  800373:	5f                   	pop    %edi
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800379:	83 fa 01             	cmp    $0x1,%edx
  80037c:	7e 0e                	jle    80038c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80037e:	8b 10                	mov    (%eax),%edx
  800380:	8d 4a 08             	lea    0x8(%edx),%ecx
  800383:	89 08                	mov    %ecx,(%eax)
  800385:	8b 02                	mov    (%edx),%eax
  800387:	8b 52 04             	mov    0x4(%edx),%edx
  80038a:	eb 22                	jmp    8003ae <getuint+0x38>
	else if (lflag)
  80038c:	85 d2                	test   %edx,%edx
  80038e:	74 10                	je     8003a0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800390:	8b 10                	mov    (%eax),%edx
  800392:	8d 4a 04             	lea    0x4(%edx),%ecx
  800395:	89 08                	mov    %ecx,(%eax)
  800397:	8b 02                	mov    (%edx),%eax
  800399:	ba 00 00 00 00       	mov    $0x0,%edx
  80039e:	eb 0e                	jmp    8003ae <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003a0:	8b 10                	mov    (%eax),%edx
  8003a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a5:	89 08                	mov    %ecx,(%eax)
  8003a7:	8b 02                	mov    (%edx),%eax
  8003a9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ae:	5d                   	pop    %ebp
  8003af:	c3                   	ret    

008003b0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003b0:	55                   	push   %ebp
  8003b1:	89 e5                	mov    %esp,%ebp
  8003b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003ba:	8b 10                	mov    (%eax),%edx
  8003bc:	3b 50 04             	cmp    0x4(%eax),%edx
  8003bf:	73 0a                	jae    8003cb <sprintputch+0x1b>
		*b->buf++ = ch;
  8003c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c4:	88 0a                	mov    %cl,(%edx)
  8003c6:	83 c2 01             	add    $0x1,%edx
  8003c9:	89 10                	mov    %edx,(%eax)
}
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	57                   	push   %edi
  8003d1:	56                   	push   %esi
  8003d2:	53                   	push   %ebx
  8003d3:	83 ec 5c             	sub    $0x5c,%esp
  8003d6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003d9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003df:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003e6:	eb 11                	jmp    8003f9 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003e8:	85 c0                	test   %eax,%eax
  8003ea:	0f 84 68 04 00 00    	je     800858 <vprintfmt+0x48b>
				return;
			putch(ch, putdat);
  8003f0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003f4:	89 04 24             	mov    %eax,(%esp)
  8003f7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f9:	0f b6 03             	movzbl (%ebx),%eax
  8003fc:	83 c3 01             	add    $0x1,%ebx
  8003ff:	83 f8 25             	cmp    $0x25,%eax
  800402:	75 e4                	jne    8003e8 <vprintfmt+0x1b>
  800404:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80040b:	c7 45 d4 ff ff ff ff 	movl   $0xffffffff,-0x2c(%ebp)
  800412:	b9 00 00 00 00       	mov    $0x0,%ecx
  800417:	c6 45 e0 20          	movb   $0x20,-0x20(%ebp)
  80041b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800422:	eb 06                	jmp    80042a <vprintfmt+0x5d>
  800424:	c6 45 e0 2d          	movb   $0x2d,-0x20(%ebp)
  800428:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	0f b6 13             	movzbl (%ebx),%edx
  80042d:	0f b6 c2             	movzbl %dl,%eax
  800430:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800433:	8d 43 01             	lea    0x1(%ebx),%eax
  800436:	83 ea 23             	sub    $0x23,%edx
  800439:	80 fa 55             	cmp    $0x55,%dl
  80043c:	0f 87 f9 03 00 00    	ja     80083b <vprintfmt+0x46e>
  800442:	0f b6 d2             	movzbl %dl,%edx
  800445:	ff 24 95 c0 2a 80 00 	jmp    *0x802ac0(,%edx,4)
  80044c:	c6 45 e0 30          	movb   $0x30,-0x20(%ebp)
  800450:	eb d6                	jmp    800428 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800452:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800455:	83 ea 30             	sub    $0x30,%edx
  800458:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80045b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80045e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800461:	83 fb 09             	cmp    $0x9,%ebx
  800464:	77 54                	ja     8004ba <vprintfmt+0xed>
  800466:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  800469:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80046c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80046f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800472:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800476:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800479:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80047c:	83 fb 09             	cmp    $0x9,%ebx
  80047f:	76 eb                	jbe    80046c <vprintfmt+0x9f>
  800481:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800484:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800487:	eb 31                	jmp    8004ba <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800489:	8b 55 14             	mov    0x14(%ebp),%edx
  80048c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80048f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800492:	8b 12                	mov    (%edx),%edx
  800494:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800497:	eb 21                	jmp    8004ba <vprintfmt+0xed>

		case '.':
			if (width < 0)
  800499:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80049d:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a2:	0f 49 55 d4          	cmovns -0x2c(%ebp),%edx
  8004a6:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004a9:	e9 7a ff ff ff       	jmp    800428 <vprintfmt+0x5b>
  8004ae:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004b5:	e9 6e ff ff ff       	jmp    800428 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8004ba:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004be:	0f 89 64 ff ff ff    	jns    800428 <vprintfmt+0x5b>
  8004c4:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8004c7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8004ca:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8004cd:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8004d0:	e9 53 ff ff ff       	jmp    800428 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004d5:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8004d8:	e9 4b ff ff ff       	jmp    800428 <vprintfmt+0x5b>
  8004dd:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e3:	8d 50 04             	lea    0x4(%eax),%edx
  8004e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004ed:	8b 00                	mov    (%eax),%eax
  8004ef:	89 04 24             	mov    %eax,(%esp)
  8004f2:	ff d7                	call   *%edi
  8004f4:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8004f7:	e9 fd fe ff ff       	jmp    8003f9 <vprintfmt+0x2c>
  8004fc:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800502:	8d 50 04             	lea    0x4(%eax),%edx
  800505:	89 55 14             	mov    %edx,0x14(%ebp)
  800508:	8b 00                	mov    (%eax),%eax
  80050a:	89 c2                	mov    %eax,%edx
  80050c:	c1 fa 1f             	sar    $0x1f,%edx
  80050f:	31 d0                	xor    %edx,%eax
  800511:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800513:	83 f8 0f             	cmp    $0xf,%eax
  800516:	7f 0b                	jg     800523 <vprintfmt+0x156>
  800518:	8b 14 85 20 2c 80 00 	mov    0x802c20(,%eax,4),%edx
  80051f:	85 d2                	test   %edx,%edx
  800521:	75 20                	jne    800543 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800523:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800527:	c7 44 24 08 f1 28 80 	movl   $0x8028f1,0x8(%esp)
  80052e:	00 
  80052f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800533:	89 3c 24             	mov    %edi,(%esp)
  800536:	e8 a5 03 00 00       	call   8008e0 <printfmt>
  80053b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80053e:	e9 b6 fe ff ff       	jmp    8003f9 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800543:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800547:	c7 44 24 08 b3 2f 80 	movl   $0x802fb3,0x8(%esp)
  80054e:	00 
  80054f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800553:	89 3c 24             	mov    %edi,(%esp)
  800556:	e8 85 03 00 00       	call   8008e0 <printfmt>
  80055b:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80055e:	e9 96 fe ff ff       	jmp    8003f9 <vprintfmt+0x2c>
  800563:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800566:	89 c3                	mov    %eax,%ebx
  800568:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80056b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  80056e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 50 04             	lea    0x4(%eax),%edx
  800577:	89 55 14             	mov    %edx,0x14(%ebp)
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80057f:	85 c0                	test   %eax,%eax
  800581:	b8 fa 28 80 00       	mov    $0x8028fa,%eax
  800586:	0f 45 45 e4          	cmovne -0x1c(%ebp),%eax
  80058a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80058d:	83 7d c4 00          	cmpl   $0x0,-0x3c(%ebp)
  800591:	7e 06                	jle    800599 <vprintfmt+0x1cc>
  800593:	80 7d e0 2d          	cmpb   $0x2d,-0x20(%ebp)
  800597:	75 13                	jne    8005ac <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800599:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80059c:	0f be 02             	movsbl (%edx),%eax
  80059f:	85 c0                	test   %eax,%eax
  8005a1:	0f 85 a2 00 00 00    	jne    800649 <vprintfmt+0x27c>
  8005a7:	e9 8f 00 00 00       	jmp    80063b <vprintfmt+0x26e>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ac:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005b0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005b3:	89 0c 24             	mov    %ecx,(%esp)
  8005b6:	e8 70 03 00 00       	call   80092b <strnlen>
  8005bb:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005be:	29 c2                	sub    %eax,%edx
  8005c0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  8005c3:	85 d2                	test   %edx,%edx
  8005c5:	7e d2                	jle    800599 <vprintfmt+0x1cc>
					putch(padc, putdat);
  8005c7:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  8005cb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005ce:	89 5d c4             	mov    %ebx,-0x3c(%ebp)
  8005d1:	89 d3                	mov    %edx,%ebx
  8005d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005da:	89 04 24             	mov    %eax,(%esp)
  8005dd:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005df:	83 eb 01             	sub    $0x1,%ebx
  8005e2:	85 db                	test   %ebx,%ebx
  8005e4:	7f ed                	jg     8005d3 <vprintfmt+0x206>
  8005e6:	8b 5d c4             	mov    -0x3c(%ebp),%ebx
  8005e9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
  8005f0:	eb a7                	jmp    800599 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005f2:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005f6:	74 1b                	je     800613 <vprintfmt+0x246>
  8005f8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005fb:	83 fa 5e             	cmp    $0x5e,%edx
  8005fe:	76 13                	jbe    800613 <vprintfmt+0x246>
					putch('?', putdat);
  800600:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800603:	89 54 24 04          	mov    %edx,0x4(%esp)
  800607:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80060e:	ff 55 e4             	call   *-0x1c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800611:	eb 0d                	jmp    800620 <vprintfmt+0x253>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800613:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800616:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  80061a:	89 04 24             	mov    %eax,(%esp)
  80061d:	ff 55 e4             	call   *-0x1c(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800620:	83 ef 01             	sub    $0x1,%edi
  800623:	0f be 03             	movsbl (%ebx),%eax
  800626:	85 c0                	test   %eax,%eax
  800628:	74 05                	je     80062f <vprintfmt+0x262>
  80062a:	83 c3 01             	add    $0x1,%ebx
  80062d:	eb 31                	jmp    800660 <vprintfmt+0x293>
  80062f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800632:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800635:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800638:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80063b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80063f:	7f 36                	jg     800677 <vprintfmt+0x2aa>
  800641:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800644:	e9 b0 fd ff ff       	jmp    8003f9 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800649:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80064c:	83 c2 01             	add    $0x1,%edx
  80064f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  800652:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800655:	89 75 e0             	mov    %esi,-0x20(%ebp)
  800658:	8b 75 cc             	mov    -0x34(%ebp),%esi
  80065b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  80065e:	89 d3                	mov    %edx,%ebx
  800660:	85 f6                	test   %esi,%esi
  800662:	78 8e                	js     8005f2 <vprintfmt+0x225>
  800664:	83 ee 01             	sub    $0x1,%esi
  800667:	79 89                	jns    8005f2 <vprintfmt+0x225>
  800669:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80066c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80066f:	8b 75 e0             	mov    -0x20(%ebp),%esi
  800672:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800675:	eb c4                	jmp    80063b <vprintfmt+0x26e>
  800677:	89 5d d8             	mov    %ebx,-0x28(%ebp)
  80067a:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80067d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800681:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800688:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80068a:	83 eb 01             	sub    $0x1,%ebx
  80068d:	85 db                	test   %ebx,%ebx
  80068f:	7f ec                	jg     80067d <vprintfmt+0x2b0>
  800691:	8b 5d d8             	mov    -0x28(%ebp),%ebx
  800694:	e9 60 fd ff ff       	jmp    8003f9 <vprintfmt+0x2c>
  800699:	89 45 d0             	mov    %eax,-0x30(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80069c:	83 f9 01             	cmp    $0x1,%ecx
  80069f:	7e 16                	jle    8006b7 <vprintfmt+0x2ea>
		return va_arg(*ap, long long);
  8006a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a4:	8d 50 08             	lea    0x8(%eax),%edx
  8006a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006aa:	8b 10                	mov    (%eax),%edx
  8006ac:	8b 48 04             	mov    0x4(%eax),%ecx
  8006af:	89 55 d8             	mov    %edx,-0x28(%ebp)
  8006b2:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006b5:	eb 32                	jmp    8006e9 <vprintfmt+0x31c>
	else if (lflag)
  8006b7:	85 c9                	test   %ecx,%ecx
  8006b9:	74 18                	je     8006d3 <vprintfmt+0x306>
		return va_arg(*ap, long);
  8006bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8006be:	8d 50 04             	lea    0x4(%eax),%edx
  8006c1:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c4:	8b 00                	mov    (%eax),%eax
  8006c6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006c9:	89 c1                	mov    %eax,%ecx
  8006cb:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ce:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8006d1:	eb 16                	jmp    8006e9 <vprintfmt+0x31c>
	else
		return va_arg(*ap, int);
  8006d3:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d6:	8d 50 04             	lea    0x4(%eax),%edx
  8006d9:	89 55 14             	mov    %edx,0x14(%ebp)
  8006dc:	8b 00                	mov    (%eax),%eax
  8006de:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006e1:	89 c2                	mov    %eax,%edx
  8006e3:	c1 fa 1f             	sar    $0x1f,%edx
  8006e6:	89 55 dc             	mov    %edx,-0x24(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006e9:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8006ec:	8b 55 dc             	mov    -0x24(%ebp),%edx
  8006ef:	bb 0a 00 00 00       	mov    $0xa,%ebx
			if ((long long) num < 0) {
  8006f4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8006f8:	0f 89 8a 00 00 00    	jns    800788 <vprintfmt+0x3bb>
				putch('-', putdat);
  8006fe:	89 74 24 04          	mov    %esi,0x4(%esp)
  800702:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800709:	ff d7                	call   *%edi
				num = -(long long) num;
  80070b:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80070e:	8b 55 dc             	mov    -0x24(%ebp),%edx
  800711:	f7 d8                	neg    %eax
  800713:	83 d2 00             	adc    $0x0,%edx
  800716:	f7 da                	neg    %edx
  800718:	eb 6e                	jmp    800788 <vprintfmt+0x3bb>
  80071a:	89 45 d0             	mov    %eax,-0x30(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80071d:	89 ca                	mov    %ecx,%edx
  80071f:	8d 45 14             	lea    0x14(%ebp),%eax
  800722:	e8 4f fc ff ff       	call   800376 <getuint>
  800727:	bb 0a 00 00 00       	mov    $0xa,%ebx
			base = 10;
			goto number;
  80072c:	eb 5a                	jmp    800788 <vprintfmt+0x3bb>
  80072e:	89 45 d0             	mov    %eax,-0x30(%ebp)
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			num = getuint(&ap, lflag);
  800731:	89 ca                	mov    %ecx,%edx
  800733:	8d 45 14             	lea    0x14(%ebp),%eax
  800736:	e8 3b fc ff ff       	call   800376 <getuint>
  80073b:	bb 08 00 00 00       	mov    $0x8,%ebx
			base = 8;
			goto number;
  800740:	eb 46                	jmp    800788 <vprintfmt+0x3bb>
  800742:	89 45 d0             	mov    %eax,-0x30(%ebp)
			

		// pointer
		case 'p':
			putch('0', putdat);
  800745:	89 74 24 04          	mov    %esi,0x4(%esp)
  800749:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800750:	ff d7                	call   *%edi
			putch('x', putdat);
  800752:	89 74 24 04          	mov    %esi,0x4(%esp)
  800756:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  80075d:	ff d7                	call   *%edi
			num = (unsigned long long)
  80075f:	8b 45 14             	mov    0x14(%ebp),%eax
  800762:	8d 50 04             	lea    0x4(%eax),%edx
  800765:	89 55 14             	mov    %edx,0x14(%ebp)
  800768:	8b 00                	mov    (%eax),%eax
  80076a:	ba 00 00 00 00       	mov    $0x0,%edx
  80076f:	bb 10 00 00 00       	mov    $0x10,%ebx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800774:	eb 12                	jmp    800788 <vprintfmt+0x3bb>
  800776:	89 45 d0             	mov    %eax,-0x30(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800779:	89 ca                	mov    %ecx,%edx
  80077b:	8d 45 14             	lea    0x14(%ebp),%eax
  80077e:	e8 f3 fb ff ff       	call   800376 <getuint>
  800783:	bb 10 00 00 00       	mov    $0x10,%ebx
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800788:	0f be 4d e0          	movsbl -0x20(%ebp),%ecx
  80078c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800790:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
  800793:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800797:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80079b:	89 04 24             	mov    %eax,(%esp)
  80079e:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007a2:	89 f2                	mov    %esi,%edx
  8007a4:	89 f8                	mov    %edi,%eax
  8007a6:	e8 d5 fa ff ff       	call   800280 <printnum>
  8007ab:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8007ae:	e9 46 fc ff ff       	jmp    8003f9 <vprintfmt+0x2c>
  8007b3:	89 45 d0             	mov    %eax,-0x30(%ebp)

            const char *null_error = "\nerror! writing through NULL pointer! (%n argument)\n";
            const char *overflow_error = "\nwarning! The value %n argument pointed to has been overflowed!\n";

            // Your code here
		if ((p = va_arg(ap, void *)) == NULL)
  8007b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b9:	8d 50 04             	lea    0x4(%eax),%edx
  8007bc:	89 55 14             	mov    %edx,0x14(%ebp)
  8007bf:	8b 00                	mov    (%eax),%eax
  8007c1:	85 c0                	test   %eax,%eax
  8007c3:	75 24                	jne    8007e9 <vprintfmt+0x41c>
		{		
			printfmt(putch, putdat, "%s", null_error);
  8007c5:	c7 44 24 0c 14 2a 80 	movl   $0x802a14,0xc(%esp)
  8007cc:	00 
  8007cd:	c7 44 24 08 b3 2f 80 	movl   $0x802fb3,0x8(%esp)
  8007d4:	00 
  8007d5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007d9:	89 3c 24             	mov    %edi,(%esp)
  8007dc:	e8 ff 00 00 00       	call   8008e0 <printfmt>
  8007e1:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  8007e4:	e9 10 fc ff ff       	jmp    8003f9 <vprintfmt+0x2c>
		}		
		if( (*(int *)putdat) > 127)
  8007e9:	83 3e 7f             	cmpl   $0x7f,(%esi)
  8007ec:	7e 29                	jle    800817 <vprintfmt+0x44a>
		{
			(*((unsigned char *)p)) = (*((unsigned char *)putdat));
  8007ee:	0f b6 16             	movzbl (%esi),%edx
  8007f1:	88 10                	mov    %dl,(%eax)
			printfmt(putch, putdat, "%s", overflow_error);			
  8007f3:	c7 44 24 0c 4c 2a 80 	movl   $0x802a4c,0xc(%esp)
  8007fa:	00 
  8007fb:	c7 44 24 08 b3 2f 80 	movl   $0x802fb3,0x8(%esp)
  800802:	00 
  800803:	89 74 24 04          	mov    %esi,0x4(%esp)
  800807:	89 3c 24             	mov    %edi,(%esp)
  80080a:	e8 d1 00 00 00       	call   8008e0 <printfmt>
  80080f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800812:	e9 e2 fb ff ff       	jmp    8003f9 <vprintfmt+0x2c>
		}

		(*((char *)p)) = (*((char *)putdat));		
  800817:	0f b6 16             	movzbl (%esi),%edx
  80081a:	88 10                	mov    %dl,(%eax)
  80081c:	8b 5d d0             	mov    -0x30(%ebp),%ebx

            break;
  80081f:	e9 d5 fb ff ff       	jmp    8003f9 <vprintfmt+0x2c>
  800824:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800827:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        }

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80082a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80082e:	89 14 24             	mov    %edx,(%esp)
  800831:	ff d7                	call   *%edi
  800833:	8b 5d d0             	mov    -0x30(%ebp),%ebx
			break;
  800836:	e9 be fb ff ff       	jmp    8003f9 <vprintfmt+0x2c>
			
		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80083b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80083f:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800846:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800848:	8d 43 ff             	lea    -0x1(%ebx),%eax
  80084b:	80 38 25             	cmpb   $0x25,(%eax)
  80084e:	0f 84 a5 fb ff ff    	je     8003f9 <vprintfmt+0x2c>
  800854:	89 c3                	mov    %eax,%ebx
  800856:	eb f0                	jmp    800848 <vprintfmt+0x47b>
				/* do nothing */;
			break;
		}
	}
}
  800858:	83 c4 5c             	add    $0x5c,%esp
  80085b:	5b                   	pop    %ebx
  80085c:	5e                   	pop    %esi
  80085d:	5f                   	pop    %edi
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	83 ec 28             	sub    $0x28,%esp
  800866:	8b 45 08             	mov    0x8(%ebp),%eax
  800869:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80086c:	85 c0                	test   %eax,%eax
  80086e:	74 04                	je     800874 <vsnprintf+0x14>
  800870:	85 d2                	test   %edx,%edx
  800872:	7f 07                	jg     80087b <vsnprintf+0x1b>
  800874:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800879:	eb 3b                	jmp    8008b6 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  80087b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80087e:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800882:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800885:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80088c:	8b 45 14             	mov    0x14(%ebp),%eax
  80088f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800893:	8b 45 10             	mov    0x10(%ebp),%eax
  800896:	89 44 24 08          	mov    %eax,0x8(%esp)
  80089a:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80089d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a1:	c7 04 24 b0 03 80 00 	movl   $0x8003b0,(%esp)
  8008a8:	e8 20 fb ff ff       	call   8003cd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008ad:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008b0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008b6:	c9                   	leave  
  8008b7:	c3                   	ret    

008008b8 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8008be:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8008c1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008c5:	8b 45 10             	mov    0x10(%ebp),%eax
  8008c8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d6:	89 04 24             	mov    %eax,(%esp)
  8008d9:	e8 82 ff ff ff       	call   800860 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008de:	c9                   	leave  
  8008df:	c3                   	ret    

008008e0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8008e6:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8008e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008ed:	8b 45 10             	mov    0x10(%ebp),%eax
  8008f0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fe:	89 04 24             	mov    %eax,(%esp)
  800901:	e8 c7 fa ff ff       	call   8003cd <vprintfmt>
	va_end(ap);
}
  800906:	c9                   	leave  
  800907:	c3                   	ret    
	...

00800910 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800916:	b8 00 00 00 00       	mov    $0x0,%eax
  80091b:	80 3a 00             	cmpb   $0x0,(%edx)
  80091e:	74 09                	je     800929 <strlen+0x19>
		n++;
  800920:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800923:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800927:	75 f7                	jne    800920 <strlen+0x10>
		n++;
	return n;
}
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	53                   	push   %ebx
  80092f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800932:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800935:	85 c9                	test   %ecx,%ecx
  800937:	74 19                	je     800952 <strnlen+0x27>
  800939:	80 3b 00             	cmpb   $0x0,(%ebx)
  80093c:	74 14                	je     800952 <strnlen+0x27>
  80093e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800943:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800946:	39 c8                	cmp    %ecx,%eax
  800948:	74 0d                	je     800957 <strnlen+0x2c>
  80094a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80094e:	75 f3                	jne    800943 <strnlen+0x18>
  800950:	eb 05                	jmp    800957 <strnlen+0x2c>
  800952:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800957:	5b                   	pop    %ebx
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	53                   	push   %ebx
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800964:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800969:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80096d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800970:	83 c2 01             	add    $0x1,%edx
  800973:	84 c9                	test   %cl,%cl
  800975:	75 f2                	jne    800969 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800977:	5b                   	pop    %ebx
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	53                   	push   %ebx
  80097e:	83 ec 08             	sub    $0x8,%esp
  800981:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800984:	89 1c 24             	mov    %ebx,(%esp)
  800987:	e8 84 ff ff ff       	call   800910 <strlen>
	strcpy(dst + len, src);
  80098c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800993:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800996:	89 04 24             	mov    %eax,(%esp)
  800999:	e8 bc ff ff ff       	call   80095a <strcpy>
	return dst;
}
  80099e:	89 d8                	mov    %ebx,%eax
  8009a0:	83 c4 08             	add    $0x8,%esp
  8009a3:	5b                   	pop    %ebx
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	56                   	push   %esi
  8009aa:	53                   	push   %ebx
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b4:	85 f6                	test   %esi,%esi
  8009b6:	74 18                	je     8009d0 <strncpy+0x2a>
  8009b8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8009bd:	0f b6 1a             	movzbl (%edx),%ebx
  8009c0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009c3:	80 3a 01             	cmpb   $0x1,(%edx)
  8009c6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c9:	83 c1 01             	add    $0x1,%ecx
  8009cc:	39 ce                	cmp    %ecx,%esi
  8009ce:	77 ed                	ja     8009bd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009d0:	5b                   	pop    %ebx
  8009d1:	5e                   	pop    %esi
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	56                   	push   %esi
  8009d8:	53                   	push   %ebx
  8009d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009e2:	89 f0                	mov    %esi,%eax
  8009e4:	85 c9                	test   %ecx,%ecx
  8009e6:	74 27                	je     800a0f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8009e8:	83 e9 01             	sub    $0x1,%ecx
  8009eb:	74 1d                	je     800a0a <strlcpy+0x36>
  8009ed:	0f b6 1a             	movzbl (%edx),%ebx
  8009f0:	84 db                	test   %bl,%bl
  8009f2:	74 16                	je     800a0a <strlcpy+0x36>
			*dst++ = *src++;
  8009f4:	88 18                	mov    %bl,(%eax)
  8009f6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009f9:	83 e9 01             	sub    $0x1,%ecx
  8009fc:	74 0e                	je     800a0c <strlcpy+0x38>
			*dst++ = *src++;
  8009fe:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a01:	0f b6 1a             	movzbl (%edx),%ebx
  800a04:	84 db                	test   %bl,%bl
  800a06:	75 ec                	jne    8009f4 <strlcpy+0x20>
  800a08:	eb 02                	jmp    800a0c <strlcpy+0x38>
  800a0a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a0c:	c6 00 00             	movb   $0x0,(%eax)
  800a0f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800a11:	5b                   	pop    %ebx
  800a12:	5e                   	pop    %esi
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a1e:	0f b6 01             	movzbl (%ecx),%eax
  800a21:	84 c0                	test   %al,%al
  800a23:	74 15                	je     800a3a <strcmp+0x25>
  800a25:	3a 02                	cmp    (%edx),%al
  800a27:	75 11                	jne    800a3a <strcmp+0x25>
		p++, q++;
  800a29:	83 c1 01             	add    $0x1,%ecx
  800a2c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a2f:	0f b6 01             	movzbl (%ecx),%eax
  800a32:	84 c0                	test   %al,%al
  800a34:	74 04                	je     800a3a <strcmp+0x25>
  800a36:	3a 02                	cmp    (%edx),%al
  800a38:	74 ef                	je     800a29 <strcmp+0x14>
  800a3a:	0f b6 c0             	movzbl %al,%eax
  800a3d:	0f b6 12             	movzbl (%edx),%edx
  800a40:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a42:	5d                   	pop    %ebp
  800a43:	c3                   	ret    

00800a44 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	53                   	push   %ebx
  800a48:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a51:	85 c0                	test   %eax,%eax
  800a53:	74 23                	je     800a78 <strncmp+0x34>
  800a55:	0f b6 1a             	movzbl (%edx),%ebx
  800a58:	84 db                	test   %bl,%bl
  800a5a:	74 25                	je     800a81 <strncmp+0x3d>
  800a5c:	3a 19                	cmp    (%ecx),%bl
  800a5e:	75 21                	jne    800a81 <strncmp+0x3d>
  800a60:	83 e8 01             	sub    $0x1,%eax
  800a63:	74 13                	je     800a78 <strncmp+0x34>
		n--, p++, q++;
  800a65:	83 c2 01             	add    $0x1,%edx
  800a68:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a6b:	0f b6 1a             	movzbl (%edx),%ebx
  800a6e:	84 db                	test   %bl,%bl
  800a70:	74 0f                	je     800a81 <strncmp+0x3d>
  800a72:	3a 19                	cmp    (%ecx),%bl
  800a74:	74 ea                	je     800a60 <strncmp+0x1c>
  800a76:	eb 09                	jmp    800a81 <strncmp+0x3d>
  800a78:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a7d:	5b                   	pop    %ebx
  800a7e:	5d                   	pop    %ebp
  800a7f:	90                   	nop
  800a80:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a81:	0f b6 02             	movzbl (%edx),%eax
  800a84:	0f b6 11             	movzbl (%ecx),%edx
  800a87:	29 d0                	sub    %edx,%eax
  800a89:	eb f2                	jmp    800a7d <strncmp+0x39>

00800a8b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a91:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a95:	0f b6 10             	movzbl (%eax),%edx
  800a98:	84 d2                	test   %dl,%dl
  800a9a:	74 18                	je     800ab4 <strchr+0x29>
		if (*s == c)
  800a9c:	38 ca                	cmp    %cl,%dl
  800a9e:	75 0a                	jne    800aaa <strchr+0x1f>
  800aa0:	eb 17                	jmp    800ab9 <strchr+0x2e>
  800aa2:	38 ca                	cmp    %cl,%dl
  800aa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800aa8:	74 0f                	je     800ab9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aaa:	83 c0 01             	add    $0x1,%eax
  800aad:	0f b6 10             	movzbl (%eax),%edx
  800ab0:	84 d2                	test   %dl,%dl
  800ab2:	75 ee                	jne    800aa2 <strchr+0x17>
  800ab4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac5:	0f b6 10             	movzbl (%eax),%edx
  800ac8:	84 d2                	test   %dl,%dl
  800aca:	74 18                	je     800ae4 <strfind+0x29>
		if (*s == c)
  800acc:	38 ca                	cmp    %cl,%dl
  800ace:	75 0a                	jne    800ada <strfind+0x1f>
  800ad0:	eb 12                	jmp    800ae4 <strfind+0x29>
  800ad2:	38 ca                	cmp    %cl,%dl
  800ad4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ad8:	74 0a                	je     800ae4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ada:	83 c0 01             	add    $0x1,%eax
  800add:	0f b6 10             	movzbl (%eax),%edx
  800ae0:	84 d2                	test   %dl,%dl
  800ae2:	75 ee                	jne    800ad2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	83 ec 0c             	sub    $0xc,%esp
  800aec:	89 1c 24             	mov    %ebx,(%esp)
  800aef:	89 74 24 04          	mov    %esi,0x4(%esp)
  800af3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800af7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800afa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b00:	85 c9                	test   %ecx,%ecx
  800b02:	74 30                	je     800b34 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b04:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b0a:	75 25                	jne    800b31 <memset+0x4b>
  800b0c:	f6 c1 03             	test   $0x3,%cl
  800b0f:	75 20                	jne    800b31 <memset+0x4b>
		c &= 0xFF;
  800b11:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b14:	89 d3                	mov    %edx,%ebx
  800b16:	c1 e3 08             	shl    $0x8,%ebx
  800b19:	89 d6                	mov    %edx,%esi
  800b1b:	c1 e6 18             	shl    $0x18,%esi
  800b1e:	89 d0                	mov    %edx,%eax
  800b20:	c1 e0 10             	shl    $0x10,%eax
  800b23:	09 f0                	or     %esi,%eax
  800b25:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800b27:	09 d8                	or     %ebx,%eax
  800b29:	c1 e9 02             	shr    $0x2,%ecx
  800b2c:	fc                   	cld    
  800b2d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b2f:	eb 03                	jmp    800b34 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b31:	fc                   	cld    
  800b32:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b34:	89 f8                	mov    %edi,%eax
  800b36:	8b 1c 24             	mov    (%esp),%ebx
  800b39:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b3d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800b41:	89 ec                	mov    %ebp,%esp
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	83 ec 08             	sub    $0x8,%esp
  800b4b:	89 34 24             	mov    %esi,(%esp)
  800b4e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b52:	8b 45 08             	mov    0x8(%ebp),%eax
  800b55:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;
	
	s = src;
  800b58:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b5b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b5d:	39 c6                	cmp    %eax,%esi
  800b5f:	73 35                	jae    800b96 <memmove+0x51>
  800b61:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b64:	39 d0                	cmp    %edx,%eax
  800b66:	73 2e                	jae    800b96 <memmove+0x51>
		s += n;
		d += n;
  800b68:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b6a:	f6 c2 03             	test   $0x3,%dl
  800b6d:	75 1b                	jne    800b8a <memmove+0x45>
  800b6f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b75:	75 13                	jne    800b8a <memmove+0x45>
  800b77:	f6 c1 03             	test   $0x3,%cl
  800b7a:	75 0e                	jne    800b8a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800b7c:	83 ef 04             	sub    $0x4,%edi
  800b7f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b82:	c1 e9 02             	shr    $0x2,%ecx
  800b85:	fd                   	std    
  800b86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b88:	eb 09                	jmp    800b93 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b8a:	83 ef 01             	sub    $0x1,%edi
  800b8d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b90:	fd                   	std    
  800b91:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b93:	fc                   	cld    
	const char *s;
	char *d;
	
	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b94:	eb 20                	jmp    800bb6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b96:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b9c:	75 15                	jne    800bb3 <memmove+0x6e>
  800b9e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ba4:	75 0d                	jne    800bb3 <memmove+0x6e>
  800ba6:	f6 c1 03             	test   $0x3,%cl
  800ba9:	75 08                	jne    800bb3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800bab:	c1 e9 02             	shr    $0x2,%ecx
  800bae:	fc                   	cld    
  800baf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb1:	eb 03                	jmp    800bb6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bb3:	fc                   	cld    
  800bb4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bb6:	8b 34 24             	mov    (%esp),%esi
  800bb9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800bbd:	89 ec                	mov    %ebp,%esp
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <memcpy>:

/* sigh - gcc emits references to this for structure assignments! */
/* it is *not* prototyped in inc/string.h - do not use directly. */
void *
memcpy(void *dst, void *src, size_t n)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bc7:	8b 45 10             	mov    0x10(%ebp),%eax
  800bca:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bce:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd8:	89 04 24             	mov    %eax,(%esp)
  800bdb:	e8 65 ff ff ff       	call   800b45 <memmove>
}
  800be0:	c9                   	leave  
  800be1:	c3                   	ret    

00800be2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
  800be8:	8b 75 08             	mov    0x8(%ebp),%esi
  800beb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800bee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bf1:	85 c9                	test   %ecx,%ecx
  800bf3:	74 36                	je     800c2b <memcmp+0x49>
		if (*s1 != *s2)
  800bf5:	0f b6 06             	movzbl (%esi),%eax
  800bf8:	0f b6 1f             	movzbl (%edi),%ebx
  800bfb:	38 d8                	cmp    %bl,%al
  800bfd:	74 20                	je     800c1f <memcmp+0x3d>
  800bff:	eb 14                	jmp    800c15 <memcmp+0x33>
  800c01:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800c06:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800c0b:	83 c2 01             	add    $0x1,%edx
  800c0e:	83 e9 01             	sub    $0x1,%ecx
  800c11:	38 d8                	cmp    %bl,%al
  800c13:	74 12                	je     800c27 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800c15:	0f b6 c0             	movzbl %al,%eax
  800c18:	0f b6 db             	movzbl %bl,%ebx
  800c1b:	29 d8                	sub    %ebx,%eax
  800c1d:	eb 11                	jmp    800c30 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c1f:	83 e9 01             	sub    $0x1,%ecx
  800c22:	ba 00 00 00 00       	mov    $0x0,%edx
  800c27:	85 c9                	test   %ecx,%ecx
  800c29:	75 d6                	jne    800c01 <memcmp+0x1f>
  800c2b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c3b:	89 c2                	mov    %eax,%edx
  800c3d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c40:	39 d0                	cmp    %edx,%eax
  800c42:	73 15                	jae    800c59 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c44:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800c48:	38 08                	cmp    %cl,(%eax)
  800c4a:	75 06                	jne    800c52 <memfind+0x1d>
  800c4c:	eb 0b                	jmp    800c59 <memfind+0x24>
  800c4e:	38 08                	cmp    %cl,(%eax)
  800c50:	74 07                	je     800c59 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c52:	83 c0 01             	add    $0x1,%eax
  800c55:	39 c2                	cmp    %eax,%edx
  800c57:	77 f5                	ja     800c4e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	57                   	push   %edi
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
  800c61:	83 ec 04             	sub    $0x4,%esp
  800c64:	8b 55 08             	mov    0x8(%ebp),%edx
  800c67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c6a:	0f b6 02             	movzbl (%edx),%eax
  800c6d:	3c 20                	cmp    $0x20,%al
  800c6f:	74 04                	je     800c75 <strtol+0x1a>
  800c71:	3c 09                	cmp    $0x9,%al
  800c73:	75 0e                	jne    800c83 <strtol+0x28>
		s++;
  800c75:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c78:	0f b6 02             	movzbl (%edx),%eax
  800c7b:	3c 20                	cmp    $0x20,%al
  800c7d:	74 f6                	je     800c75 <strtol+0x1a>
  800c7f:	3c 09                	cmp    $0x9,%al
  800c81:	74 f2                	je     800c75 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c83:	3c 2b                	cmp    $0x2b,%al
  800c85:	75 0c                	jne    800c93 <strtol+0x38>
		s++;
  800c87:	83 c2 01             	add    $0x1,%edx
  800c8a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c91:	eb 15                	jmp    800ca8 <strtol+0x4d>
	else if (*s == '-')
  800c93:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c9a:	3c 2d                	cmp    $0x2d,%al
  800c9c:	75 0a                	jne    800ca8 <strtol+0x4d>
		s++, neg = 1;
  800c9e:	83 c2 01             	add    $0x1,%edx
  800ca1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ca8:	85 db                	test   %ebx,%ebx
  800caa:	0f 94 c0             	sete   %al
  800cad:	74 05                	je     800cb4 <strtol+0x59>
  800caf:	83 fb 10             	cmp    $0x10,%ebx
  800cb2:	75 18                	jne    800ccc <strtol+0x71>
  800cb4:	80 3a 30             	cmpb   $0x30,(%edx)
  800cb7:	75 13                	jne    800ccc <strtol+0x71>
  800cb9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cbd:	8d 76 00             	lea    0x0(%esi),%esi
  800cc0:	75 0a                	jne    800ccc <strtol+0x71>
		s += 2, base = 16;
  800cc2:	83 c2 02             	add    $0x2,%edx
  800cc5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cca:	eb 15                	jmp    800ce1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ccc:	84 c0                	test   %al,%al
  800cce:	66 90                	xchg   %ax,%ax
  800cd0:	74 0f                	je     800ce1 <strtol+0x86>
  800cd2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800cd7:	80 3a 30             	cmpb   $0x30,(%edx)
  800cda:	75 05                	jne    800ce1 <strtol+0x86>
		s++, base = 8;
  800cdc:	83 c2 01             	add    $0x1,%edx
  800cdf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ce1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ce8:	0f b6 0a             	movzbl (%edx),%ecx
  800ceb:	89 cf                	mov    %ecx,%edi
  800ced:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800cf0:	80 fb 09             	cmp    $0x9,%bl
  800cf3:	77 08                	ja     800cfd <strtol+0xa2>
			dig = *s - '0';
  800cf5:	0f be c9             	movsbl %cl,%ecx
  800cf8:	83 e9 30             	sub    $0x30,%ecx
  800cfb:	eb 1e                	jmp    800d1b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800cfd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800d00:	80 fb 19             	cmp    $0x19,%bl
  800d03:	77 08                	ja     800d0d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800d05:	0f be c9             	movsbl %cl,%ecx
  800d08:	83 e9 57             	sub    $0x57,%ecx
  800d0b:	eb 0e                	jmp    800d1b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800d0d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800d10:	80 fb 19             	cmp    $0x19,%bl
  800d13:	77 15                	ja     800d2a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800d15:	0f be c9             	movsbl %cl,%ecx
  800d18:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d1b:	39 f1                	cmp    %esi,%ecx
  800d1d:	7d 0b                	jge    800d2a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800d1f:	83 c2 01             	add    $0x1,%edx
  800d22:	0f af c6             	imul   %esi,%eax
  800d25:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800d28:	eb be                	jmp    800ce8 <strtol+0x8d>
  800d2a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800d2c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d30:	74 05                	je     800d37 <strtol+0xdc>
		*endptr = (char *) s;
  800d32:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d35:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d37:	89 ca                	mov    %ecx,%edx
  800d39:	f7 da                	neg    %edx
  800d3b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800d3f:	0f 45 c2             	cmovne %edx,%eax
}
  800d42:	83 c4 04             	add    $0x4,%esp
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    
	...

00800d4c <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	83 ec 48             	sub    $0x48,%esp
  800d52:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d55:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d58:	89 7d fc             	mov    %edi,-0x4(%ebp)
  800d5b:	89 c6                	mov    %eax,%esi
  800d5d:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800d60:	89 ca                	mov    %ecx,%edx
	int32_t ret;
	asm volatile("pushl %%ecx\n\t"
  800d62:	8b 7d 10             	mov    0x10(%ebp),%edi
  800d65:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d68:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d6b:	51                   	push   %ecx
  800d6c:	52                   	push   %edx
  800d6d:	53                   	push   %ebx
  800d6e:	54                   	push   %esp
  800d6f:	55                   	push   %ebp
  800d70:	56                   	push   %esi
  800d71:	57                   	push   %edi
  800d72:	89 e5                	mov    %esp,%ebp
  800d74:	8d 35 7c 0d 80 00    	lea    0x800d7c,%esi
  800d7a:	0f 34                	sysenter 

00800d7c <.after_sysenter_label>:
  800d7c:	5f                   	pop    %edi
  800d7d:	5e                   	pop    %esi
  800d7e:	5d                   	pop    %ebp
  800d7f:	5c                   	pop    %esp
  800d80:	5b                   	pop    %ebx
  800d81:	5a                   	pop    %edx
  800d82:	59                   	pop    %ecx
  800d83:	89 c2                	mov    %eax,%edx
                   "b" (a3),
                   "D" (a4)
                 : "cc", "memory");


	if(check && ret > 0)
  800d85:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d89:	74 28                	je     800db3 <.after_sysenter_label+0x37>
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	7e 24                	jle    800db3 <.after_sysenter_label+0x37>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d93:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800d97:	c7 44 24 08 60 2c 80 	movl   $0x802c60,0x8(%esp)
  800d9e:	00 
  800d9f:	c7 44 24 04 2b 00 00 	movl   $0x2b,0x4(%esp)
  800da6:	00 
  800da7:	c7 04 24 7d 2c 80 00 	movl   $0x802c7d,(%esp)
  800dae:	e8 21 17 00 00       	call   8024d4 <_panic>

	return ret;
}
  800db3:	89 d0                	mov    %edx,%eax
  800db5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800db8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dbb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dbe:	89 ec                	mov    %ebp,%esp
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    

00800dc2 <sys_net_try_send>:
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}

int
sys_net_try_send(void *data, size_t len)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	83 ec 18             	sub    $0x18,%esp
  return syscall(SYS_net_try_send, 0, (uint32_t)data, len, 0, 0, 0);
  800dc8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800dcf:	00 
  800dd0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800dd7:	00 
  800dd8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ddf:	00 
  800de0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de3:	89 04 24             	mov    %eax,(%esp)
  800de6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de9:	ba 00 00 00 00       	mov    $0x0,%edx
  800dee:	b8 10 00 00 00       	mov    $0x10,%eax
  800df3:	e8 54 ff ff ff       	call   800d4c <syscall>
}
  800df8:	c9                   	leave  
  800df9:	c3                   	ret    

00800dfa <sys_time_msec>:
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}

unsigned int
sys_time_msec(void)
{
  800dfa:	55                   	push   %ebp
  800dfb:	89 e5                	mov    %esp,%ebp
  800dfd:	83 ec 18             	sub    $0x18,%esp
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
  800e00:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e07:	00 
  800e08:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e0f:	00 
  800e10:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e17:	00 
  800e18:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e1f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e24:	ba 00 00 00 00       	mov    $0x0,%edx
  800e29:	b8 0f 00 00 00       	mov    $0xf,%eax
  800e2e:	e8 19 ff ff ff       	call   800d4c <syscall>
}
  800e33:	c9                   	leave  
  800e34:	c3                   	ret    

00800e35 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e3b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e42:	00 
  800e43:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800e4a:	00 
  800e4b:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800e52:	00 
  800e53:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800e5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5d:	ba 01 00 00 00       	mov    $0x1,%edx
  800e62:	b8 0e 00 00 00       	mov    $0xe,%eax
  800e67:	e8 e0 fe ff ff       	call   800d4c <syscall>
}
  800e6c:	c9                   	leave  
  800e6d:	c3                   	ret    

00800e6e <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e74:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800e7b:	00 
  800e7c:	8b 45 14             	mov    0x14(%ebp),%eax
  800e7f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e83:	8b 45 10             	mov    0x10(%ebp),%eax
  800e86:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8d:	89 04 24             	mov    %eax,(%esp)
  800e90:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e93:	ba 00 00 00 00       	mov    $0x0,%edx
  800e98:	b8 0d 00 00 00       	mov    $0xd,%eax
  800e9d:	e8 aa fe ff ff       	call   800d4c <syscall>
}
  800ea2:	c9                   	leave  
  800ea3:	c3                   	ret    

00800ea4 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800eaa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800eb1:	00 
  800eb2:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800eb9:	00 
  800eba:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ec1:	00 
  800ec2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec5:	89 04 24             	mov    %eax,(%esp)
  800ec8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ecb:	ba 01 00 00 00       	mov    $0x1,%edx
  800ed0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ed5:	e8 72 fe ff ff       	call   800d4c <syscall>
}
  800eda:	c9                   	leave  
  800edb:	c3                   	ret    

00800edc <sys_env_set_trapframe>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800ee2:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800ee9:	00 
  800eea:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800ef1:	00 
  800ef2:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800ef9:	00 
  800efa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800efd:	89 04 24             	mov    %eax,(%esp)
  800f00:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f03:	ba 01 00 00 00       	mov    $0x1,%edx
  800f08:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f0d:	e8 3a fe ff ff       	call   800d4c <syscall>
}
  800f12:	c9                   	leave  
  800f13:	c3                   	ret    

00800f14 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f14:	55                   	push   %ebp
  800f15:	89 e5                	mov    %esp,%ebp
  800f17:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800f1a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f21:	00 
  800f22:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f29:	00 
  800f2a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f31:	00 
  800f32:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f35:	89 04 24             	mov    %eax,(%esp)
  800f38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f3b:	ba 01 00 00 00       	mov    $0x1,%edx
  800f40:	b8 09 00 00 00       	mov    $0x9,%eax
  800f45:	e8 02 fe ff ff       	call   800d4c <syscall>
}
  800f4a:	c9                   	leave  
  800f4b:	c3                   	ret    

00800f4c <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800f4c:	55                   	push   %ebp
  800f4d:	89 e5                	mov    %esp,%ebp
  800f4f:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800f52:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f59:	00 
  800f5a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800f61:	00 
  800f62:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800f69:	00 
  800f6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f6d:	89 04 24             	mov    %eax,(%esp)
  800f70:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f73:	ba 01 00 00 00       	mov    $0x1,%edx
  800f78:	b8 07 00 00 00       	mov    $0x7,%eax
  800f7d:	e8 ca fd ff ff       	call   800d4c <syscall>
}
  800f82:	c9                   	leave  
  800f83:	c3                   	ret    

00800f84 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva | perm, 0);
  800f8a:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800f91:	00 
  800f92:	8b 45 18             	mov    0x18(%ebp),%eax
  800f95:	0b 45 14             	or     0x14(%ebp),%eax
  800f98:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f9c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f9f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fa3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fa6:	89 04 24             	mov    %eax,(%esp)
  800fa9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fac:	ba 01 00 00 00       	mov    $0x1,%edx
  800fb1:	b8 06 00 00 00       	mov    $0x6,%eax
  800fb6:	e8 91 fd ff ff       	call   800d4c <syscall>
}
  800fbb:	c9                   	leave  
  800fbc:	c3                   	ret    

00800fbd <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fbd:	55                   	push   %ebp
  800fbe:	89 e5                	mov    %esp,%ebp
  800fc0:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800fc3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800fca:	00 
  800fcb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800fd2:	00 
  800fd3:	8b 45 10             	mov    0x10(%ebp),%eax
  800fd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fdd:	89 04 24             	mov    %eax,(%esp)
  800fe0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fe3:	ba 01 00 00 00       	mov    $0x1,%edx
  800fe8:	b8 05 00 00 00       	mov    $0x5,%eax
  800fed:	e8 5a fd ff ff       	call   800d4c <syscall>
}
  800ff2:	c9                   	leave  
  800ff3:	c3                   	ret    

00800ff4 <sys_yield>:
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
}

void
sys_yield(void)
{
  800ff4:	55                   	push   %ebp
  800ff5:	89 e5                	mov    %esp,%ebp
  800ff7:	83 ec 18             	sub    $0x18,%esp
	//cprintf("%s:sys_yield[%d]: [%x] calling sys_yield\n", __FILE__, __LINE__, thisenv->env_id);
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800ffa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801001:	00 
  801002:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801009:	00 
  80100a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801011:	00 
  801012:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801019:	b9 00 00 00 00       	mov    $0x0,%ecx
  80101e:	ba 00 00 00 00       	mov    $0x0,%edx
  801023:	b8 0c 00 00 00       	mov    $0xc,%eax
  801028:	e8 1f fd ff ff       	call   800d4c <syscall>
}
  80102d:	c9                   	leave  
  80102e:	c3                   	ret    

0080102f <sys_map_kernel_page>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

int
sys_map_kernel_page(void* kpage, void* va)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_map_kernel_page, 0, (uint32_t)kpage, (uint32_t)va, 0, 0, 0);
  801035:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80103c:	00 
  80103d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801044:	00 
  801045:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80104c:	00 
  80104d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801050:	89 04 24             	mov    %eax,(%esp)
  801053:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801056:	ba 00 00 00 00       	mov    $0x0,%edx
  80105b:	b8 04 00 00 00       	mov    $0x4,%eax
  801060:	e8 e7 fc ff ff       	call   800d4c <syscall>
}
  801065:	c9                   	leave  
  801066:	c3                   	ret    

00801067 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801067:	55                   	push   %ebp
  801068:	89 e5                	mov    %esp,%ebp
  80106a:	83 ec 18             	sub    $0x18,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  80106d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801074:	00 
  801075:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80107c:	00 
  80107d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801084:	00 
  801085:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80108c:	b9 00 00 00 00       	mov    $0x0,%ecx
  801091:	ba 00 00 00 00       	mov    $0x0,%edx
  801096:	b8 02 00 00 00       	mov    $0x2,%eax
  80109b:	e8 ac fc ff ff       	call   800d4c <syscall>
}
  8010a0:	c9                   	leave  
  8010a1:	c3                   	ret    

008010a2 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8010a8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010af:	00 
  8010b0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010b7:	00 
  8010b8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010bf:	00 
  8010c0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8010c7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ca:	ba 01 00 00 00       	mov    $0x1,%edx
  8010cf:	b8 03 00 00 00       	mov    $0x3,%eax
  8010d4:	e8 73 fc ff ff       	call   800d4c <syscall>
}
  8010d9:	c9                   	leave  
  8010da:	c3                   	ret    

008010db <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8010db:	55                   	push   %ebp
  8010dc:	89 e5                	mov    %esp,%ebp
  8010de:	83 ec 18             	sub    $0x18,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  8010e1:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8010e8:	00 
  8010e9:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8010f0:	00 
  8010f1:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8010f8:	00 
  8010f9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801100:	b9 00 00 00 00       	mov    $0x0,%ecx
  801105:	ba 00 00 00 00       	mov    $0x0,%edx
  80110a:	b8 01 00 00 00       	mov    $0x1,%eax
  80110f:	e8 38 fc ff ff       	call   800d4c <syscall>
}
  801114:	c9                   	leave  
  801115:	c3                   	ret    

00801116 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  801116:	55                   	push   %ebp
  801117:	89 e5                	mov    %esp,%ebp
  801119:	83 ec 18             	sub    $0x18,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80111c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  801123:	00 
  801124:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80112b:	00 
  80112c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801133:	00 
  801134:	8b 45 0c             	mov    0xc(%ebp),%eax
  801137:	89 04 24             	mov    %eax,(%esp)
  80113a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80113d:	ba 00 00 00 00       	mov    $0x0,%edx
  801142:	b8 00 00 00 00       	mov    $0x0,%eax
  801147:	e8 00 fc ff ff       	call   800d4c <syscall>
}
  80114c:	c9                   	leave  
  80114d:	c3                   	ret    
	...

00801150 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
  801153:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801156:	c7 44 24 08 8b 2c 80 	movl   $0x802c8b,0x8(%esp)
  80115d:	00 
  80115e:	c7 44 24 04 a4 00 00 	movl   $0xa4,0x4(%esp)
  801165:	00 
  801166:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
  80116d:	e8 62 13 00 00       	call   8024d4 <_panic>

00801172 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801172:	55                   	push   %ebp
  801173:	89 e5                	mov    %esp,%ebp
  801175:	57                   	push   %edi
  801176:	56                   	push   %esi
  801177:	53                   	push   %ebx
  801178:	83 ec 3c             	sub    $0x3c,%esp
	envid_t envidnum;
	uint32_t addr;
	int r;
	extern void _pgfault_upcall(void);
	
	set_pgfault_handler(pgfault);
  80117b:	c7 04 24 36 14 80 00 	movl   $0x801436,(%esp)
  801182:	e8 a5 13 00 00       	call   80252c <set_pgfault_handler>
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	//if I push esp it will be a pagefault.I come across a bug here.
	__asm __volatile(  
  801187:	ba 08 00 00 00       	mov    $0x8,%edx
  80118c:	89 d0                	mov    %edx,%eax
  80118e:	51                   	push   %ecx
  80118f:	52                   	push   %edx
  801190:	53                   	push   %ebx
  801191:	55                   	push   %ebp
  801192:	56                   	push   %esi
  801193:	57                   	push   %edi
  801194:	89 e5                	mov    %esp,%ebp
  801196:	8d 35 9e 11 80 00    	lea    0x80119e,%esi
  80119c:	0f 34                	sysenter 

0080119e <.after_sysenter_label>:
  80119e:	5f                   	pop    %edi
  80119f:	5e                   	pop    %esi
  8011a0:	5d                   	pop    %ebp
  8011a1:	5b                   	pop    %ebx
  8011a2:	5a                   	pop    %edx
  8011a3:	59                   	pop    %ecx
  8011a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
	
	envidnum = sys_exofork();
	cprintf("%s:fork[%d]: sys_exofork() return %x\n",__FILE__, __LINE__, envidnum);
  8011a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011ab:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
  8011b2:	00 
  8011b3:	c7 44 24 04 a1 2c 80 	movl   $0x802ca1,0x4(%esp)
  8011ba:	00 
  8011bb:	c7 04 24 e8 2c 80 00 	movl   $0x802ce8,(%esp)
  8011c2:	e8 52 f0 ff ff       	call   800219 <cprintf>
	if (envidnum < 0)
  8011c7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8011cb:	79 23                	jns    8011f0 <.after_sysenter_label+0x52>
		panic("sys_exofork: %e", envidnum);
  8011cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011d0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8011d4:	c7 44 24 08 ac 2c 80 	movl   $0x802cac,0x8(%esp)
  8011db:	00 
  8011dc:	c7 44 24 04 82 00 00 	movl   $0x82,0x4(%esp)
  8011e3:	00 
  8011e4:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
  8011eb:	e8 e4 12 00 00       	call   8024d4 <_panic>
	// We’re the child
	if (envidnum == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
  8011f0:	bb 00 00 80 00       	mov    $0x800000,%ebx
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
  8011f5:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  8011fa:	bf 00 00 40 ef       	mov    $0xef400000,%edi
	envidnum = sys_exofork();
	cprintf("%s:fork[%d]: sys_exofork() return %x\n",__FILE__, __LINE__, envidnum);
	if (envidnum < 0)
		panic("sys_exofork: %e", envidnum);
	// We’re the child
	if (envidnum == 0) {
  8011ff:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801203:	75 1c                	jne    801221 <.after_sysenter_label+0x83>
		thisenv = &envs[ENVX(sys_getenvid())];
  801205:	e8 5d fe ff ff       	call   801067 <sys_getenvid>
  80120a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80120f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801212:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801217:	a3 0c 50 80 00       	mov    %eax,0x80500c
		return 0;
  80121c:	e9 0a 02 00 00       	jmp    80142b <.after_sysenter_label+0x28d>
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
  801221:	89 d8                	mov    %ebx,%eax
  801223:	c1 e8 16             	shr    $0x16,%eax
  801226:	8b 04 86             	mov    (%esi,%eax,4),%eax
  801229:	a8 01                	test   $0x1,%al
  80122b:	0f 84 43 01 00 00    	je     801374 <.after_sysenter_label+0x1d6>
  801231:	89 d8                	mov    %ebx,%eax
  801233:	c1 e8 0c             	shr    $0xc,%eax
  801236:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801239:	f6 c2 01             	test   $0x1,%dl
  80123c:	0f 84 32 01 00 00    	je     801374 <.after_sysenter_label+0x1d6>
  801242:	8b 14 87             	mov    (%edi,%eax,4),%edx
  801245:	f6 c2 04             	test   $0x4,%dl
  801248:	0f 84 26 01 00 00    	je     801374 <.after_sysenter_label+0x1d6>
{
	int r;

	// LAB 4: Your code here.
	int perm;
	void * addr = (void *) ((uint32_t) pn * PGSIZE);
  80124e:	c1 e0 0c             	shl    $0xc,%eax
  801251:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	pte_t pte = vpt[PGNUM(addr)];
  801254:	c1 e8 0c             	shr    $0xc,%eax
  801257:	8b 04 87             	mov    (%edi,%eax,4),%eax
	perm = pte & PTE_SYSCALL;
  80125a:	89 c2                	mov    %eax,%edx
  80125c:	81 e2 07 0e 00 00    	and    $0xe07,%edx
	
	if (perm & (PTE_W|PTE_COW)) 
  801262:	a9 02 08 00 00       	test   $0x802,%eax
  801267:	0f 84 a0 00 00 00    	je     80130d <.after_sysenter_label+0x16f>
	{
		 perm &= ~PTE_W;
  80126d:	83 e2 fd             	and    $0xfffffffd,%edx
		 perm |= PTE_COW;
  801270:	80 ce 08             	or     $0x8,%dh
  801273:	89 55 dc             	mov    %edx,-0x24(%ebp)
		//map in child
		if ((r = sys_page_map(0, addr, envid, addr, perm)) < 0)
  801276:	89 54 24 10          	mov    %edx,0x10(%esp)
  80127a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80127d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801281:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801284:	89 44 24 08          	mov    %eax,0x8(%esp)
  801288:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80128b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80128f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801296:	e8 e9 fc ff ff       	call   800f84 <sys_page_map>
  80129b:	85 c0                	test   %eax,%eax
  80129d:	79 20                	jns    8012bf <.after_sysenter_label+0x121>
			panic ("duppage: page re-mapping failed at 1 : %e", r);
  80129f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012a3:	c7 44 24 08 10 2d 80 	movl   $0x802d10,0x8(%esp)
  8012aa:	00 
  8012ab:	c7 44 24 04 54 00 00 	movl   $0x54,0x4(%esp)
  8012b2:	00 
  8012b3:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
  8012ba:	e8 15 12 00 00       	call   8024d4 <_panic>
		//remap in the parent		
		if ((r = sys_page_map(0, addr, 0, addr, perm)) < 0)
  8012bf:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8012c2:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012c6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8012c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012cd:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8012d4:	00 
  8012d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8012e0:	e8 9f fc ff ff       	call   800f84 <sys_page_map>
  8012e5:	85 c0                	test   %eax,%eax
  8012e7:	0f 89 87 00 00 00    	jns    801374 <.after_sysenter_label+0x1d6>
			panic ("duppage: page re-mapping failed at 2 : %e", r);
  8012ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8012f1:	c7 44 24 08 3c 2d 80 	movl   $0x802d3c,0x8(%esp)
  8012f8:	00 
  8012f9:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
  801300:	00 
  801301:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
  801308:	e8 c7 11 00 00       	call   8024d4 <_panic>
	}
	else //include PTE_SHARE
	{
		cprintf("map two %x----%x\n",envid,addr);
  80130d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801310:	89 44 24 08          	mov    %eax,0x8(%esp)
  801314:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801317:	89 44 24 04          	mov    %eax,0x4(%esp)
  80131b:	c7 04 24 bc 2c 80 00 	movl   $0x802cbc,(%esp)
  801322:	e8 f2 ee ff ff       	call   800219 <cprintf>
		if ((r = sys_page_map (0, addr, envid, addr, PTE_U|PTE_P)) < 0)
  801327:	c7 44 24 10 05 00 00 	movl   $0x5,0x10(%esp)
  80132e:	00 
  80132f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801332:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801336:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801339:	89 44 24 08          	mov    %eax,0x8(%esp)
  80133d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801340:	89 44 24 04          	mov    %eax,0x4(%esp)
  801344:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80134b:	e8 34 fc ff ff       	call   800f84 <sys_page_map>
  801350:	85 c0                	test   %eax,%eax
  801352:	79 20                	jns    801374 <.after_sysenter_label+0x1d6>
			panic ("duppage: page re-mapping failed at 3 : %e", r);
  801354:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801358:	c7 44 24 08 68 2d 80 	movl   $0x802d68,0x8(%esp)
  80135f:	00 
  801360:	c7 44 24 04 5d 00 00 	movl   $0x5d,0x4(%esp)
  801367:	00 
  801368:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
  80136f:	e8 60 11 00 00       	call   8024d4 <_panic>
	if (envidnum == 0) {
		thisenv = &envs[ENVX(sys_getenvid())];
		return 0;
	}
	// We’re the parent.
	for (addr =  UTEXT; addr < UXSTACKTOP - PGSIZE; addr += PGSIZE) 
  801374:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80137a:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801380:	0f 85 9b fe ff ff    	jne    801221 <.after_sysenter_label+0x83>
	{
		if(	(vpd[PDX(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_P) > 0 && (vpt[PGNUM(addr)] & PTE_U) > 0)
			duppage(envidnum,PGNUM(addr));
	}
	if ((r = sys_page_alloc (envidnum, (void *)(UXSTACKTOP - PGSIZE), PTE_U|PTE_W|PTE_P)) < 0)
  801386:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80138d:	00 
  80138e:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  801395:	ee 
  801396:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801399:	89 04 24             	mov    %eax,(%esp)
  80139c:	e8 1c fc ff ff       	call   800fbd <sys_page_alloc>
  8013a1:	85 c0                	test   %eax,%eax
  8013a3:	79 20                	jns    8013c5 <.after_sysenter_label+0x227>
		panic ("fork: page allocation failed : %e", r);
  8013a5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013a9:	c7 44 24 08 94 2d 80 	movl   $0x802d94,0x8(%esp)
  8013b0:	00 
  8013b1:	c7 44 24 04 8f 00 00 	movl   $0x8f,0x4(%esp)
  8013b8:	00 
  8013b9:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
  8013c0:	e8 0f 11 00 00       	call   8024d4 <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	sys_env_set_pgfault_upcall (envidnum, _pgfault_upcall);
  8013c5:	c7 44 24 04 9c 25 80 	movl   $0x80259c,0x4(%esp)
  8013cc:	00 
  8013cd:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013d0:	89 04 24             	mov    %eax,(%esp)
  8013d3:	e8 cc fa ff ff       	call   800ea4 <sys_env_set_pgfault_upcall>
	//cprintf("%x-----%x\n",&envid,envid);
	// Start the child environment running
	if((r = sys_env_set_status(envidnum, ENV_RUNNABLE)) < 0)
  8013d8:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8013df:	00 
  8013e0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8013e3:	89 04 24             	mov    %eax,(%esp)
  8013e6:	e8 29 fb ff ff       	call   800f14 <sys_env_set_status>
  8013eb:	85 c0                	test   %eax,%eax
  8013ed:	79 20                	jns    80140f <.after_sysenter_label+0x271>
		panic("fork: set child env status failed : %e", r);
  8013ef:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8013f3:	c7 44 24 08 b8 2d 80 	movl   $0x802db8,0x8(%esp)
  8013fa:	00 
  8013fb:	c7 44 24 04 95 00 00 	movl   $0x95,0x4(%esp)
  801402:	00 
  801403:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
  80140a:	e8 c5 10 00 00       	call   8024d4 <_panic>
	//cprintf("%x-----%x\n",&envid,envid);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("fork in %x have set %x ,runnable\n",sys_getenvid(),envidnum);
	//cprintf("%x-----%x\n",&envidnum,envidnum);
	cprintf("%s:fork[%d]: fork return\n", __FILE__, __LINE__);
  80140f:	c7 44 24 08 9a 00 00 	movl   $0x9a,0x8(%esp)
  801416:	00 
  801417:	c7 44 24 04 a1 2c 80 	movl   $0x802ca1,0x4(%esp)
  80141e:	00 
  80141f:	c7 04 24 ce 2c 80 00 	movl   $0x802cce,(%esp)
  801426:	e8 ee ed ff ff       	call   800219 <cprintf>
	return envidnum;

	//panic("fork not implemented");
}
  80142b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80142e:	83 c4 3c             	add    $0x3c,%esp
  801431:	5b                   	pop    %ebx
  801432:	5e                   	pop    %esi
  801433:	5f                   	pop    %edi
  801434:	5d                   	pop    %ebp
  801435:	c3                   	ret    

00801436 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  801436:	55                   	push   %ebp
  801437:	89 e5                	mov    %esp,%ebp
  801439:	53                   	push   %ebx
  80143a:	83 ec 24             	sub    $0x24,%esp
  80143d:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801440:	8b 18                	mov    (%eax),%ebx
	uint32_t err = utf->utf_err;
  801442:	8b 50 04             	mov    0x4(%eax),%edx
	// Hint:
	//   Use the read-only page table mappings at vpt
	//   (see <inc/memlayout.h>).
	//cprintf("pgfault: do page fault here %x\n",utf->utf_eflags);
	// LAB 4: Your code here.
	if((err & FEC_WR) == 0)
  801445:	f6 c2 02             	test   $0x2,%dl
  801448:	75 2b                	jne    801475 <pgfault+0x3f>
		panic("pgfault: fault is not a write (err: %08x va: %08x ip: %08x)",err, addr, utf->utf_eip);
  80144a:	8b 40 28             	mov    0x28(%eax),%eax
  80144d:	89 44 24 14          	mov    %eax,0x14(%esp)
  801451:	89 5c 24 10          	mov    %ebx,0x10(%esp)
  801455:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801459:	c7 44 24 08 e0 2d 80 	movl   $0x802de0,0x8(%esp)
  801460:	00 
  801461:	c7 44 24 04 1c 00 00 	movl   $0x1c,0x4(%esp)
  801468:	00 
  801469:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
  801470:	e8 5f 10 00 00       	call   8024d4 <_panic>
	if ((vpd[PDX(addr)] & PTE_P) == 0 || (vpt[PGNUM(addr)] & PTE_COW) == 0)
  801475:	89 d8                	mov    %ebx,%eax
  801477:	c1 e8 16             	shr    $0x16,%eax
  80147a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801481:	a8 01                	test   $0x1,%al
  801483:	74 11                	je     801496 <pgfault+0x60>
  801485:	89 d8                	mov    %ebx,%eax
  801487:	c1 e8 0c             	shr    $0xc,%eax
  80148a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801491:	f6 c4 08             	test   $0x8,%ah
  801494:	75 1c                	jne    8014b2 <pgfault+0x7c>
		panic ("pgfault: not a write or attempting to access a non-COW page");
  801496:	c7 44 24 08 1c 2e 80 	movl   $0x802e1c,0x8(%esp)
  80149d:	00 
  80149e:	c7 44 24 04 1e 00 00 	movl   $0x1e,0x4(%esp)
  8014a5:	00 
  8014a6:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
  8014ad:	e8 22 10 00 00       	call   8024d4 <_panic>
	// Hint:
	//   You should make three system calls.
	//   No need to explicitly delete the old page's mapping.

	// LAB 4: Your code here.
	if ((r = sys_page_alloc (0, (void *)PFTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  8014b2:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8014b9:	00 
  8014ba:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  8014c1:	00 
  8014c2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8014c9:	e8 ef fa ff ff       	call   800fbd <sys_page_alloc>
  8014ce:	85 c0                	test   %eax,%eax
  8014d0:	79 20                	jns    8014f2 <pgfault+0xbc>
		panic ("pgfault: page allocation failed : %e", r);
  8014d2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8014d6:	c7 44 24 08 58 2e 80 	movl   $0x802e58,0x8(%esp)
  8014dd:	00 
  8014de:	c7 44 24 04 28 00 00 	movl   $0x28,0x4(%esp)
  8014e5:	00 
  8014e6:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
  8014ed:	e8 e2 0f 00 00       	call   8024d4 <_panic>
	addr = ROUNDDOWN (addr, PGSIZE);
  8014f2:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove (PFTEMP, addr, PGSIZE);
  8014f8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8014ff:	00 
  801500:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801504:	c7 04 24 00 f0 7f 00 	movl   $0x7ff000,(%esp)
  80150b:	e8 35 f6 ff ff       	call   800b45 <memmove>
	if((r = sys_page_map (0, PFTEMP, 0, addr, PTE_U|PTE_P|PTE_W)) < 0)
  801510:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  801517:	00 
  801518:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80151c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801523:	00 
  801524:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  80152b:	00 
  80152c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801533:	e8 4c fa ff ff       	call   800f84 <sys_page_map>
  801538:	85 c0                	test   %eax,%eax
  80153a:	79 20                	jns    80155c <pgfault+0x126>
		panic ("pgfault: page mapping failed : %e", r);
  80153c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801540:	c7 44 24 08 80 2e 80 	movl   $0x802e80,0x8(%esp)
  801547:	00 
  801548:	c7 44 24 04 2c 00 00 	movl   $0x2c,0x4(%esp)
  80154f:	00 
  801550:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
  801557:	e8 78 0f 00 00       	call   8024d4 <_panic>
	if((r = sys_page_unmap(0,PFTEMP)) < 0)
  80155c:	c7 44 24 04 00 f0 7f 	movl   $0x7ff000,0x4(%esp)
  801563:	00 
  801564:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80156b:	e8 dc f9 ff ff       	call   800f4c <sys_page_unmap>
  801570:	85 c0                	test   %eax,%eax
  801572:	79 20                	jns    801594 <pgfault+0x15e>
		panic("pgfault: page unmapping failed : %e", r);
  801574:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801578:	c7 44 24 08 a4 2e 80 	movl   $0x802ea4,0x8(%esp)
  80157f:	00 
  801580:	c7 44 24 04 2e 00 00 	movl   $0x2e,0x4(%esp)
  801587:	00 
  801588:	c7 04 24 a1 2c 80 00 	movl   $0x802ca1,(%esp)
  80158f:	e8 40 0f 00 00       	call   8024d4 <_panic>
	/* __asm__ volatile("movl %%esp, %0\n\t" */
	/* 		 :"=r"(gaga) */
	/* 		 ::); */
	/* cprintf("gaga----------%x\n", gaga); */
	//panic("pgfault not implemented");
}
  801594:	83 c4 24             	add    $0x24,%esp
  801597:	5b                   	pop    %ebx
  801598:	5d                   	pop    %ebp
  801599:	c3                   	ret    
  80159a:	00 00                	add    %al,(%eax)
  80159c:	00 00                	add    %al,(%eax)
	...

008015a0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8015a0:	55                   	push   %ebp
  8015a1:	89 e5                	mov    %esp,%ebp
  8015a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  8015a6:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  8015ac:	b8 01 00 00 00       	mov    $0x1,%eax
  8015b1:	39 ca                	cmp    %ecx,%edx
  8015b3:	75 04                	jne    8015b9 <ipc_find_env+0x19>
  8015b5:	b0 00                	mov    $0x0,%al
  8015b7:	eb 0f                	jmp    8015c8 <ipc_find_env+0x28>
  8015b9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8015bc:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  8015c2:	8b 12                	mov    (%edx),%edx
  8015c4:	39 ca                	cmp    %ecx,%edx
  8015c6:	75 0c                	jne    8015d4 <ipc_find_env+0x34>
			return envs[i].env_id;
  8015c8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8015cb:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  8015d0:	8b 00                	mov    (%eax),%eax
  8015d2:	eb 0e                	jmp    8015e2 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8015d4:	83 c0 01             	add    $0x1,%eax
  8015d7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8015dc:	75 db                	jne    8015b9 <ipc_find_env+0x19>
  8015de:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8015e2:	5d                   	pop    %ebp
  8015e3:	c3                   	ret    

008015e4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8015e4:	55                   	push   %ebp
  8015e5:	89 e5                	mov    %esp,%ebp
  8015e7:	57                   	push   %edi
  8015e8:	56                   	push   %esi
  8015e9:	53                   	push   %ebx
  8015ea:	83 ec 1c             	sub    $0x1c,%esp
  8015ed:	8b 75 08             	mov    0x8(%ebp),%esi
  8015f0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8015f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int r;
	if(!pg)
  8015f6:	85 db                	test   %ebx,%ebx
  8015f8:	b8 00 00 c0 ee       	mov    $0xeec00000,%eax
  8015fd:	0f 44 d8             	cmove  %eax,%ebx
  801600:	eb 25                	jmp    801627 <ipc_send+0x43>
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
  801602:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801605:	74 20                	je     801627 <ipc_send+0x43>
			panic ("ipc: sys try send failed : %e", r);
  801607:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80160b:	c7 44 24 08 c8 2e 80 	movl   $0x802ec8,0x8(%esp)
  801612:	00 
  801613:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
  80161a:	00 
  80161b:	c7 04 24 e6 2e 80 00 	movl   $0x802ee6,(%esp)
  801622:	e8 ad 0e 00 00       	call   8024d4 <_panic>
{
	// LAB 4: Your code here.
	int r;
	if(!pg)
		pg = (void*)UTOP; 
	while((r = sys_ipc_try_send(to_env,val,pg,perm)) != 0)
  801627:	8b 45 14             	mov    0x14(%ebp),%eax
  80162a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80162e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801632:	89 7c 24 04          	mov    %edi,0x4(%esp)
  801636:	89 34 24             	mov    %esi,(%esp)
  801639:	e8 30 f8 ff ff       	call   800e6e <sys_ipc_try_send>
  80163e:	85 c0                	test   %eax,%eax
  801640:	75 c0                	jne    801602 <ipc_send+0x1e>
	{
		if(/* r < 0 && */r != -E_IPC_NOT_RECV )
			panic ("ipc: sys try send failed : %e", r);
	}
	sys_yield();
  801642:	e8 ad f9 ff ff       	call   800ff4 <sys_yield>
}
  801647:	83 c4 1c             	add    $0x1c,%esp
  80164a:	5b                   	pop    %ebx
  80164b:	5e                   	pop    %esi
  80164c:	5f                   	pop    %edi
  80164d:	5d                   	pop    %ebp
  80164e:	c3                   	ret    

0080164f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80164f:	55                   	push   %ebp
  801650:	89 e5                	mov    %esp,%ebp
  801652:	83 ec 28             	sub    $0x28,%esp
  801655:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801658:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80165b:	89 7d fc             	mov    %edi,-0x4(%ebp)
  80165e:	8b 75 08             	mov    0x8(%ebp),%esi
  801661:	8b 45 0c             	mov    0xc(%ebp),%eax
  801664:	8b 7d 10             	mov    0x10(%ebp),%edi
	// LAB 4: Your code here.
	int r;
	if(!pg)
  801667:	85 c0                	test   %eax,%eax
  801669:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80166e:	0f 44 c2             	cmove  %edx,%eax
		pg = (void*)UTOP;

	if((r = sys_ipc_recv(pg)) < 0)
  801671:	89 04 24             	mov    %eax,(%esp)
  801674:	e8 bc f7 ff ff       	call   800e35 <sys_ipc_recv>
  801679:	89 c3                	mov    %eax,%ebx
  80167b:	85 c0                	test   %eax,%eax
  80167d:	79 2a                	jns    8016a9 <ipc_recv+0x5a>
	{
		cprintf("recv wrong %e %x\n",r,r);
  80167f:	89 44 24 08          	mov    %eax,0x8(%esp)
  801683:	89 44 24 04          	mov    %eax,0x4(%esp)
  801687:	c7 04 24 f0 2e 80 00 	movl   $0x802ef0,(%esp)
  80168e:	e8 86 eb ff ff       	call   800219 <cprintf>
		if(from_env_store != NULL)
  801693:	85 f6                	test   %esi,%esi
  801695:	74 06                	je     80169d <ipc_recv+0x4e>
			*from_env_store = 0;
  801697:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
		if(perm_store != NULL)
  80169d:	85 ff                	test   %edi,%edi
  80169f:	74 2c                	je     8016cd <ipc_recv+0x7e>
			*perm_store = 0;
  8016a1:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  8016a7:	eb 24                	jmp    8016cd <ipc_recv+0x7e>
		return r;
	}
	if(from_env_store != NULL)
  8016a9:	85 f6                	test   %esi,%esi
  8016ab:	74 0a                	je     8016b7 <ipc_recv+0x68>
		*from_env_store = thisenv->env_ipc_from;
  8016ad:	a1 0c 50 80 00       	mov    0x80500c,%eax
  8016b2:	8b 40 74             	mov    0x74(%eax),%eax
  8016b5:	89 06                	mov    %eax,(%esi)
	if(perm_store != NULL)
  8016b7:	85 ff                	test   %edi,%edi
  8016b9:	74 0a                	je     8016c5 <ipc_recv+0x76>
		*perm_store = thisenv->env_ipc_perm;
  8016bb:	a1 0c 50 80 00       	mov    0x80500c,%eax
  8016c0:	8b 40 78             	mov    0x78(%eax),%eax
  8016c3:	89 07                	mov    %eax,(%edi)
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  8016c5:	a1 0c 50 80 00       	mov    0x80500c,%eax
  8016ca:	8b 58 70             	mov    0x70(%eax),%ebx
}
  8016cd:	89 d8                	mov    %ebx,%eax
  8016cf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8016d2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8016d5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8016d8:	89 ec                	mov    %ebp,%esp
  8016da:	5d                   	pop    %ebp
  8016db:	c3                   	ret    
  8016dc:	00 00                	add    %al,(%eax)
	...

008016e0 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e6:	05 00 00 00 30       	add    $0x30000000,%eax
  8016eb:	c1 e8 0c             	shr    $0xc,%eax
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
}
  8016ee:	5d                   	pop    %ebp
  8016ef:	c3                   	ret    

008016f0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	83 ec 04             	sub    $0x4,%esp
	return INDEX2DATA(fd2num(fd));
  8016f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f9:	89 04 24             	mov    %eax,(%esp)
  8016fc:	e8 df ff ff ff       	call   8016e0 <fd2num>
  801701:	05 20 00 0d 00       	add    $0xd0020,%eax
  801706:	c1 e0 0c             	shl    $0xc,%eax
}
  801709:	c9                   	leave  
  80170a:	c3                   	ret    

0080170b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80170b:	55                   	push   %ebp
  80170c:	89 e5                	mov    %esp,%ebp
  80170e:	57                   	push   %edi
  80170f:	56                   	push   %esi
  801710:	53                   	push   %ebx
  801711:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
  801714:	a1 00 dd 7b ef       	mov    0xef7bdd00,%eax
  801719:	a8 01                	test   $0x1,%al
  80171b:	74 36                	je     801753 <fd_alloc+0x48>
  80171d:	a1 00 00 74 ef       	mov    0xef740000,%eax
  801722:	a8 01                	test   $0x1,%al
  801724:	74 2d                	je     801753 <fd_alloc+0x48>
  801726:	b8 00 10 00 d0       	mov    $0xd0001000,%eax
  80172b:	b9 00 d0 7b ef       	mov    $0xef7bd000,%ecx
  801730:	be 00 00 40 ef       	mov    $0xef400000,%esi
  801735:	89 c3                	mov    %eax,%ebx
  801737:	89 c2                	mov    %eax,%edx
  801739:	c1 ea 16             	shr    $0x16,%edx
  80173c:	8b 14 91             	mov    (%ecx,%edx,4),%edx
  80173f:	f6 c2 01             	test   $0x1,%dl
  801742:	74 14                	je     801758 <fd_alloc+0x4d>
  801744:	89 c2                	mov    %eax,%edx
  801746:	c1 ea 0c             	shr    $0xc,%edx
  801749:	8b 14 96             	mov    (%esi,%edx,4),%edx
  80174c:	f6 c2 01             	test   $0x1,%dl
  80174f:	75 10                	jne    801761 <fd_alloc+0x56>
  801751:	eb 05                	jmp    801758 <fd_alloc+0x4d>
  801753:	bb 00 00 00 d0       	mov    $0xd0000000,%ebx
			*fd_store = fd;
  801758:	89 1f                	mov    %ebx,(%edi)
  80175a:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80175f:	eb 17                	jmp    801778 <fd_alloc+0x6d>
  801761:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  801766:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80176b:	75 c8                	jne    801735 <fd_alloc+0x2a>
		if ((vpd[PDX(fd)] & PTE_P) == 0 || (vpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80176d:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
  801773:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
	return -E_MAX_OPEN;
}
  801778:	5b                   	pop    %ebx
  801779:	5e                   	pop    %esi
  80177a:	5f                   	pop    %edi
  80177b:	5d                   	pop    %ebp
  80177c:	c3                   	ret    

0080177d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80177d:	55                   	push   %ebp
  80177e:	89 e5                	mov    %esp,%ebp
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801780:	8b 45 08             	mov    0x8(%ebp),%eax
  801783:	83 f8 1f             	cmp    $0x1f,%eax
  801786:	77 36                	ja     8017be <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801788:	05 00 00 0d 00       	add    $0xd0000,%eax
  80178d:	c1 e0 0c             	shl    $0xc,%eax
	if (!(vpd[PDX(fd)] & PTE_P) || !(vpt[PGNUM(fd)] & PTE_P)) {
  801790:	89 c2                	mov    %eax,%edx
  801792:	c1 ea 16             	shr    $0x16,%edx
  801795:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80179c:	f6 c2 01             	test   $0x1,%dl
  80179f:	74 1d                	je     8017be <fd_lookup+0x41>
  8017a1:	89 c2                	mov    %eax,%edx
  8017a3:	c1 ea 0c             	shr    $0xc,%edx
  8017a6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8017ad:	f6 c2 01             	test   $0x1,%dl
  8017b0:	74 0c                	je     8017be <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fd);
		return -E_INVAL;
	}
	*fd_store = fd;
  8017b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017b5:	89 02                	mov    %eax,(%edx)
  8017b7:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
  8017bc:	eb 05                	jmp    8017c3 <fd_lookup+0x46>
  8017be:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8017c3:	5d                   	pop    %ebp
  8017c4:	c3                   	ret    

008017c5 <seek>:
	return (*dev->dev_write)(fd, buf, n);
}

int
seek(int fdnum, off_t offset)
{
  8017c5:	55                   	push   %ebp
  8017c6:	89 e5                	mov    %esp,%ebp
  8017c8:	83 ec 18             	sub    $0x18,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017cb:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8017d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d5:	89 04 24             	mov    %eax,(%esp)
  8017d8:	e8 a0 ff ff ff       	call   80177d <fd_lookup>
  8017dd:	85 c0                	test   %eax,%eax
  8017df:	78 0e                	js     8017ef <seek+0x2a>
		return r;
	fd->fd_offset = offset;
  8017e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017e7:	89 50 04             	mov    %edx,0x4(%eax)
  8017ea:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  8017ef:	c9                   	leave  
  8017f0:	c3                   	ret    

008017f1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8017f1:	55                   	push   %ebp
  8017f2:	89 e5                	mov    %esp,%ebp
  8017f4:	56                   	push   %esi
  8017f5:	53                   	push   %ebx
  8017f6:	83 ec 10             	sub    $0x10,%esp
  8017f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
  8017ff:	ba 00 00 00 00       	mov    $0x0,%edx
int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
		if (devtab[i]->dev_id == dev_id) {
  801804:	b8 04 40 80 00       	mov    $0x804004,%eax
  801809:	39 0d 04 40 80 00    	cmp    %ecx,0x804004
  80180f:	75 11                	jne    801822 <dev_lookup+0x31>
  801811:	eb 04                	jmp    801817 <dev_lookup+0x26>
  801813:	39 08                	cmp    %ecx,(%eax)
  801815:	75 10                	jne    801827 <dev_lookup+0x36>
			*dev = devtab[i];
  801817:	89 03                	mov    %eax,(%ebx)
  801819:	b8 00 00 00 00       	mov    $0x0,%eax
			return 0;
  80181e:	66 90                	xchg   %ax,%ax
  801820:	eb 36                	jmp    801858 <dev_lookup+0x67>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801822:	be 80 2f 80 00       	mov    $0x802f80,%esi
  801827:	83 c2 01             	add    $0x1,%edx
  80182a:	8b 04 96             	mov    (%esi,%edx,4),%eax
  80182d:	85 c0                	test   %eax,%eax
  80182f:	75 e2                	jne    801813 <dev_lookup+0x22>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801831:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801836:	8b 40 48             	mov    0x48(%eax),%eax
  801839:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80183d:	89 44 24 04          	mov    %eax,0x4(%esp)
  801841:	c7 04 24 04 2f 80 00 	movl   $0x802f04,(%esp)
  801848:	e8 cc e9 ff ff       	call   800219 <cprintf>
	*dev = 0;
  80184d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801853:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	return -E_INVAL;
}
  801858:	83 c4 10             	add    $0x10,%esp
  80185b:	5b                   	pop    %ebx
  80185c:	5e                   	pop    %esi
  80185d:	5d                   	pop    %ebp
  80185e:	c3                   	ret    

0080185f <fstat>:
	return (*dev->dev_trunc)(fd, newsize);
}

int
fstat(int fdnum, struct Stat *stat)
{
  80185f:	55                   	push   %ebp
  801860:	89 e5                	mov    %esp,%ebp
  801862:	53                   	push   %ebx
  801863:	83 ec 24             	sub    $0x24,%esp
  801866:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801869:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80186c:	89 44 24 04          	mov    %eax,0x4(%esp)
  801870:	8b 45 08             	mov    0x8(%ebp),%eax
  801873:	89 04 24             	mov    %eax,(%esp)
  801876:	e8 02 ff ff ff       	call   80177d <fd_lookup>
  80187b:	85 c0                	test   %eax,%eax
  80187d:	78 53                	js     8018d2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80187f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801882:	89 44 24 04          	mov    %eax,0x4(%esp)
  801886:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801889:	8b 00                	mov    (%eax),%eax
  80188b:	89 04 24             	mov    %eax,(%esp)
  80188e:	e8 5e ff ff ff       	call   8017f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801893:	85 c0                	test   %eax,%eax
  801895:	78 3b                	js     8018d2 <fstat+0x73>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if (!dev->dev_stat)
  801897:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80189c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80189f:	83 7a 14 00          	cmpl   $0x0,0x14(%edx)
  8018a3:	74 2d                	je     8018d2 <fstat+0x73>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018a5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018a8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018af:	00 00 00 
	stat->st_isdir = 0;
  8018b2:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018b9:	00 00 00 
	stat->st_dev = dev;
  8018bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018bf:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018c5:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8018c9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018cc:	89 14 24             	mov    %edx,(%esp)
  8018cf:	ff 50 14             	call   *0x14(%eax)
}
  8018d2:	83 c4 24             	add    $0x24,%esp
  8018d5:	5b                   	pop    %ebx
  8018d6:	5d                   	pop    %ebp
  8018d7:	c3                   	ret    

008018d8 <ftruncate>:
	return 0;
}

int
ftruncate(int fdnum, off_t newsize)
{
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	53                   	push   %ebx
  8018dc:	83 ec 24             	sub    $0x24,%esp
  8018df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018e9:	89 1c 24             	mov    %ebx,(%esp)
  8018ec:	e8 8c fe ff ff       	call   80177d <fd_lookup>
  8018f1:	85 c0                	test   %eax,%eax
  8018f3:	78 5f                	js     801954 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8018fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ff:	8b 00                	mov    (%eax),%eax
  801901:	89 04 24             	mov    %eax,(%esp)
  801904:	e8 e8 fe ff ff       	call   8017f1 <dev_lookup>
ftruncate(int fdnum, off_t newsize)
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801909:	85 c0                	test   %eax,%eax
  80190b:	78 47                	js     801954 <ftruncate+0x7c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80190d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801910:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801914:	75 23                	jne    801939 <ftruncate+0x61>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801916:	a1 0c 50 80 00       	mov    0x80500c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80191b:	8b 40 48             	mov    0x48(%eax),%eax
  80191e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801922:	89 44 24 04          	mov    %eax,0x4(%esp)
  801926:	c7 04 24 24 2f 80 00 	movl   $0x802f24,(%esp)
  80192d:	e8 e7 e8 ff ff       	call   800219 <cprintf>
  801932:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801937:	eb 1b                	jmp    801954 <ftruncate+0x7c>
	}
	if (!dev->dev_trunc)
  801939:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80193c:	8b 48 18             	mov    0x18(%eax),%ecx
  80193f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801944:	85 c9                	test   %ecx,%ecx
  801946:	74 0c                	je     801954 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801948:	8b 45 0c             	mov    0xc(%ebp),%eax
  80194b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80194f:	89 14 24             	mov    %edx,(%esp)
  801952:	ff d1                	call   *%ecx
}
  801954:	83 c4 24             	add    $0x24,%esp
  801957:	5b                   	pop    %ebx
  801958:	5d                   	pop    %ebp
  801959:	c3                   	ret    

0080195a <write>:
	return tot;
}

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80195a:	55                   	push   %ebp
  80195b:	89 e5                	mov    %esp,%ebp
  80195d:	53                   	push   %ebx
  80195e:	83 ec 24             	sub    $0x24,%esp
  801961:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801964:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801967:	89 44 24 04          	mov    %eax,0x4(%esp)
  80196b:	89 1c 24             	mov    %ebx,(%esp)
  80196e:	e8 0a fe ff ff       	call   80177d <fd_lookup>
  801973:	85 c0                	test   %eax,%eax
  801975:	78 66                	js     8019dd <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801977:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80197e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801981:	8b 00                	mov    (%eax),%eax
  801983:	89 04 24             	mov    %eax,(%esp)
  801986:	e8 66 fe ff ff       	call   8017f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80198b:	85 c0                	test   %eax,%eax
  80198d:	78 4e                	js     8019dd <write+0x83>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80198f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801992:	f6 42 08 03          	testb  $0x3,0x8(%edx)
  801996:	75 23                	jne    8019bb <write+0x61>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801998:	a1 0c 50 80 00       	mov    0x80500c,%eax
  80199d:	8b 40 48             	mov    0x48(%eax),%eax
  8019a0:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8019a4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019a8:	c7 04 24 45 2f 80 00 	movl   $0x802f45,(%esp)
  8019af:	e8 65 e8 ff ff       	call   800219 <cprintf>
  8019b4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  8019b9:	eb 22                	jmp    8019dd <write+0x83>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8019bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019be:	8b 48 0c             	mov    0xc(%eax),%ecx
  8019c1:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019c6:	85 c9                	test   %ecx,%ecx
  8019c8:	74 13                	je     8019dd <write+0x83>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8019ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8019cd:	89 44 24 08          	mov    %eax,0x8(%esp)
  8019d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019d8:	89 14 24             	mov    %edx,(%esp)
  8019db:	ff d1                	call   *%ecx
}
  8019dd:	83 c4 24             	add    $0x24,%esp
  8019e0:	5b                   	pop    %ebx
  8019e1:	5d                   	pop    %ebp
  8019e2:	c3                   	ret    

008019e3 <read>:
	return r;
}

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8019e3:	55                   	push   %ebp
  8019e4:	89 e5                	mov    %esp,%ebp
  8019e6:	53                   	push   %ebx
  8019e7:	83 ec 24             	sub    $0x24,%esp
  8019ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8019f4:	89 1c 24             	mov    %ebx,(%esp)
  8019f7:	e8 81 fd ff ff       	call   80177d <fd_lookup>
  8019fc:	85 c0                	test   %eax,%eax
  8019fe:	78 6b                	js     801a6b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a00:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a03:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a07:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a0a:	8b 00                	mov    (%eax),%eax
  801a0c:	89 04 24             	mov    %eax,(%esp)
  801a0f:	e8 dd fd ff ff       	call   8017f1 <dev_lookup>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a14:	85 c0                	test   %eax,%eax
  801a16:	78 53                	js     801a6b <read+0x88>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801a18:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801a1b:	8b 42 08             	mov    0x8(%edx),%eax
  801a1e:	83 e0 03             	and    $0x3,%eax
  801a21:	83 f8 01             	cmp    $0x1,%eax
  801a24:	75 23                	jne    801a49 <read+0x66>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801a26:	a1 0c 50 80 00       	mov    0x80500c,%eax
  801a2b:	8b 40 48             	mov    0x48(%eax),%eax
  801a2e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801a32:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a36:	c7 04 24 62 2f 80 00 	movl   $0x802f62,(%esp)
  801a3d:	e8 d7 e7 ff ff       	call   800219 <cprintf>
  801a42:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
		return -E_INVAL;
  801a47:	eb 22                	jmp    801a6b <read+0x88>
	}
	if (!dev->dev_read)
  801a49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a4c:	8b 48 08             	mov    0x8(%eax),%ecx
  801a4f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a54:	85 c9                	test   %ecx,%ecx
  801a56:	74 13                	je     801a6b <read+0x88>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801a58:	8b 45 10             	mov    0x10(%ebp),%eax
  801a5b:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a5f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a62:	89 44 24 04          	mov    %eax,0x4(%esp)
  801a66:	89 14 24             	mov    %edx,(%esp)
  801a69:	ff d1                	call   *%ecx
}
  801a6b:	83 c4 24             	add    $0x24,%esp
  801a6e:	5b                   	pop    %ebx
  801a6f:	5d                   	pop    %ebp
  801a70:	c3                   	ret    

00801a71 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	57                   	push   %edi
  801a75:	56                   	push   %esi
  801a76:	53                   	push   %ebx
  801a77:	83 ec 1c             	sub    $0x1c,%esp
  801a7a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a7d:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a80:	ba 00 00 00 00       	mov    $0x0,%edx
  801a85:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a8a:	b8 00 00 00 00       	mov    $0x0,%eax
  801a8f:	85 f6                	test   %esi,%esi
  801a91:	74 29                	je     801abc <readn+0x4b>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a93:	89 f0                	mov    %esi,%eax
  801a95:	29 d0                	sub    %edx,%eax
  801a97:	89 44 24 08          	mov    %eax,0x8(%esp)
  801a9b:	03 55 0c             	add    0xc(%ebp),%edx
  801a9e:	89 54 24 04          	mov    %edx,0x4(%esp)
  801aa2:	89 3c 24             	mov    %edi,(%esp)
  801aa5:	e8 39 ff ff ff       	call   8019e3 <read>
		if (m < 0)
  801aaa:	85 c0                	test   %eax,%eax
  801aac:	78 0e                	js     801abc <readn+0x4b>
			return m;
		if (m == 0)
  801aae:	85 c0                	test   %eax,%eax
  801ab0:	74 08                	je     801aba <readn+0x49>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801ab2:	01 c3                	add    %eax,%ebx
  801ab4:	89 da                	mov    %ebx,%edx
  801ab6:	39 f3                	cmp    %esi,%ebx
  801ab8:	72 d9                	jb     801a93 <readn+0x22>
  801aba:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801abc:	83 c4 1c             	add    $0x1c,%esp
  801abf:	5b                   	pop    %ebx
  801ac0:	5e                   	pop    %esi
  801ac1:	5f                   	pop    %edi
  801ac2:	5d                   	pop    %ebp
  801ac3:	c3                   	ret    

00801ac4 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  801ac4:	55                   	push   %ebp
  801ac5:	89 e5                	mov    %esp,%ebp
  801ac7:	83 ec 28             	sub    $0x28,%esp
  801aca:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801acd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801ad0:	8b 75 08             	mov    0x8(%ebp),%esi
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801ad3:	89 34 24             	mov    %esi,(%esp)
  801ad6:	e8 05 fc ff ff       	call   8016e0 <fd2num>
  801adb:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801ade:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ae2:	89 04 24             	mov    %eax,(%esp)
  801ae5:	e8 93 fc ff ff       	call   80177d <fd_lookup>
  801aea:	89 c3                	mov    %eax,%ebx
  801aec:	85 c0                	test   %eax,%eax
  801aee:	78 05                	js     801af5 <fd_close+0x31>
  801af0:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801af3:	74 0e                	je     801b03 <fd_close+0x3f>
	    || fd != fd2)
		return (must_exist ? r : 0);
  801af5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801af9:	b8 00 00 00 00       	mov    $0x0,%eax
  801afe:	0f 44 d8             	cmove  %eax,%ebx
  801b01:	eb 3d                	jmp    801b40 <fd_close+0x7c>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801b03:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b06:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b0a:	8b 06                	mov    (%esi),%eax
  801b0c:	89 04 24             	mov    %eax,(%esp)
  801b0f:	e8 dd fc ff ff       	call   8017f1 <dev_lookup>
  801b14:	89 c3                	mov    %eax,%ebx
  801b16:	85 c0                	test   %eax,%eax
  801b18:	78 16                	js     801b30 <fd_close+0x6c>
		if (dev->dev_close)
  801b1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b1d:	8b 40 10             	mov    0x10(%eax),%eax
  801b20:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b25:	85 c0                	test   %eax,%eax
  801b27:	74 07                	je     801b30 <fd_close+0x6c>
			r = (*dev->dev_close)(fd);
  801b29:	89 34 24             	mov    %esi,(%esp)
  801b2c:	ff d0                	call   *%eax
  801b2e:	89 c3                	mov    %eax,%ebx
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801b30:	89 74 24 04          	mov    %esi,0x4(%esp)
  801b34:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801b3b:	e8 0c f4 ff ff       	call   800f4c <sys_page_unmap>
	return r;
}
  801b40:	89 d8                	mov    %ebx,%eax
  801b42:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801b45:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801b48:	89 ec                	mov    %ebp,%esp
  801b4a:	5d                   	pop    %ebp
  801b4b:	c3                   	ret    

00801b4c <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801b4c:	55                   	push   %ebp
  801b4d:	89 e5                	mov    %esp,%ebp
  801b4f:	83 ec 28             	sub    $0x28,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b52:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b55:	89 44 24 04          	mov    %eax,0x4(%esp)
  801b59:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5c:	89 04 24             	mov    %eax,(%esp)
  801b5f:	e8 19 fc ff ff       	call   80177d <fd_lookup>
  801b64:	85 c0                	test   %eax,%eax
  801b66:	78 13                	js     801b7b <close+0x2f>
		return r;
	else
		return fd_close(fd, 1);
  801b68:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  801b6f:	00 
  801b70:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b73:	89 04 24             	mov    %eax,(%esp)
  801b76:	e8 49 ff ff ff       	call   801ac4 <fd_close>
}
  801b7b:	c9                   	leave  
  801b7c:	c3                   	ret    

00801b7d <stat>:
	return (*dev->dev_stat)(fd, stat);
}

int
stat(const char *path, struct Stat *stat)
{
  801b7d:	55                   	push   %ebp
  801b7e:	89 e5                	mov    %esp,%ebp
  801b80:	83 ec 18             	sub    $0x18,%esp
  801b83:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801b86:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801b89:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801b90:	00 
  801b91:	8b 45 08             	mov    0x8(%ebp),%eax
  801b94:	89 04 24             	mov    %eax,(%esp)
  801b97:	e8 78 03 00 00       	call   801f14 <open>
  801b9c:	89 c3                	mov    %eax,%ebx
  801b9e:	85 c0                	test   %eax,%eax
  801ba0:	78 1b                	js     801bbd <stat+0x40>
		return fd;
	r = fstat(fd, stat);
  801ba2:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ba5:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ba9:	89 1c 24             	mov    %ebx,(%esp)
  801bac:	e8 ae fc ff ff       	call   80185f <fstat>
  801bb1:	89 c6                	mov    %eax,%esi
	close(fd);
  801bb3:	89 1c 24             	mov    %ebx,(%esp)
  801bb6:	e8 91 ff ff ff       	call   801b4c <close>
  801bbb:	89 f3                	mov    %esi,%ebx
	return r;
}
  801bbd:	89 d8                	mov    %ebx,%eax
  801bbf:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801bc2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801bc5:	89 ec                	mov    %ebp,%esp
  801bc7:	5d                   	pop    %ebp
  801bc8:	c3                   	ret    

00801bc9 <close_all>:
		return fd_close(fd, 1);
}

void
close_all(void)
{
  801bc9:	55                   	push   %ebp
  801bca:	89 e5                	mov    %esp,%ebp
  801bcc:	53                   	push   %ebx
  801bcd:	83 ec 14             	sub    $0x14,%esp
  801bd0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int i;
	for (i = 0; i < MAXFD; i++)
		close(i);
  801bd5:	89 1c 24             	mov    %ebx,(%esp)
  801bd8:	e8 6f ff ff ff       	call   801b4c <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801bdd:	83 c3 01             	add    $0x1,%ebx
  801be0:	83 fb 20             	cmp    $0x20,%ebx
  801be3:	75 f0                	jne    801bd5 <close_all+0xc>
		close(i);
}
  801be5:	83 c4 14             	add    $0x14,%esp
  801be8:	5b                   	pop    %ebx
  801be9:	5d                   	pop    %ebp
  801bea:	c3                   	ret    

00801beb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801beb:	55                   	push   %ebp
  801bec:	89 e5                	mov    %esp,%ebp
  801bee:	83 ec 58             	sub    $0x58,%esp
  801bf1:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801bf4:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801bf7:	89 7d fc             	mov    %edi,-0x4(%ebp)
  801bfa:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801bfd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801c00:	89 44 24 04          	mov    %eax,0x4(%esp)
  801c04:	8b 45 08             	mov    0x8(%ebp),%eax
  801c07:	89 04 24             	mov    %eax,(%esp)
  801c0a:	e8 6e fb ff ff       	call   80177d <fd_lookup>
  801c0f:	89 c3                	mov    %eax,%ebx
  801c11:	85 c0                	test   %eax,%eax
  801c13:	0f 88 e0 00 00 00    	js     801cf9 <dup+0x10e>
		return r;
	close(newfdnum);
  801c19:	89 3c 24             	mov    %edi,(%esp)
  801c1c:	e8 2b ff ff ff       	call   801b4c <close>

	newfd = INDEX2FD(newfdnum);
  801c21:	8d b7 00 00 0d 00    	lea    0xd0000(%edi),%esi
  801c27:	c1 e6 0c             	shl    $0xc,%esi
	ova = fd2data(oldfd);
  801c2a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c2d:	89 04 24             	mov    %eax,(%esp)
  801c30:	e8 bb fa ff ff       	call   8016f0 <fd2data>
  801c35:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801c37:	89 34 24             	mov    %esi,(%esp)
  801c3a:	e8 b1 fa ff ff       	call   8016f0 <fd2data>
  801c3f:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((vpd[PDX(ova)] & PTE_P) && (vpt[PGNUM(ova)] & PTE_P))
  801c42:	89 da                	mov    %ebx,%edx
  801c44:	89 d8                	mov    %ebx,%eax
  801c46:	c1 e8 16             	shr    $0x16,%eax
  801c49:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801c50:	a8 01                	test   $0x1,%al
  801c52:	74 43                	je     801c97 <dup+0xac>
  801c54:	c1 ea 0c             	shr    $0xc,%edx
  801c57:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801c5e:	a8 01                	test   $0x1,%al
  801c60:	74 35                	je     801c97 <dup+0xac>
		if ((r = sys_page_map(0, ova, 0, nva, vpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801c62:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801c69:	25 07 0e 00 00       	and    $0xe07,%eax
  801c6e:	89 44 24 10          	mov    %eax,0x10(%esp)
  801c72:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801c75:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c79:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801c80:	00 
  801c81:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801c85:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801c8c:	e8 f3 f2 ff ff       	call   800f84 <sys_page_map>
  801c91:	89 c3                	mov    %eax,%ebx
  801c93:	85 c0                	test   %eax,%eax
  801c95:	78 3f                	js     801cd6 <dup+0xeb>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, vpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801c97:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801c9a:	89 c2                	mov    %eax,%edx
  801c9c:	c1 ea 0c             	shr    $0xc,%edx
  801c9f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801ca6:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801cac:	89 54 24 10          	mov    %edx,0x10(%esp)
  801cb0:	89 74 24 0c          	mov    %esi,0xc(%esp)
  801cb4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801cbb:	00 
  801cbc:	89 44 24 04          	mov    %eax,0x4(%esp)
  801cc0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cc7:	e8 b8 f2 ff ff       	call   800f84 <sys_page_map>
  801ccc:	89 c3                	mov    %eax,%ebx
  801cce:	85 c0                	test   %eax,%eax
  801cd0:	78 04                	js     801cd6 <dup+0xeb>
  801cd2:	89 fb                	mov    %edi,%ebx
  801cd4:	eb 23                	jmp    801cf9 <dup+0x10e>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801cd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cda:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801ce1:	e8 66 f2 ff ff       	call   800f4c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801ce6:	8b 45 d4             	mov    -0x2c(%ebp),%eax
  801ce9:	89 44 24 04          	mov    %eax,0x4(%esp)
  801ced:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801cf4:	e8 53 f2 ff ff       	call   800f4c <sys_page_unmap>
	return r;
}
  801cf9:	89 d8                	mov    %ebx,%eax
  801cfb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801cfe:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801d01:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801d04:	89 ec                	mov    %ebp,%esp
  801d06:	5d                   	pop    %ebp
  801d07:	c3                   	ret    

00801d08 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801d08:	55                   	push   %ebp
  801d09:	89 e5                	mov    %esp,%ebp
  801d0b:	83 ec 18             	sub    $0x18,%esp
  801d0e:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801d11:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801d14:	89 c3                	mov    %eax,%ebx
  801d16:	89 d6                	mov    %edx,%esi
	static envid_t fsenv;
	if (fsenv == 0)
  801d18:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801d1f:	75 11                	jne    801d32 <fsipc+0x2a>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801d21:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  801d28:	e8 73 f8 ff ff       	call   8015a0 <ipc_find_env>
  801d2d:	a3 00 50 80 00       	mov    %eax,0x805000
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801d32:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  801d39:	00 
  801d3a:	c7 44 24 08 00 60 80 	movl   $0x806000,0x8(%esp)
  801d41:	00 
  801d42:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801d46:	a1 00 50 80 00       	mov    0x805000,%eax
  801d4b:	89 04 24             	mov    %eax,(%esp)
  801d4e:	e8 91 f8 ff ff       	call   8015e4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801d53:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  801d5a:	00 
  801d5b:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d5f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801d66:	e8 e4 f8 ff ff       	call   80164f <ipc_recv>
}
  801d6b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801d6e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801d71:	89 ec                	mov    %ebp,%esp
  801d73:	5d                   	pop    %ebp
  801d74:	c3                   	ret    

00801d75 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801d75:	55                   	push   %ebp
  801d76:	89 e5                	mov    %esp,%ebp
  801d78:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801d7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d7e:	8b 40 0c             	mov    0xc(%eax),%eax
  801d81:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801d86:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d89:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801d8e:	ba 00 00 00 00       	mov    $0x0,%edx
  801d93:	b8 02 00 00 00       	mov    $0x2,%eax
  801d98:	e8 6b ff ff ff       	call   801d08 <fsipc>
}
  801d9d:	c9                   	leave  
  801d9e:	c3                   	ret    

00801d9f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801d9f:	55                   	push   %ebp
  801da0:	89 e5                	mov    %esp,%ebp
  801da2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801da5:	8b 45 08             	mov    0x8(%ebp),%eax
  801da8:	8b 40 0c             	mov    0xc(%eax),%eax
  801dab:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801db0:	ba 00 00 00 00       	mov    $0x0,%edx
  801db5:	b8 06 00 00 00       	mov    $0x6,%eax
  801dba:	e8 49 ff ff ff       	call   801d08 <fsipc>
}
  801dbf:	c9                   	leave  
  801dc0:	c3                   	ret    

00801dc1 <sync>:
}

// Synchronize disk with buffer cache
int
sync(void)
{
  801dc1:	55                   	push   %ebp
  801dc2:	89 e5                	mov    %esp,%ebp
  801dc4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801dc7:	ba 00 00 00 00       	mov    $0x0,%edx
  801dcc:	b8 08 00 00 00       	mov    $0x8,%eax
  801dd1:	e8 32 ff ff ff       	call   801d08 <fsipc>
}
  801dd6:	c9                   	leave  
  801dd7:	c3                   	ret    

00801dd8 <devfile_stat>:
  return fsipc(FSREQ_WRITE, NULL);	
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801dd8:	55                   	push   %ebp
  801dd9:	89 e5                	mov    %esp,%ebp
  801ddb:	53                   	push   %ebx
  801ddc:	83 ec 14             	sub    $0x14,%esp
  801ddf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801de2:	8b 45 08             	mov    0x8(%ebp),%eax
  801de5:	8b 40 0c             	mov    0xc(%eax),%eax
  801de8:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ded:	ba 00 00 00 00       	mov    $0x0,%edx
  801df2:	b8 05 00 00 00       	mov    $0x5,%eax
  801df7:	e8 0c ff ff ff       	call   801d08 <fsipc>
  801dfc:	85 c0                	test   %eax,%eax
  801dfe:	78 2b                	js     801e2b <devfile_stat+0x53>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801e00:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801e07:	00 
  801e08:	89 1c 24             	mov    %ebx,(%esp)
  801e0b:	e8 4a eb ff ff       	call   80095a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801e10:	a1 80 60 80 00       	mov    0x806080,%eax
  801e15:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801e1b:	a1 84 60 80 00       	mov    0x806084,%eax
  801e20:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
  801e26:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
  801e2b:	83 c4 14             	add    $0x14,%esp
  801e2e:	5b                   	pop    %ebx
  801e2f:	5d                   	pop    %ebp
  801e30:	c3                   	ret    

00801e31 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801e31:	55                   	push   %ebp
  801e32:	89 e5                	mov    %esp,%ebp
  801e34:	83 ec 18             	sub    $0x18,%esp
  801e37:	8b 45 10             	mov    0x10(%ebp),%eax
	// Make an FSREQ_WRITE request to the file system server.  Be
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
  fsipcbuf.write.req_fileid = fd->fd_file.id;
  801e3a:	8b 55 08             	mov    0x8(%ebp),%edx
  801e3d:	8b 52 0c             	mov    0xc(%edx),%edx
  801e40:	89 15 00 60 80 00    	mov    %edx,0x806000
  fsipcbuf.write.req_n = n;
  801e46:	a3 04 60 80 00       	mov    %eax,0x806004
  memmove(fsipcbuf.write.req_buf, buf,
  801e4b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801e50:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801e55:	0f 47 c2             	cmova  %edx,%eax
  801e58:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e5f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801e63:	c7 04 24 08 60 80 00 	movl   $0x806008,(%esp)
  801e6a:	e8 d6 ec ff ff       	call   800b45 <memmove>
      MIN(n, PGSIZE - sizeof(int) - sizeof(size_t)));
  return fsipc(FSREQ_WRITE, NULL);	
  801e6f:	ba 00 00 00 00       	mov    $0x0,%edx
  801e74:	b8 04 00 00 00       	mov    $0x4,%eax
  801e79:	e8 8a fe ff ff       	call   801d08 <fsipc>
}
  801e7e:	c9                   	leave  
  801e7f:	c3                   	ret    

00801e80 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801e80:	55                   	push   %ebp
  801e81:	89 e5                	mov    %esp,%ebp
  801e83:	53                   	push   %ebx
  801e84:	83 ec 14             	sub    $0x14,%esp
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	// LAB 5: Your code here
  int r;

  fsipcbuf.read.req_fileid = fd->fd_file.id;
  801e87:	8b 45 08             	mov    0x8(%ebp),%eax
  801e8a:	8b 40 0c             	mov    0xc(%eax),%eax
  801e8d:	a3 00 60 80 00       	mov    %eax,0x806000
  fsipcbuf.read.req_n = n;
  801e92:	8b 45 10             	mov    0x10(%ebp),%eax
  801e95:	a3 04 60 80 00       	mov    %eax,0x806004
  if((r = fsipc(FSREQ_READ, NULL)) < 0)
  801e9a:	ba 00 00 00 00       	mov    $0x0,%edx
  801e9f:	b8 03 00 00 00       	mov    $0x3,%eax
  801ea4:	e8 5f fe ff ff       	call   801d08 <fsipc>
  801ea9:	89 c3                	mov    %eax,%ebx
  801eab:	85 c0                	test   %eax,%eax
  801ead:	78 17                	js     801ec6 <devfile_read+0x46>
    return r;
  memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801eaf:	89 44 24 08          	mov    %eax,0x8(%esp)
  801eb3:	c7 44 24 04 00 60 80 	movl   $0x806000,0x4(%esp)
  801eba:	00 
  801ebb:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ebe:	89 04 24             	mov    %eax,(%esp)
  801ec1:	e8 7f ec ff ff       	call   800b45 <memmove>
  return r;	
}
  801ec6:	89 d8                	mov    %ebx,%eax
  801ec8:	83 c4 14             	add    $0x14,%esp
  801ecb:	5b                   	pop    %ebx
  801ecc:	5d                   	pop    %ebp
  801ecd:	c3                   	ret    

00801ece <remove>:
}

// Delete a file
int
remove(const char *path)
{
  801ece:	55                   	push   %ebp
  801ecf:	89 e5                	mov    %esp,%ebp
  801ed1:	53                   	push   %ebx
  801ed2:	83 ec 14             	sub    $0x14,%esp
  801ed5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (strlen(path) >= MAXPATHLEN)
  801ed8:	89 1c 24             	mov    %ebx,(%esp)
  801edb:	e8 30 ea ff ff       	call   800910 <strlen>
  801ee0:	89 c2                	mov    %eax,%edx
  801ee2:	b8 f4 ff ff ff       	mov    $0xfffffff4,%eax
  801ee7:	81 fa ff 03 00 00    	cmp    $0x3ff,%edx
  801eed:	7f 1f                	jg     801f0e <remove+0x40>
		return -E_BAD_PATH;
	strcpy(fsipcbuf.remove.req_path, path);
  801eef:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  801ef3:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801efa:	e8 5b ea ff ff       	call   80095a <strcpy>
	return fsipc(FSREQ_REMOVE, NULL);
  801eff:	ba 00 00 00 00       	mov    $0x0,%edx
  801f04:	b8 07 00 00 00       	mov    $0x7,%eax
  801f09:	e8 fa fd ff ff       	call   801d08 <fsipc>
}
  801f0e:	83 c4 14             	add    $0x14,%esp
  801f11:	5b                   	pop    %ebx
  801f12:	5d                   	pop    %ebp
  801f13:	c3                   	ret    

00801f14 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801f14:	55                   	push   %ebp
  801f15:	89 e5                	mov    %esp,%ebp
  801f17:	83 ec 28             	sub    $0x28,%esp
  801f1a:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  801f1d:	89 75 fc             	mov    %esi,-0x4(%ebp)
  801f20:	8b 75 08             	mov    0x8(%ebp),%esi

	// LAB 5: Your code here.
  int r;
  struct Fd *fd;

  r = fd_alloc(&fd);
  801f23:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f26:	89 04 24             	mov    %eax,(%esp)
  801f29:	e8 dd f7 ff ff       	call   80170b <fd_alloc>
  801f2e:	89 c3                	mov    %eax,%ebx
  if (r < 0) return r;
  801f30:	85 c0                	test   %eax,%eax
  801f32:	0f 88 89 00 00 00    	js     801fc1 <open+0xad>

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801f38:	89 34 24             	mov    %esi,(%esp)
  801f3b:	e8 d0 e9 ff ff       	call   800910 <strlen>
  fsipcbuf.open.req_omode = mode;
  r = fsipc(FSREQ_OPEN, fd);
  if (r < 0) goto out;
  return fd2num(fd);
out:
  assert(fd_close(fd, 0) == 0);
  801f40:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx

        // DO NOT ALLOCATE !!
        //r = sys_page_alloc(0, fd, PTE_U|PTE_W|PTE_P);
        //if (r < 0) goto out;

  if (strlen(path) >= MAXPATHLEN)
  801f45:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801f4a:	7f 75                	jg     801fc1 <open+0xad>
    return -E_BAD_PATH;
  strcpy(fsipcbuf.open.req_path, path);
  801f4c:	89 74 24 04          	mov    %esi,0x4(%esp)
  801f50:	c7 04 24 00 60 80 00 	movl   $0x806000,(%esp)
  801f57:	e8 fe e9 ff ff       	call   80095a <strcpy>
  fsipcbuf.open.req_omode = mode;
  801f5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f5f:	a3 00 64 80 00       	mov    %eax,0x806400
  r = fsipc(FSREQ_OPEN, fd);
  801f64:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f67:	b8 01 00 00 00       	mov    $0x1,%eax
  801f6c:	e8 97 fd ff ff       	call   801d08 <fsipc>
  801f71:	89 c3                	mov    %eax,%ebx
  if (r < 0) goto out;
  801f73:	85 c0                	test   %eax,%eax
  801f75:	78 0f                	js     801f86 <open+0x72>
  return fd2num(fd);
  801f77:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f7a:	89 04 24             	mov    %eax,(%esp)
  801f7d:	e8 5e f7 ff ff       	call   8016e0 <fd2num>
  801f82:	89 c3                	mov    %eax,%ebx
  801f84:	eb 3b                	jmp    801fc1 <open+0xad>
out:
  assert(fd_close(fd, 0) == 0);
  801f86:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  801f8d:	00 
  801f8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f91:	89 04 24             	mov    %eax,(%esp)
  801f94:	e8 2b fb ff ff       	call   801ac4 <fd_close>
  801f99:	85 c0                	test   %eax,%eax
  801f9b:	74 24                	je     801fc1 <open+0xad>
  801f9d:	c7 44 24 0c 8c 2f 80 	movl   $0x802f8c,0xc(%esp)
  801fa4:	00 
  801fa5:	c7 44 24 08 a1 2f 80 	movl   $0x802fa1,0x8(%esp)
  801fac:	00 
  801fad:	c7 44 24 04 5a 00 00 	movl   $0x5a,0x4(%esp)
  801fb4:	00 
  801fb5:	c7 04 24 b6 2f 80 00 	movl   $0x802fb6,(%esp)
  801fbc:	e8 13 05 00 00       	call   8024d4 <_panic>
  return r;
}
  801fc1:	89 d8                	mov    %ebx,%eax
  801fc3:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  801fc6:	8b 75 fc             	mov    -0x4(%ebp),%esi
  801fc9:	89 ec                	mov    %ebp,%esp
  801fcb:	5d                   	pop    %ebp
  801fcc:	c3                   	ret    
  801fcd:	00 00                	add    %al,(%eax)
	...

00801fd0 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801fd0:	55                   	push   %ebp
  801fd1:	89 e5                	mov    %esp,%ebp
  801fd3:	83 ec 18             	sub    $0x18,%esp
	strcpy(stat->st_name, "<sock>");
  801fd6:	c7 44 24 04 c1 2f 80 	movl   $0x802fc1,0x4(%esp)
  801fdd:	00 
  801fde:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fe1:	89 04 24             	mov    %eax,(%esp)
  801fe4:	e8 71 e9 ff ff       	call   80095a <strcpy>
	return 0;
}
  801fe9:	b8 00 00 00 00       	mov    $0x0,%eax
  801fee:	c9                   	leave  
  801fef:	c3                   	ret    

00801ff0 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801ff0:	55                   	push   %ebp
  801ff1:	89 e5                	mov    %esp,%ebp
  801ff3:	53                   	push   %ebx
  801ff4:	83 ec 14             	sub    $0x14,%esp
  801ff7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801ffa:	89 1c 24             	mov    %ebx,(%esp)
  801ffd:	e8 c2 05 00 00       	call   8025c4 <pageref>
  802002:	89 c2                	mov    %eax,%edx
  802004:	b8 00 00 00 00       	mov    $0x0,%eax
  802009:	83 fa 01             	cmp    $0x1,%edx
  80200c:	75 0b                	jne    802019 <devsock_close+0x29>
		return nsipc_close(fd->fd_sock.sockid);
  80200e:	8b 43 0c             	mov    0xc(%ebx),%eax
  802011:	89 04 24             	mov    %eax,(%esp)
  802014:	e8 b9 02 00 00       	call   8022d2 <nsipc_close>
	else
		return 0;
}
  802019:	83 c4 14             	add    $0x14,%esp
  80201c:	5b                   	pop    %ebx
  80201d:	5d                   	pop    %ebp
  80201e:	c3                   	ret    

0080201f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80201f:	55                   	push   %ebp
  802020:	89 e5                	mov    %esp,%ebp
  802022:	83 ec 18             	sub    $0x18,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  802025:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80202c:	00 
  80202d:	8b 45 10             	mov    0x10(%ebp),%eax
  802030:	89 44 24 08          	mov    %eax,0x8(%esp)
  802034:	8b 45 0c             	mov    0xc(%ebp),%eax
  802037:	89 44 24 04          	mov    %eax,0x4(%esp)
  80203b:	8b 45 08             	mov    0x8(%ebp),%eax
  80203e:	8b 40 0c             	mov    0xc(%eax),%eax
  802041:	89 04 24             	mov    %eax,(%esp)
  802044:	e8 c5 02 00 00       	call   80230e <nsipc_send>
}
  802049:	c9                   	leave  
  80204a:	c3                   	ret    

0080204b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80204b:	55                   	push   %ebp
  80204c:	89 e5                	mov    %esp,%ebp
  80204e:	83 ec 18             	sub    $0x18,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  802051:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  802058:	00 
  802059:	8b 45 10             	mov    0x10(%ebp),%eax
  80205c:	89 44 24 08          	mov    %eax,0x8(%esp)
  802060:	8b 45 0c             	mov    0xc(%ebp),%eax
  802063:	89 44 24 04          	mov    %eax,0x4(%esp)
  802067:	8b 45 08             	mov    0x8(%ebp),%eax
  80206a:	8b 40 0c             	mov    0xc(%eax),%eax
  80206d:	89 04 24             	mov    %eax,(%esp)
  802070:	e8 0c 03 00 00       	call   802381 <nsipc_recv>
}
  802075:	c9                   	leave  
  802076:	c3                   	ret    

00802077 <alloc_sockfd>:
	return sfd->fd_sock.sockid;
}

static int
alloc_sockfd(int sockid)
{
  802077:	55                   	push   %ebp
  802078:	89 e5                	mov    %esp,%ebp
  80207a:	56                   	push   %esi
  80207b:	53                   	push   %ebx
  80207c:	83 ec 20             	sub    $0x20,%esp
  80207f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  802081:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802084:	89 04 24             	mov    %eax,(%esp)
  802087:	e8 7f f6 ff ff       	call   80170b <fd_alloc>
  80208c:	89 c3                	mov    %eax,%ebx
  80208e:	85 c0                	test   %eax,%eax
  802090:	78 21                	js     8020b3 <alloc_sockfd+0x3c>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  802092:	c7 44 24 08 07 04 00 	movl   $0x407,0x8(%esp)
  802099:	00 
  80209a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80209d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8020a1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8020a8:	e8 10 ef ff ff       	call   800fbd <sys_page_alloc>
  8020ad:	89 c3                	mov    %eax,%ebx
alloc_sockfd(int sockid)
{
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8020af:	85 c0                	test   %eax,%eax
  8020b1:	79 0a                	jns    8020bd <alloc_sockfd+0x46>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
		nsipc_close(sockid);
  8020b3:	89 34 24             	mov    %esi,(%esp)
  8020b6:	e8 17 02 00 00       	call   8022d2 <nsipc_close>
		return r;
  8020bb:	eb 28                	jmp    8020e5 <alloc_sockfd+0x6e>
	}

	sfd->fd_dev_id = devsock.dev_id;
  8020bd:	8b 15 20 40 80 00    	mov    0x804020,%edx
  8020c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8020c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020cb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8020d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020d5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8020d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020db:	89 04 24             	mov    %eax,(%esp)
  8020de:	e8 fd f5 ff ff       	call   8016e0 <fd2num>
  8020e3:	89 c3                	mov    %eax,%ebx
}
  8020e5:	89 d8                	mov    %ebx,%eax
  8020e7:	83 c4 20             	add    $0x20,%esp
  8020ea:	5b                   	pop    %ebx
  8020eb:	5e                   	pop    %esi
  8020ec:	5d                   	pop    %ebp
  8020ed:	c3                   	ret    

008020ee <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  8020ee:	55                   	push   %ebp
  8020ef:	89 e5                	mov    %esp,%ebp
  8020f1:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  8020f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8020f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8020fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  802102:	8b 45 08             	mov    0x8(%ebp),%eax
  802105:	89 04 24             	mov    %eax,(%esp)
  802108:	e8 79 01 00 00       	call   802286 <nsipc_socket>
  80210d:	85 c0                	test   %eax,%eax
  80210f:	78 05                	js     802116 <socket+0x28>
		return r;
	return alloc_sockfd(r);
  802111:	e8 61 ff ff ff       	call   802077 <alloc_sockfd>
}
  802116:	c9                   	leave  
  802117:	c3                   	ret    

00802118 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  802118:	55                   	push   %ebp
  802119:	89 e5                	mov    %esp,%ebp
  80211b:	83 ec 28             	sub    $0x28,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80211e:	8d 55 f4             	lea    -0xc(%ebp),%edx
  802121:	89 54 24 04          	mov    %edx,0x4(%esp)
  802125:	89 04 24             	mov    %eax,(%esp)
  802128:	e8 50 f6 ff ff       	call   80177d <fd_lookup>
  80212d:	85 c0                	test   %eax,%eax
  80212f:	78 15                	js     802146 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  802131:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802134:	8b 0a                	mov    (%edx),%ecx
  802136:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80213b:	3b 0d 20 40 80 00    	cmp    0x804020,%ecx
  802141:	75 03                	jne    802146 <fd2sockid+0x2e>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  802143:	8b 42 0c             	mov    0xc(%edx),%eax
}
  802146:	c9                   	leave  
  802147:	c3                   	ret    

00802148 <listen>:
	return nsipc_connect(r, name, namelen);
}

int
listen(int s, int backlog)
{
  802148:	55                   	push   %ebp
  802149:	89 e5                	mov    %esp,%ebp
  80214b:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80214e:	8b 45 08             	mov    0x8(%ebp),%eax
  802151:	e8 c2 ff ff ff       	call   802118 <fd2sockid>
  802156:	85 c0                	test   %eax,%eax
  802158:	78 0f                	js     802169 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80215a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80215d:	89 54 24 04          	mov    %edx,0x4(%esp)
  802161:	89 04 24             	mov    %eax,(%esp)
  802164:	e8 47 01 00 00       	call   8022b0 <nsipc_listen>
}
  802169:	c9                   	leave  
  80216a:	c3                   	ret    

0080216b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80216b:	55                   	push   %ebp
  80216c:	89 e5                	mov    %esp,%ebp
  80216e:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  802171:	8b 45 08             	mov    0x8(%ebp),%eax
  802174:	e8 9f ff ff ff       	call   802118 <fd2sockid>
  802179:	85 c0                	test   %eax,%eax
  80217b:	78 16                	js     802193 <connect+0x28>
		return r;
	return nsipc_connect(r, name, namelen);
  80217d:	8b 55 10             	mov    0x10(%ebp),%edx
  802180:	89 54 24 08          	mov    %edx,0x8(%esp)
  802184:	8b 55 0c             	mov    0xc(%ebp),%edx
  802187:	89 54 24 04          	mov    %edx,0x4(%esp)
  80218b:	89 04 24             	mov    %eax,(%esp)
  80218e:	e8 6e 02 00 00       	call   802401 <nsipc_connect>
}
  802193:	c9                   	leave  
  802194:	c3                   	ret    

00802195 <shutdown>:
	return nsipc_bind(r, name, namelen);
}

int
shutdown(int s, int how)
{
  802195:	55                   	push   %ebp
  802196:	89 e5                	mov    %esp,%ebp
  802198:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80219b:	8b 45 08             	mov    0x8(%ebp),%eax
  80219e:	e8 75 ff ff ff       	call   802118 <fd2sockid>
  8021a3:	85 c0                	test   %eax,%eax
  8021a5:	78 0f                	js     8021b6 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8021a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021aa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021ae:	89 04 24             	mov    %eax,(%esp)
  8021b1:	e8 36 01 00 00       	call   8022ec <nsipc_shutdown>
}
  8021b6:	c9                   	leave  
  8021b7:	c3                   	ret    

008021b8 <bind>:
	return alloc_sockfd(r);
}

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8021b8:	55                   	push   %ebp
  8021b9:	89 e5                	mov    %esp,%ebp
  8021bb:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021be:	8b 45 08             	mov    0x8(%ebp),%eax
  8021c1:	e8 52 ff ff ff       	call   802118 <fd2sockid>
  8021c6:	85 c0                	test   %eax,%eax
  8021c8:	78 16                	js     8021e0 <bind+0x28>
		return r;
	return nsipc_bind(r, name, namelen);
  8021ca:	8b 55 10             	mov    0x10(%ebp),%edx
  8021cd:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021d1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021d4:	89 54 24 04          	mov    %edx,0x4(%esp)
  8021d8:	89 04 24             	mov    %eax,(%esp)
  8021db:	e8 60 02 00 00       	call   802440 <nsipc_bind>
}
  8021e0:	c9                   	leave  
  8021e1:	c3                   	ret    

008021e2 <accept>:
	return fd2num(sfd);
}

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8021e2:	55                   	push   %ebp
  8021e3:	89 e5                	mov    %esp,%ebp
  8021e5:	83 ec 18             	sub    $0x18,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8021e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8021eb:	e8 28 ff ff ff       	call   802118 <fd2sockid>
  8021f0:	85 c0                	test   %eax,%eax
  8021f2:	78 1f                	js     802213 <accept+0x31>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8021f4:	8b 55 10             	mov    0x10(%ebp),%edx
  8021f7:	89 54 24 08          	mov    %edx,0x8(%esp)
  8021fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021fe:	89 54 24 04          	mov    %edx,0x4(%esp)
  802202:	89 04 24             	mov    %eax,(%esp)
  802205:	e8 75 02 00 00       	call   80247f <nsipc_accept>
  80220a:	85 c0                	test   %eax,%eax
  80220c:	78 05                	js     802213 <accept+0x31>
		return r;
	return alloc_sockfd(r);
  80220e:	e8 64 fe ff ff       	call   802077 <alloc_sockfd>
}
  802213:	c9                   	leave  
  802214:	c3                   	ret    
	...

00802220 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  802220:	55                   	push   %ebp
  802221:	89 e5                	mov    %esp,%ebp
  802223:	53                   	push   %ebx
  802224:	83 ec 14             	sub    $0x14,%esp
  802227:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  802229:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  802230:	75 11                	jne    802243 <nsipc+0x23>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  802232:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  802239:	e8 62 f3 ff ff       	call   8015a0 <ipc_find_env>
  80223e:	a3 04 50 80 00       	mov    %eax,0x805004
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  802243:	c7 44 24 0c 07 00 00 	movl   $0x7,0xc(%esp)
  80224a:	00 
  80224b:	c7 44 24 08 00 70 80 	movl   $0x807000,0x8(%esp)
  802252:	00 
  802253:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  802257:	a1 04 50 80 00       	mov    0x805004,%eax
  80225c:	89 04 24             	mov    %eax,(%esp)
  80225f:	e8 80 f3 ff ff       	call   8015e4 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  802264:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80226b:	00 
  80226c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  802273:	00 
  802274:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80227b:	e8 cf f3 ff ff       	call   80164f <ipc_recv>
}
  802280:	83 c4 14             	add    $0x14,%esp
  802283:	5b                   	pop    %ebx
  802284:	5d                   	pop    %ebp
  802285:	c3                   	ret    

00802286 <nsipc_socket>:
	return nsipc(NSREQ_SEND);
}

int
nsipc_socket(int domain, int type, int protocol)
{
  802286:	55                   	push   %ebp
  802287:	89 e5                	mov    %esp,%ebp
  802289:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  80228c:	8b 45 08             	mov    0x8(%ebp),%eax
  80228f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  802294:	8b 45 0c             	mov    0xc(%ebp),%eax
  802297:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  80229c:	8b 45 10             	mov    0x10(%ebp),%eax
  80229f:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8022a4:	b8 09 00 00 00       	mov    $0x9,%eax
  8022a9:	e8 72 ff ff ff       	call   802220 <nsipc>
}
  8022ae:	c9                   	leave  
  8022af:	c3                   	ret    

008022b0 <nsipc_listen>:
	return nsipc(NSREQ_CONNECT);
}

int
nsipc_listen(int s, int backlog)
{
  8022b0:	55                   	push   %ebp
  8022b1:	89 e5                	mov    %esp,%ebp
  8022b3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8022b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8022b9:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  8022be:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022c1:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  8022c6:	b8 06 00 00 00       	mov    $0x6,%eax
  8022cb:	e8 50 ff ff ff       	call   802220 <nsipc>
}
  8022d0:	c9                   	leave  
  8022d1:	c3                   	ret    

008022d2 <nsipc_close>:
	return nsipc(NSREQ_SHUTDOWN);
}

int
nsipc_close(int s)
{
  8022d2:	55                   	push   %ebp
  8022d3:	89 e5                	mov    %esp,%ebp
  8022d5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8022d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8022db:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  8022e0:	b8 04 00 00 00       	mov    $0x4,%eax
  8022e5:	e8 36 ff ff ff       	call   802220 <nsipc>
}
  8022ea:	c9                   	leave  
  8022eb:	c3                   	ret    

008022ec <nsipc_shutdown>:
	return nsipc(NSREQ_BIND);
}

int
nsipc_shutdown(int s, int how)
{
  8022ec:	55                   	push   %ebp
  8022ed:	89 e5                	mov    %esp,%ebp
  8022ef:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  8022f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8022f5:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  8022fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022fd:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  802302:	b8 03 00 00 00       	mov    $0x3,%eax
  802307:	e8 14 ff ff ff       	call   802220 <nsipc>
}
  80230c:	c9                   	leave  
  80230d:	c3                   	ret    

0080230e <nsipc_send>:
	return r;
}

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  80230e:	55                   	push   %ebp
  80230f:	89 e5                	mov    %esp,%ebp
  802311:	53                   	push   %ebx
  802312:	83 ec 14             	sub    $0x14,%esp
  802315:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802318:	8b 45 08             	mov    0x8(%ebp),%eax
  80231b:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  802320:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802326:	7e 24                	jle    80234c <nsipc_send+0x3e>
  802328:	c7 44 24 0c cd 2f 80 	movl   $0x802fcd,0xc(%esp)
  80232f:	00 
  802330:	c7 44 24 08 a1 2f 80 	movl   $0x802fa1,0x8(%esp)
  802337:	00 
  802338:	c7 44 24 04 6c 00 00 	movl   $0x6c,0x4(%esp)
  80233f:	00 
  802340:	c7 04 24 d9 2f 80 00 	movl   $0x802fd9,(%esp)
  802347:	e8 88 01 00 00       	call   8024d4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  80234c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802350:	8b 45 0c             	mov    0xc(%ebp),%eax
  802353:	89 44 24 04          	mov    %eax,0x4(%esp)
  802357:	c7 04 24 0c 70 80 00 	movl   $0x80700c,(%esp)
  80235e:	e8 e2 e7 ff ff       	call   800b45 <memmove>
	nsipcbuf.send.req_size = size;
  802363:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  802369:	8b 45 14             	mov    0x14(%ebp),%eax
  80236c:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  802371:	b8 08 00 00 00       	mov    $0x8,%eax
  802376:	e8 a5 fe ff ff       	call   802220 <nsipc>
}
  80237b:	83 c4 14             	add    $0x14,%esp
  80237e:	5b                   	pop    %ebx
  80237f:	5d                   	pop    %ebp
  802380:	c3                   	ret    

00802381 <nsipc_recv>:
	return nsipc(NSREQ_LISTEN);
}

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  802381:	55                   	push   %ebp
  802382:	89 e5                	mov    %esp,%ebp
  802384:	56                   	push   %esi
  802385:	53                   	push   %ebx
  802386:	83 ec 10             	sub    $0x10,%esp
  802389:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80238c:	8b 45 08             	mov    0x8(%ebp),%eax
  80238f:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  802394:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  80239a:	8b 45 14             	mov    0x14(%ebp),%eax
  80239d:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8023a2:	b8 07 00 00 00       	mov    $0x7,%eax
  8023a7:	e8 74 fe ff ff       	call   802220 <nsipc>
  8023ac:	89 c3                	mov    %eax,%ebx
  8023ae:	85 c0                	test   %eax,%eax
  8023b0:	78 46                	js     8023f8 <nsipc_recv+0x77>
		assert(r < 1600 && r <= len);
  8023b2:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8023b7:	7f 04                	jg     8023bd <nsipc_recv+0x3c>
  8023b9:	39 c6                	cmp    %eax,%esi
  8023bb:	7d 24                	jge    8023e1 <nsipc_recv+0x60>
  8023bd:	c7 44 24 0c e5 2f 80 	movl   $0x802fe5,0xc(%esp)
  8023c4:	00 
  8023c5:	c7 44 24 08 a1 2f 80 	movl   $0x802fa1,0x8(%esp)
  8023cc:	00 
  8023cd:	c7 44 24 04 61 00 00 	movl   $0x61,0x4(%esp)
  8023d4:	00 
  8023d5:	c7 04 24 d9 2f 80 00 	movl   $0x802fd9,(%esp)
  8023dc:	e8 f3 00 00 00       	call   8024d4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8023e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023e5:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8023ec:	00 
  8023ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8023f0:	89 04 24             	mov    %eax,(%esp)
  8023f3:	e8 4d e7 ff ff       	call   800b45 <memmove>
	}

	return r;
}
  8023f8:	89 d8                	mov    %ebx,%eax
  8023fa:	83 c4 10             	add    $0x10,%esp
  8023fd:	5b                   	pop    %ebx
  8023fe:	5e                   	pop    %esi
  8023ff:	5d                   	pop    %ebp
  802400:	c3                   	ret    

00802401 <nsipc_connect>:
	return nsipc(NSREQ_CLOSE);
}

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  802401:	55                   	push   %ebp
  802402:	89 e5                	mov    %esp,%ebp
  802404:	53                   	push   %ebx
  802405:	83 ec 14             	sub    $0x14,%esp
  802408:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  80240b:	8b 45 08             	mov    0x8(%ebp),%eax
  80240e:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  802413:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802417:	8b 45 0c             	mov    0xc(%ebp),%eax
  80241a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80241e:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802425:	e8 1b e7 ff ff       	call   800b45 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  80242a:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  802430:	b8 05 00 00 00       	mov    $0x5,%eax
  802435:	e8 e6 fd ff ff       	call   802220 <nsipc>
}
  80243a:	83 c4 14             	add    $0x14,%esp
  80243d:	5b                   	pop    %ebx
  80243e:	5d                   	pop    %ebp
  80243f:	c3                   	ret    

00802440 <nsipc_bind>:
	return r;
}

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  802440:	55                   	push   %ebp
  802441:	89 e5                	mov    %esp,%ebp
  802443:	53                   	push   %ebx
  802444:	83 ec 14             	sub    $0x14,%esp
  802447:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80244a:	8b 45 08             	mov    0x8(%ebp),%eax
  80244d:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  802452:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802456:	8b 45 0c             	mov    0xc(%ebp),%eax
  802459:	89 44 24 04          	mov    %eax,0x4(%esp)
  80245d:	c7 04 24 04 70 80 00 	movl   $0x807004,(%esp)
  802464:	e8 dc e6 ff ff       	call   800b45 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  802469:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  80246f:	b8 02 00 00 00       	mov    $0x2,%eax
  802474:	e8 a7 fd ff ff       	call   802220 <nsipc>
}
  802479:	83 c4 14             	add    $0x14,%esp
  80247c:	5b                   	pop    %ebx
  80247d:	5d                   	pop    %ebp
  80247e:	c3                   	ret    

0080247f <nsipc_accept>:
	return ipc_recv(NULL, NULL, NULL);
}

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  80247f:	55                   	push   %ebp
  802480:	89 e5                	mov    %esp,%ebp
  802482:	83 ec 18             	sub    $0x18,%esp
  802485:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  802488:	89 75 fc             	mov    %esi,-0x4(%ebp)
	int r;

	nsipcbuf.accept.req_s = s;
  80248b:	8b 45 08             	mov    0x8(%ebp),%eax
  80248e:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  802493:	b8 01 00 00 00       	mov    $0x1,%eax
  802498:	e8 83 fd ff ff       	call   802220 <nsipc>
  80249d:	89 c3                	mov    %eax,%ebx
  80249f:	85 c0                	test   %eax,%eax
  8024a1:	78 25                	js     8024c8 <nsipc_accept+0x49>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8024a3:	be 10 70 80 00       	mov    $0x807010,%esi
  8024a8:	8b 06                	mov    (%esi),%eax
  8024aa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024ae:	c7 44 24 04 00 70 80 	movl   $0x807000,0x4(%esp)
  8024b5:	00 
  8024b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024b9:	89 04 24             	mov    %eax,(%esp)
  8024bc:	e8 84 e6 ff ff       	call   800b45 <memmove>
		*addrlen = ret->ret_addrlen;
  8024c1:	8b 16                	mov    (%esi),%edx
  8024c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8024c6:	89 10                	mov    %edx,(%eax)
	}
	return r;
}
  8024c8:	89 d8                	mov    %ebx,%eax
  8024ca:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8024cd:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8024d0:	89 ec                	mov    %ebp,%esp
  8024d2:	5d                   	pop    %ebp
  8024d3:	c3                   	ret    

008024d4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8024d4:	55                   	push   %ebp
  8024d5:	89 e5                	mov    %esp,%ebp
  8024d7:	56                   	push   %esi
  8024d8:	53                   	push   %ebx
  8024d9:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8024dc:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8024df:	8b 1d 00 40 80 00    	mov    0x804000,%ebx
  8024e5:	e8 7d eb ff ff       	call   801067 <sys_getenvid>
  8024ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8024ed:	89 54 24 10          	mov    %edx,0x10(%esp)
  8024f1:	8b 55 08             	mov    0x8(%ebp),%edx
  8024f4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8024f8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8024fc:	89 44 24 04          	mov    %eax,0x4(%esp)
  802500:	c7 04 24 fc 2f 80 00 	movl   $0x802ffc,(%esp)
  802507:	e8 0d dd ff ff       	call   800219 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80250c:	89 74 24 04          	mov    %esi,0x4(%esp)
  802510:	8b 45 10             	mov    0x10(%ebp),%eax
  802513:	89 04 24             	mov    %eax,(%esp)
  802516:	e8 9d dc ff ff       	call   8001b8 <vcprintf>
	cprintf("\n");
  80251b:	c7 04 24 7c 2f 80 00 	movl   $0x802f7c,(%esp)
  802522:	e8 f2 dc ff ff       	call   800219 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802527:	cc                   	int3   
  802528:	eb fd                	jmp    802527 <_panic+0x53>
	...

0080252c <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  80252c:	55                   	push   %ebp
  80252d:	89 e5                	mov    %esp,%ebp
  80252f:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  802532:	83 3d 00 80 80 00 00 	cmpl   $0x0,0x808000
  802539:	75 54                	jne    80258f <set_pgfault_handler+0x63>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_U|PTE_P|PTE_W)) < 0)
  80253b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  802542:	00 
  802543:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  80254a:	ee 
  80254b:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  802552:	e8 66 ea ff ff       	call   800fbd <sys_page_alloc>
  802557:	85 c0                	test   %eax,%eax
  802559:	79 20                	jns    80257b <set_pgfault_handler+0x4f>
			panic ("set_pgfault_handler: %e", r);
  80255b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80255f:	c7 44 24 08 20 30 80 	movl   $0x803020,0x8(%esp)
  802566:	00 
  802567:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  80256e:	00 
  80256f:	c7 04 24 38 30 80 00 	movl   $0x803038,(%esp)
  802576:	e8 59 ff ff ff       	call   8024d4 <_panic>
		sys_env_set_pgfault_upcall (0, _pgfault_upcall);
  80257b:	c7 44 24 04 9c 25 80 	movl   $0x80259c,0x4(%esp)
  802582:	00 
  802583:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80258a:	e8 15 e9 ff ff       	call   800ea4 <sys_env_set_pgfault_upcall>

			//panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80258f:	8b 45 08             	mov    0x8(%ebp),%eax
  802592:	a3 00 80 80 00       	mov    %eax,0x808000
}
  802597:	c9                   	leave  
  802598:	c3                   	ret    
  802599:	00 00                	add    %al,(%eax)
	...

0080259c <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80259c:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80259d:	a1 00 80 80 00       	mov    0x808000,%eax
	call *%eax
  8025a2:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8025a4:	83 c4 04             	add    $0x4,%esp
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.

	movl 0x30(%esp), %eax
  8025a7:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $0x4, %eax
  8025ab:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  8025ae:	89 44 24 30          	mov    %eax,0x30(%esp)
	# put old eip in the pre-reserved 4 bytes space
	movl 0x28(%esp), %ebx
  8025b2:	8b 5c 24 28          	mov    0x28(%esp),%ebx
	movl %ebx, (%eax)
  8025b6:	89 18                	mov    %ebx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	
	addl $0x8, %esp
  8025b8:	83 c4 08             	add    $0x8,%esp
	popal
  8025bb:	61                   	popa   
	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.

	addl $0x4, %esp
  8025bc:	83 c4 04             	add    $0x4,%esp
	popfl
  8025bf:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	pop %esp
  8025c0:	5c                   	pop    %esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret
  8025c1:	c3                   	ret    
	...

008025c4 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025c4:	55                   	push   %ebp
  8025c5:	89 e5                	mov    %esp,%ebp
	pte_t pte;

	if (!(vpd[PDX(v)] & PTE_P))
  8025c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8025ca:	89 c2                	mov    %eax,%edx
  8025cc:	c1 ea 16             	shr    $0x16,%edx
  8025cf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8025d6:	f6 c2 01             	test   $0x1,%dl
  8025d9:	74 20                	je     8025fb <pageref+0x37>
		return 0;
	pte = vpt[PGNUM(v)];
  8025db:	c1 e8 0c             	shr    $0xc,%eax
  8025de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8025e5:	a8 01                	test   $0x1,%al
  8025e7:	74 12                	je     8025fb <pageref+0x37>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8025e9:	c1 e8 0c             	shr    $0xc,%eax
  8025ec:	ba 00 00 00 ef       	mov    $0xef000000,%edx
  8025f1:	0f b7 44 c2 04       	movzwl 0x4(%edx,%eax,8),%eax
  8025f6:	0f b7 c0             	movzwl %ax,%eax
  8025f9:	eb 05                	jmp    802600 <pageref+0x3c>
  8025fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802600:	5d                   	pop    %ebp
  802601:	c3                   	ret    
	...

00802610 <__udivdi3>:
  802610:	55                   	push   %ebp
  802611:	89 e5                	mov    %esp,%ebp
  802613:	57                   	push   %edi
  802614:	56                   	push   %esi
  802615:	83 ec 10             	sub    $0x10,%esp
  802618:	8b 45 14             	mov    0x14(%ebp),%eax
  80261b:	8b 55 08             	mov    0x8(%ebp),%edx
  80261e:	8b 75 10             	mov    0x10(%ebp),%esi
  802621:	8b 7d 0c             	mov    0xc(%ebp),%edi
  802624:	85 c0                	test   %eax,%eax
  802626:	89 55 f0             	mov    %edx,-0x10(%ebp)
  802629:	75 35                	jne    802660 <__udivdi3+0x50>
  80262b:	39 fe                	cmp    %edi,%esi
  80262d:	77 61                	ja     802690 <__udivdi3+0x80>
  80262f:	85 f6                	test   %esi,%esi
  802631:	75 0b                	jne    80263e <__udivdi3+0x2e>
  802633:	b8 01 00 00 00       	mov    $0x1,%eax
  802638:	31 d2                	xor    %edx,%edx
  80263a:	f7 f6                	div    %esi
  80263c:	89 c6                	mov    %eax,%esi
  80263e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  802641:	31 d2                	xor    %edx,%edx
  802643:	89 f8                	mov    %edi,%eax
  802645:	f7 f6                	div    %esi
  802647:	89 c7                	mov    %eax,%edi
  802649:	89 c8                	mov    %ecx,%eax
  80264b:	f7 f6                	div    %esi
  80264d:	89 c1                	mov    %eax,%ecx
  80264f:	89 fa                	mov    %edi,%edx
  802651:	89 c8                	mov    %ecx,%eax
  802653:	83 c4 10             	add    $0x10,%esp
  802656:	5e                   	pop    %esi
  802657:	5f                   	pop    %edi
  802658:	5d                   	pop    %ebp
  802659:	c3                   	ret    
  80265a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802660:	39 f8                	cmp    %edi,%eax
  802662:	77 1c                	ja     802680 <__udivdi3+0x70>
  802664:	0f bd d0             	bsr    %eax,%edx
  802667:	83 f2 1f             	xor    $0x1f,%edx
  80266a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80266d:	75 39                	jne    8026a8 <__udivdi3+0x98>
  80266f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  802672:	0f 86 a0 00 00 00    	jbe    802718 <__udivdi3+0x108>
  802678:	39 f8                	cmp    %edi,%eax
  80267a:	0f 82 98 00 00 00    	jb     802718 <__udivdi3+0x108>
  802680:	31 ff                	xor    %edi,%edi
  802682:	31 c9                	xor    %ecx,%ecx
  802684:	89 c8                	mov    %ecx,%eax
  802686:	89 fa                	mov    %edi,%edx
  802688:	83 c4 10             	add    $0x10,%esp
  80268b:	5e                   	pop    %esi
  80268c:	5f                   	pop    %edi
  80268d:	5d                   	pop    %ebp
  80268e:	c3                   	ret    
  80268f:	90                   	nop
  802690:	89 d1                	mov    %edx,%ecx
  802692:	89 fa                	mov    %edi,%edx
  802694:	89 c8                	mov    %ecx,%eax
  802696:	31 ff                	xor    %edi,%edi
  802698:	f7 f6                	div    %esi
  80269a:	89 c1                	mov    %eax,%ecx
  80269c:	89 fa                	mov    %edi,%edx
  80269e:	89 c8                	mov    %ecx,%eax
  8026a0:	83 c4 10             	add    $0x10,%esp
  8026a3:	5e                   	pop    %esi
  8026a4:	5f                   	pop    %edi
  8026a5:	5d                   	pop    %ebp
  8026a6:	c3                   	ret    
  8026a7:	90                   	nop
  8026a8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8026ac:	89 f2                	mov    %esi,%edx
  8026ae:	d3 e0                	shl    %cl,%eax
  8026b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8026b3:	b8 20 00 00 00       	mov    $0x20,%eax
  8026b8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8026bb:	89 c1                	mov    %eax,%ecx
  8026bd:	d3 ea                	shr    %cl,%edx
  8026bf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8026c3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8026c6:	d3 e6                	shl    %cl,%esi
  8026c8:	89 c1                	mov    %eax,%ecx
  8026ca:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8026cd:	89 fe                	mov    %edi,%esi
  8026cf:	d3 ee                	shr    %cl,%esi
  8026d1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8026d5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8026d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8026db:	d3 e7                	shl    %cl,%edi
  8026dd:	89 c1                	mov    %eax,%ecx
  8026df:	d3 ea                	shr    %cl,%edx
  8026e1:	09 d7                	or     %edx,%edi
  8026e3:	89 f2                	mov    %esi,%edx
  8026e5:	89 f8                	mov    %edi,%eax
  8026e7:	f7 75 ec             	divl   -0x14(%ebp)
  8026ea:	89 d6                	mov    %edx,%esi
  8026ec:	89 c7                	mov    %eax,%edi
  8026ee:	f7 65 e8             	mull   -0x18(%ebp)
  8026f1:	39 d6                	cmp    %edx,%esi
  8026f3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8026f6:	72 30                	jb     802728 <__udivdi3+0x118>
  8026f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8026fb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8026ff:	d3 e2                	shl    %cl,%edx
  802701:	39 c2                	cmp    %eax,%edx
  802703:	73 05                	jae    80270a <__udivdi3+0xfa>
  802705:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  802708:	74 1e                	je     802728 <__udivdi3+0x118>
  80270a:	89 f9                	mov    %edi,%ecx
  80270c:	31 ff                	xor    %edi,%edi
  80270e:	e9 71 ff ff ff       	jmp    802684 <__udivdi3+0x74>
  802713:	90                   	nop
  802714:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802718:	31 ff                	xor    %edi,%edi
  80271a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80271f:	e9 60 ff ff ff       	jmp    802684 <__udivdi3+0x74>
  802724:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802728:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80272b:	31 ff                	xor    %edi,%edi
  80272d:	89 c8                	mov    %ecx,%eax
  80272f:	89 fa                	mov    %edi,%edx
  802731:	83 c4 10             	add    $0x10,%esp
  802734:	5e                   	pop    %esi
  802735:	5f                   	pop    %edi
  802736:	5d                   	pop    %ebp
  802737:	c3                   	ret    
	...

00802740 <__umoddi3>:
  802740:	55                   	push   %ebp
  802741:	89 e5                	mov    %esp,%ebp
  802743:	57                   	push   %edi
  802744:	56                   	push   %esi
  802745:	83 ec 20             	sub    $0x20,%esp
  802748:	8b 55 14             	mov    0x14(%ebp),%edx
  80274b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80274e:	8b 7d 10             	mov    0x10(%ebp),%edi
  802751:	8b 75 0c             	mov    0xc(%ebp),%esi
  802754:	85 d2                	test   %edx,%edx
  802756:	89 c8                	mov    %ecx,%eax
  802758:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80275b:	75 13                	jne    802770 <__umoddi3+0x30>
  80275d:	39 f7                	cmp    %esi,%edi
  80275f:	76 3f                	jbe    8027a0 <__umoddi3+0x60>
  802761:	89 f2                	mov    %esi,%edx
  802763:	f7 f7                	div    %edi
  802765:	89 d0                	mov    %edx,%eax
  802767:	31 d2                	xor    %edx,%edx
  802769:	83 c4 20             	add    $0x20,%esp
  80276c:	5e                   	pop    %esi
  80276d:	5f                   	pop    %edi
  80276e:	5d                   	pop    %ebp
  80276f:	c3                   	ret    
  802770:	39 f2                	cmp    %esi,%edx
  802772:	77 4c                	ja     8027c0 <__umoddi3+0x80>
  802774:	0f bd ca             	bsr    %edx,%ecx
  802777:	83 f1 1f             	xor    $0x1f,%ecx
  80277a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80277d:	75 51                	jne    8027d0 <__umoddi3+0x90>
  80277f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  802782:	0f 87 e0 00 00 00    	ja     802868 <__umoddi3+0x128>
  802788:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80278b:	29 f8                	sub    %edi,%eax
  80278d:	19 d6                	sbb    %edx,%esi
  80278f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  802792:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802795:	89 f2                	mov    %esi,%edx
  802797:	83 c4 20             	add    $0x20,%esp
  80279a:	5e                   	pop    %esi
  80279b:	5f                   	pop    %edi
  80279c:	5d                   	pop    %ebp
  80279d:	c3                   	ret    
  80279e:	66 90                	xchg   %ax,%ax
  8027a0:	85 ff                	test   %edi,%edi
  8027a2:	75 0b                	jne    8027af <__umoddi3+0x6f>
  8027a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8027a9:	31 d2                	xor    %edx,%edx
  8027ab:	f7 f7                	div    %edi
  8027ad:	89 c7                	mov    %eax,%edi
  8027af:	89 f0                	mov    %esi,%eax
  8027b1:	31 d2                	xor    %edx,%edx
  8027b3:	f7 f7                	div    %edi
  8027b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8027b8:	f7 f7                	div    %edi
  8027ba:	eb a9                	jmp    802765 <__umoddi3+0x25>
  8027bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027c0:	89 c8                	mov    %ecx,%eax
  8027c2:	89 f2                	mov    %esi,%edx
  8027c4:	83 c4 20             	add    $0x20,%esp
  8027c7:	5e                   	pop    %esi
  8027c8:	5f                   	pop    %edi
  8027c9:	5d                   	pop    %ebp
  8027ca:	c3                   	ret    
  8027cb:	90                   	nop
  8027cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027d0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027d4:	d3 e2                	shl    %cl,%edx
  8027d6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8027d9:	ba 20 00 00 00       	mov    $0x20,%edx
  8027de:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8027e1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8027e4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8027e8:	89 fa                	mov    %edi,%edx
  8027ea:	d3 ea                	shr    %cl,%edx
  8027ec:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8027f0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8027f3:	d3 e7                	shl    %cl,%edi
  8027f5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8027f9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8027fc:	89 f2                	mov    %esi,%edx
  8027fe:	89 7d e8             	mov    %edi,-0x18(%ebp)
  802801:	89 c7                	mov    %eax,%edi
  802803:	d3 ea                	shr    %cl,%edx
  802805:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802809:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80280c:	89 c2                	mov    %eax,%edx
  80280e:	d3 e6                	shl    %cl,%esi
  802810:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802814:	d3 ea                	shr    %cl,%edx
  802816:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80281a:	09 d6                	or     %edx,%esi
  80281c:	89 f0                	mov    %esi,%eax
  80281e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  802821:	d3 e7                	shl    %cl,%edi
  802823:	89 f2                	mov    %esi,%edx
  802825:	f7 75 f4             	divl   -0xc(%ebp)
  802828:	89 d6                	mov    %edx,%esi
  80282a:	f7 65 e8             	mull   -0x18(%ebp)
  80282d:	39 d6                	cmp    %edx,%esi
  80282f:	72 2b                	jb     80285c <__umoddi3+0x11c>
  802831:	39 c7                	cmp    %eax,%edi
  802833:	72 23                	jb     802858 <__umoddi3+0x118>
  802835:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  802839:	29 c7                	sub    %eax,%edi
  80283b:	19 d6                	sbb    %edx,%esi
  80283d:	89 f0                	mov    %esi,%eax
  80283f:	89 f2                	mov    %esi,%edx
  802841:	d3 ef                	shr    %cl,%edi
  802843:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  802847:	d3 e0                	shl    %cl,%eax
  802849:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80284d:	09 f8                	or     %edi,%eax
  80284f:	d3 ea                	shr    %cl,%edx
  802851:	83 c4 20             	add    $0x20,%esp
  802854:	5e                   	pop    %esi
  802855:	5f                   	pop    %edi
  802856:	5d                   	pop    %ebp
  802857:	c3                   	ret    
  802858:	39 d6                	cmp    %edx,%esi
  80285a:	75 d9                	jne    802835 <__umoddi3+0xf5>
  80285c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80285f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  802862:	eb d1                	jmp    802835 <__umoddi3+0xf5>
  802864:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802868:	39 f2                	cmp    %esi,%edx
  80286a:	0f 82 18 ff ff ff    	jb     802788 <__umoddi3+0x48>
  802870:	e9 1d ff ff ff       	jmp    802792 <__umoddi3+0x52>
